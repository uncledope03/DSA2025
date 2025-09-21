import ballerina/http;
import ballerina/time;

// Define Asset structure
type Asset record {|
    string assetTag;
    string name;
    string faculty;
    string department;
    string status;
    string acquiredDate;
    map<string> components;
    map<string> schedules;
    map<WorkOrder> workOrders;
|};

type WorkOrder record {|
    string id;
    string description;
    string status;
    Task[] tasks = [];
|};

type Task record {|
    string id;
    string description;
    string status;
|};

 
map<Asset> assetDB = {};
 
function createCorsResponse() returns http:Response {
    http:Response response = new;
    response.setHeader("Access-Control-Allow-Origin", "*");
    response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
    response.setHeader("Access-Control-Allow-Headers", "Content-Type");
    return response;
}

// REST API service
service /assets on new http:Listener(8080) {

    // Handle CORS preflight requests
    resource function options .() returns http:Response {
        return createCorsResponse();
    }
 
    resource function options [string assetTag]() returns http:Response {
        return createCorsResponse();
    }

 
    resource function options faculty/[string faculty]() returns http:Response {
        return createCorsResponse();
    }

    // Create new asset
    resource function post .(Asset asset) returns http:Response|error {
        http:Response response = createCorsResponse();
        
        if assetDB.hasKey(asset.assetTag) {
            response.setTextPayload("Asset already exists!");
            response.statusCode = 400;
            return response;
        }
        assetDB[asset.assetTag] = asset;
        response.setTextPayload("Asset added successfully!");
        response.statusCode = 201;
        return response;
    }

    // Get all assets
    resource function get .() returns http:Response|error {
        http:Response response = createCorsResponse();
        Asset[] assets = from var [key, value] in assetDB.entries() select value;
        response.setJsonPayload(assets);
        return response;
    }

     
    resource function get [string assetTag]() returns http:Response|error {
        http:Response response = createCorsResponse();
        
        if assetDB.hasKey(assetTag) {
            response.setJsonPayload(assetDB[assetTag]);
            return response;
        }
        response.statusCode = 404;
        response.setTextPayload("Asset not found");
        return response;
    }

    // Update asset
    resource function put [string assetTag](Asset updated) returns http:Response|error {
        http:Response response = createCorsResponse();
        
        if assetDB.hasKey(assetTag) {
            assetDB[assetTag] = updated;
            response.setTextPayload("Asset updated successfully!");
            return response;
        }
        response.statusCode = 404;
        response.setTextPayload("Asset not found!");
        return response;
    }

    // Delete asset
    resource function delete [string assetTag]() returns http:Response|error {
        http:Response response = createCorsResponse();
        
        if assetDB.hasKey(assetTag) {
            _ = assetDB.remove(assetTag);
            response.setTextPayload("Asset removed successfully!");
            return response;
        }
        response.statusCode = 404;
        response.setTextPayload("Asset not found!");
        return response;
    }

    // View assets by faculty
    resource function get faculty/[string faculty]() returns http:Response|error {
        http:Response response = createCorsResponse();
        Asset[] assets = from var [key, value] in assetDB.entries()
               where value.faculty == faculty
               select value;
        response.setJsonPayload(assets);
        return response;
    }

     
    resource function get overdue() returns http:Response|error {
        http:Response response = createCorsResponse();
        string today = time:utcNow().toString();
        Asset[] assets = from var [key, value] in assetDB.entries()
               where value.schedules.toArray().some(function (string dueDate) returns boolean {
                   return dueDate < today;
               })
               select value;
        response.setJsonPayload(assets);
        return response;
    }

    
    resource function post [string assetTag]/components(string key, string value) returns http:Response|error {
        http:Response response = createCorsResponse();
        
        if assetDB.hasKey(assetTag) {
            assetDB[assetTag].components[key] = value;
            response.setTextPayload("Component added!");
            return response;
        }
        response.statusCode = 404;
        response.setTextPayload("Asset not found!");
        return response;
    }

    
    resource function post [string assetTag]/schedules(string key, string dueDate) returns http:Response|error {
        http:Response response = createCorsResponse();
        
        if assetDB.hasKey(assetTag) {
            assetDB[assetTag].schedules[key] = dueDate;
            response.setTextPayload("Schedule added!");
            return response;
        }
        response.statusCode = 404;
        response.setTextPayload("Asset not found!");
        return response;
    }
}