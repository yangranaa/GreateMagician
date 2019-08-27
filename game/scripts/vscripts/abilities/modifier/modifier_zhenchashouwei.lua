modifier_zhenchashouwei = class({})
--------------------------------------------------------------------------------

function modifier_zhenchashouwei:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_zhenchashouwei:RemoveOnDeath()
	return true
end

--------------------------------------------------------------------------------

function modifier_zhenchashouwei:IsHidden()
	return true
end

function modifier_zhenchashouwei:OnCreated( kv )
	if IsServer() then
		self.bonusVision = GetAdditionValue("fire|water|vapour|natural|thunder|ground", self:GetParent(), 200)
		self:SetStackCount(self.bonusVision)
	end
end

function modifier_zhenchashouwei:OnRefresh(kv)
	if IsServer() then

	end
end

function modifier_zhenchashouwei:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
	}

	return funcs
end

function modifier_zhenchashouwei:GetBonusDayVision()
	return self:GetStackCount()
end

function modifier_zhenchashouwei:GetBonusNightVision()
	return self:GetStackCount()
end

function modifier_zhenchashouwei:OnDestroy()
	if IsServer() then

	end
end
