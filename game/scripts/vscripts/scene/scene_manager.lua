if scene_manager == nil then
	_G.scene_manager = class({})
end

AREA_POINT = {
	SUPPLY_POINT = Vector(0, 0, 128),
	GOODGUY_BASE = Vector(-7232, -7168, 264),
	BADGUY_BASE = Vector(7232, 7168, 264),
	MINING_TOP = Vector(1984, 7360, 128),
	MINING_BOTTOM = Vector(-1984, -7360, 128),
	MINING_MOUNTAIN = Vector(-5441.33, 5072.68, 928),
	MINING_MAGMA = Vector(7616, -7616, 128)
}

local RESPAWN_CHECK_POINT = {
	"GOODGUY_BASE", "BADGUY_BASE", "SUPPLY_POINT"
}

local RESOURCE_CHECK_POINT = {
	"MINING_TOP", "MINING_BOTTOM", "MINING_MOUNTAIN", "MINING_MAGMA"
}

function scene_manager:Init()
	if self.isInited then
		return
	end

	self.seizeMap = {}
	self.seizeEffs = {}

	self.areaTouching = {}
	self.areaScore = {}

	self.fowViewers = {}
	self.baseRecovery = {}
	self.miningTimer = {}
	self.miningCoalEff = {}
	self.resourceCount = {[DOTA_TEAM_GOODGUYS] = 0, [DOTA_TEAM_BADGUYS] = 0}

	self:SeizeArea("GOODGUY_BASE", DOTA_TEAM_GOODGUYS)
	self:SeizeArea("BADGUY_BASE", DOTA_TEAM_BADGUYS)

	self:StartSeizePointTimer()

	self:CheckEndTimer()

	self.isInited = true
end

function scene_manager:CacheHero(hero)
	self.cacheHeros = self.cacheHeros or {}
	if self.cacheHeros[hero:GetTeamNumber()] == nil then
		self.cacheHeros[hero:GetTeamNumber()] = {}
	end
	table.insert(self.cacheHeros[hero:GetTeamNumber()], hero)
end

function scene_manager:CheckEndTimer()
	Timers:CreateTimer(function()
		local seizeNum = {[DOTA_TEAM_GOODGUYS] = 0, [DOTA_TEAM_BADGUYS] = 0}
		for _, areaName in pairs(RESOURCE_CHECK_POINT) do
			if self.seizeMap[areaName] then
				seizeNum[self.seizeMap[areaName]] = seizeNum[self.seizeMap[areaName]] + 1
			end
		end

		local score = {}
		for team, num in pairs(seizeNum) do
			score[team] = num == #RESOURCE_CHECK_POINT and #RESOURCE_CHECK_POINT * 2 or num
		end

		self.resourceCount[DOTA_TEAM_GOODGUYS] = self.resourceCount[DOTA_TEAM_GOODGUYS] + score[DOTA_TEAM_GOODGUYS]
		self.resourceCount[DOTA_TEAM_BADGUYS] = self.resourceCount[DOTA_TEAM_BADGUYS] + score[DOTA_TEAM_BADGUYS]

		for uID, playerID in pairs(userPlayerMap) do
			PlayerResource:ModifyGold(playerID, score[PlayerResource:GetTeam(playerID)], true, DOTA_ModifyGold_GameTick)
		end

		local data = {}
    	data[DOTA_TEAM_GOODGUYS] = {}
    	data[DOTA_TEAM_GOODGUYS].seizeNum = seizeNum[DOTA_TEAM_GOODGUYS]
    	data[DOTA_TEAM_GOODGUYS].addGold = score[DOTA_TEAM_GOODGUYS]
    	data[DOTA_TEAM_GOODGUYS].winProgress = string.format("%.1f%%", self.resourceCount[DOTA_TEAM_GOODGUYS] / WIN_RESOURCE * 100)
    	data[DOTA_TEAM_BADGUYS] = {}
    	data[DOTA_TEAM_BADGUYS].seizeNum = seizeNum[DOTA_TEAM_BADGUYS]
    	data[DOTA_TEAM_BADGUYS].addGold = score[DOTA_TEAM_BADGUYS]
    	data[DOTA_TEAM_BADGUYS].winProgress = string.format("%.1f%%", self.resourceCount[DOTA_TEAM_BADGUYS] / WIN_RESOURCE * 100)
		ui_manager.UpdateResouceView(data)

		for team, score in pairs(self.resourceCount) do
			if score >= WIN_RESOURCE then
				ui_manager.ShowGameEndView(team)
				return nil
			end
		end
		return 1
	end)
