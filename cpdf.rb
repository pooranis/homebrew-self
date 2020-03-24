# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://www.rubydoc.info/github/Homebrew/brew/master/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Cpdf < Formula
  desc "The Coherent PDF Command Line Tools allow you to manipulate existing PDF files in a variety of ways.  Free for non-commercial, private, personal use.  See homepage for more information."
  homepage "https://community.coherentpdf.com/"
  version "v2.3.1"
  url "https://github.com/coherentgraphics/cpdf-binaries/archive/#{version}.zip"
  sha256 "3ad7ba576e16582e1f8e0a2a8a9869bf1ce912162dbf8e6d59f123ad6209af22"

  def install
    bin.install "OSX-Intel/Notarized/cpdf"
  end

end
