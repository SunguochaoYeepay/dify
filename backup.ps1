# Dify 备份脚本
Write-Host "Dify 数据备份工具" -ForegroundColor Cyan

# 获取当前日期时间作为备份名称后缀
$dateStr = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = "backups/backup_$dateStr"

# 创建备份目录
if (-not (Test-Path -Path "backups")) {
    New-Item -Path "backups" -ItemType Directory | Out-Null
}
New-Item -Path $backupDir -ItemType Directory | Out-Null

Write-Host "`n备份选项:" -ForegroundColor Green
Write-Host "1. 仅备份数据库"
Write-Host "2. 备份所有数据 (数据库 + 文件存储)"
Write-Host "3. 退出"

$choice = Read-Host "`n请输入选项 (1-3)"

switch ($choice) {
    "1" { 
        Write-Host "`n开始备份数据库..." -ForegroundColor Yellow
        
        # 检查 PostgreSQL 工具是否可用
        $pgDumpAvailable = $false
        try {
            $pgDumpCheck = docker-compose exec db which pg_dump
            if ($pgDumpCheck) {
                $pgDumpAvailable = $true
            }
        } catch {
            # 忽略错误
        }
        
        if ($pgDumpAvailable) {
            # 使用容器内的 pg_dump
            $dbBackupFile = "$backupDir/dify_db_$dateStr.sql"
            Write-Host "正在备份数据库到 $dbBackupFile" -ForegroundColor Yellow
            docker-compose exec -T db pg_dump -U postgres -d dify > $dbBackupFile
            
            if (Test-Path -Path $dbBackupFile -and (Get-Item $dbBackupFile).Length -gt 0) {
                Write-Host "数据库备份成功！" -ForegroundColor Green
            } else {
                Write-Host "数据库备份失败或文件为空" -ForegroundColor Red
            }
        } else {
            # 备份方式 2: 复制数据目录
            Write-Host "pg_dump 不可用，将直接复制数据目录..." -ForegroundColor Yellow
            
            # 检查服务是否在运行
            $isRunning = docker-compose ps --services --filter "status=running" | Select-String -Pattern "db"
            if ($isRunning) {
                Write-Host "警告: 为确保数据一致性，建议先停止服务再备份" -ForegroundColor Red
                $confirm = Read-Host "是否继续备份? (y/n)"
                if ($confirm -ne "y" -and $confirm -ne "Y") {
                    Write-Host "备份已取消" -ForegroundColor Yellow
                    exit
                }
            }
            
            # 复制数据库目录
            Write-Host "正在复制数据库文件..." -ForegroundColor Yellow
            New-Item -Path "$backupDir/db" -ItemType Directory | Out-Null
            Copy-Item -Path "volumes/db/*" -Destination "$backupDir/db" -Recurse
            
            Write-Host "数据库文件备份完成" -ForegroundColor Green
        }
    }
    "2" { 
        Write-Host "`n开始全量备份..." -ForegroundColor Yellow
        
        # 检查服务是否在运行
        $isRunning = docker-compose ps --services --filter "status=running"
        if ($isRunning) {
            Write-Host "警告: 为确保数据一致性，建议先停止服务再备份" -ForegroundColor Red
            $confirm = Read-Host "是否停止服务后继续? (y/n)"
            if ($confirm -eq "y" -or $confirm -eq "Y") {
                Write-Host "停止服务..." -ForegroundColor Yellow
                docker-compose down
                $shouldRestart = $true
            } else {
                Write-Host "继续备份，但可能存在数据不一致风险" -ForegroundColor Yellow
                $shouldRestart = $false
            }
        } else {
            $shouldRestart = $false
        }
        
        # 备份所有数据目录
        Write-Host "正在复制所有数据文件..." -ForegroundColor Yellow
        
        # 数据库
        New-Item -Path "$backupDir/db" -ItemType Directory | Out-Null
        if (Test-Path -Path "volumes/db") {
            Copy-Item -Path "volumes/db/*" -Destination "$backupDir/db" -Recurse
        }
        
        # API 存储
        New-Item -Path "$backupDir/api" -ItemType Directory | Out-Null
        if (Test-Path -Path "volumes/api") {
            Copy-Item -Path "volumes/api/*" -Destination "$backupDir/api" -Recurse
        }
        
        # Redis 数据
        New-Item -Path "$backupDir/redis" -ItemType Directory | Out-Null
        if (Test-Path -Path "volumes/redis") {
            Copy-Item -Path "volumes/redis/*" -Destination "$backupDir/redis" -Recurse
        }
        
        # 备份配置文件
        Copy-Item -Path "docker-compose.yml" -Destination "$backupDir/docker-compose.yml"
        
        Write-Host "全量备份完成！" -ForegroundColor Green
        
        # 如果之前停止了服务，询问是否重新启动
        if ($shouldRestart) {
            $restart = Read-Host "是否重新启动服务? (y/n)"
            if ($restart -eq "y" -or $restart -eq "Y") {
                Write-Host "重新启动服务..." -ForegroundColor Yellow
                ./start.ps1
            }
        }
    }
    "3" { 
        Write-Host "备份操作已取消" -ForegroundColor Yellow
        exit
    }
    default { 
        Write-Host "无效选项，操作已取消" -ForegroundColor Red
        exit
    }
}

# 压缩备份文件
Write-Host "`n正在压缩备份文件..." -ForegroundColor Yellow
Compress-Archive -Path $backupDir -DestinationPath "$backupDir.zip"

# 删除临时目录
Remove-Item -Recurse -Force $backupDir

Write-Host "`n备份完成！" -ForegroundColor Green
Write-Host "备份文件保存在: $backupDir.zip" -ForegroundColor Cyan
Write-Host "提示: 请将备份文件复制到安全位置" -ForegroundColor Yellow 