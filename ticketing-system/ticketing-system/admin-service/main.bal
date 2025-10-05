import ballerina/io;
import ballerina/uuid;
import ballerina/time;
import ballerinax/mysql;
import ballerinax/kafka;

configurable int adminPort = 8084;
configurable string kafkaUrl = "localhost:9092";
configurable string dbPassword = "";

// Database client
final mysql:Client adminDB = check new ("localhost", "root", dbPassword, "ticketing_system", 3306);

// Kafka producer
final kafka:Producer scheduleProducer = check new ({bootstrapServers: kafkaUrl});

public function main() returns error? {
    io:println("=== Windhoek Public Transport System ===");
    io:println("=== Admin Portal ===");
    
    while true {
        io:println("\nOptions:");
        io:println("1. Login as Admin");
        io:println("2. Exit");
        
        string choice = io:readln("Choose option: ");
        
        match choice {
            "1" => {
                check loginAdmin();
            }
            "2" => {
                io:println("Goodbye!");
                break;
            }
            _ => {
                io:println("Invalid option!");
            }
        }
    }
}

function loginAdmin() returns error? {
    io:println("\n--- Admin Login ---");
    string username = io:readln("Username: ");
    
    stream<record {}, error?> result = adminDB->query(`
        SELECT id, username FROM users 
        WHERE username = ? AND role = 'ADMIN'
    `, username);
    
    record {}|error? queryResult = result.next();
    if queryResult is error {
        io:println("Database error: " + queryResult.message());
        return;
    }
    if queryResult is () {
        io:println("Admin not found!");
        return;
    }
    record {|string id; string username;|} admin = <record {|string id; string username;|}>queryResult;
    
    if admin is () {
        io:println("Admin not found!");
        return;
    }
    
    io:println("Login successful! Welcome " + admin.username);
    adminDashboard(admin.id);
}

