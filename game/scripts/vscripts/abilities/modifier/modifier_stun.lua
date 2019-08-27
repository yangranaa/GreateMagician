modifier_stun = class({})

--------------------------------------------------------------------------------

function modifier_stun:IsHidden()
	return false
end

function modifier_stun:IsDebuff()
	return true
end

function modifier_stun:RemoveOnDeath()
	return true
end

--------------------------------------------------------------------------------

function modifier_stun:IsStunDebuff()
	return true
end

function modifier_stun:GetEffectName()
	return "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_stunned.vpcf"
end

function modifier_stun:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_stun:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_stun:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end

function modifier_stun:OnCreated(kv)
	if IsServer() then

	end
end

function modifier_stun:OnRefresh(kv)
	if IsServer() then
		
	end
end

function modifier_stun:CheckState()
	if IsServer() then
		if self:GetParent() ~= nil then
			local state = {
				[MODIFIER_STATE_STUNNED] = true,
			}

			return state
		end
	end
	local state = {}

	return state
end

function modifier_stun:OnDestroy()
	if IsServer() then

	end
end