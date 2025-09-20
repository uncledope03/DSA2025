//Demo Mode 

//Handles testing the system with sample data.
//This part simulates real actions (like adding cars, users, searching, etc.) to show the system works without needing the server. 


 function runDemoMode() {
    io:println("\n Running Local Demo Mode");
    io:println("==========================");

    // Testing AddCar
    AddCarRequest addReq = {
        make: "Tesla",
        model: "Model 3",
        year: 2024,
        dailyPrice: 100.0,
        mileage: 1000,
        plate: "TESLA01",
        status: "available"
    };
    CarResponse addResult = addCar(addReq);
    string addMessage = addResult.message;
    io:println(" AddCar: " + addMessage);

    // Testing CreateUsers
    User[] newUsers = [
        {id: "demo_admin", name: "Demo Admin", role: "admin"},
        {id: "demo_customer", name: "Demo Customer", role: "customer"}
    ];
    CreateUsersRequest usersReq = {users: newUsers};
    CreateUsersResponse usersResult = createUsers(usersReq);
    string usersMessage = usersResult.message;
    int usersCreated = usersResult.usersCreated;
    io:println(" CreateUsers: " + usersMessage + " (" + usersCreated.toString() + " users)");

    // Testing SearchCar
    PlateRequest searchReq = {plate: "TESLA01"};
    CarResponse searchResult = searchCar(searchReq);
    string searchMessage = searchResult.message;
    io:println(" SearchCar: " + searchMessage);