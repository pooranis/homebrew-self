class Ufasta < Formula
  desc "ufasta: utility to handle fasta files"
  homepage "https://github.com/gmarcais/ufasta"
  url "https://github.com/gmarcais/ufasta/releases/download/v0.0.3/ufasta-0.0.3.tar.gz"
  sha256 "731f01be55074571705c197e48673923c42c0ff980c7bb97945cd7b7dc86d219"
  license "MIT"
  head "https://github.com/gmarcais/ufasta.git", branch: "master"

  depends_on "boost"


  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

end
