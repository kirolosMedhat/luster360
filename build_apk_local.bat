@echo off
echo ===================================================
echo   LUSTER 360 — LOCAL ANDROID APK BUILDER
echo ===================================================
echo.
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Flutter SDK not detected in system PATH.
    echo Please install Flutter 3.24+ or push to GitHub to use
    echo the automated Cloud Build Workflow in .github/workflows/build-mobile.yml
    echo.
    pause
    exit /b 1
)

echo [1/3] Navigating to mobile_app directory...
cd mobile_app

echo [2/3] Fetching Flutter dependencies...
call flutter pub get

echo [3/3] Compiling Release Android APK...
call flutter build apk --release --split-per-abi

echo.
echo ===================================================
echo [SUCCESS] APK built at:
echo mobile_app\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
echo ===================================================
pause
