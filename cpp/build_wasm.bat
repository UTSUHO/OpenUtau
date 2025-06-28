@echo off
echo Building OpenUtau C++ Worldline for WebAssembly...
echo.

echo Checking Emscripten SDK availability...
bazel query @emsdk//... >nul 2>&1
if %errorlevel% neq 0 (
    echo Warning: Emscripten SDK not found. Attempting to fetch...
    bazel fetch @emsdk//...
    if %errorlevel% neq 0 (
        echo Error: Failed to fetch Emscripten SDK
        echo Please ensure you have internet connection and try again.
        pause
        exit /b 1
    )
)

echo Building WASM version...
if not exist ..\output\wasm\native mkdir ..\output\wasm\native

bazel build //worldline:worldline_wasm --config=wasm -c opt
if %errorlevel% neq 0 (
    echo Error: Failed to build WASM version
    echo.
    echo This might be due to:
    echo 1. Missing Emscripten SDK
    echo 2. Incompatible dependencies with WASM
    echo 3. Code that doesn't compile for WASM target
    echo.
    echo Try running: bazel clean --expunge
    echo Then retry the build.
    pause
    exit /b %errorlevel%
)

echo Copying WASM files...
if exist bazel-bin\worldline\worldline_wasm.js (
    copy bazel-bin\worldline\worldline_wasm.js ..\output\wasm\native\worldline.js
    echo Successfully copied worldline.js
) else (
    echo Warning: worldline.js not found
)

if exist bazel-bin\worldline\worldline_wasm.wasm (
    copy bazel-bin\worldline\worldline_wasm.wasm ..\output\wasm\native\worldline.wasm
    echo Successfully copied worldline.wasm
) else (
    echo Warning: worldline.wasm not found
)

if exist bazel-bin\worldline\worldline_wasm.wasm.map (
    copy bazel-bin\worldline\worldline_wasm.wasm.map ..\output\wasm\native\worldline.wasm.map
    echo Successfully copied source map
)

echo.
echo WASM build completed!
echo Output files:
if exist ..\output\wasm\native\worldline.js echo - JavaScript loader: ..\output\wasm\native\worldline.js
if exist ..\output\wasm\native\worldline.wasm echo - WASM binary: ..\output\wasm\native\worldline.wasm
if exist ..\output\wasm\native\worldline.wasm.map echo - Source map: ..\output\wasm\native\worldline.wasm.map
echo.

echo Usage example:
echo ^<script src="worldline.js"^>^</script^>
echo ^<script^>
echo   WorldlineModule().then(module =^> {
echo     console.log(module.getVersionString());
echo     // Use module.synthesize(...) for audio synthesis
echo   });
echo ^</script^>
echo.

pause 