@echo off
echo Building OpenUtau C++ Worldline for Windows...
echo.

echo Building win-x64...
if not exist ..\output\win-x64\native mkdir ..\output\win-x64\native
bazel build //worldline:worldline -c opt --cpu=x64_windows
if %errorlevel% neq 0 (
    echo Error: Failed to build win-x64
    pause
    exit /b %errorlevel%
)
if exist bazel-bin\worldline\worldline.dll (
    attrib -r bazel-bin\worldline\worldline.dll
    copy bazel-bin\worldline\worldline.dll ..\output\win-x64\native\worldline.dll
    echo Successfully built win-x64
) else (
    echo Error: Output file not found for win-x64
    pause
    exit /b 1
)
echo.

echo Building win-x86...
if not exist ..\output\win-x86\native mkdir ..\output\win-x86\native
bazel build //worldline:worldline -c opt --cpu=x64_x86_windows
if %errorlevel% neq 0 (
    echo Error: Failed to build win-x86
    pause
    exit /b %errorlevel%
)
if exist bazel-bin\worldline\worldline.dll (
    attrib -r bazel-bin\worldline\worldline.dll
    copy bazel-bin\worldline\worldline.dll ..\output\win-x86\native\worldline.dll
    echo Successfully built win-x86
) else (
    echo Error: Output file not found for win-x86
    pause
    exit /b 1
)
echo.

echo Building win-arm64 (optional)...
if not exist ..\output\win-arm64\native mkdir ..\output\win-arm64\native
bazel build //worldline:worldline -c opt --cpu=arm64_windows
if %errorlevel% neq 0 (
    echo Warning: Failed to build win-arm64 (ARM64 toolchain may not be installed)
    echo This is optional and won't affect other builds.
) else (
    if exist bazel-bin\worldline\worldline.dll (
        attrib -r bazel-bin\worldline\worldline.dll
        copy bazel-bin\worldline\worldline.dll ..\output\win-arm64\native\worldline.dll
        echo Successfully built win-arm64
    ) else (
        echo Warning: Output file not found for win-arm64
    )
)
echo.

echo Windows builds completed!
echo Successfully built:
if exist ..\output\win-x64\native\worldline.dll echo - win-x64: ..\output\win-x64\native\worldline.dll
if exist ..\output\win-x86\native\worldline.dll echo - win-x86: ..\output\win-x86\native\worldline.dll
if exist ..\output\win-arm64\native\worldline.dll echo - win-arm64: ..\output\win-arm64\native\worldline.dll
echo.
echo Note: ARM64 build requires Visual Studio with ARM64 toolchain installed.
pause
