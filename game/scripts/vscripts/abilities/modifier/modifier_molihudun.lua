modifier_molihudun = class({})

--------------------------------------------------------------------------------

function modifier_molihudun:IsHidden()
	return false
end

function modifier_molihudun:IsDebuff()
	return false
end

function modifier_molihudun:RemoveOnDeath()
	return true
end

function modifier_molihudun:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK
	}

	return funcs
end

function modifier_molihudun:GetModifierTotal_ConstantBlock()
	return self.contentBlock
end

function modifier_molihudun:OnTakeDamage(kv)
	if IsServer() then
		if kv.unit == self:GetParent() then
			if self:GetStackCount() - kv.original_damage <= 0 then
				self:Destroy()
			else
				self:SetStackCount(self:GetStackCount() - kv.original_damage)
			end
		end
	end
end

function modifier_molihudun:OnCreated(kv)
	if IsServer() then
		self:SetStackCount(kv.stackCount)
		local effArgs = {}
		effArgs.eff = "particles/momian.vpcf"
		effArgs.cps = "ent,0,target,PATTACH_POINT_FOLLOW,attach_hitloc|nm,1,90,90,0"
		effArgs.caster = self:GetParent()
		effArgs.target = self:GetParent()
		self.effIdx = abilities_eff_CreateEff(effArgs)
	end
	self.contentBlock = self:GetStackCount()
end

function modifier_molihudun:OnRefresh(kv)
	if IsServer() then
		self:SetStackCount(kv.stackCount)
	end
	self.contentBlock = self:GetStackCount()
end

function modifier_molihudun:OnDestroy()
	if IsServer() then
		if self.effIdx then
			ParticleManager:DestroyParticle(self.effIdx, false)
			ParticleManager:ReleaseParticleIndex(self.effIdx)
		end
	end
end