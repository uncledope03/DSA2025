-- Create database if not exists
CREATE DATABASE IF NOT EXISTS ticketing_system;
USE ticketing_system;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('passenger', 'admin', 'validator') DEFAULT 'passenger',
    balance DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Routes table
CREATE TABLE IF NOT EXISTS routes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    route_name VARCHAR(100) NOT NULL,
    route_type ENUM('bus', 'train') NOT NULL,
    origin VARCHAR(100) NOT NULL,
    destination VARCHAR(100) NOT NULL,
    distance_km DECIMAL(8, 2),
    base_fare DECIMAL(8, 2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trips table
CREATE TABLE IF NOT EXISTS trips (
    id INT PRIMARY KEY AUTO_INCREMENT,
    route_id INT NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    available_seats INT DEFAULT 50,
    status ENUM('scheduled', 'active', 'completed', 'cancelled') DEFAULT 'scheduled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE
);

-- Tickets table
CREATE TABLE IF NOT EXISTS tickets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    trip_id INT NOT NULL,
    ticket_type ENUM('single', 'return', 'day_pass', 'weekly_pass', 'monthly_pass') DEFAULT 'single',
    status ENUM('created', 'paid', 'validated', 'expired') DEFAULT 'created',
    purchase_price DECIMAL(8, 2) NOT NULL,
    purchased_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    validated_at TIMESTAMP NULL,
    expires_at TIMESTAMP NULL,
    validation_code VARCHAR(50) UNIQUE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
);

-- Payments table
CREATE TABLE IF NOT EXISTS payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('balance', 'card', 'cash') DEFAULT 'balance',
    status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    transaction_id VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP NULL,
    FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    type ENUM('trip_delay', 'trip_cancellation', 'ticket_validation', 'payment_confirmation') NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Insert sample data
-- Admin user (password: admin123)
INSERT IGNORE INTO users (username, email, password_hash, role, balance) VALUES
('admin', 'admin@windhoek.gov.na', 'admin123', 'admin', 0.00);

-- Sample routes
INSERT IGNORE INTO routes (route_name, route_type, origin, destination, distance_km, base_fare) VALUES
('City Center - Katutura', 'bus', 'City Center', 'Katutura', 15.5, 15.00),
('Central Station - Airport', 'train', 'Central Station', 'Hosea Kutako Airport', 45.0, 95.00),
('Wanaheda - Klein Windhoek', 'bus', 'Wanaheda', 'Klein Windhoek', 8.5, 12.00),
('CBD - UNAM Campus', 'bus', 'CBD', 'UNAM Campus', 6.0, 8.00);

-- Sample trips (future dates)
INSERT INTO trips (route_id, departure_time, arrival_time, available_seats, status) VALUES
(1, DATE_ADD(NOW(), INTERVAL 2 HOUR), DATE_ADD(NOW(), INTERVAL 2 HOUR 45 MINUTE), 48, 'scheduled'),
(1, DATE_ADD(NOW(), INTERVAL 4 HOUR), DATE_ADD(NOW(), INTERVAL 4 HOUR 45 MINUTE), 50, 'scheduled'),
(2, DATE_ADD(NOW(), INTERVAL 6 HOUR), DATE_ADD(NOW(), INTERVAL 8 HOUR), 180, 'scheduled'),
(3, DATE_ADD(NOW(), INTERVAL 1 HOUR), DATE_ADD(NOW(), INTERVAL 1 HOUR 30 MINUTE), 35, 'scheduled'),
(4, DATE_ADD(NOW(), INTERVAL 3 HOUR), DATE_ADD(NOW(), INTERVAL 3 HOUR 20 MINUTE), 45, 'scheduled'),
(1, DATE_ADD(NOW(), INTERVAL 1 DAY), DATE_ADD(NOW(), INTERVAL 1 DAY 45 MINUTE), 50, 'scheduled'),
(2, DATE_ADD(NOW(), INTERVAL 1 DAY 2 HOUR), DATE_ADD(NOW(), INTERVAL 1 DAY 4 HOUR), 200, 'scheduled');

-- Add computed column for trips to show base_fare from routes
ALTER TABLE trips ADD COLUMN base_fare DECIMAL(8,2) GENERATED ALWAYS AS (
    (SELECT base_fare FROM routes WHERE routes.id = trips.route_id)
) VIRTUAL;

COMMIT;

SELECT 'Database setup completed successfully!' as status;