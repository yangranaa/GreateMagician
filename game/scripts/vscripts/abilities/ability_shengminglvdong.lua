shengminglvdong = class({})
LinkLuaModifier( "modifier_shengminglvdong", "abilities/modifier/modifier_shengminglvdong", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function shengminglvdong:GetIntrinsicModifierName()
	return "modifier_shengminglvdong"
end

function shengminglvdong:OnUpgrade()
	-- local modifier = self:GetCaster():FindModifierByName("modifier_shengminglvdong")
	-- if modifier then

	-- 	modifier:ForceRefresh()
	-- end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------