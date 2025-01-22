meta = {
    name = 'Spelunker Trials Redux',
	description = "A collection of redesigned and rebalanced levels from the Spelunker Trials series.\n\nSee Level_List.txt in the mod files for help with choosing a shortcut.\n\n1 to 16 [Vol. 1]\n18 to 31 [Vol. 2 + Extras]\n33 to 47 [B-Sides]\n49 to 62 [C-Sides]",
    version = '1.4b',
    author = 'JawnGC',
}

register_option_int("level_selected", "Level number for shortcut door (1 to 62)", 1, 1, 62)

local level_sequence = require("LevelSequence/level_sequence")
local telescopes = require("Telescopes/telescopes")
local DIFFICULTY = require('difficulty')
local SIGN_TYPE = level_sequence.SIGN_TYPE
local save_state = require('save_state')
local horizontal_forcefields = require('horizontal_forcefields')
local olmec_pillars = require('olmec_pillars')
local blockchain_and_firebug = require("blockchain_and_firebug")
local kaizo_block = require("kaizo_block")
local single_pipes = require("single_pipes")

local update_continue_door_enabledness
local force_save
local save_data
local save_context

--Dwelling Levels
local d1 = require("skill_check")
local d2 = require("lock_picking")
local d3 = require("fetch_quest")
local d4 = require("verticality")
local d5 = require("bootcamp")
local d6 = require("low_roller")
local d7 = require("side_quest")
local d8 = require("teamwork")
local d9 = require("gravity")

--Volcana Levels
local v1 = require("heating_up")
local v2 = require("companion")
local v3 = require("knocking")
local v4 = require("treadmill")
local v5 = require("lavender")
local v6 = require("k9")
local v7 = require("giga_vlad")
local v8 = require("meltdown")
local v9 = require("hellevator")

--Jungle Levels
local j1 = require("welcome")
local j2 = require("sharpshooter")
local j3 = require("aichmophobia")
local j4 = require("pyromania")
local j5 = require("serpentine")
local j6 = require("glide")
local j7 = require("immunity")
local j8 = require("pins")
local j9 = require("pool_party")

--Tidepool Levels
local ti1 = require("torpedo")
local ti2 = require("escort")
local ti3 = require("roasted")
local ti4 = require("effervescence")
local ti5 = require("betrayal")
local ti6 = require("prison_break")
local ti7 = require("spring_break")
local ti8 = require("lake_of_rage")

--Temple Levels
local te1 = require("momentum")
local te2 = require("oasis")
local te3 = require("gunpowder")
local te4 = require("joyride")
local te5 = require("hydrated")
local te6 = require("delivery")
local te7 = require("transit")
local te8 = require("apollo")

--Neo Babylon Levels
local nb1 = require("breach")
local nb2 = require("bounce_house")
local nb3 = require("brain_freeze")
local nb4 = require("laser_tag")
local nb5 = require("guardian")
local nb6 = require("auto")
local nb7 = require("trickshot")
local nb8 = require("mythical")

--Sunken City Levels
local sc1 = require("choking_hazard")
local sc2 = require("zenith")
local sc3 = require("assist")
local sc4 = require("icarus")
local sc5 = require("popcorn")
local sc6 = require("royalty")
local sc7 = require("uppercut")
local sc8 = require("encore")

--Other Levels
local rest1 = require("rest_area_1")
local rest2 = require("rest_area_2")
local rest3 = require("rest_area_3")
local ending = require("ending")

--Set level order
levels = {d1, d2, v1, v2, v3, j1, j2, j3, ti1, ti2, te1, te2, nb1, nb2, sc1, sc2, rest1, d3, d4, v4, v5, j4, j5, ti3, ti4, te3, te4, nb3, nb4, sc3, sc4, rest2, d5, d6, d7, v6, v7, j6, j7, ti5, ti6, te5, te6, nb5, nb6, sc5, sc6, rest3, d8, d9, v8, v9, j8, j9, ti7, ti8, te7, te8, nb7, nb8, sc7, sc8, ending}
level_sequence.set_levels(levels)

--Do not spawn Ghost
set_ghost_spawn_times(-20000, -20000)

--Replace Monster Drops
replace_drop(DROP.EGGSAC_GRUB_1, ENT_TYPE.ITEM_BLOOD)
replace_drop(DROP.EGGSAC_GRUB_2, ENT_TYPE.ITEM_BLOOD)
replace_drop(DROP.EGGSAC_GRUB_3, ENT_TYPE.ITEM_BLOOD)

