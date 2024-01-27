ESX = exports["es_extended"]:getSharedObject()
local PlayerData = {}

-- Function to check if a value exists in a table
-- @param tab table: The table to search
-- @param val any: The value to search for
-- @return boolean: True if the value is found, false otherwise
local function has_value (tab, val)
    -- Iterate through the table
    for index, value in ipairs(tab) do
        -- Check if the value matches the search value
        if value == val then
            return true
        end
    end

    -- Value not found
    return false
end

-- Function to check if the player's job is police
function isPlayerJobPolice()
	-- Iterate through the player data
	for k,v in pairs(ESX.GetPlayerData()) do
		-- Iterate through the keys and values of the player data
		for k,v in pairs(k) do
			-- Print the value
			print(v)
		end
	end
end

-- Function to assess and return the lucky status based on a specified chance
-- and a condition determined by the door angle.
-- @param chanceConfig A table containing a 'chance' value (number between 0 and 100)
-- @param doorOpenAngle The angle of the door, used to determine if the door is considered open
-- @return The normalized chance (number) and the lucky status (boolean)
function assessLuckyStatus(chanceConfig, doorOpenAngle)
	-- Validate inputs
	if type(chanceConfig) ~= "table" or type(chanceConfig.chance) ~= "number" or not chanceConfig.blacklist then
        error("Invalid chance configuration provided.")
    end
	if type(doorOpenAngle) ~= "number" then
		error("Invalid door angle provided.")
	end
	
	-- Normalize the chance
	local normalizedChance = math.min(100, math.max(0, chanceConfig.chance))
	-- Check if vehicle is in blacklist
	local blacklisted = false
	for _, model in pairs(chanceConfig.blacklist) do
		if IsVehicleModel(vehicle, GetHashKey(model)) then
			blacklisted = true
			print("Vehicle is blacklisted")
			break -- Exit the loop if the vehicle is found in the blacklist
		end
	end
	-- If the vehicle is blacklisted, it's not lucky
	local isLucky = not blacklisted and (math.random(100) < normalizedChance)
	
	-- If the door is open (angle > 0.0), override isLucky to true
	if doorOpenAngle > 0.0 then
		isLucky = true
	end
	return blacklisted, isLucky
end

--[[enum VehicleLockStatus = {
					None = 0,
					Unlocked = 1,
					Locked = 2,
					LockedForPlayer = 3,
					StickPlayerInside = 4, -- Doesn't allow players to exit the vehicle with the exit vehicle key.
					CanBeBrokenInto = 7, -- Can be broken into the car. If the glass is broken, the value will be set to 1
					CanBeBrokenIntoPersist = 8, -- Can be broken into persist
					CannotBeTriedToEnter = 10, -- Cannot be tried to enter (Nothing happens when you press the vehicle enter key).
				}]]



Citizen.CreateThread(function()
	while true do
		-- gets if player is entering vehicle
		if DoesEntityExist(GetVehiclePedIsTryingToEnter(PlayerPedId())) then
			-- gets vehicle player is trying to enter and its isLock status
			local xPlayer = ESX.GetPlayerData()
			local driverPed = GetPedInVehicleSeat(vehicle, -1) -- gets ped that is driving the vehicle
			local vehicle = GetVehiclePedIsTryingToEnter(PlayerPedId()) -- gets the vehicle the player is trying to enter to
			local vehiclePlate = GetVehicleNumberPlateText(vehicle) -- gets The vehicle Plate
			local isLock = GetVehicleDoorLockStatus(vehicle) -- gets the vehicle's lock status
			local doorAngle = GetVehicleDoorAngleRatio(vehicle, 0) -- Checks the angle of the door mapped from 0.0 - 1.0 where 0.0 is fully closed and 1.0 is fully open
			local blacklisted, isLucky = assessLuckyStatus(cfg , doorAngle) -- checks if player is lucky or vehicle is blacklisted
			
			
			-- isLock doors if not lucky or blacklisted
			if ((isLock == 7) or (driverPed ~= 0 )) then
				if has_value(cfg.job_whitelist, xPlayer.job.name) then
					TriggerServerEvent('esx_nocarjack:setVehicleDoorsForEveryone', {vehicle, 1, vehiclePlate})
				else
					if not isLucky or blacklisted then
						print("Not Lucky or Blacklisted")
						TriggerServerEvent('esx_nocarjack:setVehicleDoorsForEveryone', {vehicle, 2, vehiclePlate})
					else
						print("Lucky")
						TriggerServerEvent('esx_nocarjack:setVehicleDoorsForEveryone', {vehicle, 1, vehiclePlate})
					end
				end
			end
		end
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx_nocarjack:setVehicleDoors')
AddEventHandler('esx_nocarjack:setVehicleDoors', function(vehicle, doors)
	SetVehicleDoorsLocked(vehicle, doors)
	print("Locked Doors")
end)
