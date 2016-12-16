class Dbxcli < Formula
  desc "A command line client for Dropbox built using the Go SDK"
  homepage "https://github.com/dropbox/dbxcli"
  url "https://github.com/dropbox/dbxcli/archive/v1.4.0.tar.gz"
  sha256 "22999341f70a948204ed48b99e1e0536dd77e3fc3fb887c6291673834c8e66f0"
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
