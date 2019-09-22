class Sibelia < Formula
  desc "Genome comparison via de Bruijn graph. To get the latest stable version, please visit our site."
  homepage "http://bioinf.spbau.ru/sibelia"
  url "https://github.com/bioinf/Sibelia/archive/v3.0.7.tar.gz"
  sha256 "bfc530190967cadd2d1e9779eeb1700f494c115049da878116c4540c5586e813"

  depends_on "cmake" => :build
  depends_on "gcc" => :build

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    mkdir_p "build"
    cd "build" do
      system "cmake", "../src", *std_cmake_args
      system "make"
      system "make", "install" # if this fails, try separate make/make install steps
    end
  end

end
