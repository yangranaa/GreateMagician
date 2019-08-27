_G.CostomAttribute = my_class("CostomAttribute")

function CostomAttribute.ctor(self, args)
	self.unit = args.costomUnit
	self.args = args
	self.unit.costomAttribute = self

	self:ParseArgs(args)

	if args.unit_eff then
		self:CreateFollowEff(args)
	end
	
	self:UpdateCostom(args)

	if args.unit_duration then
        self:CreateTimer(args)
    end

	if self.unitType ~= COSTOM_UNIT_TYPE.GROUND then
		my_physics:AddCollider(self.unit)
	end
end

function CostomAttribute:ParseArgs(args)
	self.unitType = COSTOM_UNIT_TYPE[args.unit_phyType]
	self.isPlane = args.unit_isPlane
	self.width = args.unit_width and GetAdditionValue(args.unit_width, args.caster)
	self.hight = (args.unit_hight and GetAdditionValue(args.unit_hight, args.caster)) or args.unit_radius or self.width
	self.mass = args.unit_mass and GetAdditionValue(args.unit_mass, args.caster) or 10
	self.unBlock = args.unit_unBlock
	self.velocity = Vector(0, 0, 0)
	if args.unit_velocity then
		local velocityStrArr = string.split(args.unit_velocity, ",")
		if velocityStrArr[1] == "caster_fow" then
			self.velocity = args.caster:GetForwardVector() * GetAdditionValue(velocityStrArr[2], args.caster)
		end
	end
	self.maxSpeedAngle = args.unit_maxSpeedAngle and GetAdditionValue(args.unit_maxSpeedAngle, args.caster)
	self.maxVelocity = args.unit_maxVelocity and GetAdditionValue(args.unit_maxVelocity, args.caster)
	self.speed = GetAdditionValue(args.unit_speed, args.caster)
	self.skipFrame = GetAdditionValue(args.unit_skipFrame, args.caster)
	self.lockPos = args.unit_lockPos
	self.lockUnit = args[args.unit_lockUnit]
	self.lockDis = args.unit_lockDis and GetAdditionValue(args.unit_lockDis, args.caster)
	self.targetOffsetZ = tonumber(args.unit_targetOffsetZ)
	self.curlockAngle = args.curlockAngle
	self.lockAngleSpeed = args.unit_lockAngleSpeed and GetAdditionValue(args.unit_lockAngleSpeed, args.caster)
	self.lockOffset = args.unit_lockOffset
	self.lockZ = args.unit_lockZ
	self.noUseG = args.unit_noUseG
	self.speedToOffset = args.unit_speedToOffset
	if type(args.unit_speedToOffset) == "string" then
		local speedToOffsetStrArr = string.split(args.unit_speedToOffset, ",")
		self.speedToOffset = Vector(tonumber(speedToOffsetStrArr[1]), tonumber(speedToOffsetStrArr[2]), tonumber(speedToOffsetStrArr[3]))
	end
	
	self.startPos = args.startPos
	self.isHullRadius = args.unit_isHullRadius
	self.deadSound = args.unit_deadSound
	self.loopSound = args.unit_loopSound

	if self.loopSound then
		EmitSoundOn(self.loopSound, self.unit)
	end

	if args.unit_hitFuns then
		self.hitFuns = {}
		local funNameArr = string.split(args.unit_hitFuns, "|")
		for _,funName in pairs(funNameArr) do
			self.hitFuns[funName] = self[funName]
		end
	end

	if not self.noUseG then
		local forceArgs = {}
		forceArgs.caster = self.unit
		forceArgs.useG = 1
		add_force(forceArgs)
	end

	if args.unit_forceToUnit then
		local forceArgs = {}
		forceArgs.caster = self.unit
		forceArgs.forceToUnit = args.unit_forceToUnit
		forceArgs.target = args.target
		add_force(forceArgs)
	end

	if args.speedToUnit then
		local speedArgs = {}
		speedArgs.caster = self.unit
		speedArgs.speedToUnit = args.speedToUnit
		speedArgs.target = args.target
		set_speed_to_unit(speedArgs)
	end

	if self.lockUnit then
		self.unit:SetForwardVector(self.lockUnit:GetForwardVector())
	end
	
	if args.unit_hp then
		self.unit:SetHPGain(GetAdditionValue(args.unit_hp, args.caster))
		self.unit:CreatureLevelUp(1)
	end

	if self.unit:IsRealHero() then
    	self.abilitySlot = args.abilitySlot or 1
    end

	local coefficient = args.coefficient or (args.caster and args.caster.costomAttribute.coefficient) or {}
	if coefficient == "none" then
		coefficient = {}
	end
	for element, _ in pairs(element_menu) do
		coefficient[element] = coefficient[element] or 0
	end
	self:ChangeCoefficient(coefficient)

	self.resistance = {}
	local resistanceStrs = string.split(args.resistance or "", ",")
	for element, _ in pairs(element_menu) do
		self.resistance[element] = 0
		if resistanceStrs[1] == "all" or (resistanceStrs[1] == "except" and resistanceStrs[2] ~= element) or resistanceStrs[1] == element then
			self.resistance[element] = 100
		end
	end

	self.giveElement = args.giveElement
