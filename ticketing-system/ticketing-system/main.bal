import ballerina/io;
import ballerina/uuid;

// Enhanced types for comprehensive ticketing system
type User record {
    int id;
    string username;
    string email;
    string password;
    string role;
    decimal balance;
    string? phone;
    boolean notifications_enabled;
    string created_at;
    string? last_login;
};

type Route record {
    int id;
    string route_name;
    string route_type;
    string origin;
    string destination;
    decimal base_fare;
    boolean is_active;
    string status; // "active", "disrupted", "maintenance"
    string? disruption_message;
    decimal distance_km;
    int estimated_duration_minutes;
};

type Trip record {
    int id;
    int route_id;
    string departure_time;
    string arrival_time;
    int available_seats;
    int total_seats;
    string status; // "scheduled", "boarding", "in_transit", "completed", "cancelled", "delayed"
    decimal? delay_minutes;
    string? status_message;
    string vehicle_number;
};

type Ticket record {
    int id;
    int user_id;
    int? trip_id; // Optional for passes
    string ticket_type; // "single", "multi_ride_5", "multi_ride_10", "daily_pass", "weekly_pass", "monthly_pass"
    string status; // "paid", "validated", "used", "expired", "cancelled", "refunded"
    decimal purchase_price;
    decimal? refund_amount;
    string purchased_at;
    string expires_at;
    string? validated_at;
    string? cancelled_at;
    string? refunded_at;
    string validation_code;
    int? rides_remaining; // For multi-ride tickets
    int? total_rides; // For multi-ride tickets
    string? cancellation_reason;
};

type Transaction record {
    int id;
    int user_id;
    string transaction_type; // "purchase", "topup", "refund", "cancellation_fee"
    decimal amount;
    decimal balance_before;
    decimal balance_after;
    string description;
    string timestamp;
    string status; // "completed", "pending", "failed"
    int? ticket_id;
};

type Notification record {
    int id;
    int user_id;
    string notification_type; // "trip_delay", "trip_cancellation", "route_disruption", "ticket_expiry", "low_balance"
    string title;
    string message;
    string timestamp;
    boolean is_read;
    int? related_trip_id;
    int? related_route_id;
};

// Global data arrays
User[] users = [
    {id: 1, username: "john_doe", email: "john@example.com", password: "password123", role: "passenger", balance: 150.00, phone: "+264812345678", notifications_enabled: true, created_at: "2024-01-01 10:00:00", last_login: "2024-01-15 14:20:00"},
    {id: 2, username: "admin", email: "admin@windhoek.com", password: "admin123", role: "admin", balance: 0.00, phone: (), notifications_enabled: true, created_at: "2024-01-01 09:00:00", last_login: "2024-01-15 15:30:00"},
    {id: 3, username: "validator1", email: "validator@transport.com", password: "val123", role: "validator", balance: 0.00, phone: (), notifications_enabled: true, created_at: "2024-01-01 08:00:00", last_login: ()}
];

Route[] routes = [
    {id: 1, route_name: "City Center Express", route_type: "bus", origin: "Windhoek Central", destination: "Katutura", base_fare: 12.50, is_active: true, status: "active", disruption_message: (), distance_km: 8.5, estimated_duration_minutes: 25},
    {id: 2, route_name: "Airport Shuttle", route_type: "bus", origin: "Hosea Kutako Airport", destination: "City Center", base_fare: 45.00, is_active: true, status: "active", disruption_message: (), distance_km: 42.0, estimated_duration_minutes: 50},
    {id: 3, route_name: "University Route", route_type: "bus", origin: "UNAM Campus", destination: "Windhoek Central", base_fare: 8.00, is_active: true, status: "disrupted", disruption_message: "Temporary detour due to road construction", distance_km: 6.2, estimated_duration_minutes: 20},
    {id: 4, route_name: "Northern Suburbs", route_type: "train", origin: "Windhoek Central", destination: "Pioneers Park", base_fare: 15.00, is_active: true, status: "active", disruption_message: (), distance_km: 12.0, estimated_duration_minutes: 18}
];

Trip[] trips = [
    {id: 1, route_id: 1, departure_time: "2024-01-15 08:00:00", arrival_time: "2024-01-15 08:30:00", available_seats: 25, total_seats: 40, status: "scheduled", delay_minutes: (), status_message: (), vehicle_number: "WDH-001"},
    {id: 2, route_id: 1, departure_time: "2024-01-15 16:00:00", arrival_time: "2024-01-15 16:30:00", available_seats: 30, total_seats: 40, status: "delayed", delay_minutes: 15.0, status_message: "Traffic congestion", vehicle_number: "WDH-002"},
    {id: 3, route_id: 2, departure_time: "2024-01-15 10:00:00", arrival_time: "2024-01-15 11:00:00", available_seats: 15, total_seats: 50, status: "boarding", delay_minutes: (), status_message: (), vehicle_number: "WDH-003"},
    {id: 4, route_id: 3, departure_time: "2024-01-15 07:00:00", arrival_time: "2024-01-15 07:45:00", available_seats: 0, total_seats: 35, status: "cancelled", delay_minutes: (), status_message: "Vehicle breakdown", vehicle_number: "WDH-004"},
    {id: 5, route_id: 4, departure_time: "2024-01-15 12:00:00", arrival_time: "2024-01-15 12:18:00", available_seats: 80, total_seats: 120, status: "scheduled", delay_minutes: (), status_message: (), vehicle_number: "WDH-T001"}
];

Ticket[] tickets = [];
Transaction[] transactions = [];
Notification[] notifications = [];

int nextTicketId = 1;
int nextTransactionId = 1;
int nextNotificationId = 1;
int currentUserId = 0;

// Ticket pricing structure
map<decimal> ticketPrices = {
    "single": 1.0,
    "multi_ride_5": 4.5,
    "multi_ride_10": 8.5,
    "daily_pass": 6.0,
    "weekly_pass": 35.0,
    "monthly_pass": 120.0
};

public function main() returns error? {
    io:println("================================================================");
    io:println("   🚌 WINDHOEK PUBLIC TRANSPORT TICKETING SYSTEM 🚊");
    io:println("        [ ENHANCED COMPREHENSIVE PLATFORM ]");
    io:println("================================================================");
    io:println("");
    io:println("✅ Enhanced system initialized successfully!");
    io:println("📊 System data loaded:");
    io:println("   👥 Users: " + users.length().toString());
    io:println("   🛣️  Routes: " + routes.length().toString()); 
    io:println("   🚌 Trips: " + trips.length().toString());
    io:println("   🎟️  Ticket Types: " + ticketPrices.keys().length().toString());
    io:println("   💰 Balance Management: ✅ Enhanced");
    io:println("   🔔 Notifications: ✅ Real-time");
    io:println("   🎫 Ticket Management: ✅ Full Lifecycle");
    io:println("   ❌ Cancellation & Refunds: ✅ Available");
    io:println("   🔄 Top-up System: ✅ Multi-option");
    io:println("");
    
    initializeSampleNotifications();
    
    while true {
        displayMainMenu();
        string choice = io:readln("Select your role (1-4): ");
        
        match choice {
            "1" => {
                check startPassengerPortal();
            }
            "2" => {
                check startAdminPortal();
            }
            "3" => {
                check startValidatorPortal();
            }
            "4" => {
                io:println("Thank you for using Windhoek Public Transport System!");
                io:println("Have a great journey! 🚌✨");
                break;
            }
            _ => {
                io:println("❌ Invalid choice! Please select 1-4.");
                io:println("");
            }
        }
    }
}

