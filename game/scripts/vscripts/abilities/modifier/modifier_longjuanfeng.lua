modifier_longjuanfeng = class({})

--------------------------------------------------------------------------------

function modifier_longjuanfeng:IsHidden()
	return true
end

function modifier_longjuanfeng:RemoveOnDeath()
	return true
end

function modifier_longjuanfeng:IsAura()
	if self:GetCaster() == self:GetParent() then
		return true
	end
	
	return false
end

function modifier_longjuanfeng:GetModifierAura()
	return "modifier_longjuanfeng"
end

--------------------------------------------------------------------------------

function modifier_longjuanfeng:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

--------------------------------------------------------------------------------

function modifier_longjuanfeng:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_longjuanfeng:GetAuraRadius()
	return self.radius
end


function modifier_longjuanfeng:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}

	return funcs
end

function modifier_longjuanfeng:GetModifierMoveSpeedBonus_Constant()
	return -150
end

function modifier_longjuanfeng:OnCreated(kv)
	if IsServer() then
		if self:GetParent() == self:GetCaster() then
			self.radius = GetAdditionValue("vapour:400", self:GetCaster())
		else
			if self:GetParent().costomAttribute then
				local forceArgs = {}
				forceArgs.caster = self:GetParent()
				forceArgs.forceUnit = self:GetCaster()
				forceArgs.forceToUnit = "forceUnit,100000,250"
				self.forceName = add_force(forceArgs)
			end

			self:StartIntervalThink(0.06)
			--DebugDrawCircle(self:GetCaster():GetAbsOrigin(), Vector(0, 0, 255), 1, 480, false, 10)
		end
	else

	end
end

function modifier_longjuanfeng:OnRefresh(kv)
	if IsServer() then
		if self:GetParent() == self:GetCaster() then
			self.radius = GetAdditionValue("vapour:400", self:GetCaster())
		end
	end
end

function modifier_longjuanfeng:OnIntervalThink(kv)	
   	if IsServer() then
   		local unit = self:GetParent()
   		if unit.costomAttribute and (unit.costomAttribute.unitType == COSTOM_UNIT_TYPE.PLAYER or unit.costomAttribute.unitType == COSTOM_UNIT_TYPE.NORMALUNIT)
   				and not unit:HasModifier("modifier_phy_motion") then
   			
   			local vec = self:GetCaster():GetAbsOrigin() - unit:GetAbsOrigin()
   			unit:SetAbsOrigin(unit:GetAbsOrigin() + vec:Normalized() * 5)
   		end
	end
end

function modifier_longjuanfeng:OnDestroy()
	if IsServer() then
		if self.forceName then
			self:GetParent().costomAttribute:RemoveForce(self.forceName)
			self.forceName = nil
		end
	end
end