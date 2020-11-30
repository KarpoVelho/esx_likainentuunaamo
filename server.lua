ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local Vehicles = nil

RegisterServerEvent('karponpaja:buyMod')
AddEventHandler('karponpaja:buyMod', function(price)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	price = tonumber(price)
		if price < xPlayer.getAccount('black_money').money then --checkkaa jos pelaajalla on tarpeeksi rahaa ja sitten:
			TriggerClientEvent('karponpaja:installMod', _source) --laittaa tuunauksen
			TriggerClientEvent('esx:showNotification', _source, _U('purchased')) --notificaatio
			xPlayer.removeAccountMoney('black_money', price) --poistaa likaset rahat
		else
			TriggerClientEvent('karponpaja:cancelInstallMod', _source) 
			TriggerClientEvent('esx:showNotification', _source, _U('not_enough_money'))
		end
	end
end)

RegisterServerEvent('karponpaja:refreshOwnedVehicle')
AddEventHandler('karponpaja:refreshOwnedVehicle', function(myCar)
	MySQL.Async.execute('UPDATE `owned_vehicles` SET `vehicle` = @vehicle WHERE `plate` = @plate',
	{
		['@plate']   = myCar.plate,
		['@vehicle'] = json.encode(myCar)
	})
end)

ESX.RegisterServerCallback('karponpaja:getVehiclesPrices', function(source, cb)
	if Vehicles == nil then
		MySQL.Async.fetchAll('SELECT * FROM vehicles', {}, function(result)
			local vehicles = {}

			for i=1, #result, 1 do
				table.insert(vehicles, {
					model = result[i].model,
					price = result[i].price
				})
			end

			Vehicles = vehicles
			cb(Vehicles)
		end)
	else
		cb(Vehicles)
	end
end)
