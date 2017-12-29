class Muscle < Formula
  desc "Multiple sequence alignment program"
  homepage "https://www.drive5.com/muscle/"
  url "https://www.drive5.com/muscle/downloads3.8.31/muscle3.8.31_src.tar.gz"
  sha256 "43c5966a82133bd7da5921e8142f2f592c2b5f53d802f0527a2801783af809ad"
  # doi "10.1093/nar/gkh340", "10.1186/1471-2105-5-113"
  # tag "bioinformatics"

  def install
    # Fix build per Makefile instructions
    Dir.chdir('src/')
#    inreplace "Makefile", "-static", ""

    system "make"
    bin.install "muscle"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/muscle -version")
  end
end
