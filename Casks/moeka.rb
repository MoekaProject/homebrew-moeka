cask "moeka" do
  arch arm: "arm64", intel: "x86_64"

  version "0.1.35"
  sha256 arm:   "49f96162ce78a3ac8e0bb3d580663e39589719daa1bcd49d7295b3256db056d8",
         intel: "fffb631c9fa0f325abf68fea1caa1cafc58db3433600ca96ae182a3e1c30d654"

  url "https://github.com/MoekaProject/community/releases/download/v#{version}/Moeka-macos-#{arch}.dmg"
  name "Moeka"
  desc "Markdown editor"
  homepage "https://moeka.app/"

  livecheck do
    url "https://github.com/MoekaProject/community"
    strategy :github_releases
  end

  auto_updates true
  depends_on macos: :monterey

  app "Moeka.app"
end
