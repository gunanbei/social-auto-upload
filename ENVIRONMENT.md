# 环境要求与版本说明

## 📌 快速参考

| 组件 | 要求版本 | 推荐版本 | 获取方式 |
|------|---------|---------|---------|
| **操作系统** | Ubuntu 18.04+ / Debian 10+ | Ubuntu 22.04 LTS | - |
| **Python** | 3.10.x | 3.10.13 | `python3.10 --version` |
| **Node.js** | 18.0.0+ | 18.20.x LTS | `node --version` |
| **npm** | 9.0.0+ | 最新 | `npm --version` |
| **内存** | 2GB+ | 4GB+ | `free -h` |
| **硬盘空间** | 5GB+ | 10GB+ | `df -h` |

---

## 🐍 Python 环境

### 版本要求
- **必需版本**: Python 3.10.x
- **不支持**: Python 3.8, 3.9, 3.11+

### 主要依赖包及版本

根据 `requirements.txt` 分析的关键依赖：

```
Flask==3.1.1              # Web 后端框架
flask-cors==6.0.0         # 跨域支持
playwright==1.52.0        # 浏览器自动化
biliup==0.4.98           # B站上传
xhs==0.2.13              # 小红书
loguru==0.7.3            # 日志
requests==2.32.3         # HTTP 请求
SQLAlchemy==2.0.41       # 数据库ORM
pillow==11.2.1           # 图像处理
aiohttp==3.9.5           # 异步HTTP
PyYAML==6.0.2            # YAML 配置
```

### 安装方法

#### Ubuntu/Debian:
```bash
# 使用 deadsnakes PPA
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt-get update
sudo apt-get install python3.10 python3.10-venv python3.10-dev -y
```

#### 从源码编译:
```bash
wget https://www.python.org/ftp/python/3.10.13/Python-3.10.13.tgz
tar -xf Python-3.10.13.tgz
cd Python-3.10.13
./configure --enable-optimizations
make -j $(nproc)
sudo make altinstall
```

#### 验证安装:
```bash
python3.10 --version
# 输出: Python 3.10.13
```

---

## 🟢 Node.js 环境

### 版本要求
- **最低版本**: Node.js 18.0.0
- **推荐版本**: Node.js 18.20.x LTS
- **原因**: Vite 6.x 要求 Node.js 18+

### 前端依赖包

根据 `sau_frontend/package.json`：

```json
{
  "dependencies": {
    "vue": "^3.5.13",           // Vue 3 框架
    "vue-router": "^4.5.1",     // 路由
    "element-plus": "^2.9.11",  // UI 组件库
    "pinia": "^3.0.2",          // 状态管理
    "axios": "^1.9.0",          // HTTP 客户端
    "sass": "^1.89.1"           // CSS 预处理器
  },
  "devDependencies": {
    "@vitejs/plugin-vue": "^5.2.3",
    "vite": "^6.3.5"            // 构建工具 (要求 Node 18+)
  }
}
```

### 使用 nvm 安装（推荐）

#### 1. 安装 nvm:
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
```

#### 2. 配置国内镜像源:
```bash
# 方法1: 环境变量（临时）
export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node/

# 方法2: 写入配置文件（永久）
echo 'export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node/' >> ~/.bashrc
source ~/.bashrc
```

#### 3. 安装 Node.js 18:
```bash
nvm install 18
nvm use 18
nvm alias default 18
```

#### 4. 配置 npm 淘宝镜像:
```bash
npm config set registry https://registry.npmmirror.com
npm config set disturl https://npmmirror.com/mirrors/node
npm config set electron_mirror https://npmmirror.com/mirrors/electron/
npm config set sass_binary_site https://npmmirror.com/mirrors/node-sass/
npm config set phantomjs_cdnurl https://npmmirror.com/mirrors/phantomjs/
npm config set chromedriver_cdnurl https://npmmirror.com/mirrors/chromedriver/
npm config set operadriver_cdnurl https://npmmirror.com/mirrors/operadriver/
npm config set selenium_cdnurl https://npmmirror.com/mirrors/selenium/
```

#### 验证配置:
```bash
node --version    # v18.20.x
npm --version     # 9.x.x
npm config get registry  # https://registry.npmmirror.com/
```

---

## 🌐 镜像源配置汇总

### Python pip 镜像

#### 临时使用:
```bash
pip install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/
```

#### 永久配置:
```bash
# 阿里云镜像（推荐）
pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/
pip config set install.trusted-host mirrors.aliyun.com

# 或使用清华镜像
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple/
```

### Node.js nvm 镜像

```bash
# Node.js 二进制文件镜像
export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node/

# 永久配置
echo 'export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node/' >> ~/.bashrc
```

### npm 镜像

```bash
# 淘宝镜像（推荐）
npm config set registry https://registry.npmmirror.com

# 查看当前配置
npm config list
```

### Playwright 浏览器镜像

```bash
# 使用国内镜像下载浏览器
export PLAYWRIGHT_DOWNLOAD_HOST=https://npmmirror.com/mirrors/playwright/

# 安装浏览器
playwright install chromium
```

---

## 🖥️ 系统依赖

### Ubuntu/Debian 必需包

```bash
sudo apt-get install -y \
    # 编译工具
    build-essential \
    gcc \
    g++ \
    make \
    # Python 编译依赖
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libffi-dev \
    liblzma-dev \
    # 工具
    wget \
    curl \
    git \
    # Playwright 浏览器依赖
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libpango-1.0-0 \
    libcairo2 \
    libasound2