function displayMainMenu() {
    io:println("🚌 WINDHOEK PUBLIC TRANSPORT SYSTEM 🚊");
    io:println("======================================");
    io:println("");
    io:println("Please select your role:");
    io:println("1. 👤 Passenger Portal - Enhanced ticketing experience");
    io:println("2. 👨‍💼 Admin Portal - Complete system management");
    io:println("3. ✅ Validator Portal - Advanced ticket validation");
    io:println("4. 🚪 Exit System");
    io:println("");
}

function startPassengerPortal() returns error? {
    io:println("");
    io:println("👤 ENHANCED PASSENGER PORTAL");
    io:println("============================");
    
    while true {
        io:println("");
        io:println("Passenger Options:");
        io:println("1. 📝 Register New Account");
        io:println("2. 🔐 Login to Your Account");
        io:println("3. 🚌 Browse Routes & Trips (Guest)");
        io:println("4. 📊 System Status (Guest)");
        io:println("5. ⬅️  Return to Main Menu");
        
        string choice = io:readln("Choose option (1-5): ");
        
        match choice {
            "1" => {
                check registerNewPassenger();
            }
            "2" => {
                check loginExistingPassenger();
            }
            "3" => {
                check browseRoutesAndTrips();
            }
            "4" => {
                check showSystemStatus();
            }
            "5" => {
                break;
            }
            _ => {
                io:println("❌ Invalid option! Please choose 1-5.");
            }
        }
    }
}

function registerNewPassenger() returns error? {
    io:println("");
    io:println("📝 PASSENGER REGISTRATION");
    io:println("=========================");
    
    string username = io:readln("Choose a Username: ");
    string email = io:readln("Enter Your Email: ");
    string phone = io:readln("Enter Your Phone Number: ");
    string password = io:readln("Create a Password: ");
    string enableNotifications = io:readln("Enable notifications? (y/n): ");
    
    // Check if username exists
    foreach User user in users {
        if user.username == username {
            io:println("❌ Username already exists! Please choose a different username.");
            return;
        }
    }
    
    int newId = users.length() + 1;
    User newUser = {
        id: newId,
        username: username,
        email: email,
        password: password,
        role: "passenger",
        balance: 100.00,
        phone: phone,
        notifications_enabled: enableNotifications.toLowerAscii() == "y",
        created_at: getCurrentTimestamp(),
        last_login: ()
    };
    users.push(newUser);
    
    recordTransaction(newId, "topup", 100.00, 0.00, 100.00, "Welcome bonus");
    
    io:println("");
    io:println("✅ Registration Successful!");
    io:println("📧 Username: " + username);
    io:println("📱 Phone: " + phone);
    io:println("💰 Welcome bonus: 100.00 NAD credited to your account");
    io:println("🔔 Notifications: " + (newUser.notifications_enabled ? "Enabled" : "Disabled"));
    io:println("🎟️  You can now login and start your journey!");
}

function loginExistingPassenger() returns error? {
    io:println("");
    io:println("🔐 PASSENGER LOGIN");
    io:println("==================");
    
    string username = io:readln("Username: ");
    string password = io:readln("Password: ");
    
    foreach int i in 0 ..< users.length() {
        User user = users[i];
        if user.username == username && user.password == password && user.role == "passenger" {
            users[i].last_login = getCurrentTimestamp();
            currentUserId = user.id;
            
            io:println("");
            io:println("✅ Login Successful! Welcome back, " + user.username);
            string lastLoginStr = user.last_login is () ? "First time login" : <string>user.last_login;
            io:println("📅 Last login: " + lastLoginStr);
            
            check showPassengerDashboard(users[i]);
            return;
        }
    }
    
    io:println("❌ Invalid credentials! Please check your username and password.");
}

function showPassengerDashboard(User user) returns error? {
    while true {
        User? currentUser = getUserById(user.id);
        if currentUser is () {
            io:println("❌ User session error!");
            break;
        }
        
        User loggedUser = currentUser;
        
        io:println("");
        io:println("🎯 PASSENGER DASHBOARD");
        io:println("======================");
        io:println("Welcome, " + loggedUser.username + "! 👋");
        io:println("💰 Balance: " + loggedUser.balance.toString() + " NAD");
        
        int unreadNotifications = getUnreadNotificationsCount(loggedUser.id);
        if unreadNotifications > 0 {
            io:println("🔔 " + unreadNotifications.toString() + " new notifications");
        }
        
        io:println("");
        io:println("What would you like to do?");
        io:println("1. 🚌 Browse Routes & Trips");
        io:println("2. 🎟️  Purchase Tickets");
        io:println("3. 📋 My Tickets & Passes");
        io:println("4. 💰 Account & Top-up");
        io:println("5. 🔔 Notifications");
        io:println("6. 📊 My Travel History");
        io:println("7. ❌ Cancel/Refund Tickets");
        io:println("8. ⚙️  Account Settings");
        io:println("9. 🚪 Logout");
        
        string choice = io:readln("Choose option (1-9): ");
        
        match choice {
            "1" => {
                check browseRoutesAndTrips();
            }
            "2" => {
                check purchaseTicketsMenu(loggedUser.id);
            }
            "3" => {
                check showMyTickets(loggedUser.id);
            }
            "4" => {
                check accountAndTopupMenu(loggedUser.id);
            }
            "5" => {
                check showNotifications(loggedUser.id);
            }
            "6" => {
                check showTravelHistory(loggedUser.id);
            }
            "7" => {
                check cancelRefundMenu(loggedUser.id);
            }
            "8" => {
                check accountSettings(loggedUser.id);
            }
            "9" => {
                io:println("👋 Logged out successfully! Thank you for using our service.");
                currentUserId = 0;
                break;
            }
            _ => {
                io:println("❌ Invalid option! Please choose 1-9.");
            }
        }
    }
}

function browseRoutesAndTrips() returns error? {
    io:println("");
    io:println("🚌 ROUTES & TRIPS BROWSER 🚊");
    io:println("=============================");
    
    io:println("📍 Available Routes:");
    io:println("====================");
    
    foreach int i in 0 ..< routes.length() {
        Route route = routes[i];
        string statusIcon = route.status == "active" ? "✅" : (route.status == "disrupted" ? "⚠️" : "🔧");
        
        io:println((i + 1).toString() + ". " + statusIcon + " " + route.route_name + " (" + route.route_type.toUpperAscii() + ")");
        io:println("   📍 " + route.origin + " → " + route.destination);
        io:println("   💰 Base Fare: " + route.base_fare.toString() + " NAD");
        io:println("   📏 Distance: " + route.distance_km.toString() + " km");
        io:println("   ⏱️  Est. Duration: " + route.estimated_duration_minutes.toString() + " minutes");
        
        if route.status == "disrupted" && route.disruption_message is string {
            string disruptionMsg = <string>route.disruption_message;
            io:println("   ⚠️  DISRUPTION: " + disruptionMsg);
        }
        io:println("");
    }
    
    io:println("🚌 Upcoming Trips:");
    io:println("==================");
    
    int count = 0;
    foreach Trip trip in trips {
        Route? route = getRouteById(trip.route_id);
        if route is Route && route.is_active {
            count += 1;
            string statusIcon = getStatusIcon(trip.status);
            
            io:println(count.toString() + ". " + statusIcon + " Trip #" + trip.id.toString() + " - " + route.route_name);
            io:println("   🛣️  " + route.origin + " → " + route.destination);
            io:println("   🕒 " + trip.departure_time + " → " + trip.arrival_time);
            io:println("   🪑 Seats: " + trip.available_seats.toString() + "/" + trip.total_seats.toString());
            io:println("   🚐 Vehicle: " + trip.vehicle_number);
            io:println("   📊 Status: " + trip.status.toUpperAscii());
            
            if trip.delay_minutes is decimal {
                decimal delayValue = <decimal>trip.delay_minutes;
                if delayValue > 0.0d {
                    io:println("   ⏰ Delayed by: " + delayValue.toString() + " minutes");
                }
            }
            
            if trip.status_message is string {
                string statusMsg = <string>trip.status_message;
                io:println("   💬 " + statusMsg);
            }
            io:println("");
        }
    }
    
    if count == 0 {
        io:println("📅 No active trips available at the moment.");
    }
}

