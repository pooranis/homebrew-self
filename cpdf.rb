# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://www.rubydoc.info/github/Homebrew/brew/master/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Cpdf < Formula
  desc "The Coherent PDF Command Line Tools allow you to manipulate existing PDF files in a variety of ways.  Free for non-commercial use."
  homepage "https://community.coherentpdf.com/"
  url "https://github.com/coherentgraphics/cpdf-binaries/archive/master.zip"
  version "v2.2-patchlevel1"
  sha256 "fd5c7c3cd46627a187e19906b5b4876eb4ace594a663f9f018ffab02216f8216"

  def install
    bin.install "OSX-Intel/cpdf"
  end

end
