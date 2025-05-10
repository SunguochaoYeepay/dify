# Dify部署与本地模型集成最终解决方案

## 问题总结

在使用Docker部署Dify社区版时，遇到以下问题：

1. 登录后台后出现多个API错误（500/400），包括：
   - `/console/api/workspaces/current/models/model-types/llm` (500错误)
   - `/console/api/workspaces/current/models/model-types/text-embedding` (500错误)
   - `/console/api/workspaces/current/model-providers` (500错误)
   - `/console/api/workspaces/current/plugin/tasks` (500错误)
   - `/console/api/datasets/retrieval-setting` (400错误)

2. 希望使用本地模型（Ollama）替代远程API提供商，但连接配置有问题

## 解决方案

### 1. 修改docker-compose.yml配置

在docker-compose.yml中为api服务添加以下环境变量：

```yaml
# 关闭模型验证和插件功能
- DISABLE_PROVIDER_MODEL_VALIDATION=true
- PLUGIN_EXECUTOR_PUBLIC_URL=http://host.docker.internal:5001
- DISABLE_PLUGIN=true

# 模拟安装了API Key（绕过初始验证）
- OPENAI_API_KEY=sk-1234567890
- ANTHROPIC_API_KEY=sk-1234567890

# Ollama配置（本地模型）
- OLLAMA_API_BASE_URL=http://host.docker.internal:11434
- AUTO_SETUP_LOCAL_PROVIDER=true
- LOCAL_MODEL_API_TYPE=ollama

# 允许Docker容器访问宿主机
extra_hosts:
  - "host.docker.internal:host-gateway"
```

### 2. 安装并配置Ollama

1. 从[Ollama官网](https://ollama.ai/download)下载并安装
2. 拉取所需模型：
   ```bash
   ollama pull llama3
   ```
3. 运行模型：
   ```bash
   ollama run llama3
   ```

### 3. 重启Dify服务

```bash
docker-compose down
docker-compose up -d
```

### 4. 在Dify中配置Ollama

1. 登录Dify控制台：http://localhost
2. 进入"设置" > "模型提供商"
3. 找到并配置Ollama模型提供商

## 解决方案原理说明

1. **禁用模型验证**：`DISABLE_PROVIDER_MODEL_VALIDATION=true`防止Dify尝试验证模型提供商的API密钥
2. **禁用插件功能**：`DISABLE_PLUGIN=true`关闭插件相关功能，避免500错误
3. **提供虚假API密钥**：提供假的OpenAI和Anthropic API密钥，通过初始验证
4. **配置本地模型**：设置Ollama相关参数，使Dify自动配置本地模型提供商
5. **网络配置**：使用`host.docker.internal`和`extra_hosts`确保Docker容器可以连接到宿主机上的Ollama服务

## 可能的网络连接问题

不同操作系统的宿主机地址：
- Windows/Mac (Docker Desktop): 使用`host.docker.internal`
- Linux: 使用宿主机的实际IP地址或添加`extra_hosts`配置

如果`host.docker.internal`不起作用，可尝试：

1. 使用实际IP地址：
   ```yaml
   - OLLAMA_API_BASE_URL=http://192.168.x.x:11434
   ```

2. 设置Ollama监听所有网络接口：
   ```bash
   # Windows
   set OLLAMA_HOST=0.0.0.0:11434
   # Linux/macOS
   export OLLAMA_HOST=0.0.0.0:11434
   ```

## 其他解决方案

如果仍有问题，可以尝试：

1. **检查防火墙设置**：确保允许11434端口的TCP流量
2. **检查API日志**：`docker-compose logs api`查看详细错误信息
3. **重置Dify环境**：
   ```bash
   docker-compose down -v
   docker-compose up -d
   ```
4. **尝试最新版本**：
   ```bash
   docker pull langgenius/dify-api:latest
   docker pull langgenius/dify-web:latest
   docker-compose up -d
   ```

## 相关文档

- [API错误排查指南](API-ERRORS.md)
- [Ollama本地模型集成](docs/OLLAMA-INTEGRATION.md)
- [本地模型集成指南](docs/LOCAL-MODEL-GUIDE.md) 