function purchaseTicketsMenu(int userId) returns error? {
    io:println("");
    io:println("🎟️  TICKET PURCHASE MENU");
    io:println("========================");
    
    io:println("Available Ticket Types:");
    io:println("1. 🎫 Single Ride Ticket");
    io:println("2. 🎟️  Multi-Ride Package (5 or 10 rides)");
    io:println("3. 📅 Daily Pass (Unlimited rides for 24 hours)");
    io:println("4. 📆 Weekly Pass (Unlimited rides for 7 days)");
    io:println("5. 🗓️  Monthly Pass (Unlimited rides for 30 days)");
    io:println("6. ⬅️  Back to Dashboard");
    
    string choice = io:readln("Choose ticket type (1-6): ");
    
    match choice {
        "1" => {
            check purchaseSingleRideTicket(userId);
        }
        "2" => {
            check purchaseMultiRidePackage(userId);
        }
        "3" => {
            check purchasePass(userId, "daily_pass");
        }
        "4" => {
            check purchasePass(userId, "weekly_pass");
        }
        "5" => {
            check purchasePass(userId, "monthly_pass");
        }
        "6" => {
            return;
        }
        _ => {
            io:println("❌ Invalid option!");
        }
    }
}

function purchaseSingleRideTicket(int userId) returns error? {
    io:println("");
    io:println("🎫 SINGLE RIDE TICKET PURCHASE");
    io:println("===============================");
    
    check browseRoutesAndTrips();
    
    string tripIdInput = io:readln("Enter Trip ID to purchase (or 'back' to return): ");
    
    if tripIdInput.toLowerAscii() == "back" {
        return;
    }
    
    int|error tripIdResult = int:fromString(tripIdInput);
    if tripIdResult is error {
        io:println("❌ Invalid Trip ID! Please enter a valid number.");
        return;
    }
    
    int tripId = tripIdResult;
    
    Trip? selectedTrip = getTripById(tripId);
    if selectedTrip is () {
        io:println("❌ Trip not found!");
        return;
    }
    
    Trip trip = selectedTrip;
    Route? selectedRoute = getRouteById(trip.route_id);
    if selectedRoute is () {
        io:println("❌ Route not found!");
        return;
    }
    
    Route route = selectedRoute;
    
    if trip.status != "scheduled" && trip.status != "boarding" {
        io:println("❌ Trip is not available for booking! Status: " + trip.status);
        return;
    }
    
    if trip.available_seats <= 0 {
        io:println("❌ Sorry, this trip is fully booked!");
        return;
    }
    
    decimal ticketPrice = route.base_fare;
    decimal currentBalance = getCurrentUserBalance(userId);
    
    if currentBalance < ticketPrice {
        io:println("❌ Insufficient balance!");
        io:println("Required: " + ticketPrice.toString() + " NAD");
        io:println("Your balance: " + currentBalance.toString() + " NAD");
        io:println("💡 Please top up your account first.");
        return;
    }
    
    io:println("");
    io:println("📋 TICKET PURCHASE SUMMARY");
    io:println("===========================");
    io:println("🛣️  Route: " + route.route_name);
    io:println("📍 " + route.origin + " → " + route.destination);
    io:println("🕒 Departure: " + trip.departure_time);
    io:println("🚐 Vehicle: " + trip.vehicle_number);
    io:println("💰 Price: " + ticketPrice.toString() + " NAD");
    io:println("💳 Your balance: " + currentBalance.toString() + " NAD");
    io:println("💵 New balance will be: " + (currentBalance - ticketPrice).toString() + " NAD");
    io:println("");
    
    string confirm = io:readln("Confirm purchase? (y/n): ");
    if confirm.toLowerAscii() == "y" {
        string validationCode = generateValidationCode();
        string expiresAt = calculateTicketExpiry("single");
        
        Ticket newTicket = {
            id: nextTicketId,
            user_id: userId,
            trip_id: tripId,
            ticket_type: "single",
            status: "paid",
            purchase_price: ticketPrice,
            refund_amount: (),
            purchased_at: getCurrentTimestamp(),
            expires_at: expiresAt,
            validated_at: (),
            cancelled_at: (),
            refunded_at: (),
            validation_code: validationCode,
            rides_remaining: (),
            total_rides: (),
            cancellation_reason: ()
        };
        
        tickets.push(newTicket);
        nextTicketId += 1;
        
        updateUserBalance(userId, currentBalance - ticketPrice);
        recordTransaction(userId, "purchase", ticketPrice, currentBalance, currentBalance - ticketPrice, "Single ride ticket for " + route.route_name, newTicket.id);
        updateTripSeats(tripId, trip.available_seats - 1);
        
        io:println("");
        io:println("✅ TICKET PURCHASED SUCCESSFULLY!");
        io:println("🎟️  Ticket ID: " + newTicket.id.toString());
        io:println("🎫 Validation Code: " + validationCode);
        io:println("📅 Expires: " + expiresAt);
        io:println("💰 New Balance: " + (currentBalance - ticketPrice).toString() + " NAD");
        io:println("📱 Your ticket is ready for validation on boarding!");
        io:println("");
        io:println("⚠️  IMPORTANT: Save your validation code: " + validationCode);
    } else {
        io:println("❌ Purchase cancelled.");
    }
}

