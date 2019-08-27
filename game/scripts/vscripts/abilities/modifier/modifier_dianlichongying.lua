modifier_dianlichongying = class({})

--------------------------------------------------------------------------------

function modifier_dianlichongying:IsHidden()
	return false
end

function modifier_dianlichongying:IsDebuff()
	return false
end

function modifier_dianlichongying:RemoveOnDeath()
	return true
end

-- function modifier_dianlichongying:GetEffectName()
-- 	return "particles/world_tower/tower_upgrade/ti7_radiant_tower_lvl11_orb.vpcf"
-- end

-- function modifier_dianlichongying:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end

function modifier_dianlichongying:OnCreated(kv)
	if IsServer() then
		self:StartIntervalThink(5)
	end
end

function modifier_dianlichongying:OnIntervalThink()
	if IsServer() then
		local selfUnit = self:GetParent()
		if IsValidEntity(selfUnit) and not selfUnit:IsAlive() then
			return
		end

		local rangeEff = {}
		rangeEff.eff = "particles/chongdian_range.vpcf"
		rangeEff.cps = "ent,0,caster,PATTACH_POINT_FOLLOW,attach_hitloc|nm,1,thunder:800,1,1"
		rangeEff.target = selfUnit
		rangeEff.caster = selfUnit
		abilities_eff_CreateEff(rangeEff)

		local effArgs = {}
		effArgs.eff = "particles/chongdian.vpcf"
		effArgs.cps = "ent,0,caster,PATTACH_POINT_FOLLOW,attach_hitloc|ent,1,target,PATTACH_POINT_FOLLOW,attach_hitloc,ent,2,target,PATTACH_ABSORIGIN_FOLLOW,attach_hitloc"
		effArgs.caster = selfUnit
		effArgs.release = 1

		selfUnit:EmitSound("Hero_Luna.Eclipse.Cast")

		local targetArgs = {}
		targetArgs.radius = GetAdditionValue("thunder:800", selfUnit)
		targetArgs.teamTarget = DOTA_UNIT_TARGET_TEAM_FRIENDLY
		targetArgs.caster = selfUnit
		targetArgs.filter = "NoRealHero"
		targetArgs.addManaValue = "thunder:500"
		local targets = FindRoundTargets(targetArgs)
		for _, target in pairs(targets) do
			effArgs.target = target
			targetArgs.target = target
			abilities_eff_CreateEff(effArgs)
			ability_add_mana(targetArgs)
		end
	end
end

function modifier_dianlichongying:OnRefresh(kv)
	if IsServer() then
		
	end
end

function modifier_dianlichongying:OnDestroy()
	if IsServer() then

	end
end