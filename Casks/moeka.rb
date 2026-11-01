cask "moeka" do
  arch arm: "arm64", intel: "x86_64"

  version "0.1.33"
  sha256 arm:   "56ae9d5c2923c88afe42b5fc95201b821308a50b47855e4a0995566073853d46",
         intel: "5c8814e420afe52f9eb45e06745fe6d51837119b3fd02cfc27c42fd57a7fcb97"

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