function purchaseMultiRidePackage(int userId) returns error? {
    io:println("");
    io:println("🎟️  MULTI-RIDE PACKAGE PURCHASE");
    io:println("================================");
    
    io:println("Available packages:");
    io:println("1. 5-Ride Package (10% discount)");
    io:println("2. 10-Ride Package (15% discount)");
    
    string choice = io:readln("Choose package (1-2): ");
    
    int rides = choice == "1" ? 5 : (choice == "2" ? 10 : 0);
    if rides == 0 {
        io:println("❌ Invalid choice!");
        return;
    }
    
    io:println("");
    io:println("Select route for package pricing:");
    foreach int i in 0 ..< routes.length() {
        Route route = routes[i];
        if route.is_active {
            decimal multiplier = rides == 5 ? <decimal>ticketPrices["multi_ride_5"] : <decimal>ticketPrices["multi_ride_10"];
            decimal packagePrice = route.base_fare * multiplier;
            decimal savings = (route.base_fare * <decimal>rides) - packagePrice;
            
            io:println((i + 1).toString() + ". " + route.route_name);
            io:println("   💰 Package Price: " + packagePrice.toString() + " NAD");
            io:println("   💵 You Save: " + savings.toString() + " NAD");
            io:println("");
        }
    }
    
    string routeChoice = io:readln("Enter route number: ");
    int|error routeIndex = int:fromString(routeChoice);
    if routeIndex is error || routeIndex < 1 || routeIndex > routes.length() {
        io:println("❌ Invalid route selection!");
        return;
    }
    
    Route selectedRoute = routes[routeIndex - 1];
    decimal multiplier = rides == 5 ? <decimal>ticketPrices["multi_ride_5"] : <decimal>ticketPrices["multi_ride_10"];
    decimal packagePrice = selectedRoute.base_fare * multiplier;
    decimal currentBalance = getCurrentUserBalance(userId);
    
    if currentBalance < packagePrice {
        io:println("❌ Insufficient balance!");
        io:println("Required: " + packagePrice.toString() + " NAD");
        io:println("Your balance: " + currentBalance.toString() + " NAD");
        return;
    }
    
    string confirm = io:readln("Confirm purchase of " + rides.toString() + "-ride package for " + packagePrice.toString() + " NAD? (y/n): ");
    if confirm.toLowerAscii() == "y" {
        string validationCode = generateValidationCode();
        string expiresAt = calculateTicketExpiry(rides == 5 ? "multi_ride_5" : "multi_ride_10");
        
        Ticket newTicket = {
            id: nextTicketId,
            user_id: userId,
            trip_id: (),
            ticket_type: rides == 5 ? "multi_ride_5" : "multi_ride_10",
            status: "paid",
            purchase_price: packagePrice,
            refund_amount: (),
            purchased_at: getCurrentTimestamp(),
            expires_at: expiresAt,
            validated_at: (),
            cancelled_at: (),
            refunded_at: (),
            validation_code: validationCode,
            rides_remaining: rides,
            total_rides: rides,
            cancellation_reason: ()
        };
        
        tickets.push(newTicket);
        nextTicketId += 1;
        
        updateUserBalance(userId, currentBalance - packagePrice);
        recordTransaction(userId, "purchase", packagePrice, currentBalance, currentBalance - packagePrice, rides.toString() + "-ride package for " + selectedRoute.route_name, newTicket.id);
        
        io:println("");
        io:println("✅ MULTI-RIDE PACKAGE PURCHASED!");
        io:println("🎟️  Ticket ID: " + newTicket.id.toString());
        io:println("🎫 Validation Code: " + validationCode);
        io:println("🚌 Rides Remaining: " + rides.toString());
        io:println("📅 Expires: " + expiresAt);
        io:println("💰 New Balance: " + (currentBalance - packagePrice).toString() + " NAD");
    }
}

function purchasePass(int userId, string passType) returns error? {
    io:println("");
    string passTitle = passType == "daily_pass" ? "DAILY PASS" : 
                      passType == "weekly_pass" ? "WEEKLY PASS" : "MONTHLY PASS";
    io:println("📅 " + passTitle + " PURCHASE");
    io:println("========================");
    
    decimal passPrice = <decimal>ticketPrices[passType];
    decimal currentBalance = getCurrentUserBalance(userId);
    
    string duration = passType == "daily_pass" ? "24 hours" : 
                     passType == "weekly_pass" ? "7 days" : "30 days";
    
    io:println("🎫 " + passTitle);
    io:println("⏰ Duration: " + duration);
    io:println("💰 Price: " + passPrice.toString() + " NAD");
    io:println("🚌 Unlimited rides on all active routes");
    io:println("");
    
    if currentBalance < passPrice {
        io:println("❌ Insufficient balance!");
        io:println("Required: " + passPrice.toString() + " NAD");
        io:println("Your balance: " + currentBalance.toString() + " NAD");
        return;
    }
    
    string confirm = io:readln("Confirm purchase? (y/n): ");
    if confirm.toLowerAscii() == "y" {
        string validationCode = generateValidationCode();
        string expiresAt = calculateTicketExpiry(passType);
        
        Ticket newTicket = {
            id: nextTicketId,
            user_id: userId,
            trip_id: (),
            ticket_type: passType,
            status: "paid",
            purchase_price: passPrice,
            refund_amount: (),
            purchased_at: getCurrentTimestamp(),
            expires_at: expiresAt,
            validated_at: (),
            cancelled_at: (),
            refunded_at: (),
            validation_code: validationCode,
            rides_remaining: (),
            total_rides: (),
            cancellation_reason: ()
        };
        
        tickets.push(newTicket);
        nextTicketId += 1;
        
        updateUserBalance(userId, currentBalance - passPrice);
        recordTransaction(userId, "purchase", passPrice, currentBalance, currentBalance - passPrice, passTitle, newTicket.id);
        
        io:println("");
        io:println("✅ " + passTitle + " PURCHASED!");
        io:println("🎟️  Pass ID: " + newTicket.id.toString());
        io:println("🎫 Validation Code: " + validationCode);
        io:println("📅 Valid until: " + expiresAt);
        io:println("💰 New Balance: " + (currentBalance - passPrice).toString() + " NAD");
    }
}

function showMyTickets(int userId) returns error? {
    io:println("");
    io:println("📋 MY TICKETS & PASSES");
    io:println("======================");
    
    Ticket[] userTickets = [];
    foreach Ticket ticket in tickets {
        if ticket.user_id == userId {
            userTickets.push(ticket);
        }
    }
    
    if userTickets.length() == 0 {
        io:println("📭 No tickets found.");
        io:println("Purchase your first ticket to see it here!");
        return;
    }
    
    // Group tickets by status
    Ticket[] activeTickets = [];
    Ticket[] usedTickets = [];
    Ticket[] expiredCancelledTickets = [];
    
    foreach Ticket ticket in userTickets {
        if ticket.status == "paid" || ticket.status == "validated" {
            activeTickets.push(ticket);
        } else if ticket.status == "used" {
            usedTickets.push(ticket);
        } else {
            expiredCancelledTickets.push(ticket);
        }
    }
    
    if activeTickets.length() > 0 {
        io:println("✅ ACTIVE TICKETS & PASSES:");
        io:println("============================");
        foreach int i in 0 ..< activeTickets.length() {
            check displayTicketDetails(activeTickets[i], i + 1);
        }
    }
    
    if usedTickets.length() > 0 {
        io:println("📋 USED TICKETS:");
        io:println("================");
        foreach int i in 0 ..< usedTickets.length() {
            check displayTicketDetails(usedTickets[i], i + 1);
        }
    }
    
    if expiredCancelledTickets.length() > 0 {
        io:println("❌ EXPIRED/CANCELLED TICKETS:");
        io:println("=============================");
        foreach int i in 0 ..< expiredCancelledTickets.length() {
            check displayTicketDetails(expiredCancelledTickets[i], i + 1);
        }
    }
}

function displayTicketDetails(Ticket ticket, int index) returns error? {
    string statusIcon = ticket.status == "paid" ? "💰" : 
                       ticket.status == "validated" ? "✅" : 
                       ticket.status == "used" ? "📋" : 
                       ticket.status == "expired" ? "⏰" : 
                       ticket.status == "cancelled" ? "❌" : "❓";
    
    io:println(index.toString() + ". " + statusIcon + " Ticket #" + ticket.id.toString());
    io:println("   🎫 Type: " + ticket.ticket_type.toUpperAscii());
    io:println("   📊 Status: " + ticket.status.toUpperAscii());
    
    if ticket.trip_id is int {
        int tripId = <int>ticket.trip_id;
        Trip? trip = getTripById(tripId);
        Route? route = trip is Trip ? getRouteById(trip.route_id) : ();
        if route is Route {
            io:println("   🛣️  Route: " + route.route_name);
            io:println("   📍 " + route.origin + " → " + route.destination);
        }
        if trip is Trip {
            io:println("   🕒 Departure: " + trip.departure_time);
        }
    }
    
    io:println("   💰 Price: " + ticket.purchase_price.toString() + " NAD");
    io:println("   🎫 Validation Code: " + ticket.validation_code);
    
    if ticket.rides_remaining is int && ticket.total_rides is int {
        int remaining = <int>ticket.rides_remaining;
        int total = <int>ticket.total_rides;
        io:println("   🚌 Rides: " + remaining.toString() + "/" + total.toString() + " remaining");
    }
    
    io:println("   📅 Purchased: " + ticket.purchased_at);
    io:println("   ⏰ Expires: " + ticket.expires_at);
    
    if ticket.validated_at is string {
        string validatedTime = <string>ticket.validated_at;
        io:println("   ✅ Validated: " + validatedTime);
    }
    
    if ticket.cancelled_at is string {
        string cancelledTime = <string>ticket.cancelled_at;
        io:println("   ❌ Cancelled: " + cancelledTime);
    }
    
    if ticket.cancellation_reason is string {
        string reason = <string>ticket.cancellation_reason;
        io:println("   💬 Reason: " + reason);
    }
    
    io:println("");
}

