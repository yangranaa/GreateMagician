MAX_COLLIDER_RADIUS = 500

if my_physics == nil then
	my_physics = {}
end

local COLLDER_HIT_MAP = {}
COLLDER_HIT_MAP[COSTOM_UNIT_TYPE.REFLECT] = {}
COLLDER_HIT_MAP[COSTOM_UNIT_TYPE.REFLECT][COSTOM_UNIT_TYPE.EXPLODE] = true
COLLDER_HIT_MAP[COSTOM_UNIT_TYPE.PLAYER] = {}
COLLDER_HIT_MAP[COSTOM_UNIT_TYPE.PLAYER][COSTOM_UNIT_TYPE.EXPLODE] = true
COLLDER_HIT_MAP[COSTOM_UNIT_TYPE.PLAYER][COSTOM_UNIT_TYPE.NORMALUNIT] = true
COLLDER_HIT_MAP[COSTOM_UNIT_TYPE.EXPLODE] = {}
COLLDER_HIT_MAP[COSTOM_UNIT_TYPE.EXPLODE][COSTOM_UNIT_TYPE.NORMALUNIT] = true
COLLDER_HIT_MAP[COSTOM_UNIT_TYPE.EXPLODE][COSTOM_UNIT_TYPE.EXPLODE] = true
COLLDER_HIT_MAP[COSTOM_UNIT_TYPE.EXPLODE][COSTOM_UNIT_TYPE.UNREAL] = true
COLLDER_HIT_MAP[COSTOM_UNIT_TYPE.ROAMELEMENT] = {}
COLLDER_HIT_MAP[COSTOM_UNIT_TYPE.ROAMELEMENT][COSTOM_UNIT_TYPE.PLAYER] = true

function my_physics:start()
	if self.thinkEnt == nil then
		self.frameCount = 0
		self.colliders = {}
		self.hitQueue = {}

		self.thinkEnt = Entities:CreateByClassname("info_target")
		self.thinkEnt:SetThink("Think", self, "my_physics", 0.01)
	end
end

function my_physics:Think()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_POST_GAME then
		return
	end

	self.frameCount = self.frameCount + 1

	local now = GameRules:GetGameTime()
	local checkMap = {}
	
	for unit, collider in pairs(my_physics.colliders) do
		if self:CheckColliderValid(unit) then
			local attribute = unit.costomAttribute
			if attribute.skipFrame <= 0 then				
				local ents = Entities:FindAllInSphere(unit:GetAbsOrigin(), (attribute.radius or attribute.width) + MAX_COLLIDER_RADIUS)
				local newInTab = {}
				for idx, ent in pairs(ents) do
					checkMap[unit] = checkMap[unit] or {}
					checkMap[ent] = checkMap[ent] or {}

					if self:CheckColliderValid(ent) and self:CheckCanHit(unit, ent) then
						if checkMap[unit][ent] then
							newInTab[ent] = checkMap[unit][ent]
						else
							if self:CheckColliderHit(unit, ent) then
								newInTab[ent] = true
							end
							checkMap[unit][ent] = newInTab[ent]
							checkMap[ent][unit] = newInTab[ent]
						end
					end
				end
				
				for ent, _ in pairs(collider.inColliders) do
					-- 从碰撞体中脱离
					if self:CheckColliderValid(ent) and not newInTab[ent] then
						self:OnColliderOut(ent, unit)
					end
				end

				for ent, _ in pairs(newInTab) do
					-- 新进入碰撞体
					if collider.inColliders[ent] == nil then
						local hitValue = ent.costomAttribute.velocity:Dot(unit:GetAbsOrigin()) + unit.costomAttribute.velocity:Dot(ent:GetAbsOrigin())
						hitValue = hitValue == 0 and 9999999 or hitValue
						self.colliders[ent].inColliders[unit] = hitValue
						self.colliders[unit].inColliders[ent] = hitValue
						local hitData = {}
						hitData.hitValue = hitValue
						hitData.unit1 = unit
						hitData.unit2 = ent
						table.insert(self.hitQueue, hitData)
					end
				end
			else
				attribute.skipFrame = attribute.skipFrame - 1
			end
		end
	end

	self:HandleHitQueue()

	return 0.01