end

function CostomAttribute:ChangeCoefficient(coefficient)
	if not self.coefficient then
		self.coefficient = {}
	end

	for element, value in pairs(coefficient) do
		self.coefficient[element] = value
	end
	
	if self.unit:IsRealHero() then
		ui_manager.UpdateLocalPlayerData(self.unit:GetPlayerOwnerID())
	end
end

function CostomAttribute:CreateTimer(args)
	if args.unit_stepExc then
        local stepStrs = string.split(args.unit_stepExc, ",")
        local phaseStrs = string.split(stepStrs[2], "|")
        self.stepTime = tonumber(stepStrs[1])
        self.phases = {}
        for _, phaseStr in pairs(phaseStrs) do
        	local phaseArr = string.split(phaseStr, "&")
        	local phase = {}
        	phase.funs = {}
        	phase.phaseTime = GetAdditionValue(phaseArr[1], args.caster)
        	phase.times = tonumber(phaseArr[3])
        	phase.argChanges = GenArgs(args, "unit_step")
        	phase.argChanges.caster = args.caster
    		phase.argChanges.excUnit = self.unit
        	local funsArr = string.split(phaseArr[2], "*")
        	for idx, funName in ipairs(funsArr) do
        		phase.funs[idx] = {}
        		phase.funs[idx].fun = _G[funName]		
        		phase.funs[idx].args = GenArgs(args, funName)
        		phase.funs[idx].args.center = self.unit:GetAbsOrigin()
        	end
            table.insert(self.phases, phase)
        end

        table.sort(self.phases, function(a,b) return a.phaseTime < b.phaseTime end)
    end


	local duration = GetAdditionValue(args.unit_duration, args.caster)
    local checkUnit = self.lockUnit

    local startTime = GameRules:GetGameTime()
    Timers:CreateTimer(function()
        if (checkUnit and (not IsValidEntity(checkUnit) or not checkUnit:IsAlive()) ) or GameRules:GetGameTime() - startTime >= duration then
            self:RemoveSelf()
            return
        end
        if not IsValidEntity(self.unit) or not self.unit:IsAlive() then
        	--self:OnRemove()
        	return
        end
        if self.phases then
            local currentPhase = nil
            for _, phase in ipairs(self.phases) do
            	if GameRules:GetGameTime() - startTime <= phase.phaseTime then
            		if (not phase.times or phase.times > 0) then
            			currentPhase = phase
	            		if phase.times then
	            			phase.times = phase.times - 1
	            		end
            		end
            		
            		break
            	end
            end
            if currentPhase then
            	GenArgsChange(currentPhase.argChanges)
            	for idx, fun in ipairs(currentPhase.funs) do		
            		TableCopyToTable(currentPhase.argChanges, fun.args)
	            	fun.fun(fun.args)
	            end
            end
        end
        return self.stepTime or 0.1
    end)
end

function CostomAttribute:OnPhyHit(unit)
	if self.unitType == COSTOM_UNIT_TYPE.EXPLODE then
		if IsValidEntity(unit) then
			local modifier = unit:FindModifierByName("modifier_zidanshijian")
			if modifier and not modifier.spActive then
				modifier:Active()
				my_physics:OnColliderOut(self.unit, unit)
				unit.skipFrame = 5
				return
			end

			if unit.costomAttribute.unitType == COSTOM_UNIT_TYPE.REFLECT or unit.costomAttribute.unitType == COSTOM_UNIT_TYPE.UNREAL then
				return
			end
		end
	elseif self.unitType == COSTOM_UNIT_TYPE.PLAYER and unit and unit.costomAttribute.unitType == COSTOM_UNIT_TYPE.NORMALUNIT then
		self.velocity.x = 0
		self.velocity.y = 0
		if self.sliderData then
			self.sliderData.sliderVelocity.x = 0
			self.sliderData.sliderVelocity.y = 0
		end
	end

	for funName,fun in pairs(self.hitFuns or {}) do
		fun(self, unit)
	end
