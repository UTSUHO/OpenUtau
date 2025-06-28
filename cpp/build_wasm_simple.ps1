# 简化的worldline WebAssembly构建脚本（分步编译C和C++文件）

Write-Host "开始构建worldline WebAssembly版本..." -ForegroundColor Green

# 检查Emscripten是否已安装
try {
    $emccVersion = emcc --version
    Write-Host "Emscripten版本: $emccVersion" -ForegroundColor Green
} catch {
    Write-Host "错误: 未找到Emscripten。请先安装Emscripten SDK。" -ForegroundColor Red
    Write-Host "安装命令: git clone https://github.com/emscripten-core/emsdk.git" -ForegroundColor Yellow
    Write-Host "然后: cd emsdk" -ForegroundColor Yellow
    Write-Host "然后: ./emsdk install latest" -ForegroundColor Yellow
    Write-Host "然后: ./emsdk activate latest" -ForegroundColor Yellow
    exit 1
}

# 设置输出目录
$outputDir = "../node/dist"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

# 设置临时对象文件目录
$tempObjDir = "output/wasm"
if (-not (Test-Path $tempObjDir)) {
    New-Item -ItemType Directory -Path $tempObjDir -Force | Out-Null
}

# 收集所有源文件
$sourceFiles = @(
    # worldline核心文件
    "worldline/worldline.cpp",
    "worldline/phrase_synth.cpp",
    
    # worldline f0估计器
    "worldline/f0/dio_estimator.cpp",
    "worldline/f0/dio_ss_estimator.cpp",
    "worldline/f0/pyin_estimator.cpp",
    "worldline/f0/frq_estimator.cpp",
    
    # worldline classic模块
    "worldline/classic/resampler.cpp",
    "worldline/classic/frq.cpp",
    "worldline/classic/timing.cpp",
    "worldline/classic/classic_args.cpp",
    
    # worldline model模块
    "worldline/model/model.cpp",
    "worldline/model/effects.cpp",
    
    # worldline common模块
    "worldline/common/vec_utils.cpp",
    "worldline/common/timer.cpp",
    
    # world依赖库
    "dependencies/world/src/codec.cpp",
    "dependencies/world/src/synthesis.cpp",
    "dependencies/world/src/matlabfunctions.cpp",
    "dependencies/world/src/common.cpp",
    "dependencies/world/src/cheaptrick.cpp",
    "dependencies/world/src/d4c.cpp",
    "dependencies/world/src/dio.cpp",
    "dependencies/world/src/fft.cpp",
    "dependencies/world/src/harvest.cpp",
    "dependencies/world/src/stonemask.cpp"
)

# 自动收集libpyin和libgvps下所有.c文件
$libpyinCFiles = Get-ChildItem -Path "dependencies/libpyin" -Filter *.c | ForEach-Object { $_.FullName.Replace("$PWD\\", "") }
$libgvpsCFiles = Get-ChildItem -Path "dependencies/libgvps" -Filter *.c | ForEach-Object { $_.FullName.Replace("$PWD\\", "") }

# 合并到C文件列表
$sourceFiles += $libpyinCFiles
$sourceFiles += $libgvpsCFiles

# 检查源文件是否存在
$missingFiles = @()
foreach ($file in $sourceFiles) {
    if (-not (Test-Path $file)) {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "警告: 以下源文件不存在:" -ForegroundColor Yellow
    foreach ($file in $missingFiles) {
        Write-Host "  - $file" -ForegroundColor Yellow
    }
    Write-Host "将跳过这些文件继续构建..." -ForegroundColor Yellow
}

# 过滤存在的源文件
$existingFiles = $sourceFiles | Where-Object { Test-Path $_ }
Write-Host "找到 $($existingFiles.Count) 个源文件" -ForegroundColor Green

# 分离C和C++文件
$cFiles = $existingFiles | Where-Object { $_.ToLower().EndsWith('.c') }
$cppFiles = $existingFiles | Where-Object { $_.ToLower().EndsWith('.cpp') }

# include参数
$includeArgs = @(
    "-I", ".",
    "-I", "worldline",
    "-I", "worldline/f0",
    "-I", "dependencies/world/src",
    "-I", "dependencies/world/tools",
    "-I", "dependencies/miniaudio",
    "-I", "dependencies/xxhash",
    "-I", "dependencies/libpyin",
    "-I", "dependencies/abseil-cpp",
    "-I", "dependencies/spline/src",
    "-I", "dependencies/libnpy/include",
    "-I", "dependencies"
)

# 1. 编译C文件
$objFiles = @()
foreach ($cFile in $cFiles) {
    $objFile = Join-Path $tempObjDir ([System.IO.Path]::GetFileNameWithoutExtension($cFile) + ".o")
    Write-Host "编译C文件: $cFile -> $objFile" -ForegroundColor Cyan
    & emcc -c $cFile -o $objFile -DFP_TYPE=double @includeArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Host "C文件编译失败: $cFile" -ForegroundColor Red
        exit 1
    }
    $objFiles += $objFile
}

# 2. 编译C++文件
foreach ($cppFile in $cppFiles) {
    $objFile = Join-Path $tempObjDir ([System.IO.Path]::GetFileNameWithoutExtension($cppFile) + ".o")
    Write-Host "编译C++文件: $cppFile -> $objFile" -ForegroundColor Cyan
    & emcc -c $cppFile -o $objFile -std=c++17 -O2 @includeArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Host "C++文件编译失败: $cppFile" -ForegroundColor Red
        exit 1
    }
    $objFiles += $objFile
}

# 3. 链接所有对象文件生成wasm
Write-Host "链接所有对象文件生成WebAssembly..." -ForegroundColor Yellow
$emccLinkArgs = @(
    "--bind",
    "-s", "WASM=1",
    "-s", "EXPORTED_FUNCTIONS=['_F0','_DecodeMgc','_DecodeBap','_WorldSynthesis','_Resample','_PhraseSynthNew','_PhraseSynthDelete','_PhraseSynthAddRequest','_PhraseSynthSetCurves','_PhraseSynthSynth']",
    "-s", "EXPORTED_RUNTIME_METHODS=['ccall','cwrap']",
    "-s", "ALLOW_MEMORY_GROWTH=1",
    "-s", "INITIAL_MEMORY=16777216",
    "-s", "MAXIMUM_MEMORY=268435456",
    "-s", "EXPORT_NAME='WorldlineModule'",
    "-s", "MODULARIZE=1",
    "-o", "$outputDir/worldline_wasm.js"
) + $objFiles

& emcc @emccLinkArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host "WebAssembly构建成功！" -ForegroundColor Green
    Write-Host "输出文件:" -ForegroundColor Cyan
    Write-Host "  - $outputDir/worldline_wasm.js" -ForegroundColor Green
    Write-Host "  - $outputDir/worldline_wasm.wasm" -ForegroundColor Green
} else {
    Write-Host "WebAssembly构建失败！" -ForegroundColor Red
    Write-Host "临时对象文件保留在: $tempObjDir" -ForegroundColor Yellow
    exit 1
} 