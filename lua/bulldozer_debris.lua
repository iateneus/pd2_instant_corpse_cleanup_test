dofile(ModPath .. "lua/settings.lua")
local ICC = InstantCorpseCleanup

local spawn_element = CoreSequenceManager.SpawnUnitElement

if spawn_element._icc_bulldozer_debris_installed then
    return
end

local original_activate = spawn_element.activate_callback

function spawn_element:activate_callback(env, ...)
    local name = self:run_parsed_func(env, self._name)

    if ICC.settings.remove_props and type(name) == "string" and name:match("/ene_acc_bulldozer_[^/]+$") then
        return
    end

    return original_activate(self, env, ...)
end

spawn_element._icc_bulldozer_debris_installed = true