end

function CostomAttribute:Teleport(unit)
	if unit and unit.costomAttribute.unitType == COSTOM_UNIT_TYPE.EXPLODE then
		return
	end

	local tpUnit = self.args[self.args.teleport_unit]
	tpUnit:SetAbsOrigin(self.unit:GetAbsOrigin())

	self:RemoveSelf()
end

function CostomAttribute:Explode(unit)
	local damageArgs = GenArgs(self.args, "explode")
	damageArgs.caster = self.unit
	damageArgs.center = self.unit:GetAbsOrigin()
	
	local targets = abilities_round_damage(damageArgs)

	self:RemoveSelf()
end

function CostomAttribute:ReflectUnit(unit)
	local normal = self.unit:GetForwardVector()
	if not self.isPlane then
		normal = self.unit:GetAbsOrigin() - unit:GetAbsOrigin()
		normal.z = 0
		normal = normal:Normalized()
	end
	local z = -0.5 * unit.costomAttribute.velocity.z
	local vecRef = Vector_Reflect(unit.costomAttribute.velocity, normal)
	vecRef.z = z
	unit.costomAttribute.velocity = vecRef
end

function CostomAttribute:Intensify(unit)
	if not IsValidEntity(unit) or not unit.costomAttribute or unit.costomAttribute.unitType ~= COSTOM_UNIT_TYPE.EXPLODE then
		return
	end

	if unit.costomAttribute.args.channelRate then
		unit.costomAttribute.args.channelRate = unit.costomAttribute.args.channelRate * 2
		unit.costomAttribute:UpdateCostom(unit.costomAttribute.args)
	end
	unit.costomAttribute.velocity = unit.costomAttribute.velocity * 2
	unit.costomAttribute.velocity.z = 1
end

function CostomAttribute:CatchRoame(unit)
	if self.giveElement then
		if IsValidEntity(unit) then
			local coefficient = {}
			for element, value in pairs(self.giveElement) do
				coefficient[element] = unit.costomAttribute.coefficient[element] + value
			end
			unit.costomAttribute:ChangeCoefficient(coefficient)
			self:RemoveSelf()
		end
	end
end

function CostomAttribute:RemoveSelf()
	if IsValidEntity(self.unit) and self.unit:IsAlive() then
		self.unit:ForceKill(true)
		self.unit:RemoveSelf()
	end
end

function CostomAttribute:OnRemove()
	if self.followEffIdx then
		ParticleManager:DestroyParticle(self.followEffIdx, false)
		ParticleManager:ReleaseParticleIndex(self.followEffIdx)
	end
	if self.deadSound then
		self.unit:EmitSound(self.deadSound)
	end
	if self.loopSound then
		StopSoundOn(self.loopSound, self.unit)
	end

	self.lockUnit = nil
	self.velocity = Vector(0, 0, 0)
end

function CostomAttribute:CreateFollowEff(args)
	local effArgs = {}
	effArgs.eff = args.unit_eff
	effArgs.cps = args.unit_cps
	effArgs.target = self.unit
	effArgs.caster = args.caster
	effArgs.channelRate = args.channelRate
	effArgs.createAttach = args.unit_createAttach or "PATTACH_ABSORIGIN_FOLLOW"

	if args.unit_cpPoint1 then
		local cpPointStrArr = string.split(args.unit_cpPoint1, "*")
		local forw = self.unit:GetForwardVector()
		local absOrigin = self.unit:GetAbsOrigin()
		local verVec = Vector(-forw.y, forw.x, 0)
		if cpPointStrArr[1] == "left" then
			verVec = verVec * -1
		end
		effArgs.cpPoint1 = absOrigin + verVec * GetAdditionValue(cpPointStrArr[2], args.caster)
	end

	if args.unit_cpPoint2 then
		local cpPointStrArr = string.split(args.unit_cpPoint2, "*")
		local forw = self.unit:GetForwardVector()
		local absOrigin = self.unit:GetAbsOrigin()
		local verVec = Vector(-forw.y, forw.x, 0)
		if cpPointStrArr[1] == "left" then
			verVec = verVec * -1
		end
		effArgs.cpPoint2 = absOrigin + verVec * GetAdditionValue(cpPointStrArr[2], args.caster)
	end

	self.followEffIdx = abilities_eff_CreateEff(effArgs)
end

