cask 'ugene' do
  version '35.0'
  sha256 '9ef6d40987898a58ec8c9c97ac526178b0591969c72d9422c336cc444ad733ad'
  url "http://ugene.unipro.ru/downloads/packages/#{version}/ugene-#{version}-mac-x86-64.dmg"
  appcast 'http://ugene.net/downloads/ugene_get_latest_mac_x86_64.html'
  name 'UGENE'
  homepage 'http://ugene.net/'

  app 'Unipro UGENE.app'

  zap trash: [
                '~/.UGENE_files',
                '~/Library/Preferences/com.unipro.UGENE.plist'
             ]

end
