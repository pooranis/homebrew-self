cask 'ugene' do
  version '1.32.0'
  sha256 '5d80dd8cbbe4a7cd123a020850845b82180f2d77882a146b2047d2ac9b021bae'

  url "http://ugene.unipro.ru/downloads/ugene-#{version}-mac-x86-64.dmg"
  appcast 'http://ugene.net/downloads/ugene_get_latest_mac_x86_64.html'
  name 'UGENE'
  homepage 'http://ugene.net/'

  app 'Unipro UGENE.app'

  zap trash: [
                '~/.UGENE_files',
                '~/Library/Preferences/com.unipro.UGENE.plist'
             ]

end
