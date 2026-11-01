cask "moeka" do
  arch arm: "arm64", intel: "x86_64"

  version "0.1.32"
  sha256 arm:   "875103f03b1af88caf692f13aed4d48b92e79549b95ef6557cf575b367dccfe2",
         intel: "ecd2c93aaaa3b6309feb895a5fab6d77856e87d37cd46189d10fc9204f6aeb8f"

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
