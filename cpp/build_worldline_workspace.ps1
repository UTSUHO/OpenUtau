# Build worldline using WORKSPACE mode with local dependencies
Write-Host "Building worldline using WORKSPACE mode..." -ForegroundColor Green

# Backup original files
Write-Host "Backing up original Bazel files..." -ForegroundColor Yellow
if (Test-Path "WORKSPACE.bazel") {
    Copy-Item "WORKSPACE.bazel" "WORKSPACE.bazel.backup" -Force
}
if (Test-Path "MODULE.bazel") {
    Copy-Item "MODULE.bazel" "MODULE.bazel.backup" -Force
}
if (Test-Path "worldline/BUILD.bazel") {
    Copy-Item "worldline/BUILD.bazel" "worldline/BUILD.bazel.backup" -Force
}

# Replace with local dependency versions
Write-Host "Using local dependency configurations..." -ForegroundColor Yellow
Copy-Item "WORKSPACE_complete.bazel" "WORKSPACE.bazel" -Force
Copy-Item "MODULE_simple.bazel" "MODULE.bazel" -Force
Copy-Item "worldline/BUILD_local.bazel" "worldline/BUILD.bazel" -Force

# Check if Bazel is available
try {
    $bazelVersion = bazel --version
    Write-Host "Found Bazel: $bazelVersion" -ForegroundColor Green
} catch {
    Write-Host "Bazel not found. Please install Bazel first." -ForegroundColor Red
    Write-Host "Visit: https://bazel.build/install" -ForegroundColor Yellow
    exit 1
}

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Cyan
bazel clean --expunge

# Build worldline
Write-Host "Building worldline..." -ForegroundColor Cyan
bazel build //worldline:worldline

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ worldline built successfully!" -ForegroundColor Green
    
    # Build main binary
    Write-Host "Building main binary..." -ForegroundColor Cyan
    bazel build //worldline:main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ main binary built successfully!" -ForegroundColor Green
    }
    
    # Build tests
    Write-Host "Building tests..." -ForegroundColor Cyan
    bazel build //worldline:worldline_test
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ tests built successfully!" -ForegroundColor Green
    }
    
    # Build audio debug
    Write-Host "Building audio debug..." -ForegroundColor Cyan
    bazel build //worldline:audio_debug
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ audio debug built successfully!" -ForegroundColor Green
    }
    
    # Show build artifacts
    Write-Host "`nBuild artifacts:" -ForegroundColor Cyan
    Write-Host "  - Shared library: bazel-bin/worldline/libworldline.dll" -ForegroundColor White
    Write-Host "  - Main binary: bazel-bin/worldline/main.exe" -ForegroundColor White
    Write-Host "  - Test binary: bazel-bin/worldline/worldline_test.exe" -ForegroundColor White
    Write-Host "  - Audio debug: bazel-bin/worldline/audio_debug.exe" -ForegroundColor White
    
    # List actual files
    Write-Host "`nActual build outputs:" -ForegroundColor Cyan
    if (Test-Path "bazel-bin/worldline") {
        Get-ChildItem "bazel-bin/worldline" -Recurse | Where-Object { $_.Extension -eq ".exe" -or $_.Extension -eq ".dll" } | ForEach-Object {
            Write-Host "  - $($_.Name)" -ForegroundColor White
        }
    }
    
} else {
    Write-Host "✗ Build failed!" -ForegroundColor Red
}

# Restore original files
Write-Host "`nRestoring original Bazel files..." -ForegroundColor Yellow
if (Test-Path "WORKSPACE.bazel.backup") {
    Copy-Item "WORKSPACE.bazel.backup" "WORKSPACE.bazel" -Force
    Remove-Item "WORKSPACE.bazel.backup" -Force
}
if (Test-Path "MODULE.bazel.backup") {
    Copy-Item "MODULE.bazel.backup" "MODULE.bazel" -Force
    Remove-Item "MODULE.bazel.backup" -Force
}
if (Test-Path "worldline/BUILD.bazel.backup") {
    Copy-Item "worldline/BUILD.bazel.backup" "worldline/BUILD.bazel" -Force
    Remove-Item "worldline/BUILD.bazel.backup" -Force
}

Write-Host "`nBuild process completed!" -ForegroundColor Green 