function accountAndTopupMenu(int userId) returns error? {
    io:println("");
    io:println("💰 ACCOUNT & TOP-UP MENU");
    io:println("========================");
    
    decimal currentBalance = getCurrentUserBalance(userId);
    io:println("💳 Current Balance: " + currentBalance.toString() + " NAD");
    io:println("");
    
    io:println("Options:");
    io:println("1. 💰 Top-up Account");
    io:println("2. 💳 View Balance History");
    io:println("3. 📊 Transaction History");
    io:println("4. ⬅️  Back to Dashboard");
    
    string choice = io:readln("Choose option (1-4): ");
    
    match choice {
        "1" => {
            check topUpAccount(userId);
        }
        "2" => {
            io:println("💳 Your current balance: " + currentBalance.toString() + " NAD");
        }
        "3" => {
            check showTransactionHistory(userId);
        }
        "4" => {
            return;
        }
        _ => {
            io:println("❌ Invalid option!");
        }
    }
}

function topUpAccount(int userId) returns error? {
    io:println("");
    io:println("💰 ACCOUNT TOP-UP");
    io:println("==================");
    
    decimal currentBalance = getCurrentUserBalance(userId);
    io:println("💳 Current Balance: " + currentBalance.toString() + " NAD");
    io:println("");
    
    io:println("Quick top-up amounts:");
    io:println("1. 50 NAD");
    io:println("2. 100 NAD");
    io:println("3. 200 NAD");
    io:println("4. 500 NAD");
    io:println("5. Custom amount");
    
    string choice = io:readln("Choose option (1-5): ");
    
    decimal topupAmount = 0.0;
    
    match choice {
        "1" => { topupAmount = 50.0; }
        "2" => { topupAmount = 100.0; }
        "3" => { topupAmount = 200.0; }
        "4" => { topupAmount = 500.0; }
        "5" => {
            string customAmount = io:readln("Enter amount to top-up: ");
            decimal|error customAmountResult = decimal:fromString(customAmount);
            if customAmountResult is decimal && customAmountResult > 0.0d {
                topupAmount = customAmountResult;
            } else {
                io:println("❌ Invalid amount!");
                return;
            }
        }
        _ => {
            io:println("❌ Invalid choice!");
            return;
        }
    }
    
    if topupAmount <= 0.0d || topupAmount > 10000.0d {
        io:println("❌ Invalid top-up amount! Must be between 0.01 and 10,000 NAD.");
        return;
    }
    
    io:println("");
    io:println("📋 TOP-UP SUMMARY:");
    io:println("==================");
    io:println("💰 Amount: " + topupAmount.toString() + " NAD");
    io:println("💳 Current Balance: " + currentBalance.toString() + " NAD");
    io:println("💵 New Balance: " + (currentBalance + topupAmount).toString() + " NAD");
    io:println("");
    
    string confirm = io:readln("Confirm top-up? (y/n): ");
    if confirm.toLowerAscii() == "y" {
        io:println("💳 Processing payment...");
        
        updateUserBalance(userId, currentBalance + topupAmount);
        recordTransaction(userId, "topup", topupAmount, currentBalance, currentBalance + topupAmount, "Account top-up");
        
        io:println("");
        io:println("✅ TOP-UP SUCCESSFUL!");
        io:println("💰 Amount added: " + topupAmount.toString() + " NAD");
        io:println("💵 New Balance: " + (currentBalance + topupAmount).toString() + " NAD");
        io:println("🎟️  You can now purchase more tickets!");
    } else {
        io:println("❌ Top-up cancelled.");
    }
}

function cancelRefundMenu(int userId) returns error? {
    io:println("");
    io:println("❌ CANCEL/REFUND TICKETS");
    io:println("========================");
    
    Ticket[] cancellableTickets = [];
    foreach Ticket ticket in tickets {
        if ticket.user_id == userId && ticket.status == "paid" {
            cancellableTickets.push(ticket);
        }
    }
    
    if cancellableTickets.length() == 0 {
        io:println("📭 No tickets available for cancellation.");
        io:println("Only paid tickets can be cancelled.");
        return;
    }
    
    io:println("📋 CANCELLABLE TICKETS:");
    io:println("=======================");
    
    foreach int i in 0 ..< cancellableTickets.length() {
        Ticket ticket = cancellableTickets[i];
        io:println((i + 1).toString() + ". Ticket #" + ticket.id.toString());
        io:println("   🎫 Type: " + ticket.ticket_type.toUpperAscii());
        io:println("   💰 Paid: " + ticket.purchase_price.toString() + " NAD");
        
        decimal refundAmount = ticket.purchase_price * 0.9;
        io:println("   💵 Refund: " + refundAmount.toString() + " NAD (10% cancellation fee)");
        
        if ticket.trip_id is int {
            int tripId = <int>ticket.trip_id;
            Trip? trip = getTripById(tripId);
            if trip is Trip {
                Route? route = getRouteById(trip.route_id);
                if route is Route {
                    io:println("   🛣️  Route: " + route.route_name);
                    io:println("   🕒 Departure: " + trip.departure_time);
                }
            }
        }
        io:println("");
    }
    
    string ticketChoice = io:readln("Enter ticket number to cancel (or 'back'): ");
    if ticketChoice.toLowerAscii() == "back" {
        return;
    }
    
    int|error ticketIndex = int:fromString(ticketChoice);
    if ticketIndex is error || ticketIndex < 1 || ticketIndex > cancellableTickets.length() {
        io:println("❌ Invalid ticket selection!");
        return;
    }
    
    Ticket selectedTicket = cancellableTickets[ticketIndex - 1];
    decimal refundAmount = selectedTicket.purchase_price * 0.9;
    decimal cancellationFee = selectedTicket.purchase_price * 0.1;
    
    io:println("");
    io:println("📋 CANCELLATION SUMMARY:");
    io:println("========================");
    io:println("🎫 Ticket #" + selectedTicket.id.toString());
    io:println("💰 Original Price: " + selectedTicket.purchase_price.toString() + " NAD");
    io:println("💵 Refund Amount: " + refundAmount.toString() + " NAD");
    io:println("💸 Cancellation Fee: " + cancellationFee.toString() + " NAD");
    io:println("");
    
    string reason = io:readln("Reason for cancellation: ");
    string confirm = io:readln("Confirm cancellation? (y/n): ");
    
    if confirm.toLowerAscii() == "y" {
        // Process cancellation
        foreach int i in 0 ..< tickets.length() {
            if tickets[i].id == selectedTicket.id {
                tickets[i].status = "cancelled";
                tickets[i].cancelled_at = getCurrentTimestamp();
                tickets[i].cancellation_reason = reason;
                tickets[i].refund_amount = refundAmount;
                break;
            }
        }
        
        decimal currentBalance = getCurrentUserBalance(userId);
        updateUserBalance(userId, currentBalance + refundAmount);
        
        recordTransaction(userId, "refund", refundAmount, currentBalance, currentBalance + refundAmount, "Ticket cancellation refund", selectedTicket.id);
        recordTransaction(userId, "cancellation_fee", cancellationFee, currentBalance + refundAmount, currentBalance + refundAmount, "Cancellation fee", selectedTicket.id);
        
        if selectedTicket.trip_id is int {
            int tripId = <int>selectedTicket.trip_id;
            Trip? trip = getTripById(tripId);
            if trip is Trip {
                updateTripSeats(tripId, trip.available_seats + 1);
            }
        }
        
        io:println("");
        io:println("✅ TICKET CANCELLED SUCCESSFULLY!");
        io:println("💵 Refund Amount: " + refundAmount.toString() + " NAD");
        io:println("💰 New Balance: " + (currentBalance + refundAmount).toString() + " NAD");
        io:println("📧 Cancellation confirmation will be sent to your email.");
    } else {
        io:println("❌ Cancellation aborted.");
    }
}

