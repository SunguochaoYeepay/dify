# Dify startup script
Write-Host "Starting Dify services..." -ForegroundColor Green

# Determine script and project root directory
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$projectRoot = (Get-Item $scriptDir).Parent.FullName

# Change to project root directory
Set-Location $projectRoot
Write-Host "Working directory: $projectRoot" -ForegroundColor Yellow

# Ensure volume directories exist
if (-not (Test-Path -Path "volumes/api/storage")) {
    Write-Host "Creating storage directories..." -ForegroundColor Yellow
    New-Item -Force -Path "volumes/api/storage" -ItemType Directory | Out-Null
}
if (-not (Test-Path -Path "volumes/db")) {
    New-Item -Force -Path "volumes/db" -ItemType Directory | Out-Null
}
if (-not (Test-Path -Path "volumes/redis")) {
    New-Item -Force -Path "volumes/redis" -ItemType Directory | Out-Null
}

# Check Docker status
try {
    docker info | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Docker is not running, please start Docker Desktop" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Docker is not installed or not accessible" -ForegroundColor Red
    exit 1
}

# Apply Docker config for mirrors if needed
if (Test-Path -Path "$scriptDir/docker-config.json") {
    Write-Host "Applying Docker mirror configuration..." -ForegroundColor Cyan
    Copy-Item -Force "$scriptDir/docker-config.json" "$env:USERPROFILE/.docker/config.json"
}

# Check if restarting or first startup
$dbExists = Test-Path -Path "volumes/db/PG_VERSION"
if (-not $dbExists) {
    Write-Host "First time startup detected. Database will be initialized..." -ForegroundColor Yellow
    Write-Host "Note: Database migration is enabled via MIGRATION_ENABLED=true in docker-compose.yml" -ForegroundColor Cyan
}

# Pull images
Write-Host "Pulling Dify images..." -ForegroundColor Cyan
docker-compose pull

# Start services
Write-Host "Starting Dify services..." -ForegroundColor Green
docker-compose up -d

# Check service status
Write-Host "Waiting for services to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 5
docker-compose ps

Write-Host "Dify services started!" -ForegroundColor Green
Write-Host "Access URL: http://localhost" -ForegroundColor Cyan
Write-Host "Initial account: admin@example.com" -ForegroundColor Cyan
Write-Host "Initial password: password" -ForegroundColor Cyan

# Database initialization note
if (-not $dbExists) {
    Write-Host "`nImportant: First startup may take extra time for database initialization." -ForegroundColor Yellow
    Write-Host "If you encounter database errors, please see docs/DATABASE.md for troubleshooting." -ForegroundColor Yellow
} 