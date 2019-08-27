if spawner_manager == nil then
	_G.spawner_manager = class({})
	spawner_manager.unitCache = {}
end

NATUREL_TYPE_LISTS = {
	mountain_type_list = require("spawner/mountain_type_list"),
	natural_br_type_list = require("spawner/natural_br_type_list"),
	natural_mid_type_list = require("spawner/natural_mid_type_list"),
	natural_tl_type_list = require("spawner/natural_tl_type_list"),
	magma_type_list = require("spawner/magma_type_list"),
}

function spawner_manager:Init()
	Timers:CreateTimer(function()
		for _, type_list in pairs(NATUREL_TYPE_LISTS) do
			spawner_manager:SpawnList(type_list)
		end
		return 360
	end)

	spawner_manager.npcCache = spawner_manager:SpawnList(require("spawner/npc_list"))
end

function spawner_manager:SpawnList(typeList)
	local result = {}
	for _, typeCfg in pairs(typeList) do
		if spawner_manager.unitCache[typeCfg] == nil then
			spawner_manager.unitCache[typeCfg] = {}
		end

		for i=#spawner_manager.unitCache[typeCfg], 1, -1 do
			if not IsValidEntity(spawner_manager.unitCache[typeCfg][i]) then
				table.remove(spawner_manager.unitCache[typeCfg], i)
			end
		end

		for i=#spawner_manager.unitCache[typeCfg], (typeCfg.maxCount or 1) - 1 do
			local args = spawner_manager.GenUnitDynData(typeCfg)
			local unit = SpawnCostomUnit(args)
			table.insert(spawner_manager.unitCache[typeCfg], unit)
			table.insert(result, unit)
		end
	end
	return result
end

function spawner_manager.GenUnitDynData(typeCfg)
	local data = {}
	data.type = typeCfg
	data.unit_name = typeCfg.unitName

	-- 随机性格
	data.unit_ai = typeCfg.characters and "ai_" .. PickRandomByRateList(typeCfg.characters)

	-- 随机系数
	data.coefficient = typeCfg.coefficientRange and RandomTableByRange(typeCfg.coefficientRange)
	data.spawnPos = typeCfg.spawnPos + RandomVector(RandomFloat(0, typeCfg.maxDistanceFromSpawn or 0))
	while not GridNav:CanFindPath(typeCfg.spawnPos, data.spawnPos) do
		data.spawnPos = typeCfg.spawnPos + RandomVector(RandomFloat(0, typeCfg.maxDistanceFromSpawn or 0))
	end
	data.unit_findClear = true

	data.unit_mass = typeCfg.mass
	data.unit_radius = typeCfg.radius
	data.unit_phyType = typeCfg.unitType
	data.unit_hight = typeCfg.hight
	data.unit_team = typeCfg.team
	data.unit_angle = typeCfg.angle
	data.unit_group = typeCfg.group ~= "" and typeCfg.group
	data.resistance = typeCfg.resistance

	if typeCfg.hpGain then
		data.upAttrData = {}
		-- 经验
		data.upAttrData.expCount = 0
		-- 蓝成长
		data.upAttrData.manaGain = RandomFloat(typeCfg.manaGain[1], typeCfg.manaGain[2])
		-- 血成长
		data.upAttrData.hpGain = RandomFloat(typeCfg.hpGain[1], typeCfg.hpGain[2])
		-- 攻成长
		data.upAttrData.atkGain = RandomFloat(typeCfg.atkGain[1], typeCfg.atkGain[2])
		data.upAttrData.atkTimeGain = RandomFloat(typeCfg.atkTimeGain[1], typeCfg.atkTimeGain[2])

		-- 随机技能
		data.upAttrData.abilities = RandomTableByRate(typeCfg.bornAbilities)

		-- 等级
		if typeCfg.randomLv then
			data.upAttrData.level = RandomInt(typeCfg.randomLv[1], typeCfg.randomLv[2])
		end
	end

	return data
end

