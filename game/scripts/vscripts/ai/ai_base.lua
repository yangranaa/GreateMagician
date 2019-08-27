_G.ai_base = my_class("ai_base")

debuff_priority = {
	stun = 102,
}

function ai_base.ctor(self, unit)
	self.unit = unit

	self.master = nil
	self.dispose = false
	self.aggro = nil
	self.state = nil
	self.roamerPoint = nil
	self.idleTime = 0.1
	self.following = false
	self.stopAI = false
	self.targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	self.groups = nil
	self.actList = {}
	self.actTable = {}
	self.lastExcTime = 0

	self.unit:SetContextThink( "ai_base.aiThink", Dynamic_Wrap( self, "aiThink" ), 0 )
end

function ai_base.aiThink(unit)
	local self = unit.ai

	if not self:IsReadyForAct() then
		return self.idleTime
	end

	self.isEscape = false

	if not self:IsCanAttack(self.aggro) then
		self.aggro = nil
	end

	if self.unit:GetAggroTarget() and self.unit:GetAggroTarget() ~= self.aggro then
		self:SetAggro(self.unit:GetAggroTarget())
	end

	self:CheckState()
	self:StartAct()

	return self.idleTime
end

function ai_base:CheckState()
	
end

function ai_base:Dispose()
	
end

----------------------状态条件判断----------------------------

function ai_base:IsInSaveRange()
	if not self:IsCanAttack(self.aggro) then return true end

	local range = self.unit:GetBaseAttackRange() - 50

	return not self.unit:IsPositionInRange(self.aggro:GetAbsOrigin(), range)
end

function ai_base:IsReadyForAct()
	if self.master and not self.unit:IsAlive() then
		self.idleTime = nil
		return false
	end

	if self:CheckfollowMaster() then
		self.idleTime = 0.1
		return false
	end

	if GameRules:GetGameTime() - self.unit:GetLastIdleChangeTime() > 10 then
		self:InterruptAct()
	end

	if (self.unit:IsIdle() or (self.unit:AttackReady() and self.unit:IsAttacking())) and (self.master == nil or self.master and not self.master.holdPet) and not self.stopAI then
		if GameRules:GetGameTime() - self.unit:GetLastIdleChangeTime() > self.idleTime then
			return true
		else
			self.idleTime = self.idleTime - (GameRules:GetGameTime() - self.unit:GetLastIdleChangeTime())
		end
	else
		self.idleTime = 0.1
	end
	
	return false
end

function ai_base:IsCanAttack(unit)
	if not IsValidEntity(unit) or not unit:IsAlive() or unit:IsInvisible() or unit:IsInvulnerable()  then return false end

	if unit.ai == nil then
		if unit == self.master then
			return false
		else
			return true
		end
	end

	if unit == self.unit or (unit.ai.master and unit.ai.master == self.master) then
		return false
	end

	for atkGroup,_ in pairs(unit.ai.groups or {}) do
		for selfGroup,_ in pairs(self.groups or {}) do
			if atkGroup == selfGroup then
				return false
			end
		end
	end

	return true
end

function ai_base:BeAttack(attacker, damage)
	if not self:IsCanAttack(attacker) then
		return
	end
	
	if self.cacheAttacker == nil then
		self.cacheAttacker = {}
		self.cacheAttacker.count = 0
	end
	local entIdx = attacker:GetEntityIndex()
	if self.cacheAttacker[entIdx] == nil then
		self.cacheAttacker.count = self.cacheAttacker.count + 1
		self.cacheAttacker[entIdx] = {}
		self.cacheAttacker[entIdx].damage = 0
		self.cacheAttacker[entIdx].unit = attacker
		self.cacheAttacker[entIdx].time = GameRules:GetGameTime()
	end
	self.cacheAttacker[entIdx].damage = self.cacheAttacker[entIdx].damage + damage

	if not self:IsCanAttack(self.aggro) then
		self.unit:Interrupt()
	else
		local aggroIdx = self.aggro:GetEntityIndex()
		if self.cacheAttacker[aggroIdx] and self.cacheAttacker[aggroIdx].damage < self.cacheAttacker[entIdx].damage then
			self.unit:Interrupt()
		end
	end
end

---------------------------------------------行为控制-------------------------

