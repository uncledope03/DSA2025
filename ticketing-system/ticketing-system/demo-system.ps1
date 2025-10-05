#!/usr/bin/env pwsh

Write-Host "=================================================" -ForegroundColor Green
Write-Host "  Windhoek Public Transport System - DEMO      " -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host ""

Write-Host "🏗️  SYSTEM ARCHITECTURE OVERVIEW" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Microservices:" -ForegroundColor Cyan
Write-Host "├─ Passenger Service (Port 8081)  - User registration, ticket booking" -ForegroundColor White
Write-Host "├─ Admin Service (Port 8084)      - Route/trip management, reporting" -ForegroundColor White
Write-Host "├─ Transport Service (Port 8086)  - Route creation, service updates" -ForegroundColor White
Write-Host "├─ Payment Service (Port 8083)    - Payment processing" -ForegroundColor White
Write-Host "├─ Ticketing Service (Port 8082)  - Ticket lifecycle (background)" -ForegroundColor White
Write-Host "├─ Notification Service (Port 8085) - Event notifications (background)" -ForegroundColor White
Write-Host "└─ Validator Service (Port 8087)  - Ticket validation on vehicles" -ForegroundColor White
Write-Host ""

Write-Host "Event-Driven Communication (Kafka Topics):" -ForegroundColor Cyan
Write-Host "├─ ticket.requests      - Ticket purchase requests" -ForegroundColor White
Write-Host "├─ payments.processed   - Payment confirmations" -ForegroundColor White
Write-Host "├─ schedule.updates     - Route/trip updates" -ForegroundColor White
Write-Host "├─ notifications        - General notifications" -ForegroundColor White
Write-Host "└─ ticket.validations   - Ticket validation events" -ForegroundColor White
Write-Host ""

Write-Host "Database (MariaDB):" -ForegroundColor Cyan
Write-Host "├─ users         - User accounts (passengers, admins, validators)" -ForegroundColor White
Write-Host "├─ routes        - Transport routes (bus/train lines)" -ForegroundColor White
Write-Host "├─ trips         - Specific trip instances with schedules" -ForegroundColor White
Write-Host "├─ tickets       - Ticket records with status tracking" -ForegroundColor White
Write-Host "├─ payments      - Payment transactions" -ForegroundColor White
Write-Host "└─ notifications - System notifications" -ForegroundColor White
Write-Host ""

Write-Host "🎯 DISTRIBUTED SYSTEMS FEATURES DEMONSTRATED" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "✅ Microservices Architecture" -ForegroundColor Green
Write-Host "   - Clear service boundaries and responsibilities" -ForegroundColor Gray
Write-Host "   - Independent deployability" -ForegroundColor Gray
Write-Host "   - Service-specific data management" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ Event-Driven Communication" -ForegroundColor Green
Write-Host "   - Asynchronous message passing via Kafka" -ForegroundColor Gray
Write-Host "   - Loose coupling between services" -ForegroundColor Gray
Write-Host "   - Event sourcing for audit trails" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ Data Persistence & Consistency" -ForegroundColor Green
Write-Host "   - ACID transactions within services" -ForegroundColor Gray
Write-Host "   - Eventual consistency across services" -ForegroundColor Gray
Write-Host "   - Proper database schema design" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ Fault Tolerance & Monitoring" -ForegroundColor Green
Write-Host "   - Error handling and graceful degradation" -ForegroundColor Gray
Write-Host "   - Service health checks" -ForegroundColor Gray
Write-Host "   - Real-time monitoring via console output" -ForegroundColor Gray
Write-Host ""

Write-Host "🚀 TYPICAL USER WORKFLOW SIMULATION" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Yellow