function spawner_manager.OnUnitDead(attacker, deadUnit)
	if (deadUnit.costomAttribute.unitType ~= COSTOM_UNIT_TYPE.PLAYER and deadUnit.costomAttribute.unitType ~= COSTOM_UNIT_TYPE.NORMALUNIT)
		 or deadUnit.summonCaster then
		return
	end

	DropItemByUnit(deadUnit)

	attacker = attacker or deadUnit.lastAtker or deadUnit
	attacker = GetRealCaster(attacker)
	if not IsValidEntity(attacker) then return end

	local getExp = deadUnit:IsRealHero() and 5000 or deadUnit:GetMaxHealth()
	if attacker.upAttrData then
		local needExp = attacker:GetMaxHealth()
		attacker.upAttrData.expCount = attacker.upAttrData.expCount + getExp

		while(attacker.upAttrData.expCount >= needExp) and attacker:GetLevel() < 10 do
			spawner_manager.SetUnitLevel(attacker, attacker:GetLevel() + 1)
			local nFXIndex = ParticleManager:CreateParticle( "particles/econ/events/ti7/hero_levelup_ti7.vpcf",  PATTACH_ABSORIGIN_FOLLOW, attacker)
			ParticleManager:SetParticleControlEnt( nFXIndex, 0, attacker,  PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0, 0, 0), true )
			ParticleManager:ReleaseParticleIndex( nFXIndex )

			attacker.upAttrData.expCount = attacker.upAttrData.expCount - needExp
			needExp = attacker:GetMaxHealth()
		end
	end

	for _, petUnit in pairs(deadUnit.petUnits or {}) do
		if IsValidEntity(petUnit) then
			petUnit:ForceKill(false)
		end
	end

	for unit, _ in pairs(deadUnit.destoryOnDie or {}) do
		if IsValidEntity(unit) and unit:IsAlive() then
			unit:ForceKill(false)
		end
	end
	deadUnit.destoryOnDie = {}

	if attacker.costomAttribute.unitType == COSTOM_UNIT_TYPE.PLAYER then
		for element, _ in pairs(element_menu) do
			if deadUnit.costomAttribute.coefficient[element] > 10 then
				local floatValue = math.floor(deadUnit.costomAttribute.coefficient[element] * 0.4)
				if deadUnit:IsRealHero() then
					deadUnit.costomAttribute.coefficient[element] = deadUnit.costomAttribute.coefficient[element] - floatValue
				end
				local unitArgs = {}
				unitArgs.unit_phyType = "ROAMELEMENT"
				unitArgs.unit_radius = 40
				unitArgs.unit_mass = 10
				unitArgs.unit_skipFrame = 50
				local minDis = deadUnit.costomAttribute.radius + unitArgs.unit_radius
				unitArgs.spawnPos = deadUnit:GetAbsOrigin() + RandomVector(RandomFloat(minDis + 20, minDis + 200))
				unitArgs.unit_noUseG = 1
				unitArgs.giveElement = {}
				unitArgs.giveElement[element] = floatValue
				unitArgs.unit_speedToOffset = Vector(0, 0, 150)
				unitArgs.unit_startZ = 50
				unitArgs.unit_eff = string.format("particles/fudongyuansu_%s.vpcf", element)
				unitArgs.unit_cps = "ent,0,target,PATTACH_ABSORIGIN_FOLLOW,attach_hitloc"
				unitArgs.unit_duration = 30
				unitArgs.unit_stepExc = "0.05,0.3&set_speed_to_pos&1|30&set_speed_to_unit&1"
				unitArgs.set_speed_to_unit_speedToUnit = "attacker,600"
				unitArgs.set_speed_to_unit_attacker = attacker.ai and attacker.ai.master or attacker
				unitArgs.set_speed_to_pos_speedToPos = "randomRound,400,70,200"
				unitArgs.unit_hitFuns = "CatchRoame"
				local unit = SpawnCostomUnit(unitArgs)
				unitArgs.caster = unit
				AppPhyMotion(unit)
			end
		end
	end
end

function spawner_manager.SetUnitLevel(unit, level)
	local curLv = unit:GetLevel()
	local dif = level - curLv
	local upData = unit.upAttrData
	local maxMana = unit:GetMaxMana() * ((1 + (upData.manaGain or 0)) ^ dif)
	local maxHp = unit:GetMaxHealth() * ((1 + (upData.hpGain or 0)) ^ dif)
	local maxAtk = unit:GetBaseDamageMax() * ((1 + (upData.atkGain or 0)) ^ dif)
	local minAtk = maxAtk * 0.9
	local atkTime = unit:GetBaseAttackTime() * ((1 - (upData.atkTimeGain or 0)) ^ dif)

	local manaGain = (maxMana - unit:GetMaxMana()) / dif
	unit:SetManaGain(manaGain)
	unit:SetHPGain((maxHp - unit:GetMaxHealth())/dif)
	unit:CreatureLevelUp(dif)
	--unit:SetMaxHealth(maxHp)
	unit:SetBaseHealthRegen(maxHp * 0.005)
	unit:SetBaseManaRegen(unit:GetMaxMana() * 0.005)
	unit:SetBaseDamageMin(minAtk)
	unit:SetBaseDamageMax(maxAtk)
	unit:SetBaseAttackTime(atkTime)
end