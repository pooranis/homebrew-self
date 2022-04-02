# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://www.rubydoc.info/github/Homebrew/brew/master/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Cpdf < Formula
  desc "The Coherent PDF Command Line Tools allow you to manipulate existing PDF files in a variety of ways.  Free for non-commercial, private, personal use.  See homepage for more information."
  homepage "https://community.coherentpdf.com/"
  version "v2.5.1"
  url "https://github.com/coherentgraphics/cpdf-binaries/archive/#{version}.zip"
  sha256 "54b9364d8f07a913bece4af30ff36f48e949f9c4b11445e350d8c109d5168dd8"
  license :cannot_represent

  
  def install
    bin.install "OSX-Intel/cpdf"
    doc.install "cpdfmanual.pdf"
    doc.install "README.md"
  end

end
