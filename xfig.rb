class Xfig < Formula
  desc "Interactive drawing tool for the X Window System"
  homepage "https://mcj.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/mcj/xfig-3.2.7a.tar.xz"
  sha256 "ca89986fc9ddb9f3c5a4f6f70e5423f98e2f33f5528a9d577fb05bbcc07ddf24"


  depends_on :x11
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "ghostscript"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking"
    system "make"
    system "make", "install-strip"
  end

  test do
    system "#{bin}/xfig", "-v"
  end
end
