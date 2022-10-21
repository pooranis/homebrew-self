class Cpdf < Formula
  desc "The Coherent PDF Command Line Tools allow you to manipulate existing PDF files in a variety of ways.  Free for non-commercial, private, personal use.  See homepage for more information."
  homepage "https://community.coherentpdf.com/"
  version "2.5.2"
  # url "https://github.com/coherentgraphics/cpdf-binaries/archive/master.zip"
  url "https://github.com/coherentgraphics/cpdf-binaries/archive/v#{version}.zip"
  sha256 "147414eba50313ad459dd17f884d922355e3abc4efc67c79177f28f1a0c9a0d5"
  license :cannot_represent


  def install
    bin.install "OSX-Intel/cpdf"
    doc.install "cpdfmanual.pdf"
    doc.install "README.md"
  end

end
