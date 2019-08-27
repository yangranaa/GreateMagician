modifier_yinnibufa = class({})
--------------------------------------------------------------------------------

function modifier_yinnibufa:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_yinnibufa:RemoveOnDeath()
	return true
end

--------------------------------------------------------------------------------

function modifier_yinnibufa:IsHidden()
	return true
end

function modifier_yinnibufa:OnCreated( kv )
	if IsServer() then
		self:SetStackCount(kv.stackCount)
		local buffArgs = {}
    	buffArgs.modifierName = "invisible"
    	buffArgs.target = self:GetParent()
    	buffArgs.caster = self:GetParent()
    	self.mdf = abilities_buff_target_buff(buffArgs)
	end
end

function modifier_yinnibufa:GetEffectName()
	return "particles/generic_gameplay/rune_invisibility.vpcf"
end

function modifier_yinnibufa:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_yinnibufa:OnRefresh(kv)
	if IsServer() then
		self:SetStackCount(kv.stackCount)
	end
end

function modifier_yinnibufa:CheckState()
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

function modifier_yinnibufa:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACKED,
	}

	return funcs
end

function modifier_yinnibufa:GetModifierTotalDamageOutgoing_Percentage()
	return 100
end

function modifier_yinnibufa:OnAttacked(kv)
	if kv.attacker == self:GetParent() then
		local effArgs = {}
		effArgs.eff = "particles/pengxue.vpcf"
		effArgs.cps = "ent,0,target,PATTACH_POINT_FOLLOW,attach_hitloc"
		effArgs.target = kv.target
		effArgs.release = 1
		abilities_eff_CreateEff(effArgs)
		self:Destroy()
	end
end

function modifier_yinnibufa:OnDestroy()
	if IsServer() then
		if self.mdf then
			self:GetParent():RemoveModifierByName("modifier_invisible")
		end
	end
end
