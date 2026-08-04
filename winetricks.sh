#!/bin/bash

# As docker can only run one process we have to use this script to get Xvfb running while calling winetricks stuff
Xvfb :5 -screen 0 1024x768x16 &
env WINEARCH=win64 WINEDEBUG=-all WINEPREFIX=/root/server WINEDLLOVERRIDES="mscoree=d" wineboot --init /nogui 
env WINEARCH=win64 WINEDEBUG=-all WINEPREFIX=/root/server wine winecfg /v win10
env WINEARCH=win64 WINEDEBUG=-all WINEPREFIX=/root/server winetricks corefonts
env WINEARCH=win64 WINEDEBUG=-all WINEPREFIX=/root/server winetricks sound=disabled

# Install vcrun2022 block
echo "Downloading 64-bit VC++ 2022 natively with retry logic..."
curl -L -f --retry 5 --retry-delay 5 -o /tmp/vc_redist.x64.exe "https://aka.ms/vs/17/release/vc_redist.x64.exe"

echo "Installing 64-bit VC++ 2022 silently..."
env WINEARCH=win64 WINEDEBUG=-all WINEPREFIX=/root/server DISPLAY=:5.0 wine /tmp/vc_redist.x64.exe /q /norestart

# Wait until all Wine background processes finish
env WINEPREFIX=/root/server wineserver -w

#echo "Injecting VC++ x64 Registry keys for Space Engineers safety net..."
#env WINEARCH=win64 WINEDEBUG=-all WINEPREFIX=/root/server wine reg add "HKLM\Software\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" /v Installed /t REG_DWORD /d 1 /f
#env WINEARCH=win64 WINEDEBUG=-all WINEPREFIX=/root/server wine reg add "HKLM\Software\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" /v MajorVersion /t REG_DWORD /d 14 /f
#env WINEARCH=win64 WINEDEBUG=-all WINEPREFIX=/root/server wine reg add "HKLM\Software\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" /v MinorVersion /t REG_DWORD /d 29 /f

# Wait again just to ensure the registry writes commit to disk
#env WINEPREFIX=/root/server wineserver -w

# Install dotnet48
env WINEARCH=win64 WINEDEBUG=-all WINEPREFIX=/root/server DISPLAY=:5.0 winetricks -q --force dotnet48