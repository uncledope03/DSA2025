import ballerina/io;

map<Car> cars = {};
map<User> users = {};
map<CartItem[]> carts = {};

public function initializeSampleData() {
    Car sampleCar1 = {
        make: "Toyota",
        model: "Corolla",
        year: 2022,
        dailyPrice: 50.0,
        mileage: 15000,
        plate: "ABC123",
        status: "available"
    };
    cars[sampleCar1.plate] = sampleCar1;
    
    Car sampleCar2 = {
        make: "Honda",
        model: "Civic",
        year: 2023,
        dailyPrice: 55.0,
        mileage: 8000,
        plate: "XYZ789",
        status: "available"
    };
    cars[sampleCar2.plate] = sampleCar2;
    
    User adminUser = {
        id: "admin1",
        name: "Admin User",
        role: "admin"
    };
    users[adminUser.id] = adminUser;
    
    User customerUser = {
        id: "user1",
        name: "John Doe",
        role: "customer"
    };
    users[customerUser.id] = customerUser;
    
    int carsCount = cars.length();
    int usersCount = users.length();
    io:println("Sample data initialized with " + carsCount.toString() + " cars and " + usersCount.toString() + " users");
}

public function searchCar(PlateRequest req) returns CarResponse {
    string reqPlate = req.plate;
    if cars.hasKey(reqPlate) {
        Car foundCar = cars.get(reqPlate);
        string carStatus = foundCar.status;
        if carStatus == "available" {
            io:println("Car found and available: " + reqPlate);
            return {car: foundCar, message: "Car found and available"};
        } else {
            io:println("Car found but not available: " + reqPlate);
            return {message: "Car found but not available for rent"};
        }
    }
    io:println("Car not found: " + reqPlate);
    return {message: "Car not found with plate: " + reqPlate};
}

public function addToCart(CartItem item) returns CartResponse {
    string itemPlate = item.plate;
    if !cars.hasKey(itemPlate) {
        return {message: "Car not found"};
    }
    
    Car car = cars.get(itemPlate);
    string carStatus = car.status;
    if carStatus != "available" {
        return {message: "Car is not available for rent"};
    }
    
    string startDate = item.startDate;
    string endDate = item.endDate;
    if startDate >= endDate {
        return {message: "Invalid dates: start date must be before end date"};
    }
    
    string userId = item.userId;
    CartItem[]? maybeCart = carts[userId];
    if maybeCart is () {
        carts[userId] = [item];
    } else {
        CartItem[] cart = maybeCart;
        cart.push(item);
        carts[userId] = cart;
    }
    
    io:println("Added to cart: " + itemPlate + " for user: " + userId);
    return {message: "Car added to cart successfully"};
}

public function placeReservation(ReservationRequest req) returns ReservationResponse {
    string userId = req.userId;
    CartItem[]? maybeCart = carts[userId];
    if maybeCart is () {
        return {message: "Cart is empty", totalPrice: 0.0};
    }
    
    CartItem[] userCart = maybeCart;
    int cartLength = userCart.length();
    if cartLength == 0 {
        return {message: "Cart is empty", totalPrice: 0.0};
    }
    
    float total = 0.0;
    foreach CartItem item in userCart {
        string itemPlate = item.plate;
        if cars.hasKey(itemPlate) {
            Car car = cars.get(itemPlate);
            float carPrice = car.dailyPrice;
            total += carPrice * 5.0;
        }
    }
    
    CartItem[] removedCart = carts.remove(userId);
    io:println("Reservation placed for user: " + userId);
    return {message: "Reservation placed successfully", totalPrice: total};
}

