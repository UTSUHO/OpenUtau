# OpenUtau C++ 依赖库下载脚本
# 此脚本将下载所有Bazel配置中定义的依赖库到本地文件夹

param(
    [string]$OutputDir = "dependencies",
    [switch]$Force = $false
)

Write-Host "开始下载 OpenUtau C++ 依赖库..." -ForegroundColor Green

# 创建输出目录
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
    Write-Host "创建目录: $OutputDir" -ForegroundColor Yellow
}

# 定义依赖库信息
$dependencies = @(
    @{
        Name = "abseil-cpp"
        Version = "20240116.1"
        Url = "https://github.com/abseil/abseil-cpp/archive/refs/tags/20240116.1.zip"
        ExtractPath = "abseil-cpp-20240116.1"
        LocalPath = "abseil-cpp"
    },
    @{
        Name = "googletest"
        Version = "1.14.0"
        Url = "https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip"
        ExtractPath = "googletest-1.14.0"
        LocalPath = "googletest"
    },
    @{
        Name = "xxhash"
        Version = "0.8.2"
        Url = "https://github.com/Cyan4973/xxHash/archive/refs/tags/v0.8.2.zip"
        ExtractPath = "xxHash-0.8.2"
        LocalPath = "xxhash"
    },
    @{
        Name = "libgvps"
        Commit = "2f1b4106d72f8f8138dc447bf0123820c0772cbd"
        Url = "https://github.com/Sleepwalking/libgvps/archive/2f1b4106d72f8f8138dc447bf0123820c0772cbd.zip"
        ExtractPath = "libgvps-2f1b4106d72f8f8138dc447bf0123820c0772cbd"
        LocalPath = "libgvps"
    },
    @{
        Name = "libnpy"
        Version = "1.0.1"
        Url = "https://github.com/llohse/libnpy/archive/refs/tags/v1.0.1.zip"
        ExtractPath = "libnpy-1.0.1"
        LocalPath = "libnpy"
    },
    @{
        Name = "libpyin"
        Commit = "b38135390b335c3e8cea6ef35cf5093789b36dac"
        Url = "https://github.com/Sleepwalking/libpyin/archive/b38135390b335c3e8cea6ef35cf5093789b36dac.zip"
        ExtractPath = "libpyin-b38135390b335c3e8cea6ef35cf5093789b36dac"
        LocalPath = "libpyin"
    },
    @{
        Name = "spline"
        Commit = "5894beaf91e9adbfdbe5c6c9a1c60770e380e8e8"
        Url = "https://github.com/ttk592/spline/archive/5894beaf91e9adbfdbe5c6c9a1c60770e380e8e8.zip"
        ExtractPath = "spline-5894beaf91e9adbfdbe5c6c9a1c60770e380e8e8"
        LocalPath = "spline"
    },
    @{
        Name = "world"
        Commit = "f8dd5fb289db6a7f7f704497752bf32b258f9151"
        Url = "https://github.com/mmorise/World/archive/f8dd5fb289db6a7f7f704497752bf32b258f9151.zip"
        ExtractPath = "World-f8dd5fb289db6a7f7f704497752bf32b258f9151"
        LocalPath = "world"
    },
    @{
        Name = "miniaudio"
        Version = "0.11.21"
        Url = "https://github.com/mackron/miniaudio/archive/refs/tags/0.11.21.zip"
        ExtractPath = "miniaudio-0.11.21"
        LocalPath = "miniaudio"
    }
)

# 下载函数
function Download-Dependency {
    param(
        [hashtable]$Dep
    )
    
    $localPath = Join-Path $OutputDir $Dep.LocalPath
    $zipPath = Join-Path $OutputDir "$($Dep.Name).zip"
    
    # 检查是否已存在
    if ((Test-Path $localPath) -and -not $Force) {
        Write-Host "跳过 $($Dep.Name) - 已存在" -ForegroundColor Yellow
        return
    }
    
    Write-Host "下载 $($Dep.Name)..." -ForegroundColor Cyan
    
    try {
        # 下载文件
        Invoke-WebRequest -Uri $Dep.Url -OutFile $zipPath -UseBasicParsing
        
        # 解压文件
        Write-Host "解压 $($Dep.Name)..." -ForegroundColor Cyan
        Expand-Archive -Path $zipPath -DestinationPath $OutputDir -Force
        
        # 重命名到目标目录
        $extractedPath = Join-Path $OutputDir $Dep.ExtractPath
        if (Test-Path $localPath) {
            Remove-Item $localPath -Recurse -Force
        }
        Rename-Item -Path $extractedPath -NewName $Dep.LocalPath
        
        # 清理zip文件
        Remove-Item $zipPath -Force
        
        Write-Host "✓ $($Dep.Name) 下载完成" -ForegroundColor Green
        
    } catch {
        Write-Host "✗ 下载 $($Dep.Name) 失败: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 下载所有依赖
foreach ($dep in $dependencies) {
    Download-Dependency -Dep $dep
}

Write-Host "`n所有依赖库下载完成！" -ForegroundColor Green
Write-Host "依赖库位置: $((Get-Location).Path)\$OutputDir" -ForegroundColor Yellow

# 显示下载的库列表
Write-Host "`n已下载的依赖库:" -ForegroundColor Cyan
Get-ChildItem $OutputDir -Directory | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor White
} 