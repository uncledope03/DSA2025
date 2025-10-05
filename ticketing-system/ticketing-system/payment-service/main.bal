import ballerina/io;
import ballerina/uuid;
import ballerina/time;
import ballerina/runtime;
import ballerinax/kafka;
import ballerinax/mysql;

configurable int paymentPort = 8083;
configurable string kafkaUrl = "localhost:9092";
configurable string dbPassword = "";

// Database client
final mysql:Client paymentDB = check new ("localhost", "root", dbPassword, "ticketing_system", 3306);

// Kafka consumers and producers
final kafka:Consumer ticketRequestConsumer = check new (kafkaUrl, "ticket.requests", "payment-group");
final kafka:Producer paymentProducer = check new (kafkaUrl, "payments.processed");

public function main() returns error? {
    io:println("Starting Payment Service...");
    
    // Interactive payment processing
    _ = start @strand {preferred: true} interactivePaymentProcessor();
    
    io:println("Payment Service is running. Type 'exit' to stop.");
    
    // Keep the service running
    while true {
        runtime:sleep(10);
    }
}

function interactivePaymentProcessor() returns error? {
    while true {
        io:println("\n=== Payment Processing ===");
        io:println("1. Process pending payments");
        io:println("2. View payment history");
        io:println("3. Exit");
        
        string choice = io:readln("Choose option: ");
        
        match choice {
            "1" => {
                _ = processPendingPayments();
            }
            "2" => {
                _ = viewPaymentHistory();
            }
            "3" => {
                break;
            }
            _ => {
                io:println("Invalid option!");
            }
        }
    }
}

function processPendingPayments() returns error? {
    io:println("\n--- Pending Payments ---");
    
    stream<record {}, error?> result = paymentDB->query(`
        SELECT t.id as ticket_id, u.username, t.price, r.name as route_name
        FROM tickets t
        JOIN users u ON t.passenger_id = u.id
        JOIN trips tr ON t.trip_id = tr.id
        JOIN routes r ON tr.route_id = r.id
        WHERE t.status = 'CREATED'
    `);
    
    int count = 0;
    string[] ticketIds = [];
    
    while true {
        record {|string ticket_id; string username; decimal price; string route_name;|}? payment = check result.next();
        if payment is () {
            break;
        }
        count += 1;
        ticketIds.push(payment.ticket_id);
        io:println(count + ". Ticket: " + payment.ticket_id);
        io:println("   Passenger: " + payment.username);
        io:println("   Route: " + payment.route_name);
        io:println("   Amount: " + payment.price.toString() + " NAD");
    }
    
    if count == 0 {
        io:println("No pending payments.");
        return;
    }
    
    string selectedTicket = io:readln("Enter Ticket ID to process: ");
    
    // Simulate payment processing
    io:println("Processing payment for ticket: " + selectedTicket);
    
    // Get ticket details
    stream<record {}, error?> ticketResult = paymentDB->query(`
        SELECT passenger_id, price FROM tickets WHERE id = ?
    `, selectedTicket);
    
    record {|string passenger_id; decimal price;|}? ticket = check ticketResult.next();
    
    if ticket is () {
        io:println("Invalid ticket ID!");
        return;
    }
    
    // Check user balance
    stream<record {}, error?> userResult = paymentDB->query(`
        SELECT balance FROM users WHERE id = ?
    `, ticket.passenger_id);
    
    record {|decimal balance;|}? user = check userResult.next();
    
    string paymentStatus = "COMPLETED";
    
    if user.balance < ticket.price {
        io:println("Insufficient balance! Payment failed.");
        paymentStatus = "FAILED";
    } else {
        // Deduct balance
        _ = check paymentDB->execute(`
            UPDATE users SET balance = balance - ? WHERE id = ?
        `, ticket.price, ticket.passenger_id);
        
        io:println("Payment successful! Balance deducted.");
    }
    
    // Create payment record
    string paymentId = uuid:createType4AsString();
    _ = check paymentDB->execute(`
        INSERT INTO payments (id, ticket_id, amount, status, payment_method)
        VALUES (?, ?, ?, ?, 'WALLET')
    `, paymentId, selectedTicket, ticket.price, paymentStatus);
    
    // Send payment confirmation
    json paymentEvent = {
        paymentId: paymentId,
        ticketId: selectedTicket,
        status: paymentStatus,
        amount: ticket.price,
        timestamp: time:utcNow()[0].toString()
    };
    
    _ = check paymentProducer->send({value: paymentEvent.toString()});
    
    io:println("Payment processing completed for ticket: " + selectedTicket);
}

function viewPaymentHistory() returns error? {
    io:println("\n--- Payment History ---");
    
    stream<record {}, error?> result = paymentDB->query(`
        SELECT p.ticket_id, u.username, p.amount, p.status, p.transaction_time
        FROM payments p
        JOIN tickets t ON p.ticket_id = t.id
        JOIN users u ON t.passenger_id = u.id
        ORDER BY p.transaction_time DESC
        LIMIT 10
    `);
    
    int count = 0;
    while true {
        record {|string ticket_id; string username; decimal amount; string status; string transaction_time;|}? payment = check result.next();
        if payment is () {
            break;
        }
        count += 1;
        io:println(count + ". Ticket: " + payment.ticket_id);
        io:println("   Passenger: " + payment.username);
        io:println("   Amount: " + payment.amount.toString() + " NAD");
        io:println("   Status: " + payment.status);
        io:println("   Time: " + payment.transaction_time);
    }
    
    if count == 0 {
        io:println("No payment history found.");
    }
}