function CostomAttribute:UpdateFollowEff(args)
	if self.followEffIdx == nil then return end
	local effArgs = {}
	effArgs.eff = args.unit_eff
	effArgs.cps = args.unit_cps
	effArgs.target = self.unit
	effArgs.caster = args.caster
	effArgs.channelRate = args.channelRate
	effArgs.effIdx = self.followEffIdx

	if args.unit_cpPoint1 then
		local cpPointStrArr = string.split(args.unit_cpPoint1, "*")
		local forw = self.unit:GetForwardVector()
		local absOrigin = self.unit:GetAbsOrigin()
		local verVec = Vector(-forw.y, forw.x, 0)
		if cpPointStrArr[1] == "left" then
			verVec = verVec * -1
		end
		effArgs.cpPoint1 = absOrigin + verVec * GetAdditionValue(cpPointStrArr[2], args.caster)
	end

	if args.unit_cpPoint2 then
		local cpPointStrArr = string.split(args.unit_cpPoint2, "*")
		local forw = self.unit:GetForwardVector()
		local absOrigin = self.unit:GetAbsOrigin()
		local verVec = Vector(-forw.y, forw.x, 0)
		if cpPointStrArr[1] == "left" then
			verVec = verVec * -1
		end
		effArgs.cpPoint2 = absOrigin + verVec * GetAdditionValue(cpPointStrArr[2], args.caster)
	end

	abilities_eff_UpdateEff(effArgs)
end

function CostomAttribute:UpdateCostom(args)
	self:ChangeRadius(args.unit_radius * args.channelRate)
	self:UpdateFollowEff(args)
end

function CostomAttribute:ChangeRadius(radius)
	-- if self.isPlane then
	-- 	self.unit:SetHullRadius(1)
	-- elseif self.unitType == COSTOM_UNIT_TYPE.GROUND then
	-- 	self.unit:SetHullRadius(1)
	-- else
		
	-- end
	self.radius = tonumber(radius)
	if self.isHullRadius then
		self.unit:SetHullRadius(radius)
	end
end

function CostomAttribute:AddForce(kv)
	if self.forceList == nil then
		self.forceList = {}
	end
	local name = DoUniqueString("force")
	local force = {}
	if kv.forceToUnit then
		local forceStrArr = string.split(kv.forceToUnit, ",")
		force.toUnit = kv[forceStrArr[1]]
		force.value = GetAdditionValue(forceStrArr[2], kv.caster)
		force.offsetZ = GetAdditionValue(forceStrArr[3], kv.caster)
	elseif kv.useG then
		force.constantFoce = Vector(0, 0, -self.mass * 1000)
	elseif kv.forceToVec then
		local forceStrArr = string.split(kv.forceToVec, ",")
		if forceStrArr[1] == "up" then
			force.constantFoce = Vector(0, 0, self.mass * GetAdditionValue(forceStrArr[2], kv.caster))
		end
	end

	self.forceList[name] = force
	return name
end

function CostomAttribute:RemoveForce(name)
	self.forceList[name] = nil
end

function CostomAttribute:IsSlider()
	return self.inIceMotion or self.inHuaxing
end

function CostomAttribute:UpdateVelocity(dt)
	local selfPos = self.startPos or self.unit:GetAbsOrigin()

	if self.speedToPos or IsValidEntity(self.speedToUnit) then
		local targetPos = Vector_Copy(self.speedToPos) or self.speedToUnit:GetAbsOrigin()
		if self.speedToOffset then
			targetPos = targetPos + self.speedToOffset
		end
		local vec = targetPos - selfPos
		vec = vec:Normalized()
		if self.isHitWall then
			self.lastSpeedToVelocity = Vector(0, 0, self.speedToValue)
		elseif self.maxSpeedAngle then
			if self.lastSpeedToVelocity then
				local angleDif = RotationDelta(VectorToAngles(self.lastSpeedToVelocity:Normalized()), VectorToAngles(vec)).y
				if angleDif > 0 then
					self.lastSpeedToVelocity = RotatePosition(Vector(0,0,0), QAngle(0, math.min(self.maxSpeedAngle, angleDif), 0), self.lastSpeedToVelocity)
				else
					self.lastSpeedToVelocity = RotatePosition(Vector(0,0,0), QAngle(0, -math.min(self.maxSpeedAngle, -angleDif), 0), self.lastSpeedToVelocity)
				end
			else
				self.lastSpeedToVelocity = vec * self.speedToValue
			end
		else
			self.lastSpeedToVelocity = vec * self.speedToValue
		end
	end

	if self.forceList then
		local finnalForce = Vector(0, 0, 0)
		for forceName, force in pairs(self.forceList) do
			if force.toUnit then
				if IsValidEntity(force.toUnit) then
					local vec = force.toUnit:GetAbsOrigin()
					vec.z = vec.z + (force.offsetZ or 0)
					vec = vec - selfPos
					finnalForce = finnalForce + vec:Normalized() * force.value
				else
					self.forceList[forceName] = nil
				end
			end
			if force.constantFoce then
				finnalForce = finnalForce + force.constantFoce
			end
		end
		local addVec = (finnalForce / self.mass) * dt
		self.velocity = self.velocity + addVec
	end

	if self.maxVelocity then
		local rate = self.maxVelocity / #self.velocity
		if rate < 1 then
			self.velocity = self.velocity * rate
		end
	end

	if self:IsSlider() and self.sliderFow then
		if not self.sliderData then
			self.sliderData = {}
		end
		self.sliderData.lastSliderFow = self.sliderData.lastSliderFow or self.unit:GetForwardVector()
		self.sliderData.lastSliderFow = Vector_Lerp(self.sliderData.lastSliderFow, self.sliderFow, dt)
		self.sliderData.sliderVelocity = self.sliderData.lastSliderFow * 1000
	end
