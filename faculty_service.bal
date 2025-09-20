 
//Handles filtering & reporting:

//GET /assets/faculty/{faculty} → Get assets by faculty

//GET /assets/overdue → Get assets with overdue schedules


 

//   faculty
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