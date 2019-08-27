modifier_preview_model = class({})

--------------------------------------------------------------------------------

function modifier_preview_model:IsHidden()
	return false
end

function modifier_preview_model:IsDebuff()
	return false
end

function modifier_preview_model:RemoveOnDeath()
	return false
end


function modifier_preview_model:OnCreated(kv)
	if IsServer() then
		local unit = self:GetParent()

		for i=1, unit:GetAbilityCount() - 1 do
			local ability = unit:GetAbilityByIndex(i)
			if ability then
				unit:RemoveAbility(ability:GetAbilityName())
			end
		end

		for k, modifier in pairs(unit:FindAllModifiers()) do
			if modifier ~= self then
				unit:RemoveModifierByName(modifier:GetName())
			end
        end

		if self:ApplyVerticalMotionController() == false then 
			self:Destroy()
		end
	end
end

function modifier_preview_model:CheckState()
	if IsServer() then
		if self:GetParent() ~= nil then
			local state = {
				[MODIFIER_STATE_INVISIBLE] = false,
				[MODIFIER_STATE_MAGIC_IMMUNE] = true,
				[MODIFIER_STATE_ATTACK_IMMUNE] = true,
				[MODIFIER_STATE_DISARMED] = true,
				[MODIFIER_STATE_UNSELECTABLE] = true,
				[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
				[MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true,
				[MODIFIER_STATE_NO_HEALTH_BAR] = true,
				[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
				[MODIFIER_STATE_OUT_OF_GAME] = true,	
			}

			return state
		end
	end
	local state = {}

	return state
end

function modifier_preview_model:UpdateVerticalMotion( me, dt )
	if IsServer() then
		local unit = self:GetParent()
		unit:SetAbsOrigin(Vector(0, 0, -500))
	end
end

function modifier_preview_model:OnRefresh(kv)
	if IsServer() then
		
	end
end

function modifier_preview_model:OnDestroy()
	if IsServer() then

	end
end