function Show-PassengerWorkflow {
    Write-Host ""
    Write-Host "👤 PASSENGER EXPERIENCE:" -ForegroundColor Cyan
    Write-Host "1. Register Account" -ForegroundColor White
    Write-Host "   └─ User: john_doe, Email: john@example.com" -ForegroundColor Gray
    Write-Host "   └─ Initial Balance: 100.00 NAD" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Browse Available Trips" -ForegroundColor White
    Write-Host "   ├─ B01 - City Center to Katutura (15.00 NAD)" -ForegroundColor Gray
    Write-Host "   ├─ T01 - Central Station to Airport (95.00 NAD)" -ForegroundColor Gray
    Write-Host "   └─ B02 - Wanaheda to Klein Windhoek (12.00 NAD)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Purchase Ticket" -ForegroundColor White
    Write-Host "   └─ Selected: B01 - City Center to Katutura" -ForegroundColor Gray
    Write-Host "   └─ Kafka Event: ticket.requests → Ticketing Service" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "4. View Personal Tickets" -ForegroundColor White
    Write-Host "   └─ Status: CREATED (waiting for payment)" -ForegroundColor Orange
}

function Show-PaymentWorkflow {
    Write-Host ""
    Write-Host "💳 PAYMENT PROCESSING:" -ForegroundColor Cyan
    Write-Host "1. Payment Service Detects Pending Ticket" -ForegroundColor White
    Write-Host "   └─ Ticket ID: 550e8400-e29b-41d4-a716-446655440000" -ForegroundColor Gray
    Write-Host "   └─ Amount: 15.00 NAD" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Process Payment" -ForegroundColor White
    Write-Host "   ├─ Check User Balance: 100.00 NAD ✅" -ForegroundColor Gray
    Write-Host "   ├─ Deduct Amount: 100.00 - 15.00 = 85.00 NAD" -ForegroundColor Gray
    Write-Host "   └─ Payment Status: COMPLETED" -ForegroundColor Green
    Write-Host ""
    Write-Host "3. Send Confirmation" -ForegroundColor White
    Write-Host "   └─ Kafka Event: payments.processed → Ticketing Service" -ForegroundColor Yellow
    Write-Host "   └─ Ticket Status Updated: CREATED → PAID" -ForegroundColor Green
}

function Show-ValidationWorkflow {
    Write-Host ""
    Write-Host "🚌 TICKET VALIDATION:" -ForegroundColor Cyan
    Write-Host "1. Passenger Boards Vehicle" -ForegroundColor White
    Write-Host "   └─ Vehicle: B01 - Route to Katutura" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Validator Scans Ticket" -ForegroundColor White
    Write-Host "   ├─ Ticket ID: 550e8400-e29b-41d4-a716-446655440000" -ForegroundColor Gray
    Write-Host "   ├─ Current Status: PAID ✅" -ForegroundColor Gray
    Write-Host "   └─ Passenger: john_doe" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Validation Success" -ForegroundColor White
    Write-Host "   ├─ Status Updated: PAID → VALIDATED ✅" -ForegroundColor Green
    Write-Host "   ├─ Welcome Message: 'Welcome aboard, john_doe!'" -ForegroundColor Green
    Write-Host "   └─ Kafka Event: ticket.validations → Notification Service" -ForegroundColor Yellow
}

function Show-AdminWorkflow {
    Write-Host ""
    Write-Host "👨‍💼 ADMIN OPERATIONS:" -ForegroundColor Cyan
    Write-Host "1. Route Management" -ForegroundColor White
    Write-Host "   ├─ Create Route: B03 - University Line" -ForegroundColor Gray
    Write-Host "   ├─ Set Fare: 8.00 NAD" -ForegroundColor Gray
    Write-Host "   └─ Kafka Event: schedule.updates (New Route Available)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "2. Trip Scheduling" -ForegroundColor White
    Write-Host "   ├─ Create Trip: Departure 14:00, Arrival 14:30" -ForegroundColor Gray
    Write-Host "   ├─ Available Seats: 45" -ForegroundColor Gray
    Write-Host "   └─ Status: SCHEDULED" -ForegroundColor Green
    Write-Host ""
    Write-Host "3. System Reports" -ForegroundColor White
    Write-Host "   ├─ Total Tickets Sold: 1,247" -ForegroundColor Gray
    Write-Host "   ├─ Total Revenue: 18,645.50 NAD" -ForegroundColor Gray
    Write-Host "   └─ Most Popular Route: B01 (423 tickets)" -ForegroundColor Gray
}

