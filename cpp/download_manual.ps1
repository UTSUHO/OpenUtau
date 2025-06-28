# Manual download script for OpenUtau dependencies
Write-Host "Manual download of OpenUtau C++ dependencies" -ForegroundColor Green

$OutputDir = "dependencies"
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
    Write-Host "Created directory: $OutputDir" -ForegroundColor Yellow
}

# Download abseil-cpp
Write-Host "Downloading abseil-cpp..." -ForegroundColor Cyan
$url = "https://github.com/abseil/abseil-cpp/archive/refs/tags/20240116.1.zip"
$zipFile = "$OutputDir\abseil-cpp.zip"
$extractPath = "$OutputDir\abseil-cpp-20240116.1"
$finalPath = "$OutputDir\abseil-cpp"

try {
    Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing
    Expand-Archive -Path $zipFile -DestinationPath $OutputDir -Force
    Rename-Item -Path $extractPath -NewName "abseil-cpp"
    Remove-Item $zipFile -Force
    Write-Host "✓ abseil-cpp downloaded" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to download abseil-cpp: $($_.Exception.Message)" -ForegroundColor Red
}

# Download googletest
Write-Host "Downloading googletest..." -ForegroundColor Cyan
$url = "https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip"
$zipFile = "$OutputDir\googletest.zip"
$extractPath = "$OutputDir\googletest-1.14.0"
$finalPath = "$OutputDir\googletest"

try {
    Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing
    Expand-Archive -Path $zipFile -DestinationPath $OutputDir -Force
    Rename-Item -Path $extractPath -NewName "googletest"
    Remove-Item $zipFile -Force
    Write-Host "✓ googletest downloaded" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to download googletest: $($_.Exception.Message)" -ForegroundColor Red
}

# Download xxhash
Write-Host "Downloading xxhash..." -ForegroundColor Cyan
$url = "https://github.com/Cyan4973/xxHash/archive/refs/tags/v0.8.2.zip"
$zipFile = "$OutputDir\xxhash.zip"
$extractPath = "$OutputDir\xxHash-0.8.2"
$finalPath = "$OutputDir\xxhash"

try {
    Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing
    Expand-Archive -Path $zipFile -DestinationPath $OutputDir -Force
    Rename-Item -Path $extractPath -NewName "xxhash"
    Remove-Item $zipFile -Force
    Write-Host "✓ xxhash downloaded" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to download xxhash: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nDownload completed!" -ForegroundColor Green
Write-Host "Dependencies location: $((Get-Location).Path)\$OutputDir" -ForegroundColor Yellow

Write-Host "`nDownloaded libraries:" -ForegroundColor Cyan
Get-ChildItem $OutputDir -Directory | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor White
} 