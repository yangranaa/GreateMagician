modifier_huaxing = class({})

--------------------------------------------------------------------------------

function modifier_huaxing:IsHidden()
	return false
end

function modifier_huaxing:IsDebuff()
	return false
end

function modifier_huaxing:RemoveOnDeath()
	return true
end

--------------------------------------------------------------------------------

function modifier_huaxing:IsStunDebuff()
	return false
end

function modifier_huaxing:GetEffectName()
	return "particles/huaxing.vpcf"
end

function modifier_huaxing:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_huaxing:OnCreated(kv)
	if IsServer() then
		if self:GetParent().costomAttribute then
			self:GetParent().costomAttribute.inHuaxing = true

			self:GetParent():EmitSound("Hero_Wisp.Spirits.Loop")
		end
	end
end

function modifier_huaxing:OnRefresh(kv)
	if IsServer() then
		
	end
end

function modifier_huaxing:CheckState()
	if IsServer() then
		if self:GetParent() ~= nil then
			local state = {

			}

			return state
		end
	end
	local state = {}

	return state
end

function modifier_huaxing:OnDestroy()
	if IsServer() then
		if self:GetParent().costomAttribute then
			self:GetParent().costomAttribute.inHuaxing = false
			self:GetParent():StopSound("Hero_Wisp.Spirits.Loop")
		end
	end
end