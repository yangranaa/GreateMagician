local ai_timid = my_class("ai_timid", ai_base)

local hp_state = {normal = 1, injured = 2, dying = 3}
local mana_state = {normal = 1, low = 2}
function ai_timid:ctor(unit)
	unit.ai = self
	self.super.ctor(self, unit)

	self.hp_state = nil
	self.mana_state = nil
	self:AddClearBuffToActList()
end

function ai_timid:CheckAggro()
	if self:IsCanAttack(self.aggro) then
		return
	end
	
	self:SetAggro(self:GetMembersAttacker(1))
end

local normalActs = {}
normalActs[ai_base.CheckfollowMaster] = 90
normalActs[ai_timid.CheckAggro] = 50
normalActs[ai_base.BuffMember] = 32
normalActs[ai_base.HealMember] = 30
normalActs[ai_base.RegenManaMember] = 29
normalActs[ai_base.ControlEnemy] = 27
normalActs[ai_base.Escape] = 25
normalActs[ai_base.AbilityDmgEnemy] = 20
normalActs[ai_base.Attack] = 10
normalActs[ai_base.Roam] = 1

local dyingActs = {}
dyingActs[ai_base.CheckfollowMaster] = 90
dyingActs[ai_timid.CheckAggro] = 50
dyingActs[ai_base.BuffMember] = 32
dyingActs[ai_base.HealMember] = 30
dyingActs[ai_base.RegenManaMember] = 29
dyingActs[ai_base.ControlEnemy] = 27
dyingActs[ai_base.Escape] = 28
dyingActs[ai_base.AbilityDmgEnemy] = 20
dyingActs[ai_base.Attack] = 10
dyingActs[ai_base.Roam] = 1

function ai_timid:CheckState()
	if self.unit:GetHealthPercent() >= 50 and self.hp_state ~= hp_state.normal then
		self.hp_state = hp_state.normal

		self:SetActsToList(normalActs)
	elseif self.unit:GetHealthPercent() < 50 and self.hp_state ~= hp_state.dying then
		self.hp_state = hp_state.dying

		self:SetActsToList(dyingActs)
	end

	if self.unit:GetManaPercent() < 15 and self.mana_state ~= mana_state.low then
		self.mana_state = mana_state.low

		local acts = {}
		acts[self.ControlEnemy] = -1
		acts[self.AbilityDmgEnemy] = -1
		acts[self.HealMember] = -1
		acts[self.BuffMember] = -1
		self:SetActsToList(acts)
	elseif self.unit:GetManaPercent() >= 15 and self.mana_state ~= mana_state.normal then
		self.mana_state = mana_state.normal

		if self.hp_state == hp_state.normal then
			self:SetActsToList(normalActs)
		elseif self.hp_state == hp_state.dying then
			self:SetActsToList(dyingActs)
		end
	end
end

return ai_timid