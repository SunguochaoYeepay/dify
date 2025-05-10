# Dify status script
Write-Host "Checking Dify services status..." -ForegroundColor Cyan

# Determine script and project root directory
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$projectRoot = (Get-Item $scriptDir).Parent.FullName

# Change to project root directory
Set-Location $projectRoot
Write-Host "Working directory: $projectRoot" -ForegroundColor Yellow

# Check services status
docker-compose ps

# Check if services are running
$containers = docker-compose ps --services --filter "status=running"
if ($containers -match "api" -and $containers -match "web") {
    Write-Host "`nDify is running!" -ForegroundColor Green
    Write-Host "Access URL: http://localhost" -ForegroundColor Cyan
} else {
    Write-Host "`nDify is not running." -ForegroundColor Red
    Write-Host "You can start it with: ./scripts/start-dify.ps1" -ForegroundColor Yellow
}

# Function to check if a port is in use
function Test-PortInUse {
    param(
        [int]$Port
    )
    
    $result = $null
    try {
        $result = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    } catch {
        return $false
    }
    
    return ($result -ne $null)
}

# Check ports
Write-Host "`nPort status:" -ForegroundColor Cyan
if (Test-PortInUse -Port 80) {
    Write-Host "Port 80 (Web): In use" -ForegroundColor Green
} else {
    Write-Host "Port 80 (Web): Not in use" -ForegroundColor Red
}

if (Test-PortInUse -Port 5001) {
    Write-Host "Port 5001 (API): In use" -ForegroundColor Green
} else {
    Write-Host "Port 5001 (API): Not in use" -ForegroundColor Red
}

if (Test-PortInUse -Port 5432) {
    Write-Host "Port 5432 (PostgreSQL): In use" -ForegroundColor Green
} else {
    Write-Host "Port 5432 (PostgreSQL): Not in use" -ForegroundColor Red
}

if (Test-PortInUse -Port 6379) {
    Write-Host "Port 6379 (Redis): In use" -ForegroundColor Green
} else {
    Write-Host "Port 6379 (Redis): Not in use" -ForegroundColor Red
}

Write-Host "`nFor detailed logs, run: docker-compose logs -f" -ForegroundColor Yellow 