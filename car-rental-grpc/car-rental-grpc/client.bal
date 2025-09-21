import ballerina/io;

public function runClientDemo() returns error? {
    io:println("🚗 Car Rental System Client");
    io:println("===========================");

    // Initialize sample data
    initializeSampleData();
    
    // Simulate the workflow
    PlateRequest searchReq = {plate: "ABC123"};
    CarResponse searchResponse = searchCar(searchReq);
    string searchMessage = searchResponse.message;
    io:println("Search Response: " + searchMessage);
    
    Car? foundCar = searchResponse.car;
    if foundCar is Car {
        string carMake = foundCar.make;
        string carModel = foundCar.model;
        io:println("Car Details: " + carMake + " " + carModel);
    }
    
    io:println("\nAvailable Cars:");
    ListCarsResponse availableCars = listAvailableCars(());
    Car[] carsList = availableCars.cars;
    foreach Car car in carsList {
        string carMake = car.make;
        string carModel = car.model;
        string carPlate = car.plate;
        io:println("- " + carMake + " " + carModel + " (" + carPlate + ")");
    }
    
    CartItem cartItem = {
        userId: "user1",
        plate: "ABC123",
        startDate: "2024-01-01",
        endDate: "2024-01-06"
    };
    CartResponse cartResponse = addToCart(cartItem);
    string cartMessage = cartResponse.message;
    io:println("Add to Cart: " + cartMessage);
    
    ReservationRequest reservationReq = {userId: "user1"};
    ReservationResponse reservationResponse = placeReservation(reservationReq);
    string reservationMessage = reservationResponse.message;
    float totalPrice = reservationResponse.totalPrice;
    io:println("Reservation: " + reservationMessage);
    io:println("Total Price: $" + totalPrice.toString());
    
    io:println("\n✅ Client demo completed!");
}
