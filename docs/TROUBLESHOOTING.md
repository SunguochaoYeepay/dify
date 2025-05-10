# Dify 部署故障排除指南

本文档汇总了在部署 Dify 过程中可能遇到的常见问题及解决方案。

## 网络连接问题

### 无法从 GitHub 克隆仓库

**症状**：
- 克隆/拉取仓库超时
- 连接被拒绝

**解决方案**：
1. 检查网络连接和防火墙设置
2. 配置 Git 代理：
   ```bash
   git config --global http.proxy http://your-proxy:port
   ```
3. 使用镜像仓库

### 无法下载 Docker 镜像

**症状**：
- 下载镜像时超时
- 连接被拒绝

**解决方案**：
1. 确认 Docker Desktop 已正确启动
2. 配置 Docker 镜像加速：
   ```json
   {
     "registry-mirrors": [
       "https://docker.m.daocloud.io",
       "https://hub-mirror.c.163.com",
       "https://registry.docker-cn.com"
     ]
   }
   ```
3. 检查防火墙设置，确保 Docker 可以访问外网

## API 主机名无法解析

### ERR_NAME_NOT_RESOLVED 错误

**症状**：
- 前端无法解析 API 主机名
- 浏览器控制台显示 `ERR_NAME_NOT_RESOLVED` 错误

**解决方案**：
1. 修改 `docker-compose.yml` 中的 API URL 设置：
   ```yaml
   web:
     environment:
       - CONSOLE_API_URL=http://localhost:5001
       - APP_API_URL=http://localhost:5001
   ```
2. 重启服务：
   ```bash
   docker-compose restart web
   ```

## CORS 跨域请求问题

### 跨域请求被阻止

**症状**：
- 浏览器控制台显示 CORS 错误
- 前端无法成功调用 API

**解决方案**：
1. 确保 `docker-compose.yml` 中包含正确的 CORS 配置：
   ```yaml
   api:
     environment:
       - CONSOLE_CORS_ALLOW_ORIGINS=http://localhost,http://127.0.0.1,http://localhost:3000,http://localhost:80
       - APP_CORS_ALLOW_ORIGINS=http://localhost,http://127.0.0.1,http://localhost:3000,http://localhost:80
   ```
2. 前端和 API 地址匹配：确保前端访问 API 的地址与 CORS 配置中允许的地址一致

## 数据库表不存在错误

### "relation 'dify_setups' does not exist"

**症状**：
- API 服务日志中出现 `relation 'dify_setups' does not exist` 错误
- 无法正常登录和使用平台

**解决方案**：
1. 确保启用了数据库迁移（在 `docker-compose.yml` 中添加环境变量）：
   ```yaml
   api:
     environment:
       - MIGRATION_ENABLED=true
   ```

2. 手动执行数据库迁移：
   ```bash
   docker-compose exec api flask db upgrade
   ```

3. 重启 API 服务：
   ```bash
   docker-compose restart api
   ```

4. 如果问题仍然存在，尝试重新创建数据库：
   ```bash
   # 停止服务
   docker-compose down
   
   # 删除数据库目录
   rm -rf ./volumes/db
   
   # 创建新的数据库目录
   mkdir -p ./volumes/db
   
   # 重新启动服务
   docker-compose up -d
   
   # 执行数据库迁移
   docker-compose exec api flask db upgrade
   ```

## 服务启动问题

### 服务无法启动或反复重启

**症状**：
- 容器启动后立即退出
- 服务健康检查失败

**解决方案**：
1. 检查日志查找错误：
   ```bash
   docker-compose logs api
   ```

2. 检查端口冲突：
   ```bash
   netstat -ano | findstr "5001"
   netstat -ano | findstr "80"
   ```

3. 确保所需的目录存在且权限正确：
   ```bash
   mkdir -p volumes/api/storage
   mkdir -p volumes/db
   mkdir -p volumes/redis
   ```

## 性能问题

### 系统运行缓慢

**症状**：
- 页面加载缓慢
- API 响应时间长

**解决方案**：
1. 增加 Docker 资源分配（内存、CPU）
2. 优化数据库配置
3. 考虑使用外部数据库服务（如 RDS）代替容器数据库

## 用户认证问题

### 无法登录或创建账户

**症状**：
- 使用默认账户无法登录
- 登录页面出现错误

**解决方案**：
1. 确认默认账户信息：
   - 用户名：admin@example.com
   - 密码：password

2. 如果无法登录，尝试重置账户：
   ```bash
   docker-compose exec api flask create-admin --email admin@example.com --password password
   ```

## 其他资源

如果上述解决方案无法解决您的问题，请参考：

1. [Dify 官方文档](https://docs.dify.ai/)
2. [GitHub 问题跟踪](https://github.com/langgenius/dify/issues)
3. [社区讨论](https://github.com/langgenius/dify/discussions) 