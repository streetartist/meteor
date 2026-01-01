@echo off
REM Meteor HTTP Native Library Build Script (Windows)
REM 需要安装 Visual Studio 或 MinGW

echo ========================================
echo   Building Meteor HTTP Native Library
echo ========================================
echo.

cd /d %~dp0

REM 检测编译器
where cl >nul 2>nul
if %ERRORLEVEL% == 0 (
    echo Using MSVC compiler...
    goto :msvc
)

where gcc >nul 2>nul
if %ERRORLEVEL% == 0 (
    echo Using GCC compiler...
    goto :gcc
)

echo ERROR: No C compiler found!
echo Please install Visual Studio or MinGW.
exit /b 1

:msvc
REM MSVC 编译
cl /LD /O2 /Fe:http_native.dll http_native.c /link ws2_32.lib
if %ERRORLEVEL% == 0 (
    echo.
    echo SUCCESS: http_native.dll created!
) else (
    echo ERROR: Compilation failed!
    exit /b 1
)
goto :end

:gcc
REM GCC/MinGW 编译
gcc -shared -O2 -o http_native.dll http_native.c -lws2_32
if %ERRORLEVEL% == 0 (
    echo.
    echo SUCCESS: http_native.dll created!
) else (
    echo ERROR: Compilation failed!
    exit /b 1
)
goto :end

:end
echo.
echo Library is ready to use!
