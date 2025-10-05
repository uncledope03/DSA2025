import ballerina/io;
import ballerina/uuid;
import ballerina/time;
import ballerinax/mysql;
import ballerinax/kafka;

configurable int transportPort = 8086;
configurable string kafkaUrl = "localhost:9092";
configurable string dbPassword = "";

// Database client
final mysql:Client transportDB = check new ("localhost", "root", dbPassword, "ticketing_system", 3306);

// Kafka producer
final kafka:Producer scheduleProducer = check new (kafkaUrl, "schedule.updates");

public function main() returns error? {
    io:println("=== Windhoek Public Transport System ===");
    io:println("=== Transport Management ===");
    
    while true {
        io:println("\nOptions:");
        io:println("1. Route Management");
        io:println("2. Trip Management");
        io:println("3. Service Updates");
        io:println("4. Exit");
        
        string choice = io:readln("Choose option: ");
        
        match choice {
            "1" => {
                _ = routeManagement();
            }
            "2" => {
                _ = tripManagement();
            }
            "3" => {
                _ = serviceUpdates();
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

function routeManagement() returns error? {
    io:println("\n--- Route Management ---");
    io:println("1. Create Route");
    io:println("2. View Routes");
    io:println("3. Update Route");
    
    string choice = io:readln("Choose option: ");
    
    match choice {
        "1" => {
            _ = createRoute();
        }
        "2" => {
            _ = viewRoutes();
        }
        "3" => {
            _ = updateRoute();
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
    
    _ = check transportDB->execute(`
        INSERT INTO routes (id, route_number, name, transport_type, start_location, end_location)
        VALUES (?, ?, ?, ?, ?, ?)
    `, routeId, routeNumber, name, transportType.toUpperAscii(), startLocation, endLocation);
    
    io:println("Route created successfully!");
    io:println("Route ID: " + routeId);
    
    // Send notification about new route
    json routeEvent = {
        title: "New Route Added",
        message: "Route " + routeNumber + " - " + name + " is now available",
        routeId: routeId,
        timestamp: time:utcNow()[0].toString()
    };
    
    _ = check scheduleProducer->send({value: routeEvent.toString()});
}

function viewRoutes() returns error? {
    io:println("\n--- All Routes ---");
    
    stream<record {}, error?> result = transportDB->query(`
        SELECT id, route_number, name, transport_type, start_location, end_location, created_at
        FROM routes
        ORDER BY route_number
    `);
    
    int count = 0;
    while true {
        record {|string id; string route_number; string name; string transport_type; 
                string start_location; string end_location; string created_at;|}? route = check result.next();
        if route is () {
            break;
        }
        count += 1;
        io:println(count + ". " + route.route_number + " - " + route.name);
        io:println("   Type: " + route.transport_type);
        io:println("   Route: " + route.start_location + " → " + route.end_location);
        io:println("   ID: " + route.id);
        io:println("   Created: " + route.created_at);
        io:println("");
    }
    
    if count == 0 {
        io:println("No routes found.");
    }
}

function updateRoute() returns error? {
    io:println("\n--- Update Route ---");
    
    _ = viewRoutes();
    
    string routeId = io:readln("Enter Route ID to update: ");
    
    // Check if route exists
    stream<record {}, error?> result = transportDB->query(`
        SELECT route_number, name FROM routes WHERE id = ?
    `, routeId);
    
    record {|string route_number; string name;|}? route = check result.next();
    
    if route is () {
        io:println("Route not found!");
        return;
    }
    
    io:println("Current: " + route.route_number + " - " + route.name);
    io:println("What would you like to update?");
    io:println("1. Route Status (Active/Inactive)");
    io:println("2. Send Schedule Update");
    
    string choice = io:readln("Choose option: ");
    
    match choice {
        "1" => {
            string status = io:readln("Set status (ACTIVE/INACTIVE): ");
            // Note: We'd need to add an 'active' column to routes table
            io:println("Status updated (feature requires database schema update)");
        }
        "2" => {
            string updateMessage = io:readln("Update message: ");
            
            json updateEvent = {
                title: "Schedule Update - " + route.route_number,
                message: updateMessage,
                routeId: routeId,
                timestamp: time:utcNow()[0].toString()
            };
            
            _ = check scheduleProducer->send({value: updateEvent.toString()});
            io:println("Schedule update sent!");
        }
        _ => {
            io:println("Invalid option!");
        }
    }
}

function tripManagement() returns error? {
    io:println("\n--- Trip Management ---");
    io:println("1. Create Trip");
    io:println("2. View Trips");
    io:println("3. Update Trip Status");
    
    string choice = io:readln("Choose option: ");
    
    match choice {
        "1" => {
            _ = createTrip();
        }
        "2" => {
            _ = viewTrips();
        }
        "3" => {
            _ = updateTripStatus();
        }
        _ => {
            io:println("Invalid option!");
        }
    }
}

function createTrip() returns error? {
    io:println("\n--- Create New Trip ---");
    
    // Show available routes
    _ = viewRoutes();
    
    string routeId = io:readln("Enter Route ID: ");
    string departureTime = io:readln("Departure Time (YYYY-MM-DD HH:MM:SS): ");
    string arrivalTime = io:readln("Arrival Time (YYYY-MM-DD HH:MM:SS): ");
    string availableSeats = io:readln("Available Seats: ");
    string price = io:readln("Price (NAD): ");
    
    string tripId = uuid:createType4AsString();
    
    _ = check transportDB->execute(`
        INSERT INTO trips (id, route_id, departure_time, arrival_time, available_seats, price)
        VALUES (?, ?, ?, ?, ?, ?)
    `, tripId, routeId, departureTime, arrivalTime, int:fromString(availableSeats), decimal:fromString(price));
    
    io:println("Trip created successfully!");
    io:println("Trip ID: " + tripId);
}

function viewTrips() returns error? {
    io:println("\n--- All Trips ---");
    
    stream<record {}, error?> result = transportDB->query(`
        SELECT t.id, r.route_number, r.name, t.departure_time, t.arrival_time, 
               t.available_seats, t.price, t.status
        FROM trips t
        JOIN routes r ON t.route_id = r.id
        WHERE t.departure_time >= CURDATE()
        ORDER BY t.departure_time
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
        io:println(count + ". Trip: " + trip.id);
        io:println("   Route: " + trip.route_number + " - " + trip.name);
        io:println("   Departure: " + trip.departure_time + " → Arrival: " + trip.arrival_time);
        io:println("   Seats: " + trip.available_seats.toString() + " | Price: " + trip.price.toString() + " NAD");
        io:println("   Status: " + trip.status);
        io:println("");
    }
    
    if count == 0 {
        io:println("No upcoming trips found.");
    }
}

function updateTripStatus() returns error? {
    io:println("\n--- Update Trip Status ---");
    
    _ = viewTrips();
    
    string tripId = io:readln("Enter Trip ID: ");
    
    io:println("Available statuses:");
    io:println("1. SCHEDULED");
    io:println("2. DELAYED");
    io:println("3. CANCELLED");
    io:println("4. COMPLETED");
    
    string statusChoice = io:readln("Choose status (1-4): ");
    
    string status = "";
    match statusChoice {
        "1" => { status = "SCHEDULED"; }
        "2" => { status = "DELAYED"; }
        "3" => { status = "CANCELLED"; }
        "4" => { status = "COMPLETED"; }
        _ => {
            io:println("Invalid status choice!");
            return;
        }
    }
    
    _ = check transportDB->execute(`
        UPDATE trips SET status = ? WHERE id = ?
    `, status, tripId);
    
    // Send notification about status change
    json statusEvent = {
        title: "Trip Status Update",
        message: "Trip " + tripId + " status changed to " + status,
        tripId: tripId,
        status: status,
        timestamp: time:utcNow()[0].toString()
    };
    
    _ = check scheduleProducer->send({value: statusEvent.toString()});
    
    io:println("Trip status updated to: " + status);
}

function serviceUpdates() returns error? {
    io:println("\n--- Service Updates ---");
    io:println("1. Send General Update");
    io:println("2. Send Route-specific Update");
    io:println("3. Send Emergency Alert");
    
    string choice = io:readln("Choose option: ");
    
    match choice {
        "1" => {
            _ = sendGeneralUpdate();
        }
        "2" => {
            _ = sendRouteUpdate();
        }
        "3" => {
            _ = sendEmergencyAlert();
        }
        _ => {
            io:println("Invalid option!");
        }
    }
}

function sendGeneralUpdate() returns error? {
    io:println("\n--- General Service Update ---");
    string title = io:readln("Update Title: ");
    string message = io:readln("Update Message: ");
    
    json updateEvent = {
        title: title,
        message: message,
        type: "GENERAL",
        timestamp: time:utcNow()[0].toString()
    };
    
    _ = check scheduleProducer->send({value: updateEvent.toString()});
    
    io:println("General update sent to all users!");
}

function sendRouteUpdate() returns error? {
    io:println("\n--- Route-specific Update ---");
    
    _ = viewRoutes();
    
    string routeId = io:readln("Enter Route ID: ");
    string title = io:readln("Update Title: ");
    string message = io:readln("Update Message: ");
    
    json updateEvent = {
        title: title,
        message: message,
        type: "ROUTE_SPECIFIC",
        routeId: routeId,
        timestamp: time:utcNow()[0].toString()
    };
    
    _ = check scheduleProducer->send({value: updateEvent.toString()});
    
    io:println("Route-specific update sent!");
}

function sendEmergencyAlert() returns error? {
    io:println("\n--- Emergency Alert ---");
    string title = io:readln("Alert Title: ");
    string message = io:readln("Alert Message: ");
    
    json alertEvent = {
        title: "[EMERGENCY] " + title,
        message: message,
        type: "EMERGENCY",
        priority: "HIGH",
        timestamp: time:utcNow()[0].toString()
    };
    
    _ = check scheduleProducer->send({value: alertEvent.toString()});
    
    io:println("Emergency alert sent to all users!");
}