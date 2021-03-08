-- Shared addon data
local addonName, addonTable = ...
local L = addonTable.L
local color = addonTable.color
local dump = addonTable.dump
local dumpTable = addonTable.dumpTable
local dumpTooltip = addonTable.dumpTooltip
local tocVersionDeprecated = addonTable.tocVersionDeprecated

local AdiBags = LibStub("AceAddon-3.0"):GetAddon("AdiBags")
local Tooltip

local configuration = {
	debug = false,
	tooltipScanning = false, -- Tooltip scanning (This is a bad idea)
	cacheNoReCheck = false, -- Just a variable to avoid rescanning
}

local filterDatabase = {
	jukeboxGarrison = {
		items = {
			-- Stash of Dusty Music Rolls: Alliance
			122201, -- Music Roll: Stormwind
			122203, -- Music Roll: Ironforge
			122205, -- Music Roll: Night Song
			122206, -- Music Roll: Gnomeregan
			122208, -- Music Roll: Exodar
			122209, -- Music Roll: Curse of the Worgen

			-- Stash of Dusty Music Rolls: Horde
			122210, -- Music Roll: Orgrimmar
			122212, -- Music Roll: Undercity
			122213, -- Music Roll: Thunder Bluff
			122216, -- Music Roll: The Zandalari
			122217, -- Music Roll: Silvermoon
			122218, -- Music Roll: Rescue the Warchief

			-- Stash of Dusty Music Rolls: Alliance and Horde
			122219, -- Music Roll: Way of the Monk

			-- Kalimdor (from North to South)
			122198, -- Music Roll: The Shattering
			122214, -- Music Roll: Mulgore Plains
			122224, -- Music Roll: Mountains
			122226, -- Music Roll: Magic
			122238, -- Music Roll: Darkmoon Carousel
			122239, -- Music Roll: Shalandis Isle

			-- Eastern Kingdom
			122195, -- Music Roll: Legends of Azeroth
			122215, -- Music Roll: Zul'Gurub Voodoo
			122222, -- Music Roll: Angelic
			122223, -- Music Roll: Ghost
			122231, -- Music Roll: Karazhan Opera House
			122233, -- Music Roll: Lament of the Highborne
			122234, -- Music Roll: Faerie Dragon

			-- Outland
			122196, -- Music Roll: The Burning Legion
			122228, -- Music Roll: The Black Temple
			-- Northend
			122197, -- Music Roll: Wrath of the Lich King
			122229, -- Music Roll: Invincible
			122236, -- Music Roll: Totems of the Grizzlemaw
			122237, -- Music Roll: Mountains of Thunder

			-- Pandaria
			122199, -- Music Roll: Heart of Pandaria
			122211, -- Music Roll: War March
			122221, -- Music Roll: Song of Liu Lang

			-- Draenor
			122200, -- Music Roll: A Siege of Worlds
		},
	},
	jukeboxJunkyard = {
		items = {
			-- Required
			168062, -- Blueprint: Rustbolt Gramophone

			-- Vinyl
			169688, -- Vinyl: Gnomeregan Forever
			169689, -- Vinyl: Mimiron's Brainstorm
			169690, -- Vinyl: Battle of Gnomeregan
			169691, -- Vinyl: Depths of Ulduar
			169692, -- Vinyl: Triumph of Gnomeregan
		},
	},
}

local options = {
	jukeboxGarrison = {
		name = L["Garrison"],
		desc = L["Enable"] .. " " .. L["Jukebox"] .. ": " .. L["Garrison"],
		type = "toggle",
		-- width = 'double',
		order = 20,
	},
	jukeboxJunkyard = {
		name = L["Junkyard"],
		desc = L["Enable"] .. " " .. L["Jukebox"] .. ": " .. L["Junkyard"],
		type = "toggle",
		-- width = 'double',
		order = 20,
	},
}

local cache = {
	items = {}
}

local function initialize()
	-- Convert filterDatabase (item|class|tooltip) [id => true]
	table.foreach(options, function(optionKey, optionData)
		if (filterDatabase[optionKey] ~= nil) then
			for filterKey, _ in pairs(filterDatabase[optionKey]) do
				if (filterDatabase[optionKey][filterKey] ~= nil) then
					local tmpTable = {}
					for _, id in ipairs(filterDatabase[optionKey][filterKey]) do
						tmpTable[id] = true
					end
					filterDatabase[optionKey][filterKey] = tmpTable
				end
			end
		end
	end)
end
initialize()

local function Tooltip_Init()
	local tip = CreateFrame("GameTooltip")
	local leftside = {};
	for i = 1, 9 do
		local Left, Right = tip:CreateFontString(), tip:CreateFontString()
		Left:SetFontObject(GameFontNormal)
		Right:SetFontObject(GameFontNormal)
		tip:AddFontStrings(Left, Right)
		leftside[i] = Left
	end
	tip.leftside = leftside
	return tip
end

local AdiBagsFilter = AdiBags:RegisterFilter("Jukebox", 98, "ABEvent-1.0")
AdiBagsFilter.uiName = L["Jukebox"]
AdiBagsFilter.uiDesc = L["Jukebox"] .. " " .. L["Filter"]

