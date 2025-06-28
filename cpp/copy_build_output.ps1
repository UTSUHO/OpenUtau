# 将 Bazel 构建产物 worldline.dll 和 worldline.if.lib 复制到 cpp/output 目录

$bazelBin = bazel info bazel-bin 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "无法获取 bazel-bin 路径，请确认 Bazel 已安装并在当前目录下运行。" -ForegroundColor Red
    exit 1
}

$outputDir = Join-Path $PSScriptRoot "output"
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
    Write-Host "已创建输出目录: $outputDir" -ForegroundColor Green
}

$srcDll = Join-Path $bazelBin "worldline\worldline.dll"
$srcLib = Join-Path $bazelBin "worldline\worldline.if.lib"

if (Test-Path $srcDll) {
    Copy-Item $srcDll $outputDir -Force
    Write-Host "已复制 worldline.dll 到 $outputDir" -ForegroundColor Green
} else {
    Write-Host "未找到 worldline.dll，构建可能未完成。" -ForegroundColor Red
}

if (Test-Path $srcLib) {
    Copy-Item $srcLib $outputDir -Force
    Write-Host "已复制 worldline.if.lib 到 $outputDir" -ForegroundColor Green
} else {
    Write-Host "未找到 worldline.if.lib，构建可能未完成。" -ForegroundColor Yellow
}
