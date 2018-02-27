local _G = getfenv()
local GuildSearch = _G.GuildSearch
local L = GuildSearch.Locales[_G.GetLocale()].Strings

local main_frame = CreateFrame('Frame', nil, UIParent)
GuildSearch.main_frame = main_frame


-- remove one row to make space
_G.GuildPlayerStatusFrame:ClearAllPoints()
_G.GuildPlayerStatusFrame:SetPoint('TOPLEFT', 0, -16)
_G.GuildStatusFrame:ClearAllPoints()
_G.GuildStatusFrame:SetPoint('TOPLEFT', 0, -16)

_G.GuildFrameButton1:ClearAllPoints()
_G.GuildFrameButton1:SetPoint('TOPLEFT', 15, -95, _G.GuildFrame)
_G.GuildFrameGuildStatusButton1:ClearAllPoints()
_G.GuildFrameGuildStatusButton1:SetPoint('TOPLEFT', 15, -95, _G.GuildFrame)

_G.GUILDMEMBERS_TO_DISPLAY = 12
_G.GuildFrameButton13:Hide()

-- resize scroll bar
_G.GuildListScrollFrame:SetHeight(_G.GuildListScrollFrame:GetHeight() - 16)
do
	local point, relativeTo, relativePoint, xOfs, yOfs = _G.GuildListScrollFrame:GetPoint()
	_G.GuildListScrollFrame:ClearAllPoints()
	_G.GuildListScrollFrame:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs - 16)
end

-- change background textures
GuildSearch.hooks.FriendsFrame_Update = _G.FriendsFrame_Update
_G.FriendsFrame_Update = function()
	GuildSearch.hooks.FriendsFrame_Update()
	
	if FriendsFrame.selectedTab == 3 then
		_G.FriendsFrameTopLeft:SetTexture([[Interface\AddOns\GuildSearch\textures\TopLeft]])
		_G.FriendsFrameTopRight:SetTexture([[Interface\AddOns\GuildSearch\textures\TopRight]])
	end
end

-- add input field
local editbox = CreateFrame('EditBox', nil, _G.GuildFrame, 'InputBoxTemplate')
main_frame.editbox = editbox
editbox:SetPoint('TOPRIGHT', -45, -66)
editbox:SetAutoFocus(false)
editbox:SetTextInsets(3, 3, 0, 0)
editbox:SetMaxLetters(32)
editbox:SetHeight(16)
editbox:SetWidth(200)
editbox:SetFontObject(GuildSearch.font.input)
editbox:SetText('')
editbox:EnableMouse(true)
editbox.r, editbox.g, editbox.b = editbox:GetTextColor()

editbox:SetScript('OnEscapePressed', function()
	this:ClearFocus()
end)
editbox:SetScript('OnEnterPressed', function()
	this:ClearFocus()
end)
editbox:SetScript('OnEditFocusGained', function()
	this.focus = true
	this:SetTextColor(1.0, 1.0, 1.0)
	this.placeholder:Hide()
end)
editbox:SetScript('OnEditFocusLost', function()
	this.focus = nil
	this:SetTextColor(this.r, this.g, this.b)
	if this:GetText() == '' then
		this.placeholder:Show()
	else
		this.placeholder:Hide()
	end
end)
editbox:SetScript('OnTextChanged', function()
	if this:GetText() == '' then
		if this.focus then
			this.placeholder:Hide()
		else
			this.placeholder:Show()
		end
	else
		this.placeholder:Hide()
	end
	
	GuildSearch:Search(this:GetText())
end)

local placeholder = editbox:CreateFontString()
editbox.placeholder = placeholder
placeholder:SetFontObject(GuildSearch.font.input)
placeholder:SetPoint('LEFT', 0, 0)
placeholder:SetText(L['Search'])