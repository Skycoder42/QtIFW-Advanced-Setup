:: %1: %{Qt:QT_INSTALL_BINS}
:: %2: path to Qt-Installer-Framwork
:: %3: online = 0; offline = anything else
:: working directory: %{sourceDir}
@echo off

::create translations
"%~1\lupdate" -locations relative ./config/controllerScript.js ./packages/com.example.advancedSample/meta/install.js ./packages/com.example.advancedSample/meta/ShortcutPage.ui ./packages/com.example.advancedSample/meta/UserPage.ui -ts ./translations/de.ts
"%~1\lrelease" -compress -nounfinished ./translations/de.ts -qm ./packages/com.example.advancedSample/meta/de.qm

::create the installer (and online repo)
IF "%~3" == "0" (
	"%~2\bin\repogen.exe" --update-new-components -p ./packages ./online_repos/win_x64
	"%~2\bin\binarycreator.exe" -n -c ./config/config.xml -p ./packages ./QtIFW-Advanced_Sample_setup_win_x64_online.exe
) ELSE (
	"%~2\bin\binarycreator.exe" -f -c ./config/config.xml -p ./packages ./QtIFW-Advanced_Sample_setup_win_x64_offline.exe
)