function showNotifications(int userId) returns error? {
    io:println("");
    io:println("🔔 NOTIFICATIONS");
    io:println("================");
    
    Notification[] userNotifications = [];
    foreach Notification notification in notifications {
        if notification.user_id == userId {
            userNotifications.push(notification);
        }
    }
    
    if userNotifications.length() == 0 {
        io:println("📭 No notifications.");
        return;
    }
    
    Notification[] unreadNotifications = [];
    Notification[] readNotifications = [];
    
    foreach Notification notification in userNotifications {
        if notification.is_read {
            readNotifications.push(notification);
        } else {
            unreadNotifications.push(notification);
        }
    }
    
    if unreadNotifications.length() > 0 {
        io:println("🆕 UNREAD NOTIFICATIONS:");
        io:println("========================");
        foreach int i in 0 ..< unreadNotifications.length() {
            check displayNotification(unreadNotifications[i], i + 1);
            markNotificationAsRead(unreadNotifications[i].id);
        }
    }
    
    if readNotifications.length() > 0 {
        io:println("📋 READ NOTIFICATIONS:");
        io:println("======================");
        foreach int i in 0 ..< readNotifications.length() {
            check displayNotification(readNotifications[i], i + 1);
        }
    }
}

function displayNotification(Notification notification, int index) returns error? {
    string typeIcon = notification.notification_type == "trip_delay" ? "⏰" :
                     notification.notification_type == "trip_cancellation" ? "❌" :
                     notification.notification_type == "route_disruption" ? "⚠️" :
                     notification.notification_type == "ticket_expiry" ? "📅" :
                     notification.notification_type == "low_balance" ? "💰" : "🔔";
    
    io:println(index.toString() + ". " + typeIcon + " " + notification.title);
    io:println("   💬 " + notification.message);
    io:println("   📅 " + notification.timestamp);
    if !notification.is_read {
        io:println("   🆕 NEW");
    }
    io:println("");
}

function showTransactionHistory(int userId) returns error? {
    io:println("");
    io:println("📊 TRANSACTION HISTORY");
    io:println("=======================");
    
    Transaction[] userTransactions = [];
    foreach Transaction txn in transactions {
        if txn.user_id == userId {
            userTransactions.push(txn);
        }
    }
    
    if userTransactions.length() == 0 {
        io:println("📤 No transactions found.");
        return;
    }
    
    foreach int i in 0 ..< userTransactions.length() {
        Transaction txn = userTransactions[i];
        string typeIcon = txn.transaction_type == "purchase" ? "🛒" :
                         txn.transaction_type == "topup" ? "💰" :
                         txn.transaction_type == "refund" ? "💵" : "💸";
        
        io:println((i + 1).toString() + ". " + typeIcon + " " + txn.transaction_type.toUpperAscii());
        io:println("   💰 Amount: " + txn.amount.toString() + " NAD");
        io:println("   📊 Balance: " + txn.balance_before.toString() + " → " + txn.balance_after.toString() + " NAD");
        io:println("   💬 " + txn.description);
        io:println("   📅 " + txn.timestamp);
        io:println("");
    }
}

function showTravelHistory(int userId) returns error? {
    io:println("");
    io:println("📊 MY TRAVEL HISTORY");
    io:println("====================");
    
    Ticket[] userTickets = [];
    foreach Ticket ticket in tickets {
        if ticket.user_id == userId && (ticket.status == "validated" || ticket.status == "used") {
            userTickets.push(ticket);
        }
    }
    
    if userTickets.length() == 0 {
        io:println("📭 No travel history found.");
        return;
    }
    
    foreach int i in 0 ..< userTickets.length() {
        Ticket ticket = userTickets[i];
        string tripIdStr = ticket.trip_id is () ? "N/A" : (<int>ticket.trip_id).toString();
        io:println((i + 1).toString() + ". 🚌 Trip #" + tripIdStr);
        
        if ticket.trip_id is int {
            int tripId = <int>ticket.trip_id;
            Trip? trip = getTripById(tripId);
            Route? route = trip is Trip ? getRouteById(trip.route_id) : ();
            if route is Route {
                io:println("   🛣️  Route: " + route.route_name);
                io:println("   📍 " + route.origin + " → " + route.destination);
            }
        }
        
        io:println("   💰 Fare: " + ticket.purchase_price.toString() + " NAD");
        string validatedTime = ticket.validated_at is () ? "Unknown" : <string>ticket.validated_at;
        io:println("   📅 Date: " + validatedTime);
        io:println("");
    }
}

function showSystemStatus() returns error? {
    io:println("");
    io:println("📊 SYSTEM STATUS");
    io:println("================");
    
    io:println("🛣️  ROUTE STATUS:");
    io:println("=================");
    foreach Route route in routes {
        string statusIcon = route.status == "active" ? "✅" : 
                           route.status == "disrupted" ? "⚠️" : "🔧";
        
        io:println(statusIcon + " " + route.route_name);
        if route.status == "disrupted" && route.disruption_message is string {
            string disruptionMsg = <string>route.disruption_message;
            io:println("  ⚠️  " + disruptionMsg);
        }
    }
    
    io:println("");
    io:println("🚌 CURRENT TRIP STATUS:");
    io:println("=======================");
    foreach Trip trip in trips {
        Route? route = getRouteById(trip.route_id);
        if route is Route {
            string statusIcon = getStatusIcon(trip.status);
            io:println(statusIcon + " Trip #" + trip.id.toString() + " - " + route.route_name);
            if trip.delay_minutes is decimal {
                decimal delayValue = <decimal>trip.delay_minutes;
                if delayValue > 0.0d {
                    io:println("  ⏰ Delayed by " + delayValue.toString() + " minutes");
                }
            }
            if trip.status_message is string {
                string statusMsg = <string>trip.status_message;
                io:println("  💬 " + statusMsg);
            }
        }
    }
}

