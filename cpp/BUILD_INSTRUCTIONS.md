# OpenUtau C++ Worldline 编译说明

## 项目概述

这是OpenUtau的C++音频合成组件，主要包含worldline库，用于高质量的语音合成。

## 源码结构

```
cpp/
├── worldline/           # 主要源码目录
│   ├── audio_output.*   # 音频输出处理
│   ├── worldline.*      # 核心worldline库
│   ├── phrase_synth.*   # 短语合成
│   ├── classic/         # 经典算法实现
│   ├── f0/             # 基频处理
│   ├── model/          # 模型相关
│   └── BUILD.bazel     # Bazel构建配置
├── third_party/        # 第三方库配置
├── toolchain/          # 工具链配置
└── build_*.sh/bat      # 编译脚本
```

## 依赖库

- **abseil-cpp**: Google的C++基础库
- **googletest**: 单元测试框架
- **xxhash**: 高性能哈希库
- **world**: WORLD声码器
- **miniaudio**: 跨平台音频库
- **libgvps, libpyin, spline**: 音频处理专用库

## 编译要求

1. 安装 [Bazelisk](https://github.com/bazelbuild/bazelisk)
2. 确保系统已安装相应的编译工具链：
   - Windows: Visual Studio 2019+
   - Linux: GCC 7+
   - macOS: Xcode Command Line Tools

## 编译方法

### Windows
```batch
# 编译所有Windows版本
build_all.bat

# 或单独编译
build_win.bat
```

### Linux
```bash
# 编译Linux版本
bash build_linux.sh
```

### macOS
```bash
# 编译macOS版本
bash build_mac.sh
```

## 输出文件

编译完成后，输出文件将位于根目录的 `output` 文件夹中：

```
../output/
├── win-x64/native/worldline.dll      # Windows 64位
├── win-x86/native/worldline.dll      # Windows 32位
├── win-arm64/native/worldline.dll    # Windows ARM64
├── linux-x64/native/libworldline.so  # Linux 64位
├── linux-arm64/native/libworldline.so # Linux ARM64
├── osx-x64/native/libworldline.dylib  # macOS Intel
├── osx-arm64/native/libworldline.dylib # macOS Apple Silicon
└── osx/native/libworldline.dylib      # macOS 通用二进制
```

## 手动编译命令

如需手动编译特定目标：

```bash
# 编译动态库
bazel build //worldline:worldline -c opt

# 编译可执行文件（用于测试）
bazel build //worldline:main -c opt

# 运行测试
bazel test //worldline:worldline_test
bazel test //worldline:audio_output_test

# 清理构建缓存
bazel clean
bazel clean --expunge  # 完全清理
```

## 故障排除

- **Windows上Bazel卡死**: 打开任务管理器，结束Java进程
- **权限问题**: 确保对输出目录有写权限
- **依赖下载失败**: 检查网络连接，可能需要代理设置

## 开发建议

- 推荐使用Visual Studio Code进行开发
- 安装C++扩展以获得IntelliSense支持
- 使用 `bazel query` 命令查看依赖关系 