modifier_shengminglvdong = class({})

--------------------------------------------------------------------------------

function modifier_shengminglvdong:IsHidden()
	return false
end

function modifier_shengminglvdong:IsDebuff()
	return false
end

function modifier_shengminglvdong:RemoveOnDeath()
	return true
end

function modifier_shengminglvdong:GetEffectName()
	return "particles/world_tower/tower_upgrade/ti7_radiant_tower_lvl11_orb.vpcf"
end

function modifier_shengminglvdong:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_shengminglvdong:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
	}

	return funcs
end

function modifier_shengminglvdong:GetOverrideAnimation( params )
	return ACT_DOTA_CONSTANT_LAYER
end

function modifier_shengminglvdong:GetActivityTranslationModifiers()
	return "level6"
end

function modifier_shengminglvdong:OnCreated(kv)
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_shengminglvdong:OnIntervalThink()
	if IsServer() then
		local selfUnit = self:GetParent()
		if IsValidEntity(selfUnit) and not selfUnit:IsAlive() then
			local destUnit = CreateUnitByName("tower_dest", selfUnit:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
			destUnit:ForceKill(false)
			selfUnit:RemoveSelf()
			return
		end

		local healEffArgs = {}
		healEffArgs.eff = "particles/zhiyuzhijing.vpcf"
		healEffArgs.cps = "ent,0,target,PATTACH_ABSORIGIN_FOLLOW,attach_hitloc|nm,3,1,1,natural:1"
		healEffArgs.target = selfUnit
		healEffArgs.caster = selfUnit
		healEffArgs.release = 1
		abilities_eff_CreateEff(healEffArgs)

		local targetHandleArgs = {}
		targetHandleArgs.eff = "particles/shengminglvdong_heal.vpcf"
		targetHandleArgs.cps = "ent,0,target,PATTACH_ABSORIGIN_FOLLOW,attach_hitloc"
		targetHandleArgs.release = 1
		targetHandleArgs.healValue = "natural:200"
		targetHandleArgs.caster = GetRealCaster(selfUnit)

		selfUnit:EmitSound("n_creep_ForestTrollHighPriest.Heal")

		local targetArgs = {}
		targetArgs.radius = GetAdditionValue("natural:400", selfUnit)
		targetArgs.teamTarget = DOTA_UNIT_TARGET_TEAM_FRIENDLY
		targetArgs.caster = selfUnit
		targetArgs.filter = "NoRealHero"
		local targets = FindRoundTargets(targetArgs)
		for _, target in pairs(targets) do
			targetHandleArgs.target = target
			abilities_eff_CreateEff(targetHandleArgs)
			ability_heal(targetHandleArgs)
		end
	end
end

function modifier_shengminglvdong:OnRefresh(kv)
	if IsServer() then
		
	end
end

function modifier_shengminglvdong:OnDestroy()
	if IsServer() then

	end
end