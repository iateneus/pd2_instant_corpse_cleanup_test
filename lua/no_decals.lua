dofile(ModPath .. "lua/settings.lua")
local ICC = InstantCorpseCleanup

if RequiredScript == "lib/managers/gameplaycentralmanager" then

Hooks:PostHook(GamePlayCentralManager, "init", "ICC_NoDecals_Init", function(self)
    self._icc_defaults = { bullet = self._block_bullet_decals, blood = self._block_blood_decals }
    ICC:ApplyDecalSettings(self)
end)

local original_local_flesh = Hooks:GetFunction(GamePlayCentralManager, "play_impact_flesh")
Hooks:OverrideFunction(GamePlayCentralManager, "play_impact_flesh", function(self, ...)
    if ICC.settings.remove_blood then return end
    return original_local_flesh(self, ...)
end)

local original_bullet_hit = Hooks:GetFunction(GamePlayCentralManager, "_play_bullet_hit")
Hooks:OverrideFunction(GamePlayCentralManager, "_play_bullet_hit", function(self, params)
    local unit = params.col_ray.unit
    if not ICC.settings.remove_blood or not alive(unit) or not unit:in_slot(self._slotmask_flesh) then
        return original_bullet_hit(self, params)
    end
    local count = #self._play_effects
    original_bullet_hit(self, params)
    for i = #self._play_effects, count + 1, -1 do
        table.remove(self._play_effects, i)
    end
end)

local original_flesh = Hooks:GetFunction(GamePlayCentralManager, "sync_play_impact_flesh")
Hooks:OverrideFunction(GamePlayCentralManager, "sync_play_impact_flesh", function(self, from, dir)
    if not ICC.settings.remove_blood then
        return original_flesh(self, from, dir)
    end
    local sound_source = self:_get_impact_source()
    sound_source:stop()
    sound_source:set_position(from)
    sound_source:set_switch("materials", "flesh")
    sound_source:post_event("bullet_hit")
end)


elseif RequiredScript == "lib/managers/explosionmanager" then
local original_spawn = Hooks:GetFunction(ExplosionManager, "spawn_sound_and_effects")

Hooks:OverrideFunction(ExplosionManager, "spawn_sound_and_effects", function(self,
    position, normal, range, effect_name, sound_event, on_unit, idstr_decal,
    idstr_effect, molotov_damage_effect_table, ...)
    if ICC.settings.remove_decals then idstr_decal = false end
    return original_spawn(self, position, normal, range, effect_name, sound_event,
        on_unit, idstr_decal, idstr_effect, molotov_damage_effect_table, ...)
end)

end
