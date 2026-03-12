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
-- === helpers ===
local function _findGroundZ(pos)
    local probes = { 50.0, 40.0, 30.0, 20.0, 10.0, 5.0, 3.0, 2.0, 1.0, 0.0 }
    for _, h in ipairs(probes) do
        local ok, gz = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z + h, false)
        if ok then return gz end
    end
    return nil
end

local function _easeOutCubic(x)
    -- clamp 0..1
    if x < 0.0 then x = 0.0 elseif x > 1.0 then x = 1.0 end
    return 1.0 - ((1.0 - x) ^ 3)
end

-- === main ===
local function ShowVoiceRangeRing(rangeMeters, modeIndex)
    _voiceRingThreadId = _voiceRingThreadId + 1
    local myId = _voiceRingThreadId

    local style = VoiceModeStyles[modeIndex] or { r = 120, g = 200, b = 255, label = "Voice" }
    local durationMs = 2000
    local startAt = GetGameTimer()

    Citizen.CreateThread(function()
        while GetGameTimer() - startAt < durationMs and myId == _voiceRingThreadId do
            local ped   = PlayerPedId()
            local pos   = GetEntityCoords(ped)

            -- 1) baseZ: ระดับพื้นจริง (ถ้าไม่เจอ ใช้ pos.z - 1.0)
            local gz    = _findGroundZ(pos)
            local baseZ = (gz and (gz + 0.05)) or (pos.z - 1.0)

            -- 2) ยกวงเมื่ออยู่ในรถ (adaptive ตามความสูงใต้ท้องรถ)
            local drawZ = baseZ
            if IsPedInAnyVehicle(ped, false) then
                local veh = GetVehiclePedIsIn(ped, false)
                if veh ~= 0 then
                    local clearance = GetEntityHeightAboveGround(veh) or 0.0
                    local margin    = 0.25
                    local maxLift   = 1.6
                    local targetLift = math.min(maxLift, clearance + margin)

                    -- easing 300ms แรก ให้นุ่ม
                    local elapsed   = GetGameTimer() - startAt
                    local ease      = _easeOutCubic(elapsed / 300.0)
                    drawZ = baseZ + (targetLift * ease)

                    -- กรณีหา ground ไม่เจอเลย (interior แปลก ๆ): ยกคงที่พอประมาณ
                    if not gz then
                        drawZ = (pos.z - 0.4) + (0.6 * ease)
                    end
                end
            end

            -- 3) เอฟเฟกต์พัลส์ (ทึบ+สเกล)
            local t        = (GetGameTimer() - startAt)
            local alpha    = math.floor(90 + 65 * math.sin(t / 200.0))
            local scaleMul = 1.0 + 0.08 * math.sin(t / 300.0)

            -- 4) วาดวงหลัก (ทรงกระบอกเตี้ย ๆ)
            DrawMarker(
                1,
                pos.x, pos.y, drawZ,
                0.0, 0.0, 0.0,            -- dir
                0.0, 0.0, 0.0,            -- rot
                rangeMeters * 2.0 * scaleMul,
                rangeMeters * 2.0 * scaleMul,
                0.35,
                style.r, style.g, style.b, alpha,
                false, true, 2, false, nil, nil, false
            )

            -- 5) วาดขอบวง (บางกว่า/ทึบขึ้นนิดหน่อย)
            DrawMarker(
                1,
                pos.x, pos.y, drawZ - 0.01,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                rangeMeters * 2.0 * (scaleMul + 0.03),
                rangeMeters * 2.0 * (scaleMul + 0.03),
                0.02,
                style.r, style.g, style.b, math.min(alpha + 40, 180),
                false, true, 2, false, nil, nil, false
            )

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
		if playerMuted and not adamantineZone then
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
		pcall(function ()
			exports["familie_hud"]:SetWidgetData('voiceMode', 'Muted')
    	end)
		pcall(function ()
			exports["f_unity_hud"]:SetWidgetData('voiceMode', 'Muted')
    	end)
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
		pcall(function ()
			exports["familie_hud"]:SetWidgetData('voiceMode', voiceModeData[2])
    	end)
		pcall(function ()
			exports["f_unity_hud"]:SetWidgetData('voiceMode', voiceModeData[2])
    	end)
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
	pcall(function ()
		exports["familie_hud"]:SetWidgetData('voiceMode', isCustom and "Custom" or voiceModeData[2])
	end)
	pcall(function ()
		exports["f_unity_hud"]:SetWidgetData('voiceMode', isCustom and "Custom" or voiceModeData[2])
	end)
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
