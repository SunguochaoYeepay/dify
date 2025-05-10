# Dify插件安装问题解决方案

## 问题描述

在使用Docker部署Dify后，尝试通过控制台安装插件（如GitHub插件）时，遇到`500 INTERNAL SERVER ERROR`错误，提示"安装失败"。通过浏览器开发者工具可以看到以下请求失败：

```
GET http://localhost:5001/console/api/workspaces/current/plugin/marketplace/pkg?plugin_unique_identifier=langgenius%2Fgithub%3A0.0.5%40431d... 500 (INTERNAL SERVER ERROR)
```

## 原因分析

1. Dify的插件功能需要一个专门的服务（sandbox）来执行插件代码，而我们之前的配置中没有启动这个服务
2. 虽然设置了`DISABLE_PLUGIN=true`环境变量，但Dify界面仍然允许访问插件页面，导致API请求失败
3. 插件执行器的公共URL配置不正确，指向了错误的地址

## 解决方案

### 1. 修改docker-compose.yml添加sandbox服务

```yaml
  # 添加插件执行器服务（sandbox）
  sandbox:
    image: langgenius/dify-sandbox:0.2.1
    restart: always
    environment:
      - PORT=5002
      - LOG_LEVEL=INFO
      - SECRET_KEY=sk-change-me-to-a-random-key
    ports:
      - "5002:5002"
    extra_hosts:
      - "host.docker.internal:host-gateway"
```

### 2. 调整API服务的插件配置

```yaml
# 关闭模型验证（但启用插件功能）
- DISABLE_PROVIDER_MODEL_VALIDATION=true
- PLUGIN_EXECUTOR_PUBLIC_URL=http://sandbox:5002
# 移除DISABLE_PLUGIN=true以启用插件功能
```

### 3. 确保API服务依赖于sandbox服务

```yaml
depends_on:
  - db
  - redis
  - sandbox
```

## 实施步骤

1. 修改docker-compose.yml文件，添加sandbox服务和调整配置
2. 停止现有Dify服务：`docker-compose down`
3. 启动新配置的服务：`docker-compose up -d`
4. 访问Dify控制台并尝试安装插件

## 验证方法

登录Dify控制台，进入"插件"页面，尝试安装GitHub插件。如果配置正确，应该可以成功安装并看到插件列表中出现GitHub插件。

## 注意事项

1. 确保本地Ollama服务正常运行，以便能够使用本地模型
2. 本地模型（如llama3:70b、qwen3:30b）将在安装供应商和模型后可用
3. 如果仍然遇到问题，可以查看Docker日志：`docker-compose logs api`或`docker-compose logs sandbox` 