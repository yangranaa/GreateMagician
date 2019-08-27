modifier_shijianjiasu = class({})
--------------------------------------------------------------------------------

function modifier_shijianjiasu:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_shijianjiasu:RemoveOnDeath()
	return true
end

--------------------------------------------------------------------------------

function modifier_shijianjiasu:IsHidden()
	return false
end

function modifier_shijianjiasu:OnCreated( kv )
	if IsServer() then
		self:SetStackCount(kv.stackCount)
	end
	self.curManaRegen = self:GetParent():GetManaRegen()
end

function modifier_shijianjiasu:GetEffectName()
	return "particles/shijianjiasu.vpcf"
end

function modifier_shijianjiasu:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_shijianjiasu:OnRefresh(kv)
	if IsServer() then
		self:SetStackCount(kv.stackCount)
	end
end

function modifier_shijianjiasu:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING,
	}

	return funcs
end

function modifier_shijianjiasu:GetModifierConstantManaRegen()
	if self.curManaRegen then
		return self.curManaRegen * (1 + self:GetStackCount() * 0.01)
	end
end

function modifier_shijianjiasu:GetModifierHealthRegenPercentage()
	return self:GetStackCount() * 0.1
end

function modifier_shijianjiasu:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount()
end

function modifier_shijianjiasu:GetModifierPercentageCooldownStacking()
	return self:GetStackCount()
end

function modifier_shijianjiasu:OnDestroy()
	if IsServer() then

	end
end
