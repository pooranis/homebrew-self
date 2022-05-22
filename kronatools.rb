class Kronatools < Formula
  desc "Krona Tools is a set of scripts to create Krona charts from several Bioinformatics tools as well as from text and XML files."
  homepage "https://github.com/marbl/Krona/wiki"
  version "2.8.1"
  url "https://github.com/marbl/Krona/releases/download/v#{version}/KronaTools-#{version}.tar"
  sha256 "f3ab44bf172e1f846e8977c7443d2e0c9676b421b26c50e91fa996d70a6bfd10"

  skip_clean "taxonomy"

  def install
    prefix.install Dir["./*"]
    cd "#{prefix}"
    system "./install.pl --prefix=#{prefix}"
  end
end
