ESX = exports["es_extended"]:getSharedObject()

local vehicles = {}

function getVehData(plate, callback)
    local query = [[
        SELECT 
            ov.plate AS plate, 
            CONCAT(u.firstname, ' ', u.lastname) AS ownerName
        FROM 
            `owned_vehicles` ov
        LEFT JOIN 
            `users` u ON ov.owner = u.identifier
        WHERE 
            ov.plate = @plate
    ]]
    
    MySQL.Async.fetchAll(query, {['@plate'] = plate},
    function(result)
        local info = {}
        if result and result[1] then
            info.plate = result[1].plate
            info.owner = result[1].ownerName
        else
            info.plate = plate
        end
        callback(info)
    end)
end

RegisterNetEvent("esx_nocarjack:setVehicleDoorsForEveryone")
AddEventHandler("esx_nocarjack:setVehicleDoorsForEveryone", function(veh, doors, plate)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local veh_model = veh[1]
    local veh_doors = veh[2]
    local veh_plate = veh[3]

    if not vehicles[veh_plate] then
        getVehData(veh_plate, function(veh_data)
            if veh_data.plate ~= plate then
                local players = GetPlayers()
                for _,player in pairs(players) do
                    TriggerClientEvent("esx_nocarjack:setVehicleDoors", player, table.unpack(veh, doors))
                end
            end
        end)
        vehicles[veh_plate] = true
    end
end)