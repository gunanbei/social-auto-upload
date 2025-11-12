# Social Auto Upload - 服务器部署指南

## 📋 目录

- [环境要求](#环境要求)
- [快速部署](#快速部署)
- [手动部署](#手动部署)
- [配置说明](#配置说明)
- [服务管理](#服务管理)
- [常见问题](#常见问题)

---

## 🖥️ 环境要求

### 必需环境

| 软件 | 版本要求 | 说明 |
|------|---------|------|
| **操作系统** | Ubuntu 18.04+ / Debian 10+ | 推荐 Ubuntu 20.04/22.04 LTS |
| **Python** | 3.10.x | 必须使用 Python 3.10 |
| **Node.js** | 18.x LTS | 前端需要 Node.js 18+ |
| **内存** | 2GB+ | 推荐 4GB+ |
| **硬盘** | 5GB+ | 用于存储视频和浏览器驱动 |

### 系统架构
- ✅ x86_64 (amd64)
- ✅ ARM64 (部分支持)

---

## 🚀 快速部署

### 一键部署（推荐）

```bash
# 1. 克隆项目
git clone https://github.com/dreammis/social-auto-upload.git
cd social-auto-upload

# 2. 运行自动部署脚本
./deploy_setup.sh
```

部署脚本会自动完成以下操作：
- ✅ 检测并更新系统
- ✅ 安装系统依赖包
- ✅ 安装 Python 3.10
- ✅ 安装 nvm 和 Node.js 18（配置淘宝镜像）
- ✅ 创建 Python 虚拟环境
- ✅ 安装项目依赖
- ✅ 安装 Playwright 浏览器驱动
- ✅ 初始化数据库
- ✅ 创建必要的目录结构

---

## 🔧 手动部署

如果自动脚本无法满足需求，可以按以下步骤手动部署：

### 1. 更新系统

```bash
sudo apt-get update
sudo apt-get upgrade -y
```

### 2. 安装系统依赖

```bash
sudo apt-get install -y build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev \
    liblzma-dev python3-openssl git
```

### 3. 安装 Python 3.10

#### Ubuntu 18.04/20.04:
```bash
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt-get update
sudo apt-get install python3.10 python3.10-venv python3.10-dev -y
```

#### 验证安装:
```bash
python3.10 --version
# 输出: Python 3.10.x
```

### 4. 安装 nvm 和 Node.js

#### 安装 nvm:
```bash
# 下载并安装 nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# 加载 nvm（或重新打开终端）
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

#### 配置 nvm 淘宝镜像源:
```bash
# 设置Node.js下载镜像
export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node/

# 写入配置文件（永久生效）
echo 'export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node/' >> ~/.bashrc
echo 'export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node/' >> ~/.zshrc
```

#### 安装 Node.js 18:
```bash
nvm install 18
nvm use 18
nvm alias default 18

# 验证安装
node --version  # 输出: v18.x.x
npm --version   # 输出: 9.x.x
```

#### 配置 npm 淘宝镜像:
```bash
npm config set registry https://registry.npmmirror.com

# 验证镜像源
npm config get registry
# 输出: https://registry.npmmirror.com/
```

### 5. 克隆项目并配置

```bash
# 克隆项目
git clone https://github.com/dreammis/social-auto-upload.git
cd social-auto-upload

# 创建必要的目录
mkdir -p cookiesFile videoFile
mkdir -p cookies/douyin_uploader
mkdir -p cookies/ks_uploader
mkdir -p cookies/tencent_uploader
mkdir -p cookies/xiaohongshu_uploader

# 复制配置文件
cp conf.example.py conf.py
```

### 6. 安装 Python 依赖

```bash
# 创建虚拟环境
python3.10 -m venv venv

# 激活虚拟环境
source venv/bin/activate

# 配置pip镜像源（加速安装）
pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/
pip config set install.trusted-host mirrors.aliyun.com

# 升级pip
pip install --upgrade pip

# 安装项目依赖
pip install -r requirements.txt
```

### 7. 安装 Playwright 浏览器驱动

```bash
# 确保虚拟环境已激活
source venv/bin/activate

# 安装浏览器驱动
playwright install chromium firefox

# 安装浏览器系统依赖
playwright install-deps chromium firefox
```

### 8. 安装前端依赖

```bash
cd sau_frontend

# 确保使用 Node.js 18
nvm use 18

# 安装依赖
npm install

# 返回项目根目录
cd ..
```

### 9. 初始化数据库

```bash
# 确保虚拟环境已激活
source venv/bin/activate

# 初始化数据库
cd db
python3.10 createTable.py
cd ..
```

---

## ⚙️ 配置说明

### 1. 编辑配置文件

```bash
nano conf.py  # 或使用 vim/vi
```

主要配置项：

```python
# Chrome浏览器路径（Linux服务器）
LOCAL_CHROME_PATH = "/usr/bin/google-chrome"  # 或 "/usr/bin/chromium-browser"

# 其他配置项根据需要修改...
```

### 2. 获取平台 Cookie

运行对应平台的 Cookie 获取脚本：

```bash
# 激活虚拟环境
source venv/bin/activate

# 获取抖音Cookie
python examples/get_douyin_cookie.py

# 获取快手Cookie
python examples/get_kuaishou_cookie.py

# 获取小红书Cookie
python examples/get_xiaohongshu_cookie.py

# 获取视频号Cookie
python examples/get_tencent_cookie.py

# 获取B站Cookie
python examples/get_bilibili_cookie.py
```

Cookie 文件会保存在 `cookies/[平台]_uploader/account.json`

---

## 🎯 启动服务

### 方式一：手动启动（开发/测试）

#### 启动后端服务:
```bash
# 激活虚拟环境
source venv/bin/activate

# 启动后端（端口 5409）
python sau_backend.py
```

#### 启动前端服务（新终端）:
```bash
cd sau_frontend

# 确保使用 Node.js 18
nvm use 18

# 启动前端（端口 5173）
npm run dev
```

#### 前端构建（生产环境）:
```bash
cd sau_frontend
npm run build
```

### 方式二：systemd 服务（生产环境推荐）

自动部署脚本会询问是否创建 systemd 服务，如果已创建：

#### 管理后端服务:
```bash
# 启动服务
sudo systemctl start social-auto-upload-backend

# 停止服务
sudo systemctl stop social-auto-upload-backend

# 重启服务
sudo systemctl restart social-auto-upload-backend

# 查看状态
sudo systemctl status social-auto-upload-backend

# 开机自启
sudo systemctl enable social-auto-upload-backend

# 禁用自启
sudo systemctl disable social-auto-upload-backend

# 查看日志
sudo journalctl -u social-auto-upload-backend -f
```

#### 管理前端服务:
```bash
# 启动服务
sudo systemctl start social-auto-upload-frontend

# 查看状态
sudo systemctl status social-auto-upload-frontend
```

### 方式三：使用 Docker（可选）

```bash
# 使用 docker-compose
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

---

## 🌐 访问服务

部署成功后，可以通过以下地址访问：

- **前端界面**: http://服务器IP:5173
- **后端API**: http://服务器IP:5409

### 防火墙配置

如果无法访问，需要开放端口：

```bash
# Ubuntu/Debian (ufw)
sudo ufw allow 5173
sudo ufw allow 5409

# CentOS/RHEL (firewalld)
sudo firewall-cmd --permanent --add-port=5173/tcp
sudo firewall-cmd --permanent --add-port=5409/tcp
sudo firewall-cmd --reload
```

---

## 🔍 常见问题

### 1. Python 版本问题

**问题**: 系统只有 Python 3.8/3.9，安装 Python 3.10 失败

**解决方案**:
```bash
# 方法1: 使用 deadsnakes PPA (Ubuntu)
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt-get update
sudo apt-get install python3.10 python3.10-venv python3.10-dev

# 方法2: 从源码编译安装
wget https://www.python.org/ftp/python/3.10.13/Python-3.10.13.tgz
tar -xf Python-3.10.13.tgz
cd Python-3.10.13
./configure --enable-optimizations
make -j $(nproc)
sudo make altinstall
```

### 2. nvm 安装后无法使用

**问题**: 运行 `nvm` 提示命令未找到

**解决方案**:
```bash
# 重新加载配置
source ~/.bashrc
# 或
source ~/.zshrc

# 手动加载 nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

### 3. Playwright 浏览器安装失败

**问题**: 网络问题导致浏览器下载失败

**解决方案**:
```bash
# 方法1: 使用国内镜像
export PLAYWRIGHT_DOWNLOAD_HOST=https://npmmirror.com/mirrors/playwright/

# 方法2: 手动安装系统依赖
sudo apt-get install -y libnss3 libatk-bridge2.0-0 libdrm2 libxkbcommon0 libgbm1 libasound2

# 重新安装
playwright install chromium
playwright install-deps chromium
```

### 4. npm install 很慢或失败

**问题**: 依赖包下载缓慢

**解决方案**:
```bash
# 确认已设置淘宝镜像
npm config get registry

# 如果不是淘宝镜像，重新设置
npm config set registry https://registry.npmmirror.com

# 清理缓存后重试
npm cache clean --force
npm install
```

### 5. 数据库初始化失败

**问题**: `database.db` 文件创建失败

**解决方案**:
```bash
# 确保 db 目录存在且有写权限
mkdir -p db
chmod 755 db

# 确保虚拟环境已激活
source venv/bin/activate

# 重新初始化
cd db
python3.10 createTable.py
cd ..
```

### 6. 服务器无图形界面如何获取Cookie

**问题**: 服务器没有桌面环境，无法显示浏览器

**解决方案**:

**方法1**: 本地获取 Cookie 后上传
```bash
# 在本地运行脚本获取Cookie
python examples/get_douyin_cookie.py

# 将生成的Cookie文件上传到服务器
scp cookies/douyin_uploader/account.json user@server:/path/to/project/cookies/douyin_uploader/
```

**方法2**: 使用 Xvfb 虚拟显示
```bash
# 安装 Xvfb
sudo apt-get install xvfb -y

# 使用 Xvfb 运行脚本
xvfb-run python examples/get_douyin_cookie.py
```

### 7. Chrome 浏览器未安装

**问题**: 提示找不到 Chrome 浏览器

**解决方案**:
```bash
# 安装 Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt-get install ./google-chrome-stable_current_amd64.deb -y

# 或安装 Chromium
sudo apt-get install chromium-browser -y

# 更新 conf.py 中的浏览器路径
LOCAL_CHROME_PATH = "/usr/bin/google-chrome"  # 或 "/usr/bin/chromium-browser"
```

### 8. 内存不足

**问题**: 运行时提示内存不足

**解决方案**:
```bash
# 创建 swap 交换空间（临时方案）
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 永久生效
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

## 📊 性能优化

### 1. 使用生产模式运行

```bash
# 前端构建为静态文件
cd sau_frontend
npm run build

# 使用 nginx 或其他 Web 服务器提供静态文件
```

### 2. 配置 Nginx 反向代理（推荐）

```nginx
server {
    listen 80;
    server_name your-domain.com;

    # 前端静态文件
    location / {
        root /path/to/social-auto-upload/sau_frontend/dist;
        try_files $uri $uri/ /index.html;
    }

    # 后端 API 代理
    location /api/ {
        proxy_pass http://127.0.0.1:5409/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### 3. 启用 PM2 管理 Node.js 进程（可选）

```bash
# 安装 PM2
npm install -g pm2

# 启动前端（开发模式）
cd sau_frontend
pm2 start "npm run dev" --name sau-frontend

# 查看状态
pm2 status

# 查看日志
pm2 logs sau-frontend
```

---

## 🔒 安全建议

1. **不要以 root 用户运行服务**
2. **配置防火墙，只开放必要端口**
3. **定期更新系统和依赖包**
4. **使用 HTTPS（配置 SSL 证书）**
5. **定期备份数据库和配置文件**

```bash
# 备份数据库
cp db/database.db db/database.db.backup.$(date +%Y%m%d)

# 备份 Cookie 文件
tar -czf cookies_backup_$(date +%Y%m%d).tar.gz cookies/ cookiesFile/
```

---

## 📚 更多资源

- **官方文档**: https://sap-doc.nasdaddy.com/
- **GitHub 仓库**: https://github.com/dreammis/social-auto-upload
- **问题反馈**: https://github.com/dreammis/social-auto-upload/issues

---

## 📝 更新日志

### v1.0.0 (2024-01-xx)
- ✅ 支持 Ubuntu/Debian 系统一键部署
- ✅ 自动配置国内镜像源
- ✅ 支持 systemd 服务管理
- ✅ 完整的部署文档

---

## 🤝 贡献

欢迎提交问题和改进建议！

---

**祝您部署顺利！如有问题请参考文档或加入交流群获取支持。**

