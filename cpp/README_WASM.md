# Worldline WebAssembly 构建指南

本指南说明如何将worldline.dll转换为WebAssembly版本。

## 前置要求

### 1. 安装Emscripten SDK

```bash
# 克隆Emscripten SDK
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk

# 安装最新版本
./emsdk install latest

# 激活最新版本
./emsdk activate latest

# 设置环境变量（Windows PowerShell）
./emsdk_env.ps1
```

### 2. 验证安装

```bash
emcc --version
```

应该显示Emscripten版本信息。

## 构建步骤

### 方法1：使用简化构建脚本（推荐）

1. 进入cpp目录：
```bash
cd cpp
```

2. 运行构建脚本：
```bash
./build_wasm_simple.ps1
```

### 方法2：使用CMake构建

1. 进入cpp目录：
```bash
cd cpp
```

2. 运行CMake构建脚本：
```bash
./build_wasm.ps1
```

## 输出文件

构建成功后，以下文件将生成在 `node/dist/` 目录中：

- `worldline_wasm.js` - WebAssembly模块的JavaScript包装器
- `worldline_wasm.wasm` - WebAssembly二进制文件
- `test_wasm.html` - 测试页面

## 测试WebAssembly模块

1. 启动本地Web服务器（因为CORS限制）：
```bash
cd node/dist
python -m http.server 8000
```

2. 在浏览器中打开：
```
http://localhost:8000/test_wasm.html
```

3. 点击测试按钮验证模块功能。

## 在JavaScript中使用

```javascript
// 动态导入模块
import('./worldline_wasm.js').then(async (module) => {
    const WorldlineModule = module.default;
    const instance = await WorldlineModule();
    
    // 使用ccall调用C++函数
    const result = instance.ccall(
        'F0',           // 函数名
        'number',       // 返回类型
        ['array', 'number', 'number', 'number', 'number'], // 参数类型
        [samples, samples.length, sampleRate, framePeriod, method] // 参数值
    );
});
```

## 导出的函数

以下C++函数已导出到WebAssembly：

- `F0` - 计算基频
- `DecodeMgc` - 解码MGC参数
- `DecodeBap` - 解码BAP参数
- `WorldSynthesis` - WORLD合成
- `Resample` - 重采样
- `PhraseSynthNew` - 创建短语合成器
- `PhraseSynthDelete` - 删除短语合成器
- `PhraseSynthAddRequest` - 添加合成请求
- `PhraseSynthSetCurves` - 设置曲线参数
- `PhraseSynthSynth` - 执行短语合成

## 故障排除

### 常见错误

1. **"未找到Emscripten"**
   - 确保已正确安装Emscripten SDK
   - 确保环境变量已设置

2. **编译错误**
   - 检查源文件路径是否正确
   - 确保所有依赖的头文件都存在

3. **运行时错误**
   - 确保在Web服务器环境下运行（不是直接打开HTML文件）
   - 检查浏览器控制台的错误信息

### 调试技巧

1. 在构建脚本中添加 `-g` 标志以生成调试信息
2. 使用浏览器开发者工具检查WebAssembly模块加载状态
3. 查看浏览器控制台的详细错误信息

## 性能优化

- 使用 `-O2` 或 `-O3` 优化级别
- 调整内存设置（`INITIAL_MEMORY`, `MAXIMUM_MEMORY`）
- 考虑使用 `-s SINGLE_FILE=1` 将WASM嵌入到JS文件中

## 许可证

本WebAssembly构建遵循原始worldline项目的许可证。 