# Run the simulation
Show-PassengerWorkflow
Show-PaymentWorkflow
Show-ValidationWorkflow
Show-AdminWorkflow

Write-Host ""
Write-Host "🔄 EVENT FLOW DEMONSTRATION" -ForegroundColor Yellow
Write-Host "============================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Event Chain Example:" -ForegroundColor Cyan
Write-Host "Passenger Service → [ticket.requests] → Ticketing Service" -ForegroundColor White
Write-Host "                                     ↓" -ForegroundColor White
Write-Host "Payment Service → [payments.processed] → Ticketing Service" -ForegroundColor White
Write-Host "                                     ↓" -ForegroundColor White  
Write-Host "Validator Service → [ticket.validations] → Notification Service" -ForegroundColor White
Write-Host "                                     ↓" -ForegroundColor White
Write-Host "                            User Notifications" -ForegroundColor Green
Write-Host ""

Write-Host "🎮 INTERACTIVE FEATURES" -ForegroundColor Yellow
Write-Host "========================" -ForegroundColor Yellow
Write-Host "✅ Menu-driven interfaces for all services" -ForegroundColor Green
Write-Host "✅ Real-time status updates and feedback" -ForegroundColor Green
Write-Host "✅ Error handling with user-friendly messages" -ForegroundColor Green
Write-Host "✅ Multi-service communication via events" -ForegroundColor Green
Write-Host "✅ Complete ticket lifecycle tracking" -ForegroundColor Green
Write-Host "✅ Emergency override capabilities" -ForegroundColor Green
Write-Host "✅ Comprehensive reporting and monitoring" -ForegroundColor Green
Write-Host ""

Write-Host "📊 SYSTEM STATUS" -ForegroundColor Yellow
Write-Host "=================" -ForegroundColor Yellow

# Check if Kafka is running
$kafkaProcess = Get-Process -Name "java" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*kafka*" -or $_.CommandLine -like "*zookeeper*" }
if ($kafkaProcess) {
    Write-Host "✅ Kafka & Zookeeper: RUNNING" -ForegroundColor Green
} else {
    Write-Host "❌ Kafka & Zookeeper: NOT DETECTED" -ForegroundColor Red
    Write-Host "   Run: .\kafka-setup\start_zookeeper.bat && .\kafka-setup\start_kafka.bat" -ForegroundColor Gray
}

# Check Ballerina
try {
    $balVersion = bal version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Ballerina: AVAILABLE" -ForegroundColor Green
        Write-Host "   Version: $(($balVersion | Select-String 'Ballerina').ToString().Trim())" -ForegroundColor Gray
    } else {
        Write-Host "❌ Ballerina: NOT AVAILABLE" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Ballerina: NOT AVAILABLE" -ForegroundColor Red
}

# Check MariaDB/MySQL
try {
    mysql --version 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ MariaDB/MySQL: AVAILABLE" -ForegroundColor Green
    } else {
        Write-Host "❌ MariaDB/MySQL: NOT AVAILABLE" -ForegroundColor Orange
        Write-Host "   System can run with simulated data for demonstration" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ MariaDB/MySQL: NOT AVAILABLE" -ForegroundColor Orange
    Write-Host "   System can run with simulated data for demonstration" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🚀 TO START THE ACTUAL SERVICES:" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow
Write-Host "1. Ensure MariaDB is installed and running" -ForegroundColor White
Write-Host "2. Run individual service scripts:" -ForegroundColor White
Write-Host "   .\start-admin.ps1      # Route and trip management" -ForegroundColor Gray
Write-Host "   .\start-passenger.ps1  # User interface" -ForegroundColor Gray
Write-Host "   .\start-payment.ps1    # Payment processing" -ForegroundColor Gray
Write-Host "   .\start-validator.ps1  # Ticket validation" -ForegroundColor Gray
Write-Host ""
Write-Host "📚 For complete documentation, see README.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "System demonstration complete! ✨" -ForegroundColor Green