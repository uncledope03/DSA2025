import ballerina/http;
import ballerina/io;

listener http:Listener httpListener = new (8080);

service /carRental on httpListener {

    resource function post addCar(AddCarRequest request) returns CarResponse {
        io:println("🚗 HTTP AddCar called for plate: " + request.plate);
        return addCar(request);
    }

    resource function post createUsers(CreateUsersRequest request) returns CreateUsersResponse {
        io:println("👥 HTTP CreateUsers called");
        return createUsers(request);
    }

    resource function put updateCar(UpdateCarRequest request) returns CarResponse {
        io:println("🔄 HTTP UpdateCar called for plate: " + request.plate);
        return updateCar(request);
    }

    resource function delete removeCar/[string plate]() returns RemoveCarResponse {
        io:println("🗑️ HTTP RemoveCar called for plate: " + plate);
        PlateRequest req = {plate: plate};
        return removeCar(req);
    }

    resource function get listAvailableCars(string keyword = "", int? year = ()) returns ListCarsResponse {
        io:println("📋 HTTP ListAvailableCars called with filter: " + keyword);
        FilterRequest filter = {keyword: keyword, year: year};
        return listAvailableCars(filter);
    }

    resource function get searchCar/[string plate]() returns CarResponse {
        io:println("🔍 HTTP SearchCar called for plate: " + plate);
        PlateRequest req = {plate: plate};
        return searchCar(req);
    }

    resource function post addToCart(CartItem request) returns CartResponse {
        io:println("🛒 HTTP AddToCart called for plate: " + request.plate);
        return addToCart(request);
    }

    resource function post placeReservation(ReservationRequest request) returns ReservationResponse {
        io:println("📋 HTTP PlaceReservation called for user: " + request.userId);
        return placeReservation(request);
    }
}
