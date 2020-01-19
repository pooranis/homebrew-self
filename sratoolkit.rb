class Sratoolkit < Formula
  desc "Data tools for INSDC Sequence Read Archive"
  homepage "https://github.com/ncbi/sra-tools"
  url "https://github.com/ncbi/sra-tools/archive/2.10.2.tar.gz"
  sha256 "e8f95d5c68528bbb9ea1a817d3a20115c63a6f8ce28b814fbd78a88bbdcf5524"
  head "https://github.com/ncbi/sra-tools.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "5666b45a693e675a145503ee348aa9be199b6dd53d8e3582e6a2af2f4f647b94" => :catalina
    sha256 "8d9a22d8cc446e66d66b44e8d8e2bbdf60faaa9cc8166e9c7cad1dd5e98abf8b" => :mojave
    sha256 "3dc2db39ac207dc8ba786ba808105cba4128cc9cb5573a02c28e9a71208886c9" => :high_sierra
  end

  depends_on "hdf5"
  depends_on "libmagic"
  depends_on "brewsci/bio/ascp" => :optional
  uses_from_macos "libxml2"
  uses_from_macos "perl"

  resource "ngs-sdk" do
    url "https://github.com/ncbi/ngs/archive/2.10.2.tar.gz"
    sha256 "613be73b31474b7e3d616ad3d7fea3a6a598a9b3695309a1b1e0bc4224248447"
  end

  resource "ncbi-vdb" do
    url "https://github.com/ncbi/ncbi-vdb/archive/2.10.2.tar.gz"
    sha256 "597383174700949cd6dc158e0528422a36a40d97c966b3a9327751f4e8224e91"
  end

  def install
    ngs_sdk_prefix = buildpath/"ngs-sdk-prefix"
    resource("ngs-sdk").stage do
      cd "ngs-sdk" do
        system "./configure",
          "--prefix=#{ngs_sdk_prefix}",
          "--build=#{buildpath}/ngs-sdk-build"
        system "make"
        system "make", "install"
      end
    end

    ncbi_vdb_source = buildpath/"ncbi-vdb-source"
    ncbi_vdb_build = buildpath/"ncbi-vdb-build"
    ncbi_vdb_source.install resource("ncbi-vdb")
    cd ncbi_vdb_source do
      system "./configure",
        "--prefix=#{buildpath/"ncbi-vdb-prefix"}",
        "--with-ngs-sdk-prefix=#{ngs_sdk_prefix}",
        "--build=#{ncbi_vdb_build}"
      ENV.deparallelize { system "make" }
    end

    # Fix the error: ld: library not found for -lmagic-static
    # Upstream PR: https://github.com/ncbi/sra-tools/pull/105
    inreplace "tools/copycat/Makefile", "-smagic-static", "-smagic"

    system "./configure",
      "--prefix=#{prefix}",
      "--with-ngs-sdk-prefix=#{ngs_sdk_prefix}",
      "--with-ncbi-vdb-sources=#{ncbi_vdb_source}",
      "--with-ncbi-vdb-build=#{ncbi_vdb_build}",
      "--build=#{buildpath}/sra-tools-build"

    system "make", "install"

    # Remove non-executable files.
    rm_r [bin/"magic", bin/"ncbi"]
  end

  test do
    assert_match "Read 1 spots for SRR000001", shell_output("#{bin}/fastq-dump -N 1 -X 1 SRR000001")
    assert_match "@SRR000001.1 EM7LVYS02FOYNU length=284", File.read("SRR000001.fastq")
  end
end
