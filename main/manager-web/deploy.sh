
#!/bin/bash

# xiaozhi-esp32-server Web前端更新脚本
# 用于更新已部署的Vue前端应用

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置变量
WEB_DIR="$(pwd)"
DIST_DIR="${WEB_DIR}/dist"
WEB_ROOT="/var/www/xiaozhi-web"
NGINX_SITE_NAME="xiaozhi-manager-web"

# 打印信息函数
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# 检查是否为root用户或有sudo权限
check_permissions() {
    info "检查权限..."
    if [[ $EUID -ne 0 ]] && ! sudo -n true 2>/dev/null; then
        error "需要root权限或sudo权限来执行此脚本"
    fi
}

# 停止Nginx站点
stop_nginx_site() {
    info "停止Nginx站点..."
    
    # 检查站点是否存在
    if [ -L "/etc/nginx/sites-enabled/${NGINX_SITE_NAME}" ]; then
        # 临时禁用站点
        sudo rm -f "/etc/nginx/sites-enabled/${NGINX_SITE_NAME}"
        info "已临时禁用站点: ${NGINX_SITE_NAME}"
        
        # 重载Nginx配置
        sudo nginx -t && sudo nginx -s reload
        info "Nginx配置已重载"
    else
        warning "站点 ${NGINX_SITE_NAME} 未启用，跳过停止步骤"
    fi
}

# 安装依赖并构建项目
build_project() {
    info "安装项目依赖..."
    npm install
    
    info "构建项目..."
    npm run build
    
    if [ ! -d "dist" ]; then
        error "构建失败，dist目录不存在"
    fi
    
    info "项目构建成功"
}

# 更新前端文件
update_files() {
    info "更新前端文件..."
    
    # 检查目标目录是否存在
    if [ ! -d "${WEB_ROOT}" ]; then
        sudo mkdir -p "${WEB_ROOT}"
        info "创建目标目录: ${WEB_ROOT}"
    fi
    
    # 备份当前文件（如果存在）
    if [ -d "${WEB_ROOT}" ] && [ "$(ls -A ${WEB_ROOT})" ]; then
        BACKUP_DIR="${WEB_ROOT}_backup_$(date +%Y%m%d_%H%M%S)"
        sudo cp -r "${WEB_ROOT}" "${BACKUP_DIR}"
        info "已备份当前文件到: ${BACKUP_DIR}"
    fi
    
    # 清理目标目录
    sudo rm -rf "${WEB_ROOT}"/*
    
    # 复制新文件
    sudo cp -r "${DIST_DIR}"/* "${WEB_ROOT}/"
    
    # 设置权限
    sudo chown -R www-data:www-data "${WEB_ROOT}"
    sudo chmod -R 755 "${WEB_ROOT}"
    
    info "前端文件更新完成"
}

# 重启Nginx站点
restart_nginx_site() {
    info "重启Nginx站点..."
    
    # 重新启用站点
    if [ -f "/etc/nginx/sites-available/${NGINX_SITE_NAME}" ]; then
        sudo ln -sf "/etc/nginx/sites-available/${NGINX_SITE_NAME}" "/etc/nginx/sites-enabled/${NGINX_SITE_NAME}"
        info "已重新启用站点: ${NGINX_SITE_NAME}"
        
        # 重载Nginx配置
        if sudo nginx -t; then
            sudo nginx -s reload
            info "Nginx配置已重载"
        else
            error "Nginx配置测试失败，请检查配置文件"
        fi
    else
        warning "站点配置文件 ${NGINX_SITE_NAME} 不存在，无法重启站点"
        warning "请确认站点配置文件路径: /etc/nginx/sites-available/${NGINX_SITE_NAME}"
    fi
}

# 显示更新信息
show_info() {
    echo ""
    echo -e "${GREEN}=== 更新完成 ===${NC}"
    echo ""
    echo "前端应用已成功更新到: ${WEB_ROOT}"
    echo "Nginx站点: ${NGINX_SITE_NAME}"
    echo ""
    echo "如需手动重启Nginx，请执行: sudo systemctl restart nginx"
}

# 主函数
main() {
    info "开始更新 xiaozhi-web 前端应用..."
    
    check_permissions
    stop_nginx_site
    build_project
    update_files
    restart_nginx_site
    show_info
    
    info "更新脚本执行完成！"
}

# 执行主函数
main