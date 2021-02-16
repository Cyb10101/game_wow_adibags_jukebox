local addonName, addonTable = ...

local L = setmetatable({}, {
	__index = function(self, key)
		if key then
			rawset(self, key, tostring(key))
		end
		return tostring(key)
	end,
})
addonTable.L = L

local locale = GetLocale()

-- Default: en_GB
L["Jukebox"] = true
L["Garrison"] = true
L["Junkyard"] = true

if locale == "deDE" then
	L["Jukebox"] = "Musikbox"
	L["Garrison"] = "Garnison"
	L["Junkyard"] = "Schrottplatz"
elseif locale == "enUS" then
	-- L["Jukebox"] = "Missing translation"
	-- L["Garrison"] = "Missing translation"
	-- L["Junkyard"] = "Missing translation"
elseif locale == "esES" then
	-- L["Jukebox"] = "Missing translation"
	-- L["Garrison"] = "Missing translation"
	-- L["Junkyard"] = "Missing translation"
elseif locale == "esMX" then
	-- L["Jukebox"] = "Missing translation"
	-- L["Garrison"] = "Missing translation"
	-- L["Junkyard"] = "Missing translation"
elseif locale == "frFR" then
	-- L["Jukebox"] = "Missing translation"
	-- L["Garrison"] = "Missing translation"
	-- L["Junkyard"] = "Missing translation"
elseif locale == "itIT" then
	-- L["Jukebox"] = "Missing translation"
	-- L["Garrison"] = "Missing translation"
	-- L["Junkyard"] = "Missing translation"
elseif locale == "koKR" then
	-- L["Jukebox"] = "Missing translation"
	-- L["Garrison"] = "Missing translation"
	-- L["Junkyard"] = "Missing translation"
elseif locale == "ptBR" then
	-- L["Jukebox"] = "Missing translation"
	-- L["Garrison"] = "Missing translation"
	-- L["Junkyard"] = "Missing translation"
elseif locale == "ruRU" then
	-- L["Jukebox"] = "Missing translation"
	-- L["Garrison"] = "Missing translation"
	-- L["Junkyard"] = "Missing translation"
elseif locale == "zhCN" then
	-- L["Jukebox"] = "Missing translation"
	-- L["Garrison"] = "Missing translation"
	-- L["Junkyard"] = "Missing translation"
elseif locale == "zhTW" then
	-- L["Jukebox"] = "Missing translation"
	-- L["Garrison"] = "Missing translation"
	-- L["Junkyard"] = "Missing translation"
end

-- Localize true values with key name
for key, value in pairs(L) do
	if value == true then
		L[key] = key
	end
end
