#!/bin/bash
###############################################################################
# 环境检查脚本 - Social Auto Upload
# 用于验证服务器环境是否满足部署要求
###############################################################################

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查计数
PASS=0
WARN=0
FAIL=0

# 打印函数
print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_pass() {
    echo -e "${GREEN}✅ $1${NC}"
    ((PASS++))
}

print_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARN++))
}

print_fail() {
    echo -e "${RED}❌ $1${NC}"
    ((FAIL++))
}

print_info() {
    echo -e "   $1"
}

# 开始检查
echo ""
print_header "环境检查开始"
echo ""

# 1. 检查操作系统
print_header "操作系统"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME=$NAME
    OS_VERSION=$VERSION_ID
    
    if [[ "$OS_NAME" == *"Ubuntu"* ]] || [[ "$OS_NAME" == *"Debian"* ]]; then
        print_pass "操作系统: $OS_NAME $OS_VERSION"
    else
        print_warn "操作系统: $OS_NAME $OS_VERSION (未经充分测试)"
    fi
else
    print_fail "无法检测操作系统"
fi

# 2. 检查 Python 3.10
print_header "Python 环境"
if command -v python3.10 &> /dev/null; then
    PYTHON_VERSION=$(python3.10 --version)
    print_pass "Python 3.10: $PYTHON_VERSION"
    
    # 检查虚拟环境
    if [ -d "venv" ]; then
        print_pass "虚拟环境: venv 目录存在"
        
        # 检查虚拟环境中的包
        if [ -f "venv/bin/pip" ]; then
            source venv/bin/activate
            INSTALLED_PACKAGES=$(pip list 2>/dev/null | wc -l)
            if [ $INSTALLED_PACKAGES -gt 10 ]; then
                print_pass "已安装 Python 包数量: $INSTALLED_PACKAGES"
            else
                print_warn "Python 包数量较少，可能需要安装依赖"
            fi
            deactivate 2>/dev/null
        fi
    else
        print_warn "虚拟环境未创建"
        print_info "运行: python3.10 -m venv venv"
    fi
else
    print_fail "Python 3.10 未安装"
    print_info "运行部署脚本或手动安装 Python 3.10"
fi

# 3. 检查 Node.js
print_header "Node.js 环境"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    NODE_MAJOR=$(echo $NODE_VERSION | cut -d'v' -f2 | cut -d'.' -f1)
    
    if [ "$NODE_MAJOR" -ge 18 ]; then
        print_pass "Node.js: $NODE_VERSION"
    else
        print_fail "Node.js 版本过低: $NODE_VERSION (需要 18+)"
        print_info "运行: nvm install 18 && nvm use 18"
    fi
else
    print_fail "Node.js 未安装"
    print_info "运行部署脚本或手动安装 Node.js"
fi

# 4. 检查 npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    print_pass "npm: v$NPM_VERSION"
else
    print_fail "npm 未安装"
fi

# 5. 检查 nvm
print_header "包管理器"
if [ -d "$HOME/.nvm" ]; then
    print_pass "nvm: 已安装"
else
    print_warn "nvm 未安装（推荐使用 nvm 管理 Node.js 版本）"
    print_info "安装命令: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
fi

# 6. 检查 pip
if command -v pip &> /dev/null; then
    PIP_VERSION=$(pip --version | awk '{print $2}')
    print_pass "pip: v$PIP_VERSION"
else
    print_warn "pip 未找到"
fi

# 7. 检查 Playwright
print_header "浏览器自动化"
if [ -f "venv/bin/playwright" ]; then
    source venv/bin/activate 2>/dev/null
    PLAYWRIGHT_VERSION=$(playwright --version 2>/dev/null | awk '{print $2}')
    if [ -n "$PLAYWRIGHT_VERSION" ]; then
        print_pass "Playwright: v$PLAYWRIGHT_VERSION"
    else
        print_pass "Playwright: 已安装"
    fi
    deactivate 2>/dev/null
    
    # 检查浏览器
    if [ -d "$HOME/.cache/ms-playwright" ]; then
        BROWSER_COUNT=$(ls -1 "$HOME/.cache/ms-playwright" 2>/dev/null | wc -l)
        if [ $BROWSER_COUNT -gt 0 ]; then
            print_pass "Playwright 浏览器: 已安装 ($BROWSER_COUNT 个)"
        else
            print_warn "Playwright 浏览器未安装"
            print_info "运行: playwright install chromium firefox"
        fi
    else
        print_warn "Playwright 浏览器目录不存在"
    fi
else
    print_fail "Playwright 未安装"
    print_info "运行: source venv/bin/activate && pip install playwright"
fi

# 8. 检查 Chrome/Chromium
if command -v google-chrome &> /dev/null; then
    CHROME_VERSION=$(google-chrome --version)
    print_pass "Chrome: $CHROME_VERSION"
elif command -v chromium-browser &> /dev/null; then
    CHROMIUM_VERSION=$(chromium-browser --version)
    print_pass "Chromium: $CHROMIUM_VERSION"
elif command -v chromium &> /dev/null; then
    CHROMIUM_VERSION=$(chromium --version)
    print_pass "Chromium: $CHROMIUM_VERSION"
else
    print_warn "Chrome/Chromium 未安装（某些功能可能需要）"
    print_info "安装: wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    print_info "      sudo apt install ./google-chrome-stable_current_amd64.deb"
fi

