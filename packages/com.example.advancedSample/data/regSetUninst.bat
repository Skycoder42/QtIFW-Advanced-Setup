:: %1: guid
:: %2: maintanancetool path
:: %3: base_key
:: %4: 0: offline; 1: online
@echo off

:: check which node has to be updated
reg query "%~3\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\%~1"
IF "%errorlevel%" == "0" (
	set baseKey=WOW6432Node\Microsoft
) ELSE (
	set baseKey=Microsoft
)

:: Update the entry. The way depends on online or offline installer
IF "%~4" == "0" (
	reg add "%~3\SOFTWARE\%baseKey%\Windows\CurrentVersion\Uninstall\%~1" /f /v "NoModify" /t REG_DWORD /d 1
) ELSE (
	reg add "%~3\SOFTWARE\%baseKey%\Windows\CurrentVersion\Uninstall\%~1" /f /v "UninstallString" /t REG_SZ /d "%~2 uninstallOnly=1"
)

:: Self-Delete
del "%~f0"
