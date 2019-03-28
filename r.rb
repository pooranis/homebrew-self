class R < Formula
  desc "Software environment for statistical computing"
  homepage "https://www.r-project.org/"
  url "https://cran.r-project.org/src/base/R-3/R-3.5.3.tar.gz"
  sha256 "2bfa37b7bd709f003d6b8a172ddfb6d03ddd2d672d6096439523039f7a8e678c"

  ## See https://github.com/sethrfore/homebrew-r-srf
  ## and https://github.com/adamhsparks/setup_macOS_for_R for help as well

  depends_on "pkg-config" => :build
  depends_on "gcc" # for gfortran
  depends_on "gettext"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "pcre"
  depends_on "readline"
  depends_on "xz"
  depends_on "openblas"
  depends_on "libtiff" => :recommended
  depends_on "llvm" => :optional
  depends_on "pango" => :optional
  option "with-pango", "Pango support is only available if also building --with-cairo."
  depends_on "cairo" => :optional
  depends_on :java => :optional
  
  ## to build manuals
  option "without-texinfo", "Don't build html manual with texinfo."
  depends_on "texinfo" => :recommended

  def caveats
    <<~EOS
        By default, texinfo is used to build the html manual.
        If pdftex is also in your path, then you will also have
        the ability to make pdf help files, but this is optional.

        If you build --without-texinfo, then you may have 
        to configure texinfo and pdftex yourself after 
        installation, if you need them later.

    EOS
  end


  # needed to preserve executable permissions on files without shebangs
  skip_clean "lib/R/bin"

  resource "gss" do
    url "https://cloud.r-project.org/src/contrib/gss_2.1-9.tar.gz", :using => :nounzip
    mirror "https://mirror.las.iastate.edu/CRAN/src/contrib/gss_2.1-9.tar.gz"
    sha256 "2961fe61c1d3bb3fe7b8e1070d6fb1dfc5d71e0c6e8a6b7c46ff6b42867c4cf3"
  end

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
      "--enable-prebuilt-html"
#      "--enable-lto"
    ]

    if MacOS.version > :sierra
      args << "--enable-lto"
    end
    
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
      args += [
        "CC=#{Formula["llvm"].opt_bin}/clang",
        "CXX=#{Formula["llvm"].opt_bin}/clang++",
        "OBJC=#{Formula["llvm"].opt_bin}/clang"
      ]
    end

    if build.with? "texinfo"
      pdftexpath = File.dirname(which("pdftex", path = ORIGINAL_PATHS))
      if pdftexpath.nil?
        opoo "Building with texinfo, but pdftex not found in original PATH.  It is only 
        needed if you want to make pdf manuals, so these will not be made."
      else
        ENV.append_path "PATH", pdftexpath
        ohai "Found pdftex in #{pdftexpath}"
      end      
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
  end

  def post_install
    short_version =
      `#{bin}/Rscript -e 'cat(as.character(getRversion()[1,1:2]))'`.strip
    site_library = HOMEBREW_PREFIX/"lib/R/#{short_version}/site-library"
    site_library.mkpath
    ln_s site_library, lib/"R/site-library"

    ## change permissions on html directory
    html_doc = lib/"R/doc/html"
    system "chmod", "-R", "u+w", html_doc
  end

  test do
    assert_equal "[1] 2", shell_output("#{bin}/Rscript -e 'print(1+1)'").chomp
    assert_equal ".dylib", shell_output("#{bin}/R CMD config DYLIB_EXT").chomp

    testpath.install resource("gss")
    system bin/"R", "CMD", "INSTALL", "--library=.", Dir["gss*"].first
    assert_predicate testpath/"gss/libs/gss.so", :exist?,
                     "Failed to install gss package"
  end
end
