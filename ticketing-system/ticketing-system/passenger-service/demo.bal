import ballerina/io;

public function main() returns error? {
    io:println("==========================================================");
    io:println("   Windhoek Public Transport System - Passenger Portal  ");
    io:println("==========================================================");
    io:println("");
    
    while true {
        displayMainMenu();
        string choice = io:readln("Choose option: ");
        
        match choice {
            "1" => {
                check registerPassenger();
            }
            "2" => {
                check loginPassenger();
            }
            "3" => {
                io:println("Thank you for using Windhoek Public Transport!");
                io:println("Goodbye! 👋");
                break;
            }
            _ => {
                io:println("❌ Invalid option! Please try again.");
                io:println("");
            }
        }
    }
}

function displayMainMenu() {
    io:println("🚌 MAIN MENU 🚊");
    io:println("================");
    io:println("1. 👤 Register New Account");
    io:println("2. 🔐 Login");
    io:println("3. 🚪 Exit");
    io:println("");
}

function registerPassenger() returns error? {
    io:println("");
    io:println("👤 PASSENGER REGISTRATION");
    io:println("=========================");
    
    string username = io:readln("Enter Username: ");
    string email = io:readln("Enter Email: ");
    string password = io:readln("Enter Password: ");
    
    io:println("");
    io:println("✅ Registration Successful!");
    io:println("📧 User: " + username);
    io:println("💰 Initial Balance: 100.00 NAD (credited to your account)");
    io:println("🎟️  You can now login and purchase tickets!");
    io:println("");
    
    return;
}

function loginPassenger() returns error? {
    io:println("");
    io:println("🔐 PASSENGER LOGIN");
    io:println("==================");
    
    string username = io:readln("Username: ");
    string password = io:readln("Password: ");
    
    // Simulate login validation
    io:println("");
    io:println("✅ Login Successful! Welcome " + username);
    io:println("");
    
    check passengerDashboard(username);
    
    return;
}

function passengerDashboard(string username) returns error? {
    while true {
        io:println("🎯 PASSENGER DASHBOARD");
        io:println("======================");
        io:println("Welcome back, " + username + "! | Balance: 85.00 NAD 💰");
        io:println("");
        io:println("Available Options:");
        io:println("1. 🚌 View Available Trips");
        io:println("2. 🎟️  Purchase Ticket");
        io:println("3. 📋 My Tickets");
        io:println("4. 🔔 View Notifications");
        io:println("5. 💳 Top Up Balance");
        io:println("6. 🚪 Logout");
        io:println("");
        
        string choice = io:readln("Choose option: ");
        
        match choice {
            "1" => {
                check viewAvailableTrips();
            }
            "2" => {
                check purchaseTicket();
            }
            "3" => {
                check viewMyTickets();
            }
            "4" => {
                check viewNotifications();
            }
            "5" => {
                check topUpBalance();
            }
            "6" => {
                io:println("👋 Logged out successfully!");
                io:println("");
                break;
            }
            _ => {
                io:println("❌ Invalid option! Please try again.");
                io:println("");
            }
        }
    }
    
    return;
}

function viewAvailableTrips() returns error? {
    io:println("");
    io:println("🚌 AVAILABLE TRIPS 🚊");
    io:println("=====================");
    io:println("");
    
    io:println("📍 Today's Schedule:");
    io:println("1. Route B01 - City Center → Katutura");
    io:println("   🕒 Departure: 08:30 | Arrival: 09:15");
    io:println("   💰 Price: 15.00 NAD | 🪑 Seats Available: 42/50");
    io:println("   🚌 Vehicle: Bus");
    io:println("");
    
    io:println("2. Route T01 - Central Station → Airport");
    io:println("   🕒 Departure: 10:00 | Arrival: 10:45");
    io:println("   💰 Price: 95.00 NAD | 🪑 Seats Available: 180/200");
    io:println("   🚊 Vehicle: Train");
    io:println("");
    
    io:println("3. Route B02 - Wanaheda → Klein Windhoek");
    io:println("   🕒 Departure: 11:30 | Arrival: 12:05");
    io:println("   💰 Price: 12.00 NAD | 🪑 Seats Available: 35/40");
    io:println("   🚌 Vehicle: Bus");
    io:println("");
    
    io:println("4. Route B03 - CBD → UNAM Campus");
    io:println("   🕒 Departure: 14:00 | Arrival: 14:30");
    io:println("   💰 Price: 8.00 NAD | 🪑 Seats Available: 45/50");
    io:println("   🚌 Vehicle: Bus");
    io:println("");
    
    io:println("Press Enter to return to dashboard...");
    _ = io:readln("");
    
    return;
}

