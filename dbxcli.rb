class Dbxcli < Formula
  desc "A command line client for Dropbox built using the Go SDK"
  homepage "https://github.com/dropbox/dbxcli"
  url "https://github.com/dropbox/dbxcli/archive/v2.0.2.tar.gz"
  sha256 "fed8df7dedb099aa2f7ae39fda0687389adae64bcb92a7b705523921b42beb07"
  head "https://github.com/dropbox/dbxcli.git"


  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/dropbox/dbxcli").install buildpath.children
    cd "src/github.com/dropbox/dbxcli" do
      system "go", "build", "-o", bin/"dbxcli"
      prefix.install_metafiles
      bash_completion.install "contrib/dbxcli_bash_completion.sh"
    end

  end

end