function ai_base:StartAct()
	if #self.actList == 0 then return end
	actList = self.actList

	local args = {}
	args.clearAbilities = {}

	local removeAbilities = {}
	for k, ability in pairs(self.unit.abilities or {}) do
		if ability:IsNull() then
			table.insert(removeAbilities, k)
		elseif ability:IsFullyCastable() then
			args.buffAbilities = args.buffAbilities or ability.effTypes.isBuff and ability
			args.ctlAbilities = args.ctlAbilities or ability.effTypes.isControl and ability
			args.atkAbilities = args.atkAbilities or ability.effTypes.isAtk and ability
			args.healAblities = args.healAblities or ability.effTypes.isHeal and ability
			args.escapeAbilities = args.escapeAbilities or ability.effTypes.isEscape and ability
			args.regenManaAbilites = args.regenManaAbilites or ability.effTypes.isRmana and ability
			if ability.effTypes.clearDebuff then
				args.clearAbilities[ability.effTypes.clearDebuff] = ability 
			end
		end
	end

	for i, removeIdx in ipairs(removeAbilities) do
		table.remove(self.unit.abilities, removeIdx)
	end

	for _, act in ipairs(actList) do
		local excAct = act.f(self, args)
		-- if excAct then
		-- 	print("asdasd", excAct, act.p, self.unit:GetUnitName())
		-- end
		if excAct then
			self.idleTime = 1
			self.lastExcTime = GameRules:GetGameTime()
			self.lastExcFunPro = act.p
			return true
		end
	end

	return false
end

function ai_base:SetActsToList(acts)
	for actFun, priority in pairs(acts) do
		self.actTable[actFun] = priority
	end
	self:SortActToList()
end

function ai_base:AddActToList(actFun, priority)
	self.actTable[actFun] = priority
	self:SortActToList()
end

function ai_base:RemoveActInList(actFun)
	self.actTable[actFun] = nil
	self:SortActToList()
end

function ai_base:SortActToList()
	self.actList = {}
	for fun, priority in pairs(self.actTable) do
		local kv = {p = priority, f = fun }
		table.insert(self.actList, kv)
	end
	table.sort(self.actList, function(a, b)
	 	return a.p > b.p
 	end)
end

function ai_base:AddClearBuffToActList()
	if TableCount(self.clearBuffFuns or {}) > 0 then return end
	self.clearBuffFuns = {}
	for debuffName, priority in pairs(debuff_priority) do
		local clearBuffFun = function(self, args)
			if TableCount(args.clearAbilities) == 0 then return false end
			for debuffNames, ability in pairs(args.clearAbilities) do
				for name, _ in pairs(debuffNames) do
					if name == debuffName then
						local target = self:GetMember(3, "modifier_" .. debuffName, true)
						if target then	
							return self:CastAbility(ability, target)
						end
					end
				end
			end
			return false
		end

		self.clearBuffFuns[clearBuffFun] = priority
	end
	self:SetActsToList(self.clearBuffFuns)
end

function ai_base:RemoveClearBuffActInList()
	for fun, priority in pairs(self.clearBuffFuns or {}) do
		self:RemoveActInList(fun)
	end
end

------------------------------------member-----------------
if ai_base.groupMembers == nil then
	ai_base.groupMembers = {}
end

function ai_base:AddToGroup(groupName)
	if self.groups == nil then
		self.groups = {}
	end
	self.groups[groupName] = true

	if ai_base.groupMembers[groupName] == nil then
		ai_base.groupMembers[groupName] = {}
		ai_base.groupMembers[groupName].leader = self.unit
	end
	ai_base.groupMembers[groupName][self.unit:GetEntityIndex()] = self.unit
end

function ai_base:RemoveFromGroup(groupName)
	for name,v in pairs(self.groups or {}) do
		if groupName == nil or name == groupName then
			ai_base.groupMembers[name][self.unit:GetEntityIndex()] = nil
			self.groups[name] = nil
		end
	end
end

function ai_base:GetRandomGroupName()
	if self.groups then
		for k,v in pairs(self.groups) do
			return k
		end
	end
	return nil
end

function ai_base:GetAllMembers()
	local result = {}
	result[self.unit:GetEntityIndex()] = self.unit

	for groupName,_ in pairs(self.groups or {}) do
		local groupMembers = self:GetGroupMembers(groupName)
		for entIdx, unit in pairs(groupMembers or {}) do
			result[entIdx] = unit
		end
	end
	if self.master then
		for entIdx, unit in pairs(self.master.petUnits or {}) do
			if IsValidEntity(unit) then
				result[entIdx] = unit
			else
				self.master.petUnits[entIdx] = nil
			end
		end
	end

	return result
