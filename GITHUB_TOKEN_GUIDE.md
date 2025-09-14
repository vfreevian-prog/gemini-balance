# GitHub Personal Access Token 创建指导

## 为什么需要 Personal Access Token？

当您需要将 Docker 镜像推送到 GitHub Container Registry (GHCR) 时，需要进行身份验证。GitHub Personal Access Token (PAT) 是一种安全的认证方式，可以替代密码进行 API 访问。

## 创建步骤

### 1. 访问 GitHub Token 设置页面

打开浏览器，访问：https://github.com/settings/tokens

### 2. 创建新的 Token

1. 点击 **"Generate new token"** 按钮
2. 选择 **"Generate new token (classic)"**

### 3. 配置 Token 设置

#### 基本信息
- **Note (备注)**: 填写一个有意义的名称，例如：`Docker GHCR Push Token`
- **Expiration (过期时间)**: 建议选择 `90 days` 或根据需要选择

#### 权限设置 (Scopes)

**必需权限**：
- ✅ **`write:packages`** - 允许上传包到 GitHub Packages
- ✅ **`read:packages`** - 允许下载包（通常会自动选中）

**可选权限**（根据需要）：
- ✅ **`repo`** - 如果需要访问私有仓库
- ✅ **`workflow`** - 如果需要触发 GitHub Actions

### 4. 生成 Token

1. 滚动到页面底部
2. 点击 **"Generate token"** 按钮
3. **重要**：立即复制生成的 Token（以 `ghp_` 开头的字符串）
4. **注意**：Token 只会显示一次，请妥善保存

## 使用 Token

### 方法 1: 环境变量（推荐）

**Windows (PowerShell)**:
```powershell
$env:GITHUB_TOKEN = "ghp_your_token_here"
echo $env:GITHUB_TOKEN | docker login ghcr.io -u freevian --password-stdin
```

**Linux/macOS (Bash)**:
```bash
export GITHUB_TOKEN="ghp_your_token_here"
echo $GITHUB_TOKEN | docker login ghcr.io -u freevian --password-stdin
```

### 方法 2: 直接使用

```bash
echo "ghp_your_token_here" | docker login ghcr.io -u freevian --password-stdin
```

## 验证登录状态

登录成功后，可以通过以下命令验证：

```bash
docker system info | grep -i registry
```

或者查看 Docker 配置文件：

**Windows**: `%USERPROFILE%\.docker\config.json`
**Linux/macOS**: `~/.docker/config.json`

## 安全注意事项

1. **不要将 Token 提交到代码仓库**
2. **定期轮换 Token**（建议每 90 天更换一次）
3. **只授予必要的权限**
4. **如果 Token 泄露，立即在 GitHub 设置中撤销**

## 撤销 Token

如果需要撤销 Token：

1. 访问：https://github.com/settings/tokens
2. 找到对应的 Token
3. 点击 **"Delete"** 按钮

## 常见问题

### Q: Token 过期了怎么办？
A: 重新按照上述步骤创建新的 Token，并更新本地配置。

### Q: 登录时提示权限不足？
A: 检查 Token 是否包含 `write:packages` 权限。

### Q: 推送镜像时提示 "unauthorized"？
A: 确认：
   - Token 权限正确
   - 用户名是 `freevian`
   - 镜像名称格式正确：`ghcr.io/freevian/gemini-balance`

### Q: 如何在 GitHub Actions 中使用？
A: GitHub Actions 会自动提供 `GITHUB_TOKEN`，无需手动创建。如果需要额外权限，可以在仓库的 Secrets 中添加自定义 Token。

## 相关链接

- [GitHub Personal Access Tokens 官方文档](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [GitHub Container Registry 文档](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Docker 登录文档](https://docs.docker.com/engine/reference/commandline/login/)