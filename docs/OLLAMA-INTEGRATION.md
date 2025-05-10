# Dify与Ollama本地模型集成指南

本指南详细介绍如何将Dify与Ollama本地模型集成，让您可以在不依赖远程API提供商的情况下运行AI应用。

## 先决条件

- 已安装Docker和Docker Compose
- Windows、Mac或Linux操作系统
- 已安装Dify（参考项目根目录README.md）

## 步骤1：安装Ollama

1. 从[Ollama官网](https://ollama.ai/download)下载适合您操作系统的安装包
2. 按照安装向导完成安装
3. 安装完成后，确认Ollama服务已启动

## 步骤2：下载和运行模型

```bash
# 拉取最新的Llama 3模型
ollama pull llama3

# 也可以拉取其他模型
# ollama pull llama2
# ollama pull mistral
# ollama pull phi

# 运行模型（首次启动会加载模型，可能需要一些时间）
ollama run llama3
```

测试模型是否正常工作：
```bash
# 发送一个简单的请求
curl http://localhost:11434/api/generate -d '{
  "model": "llama3",
  "prompt": "你好，请简单介绍一下自己",
  "stream": false
}'
```

## 步骤3：配置Dify连接Ollama

编辑`docker-compose.yml`文件，添加Ollama相关配置：

```yaml
services:
  api:
    environment:
      # 其他配置...
      
      # Ollama配置
      - OLLAMA_API_BASE_URL=http://host.docker.internal:11434
      - AUTO_SETUP_LOCAL_PROVIDER=true
      - LOCAL_MODEL_API_TYPE=ollama
      
      # 禁用API验证和插件功能
      - DISABLE_PROVIDER_MODEL_VALIDATION=true
      - PLUGIN_EXECUTOR_PUBLIC_URL=http://host.docker.internal:5001
      - DISABLE_PLUGIN=true
      
    # 允许Docker容器访问宿主机
    extra_hosts:
      - "host.docker.internal:host-gateway"
```

## 步骤4：重启Dify服务

```bash
# 停止服务
docker-compose down

# 启动服务
docker-compose up -d
```

## 步骤5：配置Dify使用Ollama模型

1. 登录Dify控制台：http://localhost
2. 进入"设置" > "模型提供商"
3. 找到"Ollama"提供商，点击"添加"
4. 配置模型设置：
   - 模型提供商: Ollama
   - 基础地址: http://host.docker.internal:11434/api（或Ollama实际地址）
   - 模型: llama3（或您选择的模型）
5. 点击"保存"完成配置

## 网络连接问题排查

如果Docker容器无法连接到宿主机上的Ollama服务，可能有以下几种情况：

### 不同操作系统的宿主机地址

- **Windows/Mac (Docker Desktop)**: 使用`host.docker.internal`
- **Linux**: 使用宿主机的实际IP地址（如`172.17.0.1`）或添加`extra_hosts`配置

### 检查Ollama服务可访问性

```bash
# 在Docker容器内部测试连接
docker exec -it dify-api-1 curl http://host.docker.internal:11434/api/version

# 如果上面命令失败，使用宿主机IP地址尝试
docker exec -it dify-api-1 curl http://[宿主机IP]:11434/api/version
```

### 防火墙设置

确保防火墙允许端口11434的TCP流量。

### WSL2 特殊配置（Windows用户）

如果在WSL2环境中运行，可能需要额外的网络配置。参考[WSL网络指南](https://docs.microsoft.com/windows/wsl/networking)。

## 进阶配置

### 模型参数设置

在Dify控制台中，您可以为Ollama模型设置以下参数：

- 温度(Temperature): 控制输出的随机性
- 最大生成长度(Max Tokens): 限制生成文本的长度
- Top P: 控制输出的多样性
- 频率惩罚(Frequency Penalty): 减少重复内容
- 存在惩罚(Presence Penalty): 鼓励新主题

### 使用多个模型

Ollama支持同时运行多个模型，您可以在Dify中配置不同模型用于不同的应用：

1. 在Ollama中拉取并运行多个模型
2. 在Dify控制台中为每个模型添加单独的配置
3. 为不同应用选择适合的模型

## 故障排除

### 常见错误

1. **连接被拒绝**
   - 检查Ollama服务是否正在运行
   - 验证Docker网络配置是否正确

2. **模型加载失败**
   - 确认模型已正确下载到Ollama
   - 检查模型名称是否正确

3. **API错误500/400**
   - 参考[API错误排查指南](../API-ERRORS.md)
   - 尝试禁用验证功能或提供虚拟API密钥

4. **生成结果为空**
   - 检查模型参数设置
   - 尝试用较简单的提示测试

## 资源与参考

- [Ollama官方文档](https://ollama.ai/docs)
- [Dify官方文档](https://docs.dify.ai/)
- [API错误排查指南](../API-ERRORS.md)
- [本地模型集成完全指南](LOCAL-MODEL-GUIDE.md) 