end

function ai_base:GetGroupMembers(groupName)
	for entIdx, unit in pairs(ai_base.groupMembers[groupName] or {}) do
		if not IsUnitExistAndAlive(unit) then
			ai_base.groupMembers[groupName][entIdx] = nil
		end
	end
	return ai_base.groupMembers[groupName]
end

-- 1 minHp 2 minMp 3 debuff 4 escape 5 random
function ai_base:GetMember(flag, debuff, notRandom)
	local allMembers = self:GetAllMembers()
	local minHpMeb = nil
	local minMpMeb = nil
	local debuffMeb = nil
	local escapeMeb = nil
	local randomMeb = nil
	for _, ent in pairs(allMembers) do
		randomMeb = ent
		if flag == 1 then
			minHpMeb = minHpMeb or ent
			if ent:GetHealthPercent() < minHpMeb:GetHealthPercent() then
				minHpMeb = ent
			end
		elseif flag == 2 then
			minMpMeb = minMpMeb or ent
			if ent:GetManaPercent() < minMpMeb:GetManaPercent() then
				minMpMeb = ent
			end
		elseif flag == 3 then
			if ent:HasModifier(debuff) then
				return ent
			end
		elseif flag == 4 then
			if ent.ai.isEscape then
				return ent
			end
		end
	end
	if notRandom then
		return nil
	else
		return minHpMeb or minMpMeb or randomMeb
	end
end

function ai_base:GetMembersAttacker(flag)
	local allMembers = self:GetAllMembers()
	for _, ent in pairs(allMembers) do
		if flag == 3 and self:IsCanAttack(ent.ai.aggro) then
			return ent.ai.aggro
		end
		local target = ent.ai:GetAttackerInCache(flag)
		if target then
			return target
		end
	end

	return nil
end

--flag 1 最大伤害 2 最早 3 随机 4 逃跑
function ai_base:GetAttackerInCache(flag)
	if self.cacheAttacker == nil then return end
	local maxDmgAtker = nil
	local firstDmgAtker = nil
	local randomAtker = nil
	
	flag = flag or 1
	for k, v in pairs(self.cacheAttacker) do
		if k ~= "count" then
			if not self:IsCanAttack(v.unit) then
				self.cacheAttacker.count = self.cacheAttacker.count - 1
				self.cacheAttacker[k] = nil
			else
				if flag == 1 then
					maxDmgAtker = maxDmgAtker or v
					if maxDmgAtker.damage < v.damage then
						maxDmgAtker = v
					end
				elseif flag == 2 then
					firstDmgAtker = firstDmgAtker or v
					if firstDmgAtker.time > v.time then
						firstDmgAtker = v
					end
				elseif flag == 4 and v.unit.ai.isEscape then
					return v.unit
				end
				randomAtker = v
			end
		end
	end

	return (maxDmgAtker and maxDmgAtker.unit) or (firstDmgAtker and firstDmgAtker.unit) or (randomAtker and randomAtker.unit) or nil 
end

function ai_base:SetAggro(target, lockTime)
	if lockTime == nil and self.lockAggroTime and self.lockAggroTime > GameRules:GetGameTime() and self:IsCanAttack(self.aggro) then
		return
	end

	if self:IsCanAttack(target) then
		self.aggro = target
		self:InterruptAct()

		if lockTime then
			self.lockAggroTime = GameRules:GetGameTime() + lockTime
		end
	end
end

function ai_base:SetMaster(master)
	self.master = master
	self.aggro = nil
	self.targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	self:InterruptAct()
	if self.master.petUnits == nil then
		self.master.petUnits = {}
	end

	self:RemoveFromGroup()
	
	self.cacheAttacker = nil
	self.master.petUnits[self.unit:GetEntityIndex()] = self.unit
	self.unit.pOnwer = master:GetPlayerOwnerID()
	self.unit:SetOwner(master)
	self.unit:SetControllableByPlayer(master:GetPlayerOwnerID(), false)
	self.unit:SetTeam(master:GetTeamNumber())
end

function ai_base:OnDie()
	if self.master and self.master.petUnits then
		self.master.petUnits[self.unit:GetEntityIndex()] = nil
	end
end

