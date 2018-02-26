local _G = getfenv()
local GuildSearch = _G.GuildSearch

GuildSearch.hooks = {}

local Event = CreateFrame('Frame')

Event:SetScript('OnEvent', function()
	this[event](this)
end)

GuildSearch.Event = Event
