modifier_xiashendongjie = class({})
--------------------------------------------------------------------------------

function modifier_xiashendongjie:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_xiashendongjie:RemoveOnDeath()
	return true
end

--------------------------------------------------------------------------------

function modifier_xiashendongjie:IsHidden()
	return false
end

function modifier_xiashendongjie:OnCreated( kv )
	if IsServer() then
		
	end
end

function modifier_xiashendongjie:GetEffectName()
	return "particles/bingjinzita.vpcf"
end

function modifier_xiashendongjie:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_xiashendongjie:OnRefresh()
	
end

function modifier_xiashendongjie:DeclareFunctions()
	local funcs = {
	}

	return funcs
end

function modifier_xiashendongjie:CheckState()
	if IsServer() then
		if self:GetParent() ~= nil then
			local state = {
				[MODIFIER_STATE_ROOTED] = true
			}

			return state
		end
	end
	local state = {}

	return state
end


function modifier_xiashendongjie:OnDestroy()
	if IsServer() then

	end
end
