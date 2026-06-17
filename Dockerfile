FROM node:22-slim

WORKDIR /app

# 安装 CA 证书，确保 HTTPS 上游请求正常
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# 先复制 package.json，利用 Docker 层缓存加速重复构建
COPY server/package.json server/

# 安装依赖（只有 express + cookie-parser，纯 JS，无需编译）
RUN cd server && npm install --omit=dev

# 复制全部项目文件
COPY . .

# 创建数据持久化目录（SQLite 数据库写入此处）
RUN mkdir -p /app/data

EXPOSE 8787

# 启用 node:sqlite 实验性模块（Node 22.5+ 支持，22.x 默认启用）
CMD ["node", "--experimental-sqlite", "server/index.js"]
