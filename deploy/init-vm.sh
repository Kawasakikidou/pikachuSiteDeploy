#!/bin/bash
set -e

echo "========================================"
echo "  Pikachu VM 初始化脚本"
echo "========================================"

# 更新系统
echo "[1/5] 更新系统包..."
sudo apt-get update -y && sudo apt-get upgrade -y

# 安装 Docker
echo "[2/5] 安装 Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sudo bash
    sudo usermod -aG docker $USER
fi

# 登录 GitHub Container Registry (拉取镜像需要)
echo "[3/5] 登录 GHCR..."
if [ -n "$GITHUB_TOKEN" ]; then
    echo "$GITHUB_TOKEN" | docker login ghcr.io -u kawasakikidou --password-stdin
elif [ -f /opt/pikachu/.ghcr_token ]; then
    cat /opt/pikachu/.ghcr_token | docker login ghcr.io -u kawasakikidou --password-stdin
else
    echo "⚠ 未提供 GITHUB_TOKEN，拉取公开镜像不需要登录，按回车继续..."
    read -r
fi

# 拉取最新代码
echo "[4/5] 克隆/更新仓库..."
if [ -d /opt/pikachu/.git ]; then
    cd /opt/pikachu && git pull
else
    sudo git clone https://github.com/Kawasakikidou/pikachuSiteDeploy.git /opt/pikachu
    sudo chown -R $USER:$USER /opt/pikachu
    cd /opt/pikachu
fi

# 创建 .env
if [ ! -f .env ]; then
    cp .env.example .env
    echo "⚠ 请编辑 .env 修改密码: nano .env"
fi

# 启动服务
echo "[5/5] 启动 Pikachu..."
docker compose pull
docker compose up -d

echo ""
echo "========================================"
echo "  部署完成!"
echo "  访问 http://<你的IP>/ 开始使用"
echo "========================================"
