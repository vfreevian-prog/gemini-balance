@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM 本地构建和推送Docker镜像脚本
REM 使用方法: build-local.bat [选项]
REM 选项:
REM   build-only    只构建镜像，不推送
REM   push-only     只推送镜像（需要先构建）
REM   help          显示帮助信息

REM 颜色定义
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

REM 配置
set "REGISTRY=ghcr.io"
set "IMAGE_NAME=freevian/gemini-balance"
set "TAG=latest"
set "FULL_IMAGE_NAME=%REGISTRY%/%IMAGE_NAME%:%TAG%"

REM 日志函数
:log_info
echo %BLUE%[INFO]%NC% %~1
goto :eof

:log_success
echo %GREEN%[SUCCESS]%NC% %~1
goto :eof

:log_warning
echo %YELLOW%[WARNING]%NC% %~1
goto :eof

:log_error
echo %RED%[ERROR]%NC% %~1
goto :eof

REM 检查Docker
:check_docker
call :log_info "检查Docker环境..."
docker --version >nul 2>&1
if errorlevel 1 (
    call :log_error "Docker 未安装或不在 PATH 中"
    exit /b 1
)
call :log_success "Docker 环境正常"
goto :eof

REM 检查登录状态
:check_login
call :log_info "检查GitHub Container Registry登录状态..."
docker system info | findstr "ghcr.io" >nul 2>&1
if errorlevel 1 (
    call :log_warning "未登录到GitHub Container Registry"
    call :log_info "请先运行以下命令登录:"
    echo echo YOUR_GITHUB_TOKEN ^| docker login ghcr.io -u freevian --password-stdin
    call :log_info "其中 YOUR_GITHUB_TOKEN 是您的GitHub Personal Access Token"
    call :log_info "创建Token: https://github.com/settings/tokens"
    call :log_info "需要勾选 write:packages 权限"
    exit /b 1
)
call :log_success "已登录到GitHub Container Registry"
goto :eof

REM 构建镜像
:build_image
call :log_info "开始构建Docker镜像..."
call :log_info "镜像名称: %FULL_IMAGE_NAME%"
docker build -t %FULL_IMAGE_NAME% .
if errorlevel 1 (
    call :log_error "镜像构建失败"
    exit /b 1
)
call :log_success "镜像构建完成: %FULL_IMAGE_NAME%"
goto :eof

REM 推送镜像
:push_image
call :log_info "开始推送Docker镜像..."
docker push %FULL_IMAGE_NAME%
if errorlevel 1 (
    call :log_error "镜像推送失败"
    call :log_info "请检查网络连接和登录状态"
    exit /b 1
)
call :log_success "镜像推送完成: %FULL_IMAGE_NAME%"
goto :eof

REM 显示帮助
:show_help
echo 本地Docker镜像构建和推送脚本
echo 使用方法: %~nx0 [选项]
echo.
echo 选项:
echo   build-only    只构建镜像，不推送
echo   push-only     只推送镜像（需要先构建）
echo   help          显示此帮助信息
echo.
echo 默认行为（无参数）: 检查环境 -^> 构建镜像 -^> 推送镜像
echo.
echo 注意事项:
echo 1. 需要先创建GitHub Personal Access Token
echo 2. Token需要包含 write:packages 权限
echo 3. 使用以下命令登录:
echo    echo YOUR_TOKEN ^| docker login ghcr.io -u freevian --password-stdin
echo.
echo GitHub Token创建地址: https://github.com/settings/tokens
goto :eof

REM 主逻辑
if "%~1"=="build-only" (
    call :check_docker
    call :build_image
) else if "%~1"=="push-only" (
    call :check_docker
    call :check_login
    call :push_image
) else if "%~1"=="help" (
    call :show_help
) else if "%~1"=="" (
    REM 默认行为：完整流程
    call :check_docker
    call :build_image
    call :check_login
    call :push_image
) else (
    call :log_error "未知选项: %~1"
    call :log_info "使用 help 查看帮助信息"
    exit /b 1
)

endlocal