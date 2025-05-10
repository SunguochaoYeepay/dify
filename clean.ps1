# Dify 清理脚本
Write-Host "Dify 清理工具" -ForegroundColor Cyan
Write-Host "该脚本将帮助清理无用的 Docker 资源和临时文件" -ForegroundColor Yellow

# 解析参数
$all = $false
if ($args.Count -gt 0 -and $args[0] -eq "all") {
    $all = $true
}

# 显示选项
if (-not $all) {
    Write-Host "`n选择清理选项:" -ForegroundColor Green
    Write-Host "1. 清理未使用的 Docker 镜像"
    Write-Host "2. 清理 Docker 缓存"
    Write-Host "3. 清理未使用的 Docker 卷"
    Write-Host "4. 全部清理"
    Write-Host "5. 退出"
    
    $choice = Read-Host "`n请输入选项 (1-5)"
    
    switch ($choice) {
        "1" { 
            Write-Host "`n清理未使用的 Docker 镜像..." -ForegroundColor Yellow
            docker image prune -f
        }
        "2" { 
            Write-Host "`n清理 Docker 缓存..." -ForegroundColor Yellow
            docker builder prune -f
        }
        "3" { 
            Write-Host "`n清理未使用的 Docker 卷..." -ForegroundColor Yellow
            docker volume prune -f
        }
        "4" { 
            $all = $true
        }
        "5" { 
            Write-Host "已取消操作" -ForegroundColor Yellow
            exit
        }
        default { 
            Write-Host "无效选项，已取消操作" -ForegroundColor Red
            exit
        }
    }
}

# 执行全面清理
if ($all) {
    # 先停止服务
    Write-Host "`n停止所有 Dify 服务..." -ForegroundColor Yellow
    docker-compose down
    
    # 清理 Docker 资源
    Write-Host "`n清理所有未使用的 Docker 资源..." -ForegroundColor Yellow
    docker system prune -f
    
    # 清理临时文件
    Write-Host "`n清理临时文件..." -ForegroundColor Yellow
    if (Test-Path -Path "temp") {
        Remove-Item -Recurse -Force "temp" | Out-Null
    }
    
    Write-Host "`n清理完成！" -ForegroundColor Green
    
    # 提示重新启动
    $restart = Read-Host "是否立即重新启动 Dify 服务？(y/n)"
    if ($restart -eq "y" -or $restart -eq "Y") {
        Write-Host "`n重新启动 Dify 服务..." -ForegroundColor Cyan
        ./start.ps1
    } else {
        Write-Host "`n清理完成。您可以使用 ./start.ps1 随时启动服务。" -ForegroundColor Cyan
    }
} else {
    Write-Host "`n部分清理完成。使用 ./clean.ps1 all 执行全面清理。" -ForegroundColor Green
} 