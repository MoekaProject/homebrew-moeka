cask "moeka" do
  arch arm: "arm64", intel: "x86_64"

  version "0.1.31"
  sha256 arm:   "4f7b9eeba2b9c486a221c4d614ba0ad00d67f59cfd04677e86e1feb83cb64046",
         intel: "db6b3a3890496cee4a3ca3a003a399cf289a07f616d208135ae4a95bcca7ac44"

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
