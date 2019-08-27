modifier_playact = class({})

--------------------------------------------------------------------------------

function modifier_playact:IsHidden()
	return true
end

function modifier_playact:IsDebuff()
	return false
end

function modifier_playact:RemoveOnDeath()
	return true
end

function modifier_playact:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE
	}

	return funcs
end

function modifier_playact:GetOverrideAnimationRate()
	return self.aniRate
end

function modifier_playact:GetOverrideAnimation( params )
	return self.actId
end

local tsMap = {
	"",
	"test"
}

function modifier_playact:GetActivityTranslationModifiers()
	return tsMap[self.tsModifers]
end

function modifier_playact:OnCreated(kv)
	if IsServer() then
		self:SetStackCount(kv.stackCount)
	end
	local stackCount = self:GetStackCount()
	if stackCount > 0 then
		self.actId = math.floor(stackCount / 10000)
		stackCount = stackCount - self.actId * 10000
		self.tsModifers = math.floor(stackCount / 100)
		self.aniRate = stackCount / 10
	end
end

function modifier_playact:OnRefresh(kv)
	if IsServer() then
		self:SetStackCount(kv.stackCount)
	end
	local stackCount = self:GetStackCount()
	if stackCount > 0 then
		self.actId = math.floor(stackCount / 10000)
		stackCount = stackCount - self.actId * 10000
		self.tsModifers = math.floor(stackCount / 100)
		stackCount = stackCount - self.tsModifers * 100
		self.aniRate = stackCount / 10
	end
end

function modifier_playact:OnDestroy()
	if IsServer() then

	end
end