end

function my_physics:HandleHitQueue()
	------同一时间可能多个碰撞 碰撞事件处理
	table.sort(self.hitQueue, function(a,b) return a.hitValue > b.hitValue end)
	local handleUnits = {}
	for i=#self.hitQueue, 1, -1 do
		local hitData = self.hitQueue[i]
		if IsValidEntity(hitData.unit1) and IsValidEntity(hitData.unit2) and self.colliders[hitData.unit1].inColliders[hitData.unit2] then
			if not handleUnits[hitData.unit1] and not handleUnits[hitData.unit2] then
				self:OnColliderHit(hitData.unit1, hitData.unit2)
				handleUnits[hitData.unit1] = 1
				handleUnits[hitData.unit2] = 1
				table.remove(self.hitQueue, i)
			end
		else
			table.remove(self.hitQueue, i)
		end
	end

end

function my_physics:AddCollider(unit)
	if unit.costomAttribute == nil then
		print("wrong unit......", unit, unit:GetUnitName())
		return
	end

	self.colliders[unit] = {}

	if unit.costomAttribute.isPlane then
		self.colliders[unit] = {isPlane = 1, unit = unit, inColliders = {}}
	else
		self.colliders[unit] = {unit = unit, inColliders = {}}	
	end
end

function my_physics:RemoveCollider(unit)
	if self.colliders[unit] then
		for ent, _ in pairs(self.colliders[unit].inColliders) do
			self:OnColliderOut(unit, ent)
		end
		self.colliders[unit] = nil
	end
end

function my_physics:CheckColliderValid(unit)
	if IsValidEntity(unit) and self.colliders[unit] and unit:IsAlive() then
		return true
	else
		if not IsValidEntity(unit) then
			self:RemoveCollider(unit)
		end
		return false
	end
end

function my_physics:CheckCanHit(collider1, collider2)
	if collider1 == collider2 then return false end

	if collider1.costomAttribute.skipFrame ~= 0 or collider2.costomAttribute.skipFrame ~= 0 then
		return false
	end

	local unitType1 = collider1.costomAttribute.unitType
	local unitType2 = collider2.costomAttribute.unitType

	return (COLLDER_HIT_MAP[unitType1] and COLLDER_HIT_MAP[unitType1][unitType2]) or (COLLDER_HIT_MAP[unitType2] and COLLDER_HIT_MAP[unitType2][unitType1])
end

function my_physics:CheckColliderHightCanHit(collider1, collider2)
	local c1Attr = collider1.unit.costomAttribute
	local c2Attr = collider2.unit.costomAttribute
	local c1Pos = collider1.unit:GetAbsOrigin()
	local c2Pos = collider2.unit:GetAbsOrigin()

	if c1Pos.z > c2Pos.z + c2Attr.hight or c2Pos.z > c1Pos.z + c1Attr.hight then
		return false
	end
	return true
end

function my_physics:CheckCylinderHitPlane(cylinder, plane)
	if not self:CheckColliderHightCanHit(cylinder, plane) then
		return false
	end

	local pNor = plane.unit:GetForwardVector()
	local pPos = plane.unit:GetAbsOrigin()
	local spPos = cylinder.unit:GetAbsOrigin()
	local spDp = spPos.x * pNor.x + spPos.y * pNor.y - pPos.x * pNor.x - pPos.y * pNor.y
	local radius = cylinder.unit.costomAttribute.radius
	local width = plane.unit.costomAttribute.width
	local pToSp = spPos - pPos
	local sqSpDp = spDp * spDp

	-- if Debug then
	-- 	DebugDrawBoxDirection(cylinder.unit:GetAbsOrigin(), Vector(-radius,-radius,0), Vector(radius,radius,cylinder.unit.costomAttribute.hight), cylinder.unit:GetForwardVector(), Vector(255, 0, 0), 128, 2)
	-- end

	-- if Debug then
	-- 	DebugDrawBoxDirection(plane.unit:GetAbsOrigin(), Vector(-1,-plane.unit.costomAttribute.width,0), Vector(1,plane.unit.costomAttribute.width,plane.unit.costomAttribute.hight), plane.unit:GetForwardVector(), Vector(255, 0, 0), 128, 2)
	-- end
	
	if sqSpDp <= radius * radius and pToSp.x * pToSp.x + pToSp.y * pToSp.y <= width * width + sqSpDp then
		return true
	end
	return false
