class AssemblyStats < Formula
  desc "Get assembly statistics from FASTA and FASTQ files"
  homepage "https://github.com/sanger-pathogens/assembly-stats"
  url "https://github.com/sanger-pathogens/assembly-stats/archive/v1.0.1.tar.gz"
  sha256 "02be614da4d244673bcd0adc6917749681d52a58cb0a039c092d01cdeabd8575"

  depends_on "cmake" => :build

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel

    # Remove unrecognized options if warned by configure
 
    mkdir_p "build"
    cd "build" do
      system "cmake","-DINSTALL_DIR:PATH=#{prefix}/bin", ".."
      system "make"
      system "make","test"
      system "make", "install"
    end
    # system "cmake", ".", *std_cmake_args
     # if this fails, try separate make/make install steps
  end


end
