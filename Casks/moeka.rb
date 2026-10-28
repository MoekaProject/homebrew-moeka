cask "moeka" do
  arch arm: "arm64", intel: "x86_64"

  version "0.1.30"
  sha256 arm:   "fc3fc76543f2504626d61024445f5ebe4fa0dae83b115bf61c8a32d5d089097f",
         intel: "ae953d1feaabd382c4f6906d7b6108b5cda0f46455c76c8dc393ceaee8a4b026"

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