function accountSettings(int userId) returns error? {
    io:println("");
    io:println("⚙️  ACCOUNT SETTINGS");
    io:println("====================");
    
    User? user = getUserById(userId);
    if user is () {
        io:println("❌ User not found!");
        return;
    }
    
    User currentUser = user;
    
    io:println("Current Settings:");
    io:println("📧 Email: " + currentUser.email);
    string phoneStr = currentUser.phone is () ? "Not set" : <string>currentUser.phone;
    io:println("📱 Phone: " + phoneStr);
    io:println("🔔 Notifications: " + (currentUser.notifications_enabled ? "Enabled" : "Disabled"));
    io:println("");
    
    io:println("Options:");
    io:println("1. 📧 Update Email");
    io:println("2. 📱 Update Phone");
    io:println("3. 🔔 Toggle Notifications");
    io:println("4. 🔐 Change Password");
    io:println("5. ⬅️  Back to Dashboard");
    
    string choice = io:readln("Choose option (1-5): ");
    
    match choice {
        "1" => {
            string newEmail = io:readln("Enter new email: ");
            updateUserField(userId, "email", newEmail);
            io:println("✅ Email updated successfully!");
        }
        "2" => {
            string newPhone = io:readln("Enter new phone number: ");
            updateUserField(userId, "phone", newPhone);
            io:println("✅ Phone number updated successfully!");
        }
        "3" => {
            boolean newNotificationSetting = !currentUser.notifications_enabled;
            updateUserField(userId, "notifications_enabled", newNotificationSetting);
            io:println("✅ Notifications " + (newNotificationSetting ? "enabled" : "disabled") + "!");
        }
        "4" => {
            string currentPassword = io:readln("Enter current password: ");
            if currentPassword == currentUser.password {
                string newPassword = io:readln("Enter new password: ");
                string confirmPassword = io:readln("Confirm new password: ");
                if newPassword == confirmPassword {
                    updateUserField(userId, "password", newPassword);
                    io:println("✅ Password changed successfully!");
                } else {
                    io:println("❌ Passwords don't match!");
                }
            } else {
                io:println("❌ Current password incorrect!");
            }
        }
        "5" => {
            return;
        }
        _ => {
            io:println("❌ Invalid option!");
        }
    }
}

function startAdminPortal() returns error? {
    io:println("");
    io:println("👨‍💼 ENHANCED ADMIN PORTAL");
    io:println("===========================");
    
    string adminPassword = io:readln("Enter Admin Password: ");
    if adminPassword != "admin123" {
        io:println("❌ Access Denied! Incorrect password.");
        return;
    }
    
    io:println("✅ Admin Access Granted!");
    
    while true {
        io:println("");
        io:println("🎛️  ADMIN DASHBOARD:");
        io:println("===================");
        io:println("1. 🛣️  Route Management");
        io:println("2. 🚌 Trip Management");
        io:println("3. 👥 User Management");
        io:println("4. 🎟️  Ticket Management");
        io:println("5. 📊 Analytics & Reports");
        io:println("6. 🔔 Notifications & Alerts");
        io:println("7. 💰 Financial Management");
        io:println("8. 🚨 System Monitoring");
        io:println("9. ⬅️  Return to Main Menu");
        
        string choice = io:readln("Choose option (1-9): ");
        
        match choice {
            "1" => {
                io:println("🛣️  ROUTE MANAGEMENT - Feature available in enhanced version");
            }
            "2" => {
                io:println("🚌 TRIP MANAGEMENT - Feature available in enhanced version");
            }
            "3" => {
                io:println("👥 USER MANAGEMENT - Feature available in enhanced version");
            }
            "4" => {
                io:println("🎟️  TICKET MANAGEMENT - Feature available in enhanced version");
            }
            "5" => {
                check showSystemReports();
            }
            "6" => {
                io:println("🔔 NOTIFICATIONS & ALERTS - Feature available in enhanced version");
            }
            "7" => {
                io:println("💰 FINANCIAL MANAGEMENT - Feature available in enhanced version");
            }
            "8" => {
                check showSystemStatus();
            }
            "9" => {
                break;
            }
            _ => {
                io:println("❌ Invalid option! Please choose 1-9.");
            }
        }
    }
}

function showSystemReports() returns error? {
    io:println("");
    io:println("📊 SYSTEM REPORTS");
    io:println("=================");
    
    int userCount = users.length();
    int routeCount = 0;
    foreach Route route in routes {
        if route.is_active {
            routeCount += 1;
        }
    }
    
    int ticketCount = tickets.length();
    decimal totalRevenue = 0.0;
    foreach Ticket ticket in tickets {
        totalRevenue += ticket.purchase_price;
    }
    
    io:println("👥 Total Users: " + userCount.toString());
    io:println("🛣️  Active Routes: " + routeCount.toString());
    io:println("🎟️  Total Tickets Sold: " + ticketCount.toString());
    io:println("💰 Total Revenue: " + totalRevenue.toString() + " NAD");
    io:println("");
    io:println("📈 System is operational and serving customers!");
}

function startValidatorPortal() returns error? {
    io:println("");
    io:println("✅ ENHANCED VALIDATOR PORTAL");
    io:println("=============================");
    
    while true {
        io:println("");
        io:println("Validator Options:");
        io:println("1. 🎫 Validate Ticket/Pass");
        io:println("2. 📋 Validation History");
        io:println("3. 🚌 Current Trip Status");
        io:println("4. 📊 Daily Validation Report");
        io:println("5. ⬅️  Return to Main Menu");
        
        string choice = io:readln("Choose option (1-5): ");
        
        match choice {
            "1" => {
                check validateTicketByCode();
            }
            "2" => {
                io:println("📋 VALIDATION HISTORY - Enhanced validator features");
            }
            "3" => {
                io:println("🚌 CURRENT TRIP STATUS - Enhanced validator features");
            }
            "4" => {
                io:println("📊 DAILY VALIDATION REPORT - Enhanced validator features");
            }
            "5" => {
                break;
            }
            _ => {
                io:println("❌ Invalid option! Please choose 1-5.");
            }
        }
    }
}

