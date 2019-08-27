modifier_phy_motion = class({})
--------------------------------------------------------------------------------

function modifier_phy_motion:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_phy_motion:IsStunDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_phy_motion:RemoveOnDeath()
	return true
end

--------------------------------------------------------------------------------

function modifier_phy_motion:IsHidden()
	return true
end

-- vmotion duration,speed,state,useg,autoend
-- hmotion duration,speed,state,keepVec,allowH

function modifier_phy_motion:OnCreated( kv )
	if IsServer() then
		if self:GetParent().costomAttribute == nil then
			self:Destroy()
			return
		end

		if self:ApplyHorizontalMotionController() == false then 
			self:Destroy()
		end

		if self:ApplyVerticalMotionController() == false then 
			self:Destroy()
		end

		self.hitFrame = {}
	end
end

function modifier_phy_motion:OnRefresh(kv)
	if IsServer() then
		
	end
end


--------------------------------------------------------------------------------

function modifier_phy_motion:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_EVENT_ON_ORDER,
	}

	return funcs
end

--------------------------------------------------------------------------------
function modifier_phy_motion:OnOrder(kv)
	if IsServer() then
		if kv.order_type == 1 then
			local unit = self:GetParent()
			if unit.costomAttribute and unit.costomAttribute:IsSlider() then
				local vec = kv.new_pos - unit:GetAbsOrigin()
				vec.z = 0
				unit.costomAttribute.sliderFow = vec:Normalized()
			end
		end
	end
end

--------------------------------------------------------------------------------

function modifier_phy_motion:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end

--------------------------------------------------------------------------------

function modifier_phy_motion:CheckState()
	if IsServer() then

	end
	local state = {}

	return state
end

--------------------------------------------------------------------------------

function modifier_phy_motion:UpdateHorizontalMotion( me, dt )
	if IsServer() then
		local unit = self:GetParent()
		if unit.costomAttribute.lockPos then
			unit:SetOrigin(unit.costomAttribute.lockPos)
			return
		end
		if IsValidEntity(unit.costomAttribute.lockUnit) and unit.costomAttribute.lockUnit:IsAlive() then
			local lockAbsOri = unit.costomAttribute.lockUnit:GetAbsOrigin()
			lockAbsOri.z = lockAbsOri.z + (unit.costomAttribute.targetOffsetZ or 0)
			if unit.costomAttribute.lockOffset then
				unit:SetOrigin(lockAbsOri + unit.costomAttribute.lockOffset)
			end
			if unit.costomAttribute.lockAngleSpeed then
				local rotPos = lockAbsOri + Vector(unit.costomAttribute.lockDis, 0, 0)
				unit.costomAttribute.curlockAngle = unit.costomAttribute.curlockAngle + dt * unit.costomAttribute.lockAngleSpeed
				unit:SetOrigin(RotatePosition(lockAbsOri, QAngle(0, unit.costomAttribute.curlockAngle, 0), rotPos))
			end
			return
		else
			unit.costomAttribute.lockUnit = nil
		end

		self:UpdateUnitVelocity(dt)

		local velocity = unit.costomAttribute.velocity
		local oldOrigin = unit:GetAbsOrigin()
		local hVec = Vector(velocity.x, velocity.y, 0)
		if unit.costomAttribute:IsSlider() and unit.costomAttribute.sliderData then
			hVec = hVec + unit.costomAttribute.sliderData.sliderVelocity
		end

		if unit.costomAttribute.lastSpeedToVelocity then
			hVec = hVec + unit.costomAttribute.lastSpeedToVelocity
		end

		local newOrigin = oldOrigin + hVec * dt
		if unit.costomAttribute.unBlock then
			unit:SetOrigin(newOrigin)
		else
			local checkH = unit.costomAttribute:IsSlider() and 40 or 20
			local fowHight = GetGroundHeight(newOrigin + hVec:Normalized() * 75, nil)
			fowHight = fowHight < -512 and 9999 or fowHight
			if fowHight > oldOrigin.z + checkH then
				velocity.x = 0
				velocity.y = 0
				if unit.costomAttribute.sliderData then
					unit.costomAttribute.sliderData.sliderVelocity.x = 0
					unit.costomAttribute.sliderData.sliderVelocity.y = 0
				end
				unit.costomAttribute.isHitWall = true
				my_physics:OnHitWall(unit)
				return
			else
				unit.costomAttribute.isHitWall = false
				unit:SetOrigin(newOrigin)
			end
		end
	end
end

function modifier_phy_motion:UpdateUnitVelocity(dt)
	local curTime = GameRules:GetGameTime()
	if not self.lastUpVTime or self.lastUpVTime ~= curTime then
		local unit = self:GetParent()
		unit.costomAttribute:UpdateVelocity(dt)
	end
	
	self.lastUpVTime = curTime
end

