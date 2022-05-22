cask 'aliview' do
  version '1.28'
  sha256 'a1930a40e777d7f10f1a04495d8421cd3bb668b623bd0c62a9b87bb34c138c3f'

  url "https://ormbunkar.se/aliview/downloads/mac/AliView-#{version}-app.zip"
  appcast 'https://github.com/AliView/AliView/releases.atom'
  name 'AliView'
  homepage 'https://ormbunkar.se/aliview/'

  app "AliView-#{version}/AliView.app"

  zap trash: '~/.AliView'
end
