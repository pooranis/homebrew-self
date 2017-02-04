class Dbxcli < Formula
  desc "A command line client for Dropbox built using the Go SDK"
  homepage "https://github.com/dropbox/dbxcli"
  url "https://github.com/dropbox/dbxcli/archive/v2.0.0.tar.gz"
  sha256 "a914fe87664e80c9374ef97b711fd04218c0afe87c5921e04e7afd01dd3ba06f"
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