end

function set_speed_to_pos(kv)
	local target = kv.excUnit or kv.caster
	local CA = target.costomAttribute

	CA.speedToUnit = nil
	CA.speedToPos = nil
	if kv.speedToPos then
		local speedStrArr = string.split(kv.speedToPos, ",")
		if speedStrArr[1] == "randomRound" then
			CA.speedToPos = CA.unit:GetAbsOrigin() + RandomVector(RandomFloat(tonumber(speedStrArr[3]), tonumber(speedStrArr[4])))	
		elseif speedStrArr[1] == "selfFow" then
			CA.speedToPos = CA.unit:GetAbsOrigin() + CA.unit:GetForwardVector() * GetAdditionValue(speedStrArr[3], kv.caster)
			CA.speedToPos.z = CA.speedToPos.z + GetAdditionValue(speedStrArr[4], kv.caster)
		end
		CA.speedToValue = GetAdditionValue(speedStrArr[2], kv.caster)
	end
end

function set_speed_to_unit(kv)
	local target = kv.excUnit or kv.caster
	local CA = target.costomAttribute

	CA.speedToPos = nil
	if kv.speedToUnit then
		local speedStrArr = string.split(kv.speedToUnit, ",")
		local checkDis = GetAdditionValue(speedStrArr[3], kv.caster)
		if speedStrArr[1] == "casterRound" then
			if CA.speedToUnit == kv.caster or not IsValidEntity(CA.speedToUnit) or not CA.speedToUnit:IsAlive() or (checkDis ~= 0 and CA.speedToUnit:GetRangeToUnit(kv.caster) > checkDis) then
				CA.speedToUnit = nil
			end
			if not CA.speedToUnit then
				kv.center = kv.caster:GetAbsOrigin()
				local targets = FindRoundTargets(kv)
				if #targets > 0 then
					CA.speedToUnit = targets[RandomInt(1, #targets)]
				end
			end
			if CA.speedToUnit == nil then 
				CA.speedToUnit = kv.caster
				CA.speedToOffset = RandomVector(RandomFloat(-checkDis, checkDis))
			else
			 	CA.speedToOffset = nil
			end
		elseif speedStrArr[1] == "unitRound" then
			if not IsValidEntity(CA.speedToUnit) or not CA.speedToUnit:IsAlive() or (checkDis ~= 0 and CA.speedToUnit:GetRangeToUnit(CA.unit) > checkDis) then
				CA.speedToUnit = nil
			end
			if not CA.speedToUnit then
				local targets = FindRoundTargets(kv)
				if #targets > 0 then
					CA.speedToUnit = targets[RandomInt(1, #targets)]
				end
			end
		else
			CA.speedToUnit = kv[speedStrArr[1]]
		end
		
		CA.speedToValue = GetAdditionValue(speedStrArr[2], kv.caster)
	end
end

function add_force(kv)
	local target = kv.caster

	local CA = target.costomAttribute
	if CA.unitType == COSTOM_UNIT_TYPE.GROUND then
		return
	end
	return CA:AddForce(kv)
end

function change_args(kv)
	local argsStrArr = string.split(kv.changeArgs, "|")
	for _, argStr in ipairs(argsStrArr) do
		local argStrArr = string.split(argStr, "&")
		kv[argStrArr[1]] = argStrArr[2]
	end
end