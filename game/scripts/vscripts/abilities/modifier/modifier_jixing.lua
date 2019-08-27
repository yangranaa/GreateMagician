modifier_jixing = class({})
--------------------------------------------------------------------------------

function modifier_jixing:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_jixing:RemoveOnDeath()
	return true
end

--------------------------------------------------------------------------------

function modifier_jixing:IsHidden()
	return false
end

function modifier_jixing:OnCreated( kv )
	if IsServer() then
		self:SetStackCount(kv.stackCount)
	end
end

function modifier_jixing:GetStatusEffectName()
	return "particles/jixing.vpcf"
end


function modifier_jixing:OnRefresh(kv)
	if IsServer() then
		self:SetStackCount(kv.stackCount)
	end
end

function modifier_jixing:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_jixing:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount()
end

function modifier_jixing:OnDestroy()
	if IsServer() then

	end
end
