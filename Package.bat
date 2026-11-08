@echo off
rem Builds Release\simpleMenu-v<version>.zip (Fluffy Mod Manager or manual install)
rem from Build\Winmm.dll and the files in Package\fluffy. Settings are not shipped:
rem the menu keeps them in Documents\Simple Menu, so updates never reset them.
rem Run Build.bat first.
setlocal
set VERSION=1.4.1
cd /d "%~dp0"
if not exist Build\Winmm.dll (
  echo Build\Winmm.dll not found. Run Build.bat first.
  exit /b 1
)
copy /y Build\Winmm.dll Package\fluffy\winmm.dll >nul || exit /b 1
if exist Package\fluffy\simpleMenu.ini del Package\fluffy\simpleMenu.ini
if exist Package\fluffy\denizMenu.ini del Package\fluffy\denizMenu.ini
if exist Package\fluffy\w1zsMenu.ini del Package\fluffy\w1zsMenu.ini
rem Empty log so Fluffy records it and removes it on uninstall.
type nul > Package\fluffy\simpleMenu.log
if not exist Release mkdir Release
set ZIP=Release\simpleMenu-v%VERSION%.zip
if exist "%ZIP%" del "%ZIP%"
powershell -NoProfile -Command "Compress-Archive -Path Package\fluffy\modinfo.ini,Package\fluffy\screenshot.png,Package\fluffy\winmm.dll,Package\fluffy\simpleMenu.log,Package\fluffy\SimpleMenu-README.txt -DestinationPath '%ZIP%'" || exit /b 1
echo Built %ZIP%
