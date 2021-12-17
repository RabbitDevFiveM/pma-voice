Cfg = {}
-- possibly GetConvar('voice_modes', '0.5;2.0;5.0')
-- possibly GetConvar('voice_modeNames', 'Whisper;Normal;Shouting') and seperate them on runtime?

Cfg["Debug"] = false

Cfg.micClicks = true -- Are clicks enabled or not
Cfg.micClickOn = false -- Is click sound on active
Cfg.micClickOff = false -- Is click sound off active
if GetConvar('voice_useNativeAudio', 'false') == 'true' then
	-- native audio distance seems to be larger then regular gta units
	Cfg.defaultVoice = 2 -- ค่าเสียงเริ่มต้น
	Cfg.voiceModes = {
		{1.5, "กระซิบ"}, -- Whisper speech distance in gta distance units
		{8.0, "ปกติ"}, -- Normal speech distance in gta distance units
		{22.0, "ตะโกน"}, -- Shout speech distance in gta distance units
		{60.0, "กิจกรรม"}, -- Activity speech distance in gta distance units
        {500.0, "พระเจ้า"} -- Megaphone speech distance in gta distance units
	}
else
	Cfg.defaultVoice = 2 -- ค่าเสียงเริ่มต้น
	Cfg.voiceModes = {
		{1.8, "กระซิบ"}, -- Whisper speech distance in gta distance units
		{7.0, "ปกติ"}, -- Normal speech distance in gta distance units
		{20.0, "ตะโกน"}, -- Shout speech distance in gta distance units
		{60.0, "กิจกรรม"}, -- Activity speech distance in gta distance units
        {500.0, "พระเจ้า"} -- Megaphone speech distance in gta distance units
	}
end

logger = {
	['log'] = function(message, ...)
		print((message):format(...))
	end,
	['info'] = function(message, ...)
		if GetConvarInt('voice_debugMode', 0) >= 1 then
			print(('[info] ' .. message):format(...))
		end	
	end,
	['warn'] = function(message, ...)
		print(('[^1WARNING^7] ' .. message):format(...))
	end,
	['verbose'] = function(message, ...)
		if GetConvarInt('voice_debugMode', 0) >= 4 then
			print(('[verbose] ' .. message):format(...))
		end	
	end,
}


function tPrint(tbl, indent)
	indent = indent or 0
	for k, v in pairs(tbl) do
		local tblType = type(v)
		formatting = string.rep("  ", indent) .. k .. ": "
		if tblType == "table" then
			print(formatting)
			tPrint(v, indent + 1)
		elseif tblType == 'boolean' then
			print(formatting .. tostring(v))
		elseif tblType == "function" then
			print(formatting .. tostring(v))
		else
			print(formatting .. v)
		end
	end
end