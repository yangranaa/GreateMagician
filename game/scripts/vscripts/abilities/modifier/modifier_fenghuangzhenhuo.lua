modifier_fenghuangzhenhuo = class({})

--------------------------------------------------------------------------------

function modifier_fenghuangzhenhuo:IsHidden()
	return false
end

function modifier_fenghuangzhenhuo:IsDebuff()
	return false
end

function modifier_fenghuangzhenhuo:RemoveOnDeath()
	return true
end

function modifier_fenghuangzhenhuo:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end

function modifier_fenghuangzhenhuo:OnAttackLanded(kv)
	if kv.attacker ~= self:GetParent() then
		return
	end

	local debuffArgs = {}
	debuffArgs.modifierName = "ranshao"
	debuffArgs.duration = 5
	debuffArgs.target = kv.target
	debuffArgs.stackCount = "fire:1"
	debuffArgs.caster = self:GetParent()
	abilities_buff_target_buff(debuffArgs)
end

function modifier_fenghuangzhenhuo:OnCreated(kv)
	if IsServer() then

	end
end

function modifier_fenghuangzhenhuo:OnRefresh(kv)
	if IsServer() then

	end
end

function modifier_fenghuangzhenhuo:OnDestroy()
	if IsServer() then

	end
end