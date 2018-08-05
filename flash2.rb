class Flash2 < Formula
  desc "Flash2 has some improvements from FLASh 1 read merger (https://ccb.jhu.edu/software/FLASH/) including new logic from innie and outie overlaps as well as some initial steps for flash for amplicons"
  homepage "https://github.com/dstreett/FLASH2"
  url "https://github.com/dstreett/FLASH2/archive/2.2.00.tar.gz"
  sha256 "7bb357a935de87be8a294b35ed281eca2e08afa1e1a1d1b1c24a024b80b713ff"

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    # Remove unrecognized options if warned by configure
    # system "cmake", ".", *std_cmake_args
    system "make" # if this fails, try separate make/make install steps
    bin.install "flash2"
  end
end
