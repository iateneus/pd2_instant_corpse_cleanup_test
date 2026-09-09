dofile(ModPath .. "lua/settings.lua")
local ICC = InstantCorpseCleanup

if RequiredScript == "lib/managers/enemymanager" then
    Hooks:PostHook(EnemyManager, "init", "ICC_NativeDisposalSetup", function(self)
        self._icc_defaults = {
            _MAX_NR_CORPSES = self._MAX_NR_CORPSES,
            _MAX_NR_SHIELDS = self._MAX_NR_SHIELDS,
            _shield_disposal_lifetime = self._shield_disposal_lifetime,
            _corpse_disposal_upd_interval = self._corpse_disposal_upd_interval,
            _shield_disposal_upd_interval = self._shield_disposal_upd_interval
        }
        ICC:ApplyEnemySettings(self)
    end)

    Hooks:PostHook(EnemyManager, "corpse_limit", "ICC_ForceZeroCorpseLimit", function()
        if ICC.settings.remove_corpses then
            return ICC:InStealth() and 9999 or 0
        end
    end)

    Hooks:PostHook(EnemyManager, "shield_limit", "ICC_ForceZeroShieldLimit", function()
        if ICC.settings.remove_shields then
            return ICC:InStealth() and 9999 or 0
        end
    end)

    local function dispose_corpses(self)
        if ICC.settings.remove_corpses and not ICC:InStealth() and self:is_corpse_disposal_enabled() then
            self:_upd_corpse_disposal(self._timer:time())
        end
    end
    Hooks:PostHook(EnemyManager, "on_enemy_died", "ICC_DisposeCorpseImmediately", dispose_corpses)
    Hooks:PostHook(EnemyManager, "on_civilian_died", "ICC_DisposeCivilianImmediately", dispose_corpses)
elseif RequiredScript == "lib/units/enemies/cop/copdamage" then
    local original = Hooks:GetFunction(CopDamage, "_spawn_head_gadget")
    Hooks:OverrideFunction(CopDamage, "_spawn_head_gadget", function(self, ...)
        if ICC.settings.remove_props then return end
        return original(self, ...)
    end)
end
