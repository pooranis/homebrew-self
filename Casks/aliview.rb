cask 'aliview' do
  version '1.26'
  sha256 '38851e64d05e2f5a4c23675c4258c8c7c49cba52efe06c5bf8c2989f33f63b4e'

  url "https://ormbunkar.se/aliview/downloads/mac/AliView-#{version}-app.zip"
  appcast 'https://github.com/AliView/AliView/releases.atom'
  name 'AliView'
  homepage 'https://ormbunkar.se/aliview/'

  app "AliView-#{version}/AliView.app"

  zap trash: '~/.AliView'
end