end

local seizeNeed = 30
function scene_manager:SeizeEffUpdate(areaName, score)
	local effArg = {}
	local baseEffCps = nil
	local addCps = nil
	effArg.createAttach = "PATTACH_WORLDORIGIN"

	local vecPoint = AREA_POINT[areaName]
	self.seizeEffs[areaName] = self.seizeEffs[areaName] or {}
	if score > 0 then
		if self.seizeEffs[areaName][DOTA_TEAM_BADGUYS] then
			abilities_eff_RemoveEff( { effIdx = self.seizeEffs[areaName][DOTA_TEAM_BADGUYS] } )
			self.seizeEffs[areaName][DOTA_TEAM_BADGUYS] = nil
		end

		local groundHeight = GetGroundHeight(vecPoint, nil)
		baseEffCps = string.format("nm,0,%f,%f,%f", vecPoint.x, vecPoint.y + 200, groundHeight - 800 * (1 - score / seizeNeed) )
		addCps = string.format("|nm,1,%f,%f,%f", vecPoint.x, vecPoint.y + 200, groundHeight)
		effArg.cps = baseEffCps .. addCps
		effArg.eff = "particles/goodguy_zhanqi.vpcf"
		if not self.seizeEffs[areaName][DOTA_TEAM_GOODGUYS] then
			self.seizeEffs[areaName][DOTA_TEAM_GOODGUYS] = abilities_eff_CreateEff(effArg)
		else
			effArg.effIdx = self.seizeEffs[areaName][DOTA_TEAM_GOODGUYS]
			abilities_eff_UpdateEff(effArg)
		end
	elseif score < 0 then
		if self.seizeEffs[areaName][DOTA_TEAM_GOODGUYS] then
			abilities_eff_RemoveEff( {effIdx = self.seizeEffs[areaName][DOTA_TEAM_GOODGUYS]} )
			self.seizeEffs[areaName][DOTA_TEAM_GOODGUYS] = nil
		end

		local groundHeight = GetGroundHeight(vecPoint, nil)
		baseEffCps = string.format("nm,0,%f,%f,%f", vecPoint.x, vecPoint.y + 200, groundHeight - 800 * (1 + score / seizeNeed) )
		addCps = string.format("|nm,1,%f,%f,%f", vecPoint.x, vecPoint.y + 200, groundHeight)
		effArg.cps = baseEffCps .. addCps
		effArg.eff = "particles/badguy_zhanqi.vpcf"

		if not self.seizeEffs[areaName][DOTA_TEAM_BADGUYS] then
			self.seizeEffs[areaName][DOTA_TEAM_BADGUYS] = abilities_eff_CreateEff(effArg)
		else
			effArg.effIdx = self.seizeEffs[areaName][DOTA_TEAM_BADGUYS]
			abilities_eff_UpdateEff(effArg)
		end
	end
end

