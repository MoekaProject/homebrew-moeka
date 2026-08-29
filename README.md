# Homebrew Cask

`Casks/moeka.rb` tracks the signed, notarized architecture-specific DMGs in the public release repository.

Install Moeka with:

```sh
brew tap MoekaProject/moeka
brew install --cask moeka
```

The markdown-editor source repository keeps the cask template at `packaging/homebrew/moeka.rb`. Its release workflow copies that template to this tap and updates `version` and both SHA-256 values after the DMGs are uploaded.

For source-repository local validation:

```sh
brew install --cask ./packaging/homebrew/moeka.rb
brew uninstall --cask moeka
```
