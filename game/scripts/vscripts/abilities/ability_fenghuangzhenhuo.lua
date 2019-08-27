fenghuangzhenhuo = class({})
LinkLuaModifier( "modifier_fenghuangzhenhuo", "abilities/modifier/modifier_fenghuangzhenhuo", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function fenghuangzhenhuo:GetIntrinsicModifierName()
	return "modifier_fenghuangzhenhuo"
end

function fenghuangzhenhuo:OnUpgrade()
	-- local modifier = self:GetCaster():FindModifierByName("modifier_fenghuangzhenhuo")
	-- if modifier then

	-- 	modifier:ForceRefresh()
	-- end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------