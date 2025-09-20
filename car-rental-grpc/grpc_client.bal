import ballerina/io;
import ballerina/http;

http:Client serviceClient = check new ("http://localhost:9090");

public function runGrpcClientDemo() returns error? {
    io:println("🚀 Starting Service Client Demo");
    io:println("===============================");
    
    io:println("📝 Testing HTTP-based service operations");
    
    // Test AddCar service call
    AddCarRequest addReq = {
        make: "BMW",
        model: "X5",
        year: 2024,
        dailyPrice: 120.0,
        mileage: 5000,
        plate: "BMW001",
        status: "available"
    };
    
    CarResponse addResult = check serviceClient->/grpcService/addCar.post(addReq);
    string addMessage = addResult.message;
    io:println("✅ Service AddCar: " + addMessage);

    // Test SearchCar service call
    CarResponse searchResult = check serviceClient->/grpcService/searchCar/["BMW001"].get();
    string searchMessage = searchResult.message;
    io:println("✅ Service SearchCar: " + searchMessage);

    // Test AddToCart service call
    CartItem cartReq = {
        userId: "user1",
        plate: "BMW001",
        startDate: "2024-01-01",
        endDate: "2024-01-05"
    };
    
    CartResponse cartResult = check serviceClient->/grpcService/addToCart.post(cartReq);
    string cartMessage = cartResult.message;
    io:println("✅ Service AddToCart: " + cartMessage);

    // Test PlaceReservation service call
    ReservationRequest resReq = {userId: "user1"};
    ReservationResponse resResult = check serviceClient->/grpcService/placeReservation.post(resReq);
    string resMessage = resResult.message;
    float totalPrice = resResult.totalPrice;
    io:println("✅ Service PlaceReservation: " + resMessage);
    io:println("💰 Total Price: $" + totalPrice.toString());

    // Test CreateUsers service call
    User[] newUsers = [
        {id: "service_user1", name: "Service User 1", role: "customer"},
        {id: "service_user2", name: "Service User 2", role: "admin"}
    ];
    
    CreateUsersRequest streamReq = {users: newUsers};
    CreateUsersResponse streamResult = check serviceClient->/grpcService/createUsers.post(streamReq);
    string streamMessage = streamResult.message;
    int usersCreated = streamResult.usersCreated;
    io:println("✅ Service CreateUsers: " + streamMessage);
    io:println("👥 Users Created: " + usersCreated.toString());

    // Test ListAvailableCars service call
    ListCarsResponse listResult = check serviceClient->/grpcService/listAvailableCars.get(keyword = "BMW");
    Car[] availableCars = listResult.cars;
    string listMessage = listResult.message;
    io:println("✅ Service ListAvailableCars: " + listMessage);
    io:println("🚗 Available Cars Found: " + availableCars.length().toString());
    
    foreach Car car in availableCars {
        string carMake = car.make;
        string carModel = car.model;
        string carPlate = car.plate;
        io:println("   - " + carMake + " " + carModel + " (" + carPlate + ")");
    }

    // Test UpdateCar service call
    UpdateCarRequest updateReq = {
        plate: "BMW001",
        make: (),
        model: (),
        year: (),
        dailyPrice: 150.0,
        mileage: (),
        status: ()
    };
    
    CarResponse updateResult = check serviceClient->/grpcService/updateCar.put(updateReq);
    string updateMessage = updateResult.message;
    io:println("✅ Service UpdateCar: " + updateMessage);

    // Test RemoveCar service call
    RemoveCarResponse removeResult = check serviceClient->/grpcService/removeCar/["ABC123"].delete();
    string removeMessage = removeResult.message;
    Car[] remainingCars = removeResult.remainingCars;
    int remainingCount = remainingCars.length();
    io:println("✅ Service RemoveCar: " + removeMessage);
    io:println("🚗 Remaining Cars: " + remainingCount.toString());

    io:println("\n🎉 Service Client Demo Completed!");
    io:println("📝 All service operations completed successfully");
    
    return ();
}
