Cfg = {}
-- possibly GetConvar('voice_modes', '0.5;2.0;5.0')
-- possibly GetConvar('voice_modeNames', 'Whisper;Normal;Shouting') and seperate them on runtime?

Cfg["Debug"] = true

if GetConvar('voice_useNativeAudio', 'false') == 'true' then
	-- native audio distance seems to be larger then regular gta units
	Cfg.voiceModes = {
		{2.5, "Whisper"}, -- Whisper speech distance in gta distance units
		{7.0, "Normal"}, -- Normal speech distance in gta distance units
		{15.0, "Shouting"}, -- Shout speech distance in gta distance units
		{50.0, "Activity"}, -- Shout speech distance in gta distance units
        {500.0, "Megaphone"} --
	}
else
	Cfg.voiceModes = {
		{2.0, "กระซิบ"}, -- Whisper speech distance in gta distance units
		{8.0, "ปกติ"}, -- Normal speech distance in gta distance units
		{20.0, "ตะโกน"}, -- Shout speech distance in gta distance units
		{50.0, "กิจกรรม"}, -- Shout speech distance in gta distance units
        {500.0, "พระเจ้า"} -- hout speech distance in gta distance units
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