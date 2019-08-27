longjuanfeng = class({})
LinkLuaModifier( "modifier_longjuanfeng", "abilities/modifier/modifier_longjuanfeng", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function longjuanfeng:GetIntrinsicModifierName()
	return "modifier_longjuanfeng"
end

function longjuanfeng:OnUpgrade()
	-- local modifier = self:GetCaster():FindModifierByName("modifier_longjuanfeng")
	-- if modifier then

	-- 	modifier:ForceRefresh()
	-- end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------