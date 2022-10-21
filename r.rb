class R < Formula
  # desc "Software environment for statistical computing"
  # homepage "https://www.r-project.org/"
  # url "https://cran.r-project.org/src/base/R-4/R-4.2.1.tar.gz"
  # sha256 "4d52db486d27848e54613d4ee977ad952ec08ce17807e1b525b10cd4436c643f"
  # license "GPL-2.0-or-later"
  desc "Software environment for statistical computing - patched version"
  homepage "https://www.r-project.org/"
  url "https://cran.r-project.org/src/base/R-4/R-4.2.1.tar.gz"
  sha256 "4d52db486d27848e54613d4ee977ad952ec08ce17807e1b525b10cd4436c643f"
  license "GPL-2.0-or-later"

  livecheck do
    url "https://cran.rstudio.com/banner.shtml"
    regex(%r{href=(?:["']?|.*?/)R[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end


  depends_on "pkg-config"
  depends_on "gcc" # for gfortran
  depends_on "gettext"
  depends_on "jpeg-turbo"
  depends_on "libpng"
  depends_on "openblas"
  depends_on "pcre2"
  depends_on "readline"
  depends_on "xz"
  depends_on "libtiff"
  depends_on "pango"
  depends_on "cairo"
  #  depends_on "libxt" ## because homebrew builds cairo with only partial set of x11 libs, some packages assume all exist - libxt Xtrinsic seems to be most popular missing one
  depends_on "icu4c" ## stringi needs newer version, so for consistency

  uses_from_macos "curl"
  uses_from_macos "libffi"
  # uses_from_macos "icu4c"

  depends_on "libomp" => :recommended
  option "without-texinfo", "Build without texinfo support.  Only needed to build the html manual."
  depends_on "texinfo" => :recommended

  ## stuff we don't use
  option "with-llvm", "Build with homebrew llvm. See caveats."
  depends_on "llvm" => :optional
  depends_on "openjdk" => :optional
  depends_on "tcl-tk" => :optional # too much trouble


  def caveats
    <<~EOS
        TEXINFO
        If pdftex is also in your path, then you will also have
        the ability to make pdf/html help files. Need inconsolata,
        helvetic and fancyvrb latex packages installed.

        LLVM/OpenMP
        Two ways to get OpenMP:
        1. Install with apple clang and homebrew libomp (default/recommended).
        2. Install with homebrew llvm's clang (use --with-llvm --without-libomp)
           There may be problems in installing packages
           if you build with homebrew llvm AND ALSO have libomp installed.
           Should unlink before installing that way:
           brew unlink libomp

        For best installation, use custom openblas and see info in that
        formula for how to best set up libomp and gcc together:
             brew info pooranis/self/openblas


    EOS
  end

  # needed to preserve executable permissions on files without shebangs
  skip_clean "lib/R/bin", "lib/R/doc"

  def install
    ## otherwise homebrew superenv replaces CFLAGS -march=native with -march=nehalem and replaces -O3 with -Os
    ENV.runtime_cpu_detection
    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"

    if build.with? "libomp"
      if build.with? "llvm"
        odie "ERROR: can't build with both libomp and llvm, as llvm contains its own libomp and they will conflict.  Please choose one."
      end
    end

    args = [
      "--prefix=#{prefix}",
      "--enable-memory-profiling",
      "--with-aqua",
      "--with-blas=-L#{Formula["openblas"].opt_lib} -lopenblas",
      "--with-lapack",
      "--enable-R-shlib",
      "--enable-lto",
      "--without-x",
      "--with-cairo",
      "--without-static-cairo",
      # This isn't necessary to build R, but it's saved in Makeconf
      # and helps CRAN packages find gfortran when Homebrew may not be
      # in PATH (e.g. under RStudio, launched from Finder)
      "FC=#{Formula["gcc"].opt_bin}/gfortran",
    ]

    ## homebrewlibs keg-only dependencies besides BLAS
    ["readline", "icu4c"].each do |f|
      ENV.append "CPPFLAGS", "-I#{Formula[f].opt_include}"
      ENV.append "LDFLAGS", "-L#{Formula[f].opt_lib}"
    end

    if build.with? "tcl-tk"
      args += [
        "--with-tcl-config=#{Formula["tcl-tk"].opt_lib}/tclConfig.sh",
        "--with-tk-config=#{Formula["tcl-tk"].opt_lib}/tkConfig.sh"
      ]
    end

    if build.with? "openjdk"
      args << "--enable-java"
    else
      args << "--disable-java"
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
        "OBJCXX=#{Formula["llvm"].opt_bin}/clang++",
        "LTO=-flto=thin",
        "LTO_FC=-flto",
        "LTO_LD=-Wl,-mllvm,-threads=4"
      ]
    else
      # BLAS detection fails with Xcode 12 due to missing prototype
      # https://bugs.r-project.org/bugzilla/show_bug.cgi?id=18024
      # unclear if needed for Apple Clang, but put it here anyway as upstream formula has it
      ENV.append "CFLAGS", "-Wno-implicit-function-declaration -g -O3 -pipe -march=native"
      ENV.append "CXXFLAGS", "-g -O3 -pipe -march=native"
    end

    if build.with? "libomp"
      args += [
        "R_OPENMP_CFLAGS=-Xclang -fopenmp -Wno-unused-command-line-argument -Wl,-lomp",
        "SHLIB_OPENMP_CFLAGS=-Xclang -fopenmp -Wno-unused-command-line-argument -Wl,-lomp",
        "SHLIB_OPENMP_CXXFLAGS=-Xclang -fopenmp -Wno-unused-command-line-argument -Wl,-lomp",
        ## put libomp first in path to avoid linking to libgomp
        ## could also see if libgomp is symlinked to libomp either in libomp lib dir
        ## or in gcc lib dir - but in practice seems ok without
        ## unclear whether -lomp is needed with the former
        "R_OPENMP_FFLAGS='-fopenmp -L#{Formula["libomp"].opt_lib} -lomp'",
        "SHLIB_OPENMP_FFLAGS=-fopenmp -L#{Formula["libomp"].opt_lib} -lomp"
      ]
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


    if build.with? "tcl-tk"
      inreplace lib/"R/etc/Makeconf", Formula["tcl-tk"].prefix.realpath,
                Formula["tcl-tk"].opt_prefix
    end



    if build.with? "openjdk"
      inreplace lib/"R/etc/Makeconf", Formula["openjdk"].prefix.realpath,
                Formula["openjdk"].opt_prefix
      inreplace lib/"R/etc/ldpaths", Formula["openjdk"].prefix.realpath,
                Formula["openjdk"].opt_prefix
    end

  end

  def post_install
    short_version =
      `#{bin}/Rscript -e 'cat(as.character(getRversion()[1,1:2]))'`.strip
    site_library = HOMEBREW_PREFIX/"lib/R/#{short_version}/site-library"
    site_library.mkpath
    ln_s site_library, lib/"R/site-library"
    ## avoid deleting when empty
    system "echo", "dummy", ">", "#{site_library}/dummy"
  end

  test do
    assert_equal "[1] 2", shell_output("#{bin}/Rscript -e 'print(1+1)'").chomp
    assert_equal shared_library(""), shell_output("#{bin}/R CMD config DYLIB_EXT").chomp

    system bin/"Rscript", "-e", "if(!capabilities('cairo')) stop('cairo not available')"

    if build.with? "tcl-tk"
      assert_equal "[1] \"aqua\"",
                   shell_output("#{bin}/Rscript -e 'library(tcltk)' -e 'tclvalue(.Tcl(\"tk windowingsystem\"))'").chomp
    end

    system bin/"Rscript", "-e", "install.packages('gss', '.', 'https://cloud.r-project.org')"
    assert_predicate testpath/"gss/libs/gss.so", :exist?,
                     "Failed to install gss package"
  end
end
