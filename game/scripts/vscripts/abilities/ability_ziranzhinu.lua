ziranzhinu = class({})
LinkLuaModifier( "modifier_ziranzhinu", "abilities/modifier/modifier_ziranzhinu", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function ziranzhinu:GetIntrinsicModifierName()
	return "modifier_ziranzhinu"
end

function ziranzhinu:OnUpgrade()
	-- local modifier = self:GetCaster():FindModifierByName("modifier_ziranzhinu")
	-- if modifier then

	-- 	modifier:ForceRefresh()
	-- end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------