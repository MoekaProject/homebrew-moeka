# ci: 使用 Homebrew livecheck 自动更新 Moeka cask

## 摘要

本 PR 让 tap 每小时用 Homebrew 自带的 `livecheck` 检测
[`MoekaProject/community`](https://github.com/MoekaProject/community)
的最新正式版，检测到新版本后调用官方
`brew bump-cask-pr --write-only` 下载 DMG、计算双架构 SHA-256，
更新 `Casks/moeka.rb` 并自动提交推送。

- 有新版本：自动发版，不需要维护者手动操作；
- 已是最新：直接跳过，不产生提交；
- 不新增 secret，只使用仓库自带的 `GITHUB_TOKEN`；
- 完整的版本检测、下载和校验和计算都由 Homebrew 官方 Ruby 工具完成。

本 PR 中的 cask 已经更新到 **0.1.29**，并新增了明确的 `livecheck` 块。

## 背景与动机

目前 tap 停留在 `0.1.11`，而 `MoekaProject/community` 已经发布到
`v0.1.29`。README 中描述的源码仓库发版同步流程没有实际运行
（源码仓库也不公开），导致 tap 长期落后。

本方案把自动化完全放在 tap 仓库内：

- 只依赖公开的 Release 信息和发布资产；
- 不依赖私有源码仓库的 CI 或 secret；
- 脚本幂等，推送前先 `git pull --rebase`，
  即使源码仓库的同步流程恢复，也不会互相覆盖。

## 为什么不能只用 cask 的 .rb 文件

`.rb` 是声明式的安装配方，本身不会定时运行，也无法自行提交更新。
Homebrew 提供的原生机制是：

- `livecheck`：负责检测上游最新版本；
- `brew bump-cask-pr`：负责下载、计算 SHA-256 并改写 cask。

本机实测发现：**原 cask 没有 `livecheck` 块时无法可靠检测**
（默认策略会走 `git ls-remote`，实测超时并返回
`Unable to get versions`）。补上标准 livecheck 块后，
`brew livecheck` 正确报告 `0.1.11 -> 0.1.29`。

`brew bump-cask-pr` 必须显式传入目标版本，因此最终结构是：

```
GitHub Actions 定时触发
        ↓
brew livecheck（检测版本，失败时用 GitHub API 兜底）
        ↓
brew bump-cask-pr --write-only --version X（官方实现负责下载和 SHA-256）
        ↓
git commit + push
```

这样既保留了 Homebrew 成熟的 Ruby 工具链，又满足「全自动发版」的目标。

## 本 PR 的改动

| 文件 | 用途 |
| --- | --- |
| `Casks/moeka.rb` | 新增 `livecheck` 块；更新到 0.1.29，写入实际计算的 SHA-256 |
| `.github/workflows/auto-bump-moeka.yml` | 每小时定时 + 手动触发；检测版本并在有新版本时调用 Homebrew 更新、提交、推送 |

## 工作原理

1. workflow 每小时运行一次（`cron: "0 * * * *"`），也支持 Actions 页手动触发。
2. 把当前 checkout 注册为 `moekaproject/moeka` tap，并在 Homebrew 7 下执行 `brew trust`。
3. `brew livecheck` 根据 cask 的 `strategy :github_releases` 查询最新正式版。
4. 如果 livecheck 不可用（例如源码模板覆盖了 cask、丢失 livecheck 块），
   自动回退到 GitHub API 的 `releases/latest`。
5. 只有确认新版本更新时，才执行：

   ```sh
   brew bump-cask-pr --write-only --no-audit --no-style \
     --version "$VERSION" moekaproject/moeka/moeka
   ```

   Homebrew 会下载 arm64 和 x86_64 两个 DMG，计算 SHA-256 并改写 cask。
6. 有文件变化时提交并推送；没有变化则直接退出，不产生空提交。

## 安全性与可靠性

- **不新增密钥。** 使用 Actions 临时的 `GITHUB_TOKEN`，
  通过 `permissions: contents: write` 限定在本仓库。
- **不手写 SHA-256 逻辑。** 下载和校验和全部由 Homebrew 官方实现完成。
- **失败即停止。** livecheck 和 GitHub API 都不可用、版本解析失败时任务会报错。
- **不会发布旧版本。** 兜底路径会做语义化版本比较，只在确实更新时继续。
- **无重复提交。** 已是最新时不会产生提交，也不会空跑失败。
- **并发安全。** `concurrency` 防止任务重叠；推送前 rebase，兼容其他自动化。
- **只使用官方 action。** 除 `actions/checkout@v4` 外，
  使用 Homebrew 官方 action 和命令。

## 本机验证结果

- 未加 livecheck 时：`brew livecheck` 返回
  `Unable to get versions`（`git ls-remote timed out`）。
- 加 livecheck 后：正确返回 `current: 0.1.11`、`latest: 0.1.29`、`outdated: true`。
- 官方 `brew bump-cask-pr --write-only --version 0.1.29` 执行成功，
  生成的文件与独立下载计算的结果完全一致：

  ```text
  arm64   c579ed1b2909d730ed390f6efcf469095808ff00f92821939fde5963eaacdeae
  x86_64  da1f7dfdadea684551280e6c34c656bdaec3d800ea6c378d69bb69c5769c4acc
  ```

- 两个资产的字节数分别为 `21304110` 和 `23181634`，与 GitHub API 一致。
- 检测逻辑的四条路径全部验证通过：
  - 0.1.29 已是最新 → 不更新；
  - 上游 tap 0.1.11 → 检测到 0.1.29；
  - livecheck 人为失败 → API 兜底检测到 0.1.29；
  - 兜底时版本相等 → 不更新。
- workflow YAML 解析通过，所有 shell 步骤通过 `bash -n`；
  更新后的 cask 通过 `ruby -c`。

## 维护者验证指南

以下命令可直接复制执行。文中的版本号、校验和与文件大小对应
`v0.1.29`（截至 2026-10-25）；如果审核时已有更新的 Release，
脚本会自然地使用那个更新的版本。

### 1. 静态检查（不联网）

```sh
bash -n <(ruby -ryaml -e '
  y = YAML.load_file(".github/workflows/auto-bump-moeka.yml");
  y["jobs"]["bump"]["steps"].each { |s| puts s["run"] if s["run"] }
')
ruby -c Casks/moeka.rb
ruby -ryaml -e 'YAML.load_file(".github/workflows/auto-bump-moeka.yml"); puts "yaml ok"'
```

预期：`bash -n` 不输出内容，Ruby 输出 `Syntax OK` 和 `yaml ok`。

### 2. 在本机注册临时 tap，验证版本检测

用临时副本把版本改成 `0.1.11`，避免改动当前工作区：

```sh
review_parent="$(mktemp -d)"
review_dir="${review_parent}/homebrew-moeka"
git clone . "${review_dir}"
sed -i '' -E 's/^([[:space:]]*version[[:space:]]*)"[^"]*"/\1"0.1.11"/' \
  "${review_dir}/Casks/moeka.rb"

mkdir -p "$(brew --repository)/Library/Taps/moeka-review"
ln -sfn "${review_dir}" \
  "$(brew --repository)/Library/Taps/moeka-review/homebrew-moeka"

brew trust moeka-review/moeka
HOMEBREW_NO_INSTALL_FROM_API=1 \
  brew livecheck --cask moeka-review/moeka/moeka --json
```

预期输出（节选）：

```json
{
  "version": {
    "current": "0.1.11",
    "latest": "0.1.29",
    "outdated": true
  }
}
```

### 3. 验证官方 bump 流程

继续使用上面的临时 tap：

```sh
HOMEBREW_NO_INSTALL_FROM_API=1 \
brew bump-cask-pr --write-only --no-audit --no-style \
  --version 0.1.29 moeka-review/moeka/moeka

git -C "${review_dir}" diff -- Casks/moeka.rb
```

预期 diff：`version` 变为 `0.1.29`，两个 `sha256` 变为上面的值，
`livecheck` 块保持不变。

> 第一次运行 `bump-cask-pr` 时，Homebrew 可能会安装它自己的 Ruby gem
> 并下载约 44 MB 的 DMG，这是官方工具的正常行为。

### 4. 独立复算校验和

```sh
for arch in arm64 x86_64; do
  curl -fsSL -o "/tmp/Moeka-macos-${arch}.dmg" \
    "https://github.com/MoekaProject/community/releases/download/v0.1.29/Moeka-macos-${arch}.dmg"
  shasum -a 256 "/tmp/Moeka-macos-${arch}.dmg"
done
```

预期：

```text
c579ed1b2909d730ed390f6efcf469095808ff00f92821939fde5963eaacdeae  /tmp/Moeka-macos-arm64.dmg
da1f7dfdadea684551280e6c34c656bdaec3d800ea6c378d69bb69c5769c4acc  /tmp/Moeka-macos-x86_64.dmg
```

核对 cask：

```sh
sed -n '4,6p' Casks/moeka.rb
```

文件大小也可通过 API 核对：

```sh
curl -sSL https://api.github.com/repos/MoekaProject/community/releases/latest \
  | jq -r '.assets[] | select(.name | test("macos.*dmg")) | "\(.name) \(.size) 字节"'
```

0.1.29 的预期结果：`Moeka-macos-arm64.dmg 21304110 字节`、
`Moeka-macos-x86_64.dmg 23181634 字节`。

### 5. 验证 workflow（不产生副作用）

1. 把本分支推送到 fork（手动触发要求 workflow 文件存在于该 fork 的默认分支）。
2. 打开 fork 的 **Actions → Auto-bump Moeka cask → Run workflow**。
3. 将 `dry_run` 设为 **true** 并运行。
4. 预期：日志显示当前版本和检测结果，最后输出
   `Cask unchanged; nothing to push.`，不会产生提交。

如果想完整看到一次真实 bump，可在 fork 的临时分支中把版本改回 0.1.11
再运行（`dry_run=false`），验证完成后删除该分支即可。

### 6. cask 安装检查

```sh
brew install --cask ./Casks/moeka.rb
brew uninstall --cask moeka
```

若本机已经安装 Moeka，可改用：

```sh
brew reinstall --cask --force ./Casks/moeka.rb
```

### 7. 清理临时 tap

```sh
unlink "$(brew --repository)/Library/Taps/moeka-review/homebrew-moeka"
rm -rf "${review_parent}"
```

## 仓库权限设置

自动推送需要 **Settings → Actions → General → Workflow permissions →
Read and write permissions**。如果 `main` 禁止直接推送，
可以放行 GitHub Actions bot，或把最后一步替换为
`brew bump-cask-pr` 的 PR 流程；检测逻辑无需改动。

## 回滚方式

在 Actions 页面停用该 workflow，或回滚 workflow 所在的提交。
0.1.29 的 cask 更新是独立内容，可以单独回滚。

## 审核清单

- [ ] workflow YAML 解析通过，所有 shell 步骤通过 `bash -n`。
- [ ] `ruby -c Casks/moeka.rb` 通过。
- [ ] 临时 tap 上 `brew livecheck` 能从 0.1.11 检测到 0.1.29。
- [ ] `brew bump-cask-pr --write-only` 生成的校验和与 cask 一致。
- [ ] 独立下载复算的校验和一致。
- [ ] workflow 的 dry run 不产生提交。
- [ ] 仓库允许 workflow 使用 `contents: write` 权限。
