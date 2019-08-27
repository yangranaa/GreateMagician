modifier_jianrenfengbao = class({})

--------------------------------------------------------------------------------

function modifier_jianrenfengbao:IsHidden()
	return false
end

function modifier_jianrenfengbao:IsDebuff()
	return false
end

function modifier_jianrenfengbao:RemoveOnDeath()
	return true
end

function modifier_jianrenfengbao:GetEffectName()
	return "particles/jianrenfengbao.vpcf"
end

function modifier_jianrenfengbao:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_jianrenfengbao:CheckState()
    if IsServer() then
        if self:GetParent() ~= nil then
            local state = {
                [MODIFIER_STATE_MAGIC_IMMUNE] = true,
            }
            return state
        end
    end
    local state = {}

    return state
end

function modifier_jianrenfengbao:OnCreated(kv)
	if IsServer() then
		self:StartIntervalThink(0.3)
        EmitSoundOn("Hero_Juggernaut.BladeFuryStart", self:GetParent())
	end
end

function modifier_jianrenfengbao:OnIntervalThink()
   	if IsServer() then
   		local selfUnit = self:GetParent()

        local dmgArgs = {}
        dmgArgs.radius = 300
        dmgArgs.ability = self:GetAbility()
        dmgArgs.caster = selfUnit
        dmgArgs.damageElements = "atk"
        abilities_round_damage(dmgArgs)
	end
end

function modifier_jianrenfengbao:OnRefresh(kv)
	if IsServer() then
		
	end
end

function modifier_jianrenfengbao:OnDestroy()
	if IsServer() then
        StopSoundOn("Hero_Juggernaut.BladeFuryStart", self:GetParent())
	end
end