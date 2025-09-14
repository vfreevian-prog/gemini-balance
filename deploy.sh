#!/bin/bash

# Gemini Balance 自定义版本部署脚本
# 使用方法: ./deploy.sh [选项]
# 选项:
#   --build-only    只构建镜像，不启动服务
#   --no-build      不重新构建镜像，直接启动服务
#   --stop          停止所有服务
#   --restart       重启所有服务
#   --logs          查看服务日志
#   --status        查看服务状态

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# 检查必要文件
check_files() {
    log_info "检查必要文件..."
    
    if [ ! -f "Dockerfile" ]; then
        log_error "Dockerfile 不存在！"
        exit 1
    fi
    
    if [ ! -f "docker-compose.production.yml" ]; then
        log_error "docker-compose.production.yml 不存在！"
        exit 1
    fi
    
    if [ ! -f ".env.production" ]; then
        log_warning ".env.production 不存在，请先配置环境变量！"
        log_info "您可以复制 .env.production 模板并修改其中的配置"
        exit 1
    fi
    
    log_success "文件检查完成"
}

# 构建镜像
build_image() {
    log_info "开始构建自定义镜像..."
    docker build -t gemini-balance:custom .
    log_success "镜像构建完成"
}

# 启动服务
start_services() {
    log_info "启动服务..."
    docker-compose -f docker-compose.production.yml up -d
    log_success "服务启动完成"
    
    log_info "等待服务健康检查..."
    sleep 10
    
    # 检查服务状态
    if docker-compose -f docker-compose.production.yml ps | grep -q "Up"; then
        log_success "服务运行正常"
        log_info "访问地址: http://localhost:8000"
    else
        log_error "服务启动失败，请检查日志"
        docker-compose -f docker-compose.production.yml logs
    fi
}

# 停止服务
stop_services() {
    log_info "停止服务..."
    docker-compose -f docker-compose.production.yml down
    log_success "服务已停止"
}

# 重启服务
restart_services() {
    log_info "重启服务..."
    docker-compose -f docker-compose.production.yml restart
    log_success "服务已重启"
}

# 查看日志
show_logs() {
    log_info "显示服务日志..."
    docker-compose -f docker-compose.production.yml logs -f
}

# 查看状态
show_status() {
    log_info "服务状态:"
    docker-compose -f docker-compose.production.yml ps
    
    log_info "\n容器资源使用情况:"
    docker stats --no-stream $(docker-compose -f docker-compose.production.yml ps -q) 2>/dev/null || log_warning "无法获取资源使用情况"
}

# 清理旧镜像
cleanup() {
    log_info "清理未使用的镜像..."
    docker image prune -f
    log_success "清理完成"
}

# 主函数
main() {
    case "$1" in
        --build-only)
            check_files
            build_image
            ;;
        --no-build)
            check_files
            start_services
            ;;
        --stop)
            stop_services
            ;;
        --restart)
            restart_services
            ;;
        --logs)
            show_logs
            ;;
        --status)
            show_status
            ;;
        --cleanup)
            cleanup
            ;;
        --help|-h)
            echo "Gemini Balance 部署脚本"
            echo "使用方法: $0 [选项]"
            echo ""
            echo "选项:"
            echo "  --build-only    只构建镜像，不启动服务"
            echo "  --no-build      不重新构建镜像，直接启动服务"
            echo "  --stop          停止所有服务"
            echo "  --restart       重启所有服务"
            echo "  --logs          查看服务日志"
            echo "  --status        查看服务状态"
            echo "  --cleanup       清理未使用的镜像"
            echo "  --help, -h      显示此帮助信息"
            echo ""
            echo "默认行为（无参数）: 检查文件 -> 构建镜像 -> 启动服务"
            ;;
        "")
            # 默认行为：完整部署
            check_files
            build_image
            start_services
            ;;
        *)
            log_error "未知选项: $1"
            log_info "使用 --help 查看帮助信息"
            exit 1
            ;;
    esac
}

# 检查 Docker 和 Docker Compose
if ! command -v docker &> /dev/null; then
    log_error "Docker 未安装或不在 PATH 中"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    log_error "Docker Compose 未安装或不在 PATH 中"
    exit 1
fi

# 执行主函数
main "$@"