modifier_yinli = class({})

--------------------------------------------------------------------------------

function modifier_yinli:IsHidden()
	return true
end

function modifier_yinli:RemoveOnDeath()
	return true
end

function modifier_yinli:IsAura()
	if self.isOwner then
		return true
	end
	
	return false
end

function modifier_yinli:GetModifierAura()
	return "modifier_yinli"
end

--------------------------------------------------------------------------------

function modifier_yinli:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

--------------------------------------------------------------------------------

function modifier_yinli:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end


function modifier_yinli:GetAuraRadius()
	return self.radius
end


function modifier_yinli:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}

	return funcs
end

function modifier_yinli:GetModifierMoveSpeedBonus_Constant()
	if not self.isOwner then
		return -150
	end
	return 0
end

function modifier_yinli:OnCreated(kv)
	if IsServer() then
		self.isOwner = kv.isProvidedByAura ~= 1
		if self.isOwner then
			if IsValidEntity(self:GetCaster().yinliUnit) and self:GetCaster().yinliUnit ~= self:GetParent() then
				self:GetCaster().yinliUnit:RemoveModifierByName("modifier_yinli")
			end
			self:GetCaster().yinliUnit = self:GetParent()
			self.radius = GetAdditionValue("ground:400", self:GetCaster())
			local effArgs = {}
			effArgs.eff = "particles/chaozhonglichang.vpcf"
			effArgs.cps = "ent,0,target,PATTACH_ABSORIGIN_FOLLOW,attach_hitloc|nm,1,ground:400,1,1"
			effArgs.caster = self:GetCaster()
			effArgs.target = self:GetParent()
			self.effIdx = abilities_eff_CreateEff(effArgs)
			self:StartIntervalThink(1)
			self.duration = kv.duration
			self:GetParent():EmitSound("Hero_Juggernaut.HealingWard.Loop")
		else
			if self:GetParent().costomAttribute then
				local forceArgs = {}
				forceArgs.caster = self:GetParent()
				forceArgs.forceUnit = self:GetCaster().yinliUnit
				forceArgs.forceToUnit = "forceUnit,100000,150"
				self.forceName = add_force(forceArgs)
			end
			--DebugDrawCircle(self:GetCaster():GetAbsOrigin(), Vector(0, 0, 255), 1, 480, false, 10)
		end
	else

	end
end

function modifier_yinli:OnRefresh(kv)
	if IsServer() then
		if self.isOwner then
			self.radius = GetAdditionValue("ground:400", self:GetCaster())
		end
	end
end

function modifier_yinli:OnIntervalThink(kv)	
   	if IsServer() then
   		self.duration = self.duration - 1
   		if self.duration <= 0 then
   			self:Destroy()
   		end
	end
end

function modifier_yinli:OnDestroy()
	if IsServer() then
		if self.forceName then
			self:GetParent().costomAttribute:RemoveForce(self.forceName)
			self.forceName = nil
		end

		if self.effIdx then
			ParticleManager:DestroyParticle(self.effIdx, false)
			ParticleManager:ReleaseParticleIndex(self.effIdx)
			self:GetParent():StopSound("Hero_Juggernaut.HealingWard.Loop")
		end
	end
end