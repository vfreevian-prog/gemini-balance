#!/bin/bash

# 本地构建和推送Docker镜像脚本
# 使用方法: ./build-local.sh [选项]
# 选项:
#   build-only    只构建镜像，不推送
#   push-only     只推送镜像（需要先构建）
#   help          显示帮助信息

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
REGISTRY="ghcr.io"
IMAGE_NAME="freevian/gemini-balance"
TAG="latest"
FULL_IMAGE_NAME="$REGISTRY/$IMAGE_NAME:$TAG"

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查Docker
check_docker() {
    log_info "检查Docker环境..."
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装或不在 PATH 中"
        exit 1
    fi
    log_success "Docker 环境正常"
}

# 检查登录状态
check_login() {
    log_info "检查GitHub Container Registry登录状态..."
    if ! docker system info 2>/dev/null | grep -q "ghcr.io"; then
        log_warning "未登录到GitHub Container Registry"
        log_info "请先运行以下命令登录:"
        echo "echo YOUR_GITHUB_TOKEN | docker login ghcr.io -u freevian --password-stdin"
        log_info "其中 YOUR_GITHUB_TOKEN 是您的GitHub Personal Access Token"
        log_info "创建Token: https://github.com/settings/tokens"
        log_info "需要勾选 write:packages 权限"
        exit 1
    fi
    log_success "已登录到GitHub Container Registry"
}

# 构建镜像
build_image() {
    log_info "开始构建Docker镜像..."
    log_info "镜像名称: $FULL_IMAGE_NAME"
    if ! docker build -t "$FULL_IMAGE_NAME" .; then
        log_error "镜像构建失败"
        exit 1
    fi
    log_success "镜像构建完成: $FULL_IMAGE_NAME"
}

# 推送镜像
push_image() {
    log_info "开始推送Docker镜像..."
    if ! docker push "$FULL_IMAGE_NAME"; then
        log_error "镜像推送失败"
        log_info "请检查网络连接和登录状态"
        exit 1
    fi
    log_success "镜像推送完成: $FULL_IMAGE_NAME"
}

# 显示帮助
show_help() {
    echo "本地Docker镜像构建和推送脚本"
    echo "使用方法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  build-only    只构建镜像，不推送"
    echo "  push-only     只推送镜像（需要先构建）"
    echo "  help          显示此帮助信息"
    echo ""
    echo "默认行为（无参数）: 检查环境 -> 构建镜像 -> 推送镜像"
    echo ""
    echo "注意事项:"
    echo "1. 需要先创建GitHub Personal Access Token"
    echo "2. Token需要包含 write:packages 权限"
    echo "3. 使用以下命令登录:"
    echo "   echo YOUR_TOKEN | docker login ghcr.io -u freevian --password-stdin"
    echo ""
    echo "GitHub Token创建地址: https://github.com/settings/tokens"
}

# 主逻辑
case "$1" in
    "build-only")
        check_docker
        build_image
        ;;
    "push-only")
        check_docker
        check_login
        push_image
        ;;
    "help")
        show_help
        ;;
    "")
        # 默认行为：完整流程
        check_docker
        build_image
        check_login
        push_image
        ;;
    *)
        log_error "未知选项: $1"
        log_info "使用 help 查看帮助信息"
        exit 1
        ;;
esac