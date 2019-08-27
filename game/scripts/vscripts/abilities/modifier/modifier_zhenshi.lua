modifier_zhenshi = class({})

--------------------------------------------------------------------------------

function modifier_zhenshi:IsHidden()
	return true
end

function modifier_zhenshi:RemoveOnDeath()
	return true
end

function modifier_zhenshi:IsAura()
	return true
end

function modifier_zhenshi:GetModifierAura()
	return "modifier_truesight"
end

function modifier_zhenshi:GetEffectName()
	return "particles/zhenshi.vpcf"
end

function modifier_zhenshi:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

--------------------------------------------------------------------------------

function modifier_zhenshi:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

--------------------------------------------------------------------------------

function modifier_zhenshi:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_zhenshi:GetAuraRadius()
	return self.radius
end

function modifier_zhenshi:OnCreated(kv)
	if IsServer() then
		self.radius = GetAdditionValue("ground:400", self:GetCaster())
	end
end

function modifier_zhenshi:OnRefresh(kv)
	if IsServer() then

	end
end

function modifier_zhenshi:OnDestroy()
	if IsServer() then

	end
end