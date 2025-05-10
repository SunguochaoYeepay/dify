# Dify 社区版 Docker 部署

## 项目说明
Dify 是一个开源的 LLM 应用开发平台，这个仓库包含了使用 Docker 部署 Dify 社区版的配置文件。

## 快速开始

### 前置要求
- 安装 [Docker](https://docs.docker.com/get-docker/)
- 安装 [Docker Compose](https://docs.docker.com/compose/install/)

### 部署步骤

1. **启动所有服务**
```bash
# 使用 PowerShell 脚本启动（推荐）
./start-dify.ps1

# 或者直接使用 docker-compose
docker-compose up -d
```

2. **访问 Dify 控制台**
- 浏览器访问: http://localhost
- 默认管理员账户: 
  - 邮箱: admin@example.com
  - 密码: password

3. **停止服务**
```bash
# 使用 PowerShell 脚本停止（推荐）
./stop-dify.ps1

# 或者直接使用 docker-compose
docker-compose down
```

## 网络问题解决方案

如果遇到镜像下载失败的问题，请尝试以下解决方案：

1. **确保 Docker Desktop 已启动**
   - 检查任务栏图标或启动 Docker Desktop 应用

2. **检查网络连接**
   - 确认可以访问外网
   - 如果使用公司网络，可能需要配置代理

3. **配置 Docker 镜像加速**
   - 在 Docker Desktop 的设置中添加镜像加速地址
   - 常用加速地址：
     - https://docker.m.daocloud.io
     - https://hub-mirror.c.163.com
     - https://registry.docker-cn.com

## 配置说明

### 环境变量
重要的环境变量已在 `docker-compose.yml` 文件中配置，生产环境使用前请修改：

- `SECRET_KEY`: 安全密钥，生产环境必须修改
- `INIT_ROOT_EMAIL` 和 `INIT_ROOT_PASSWORD`: 初始管理员账户
- `DB_PASSWORD` 和 `REDIS_PASSWORD`: 数据库密码

### LLM 集成
需要在 Dify 控制台中配置语言模型提供商 API Key:
1. 登录后进入"设置" > "模型提供商"
2. 根据提示添加 OpenAI、Azure OpenAI、Anthropic 等提供商的 API Key

## 数据存储
数据存储在本地的 `volumes` 目录中:
- `volumes/db`: PostgreSQL 数据
- `volumes/redis`: Redis 数据
- `volumes/api/storage`: 文件和向量数据库存储

## 生产环境建议
1. 修改所有默认密码
2. 配置 HTTPS
3. 设置数据备份策略
4. 考虑使用外部数据库服务
5. 配置防火墙

## 相关资源
- [Dify 官方文档](https://docs.dify.ai/)
- [Dify GitHub 仓库](https://github.com/langgenius/dify)
- [Dify Docker Hub](https://hub.docker.com/u/langgenius) 