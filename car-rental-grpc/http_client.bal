import ballerina/http;
import ballerina/io;

http:Client carRentalClient = check new ("http://localhost:8080");

public function runHttpClientDemo() returns error? {
    io:println("🚀 Starting HTTP Client Demo");
    io:println("============================");
    
    // Test AddCar
    AddCarRequest addReq = {
        make: "BMW",
        model: "X5",
        year: 2024,
        dailyPrice: 120.0,
        mileage: 5000,
        plate: "BMW001",
        status: "available"
    };
    
    CarResponse addResult = check carRentalClient->/carRental/addCar.post(addReq);
    string addMessage = addResult.message;
    io:println("✅ HTTP AddCar: " + addMessage);

    // Test SearchCar
    CarResponse searchResult = check carRentalClient->/carRental/searchCar/["BMW001"].get();
    string searchMessage = searchResult.message;
    io:println("✅ HTTP SearchCar: " + searchMessage);

    // Test AddToCart
    CartItem cartReq = {
        userId: "user1",
        plate: "BMW001",
        startDate: "2024-01-01",
        endDate: "2024-01-05"
    };
    
    CartResponse cartResult = check carRentalClient->/carRental/addToCart.post(cartReq);
    string cartMessage = cartResult.message;
    io:println("✅ HTTP AddToCart: " + cartMessage);

    // Test PlaceReservation
    ReservationRequest resReq = {userId: "user1"};
    ReservationResponse resResult = check carRentalClient->/carRental/placeReservation.post(resReq);
    string resMessage = resResult.message;
    float totalPrice = resResult.totalPrice;
    io:println("✅ HTTP PlaceReservation: " + resMessage);
    io:println("💰 Total Price: $" + totalPrice.toString());

    // Test CreateUsers
    User[] newUsers = [
        {id: "http_user1", name: "HTTP User 1", role: "customer"},
        {id: "http_user2", name: "HTTP User 2", role: "admin"}
    ];
    
    CreateUsersRequest streamReq = {users: newUsers};
    CreateUsersResponse streamResult = check carRentalClient->/carRental/createUsers.post(streamReq);
    string streamMessage = streamResult.message;
    int usersCreated = streamResult.usersCreated;
    io:println("✅ HTTP CreateUsers: " + streamMessage);
    io:println("👥 Users Created: " + usersCreated.toString());

    // Test ListAvailableCars
    ListCarsResponse listResult = check carRentalClient->/carRental/listAvailableCars.get(keyword = "BMW");
    Car[] availableCars = listResult.cars;
    string listMessage = listResult.message;
    io:println("✅ HTTP ListAvailableCars: " + listMessage);
    io:println("🚗 Available Cars Found: " + availableCars.length().toString());

    // Test UpdateCar
    UpdateCarRequest updateReq = {
        plate: "BMW001",
        make: (),
        model: (),
        year: (),
        dailyPrice: 150.0,
        mileage: (),
        status: ()
    };
    
    CarResponse updateResult = check carRentalClient->/carRental/updateCar.put(updateReq);
    string updateMessage = updateResult.message;
    io:println("✅ HTTP UpdateCar: " + updateMessage);

    // Test RemoveCar
    RemoveCarResponse removeResult = check carRentalClient->/carRental/removeCar/["ABC123"].delete();
    string removeMessage = removeResult.message;
    Car[] remainingCars = removeResult.remainingCars;
    int remainingCount = remainingCars.length();
    io:println("✅ HTTP RemoveCar: " + removeMessage);
    io:println("🚗 Remaining Cars: " + remainingCount.toString());

    io:println("\n🎉 HTTP Client Demo Completed!");
    io:println("📝 All HTTP operations completed successfully");
    
    return ();
}
