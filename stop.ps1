# Dify 停止脚本
Write-Host "正在停止 Dify 服务..." -ForegroundColor Yellow

# 停止服务
docker-compose down

Write-Host "Dify 服务已停止" -ForegroundColor Green 