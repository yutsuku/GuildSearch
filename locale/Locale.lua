local _G = getfenv();
local GuildSearch = _G.GuildSearch;

local Locale = {};

function Locale:new()
    local locale = {
        Strings = {},
    };

    setmetatable(locale.Strings, {
        __index = function (self, str)
            return str;
        end,
    });

    return locale;
end

GuildSearch.Locale = Locale;