#!/usr/bin/env pwsh

Write-Host "=================================================" -ForegroundColor Green
Write-Host "  Windhoek Public Transport Ticketing System   " -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

Write-Host ""
Write-Host "Starting system components..." -ForegroundColor Yellow

# Check if Kafka is running
Write-Host "1. Checking Kafka..." -ForegroundColor Cyan
$kafkaProcess = Get-Process -Name "java" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "java" }

if (-not $kafkaProcess) {
    Write-Host "   Starting Zookeeper..." -ForegroundColor Yellow
    Start-Process -FilePath "C:\ticketing-system\kafka-setup\start_zookeeper.bat" -WindowStyle Minimized
    Start-Sleep -Seconds 5
    
    Write-Host "   Starting Kafka..." -ForegroundColor Yellow
    Start-Process -FilePath "C:\ticketing-system\kafka-setup\start_kafka.bat" -WindowStyle Minimized
    Start-Sleep -Seconds 10
    
    Write-Host "   Creating Kafka topics..." -ForegroundColor Yellow
    Start-Process -FilePath "C:\ticketing-system\kafka-setup\create_topics.bat" -Wait
} else {
    Write-Host "   Kafka is already running" -ForegroundColor Green
}

# Check MariaDB connection
Write-Host "2. Checking MariaDB connection..." -ForegroundColor Cyan
try {
    $testConnection = mysql -u root -e "SELECT 1;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   MariaDB is accessible" -ForegroundColor Green
    } else {
        Write-Host "   MariaDB connection test failed" -ForegroundColor Red
        Write-Host "   Please ensure MariaDB is running and accessible" -ForegroundColor Red
    }
} catch {
    Write-Host "   Could not test MariaDB connection" -ForegroundColor Yellow
    Write-Host "   Please ensure MariaDB is installed and running" -ForegroundColor Yellow
}

# Setup database
Write-Host "3. Setting up database..." -ForegroundColor Cyan
try {
    $schemaContent = Get-Content "C:\ticketing-system\database-setup\ticketing_system.sql" -Raw
    $dataContent = Get-Content "C:\ticketing-system\database-setup\setup_data.sql" -Raw
    
    mysql -u root -e $schemaContent
    mysql -u root -e $dataContent
    Write-Host "   Database setup completed" -ForegroundColor Green
} catch {
    Write-Host "   Database setup failed - continuing anyway" -ForegroundColor Yellow
    Write-Host "   Error: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "System startup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Available Services:" -ForegroundColor Yellow
Write-Host "==================" -ForegroundColor Yellow
Write-Host "1. Passenger Service  - .\start-passenger.ps1" -ForegroundColor White
Write-Host "2. Admin Service      - .\start-admin.ps1" -ForegroundColor White
Write-Host "3. Transport Service  - .\start-transport.ps1" -ForegroundColor White
Write-Host "4. Payment Service    - .\start-payment.ps1" -ForegroundColor White
Write-Host "5. Ticketing Service  - .\start-ticketing.ps1" -ForegroundColor White
Write-Host "6. Notification Service - .\start-notification.ps1" -ForegroundColor White
Write-Host "7. Validator Service  - .\start-validator.ps1" -ForegroundColor White
Write-Host ""
Write-Host "Background Services (automatically started):" -ForegroundColor Yellow
Write-Host "- Ticketing Service (processing)" -ForegroundColor Gray
Write-Host "- Notification Service (listening)" -ForegroundColor Gray
Write-Host ""
Write-Host "Starting background services..." -ForegroundColor Yellow

# Start background services
Write-Host "Starting Ticketing Service..." -ForegroundColor Cyan
Start-Process -FilePath "pwsh" -ArgumentList "-File", "C:\ticketing-system\start-ticketing.ps1" -WindowStyle Minimized

Start-Sleep -Seconds 2

Write-Host "Starting Notification Service..." -ForegroundColor Cyan
Start-Process -FilePath "pwsh" -ArgumentList "-File", "C:\ticketing-system\start-notification.ps1" -WindowStyle Minimized

Write-Host ""
Write-Host "System is ready!" -ForegroundColor Green
Write-Host "Choose a service to start from the list above." -ForegroundColor White
Write-Host ""
Write-Host "Demo Usage:" -ForegroundColor Yellow
Write-Host "1. Start Admin Service first to create routes and trips" -ForegroundColor White
Write-Host "2. Start Passenger Service to register and buy tickets" -ForegroundColor White
Write-Host "3. Start Payment Service to process payments" -ForegroundColor White
Write-Host "4. Start Validator Service to validate tickets" -ForegroundColor White
Write-Host ""