function scene_manager:StartSeizePointTimer()
	Timers:CreateTimer(function()
		for areaName, touchings in pairs(self.areaTouching) do
			local score = self.areaScore[areaName] or 0
			for unit, touchData in pairs(touchings) do
				if not IsValidEntity(unit) or not unit:IsAlive() then
					self.areaTouching[areaName][unit] = nil
				else
					if touchData.team == DOTA_TEAM_GOODGUYS then
						score = score + 0.05
					else
						score = score - 0.05
					end
				end	
			end
			score = score > seizeNeed and seizeNeed or score
			score = score < -seizeNeed and -seizeNeed or score

			if self.areaScore[areaName] ~= score then
				self.areaScore[areaName] = score
				
				self:SeizeEffUpdate(areaName, score)

				if score == seizeNeed and self.seizeMap[areaName] ~= DOTA_TEAM_GOODGUYS then
					self:SeizeArea(areaName, DOTA_TEAM_GOODGUYS)
				end

				if score == -seizeNeed and self.seizeMap[areaName] ~= DOTA_TEAM_BADGUYS then
					self:SeizeArea(areaName, DOTA_TEAM_BADGUYS)
				end
					
				ui_manager.UpdatePointScore(areaName, score)
			end
		end

		return 0.05
	end)
end

function scene_manager:ChangeFowViewer(areaName, team)
	if IsValidEntity(self.fowViewers[areaName]) then
		self.fowViewers[areaName]:RemoveSelf()
	end
	local viewerArgs = {}
	viewerArgs.unit_name = "fow_viewer"
	viewerArgs.spawnPos = AREA_POINT[areaName]
	viewerArgs.unit_team = team
	self.fowViewers[areaName] = SpawnCostomUnit(viewerArgs)
end

function scene_manager:SeizeArea(areaName, team)
	self.seizeMap[areaName] = team
	self.areaScore[areaName] = team == DOTA_TEAM_GOODGUYS and seizeNeed or -seizeNeed
	self:SeizeEffUpdate(areaName, self.areaScore[areaName])
	self:ChangeFowViewer(areaName, team)

	if areaName == "GOODGUY_BASE" or areaName == "BADGUY_BASE" then
		if IsValidEntity(self.baseRecovery[areaName]) then
			self.baseRecovery[areaName]:RemoveSelf()
		end
		local recoveryArgs = {}
		recoveryArgs.unit_name = "base_recovery"
		recoveryArgs.spawnPos = AREA_POINT[areaName]
		recoveryArgs.unit_team = team
		self.baseRecovery[areaName] = SpawnCostomUnit(recoveryArgs)
	end

	if string.find(areaName, "MINING") then
		if self.miningCoalEff[areaName] == nil then
			local coalEffArgs = {}
			coalEffArgs.eff = "particles/wajuetexiao.vpcf"
			coalEffArgs.Target = "POINT"
			coalEffArgs.cps = "nm,0"
			coalEffArgs.target_points = {AREA_POINT[areaName]}
			self.miningCoalEff[areaName] = abilities_eff_CreateEff(coalEffArgs)
		end
	end
end

function scene_manager:OnHeroDead(unit)
	unit:SetTimeUntilRespawn(5)
	Timers:CreateTimer(4.8, function()
		local minDisPoint = self.CheckRespawnPoint(unit)
		if minDisPoint == nil then
			unit:SetTimeUntilRespawn(5)
			return 4.8
		else
			unit:SetRespawnPosition(minDisPoint.pos)
		end
	end)
end

function scene_manager.CheckRespawnPoint(unit)
	local team = unit:GetTeamNumber()
	local minDisPoint = nil
	for _, areaName in pairs(RESPAWN_CHECK_POINT) do
		if scene_manager.seizeMap[areaName] == team then
			local dis = (unit:GetAbsOrigin() - AREA_POINT[areaName]):Length()
			if minDisPoint == nil or minDisPoint.dis > dis then
				minDisPoint = {}
				minDisPoint.dis = dis
				minDisPoint.pos = RotatePosition(AREA_POINT[areaName], QAngle(0, unit:GetPlayerOwnerID() * 36, 0), AREA_POINT[areaName] + Vector(200, 0, 0))			
			end
		end
	end
	return minDisPoint
end

