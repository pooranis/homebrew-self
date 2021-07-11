# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://www.rubydoc.info/github/Homebrew/brew/master/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Cpdf < Formula
  desc "The Coherent PDF Command Line Tools allow you to manipulate existing PDF files in a variety of ways.  Free for non-commercial, private, personal use.  See homepage for more information."
  homepage "https://community.coherentpdf.com/"
  version "v2.4"
  url "https://github.com/coherentgraphics/cpdf-binaries/archive/#{version}.zip"
  sha256 "b11748ebfc6de41a5638b1ee0a13c5ee21565a56a429f1dd5e9c603f7fe83346"

  def install
    bin.install "OSX-Intel/cpdf"
    doc.install "cpdfmanual.pdf"
    doc.install "README.md"
  end

end
