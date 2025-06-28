# Download WORKSPACE.bazel dependencies
Write-Host "Downloading WORKSPACE.bazel dependencies..." -ForegroundColor Green

$OutputDir = "dependencies"
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
    Write-Host "Created directory: $OutputDir" -ForegroundColor Yellow
}

# Download libgvps
Write-Host "Downloading libgvps..." -ForegroundColor Cyan
$url = "https://github.com/Sleepwalking/libgvps/archive/2f1b4106d72f8f8138dc447bf0123820c0772cbd.zip"
$zipFile = "$OutputDir\libgvps.zip"
$extractPath = "$OutputDir\libgvps-2f1b4106d72f8f8138dc447bf0123820c0772cbd"

try {
    Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing
    Expand-Archive -Path $zipFile -DestinationPath $OutputDir -Force
    Rename-Item -Path $extractPath -NewName "libgvps"
    Remove-Item $zipFile -Force
    Write-Host "✓ libgvps downloaded" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to download libgvps: $($_.Exception.Message)" -ForegroundColor Red
}

# Download libnpy
Write-Host "Downloading libnpy..." -ForegroundColor Cyan
$url = "https://github.com/llohse/libnpy/archive/refs/tags/v1.0.1.zip"
$zipFile = "$OutputDir\libnpy.zip"
$extractPath = "$OutputDir\libnpy-1.0.1"

try {
    Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing
    Expand-Archive -Path $zipFile -DestinationPath $OutputDir -Force
    Rename-Item -Path $extractPath -NewName "libnpy"
    Remove-Item $zipFile -Force
    Write-Host "✓ libnpy downloaded" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to download libnpy: $($_.Exception.Message)" -ForegroundColor Red
}

# Download libpyin
Write-Host "Downloading libpyin..." -ForegroundColor Cyan
$url = "https://github.com/Sleepwalking/libpyin/archive/b38135390b335c3e8cea6ef35cf5093789b36dac.zip"
$zipFile = "$OutputDir\libpyin.zip"
$extractPath = "$OutputDir\libpyin-b38135390b335c3e8cea6ef35cf5093789b36dac"

try {
    Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing
    Expand-Archive -Path $zipFile -DestinationPath $OutputDir -Force
    Rename-Item -Path $extractPath -NewName "libpyin"
    Remove-Item $zipFile -Force
    Write-Host "✓ libpyin downloaded" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to download libpyin: $($_.Exception.Message)" -ForegroundColor Red
}

# Download spline
Write-Host "Downloading spline..." -ForegroundColor Cyan
$url = "https://github.com/ttk592/spline/archive/5894beaf91e9adbfdbe5c6c9a1c60770e380e8e8.zip"
$zipFile = "$OutputDir\spline.zip"
$extractPath = "$OutputDir\spline-5894beaf91e9adbfdbe5c6c9a1c60770e380e8e8"

try {
    Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing
    Expand-Archive -Path $zipFile -DestinationPath $OutputDir -Force
    Rename-Item -Path $extractPath -NewName "spline"
    Remove-Item $zipFile -Force
    Write-Host "✓ spline downloaded" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to download spline: $($_.Exception.Message)" -ForegroundColor Red
}

# Download world
Write-Host "Downloading world..." -ForegroundColor Cyan
$url = "https://github.com/mmorise/World/archive/f8dd5fb289db6a7f7f704497752bf32b258f9151.zip"
$zipFile = "$OutputDir\world.zip"
$extractPath = "$OutputDir\World-f8dd5fb289db6a7f7f704497752bf32b258f9151"

try {
    Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing
    Expand-Archive -Path $zipFile -DestinationPath $OutputDir -Force
    Rename-Item -Path $extractPath -NewName "world"
    Remove-Item $zipFile -Force
    Write-Host "✓ world downloaded" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to download world: $($_.Exception.Message)" -ForegroundColor Red
}

# Download miniaudio
Write-Host "Downloading miniaudio..." -ForegroundColor Cyan
$url = "https://github.com/mackron/miniaudio/archive/refs/tags/0.11.21.zip"
$zipFile = "$OutputDir\miniaudio.zip"
$extractPath = "$OutputDir\miniaudio-0.11.21"

try {
    Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing
    Expand-Archive -Path $zipFile -DestinationPath $OutputDir -Force
    Rename-Item -Path $extractPath -NewName "miniaudio"
    Remove-Item $zipFile -Force
    Write-Host "✓ miniaudio downloaded" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to download miniaudio: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nAll WORKSPACE dependencies downloaded!" -ForegroundColor Green
Write-Host "Dependencies location: $((Get-Location).Path)\$OutputDir" -ForegroundColor Yellow

Write-Host "`nAll downloaded libraries:" -ForegroundColor Cyan
Get-ChildItem $OutputDir -Directory | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor White
} 