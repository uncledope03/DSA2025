import ballerina/io;

public function runInteractiveMenu() returns error? {
    io:println("🚗 Car Rental System - Interactive Menu");
    io:println("=======================================");
    
    initializeSampleData();
    
    while true {
        io:println("\n--- MAIN MENU ---");
        io:println("1. Admin Operations");
        io:println("2. Customer Operations");
        io:println("3. Exit");
        
        string choice = io:readln("Enter your choice (1-3): ");
        
        if choice == "1" {
            error? adminResult = runAdminMenu();
            if adminResult is error {
                string errorMessage = adminResult.message();
                io:println("Error in admin operations: " + errorMessage);
            }
        } else if choice == "2" {
            error? customerResult = runCustomerMenu();
            if customerResult is error {
                string errorMessage = customerResult.message();
                io:println("Error in customer operations: " + errorMessage);
            }
        } else if choice == "3" {
            io:println("Thank you for using Car Rental System!");
            break;
        } else {
            io:println("Invalid choice. Please try again.");
        }
    }
}

function runAdminMenu() returns error? {
    while true {
        io:println("\n--- ADMIN MENU ---");
        io:println("1. Add Car");
        io:println("2. Create Users");
        io:println("3. Update Car");
        io:println("4. Remove Car");
        io:println("5. View All Cars");
        io:println("6. Back to Main Menu");
        
        string choice = io:readln("Enter your choice (1-6): ");
        
        if choice == "1" {
            promptAddCar();
        } else if choice == "2" {
            promptCreateUsers();
        } else if choice == "3" {
            promptUpdateCar();
        } else if choice == "4" {
            promptRemoveCar();
        } else if choice == "5" {
            viewAllCars();
        } else if choice == "6" {
            break;
        } else {
            io:println("Invalid choice. Please try again.");
        }
    }
}

function runCustomerMenu() returns error? {
    while true {
        io:println("\n--- CUSTOMER MENU ---");
        io:println("1. List Available Cars");
        io:println("2. Search Car by Plate");
        io:println("3. Add Car to Cart");
        io:println("4. Place Reservation");
        io:println("5. Back to Main Menu");
        
        string choice = io:readln("Enter your choice (1-5): ");
        
        if choice == "1" {
            promptListAvailableCars();
        } else if choice == "2" {
            promptSearchCar();
        } else if choice == "3" {
            promptAddToCart();
        } else if choice == "4" {
            promptPlaceReservation();
        } else if choice == "5" {
            break;
        } else {
            io:println("Invalid choice. Please try again.");
        }
    }
}

function promptAddCar() {
    io:println("\n--- ADD CAR ---");
    string make = io:readln("Enter car make: ");
    string model = io:readln("Enter car model: ");
    string yearStr = io:readln("Enter car year: ");
    string priceStr = io:readln("Enter daily price: ");
    string mileageStr = io:readln("Enter mileage: ");
    string plate = io:readln("Enter number plate: ");
    string status = io:readln("Enter status (available/unavailable): ");
    
    int|error year = int:fromString(yearStr);
    float|error dailyPrice = float:fromString(priceStr);
    int|error mileage = int:fromString(mileageStr);
    
    if year is error || dailyPrice is error || mileage is error {
        io:println("Invalid input. Please enter valid numbers.");
        return;
    }
    
    AddCarRequest req = {
        make: make,
        model: model,
        year: year,
        dailyPrice: dailyPrice,
        mileage: mileage,
        plate: plate,
        status: status
    };
    
    CarResponse response = addCar(req);
    string responseMessage = response.message;
    io:println("Result: " + responseMessage);
}

function promptCreateUsers() {
    io:println("\n--- CREATE USERS ---");
    string countStr = io:readln("How many users do you want to create? ");
    int|error userCount = int:fromString(countStr);
    
    if userCount is error || userCount <= 0 {
        io:println("Invalid number of users.");
        return;
    }
    
    User[] newUsers = [];
    int i = 0;
    while i < userCount {
        int userNumber = i + 1;
        io:println("\nUser " + userNumber.toString() + ":");
        string userId = io:readln("Enter user ID: ");
        string userName = io:readln("Enter user name: ");
        string userRole = io:readln("Enter user role (admin/customer): ");
        
        User newUser = {
            id: userId,
            name: userName,
            role: userRole
        };
        newUsers.push(newUser);
        i += 1;
    }
    
    CreateUsersRequest req = {users: newUsers};
    CreateUsersResponse response = createUsers(req);
    string responseMessage = response.message;
    int usersCreated = response.usersCreated;
    io:println("Result: " + responseMessage);
    io:println("Users created: " + usersCreated.toString());
}

