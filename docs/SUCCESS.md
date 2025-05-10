# 🎉 Dify 部署成功！

## 访问信息

- **控制台地址**: http://localhost
- **API 服务地址**: http://localhost:5001
- **默认账户**: admin@example.com
- **默认密码**: password

## 已启动的服务

- **Web 控制台**: dify-web-1
- **API 服务**: dify-api-1
- **数据库**: dify-db-1 (PostgreSQL)
- **缓存**: dify-redis-1 (Redis)

## 下一步操作

1. **登录控制台**
   - 使用默认账户登录并修改密码

2. **配置 API Key**
   - 在"设置" > "模型提供商"中配置 OpenAI 或其他 LLM 模型的 API Key

3. **创建应用**
   - 在控制台创建你的第一个 AI 应用
   - 可以从预设模板开始

## 管理命令

- **查看服务状态**:
  ```
  docker-compose ps
  ```

- **查看服务日志**:
  ```
  docker-compose logs -f
  ```

- **停止服务**:
  ```
  ./stop-dify.ps1
  ```
  或
  ```
  docker-compose down
  ```

- **重启服务**:
  ```
  ./start-dify.ps1
  ```
  或
  ```
  docker-compose restart
  ```

## 重要提示

- 请确保修改默认密码以保证安全
- 所有数据存储在 `volumes` 目录，请定期备份
- 生产环境部署时，请修改 `SECRET_KEY` 和所有数据库密码 