local _G = getfenv();
local GuildSearch = _G.GuildSearch;

local LocaleTable = {};

function LocaleTable:new(defaultLocale)
    local localeTable = {
        DEFAULT = defaultLocale,
    };

    setmetatable(localeTable, {
        __index = function (self, key)
            return self.DEFAULT;
        end,
    });

    return localeTable;
end

GuildSearch.LocaleTable = LocaleTable;