function abilities_buff_target_buff(keys)
	local name = keys.modifierName
	local modifierArgs = {}
	local argStr = nil
	local curArgs = nil
	local targetEnt = keys.target

	if keys.Target == "CASTER" then
		targetEnt = keys.caster
	end

	if keys.Target == "POINT" and not targetEnt then
		targetEnt = keys.caster
		modifierArgs.target_point = keys.target_points[1]
	end

	modifierArgs.duration = GetAdditionValue(keys.duration, keys.caster)
	if modifierArgs.duration == 0 then
		modifierArgs.duration = nil
	end

	if keys.stackCount then
		modifierArgs.stackCount = math.floor(GetAdditionValue(keys.stackCount, keys.caster))
	end

	if keys.overAni then
		local overAniStrArr = string.split(keys.overAni, ",")
		modifierArgs.stackCount = _G[overAniStrArr[1]] * 10000 + (tonumber(overAniStrArr[2]) or 0) * 100 + (tonumber(overAniStrArr[3]) or 1) * 10
	end

	modifierArgs.eff = keys.eff

	local mdf = targetEnt:AddNewModifier(keys.caster, keys.ability, "modifier_"..name, modifierArgs)
	return mdf
end