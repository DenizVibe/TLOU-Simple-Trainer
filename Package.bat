@echo off
rem Builds Release\simpleMenu-v<version>.zip (Fluffy Mod Manager or manual install)
rem from Build\Winmm.dll and the files in Package\Fluffy. Settings are not shipped:
rem the menu keeps them in Documents\Simple Menu, so updates never reset them.
rem Run Build.bat first.
setlocal
set VERSION=1.4.1
cd /d "%~dp0"
if not exist Build\Winmm.dll (
  echo Build\Winmm.dll not found. Run Build.bat first.
  exit /b 1
)
copy /y Build\Winmm.dll Package\Fluffy\winmm.dll >nul || exit /b 1
if exist Package\Fluffy\simpleMenu.ini del Package\Fluffy\simpleMenu.ini
if exist Package\Fluffy\denizMenu.ini del Package\Fluffy\denizMenu.ini
if exist Package\Fluffy\w1zsMenu.ini del Package\Fluffy\w1zsMenu.ini
rem Empty log so Fluffy records it and removes it on uninstall.
type nul > Package\Fluffy\simpleMenu.log
if not exist Release mkdir Release
set ZIP=Release\simpleMenu-v%VERSION%.zip
if exist "%ZIP%" del "%ZIP%"
powershell -NoProfile -Command "Compress-Archive -Path Package\Fluffy\modinfo.ini,Package\Fluffy\screenshot.png,Package\Fluffy\winmm.dll,Package\Fluffy\simpleMenu.log,Package\Fluffy\SimpleMenu-README.txt -DestinationPath '%ZIP%'" || exit /b 1
echo Built %ZIP%
