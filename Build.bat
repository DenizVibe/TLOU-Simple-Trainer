@echo off
rem Builds Winmm.dll (Simple Menu) and Scan.Test.exe with the MSVC x64 toolchain.
rem Requires Visual Studio 2022 Build Tools with the "Desktop development with C++" workload.
setlocal
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
for /f "usebackq delims=" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VSDIR=%%i"
if not defined VSDIR (
  echo MSVC x64 tools not found. Install Visual Studio 2022 Build Tools with the C++ workload.
  exit /b 1
)
call "%VSDIR%\VC\Auxiliary\Build\vcvars64.bat" >nul || exit /b 1

cd /d "%~dp0"
if not exist Build\Obj mkdir Build\Obj
if not exist Build\Obj3 mkdir Build\Obj3
del /q Build\Obj\*.obj 2>nul

rem /EHa: C++ destructors also run for SEH exceptions caught by the overlay's guard.
set COMMON=/nologo /O2 /MT /GS /guard:cf /DUNICODE /D_UNICODE /DWIN32_LEAN_AND_MEAN /DNOMINMAX
set INCLUDES=/I. /ISrc /ISrc\Core /ISrc\Engine /ISrc\Features /ISrc\Input /ISrc\Settings /ISrc\UI /IExternal\ImGui /IExternal\MinHook\include
set CFLAGS=%COMMON% /std:c++17 /W4 /WX /EHa /DIMGUI_DISABLE_OBSOLETE_FUNCTIONS %INCLUDES%
set TPFLAGS=%COMMON% /W3 /EHa /DIMGUI_DISABLE_OBSOLETE_FUNCTIONS /IExternal\ImGui

set SRC_CORE=Src\Core\Dll.Main.cpp Src\Core\Log.cpp Src\Core\Proxy.Winmm.cpp
set SRC_ENGINE=Src\Engine\Game.cpp Src\Engine\Engine.cpp Src\Engine\Scan.cpp Src\Engine\D.Scan.cpp Src\Engine\Skin.Scan.cpp
set SRC_FEATURES=Src\Features\Ammo.cpp Src\Features\Character.cpp Src\Features\Features.cpp Src\Features\Skins.cpp Src\Features\Upgrades.cpp Src\Features\Pause.cpp
set SRC_INPUT=Src\Input\Input.cpp Src\Input\Hotkeys.cpp
set SRC_SETTINGS=Src\Settings\Settings.cpp
set SRC_UI=Src\UI\Render.cpp Src\UI\Menu.cpp

set ALL_SRC=%SRC_CORE% %SRC_ENGINE% %SRC_FEATURES% %SRC_INPUT% %SRC_SETTINGS% %SRC_UI%

set IMGUI=External\ImGui\imgui.cpp External\ImGui\imgui_draw.cpp External\ImGui\imgui_tables.cpp ^
 External\ImGui\imgui_widgets.cpp External\ImGui\backends\imgui_impl_dx12.cpp
set MINHOOK=External\MinHook\src\buffer.c External\MinHook\src\hook.c External\MinHook\src\trampoline.c ^
 External\MinHook\src\hde\hde64.c

cl %TPFLAGS% /c %IMGUI% /Fo"Build\Obj3\\" || exit /b 1
cl %COMMON% /W3 /c %MINHOOK% /Fo"Build\Obj3\\" || exit /b 1
cl %CFLAGS% /c %ALL_SRC% /Fo"Build\Obj\\" || exit /b 1
ml64 /nologo /c /Fo"Build\Obj\Winmm.Stubs.obj" Src\Core\Winmm.Stubs.asm || exit /b 1
ml64 /nologo /c /Fo"Build\Obj\Trace.Thunks.obj" Src\Core\Trace.Thunks.asm || exit /b 1
if exist Build\version.dll del Build\version.dll
link /nologo /DLL /DEF:Src\Core\Winmm.def /GUARD:CF /IMPLIB:Build\Winmm.lib /OUT:Build\Winmm.dll Build\Obj\*.obj Build\Obj3\*.obj ^
 user32.lib kernel32.lib shell32.lib d3d12.lib dxgi.lib || exit /b 1
cl %CFLAGS% Tests\Scan.Test.cpp Src\Engine\Scan.cpp Src\Engine\D.Scan.cpp Src\Engine\Skin.Scan.cpp /Fo"Build\\" /Fe"Build\Scan.Test.exe" || exit /b 1
cl %CFLAGS% Tests\Proxy.Test.cpp /Fo"Build\\" /Fe"Build\Proxy.Test.exe" || exit /b 1

echo.
echo Built Build\Winmm.dll, Build\Scan.Test.exe and Build\Proxy.Test.exe
