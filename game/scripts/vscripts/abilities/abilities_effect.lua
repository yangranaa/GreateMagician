function abilities_eff_CreateEff(keys)
	local owner = keys.target
	local createAttach = PATTACH_ABSORIGIN_FOLLOW -- PATTACH_OVERHEAD_FOLLOW PATTACH_POINT_FOLLOW
	if keys.Target == "CASTER" then
		owner = keys.caster
	end

	if keys.Target == "POINT" then
		owner = keys.caster
		createAttach = PATTACH_WORLDORIGIN
	end

	if keys.createAttach then
		createAttach = _G[keys.createAttach]
	end

	local nFXIndex = ParticleManager:CreateParticle(keys.eff, createAttach, owner)
	keys.fxIndex = nFXIndex

	abilities_eff_SetCps(keys)
	
	if keys.release == 1 then
		ParticleManager:ReleaseParticleIndex(nFXIndex)
	else
		if keys.autoDel then
			local autoDelStr = string.split(keys.autoDel, ",")
			Timers:CreateTimer(GetAdditionValue(autoDelStr[1], keys.caster), function()
				ParticleManager:DestroyParticle(nFXIndex, false)
				ParticleManager:ReleaseParticleIndex(nFXIndex)
				return
			end)
		elseif keys.ability then
			if keys.ability["eff_" .. keys.eff] == nil then
				keys.ability["eff_" .. keys.eff] = {}
			end
			table.insert(keys.ability["eff_" .. keys.eff], nFXIndex)
		end
	end

	return nFXIndex
end

function abilities_eff_SetCps(keys)
	if not keys.cps then return end
	
	local channelRate = GenChannelRate(keys)
	local cps = string.split(keys.cps, "|")
	for _, cpStr in ipairs(cps) do
		local cpSet = string.split(cpStr, ",")
		if cpSet[1] == "ent" then
			local unit = keys[cpSet[3]]
			if keys.replaceCaster and cpSet[3] == "caster" then
				unit = keys.replaceCaster
			end
			if keys.replaceTarget and cpSet[3] == "target" then
				unit = keys.replaceTarget
			end
			ParticleManager:SetParticleControlEnt(keys.fxIndex, tonumber(cpSet[2]), unit, _G[cpSet[4]], cpSet[5], Vector(0, 0, 0), true)
		elseif cpSet[1] == "fw" then
			ParticleManager:SetParticleControlForward(keys.fxIndex, tonumber(cpSet[2]), keys.caster:GetForwardVector())
		elseif cpSet[1] == "lineTP" then
			local vDirection = keys.caster:GetForwardVector()
			local point = keys.caster:GetAbsOrigin() + vDirection * GetAdditionValue(keys.length, keys.caster) * channelRate
			ParticleManager:SetParticleControl(keys.fxIndex, tonumber(cpSet[2]), point)
		elseif cpSet[1] == "nm" then
			local vecX = GetAdditionValue(cpSet[3], keys.caster) * channelRate
			local vecY = GetAdditionValue(cpSet[4], keys.caster) * channelRate
			local vecZ = GetAdditionValue(cpSet[5], keys.caster) * channelRate
			if keys.Target == "POINT" and cpSet[3] == nil then
				vecX = keys.replaceTargetPoint and keys.replaceTargetPoint.x or keys.target_points[1].x
				vecY = keys.replaceTargetPoint and keys.replaceTargetPoint.y or keys.target_points[1].y
				vecZ = keys.replaceTargetPoint and keys.replaceTargetPoint.z or keys.target_points[1].z
			elseif keys.Target == "TARGET" and keys.target and cpSet[3] == nil then
				local targetPoint = keys.target:GetAbsOrigin()
				vecX = targetPoint.x
				vecY = targetPoint.y
				vecZ = targetPoint.z
			elseif keys.Target == "CASTER" and cpSet[3] == nil then
				local targetPoint = keys.caster:GetAbsOrigin()
				vecX = targetPoint.x
				vecY = targetPoint.y
				vecZ = targetPoint.z
			end
			--print(vecX, vecY, vecZ, cpStr)
			ParticleManager:SetParticleControl(keys.fxIndex, tonumber(cpSet[2]), Vector(vecX, vecY, vecZ))
		elseif cpSet[1] == "point" then
			ParticleManager:SetParticleControl(keys.fxIndex, tonumber(cpSet[2]), keys[cpSet[3]])
		end
	end
end

function abilities_eff_UpdateEff(keys)
	if keys.effIdx or keys.ability and keys.ability["eff_" .. keys.eff] and #keys.ability["eff_" .. keys.eff] > 0 then
		local nFXIndex = keys.effIdx or keys.ability["eff_" .. keys.eff][1]
		keys.fxIndex = nFXIndex
		abilities_eff_SetCps(keys)
	end
end

function abilities_eff_RemoveEff(keys)
	local nFXIndex = keys.effIdx
	if keys.effIdx then

	elseif keys.ability and keys.ability["eff_" .. keys.eff] and #keys.ability["eff_" .. keys.eff] > 0 then
		nFXIndex = table.remove(keys.ability["eff_" .. keys.eff], 1)
	end
	
	if nFXIndex then
		ParticleManager:DestroyParticle(nFXIndex, false)
		ParticleManager:ReleaseParticleIndex(nFXIndex)
	end
end