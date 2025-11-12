#!/bin/bash
###############################################################################
# Social Auto Upload - 服务器部署环境配置脚本
# 适用系统: Ubuntu/Debian Linux
# 
# 本脚本将自动安装和配置以下环境:
# 1. Python 3.10
# 2. Node.js 18.x (通过nvm管理，配置淘宝镜像)
# 3. 项目依赖包
# 4. Playwright浏览器驱动
###############################################################################

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为root用户
check_root() {
    if [ "$EUID" -eq 0 ]; then 
        log_warn "检测到以root用户运行，建议使用普通用户执行本脚本"
        read -p "是否继续? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# 检测操作系统
detect_os() {
    log_info "检测操作系统..."
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
        log_info "操作系统: $OS $VER"
    else
        log_error "无法检测操作系统版本"
        exit 1
    fi
}

# 更新系统包
update_system() {
    log_info "更新系统包管理器..."
    sudo apt-get update
    sudo apt-get upgrade -y
}

# 安装系统依赖
install_system_dependencies() {
    log_info "安装系统依赖包..."
    sudo apt-get install -y \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        wget \
        curl \
        llvm \
        libncurses5-dev \
        libncursesw5-dev \
        xz-utils \
        tk-dev \
        libffi-dev \
        liblzma-dev \
        python3-openssl \
        git \
        ca-certificates \
        fonts-liberation \
        libasound2 \
        libatk-bridge2.0-0 \
        libatk1.0-0 \
        libc6 \
        libcairo2 \
        libcups2 \
        libdbus-1-3 \
        libexpat1 \
        libfontconfig1 \
        libgbm1 \
        libgcc1 \
        libglib2.0-0 \
        libgtk-3-0 \
        libnspr4 \
        libnss3 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libstdc++6 \
        libx11-6 \
        libx11-xcb1 \
        libxcb1 \
        libxcomposite1 \
        libxcursor1 \
        libxdamage1 \
        libxext6 \
        libxfixes3 \
        libxi6 \
        libxrandr2 \
        libxrender1 \
        libxss1 \
        libxtst6 \
        lsb-release \
        xdg-utils
    
    log_info "系统依赖安装完成"
}

# 安装Python 3.10
install_python() {
    log_info "检查Python 3.10安装状态..."
    
    if command -v python3.10 &> /dev/null; then
        PYTHON_VERSION=$(python3.10 --version | awk '{print $2}')
        log_info "Python 3.10 已安装 (版本: $PYTHON_VERSION)"
        return 0
    fi
    
    log_info "开始安装Python 3.10..."
    
    # 添加deadsnakes PPA (用于Ubuntu)
    if [[ "$OS" == *"Ubuntu"* ]]; then
        sudo apt-get install -y software-properties-common
        sudo add-apt-repository -y ppa:deadsnakes/ppa
        sudo apt-get update
    fi
    
    # 安装Python 3.10
    sudo apt-get install -y python3.10 python3.10-venv python3.10-dev python3-pip
    
    # 验证安装
    if command -v python3.10 &> /dev/null; then
        PYTHON_VERSION=$(python3.10 --version)
        log_info "Python 3.10 安装成功: $PYTHON_VERSION"
    else
        log_error "Python 3.10 安装失败"
        exit 1
    fi
    
    # 设置python3.10为默认python3 (可选)
    # sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1
}

# 安装nvm和Node.js
install_nodejs() {
    log_info "检查nvm安装状态..."
    
    # 设置nvm相关的环境变量
    export NVM_DIR="$HOME/.nvm"
    
    # 检查nvm是否已安装
    if [ -d "$NVM_DIR" ]; then
        log_info "nvm 已安装，跳过安装步骤"
    else
        log_info "开始安装nvm..."
        
        # 下载并安装nvm (使用国内镜像加速)
        export NVM_SOURCE="https://ghproxy.com/https://github.com/nvm-sh/nvm.git"
        
        # 方式1: 使用curl安装nvm
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        
        # 或者使用国内镜像
        # curl -o- https://gitee.com/mirrors/nvm/raw/master/install.sh | bash
    fi
    
    # 加载nvm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    # 配置nvm淘宝镜像源
    log_info "配置nvm淘宝镜像源..."
    export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node/
    
    # 将镜像源配置写入配置文件
    if ! grep -q "NVM_NODEJS_ORG_MIRROR" ~/.bashrc; then
        echo "" >> ~/.bashrc
        echo "# NVM 淘宝镜像源配置" >> ~/.bashrc
        echo "export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node/" >> ~/.bashrc
    fi
    
    if ! grep -q "NVM_NODEJS_ORG_MIRROR" ~/.zshrc 2>/dev/null; then
        echo "" >> ~/.zshrc
        echo "# NVM 淘宝镜像源配置" >> ~/.zshrc
        echo "export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node/" >> ~/.zshrc
    fi
    
    # 安装Node.js 18 LTS
    log_info "安装Node.js 18 LTS..."
    nvm install 18
    nvm use 18
    nvm alias default 18
    
    # 验证安装
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        NPM_VERSION=$(npm --version)
        log_info "Node.js 安装成功: $NODE_VERSION"
        log_info "npm 版本: $NPM_VERSION"
    else
        log_error "Node.js 安装失败"
        exit 1
    fi
    
    # 配置npm淘宝镜像源
    log_info "配置npm淘宝镜像源..."
    npm config set registry https://registry.npmmirror.com
    
    # 验证镜像源配置
    NPM_REGISTRY=$(npm config get registry)
    log_info "npm镜像源已设置为: $NPM_REGISTRY"
}

# 创建Python虚拟环境
create_python_venv() {
    log_info "创建Python虚拟环境..."
    
    if [ -d "venv" ]; then
        log_warn "虚拟环境已存在，跳过创建"
    else
        python3.10 -m venv venv
        log_info "Python虚拟环境创建成功"
    fi
    
    # 激活虚拟环境
    source venv/bin/activate
    
    # 升级pip
    log_info "升级pip..."
    pip install --upgrade pip
    
    # 配置pip淘宝镜像源
    log_info "配置pip淘宝镜像源..."
    pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/
    pip config set install.trusted-host mirrors.aliyun.com
}

# 安装Python依赖
install_python_dependencies() {
    log_info "安装Python项目依赖..."
    
    # 确保虚拟环境已激活
    if [ -z "$VIRTUAL_ENV" ]; then
        source venv/bin/activate
    fi
    
    if [ ! -f "requirements.txt" ]; then
        log_error "requirements.txt 文件不存在"
        exit 1
    fi
    
    # 安装依赖 (使用国内镜像源)
    pip install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/
    
    log_info "Python依赖安装完成"
}

# 安装Playwright浏览器
install_playwright_browsers() {
    log_info "安装Playwright浏览器驱动..."
    
    # 确保虚拟环境已激活
    if [ -z "$VIRTUAL_ENV" ]; then
        source venv/bin/activate
    fi
    
    # 安装chromium和firefox
    playwright install chromium firefox
    
    # 安装浏览器系统依赖
    playwright install-deps chromium firefox
    
    log_info "Playwright浏览器驱动安装完成"
}

# 安装前端依赖
install_frontend_dependencies() {
    log_info "安装前端依赖..."
    
    if [ ! -d "sau_frontend" ]; then
        log_warn "sau_frontend 目录不存在，跳过前端依赖安装"
        return 0
    fi
    
    cd sau_frontend
    
    # 确保使用Node.js 18
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm use 18
    
    # 清理可能存在的node_modules
    if [ -d "node_modules" ]; then
        log_warn "检测到现有node_modules，建议清理后重新安装"
        read -p "是否删除现有node_modules并重新安装? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf node_modules package-lock.json
        fi
    fi
    
    # 安装依赖
    npm install
    
    cd ..
    
    log_info "前端依赖安装完成"
}

# 初始化项目配置
init_project_config() {
    log_info "初始化项目配置..."
    
    # 创建必要的目录
    mkdir -p cookiesFile
    mkdir -p videoFile
    mkdir -p cookies/douyin_uploader
    mkdir -p cookies/ks_uploader
    mkdir -p cookies/tencent_uploader
    mkdir -p cookies/xiaohongshu_uploader
    
    # 复制配置文件示例
    if [ ! -f "conf.py" ] && [ -f "conf.example.py" ]; then
        cp conf.example.py conf.py
        log_info "已创建 conf.py 配置文件，请根据需要修改"
    fi
    
    # 初始化数据库
    if [ ! -f "db/database.db" ]; then
        log_info "初始化数据库..."
        source venv/bin/activate
        cd db
        python3.10 createTable.py
        cd ..
        log_info "数据库初始化完成"
    else
        log_info "数据库已存在，跳过初始化"
    fi
}

# 创建系统服务文件 (可选)
create_systemd_service() {
    log_info "是否创建systemd服务以实现开机自启?"
    read -p "创建服务? (y/n) " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 0
    fi
    
    CURRENT_DIR=$(pwd)
    CURRENT_USER=$(whoami)
    
    # 创建后端服务文件
    sudo tee /etc/systemd/system/social-auto-upload-backend.service > /dev/null <<EOF
[Unit]
Description=Social Auto Upload Backend Service
After=network.target

[Service]
Type=simple
User=$CURRENT_USER
WorkingDirectory=$CURRENT_DIR
Environment="PATH=$CURRENT_DIR/venv/bin"
ExecStart=$CURRENT_DIR/venv/bin/python3.10 $CURRENT_DIR/sau_backend.py
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    # 创建前端服务文件
    sudo tee /etc/systemd/system/social-auto-upload-frontend.service > /dev/null <<EOF
[Unit]
Description=Social Auto Upload Frontend Service
After=network.target

[Service]
Type=simple
User=$CURRENT_USER
WorkingDirectory=$CURRENT_DIR/sau_frontend
Environment="PATH=$HOME/.nvm/versions/node/v18.20.5/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ExecStart=$HOME/.nvm/versions/node/v18.20.5/bin/npm run dev
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    # 重新加载systemd配置
    sudo systemctl daemon-reload
    
    log_info "systemd服务文件创建完成"
    log_info "使用以下命令管理服务:"
    echo "  启动后端: sudo systemctl start social-auto-upload-backend"
    echo "  启动前端: sudo systemctl start social-auto-upload-frontend"
    echo "  开机自启: sudo systemctl enable social-auto-upload-backend"
    echo "  开机自启: sudo systemctl enable social-auto-upload-frontend"
    echo "  查看状态: sudo systemctl status social-auto-upload-backend"
}

# 显示部署完成信息
show_completion_info() {
    log_info "======================================"
    log_info "部署完成!"
    log_info "======================================"
    echo ""
    log_info "环境信息:"
    echo "  Python: $(python3.10 --version)"
    echo "  Node.js: $(node --version)"
    echo "  npm: $(npm --version)"
    echo ""
    log_info "启动命令:"
    echo "  1. 激活Python虚拟环境:"
    echo "     source venv/bin/activate"
    echo ""
    echo "  2. 启动后端服务 (端口5409):"
    echo "     python sau_backend.py"
    echo ""
    echo "  3. 启动前端服务 (端口5173):"
    echo "     cd sau_frontend && npm run dev"
    echo ""
    log_info "配置文件:"
    echo "  - 编辑 conf.py 配置Chrome浏览器路径等"
    echo "  - 运行 examples 目录下的脚本获取各平台Cookie"
    echo ""
    log_warn "重要提示:"
    echo "  1. 请修改 conf.py 中的 LOCAL_CHROME_PATH"
    echo "  2. 首次使用前需要获取各平台的Cookie"
    echo "  3. 将要上传的视频文件放入 videoFile 目录"
    echo "  4. 详细文档: https://sap-doc.nasdaddy.com/"
    echo ""
    log_info "======================================"
}

# 主函数
main() {
    echo ""
    log_info "======================================"
    log_info "Social Auto Upload 服务器部署脚本"
    log_info "======================================"
    echo ""
    
    check_root
    detect_os
    update_system
    install_system_dependencies
    install_python
    install_nodejs
    create_python_venv
    install_python_dependencies
    install_playwright_browsers
    install_frontend_dependencies
    init_project_config
    create_systemd_service
    show_completion_info
}

# 执行主函数
main

