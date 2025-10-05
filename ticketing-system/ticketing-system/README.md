# Windhoek Public Transport Ticketing System

A distributed smart ticketing system for buses and trains built with Ballerina, Kafka, and MariaDB.

## 🏗️ Architecture

This system implements a microservices architecture with event-driven communication:

### Services
- **Passenger Service** (Port 8081): User registration, login, ticket management
- **Admin Service** (Port 8084): Route/trip management, reporting
- **Transport Service** (Port 8086): Route creation, trip scheduling, service updates
- **Ticketing Service** (Port 8082): Ticket lifecycle management (background)
- **Payment Service** (Port 8083): Payment processing
- **Notification Service** (Port 8085): Event-driven notifications (background)
- **Validator Service** (Port 8087): Ticket validation on vehicles

### Technology Stack
- **Language**: Ballerina 2201.12.9
- **Message Broker**: Apache Kafka 3.9.0
- **Database**: MariaDB 10.4.32
- **Platform**: Windows with PowerShell

## 🚀 Quick Start

### Prerequisites
1. **Ballerina**: Install from https://ballerina.io/downloads/
2. **MariaDB**: Install and start the service
3. **Apache Kafka**: Already configured at `C:\kafka_2.13-3.9.0`
4. **PowerShell**: Available on Windows

### Installation & Setup

1. **Start the System Infrastructure**:
   ```powershell
   .\start-system.ps1
   ```
   This will:
   - Start Zookeeper and Kafka (if not running)
   - Create Kafka topics
   - Set up the database schema
   - Start background services

2. **Start Individual Services** (in separate terminal windows):
   ```powershell
   # Admin first (to set up routes and trips)
   .\start-admin.ps1
   
   # Passenger service (for user registration and ticket booking)
   .\start-passenger.ps1
   
   # Payment service (to process payments)
   .\start-payment.ps1
   
   # Validator service (for ticket validation)
   .\start-validator.ps1
   
   # Transport service (for route management)
   .\start-transport.ps1
   ```

## 📋 Database Schema

The system uses the following main tables:
- `users` - User accounts (passengers, admins, validators)
- `routes` - Transport routes (bus/train lines)
- `trips` - Specific trip instances with schedules
- `tickets` - Ticket records with status tracking
- `payments` - Payment transactions
- `notifications` - System notifications

## 🎯 Demo Workflow

### 1. Admin Setup
```
1. Start Admin Service: .\start-admin.ps1
2. Login as admin (username: "admin")
3. Create routes and trips for demonstration
```

### 2. Passenger Experience
```
1. Start Passenger Service: .\start-passenger.ps1
2. Register new user account
3. Login with created credentials
4. Browse available trips
5. Purchase ticket (creates ticket request)
```

### 3. Payment Processing
```
1. Start Payment Service: .\start-payment.ps1
2. Process pending payments
3. Select ticket to pay for
4. Payment confirmation sent via Kafka
```

### 4. Ticket Validation
```
1. Start Validator Service: .\start-validator.ps1
2. Enter ticket ID to validate
3. System confirms ticket status and validates
```

## 🔄 Event-Driven Architecture

### Kafka Topics
- `ticket.requests` - New ticket purchase requests
- `payments.processed` - Payment confirmations
- `schedule.updates` - Route/trip updates and notifications
- `notifications` - General system notifications
- `ticket.validations` - Ticket validation events

### Event Flow
1. **Ticket Purchase**: Passenger → `ticket.requests` → Ticketing Service
2. **Payment**: Payment Service → `payments.processed` → Ticketing Service
3. **Notifications**: Various services → `schedule.updates` → Notification Service
4. **Validation**: Validator → `ticket.validations` → Notification Service

## 🛠️ Service Details

### Passenger Service Features
- ✅ User registration and login
- ✅ View available trips
- ✅ Purchase tickets (via Kafka events)
- ✅ View personal tickets
- ✅ View notifications

### Admin Service Features
- ✅ Route management (create, view)
- ✅ Trip management (create, view)
- ✅ Sales reporting
- ✅ Service disruption announcements

### Transport Service Features
- ✅ Comprehensive route management
- ✅ Trip scheduling and status updates
- ✅ Service update broadcasting
- ✅ Emergency alerts

### Payment Service Features
- ✅ Interactive payment processing
- ✅ Balance management
- ✅ Payment history
- ✅ Kafka event publishing

### Ticketing Service Features
- ✅ Background ticket processing
- ✅ Ticket status management
- ✅ Event-driven workflow

### Notification Service Features
- ✅ Background event listening
- ✅ Multi-user notifications
- ✅ Database persistence

### Validator Service Features
- ✅ Ticket validation with status checks
- ✅ Vehicle login mode
- ✅ Validation history
- ✅ Emergency override functionality

## 🎮 Interactive Features

All services provide interactive command-line interfaces with:
- Menu-driven navigation
- Real-time data display
- Error handling and validation
- User-friendly prompts and feedback

## 🔧 Configuration

### Database Configuration
- Host: localhost
- Port: 3306
- Database: ticketing_system
- User: root
- Password: (empty by default, configurable)

### Kafka Configuration
- Bootstrap Server: localhost:9092
- Topics: Auto-created by setup script

## 📊 System Capabilities

### Distributed Systems Features Demonstrated
- ✅ **Microservices Architecture**: Clear service boundaries
- ✅ **Event-Driven Communication**: Kafka-based messaging
- ✅ **Data Persistence**: MariaDB with relational design
- ✅ **Containerization Alternative**: Direct deployment without Docker
- ✅ **Interactive Operations**: CLI-based user interfaces
- ✅ **Fault Tolerance**: Error handling and service isolation
- ✅ **Real-time Processing**: Background event processing

### Business Logic
- ✅ **User Management**: Registration, authentication, roles
- ✅ **Route Management**: Transport lines, schedules, pricing
- ✅ **Ticket Lifecycle**: Create → Pay → Validate → Expire
- ✅ **Payment Processing**: Balance management, transaction tracking
- ✅ **Notifications**: Real-time updates for users
- ✅ **Reporting**: Sales analytics, popular routes

## 🚨 Troubleshooting

### Common Issues
1. **Port conflicts**: Ensure services use different ports
2. **Database connection**: Verify MariaDB is running
3. **Kafka connectivity**: Check if Kafka and Zookeeper are started
4. **Ballerina dependencies**: Verify MySQL and Kafka connectors

### Log Locations
- Service logs appear in console output
- Check individual service windows for errors
- Database errors: Check MariaDB logs

## 🔍 Monitoring

The system provides real-time monitoring through:
- Console output from each service
- Database queries for system state
- Kafka topic monitoring (use provided check scripts)

## 📈 Scalability Considerations

This implementation demonstrates production-ready patterns:
- Horizontal scaling: Multiple instances of each service
- Load distribution: Kafka partitioning
- Database optimization: Proper indexing and relationships
- Event sourcing: Complete audit trail of all operations

---

## 🎯 Assignment Requirements Met

✅ **Microservices with clear boundaries and APIs**
✅ **Event-driven design using Kafka topics and producers/consumers**  
✅ **Data modeling and persistence in MariaDB with consistency considerations**
✅ **Service orchestration for multi-service deployment (without Docker)**
✅ **Testing, monitoring, and fault-tolerance strategies**

The system is ready for demonstration and showcases all required distributed systems concepts in a real-world scenario.