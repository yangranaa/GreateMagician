modifier_zidanshijian = class({})
--------------------------------------------------------------------------------

function modifier_zidanshijian:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_zidanshijian:RemoveOnDeath()
	return true
end

--------------------------------------------------------------------------------

function modifier_zidanshijian:IsHidden()
	return false
end

function modifier_zidanshijian:OnCreated( kv )
	if IsServer() then
		self.spActive = false
	end
end

function modifier_zidanshijian:GetEffectName()
	return "particles/zidanshijian.vpcf"
end

function modifier_zidanshijian:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_zidanshijian:OnRefresh()
	
end

function modifier_zidanshijian:OnIntervalThink()
   	if IsServer() then
   		
	end
end

function modifier_zidanshijian:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function modifier_zidanshijian:OnTakeDamage(kv)
	if not self.spActive then
		if kv.unit == self:GetParent() then
			kv.unit:SetHealth(kv.unit:GetHealth() + kv.damage)
			self:Active()
		end	
	end
end

function modifier_zidanshijian:Active()
	self.spActive = true
	self:SetStackCount(1)
	self:SetDuration(3, true)
end

function modifier_zidanshijian:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount() * 50
end

function modifier_zidanshijian:CheckState()
	if IsServer() then
		if self:GetParent() ~= nil then
			local state = {
				[MODIFIER_STATE_INVULNERABLE] = not self.spActive
			}

			return state
		end
	end
	local state = {}

	return state
end


function modifier_zidanshijian:OnDestroy()
	if IsServer() then

	end
end
