# Dify 重启脚本
Write-Host "正在重启 Dify 服务..." -ForegroundColor Cyan

# 解析参数
$service = $null
if ($args.Count -gt 0) {
    $service = $args[0]
}

# 执行重启
if ($service) {
    # 重启特定服务
    Write-Host "重启 $service 服务..." -ForegroundColor Yellow
    docker-compose restart $service
} else {
    # 重启所有服务
    Write-Host "重启所有服务..." -ForegroundColor Yellow
    docker-compose restart
}

# 显示状态
Write-Host "`n服务状态：" -ForegroundColor Cyan
docker-compose ps

Write-Host "`nDify 服务已重启" -ForegroundColor Green
Write-Host "提示: 使用 ./status.ps1 查看完整状态" -ForegroundColor Yellow 