ability_ray = my_class("ability_ray", ai_base)

function ability_ray:ctor(args)
	self.unit = args.unit
	self.args = args

	self.hight = GetAdditionValue(args.ray_hight, args.caster)
	self.length = GetAdditionValue(args.ray_length, args.caster)

	self.reflect = nil
	self.origin = nil
	self.foward = nil
	self.loopSound = args.ray_loopSound

	if self.unit == args.caster then
		self.unit:AddNewModifier(self.unit, args.ability, "modifier_turn_channel", {duration = GetAdditionValue(args.ray_duration, args.caster)})
		if self.loopSound then
			self.unit:EmitSound(self.loopSound)
		end
	end

	self.timer = Timers:CreateTimer(function()
		if not IsValidEntity(args.caster) or not args.caster:IsAlive() or args.caster:IsStunned() or not args.caster:HasModifier("modifier_turn_channel") then
            self:OnRemove()
            return
        end

		self:CheckHitPoint()
		if not self.RayEffIdx then
			self:CreateRayEff(args)
		else
			self:UpdateFollowEff(args)
		end
		if self.hitResult.unit and self.hitResult.unit.costomAttribute.unitType == COSTOM_UNIT_TYPE.REFLECT then
			if self.reflect and self.hitResult.unit ~= self.reflect.unit then
				self.reflect:OnRemove()
				self.reflect = nil
			end
			if self.reflect == nil then
				self:CreateRelect(self.hitResult)
			end
			self.reflect.starPos = self.hitResult.hitPos + self.hitResult.normal
			self.reflect.foward = Vector_Reflect(self.hitResult.hitPos - self.starPos, self.hitResult.normal):Normalized()
		else
			if self.reflect then
				self.reflect:OnRemove()
				self.reflect = nil
			end

			if self.hitResult.unit then
				for _,funName in ipairs(string.split(args.ray_funs, "|")) do
			        self[funName](self)
			    end
			end
		end

		return 0.05
	end)
end

function ability_ray:RayHeal()
	local healArgs = GenArgs(self.args, "rayHeal")
	healArgs.caster = self.args.caster
	healArgs.target = self.hitResult.unit

	ability_heal(healArgs)
end

function ability_ray:RayDamageTarget()
	local damageArgs = GenArgs(self.args, "rayDamage")
	damageArgs.caster = self.args.caster
	damageArgs.target = self.hitResult.unit

	ability_apply_damage(damageArgs)
end

function ability_ray:CreateRelect(hitResult)
	self.reflect = ability_ray.new(self.args)
	self.reflect.unit = hitResult.unit
	self.reflect.origin = self
end

function ability_ray:OnRemove()
	Timers:RemoveTimer(self.timer)

	if self.RayEffIdx then
		ParticleManager:DestroyParticle(self.RayEffIdx, false)
		ParticleManager:ReleaseParticleIndex(self.RayEffIdx)
	end

	if self.reflect then
		self.reflect:OnRemove()
	end

	if IsValidEntity(self.unit) and self.unit == self.args.caster then
		self.unit:RemoveModifierByName("modifier_turn_channel")

		if self.loopSound then
			self.unit:StopSound(self.loopSound)
		end
	end
end

function ability_ray:CheckHitPoint()
	if self.origin == nil then
		self.starPos = self.unit:GetAbsOrigin() + self.unit:GetForwardVector() * self.unit.costomAttribute.radius * 1.2
		self.starPos.z = self.starPos.z + self.hight
	    self.hitResult = my_physics:RayTest(self.starPos, self.unit:GetForwardVector(), self.length)
	    self.targetPoint = self.hitResult.hitPos or self.starPos + self.unit:GetForwardVector() * self.length
	else
		self.hitResult = my_physics:RayTest(self.starPos, self.foward, self.length)
		self.targetPoint = self.hitResult.hitPos or self.starPos + self.foward * self.length
	end
end

function ability_ray:CreateRayEff(args)
	local effArgs = {}
	effArgs.eff = args.ray_eff
	effArgs.cps = args.ray_cps
	effArgs.caster = self.unit
	effArgs.effPoint0 = self.starPos
	effArgs.effPoint1 = self.targetPoint
	effArgs.createAttach = "PATTACH_WORLDORIGIN"

	self.RayEffIdx = abilities_eff_CreateEff(effArgs)
end

function ability_ray:UpdateFollowEff(args)
	if self.RayEffIdx == nil then return end
	local effArgs = {}
	effArgs.eff = args.ray_eff
	effArgs.cps = args.ray_cps
	effArgs.caster = self.unit
	effArgs.effPoint0 = self.starPos
	effArgs.effPoint1 = self.targetPoint
	effArgs.effIdx = self.RayEffIdx

	abilities_eff_UpdateEff(effArgs)
end

return ability_ray