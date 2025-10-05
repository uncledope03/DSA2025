import ballerina/io;
import ballerina/uuid;
import ballerina/time;
import ballerinax/mysql;
import ballerinax/kafka;

configurable int passengerPort = 8081;
configurable string kafkaUrl = "localhost:9092";
configurable string dbPassword = "";

// Database client
final mysql:Client passengerDB = check new ("localhost", "root", dbPassword, "ticketing_system", 3306);

// Kafka producer
final kafka:Producer ticketProducer = check new (kafkaUrl, "ticket.requests");

public function main() returns error? {
    io:println("=== Windhoek Public Transport System ===");
    io:println("=== Passenger Portal ===");
    
    while true {
        io:println("\nOptions:");
        io:println("1. Register");
        io:println("2. Login");
        io:println("3. Exit");
        
        string choice = io:readln("Choose option: ");
        
        match choice {
            "1" => {
                _ = registerPassenger();
            }
            "2" => {
                _ = loginPassenger();
            }
            "3" => {
                io:println("Goodbye!");
                break;
            }
            _ => {
                io:println("Invalid option!");
            }
        }
    }
}

function registerPassenger() returns error? {
    io:println("\n--- Passenger Registration ---");
    string username = io:readln("Username: ");
    string email = io:readln("Email: ");
    string password = io:readln("Password: ");
    
    string userId = uuid:createType4AsString();
    
    _ = check passengerDB->execute(`
        INSERT INTO users (id, username, email, password_hash, role, balance)
        VALUES (?, ?, ?, ?, 'PASSENGER', 100.00)
    `, userId, username, email, password);
    
    io:println("Registration successful! You have been credited 100.00 NAD");
    return;
}

function loginPassenger() returns error? {
    io:println("\n--- Passenger Login ---");
    string username = io:readln("Username: ");
    
    stream<record {}, error?> result = passengerDB->query(`
        SELECT id, username, balance FROM users 
        WHERE username = ? AND role = 'PASSENGER'
    `, username);
    
    record {|string id; string username; decimal balance;|}? user = check result.next();
    
    if user is () {
        io:println("User not found!");
        return;
    }
    
    io:println("Login successful! Welcome " + user.username);
    passengerDashboard(user.id, user.username, user.balance);
}

function passengerDashboard(string userId, string username, decimal balance) returns error? {
    while true {
        io:println("\n=== Passenger Dashboard ===");
        io:println("Welcome, " + username + " | Balance: " + balance.toString() + " NAD");
        io:println("\nOptions:");
        io:println("1. View Available Trips");
        io:println("2. Purchase Ticket");
        io:println("3. View My Tickets");
        io:println("4. View Notifications");
        io:println("5. Logout");
        
        string choice = io:readln("Choose option: ");
        
        match choice {
            "1" => {
                _ = viewAvailableTrips();
            }
            "2" => {
                _ = purchaseTicket(userId);
            }
            "3" => {
                _ = viewMyTickets(userId);
            }
            "4" => {
                _ = viewNotifications(userId);
            }
            "5" => {
                break;
            }
            _ => {
                io:println("Invalid option!");
            }
        }
    }
}

function viewAvailableTrips() returns error? {
    io:println("\n--- Available Trips ---");
    
    stream<record {}, error?> result = passengerDB->query(`
        SELECT t.id, r.name, r.route_number, r.transport_type, 
               t.departure_time, t.arrival_time, t.price, t.available_seats
        FROM trips t
        JOIN routes r ON t.route_id = r.id
        WHERE t.status = 'SCHEDULED' AND t.departure_time > NOW()
        ORDER BY t.departure_time
    `);
    
    int count = 0;
    while true {
        record {|string id; string name; string route_number; string transport_type; 
                string departure_time; string arrival_time; decimal price; int available_seats;|}? trip = check result.next();
        if trip is () {
            break;
        }
        count += 1;
        io:println(count + ". " + trip.route_number + " - " + trip.name + 
                   " (" + trip.transport_type + ")");
        io:println("   Departure: " + trip.departure_time + 
                   " | Price: " + trip.price.toString() + " NAD" +
                   " | Seats: " + trip.available_seats.toString());
    }
    
    if count == 0 {
        io:println("No available trips found.");
    }
}

function purchaseTicket(string userId) returns error? {
    io:println("\n--- Purchase Ticket ---");
    
    // Show available trips
    _ = viewAvailableTrips();
    
    string tripId = io:readln("Enter Trip ID: ");
    
    // Get trip details
    stream<record {}, error?> result = passengerDB->query(`
        SELECT price FROM trips WHERE id = ? AND status = 'SCHEDULED'
    `, tripId);
    
    record {|decimal price;|}? trip = check result.next();
    
    if trip is () {
        io:println("Invalid trip ID!");
        return;
    }
    
    io:println("Trip price: " + trip.price.toString() + " NAD");
    
    // Create ticket request
    string ticketId = uuid:createType4AsString();
    json ticketRequest = {
        ticketId: ticketId,
        passengerId: userId,
        tripId: tripId,
        ticketType: "SINGLE",
        price: trip.price,
        timestamp: time:utcNow()[0].toString()
    };
    
    // Send to Kafka
    _ = check ticketProducer->send({value: ticketRequest.toString()});
    
    io:println("Ticket request sent! Ticket ID: " + ticketId);
    io:println("Please proceed to payment...");
}

function viewMyTickets(string userId) returns error? {
    io:println("\n--- My Tickets ---");
    
    stream<record {}, error?> result = passengerDB->query(`
        SELECT t.id, r.name, r.route_number, t2.departure_time, 
               t2.arrival_time, t.status, t.purchase_time
        FROM tickets t
        JOIN trips t2 ON t.trip_id = t2.id
        JOIN routes r ON t2.route_id = r.id
        WHERE t.passenger_id = ?
        ORDER BY t.purchase_time DESC
    `, userId);
    
    int count = 0;
    while true {
        record {|string id; string name; string route_number; string departure_time; 
                string arrival_time; string status; string purchase_time;|}? ticket = check result.next();
        if ticket is () {
            break;
        }
        count += 1;
        io:println(count + ". Ticket: " + ticket.id);
        io:println("   Route: " + ticket.route_number + " - " + ticket.name);
        io:println("   Departure: " + ticket.departure_time);
        io:println("   Status: " + ticket.status);
        io:println("   Purchased: " + ticket.purchase_time);
    }
    
    if count == 0 {
        io:println("No tickets found.");
    }
}

function viewNotifications(string userId) returns error? {
    io:println("\n--- Notifications ---");
    
    stream<record {}, error?> result = passengerDB->query(`
        SELECT title, message, created_at, is_read
        FROM notifications 
        WHERE user_id = ?
        ORDER BY created_at DESC
        LIMIT 10
    `, userId);
    
    int count = 0;
    while true {
        record {|string title; string message; string created_at; boolean is_read;|}? notification = check result.next();
        if notification is () {
            break;
        }
        count += 1;
        string readStatus = notification.is_read ? "[READ]" : "[NEW]";
        io:println(count + ". " + readStatus + " " + notification.title);
        io:println("   " + notification.message);
        io:println("   " + notification.created_at);
    }
    
    if count == 0 {
        io:println("No notifications found.");
    }
}