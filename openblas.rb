class Openblas < Formula
  desc "Optimized BLAS library"
  homepage "https://www.openblas.net/"
  url "https://github.com/xianyi/OpenBLAS/archive/refs/tags/v0.3.26.tar.gz"
  sha256 "4e6e4f5cb14c209262e33e6816d70221a2fe49eb69eaf0a06f065598ac602c68"
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
    macOS version and cpu target (because it is faster than compiling
    for dynamic architecture).

    The motivation for it is from https://github.com/Homebrew/homebrew-core/issues/75506
    We would like to build without using gcc's libgomp since it is not fork-safe, and
    instead use libomp from llvm.

    What happens if we link to libomp AND libgomp (which comes with gcc)?
    According to man ld:
    ##  By default all references resolved to a dynamic library record the library to which they
    ##   were resolved.
    so probably no risk of linking to libomp AND libgomp...???

    For the cleanest most risk-averse installation,
    you should install homebrew gcc and either llvm or libomp first.
    Then replace gcc's libgomp with the respective libomp.  Here is example
    using libomp (which is currently how formula is written):
        cd /opt/homebrew/opt/libomp/lib
        ln -s libomp.dylib libgomp.dylib
        ln -s libomp.a libgomp.a
        brew unlink libomp
        brew link libomp

    I think using the gcc libgomp headers is ok (this is what conda does).  The resulting openblas
    fails/warns on one of the tests, but the conda openblas also fails that one (and I think openblas
    compiled with gcc/libgomp does too?).

    Interestingly homebrew llvm symlinks libomp to libgomp!  So, can symlink
        that instead.  This will ensure that R libs are only linked against libomp.

    EOS
end

  def install
    ENV.runtime_cpu_detection
    ENV.permit_arch_flags # otherwise homebrew superenv removes -m64 unclear whether this is bad or not?
    ENV.deparallelize # build is parallel by default, but setting -j confuses it

    # The build log has many warnings of macOS build version mismatches.
    ENV["MACOSX_DEPLOYMENT_TARGET"] = MacOS.version
    # ENV["DYNAMIC_ARCH"] = "1"
    ENV["USE_OPENMP"] = "1"
    # Force a large NUM_THREADS to support larger Macs than the VMs that build the bottles
    # ENV["NUM_THREADS"] = 56
    ## Use number of threads present in machine
    ENV["NUM_THREADS"] = Hardware::CPU.cores.to_s
    # See available targets in TargetList.txt
    ENV["TARGET"] = case Hardware.oldest_cpu
    when :arm_vortex_tempest
      "VORTEX"
    when :westmere
      "NEHALEM"
    else
      Hardware.oldest_cpu.upcase.to_s
    end

    # Apple Silicon does not support SVE
    # https://github.com/xianyi/OpenBLAS/issues/4212
    ENV["NO_SVE"] = "1" if Hardware::CPU.arm?
    
    ## Edit MacOS SDK that you have installed /Library/Developer/CommandLineTools/SDKs
    ENV.prepend "CPPFLAGS", "-I#{Formula["libomp"].opt_include}"
    ENV.prepend "LDFLAGS", "-L#{Formula["libomp"].opt_lib} -L#{HOMEBREW_PREFIX}/lib -lomp"
    ## ENV.prepend "FFLAGS", "-mmacosx-version-min=12.3"
    ## ENV["MYFFLAGS"] = ENV["FFLAGS"]

    # limit build to use half threads
    ENV["NB_JOBS"] = (Hardware::CPU.cores / 2.to_f).ceil.to_s

    # Must call in two steps and use make_nb_jobs to reduce the parallel make
    system "make", "FC=gfortran", "CFLAGS=${CPPFLAGS} -Xclang -fopenmp", "MAKE_NB_JOBS=${NB_JOBS}", "VERBOSE=1", "PREFIX=#{prefix}", "libs", "netlib", "shared"
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
    system "./test"
  end
end
