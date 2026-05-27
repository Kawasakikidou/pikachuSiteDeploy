#!/bin/bash
# 手动部署脚本 - 在 Azure VM 上执行
# ssh 到 VM 后运行: bash deploy/init-vm.sh

set -e

echo "========================================"
echo "  Pikachu VM 初始化脚本"
echo "========================================"

# 更新系统
echo "[1/4] 更新系统包..."
sudo apt-get update -y && sudo apt-get upgrade -y

# 安装 Docker
echo "[2/4] 安装 Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sudo bash
    sudo usermod -aG docker $USER
fi

# 安装 Docker Compose
echo "[3/4] 安装 Docker Compose..."
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    sudo apt-get install -y docker-compose-plugin
fi

# 部署
echo "[4/4] 部署 Pikachu..."
cd /opt/pikachu

if [ ! -f .env ]; then
    cp .env.example .env
    echo "⚠ 请编辑 .env 修改默认密码: nano .env"
fi

sudo docker compose up -d --build

echo ""
echo "========================================"
echo "  部署完成!"
echo "  访问 http://<你的IP>/ 开始使用"
echo "========================================"