public function addCar(AddCarRequest req) returns CarResponse {
    string reqPlate = req.plate;
    if cars.hasKey(reqPlate) {
        return {message: "Car with plate " + reqPlate + " already exists"};
    }
    
    Car newCar = {
        make: req.make,
        model: req.model,
        year: req.year,
        dailyPrice: req.dailyPrice,
        mileage: req.mileage,
        plate: reqPlate,
        status: req.status
    };
    
    cars[reqPlate] = newCar;
    io:println("Car added successfully with plate: " + reqPlate);
    return {car: newCar, message: "Car added successfully. Unique ID (plate): " + reqPlate};
}

public function createUsers(CreateUsersRequest req) returns CreateUsersResponse {
    int usersCreated = 0;
    User[] reqUsers = req.users;
    
    foreach User user in reqUsers {
        string userId = user.id;
        if !users.hasKey(userId) {
            users[userId] = user;
            usersCreated += 1;
            string userName = user.name;
            string userRole = user.role;
            io:println("User created: " + userName + " (" + userRole + ")");
        } else {
            io:println("User with ID " + userId + " already exists, skipping...");
        }
    }
    
    return {message: "User creation completed", usersCreated: usersCreated};
}

public function updateCar(UpdateCarRequest req) returns CarResponse {
    string reqPlate = req.plate;
    if !cars.hasKey(reqPlate) {
        return {message: "Car with plate " + reqPlate + " not found"};
    }
    
    Car existingCar = cars.get(reqPlate);
    Car updatedCar = {
        make: req.make ?: existingCar.make,
        model: req.model ?: existingCar.model,
        year: req.year ?: existingCar.year,
        dailyPrice: req.dailyPrice ?: existingCar.dailyPrice,
        mileage: req.mileage ?: existingCar.mileage,
        plate: existingCar.plate,
        status: req.status ?: existingCar.status
    };
    
    cars[reqPlate] = updatedCar;
    io:println("Car updated successfully: " + reqPlate);
    return {car: updatedCar, message: "Car updated successfully"};
}

public function removeCar(PlateRequest req) returns RemoveCarResponse {
    string reqPlate = req.plate;
    if !cars.hasKey(reqPlate) {
        Car[] allCars = cars.toArray();
        return {message: "Car with plate " + reqPlate + " not found", remainingCars: allCars};
    }
    
    Car removedCar = cars.remove(reqPlate);
    Car[] remainingCars = cars.toArray();
    io:println("Car removed successfully: " + reqPlate);
    return {message: "Car removed successfully", remainingCars: remainingCars};
}

public function listAvailableCars(FilterRequest? filter) returns ListCarsResponse {
    Car[] availableCars = [];
    string[] carKeys = cars.keys();
    
    foreach string key in carKeys {
        Car car = cars.get(key);
        string carStatus = car.status;
        if carStatus == "available" {
            boolean includesCar = true;
            
            if filter is FilterRequest {
                string filterKeyword = filter.keyword;
                if filterKeyword != "" {
                    string carMake = car.make;
                    string carModel = car.model;
                    string carPlate = car.plate;
                    string carInfo = carMake + " " + carModel + " " + carPlate;
                    string lowerCarInfo = carInfo.toLowerAscii();
                    string lowerKeyword = filterKeyword.toLowerAscii();
                    if !lowerCarInfo.includes(lowerKeyword) {
                        includesCar = false;
                    }
                }
                
                int? filterYear = filter.year;
                if filterYear is int {
                    int carYear = car.year;
                    if carYear != filterYear {
                        includesCar = false;
                    }
                }
            }
            
            if includesCar {
                availableCars.push(car);
            }
        }
    }
    
    return {cars: availableCars, message: "Available cars retrieved successfully"};
}

public function getStorageInfo() returns string {
    int carsCount = cars.length();
    int usersCount = users.length();
    int cartsCount = carts.length();
    return "Storage Information:\n" +
           "- Storage Type: In-Memory Maps\n" +
           "- Cars: " + carsCount.toString() + " entries\n" +
           "- Users: " + usersCount.toString() + " entries\n" +
           "- Active Carts: " + cartsCount.toString() + " users\n" +
           "- Persistence: Memory only (data lost on restart)";
}
