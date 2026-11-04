cask "moeka" do
  arch arm: "arm64", intel: "x86_64"

  version "0.1.34"
  sha256 arm:   "ac10943347a91d5be59a815b3d0008db4389b40e62fd022dfb728c8320474087",
         intel: "e873d1267ba92c6b23f4cf4eef91c581ea3165556e11cd5784fe9f8f10d2b9f2"

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
