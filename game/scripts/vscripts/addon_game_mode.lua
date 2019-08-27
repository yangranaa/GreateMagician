if GreatMagicianGameMode == nil then
	GreatMagicianGameMode = class({})
end
_G.MAX_PET_NUM = 4

require('utility/json')
require('utility/bit')
require('utility/define')

require('core/my_class')
require('core/my_event')
require('core/timers')
require('core/my_physics')
require("core/CostomAttribute")
require('ai/ai_base')
require('utility/utility_functions')

require('abilities/abilities_damage')
require('abilities/abilities_apply_modifier')
require('abilities/abilities_effect')

require('ui/player_manager')
require('ui/ui_manager')
require('ui/score_manager')
require('scene/scene_manager')
require('spawner/spawner_manager')
require('spawner/gift_manager')

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]


	local models = {}
	for _, name in pairs(models) do
		PrecacheResource( "model", name, context )
	end

	local heroes = {
		"wisp",
		"enigma",
		"dark_willow",
		"winter_wyvern",
		"nevermore",
		"ogre_magi",
		"storm_spirit",
		"morphling",
		"treant",
  	}
	for _,heroName in pairs(heroes) do
		PrecacheUnitByNameSync("npc_dota_hero_"..heroName, context)
	end

	local sounds = {
		"soundevents/game_sounds_heroes/game_sounds_rattletrap.vsndevts",
		"soundevents/music/valve_dota_001/soundevents_music.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_warlock.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_luna.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_earth_spirit.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_witchdoctor.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_dragon_knight.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_lion.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_nevermore.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_omniknight.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_venomancer.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_lone_druid.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_shadowshaman.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_pugna.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_phantom_lancer.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_ogre_magi.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_brewmaster.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_tusk.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_ember_spirit.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_juggernaut.vsndevts",
		"soundevents/game_sounds_ambient.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_wisp.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_earthshaker.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_lich.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_ember_spirit.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_razor.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_disruptor.vsndevts",
		"soundevents/game_sounds_creeps.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_morphling.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_pudge.vsndevts",
		"soundevents/game_sounds_greevils.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_oracle.vsndevts",
		"soundevents/game_sounds_items.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_arc_warden.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_stormspirit.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_dark_seer.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_antimage.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_lina.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_sniper.vsndevts",
		"soundevents/game_sounds.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_templar_assassin.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_clinkz.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_batrider.vsndevts",
		"soundevents/game_sounds_heroes/game_sounds_ancient_apparition.vsndevts",
		"soundevents/game_sounds_ui_imported.vsndevts",
		"soundevents/game_sounds_main.vsndevts",
	}
	for i,v in ipairs(sounds) do
		PrecacheResource( "soundfile", v, context )
	end

	local particles = {
		"particles/econ/events/ti7/hero_levelup_ti7.vpcf",
	}

	for i,v in ipairs(particles) do
		PrecacheResource("particle", v, context)
	end

	local particlesFolder = {
		"particles/econ/items/shadow_fiend/sf_desolation",
	}

	for i,v in ipairs(particlesFolder) do
		PrecacheResource( "particle_folder", v, context )
	end
end

-- Create the game mode when we activate
function Activate()
	GameRules.GreateMagician = GreatMagicianGameMode()
	GameRules.GreateMagician:InitGameMode()
end

function GreatMagicianGameMode:InitGameMode()
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 5)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 5)
	GameRules:GetGameModeEntity():SetContextThink( "GreatMagicianGameMode:GameThink", function() return self:OnThink() end, 0 )
	--GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)
	GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_wisp")
	GameRules:GetGameModeEntity():SetHUDVisible(DOTA_HUD_VISIBILITY_INVENTORY_PROTECT, false)
	--GameRules:GetGameModeEntity():SetHUDVisible(DOTA_HUD_VISIBILITY_INVENTORY_QUICKBUY, false)
	GameRules:GetGameModeEntity():SetHUDVisible(DOTA_HUD_VISIBILITY_INVENTORY_COURIER, false)
	GameRules:GetGameModeEntity():SetHUDVisible(DOTA_HUD_VISIBILITY_INVENTORY_GOLD, true)
	GameRules:GetGameModeEntity():SetBuybackEnabled(false)

	GameRules:GetGameModeEntity():SetAnnouncerDisabled(true)

	GameRules:SetCreepMinimapIconScale(0.5)
	GameRules:SetStrategyTime(0)
	GameRules:SetShowcaseTime(0)

	-- GameRules:SetGoldPerTick(0.0)
	--GameRules:SetHeroSelectionTime(0)
	--GameRules:SetPreGameTime(0)

	ListenToGameEvent( "entity_hurt", Dynamic_Wrap( GreatMagicianGameMode, "OnEntityHurt" ), self )
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( GreatMagicianGameMode, "OnEntityKilled" ), self )
	ListenToGameEvent( "player_reconnected", Dynamic_Wrap( GreatMagicianGameMode, "player_reconnected" ), self )
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( GreatMagicianGameMode, "game_rules_state_change" ), self )
	ListenToGameEvent( "player_connect_full", Dynamic_Wrap(GreatMagicianGameMode, "player_connect_full"), self)
	ListenToGameEvent( "player_team", Dynamic_Wrap( GreatMagicianGameMode, "player_team" ), self )
	ListenToGameEvent( "dota_player_used_ability", Dynamic_Wrap( GreatMagicianGameMode, "dota_player_used_ability" ), self )
	ListenToGameEvent( "dota_non_player_used_ability", Dynamic_Wrap( GreatMagicianGameMode, "dota_non_player_used_ability" ), self )
	ListenToGameEvent( "player_spawn", Dynamic_Wrap( GreatMagicianGameMode, "player_spawn" ), self )
	ListenToGameEvent( "dota_inventory_item_added", Dynamic_Wrap( GreatMagicianGameMode, "dota_inventory_item_added" ), self )
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( GreatMagicianGameMode, "npc_spawned" ), self )
	ListenToGameEvent( "dota_inventory_item_changed", Dynamic_Wrap( GreatMagicianGameMode, "dota_inventory_item_changed" ), self )

	Convars:RegisterCommand( "test", function(...) return GreatMagicianGameMode.test() end, "test.", FCVAR_CHEAT )
	Convars:RegisterCommand( "kill_all", function(...) return GreatMagicianGameMode.kill_all() end, "kill_all.", FCVAR_CHEAT )
	Convars:RegisterCommand( "open_view", GreatMagicianGameMode.open_view, "open_view", FCVAR_CHEAT )

	spawner_manager:Init()
	player_manager.Init()
