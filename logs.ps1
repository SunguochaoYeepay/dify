# Dify 日志查看脚本

# 定义服务颜色
$colors = @{
    "api" = "Cyan"
    "web" = "Green"
    "db" = "Magenta"
    "redis" = "Yellow"
}

# 解析参数
$service = $null
$dberrors = $false
$lines = 100

if ($args.Count -gt 0) {
    if ($args[0] -eq "dberrors") {
        $dberrors = $true
    } else {
        $service = $args[0]
    }
}

# 显示标题
if ($dberrors) {
    Write-Host "查看数据库相关错误..." -ForegroundColor Red
} elseif ($service) {
    $color = if ($colors.ContainsKey($service)) { $colors[$service] } else { "White" }
    Write-Host "查看 $service 服务日志..." -ForegroundColor $color
} else {
    Write-Host "查看所有服务日志..." -ForegroundColor Cyan
}

# 执行日志查看命令
if ($dberrors) {
    docker-compose logs | Select-String -Pattern "Error|exception|migration|database|relation|dify_setups" -CaseSensitive:$false | ForEach-Object {
        if ($_ -match "Error|exception|failed") {
            Write-Host $_ -ForegroundColor Red
        } else {
            Write-Host $_ -ForegroundColor Yellow
        }
    }
} elseif ($service) {
    docker-compose logs --tail=$lines -f $service
} else {
    docker-compose logs --tail=$lines -f
}

# 显示提示
Write-Host "`n提示:" -ForegroundColor Cyan
Write-Host "- 使用 Ctrl+C 退出日志查看" -ForegroundColor Yellow
Write-Host "- 使用 logs.ps1 [服务名] 查看特定服务日志 (api, web, db, redis)" -ForegroundColor Yellow
Write-Host "- 使用 logs.ps1 dberrors 过滤数据库相关错误" -ForegroundColor Yellow 