class Mummer4 < Formula
  desc "MUMmer alignment tool "
  homepage "https://github.com/mummer4/mummer"
  url "https://github.com/mummer4/mummer/releases/download/v4.0.0beta2/mummer-4.0.0beta2.tar.gz"
  sha256 "cece76e418bf9c294f348972e5b23a0230beeba7fd7d042d5584ce075ccd1b93"
  version "4.0.0beta2"

  depends_on "gcc" => :build
  fails_with :clang ## we want to build with homebrew gcc https://github.com/mummer4/mummer/blob/master/INSTALL.md#dependencies
  
  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    # Remove unrecognized options if warned by configure
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install" # if this fails, try separate make/make install steps

    ## remove annotate as it is deprecated: https://github.com/mummer4/mummer/blob/master/MANUAL.md#annotate
    rm_f "#{bin}/annotate"
  end
end