# 9. 检查项目文件结构
print_header "项目结构"
REQUIRED_FILES=(
    "sau_backend.py"
    "requirements.txt"
    "conf.example.py"
    "sau_frontend/package.json"
    "db/createTable.py"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        print_pass "文件存在: $file"
    else
        print_fail "文件缺失: $file"
    fi
done

# 检查必需目录
REQUIRED_DIRS=(
    "cookies"
    "uploader"
    "examples"
    "sau_frontend"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        print_pass "目录存在: $dir/"
    else
        print_fail "目录缺失: $dir/"
    fi
done

# 10. 检查配置文件
print_header "配置文件"
if [ -f "conf.py" ]; then
    print_pass "配置文件: conf.py 已创建"
else
    print_warn "配置文件: conf.py 未创建"
    print_info "运行: cp conf.example.py conf.py"
fi

# 11. 检查数据库
if [ -f "db/database.db" ]; then
    DB_SIZE=$(du -h db/database.db | awk '{print $1}')
    print_pass "数据库: db/database.db ($DB_SIZE)"
else
    print_warn "数据库未初始化"
    print_info "运行: cd db && python3.10 createTable.py && cd .."
fi

# 12. 检查运行时目录
print_header "运行时目录"
RUNTIME_DIRS=(
    "cookiesFile"
    "videoFile"
)

for dir in "${RUNTIME_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        print_pass "目录存在: $dir/"
    else
        print_warn "目录不存在: $dir/"
        print_info "运行: mkdir -p $dir"
    fi
done

# 13. 检查镜像源配置
print_header "镜像源配置"

# pip 镜像
if [ -f "$HOME/.config/pip/pip.conf" ] || [ -f "$HOME/.pip/pip.conf" ]; then
    PIP_MIRROR=$(pip config get global.index-url 2>/dev/null)
    if [[ "$PIP_MIRROR" == *"aliyun"* ]] || [[ "$PIP_MIRROR" == *"tsinghua"* ]] || [[ "$PIP_MIRROR" == *"douban"* ]]; then
        print_pass "pip 镜像源: $PIP_MIRROR"
    else
        print_warn "pip 镜像源: $PIP_MIRROR (建议使用国内镜像)"
    fi
else
    print_warn "pip 镜像源未配置"
    print_info "运行: pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/"
fi

# npm 镜像
if command -v npm &> /dev/null; then
    NPM_REGISTRY=$(npm config get registry 2>/dev/null)
    if [[ "$NPM_REGISTRY" == *"npmmirror"* ]] || [[ "$NPM_REGISTRY" == *"taobao"* ]]; then
        print_pass "npm 镜像源: $NPM_REGISTRY"
    else
        print_warn "npm 镜像源: $NPM_REGISTRY (建议使用淘宝镜像)"
        print_info "运行: npm config set registry https://registry.npmmirror.com"
    fi
fi

# 14. 检查系统资源
print_header "系统资源"

# 内存
if command -v free &> /dev/null; then
    TOTAL_MEM=$(free -m | awk '/^Mem:/ {print $2}')
    if [ $TOTAL_MEM -ge 2048 ]; then
        print_pass "内存: ${TOTAL_MEM}MB"
    elif [ $TOTAL_MEM -ge 1024 ]; then
        print_warn "内存: ${TOTAL_MEM}MB (推荐 2GB+)"
    else
        print_fail "内存不足: ${TOTAL_MEM}MB (最低 2GB)"
    fi
fi

# 硬盘空间
if command -v df &> /dev/null; then
    DISK_AVAIL=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ $DISK_AVAIL -ge 5 ]; then
        print_pass "可用硬盘空间: ${DISK_AVAIL}GB"
    else
        print_warn "硬盘空间不足: ${DISK_AVAIL}GB (推荐 5GB+)"
    fi
fi

# 15. 检查网络连接
print_header "网络连接"
if ping -c 1 -W 2 baidu.com &> /dev/null; then
    print_pass "网络连接: 正常"
else
    print_warn "网络连接: 无法访问外网（可能影响依赖安装）"
fi

# 16. 检查前端依赖
print_header "前端依赖"
if [ -d "sau_frontend/node_modules" ]; then
    MODULE_COUNT=$(ls -1 sau_frontend/node_modules 2>/dev/null | wc -l)
    if [ $MODULE_COUNT -gt 10 ]; then
        print_pass "前端依赖: 已安装 ($MODULE_COUNT 个模块)"
    else
        print_warn "前端依赖可能不完整"
        print_info "运行: cd sau_frontend && npm install"
    fi
else
    print_warn "前端依赖未安装"
    print_info "运行: cd sau_frontend && npm install"
fi

# 汇总结果
echo ""
print_header "检查结果汇总"
echo ""
echo -e "${GREEN}通过: $PASS${NC}"
echo -e "${YELLOW}警告: $WARN${NC}"
echo -e "${RED}失败: $FAIL${NC}"
echo ""

# 给出建议
if [ $FAIL -eq 0 ]; then
    if [ $WARN -eq 0 ]; then
        echo -e "${GREEN}🎉 恭喜！环境配置完美，可以开始使用了！${NC}"
        echo ""
        echo "启动命令:"
        echo "  1. 激活虚拟环境: source venv/bin/activate"
        echo "  2. 启动后端: python sau_backend.py"
        echo "  3. 启动前端: cd sau_frontend && npm run dev"
    else
        echo -e "${YELLOW}⚠️  环境基本满足要求，但有一些警告项需要注意${NC}"
        echo "建议查看上述警告并进行优化"
    fi
else
    echo -e "${RED}❌ 环境配置不完整，请解决上述失败项后再运行${NC}"
    echo ""
    echo "建议:"
    echo "  1. 运行自动部署脚本: ./deploy_setup.sh"
    echo "  2. 或参考 DEPLOYMENT.md 手动配置"
fi

echo ""
print_header "更多帮助"
echo "  📖 部署文档: cat DEPLOYMENT.md"
echo "  📋 环境说明: cat ENVIRONMENT.md"
echo "  🌐 官方文档: https://sap-doc.nasdaddy.com/"
echo ""

