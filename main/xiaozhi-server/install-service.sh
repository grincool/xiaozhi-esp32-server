#!/bin/bash

# 颜色定义
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# 打印带颜色的信息
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]; then
    error "请使用sudo运行此脚本"
    exit 1
fi

# 设置服务名称
SERVICE_NAME="xiaozhi-server"

# 检查服务文件是否存在
if [ ! -f "$SERVICE_NAME.service" ]; then
    error "服务文件 $SERVICE_NAME.service 不存在"
    exit 1
fi

# 复制服务文件到systemd目录
info "复制服务文件到systemd目录..."
cp "$SERVICE_NAME.service" /etc/systemd/system/

# 重新加载systemd配置
info "重新加载systemd配置..."
systemctl daemon-reload

# 注意：不启用服务自启动
# systemctl enable $SERVICE_NAME

success "服务安装完成，但未设置开机自启动"
info "您可以使用以下命令手动启动服务:"
echo "sudo systemctl start $SERVICE_NAME"

info "您也可以使用以下命令查看服务状态:"
echo "sudo systemctl status $SERVICE_NAME"

info "您可以使用以下命令查看服务日志:"
info "如果您是以root用户身份运行:"
echo "tail -f /home/deployer/projects/running-apps/xiaozhi-server/logs/output.log"
echo "tail -f /home/deployer/projects/running-apps/xiaozhi-server/logs/error.log"
info "如果您是以deployer用户身份运行(su - deployer):"
echo "tail -f ~/projects/running-apps/xiaozhi-server/logs/output.log"
echo "tail -f ~/projects/running-apps/xiaozhi-server/logs/error.log"

info "您可以使用以下命令停止服务:"
echo "sudo systemctl stop $SERVICE_NAME"