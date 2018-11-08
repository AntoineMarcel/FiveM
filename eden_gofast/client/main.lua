local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX 						= nil
PlayerData					= {}
local currentlyfast		 	= false
local secondsRemaining  	= 0
local generalLoaded 		= false
local PlayingAnim 			= false
local ok 					= false
local ped					= {}
local first 				= false
local StartGoFast 			= false
local missionped = {
	{id=1, Name=StartPed, VoiceName="GENERIC_INSULT_HIGH", Ambiance="AMMUCITY", Weapon=1649403952, modelHash="G_M_Y_BallaOrig_01", x = -1409.0158691406, y = 546.56646728516, z = 121.92869567871, heading=269.059},
	{id=2, Name=StartDog, VoiceName="GENERIC_INSULT_HIGH", Ambiance="AMMUCITY", Weapon=1649403952, modelHash="A_C_Rottweiler", 	x = -1410.0158691406, y = 547.56646728516, z = 121.92869567871, heading=257.118}}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(1)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

Citizen.CreateThread(function()
	Citizen.Wait(1)
	if (not generalLoaded) then
		for i=1, #missionped do
			RequestModel(GetHashKey(missionped[i].modelHash))
			while not HasModelLoaded(GetHashKey(missionped[i].modelHash)) do
			Citizen.Wait(10)
			end

			RequestAnimDict('creatures@rottweiler@amb@world_dog_sitting@base')
			while not HasAnimDictLoaded('creatures@rottweiler@amb@world_dog_sitting@base') do
				Citizen.Wait(10)
			end

			missionped[i].id = CreatePed(28, missionped[i].modelHash, missionped[i].x, missionped[i].y, missionped[i].z, missionped[i].heading, false, false)
			if missionped[i].modelHash == "G_M_Y_BallaOrig_01" then
				SetPedFleeAttributes(missionped[i].id, 0, 0)
				SetAmbientVoiceName(missionped[i].id, missionped[i].Ambiance)
				SetPedDropsWeaponsWhenDead(missionped[i].id, false)
				SetPedDiesWhenInjured(missionped[i].id, false)
				GiveWeaponToPed(missionped[i].id, 324215364, 2800, true, true)
			end

			if missionped[i].modelHash == "A_C_Rottweiler" then
				TaskPlayAnim(missionped[i].id,'creatures@rottweiler@amb@world_dog_sitting@base', 'base' ,8.0, -8, -1, 1, 0, false, false, false )
			end

			Citizen.Wait(1500)
			SetEntityInvincible(missionped[i].id , true)
			FreezeEntityPosition(missionped[i].id, true)
		end
	end
	generalLoaded = true
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		RequestAnimDict("gestures@m@standing@casual")
		while (not HasAnimDictLoaded("gestures@m@standing@casual")) do
			Citizen.Wait(10)
		end

		RequestAnimDict("cellphone@")
		while (not HasAnimDictLoaded("cellphone@")) do
			Citizen.Wait(10)
		end

		for i=1, #missionped do
			distance = GetDistanceBetweenCoords(missionped[i].x, missionped[i].y, missionped[i].z, GetEntityCoords(GetPlayerPed(-1)))

			if distance < 4 and PlayingAnim ~= true then
				if PlayingAnim == true then
					TaskPlayAnim(missionped[i].id,"gestures@m@standing@casual","gesture_bring_it_on", 1.0, -1.0, -1, 0, 1, true, true, true)
				end

				if missionped[i].modelHash == "A_C_Rottweiler" then
					TaskPlayAnim(missionped[i].id,'creatures@rottweiler@amb@world_dog_sitting@base', 'base' ,8.0, -8, -1, 1, 0, false, false, false )
				end

				TaskPlayAnim(missionped[i].id,"gestures@m@standing@casual","gesture_come_here_soft", 1.0, -1.0, 4000, 0, 1, true, true, true)
				PlayAmbientSpeech1(missionped[i].id, missionped[i].VoiceName, "SPEECH_PARAMS_FORCE", 1)
				PlayingAnim = true
				headsUp(_U('press_start'))
			end
			if distance > 5.5 and distance < 6 then
				PlayingAnim = false
			end
		end
	end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(10)
    local coords	 = GetEntityCoords(GetPlayerPed(-1))
	local phoneModel = GetHashKey('prop_npc_phone_02')

	distance = GetDistanceBetweenCoords(-1409.0158691406, 546.56646728516, 122.92869567871, GetEntityCoords(GetPlayerPed(-1)))

    if distance < 4 and not (PlayerData.job ~= nil and PlayerData.job.name == 'police') then
		if IsControlJustPressed(1, Keys["E"]) then

			for i=1, #missionped do
				if missionped[i].modelHash == "G_M_Y_BallaOrig_01" then

					local coords1    = GetEntityCoords(missionped[i].id )
					local bone       = GetPedBoneIndex(missionped[i].id , 28422)

					RequestModel(phoneModel)
					while not HasModelLoaded(phoneModel) do
						Citizen.Wait(10)
					end

					RequestAnimDict('cellphone@')
					while not HasAnimDictLoaded('cellphone@') do
						Citizen.Wait(10)
					end

					FreezeEntityPosition(missionped[i].id, false)
					GiveWeaponToPed(missionped[i].id, -1569615261, 2800, true, true)
					TaskPlayAnim(missionped[i].id , 'cellphone@', 'cellphone_call_listen_base', 1.0, -1, -1, 50, 0, true, true, true)
					Citizen.Wait(680)
					CellphoneObject = CreateObject(phoneModel, coords1.x, coords1.y, coords1.z, 1, 1, 0)
					AttachEntityToEntity(CellphoneObject, missionped[i].id , bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
					Citizen.Wait(5000)
					DeleteObject(CellphoneObject)
					Citizen.Wait(250)
					GiveWeaponToPed(missionped[i].id, 324215364, 2800, true, true)
					ClearPedTasks(missionped[i].id )
					FreezeEntityPosition(missionped[i].id, true)
					TriggerServerEvent('eden_gofast:check')
				end
			end
    	end
    end
  end
end)

RegisterNetEvent('eden_gofast:start')
AddEventHandler('eden_gofast:start', function(caution)

	local plyCoords 	= GetEntityCoords(GetPlayerPed(-1), true)
	local Weapon		= 1649403952
	local randomSpawn   = math.random(#Config.MissionLocations)
	local RandomPed 	= Config.Peds[GetRandomIntInRange(1, #Config.Peds)]
	local mult 			= 10^(n or 0)

	RequestModel(RandomPed)
	while ( not HasModelLoaded(RandomPed) ) do
		Citizen.Wait(10)
	end

	CreateVehicule()
	currentlyfast 		= true
	first 				= false
	ok 					= false
	StartGoFast = true
	x,y,z= Config.MissionLocations[randomSpawn][1], Config.MissionLocations[randomSpawn][2], Config.MissionLocations[randomSpawn][3]
	localisation = AddBlipForCoord(x,y,z)
	SetBlipAsFriendly(localisation, 1)
	SetBlipCategory(localisation, 3)
	SetBlipRoute(localisation,  true)
	distancereward = GetDistanceBetweenCoords(-1409.0158691406, 546.56646728516, 122.92869567871,x,y,z, true)
	secondsRemaining = math.floor(((distancereward / 10 ) / 2) * mult + 0.5 ) / mult
	reward = (math.floor(((distancereward * math.random(5, 9)) / 100) * mult + 0.5) / mult ) * 15
	caution = math.floor((reward / math.random(3, 6)) * mult + 0.5) / mult
	TriggerServerEvent('eden_gofast:remove_caution', caution)
	ESX.ShowNotification(_U('give_drug') .. caution .. _U('give_drug2'))
	FinalPed = CreatePed(10,RandomPed,x,y,z,true, true)
	SetPedDropsWeaponsWhenDead(FinalPed, false)
	GiveWeaponToPed(FinalPed, Weapon, 2800, false, true)
	SetCurrentPedWeapon(FinalPed, Weapon,true)
	SetEntityAsMissionEntity(FinalPed, true,true)
end)

function CreateVehicule()

	local essence 		= math.random(80, 100)
	local playerPed		= GetPlayerPed(-1)
	local model			= Config.Vehicles[GetRandomIntInRange(1,  #Config.Vehicles)]
	local RandomPed 	= Config.Peds[GetRandomIntInRange(1,  #Config.Peds)]
	local Weapon		= 1649403952

	RequestModel(model)
	while not HasModelLoaded(model) do
		Citizen.Wait(10)
	end

	RequestModel(RandomPed)
	while not HasModelLoaded(RandomPed) do
		Citizen.Wait(10)
	end

	plyCar 		= 	CreateVehicle(model, -1445.0501708984, 420.69583129883, 109.76290893555, 180.112, 0, true, false)
	startped 	= 	CreatePedInsideVehicle(plyCar, 4, RandomPed, -1, true, false)
	TaskGoToCoordAnyMeans(startped, -1430.7426757813, 525.29656982422, 117.50813293457, 175.028, 0, 0, 0, 0xbf800000)
	SetVehicleOnGroundProperly(plyCar)
	TriggerEvent("advancedFuel:setEssence", essence , GetVehicleNumberPlateText(plyCar), GetDisplayNameFromVehicleModel(GetEntityModel(plyCar)))
	SetModelAsNoLongerNeeded(plyCar)
	SetVehicleColours(plyCar, math.random(0 , 5) , math.random(0 , 4) )
	SetVehicleWindowTint(plyCar, 1)
	SetVehicleModKit(plyCar, 0)
	SetVehicleWindowTint(plyCar, 1)
	SetVehicleNumberPlateText(plyCar, " Endora ")
	ToggleVehicleMod(plyCar, 18, true)
	SetVehicleMod(plyCar, 11,  math.random(0,3))
	SetVehicleMod(plyCar, 46, 5)
	ESX.ShowNotification(_U('give_veh') .. model .. _U('give_veh2'))
	Citizen.Wait(30000)
	SetPedDropsWeaponsWhenDead(startped, false)
	GiveWeaponToPed(startped, Weapon, 2800, false, true)
	SetCurrentPedWeapon(startped, Weapon,true)
	TaskGoToCoordAnyMeans(startped,-1409.0158691406, 546.56646728516, 122.92869567871, 5.0, 0, 0, 0, 0xbf800000)
end

function PNJCar()
	local seat 		= 0
	local Weapon 	= 453432689

	for i=4, 0, 1 do
		if IsVehicleSeatFree(plyCar,  seat) then
			seat = i
			break
		end
	end

	SetPedDropsWeaponsWhenDead(FinalPed, false)
	GiveWeaponToPed(FinalPed, Weapon, 2800, false, true)
	SetCurrentPedWeapon(FinalPed, Weapon,true)
	TaskEnterVehicle(FinalPed,  plyCar,  -1,  seat,  2.0,  0)
	TaskVehicleDriveWander(FinalPed, plyCar, 220.0, 1074528293)
	TaskVehicleDriveWander(FinalPed, plyCar, 220.0, 2883621)
 	TaskVehicleDriveWander(FinalPed, plyCar, 220.0, 5)
	TaskVehicleDriveWander(FinalPed, plyCar, 220.0, 786468)
	TaskVehicleDriveWander(FinalPed, plyCar, 220.0, 4194304)
	TaskVehicleDriveWander(FinalPed, plyCar, 220.0, 6)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		local coords 		= GetEntityCoords(GetPlayerPed(-1))
		local lastvehicule 	= GetVehiclePedIsIn(GetPlayerPed(-1),false)
		local distance2 	= GetDistanceBetweenCoords(coords.x,coords.y,coords.z,x,y,z)
		local minute = math.floor(secondsRemaining / 60)

		if distance2 < 5 and StartGoFast then
			if lastvehicule == plyCar then

				headsUp(_U('press_finish'))
				RemoveBlip(localisation)
				if IsControlJustPressed(1, Keys["E"]) then
					TriggerServerEvent('eden_gofast:itemremove', reward)
					StartGoFast = false
					first = true
				end
			else
				ESX.ShowNotification(_U('not_good_veh'))
				TaskCombatPed(FinalPed, GetPlayerPed(-1), 0, 16)
				RemoveBlip(localisation)
				currentlyfast = false
				StartGoFast = false
			end
		end

		if currentlyfast then
			drawTxt(0.66, 1.44, 1.0,1.0,0.4, _U('time') .. minute .. _U('time_minute') .. secondsRemaining , 255, 255, 255, 255)
		end

		if  GetEntityHealth(GetPlayerPed(-1)) <= 0 then
			SetEntityCoords( pedrevance , -4432.4321 , -5643.3969 , 999 , true , true , true , true )
			SetEntityCoords( pedrevance2 , -4432.4321 , -5643.3969 , 999 , true , true , true , true )
			DeleteVehicle(carrevange)

			for i=1, #missionped do
			TaskGoToCoordAnyMeans(missionped[i].id , -1409.0158691406, 546.56646728516, 122.92869567871, 5.0, 0, 0, 786603, 0xbf800000)
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		if currentlyfast then
			Citizen.Wait(1000)
			if(secondsRemaining > 0)then
				secondsRemaining = secondsRemaining - 1
			else
				FailGoFast()
				RemoveBlip(localisation)
				TriggerServerEvent('eden_gofast:failrun')
			end
		end
	end
end)

function deplacement()
	local coords = GetEntityCoords(GetPlayerPed(-1))
	TaskWanderInArea(FinalPed, coords.x +1, coords.y +1, coords.z -1, 15,15,15)
	ok = true
end

RegisterNetEvent('eden_gofast:ragepnj')
AddEventHandler('eden_gofast:ragepnj', function()
	TaskCombatPed(FinalPed, GetPlayerPed(-1), 0, 16)
end)

RegisterNetEvent('eden_gofast:recuperation')
AddEventHandler('eden_gofast:recuperation', function()

	if currentlyfast then
		ESX.ShowNotification(_U('finish'))
		TaskLeaveVehicle(GetPlayerPed(-1),GetVehiclePedIsIn(GetPlayerPed(-1)),1)
		Citizen.Wait(1500)
		PNJCar()
		currentlyfast = false
		first = true
	else
		first = true
		ESX.ShowNotification(_U('finish_time'))
		TaskLeaveVehicle(GetPlayerPed(-1),GetVehiclePedIsIn(GetPlayerPed(-1)),1)
		Citizen.Wait(1500)
		PNJCar()
	end

	SetTimeout( Config.Minutes * 60 * 1000, function()
		DeleteVehicle(plyCar)
		DeleteEntity(FinalPed)
		DeleteEntity(startped)
	end)
end)

function FailGoFast()

  local model = "BestiaGTS"
  local localped = GetPlayerPed(-1)
  local coords = GetEntityCoords(localped)
  local seat      = 0
  local Weapon    = 453432689
  local nmbrennemis = 0
  local GroupHandle = CreateGroup(0)
  local p = 6
	local RandomPed = Config.Peds[GetRandomIntInRange(1,  #Config.Peds)]

	RequestModel(model)
	while not HasModelLoaded(model) do
		Citizen.Wait(10)
	end

	RequestModel(RandomPed)
	while ( not HasModelLoaded(RandomPed) ) do
		Citizen.Wait(10)
	end

	while nmbrennemis ~= 2 do

	carrevange  =   CreateVehicle(model,  coords.x + p ,coords.y+5,coords.z ,175)
    SetVehicleOnGroundProperly(carrevange)
    pedrevance  =   CreatePedInsideVehicle(carrevange, 4, RandomPed, -1, true, 0)
    pedrevance2 =   CreatePedInsideVehicle(carrevange, 4, RandomPed, 0, true, 0)
    SetPedAsGroupLeader(pedrevance, GroupHandle)
    SetPedAsGroupMember(pedrevance, GroupHandle)
    SetPedNeverLeavesGroup(pedrevance, true)
    SetPedCanBeTargetted(pedrevance, false)
    SetPedAsGroupMember(pedrevance2, GroupHandle)
    SetPedNeverLeavesGroup(pedrevance2, true)
    SetPedCanBeTargetted(pedrevance2, false)
    SetGroupSeparationRange(GroupHandle,999999.9)
    SetPedFleeAttributes(pedrevance, 0, 0)
    SetPedFleeAttributes(pedrevance, 2, 0)
    SetPedFleeAttributes(pedrevance, 64, 0)
    SetPedFleeAttributes(pedrevance, 128, 0)
    SetPedFleeAttributes(pedrevance, 8, 0)
    SetPedFleeAttributes(pedrevance, 1, 0)
    SetPedFleeAttributes(pedrevance, 32, 0)
    SetPedDiesWhenInjured(pedrevance, false)
    SetPedDropsWeaponsWhenDead(pedrevance, false)
    GiveWeaponToPed(pedrevance, Weapon, 2800, false, true)
    SetCurrentPedWeapon(pedrevance, Weapon,true)
    SetPedDiesWhenInjured(pedrevance2, false)
    SetPedDropsWeaponsWhenDead(pedrevance2, false)
    GiveWeaponToPed(pedrevance2, Weapon, 2800, false, true)
    SetCurrentPedWeapon(pedrevance2, Weapon,true)
    TaskFollowToOffsetOfEntity(pedrevance, localped, coords.x ,coords.y, coords.z, 2, 500, 0, true )
    TaskVehicleDriveWander(pedrevance, carrevange, 220.0, 1074528293)
    TaskVehicleDriveWander(pedrevance, carrevange, 220.0, 2883621)
    TaskVehicleDriveWander(pedrevance, carrevange, 220.0, 5)
    TaskVehicleDriveWander(pedrevance, carrevange, 220.0, 786468)
    TaskVehicleDriveWander(pedrevance, carrevange, 220.0, 4194304)
    TaskVehicleDriveWander(pedrevance, carrevange, 220.0, 6)
	TaskCombatPed(pedrevance,GetPlayerPed(-1), 0, 16)
	Citizen.Wait(2500)

    	p = p + 3
		nmbrennemis = nmbrennemis + 1
		StartGoFast = false
		currentlyfast = false

	end

	SetTimeout( Config.Minutes * 60 * 1000, function()
		DeleteVehicle(plyCar)
		DeleteEntity(startped)
	end)
end

function headsUp(text)
	SetTextComponentFormat('STRING')
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function drawTxt(x,y ,width,height,scale, text, r,g,b,a, outline)
	SetTextFont(0)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	if(outline)then
		SetTextOutline()
	end
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x - width/2, y - height/2 + 0.005)
end


RegisterNetEvent('eden_gofast:StartNotify')
AddEventHandler('eden_gofast:StartNotify',function(inputText)

  SetNotificationTextEntry("STRING");
  AddTextComponentString(inputText);
  SetNotificationMessage("CHAR_BLOCKED", "CHAR_BLOCKED", true, 1, "~y~Gofast~s~", "Gofast Dévellopé // Endora");
  DrawNotification(false, true);
end)