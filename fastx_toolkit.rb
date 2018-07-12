class FastxToolkit < Formula
  desc "Process short-read FASTA/FASTQ sequencing files"
  homepage "http://hannonlab.cshl.edu/fastx_toolkit/"
  # tag "bioinformatics"
  version '0.0.14'
  revision 2

  stable do
    url "https://codeload.github.com/pooranis/fastx_toolkit/legacy.tar.gz/master/pooranis-fastx_toolkit-0.0.14-2-g0497a17.tar.gz"
    sha256 "e59ef63e251583a6de02c85c58a462850900df8c9961b8a956f79f68b9ead198"

    resource "libgtextutils" do
      url "https://github.com/agordon/libgtextutils/releases/download/0.7/libgtextutils-0.7.tar.gz"
      sha256 "792e0ea3c96ffe3ad65617a104b7dc50684932bc96d2adab501c952fd65c3e4a"
    end
  end

  head do
    url "https://github.com/pooranis/fastx_toolkit.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build

    resource "libgtextutils" do
      url "https://github.com/agordon/libgtextutils.git"
    end
  end

  depends_on "pkg-config" => :build

  fails_with :clang do
    build (MacOS.version >= :mavericks ? 425 : 503)
    cause "clang build fails on Mountain Lion, but works on Mavericks. See issue #620"
  end

  def install
    resource("libgtextutils").stage do
      if build.head?
        inreplace "reconf", "libtoolize", "glibtoolize"
        system "sh", "./reconf"
      end
      system "./configure", "--disable-debug",
        "--disable-dependency-tracking",
        "--prefix=#{prefix}"
      system "make"
      system "make", "install"
    end

    # --disable-debug causes fastx_trimmer to crash. See #216.
    if build.head?
      inreplace "reconf", "libtoolize", "glibtoolize"
      system "sh", "./reconf"
    end
    system "./configure", "--disable-dependency-tracking",
      "--prefix=#{prefix}", "PKG_CONFIG_PATH=#{lib}/pkgconfig"
    system "make", "install"
    # Hack to fix conflicts with autoconf-archive. See:
    # https://github.com/Homebrew/homebrew-science/issues/5267
    # https://github.com/agordon/fastx_toolkit/issues/6
    rm_rf share
  end

  test do
    fixture = <<~EOS
      >MY-ID
      AAAAAGGGGG
      CCCCCTTTTT
      AGCTN
      EOS
    expect = <<~EOS
      >MY-ID
      AAAAAGGGGGCCCCCTTTTTAGCTN
      EOS
    actual = `echo "#{fixture}" | #{bin}/fasta_formatter`
    actual == expect
  end
end
