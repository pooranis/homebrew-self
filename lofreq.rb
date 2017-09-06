class Lofreq < Formula
  desc "LoFreq Star: Sensitive variant calling from sequencing data"
  homepage "http://csb5.github.io/lofreq/"
  url "https://github.com/CSB5/lofreq/archive/v2.1.3.1.tar.gz"
  sha256 "72ad0165a226ad8601297d5e01d139574f30d0637c70dec543f8d513c26958eb"

  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "libtool" => :build

  resource "samtools" do
    url "http://downloads.sourceforge.net/project/samtools/samtools/1.1/samtools-1.1.tar.bz2"
    sha256 "c24d26c303153d72b5bf3cc11f72c6c375a4ca1140cc485648c8c5473414b7f8"
  end

  
  
  def install
    # ENV.deparallelize  # if your formula fails when building in parallel

    resource("samtools").stage "#{buildpath}/samtools"
    cd "#{buildpath}/samtools" do
      system "make", "-j4"
    end


    system "glibtoolize"
    system "./bootstrap"
    # Remove unrecognized options if warned by configure
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "SAMTOOLS=#{buildpath}/samtools",
                          "HTSLIB=#{buildpath}/samtools/htslib-1.1"

    
    system "make" # if this fails, try separate make/make install steps
    system "make", "install"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test lofreq`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end


