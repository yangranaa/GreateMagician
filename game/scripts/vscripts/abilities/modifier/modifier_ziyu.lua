modifier_ziyu = class({})
--------------------------------------------------------------------------------

function modifier_ziyu:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_ziyu:RemoveOnDeath()
	return true
end

--------------------------------------------------------------------------------

function modifier_ziyu:IsHidden()
	return false
end

function modifier_ziyu:OnCreated( kv )
	if IsServer() then
		self:SetStackCount(kv.stackCount)
	end
end

function modifier_ziyu:GetEffectName()
	return "particles/ziyu.vpcf"
end

function modifier_ziyu:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ziyu:OnRefresh(kv)
	if IsServer() then
		self:SetStackCount(kv.stackCount)
	end
end

function modifier_ziyu:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
	}

	return funcs
end

function modifier_ziyu:GetModifierHealthRegenPercentage()
	return self:GetStackCount()
end

function modifier_ziyu:OnDestroy()
	if IsServer() then

	end
end
