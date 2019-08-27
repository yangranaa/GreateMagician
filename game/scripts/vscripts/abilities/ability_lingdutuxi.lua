lingdutuxi = class({})
LinkLuaModifier( "modifier_lingdutuxi", "abilities/modifier/modifier_lingdutuxi", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function lingdutuxi:GetIntrinsicModifierName()
	return "modifier_lingdutuxi"
end

function lingdutuxi:OnUpgrade()
	-- local modifier = self:GetCaster():FindModifierByName("modifier_lingdutuxi")
	-- if modifier then

	-- 	modifier:ForceRefresh()
	-- end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------