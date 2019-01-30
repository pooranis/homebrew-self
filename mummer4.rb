# coding: utf-8
class Mummer4 < Formula
  desc "MUMmer alignment tool "
  homepage "https://github.com/mummer4/mummer"
  url "https://github.com/mummer4/mummer/releases/download/v4.0.0beta2/mummer-4.0.0beta2.tar.gz"
  sha256 "cece76e418bf9c294f348972e5b23a0230beeba7fd7d042d5584ce075ccd1b93"
  version "4.0.0beta2"

  # See https://mummer4.github.io/install/install.html
  option "with-visual-tools", "Install/add to path tools needed for mummer visualizations - fig2dev, gnuplot, and xfig."
  option "with-python", "Build with SWIG python binding."
  option "with-perl",  "Build with SWIG perl binding."

  depends_on "gcc" => :build
  fails_with :clang ## we want to build with homebrew gcc https://github.com/mummer4/mummer/blob/master/INSTALL.md#dependencies
  depends_on "gnuplot@4" => :optional
  depends_on "pooranis/self/xfig" => :optional
  depends_on "fig2dev" => :optional

  depends_on "gnuplot@4" if build.with? "visual-tools"
  depends_on "pooranis/self/xfig" if build.with? "visual-tools"
  depends_on "fig2dev" if build.with? "visual-tools"

  if build.with? "python"
    # See https://github.com/swig/swig/issues/769#issuecomment-241225679
    patch :DATA
  end


  def install

    # ENV.deparallelize  # if your formula fails when building in parallel
    # Remove unrecognized options if warned by configure
    args = [
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--prefix=#{prefix}",
      "SED=/usr/bin/sed",
      "--disable-openmp"
    ]

    ## See https://github.com/mummer4/mummer/blob/master/swig/INSTALL.md
    if build.with? "python"
      args << "--enable-python-binding"
    end

    if build.with? "perl"
      args << "--enable-perl-binding"
    end
    
    system "./configure", *args
    system "make"
    system "make", "install" # if this fails, try separate make/make install steps

    ## remove annotate as it is deprecated: https://github.com/mummer4/mummer/blob/master/MANUAL.md#annotate
    rm_f "#{bin}/annotate"
  end

  def caveats
    <<~EOS
        If built with python bindings, the binding will be installed to #{opt_prefix}/lib/python.
        If built with perl bindings, the binding will be installed to #{opt_prefix}/lib/perl.

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

__END__
diff --git a/swig/python/mummer.py b/swig/python/mummer.py
index 7a31376..5ffaf3f 100644
--- a/swig/python/mummer.py
+++ b/swig/python/mummer.py
@@ -8,37 +8,7 @@
 
 
 from sys import version_info as _swig_python_version_info
-if _swig_python_version_info >= (2, 7, 0):
-    def swig_import_helper():
-        import importlib
-        pkg = __name__.rpartition('.')[0]
-        mname = '.'.join((pkg, '_mummer')).lstrip('.')
-        try:
-            return importlib.import_module(mname)
-        except ImportError:
-            return importlib.import_module('_mummer')
-    _mummer = swig_import_helper()
-    del swig_import_helper
-elif _swig_python_version_info >= (2, 6, 0):
-    def swig_import_helper():
-        from os.path import dirname
-        import imp
-        fp = None
-        try:
-            fp, pathname, description = imp.find_module('_mummer', [dirname(__file__)])
-        except ImportError:
-            import _mummer
-            return _mummer
-        try:
-            _mod = imp.load_module('_mummer', fp, pathname, description)
-        finally:
-            if fp is not None:
-                fp.close()
-        return _mod
-    _mummer = swig_import_helper()
-    del swig_import_helper
-else:
-    import _mummer
+from . import _mummer
 del _swig_python_version_info
 
 try:

