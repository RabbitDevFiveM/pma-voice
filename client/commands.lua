ESX = nil

Citizen.CreateThread(function ()
    while ESX == nil do
     TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
     Citizen.Wait(0)
    end
   
    while ESX.GetPlayerData() == nil do
     Citizen.Wait(10)
    end

end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

local wasProximityDisabledFromOverride = false
disableProximityCycle = false
RegisterCommand('setvoiceintent', function(source, args)
	if GetConvarInt('voice_allowSetIntent', 1) == 1 then
		local intent = args[1]
		if intent == 'speech' then
			MumbleSetAudioInputIntent(GetHashKey('speech'))
		elseif intent == 'music' then
			MumbleSetAudioInputIntent(GetHashKey('music'))
		end
		LocalPlayer.state:set('voiceIntent', intent, true)
	end
end)

-- TODO: Better implementation of this?
RegisterCommand('vol', function(_, args)
	if not args[1] then return end
	setVolume(tonumber(args[1]))
end)

playerMuted = false
IS_DEAD = false
adamantineZone = false

Citizen.CreateThread(function()
    while(true) do
        IS_DEAD = IsPedDeadOrDying(PlayerPedId())
        Citizen.Wait(500)
    end
end)

AddEventHandler("playerSpawned", function()
	IS_DEAD = false
	Wait(1000)
	if playerMuted and not adamantineZone then
		Mute()
	end
end)

AddEventHandler('esx:onPlayerDeath', function()
	if not playerMuted then
		Mute()
	end
end)

AddEventHandler('adamantine:enterzone', function(status)
	adamantineZone = status
end)

RegisterNetEvent('mumble:SetMute')
AddEventHandler('mumble:SetMute', function(status)
	if status then
		if not playerMuted then
			Mute()
		end
	else
		if playerMuted then
			Mute()
		end
	end
end)

function Mute()
	playerMuted = not playerMuted
	if playerMuted then
		LocalPlayer.state:set('proximity', {
			index = 0,
			distance =  0.1,
			mode = 'Muted',
		}, true)
		MumbleSetAudioInputDistance(0.1)
		SendNUIMessage({
			voiceMode = 'Muted'
		})
		exports["familie_widget"]:SetWidgetData('voiceMode', 'Muted')
	else
		local voiceMode = 2
		local voiceModeData = Cfg.voiceModes[voiceMode]
		MumbleSetAudioInputDistance(voiceModeData[1] + 0.0)
		mode = voiceMode
		LocalPlayer.state:set('proximity', {
			index = voiceMode,
			distance =  voiceModeData[1],
			mode = voiceModeData[2],
		}, true)
		-- make sure we update the UI to the latest voice mode
		SendNUIMessage({
			voiceMode = voiceMode - 1
		})

		exports["familie_widget"]:SetWidgetData('voiceMode', voiceModeData[2])
		
		setProximityState(Cfg.voiceModes[mode][1], false)
		TriggerEvent('pma-voice:setTalkingMode', voiceMode)
	end
end

function changeMode()
	if not IS_DEAD then
		-- Proximity is either disabled, or manually overwritten.
		if GetConvarInt('voice_enableProximityCycle', 1) ~= 1 or disableProximityCycle then return end
		if playerMuted then return end
		local newMode = mode + 1

		-- If we're within the range of our voice modes, allow the increase, otherwise reset to the first state
		if newMode <= #Cfg.voiceModes then
			mode = newMode
		else
			mode = 1
		end

		if Cfg.Dome and newMode == 4 then
			local playerPed = PlayerPedId()
			local coords = GetEntityCoords(playerPed)
			for k, v in pairs(Cfg.Dome) do
			  local dist = #(coords - v.coords)
			  if dist > v.radius then
				newMode = 5
			  end
			end
		end

		if newMode == 5 and (not ESX.Game.CheckHasItem('microphone', 1) and not ESX.Game.CheckHasItem('god', 1)) then
			mode = 1
		end

		if newMode == 6 and (not ESX.Game.CheckHasItem('megaphone', 1) and not ESX.Game.CheckHasItem('god', 1)) then
			mode = 1
		end
	
		if newMode == 7 and not ESX.Game.CheckHasItem('god', 1) then
			mode = 1
		end

		setProximityState(Cfg.voiceModes[mode][1], false)
		TriggerEvent('pma-voice:setTalkingMode', mode)
	end
end

exports('setAllowProximityCycleState', function(state)
	type_check({state, "boolean"})
	disableProximityCycle = state
end)

function setProximityState(proximityRange, isCustom)
	local voiceModeData = Cfg.voiceModes[mode]
	MumbleSetTalkerProximity(proximityRange + 0.0)
	LocalPlayer.state:set('proximity', {
		index = mode,
		distance = proximityRange,
		mode = isCustom and "Custom" or voiceModeData[2],
	}, true)
	sendUIMessage({
		-- JS expects this value to be - 1, "custom" voice is on the last index
		voiceMode = isCustom and #Cfg.voiceModes or mode - 1
	})

	exports["familie_widget"]:SetWidgetData('voiceMode', isCustom and "Custom" or voiceModeData[2])
end

exports("overrideProximityRange", function(range, disableCycle)
	type_check({range, "number"})
	setProximityState(range, true)
	if disableCycle then
		disableProximityCycle = true
		wasProximityDisabledFromOverride = true
	end
end)

exports("clearProximityOverride", function()
	local voiceModeData = Cfg.voiceModes[mode]
	setProximityState(voiceModeData[1], false)
	if wasProximityDisabledFromOverride then
		disableProximityCycle = false
	end
end)

RegisterCommand('cycleproximity', function()
	changeMode()
end, false)
if gameVersion == 'fivem' then
	RegisterKeyMapping('cycleproximity', 'Cycle Proximity', 'keyboard', GetConvar('voice_defaultCycle', 'F11'))
end
