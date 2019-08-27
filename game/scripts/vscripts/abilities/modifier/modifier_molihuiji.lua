modifier_molihuiji = class({})
--------------------------------------------------------------------------------

function modifier_molihuiji:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_molihuiji:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------

function modifier_molihuiji:IsHidden()
	return true
end

function modifier_molihuiji:IsPurgable()
	return false
end

function modifier_molihuiji:OnCreated( kv )
	if IsServer() then
		
	end
end

-- function modifier_molihuiji:GetEffectName()
-- 	return "particles/ziyu.vpcf"
-- end

-- function modifier_molihuiji:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end

function modifier_molihuiji:OnRefresh()
	
end

function modifier_molihuiji:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE
	}

	return funcs
end

function modifier_molihuiji:GetModifierTotalPercentageManaRegen()
	return 5
end

function modifier_molihuiji:OnDestroy()
	if IsServer() then

	end
end
