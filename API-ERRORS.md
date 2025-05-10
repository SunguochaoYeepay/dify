# Dify API 错误排查指南

## 常见错误

在部署 Dify 时，你可能会遇到以下 API 错误：

1. `GET /console/api/workspaces/current/models/model-types/llm 500 (INTERNAL SERVER ERROR)`
2. `GET /console/api/workspaces/current/models/model-types/text-embedding 500 (INTERNAL SERVER ERROR)`
3. `GET /console/api/workspaces/current/model-providers 500 (INTERNAL SERVER ERROR)`
4. `GET /console/api/workspaces/current/plugin/tasks 500 (INTERNAL SERVER ERROR)`
5. `GET /console/api/datasets/retrieval-setting 400 (BAD REQUEST)`

## 错误原因

这些错误通常是由以下原因导致的：

1. **模型验证失败**：Dify 尝试验证配置的 LLM 模型提供商（如 OpenAI、Anthropic 等）API 密钥是否有效
2. **插件服务未配置**：与插件相关的 API 请求失败
3. **网络连接问题**：Docker 容器无法连接到模型提供商的 API 或本地模型服务（如 Ollama）

## 解决方案

### 方案一：禁用验证和插件功能

在 `docker-compose.yml` 文件中添加以下环境变量到 `api` 服务：

```yaml
# 关闭模型验证和插件功能
- DISABLE_PROVIDER_MODEL_VALIDATION=true
- PLUGIN_EXECUTOR_PUBLIC_URL=http://host.docker.internal:5001
- DISABLE_PLUGIN=true
```

### 方案二：提供虚拟 API 密钥

在 `docker-compose.yml` 中添加以下环境变量来绕过初始验证：

```yaml
# 模拟安装了 API Key
- OPENAI_API_KEY=sk-1234567890
- ANTHROPIC_API_KEY=sk-1234567890
```

### 方案三：配置本地模型

如果你想使用本地模型（如 Ollama），添加以下环境变量：

```yaml
# Ollama 配置
- OLLAMA_API_BASE_URL=http://host.docker.internal:11434
- AUTO_SETUP_LOCAL_PROVIDER=true
- LOCAL_MODEL_API_TYPE=ollama
```

### 方案四：网络配置

确保 Docker 容器可以正确连接到宿主机，添加 `extra_hosts` 配置：

```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
```

## 使用 Ollama 集成步骤

1. 下载并安装 [Ollama](https://ollama.ai/download)
2. 拉取并运行所需模型：`ollama run llama3`
3. 在 Dify 中添加 Ollama 模型提供商配置
4. 确保 Docker 网络配置允许容器访问宿主机上的 Ollama 服务

## 故障排除

如果按照上述步骤配置后仍有错误，请尝试：

1. 重新启动 Docker 服务：`docker-compose down && docker-compose up -d`
2. 检查 API 服务日志：`docker-compose logs api`
3. 确保 Ollama 服务正在运行：`curl http://localhost:11434/api/version`
4. 尝试重置数据库：`docker-compose down -v && docker-compose up -d`

## 网络连接问题（Docker 到 Ollama）

如果 Docker 容器无法连接到宿主机的 Ollama 服务，有两种常见解决方案：

1. 在 Docker 网络配置中添加 `extra_hosts` 映射（已在 docker-compose.yml 中配置）
2. 设置 `OLLAMA_HOST` 环境变量为 Docker 宿主机 IP

如果你使用 Docker Desktop 或其他环境，可能需要使用 `host.docker.internal` 作为宿主机地址。