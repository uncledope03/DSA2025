CREATE DATABASE IF NOT EXISTS ticketing_system;
USE ticketing_system;

-- Users table
CREATE TABLE users (
    id VARCHAR(50) PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('PASSENGER', 'ADMIN', 'VALIDATOR') NOT NULL,
    balance DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Routes table
CREATE TABLE routes (
    id VARCHAR(50) PRIMARY KEY,
    route_number VARCHAR(20) NOT NULL,
    name VARCHAR(255) NOT NULL,
    transport_type ENUM('BUS', 'TRAIN') NOT NULL,
    start_location VARCHAR(255) NOT NULL,
    end_location VARCHAR(255) NOT NULL,
    stops JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trips table
CREATE TABLE trips (
    id VARCHAR(50) PRIMARY KEY,
    route_id VARCHAR(50) NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    available_seats INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    status ENUM('SCHEDULED', 'DELAYED', 'CANCELLED', 'COMPLETED') DEFAULT 'SCHEDULED',
    FOREIGN KEY (route_id) REFERENCES routes(id)
);

-- Tickets table
CREATE TABLE tickets (
    id VARCHAR(50) PRIMARY KEY,
    passenger_id VARCHAR(50) NOT NULL,
    trip_id VARCHAR(50) NOT NULL,
    ticket_type ENUM('SINGLE', 'MULTIPLE', 'PASS') NOT NULL,
    status ENUM('CREATED', 'PAID', 'VALIDATED', 'EXPIRED') DEFAULT 'CREATED',
    price DECIMAL(10,2) NOT NULL,
    purchase_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    validation_time TIMESTAMP NULL,
    expires_at TIMESTAMP NULL,
    FOREIGN KEY (passenger_id) REFERENCES users(id),
    FOREIGN KEY (trip_id) REFERENCES trips(id)
);

-- Payments table
CREATE TABLE payments (
    id VARCHAR(50) PRIMARY KEY,
    ticket_id VARCHAR(50) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status ENUM('PENDING', 'COMPLETED', 'FAILED') DEFAULT 'PENDING',
    payment_method VARCHAR(50) NOT NULL,
    transaction_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES tickets(id)
);

-- Notifications table
CREATE TABLE notifications (
    id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('TRIP_UPDATE', 'TICKET_CONFIRMATION', 'SYSTEM_ALERT') NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);