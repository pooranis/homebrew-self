class Pdfjam < Formula
  desc "Shell scripts providing a simple interface to latex's pdfpages."
  homepage "http://www2.warwick.ac.uk/fac/sci/statistics/staff/academic-research/firth/software/pdfjam/"
  url "https://www2.warwick.ac.uk/fac/sci/statistics/staff/academic/firth/software/pdfjam/pdfjam_208.tgz"
  sha256 "c731c598cfad076c985526ff89cbf34423a216101aa5e2d753a71de119ecc0f3"

  def install
    ## use letterpaper size by default
    inreplace "pdfjam.conf" do |s|
      s.gsub! /paper='a4paper'/, "# paper='a4paper'"
      s.gsub! /# paper='letterpaper'/, "paper='letterpaper'"
    end

    prefix.install "bin"
    share.mkpathb
    share.install "pdfjam.conf"
    man.mkpath
    man1.install Dir["man1/*"]
  end
end