end

function GreatMagicianGameMode:dota_inventory_item_changed(kv)
	print("dota_inventory_item_changed")

end

function GreatMagicianGameMode:npc_spawned(kv)
	local unit = EntIndexToHScript(kv.entindex)
	if unit:IsRealHero() and not unit.handleFirstBorn then
		unit.handleFirstBorn = true
		local basePos = AREA_POINT.GOODGUY_BASE
		if unit:GetTeamNumber() ~= DOTA_TEAM_GOODGUYS then basePos = AREA_POINT.BADGUY_BASE end
		unit:SetAbsOrigin(RotatePosition(basePos, QAngle(0, unit:GetPlayerOwnerID() * 36, 0), basePos + Vector(200, 0, 0)))
	end
end

function GreatMagicianGameMode:dota_inventory_item_added(kv)
	print("dota_inventory_item_added")
	for k,v in pairs(kv) do
		print(k,v)
	end
end

function GreatMagicianGameMode:player_spawn(kv)
	print("player_spawn")
	for k,v in pairs(kv) do
		print(k,v)
	end
end

function GreatMagicianGameMode.kill_all()
	local targets = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, Vector(0, 0, 0), nil,
		FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	for k,unit in pairs(targets or {}) do
		if not unit:IsNull() then
			unit:ForceKill(false)
		end
	end
end

function GreatMagicianGameMode.test()
	local kv = {}
	kv.caster = PlayerResource:GetPlayer(0):GetAssignedHero()
	test(kv)
end

function GreatMagicianGameMode.open_view()
	
end

function GreatMagicianGameMode:dota_player_used_ability(event)

end

function GreatMagicianGameMode:dota_non_player_used_ability(event)
	local caster = EntIndexToHScript(event.caster_entindex)
	local ability = caster:FindAbilityByName(event.abilityname)
	
end

_G.userPlayerMap = {}
function GreatMagicianGameMode:player_connect_full(event)
	if userPlayerMap[event.userid] == nil then
		userPlayerMap[event.userid] = event.PlayerID

		player_manager.InitPlayerData(event.PlayerID)
	end
end

function GreatMagicianGameMode:player_team(event)
	if event.disconnect == 1 then
		local player = PlayerResource:GetPlayer(userPlayerMap[event.userid])
		player_manager.SaveAllDataToServer(player)
	end
end

function GreatMagicianGameMode:game_rules_state_change(event)
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		scene_manager:Init()
		ui_manager.InitPreviewUnit()
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		my_event.Broadcaster("game_rules_state_change", DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP)

		player_manager.CacheAccountTime()
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then
		for uID, playerID in pairs(userPlayerMap) do
			local player = PlayerResource:GetPlayer(playerID)
			if player then
				ui_manager.CloseHeroSelectView(playerID)
			end
		end
		GameRules:FinishCustomGameSetup()
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
		
	end
end

function GreatMagicianGameMode:player_reconnected(event)
	print("player_reconnected" .. serialize(event))
	-- local player = PlayerResource:GetPlayer(event.player)
	-- player_manager.InitPlayerData(player)
end

function GreatMagicianGameMode:OnEntityKilled(event)
	local deadUnit = EntIndexToHScript(event.entindex_killed)
	local attacker = EntIndexToHScript(event.entindex_attacker)

	if deadUnit.costomAttribute then
		deadUnit.costomAttribute:OnRemove()

		spawner_manager.OnUnitDead(attacker, deadUnit)
	end

	if deadUnit:IsRealHero() then
		scene_manager:OnHeroDead(deadUnit)
	end

	score_manager.OnEntityKilled(attacker, deadUnit)
end

function GreatMagicianGameMode:OnEntityHurt(event)
	local beAttacker = EntIndexToHScript(event.entindex_killed)
	if event.entindex_attacker then
		local attacker = EntIndexToHScript(event.entindex_attacker)
		local realAttacker = GetRealCaster(attacker)
		
		score_manager.OnEntityHurt(realAttacker, beAttacker, event.damage)

		if beAttacker.ai then
			if attacker.costomAttribute and attacker.costomAttribute.unitType == COSTOM_UNIT_TYPE.NORMALUNIT then
				beAttacker.ai:BeAttack(attacker, event.damage)
			else
				beAttacker.ai:BeAttack(realAttacker, event.damage)
			end
		end 
	end
end

-- Evaluate the state of the game
function GreatMagicianGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		
	end
	return 1
end