end

function my_physics:CheckCylinderHitCylinder(cylinder1, cylinder2)
	if not self:CheckColliderHightCanHit(cylinder1, cylinder2) then
		return false
	end

	local c2Toc1 = cylinder1.unit:GetAbsOrigin() - cylinder2.unit:GetAbsOrigin()
	local disSq = c2Toc1.x * c2Toc1.x + c2Toc1.y * c2Toc1.y
	local radiusCount = cylinder1.unit.costomAttribute.radius + cylinder2.unit.costomAttribute.radius
	
	-- if Debug then
	--  	DebugDrawCircle(cylinder1.unit:GetAbsOrigin(), Vector(255, 0, 0), 5, cylinder1.unit.costomAttribute.radius, true, 0.1)
	-- end
	
	if disSq <= radiusCount * radiusCount then
		return true
	end
	return false
end

function my_physics:CheckRayHitPlane(origin, dir, length, plane)
	local hitResult = {hit = false}
	local pPos = plane.unit:GetAbsOrigin()
	if origin.z > pPos.z + plane.unit.costomAttribute.hight or origin.z < pPos.z then
		return hitResult
	end

	if Debug then
		DebugDrawBoxDirection(plane.unit:GetAbsOrigin(), Vector(-1,-plane.unit.costomAttribute.width,0), Vector(1,plane.unit.costomAttribute.width,plane.unit.costomAttribute.hight), plane.unit:GetForwardVector(), Vector(255, 0, 0), 128, 2)
	end

	local pNor = plane.unit:GetForwardVector()
	local pNorDotDir = (pNor:Dot(dir))
	if pNorDotDir < 0 then
		local t = (pNor:Dot(pPos) -  pNor:Dot(origin)) / pNorDotDir
		local hitPos = origin + t * dir
		local vHitToP = pPos - hitPos
		local width = plane.unit.costomAttribute.width

		if t <= length and (vHitToP.x * vHitToP.x + vHitToP.y *vHitToP.y) <= width * width then
			hitResult.hitPos = hitPos
			hitResult.t = t
			hitResult.hit = true
			hitResult.unit = plane.unit
			hitResult.normal = pNor
		end
	end
	
	return hitResult
end

function my_physics:CheckRayHitCylinder(origin, dir, length, cylinder)
	local hitResult = {hit = false}
	local cPos = cylinder.unit:GetAbsOrigin()

	if origin.z > cPos.z + cylinder.unit.costomAttribute.hight or origin.z < cPos.z then
		return hitResult
	end

	if Debug then
	 	DebugDrawBoxDirection(cylinder.unit:GetAbsOrigin(), Vector(-cylinder.unit.costomAttribute.radius,-cylinder.unit.costomAttribute.radius,0), Vector(cylinder.unit.costomAttribute.radius,cylinder.unit.costomAttribute.radius,cylinder.unit.costomAttribute.hight), cylinder.unit:GetForwardVector(), Vector(255, 0, 0), 128, 2)
	end

	local D = origin - cPos
	D.z = 0
	local B = D:Dot(dir)
	local R = cylinder.unit.costomAttribute.radius
	local DD = D:Dot(D)
	local RR = R * R
	local discr = B * B + RR - DD
	if RR >= DD then
		hitResult.hitPos = origin
		hitResult.t = 0
		hitResult.hit = true
		hitResult.unit = cylinder.unit
		hitResult.normal = origin - cPos
		hitResult.normal.z = 0
		hitResult.normal = hitResult.normal:Normalized()
	else
		if B < 0 and discr >= 0 then
			local t = - B - math.sqrt(discr)
			t = t < 0 and 0 or t		
			if t <= length then
				hitResult.hit = true
				hitResult.t = t
				hitResult.hitPos = origin + t * dir
				hitResult.unit = cylinder.unit
				hitResult.normal = hitResult.hitPos - cPos
				hitResult.normal.z = 0
				hitResult.normal = hitResult.normal:Normalized()
			end
		end
	end
	return hitResult
