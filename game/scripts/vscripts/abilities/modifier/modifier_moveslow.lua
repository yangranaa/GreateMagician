modifier_moveslow = class({})

--------------------------------------------------------------------------------

function modifier_moveslow:IsHidden()
	return true
end

function modifier_moveslow:IsDebuff()
	return true
end

function modifier_moveslow:RemoveOnDeath()
	return true
end

--------------------------------------------------------------------------------

function modifier_moveslow:IsStunDebuff()
	return true
end

function modifier_moveslow:GetEffectName()
	return "particles/bingdan_jiansu.vpcf"
end

function modifier_moveslow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_moveslow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_moveslow:GetModifierMoveSpeedBonus_Percentage()
	return -50
end

function modifier_moveslow:OnCreated(kv)
	if IsServer() then
	
	end
end

function modifier_moveslow:OnRefresh(kv)
	if IsServer() then
		
	end
end

function modifier_moveslow:OnDestroy()
	if IsServer() then

	end
end