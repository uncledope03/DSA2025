import ballerina/http;
import ballerina/io;

// Simple service without gRPC for now - focusing on core functionality
service /grpcService on new http:Listener(9090) {

    resource function post addCar(AddCarRequest request) returns CarResponse {
        io:println("🚗 Service AddCar called for plate: " + request.plate);

        string requestPlate = request.plate;
        if cars.hasKey(requestPlate) {
            return {message: "Car with plate " + requestPlate + " already exists"};
        }

        Car newCar = {
            make: request.make,
            model: request.model,
            year: request.year,
            dailyPrice: request.dailyPrice,
            mileage: request.mileage,
            plate: requestPlate,
            status: request.status
        };

        cars[requestPlate] = newCar;
        io:println("✅ Car added via service: " + requestPlate);
        return {car: newCar, message: "Car added successfully via service. Unique ID: " + requestPlate};
    }

    resource function post createUsers(CreateUsersRequest request) returns CreateUsersResponse {
        io:println("👥 Service CreateUsers called");
        int usersCreated = 0;

        User[] requestUsers = request.users;
        foreach User userReq in requestUsers {
            string userId = userReq.id;
            if !users.hasKey(userId) {
                User newUser = {
                    id: userId,
                    name: userReq.name,
                    role: userReq.role
                };
                users[userId] = newUser;
                usersCreated += 1;
                string userName = userReq.name;
                io:println("✅ User created via service: " + userName);
            }
        }

        return {message: "Users created successfully via service", usersCreated: usersCreated};
    }

    resource function put updateCar(UpdateCarRequest request) returns CarResponse {
        io:println("🔄 Service UpdateCar called for plate: " + request.plate);

        string requestPlate = request.plate;
        if !cars.hasKey(requestPlate) {
            return {message: "Car with plate " + requestPlate + " not found"};
        }

        Car existingCar = cars.get(requestPlate);
        Car updatedCar = {
            make: request.make ?: existingCar.make,
            model: request.model ?: existingCar.model,
            year: request.year ?: existingCar.year,
            dailyPrice: request.dailyPrice ?: existingCar.dailyPrice,
            mileage: request.mileage ?: existingCar.mileage,
            plate: existingCar.plate,
            status: request.status ?: existingCar.status
        };

        cars[requestPlate] = updatedCar;
        io:println("✅ Car updated via service: " + requestPlate);
        return {car: updatedCar, message: "Car updated successfully via service"};
    }

    resource function delete removeCar/[string plate]() returns RemoveCarResponse {
        io:println("🗑️ Service RemoveCar called for plate: " + plate);

        if !cars.hasKey(plate) {
            Car[] allCars = cars.toArray();
            return {message: "Car not found", remainingCars: allCars};
        }

        Car removedCar = cars.remove(plate);
        Car[] remainingCars = cars.toArray();
        io:println("✅ Car removed via service: " + plate);
        return {message: "Car removed successfully via service", remainingCars: remainingCars};
    }

    resource function get listAvailableCars(string keyword = "", int? year = ()) returns ListCarsResponse {
        io:println("📋 Service ListAvailableCars called with filter: " + keyword);

        FilterRequest filter = {keyword: keyword, year: year};
        return listAvailableCars(filter);
    }

    resource function get searchCar/[string plate]() returns CarResponse {
        io:println("🔍 Service SearchCar called for plate: " + plate);

        PlateRequest req = {plate: plate};
        return searchCar(req);
    }

    resource function post addToCart(CartItem request) returns CartResponse {
        io:println("🛒 Service AddToCart called for plate: " + request.plate);
        return addToCart(request);
    }

    resource function post placeReservation(ReservationRequest request) returns ReservationResponse {
        io:println("📋 Service PlaceReservation called for user: " + request.userId);
        return placeReservation(request);
    }
}
