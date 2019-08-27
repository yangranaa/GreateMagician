modifier_roudanzhanche = class({})

--------------------------------------------------------------------------------

function modifier_roudanzhanche:IsHidden()
	return false
end

function modifier_roudanzhanche:IsDebuff()
	return false
end

function modifier_roudanzhanche:RemoveOnDeath()
	return true
end

--------------------------------------------------------------------------------

function modifier_roudanzhanche:IsStunDebuff()
	return false
end

function modifier_roudanzhanche:GetEffectName()
	return "particles/roudanzhanche.vpcf"
end

function modifier_roudanzhanche:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_roudanzhanche:OnCreated(kv)
	if IsServer() then
		self:StartIntervalThink(0.1)

		self.damageArgs = {}
		self.damageArgs.radius = 200
		self.damageArgs.force = 50000
		self.damageArgs.usePM = 1
		self.damageArgs.damageElements = "speed:0.5"
		self.damageArgs.chDir = "c2t"
		self.damageArgs.changeVelocity = 1
		self.damageArgs.modifierNames = "stun"
		self.damageArgs.stun_duration = "1"
		self.damageArgs.caster = self:GetParent()
		self.damageArgs.ability = self:GetAbility()

		EmitSoundOn("Hero_EarthSpirit.RollingBoulder.Loop", self:GetParent())
	end

	self.startTime = GameRules:GetGameTime()
end

function modifier_roudanzhanche:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_MAX,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
	}

	return funcs
end

function modifier_roudanzhanche:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end

function modifier_roudanzhanche:GetModifierMoveSpeed_Limit( params )
    return 1000
end

function modifier_roudanzhanche:GetModifierMoveSpeed_Max()
	return 1000
end

function modifier_roudanzhanche:GetModifierMoveSpeed_Absolute()
	return self:GetParent():GetBaseMoveSpeed() + (GameRules:GetGameTime() - self.startTime) * 100
end

function modifier_roudanzhanche:OnIntervalThink()
	if IsServer() then
		local targets = abilities_round_damage(self.damageArgs)
		if #targets > 0 then
			self:Destroy()
		end
	end
end

function modifier_roudanzhanche:OnRefresh(kv)
	if IsServer() then
		
	end
end

function modifier_roudanzhanche:OnDestroy()
	if IsServer() then
		StopSoundOn("Hero_EarthSpirit.RollingBoulder.Loop", self:GetParent())
	end
end