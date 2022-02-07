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

RegisterCommand('setvoiceintent', function(source, args)
	if GetConvarInt('voice_allowSetIntent', 1) == 1 then
		local intent = args[1]
		if intent == 'speech' then
			MumbleSetAudioInputIntent(GetHashKey('speech'))
		elseif intent == 'music' then
			MumbleSetAudioInputIntent(GetHashKey('music'))
		end
	end
end)

-- TODO: Better implementation of this?
RegisterCommand('vol', function(_, args)
	if not args[1] then return end
	setVolume(args[1])
end)

playerMuted = false
IS_DEAD = false

Citizen.CreateThread(function()
    while(true) do
        IS_DEAD = IsPedDeadOrDying(PlayerPedId())
        Citizen.Wait(500)
    end
end)

AddEventHandler("playerSpawned", function()
	IS_DEAD = false
	Wait(1000)
	if playerMuted then
		Mute()
	end
end)

AddEventHandler('esx:onPlayerDeath', function()
	if not playerMuted then
		Mute()
	end
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
		TriggerEvent('pma-voice:setTalkingMode', voiceMode)
	end
end

function changeMode()
	if not IS_DEAD then
		if GetConvarInt('voice_enableProximity', 1) ~= 1 then return end
		if playerMuted then return end
		
		local voiceMode = mode
		local newMode = voiceMode + 1
		
		voiceMode = (newMode <= #Cfg.voiceModes and newMode) or 1
	
		if newMode == 4 and (not ESX.Game.CheckHasItem('megaphone', 1) and not ESX.Game.CheckHasItem('god', 1)) then
			voiceMode = 1
		end
	
		if newMode == 5 and not ESX.Game.CheckHasItem('god', 1) then
			voiceMode = 1
		end
	
		local voiceModeData = Cfg.voiceModes[voiceMode]
		MumbleSetTalkerProximity(voiceModeData[1] + 0.0)
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
		TriggerEvent('pma-voice:setTalkingMode', voiceMode)
	end
end

RegisterCommand('cycleproximity', function()
	changeMode()
end, false)
if gameVersion == 'fivem' then
	RegisterKeyMapping('cycleproximity', 'Cycle Proximity', 'keyboard', GetConvar('voice_defaultCycle', 'F11'))
end