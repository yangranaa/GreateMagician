modifier_ranshao = class({})

--------------------------------------------------------------------------------

function modifier_ranshao:IsHidden()
	return false
end

function modifier_ranshao:IsDebuff()
	return true
end

function modifier_ranshao:RemoveOnDeath()
	return true
end

function modifier_ranshao:GetTexture()
	return "warlock_rain_of_chaos.png"
end

function modifier_ranshao:GetEffectName()
	return "particles/ranshaodebuff.vpcf"
end

function modifier_ranshao:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ranshao:OnCreated(kv)
	if IsServer() then
		self:StartIntervalThink(1)
		self:SetStackCount(kv.stackCount)
	end
end

function modifier_ranshao:OnIntervalThink()
	if IsServer() then
		if not IsValidEntity(self:GetCaster()) then
			self:Destroy()
		end
		local selfUnit = self:GetParent()
		local damageArgs = {}
		damageArgs.damageElements = "fire"
		damageArgs.baseDamage = selfUnit:GetHealth() * 0.01 * self:GetStackCount()
		damageArgs.caster = self:GetCaster()
		damageArgs.target = selfUnit
		ability_apply_damage(damageArgs)
	end
end

function modifier_ranshao:OnRefresh(kv)
	if IsServer() then
		self:SetStackCount(self:GetStackCount() + kv.stackCount)
	end
end

function modifier_ranshao:OnDestroy()
	if IsServer() then

	end
end