function promptUpdateCar() {
    io:println("\n--- UPDATE CAR ---");
    string plate = io:readln("Enter car plate to update: ");
    
    io:println("Leave fields empty to keep current values:");
    string make = io:readln("Enter new make (or press Enter to skip): ");
    string model = io:readln("Enter new model (or press Enter to skip): ");
    string yearStr = io:readln("Enter new year (or press Enter to skip): ");
    string priceStr = io:readln("Enter new daily price (or press Enter to skip): ");
    string mileageStr = io:readln("Enter new mileage (or press Enter to skip): ");
    string status = io:readln("Enter new status (or press Enter to skip): ");
    
    int? yearValue = ();
    if yearStr != "" {
        int|error yearResult = int:fromString(yearStr);
        if yearResult is int {
            yearValue = yearResult;
        }
    }
    
    float? priceValue = ();
    if priceStr != "" {
        float|error priceResult = float:fromString(priceStr);
        if priceResult is float {
            priceValue = priceResult;
        }
    }
    
    int? mileageValue = ();
    if mileageStr != "" {
        int|error mileageResult = int:fromString(mileageStr);
        if mileageResult is int {
            mileageValue = mileageResult;
        }
    }
    
    UpdateCarRequest req = {
        plate: plate,
        make: make == "" ? () : make,
        model: model == "" ? () : model,
        year: yearValue,
        dailyPrice: priceValue,
        mileage: mileageValue,
        status: status == "" ? () : status
    };
    
    CarResponse response = updateCar(req);
    string responseMessage = response.message;
    io:println("Result: " + responseMessage);
}

function promptRemoveCar() {
    io:println("\n--- REMOVE CAR ---");
    string plate = io:readln("Enter car plate to remove: ");
    
    PlateRequest req = {plate: plate};
    RemoveCarResponse response = removeCar(req);
    string responseMessage = response.message;
    Car[] remainingCars = response.remainingCars;
    int remainingCount = remainingCars.length();
    io:println("Result: " + responseMessage);
    io:println("Remaining cars in inventory: " + remainingCount.toString());
}

function viewAllCars() {
    io:println("\n--- ALL CARS ---");
    string[] carKeys = cars.keys();
    int carCount = carKeys.length();
    
    if carCount == 0 {
        io:println("No cars in inventory.");
        return;
    }
    
    foreach string key in carKeys {
        Car car = cars.get(key);
        string carPlate = car.plate;
        string carMake = car.make;
        string carModel = car.model;
        int carYear = car.year;
        float carPrice = car.dailyPrice;
        string carStatus = car.status;
        io:println("Plate: " + carPlate + " | " + carMake + " " + carModel + 
                  " (" + carYear.toString() + ") | $" + carPrice.toString() + 
                  "/day | Status: " + carStatus);
    }
}

function promptListAvailableCars() {
    io:println("\n--- LIST AVAILABLE CARS ---");
    string filterChoice = io:readln("Do you want to filter? (y/n): ");
    
    FilterRequest? filter = ();
    string lowerFilterChoice = filterChoice.toLowerAscii();
    if lowerFilterChoice == "y" {
        string keyword = io:readln("Enter keyword to filter (make/model/plate) or press Enter to skip: ");
        string yearStr = io:readln("Enter year to filter or press Enter to skip: ");
        
        int? yearValue = ();
        if yearStr != "" {
            int|error yearResult = int:fromString(yearStr);
            if yearResult is int {
                yearValue = yearResult;
            }
        }
        
        filter = {
            keyword: keyword,
            year: yearValue
        };
    }
    
    ListCarsResponse response = listAvailableCars(filter);
    string responseMessage = response.message;
    Car[] availableCars = response.cars;
    int availableCount = availableCars.length();
    io:println("Result: " + responseMessage);
    
    if availableCount == 0 {
        io:println("No available cars found.");
    } else {
        io:println("Available cars:");
        foreach Car car in availableCars {
            string carMake = car.make;
            string carModel = car.model;
            string carPlate = car.plate;
            float carPrice = car.dailyPrice;
            io:println("- " + carMake + " " + carModel + " (" + carPlate + ") - $" + 
                      carPrice.toString() + "/day");
        }
    }
}

function promptSearchCar() {
    io:println("\n--- SEARCH CAR ---");
    string plate = io:readln("Enter car plate to search: ");
    
    PlateRequest req = {plate: plate};
    CarResponse response = searchCar(req);
    string responseMessage = response.message;
    io:println("Result: " + responseMessage);
    
    Car? foundCar = response.car;
    if foundCar is Car {
        string carMake = foundCar.make;
        string carModel = foundCar.model;
        int carYear = foundCar.year;
        float carPrice = foundCar.dailyPrice;
        io:println("Car Details: " + carMake + " " + carModel + 
                  " (" + carYear.toString() + ") - $" + carPrice.toString() + "/day");
    }
}

function promptAddToCart() {
    io:println("\n--- ADD TO CART ---");
    string userId = io:readln("Enter your user ID: ");
    string plate = io:readln("Enter car plate: ");
    string startDate = io:readln("Enter start date (YYYY-MM-DD): ");
    string endDate = io:readln("Enter end date (YYYY-MM-DD): ");
    
    CartItem item = {
        userId: userId,
        plate: plate,
        startDate: startDate,
        endDate: endDate
    };
    
    CartResponse response = addToCart(item);
    string responseMessage = response.message;
    io:println("Result: " + responseMessage);
}

function promptPlaceReservation() {
    io:println("\n--- PLACE RESERVATION ---");
    string userId = io:readln("Enter your user ID: ");
    
    ReservationRequest req = {userId: userId};
    ReservationResponse response = placeReservation(req);
    string responseMessage = response.message;
    float totalPrice = response.totalPrice;
    io:println("Result: " + responseMessage);
    if totalPrice > 0.0 {
        io:println("Total Price: $" + totalPrice.toString());
    }
}
