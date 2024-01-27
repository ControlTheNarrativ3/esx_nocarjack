ESX = exports["es_extended"]:getSharedObject()
local PlayerData = {}


local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function isPlayerJobPolice()
	for k,v in pairs(ESX.GetPlayerData()) do
		for k,v in pairs(k) do
			print(v)
		end
	end
end

Citizen.CreateThread(function()
	while true do
		-- gets if player is entering vehicle
		local veh = GetVehiclePedIsTryingToEnter(PlayerPedId())
		if DoesEntityExist(veh) then
			-- gets vehicle player is trying to enter and its lock status
			local lock = GetVehicleDoorLockStatus(veh)
			local doorAngle = GetVehicleDoorAngleRatio(veh, 0)
			local lucky = (math.random(100) < math.min(100, math.max(0, cfg.chance)))
			local blacklisted = false
			for k,model in pairs(cfg.blacklist) do
				if IsVehicleModel(veh, GetHashKey(model)) then
					blacklisted = true
					break
				end
			end
			local pedd = GetPedInVehicleSeat(veh, -1)
			local plate = GetVehicleNumberPlateText(veh)
			-- lock doors if not lucky or blacklisted
			if lock == 7 or pedd ~= 0 then
				if has_value(cfg.job_whitelist, xPlayer.job.name) then
					TriggerServerEvent('esx_nocarjack:setVehicleDoorsForEveryone', {veh, 1, plate})
				else
					if not lucky or blacklisted then
						TriggerServerEvent('esx_nocarjack:setVehicleDoorsForEveryone', {veh, 2, plate})
					else
						TriggerServerEvent('esx_nocarjack:setVehicleDoorsForEveryone', {veh, 1, plate})
					end
				end
			end
		end
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx_nocarjack:setVehicleDoors')
AddEventHandler('esx_nocarjack:setVehicleDoors', function(veh, doors)
	SetVehicleDoorsLocked(veh, doors)
end)
