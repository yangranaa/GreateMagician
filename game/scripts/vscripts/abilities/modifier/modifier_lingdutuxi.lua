modifier_lingdutuxi = class({})

--------------------------------------------------------------------------------

function modifier_lingdutuxi:IsHidden()
	return false
end

function modifier_lingdutuxi:IsDebuff()
	return false
end

function modifier_lingdutuxi:RemoveOnDeath()
	return true
end

function modifier_lingdutuxi:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end

function modifier_lingdutuxi:OnAttackLanded(kv)
	if kv.attacker ~= self:GetParent() then
		return
	end

	local debuffArgs = {}
	debuffArgs.modifierName = "moveslow"
	debuffArgs.duration = 0.5
	debuffArgs.target = kv.target
	abilities_buff_target_buff(debuffArgs)

	if RandomFloat(0, 1) <= 0.3 then
		debuffArgs.modifierName = "frozen"
		debuffArgs.duration = 1
		abilities_buff_target_buff(debuffArgs)
	end
end

function modifier_lingdutuxi:OnCreated(kv)
	if IsServer() then

	end
end

function modifier_lingdutuxi:OnRefresh(kv)
	if IsServer() then

	end
end

function modifier_lingdutuxi:OnDestroy()
	if IsServer() then

	end
end