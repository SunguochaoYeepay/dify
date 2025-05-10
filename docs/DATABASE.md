# Dify 数据库初始化与迁移

## 常见问题

### 表不存在错误（"relation 'dify_setups' does not exist"）

这个错误通常出现在初次部署时，表示数据库表结构尚未创建。Dify 使用数据库迁移来创建和更新表结构。

## 解决方案

### 1. 启用数据库迁移

在 `docker-compose.yml` 文件中，为 API 服务添加 `MIGRATION_ENABLED` 环境变量：

```yaml
api:
  environment:
    # 其他环境变量...
    - MIGRATION_ENABLED=true
```

这个环境变量会在 API 服务启动时自动执行数据库迁移，创建所有必要的表。

### 2. 重新创建数据库

如果启用迁移后仍然无法解决问题，可以尝试重新创建数据库：

```bash
# 停止所有服务
docker-compose down

# 删除数据库卷
rm -rf ./volumes/db

# 重新创建数据库目录
mkdir -p ./volumes/db

# 重新启动服务
docker-compose up -d
```

### 3. 手动执行迁移（高级）

对于有经验的用户，可以直接进入 API 容器手动执行迁移：

```bash
# 进入 API 容器
docker-compose exec api bash

# 在容器内执行迁移命令
flask db upgrade

# 退出容器
exit
```

## 数据备份与恢复

### 备份数据库

```bash
docker-compose exec db pg_dump -U postgres -d dify > backup.sql
```

### 恢复数据库

```bash
cat backup.sql | docker-compose exec -T db psql -U postgres -d dify
```

## 其他数据库问题

### 连接失败

如果 API 服务无法连接到数据库，请检查以下事项：

1. 确保数据库容器正在运行
2. 验证 API 服务中的数据库连接配置正确
3. 确认数据库密码匹配

### 性能问题

对于生产环境，考虑调整 PostgreSQL 配置以获得更好的性能。可以通过添加自定义配置文件来实现：

```yaml
db:
  volumes:
    - ./volumes/db:/var/lib/postgresql/data
    - ./config/postgresql.conf:/etc/postgresql/postgresql.conf
  command: postgres -c config_file=/etc/postgresql/postgresql.conf
``` 