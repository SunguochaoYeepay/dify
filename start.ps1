# Dify 启动脚本
Write-Host "正在启动 Dify 服务..." -ForegroundColor Green

# 确保卷目录存在
if (-not (Test-Path -Path "volumes/api/storage")) {
    New-Item -Force -Path "volumes/api/storage" -ItemType Directory | Out-Null
}
if (-not (Test-Path -Path "volumes/db")) {
    New-Item -Force -Path "volumes/db" -ItemType Directory | Out-Null
}
if (-not (Test-Path -Path "volumes/redis")) {
    New-Item -Force -Path "volumes/redis" -ItemType Directory | Out-Null
}

# 启动服务
docker-compose up -d

# 检查数据库是否需要迁移
$dbExists = Test-Path -Path "volumes/db/PG_VERSION"
if (-not $dbExists) {
    Write-Host "首次启动，等待数据库初始化..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    Write-Host "执行数据库迁移..." -ForegroundColor Cyan
    docker-compose exec api flask db upgrade
}

# 显示状态
docker-compose ps

Write-Host "`nDify 服务已启动！" -ForegroundColor Green
Write-Host "访问地址: http://localhost" -ForegroundColor Cyan
Write-Host "默认账户: admin@example.com" -ForegroundColor Cyan
Write-Host "默认密码: password" -ForegroundColor Cyan
Write-Host "`n提示: 首次登录后请立即修改默认密码" -ForegroundColor Yellow 