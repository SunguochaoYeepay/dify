# Dify 社区版 Docker 部署

使用 Docker 快速部署 Dify LLM 应用开发平台。

## 快速开始

```bash
# 启动 Dify 服务
./start.ps1

# 停止 Dify 服务
./stop.ps1

# 重启 Dify 服务
./restart.ps1
# 重启单个服务（例如 api）
./restart.ps1 api

# 查看服务状态
./status.ps1

# 查看服务日志
./logs.ps1
# 查看单个服务日志
./logs.ps1 api
# 查看数据库错误
./logs.ps1 dberrors

# 清理 Docker 资源
./clean.ps1
# 一键全面清理
./clean.ps1 all

# 备份数据
./backup.ps1
```

## 访问信息

- 控制台: http://localhost
- 账户: admin@example.com
- 密码: password

## 常见问题

### API 错误排查

如果在登录后遇到API 500/400错误，请参考[API错误排查指南](API-ERRORS.md)。主要解决方法包括：

1. 禁用模型验证和插件功能
2. 提供虚拟API密钥
3. 配置本地模型连接
4. 优化Docker网络设置

详细配置示例：

```yaml
# docker-compose.yml 中添加环境变量
- DISABLE_PROVIDER_MODEL_VALIDATION=true
- PLUGIN_EXECUTOR_PUBLIC_URL=http://sandbox:5002
- DISABLE_PLUGIN=false
- OPENAI_API_KEY=sk-1234567890
- ANTHROPIC_API_KEY=sk-1234567890
```

## 本地模型集成（Ollama）

本项目已配置好与Ollama的集成，可使用您自己的本地模型，无需依赖远程API：

1. 安装[Ollama](https://ollama.ai/download)
2. 拉取并运行所需模型（例如：`ollama pull llama3`）
3. 在Dify控制台中配置Ollama模型提供商
4. 享受本地AI计算的安全性和隐私性

详细集成指南请参考[本地模型集成指南](docs/OLLAMA-INTEGRATION.md)。

## 部署方式

本仓库提供了两种部署配置：

1. **精简部署** (`docker-compose.yml`) - 适合个人使用和测试
2. **完整部署** (`docker-compose-full.yml`) - 适合生产环境和多用户场景

详细对比请查看[部署指南](DEPLOYMENT-GUIDE.md)。

## 关于 Dify

[Dify](https://github.com/langgenius/dify) 是一个开源的LLM应用开发平台，提供开箱即用的各类大模型应用所需的基础功能，支持私有部署。

本仓库包含针对Dify社区版的Docker部署配置和定制文档。

## 文档

详细使用说明请参考 `docs` 目录中的文档：

- [日常使用手册](docs/USAGE.md) - 常用操作和命令
- [故障排除指南](docs/TROUBLESHOOTING.md) - 常见问题和解决方案 
- [数据库指南](docs/DATABASE.md) - 数据库相关操作说明
- [API 错误排查指南](API-ERRORS.md) - 解决 API 500/400 错误
- [本地模型集成完全指南](docs/LOCAL-MODEL-GUIDE.md) - 使用本地模型替代远程 API
- [Ollama 本地模型集成](docs/OLLAMA-INTEGRATION.md) - Ollama 集成详细配置
- [部署成功指南](docs/SUCCESS.md) - 部署成功后的操作指南

## 文件结构

- `docker-compose.yml` - Docker 服务配置
- `start.ps1`, `stop.ps1`, `restart.ps1`, `status.ps1`, `logs.ps1`, `clean.ps1`, `backup.ps1` - 常用操作脚本
- `docs/` - 详细文档目录
- `volumes/` - 数据持久化存储
- `scripts/` - 后台脚本目录 