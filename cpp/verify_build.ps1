# Verify build output
Write-Host "Verifying build output..." -ForegroundColor Green

$bazelBin = bazel info bazel-bin 2>$null
if ($LASTEXITCODE -eq 0) {
    $worldlinePath = Join-Path $bazelBin "worldline\worldline.dll"
    if (Test-Path $worldlinePath) {
        $fileInfo = Get-Item $worldlinePath
        Write-Host "✓ Build successful!" -ForegroundColor Green
        Write-Host "Output file: $worldlinePath" -ForegroundColor Cyan
        Write-Host "File size: $($fileInfo.Length) bytes" -ForegroundColor Cyan
        Write-Host "Last modified: $($fileInfo.LastWriteTime)" -ForegroundColor Cyan
    } else {
        Write-Host "✗ Build output not found: $worldlinePath" -ForegroundColor Red
    }
} else {
    Write-Host "✗ Failed to get bazel-bin path" -ForegroundColor Red
}

# Also check for import library
$importLibPath = Join-Path $bazelBin "worldline\worldline.if.lib"
if (Test-Path $importLibPath) {
    Write-Host "✓ Import library found: $importLibPath" -ForegroundColor Green
} else {
    Write-Host "✗ Import library not found: $importLibPath" -ForegroundColor Red
} 