function purchaseTicket() returns error? {
    io:println("");
    io:println("🎟️  PURCHASE TICKET");
    io:println("===================");
    io:println("");
    
    // Show available trips first
    check viewAvailableTrips();
    
    string routeChoice = io:readln("Select route (1-4): ");
    
    string routeName = "";
    string price = "";
    
    match routeChoice {
        "1" => {
            routeName = "B01 - City Center → Katutura";
            price = "15.00";
        }
        "2" => {
            routeName = "T01 - Central Station → Airport";
            price = "95.00";
        }
        "3" => {
            routeName = "B02 - Wanaheda → Klein Windhoek";
            price = "12.00";
        }
        "4" => {
            routeName = "B03 - CBD → UNAM Campus";
            price = "8.00";
        }
        _ => {
            io:println("❌ Invalid route selection!");
            return;
        }
    }
    
    io:println("");
    io:println("📋 TICKET PURCHASE SUMMARY");
    io:println("===========================");
    io:println("🚌 Route: " + routeName);
    io:println("💰 Price: " + price + " NAD");
    io:println("");
    
    string confirm = io:readln("Confirm purchase (y/n): ");
    
    if (confirm.toLowerAscii() == "y" || confirm.toLowerAscii() == "yes") {
        io:println("");
        io:println("🔄 Processing ticket request...");
        io:println("📡 Sending event to Kafka: ticket.requests");
        io:println("✅ Ticket request created!");
        io:println("");
        io:println("🎟️  Ticket ID: TKT-" + generateTicketId());
        io:println("📊 Status: CREATED (waiting for payment)");
        io:println("💡 Next: Go to Payment Service to complete payment");
        io:println("");
        io:println("🔔 You will receive notifications when:");
        io:println("   - Payment is processed");
        io:println("   - Ticket is ready for validation");
        io:println("   - Trip status changes");
    } else {
        io:println("❌ Ticket purchase cancelled.");
    }
    
    io:println("");
    io:println("Press Enter to return to dashboard...");
    _ = io:readln("");
    
    return;
}

function viewMyTickets() returns error? {
    io:println("");
    io:println("📋 MY TICKETS");
    io:println("==============");
    io:println("");
    
    io:println("🎟️  Ticket History:");
    io:println("1. Ticket ID: TKT-001-ABC-789");
    io:println("   🚌 Route: B01 - City Center → Katutura");
    io:println("   🕒 Departure: Today 08:30");
    io:println("   ✅ Status: VALIDATED ✓");
    io:println("   📅 Purchased: Yesterday 15:30");
    io:println("");
    
    io:println("2. Ticket ID: TKT-002-DEF-456");
    io:println("   🚊 Route: T01 - Central Station → Airport");
    io:println("   🕒 Departure: Tomorrow 10:00");
    io:println("   💳 Status: PAID (ready for validation)");
    io:println("   📅 Purchased: Today 09:15");
    io:println("");
    
    io:println("3. Ticket ID: TKT-003-GHI-123");
    io:println("   🚌 Route: B02 - Wanaheda → Klein Windhoek");
    io:println("   🕒 Departure: Today 11:30");
    io:println("   🟡 Status: CREATED (waiting for payment)");
    io:println("   📅 Purchased: Today 10:45");
    io:println("");
    
    io:println("📊 Ticket Statistics:");
    io:println("✅ Completed Trips: 1");
    io:println("💳 Paid Tickets: 1");
    io:println("🟡 Pending Payment: 1");
    io:println("💰 Total Spent: 15.00 NAD");
    
    io:println("");
    io:println("Press Enter to return to dashboard...");
    _ = io:readln("");
    
    return;
}

function viewNotifications() returns error? {
    io:println("");
    io:println("🔔 NOTIFICATIONS");
    io:println("================");
    io:println("");
    
    io:println("📬 Recent Notifications:");
    io:println("");
    
    io:println("1. 🎉 [NEW] Ticket Validated Successfully!");
    io:println("   Ticket TKT-001-ABC-789 validated on B01 route");
    io:println("   Welcome aboard! Have a safe trip.");
    io:println("   📅 5 minutes ago");
    io:println("");
    
    io:println("2. 💳 [PAYMENT] Payment Confirmed");
    io:println("   Payment of 95.00 NAD processed for ticket TKT-002-DEF-456");
    io:println("   Ticket is now ready for validation.");
    io:println("   📅 2 hours ago");
    io:println("");
    
    io:println("3. ⚠️  [SERVICE] Route Update");
    io:println("   Route B03 - CBD to UNAM Campus");
    io:println("   Service running normally. All trips on schedule.");
    io:println("   📅 Today 07:00");
    io:println("");
    
    io:println("4. 🎟️  [TICKET] New Ticket Created");
    io:println("   Ticket TKT-003-GHI-123 created for B02 route");
    io:println("   Please proceed to payment to complete purchase.");
    io:println("   📅 1 hour ago");
    io:println("");
    
    io:println("🔔 You have 3 unread notifications");
    
    io:println("");
    io:println("Press Enter to return to dashboard...");
    _ = io:readln("");
    
    return;
}

function topUpBalance() returns error? {
    io:println("");
    io:println("💳 TOP UP BALANCE");
    io:println("=================");
    io:println("💰 Current Balance: 85.00 NAD");
    io:println("");
    
    string amount = io:readln("Enter amount to add (NAD): ");
    
    io:println("");
    io:println("🔄 Processing top-up...");
    io:println("💳 Adding " + amount + " NAD to your account");
    io:println("✅ Balance updated successfully!");
    io:println("💰 New Balance: " + (85.00 + <decimal>checkpanic float:fromString(amount)).toString() + " NAD");
    
    io:println("");
    io:println("Press Enter to return to dashboard...");
    _ = io:readln("");
    
    return;
}

function generateTicketId() returns string {
    // Simple ticket ID generation for demo
    string[] prefixes = ["ABC", "DEF", "GHI", "JKL", "MNO"];
    string[] numbers = ["123", "456", "789", "321", "654"];
    
    return "001-" + prefixes[1] + "-" + numbers[2];
}