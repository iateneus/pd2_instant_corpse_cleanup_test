dofile(ModPath .. "lua/settings.lua")
local ICC = InstantCorpseCleanup

Hooks:Add("LocalizationManagerPostInit", "ICC_Localization", function(loc)
    loc:load_localization_file(ICC.path .. "loc/english.json")
end)

Hooks:Add("MenuManagerInitialize", "ICC_Menu", function()
    for key in pairs(ICC.settings) do
        local setting = key
        MenuCallbackHandler["icc_" .. setting] = function(_, item)
            ICC.settings[setting] = item:value() == "on"
            ICC:Save()
            ICC:ApplyEnemySettings(managers.enemy)
            ICC:ApplyDecalSettings(managers.game_play_central)
        end
    end
    MenuHelper:LoadFromJsonFile(ICC.path .. "menu/options.json", ICC, ICC.settings)
end)