function validateTicketByCode() returns error? {
    io:println("");
    io:println("🎫 TICKET/PASS VALIDATION");
    io:println("==========================");
    
    string validationCode = io:readln("Enter/Scan Validation Code: ");
    
    Ticket? foundTicket = ();
    foreach Ticket ticket in tickets {
        if ticket.validation_code == validationCode {
            foundTicket = ticket;
            break;
        }
    }
    
    if foundTicket is () {
        io:println("❌ Invalid validation code! Ticket not found.");
        return;
    }
    
    Ticket ticket = foundTicket;
    User? user = getUserById(ticket.user_id);
    
    if user is () {
        io:println("❌ User not found!");
        return;
    }
    
    User passenger = user;
    
    io:println("");
    io:println("📋 TICKET/PASS DETAILS");
    io:println("======================");
    io:println("🎫 Ticket ID: " + ticket.id.toString());
    io:println("👤 Passenger: " + passenger.username);
    io:println("🎟️  Type: " + ticket.ticket_type.toUpperAscii());
    io:println("📊 Current Status: " + ticket.status.toUpperAscii());
    
    if ticket.trip_id is int {
        int tripId = <int>ticket.trip_id;
        Trip? trip = getTripById(tripId);
        Route? route = trip is Trip ? getRouteById(trip.route_id) : ();
        if route is Route && trip is Trip {
            io:println("🛣️  Route: " + route.route_name);
            io:println("📍 " + route.origin + " → " + route.destination);
            io:println("🕒 Departure: " + trip.departure_time);
        }
    }
    
    io:println("💰 Price: " + ticket.purchase_price.toString() + " NAD");
    io:println("📅 Expires: " + ticket.expires_at);
    
    if ticket.rides_remaining is int && ticket.total_rides is int {
        int remaining = <int>ticket.rides_remaining;
        int total = <int>ticket.total_rides;
        io:println("🚌 Rides Remaining: " + remaining.toString() + "/" + total.toString());
    }
    
    io:println("");
    
    // Check ticket validity
    if ticket.status == "cancelled" || ticket.status == "refunded" {
        io:println("❌ This ticket has been cancelled or refunded!");
        if ticket.cancelled_at is string {
            string cancelledTime = <string>ticket.cancelled_at;
            io:println("📅 Cancelled on: " + cancelledTime);
        }
        if ticket.cancellation_reason is string {
            string reason = <string>ticket.cancellation_reason;
            io:println("💬 Reason: " + reason);
        }
        return;
    }
    
    if ticket.status == "expired" {
        io:println("❌ This ticket has expired!");
        return;
    }
    
    if ticket.expires_at < getCurrentTimestamp() {
        foreach int i in 0 ..< tickets.length() {
            if tickets[i].id == ticket.id {
                tickets[i].status = "expired";
                break;
            }
        }
        io:println("❌ This ticket has expired!");
        return;
    }
    
    if ticket.status == "paid" || ticket.status == "validated" {
        if ticket.ticket_type == "single" {
            if ticket.status == "validated" {
                io:println("⚠️  This single-ride ticket has already been validated!");
                return;
            }
            
            string confirm = io:readln("Validate this single-ride ticket? (y/n): ");
            if confirm.toLowerAscii() == "y" {
                foreach int i in 0 ..< tickets.length() {
                    if tickets[i].id == ticket.id {
                        tickets[i].status = "used";
                        tickets[i].validated_at = getCurrentTimestamp();
                        break;
                    }
                }
                
                io:println("");
                io:println("✅ SINGLE-RIDE TICKET VALIDATED!");
                io:println("🎉 Welcome aboard, " + passenger.username + "!");
                io:println("🚌 Have a safe journey!");
                io:println("📋 This ticket is now used and cannot be used again.");
            }
        } else if ticket.ticket_type.startsWith("multi_ride") {
            if ticket.rides_remaining is int && ticket.rides_remaining > 0 {
                string confirm = io:readln("Use one ride from this multi-ride package? (y/n): ");
                if confirm.toLowerAscii() == "y" {
                    foreach int i in 0 ..< tickets.length() {
                        if tickets[i].id == ticket.id {
                            if tickets[i].rides_remaining is int {
                                tickets[i].rides_remaining = tickets[i].rides_remaining - 1;
                            }
                            tickets[i].validated_at = getCurrentTimestamp();
                            if tickets[i].rides_remaining is int && tickets[i].rides_remaining <= 0 {
                                tickets[i].status = "used";
                            } else {
                                tickets[i].status = "validated";
                            }
                            break;
                        }
                    }
                    
                    int remainingRides = ticket.rides_remaining is () ? 0 : <int>ticket.rides_remaining - 1;
                    io:println("");
                    io:println("✅ MULTI-RIDE TICKET VALIDATED!");
                    io:println("🎉 Welcome aboard, " + passenger.username + "!");
                    io:println("🚌 Rides remaining: " + remainingRides.toString());
                    if remainingRides == 0 {
                        io:println("📋 This was your last ride on this package!");
                    }
                }
            } else {
                io:println("❌ No rides remaining on this multi-ride package!");
            }
        } else {
            string confirm = io:readln("Validate this " + ticket.ticket_type + "? (y/n): ");
            if confirm.toLowerAscii() == "y" {
                foreach int i in 0 ..< tickets.length() {
                    if tickets[i].id == ticket.id {
                        tickets[i].status = "validated";
                        tickets[i].validated_at = getCurrentTimestamp();
                        break;
                    }
                }
                
                io:println("");
                io:println("✅ " + ticket.ticket_type.toUpperAscii() + " VALIDATED!");
                io:println("🎉 Welcome aboard, " + passenger.username + "!");
                io:println("🚌 Your pass is valid until: " + ticket.expires_at);
            }
        }
    } else {
        io:println("❌ This ticket is not ready for validation (Status: " + ticket.status + ")");
    }
}

// Helper functions
function getCurrentTimestamp() returns string {
    return "2024-01-15 " + getCurrentTime();
}

function getCurrentTime() returns string {
    return "15:45:00";
}

function generateValidationCode() returns string {
    return "VAL-" + nextTicketId.toString() + "-" + uuid:createType1AsString().substring(0, 8);
}

function calculateTicketExpiry(string ticketType) returns string {
    match ticketType {
        "single" => { return "2024-01-16 23:59:59"; }
        "multi_ride_5"|"multi_ride_10" => { return "2024-02-15 23:59:59"; }
        "daily_pass" => { return "2024-01-16 23:59:59"; }
        "weekly_pass" => { return "2024-01-22 23:59:59"; }
        "monthly_pass" => { return "2024-02-15 23:59:59"; }
        _ => { return "2024-01-16 23:59:59"; }
    }
}

function getRouteById(int routeId) returns Route? {
    foreach Route route in routes {
        if route.id == routeId {
            return route;
        }
    }
    return ();
}

function getTripById(int tripId) returns Trip? {
    foreach Trip trip in trips {
        if trip.id == tripId {
            return trip;
        }
    }
    return ();
}

function getUserById(int userId) returns User? {
    foreach User user in users {
        if user.id == userId {
            return user;
        }
    }
    return ();
}

function getCurrentUserBalance(int userId) returns decimal {
    User? user = getUserById(userId);
    return user?.balance ?: 0.0;
}

function updateUserBalance(int userId, decimal newBalance) {
    foreach int i in 0 ..< users.length() {
        if users[i].id == userId {
            users[i].balance = newBalance;
            break;
        }
    }
}

function updateUserField(int userId, string fieldName, anydata newValue) {
    foreach int i in 0 ..< users.length() {
        if users[i].id == userId {
            match fieldName {
                "email" => { users[i].email = <string>newValue; }
                "phone" => { users[i].phone = <string>newValue; }
                "notifications_enabled" => { users[i].notifications_enabled = <boolean>newValue; }
                "password" => { users[i].password = <string>newValue; }
            }
            break;
        }
    }
}

function updateTripSeats(int tripId, int newSeats) {
    foreach int i in 0 ..< trips.length() {
        if trips[i].id == tripId {
            trips[i].available_seats = newSeats;
            break;
        }
    }
}

function recordTransaction(int userId, string transactionType, decimal amount, decimal balanceBefore, decimal balanceAfter, string description, int? ticketId = ()) {
    Transaction newTransaction = {
        id: nextTransactionId,
        user_id: userId,
        transaction_type: transactionType,
        amount: amount,
        balance_before: balanceBefore,
        balance_after: balanceAfter,
        description: description,
        timestamp: getCurrentTimestamp(),
        status: "completed",
        ticket_id: ticketId
    };
    
    transactions.push(newTransaction);
    nextTransactionId += 1;
}

function getStatusIcon(string status) returns string {
    match status {
        "scheduled" => { return "📅"; }
        "boarding" => { return "🚌"; }
        "in_transit" => { return "🛤️"; }
        "completed" => { return "✅"; }
        "cancelled" => { return "❌"; }
        "delayed" => { return "⏰"; }
        _ => { return "❓"; }
    }
}

function getUnreadNotificationsCount(int userId) returns int {
    int count = 0;
    foreach Notification notification in notifications {
        if notification.user_id == userId && !notification.is_read {
            count += 1;
        }
    }
    return count;
}

function markNotificationAsRead(int notificationId) {
    foreach int i in 0 ..< notifications.length() {
        if notifications[i].id == notificationId {
            notifications[i].is_read = true;
            break;
        }
    }
}

function initializeSampleNotifications() {
    Notification[] sampleNotifications = [
        {id: 1, user_id: 1, notification_type: "trip_delay", title: "Trip Delay", message: "Your trip on City Center Express is delayed by 15 minutes", timestamp: "2024-01-15 14:00:00", is_read: false, related_trip_id: 2, related_route_id: ()},
        {id: 2, user_id: 1, notification_type: "low_balance", title: "Low Balance", message: "Your account balance is running low. Consider topping up.", timestamp: "2024-01-15 13:00:00", is_read: false, related_trip_id: (), related_route_id: ()}
    ];
    
    foreach Notification notification in sampleNotifications {
        notifications.push(notification);
        nextNotificationId += 1;
    }
}