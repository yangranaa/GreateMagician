local ai_rage = my_class("ai_rage", ai_base)

local hp_state = {normal = 1}

function ai_rage:ctor(unit)
	unit.ai = self
	self.super.ctor(self, unit)

	--self.unit:SetRenderColor(255, 0, 0)
	--self.unit:NotifyWearablesOfModelChange(false)
	self.hp_state = nil
end

function ai_rage:CheckAggro()
	if self.aggro then
		return
	end
	self:SetAggro(self:GetMembersAttacker(1))

	if self.aggro then
		return
	end
	
	local findArgs = {}
	findArgs.caster = self.unit
	findArgs.teamTarget = self.targetTeam
	findArgs.radius = self.unit.type.atkSearchRadius
	findArgs.flag = DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE
	local targets = FindRoundTargets(findArgs)
	for k,v in pairs(targets or {}) do
		if self:IsCanAttack(v) then
			self:SetAggro(v)
			break
		end
	end
end

local normalActs = {}
normalActs[ai_base.CheckfollowMaster] = 90
normalActs[ai_rage.CheckAggro] = 50
normalActs[ai_base.BuffMember] = 31
normalActs[ai_base.RegenManaMember] = 30
normalActs[ai_base.AbilityDmgEnemy] = 29
normalActs[ai_base.ControlEnemy] = 28
normalActs[ai_base.HealMember] = 27
normalActs[ai_base.Attack] = 26
normalActs[ai_base.Roam] = 1

function ai_rage:CheckState()
	if self.hp_state ~= hp_state.normal then
		self.hp_state = hp_state.normal

		self:SetActsToList(normalActs)
	end
end

return ai_rage