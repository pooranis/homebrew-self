class Openblas < Formula
  desc "Optimized BLAS library"
  homepage "https://www.openblas.net/"
  url "https://github.com/xianyi/OpenBLAS/archive/v0.3.20.tar.gz"
  sha256 "8495c9affc536253648e942908e88e097f2ec7753ede55aca52e5dead3029e3c"
  license "BSD-3-Clause"
  head "https://github.com/xianyi/OpenBLAS.git", branch: "develop"

  livecheck do
    url :stable
    strategy :github_latest
  end

  keg_only :shadowed_by_macos, "macOS provides BLAS in Accelerate.framework"

  depends_on "gcc" # for gfortran
  depends_on "libomp" # for openmp
  # depends_on "llvm" ## can uncomment and modify for using with llvm
  # fails_with :clang

def caveats
    <<~EOS
    This formula is very custom and needs editing before installation for the specific
    macOS version and number of threads you have (because it is faster than compiling
    for dynamic architecture).

    The motivation for it is from https://github.com/Homebrew/homebrew-core/issues/75506
    We would like to build without using gcc's libgomp since it is not fork-safe, and
    instead use libomp from llvm.

    For the cleanest installation,
    you should install homebrew gcc and either llvm or libomp first.
    Then replace gcc's libgomp with the respective libomp.  Here is example
    using libomp (which is currently how formula is written):
        cd /usr/local/opt/gcc/lib/gcc/11
        mkdir libgomp
        mv libgomp* libgomp/
        ln -s /usr/local/opt/libomp/lib/libomp.a libgomp.a
        ln -s /usr/local/opt/libomp/lib/libomp.dylib libgomp.dylib
        cd gcc/x86_64-apple-darwin21/11/include
        mkdir libgomp
        mv omp.h libgomp/
        ln -s /usr/local/opt/libomp/include/* .

    Interestingly homebrew llvm symlinks libomp to libgomp!  So, can symlink
        that instead.  This will ensure that R libs are only linked against libomp.

    EOS
end

  def install
    ENV.runtime_cpu_detection
    ENV.deparallelize # build is parallel by default, but setting -j confuses it

    # ENV["DYNAMIC_ARCH"] = "1"
    ENV["USE_OPENMP"] = "1"
    # Force a large NUM_THREADS to support larger Macs than the VMs that build the bottles
    ENV["NUM_THREADS"] = "8"
    # ENV["TARGET"] = case Hardware.oldest_cpu
    # when :arm_vortex_tempest
    #   "VORTEX"
    # else
    #   Hardware.oldest_cpu.upcase.to_s
    # end

    ENV["TARGET"] = "HASWELL"
    ## Edit MacOS SDK that you have installed /Library/Developer/CommandLineTools/SDKs
    ENV.prepend "CPPFLAGS", "-mmacosx-version-min=12.3 -I#{Formula["libomp"].opt_include} -I#{HOMEBREW_PREFIX}/include -Xclang -fopenmp"
    ENV.prepend "LDFLAGS", "-L#{Formula["libomp"].opt_lib} -L#{HOMEBREW_PREFIX}/lib -lomp"


    # Must call in two steps
    system "make", "FC=#{Formula["gcc"].opt_bin}/gfortran", "CFLAGS=${CPPFLAGS}", "VERBOSE=1", "PREFIX=#{prefix}", "libs", "netlib", "shared"
    # system "make", "CC=#{ENV.cc}", "FC=gfortran", "libs", "netlib", "shared"
    system "make", "PREFIX=#{prefix}", "install"

    lib.install_symlink shared_library("libopenblas") => shared_library("libblas")
    lib.install_symlink shared_library("libopenblas") => shared_library("liblapack")
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <stdlib.h>
      #include <math.h>
      #include "cblas.h"

      int main(void) {
        int i;
        double A[6] = {1.0, 2.0, 1.0, -3.0, 4.0, -1.0};
        double B[6] = {1.0, 2.0, 1.0, -3.0, 4.0, -1.0};
        double C[9] = {.5, .5, .5, .5, .5, .5, .5, .5, .5};
        cblas_dgemm(CblasColMajor, CblasNoTrans, CblasTrans,
                    3, 3, 2, 1, A, 3, B, 3, 2, C, 3);
        for (i = 0; i < 9; i++)
          printf("%lf ", C[i]);
        printf("\\n");
        if (fabs(C[0]-11) > 1.e-5) abort();
        if (fabs(C[4]-21) > 1.e-5) abort();
        return 0;
      }
    EOS
    system "clang", "test.c", "-I#{include}", "-L#{lib}", "-lopenblas",
                   "-o", "test"
    # system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lopenblas",
    #                "-o", "test"
    system "./test"
  end
end
