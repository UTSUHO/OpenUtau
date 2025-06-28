@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo OpenUtau C++ Worldline 安装和编译脚本
echo =====================================
echo.

:: 检查是否已安装 bazel 或 bazelisk
where bazel >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ 检测到 bazel 已安装
    goto :BUILD
)

where bazelisk >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ 检测到 bazelisk 已安装
    goto :BUILD
)

echo ⚠ 未检测到 Bazel/Bazelisk，正在自动安装...
echo.

:: 创建临时目录
if not exist temp mkdir temp
cd temp

:: 下载 Bazelisk
echo 正在下载 Bazelisk...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-windows-amd64.exe' -OutFile 'bazelisk.exe'}"

if not exist bazelisk.exe (
    echo ❌ 下载失败，请手动安装 Bazelisk
    echo 下载地址: https://github.com/bazelbuild/bazelisk/releases
    pause
    exit /b 1
)

:: 将 bazelisk 复制到系统路径
echo 正在安装 Bazelisk...
copy bazelisk.exe "%USERPROFILE%\bazelisk.exe" >nul
copy bazelisk.exe "%USERPROFILE%\bazel.exe" >nul

:: 添加到 PATH（当前会话）
set "PATH=%USERPROFILE%;%PATH%"

:: 清理临时文件
cd ..
rmdir /s /q temp

echo ✓ Bazelisk 安装完成
echo.

:BUILD
echo 开始编译 OpenUtau C++ Worldline...
echo.

:: 设置编译函数
goto :MAIN

:BUILD_TARGET
echo 正在编译 %~1...
if not exist ..\output\%~1\native mkdir ..\output\%~1\native

bazel build //worldline:worldline -c opt --cpu=%~2
if %errorlevel% neq 0 (
    echo ❌ 编译 %~1 失败
    exit /b %errorlevel%
)

if exist bazel-bin\worldline\worldline.dll (
    attrib -r bazel-bin\worldline\worldline.dll
    copy bazel-bin\worldline\worldline.dll ..\output\%~1\native\ >nul
    echo ✓ %~1 编译成功
) else (
    echo ❌ 找不到编译输出文件 %~1
)
echo.
exit /b 0

:MAIN
call :BUILD_TARGET win-x64 x64_windows
if %errorlevel% neq 0 exit /b %errorlevel%

call :BUILD_TARGET win-x86 x64_x86_windows  
if %errorlevel% neq 0 exit /b %errorlevel%

call :BUILD_TARGET win-arm64 arm64_windows
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo 🎉 编译完成！
echo.
echo 输出文件位置：
echo - Windows x64: ..\output\win-x64\native\worldline.dll
echo - Windows x86: ..\output\win-x86\native\worldline.dll  
echo - Windows ARM64: ..\output\win-arm64\native\worldline.dll
echo.
echo 如需编译其他平台版本，请运行：
echo - Linux: bash build_linux.sh
echo - macOS: bash build_mac.sh
echo.

:: 添加 bazelisk 到用户 PATH（永久）
echo 正在将 Bazelisk 添加到系统 PATH...
powershell -Command "& {$path = [Environment]::GetEnvironmentVariable('PATH', 'User'); if ($path -notlike '*%USERPROFILE%*') { [Environment]::SetEnvironmentVariable('PATH', $path + ';%USERPROFILE%', 'User') }}"

echo.
echo 💡 提示：Bazelisk 已安装到 %USERPROFILE%
echo    重启命令行后可直接使用 bazel 命令
echo.

pause 