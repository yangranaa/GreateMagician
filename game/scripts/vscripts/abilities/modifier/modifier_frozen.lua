modifier_frozen = class({})

--------------------------------------------------------------------------------

function modifier_frozen:IsHidden()
	return false
end

function modifier_frozen:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_frozen:IsStunDebuff()
	return true
end

function modifier_frozen:GetEffectName()
	return "particles/bingdong.vpcf"
end

function modifier_frozen:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_frozen:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_frozen:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end

function modifier_frozen:OnCreated(kv)
	if IsServer() then

	end
end

function modifier_frozen:OnRefresh(kv)
	if IsServer() then
		
	end
end

function modifier_frozen:CheckState()
	if IsServer() then
		if self:GetParent() ~= nil then
			local state = {
				[MODIFIER_STATE_FROZEN] = true,
				[MODIFIER_STATE_STUNNED] = true,
			}

			return state
		end
	end
	local state = {}

	return state
end

function modifier_frozen:OnDestroy()
	if IsServer() then

	end
end