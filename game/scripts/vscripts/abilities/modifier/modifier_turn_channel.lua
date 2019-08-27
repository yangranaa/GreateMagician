modifier_turn_channel = class({})
--------------------------------------------------------------------------------

function modifier_turn_channel:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_turn_channel:RemoveOnDeath()
	return true
end

--------------------------------------------------------------------------------

function modifier_turn_channel:IsHidden()
	return true
end

function modifier_turn_channel:OnCreated( kv )
	if IsServer() then
		self:StartIntervalThink(0.03)
	end
end

function modifier_turn_channel:OnRefresh()
	
end

function modifier_turn_channel:OnIntervalThink()
   	if IsServer() then
   		--if self.TargetAngle then
   			local unit = self:GetParent()
	   		local angle = unit:GetAngles()
	   		if self.lastAngle then
	   			if angle.y > self.lastAngle.y then
		   			angle.y = self.lastAngle.y + 0.4
		   		else
		   			angle.y = self.lastAngle.y - 0.4
		   		end
	   		end

	   		unit:SetAngles(angle.x, angle.y, angle.z)
   			self.lastAngle = angle
   		--end
	end
end

function modifier_turn_channel:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
	}

	return funcs
end

function modifier_turn_channel:OnOrder(kv)
	if IsServer() then	
		-- local unit = self:GetParent()
		-- local vec = kv.new_pos - unit:GetAbsOrigin()
		-- vec.z = 0
		-- self.TargetAngle = Vector_Angle(vec, Vector(1, 0, 0))
		if kv.order_type == 33 then
			self:Destroy()
		end
	end
end

function modifier_turn_channel:CheckState()
	if IsServer() then
		if self:GetParent() ~= nil then
			local state = {
				[MODIFIER_STATE_ROOTED] = true,
			}

			return state
		end
	end
	local state = {}

	return state
end


function modifier_turn_channel:OnDestroy()
	if IsServer() then

	end
end
