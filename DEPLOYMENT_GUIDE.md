# Gemini Balance 自定义版本部署指南

本指南将帮助您将修改后的 Gemini Balance 项目部署到服务器上。

## 📋 前置要求

### 服务器要求
- 操作系统：Linux (推荐 Ubuntu 20.04+) 或 Windows Server
- 内存：至少 2GB RAM
- 存储：至少 10GB 可用空间
- 网络：可访问互联网

### 软件要求
- Docker (版本 20.10+)
- Docker Compose (版本 2.0+)
- Git (用于代码传输)

## 🚀 快速部署

### 1. 准备代码

#### 方法一：使用 Git（推荐）
```bash
# 如果您的代码已经推送到 Git 仓库
git clone <your-repository-url>
cd gemini-balance
```

#### 方法二：直接上传
将整个项目文件夹上传到服务器

### 2. 配置环境变量

```bash
# 复制生产环境配置模板
cp .env.production .env

# 编辑配置文件
nano .env  # 或使用其他编辑器
```

**重要配置项：**

```bash
# 数据库配置
MYSQL_USER=gemini
MYSQL_PASSWORD=your_secure_password_here  # 请设置强密码
MYSQL_DATABASE=gemini_balance

# API密钥 - 必须配置
API_KEYS=["AIzaSy_your_actual_api_key_1","AIzaSy_your_actual_api_key_2"]
ALLOWED_TOKENS=["sk-your_access_token"]
AUTH_TOKEN=sk-your_access_token

# 其他配置根据需要修改
```

### 3. 部署服务

#### Linux/macOS 用户
```bash
# 给部署脚本执行权限
chmod +x deploy.sh

# 执行完整部署
./deploy.sh

# 或者分步执行
./deploy.sh --build-only  # 只构建镜像
./deploy.sh --no-build    # 只启动服务（不重新构建）
```

#### Windows 用户
```cmd
# 执行完整部署
deploy.bat

# 或者分步执行
deploy.bat build-only  # 只构建镜像
deploy.bat no-build    # 只启动服务（不重新构建）
```

## 🔧 管理命令

### 查看服务状态
```bash
# Linux/macOS
./deploy.sh --status

# Windows
deploy.bat status
```

### 查看日志
```bash
# Linux/macOS
./deploy.sh --logs

# Windows
deploy.bat logs
```

### 重启服务
```bash
# Linux/macOS
./deploy.sh --restart

# Windows
deploy.bat restart
```

### 停止服务
```bash
# Linux/macOS
./deploy.sh --stop

# Windows
deploy.bat stop
```

### 清理未使用的镜像
```bash
# Linux/macOS
./deploy.sh --cleanup

# Windows
deploy.bat cleanup
```

## 🌐 访问服务

部署成功后，您可以通过以下地址访问服务：

- **API 服务**：`http://your-server-ip:8000`
- **健康检查**：`http://your-server-ip:8000/health`
- **管理界面**：`http://your-server-ip:8000/auth`

## 🔒 安全配置

### 1. 防火墙设置
```bash
# Ubuntu/Debian
sudo ufw allow 8000/tcp
sudo ufw enable

# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=8000/tcp
sudo firewall-cmd --reload
```

### 2. 反向代理（推荐）

使用 Nginx 作为反向代理：

```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 3. SSL 证书（推荐）
使用 Let's Encrypt 获取免费 SSL 证书：

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## 📊 监控和维护

### 1. 日志管理
项目已配置自动日志清理，您可以在 `.env` 文件中调整：

```bash
# 自动删除错误日志
AUTO_DELETE_ERROR_LOGS_ENABLED=true
AUTO_DELETE_ERROR_LOGS_DAYS=7

# 自动删除请求日志
AUTO_DELETE_REQUEST_LOGS_ENABLED=true
AUTO_DELETE_REQUEST_LOGS_DAYS=30
```

### 2. 数据备份
```bash
# 备份数据库
docker exec gemini-balance-mysql-custom mysqldump -u root -p gemini_balance > backup_$(date +%Y%m%d).sql

# 备份文件存储
tar -czf files_backup_$(date +%Y%m%d).tar.gz files/
```

### 3. 更新部署
当您修改代码后，重新部署：

```bash
# 拉取最新代码（如果使用 Git）
git pull

# 重新构建并部署
./deploy.sh  # Linux/macOS
deploy.bat   # Windows
```

## 🐛 故障排除

### 常见问题

1. **服务启动失败**
   ```bash
   # 查看详细日志
   docker-compose -f docker-compose.production.yml logs
   ```

2. **数据库连接失败**
   - 检查 `.env` 文件中的数据库配置
   - 确保 MySQL 容器正常运行

3. **API 密钥错误**
   - 检查 `.env` 文件中的 `API_KEYS` 配置
   - 确保密钥格式正确（JSON 数组）

4. **端口被占用**
   ```bash
   # 检查端口占用
   netstat -tlnp | grep 8000
   
   # 修改端口（在 docker-compose.production.yml 中）
   ports:
     - "8001:8000"  # 改为其他端口
   ```

### 性能优化

1. **调整容器资源限制**
   在 `docker-compose.production.yml` 中添加：
   ```yaml
   services:
     gemini-balance:
       deploy:
         resources:
           limits:
             memory: 1G
             cpus: '0.5'
   ```

2. **数据库优化**
   ```yaml
   mysql:
     command: --innodb-buffer-pool-size=256M --max-connections=100
   ```

## 📞 支持

如果您在部署过程中遇到问题：

1. 检查日志文件
2. 确认配置文件正确
3. 验证网络连接
4. 查看 Docker 容器状态

---

**注意**：请确保在生产环境中使用强密码，并定期更新 API 密钥和访问令牌。