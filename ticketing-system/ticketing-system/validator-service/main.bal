import ballerina/io;
import ballerina/time;
import ballerinax/mysql;
import ballerinax/kafka;

configurable int validatorPort = 8087;
configurable string kafkaUrl = "localhost:9092";
configurable string dbPassword = "";

// Database client
final mysql:Client validatorDB = check new ("localhost", "root", dbPassword, "ticketing_system", 3306);

// Kafka producer
final kafka:Producer validationProducer = check new (kafkaUrl, "ticket.validations");

public function main() returns error? {
    io:println("=== Windhoek Public Transport System ===");
    io:println("=== Ticket Validator ===");
    
    while true {
        io:println("\nValidator Options:");
        io:println("1. Validate Ticket");
        io:println("2. View Validation History");
        io:println("3. Vehicle Login");
        io:println("4. Exit");
        
        string choice = io:readln("Choose option: ");
        
        match choice {
            "1" => {
                _ = validateTicket();
            }
            "2" => {
                _ = viewValidationHistory();
            }
            "3" => {
                _ = vehicleLogin();
            }
            "4" => {
                io:println("Goodbye!");
                break;
            }
            _ => {
                io:println("Invalid option!");
            }
        }
    }
}

function vehicleLogin() returns error? {
    io:println("\n--- Vehicle Login ---");
    string vehicleId = io:readln("Vehicle/Route ID: ");
    string operatorId = io:readln("Operator ID: ");
    
    // In a real system, this would authenticate the operator
    io:println("Vehicle " + vehicleId + " logged in with operator " + operatorId);
    
    vehicleValidationMode(vehicleId, operatorId);
}

function vehicleValidationMode(string vehicleId, string operatorId) returns error? {
    while true {
        io:println("\n=== Vehicle Validation Mode ===");
        io:println("Vehicle: " + vehicleId + " | Operator: " + operatorId);
        io:println("\nOptions:");
        io:println("1. Validate Passenger Ticket");
        io:println("2. View Today's Validations");
        io:println("3. Emergency Override");
        io:println("4. Logout");
        
        string choice = io:readln("Choose option: ");
        
        match choice {
            "1" => {
                _ = validatePassengerTicket(vehicleId);
            }
            "2" => {
                _ = viewTodayValidations(vehicleId);
            }
            "3" => {
                _ = emergencyOverride(vehicleId);
            }
            "4" => {
                io:println("Logged out from vehicle " + vehicleId);
                break;
            }
            _ => {
                io:println("Invalid option!");
            }
        }
    }
}

function validateTicket() returns error? {
    io:println("\n--- Ticket Validation ---");
    string ticketId = io:readln("Enter Ticket ID: ");
    
    // Check if ticket exists and is valid
    stream<record {}, error?> result = validatorDB->query(`
        SELECT t.id, t.status, t.passenger_id, u.username, 
               tr.departure_time, r.route_number, r.name
        FROM tickets t
        JOIN users u ON t.passenger_id = u.id
        JOIN trips tr ON t.trip_id = tr.id
        JOIN routes r ON tr.route_id = r.id
        WHERE t.id = ?
    `, ticketId);
    
    record {|string id; string status; string passenger_id; string username;
            string departure_time; string route_number; string name;|}? ticket = check result.next();
    
    if ticket is () {
        io:println("❌ Ticket not found!");
        return;
    }
    
    io:println("\n--- Ticket Details ---");
    io:println("Ticket ID: " + ticket.id);
    io:println("Passenger: " + ticket.username);
    io:println("Route: " + ticket.route_number + " - " + ticket.name);
    io:println("Departure: " + ticket.departure_time);
    io:println("Status: " + ticket.status);
    
    if ticket.status == "PAID" {
        // Update ticket to VALIDATED
        _ = check validatorDB->execute(`
            UPDATE tickets SET status = 'VALIDATED', validation_time = NOW() WHERE id = ?
        `, ticketId);
        
        io:println("\n✅ TICKET VALIDATED SUCCESSFULLY!");
        io:println("Welcome aboard, " + ticket.username + "!");
        
        // Send validation event
        json validationEvent = {
            ticketId: ticketId,
            passengerId: ticket.passenger_id,
            status: "VALIDATED",
            timestamp: time:utcNow()[0].toString()
        };
        
        _ = check validationProducer->send({value: validationEvent.toString()});
        
    } else if ticket.status == "VALIDATED" {
        io:println("\n⚠️  TICKET ALREADY VALIDATED");
        io:println("This ticket has already been used.");
        
    } else if ticket.status == "EXPIRED" {
        io:println("\n❌ TICKET EXPIRED");
        io:println("This ticket is no longer valid.");
        
    } else if ticket.status == "CREATED" {
        io:println("\n❌ TICKET NOT PAID");
        io:println("This ticket has not been paid for.");
        
    } else {
        io:println("\n❌ INVALID TICKET STATUS");
    }
}

