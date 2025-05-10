# Dify 状态检查脚本
Write-Host "Dify 服务状态：" -ForegroundColor Cyan

# 获取容器状态
docker-compose ps

# 检查关键端口
Write-Host "`n端口状态：" -ForegroundColor Cyan
$ports = @(80, 5001, 5432, 6379)
foreach ($port in $ports) {
    try {
        $result = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
        if ($result) {
            $service = switch ($port) {
                80 { "Web 服务" }
                5001 { "API 服务" }
                5432 { "数据库服务" }
                6379 { "Redis 服务" }
                default { "未知服务" }
            }
            Write-Host "✓ 端口 $port ($service) 正在运行" -ForegroundColor Green
        } else {
            Write-Host "✗ 端口 $port 未在运行" -ForegroundColor Red
        }
    } catch {
        Write-Host "✗ 端口 $port 检查失败" -ForegroundColor Red
    }
}

Write-Host "`n提示: 使用 ./logs.ps1 查看详细日志" -ForegroundColor Yellow 