function AdiBagsFilter:OnInitialize()
	local profileEnabled = {}
	table.foreach(options, function(optionKey, optionData)
		if (optionData.type == "toggle") then
			profileEnabled[optionKey] = true
		elseif (optionData.type == "multiselect") then
			profileEnabled[optionKey] = {true}
		end
	end)

	self.db = AdiBags.db:RegisterNamespace("Jukebox", {
		profile = profileEnabled,
	})
end

function AdiBagsFilter:Update()
	self:SendMessage("AdiBags_FiltersChanged")
end

function AdiBagsFilter:OnEnable()
	AdiBags:UpdateFilters()
end

function AdiBagsFilter:OnDisable()
	AdiBags:UpdateFilters()
end

local function unescape(String)
	local Result = tostring(String)
	Result = gsub(Result, "|c........", "") -- Remove color start.
	Result = gsub(Result, "|r", "") -- Remove color end.
	Result = gsub(Result, "|H.-|h(.-)|h", "%1") -- Remove links.
	Result = gsub(Result, "|T.-|t", "") -- Remove textures.
	Result = gsub(Result, "{.-}", "") -- Remove raid target icons.
	return Result
end

local function findCategoryByTooltip(instanceFilter, slotData)
	if (cache.items[slotData.itemId] ~= nil and cache.items[slotData.itemId] == configuration.cacheNoReCheck) then
		return nil -- Previously not found
	end

	if (cache.items[slotData.itemId] ~= nil) then
		return (configuration.debug and color.red or "") .. cache.items[slotData.itemId] .. (configuration.debug and color.reset or "")
	end

	if (configuration.tooltipScanning) then
		-- Find filter by tooltip
		-- Note: This is a bad idea, but it works
		Tooltip = Tooltip or Tooltip_Init()
		Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
		Tooltip:ClearLines()

		if slotData.bag == BANK_CONTAINER then
			Tooltip:SetInventoryItem("player", BankButtonIDToInvSlotID(slotData.slot, nil))
		else
			Tooltip:SetBagItem(slotData.bag, slotData.slot)
		end

		local tooltipText = {
			unescape(Tooltip.leftside[1]:GetText()),
			unescape(Tooltip.leftside[2]:GetText()),
			unescape(Tooltip.leftside[3]:GetText()),
			unescape(Tooltip.leftside[4]:GetText()),
			unescape(Tooltip.leftside[5]:GetText()),
			unescape(Tooltip.leftside[6]:GetText()),
			unescape(Tooltip.leftside[7]:GetText()),
			unescape(Tooltip.leftside[8]:GetText()),
			unescape(Tooltip.leftside[9]:GetText()),
		}

		-- Find filter category by tooltip
		local categoryByTooltip = table.foreach(options, function(optionKey, optionData)
			if (instanceFilter.db.profile[optionKey] and optionData.type == "toggle") then

				-- Find filter category by explizit tooltip
				for i = 1,9 do
					local tooltipKey = "tooltip" .. i
					if (filterDatabase[optionKey][tooltipKey] ~= nil and filterDatabase[optionKey][tooltipKey][tooltipText[i]]) then
						return optionData.name
					end
				end

				-- Find filter category by all tooltips
				for i = 1,9 do
					if (filterDatabase[optionKey].tooltip ~= nil and filterDatabase[optionKey].tooltip[tooltipText[i]]) then
						return optionData.name
					end
				end

			end
		end)
		Tooltip:Hide()

		if (categoryByTooltip ~= nil) then
			cache.items[slotData.itemId] = categoryByTooltip
			return (configuration.debug and color.red or "") .. categoryByTooltip .. (configuration.debug and color.reset or "")
		end
	end

	cache.items[slotData.itemId] = configuration.cacheNoReCheck
	return nil
end

function AdiBagsFilter:Filter(slotData)
	-- Find filter category by itemId
	local findCategoryByItemId = table.foreach(options, function(optionKey, optionData)
		if (self.db.profile[optionKey] and optionData.type == "toggle" and filterDatabase[optionKey].items ~= nil and filterDatabase[optionKey].items[slotData.itemId]) then
			return optionData.name
		end
	end)
	if (findCategoryByItemId ~= nil) then
		return (configuration.debug and color.red or "") .. findCategoryByItemId .. (configuration.debug and color.reset or "")
	end

	-- Find filter by class or subclass
	local findCategoryByClass = table.foreach(options, function(optionKey, optionData)
		if (self.db.profile[optionKey] and optionData.type == "toggle") then
			if ((filterDatabase[optionKey].class ~= nil and filterDatabase[optionKey].class[slotData.class]) or (filterDatabase[optionKey].subclass ~= nil and filterDatabase[optionKey].subclass[slotData.subclass])) then
				return optionData.name
			end
		end
	end)
	if (findCategoryByClass ~= nil) then
		return (configuration.debug and color.red or "") .. findCategoryByClass .. (configuration.debug and color.reset or "")
	end

	-- Find filter by tooltip
	local categoryByTooltip = findCategoryByTooltip(self, slotData)
	if (categoryByTooltip ~= nil) then
		return categoryByTooltip
	end
end

function AdiBagsFilter:GetOptions()
	return options, AdiBags:GetOptionHandler(self, false, function()
		return self:Update()
	end)
end
