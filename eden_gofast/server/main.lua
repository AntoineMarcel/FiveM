ESX = nil
CopsConnected = 0

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('esx:playerLoaded', function(source)

	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'police' then
		CopsConnected = CopsConnected + 1
	end
end)

AddEventHandler('esx:playerDropped', function(source)

	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'police'  then
		CopsConnected = CopsConnected - 1
	end
end)

AddEventHandler('esx:setJob', function(source, job, lastJob)

	local xPlayer = ESX.GetPlayerFromId(source)

	if job.name == 'police' and lastJob.name ~= 'police' then
		CopsConnected = CopsConnected + 1
	end

	if job.name ~= 'police' and lastJob.name == 'police' then
		CopsConnected = CopsConnected - 1
	end
end)

----------------------------------------------------------------------
------------------------------- OTHER  -------------------------------
----------------------------------------------------------------------
RegisterServerEvent("eden_gofast:check")
AddEventHandler("eden_gofast:check", function(caution)
  	local _source        = source
	local xPlayer        = ESX.GetPlayerFromId(_source)
	local xPlayers 		 = ESX.GetPlayers()
	local time 		     = os.date("%d/%m/%y %X")
  	local pack_drugs 	 = xPlayer.getInventoryItem('pack_drugs').count

	  TriggerClientEvent('eden_gofast:StartNotify', -1)

	if pack_drugs >= 1 then
		TriggerClientEvent('esx:showNotification', source,  _U('have_drug'))
	else

		if CopsConnected >= 0 then
			TriggerClientEvent('eden_gofast:start', _source)
			print('GostFast lance par : ' ..xPlayer.name .. ' a : ' .. time)
    		xPlayer.addInventoryItem('pack_drugs', 1)

			for i=1, #xPlayers, 1 do
				local xPlayer2 = ESX.GetPlayerFromId(xPlayers[i])
				if xPlayer2.job.name == 'police' then
					TriggerClientEvent('esx:showNotification', xPlayers[i], _U('police_start'))
				end
			end
		else
			TriggerClientEvent('esx:showNotification', _source, _U('need_cop'))
		end
  	end
end)

RegisterServerEvent('eden_gofast:remove_caution')
AddEventHandler('eden_gofast:remove_caution', function(caution,localisation)
	local _source        = source
	local xPlayer        = ESX.GetPlayerFromId(_source)

	xPlayer.removeMoney(caution)
end)

RegisterServerEvent('eden_gofast:itemremove')
AddEventHandler('eden_gofast:itemremove', function(reward)

	local _source			= source
	local xPlayer  		= ESX.GetPlayerFromId(source)
	local xPlayers 		= ESX.GetPlayers()
	local pack_drugs 	= xPlayer.getInventoryItem('pack_drugs').count
	local time 		    = os.date("%d/%m/%y %X")

	if pack_drugs < 1 then
    TriggerClientEvent('esx:showNotification', source, _U('dont_have_pack_drugs'))
		TriggerClientEvent('eden_gofast:ragepnj', _source)
		print('GostFast fini par : ' ..xPlayer.name .. ' a : ' .. time .. '// Fail pas de drogue avec lui' )
	else

		for i=1, #xPlayers, 1 do
			local xPlayer2 = ESX.GetPlayerFromId(xPlayers[i])
			if xPlayer2.job.name == 'police' then
				TriggerClientEvent('esx:showNotification', xPlayers[i], _U('police_finish'))
			end
		end

		xPlayer.addAccountMoney('black_money', reward)
		TriggerClientEvent('eden_gofast:recuperation', _source)
		TriggerClientEvent('esx:showNotification', source, _U('your_reward') ..reward.. '$')
		xPlayer.removeInventoryItem('pack_drugs', 1)

		print('GostFast fini par : ' ..xPlayer.name .. ' a : ' .. time .. '// Gain : '..reward..'$' )
	end
	TriggerClientEvent('eden_gofast:StartNotify', -1)
end)


RegisterServerEvent('eden_gofast:failrun')
AddEventHandler('eden_gofast:failrun', function()

	local _source		  = source
	local xPlayer  		= ESX.GetPlayerFromId(source)
	local time 		    = os.date("%d/%m/%y %X")

	print('GostFast fini par : ' ..xPlayer.name .. ' a : ' .. time .. '// Mission FAIL ')
end)
