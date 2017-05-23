:: %1 debug|release
:: %2 Qt bin dir
:: %3 Qt translation dir
:: %4 pro-dir
@echo off
mkdir deployment
cd deployment
copy "..\%1\seasonproxer.exe" .\

"%~2\windeployqt.exe" --%1 -no-translations seasonproxer.exe
del vcredist_x64.exe

"%~2\lrelease.exe" -compress -nounfinished "%~4\Core\Core.pro"
"%~2\lrelease.exe" -compress -nounfinished "%~4\Desktop\Desktop.pro"

mkdir translations
cd translations
xcopy /y "%~3\qtbase_*.qm" .\*
xcopy /y "%~3\qtwebsockets_*.qm" .\*
xcopy /y "%~4\Core\*.qm" .\*
xcopy /y "%~4\Desktop\*.qm" .\*
cd ..

echo [Paths] > qt.conf
echo Prefix=. >> qt.conf
