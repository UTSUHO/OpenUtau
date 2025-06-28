Write-Host "开始下载 OpenUtau C++ 依赖库..." -ForegroundColor Green

$OutputDir = "dependencies"
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
    Write-Host "创建目录: $OutputDir" -ForegroundColor Yellow
}

$deps = @(
    @{Name="abseil-cpp"; Url="https://github.com/abseil/abseil-cpp/archive/refs/tags/20240116.1.zip"; Extract="abseil-cpp-20240116.1"; Local="abseil-cpp"},
    @{Name="googletest"; Url="https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip"; Extract="googletest-1.14.0"; Local="googletest"},
    @{Name="xxhash"; Url="https://github.com/Cyan4973/xxHash/archive/refs/tags/v0.8.2.zip"; Extract="xxHash-0.8.2"; Local="xxhash"},
    @{Name="libgvps"; Url="https://github.com/Sleepwalking/libgvps/archive/2f1b4106d72f8f8138dc447bf0123820c0772cbd.zip"; Extract="libgvps-2f1b4106d72f8f8138dc447bf0123820c0772cbd"; Local="libgvps"},
    @{Name="libnpy"; Url="https://github.com/llohse/libnpy/archive/refs/tags/v1.0.1.zip"; Extract="libnpy-1.0.1"; Local="libnpy"},
    @{Name="libpyin"; Url="https://github.com/Sleepwalking/libpyin/archive/b38135390b335c3e8cea6ef35cf5093789b36dac.zip"; Extract="libpyin-b38135390b335c3e8cea6ef35cf5093789b36dac"; Local="libpyin"},
    @{Name="spline"; Url="https://github.com/ttk592/spline/archive/5894beaf91e9adbfdbe5c6c9a1c60770e380e8e8.zip"; Extract="spline-5894beaf91e9adbfdbe5c6c9a1c60770e380e8e8"; Local="spline"},
    @{Name="world"; Url="https://github.com/mmorise/World/archive/f8dd5fb289db6a7f7f704497752bf32b258f9151.zip"; Extract="World-f8dd5fb289db6a7f7f704497752bf32b258f9151"; Local="world"},
    @{Name="miniaudio"; Url="https://github.com/mackron/miniaudio/archive/refs/tags/0.11.21.zip"; Extract="miniaudio-0.11.21"; Local="miniaudio"}
)

foreach ($dep in $deps) {
    $localPath = Join-Path $OutputDir $dep.Local
    $zipPath = Join-Path $OutputDir "$($dep.Name).zip"
    
    if (Test-Path $localPath) {
        Write-Host "跳过 $($dep.Name) - 已存在" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "下载 $($dep.Name)..." -ForegroundColor Cyan
    
    try {
        Invoke-WebRequest -Uri $dep.Url -OutFile $zipPath -UseBasicParsing
        Write-Host "解压 $($dep.Name)..." -ForegroundColor Cyan
        Expand-Archive -Path $zipPath -DestinationPath $OutputDir -Force
        
        $extractedPath = Join-Path $OutputDir $dep.Extract
        Rename-Item -Path $extractedPath -NewName $dep.Local
        
        Remove-Item $zipPath -Force
        Write-Host "✓ $($dep.Name) 下载完成" -ForegroundColor Green
    } catch {
        Write-Host "✗ 下载 $($dep.Name) 失败: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n所有依赖库下载完成！" -ForegroundColor Green
Write-Host "依赖库位置: $((Get-Location).Path)\$OutputDir" -ForegroundColor Yellow

Write-Host "`n已下载的依赖库:" -ForegroundColor Cyan
Get-ChildItem $OutputDir -Directory | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor White
} 