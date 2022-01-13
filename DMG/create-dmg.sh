create-dmg \
  --volname "Alby Installer" \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "Alby.app" 200 190 \
  --hide-extension "Alby.app" \
  --app-drop-link 600 185 \
  --no-internet-enable \
  --hdiutil-quiet \
  "Alby-Installer.dmg" \
  "dmg_content/"