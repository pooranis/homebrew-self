class Lofreq < Formula
  desc "LoFreq Star: Sensitive variant calling from sequencing data"
  homepage "http://csb5.github.io/lofreq/"
  url "https://github.com/CSB5/lofreq/archive/v2.1.3.1.tar.gz"
  sha256 "72ad0165a226ad8601297d5e01d139574f30d0637c70dec543f8d513c26958eb"

  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "libtool" => :build
  depends_on "htslib" => :build
  depends_on "samtools" => :build

  patch :DATA

  
  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    inreplace "src/lofreq/Makefile.am", "@HTSLIB@/libhts.a", "#{Formula['htslib'].opt_lib}/libhts.a"
    inreplace "src/lofreq/Makefile.am", "@SAMTOOLS@/libbam.a", "#{Formula['samtools'].opt_lib}/libbam.a"

    
    system "glibtoolize"
    system "./bootstrap"
    # Remove unrecognized options if warned by configure
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "SAMTOOLS=#{Formula['samtools'].opt_include}/bam",
                          "HTSLIB=/usr/local/include"

    ENV.append "LDFLAGS", " -L#{HOMEBREW_PREFIX}/lib"
    ENV.append "LDFLAGS", " -lbam"
    ENV.append "LDFLAGS", " -lhts"
    
    system "make", "LDFLAGS=#{ENV.ldflags}" # if this fails, try separate make/make install steps
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

__END__
diff --git a/src/lofreq/bam_md_ext.h b/src/lofreq/bam_md_ext.h
index 2c8d90c..4510787 100644
--- a/src/lofreq/bam_md_ext.h
+++ b/src/lofreq/bam_md_ext.h
@@ -23,6 +23,7 @@
    SOFTWARE.
 */
 
+#undef bam_nt16_nt4_table
 #ifndef BAM_MD_EXT_H
 #define BAM_MD_EXT_H
 
