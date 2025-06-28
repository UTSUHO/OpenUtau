# Bazel/Bazelisk 安装指南

## 自动安装（推荐）

直接运行以下脚本，它会自动下载并安装 Bazelisk：

```batch
setup_and_build.bat
```

## 手动安装

### 方法1：使用 Chocolatey（推荐）

如果您已安装 Chocolatey：

```batch
choco install bazelisk
```

### 方法2：使用 Scoop

如果您已安装 Scoop：

```batch
scoop install bazelisk
```

### 方法3：手动下载

1. 访问 [Bazelisk Releases](https://github.com/bazelbuild/bazelisk/releases)
2. 下载 `bazelisk-windows-amd64.exe`
3. 重命名为 `bazel.exe`
4. 将文件放到 PATH 环境变量包含的目录中（如 `C:\Windows\System32`）

### 方法4：使用 npm

如果您已安装 Node.js：

```batch
npm install -g @bazel/bazelisk
```

## 验证安装

安装完成后，打开新的命令行窗口，运行：

```batch
bazel version
```

如果显示版本信息，说明安装成功。

## 编译项目

安装完成后，您可以使用以下任一方式编译：

```batch
# 使用自动化脚本
setup_and_build.bat

# 或使用原始脚本
build_all.bat
build_win.bat
```

## 常见问题

### Q: 提示 "bazel 不是内部或外部命令"
A: 说明 Bazel 未正确安装或未添加到 PATH。请重新安装并重启命令行。

### Q: 下载速度慢或失败
A: 可能需要配置代理或使用国内镜像。可以手动下载后放到指定位置。

### Q: 编译时提示权限错误
A: 以管理员身份运行命令行，或确保对项目目录有写权限。

### Q: 编译卡住不动
A: 在任务管理器中结束 Java 进程，然后重新编译。 