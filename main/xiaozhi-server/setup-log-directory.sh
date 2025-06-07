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

# 创建日志目录
mkdir -p /home/deployer/projects/running-apps/xiaozhi-server/logs

# 获取当前用户
CURRENT_USER=$(whoami)

# 设置目录所有者为deployer用户（与服务运行用户一致）
if [ "$CURRENT_USER" != "deployer" ]; then
    info "当前用户不是deployer，设置目录所有者为deployer..."
    chown -R deployer:deployer /home/deployer/projects/running-apps/xiaozhi-server/logs
else
    info "当前用户已经是deployer，无需更改所有者"
fi

# 设置适当的权限
chmod -R 755 /home/deployer/projects/running-apps/xiaozhi-server/logs

success "日志目录已创建并设置权限: /home/deployer/projects/running-apps/xiaozhi-server/logs"
info "服务日志将输出到:"
echo "  - 标准输出: /home/deployer/projects/running-apps/xiaozhi-server/logs/output.log"
echo "  - 标准错误: /home/deployer/projects/running-apps/xiaozhi-server/logs/error.log"