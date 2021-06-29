local CurrentActionData, currentTask = {}, {}
local HasAlreadyEnteredMarker, isDead, hasAlreadyJoined, addBlip = false, false, false, true
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
					exports['mythic_progbar']:Progress({
						name = "unique_action_name",
						duration = 1000,
						label = _U('progbar'),
						useWhileDead = true,
						canCancel = true,
						controlDisables = {
							disableMovement = true,
							disableCarMovement = true,
							disableMouse = false,
							disableCombat = true,
						}
					})
					Citizen.Wait(1000)

					OpenStorageArmoryMenu(CurrentActionData.station)
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
			password = KeyboardInput("Send a message : ",  "Password :","" ,4)
			TriggerEvent("esx_inventoryhud:openStorageInventory", Config.PwStorages[tonumber(password)]["society"])
		end
	end, function(data, menu)
		menu.close()

		CurrentAction     = 'menu_storage'
		CurrentActionMsg  = _U('open_storage')
		CurrentActionData = {station = station}
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

AddEventHandler('playerSpawned', function(spawn)
	isDead = false
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
end)