function ai_base:InterruptAct()
	self.unit:Interrupt()
	self.unit:SetForceAttackTarget(nil)
	self.unit:SetForceAttackTargetAlly(nil)
end

function ai_base:OnHold()
	self:InterruptAct()
end

---------------------------行为------------------------------------------
-- 攻击 回蓝 回血 伤害技 控制技 Buff 跟随主 逃跑 闲逛
function ai_base:Attack()
	if not self:IsCanAttack(self.aggro) or self.unit:GetAttackCapability() == 0 then return false end

	if self.unit:IsAttackingEntity(self.aggro) then
		return true
	end

	if self.aggro:GetTeamNumber() == self.unit:GetTeamNumber() then
		self.unit:SetForceAttackTargetAlly(self.aggro)
	else
		self.unit:MoveToTargetToAttack(self.aggro)
	end
	return true
end

function ai_base:RegenManaMember(args)
	if not args.regenManaAbilites then return false end
	local target = self:GetMember(2)
	if target and target:GetManaPercent() < 50 then
		return self:CastAbility(args.regenManaAbilites, target)
	end
	return false
end

function ai_base:HealMember(args)
	if not args.healAblities then return false end
	local target = self:GetMember(1)
	if target and target:GetHealthPercent() < 90 then
		return self:CastAbility(args.healAblities, target)
	end
	return false
end

function ai_base:AbilityDmgEnemy(args)
	if not args.atkAbilities then return false end
	local target = nil
	if self.aggro then
		target = self.aggro
	else
		target = self:GetMembersAttacker(3)
	end
	if target then
		return self:CastAbility(args.atkAbilities, target)
	end
	return false
end

function ai_base:ControlEnemy(args)
	if not args.ctlAbilities then return false end
	local target = self:GetMember(4)
	target = target and target.ai.aggro
	
	if target == nil then
		target = self:GetMembersAttacker(4)
	end
	if target then
		return self:CastAbility(args.ctlAbilities, target)
	end

	return false
end

function ai_base:BuffMember(args)
	if not args.buffAbilities or self.aggro == nil then return false end
	local member = self:GetMember(1)
	if member then
		return self:CastAbility(args.buffAbilities, member)
	end
	return false
end

function ai_base:CheckfollowMaster()
	if self.master == nil then
		return false
	end

	local checkDis = 0
	if self:IsCanAttack(self.aggro) then
		checkDis = self.unit.type.atkSearchRadius
	else
		checkDis = self.unit.type.followDis
	end

	local dis = GridNav:FindPathLength(self.unit:GetAbsOrigin(), self.master:GetAbsOrigin())
	if dis > checkDis then
		self.aggro = nil
		self.unit:MoveToPosition(self.master:GetAbsOrigin())
		self.following = true
		return true
	else
		self.following = false
		return false
	end
end

function ai_base:Escape(args)
	if self.aggro == nil or self:IsInSaveRange() then return false end

	if args.escapeAbilities and self:CastAbility(args.escapeAbilities, self.unit) then
		return true
	end

	if not self.unit:HasMovementCapability() then return false end

	self.isEscape = true
	local center = Vector(0, 0, 0)
	local maxRange = 3500

	if self.unit.type then
		maxRange = self.unit.type.maxDistanceFromSpawn
	end
	if self.master then	
		center = self.master:GetAbsOrigin()
		maxRange = self.unit.type.followDis
	elseif self.unit.spawner then
		center = self.unit.spawner:GetOrigin()
	elseif self.unit.type and self.unit.type.spawnPos then
		center = self.unit.type.spawnPos
	end

	local aToCenterVec = center - self.aggro:GetAbsOrigin()
	local ration = 1--RandomFloat(0, 1) > 0.5 and 1 or -1
	local tarVec = Vector(ration * aToCenterVec.y, -ration * aToCenterVec.x, 0):Normalized()
	local tarPos = center + tarVec * maxRange
	local moveVec = tarPos - self.unit:GetAbsOrigin()

	local movePos = self.unit:GetAbsOrigin() + moveVec:Normalized() * self.unit:GetBaseMoveSpeed()

	self.unit:MoveToPosition(movePos)
	return true
end

