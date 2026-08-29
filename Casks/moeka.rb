cask "moeka" do
  arch arm: "arm64", intel: "x86_64"

  version "0.1.11"
  sha256 arm:   "03f688af96050cea264413b5608dcf62abd693db5c79665f3e8b7fa42eb799a8",
         intel: "1afbe883d3ae45221b23983068afbad8e55ddd180b0862c18a983be74a0a9eec"

  url "https://github.com/MoekaProject/community/releases/download/v#{version}/Moeka-macos-#{arch}.dmg"
  name "Moeka"
  desc "Markdown editor"
  homepage "https://moeka.app/"

  auto_updates true
  depends_on macos: :monterey

  app "Moeka.app"
end
