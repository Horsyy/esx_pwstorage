local CurrentActionData, currentTask = {}, {}
local HasAlreadyEnteredMarker, hasAlreadyJoined, addBlip, setBusy, addingDB = false, false, true, false, false
local LastStation, LastPart, LastPartNum, LastEntity, CurrentAction, CurrentActionMsg
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end
end)

AddEventHandler('esx_pwstorage:hasEnteredMarker', function(station, part, partNum)
	if part == 'Storage' then
		CurrentAction     = 'menu_storage'
		CurrentActionMsg  = _U('open_storage')
		CurrentActionData = {station = station}
	end
end)

AddEventHandler('esx_pwstorage:hasExitedMarker', function(station, part, partNum)
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
	if setBusy and Config.EnableRestrictedMode then
		TriggerServerEvent('esx_pwstorage:setBusy', 0)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local playerPed = PlayerPedId()
		local playerCoords = GetEntityCoords(playerPed)
		local isInMarker, hasExited, letSleep = false, false, true
		local currentStation, currentPart, currentPartNum

		if addBlip and Config.EnableBlips then
			for k,v in pairs(Config.StorageLocations) do
				for i=1, #v.Storages, 1 do
				  blip = AddBlipForCoord(v.Storages[i])
				  SetBlipSprite(blip, Config.Sprite)
				  SetBlipDisplay(blip, 4)
				  SetBlipScale(blip, Config.BlipSize)
				  SetBlipColour(blip, Config.BlipColor)
				  SetBlipAlpha(blip, Config.BlipTransparency)
				  SetBlipAsShortRange(blip, true)
				  BeginTextCommandSetBlipName("STRING")
				  AddTextComponentSubstringPlayerName(_('blip'))
				  EndTextCommandSetBlipName(blip)
				end
			end
			addBlip = false
		end

		if ((IsControlJustPressed(0, 73) or IsControlJustPressed(0, 177) or IsControlJustPressed(0, 200)) and addingDB) and Config.EnableCommands then
			ESX.ShowNotification(_U('canceling'))
			TriggerEvent('mythic_progbar:client:cancel')
			addingDB = false
		end

		for k,v in pairs(Config.StorageLocations) do
			for i=1, #v.Storages, 1 do
				local distance = #(playerCoords - v.Storages[i])

				if distance < Config.DrawDistance then
					DrawMarker(21, v.Storages[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
					letSleep = false

					if distance < Config.MarkerSize.x then
						isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Storage', i
					end
				end
			end
		end

		if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)) then
			if
				(LastStation and LastPart and LastPartNum) and
				(LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)
			then
				TriggerEvent('esx_pwstorage:hasExitedMarker', LastStation, LastPart, LastPartNum)
				hasExited = true
			end

			HasAlreadyEnteredMarker = true
			LastStation             = currentStation
			LastPart                = currentPart
			LastPartNum             = currentPartNum

			TriggerEvent('esx_pwstorage:hasEnteredMarker', currentStation, currentPart, currentPartNum)
		end

		if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('esx_pwstorage:hasExitedMarker', LastStation, LastPart, LastPartNum)
		end

		if letSleep then
			Citizen.Wait(500)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction then
			ESX.ShowHelpNotification(CurrentActionMsg)
			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'menu_storage' then
					TriggerEvent("mythic_progbar:client:progress", {
						name = "Opening_Storage",
						duration = math.random(200, 2000),
						label = _U('progbar'),
						useWhileDead = false,
						canCancel = true,
						controlDisables = {
							disableMovement = true,
							disableCarMovement = true,
							disableMouse = false,
							disableCombat = true,
						}
					}, function(status)
						if not status then
							if Config.EnableRestrictedMode then
								Citizen.Wait(math.random(100, 1000))
								ESX.TriggerServerCallback('esx_pwstorage:isBusy', function(busy)
									if not busy then
										OpenStorageArmoryMenu(CurrentActionData.station)
										TriggerServerEvent('esx_pwstorage:setBusy', 1)
										setBusy = true
									else
										ESX.ShowNotification(_U('busy_msg'))
									end
								end)
							else
								OpenStorageArmoryMenu(CurrentActionData.station)
							end
						end
					end)
				end
				CurrentAction = nil
			end
		end
	end
end)

function OpenStorageArmoryMenu(station)
	local elements = {}

	table.insert(elements, {label = '<span style="color:green;">'.. _U('menu_pass') ..'</span>', value = 'pass'})

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'storage', {
		title    = _U('menu_title'),
		align    = 'left',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'pass' then
			password = KeyboardInput("Send a message : ", "Password :", "", Config.PasswordLength)

			ESX.TriggerServerCallback('esx_pwstorage:isExpired', function(isExpired, society)
				if not isExpired then
					if Config.EnableSQL then
						ESX.ShowNotification(society)
						TriggerEvent("esx_inventoryhud:openStorageInventory", society)
					else
						ESX.ShowNotification(Config.PwStorages[tonumber(password)]['society'])
						TriggerEvent("esx_inventoryhud:openStorageInventory", Config.PwStorages[tonumber(password)]['society'])
					end
				else
					ESX.ShowNotification(_U('expired'))
				end
			end, password)
		end
	end, function(data, menu)
		menu.close()
		if Config.EnableRestrictedMode then
			TriggerServerEvent('esx_pwstorage:setBusy', 0)
			setBusy = false
		end
	end)
end

function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
    AddTextEntry(entryTitle, textEntry)

    DisplayOnscreenKeyboard(1, entryTitle, '', inputText, '', '', '', maxLength)
    blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        blockinput = false
        return result
    else
        Citizen.Wait(500)
        blockinput = false
        return nil
    end
end

------------------------------------------------------------------------------
------------------------- ADD DATABASE USING COMMAND -------------------------
------------------------------------------------------------------------------
if Config.EnableCommands then
	RegisterNetEvent('esx_pwstorage:addDataBase')
	AddEventHandler('esx_pwstorage:addDataBase', function(storage, label, password, expired)
		addingDB = true
		TriggerEvent("mythic_progbar:client:progress", {
			name = "Adding_Database",
			duration = 5000,
			label = _U('addingdb'),
			useWhileDead = false,
			canCancel = true,
			controlDisables = {
				disableMovement = false,
				disableCarMovement = false,
				disableMouse = false,
				disableCombat = true,
			}
		}, function(status)
			if not status then
				TriggerServerEvent('esx_pwstorage:addDataBase', storage, label, password, expired)
				addingDB = false
			end
		end)
	end)
end
