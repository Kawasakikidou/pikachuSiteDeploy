#!/bin/bash
# Azure Pikachu 靶场部署脚本
# 用法: bash deploy/azure-vm-deploy.sh
# 前提: 已安装 Azure CLI 并登录 (az login)

set -e

# ========== 配置变量 ==========
RESOURCE_GROUP="pikachu-rg"
LOCATION="eastasia"
VM_NAME="pikachu-vm"
VM_SIZE="Standard_B1s"
ADMIN_USER="azureuser"
VM_IMAGE="Canonical:ubuntu-24_04-lts:server:latest"
SUBDOMAIN="${SUBDOMAIN:-pikachu}"              # 子域名前缀
DOMAIN="${DOMAIN:-kawasakikidou.top}"          # 主域名
FQDN="${SUBDOMAIN}.${DOMAIN}"                  # 完整域名

echo "========================================"
echo "  Pikachu 靶场 - Azure VM 部署"
echo "  域名: ${FQDN}"
echo "========================================"

# ========== 步骤1: 创建资源组 ==========
echo ""
echo "[1/5] 创建资源组 ${RESOURCE_GROUP}..."
az group create \
    --name ${RESOURCE_GROUP} \
    --location ${LOCATION} \
    --output table

# ========== 步骤2: 创建 VM ==========
echo ""
echo "[2/5] 创建 Azure VM (${VM_SIZE})..."
echo "      系统将提示你输入 VM 密码（或按回车自动生成 SSH 密钥）"

az vm create \
    --resource-group ${RESOURCE_GROUP} \
    --name ${VM_NAME} \
    --image ${VM_IMAGE} \
    --size ${VM_SIZE} \
    --admin-username ${ADMIN_USER} \
    --generate-ssh-keys \
    --public-ip-sku Standard \
    --output table

# 获取公网 IP
PUBLIC_IP=$(az vm show \
    --resource-group ${RESOURCE_GROUP} \
    --name ${VM_NAME} \
    --show-details \
    --query "publicIps" \
    --output tsv)

echo ""
echo "VM 创建完成! 公网 IP: ${PUBLIC_IP}"

# ========== 步骤3: 开放端口 ==========
echo ""
echo "[3/5] 开放 HTTP(80) 和 SSH(22) 端口..."
az vm open-port \
    --resource-group ${RESOURCE_GROUP} \
    --name ${VM_NAME} \
    --port 80 \
    --priority 100 \
    --output table 2>/dev/null || true

# ========== 步骤4: 初始化 VM 并部署 ==========
echo ""
echo "[4/5] 初始化 VM 并部署 Pikachu (这可能需要几分钟)..."
echo "      安装 Docker + 拉取代码 + 启动服务..."

ssh -o StrictHostKeyChecking=no ${ADMIN_USER}@${PUBLIC_IP} << 'ENDSSH'
set -e

# 更新系统
sudo apt-get update -y

# 安装 Docker
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sudo bash
    sudo usermod -aG docker $USER
fi

# 安装 Docker Compose
if ! command -v docker-compose &> /dev/null; then
    sudo apt-get install -y docker-compose-plugin
fi

# 克隆仓库（替换为你的仓库地址）
REPO_URL="${REPO_URL:-https://github.com/YOUR_USER/aimingSite.git}"
if [ ! -d /opt/pikachu ]; then
    sudo git clone ${REPO_URL} /opt/pikachu
fi

cd /opt/pikachu

# 创建 .env 文件
cat > .env << EOF
MYSQL_ROOT_PASSWORD=$(openssl rand -hex 16)
PIKACHU_PORT=80
EOF

# 启动服务
sudo docker compose up -d

# 等待服务就绪
sleep 10

echo "Docker 状态:"
sudo docker compose ps
ENDSSH

# ========== 步骤5: DNS 提示 ==========
echo ""
echo "========================================"
echo "  部署完成!"
echo "========================================"
echo ""
echo "VM 公网 IP: ${PUBLIC_IP}"
echo ""
echo "请在你的 DNS 管理面板中添加以下记录:"
echo "  类型: A"
echo "  主机记录: ${SUBDOMAIN}"
echo "  记录值: ${PUBLIC_IP}"
echo ""
echo "添加后等待 DNS 生效，然后访问:"
echo "  http://${FQDN}/"
echo ""
echo "首次访问需要初始化数据库:"
echo "  1. 打开 http://${FQDN}/"
echo "  2. 点击 '安装/初始化' 按钮"
echo "  3. 进入 http://${FQDN}/pkxss/ 初始化 XSS 后台"
echo ""
echo "SSH 登录:"
echo "  ssh ${ADMIN_USER}@${PUBLIC_IP}"
echo ""
echo "服务管理:"
echo "  ssh ${ADMIN_USER}@${PUBLIC_IP} 'cd /opt/pikachu && sudo docker compose ps'"
echo "  ssh ${ADMIN_USER}@${PUBLIC_IP} 'cd /opt/pikachu && sudo docker compose restart'"
echo "  ssh ${ADMIN_USER}@${PUBLIC_IP} 'cd /opt/pikachu && sudo docker compose down'"
echo ""
