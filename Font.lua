local _G = getfenv()
local GuildSearch = _G.GuildSearch

GuildSearch.font = {}

local font = CreateFont('GuildSearchInputFont')
do
	font:SetFontObject(GameFontNormal)
	local name, size, flags = font:GetFont()
	font:SetFont(name, 10)
	font:SetTextColor(0.5, 0.5, 0.5)
end

GuildSearch.font.input = font