```

### Chrome/Chromium 浏览器

```bash
# 安装 Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt-get install ./google-chrome-stable_current_amd64.deb -y

# 或安装 Chromium
sudo apt-get install chromium-browser -y

# 验证安装
google-chrome --version
# 或
chromium-browser --version
```

---

## 🎯 Playwright 浏览器

### 支持的浏览器

| 浏览器 | 版本 | 用途 | 必需 |
|-------|------|------|------|
| Chromium | 最新 | 主要平台（抖音、快手等） | ✅ 是 |
| Firefox | 最新 | TikTok（旧版方案） | ⚠️ 可选 |
| WebKit | 最新 | 未使用 | ❌ 否 |

### 安装命令

```bash
# 激活虚拟环境
source venv/bin/activate

# 安装浏览器
playwright install chromium firefox

# 安装浏览器系统依赖
playwright install-deps chromium firefox
```

### 验证安装

```bash
playwright --version
# 输出: Version 1.52.0
```

---

## 💾 数据库

### SQLite
- **版本**: 3.x (Python 自带)
- **用途**: 存储账号信息、文件记录
- **位置**: `db/database.db`

### 初始化

```bash
source venv/bin/activate
cd db
python3.10 createTable.py
```

---

## 📦 项目结构

```
social-auto-upload/
├── sau_backend.py           # 后端入口 (Flask, Port 5409)
├── sau_frontend/            # 前端项目 (Vue 3 + Vite)
│   ├── package.json
│   └── src/
├── requirements.txt         # Python 依赖
├── conf.py                  # 配置文件
├── db/                      # 数据库
│   └── database.db
├── cookies/                 # Cookie 存储（examples 脚本）
├── cookiesFile/             # Cookie 存储（Web 界面）
├── videoFile/               # 视频文件存储
├── uploader/                # 各平台上传模块
├── examples/                # 示例脚本
├── deploy_setup.sh          # 🆕 一键部署脚本
└── DEPLOYMENT.md            # 🆕 详细部署文档
```

---

## 🔍 版本检查命令

### 检查脚本

创建 `check_env.sh` 脚本：

```bash
#!/bin/bash

echo "=== 环境检查 ==="
echo ""

# Python
if command -v python3.10 &> /dev/null; then
    echo "✅ Python: $(python3.10 --version)"
else
    echo "❌ Python 3.10 未安装"
fi

# Node.js
if command -v node &> /dev/null; then
    NODE_VER=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VER" -ge 18 ]; then
        echo "✅ Node.js: $(node --version)"
    else
        echo "⚠️  Node.js: $(node --version) (建议 18+)"
    fi
else
    echo "❌ Node.js 未安装"
fi

# npm
if command -v npm &> /dev/null; then
    echo "✅ npm: v$(npm --version)"
else
    echo "❌ npm 未安装"
fi

# nvm
if [ -d "$HOME/.nvm" ]; then
    echo "✅ nvm: 已安装"
else
    echo "⚠️  nvm: 未安装（推荐安装）"
fi

# Playwright
if [ -f "venv/bin/playwright" ]; then
    source venv/bin/activate 2>/dev/null
    echo "✅ Playwright: $(playwright --version 2>/dev/null || echo '已安装')"
else
    echo "❌ Playwright 未安装"
fi

# Chrome
if command -v google-chrome &> /dev/null; then
    echo "✅ Chrome: $(google-chrome --version)"
elif command -v chromium-browser &> /dev/null; then
    echo "✅ Chromium: $(chromium-browser --version)"
else
    echo "⚠️  Chrome/Chromium: 未安装"
fi

# 系统信息
echo ""
echo "=== 系统信息 ==="
echo "OS: $(lsb_release -d | cut -f2)"
echo "内存: $(free -h | awk '/^Mem:/ {print $2}')"
echo "硬盘: $(df -h / | awk 'NR==2 {print $4 " 可用"}')"

echo ""
echo "=== 镜像源配置 ==="
echo "pip: $(pip config get global.index-url 2>/dev/null || echo '未配置')"
echo "npm: $(npm config get registry 2>/dev/null || echo '未配置')"
```

运行检查：
```bash
chmod +x check_env.sh
./check_env.sh
```

---

## 📝 常见版本问题

### Python 版本不匹配

**症状**: 
```
ModuleNotFoundError: No module named 'xxx'
SyntaxError: invalid syntax
```

**解决**: 确保使用 Python 3.10
```bash
python3.10 --version  # 必须是 3.10.x
python3.10 -m venv venv
source venv/bin/activate
```

### Node.js 版本过低

**症状**:
```
error vite@6.3.5: The engine "node" is incompatible with this module
```

**解决**: 升级到 Node.js 18+
```bash
nvm install 18
nvm use 18
nvm alias default 18
```

### npm 安装慢

**症状**: npm install 卡住或超时

**解决**: 配置淘宝镜像
```bash
npm config set registry https://registry.npmmirror.com
npm cache clean --force
npm install
```

---

## 🆘 获取帮助

- 📖 **详细部署文档**: [DEPLOYMENT.md](./DEPLOYMENT.md)
- 🌐 **官方文档**: https://sap-doc.nasdaddy.com/
- 🐛 **问题反馈**: https://github.com/dreammis/social-auto-upload/issues
- 💬 **交流群**: 关注公众号获取

---

**最后更新**: 2024-11-03

