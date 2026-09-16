@echo off
echo =======================================================
echo   LUSTER 360 -- ONE-CLICK ANDROID USB INSTALLER
echo =======================================================
echo.

set ADB=E:\Android\sdk\platform-tools\adb.exe

if not exist %ADB% (
    set ADB=adb
)

echo [1/2] Detecting connected Android devices...
%ADB% devices
echo.

echo [2/2] Installing Luster-360-v1.0.0.apk onto connected phone...
%ADB% install -r %~dp0Luster-360-v1.0.0.apk

if %errorlevel% equ 0 (
    echo.
    echo =======================================================
    echo   [SUCCESS] Luster 360 App installed on your phone!
    echo =======================================================
) else (
    echo.
    echo [NOTE] If no device was found, please:
    echo   1. Connect your Android phone with a USB cable
    echo   2. Enable 'USB Debugging' in Developer Options
    echo   3. Or simply open http://192.168.1.6:3001/luster360.apk in your phone's browser
)

echo.
pause
