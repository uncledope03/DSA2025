USE ticketing_system;

-- Create admin user
INSERT INTO users (id, username, email, password_hash, role, balance) VALUES 
('admin1', 'admin', 'admin@windhoek.gov.na', 'admin123', 'ADMIN', 0.00);

-- Sample routes
INSERT INTO routes (id, route_number, name, transport_type, start_location, end_location) VALUES 
('route1', 'B01', 'City Center - Katutura', 'BUS', 'City Center', 'Katutura'),
('route2', 'T01', 'Central Station - Hosea Kutako', 'TRAIN', 'Central Station', 'Hosea Kutako Airport'),
('route3', 'B02', 'Wanaheda - Klein Windhoek', 'BUS', 'Wanaheda', 'Klein Windhoek');

-- Sample trips
INSERT INTO trips (id, route_id, departure_time, arrival_time, available_seats, price) VALUES 
('trip1', 'route1', '2024-12-20 08:00:00', '2024-12-20 08:45:00', 40, 15.00),
('trip2', 'route1', '2024-12-20 09:00:00', '2024-12-20 09:45:00', 40, 15.00),
('trip3', 'route2', '2024-12-20 10:00:00', '2024-12-20 10:30:00', 200, 25.00),
('trip4', 'route3', '2024-12-20 11:00:00', '2024-12-20 11:35:00', 35, 12.00);