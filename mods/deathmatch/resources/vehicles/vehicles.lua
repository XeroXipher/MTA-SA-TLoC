

addCommandHandler("createVehicle", function(player, command, model, rx, ry, rz)

    local db = exports.db.getConnection();
    local x, y, z = getElementPosition(player);
    local y = y + 5
    local rx, ry, rz = getElementRotation(player);

    dbExec(db, "INSERT INTO vehicles (model, x, y, z, rx, ry, rz) VALUES(?,?,?,?,?,?,?)", model, x, y, z, rx, ry, rz);    
   
    local vehicleObject = createVehicle(model, x, y, z, rx, ry, rz);
   
    dbQuery(function(queryHandle)
        local results = dbPoll(queryHandle, 0)
        local vehicle = results[1]

            
        
        setElementData(vehicleObject, "id", vehicle.id)


    end, db, "SELECT id FROM vehicles ORDER BY id DESC LIMIT 1");


end, false, false);



function loadAllVehicles(queryHandle)
    local results = dbPoll(queryHandle, 0)

    for index, vehicle in pairs(results) do
        local vehicleObject = createVehicle(vehicle.model, vehicle.x, vehicle.y, vehicle.z, vehicle.rx, vehicle.ry, vehicle.rz);
        
        setElementData(vehicleObject, "id", vehicle.id)
    end
end;


addEventHandler("onResourceStart", resourceRoot, function()
    local db = exports.db.getConnection();
    dbQuery(loadAllVehicles, db, "SELECT * FROM vehicles")
    
end);

addEventHandler("onResourceStop", resourceRoot, function()
    local db = exports.db.getConnection();
    local vehicles = getElementsByType("vehicle")

    for index, vehicle in pairs(vehicles) do
        local id = getElementData(vehicle, "id")
        local x,y,z = getElementPosition(vehicle)

        local rx, ry, rz = getElementRotation(vehicle)
        dbExec(db, "UPDATE vehicles SET x = ?, y = ?, z = ?, rx = ?, ry = ?, rz = ? WHERE id = ?", x, y, z, rx, ry, rz, id);
       
    end
end);
