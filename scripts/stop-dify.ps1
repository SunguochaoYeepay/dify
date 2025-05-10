# Dify shutdown script
Write-Host "Stopping Dify services..." -ForegroundColor Yellow

# Determine script and project root directory
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$projectRoot = (Get-Item $scriptDir).Parent.FullName

# Change to project root directory
Set-Location $projectRoot
Write-Host "Working directory: $projectRoot" -ForegroundColor Yellow

# Stop services
docker-compose down

Write-Host "Dify services stopped" -ForegroundColor Green 