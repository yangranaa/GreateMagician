local ai_test = my_class("ai_test", ai_base)

local hp_state = {normal = 1}

function ai_test:ctor(unit)
	unit.ai = self
	self.super.ctor(self, unit)

	self.hp_state = nil
	self.count = 0
end

function ai_test:CheckAggro()

end

function ai_test:test()
	self.count = self.count + 1
	if self.count % 5 ~= 0 then return end
	if not self.unit:HasAbility("fanshebingjing") then
		self.ability = self.unit:AddAbility("fanshebingjing")
   		self.ability:SetLevel(1)
	end
	if self.ability:IsFullyCastable() then
		self.unit:CastAbilityOnPosition(self.unit:GetAbsOrigin() + self.unit:GetForwardVector(), self.ability, -1)
	end
end

local normalActs = {}
normalActs[ai_test.test] = 100

function ai_test:CheckState()
	if self.hp_state ~= hp_state.normal then
		self.hp_state = hp_state.normal

		self:SetActsToList(normalActs)
	end
end

return ai_test