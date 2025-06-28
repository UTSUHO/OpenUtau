@echo off
chcp 65001 >nul

echo OpenUtau C++ Worldline 编译脚本
echo ================================

echo 正在编译 Windows 版本...
call build_win.bat

echo.
echo 编译完成！
echo 输出文件位置：
echo - Windows x64: ..\output\win-x64\native\worldline.dll
echo - Windows x86: ..\output\win-x86\native\worldline.dll  
echo - Windows ARM64: ..\output\win-arm64\native\worldline.dll
echo.

echo 如需编译其他平台版本，请运行：
echo - Linux: bash build_linux.sh
echo - macOS: bash build_mac.sh
echo.

pause 