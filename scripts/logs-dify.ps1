# Dify logs script
Write-Host "Viewing Dify logs..." -ForegroundColor Magenta

# Determine script and project root directory
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path -Parent $scriptPath
$projectRoot = (Get-Item $scriptDir).Parent.FullName

# Change to project root directory
Set-Location $projectRoot
Write-Host "Working directory: $projectRoot" -ForegroundColor Yellow

# Function to show general logs
function Show-Logs {
    param (
        [string]$Service = "",
        [switch]$FollowMode = $true,
        [switch]$Tail = $true,
        [int]$Lines = 100
    )
    
    $logCommand = "docker-compose logs"
    
    if ($Tail) {
        $logCommand += " --tail=$Lines"
    }
    
    if ($FollowMode) {
        $logCommand += " -f"
    }
    
    if ($Service) {
        $logCommand += " $Service"
    }
    
    Invoke-Expression $logCommand
}

# Function to show database-related errors
function Show-DBErrors {
    Write-Host "Filtering logs for database-related errors..." -ForegroundColor Yellow
    docker-compose logs | Select-String -Pattern "Error|exception|migration|database|relation|dify_setups" -CaseSensitive:$false | ForEach-Object {
        if ($_ -match "Error|exception|failed") {
            Write-Host $_ -ForegroundColor Red
        } else {
            Write-Host $_ -ForegroundColor Yellow
        }
    }
}

# Parse command line arguments
if ($args.Count -gt 0) {
    $firstArg = $args[0].ToLower()
    
    if ($firstArg -eq "dberrors") {
        # Show database errors
        Show-DBErrors
    } else {
        # Regular service logs
        Show-Logs -Service $firstArg
    }
} else {
    # No arguments, show all logs
    Show-Logs
}

Write-Host "Tip: Use 'logs.ps1 [service]' to view logs for a specific service (api, web, db, redis)" -ForegroundColor Cyan
Write-Host "Tip: Use 'logs.ps1 dberrors' to filter for database-related errors" -ForegroundColor Cyan 