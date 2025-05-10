# Dify 本地模型集成完全指南

本文档提供了在 Dify 平台中使用本地大语言模型的完整指南，不依赖 OpenAI 等远程 API 提供商。这样可以保护数据隐私，减少 API 成本，并能在离线环境下工作。

## 快速配置摘要

1. 安装并启动 [Ollama](https://ollama.ai/download)
2. 确保 Ollama 能被 Docker 访问（防火墙设置、网络配置）
3. 修改 `docker-compose.yml`，添加关键环境变量
4. 重启 Dify 服务
5. 登录 Dify 使用本地模型

## 详细配置步骤

### 1. 安装和配置 Ollama

**安装 Ollama:**
- 从 [Ollama 官网](https://ollama.ai/download) 下载并安装
- 安装后，Ollama 默认在 11434 端口提供服务

**下载所需模型:**
```bash
# 下载模型（根据需要选择）
ollama pull llama3
ollama pull mistral
ollama pull gemma:7b
```

**使 Ollama 可被 Docker 访问:**
```bash
# 设置 Ollama 监听所有网络接口而不仅是 localhost
set OLLAMA_HOST=0.0.0.0:11434

# 重启 Ollama 服务
# 可能需要关闭 Ollama 并重新启动
```

**检查 Ollama 服务状态:**
```bash
# 检查 Ollama 版本
curl http://localhost:11434/api/version

# 查看已安装的模型
curl http://localhost:11434/api/tags
```

### 2. 配置防火墙（管理员权限）

为确保 Docker 容器可以访问宿主机的 Ollama 服务，需要配置防火墙规则：

**通过命令行（需要管理员权限）:**
```bash
# 添加允许 11434 端口的入站规则
netsh advfirewall firewall add rule name="Ollama API" dir=in action=allow protocol=TCP localport=11434
```

**或通过 Windows 防火墙图形界面:**
1. 打开"Windows安全中心"
2. 点击"防火墙和网络保护"
3. 点击"高级设置"
4. 选择"入站规则" > "新建规则"
5. 选择"端口"，点击"下一步"
6. 选择"TCP"和"特定本地端口"，输入"11434"
7. 选择"允许连接"，点击"下一步"
8. 选择适用的网络类型，点击"下一步"
9. 命名为"Ollama API"，完成

### 3. 修改 Dify 配置文件

编辑 `docker-compose.yml` 文件，在 api 服务的 environment 部分添加以下环境变量：

```yaml
api:
  environment:
    # 禁用需要 API Key 的功能，使界面能正常显示
    - DISABLE_PROVIDER_MODEL_VALIDATION=true
    # 插件服务配置
    - PLUGIN_EXECUTOR_PUBLIC_URL=http://localhost:5001
    - DISABLE_PLUGIN=true
    # Ollama配置 - 使用宿主机IP地址
    - OLLAMA_API_BASE_URL=http://192.168.31.250:11434
    # 启用本地模型自动配置
    - AUTO_SETUP_LOCAL_PROVIDER=true
    # 解决本地模型API问题
    - LOCAL_MODEL_API_TYPE=ollama
```

> **重要:** 将 `192.168.31.250` 替换为您的实际 IP 地址，可通过 `ipconfig` 命令查看。

#### 环境变量说明

| 环境变量 | 说明 |
|----------|------|
| DISABLE_PROVIDER_MODEL_VALIDATION | 禁用模型提供商验证，解决登录后 API 500 错误 |
| PLUGIN_EXECUTOR_PUBLIC_URL | 插件服务 URL，需要设置以避免错误 |
| DISABLE_PLUGIN | 禁用插件功能，减少错误 |
| OLLAMA_API_BASE_URL | Ollama API 地址，指向运行 Ollama 的服务器 |
| AUTO_SETUP_LOCAL_PROVIDER | 自动设置本地模型提供商，无需手动配置 |
| LOCAL_MODEL_API_TYPE | 指定本地模型 API 类型为 Ollama |

### 4. 重启 Dify 服务

```bash
# 重启所有服务
docker-compose restart

# 或仅重启 API 服务
docker-compose restart api
```

### 5. 访问 Dify 控制台

1. 浏览器访问: http://localhost
2. 使用默认账户登录:
   - 邮箱: admin@example.com
   - 密码: password
3. 进入"应用"页面，创建新应用
4. 在模型选择页面，应该能看到 Ollama 模型

## 疑难解答

### 1. API 500/400 错误

**症状:**
- 登录后无法加载模型列表
- 控制台报错: 
  ```
  GET http://localhost:5001/console/api/workspaces/current/models/model-types/text-embedding 500
  ```

**解决方案:**
- 确保已设置 `DISABLE_PROVIDER_MODEL_VALIDATION=true`
- 确保已设置 `AUTO_SETUP_LOCAL_PROVIDER=true`
- 确保已设置 `LOCAL_MODEL_API_TYPE=ollama`
- 重启 API 服务: `docker-compose restart api`

### 2. Docker 无法连接到 Ollama

**症状:**
- Dify 控制台未显示 Ollama 模型
- API 日志显示连接 Ollama 的错误

**解决方案:**
1. **检查 Ollama 服务**:
   ```bash
   curl http://localhost:11434/api/version
   ```

2. **设置 Ollama 监听所有网络接口**:
   ```bash
   set OLLAMA_HOST=0.0.0.0:11434
   # 重启 Ollama
   ```

3. **检查防火墙设置**:
   确保 TCP 端口 11434 允许入站连接

4. **尝试不同的 URL 格式**:
   - 直接 IP 地址: `http://192.168.31.250:11434`
   - Docker 特殊主机名: `http://host.docker.internal:11434`
   - 通过 API 日志检查连接问题: `docker-compose logs api | findstr "ollama"`

### 3. 模型未显示在 Dify 中

**症状:**
- Ollama 运行正常，但 Dify 中看不到模型

**解决方案:**
1. 确认 API 连接测试成功
2. 检查 Ollama 中已安装的模型: `curl http://localhost:11434/api/tags`
3. 确保 Dify 配置了正确的环境变量
4. 查看 API 日志: `docker-compose logs api`

## 附录: IP 地址查找

```bash
# Windows
ipconfig

# Linux/macOS
ifconfig
ip addr
```

## 优势和注意事项

### 使用本地模型的优势

1. **数据隐私**：所有处理都在本地完成，数据不会发送到第三方服务器
2. **成本控制**：无需支付API使用费
3. **离线使用**：不依赖互联网连接
4. **定制灵活**：可以使用自定义的微调模型

### 注意事项

1. **硬件要求**：运行大型语言模型需要足够的 GPU/CPU 资源
2. **性能限制**：本地模型的性能可能不如云端服务
3. **模型大小**：需要足够的硬盘空间存储模型（如 llama3:70b 约 40GB）

## 相关链接

- [Ollama 官方文档](https://ollama.ai/docs)
- [Dify 官方文档](https://docs.dify.ai/)
- [Dify GitHub 项目](https://github.com/langgenius/dify) 