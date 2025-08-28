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

-- === ตั้งค่าโทนสี/สไตล์ต่อโหมด (แก้ไขได้) ===
-- โหมดนับตาม index ของ Cfg.voiceModes (1..#)
local VoiceModeStyles = {
    [1] = { r = 80,  g = 200, b = 255, label = "Whisper"    }, -- กระซิบ
    [2] = { r = 60,  g = 255, b = 120, label = "Normal"     }, -- ปกติ
    [3] = { r = 255, g = 180, b = 60,  label = "Shout"      }, -- ตะโกน
    [4] = { r = 200, g = 120, b = 255, label = "Dome"       }, -- Dome
    [5] = { r = 255, g = 70,  b = 70,  label = "Microphone" }, -- ไมค์
    [6] = { r = 255, g = 120, b = 40,  label = "Megaphone"  }, -- เมก้าโฟน
    [7] = { r = 255, g = 255, b = 255, label = "God"        }, -- Admin/GM
}

-- ป้องกันซ้อนเธรดวาดวง
local _voiceRingThread = nil
local _voiceRingThreadId = 0

-- แสดงวงรัศมีเสียง (พัลส์ 2 วินาที)
local function ShowVoiceRangeRing(rangeMeters, modeIndex)
    _voiceRingThreadId = _voiceRingThreadId + 1
    local myId = _voiceRingThreadId

    local style = VoiceModeStyles[modeIndex] or { r = 120, g = 200, b = 255, label = "Voice" }
    local durationMs = 2000
    local startAt = GetGameTimer()

    -- เธรดวาดวง
    Citizen.CreateThread(function()
        while GetGameTimer() - startAt < durationMs and myId == _voiceRingThreadId do
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)

            -- พัลส์ความทึบ + ขยาย/หดเล็กน้อย
            local now = GetGameTimer()
            local t = (now - startAt)
            local alpha = math.floor(90 + 65 * math.sin(t / 200.0))      -- 25Hz-ish pulse
            local scalePulse = 1.0 + 0.08 * math.sin(t / 300.0)          -- ขยาย/หด 8%

            -- วาดเป็นทรงกระบอกเตี้ย ๆ ที่พื้นให้เหมือน “วงรัศมี”
            -- ใช้ DrawMarker แบบ cylinder (สเกล X,Y = เส้นผ่านศูนย์กลาง)
            DrawMarker(
                1,                              -- MarkerTypeCylinder (ดูเป็นวง)
                coords.x, coords.y, coords.z - 1.0,
                0.0, 0.0, 0.0,                  -- direction
                0.0, 0.0, 0.0,                  -- rotation
                rangeMeters * 2.0 * scalePulse, -- scale X
                rangeMeters * 2.0 * scalePulse, -- scale Y
                0.35,                           -- scale Z (หนาเตี้ย)
                style.r, style.g, style.b, alpha,
                false, false, 2, false, nil, nil, false
            )

            -- วงชั้นนอกบาง ๆ ให้เด่นขึ้น (เหมือนขอบ)
            DrawMarker(
                1,
                coords.x, coords.y, coords.z - 1.01,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                rangeMeters * 2.0 * (scalePulse + 0.03),
                rangeMeters * 2.0 * (scalePulse + 0.03),
                0.02,
                style.r, style.g, style.b, math.min(alpha + 40, 180),
                false, false, 2, false, nil, nil, false
            )

            -- (ออปชั่น) แสดง 3D text ชื่อโหมดตรงกลาง
            -- ถ้าไม่อยากให้แสดงก็คอมเมนต์ทิ้งได้
            -- SetDrawOrigin(coords.x, coords.y, coords.z + 0.95, 0)
            -- SetTextFont(4); SetTextScale(0.30, 0.30); SetTextProportional(1)
            -- SetTextColour(style.r, style.g, style.b, 200); SetTextOutline()
            -- SetTextEntry("STRING"); AddTextComponentString(style.label or "Voice")
            -- DrawText(0.0, 0.0)
            -- ClearDrawOrigin()

            Citizen.Wait(0)
        end
    end)
end

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

		local range = Cfg.voiceModes[mode][1]
		setProximityState(Cfg.voiceModes[mode][1], false)
		TriggerEvent('pma-voice:setTalkingMode', mode)

		
		-- ⭐ แสดงวงรอบตัวเป็นเวลา ~2 วิ (พัลส์ + สีตามโหมด)
		ShowVoiceRangeRing(range, mode)
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
	RegisterKeyMapping('cycleproximity', 'Cycle Proximity', 'keyboard', GetConvar('voice_defaultCycle', 'Z'))
end
