class Kronatools < Formula
  desc "Krona Tools is a set of scripts to create Krona charts from several Bioinformatics tools as well as from text and XML files."
  homepage "https://github.com/marbl/Krona/wiki"
  url "https://github.com/marbl/Krona/releases/download/2.7/KronaTools-2.7.tar"
  sha256 "9f4787a240366bc156e3c0ed14667462f0eb0e5f4e6961c9d9e7f3c58dab45ba"

  skip_clean "taxonomy"

  def install
    prefix.install Dir["./*"]
    cd "#{prefix}"
    system "./install.pl --prefix=#{prefix}"
  end
end
