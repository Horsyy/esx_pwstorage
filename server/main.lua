ESX = nil
local busy = false

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_pwstorage:setBusy')
AddEventHandler('esx_pwstorage:setBusy', function(type)
	if type == 1 then
		busy = true
	else
		busy = false
	end
end)

ESX.RegisterServerCallback('esx_pwstorage:isBusy',function(source, cb)
	cb(busy)
end)

AddEventHandler('esx:playerDropped', function()
	if busy then
		busy = false
	end
end)

ESX.RegisterServerCallback('esx_pwstorage:isExpired',function(source, cb, password)
	if Config.CheckForExpired then
		CurrentDate = os.date("%d/%m/%Y")
		if Config.EnableSQL then
			MySQL.Async.fetchAll('SELECT society,UNIX_TIMESTAMP(expired) AS expired FROM esx_pwstorage WHERE password = @password', {['@password'] = password}, function(data)
				local dt = data[1].expired
				local society = data[1].society

				if dt<os.time() then
					cb(true)
				else
					cb(false, society)
				end
			end)
		else
			local dt = {year=Config.PwStorages[tonumber(password)]['expired']['year'], month=Config.PwStorages[tonumber(password)]['expired']['month'], day=Config.PwStorages[tonumber(password)]['expired']['day']}
			if os.time(dt)<os.time() then
				cb(true)
			else
				cb(false)
			end
		end
	else
		cb(false)
	end
end)

------------------------------------------------------------------------------
------------------------- ADD DATABASE USING COMMAND -------------------------
------------------------------------------------------------------------------

if Config.EnableCommands then
	ESX.RegisterCommand('addStorage', Config.AuthorizedMembers, function(xPlayer, args, showError)
		if args.society then
			storage = 'society_' .. args.society .. 'Storage'
			label = args.society .. ' Storage'
			password = args.password
			expired = args.expired
			
			for k,v in ipairs(MySQL.Sync.fetchAll("SELECT * FROM esx_pwstorage")) do
				if v.password == password then
					xPlayer.showNotification(_U('existsPass'))
					return
				elseif v.society == storage then
					xPlayer.showNotification(_U('exists'))
					return
				end
			end

			MySQL.Async.fetchAll('SELECT * FROM addon_account WHERE name = @name', {['@name'] = storage}, function(data) -- Just to be safe for DataBase duplicates
				if next(data) == nil then
					xPlayer.triggerEvent('esx_pwstorage:addDataBase', storage, label, password, expired)
					xPlayer.showNotification(_U('preparing', args.society, password))

					--[[if not Config.EnableSQL then
						local playerId = xPlayer.source
						date_added = os.date("%d/%m/%Y %X")
						local path = GetResourcePath(GetCurrentResourceName())
						path = path:gsub('//', '/')..'/config.lua'

						file = io.open(path, 'a+')
						label = '\n\n-- Storage Added by ' ..GetPlayerName(playerId).. ' under the name "'.. label ..'" with Password: "'.. password ..'" ('.. date_added ..')\ntable.insert(Config.PwStorages, {'
						file:write(label)
						file:write("[".. password .."] = { ['society'] = '".. storage .."' }")
						file:write('})')
						file:close()
					end]]
				else
					xPlayer.showNotification(_U('exists'))
				end
			end)
		end
	end, true, {help = _U('StorageHelp'), validate = true, arguments = {
		{name = 'society', help = _U('SocietyHelp'), type = 'string'},
		{name = 'password', help = _U('SocietyHelpPass'), type = 'string'},
		{name = 'expired', help = _U('SocietyExpired'), type = 'string'}
	}})

	RegisterServerEvent('esx_pwstorage:addDataBase')
	AddEventHandler('esx_pwstorage:addDataBase', function(storage, label, password, expired)
		local xSource = ESX.GetPlayerFromId(source)
		if xSource.getGroup() == 'user' then
			DropPlayer(source, '[esx_pwstorage] Lua Injection')
			return
		end

		if not Config.EnableSQL then
			local playerId = xPlayer.source
			date_added = os.date("%d/%m/%Y %X")
			local path = GetResourcePath(GetCurrentResourceName())
				path = path:gsub('//', '/')..'/config.lua'

				file = io.open(path, 'a+')
				label = '\n\n-- Storage Added by ' ..GetPlayerName(playerId).. ' under the name "'.. label ..'" with Password: "'.. password ..'" ('.. date_added ..')\ntable.insert(Config.PwStorages, {'
				file:write(label)
				file:write("[".. password .."] = { ['society'] = '".. storage .."' }")
				file:write('})')
				file:close()
		end

		MySQL.Async.execute("INSERT INTO esx_pwstorage (password, society, expired) VALUES (@password, @society, @expired)",{['@password'] = password, ['@society'] = storage, ['@expired'] = expired})
		MySQL.Async.execute("INSERT INTO addon_account (name, label, shared) VALUES (@name, @label, @shared)",{['@name'] = storage, ['@label'] = label, ['@shared'] = 1})
		MySQL.Async.execute("INSERT INTO addon_account (name, label, shared) VALUES (@name, @label, @shared)",{['@name'] = storage .. '_blackMoney', ['@label'] = label .. ' Black Money', ['@shared'] = 1})
		MySQL.Async.execute("INSERT INTO datastore (name, label, shared) VALUES (@name, @label, @shared)",{['@name'] = storage, ['@label'] = label, ['@shared'] = 1})
		MySQL.Async.execute("INSERT INTO addon_inventory (name, label, shared) VALUES (@name, @label, @shared)",{['@name'] = storage, ['@label'] = label, ['@shared'] = 1})
		xSource.showNotification(_U('addedStorage', storage))
	end)

	ESX.RegisterCommand('renewStorage', Config.AuthorizedMembers, function(xPlayer, args, showError)
		if args.password then
			password = args.password
			expired = args.expired

			for k,v in ipairs(MySQL.Sync.fetchAll("SELECT * FROM esx_pwstorage")) do
				if v.password == password then
					MySQL.Async.execute("UPDATE esx_pwstorage SET expired=@expired WHERE password=@password", {['@expired'] = expired, ['@password'] = password})
					xPlayer.showNotification('~y~Expiration~s~ Date changed to ~g~'.. expired ..'~s~ from ~r~'.. v.expired ..'~s~.')
				end
			end
		end
	end, true, {help = _U('StorageHelp'), validate = true, arguments = {
		{name = 'password', help = _U('renewHelpPass'), type = 'string'},
		{name = 'expired', help = _U('renewExpired'), type = 'string'}
	}})
end