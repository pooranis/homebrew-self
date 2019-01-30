# coding: utf-8
class Mummer4 < Formula
  desc "MUMmer alignment tool "
  homepage "https://mummer4.github.io"
  url "https://github.com/mummer4/mummer/releases/download/v4.0.0beta2/mummer-4.0.0beta2.tar.gz"
  sha256 "cece76e418bf9c294f348972e5b23a0230beeba7fd7d042d5584ce075ccd1b93"
  version "4.0.0beta2"

  # See https://mummer4.github.io/install/install.html
  
  
  option "with-python", "Build with SWIG python binding"
  option "with-perl",  "Build with SWIG perl binding"

  depends_on "gcc" => :build
  fails_with :clang ## we want to build with homebrew gcc https://github.com/mummer4/mummer/blob/master/INSTALL.md#dependencies
  depends_on "gnuplot" => :recommended
  depends_on "xfig" => :recommended
  depends_on "fig2dev" => :recommended


  def install

    ## configure args
    args = [
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--prefix=#{prefix}",
      "SED=/usr/bin/sed",
      "--disable-openmp"
    ]

    ## See https://github.com/mummer4/mummer/blob/master/swig/INSTALL.md
    if build.with? "perl"
      args << "--enable-perl-binding"
    end
    
    if build.with? "python"
      # See https://github.com/swig/swig/issues/769#issuecomment-241225679
      ohai "Fixing swig python wrapper"
      inreplace "swig/python/mummer.py", /if _swig_python_version_info \>\= \(2, 7, 0\)\:.+(?=\ndel _swig_python_version_info)/m, "from . import _mummer"
      args << "--enable-python-binding"
    end

    ## configure and make make install
    system "./configure", *args
    system "make"
    system "make", "install" # if this fails, try separate make/make install steps

    ## remove annotate as it is deprecated: https://github.com/mummer4/mummer/blob/master/MANUAL.md#annotate
    rm_f "#{bin}/annotate"
  end

  def caveats
    <<~EOS
        gnuplot, xfig, and fig2dev are only used for MUMmer's visualization tools.  If you don't need those tools, then you can install without the recommended dependencies.

        SWIG bindings
        =============
        If built with python and/or perl bindings, the bindings will be installed to #{opt_prefix}/lib/python or #{opt_prefix}/lib/perl respectively.

        To use either binding, update your PYTHONPATH or PERL5LIB environment variable accordingly.

        See https://github.com/mummer4/mummer/blob/master/swig/INSTALL.md for more information.

    EOS
  end

  # test do
  #   if build.with? "python"
  #     ENV.prepend_path "PYTHONPATH", lib/"python"
  #     system "python", "-c", "import mummer"
  #   end
  # end
  
end
