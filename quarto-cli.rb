class QuartoCli < Formula
  desc "Open-source scientific and technical publishing system built on Pandoc."
  homepage "https://quarto.org/"
  version "0.9.440"
  url "https://github.com/quarto-dev/quarto-cli/releases/download/v#{version}/quarto-#{version}-macos.tar.gz",
      verified: "github.com/quarto-dev/quarto-cli/"
  sha256 "d6c0afa3a99f35e2afcfd863b4f6bbbfe94864f5beacf1c157efca5e7aeb3b14"
  license "GPL-2"

  def install
    inreplace "bin/quarto", '${BASH_SOURCE[0]}', "#{prefix}/libexec/bin/quarto"
    libexec.install "bin/"
    libexec.install "share/"
    bin.install_symlink libexec/"bin/quarto"
  end

end
