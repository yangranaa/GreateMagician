modifier_ziranzhinu = class({})

--------------------------------------------------------------------------------

function modifier_ziranzhinu:IsHidden()
	return false
end

function modifier_ziranzhinu:IsDebuff()
	return false
end

function modifier_ziranzhinu:RemoveOnDeath()
	return true
end

function modifier_ziranzhinu:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}

	return funcs
end

function modifier_ziranzhinu:OnTakeDamage(kv)
	if IsServer() then
		if kv.unit == self:GetParent() then
			if RandomFloat(0, 1500) < kv.damage then
				local target = GetRealCaster(kv.attacker)
				local effArgs = {}
				effArgs.eff = "particles/chanrao.vpcf"
				effArgs.cps = "ent,0,target,PATTACH_ABSORIGIN_FOLLOW,attach_hitloc"
				effArgs.target = target 
				effArgs.release = 1
				abilities_eff_CreateEff(effArgs)


				local damageArgs = {}
				damageArgs.ability = self:GetAbility()
				damageArgs.damageElements = "natural"
				damageArgs.target = target
				damageArgs.modifierNames = "xiashendongjie"
				damageArgs.xiashendongjie_duration = "natural:1.5"
				damageArgs.caster = kv.unit
				GenAbilityArgs(damageArgs)

				ability_apply_damage(damageArgs)
			end
		end
	end
end

function modifier_ziranzhinu:OnCreated(kv)
	if IsServer() then

	end
end

function modifier_ziranzhinu:OnRefresh(kv)
	if IsServer() then

	end
end

function modifier_ziranzhinu:OnDestroy()
	if IsServer() then

	end
end