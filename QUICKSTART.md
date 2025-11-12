# 🚀 快速开始 - 服务器部署

> 适用于 Ubuntu/Debian Linux 系统

## 📋 前置要求

- 系统: Ubuntu 18.04+ / Debian 10+
- 权限: sudo 权限
- 网络: 能够访问互联网

---

## ⚡ 一键部署（3分钟搞定）

### 方法一：使用自动化脚本（推荐）

```bash
# 1. 克隆项目
git clone https://github.com/dreammis/social-auto-upload.git
cd social-auto-upload

# 2. 运行部署脚本（全自动）
./deploy_setup.sh

# 3. 等待安装完成（约 5-10 分钟，取决于网络速度）
```

脚本会自动完成：
- ✅ 安装 Python 3.10
- ✅ 安装 Node.js 18（通过 nvm）
- ✅ 配置国内镜像源
- ✅ 安装所有依赖
- ✅ 初始化数据库
- ✅ 安装浏览器驱动

---

## 🔍 检查环境

部署完成后，运行环境检查：

```bash
./check_env.sh
```

如果看到 `🎉 恭喜！环境配置完美` 说明一切就绪！

---

## 🎯 启动服务

### 1. 激活 Python 虚拟环境

```bash
source venv/bin/activate
```

### 2. 启动后端（新终端1）

```bash
python sau_backend.py
```

后端服务运行在: `http://服务器IP:5409`

### 3. 启动前端（新终端2）

```bash
cd sau_frontend
npm run dev
```

前端服务运行在: `http://服务器IP:5173`

---

## 🌐 访问项目

在浏览器中打开：

```
http://你的服务器IP:5173
```

---

## 📝 首次配置

### 1. 修改配置文件

```bash
nano conf.py  # 或使用 vim
```

重要配置项：
```python
# Chrome 浏览器路径
LOCAL_CHROME_PATH = "/usr/bin/google-chrome"
```

### 2. 获取平台 Cookie

运行对应平台的 Cookie 获取脚本：

```bash
# 激活虚拟环境
source venv/bin/activate

# 获取抖音 Cookie
python examples/get_douyin_cookie.py

# 获取小红书 Cookie
python examples/get_xiaohongshu_cookie.py

# 其他平台类似...
```

### 3. 准备视频文件

将要上传的视频放入 `videoFile` 目录：

```bash
cp 你的视频.mp4 videoFile/
```

---

## 🔧 常用命令

### 查看服务状态

```bash
# 查看后端进程
ps aux | grep sau_backend

# 查看前端进程
ps aux | grep vite
```

### 停止服务

```bash
# 在运行服务的终端按 Ctrl+C
```

### 重新启动

```bash
# 后端
source venv/bin/activate
python sau_backend.py

# 前端
cd sau_frontend
npm run dev
```

---

## 🐛 遇到问题？

### 检查列表

1. ✅ 运行 `./check_env.sh` 检查环境
2. ✅ 确认端口 5173 和 5409 未被占用
3. ✅ 检查防火墙设置
4. ✅ 查看服务器日志

### 端口被占用

```bash
# 查看端口占用
sudo lsof -i :5409
sudo lsof -i :5173

# 结束占用进程
kill -9 <PID>
```

### 开放防火墙端口

```bash
# Ubuntu (ufw)
sudo ufw allow 5173
sudo ufw allow 5409

# 查看防火墙状态
sudo ufw status
```

### 查看详细日志

```bash
# 后端日志在控制台输出
# 或查看系统日志
tail -f /var/log/syslog | grep python
```

---

## 📚 进阶配置

### 生产环境部署

#### 1. 构建前端

```bash
cd sau_frontend
npm run build
```

#### 2. 使用 systemd 管理服务

创建服务文件（自动脚本已支持）：

```bash
# 启动服务
sudo systemctl start social-auto-upload-backend
sudo systemctl start social-auto-upload-frontend

# 开机自启
sudo systemctl enable social-auto-upload-backend
sudo systemctl enable social-auto-upload-frontend

# 查看状态
sudo systemctl status social-auto-upload-backend
```

#### 3. 配置 Nginx 反向代理

创建 Nginx 配置 `/etc/nginx/sites-available/sau`:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    # 前端
    location / {
        proxy_pass http://127.0.0.1:5173;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # 后端 API
    location /api/ {
        proxy_pass http://127.0.0.1:5409/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

启用配置：
```bash
sudo ln -s /etc/nginx/sites-available/sau /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## 📊 性能优化

### 1. 增加 swap 空间（内存不足时）

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 永久生效
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 2. 使用 PM2 管理 Node.js 进程

```bash
npm install -g pm2

cd sau_frontend
pm2 start "npm run dev" --name sau-frontend

# 开机自启
pm2 startup
pm2 save
```

---

## 🔄 更新项目

```bash
# 1. 进入项目目录
cd social-auto-upload

# 2. 拉取最新代码
git pull

# 3. 更新 Python 依赖
source venv/bin/activate
pip install -r requirements.txt --upgrade

# 4. 更新前端依赖
cd sau_frontend
npm install
cd ..

# 5. 重启服务
```

---

## 🛡️ 安全建议

1. **不要以 root 用户运行**
2. **配置防火墙，仅开放必要端口**
3. **定期更新系统和依赖**
4. **备份数据库和配置文件**

```bash
# 备份脚本
cp db/database.db db/database.db.backup.$(date +%Y%m%d)
tar -czf backup_$(date +%Y%m%d).tar.gz db/ cookies/ cookiesFile/ conf.py
```

---

## 📖 完整文档

- **详细部署**: [DEPLOYMENT.md](./DEPLOYMENT.md)
- **环境说明**: [ENVIRONMENT.md](./ENVIRONMENT.md)
- **官方文档**: https://sap-doc.nasdaddy.com/

---

## ❓ 常见问题速查

| 问题 | 解决方案 |
|------|---------|
| Python 版本不对 | `sudo apt-get install python3.10` |
| Node.js 版本过低 | `nvm install 18 && nvm use 18` |
| npm 安装慢 | `npm config set registry https://registry.npmmirror.com` |
| pip 安装慢 | `pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/` |
| 端口被占用 | `sudo lsof -i :端口号` 然后 `kill -9 PID` |
| 无法访问服务 | 检查防火墙 `sudo ufw status` |
| Playwright 安装失败 | `export PLAYWRIGHT_DOWNLOAD_HOST=https://npmmirror.com/mirrors/playwright/` |
| 数据库错误 | 重新初始化 `cd db && python3.10 createTable.py` |

---

## 🆘 获取帮助

- 🐛 **问题反馈**: https://github.com/dreammis/social-auto-upload/issues
- 💬 **交流群**: 关注公众号获取入群方式
- 📧 **邮件支持**: 参考官方文档

---

## ⏱️ 预计耗时

| 步骤 | 时间 |
|------|------|
| 克隆项目 | 1-2 分钟 |
| 运行部署脚本 | 5-15 分钟 |
| 配置和测试 | 5-10 分钟 |
| **总计** | **15-30 分钟** |

---

**祝您使用愉快！如有问题请查看完整文档或联系社区获取支持。** 🎉