function validatePassengerTicket(string vehicleId) returns error? {
    io:println("\n--- Validate Passenger Ticket ---");
    string ticketId = io:readln("Scan/Enter Ticket ID: ");
    
    // Get trip information for this vehicle (simplified - assumes vehicle ID matches trip)
    stream<record {}, error?> tripResult = validatorDB->query(`
        SELECT t.id, r.route_number, r.name
        FROM trips t
        JOIN routes r ON t.route_id = r.id
        WHERE t.id = ? OR r.id = ?
        AND t.departure_time <= NOW() 
        AND t.arrival_time >= NOW()
        AND t.status = 'SCHEDULED'
        LIMIT 1
    `, vehicleId, vehicleId);
    
    record {|string id; string route_number; string name;|}? currentTrip = check tripResult.next();
    
    if currentTrip is () {
        io:println("⚠️  No active trip found for this vehicle");
    } else {
        io:println("Current Trip: " + currentTrip.route_number + " - " + currentTrip.name);
    }
    
    // Validate the ticket (reuse existing validation logic)
    _ = validateTicket();
}

function viewValidationHistory() returns error? {
    io:println("\n--- Validation History ---");
    
    stream<record {}, error?> result = validatorDB->query(`
        SELECT t.id, u.username, r.route_number, r.name, 
               t.validation_time, t.status
        FROM tickets t
        JOIN users u ON t.passenger_id = u.id
        JOIN trips tr ON t.trip_id = tr.id
        JOIN routes r ON tr.route_id = r.id
        WHERE t.status = 'VALIDATED'
        ORDER BY t.validation_time DESC
        LIMIT 20
    `);
    
    int count = 0;
    while true {
        record {|string id; string username; string route_number; string name;
                string validation_time; string status;|}? validation = check result.next();
        if validation is () {
            break;
        }
        count += 1;
        io:println(count + ". Ticket: " + validation.id);
        io:println("   Passenger: " + validation.username);
        io:println("   Route: " + validation.route_number + " - " + validation.name);
        io:println("   Validated: " + validation.validation_time);
        io:println("");
    }
    
    if count == 0 {
        io:println("No validation history found.");
    }
}

function viewTodayValidations(string vehicleId) returns error? {
    io:println("\n--- Today's Validations for Vehicle " + vehicleId + " ---");
    
    stream<record {}, error?> result = validatorDB->query(`
        SELECT t.id, u.username, t.validation_time
        FROM tickets t
        JOIN users u ON t.passenger_id = u.id
        JOIN trips tr ON t.trip_id = tr.id
        JOIN routes r ON tr.route_id = r.id
        WHERE t.status = 'VALIDATED'
        AND DATE(t.validation_time) = CURDATE()
        AND (tr.id = ? OR r.id = ?)
        ORDER BY t.validation_time DESC
    `, vehicleId, vehicleId);
    
    int count = 0;
    while true {
        record {|string id; string username; string validation_time;|}? validation = check result.next();
        if validation is () {
            break;
        }
        count += 1;
        io:println(count + ". " + validation.username + " - " + validation.validation_time);
    }
    
    io:println("\nTotal validations today: " + count.toString());
}

function emergencyOverride(string vehicleId) returns error? {
    io:println("\n--- Emergency Override ---");
    io:println("⚠️  USE ONLY IN EMERGENCY SITUATIONS");
    
    string reason = io:readln("Emergency reason: ");
    string passengerId = io:readln("Passenger ID (if known): ");
    
    io:println("Emergency override logged for vehicle " + vehicleId);
    io:println("Reason: " + reason);
    
    // In a real system, this would create an audit log entry
    // Create a notification for the emergency override
    json emergencyEvent = {
        type: "EMERGENCY_OVERRIDE",
        vehicleId: vehicleId,
        reason: reason,
        passengerId: passengerId,
        timestamp: time:utcNow()[0].toString()
    };
    
    _ = check validationProducer->send({value: emergencyEvent.toString()});
    
    io:println("✅ Emergency override recorded and reported.");
}