end

function my_physics:CheckColliderHit(unit1, unit2)
	if self.colliders[unit1] == nil or self.colliders[unit2] == nil then return false end

	local unitPos1 = unit1:GetAbsOrigin()
	local unitPos2 = unit2:GetAbsOrigin()

	if self.colliders[unit1].isPlane then
		if not self.colliders[unit2].isPlane then
			return self:CheckCylinderHitPlane(self.colliders[unit2], self.colliders[unit1])
		end
	else
		if self.colliders[unit2].isPlane then
			return self:CheckCylinderHitPlane(self.colliders[unit1], self.colliders[unit2])
		else
			return self:CheckCylinderHitCylinder(self.colliders[unit1], self.colliders[unit2])
		end
	end

	return false
end

function my_physics:RayTest(origin, dir, length, colliderTypes)
	local hitResult = {hit = false}
	colliderTypes = colliderTypes or {[COSTOM_UNIT_TYPE.REFLECT] = true, [COSTOM_UNIT_TYPE.PLAYER] = true, [COSTOM_UNIT_TYPE.EXPLODE] = true, [COSTOM_UNIT_TYPE.NORMALUNIT] = true}
	for unit, collider in pairs(self.colliders) do
		if colliderTypes[unit.costomAttribute.unitType] and self:CheckColliderValid(unit) then
			if collider.isPlane then
				local hitPlane = self:CheckRayHitPlane(origin, dir, length, collider) 
				if hitResult.hit == false or (hitPlane.t and hitPlane.t < hitResult.t) then
					hitResult = hitPlane
				end
			else
				local hitCylinder = self:CheckRayHitCylinder(origin, dir, length, collider)
				if hitResult.hit == false or (hitCylinder.t and hitCylinder.t < hitResult.t) then
					hitResult = hitCylinder
				end
			end
		end
	end

	if Debug then
		if hitResult.hitPos then
			DebugDrawLine(origin, hitResult.hitPos, 255, 0, 0, true, 2)
			DebugDrawLine(hitResult.hitPos, hitResult.hitPos + hitResult.normal * 100, 0, 255, 0, true, 2)
			local refVec = Vector_Reflect(hitResult.hitPos - origin, hitResult.normal)
			DebugDrawLine(hitResult.hitPos, hitResult.hitPos + refVec, 0, 0, 255, true, 2)
		else
			DebugDrawLine(origin, origin + dir * length, 255, 0, 0, true, 2)
		end
	end

	return hitResult
end

if not my_physics.colliders then my_physics:start() end

function my_physics:OnHitGround(unit)
	--if Debug then print("hitGround", unit, unit:GetUnitName()) end
	Timers:CreateTimer(0.06, function()
		if my_physics:CheckColliderValid(unit) and unit.costomAttribute.unitType > 0 then
			unit.costomAttribute:OnPhyHit()
		end
	end)
end

function my_physics:OnHitWall(unit)
	--if Debug then print("hitWall", unit, unit:GetUnitName()) end
	
	local status, err = pcall(function ()
		if unit.costomAttribute.unitType > 0 then
			unit.costomAttribute:OnPhyHit()
		end
	end)
	if not status then
		Warning(err)
	end
end

function my_physics:OnColliderOut(unit1, unit2)
	if self.colliders[unit1] then
		self.colliders[unit1].inColliders[unit2] = nil
	end

	if self.colliders[unit2] then
		self.colliders[unit2].inColliders[unit1] = nil
	end
end

function my_physics:OnColliderHit(unit1, unit2)
	--print("in,", unit1:GetUnitName(), unit1:GetAbsOrigin(), unit2:GetUnitName(), unit2:GetAbsOrigin())

	local status, err = pcall(function ()
		unit1.costomAttribute:OnPhyHit(unit2)
		if IsValidEntity(unit2) and unit2:IsAlive() then
			unit2.costomAttribute:OnPhyHit(unit1)
		end
	end)
	if not status then
		Warning(err)
	end
end