if _G.InstantCorpseCleanup then
    return
end

local ICC = { path = ModPath, settings = {
    remove_corpses = true,
    remove_shields = true,
    remove_props = true,
    remove_decals = true,
    remove_blood = true
} }
_G.InstantCorpseCleanup = ICC
ICC.save_path = SavePath .. "instant_corpse_cleanup.json"

local input = io.open(ICC.save_path, "r")
if input then
    local contents = input:read("*all")
    input:close()
    local ok, saved = pcall(json.decode, contents)
    if ok and type(saved) == "table" then
        -- Older versions used one setting for blood, bullets and explosions.
        if type(saved.remove_blood) ~= "boolean" and type(saved.remove_decals) == "boolean" then
            ICC.settings.remove_blood = saved.remove_decals
        end
        for key in pairs(ICC.settings) do
            if type(saved[key]) == "boolean" then
                ICC.settings[key] = saved[key]
            end
        end
    end
end

function ICC:Save()
    local output = io.open(self.save_path, "w")
    if not output then
        log("[Instant Corpse Cleanup] Could not save settings.")
        return
    end
    output:write(json.encode(self.settings))
    output:close()
end

function ICC:InStealth()
    local state = managers.groupai and managers.groupai:state()
    return state and state:whisper_mode()
end

function ICC:ApplyEnemySettings(enemy)
    if not enemy or not enemy._icc_defaults then return end
    local defaults = enemy._icc_defaults
    enemy._MAX_NR_CORPSES = self.settings.remove_corpses and 0 or defaults._MAX_NR_CORPSES
    enemy._corpse_disposal_upd_interval = self.settings.remove_corpses and 0.10 or defaults._corpse_disposal_upd_interval
    enemy._MAX_NR_SHIELDS = self.settings.remove_shields and 0 or defaults._MAX_NR_SHIELDS
    enemy._shield_disposal_lifetime = self.settings.remove_shields and 0 or defaults._shield_disposal_lifetime
    enemy._shield_disposal_upd_interval = self.settings.remove_shields and 0.10 or defaults._shield_disposal_upd_interval
end

function ICC:ApplyDecalSettings(central)
    if not central or not central._icc_defaults then return end
    central._block_bullet_decals = self.settings.remove_decals or central._icc_defaults.bullet
    central._block_blood_decals = self.settings.remove_blood or central._icc_defaults.blood
end