local create_stats = require('stats')
local function create_saved_run()
	return {
		has_saved_run = false,
		saved_run_attempts = nil,
		saved_run_time = nil,
		saved_run_level = nil,
	}
end

local game_state = {
	difficulty = DIFFICULTY.NORMAL,
	stats = create_stats(),
	normal_saved_run = create_saved_run(),
}

local continue_door

function update_continue_door_enabledness()
	if not continue_door then return end
	local current_saved_run = game_state.normal_saved_run
	continue_door.update_door(current_saved_run.saved_run_level, current_saved_run.saved_run_attempts, current_saved_run.saved_run_time)
end

-- "Continue Run" Door
define_tile_code("continue_run")
local function continue_run_callback()
	return set_pre_tile_code_callback(function(x, y, layer)
		continue_door = level_sequence.spawn_continue_door(
			x,
			y,
			layer,
			game_state.normal_saved_run.saved_run_level,
			game_state.normal_saved_run.saved_run_attempts,
			game_state.normal_saved_run.saved_run_time,
			SIGN_TYPE.RIGHT)
		return true
	end, "continue_run")
end

-- Tile Codes for Shortcuts
define_tile_code("shortcuts")
local function shortcut_callback()
	return set_pre_tile_code_callback(function(x, y, layer)
		if options.level_selected < 1 then
			options.level_selected = 1
		elseif options.level_selected > #levels - 1 then
			options.level_selected = #levels - 1
		end
		
		level_sequence.spawn_shortcut(x, y, layer, levels[options.level_selected], SIGN_TYPE.RIGHT)
		return true
	end, "shortcuts")
end

--Misc Tile Codes
define_tile_code("m_arrow")
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn(ENT_TYPE.ITEM_METAL_ARROW, x, y, layer, 0, 0)
	return true
end, "m_arrow")

define_tile_code("anti_thorn_technology")
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_PICKUP_SPIKESHOES, x, y, layer, 0, 0)		
	return true
end, "anti_thorn_technology")

define_tile_code("mitt")
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_PICKUP_PITCHERSMITT, x, y, layer, 0, 0)		
	return true
end, "mitt")

define_tile_code("yellow_cape")
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_CAPE, x, y, layer, 0, 0)		
	return true
end, "yellow_cape")

define_tile_code("springs")
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_PICKUP_SPRINGSHOES, x, y, layer, 0, 0)	
	return true
end, "springs")
	
define_tile_code("climbers")
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_PICKUP_CLIMBINGGLOVES, x, y, layer, 0, 0)		
	return true
end, "climbers")

define_tile_code("freezeray")
local freeze_ray
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_FREEZERAY, x, y, layer, 0, 0)
	return true
end, "freezeray")

define_tile_code("pp")
local pp
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_POWERPACK, x, y, layer, 0, 0)		
	pp = get_entity(block_id)
	return true
end, "pp")	

define_tile_code("shot_gun")
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_SHOTGUN, x, y, layer, 0, 0)
	return true
end, "shot_gun")

level_sequence.set_on_win(function(attempts, total_time)
	local frames = total_time
	local hours = 0
	local minutes = 0
	local seconds = 0
	local milliseconds = 0
	
	hours = frames // 216000
	frames = frames - (hours * 216000)
	
	minutes = frames // 3600
	frames = frames - (minutes * 3600)
	
	seconds = frames // 60
	frames = frames - (seconds * 60)
	
	milliseconds = math.floor(frames * 16.667)

	print("Total Deaths: " .. tostring(attempts - 1))
	print("Total Time: " .. hours .. "h " .. minutes .. "m " .. seconds .. "s " .. milliseconds .. "ms")
	warp(1, 1, THEME.BASE_CAMP)
end)

--Dark Level stuff
set_callback(function()
	if state.theme == THEME.BASE_CAMP then
		state.level_flags = clr_flag(state.level_flags, 18)
	elseif level_sequence.get_run_state().current_level.identifier == "lavender" then
		state.level_flags = set_flag(state.level_flags, 18)
	elseif level_sequence.get_run_state().current_level.identifier == "giga_vlad" then
		state.level_flags = set_flag(state.level_flags, 18)
	elseif level_sequence.get_run_state().current_level.identifier == "prison_break" then
		state.level_flags = set_flag(state.level_flags, 18)
	else	
		state.level_flags = clr_flag(state.level_flags, 18)
	end	
end, ON.POST_ROOM_GENERATION)

