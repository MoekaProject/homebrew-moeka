cask "moeka" do
  arch arm: "arm64", intel: "x86_64"

  version "0.1.29"
  sha256 arm:   "c579ed1b2909d730ed390f6efcf469095808ff00f92821939fde5963eaacdeae",
         intel: "da1f7dfdadea684551280e6c34c656bdaec3d800ea6c378d69bb69c5769c4acc"

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
