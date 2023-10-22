class Cpdf < Formula
  desc "The Coherent PDF Command Line Tools allow you to manipulate existing PDF files in a variety of ways.  Free for non-commercial, private, personal use.  See homepage for more information.  See https://github.com/coherentgraphics/cpdf-binaries/blob/master/LICENSE for licensing"
  homepage "https://community.coherentpdf.com/"
  version "2.6.1"
  url "https://github.com/coherentgraphics/cpdf-binaries/archive/refs/tags/v#{version}.zip"
  sha256 "eabec23dcc4f64cfb4e003e3c85cd6460805982b73f22e316639e3a2143d9444"
  license :cannot_represent


  def install
    bin.install "OSX-Intel/cpdf"
    doc.install "cpdfmanual.pdf"
    doc.install "README.md"
  end

end
