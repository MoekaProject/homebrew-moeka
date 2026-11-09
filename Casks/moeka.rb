cask "moeka" do
  arch arm: "arm64", intel: "x86_64"

  version "0.1.37"
  sha256 arm:   "843242cefe353d70529a204762c30828a2bd1a2c3a3bce3572481411a78b5ef7",
         intel: "6e082fc42c9b1ff3469408a5648fd5b35258f6c9736faab4b88e5311f6b79a47"

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
