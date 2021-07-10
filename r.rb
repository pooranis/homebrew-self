class R < Formula
  desc "Software environment for statistical computing"
  homepage "https://www.r-project.org/"
  url "https://cran.r-project.org/src/base/R-4/R-4.1.0.tar.gz"
  sha256 "e8e68959d7282ca147360fc9644ada9bd161bab781bab14d33b8999a95182781"
  license "GPL-2.0-or-later"

  livecheck do
    url "https://cran.rstudio.com/banner.shtml"
    regex(%r{href=(?:["']?|.*?/)R[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end


  ## See https://github.com/sethrfore/homebrew-r-srf
  ## and https://github.com/adamhsparks/setup_macOS_for_R for help as well

  depends_on "pkg-config" => :build
  depends_on "gcc" # for gfortran
  depends_on "gettext"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "openblas"
  depends_on "pcre2"
  depends_on "readline"
  depends_on "tcl-tk" => :optional
  depends_on "xz"
  depends_on "libtiff" => :recommended
  depends_on "llvm" => :recommended
  option "without-pango", "Pango support is only available if also building with cairo."
  depends_on "pango" => :recommended
  depends_on "cairo" => :recommended
  depends_on "texinfo" => :recommended

  ## stuff we don't use
  depends_on "openjdk" => :optional

  def caveats
    <<~EOS
        TEXINFO
        Texinfo is used to build the html manual.
        If pdftex is also in your path, then you will also have
        the ability to make pdf help files.

        LLVM/OpenMP
        Using homebrew llvm allows for OpenMP.  There may be problems in installing packages
        if you ALSO have libomp installed.  Should unlink before installing:
        brew unlink libomp

    EOS
  end


  # needed to preserve executable permissions on files without shebangs
  skip_clean "lib/R/bin", "lib/R/doc"

  def install

    args = [
      "--prefix=#{prefix}",
      "--enable-memory-profiling",
      "--without-x",
      "--with-aqua",
      "--with-blas=-L#{Formula["openblas"].opt_lib} -lopenblas",
      "--with-lapack",
      "--enable-R-shlib",

    ]


    ## homebrewlibs keg-only dependencies besides BLAS
    ENV.append "CPPFLAGS", "-I#{Formula["readline"].opt_include}"
    ENV.append "LDFLAGS", "-L#{Formula["readline"].opt_lib}"

    if build.with? "tcl-tk"
      args += [
        "--with-tcl-config=#{Formula["tcl-tk"].opt_lib}/tclConfig.sh",
        "--with-tk-config=#{Formula["tcl-tk"].opt_lib}/tkConfig.sh"
      ]
    end

    if build.with? "java"
      args << "--enable-java"
    else
      args << "--disable-java"
    end

    if build.with? "cairo"
      # Fix cairo detection with Quartz-only cairo
      inreplace ["configure", "m4/cairo.m4"], "cairo-xlib.h", "cairo-quartz.h"
    else
      args << "--without-cairo"
    end

    if build.with? "llvm"
      ENV.prepend_path "PATH", "#{Formula["llvm"].opt_bin}"
      ENV.prepend_path "CPATH", "#{HOMEBREW_PREFIX}/include"
      ENV.prepend_path "LIBRARY_PATH", "#{ENV["HOMEBREW_LIBRARY_PATHS"]}"
      ENV.prepend "LDFLAGS", "-L#{Formula["llvm"].opt_lib}"

      args += [
        "CC=#{Formula["llvm"].opt_bin}/clang",
        "CXX=#{Formula["llvm"].opt_bin}/clang++",
        "OBJC=#{Formula["llvm"].opt_bin}/clang",
        "OBJCXX=#{Formula["llvm"].opt_bin}/clang++"
      ]
    else
      # BLAS detection fails with Xcode 12 due to missing prototype
      # https://bugs.r-project.org/bugzilla/show_bug.cgi?id=18024
      # unclear if needed for Apple Clang, but put it here anyway as upstream formula has it
      ENV.append "CFLAGS", "-Wno-implicit-function-declaration"
    end

    if build.with? "texinfo"
      pdftexpath = which("pdflatex", path = ORIGINAL_PATHS)
      if pdftexpath.nil?
        opoo "Building with texinfo, but pdflatex not found in original PATH.  It is only
        needed if you want to make pdf manuals."
      else
        pdftexpath = File.dirname(File.realpath(pdftexpath))
        ENV.append_path "PATH", pdftexpath
        ohai "Found pdflatex in #{pdftexpath}"
      end
    end


    system "./configure", *args
#    ENV.deparallelize do
      system "make"
      system "make", "install"
#    end

    cd "src/nmath/standalone" do
      system "make"
#      ENV.deparallelize do
        system "make", "install"
#      end
    end

    ## build manuals
    if build.with? "texinfo"
      cd "doc/manual" do
        system "make", "html"
#        ENV.deparallelize do
          system "make", "install"
#        end
      end
    end

    r_home = lib/"R"

    # make linked Homebrew packages discoverable for R CMD INSTALL for /usr/local
    inreplace r_home/"etc/Makeconf" do |s|
      s.gsub!(/^CPPFLAGS =.*/, "\\0 -I#{HOMEBREW_PREFIX}/include")
      s.gsub!(/^LDFLAGS =.*/, "\\0 -L#{HOMEBREW_PREFIX}/lib")
      s.gsub!(/.LDFLAGS =.*/, "\\0 $(LDFLAGS)")
    end

    include.install_symlink Dir[r_home/"include/*"]
    lib.install_symlink Dir[r_home/"lib/*"]

    # avoid triggering mandatory rebuilds of r when gcc is upgraded
    inreplace lib/"R/etc/Makeconf", Formula["gcc"].prefix.realpath,
                                    Formula["gcc"].opt_prefix
    inreplace lib/"R/etc/Makeconf", Formula["pcre2"].prefix.realpath,
                                    Formula["pcre2"].opt_prefix
  end

  def post_install
    short_version =
      `#{bin}/Rscript -e 'cat(as.character(getRversion()[1,1:2]))'`.strip
    site_library = HOMEBREW_PREFIX/"lib/R/#{short_version}/site-library"
    site_library.mkpath
    ln_s site_library, lib/"R/site-library"
  end

  test do
    assert_equal "[1] 2", shell_output("#{bin}/Rscript -e 'print(1+1)'").chomp
    assert_equal ".dylib", shell_output("#{bin}/R CMD config DYLIB_EXT").chomp

    if build.with? "tcl-tk"
      assert_equal "[1] \"aqua\"",
                   shell_output("#{bin}/Rscript -e 'library(tcltk)' -e 'tclvalue(.Tcl(\"tk windowingsystem\"))'").chomp
    end

    system bin/"Rscript", "-e", "install.packages('gss', '.', 'https://cloud.r-project.org')"
    assert_predicate testpath/"gss/libs/gss.so", :exist?,
                     "Failed to install gss package"
  end
end
