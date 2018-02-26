local _G = getfenv()
local GuildSearch = _G.GuildSearch
local debug_level = 0 -- 0 release, 1 some messages, 3 all messages
local addon = GuildSearch.Event
local L = GuildSearch.Locales[_G.GetLocale()].Strings

GuildSearch.found = {}

local gmatch = string.gfind

setmetatable(GuildSearch, {
	__index = addon
});

addon:RegisterEvent('ADDON_LOADED')
addon:RegisterEvent('PLAYER_LOGIN')

function GuildSearch:print(message, level, headless)
	if not message then return end
	if level then
		if level <= debug_level then
			if headless then
				DEFAULT_CHAT_FRAME:AddMessage(message, 0.53, 0.69, 0.19)
			else
				DEFAULT_CHAT_FRAME:AddMessage('[GuildSearch]: ' .. message, 0.53, 0.69, 0.19)
			end
		end
	else
		if headless then
			DEFAULT_CHAT_FRAME:AddMessage(message)
		else
			DEFAULT_CHAT_FRAME:AddMessage('[GuildSearch]: ' .. message)
		end
	end
end

function addon:ADDON_LOADED()
	if arg1 ~= 'GuildSearch' then
		return
	end
end

function addon:PLAYER_LOGIN()
	GuildSearch.version = GetAddOnMetadata('GuildSearch', 'Version')
end

function GuildSearch:BuildList(searchText)
	self.found = {}
	
	local numGuildMembers = GetNumGuildMembers()
	local name, rank, rankIndex, level, class, zone, note, officernote, online
	local match
	local matcher = self:FuzzyMatcher(searchText)
	local rating
	
	for i = 1, numGuildMembers, 1 do
		rating = 0
		match = nil
		name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(i)
		
		local nameRating = name and matcher(name)
		local noteRating = note and matcher(note)
		local officerNoteRating = officerNoteRating and matcher(officerNoteRating)
		
		rating = nameRating and nameRating * 2
		
		if noteRating then
			rating = rating and max(rating, noteRating) or noteRating
		end
		if officerNoteRating then
			rating = rating and max(rating, officerNoteRating) or officerNoteRating
		end

		if rating and rating > 1 then
			tinsert(self.found, {i, rating, name, rank, rankIndex, level, class, zone, note, officernote, online})
		end
		-- sort by rating, name
		sort(self.found, function(a, b)
			if a[2] == b[2] then
				return a[3] > b[3]
			else
				return a[2] > b[2]
			end
		end)
	end
end

function GuildSearch:UpdateListing()
	FauxScrollFrame_Update(_G.GuildListScrollFrame, getn(self.found), GUILDMEMBERS_TO_DISPLAY, FRIENDS_FRAME_GUILD_HEIGHT)
	
	local button, button_name, button_zone, button_level, button_class
	local index, rating, name, rank, rankIndex, level, class, zone, note, officernote, online
	local guildOffset = FauxScrollFrame_GetOffset(GuildListScrollFrame)
	local guildIndex
	
	if getn(self.found) > 0 then
		for i=1, GUILDMEMBERS_TO_DISPLAY, 1 do
			button = _G[format('GuildFrameButton%d', i)]
			button_name = _G[format('GuildFrameButton%dName', i)]
			button_zone = _G[format('GuildFrameButton%dZone', i)]
			button_level = _G[format('GuildFrameButton%dLevel', i)]
			button_class = _G[format('GuildFrameButton%dClass', i)]
			
			if self.found[i] then
				index, rating, name, rank, rankIndex, level, class, zone, note, officernote, online = unpack(self.found[i])
				
				button_name:SetText(name)
				button_zone:SetText(zone)
				button_level:SetText(level)
				button_class:SetText(class)

				button.guildIndex = index or 0
				
				if ( not online ) then
					button_name:SetTextColor(0.5, 0.5, 0.5)
					button_zone:SetTextColor(0.5, 0.5, 0.5)
					button_level:SetTextColor(0.5, 0.5, 0.5)
					button_class:SetTextColor(0.5, 0.5, 0.5)
				else
					button_name:SetTextColor(1.0, 0.82, 0.0)
					button_zone:SetTextColor(1.0, 1.0, 1.0)
					button_level:SetTextColor(1.0, 1.0, 1.0)
					button_class:SetTextColor(1.0, 1.0, 1.0)
				end
				
				if GetGuildRosterSelection() == button.guildIndex then
					button:LockHighlight()
				else
					button:UnlockHighlight()
				end
				
				button:Show()
			else
				button:Hide()
			end
		end
	else
		for i=1, GUILDMEMBERS_TO_DISPLAY, 1 do
			button = _G[format('GuildFrameButton%d', i)]
			button:Hide()
		end
	end
end

function GuildSearch:Search(input)
	if input ~= '' then
		self:BuildList(strupper(input))
		self:UpdateListing()
	else
		_G.GuildStatus_Update()
	end
end

-- borrowed from crafty addon, thanks to shirsig
function GuildSearch:FuzzyMatcher(input)
	local uppercaseInput = strupper(input)
	local pattern = '(.*)'
	for i=1,strlen(uppercaseInput) do
		if strfind(strsub(uppercaseInput, i, i), '%w') or strfind(strsub(uppercaseInput, i, i), '%s') then
			pattern = pattern .. strsub(uppercaseInput, i, i) .. '(.-)'
 		end
	end
	return function(candidate)
		local match = { strfind(strupper(candidate), pattern) }
		if match[1] then
			local rating = 0
			for i=4,getn(match)-1 do
				if strlen(match[i]) == 0 then
					rating = rating + 1
				end
 			end
			return rating
 		end
	end
end

-- ignore updates if search is active
GuildSearch.hooks.GuildStatus_Update = _G.GuildStatus_Update
_G.GuildStatus_Update = function()
	GuildSearch.hooks.GuildStatus_Update()
	
	if GuildSearch.main_frame.editbox:GetText() ~= '' then
		GuildSearch:UpdateListing()
	end
end