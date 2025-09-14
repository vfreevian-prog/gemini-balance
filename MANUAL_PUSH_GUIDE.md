# 手动推送 Docker 镜像到 GitHub Container Registry 指导

## 概述

本指导将帮助您手动构建和推送 Docker 镜像到 GitHub Container Registry (GHCR)，作为 GitHub Actions 自动化的替代方案。

## 前置条件

1. ✅ 已安装 Docker
2. ✅ 已创建 GitHub Personal Access Token（参考 `GITHUB_TOKEN_GUIDE.md`）
3. ✅ Token 包含 `write:packages` 权限

## 快速开始

### 使用自动化脚本（推荐）

我们已经为您准备了自动化脚本：

**Windows 用户**:
```cmd
.\build-local.bat
```

**Linux/macOS 用户**:
```bash
chmod +x build-local.sh
./build-local.sh
```

### 脚本选项

- `build-local.bat` 或 `./build-local.sh` - 完整流程（构建+推送）
- `build-local.bat build-only` - 仅构建镜像
- `build-local.bat push-only` - 仅推送镜像
- `build-local.bat help` - 显示帮助信息

## 手动步骤详解

如果您希望手动执行每个步骤，请按以下顺序操作：

### 1. 登录到 GitHub Container Registry

首先，使用您的 GitHub Personal Access Token 登录：

```bash
echo "YOUR_GITHUB_TOKEN" | docker login ghcr.io -u freevian --password-stdin
```

**替换 `YOUR_GITHUB_TOKEN` 为您的实际 Token**

成功登录后会显示：
```
Login Succeeded
```

### 2. 构建 Docker 镜像

在项目根目录执行：

```bash
docker build -t ghcr.io/freevian/gemini-balance:latest .
```

构建过程中会显示各个步骤的进度。成功完成后会显示：
```
Successfully built [image_id]
Successfully tagged ghcr.io/freevian/gemini-balance:latest
```

### 3. 推送镜像到 GHCR

```bash
docker push ghcr.io/freevian/gemini-balance:latest
```

推送完成后会显示镜像的摘要信息。

### 4. 验证推送结果

访问您的 GitHub 仓库页面，在右侧边栏的 "Packages" 部分应该能看到新推送的镜像。

或者访问：https://github.com/freevian/gemini-balance/pkgs/container/gemini-balance

## 高级用法

### 推送多个标签

```bash
# 构建并标记多个版本
docker build -t ghcr.io/freevian/gemini-balance:latest .
docker tag ghcr.io/freevian/gemini-balance:latest ghcr.io/freevian/gemini-balance:v1.0.0

# 推送所有标签
docker push ghcr.io/freevian/gemini-balance:latest
docker push ghcr.io/freevian/gemini-balance:v1.0.0
```

### 多平台构建

如果需要支持多个架构（如 ARM64）：

```bash
# 创建并使用 buildx builder
docker buildx create --use

# 多平台构建并推送
docker buildx build --platform linux/amd64,linux/arm64 \
  -t ghcr.io/freevian/gemini-balance:latest \
  --push .
```

## 故障排除

### 常见错误及解决方案

#### 1. "unauthorized: unauthenticated"

**原因**: 未登录或 Token 无效

**解决方案**:
- 检查是否已正确登录 GHCR
- 验证 Token 是否有效且包含正确权限
- 重新登录

#### 2. "denied: permission_denied"

**原因**: Token 权限不足

**解决方案**:
- 确认 Token 包含 `write:packages` 权限
- 重新创建 Token 并确保选择正确的权限

#### 3. "no such file or directory: Dockerfile"

**原因**: 不在正确的目录中

**解决方案**:
- 确保在项目根目录（包含 Dockerfile 的目录）中执行命令
- 使用 `ls` 或 `dir` 命令确认当前目录内容

#### 4. 构建过程中出现依赖错误

**原因**: 网络问题或依赖源不可用

**解决方案**:
- 检查网络连接
- 重试构建命令
- 如果是 npm 依赖问题，可以尝试清理缓存：`docker build --no-cache`

### 检查命令

```bash
# 检查 Docker 版本
docker --version

# 检查登录状态
docker system info | grep -i registry

# 查看本地镜像
docker images | grep gemini-balance

# 查看构建历史
docker history ghcr.io/freevian/gemini-balance:latest
```

## 自动化建议

### 1. 创建别名

**Linux/macOS (.bashrc 或 .zshrc)**:
```bash
alias build-gemini='cd /path/to/gemini-balance && ./build-local.sh'
```

**Windows (PowerShell Profile)**:
```powershell
function Build-Gemini {
    Set-Location "C:\Path\To\gemini-balance"
    .\build-local.bat
}
```

### 2. 环境变量设置

将 GitHub Token 设置为环境变量，避免每次输入：

**Windows**:
```cmd
setx GITHUB_TOKEN "your_token_here"
```

**Linux/macOS**:
```bash
echo 'export GITHUB_TOKEN="your_token_here"' >> ~/.bashrc
source ~/.bashrc
```

然后可以使用：
```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u freevian --password-stdin
```

## 最佳实践

1. **定期更新**: 定期推送新版本，保持镜像最新
2. **版本标签**: 使用语义化版本标签（如 v1.0.0）
3. **清理本地**: 定期清理本地不需要的镜像：`docker image prune`
4. **安全性**: 不要在脚本中硬编码 Token
5. **备份**: 保存重要的 Dockerfile 和构建脚本

## 相关文件

- `build-local.bat` - Windows 自动化脚本
- `build-local.sh` - Linux/macOS 自动化脚本
- `GITHUB_TOKEN_GUIDE.md` - Token 创建指导
- `Dockerfile` - Docker 镜像构建文件
- `docker-compose.yml` - 本地开发环境配置

## 支持

如果遇到问题，请检查：
1. Docker 是否正常运行
2. 网络连接是否正常
3. GitHub Token 是否有效
4. 项目文件是否完整

更多帮助请参考 [Docker 官方文档](https://docs.docker.com/) 和 [GitHub Container Registry 文档](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)。