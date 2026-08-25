@echo off
set FLUTTER_DIR=C:\src\flutter
if exist "%FLUTTER_DIR%" (
    echo Flutter already exists at %FLUTTER_DIR%
) else (
    echo Downloading Flutter...
    if not exist "C:\src" mkdir "C:\src"
    curl.exe -L -o C:\src\flutter.zip https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.1-stable.zip
    echo Extracting Flutter...
    tar.exe -xf C:\src\flutter.zip -C C:\src\
    del C:\src\flutter.zip
    echo Flutter installed at %FLUTTER_DIR%
)

echo Initializing Project...
set MOBILE_DIR=c:\Users\Administrator\Downloads\iot nusa power\mobile
cd /d "%MOBILE_DIR%"
move pubspec.yaml pubspec.yaml.bak
move lib\main.dart lib\main.dart.bak

call C:\src\flutter\bin\flutter.bat create .

move /Y pubspec.yaml.bak pubspec.yaml
move /Y lib\main.dart.bak lib\main.dart

call C:\src\flutter\bin\flutter.bat pub get
