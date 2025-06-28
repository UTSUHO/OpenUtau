@echo off
chcp 65001 >nul

echo OpenUtau Worldline WebAssembly 编译指南
echo ========================================
echo.

echo 由于 Emscripten 与 Bazel 的集成比较复杂，我们提供以下几种方案：
echo.

echo 方案1: 使用 Docker 容器编译 WASM (推荐)
echo ----------------------------------------
echo 1. 安装 Docker Desktop
echo 2. 运行编译脚本: build_wasm_docker.bat
echo.

echo 方案2: 手动安装 Emscripten
echo ---------------------------
echo 1. 下载 Emscripten SDK: https://github.com/emscripten-core/emsdk
echo 2. 安装并激活最新版本
echo 3. 运行手动编译命令
echo.

echo 方案3: 使用预编译的 WASM 文件
echo ------------------------------
echo 如果您只需要使用 WASM 版本，可以：
echo 1. 从 OpenUtau 官方发布页面下载预编译的 WASM 文件
echo 2. 或者联系项目维护者获取编译好的版本
echo.

echo 注意事项：
echo =========
echo - WASM 编译需要处理第三方依赖库的兼容性
echo - 某些 C++ 特性在 WASM 中可能不完全支持
echo - 建议先确保原生版本编译成功后再尝试 WASM
echo.

echo 详细说明请查看: WASM_COMPILATION_GUIDE.md
echo 示例代码请查看: wasm_example.html
echo.

echo 如需技术支持，请访问：
echo - OpenUtau GitHub: https://github.com/stakira/OpenUtau
echo - Emscripten 文档: https://emscripten.org/docs/
echo.

pause 