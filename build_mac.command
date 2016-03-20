#!/bin/bash
# $1: %{Qt:QT_INSTALL_BINS}
# $2: path to Qt-Installer-Framwork
# $3: online = 0; offline = anything else
# working directory: %{sourceDir}

#create translations
"$1/lupdate" -locations relative ./config/controllerScript.js ./packages/com.SkyCoder42.AdvancedSetup/meta/install.js ./packages/com.SkyCoder42.AdvancedSetup/meta/ShortcutPage.ui ./packages/com.SkyCoder42.AdvancedSetup/meta/UserPage.ui -ts ./translations/template.ts ./translations/de.ts
"$1/lrelease" -compress -nounfinished ./translations/de.ts -qm ./packages/com.SkyCoder42.AdvancedSetup/meta/de.qm

#create the installer (and online repo)
if [ "$3" == "0" ]; then
	"$2/bin/repogen" --update-new-components -p ./packages ./online_repos/mac_x64
	"$2/bin/binarycreator" -n -c ./config/config.xml -p ./packages ./QtIFW-Advanced_Sample_setup_mac_x64_online.app
else
	"$2/bin/binarycreator" -f -c ./config/config.xml -p ./packages ./QtIFW-Advanced_Sample_setup_mac_x64_offline.app
fi
