import ballerina/io;
import ballerina/uuid;
import ballerina/runtime;
import ballerinax/kafka;
import ballerinax/mysql;

configurable int notificationPort = 8085;
configurable string kafkaUrl = "localhost:9092";
configurable string dbPassword = "";

// Database client
final mysql:Client notificationDB = check new ("localhost", "root", dbPassword, "ticketing_system", 3306);

// Kafka consumers
final kafka:Consumer scheduleConsumer = check new (kafkaUrl, "schedule.updates", "notification-group");
final kafka:Consumer validationConsumer = check new (kafkaUrl, "ticket.validations", "notification-group");

public function main() returns error? {
    io:println("Starting Notification Service...");
    
    // Start listening for schedule updates
    _ = start @strand {preferred: true} scheduleUpdateListener();
    
    // Start listening for ticket validations
    _ = start @strand {preferred: true} validationListener();
    
    io:println("Notification Service is running. Press Ctrl+C to stop.");
    
    // Keep the service running
    while true {
        runtime:sleep(10);
    }
}

function scheduleUpdateListener() returns error? {
    while true {
        var result = scheduleConsumer->poll(1);
        if result is kafka:ConsumerRecord[] {
            foreach var record in result {
                processScheduleUpdate(record);
            }
        }
        runtime:sleep(1);
    }
}

function processScheduleUpdate(kafka:ConsumerRecord record) returns error? {
    json update = check record.value.toString().fromJsonString();
    
    string message = update.message.toString();
    string updateType = update.type.toString();
    
    // Get all passengers
    stream<record {}, error?> result = notificationDB->query(`
        SELECT id FROM users WHERE role = 'PASSENGER'
    `);
    
    while true {
        record {|string id;|}? user = check result.next();
        if user is () {
            break;
        }
        
        // Create notification for each passenger
        string notificationId = uuid:createType4AsString();
        _ = check notificationDB->execute(`
            INSERT INTO notifications (id, user_id, title, message, type)
            VALUES (?, ?, ?, ?, ?)
        `, notificationId, user.id, "Schedule Update", message, "TRIP_UPDATE");
    }
    
    io:println("Sent schedule update notifications to all passengers: " + message);
}

function validationListener() returns error? {
    while true {
        var result = validationConsumer->poll(1);
        if result is kafka:ConsumerRecord[] {
            foreach var record in result {
                processValidation(record);
            }
        }
        runtime:sleep(1);
    }
}

function processValidation(kafka:ConsumerRecord record) returns error? {
    json validation = check record.value.toString().fromJsonString();
    
    string ticketId = validation.ticketId.toString();
    string status = validation.status.toString();
    
    // Get passenger ID from ticket
    stream<record {}, error?> result = notificationDB->query(`
        SELECT passenger_id FROM tickets WHERE id = ?
    `, ticketId);
    
    record {|string passenger_id;|}? ticket = check result.next();
    
    if ticket is () {
        return;
    }
    
    string title = "Ticket " + status;
    string message = "Your ticket " + ticketId + " has been " + status.toLowerCase();
    
    string notificationId = uuid:createType4AsString();
    _ = check notificationDB->execute(`
        INSERT INTO notifications (id, user_id, title, message, type)
        VALUES (?, ?, ?, ?, 'TICKET_CONFIRMATION')
    `, notificationId, ticket.passenger_id, title, message);
    
    io:println("Sent notification to user " + ticket.passenger_id + ": " + message);
}