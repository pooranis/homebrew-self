class R < Formula
  desc "Software environment for statistical computing"
  homepage "https://www.r-project.org/"
  url "https://cran.r-project.org/src/base/R-4/R-4.0.2.tar.gz"
  sha256 "d3bceab364da0876625e4097808b42512395fdf41292f4915ab1fd257c1bbe75"

  ## See https://github.com/sethrfore/homebrew-r-srf
  ## and https://github.com/adamhsparks/setup_macOS_for_R for help as well

  depends_on "pkg-config" => :build
  depends_on "gcc" # for gfortran
  depends_on "gettext"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "pcre2"
  depends_on "readline"
  depends_on "xz"
  depends_on "openblas"
  depends_on "libtiff" => :recommended
  depends_on "llvm" => :recommended
  option "without-pango", "Pango support is only available if also building with cairo."
  depends_on "pango" => :recommended
  depends_on "cairo" => :recommended
  depends_on :java => :optional
  option "with-tcltk", "Build with tcl tk support."
  ## to build manuals
  option "without-texinfo", "Don't build html manual with texinfo."
  depends_on "texinfo" => :recommended

  def caveats
    <<~EOS
        TEXINFO
        By default, texinfo is used to build the html manual.
        If pdftex is also in your path, then you will also have
        the ability to make pdf help files, but this is optional.

        If you build --without-texinfo, then you may have
        to configure texinfo and pdftex yourself after
        installation if you need them later.

        Tcl/Tk
        Building --with-tcltk will look for ActiveTcl/Tk.  If needed,
        you can install ActiveTcl with:
        brew cask install tcl

    EOS
  end


  # needed to preserve executable permissions on files without shebangs
  skip_clean "lib/R/bin", "lib/R/doc"

  def install
    # Fix dyld: lazy symbol binding failed: Symbol not found: _clock_gettime
    if MacOS.version == "10.11" && MacOS::Xcode.installed? &&
       MacOS::Xcode.version >= "8.0"
      ENV["ac_cv_have_decl_clock_gettime"] = "no"
    end

    args = [
      "--prefix=#{prefix}",
      "--enable-memory-profiling",
      "--without-x",
      "--with-aqua",
      "--with-lapack",
      "--enable-R-shlib",
      "SED=/usr/bin/sed", # don't remember Homebrew's sed shim
      "--with-blas=-L#{Formula["openblas"].opt_lib} -lopenblas",
    ]

    ## blas linking flags
    ENV.append "LDFLAGS", "-L#{Formula["openblas"].opt_lib}"

    if build.with? "java"
      args << "--enable-java"
    else
      args << "--disable-java"
    end

    if build.with? "cairo"
      args << "--with-cairo"
      # Fix cairo detection with Quartz-only cairo
      inreplace ["configure", "m4/cairo.m4"], "cairo-xlib.h", "cairo.h"
    else
      args << "--without-cairo"
    end

    if build.with? "llvm"
      ENV.prepend_path "PATH", "#{Formula["llvm"].opt_bin}"
      ENV.append "LDFLAGS", "-L#{Formula["llvm"].opt_lib} -Wl,-rpath,#{Formula["llvm"].opt_lib}"
      ENV.append "CPPFLAGS", "-I#{Formula["llvm"].opt_include}"
      ENV.append_path "CPATH", "#{ENV["HOMEBREW_ISYSTEM_PATHS"]}"

      args += [
        "CC=#{Formula["llvm"].opt_bin}/clang",
        "CXX=#{Formula["llvm"].opt_bin}/clang++",
        "OBJC=#{Formula["llvm"].opt_bin}/clang"
      ]
    end

    if build.with? "texinfo"
      pdftexpath = which("pdflatex", path = ORIGINAL_PATHS)
      if pdftexpath.nil?
        opoo "Building with texinfo, but pdflatex not found in original PATH.  It is only
        needed if you want to make pdf manuals."
      else
        pdftexpath = File.dirname(pdftexpath)
        ENV.append_path "PATH", pdftexpath
        ohai "Found pdflatex in #{pdftexpath}"
      end
    end


    if build.with? "tcltk"
      tclpath=Pathname.new("/Library/Frameworks/Tcl.framework/tclConfig.sh")
      tkpath=Pathname.new("/Library/Frameworks/Tk.framework/tkConfig.sh")
      if not tclpath.exist?
        odie "Cannot find #{tclpath}.  Please install R without tcltk option or install
        ActiveTcl:
        brew cask install tcl"
      end
      if not tkpath.exist?
        odie "Cannot find #{tkpath}.Please install R without tcltk option or install
        ActiveTcl:
        brew cask install tcl"
      end
      ohai "Found ActiveTcl configs #{tclpath} and #{tkpath}."
      args += [
        "--with-tcl-config=#{tclpath}",
        "--with-tk-config=#{tkpath}"
      ]
    end

    # Help CRAN packages find gettext and readline
    ["gettext", "readline"].each do |f|
      ENV.append "CPPFLAGS", "-I#{Formula[f].opt_include}"
      ENV.append "LDFLAGS", "-L#{Formula[f].opt_lib}"
    end

    system "./configure", *args
    system "make"
#    ENV.deparallelize do
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

    # make Homebrew packages discoverable for R CMD INSTALL
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

    ## change permissions on html directory
    # html_doc = lib/"R/doc/html"
    # system "chmod", "-R", "gu+w", html_doc
  end

  test do
    assert_equal "[1] 2", shell_output("#{bin}/Rscript -e 'print(1+1)'").chomp
    assert_equal ".dylib", shell_output("#{bin}/R CMD config DYLIB_EXT").chomp

    system bin/"Rscript -e \'install.packages(\"gss\", \".\", \"https://cloud.r-project.org\")\'"
    assert_predicate testpath/"gss/libs/gss.so", :exist?,
                     "Failed to install gss package"
  end
end
