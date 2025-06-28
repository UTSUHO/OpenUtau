# OpenUtau C++ 依赖库下载说明

本文档说明了如何下载 OpenUtau C++ 项目所需的所有依赖库。

## 依赖库列表

根据 Bazel 配置文件分析，项目需要以下依赖库：

### MODULE.bazel 依赖
- **abseil-cpp** (v20240116.1) - Google的C++库
- **googletest** (v1.14.0) - Google的C++测试框架  
- **xxhash** (v0.8.2) - 快速哈希算法库

### WORKSPACE.bazel 依赖
- **libgvps** - 音频处理库
- **libnpy** (v1.0.1) - NumPy数组文件格式支持
- **libpyin** - 音高检测库
- **spline** - 样条插值库
- **world** - 语音合成库
- **miniaudio** (v0.11.21) - 音频库

## 下载方法

### 方法1: 使用 PowerShell 脚本（推荐）

```powershell
# 进入 cpp 目录
cd cpp

# 运行下载脚本
.\download_dependencies.ps1

# 强制重新下载（如果已存在）
.\download_dependencies.ps1 -Force

# 指定输出目录
.\download_dependencies.ps1 -OutputDir "my_dependencies"
```

### 方法2: 使用批处理脚本

```cmd
# 进入 cpp 目录
cd cpp

# 运行下载脚本
download_dependencies.bat

# 强制重新下载
download_dependencies.bat --force
```

### 方法3: 手动下载

如果脚本无法运行，您可以手动下载每个依赖库：

1. **abseil-cpp**: https://github.com/abseil/abseil-cpp/archive/refs/tags/20240116.1.zip
2. **googletest**: https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
3. **xxhash**: https://github.com/Cyan4973/xxHash/archive/refs/tags/v0.8.2.zip
4. **libgvps**: https://github.com/Sleepwalking/libgvps/archive/2f1b4106d72f8f8138dc447bf0123820c0772cbd.zip
5. **libnpy**: https://github.com/llohse/libnpy/archive/refs/tags/v1.0.1.zip
6. **libpyin**: https://github.com/Sleepwalking/libpyin/archive/b38135390b335c3e8cea6ef35cf5093789b36dac.zip
7. **spline**: https://github.com/ttk592/spline/archive/5894beaf91e9adbfdbe5c6c9a1c60770e380e8e8.zip
8. **world**: https://github.com/mmorise/World/archive/f8dd5fb289db6a7f7f704497752bf32b258f9151.zip
9. **miniaudio**: https://github.com/mackron/miniaudio/archive/refs/tags/0.11.21.zip

## 输出结构

下载完成后，您将得到以下目录结构：

```
dependencies/
├── abseil-cpp/
├── googletest/
├── xxhash/
├── libgvps/
├── libnpy/
├── libpyin/
├── spline/
├── world/
└── miniaudio/
```

## 注意事项

1. 确保您的网络连接正常，因为需要从 GitHub 下载大量文件
2. 下载过程可能需要几分钟时间，取决于网络速度
3. 如果某个库下载失败，脚本会跳过并继续下载其他库
4. 所有依赖库都会下载到 `dependencies` 目录中（除非指定其他目录）

## 故障排除

### PowerShell 执行策略问题
如果遇到执行策略错误，请运行：
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 网络连接问题
如果某些库下载失败，请检查：
1. 网络连接是否正常
2. 防火墙是否阻止了下载
3. 代理设置是否正确

### 磁盘空间不足
确保有足够的磁盘空间（至少需要 500MB）

## 验证下载

下载完成后，您可以检查 `dependencies` 目录中是否包含所有9个依赖库文件夹。 