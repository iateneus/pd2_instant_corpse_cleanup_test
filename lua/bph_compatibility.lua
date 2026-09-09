dofile(ModPath .. "lua/settings.lua")
local ICC = InstantCorpseCleanup

local START_ID = 101137 -- link_obj_start011: Clear the area
local RELEASE_ID = 101413 -- reached_amount_of_enemies_dead_part2
local WAIT_SECONDS = 20

Hooks:PreHook(CoreMissionManager.MissionScript, "_create_elements",
    "HellsIslandClearAreaTimer_CreateElements", function(self, elements)
        if not ICC.settings.remove_corpses or not Global.game_settings or Global.game_settings.level_id ~= "bph"
            or not Network:is_server() then
            return
        end

        local start, release
        for _, element in ipairs(elements) do
            if element.id == START_ID then
                start = element
            elseif element.id == RELEASE_ID then
                release = element
            end
        end

        if not start and not release then
            return
        end

        if not start or not release
            or start.class ~= "ElementInstanceInputEvent"
            or release.class ~= "ElementCounterTrigger"
            or not start.values or not release.values
            or release.values.amount ~= 10
            or release.values.trigger_type ~= "value" then
            log("[Hells Island Clear Area Timer] Unexpected mission layout; patch not applied.")
            return
        end

        release.values.elements = {}
        start.values.on_executed = start.values.on_executed or {}
        for _, link in ipairs(start.values.on_executed) do
            if link.id == RELEASE_ID then
                link.delay = WAIT_SECONDS
                return
            end
        end
        table.insert(start.values.on_executed, { id = RELEASE_ID, delay = WAIT_SECONDS })
        log("[Hells Island Clear Area Timer] Installed 20-second escort objective delay.")
    end)