--------------------------------------------------------------------------------
function modifier_phy_motion:OnHorizontalMotionInterrupted()
	print("hhhhhhhh")
	self:Destroy()
end

--------------------------------------------------------------------------------

function modifier_phy_motion:UpdateVerticalMotion( me, dt )
	if IsServer() then
		local unit = self:GetParent()
		local oldOrigin = unit:GetAbsOrigin()
		if unit.costomAttribute.lockPos then
			unit:SetOrigin(unit.costomAttribute.lockPos)
			return
		end
		if IsValidEntity(unit.costomAttribute.lockUnit) and unit.costomAttribute.lockUnit:IsAlive() then
			local lockAbsOri = unit.costomAttribute.lockUnit:GetAbsOrigin()
			lockAbsOri.z = lockAbsOri.z + (unit.costomAttribute.targetOffsetZ or 0)
			if unit.costomAttribute.lockOffset then
				unit:SetOrigin(lockAbsOri + unit.costomAttribute.lockOffset)
			end
			if unit.costomAttribute.lockAngleSpeed then
				local rotPos = lockAbsOri + Vector(unit.costomAttribute.lockDis, 0, 0)
				unit.costomAttribute.curlockAngle = unit.costomAttribute.curlockAngle + dt * unit.costomAttribute.lockAngleSpeed
				unit:SetOrigin(RotatePosition(lockAbsOri, QAngle(0, unit.costomAttribute.curlockAngle, 0), rotPos))
			end
			return
		else
			unit.costomAttribute.lockUnit = nil
		end

		if unit.costomAttribute.lockZ then
			unit:SetAbsOrigin(Vector(0, 0, unit.costomAttribute.lockZ))
			return
		end
		if unit.costomAttribute.startPos then
			unit:SetAbsOrigin(unit.costomAttribute.startPos)
			unit.costomAttribute.startPos = nil
			return
		end

		self:UpdateUnitVelocity(dt)
		
		local velocity = unit.costomAttribute.velocity

		local groundHeight = GetGroundHeight(oldOrigin, nil)
		if groundHeight == 127 and not GridNav:IsTraversable(oldOrigin) then
			groundHeight = -500
		end
		
		if groundHeight >= oldOrigin.z and velocity.z < 0 then
			velocity.z = 0
		end

		local newOrigin = Vector(oldOrigin.x, oldOrigin.y, oldOrigin.z)
		newOrigin = newOrigin + velocity.z * dt

		if unit.costomAttribute.lastSpeedToVelocity then
			newOrigin = newOrigin + unit.costomAttribute.lastSpeedToVelocity.z * dt
		end

		if unit.costomAttribute.unBlock then
			newOrigin.z = math.max(groundHeight, newOrigin.z)
			unit:SetAbsOrigin(newOrigin)
		else
			if velocity.z <= 0 and groundHeight >= newOrigin.z and 
				not unit.costomAttribute:IsSlider() and not unit.costomAttribute.speedToUnit and not unit.costomAttribute.speedToPos then
				newOrigin.z = groundHeight
				unit:SetAbsOrigin(newOrigin)
				my_physics:OnHitGround(unit)
				self:Destroy()
				--DebugDrawCircle(newOrigin, Vector(0, 0, 255), 1, 50, false, 10)
			else
				--DebugDrawCircle(newOrigin, Vector(0, 255, 255), 1, 40, false, 10)
				unit:SetAbsOrigin(newOrigin)	
			end
		end

		if newOrigin.z > groundHeight + 50 and unit:IsRealHero() then
			self:SetFlyViewer(newOrigin)
		else
			self:RemoveFlyViewer()
		end

		if newOrigin.z < -256 then
			self:GetParent():ForceKill(false)
		end
	end
end

function modifier_phy_motion:SetFlyViewer(pos)
	if self.flyViewer == nil then
		self.flyViewer = CreateUnitByName("fly_viewer", pos, false, nil, nil, self:GetParent():GetTeamNumber())
	else
		self.flyViewer:SetAbsOrigin(pos)
	end
end

function modifier_phy_motion:RemoveFlyViewer()
	if self.flyViewer then
		self.flyViewer:RemoveSelf()
		self.flyViewer = nil
	end
end

--------------------------------------------------------------------------------
function modifier_phy_motion:OnVerticalMotionInterrupted()
	print("vvvvvvvvvvvvvv")
end

function modifier_phy_motion:OnDestroy()
	if IsServer() then
		local unit = self:GetParent()
		unit:RemoveHorizontalMotionController(self)
		unit:RemoveVerticalMotionController(self)

		if unit.costomAttribute then
			unit.costomAttribute.velocity = Vector(0, 0, 0)
			unit.costomAttribute.lastSpeedToVelocity = Vector(0, 0, 0)
			unit.costomAttribute.sliderData = nil
		end

		self:RemoveFlyViewer()
	end
end


