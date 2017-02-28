class AssemblyStats < Formula
  desc "Get assembly statistics from FASTA and FASTQ files"
  homepage "https://github.com/sanger-pathogens/assembly-stats"
  url "https://github.com/sanger-pathogens/assembly-stats/archive/v1.0.0.tar.gz"
  sha256 "29db86efa655f8e50a0807aadb863a532a56b41985ffc5faf1b27afe36be8dc8"

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
