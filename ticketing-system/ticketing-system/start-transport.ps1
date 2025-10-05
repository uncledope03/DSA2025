#!/usr/bin/env pwsh

Write-Host "Starting Transport Service..." -ForegroundColor Green
Write-Host "Changing to transport-service directory..." -ForegroundColor Yellow

Set-Location "C:\ticketing-system\transport-service"

Write-Host "Running Ballerina service..." -ForegroundColor Yellow
try {
    bal run main.bal
} catch {
    Write-Host "Error starting transport service: $_" -ForegroundColor Red
    Write-Host "Please check if:" -ForegroundColor Yellow
    Write-Host "1. Ballerina is installed and in PATH" -ForegroundColor White
    Write-Host "2. MariaDB is running and accessible" -ForegroundColor White
    Write-Host "3. Kafka is running" -ForegroundColor White
    Write-Host "4. All dependencies are available" -ForegroundColor White
}

Write-Host "Transport Service stopped." -ForegroundColor Red
Set-Location "C:\ticketing-system"