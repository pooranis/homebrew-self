class Kronatools < Formula
  desc "Krona Tools is a set of scripts to create Krona charts from several Bioinformatics tools as well as from text and XML files."
  homepage "https://github.com/marbl/Krona/wiki"
  url "https://github.com/marbl/Krona/releases/download/v2.7/KronaTools-2.7.tar"
  sha256 "388270ac299da7e38b96bb144e72bd6844d42176c327c03a594e338d19a56f73"

  skip_clean "taxonomy"

  def install
    prefix.install Dir["./*"]
    cd "#{prefix}"
    system "./install.pl --prefix=#{prefix}"
  end
end
