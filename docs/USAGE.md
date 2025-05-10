# Dify 日常使用手册

本文档提供 Dify 平台的日常操作指南。

## 服务管理

### 启动服务

```bash
# PowerShell
./start.ps1

# 或直接使用 Docker Compose
docker-compose up -d
```

### 停止服务

```bash
# PowerShell
./stop.ps1

# 或直接使用 Docker Compose
docker-compose down
```

### 重启服务

```bash
# 重启所有服务
docker-compose restart

# 仅重启特定服务
docker-compose restart api
docker-compose restart web
```

### 查看服务状态

```bash
# PowerShell
./status.ps1

# 或直接使用 Docker Compose
docker-compose ps
```

### 查看日志

```bash
# 查看所有服务日志
./logs.ps1

# 查看特定服务日志
./logs.ps1 api
./logs.ps1 web
./logs.ps1 db
./logs.ps1 redis

# 查看数据库相关错误
./logs.ps1 dberrors
```

## 数据管理

### 备份数据

```bash
# 备份数据库
docker-compose exec db pg_dump -U postgres -d dify > backup.sql

# 备份所有数据（包括文件存储）
# 停止服务后进行
docker-compose down
# 复制数据目录
cp -r volumes backup-volumes
```

### 恢复数据

```bash
# 恢复数据库
cat backup.sql | docker-compose exec -T db psql -U postgres -d dify

# 恢复所有数据（包括文件存储）
# 停止服务
docker-compose down
# 复制备份目录替换现有目录
rm -rf volumes
cp -r backup-volumes volumes
# 重新启动服务
docker-compose up -d
```

### 重置数据库

如果需要重新初始化数据库：

```bash
# 停止服务
docker-compose down

# 删除数据库目录
rm -rf ./volumes/db

# 创建新的数据库目录
mkdir -p ./volumes/db

# 重新启动服务
docker-compose up -d
```

## 日常维护

### 更新 Dify 版本

```bash
# 拉取最新镜像
docker-compose pull

# 重启服务以应用新版本
docker-compose down
docker-compose up -d
```

### 清理磁盘空间

```bash
# 清理不再使用的 Docker 镜像
docker image prune -a

# 清理 Docker 卷
docker volume prune

# 清理 Docker 系统
docker system prune
```

### 配置修改

如需修改 Dify 配置：

1. 编辑 `docker-compose.yml` 文件
2. 重启服务以应用更改：
   ```bash
   docker-compose down
   docker-compose up -d
   ```

## 访问信息

- 控制台地址: http://localhost
- API 地址: http://localhost:5001
- 默认账户: admin@example.com
- 默认密码: password

## 注意事项

1. 首次登录后请立即修改默认密码
2. 定期备份数据库和文件存储
3. 生产环境使用请修改所有默认密钥和密码 