if element_comb == nil then
	element_comb = class({})
	element_comb.unitElements = {}
end

function element_comb.AddUnit(unit)
	element_comb.unitElements[unit] = {}

	for element, _ in pairs(element_menu) do
		local itemArgs = {}
		itemArgs["item_" .. element] = {1, {1, 1} }
		GiveItemToUnit(unit, itemArgs)
	end

	ui_manager.RegisterElementCast(unit:GetEntityIndex())
end

function element_add(kv)
	if element_comb.unitElements[kv.caster] then
		table.insert(element_comb.unitElements[kv.caster], kv.element)
	end

	ui_manager.AddElementCast(kv.caster:GetEntityIndex(), kv.element)
end

function element_compose(kv)
	local elements = element_comb.unitElements[kv.caster]
	local abilityKey = ""
	for _,element in ipairs(elements) do
		abilityKey = abilityKey .. element .. "A"
	end
	if not kv.caster.comAbilities then
		kv.caster.comAbilities = {}
	end
	
	for i=#kv.caster.comAbilities, 1, -1 do
		if not IsValidEntity(kv.caster.comAbilities[i]) then
			table.remove(kv.caster.comAbilities, i)
		end
	end

	local playerID = kv.caster:GetPlayerOwnerID()
	local abilityName = player_manager.playerDatas[playerID].acquireAbilities[abilityKey]
	if abilityName and not kv.caster:HasAbility(abilityName) then
		if #kv.caster.comAbilities >= kv.caster.costomAttribute.abilitySlot then
			local ability = table.remove(kv.caster.comAbilities, 1)
			RemoveAbility(kv.caster, ability)
		end
		local ability = kv.caster:AddAbility(abilityName)
		ability:SetLevel(1)
		table.insert(kv.caster.comAbilities, ability)

		local effArgs = {}
		effArgs.eff = "particles/combsuc.vpcf"
		effArgs.target = kv.caster
		effArgs.cps = "ent,1,target,PATTACH_POINT_FOLLOW,attach_hitloc|ent,3,target,PATTACH_ABSORIGIN_FOLLOW,attach_hitloc"
		abilities_eff_CreateEff(effArgs)

		EmitSoundOn("DOTA_Item.FaerieSpark.Activate", kv.caster)

		local uiEffArgs = {}
		uiEffArgs.effType = "combAbility"
		uiEffArgs.abilityIdx = ability:GetAbilityIndex()
		ui_manager.ShowUIEff(playerID, uiEffArgs)
	else
		local effArgs = {}
		effArgs.eff = "particles/combfail.vpcf"
		effArgs.target = kv.caster
		effArgs.cps = "ent,3,target,PATTACH_POINT_FOLLOW,attach_hitloc"
		abilities_eff_CreateEff(effArgs)
		EmitSoundOn("Hero_WitchDoctor.Maledict_CastFail", kv.caster)
	end

	element_comb.unitElements[kv.caster] = {}

	ui_manager.ClearElement(kv.caster:GetEntityIndex())
end