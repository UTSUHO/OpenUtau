@echo off
setlocal enabledelayedexpansion

REM OpenUtau C++ 依赖库下载脚本
REM 此脚本将下载所有Bazel配置中定义的依赖库到本地文件夹

set OUTPUT_DIR=dependencies
set FORCE_DOWNLOAD=false

if "%1"=="--force" set FORCE_DOWNLOAD=true

echo 开始下载 OpenUtau C++ 依赖库...

REM 创建输出目录
if not exist "%OUTPUT_DIR%" (
    mkdir "%OUTPUT_DIR%"
    echo 创建目录: %OUTPUT_DIR%
)

REM 定义依赖库信息（使用数组模拟）
set deps[0]=abseil-cpp
set deps[1]=googletest
set deps[2]=xxhash
set deps[3]=libgvps
set deps[4]=libnpy
set deps[5]=libpyin
set deps[6]=spline
set deps[7]=world
set deps[8]=miniaudio

set urls[0]=https://github.com/abseil/abseil-cpp/archive/refs/tags/20240116.1.zip
set urls[1]=https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
set urls[2]=https://github.com/Cyan4973/xxHash/archive/refs/tags/v0.8.2.zip
set urls[3]=https://github.com/Sleepwalking/libgvps/archive/2f1b4106d72f8f8138dc447bf0123820c0772cbd.zip
set urls[4]=https://github.com/llohse/libnpy/archive/refs/tags/v1.0.1.zip
set urls[5]=https://github.com/Sleepwalking/libpyin/archive/b38135390b335c3e8cea6ef35cf5093789b36dac.zip
set urls[6]=https://github.com/ttk592/spline/archive/5894beaf91e9adbfdbe5c6c9a1c60770e380e8e8.zip
set urls[7]=https://github.com/mmorise/World/archive/f8dd5fb289db6a7f7f704497752bf32b258f9151.zip
set urls[8]=https://github.com/mackron/miniaudio/archive/refs/tags/0.11.21.zip

set extract_paths[0]=abseil-cpp-20240116.1
set extract_paths[1]=googletest-1.14.0
set extract_paths[2]=xxHash-0.8.2
set extract_paths[3]=libgvps-2f1b4106d72f8f8138dc447bf0123820c0772cbd
set extract_paths[4]=libnpy-1.0.1
set extract_paths[5]=libpyin-b38135390b335c3e8cea6ef35cf5093789b36dac
set extract_paths[6]=spline-5894beaf91e9adbfdbe5c6c9a1c60770e380e8e8
set extract_paths[7]=World-f8dd5fb289db6a7f7f704497752bf32b258f9151
set extract_paths[8]=miniaudio-0.11.21

set local_paths[0]=abseil-cpp
set local_paths[1]=googletest
set local_paths[2]=xxhash
set local_paths[3]=libgvps
set local_paths[4]=libnpy
set local_paths[5]=libpyin
set local_paths[6]=spline
set local_paths[7]=world
set local_paths[8]=miniaudio

REM 下载所有依赖
for /L %%i in (0,1,8) do (
    set dep_name=!deps[%%i]!
    set dep_url=!urls[%%i]!
    set extract_path=!extract_paths[%%i]!
    set local_path=!local_paths[%%i]!
    
    set local_dir=%OUTPUT_DIR%\!local_path!
    set zip_file=%OUTPUT_DIR%\!dep_name!.zip
    
    REM 检查是否已存在
    if exist "!local_dir!" (
        if "%FORCE_DOWNLOAD%"=="false" (
            echo 跳过 !dep_name! - 已存在
            goto :continue
        )
    )
    
    echo 下载 !dep_name!...
    
    REM 下载文件
    powershell -Command "Invoke-WebRequest -Uri '!dep_url!' -OutFile '!zip_file!' -UseBasicParsing"
    if errorlevel 1 (
        echo 下载 !dep_name! 失败
        goto :continue
    )
    
    REM 解压文件
    echo 解压 !dep_name!...
    powershell -Command "Expand-Archive -Path '!zip_file!' -DestinationPath '%OUTPUT_DIR%' -Force"
    
    REM 重命名到目标目录
    set extracted_dir=%OUTPUT_DIR%\!extract_path!
    if exist "!local_dir!" (
        rmdir /s /q "!local_dir!"
    )
    ren "!extracted_dir!" "!local_path!"
    
    REM 清理zip文件
    del "!zip_file!"
    
    echo ✓ !dep_name! 下载完成
    
    :continue
)

echo.
echo 所有依赖库下载完成！
echo 依赖库位置: %CD%\%OUTPUT_DIR%

REM 显示下载的库列表
echo.
echo 已下载的依赖库:
for /d %%d in (%OUTPUT_DIR%\*) do (
    echo   - %%~nxd
)

pause 