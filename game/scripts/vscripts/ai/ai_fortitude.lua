local ai_fortitude = my_class("ai_fortitude", ai_base)

local hp_state = {normal = 1}
local mana_state = {normal = 1, low = 2}
function ai_fortitude:ctor(unit)
	unit.ai = self
	self.super.ctor(self, unit)

	self.hp_state = nil
	self.mana_state = nil
	self:AddClearBuffToActList()
end

function ai_fortitude:CheckAggro()
	if self:IsCanAttack(self.aggro) then
		return
	end

	self:SetAggro(self:GetMembersAttacker(1))
end

local normalActs = {}
normalActs[ai_base.CheckfollowMaster] = 90
normalActs[ai_fortitude.CheckAggro] = 50
normalActs[ai_base.BuffMember] = 32
normalActs[ai_base.HealMember] = 30
normalActs[ai_base.RegenManaMember] = 29
normalActs[ai_base.ControlEnemy] = 27
normalActs[ai_base.AbilityDmgEnemy] = 20
normalActs[ai_base.Attack] = 10
normalActs[ai_base.Roam] = 1

function ai_fortitude:CheckState()
	if self.hp_state ~= hp_state.normal then
		self.hp_state = hp_state.normal

		self:SetActsToList(normalActs)
	end

	if self.unit:GetManaPercent() < 25 and self.mana_state ~= mana_state.low then
		self.mana_state = mana_state.low

		local acts = {}
		acts[self.ControlEnemy] = -1
		acts[self.AbilityDmgEnemy] = -1
		acts[self.HealMember] = -1
		acts[self.BuffMember] = -1
		self:SetActsToList(acts)
	elseif self.unit:GetManaPercent() >= 25 and self.mana_state ~= mana_state.normal then
		self.mana_state = mana_state.normal

		if self.hp_state == hp_state.normal then
			self:SetActsToList(normalActs)
		end
	end
end

return ai_fortitude