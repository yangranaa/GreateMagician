modifier_yijiechuansuo = class({})
--------------------------------------------------------------------------------

function modifier_yijiechuansuo:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_yijiechuansuo:RemoveOnDeath()
	return true
end

--------------------------------------------------------------------------------

function modifier_yijiechuansuo:IsHidden()
	return true
end

function modifier_yijiechuansuo:OnCreated( kv )
	if IsServer() then
		self:SetStackCount(kv.stackCount)
		local buffArgs = {}
    	buffArgs.modifierName = "invisible"
    	buffArgs.target = self:GetParent()
    	buffArgs.caster = self:GetParent()
    	self.mdf = abilities_buff_target_buff(buffArgs)
	end
end

function modifier_yijiechuansuo:GetEffectName()
	return "particles/generic_gameplay/rune_invisibility.vpcf"
end

function modifier_yijiechuansuo:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_yijiechuansuo:OnRefresh(kv)
	if IsServer() then
		self:SetStackCount(kv.stackCount)
	end
end

function modifier_yijiechuansuo:CheckState()
	if IsServer() then
		if self:GetParent() ~= nil then
			local state = {
				[MODIFIER_STATE_INVISIBLE] = true,
			}

			return state
		end
	end
	local state = {}

	return state
end

function modifier_yijiechuansuo:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}

	return funcs
end

function modifier_yijiechuansuo:GetModifierMoveSpeedBonus_Constant()
	return -150 + self:GetStackCount() * 40
end

function modifier_yijiechuansuo:OnAbilityExecuted(kv)
	if kv.unit == self:GetParent() then
		self:Destroy()
	end
end

function modifier_yijiechuansuo:OnDestroy()
	if IsServer() then
		if self.mdf then
			self:GetParent():RemoveModifierByName("modifier_invisible")
		end
	end
end