function ai_base:Roam()
	local origin = nil
	local maxRange = nil
	if self.master then	
		origin = self.master:GetAbsOrigin()
		maxRange = self.unit.type.followDis
	elseif self.unit.type.patrolPath then
		self.patrolPoint = self.patrolPoint or RandomInt(1, #self.unit.type.patrolPath)
		local randomAdd = RandomInt(0, 1) * 2 - 1
		if self.patrolPoint == #self.unit.type.patrolPath then
			randomAdd = -1
		elseif self.patrolPoint == 0 then
			randomAdd = 1
		end
		self.patrolPoint = self.patrolPoint + randomAdd
		origin = self.unit.type.patrolPath[self.patrolPoint]
		maxRange = self.unit.type.maxDistanceFromSpawn
	elseif self.unit.type.spawnPos then
		if self.unit.type.roamer == 0 and #(self.unit.type.spawnPos - self.unit:GetAbsOrigin()) <= self.unit.type.maxDistanceFromSpawn then
			return false
		end
		origin = self.unit.type.spawnPos
		maxRange = self.unit.type.maxDistanceFromSpawn
	elseif self.groups then
		for name,v in pairs(self.groups) do
			if IsValidEntity(ai_base.groupMembers[name].leader) and ai_base.groupMembers[name].leader:IsAlive()  then
				origin = ai_base.groupMembers[name].leader:GetAbsOrigin()
				maxRange = maxDistanceFromSpawn
				break
			end
		end
	end
	if origin == nil or maxRange == nil then 
		origin = self.unit:GetAbsOrigin()
		maxRange = 1000
	end

	self.roamerPoint = nil
	local point = origin + RandomVector(RandomFloat(0, maxRange))
	if GridNav:CanFindPath(self.unit:GetAbsOrigin(), point) then
		self.roamerPoint = point
	end

	if self.roamerPoint then
		self.unit:MoveToPosition( self.roamerPoint )
		return true
	end
	return false
end

function ai_base:backToSpawnPos(args)
	local origin = nil
	if self.master then	
		origin = self.master:GetAbsOrigin()
	elseif self.unit.spawner then
		origin = self.unit.spawner:GetOrigin()
	elseif self.unit.type.spawnPos then
		origin = self.unit.type.spawnPos
	end
	if origin == nil then return false end

	if GridNav:FindPathLength(origin, self.unit:GetAbsOrigin()) > 100 then
		self.unit:MoveToPosition(origin)
		return true
	end

	return false
end

function ai_base:CastAbility(ability, target, point)
	if self.unit:HasModifier("modifier_my_silence") then return false end
	local abilityKV = ability:GetAbilityKeyValues()
	if abilityKV.AbilityUnitTargetTeam ~= "DOTA_UNIT_TARGET_TEAM_FRIENDLY" then
		if not self:IsCanAttack(target) then
			return false
		end

		if string.match(abilityKV.AbilityBehavior, "DOTA_ABILITY_BEHAVIOR_UNIT_TARGET") then
			self.unit:CastAbilityOnTarget(target, ability, -1)
			return true
		elseif string.match(abilityKV.AbilityBehavior, "DOTA_ABILITY_BEHAVIOR_POINT") then
			self.unit:CastAbilityOnPosition(point or target:GetAbsOrigin(), ability, -1)
			return true
		elseif string.match(abilityKV.AbilityBehavior, "DOTA_ABILITY_BEHAVIOR_NO_TARGET")
				and (tonumber(abilityKV.AbilityCastRange) == 0 or self.unit:IsPositionInRange(target:GetAbsOrigin(), tonumber(abilityKV.AbilityCastRange))) then
			self.unit:CastAbilityNoTarget(ability, -1)
			return true
		end
	else
		if not IsValidEntity(target) or not target:IsAlive() then
			return false
		end
		if string.match(abilityKV.AbilityBehavior, "DOTA_ABILITY_BEHAVIOR_UNIT_TARGET") then
			self.unit:CastAbilityOnTarget(target, ability, -1)
			return true
		elseif string.match(abilityKV.AbilityBehavior, "DOTA_ABILITY_BEHAVIOR_POINT") then
			self.unit:CastAbilityOnPosition(point or target:GetAbsOrigin(), ability, -1)
			return true
		elseif string.match(abilityKV.AbilityBehavior, "DOTA_ABILITY_BEHAVIOR_NO_TARGET")
				and (tonumber(abilityKV.AbilityCastRange) == 0 or self.unit:IsPositionInRange(target:GetAbsOrigin(), tonumber(abilityKV.AbilityCastRange))) then

			self.unit:CastAbilityNoTarget(ability, -1)
			return true
		end
	end

	return false
end