class OpenblasPthread < Formula
  desc "Optimized BLAS library using Pthreads"
  homepage "https://www.openblas.net/"
  url "https://github.com/xianyi/OpenBLAS/archive/v0.3.21.tar.gz"
  sha256 "f36ba3d7a60e7c8bcc54cd9aaa9b1223dd42eaf02c811791c37e8ca707c241ca"
  license "BSD-3-Clause"
  head "https://github.com/xianyi/OpenBLAS.git", branch: "develop"

  livecheck do
    url :stable
    strategy :github_latest
  end

  keg_only :shadowed_by_macos, "macOS provides BLAS in Accelerate.framework"

  depends_on "gcc" # for gfortran
  # depends_on "llvm" ## can uncomment and modify for using with llvm
  # fails_with :clang

def caveats
    <<~EOS
    This formula is very custom and needs editing before installation for the specific
    macOS version and cpu target (because it is faster than compiling
    for dynamic architecture).

    The motivation for it is from https://github.com/Homebrew/homebrew-core/issues/75506
    We would like to build only using pthreads.

    EOS
end

  def install
    ENV.runtime_cpu_detection
    ENV.permit_arch_flags # otherwise homebrew superenv removes -m64 unclear whether this is bad or not?
    ENV.deparallelize # build is parallel by default, but setting -j confuses it

    # The build log has many warnings of macOS build version mismatches.
    ENV["MACOSX_DEPLOYMENT_TARGET"] = MacOS.version
    # ENV["DYNAMIC_ARCH"] = "1"
    ENV["USE_THREAD"] = "1"
    # Force a large NUM_THREADS to support larger Macs than the VMs that build the bottles
    # ENV["NUM_THREADS"] = 56
    ## Use number of threads present in machine
    ENV["NUM_THREADS"] = Hardware::CPU.cores.to_s
    # ENV["TARGET"] = case Hardware.oldest_cpu
    # when :arm_vortex_tempest
    #   "VORTEX"
    # else
    #   Hardware.oldest_cpu.upcase.to_s
    # end

    # use native processor as target
    ENV["TARGET"] = "HASWELL"
    ## Edit MacOS SDK that you have installed /Library/Developer/CommandLineTools/SDKs
    # ENV.prepend "CPPFLAGS", "-I#{Formula["libomp"].opt_include}"
    # ENV.prepend "LDFLAGS", "-L#{Formula["libomp"].opt_lib} -L#{HOMEBREW_PREFIX}/lib -lomp"
    ## ENV.prepend "LDFLAGS", "-L#{HOMEBREW_PREFIX}/lib"
    ## ENV.prepend "FFLAGS", "-mmacosx-version-min=12.3"
    ## ENV["MYFFLAGS"] = ENV["FFLAGS"]

    # limit build to use half threads
    ENV["NB_JOBS"] = (Hardware::CPU.cores / 2.to_f).ceil.to_s

    # Must call in two steps and use make_nb_jobs to reduce the parallel make
    system "make", "FC=gfortran", "MAKE_NB_JOBS=${NB_JOBS}", "VERBOSE=1", "PREFIX=#{prefix}", "libs", "netlib", "shared"
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
