@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM Gemini Balance 自定义版本部署脚本 (Windows版本)
REM 使用方法: deploy.bat [选项]
REM 选项:
REM   build-only    只构建镜像，不启动服务
REM   no-build      不重新构建镜像，直接启动服务
REM   stop          停止所有服务
REM   restart       重启所有服务
REM   logs          查看服务日志
REM   status        查看服务状态
REM   cleanup       清理未使用的镜像

REM 颜色定义
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

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

REM 检查必要文件
:check_files
call :log_info "检查必要文件..."

if not exist "Dockerfile" (
    call :log_error "Dockerfile 不存在！"
    exit /b 1
)

if not exist "docker-compose.production.yml" (
    call :log_error "docker-compose.production.yml 不存在！"
    exit /b 1
)

if not exist ".env.production" (
    call :log_warning ".env.production 不存在，请先配置环境变量！"
    call :log_info "您可以复制 .env.production 模板并修改其中的配置"
    exit /b 1
)

call :log_success "文件检查完成"
goto :eof

REM 构建镜像
:build_image
call :log_info "开始构建自定义镜像..."
docker build -t gemini-balance:custom .
if errorlevel 1 (
    call :log_error "镜像构建失败"
    exit /b 1
)
call :log_success "镜像构建完成"
goto :eof

REM 启动服务
:start_services
call :log_info "启动服务..."
docker-compose -f docker-compose.production.yml up -d
if errorlevel 1 (
    call :log_error "服务启动失败"
    exit /b 1
)
call :log_success "服务启动完成"

call :log_info "等待服务健康检查..."
timeout /t 10 /nobreak >nul

REM 检查服务状态
docker-compose -f docker-compose.production.yml ps | findstr "Up" >nul
if errorlevel 1 (
    call :log_error "服务启动失败，请检查日志"
    docker-compose -f docker-compose.production.yml logs
) else (
    call :log_success "服务运行正常"
    call :log_info "访问地址: http://localhost:8000"
)
goto :eof

REM 停止服务
:stop_services
call :log_info "停止服务..."
docker-compose -f docker-compose.production.yml down
call :log_success "服务已停止"
goto :eof

REM 重启服务
:restart_services
call :log_info "重启服务..."
docker-compose -f docker-compose.production.yml restart
call :log_success "服务已重启"
goto :eof

REM 查看日志
:show_logs
call :log_info "显示服务日志..."
docker-compose -f docker-compose.production.yml logs -f
goto :eof

REM 查看状态
:show_status
call :log_info "服务状态:"
docker-compose -f docker-compose.production.yml ps
echo.
call :log_info "容器资源使用情况:"
for /f "tokens=*" %%i in ('docker-compose -f docker-compose.production.yml ps -q 2^>nul') do (
    docker stats --no-stream %%i 2>nul
)
goto :eof

REM 清理旧镜像
:cleanup
call :log_info "清理未使用的镜像..."
docker image prune -f
call :log_success "清理完成"
goto :eof

REM 显示帮助
:show_help
echo Gemini Balance 部署脚本 (Windows版本)
echo 使用方法: %~nx0 [选项]
echo.
echo 选项:
echo   build-only    只构建镜像，不启动服务
echo   no-build      不重新构建镜像，直接启动服务
echo   stop          停止所有服务
echo   restart       重启所有服务
echo   logs          查看服务日志
echo   status        查看服务状态
echo   cleanup       清理未使用的镜像
echo   help          显示此帮助信息
echo.
echo 默认行为（无参数）: 检查文件 -^> 构建镜像 -^> 启动服务
goto :eof

REM 检查 Docker 和 Docker Compose
docker --version >nul 2>&1
if errorlevel 1 (
    call :log_error "Docker 未安装或不在 PATH 中"
    exit /b 1
)

docker-compose --version >nul 2>&1
if errorlevel 1 (
    call :log_error "Docker Compose 未安装或不在 PATH 中"
    exit /b 1
)

REM 主逻辑
if "%~1"=="build-only" (
    call :check_files
    call :build_image
) else if "%~1"=="no-build" (
    call :check_files
    call :start_services
) else if "%~1"=="stop" (
    call :stop_services
) else if "%~1"=="restart" (
    call :restart_services
) else if "%~1"=="logs" (
    call :show_logs
) else if "%~1"=="status" (
    call :show_status
) else if "%~1"=="cleanup" (
    call :cleanup
) else if "%~1"=="help" (
    call :show_help
) else if "%~1"=="" (
    REM 默认行为：完整部署
    call :check_files
    call :build_image
    call :start_services
) else (
    call :log_error "未知选项: %~1"
    call :log_info "使用 help 查看帮助信息"
    exit /b 1
)

endlocal