set_post_entity_spawn(function(entity) 
	entity.flags = clr_flag(entity.flags, 22) 
end, SPAWN_TYPE.ANY, MASK.ITEM, nil)

set_callback(function()
    if state.loading == 1 and state.screen_next == SCREEN.TRANSITION then
        for _, p in ipairs(players) do
            for _, v in ipairs(p:get_powerups()) do
                p:remove_powerup(v)
            end
        end
    end
end, ON.LOADING)

--Remove resources from the player and set health to 1
--Remove held item from the player
level_sequence.set_on_post_level_generation(function(level)
	if #players == 0 then return end
	
	players[1].inventory.bombs = 0
	players[1].inventory.ropes = 0
	players[1].health = 1
	
	if players[1].holding_uid ~= -1 then
		players[1]:get_held_entity():destroy()
	end
end)

level_sequence.set_on_completed_level(function(completed_level, next_level)
	if not next_level then return end

	local current_stats = game_state.stats
	local best_level_index = level_sequence.index_of_level(current_stats.best_level)
	local current_level_index = level_sequence.index_of_level(next_level)

	if (not best_level_index or current_level_index > best_level_index) and
			not level_sequence.took_shortcut() then
				current_stats.best_level = next_level
	end
end)

-- Manage saving data and keeping the time in sync during level transitions and resets.
function save_data()
	if save_context then
		force_save(save_context)
	end
end

function save_current_run_stats()
	local run_state = level_sequence.get_run_state()
	-- Save the current run
	if state.theme ~= THEME.BASE_CAMP and
		level_sequence.run_in_progress() then
		local saved_run = game_state.normal_saved_run
		saved_run.saved_run_attempts = run_state.attempts
		saved_run.saved_run_level = run_state.current_level
		saved_run.saved_run_time = run_state.total_time
		saved_run.has_saved_run = true
	end
end

function save_current_run_stats2()
	local run_state = level_sequence.get_run_state()
	-- Save the current run
	if state.theme ~= THEME.BASE_CAMP and
		level_sequence.run_in_progress() then
		local saved_run = game_state.normal_saved_run
		saved_run.saved_run_level = run_state.current_level
		saved_run.has_saved_run = true
	end
end

-- Saves the current state of the run so that it can be continued later if exited.
local function save_current_run_stats_callback()
	return set_callback(function()
		save_current_run_stats()
	end, ON.FRAME)
end

local function save_current_run_stats_callback2()
	return set_callback(function()
		save_current_run_stats2()
	end, ON.TRANSITION)
end

local function clear_variables_callback()
	return set_callback(function()
		continue_door = nil
	end, ON.PRE_LOAD_LEVEL_FILES)
end

set_callback(function(ctx)
	game_state = save_state.load(game_state, level_sequence, ctx)
end, ON.LOAD)

function force_save(ctx)
	save_state.save(game_state, level_sequence, ctx)
end

local function on_save_callback()
	return set_callback(function(ctx)
		save_context = ctx
		force_save(ctx)
	end, ON.SAVE)
end

local active = false
local callbacks = {}

local function activate()
	if active then return end
	active = true
	level_sequence.activate()

	local function add_callback(callback_id)
		callbacks[#callbacks+1] = callback_id
	end

	add_callback(continue_run_callback())
	add_callback(shortcut_callback())
	add_callback(clear_variables_callback())
	add_callback(on_save_callback())
	add_callback(save_current_run_stats_callback())
	add_callback(save_current_run_stats_callback2())
end

set_callback(function()
    activate()
end, ON.LOAD)

set_callback(function()
    activate()
end, ON.SCRIPT_ENABLE)

set_callback(function()
    if not active then return end
	active = false
	level_sequence.deactivate()

	for _, callback in pairs(callbacks) do
		clear_callback(callback)
	end

	callbacks = {}

end, ON.SCRIPT_DISABLE)

--Instant Restart on death
set_callback(function()
	if state.screen ~= 12 then
		return
	end

	local health = 0
	for i = 1,#players do
		health = health + players[i].health
	end

	if health == 0 then
		state.quest_flags = set_flag(state.quest_flags, 1)
		warp(state.world_start, state.level_start, state.theme_start)
	end
end, ON.FRAME)