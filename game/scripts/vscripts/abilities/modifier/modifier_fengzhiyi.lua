modifier_fengzhiyi = class({})
--------------------------------------------------------------------------------

function modifier_fengzhiyi:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_fengzhiyi:RemoveOnDeath()
	return true
end

--------------------------------------------------------------------------------

function modifier_fengzhiyi:IsHidden()
	return false
end

function modifier_fengzhiyi:OnCreated( kv )
	if IsServer() then
		self:SetStackCount(kv.stackCount)
		local unit = self:GetParent()
		unit.costomAttribute.resistance["vapour"] = unit.costomAttribute.resistance["vapour"] + kv.stackCount

		local forceArgs = {}
		forceArgs.caster = self:GetParent()
		forceArgs.forceToVec = "up,600"
		self.forceName = add_force(forceArgs)

		local effArgs = {}
   		effArgs.eff = "particles/heichibang.vpcf"
   		effArgs.cps = "ent,0,target,PATTACH_POINT_FOLLOW,attach_hitloc|ent,1,target,PATTACH_ABSORIGIN_FOLLOW,attach_hitloc"
   		effArgs.target = unit
     	effArgs.caster = unit
   		self.effIdx = abilities_eff_CreateEff(effArgs)
	end
end

function modifier_fengzhiyi:OnRefresh(kv)
	if IsServer() then
		local unit = self:GetParent()
		unit.costomAttribute.resistance["vapour"] = unit.costomAttribute.resistance["vapour"] + kv.stackCount - self:GetStackCount()
		self:SetStackCount(kv.stackCount)
	end
end

function modifier_fengzhiyi:OnDestroy()
	if IsServer() then
		local unit = self:GetParent()
		unit.costomAttribute.resistance["vapour"] = unit.costomAttribute.resistance["vapour"] - self:GetStackCount()
		
		if self.forceName then
			self:GetParent().costomAttribute:RemoveForce(self.forceName)
			self.forceName = nil
		end

		if self.effIdx then
			ParticleManager:DestroyParticle(self.effIdx, false)
			ParticleManager:ReleaseParticleIndex(self.effIdx)
		end
	end
end
