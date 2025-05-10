# Dify API 错误解决指南

本文档提供了解决 Dify API 常见错误的方法，特别是首次登录后遇到的 500 和 400 错误。

## 常见 API 错误

### 500 内部服务器错误

```
GET http://localhost:5001/console/api/workspaces/current/models/model-types/text-embedding 500 (INTERNAL SERVER ERROR)
GET http://localhost:5001/console/api/workspaces/current/models/model-types/llm 500 (INTERNAL SERVER ERROR)
GET http://localhost:5001/console/api/workspaces/current/model-providers 500 (INTERNAL SERVER ERROR)
GET http://localhost:5001/console/api/workspaces/current/plugin/tasks 500 (INTERNAL SERVER ERROR)
GET http://localhost:5001/console/api/workspaces/current/models/model-types/rerank 500 (INTERNAL SERVER ERROR)
```

### 400 错误

```
GET http://localhost:5001/console/api/datasets/retrieval-setting 400 (BAD REQUEST)
```

## 错误原因

这些错误通常出现在以下情况：

1. **未配置模型提供商**：Dify 需要配置 OpenAI、Anthropic 等 API Key
2. **插件服务未启动或配置错误**：插件功能未正确配置
3. **数据库迁移未完全完成**：初始化过程可能未成功

## 解决方案

### 方案 1: 禁用需要 API Key 的功能

修改 `docker-compose.yml` 文件，添加以下环境变量：

```yaml
api:
  environment:
    # 禁用需要 API Key 的功能，使界面能正常显示
    - DISABLE_PROVIDER_MODEL_VALIDATION=true
    # 插件服务配置
    - PLUGIN_EXECUTOR_PUBLIC_URL=http://localhost:5001
    - DISABLE_PLUGIN=true
```

这将禁用模型验证和插件功能，使界面可以正常显示，而不会出现 500 错误。

### 方案 2: 配置 API Key

1. 登录到 Dify 控制台（http://localhost）
2. 进入"设置" > "模型提供商"
3. 添加至少一个模型提供商的 API Key（如 OpenAI、Anthropic 等）
4. 确保 API Key 格式正确并有效

配置 API Key 后，系统将能够正常调用各种模型和功能。

### 方案 3: 完全重置数据库

如果上述方法仍然无法解决，可以尝试完全重置数据库：

```bash
# 停止服务
docker-compose down

# 删除数据库目录
rm -rf ./volumes/db

# 创建新的数据库目录
mkdir -p ./volumes/db

# 修改 docker-compose.yml 添加环境变量
# DISABLE_PROVIDER_MODEL_VALIDATION=true
# DISABLE_PLUGIN=true

# 重新启动服务
docker-compose up -d

# 等待服务完全启动（约 1-2 分钟）
```

## 预防措施

为避免类似问题，建议：

1. 在首次启动 Dify 前，编辑 `docker-compose.yml` 文件添加上述环境变量
2. 登录后立即配置有效的 API Key
3. 使用 `./logs.ps1 api` 命令监控 API 服务日志，查看是否有错误
4. 配置好 API Key 后，如希望启用插件功能，可以将 `DISABLE_PLUGIN` 设为 `false` 并重启服务

## 后续步骤

成功登录系统并解决 API 错误后，可以：

1. 配置适当的 API Key
2. 创建应用程序
3. 设置数据集
4. 测试和调整您的 AI 应用程序

如需更多帮助，请参考 [Dify 官方文档](https://docs.dify.ai/) 