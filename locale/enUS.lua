local _G = getfenv()
local GuildSearch = _G.GuildSearch
local enUS = GuildSearch.Locale:new()
local L = enUS.Strings

GuildSearch.Locales = GuildSearch.Locales or GuildSearch.LocaleTable:new(enUS)
GuildSearch.Locales["enUS"] = enUS

-- not much here really
L["Search"] = "Search"