function scene_manager:AddTouching(areaName, unit)
	if not scene_manager.isInited then
		scene_manager:Init()
	end

	if scene_manager.areaTouching[areaName] == nil then
		scene_manager.areaTouching[areaName] = {}
	end

	local touchData = {}
	touchData.startTime = GameRules:GetGameTime()
	touchData.team = unit:GetTeamNumber()
	scene_manager.areaTouching[areaName][unit] = touchData
	local effArg = {}
	effArg.eff = "particles/zhanlingxiaoguo.vpcf"
	effArg.target = unit
	effArg.cps = "ent,0,target,PATTACH_ABSORIGIN_FOLLOW,attach_hitloc|ent,1,target,PATTACH_ABSORIGIN_FOLLOW,attach_hitloc"
	unit.seizeEffIdx = abilities_eff_CreateEff(effArg)
end

function scene_manager:RemoveTouching(areaName, unit)
	scene_manager.areaTouching[areaName][unit] = nil
	abilities_eff_RemoveEff({effIdx = unit.seizeEffIdx})
end

function OnStartTouchingArea(kv)
	if kv.caller then
		if kv.caller:GetName() == "ice_mountain_trigger" then
			if kv.activator:IsRealHero() then
				kv.activator.costomAttribute.inIceMotion = true
				AppPhyMotion(kv.activator)
			end
		elseif kv.caller:GetName() == "magma_trigger" then
			kv.activator.magmaTimer = Timers:CreateTimer(function()
				local dmgArgs = {}
				dmgArgs.damage = 500
				dmgArgs.caster = kv.activator.lastAtker or kv.activator
				dmgArgs.target = kv.activator
				dmgArgs.damageType = DAMAGE_TYPE_MAGICAL
				ability_apply_damage(dmgArgs)
				return 0.5
			end)
		elseif string.find(kv.caller:GetName(), "PROTECT") then
			if (string.find(kv.caller:GetName(), "BAD") and kv.activator:GetTeamNumber() == DOTA_TEAM_BADGUYS) or (string.find(kv.caller:GetName(), "GOOD") and kv.activator:GetTeamNumber() == DOTA_TEAM_GOODGUYS) then
				return
			end
			kv.activator.protectTimer = Timers:CreateTimer(function()
				local dmgArgs = {}
				dmgArgs.damage = 500
				dmgArgs.caster = kv.activator.lastAtker or kv.activator
				dmgArgs.target = kv.activator
				dmgArgs.damageType = DAMAGE_TYPE_MAGICAL
				ability_apply_damage(dmgArgs)

				kv.activator:EmitSound("Hero_Zuus.GodsWrath")

				local effArgs = {}
				effArgs.eff = "particles/protectthunder.vpcf"
				effArgs.cps = "ent,0,target,PATTACH_ABSORIGIN_FOLLOW,attach_hitloc|ent,1,target,PATTACH_ABSORIGIN_FOLLOW,attach_hitloc|point,2,oriPos"
				effArgs.oriPos = kv.caller:GetAbsOrigin()
				effArgs.target = kv.activator
				effArgs.release = 1
				abilities_eff_CreateEff(effArgs)
				return 0.5
			end)
		else
			scene_manager:AddTouching(string.gsub(kv.caller:GetName(), "_trigger", ""), kv.activator)
		end
	end
end

function OnEndTouchingArea(kv)
	if kv.caller then
		if kv.caller:GetName() == "ice_mountain_trigger" then
			if kv.activator:IsRealHero() then
				kv.activator.costomAttribute.inIceMotion = false
			end
		elseif kv.caller:GetName() == "magma_trigger" then
			Timers:RemoveTimer(kv.activator.magmaTimer)
			kv.activator.magmaTimer = nil
		elseif string.find(kv.caller:GetName(), "PROTECT") then
			if kv.activator.protectTimer then
				Timers:RemoveTimer(kv.activator.protectTimer)
				kv.activator.protectTimer = nil
			end
		else
			scene_manager:RemoveTouching(string.gsub(kv.caller:GetName(), "_trigger", ""), kv.activator)
		end
	end
end