function adminDashboard(string adminId) returns error? {
    while true {
        io:println("\n=== Admin Dashboard ===");
        io:println("Options:");
        io:println("1. Manage Routes");
        io:println("2. Manage Trips");
        io:println("3. View Reports");
        io:println("4. Send Service Updates");
        io:println("5. Logout");
        
        string choice = io:readln("Choose option: ");
        
        match choice {
            "1" => {
                _ = manageRoutes();
            }
            "2" => {
                _ = manageTrips();
            }
            "3" => {
                _ = viewReports();
            }
            "4" => {
                _ = sendServiceUpdates();
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

function manageRoutes() returns error? {
    io:println("\n--- Route Management ---");
    io:println("1. Create New Route");
    io:println("2. View All Routes");
    
    string choice = io:readln("Choose option: ");
    
    match choice {
        "1" => {
            _ = createRoute();
        }
        "2" => {
            _ = viewAllRoutes();
        }
        _ => {
            io:println("Invalid option!");
        }
    }
}

function createRoute() returns error? {
    io:println("\n--- Create New Route ---");
    string routeNumber = io:readln("Route Number: ");
    string name = io:readln("Route Name: ");
    string transportType = io:readln("Transport Type (BUS/TRAIN): ");
    string startLocation = io:readln("Start Location: ");
    string endLocation = io:readln("End Location: ");
    
    string routeId = uuid:createType4AsString();
    
    _ = check adminDB->execute(`
        INSERT INTO routes (id, route_number, name, transport_type, start_location, end_location)
        VALUES (?, ?, ?, ?, ?, ?)
    `, routeId, routeNumber, name, transportType.toUpper(), startLocation, endLocation);
    
    io:println("Route created successfully! ID: " + routeId);
}

function viewAllRoutes() returns error? {
    io:println("\n--- All Routes ---");
    
    stream<record {}, error?> result = adminDB->query(`
        SELECT id, route_number, name, transport_type, start_location, end_location
        FROM routes
        ORDER BY route_number
    `);
    
    int count = 0;
    while true {
        record {|string id; string route_number; string name; string transport_type; 
                string start_location; string end_location;|}? route = check result.next();
        if route is () {
            break;
        }
        count += 1;
        io:println(count + ". " + route.route_number + " - " + route.name);
        io:println("   Type: " + route.transport_type);
        io:println("   From: " + route.start_location + " to " + route.end_location);
        io:println("   ID: " + route.id);
    }
    
    if count == 0 {
        io:println("No routes found.");
    }
}

function viewReports() returns error? {
    io:println("\n--- System Reports ---");
    
    // Ticket sales report
    stream<record {}, error?> salesResult = adminDB->query(`
        SELECT 
            COUNT(*) as total_tickets,
            SUM(price) as total_revenue,
            AVG(price) as avg_ticket_price
        FROM tickets 
        WHERE status = 'PAID'
    `);
    
    record {|int total_tickets; decimal total_revenue; decimal avg_ticket_price;|}? sales = check salesResult.next();
    
    io:println("Ticket Sales Report:");
    io:println("Total Tickets Sold: " + sales.total_tickets.toString());
    io:println("Total Revenue: " + sales.total_revenue.toString() + " NAD");
    io:println("Average Ticket Price: " + sales.avg_ticket_price.toString() + " NAD");
    
    // Popular routes
    io:println("\nPopular Routes:");
    stream<record {}, error?> routesResult = adminDB->query(`
        SELECT r.route_number, r.name, COUNT(t.id) as ticket_count
        FROM tickets t
        JOIN trips tr ON t.trip_id = tr.id
        JOIN routes r ON tr.route_id = r.id
        WHERE t.status = 'PAID'
        GROUP BY r.id
        ORDER BY ticket_count DESC
        LIMIT 5
    `);
    
    int count = 0;
    while true {
        record {|string route_number; string name; int ticket_count;|}? route = check routesResult.next();
        if route is () {
            break;
        }
        count += 1;
        io:println(count + ". " + route.route_number + " - " + route.name + 
                   " (" + route.ticket_count.toString() + " tickets)");
    }
}

function manageTrips() returns error? {
    io:println("\n--- Trip Management ---");
    io:println("1. Create New Trip");
    io:println("2. View All Trips");
    
    string choice = io:readln("Choose option: ");
    
    match choice {
        "1" => {
            _ = createTrip();
        }
        "2" => {
            _ = viewAllTrips();
        }
        _ => {
            io:println("Invalid option!");
        }
    }
}

function createTrip() returns error? {
    io:println("\n--- Create New Trip ---");
    
    // Show available routes first
    _ = viewAllRoutes();
    
    string routeId = io:readln("Enter Route ID: ");
    string departureTime = io:readln("Departure Time (YYYY-MM-DD HH:MM:SS): ");
    string arrivalTime = io:readln("Arrival Time (YYYY-MM-DD HH:MM:SS): ");
    string availableSeats = io:readln("Available Seats: ");
    string price = io:readln("Price (NAD): ");
    
    string tripId = uuid:createType4AsString();
    
    _ = check adminDB->execute(`
        INSERT INTO trips (id, route_id, departure_time, arrival_time, available_seats, price)
        VALUES (?, ?, ?, ?, ?, ?)
    `, tripId, routeId, departureTime, arrivalTime, int:fromString(availableSeats), decimal:fromString(price));
    
    io:println("Trip created successfully! ID: " + tripId);
}

function viewAllTrips() returns error? {
    io:println("\n--- All Trips ---");
    
    stream<record {}, error?> result = adminDB->query(`
        SELECT t.id, r.route_number, r.name, t.departure_time, t.arrival_time, 
               t.available_seats, t.price, t.status
        FROM trips t
        JOIN routes r ON t.route_id = r.id
        ORDER BY t.departure_time DESC
        LIMIT 20
    `);
    
    int count = 0;
    while true {
        record {|string id; string route_number; string name; string departure_time; 
                string arrival_time; int available_seats; decimal price; string status;|}? trip = check result.next();
        if trip is () {
            break;
        }
        count += 1;
        io:println(count + ". Trip ID: " + trip.id);
        io:println("   Route: " + trip.route_number + " - " + trip.name);
        io:println("   Departure: " + trip.departure_time);
        io:println("   Arrival: " + trip.arrival_time);
        io:println("   Seats: " + trip.available_seats.toString() + " | Price: " + trip.price.toString() + " NAD");
        io:println("   Status: " + trip.status);
    }
    
    if count == 0 {
        io:println("No trips found.");
    }
}

function sendServiceUpdates() returns error? {
    io:println("\n--- Send Service Update ---");
    string title = io:readln("Update Title: ");
    string message = io:readln("Update Message: ");
    string severity = io:readln("Severity (LOW/MEDIUM/HIGH): ");
    
    json updateEvent = {
        title: title,
        message: message,
        severity: severity.toUpperAscii(),
        timestamp: time:utcNow()[0].toString()
    };
    
    _ = check scheduleProducer->send({value: updateEvent.toString()});
    
    io:println("Service update sent successfully!");
}
