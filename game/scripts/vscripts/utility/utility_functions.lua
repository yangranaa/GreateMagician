

local AI_TABLE = {
    ai_test = require("ai/ai_test"),
    ai_rage = require("ai/ai_rage"),
    ai_fortitude = require("ai/ai_fortitude"),
    ai_timid = require("ai/ai_timid"),
}

--------------game----------------------
function SpawnCostomUnit(args)
    GenChannelRate(args, true)
    args.unit_radius = GetAdditionValue(args.unit_radius, args.caster)
    if not args.spawnPos then
        if args.unit_lockUnit then
            local unit = args[args.unit_lockUnit]
            if args.unit_lockOffset then
                local offsetStrs = string.split(args.unit_lockOffset, ",")
                if offsetStrs[1] == "fow" then
                    local lockRadius = (unit.costomAttribute and unit.costomAttribute.radius) or 0
                    args.unit_lockOffset = unit:GetForwardVector() * (tonumber(offsetStrs[2]) + lockRadius + args.unit_radius)
                    args.unit_lockOffset.z = args.unit_lockOffset.z + tonumber(offsetStrs[3])
                end
                args.spawnPos = unit:GetAbsOrigin() + args.unit_lockOffset
            end 
        elseif args.unit_lockPos then
            args.spawnPos = args.unit_lockPos
        else
            if args.unit_spawnOn == "Point" then
                args.spawnPos = args.target_points[1]
            elseif args.caster then
                local addVec = args.caster:GetForwardVector() * (args.unit_radius + args.caster.costomAttribute.radius + 20)
                args.spawnPos = args.caster:GetAbsOrigin() + addVec
                
            end
        end
    end

    args.spawnPos = args.spawnPos or Vector(0, 0, 0)

    if args.unit_lockZ then
        args.unit_lockZ = args.spawnPos.z + tonumber(args.unit_lockZ)
    end
    if args.unit_startZ then
        args.startPos = args.spawnPos
        args.startPos.z = args.startPos.z + tonumber(args.unit_startZ)
    end

    local team = DOTA_TEAM_NEUTRALS
    if args.unit_team then
        if args.unit_team == "caster" then
            team = args.caster:GetTeamNumber()
        else
            team = args.unit_team
        end
    end
    
    local owner = nil
    if args.unit_owner then
        owner = args[args.unit_owner]
    end

    local findClear = args.unit_findClear ~= nil
    if not args.costomUnit then
        args.unit_name = args.unit_name or "unreal_unit"
        args.costomUnit = CreateUnitByName(args.unit_name, args.spawnPos, findClear, owner, owner, team)
    end
    args.costomUnit.type = args.type
    args.costomUnit.destoryByAbilityDestory = args.unit_destoryByAbilityDestory

    if args.unit_controlBy then
        args.costomUnit:SetControllableByPlayer(args.caster:GetPlayerOwnerID(), true)
    end

    if args.caster then
        args.costomUnit.summonCaster = args.caster
        args.costomUnit:SetForwardVector(args.caster:GetForwardVector())
    end

    if args.curlockAngle then
        args.costomUnit:SetAngles(0, args.curlockAngle, 0)
    end

    if args.unit_angle then
        args.costomUnit:SetAngles(args.unit_angle.x, args.unit_angle.y, args.unit_angle.z)
    end 

    if args.ability then
        args.ability.summonUnit = args.costomUnit
    end

    if args.unit_ai then
        args.costomUnit.ai = AI_TABLE[args.unit_ai].new(args.costomUnit)
        if args.unit_group then
            args.costomUnit.ai:AddToGroup(args.unit_group)
        end
    end

    if args.unit_numLimit then
        local limitStrArr = string.split(args.unit_numLimit, ",")
        args.caster.limitUnits = args.caster.limitUnits or {}
        args.caster.limitUnits[limitStrArr[1]] = args.caster.limitUnits[limitStrArr[1]] or {}
        for i=#args.caster.limitUnits[limitStrArr[1]], 1, -1 do
            if not IsValidEntity(args.caster.limitUnits[limitStrArr[1]][i]) then
                table.remove(args.caster.limitUnits[limitStrArr[1]], i)
            end
        end
        if #args.caster.limitUnits[limitStrArr[1]] >= GetAdditionValue(limitStrArr[2], args.caster) then
            local lmtUnit = table.remove(args.caster.limitUnits[limitStrArr[1]], 1)
            lmtUnit:ForceKill(false)
        end
        table.insert(args.caster.limitUnits[limitStrArr[1]], args.costomUnit)
    end

    if args.unit_phyType then
        CostomAttribute.new(args)
    end

    args.costomUnit.upAttrData = args.upAttrData
    if args.costomUnit.upAttrData then
        spawner_manager.SetUnitLevel(args.costomUnit, args.costomUnit.upAttrData.level)

        LearnAbilities(args.costomUnit, args.costomUnit.upAttrData.abilities)
    end

    if args.abilities then
        LearnAbilities(args.costomUnit, args.abilities)
    end

    if args.unit_modifierNames then
        local modiferArgs = {}
        modiferArgs.modifierNames = args.unit_modifierNames
        modiferArgs.caster = args.caster
        modiferArgs.target = args.costomUnit
        modiferArgs.ability = args.ability
        ability_apply_modifiers(modiferArgs)
    end

    if args.unit_destoryBySummerDie then
        args.caster.destoryOnDie = args.caster.destoryOnDie or {}
        args.caster.destoryOnDie[args.costomUnit] = 1
    end

    return args.costomUnit
end

function FindRoundTargets(args)
    local typeFilter = args.typeFilter or DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    local teamTarget = args.teamTarget or (IsValidEntity(args.caster) and args.caster.ai and args.caster.ai.teamTarget) or DOTA_UNIT_TARGET_TEAM_BOTH
    local filter = args.filter or "NoApplyDamage"
    if IsValidEntity(args.ability) and args.ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_FRIENDLY then
        teamTarget = args.teamTarget or DOTA_UNIT_TARGET_TEAM_FRIENDLY
        filter = args.filter
    end
    local targetFlags = args.targetFlags or (IsValidEntity(args.ability) and args.ability:GetAbilityTargetFlags()) or DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES
    local center = args.center or (args.target_points and args.target_points[1]) or (IsValidEntity(args.target) and args.target:GetAbsOrigin()) or (IsValidEntity(args.caster) and args.caster:GetAbsOrigin())
    local teamNum = args.teamNum or (IsValidEntity(args.caster) and args.caster:GetTeamNumber())
    local cacheUnit = args.caster
    local radius = args.caster and GetAdditionValue(args.radius, args.caster)
    local angle = args.angle
    local findOrder = args.findOrder or FIND_ANY_ORDER

    if type(center) == "string" then
        local xyz = string.split(center, " ")
        center = Vector(tonumber(xyz[1]), tonumber(xyz[2]), tonumber(xyz[3]))
    end

    if Debug then
        DebugDrawCircle(center, Vector(255, 0, 0), 1, radius, false, 1)
    end

    local targets = FindUnitsInRadius(teamNum, center, 
        cacheUnit, radius, teamTarget, typeFilter, targetFlags, findOrder, false)

    for i=#targets, 1, -1 do
        if FilterUnit(filter, args.caster, targets[i]) then
            table.remove(targets, i)
        elseif angle and math.abs(Vector_Angle(args.caster:GetForwardVector(), targets[i]:GetAbsOrigin() - args.caster:GetAbsOrigin())) > angle then
            table.remove(targets, i)
        end
    end

    if args.targetNum and #targets > args.targetNum then
        for i=#targets, args.targetNum + 1, -1 do
            table.remove(targets, i)
        end
    end

    return targets
end

function RemoveAbility(unit, ability)
    if type(ability) == "string" then
        unit:RemoveAbility(ability)
    else
        if IsValidEntity(ability.summonUnit) and ability.summonUnit.destoryByAbilityDestory then
            ability.summonUnit:ForceKill(false)
        end

        if IsValidEntity(ability) then
            unit:RemoveAbility(ability:GetAbilityName())
        end
    end
end

function LearnAbilities(unit, args)
    local tab = args
    if type(args) == "string" then
        local abilitiesArr = string.split(args, "|")
        tab = {}
        for _, abilityStr in pairs(abilitiesArr) do
            local abilityArr = string.split(abilityStr, ":")
            tab[abilityArr[1]] = tonumber(abilityArr[2]) or 1
        end
    end
    
    for name, lv in pairs(tab) do
        if not unit.abilities then
            unit.abilities = {}
        end

        local ability = unit:FindAbilityByName(name)
        if not ability then
            ability = unit:AddAbility(name)
        end
        table.insert(unit.abilities, ability)
        ability:SetLevel(lv)
        ability.effTypes = GetAbilityEffTypes(ability)
    end
end

function GetRealCaster(caster)
    return caster.summonCaster or caster
end

function GetAbilityEffTypes(ability)
    local result = {}
    result.isBuff = ability:GetSpecialValueFor("isBuff") ~= 0
    result.isHeal = ability:GetSpecialValueFor("isHeal") ~= 0
    result.isRmana = ability:GetSpecialValueFor("isRmana") ~= 0
    result.isAtk = ability:GetSpecialValueFor("isAtk") ~= 0
    result.isControl = ability:GetSpecialValueFor("isControl") ~= 0
    result.isEscape = ability:GetSpecialValueFor("isEscape") ~= 0
    for debuffName, _ in pairs(debuff_priority) do
        if ability:GetSpecialValueFor("clear_".. debuffName) ~= 0 or ability:GetSpecialValueFor("clear_all") ~= 0 then
            if result.clearDebuff == nil then
                result.clearDebuff = {}
            end
            result.clearDebuff[debuffName] = 1
        end
    end

    return result
end

function GetInventoryItem(unit, itemName)
    for i=0,8 do
        local item = unit:GetItemInSlot(i)
        if item and item:GetAbilityName() == itemName then
            return item
        end
    end
    return nil
end

function GiveItemToUnit(unit, itemTable)
    for itemName, args in pairs(itemTable) do
        if RandomFloat(0, 1) <= args[1] then
            local num = RandomInt(args[2][1], args[2][2])
            for i=1, num do
                local item = nil
                if unit:HasAnyAvailableInventorySpace() then
                    item = CreateItem(itemName, nil, nil)
                    unit:AddItem(item)
                else
                    item = GetInventoryItem(unit, itemName)
                    if not item:IsStackable() then
                        local launchArgs = {}
                        launchArgs.className = itemName
                        launchArgs.origin = unit:GetAbsOrigin()
                        launchArgs.keepTime = args[4]
                        LaunchItem(launchArgs)
                        item = nil
                    end
                end
                if IsValidEntity(item) and args[3] then
                    item:SetCurrentCharges(item:GetCurrentCharges() + args[3])
                end
            end
        end
    end
end

function DropItemByUnit(unit, overrideTable)
    local itemTable = overrideTable or (unit.type ~= nil and unit.type.itemTable)
    if not itemTable then return end
    
    for itemName, args in pairs(itemTable) do
        if RandomFloat(0, 1) <= args[1] then
            local num = RandomInt(args[2][1], args[2][2])
            for i=1, num do
                local launchArgs = {}
                launchArgs.className = itemName
                launchArgs.origin = unit:GetAbsOrigin()
                launchArgs.keepTime = args[4]
                launchArgs.hight = RandomInt(100, 250)
                launchArgs.duration = RandomFloat(0.4, 0.7)
                launchArgs.useOnContact = args[5]
                local item = LaunchItem(launchArgs)
                if args[3] then
                    item:SetCurrentCharges(args[3])
                end
            end
        end
    end
end

function LaunchItem(args)
    local offSet = RandomVector(args.length or RandomFloat(50, 300))
    local item = CreateItem(args.className, nil, nil)
    local modelScale = item:GetSpecialValueFor("modelScale")
    modelScale = modelScale ~= nil and modelScale > 0 and modelScale or 1
    local pyItem = CreateItemOnPositionSync(args.origin, item)
    pyItem:SetModelScale(modelScale)
    hight = args.hight or 150
    duration = args.duration or 0.45
    item:LaunchLoot(args.useOnContact or false, hight, duration, args.origin + offSet)
    if args.keepTime then
        pyItem.DestroySelf = function(unit)
            local nFXIndex = ParticleManager:CreateParticle( "particles/item_disappear.vpcf",  PATTACH_CUSTOMORIGIN, nil)
            ParticleManager:SetParticleControl( nFXIndex, 2, pyItem:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex( nFXIndex )
            UTIL_Remove(unit)
        end
        pyItem:SetContextThink("Destroy_self"..pyItem:GetEntityIndex(), Dynamic_Wrap(pyItem, "DestroySelf" ), args.keepTime)
    end
    return item
end

function SetModelScale(unit, scale, noIncludeCollision)
    unit.baseScale = unit.baseScale or unit:GetModelScale()
    unit.baseRadius = unit.baseRadius or unit:GetHullRadius()
    unit:SetModelScale(scale)
    if noIncludeCollision == nil then
        unit:SetHullRadius(unit.baseRadius * scale)
    end 
end

function SetRanderColor(unit, r, g, b)
    unit:SetRenderColor(r, g, b)
    local childs = unit:GetChildren()
    for k,child in pairs(childs) do
        if child:GetClassname() == "dota_item_wearable" then
            child:SetRenderColor(r, g, b)
        end
    end
end

function GenChannelRate(kv, refresh)
    if not refresh and kv.channelRate then return kv.channelRate end

    kv.channelRate = 1
    if kv.channelTime and kv.startTime then
        local channelArgStr = string.split(kv.channelTime, ",")

        kv.channelRate = ((GameRules:GetGameTime() - kv.startTime) / tonumber(channelArgStr[1]))
    end
    return kv.channelRate
end

function GenArgsChange(args)
    local result = {}
    local centerEnt = args.excUnit or args.caster

    if args.TPChange then
        args.target_points = {}
        local TPChangeStrArr = string.split(args.TPChange, ",")
        if TPChangeStrArr[1] == "randomRound" then
            local range = GetAdditionValue(TPChangeStrArr[2], args.caster)
            args.target_points[1] = centerEnt:GetAbsOrigin() + RandomVector(RandomFloat(0, range))
        elseif TPChangeStrArr[1] == "randomTarget" then
            local findArgs = {}
            findArgs.caster = centerEnt
            findArgs.radius = GetAdditionValue(TPChangeStrArr[2], args.caster)
            findArgs.filter = "NoApplyDamage,Self"
            local targets = FindRoundTargets(findArgs)
            if #targets > 0 then
                args.target_points[1] = PickRandomValue(targets):GetAbsOrigin()
            else
                args.target_points[1] = centerEnt:GetAbsOrigin()    
            end
        end
        args.center = args.target_points[1]
    end

    if args.centerChange then
        args.center = centerEnt:GetAbsOrigin()
    end
end

function GenAbilityArgs(args)
    args.baseDamage = args.baseDamage or IsValidEntity(args.ability) and args.ability:GetSpecialValueFor("baseDamage")
    args.damageType = args.damageType or IsValidEntity(args.ability) and args.ability:GetAbilityDamageType()
    args.teamTarget = args.teamTarget or IsValidEntity(args.ability) and args.ability:GetAbilityTargetTeam()
    args.targetFlags = args.targetFlags or IsValidEntity(args.ability) and args.ability:GetAbilityTargetFlags()
end

local additionValues = {"radius", "force", "speed", "mass", "duration", "healValue", "autoDel"}
local normalValues = {"usePM", "damageElements", "chDir", "hDir", "hVelocity", "vVelocity", "changeVelocity", "modifierNames", "eff", "cps", "speedToPos", "speedToUnit", "attacker", "filter", "TPChange", "centerChange", "emit_sound"}
local modifierArgKeys = {"duration", "stackCount", "eff"}
function GenArgs(args, prefix)
    local result = {}
    local channelRateKeys = {}
    if args.channelTime then
        local CRKeyArr = string.split(args.channelTime, ",")
        for i=2, #CRKeyArr do
            table.insert(channelRateKeys, CRKeyArr[i])
        end
    end
    result.baseDamage = args.baseDamage
    result.damageType = args.damageType
    result.teamTarget = args.teamTarget
    result.targetFlags = args.targetFlags
    result.Target = args.Target
    
    for _,v in pairs(additionValues) do
        if args[prefix .. "_" .. v] then
            result[v] = GetAdditionValue(args[prefix .. "_" .. v], args.caster)
        end
    end
    
    for _,v in pairs(normalValues) do
        if args[prefix .. "_" .. v] then
            result[v] = args[prefix .. "_" .. v]
        end
    end

    if result.modifierNames then
        result.modifierArgs = GenModifierArgs(args, result.modifierNames)
    end

    if #channelRateKeys > 0 then
        local channelRate = GenChannelRate(args)
        for _,key in ipairs(channelRateKeys) do
            if result[key] then
                result[key] = result[key] * channelRate
            end
        end
    end

    return result
end

function GenModifierArgs(args, modifierNames)
    local result = {}
    if modifierNames then
        local modifiersStrArr = string.split(modifierNames, "|")
        for _, modifierName in ipairs(modifiersStrArr) do
            local modifierArg = {}
            modifierArg.modifierName = modifierName
            modifierArg.ability = args.ability
            for _, modifierArgKey in ipairs(modifierArgKeys) do
                modifierArg[modifierArgKey] = args[modifierName .. "_" .. modifierArgKey]
            end
            table.insert(result, modifierArg)
        end
    end
    return result
end

function GenDamageArgs(args)
    args.channelRate = args.channelRate or 1
    args.radius = args.radius * args.channelRate
    args.baseDamage = args.baseDamage * args.channelRate
    args.speed = args.speed and args.speed * args.channelRate
    args.force = args.force and args.force * args.channelRate
end

function GetCanTakeDamage(target)
    if not target.costomAttribute then
        return false
    elseif target.costomAttribute.unitType == COSTOM_UNIT_TYPE.ROAMELEMENT then
        return false
    end
    return true
end

function FilterUnit(str, unit, target)
    if not str then return false end
    local filterFlags = string.split(str, ",")
    for i,flag in ipairs(filterFlags) do
        if flag == "Self" and (unit == target or (target:GetPlayerOwnerID() ~= -1 and target:GetPlayerOwnerID() == unit:GetPlayerOwnerID()) or target == GetRealCaster(unit)) then
            return true
        elseif flag == "NoApplyDamage" and not GetCanTakeDamage(target) then
            return true
        elseif flag == "SameTeam" and unit:GetTeamNumber() == target:GetTeamNumber() then
            return true
        elseif flag == "NoSelf" and unit ~= target then
            return true
        elseif flag == "NoRealHero" and not target:IsRealHero() then
            return true
        elseif flag == "SameUnit" and unit:GetUnitName() == target:GetUnitName() then
            return true
        end
    end
    return false
end

function CalculateDamage(baseDamage, damageElements, caster, target)
    local elementStrs = string.split(damageElements, "|")
    local result = {}
    result.damageCount = 0
    result.partDamage = {}
    for i,element in ipairs(elementStrs) do
        local damage = GetAdditionValue(element, caster, baseDamage)
        damage = damage * (100 - GetEleResistance(element, target)) * 0.01
        result.partDamage[element] = damage
        result.damageCount = result.damageCount + damage
    end
    return result
end

function GetCoefficient(element, unit)
    if not unit then return 0 end

    local result = 0
    if element == "atk" then
        result = unit:GetBaseDamageMin() / 8
    end
    if element == "speed" then
        result = unit:GetMoveSpeedModifier(unit:GetBaseMoveSpeed(), true) / 5
    end

    if unit.costomAttribute.tempCoefficient then
        result = result + (unit.costomAttribute.tempCoefficient[element] or 0)
    end
    if unit.costomAttribute.coefficient then
        result = result + (unit.costomAttribute.coefficient[element] or 0)
    end
    
    return result
end

function GetEleResistance(element, unit)
    local result = 0
    if unit.costomAttribute.resistance then
        result = unit.costomAttribute.resistance[element] or 0
    end
    return result
end

function GetAdditionValue(str, unit, val)
    if str == nil then return 0 end
    val = (val == nil or val == 0) and 1 or val
    if tonumber(str) == nil then
        local result = 0
        local groups = string.split(str, "|")
        if string.find(str, "&") then
            groups = string.split(str, "&")
        end
        for i, group in ipairs(groups) do
            local calculKV = string.split(group, ":")
            local rateVal = GetCoefficient(calculKV[1], unit)
            result = result + (tonumber(calculKV[2]) or 1) * ((100 + rateVal) * 0.01) * val
        end

        return result 
    else
        return tonumber(str)
    end
end

function IsUnitExistAndAlive(unit)
    return IsValidEntity(unit) and unit:IsAlive()
end

----------------------table---------------
function PickRandomShuffle( reference_list, bucket )
    if ( #reference_list == 0 ) then
        return nil
    end
    
    if ( #bucket == 0 ) then
        -- ran out of options, refill the bucket from the reference
        for k, v in pairs(reference_list) do
            bucket[k] = v
        end
    end

    -- pick a value from the bucket and remove it
    local pick_index = RandomInt( 1, #bucket )
    local result = bucket[ pick_index ]
    table.remove( bucket, pick_index )
    return result
end

function PickRandomValue(table, except)
    if table == nil then
        return nil
    end
    local count = TableCount(table)
    if except then count = count - 1 end
    local randomV = RandomInt(1, count)
    for k,v in pairs(table) do
        if k ~= except then
            if randomV == 1 then
                return v, k
            end
            randomV = randomV - 1
        end
    end
end

function RandomTableByRate(table)
    local result = {}
    for k,v in pairs(table or {}) do
        if v >= 1 then
            result[k] = v
        elseif RandomFloat(0, 0.999) < v then
            result[k] = 1
        end
    end
    return result
end

function RandomTableByRange(table)
    local result = {}
    for k,v in pairs(table) do
        result[k] = RandomInt(v[1], v[2])
    end

    return result
end

function PickRandomByRateList(list)
    local count = 0
    for k,rate in pairs(list) do
        count = count + rate
    end
    local randomF = RandomFloat(0, count)
    local rateCount = 0
    for k,rate in pairs(list) do
        rateCount = rateCount + rate
        if randomF <= rateCount then
            return k
        end
    end
    return nil
end

function TableCopyToTable(from, to)
    for k,v in pairs(from or {}) do
        to[k] = v
    end
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function ShuffledList( orig_list )
    local list = shallowcopy( orig_list )
    local result = {}
    local count = #list
    for i = 1, count do
        local pick = RandomInt( 1, #list )
        result[ #result + 1 ] = list[ pick ]
        table.remove( list, pick )
    end
    return result
end

function TableCount( t )
    local n = 0
    for _ in pairs( t ) do
        n = n + 1
    end
    return n
end

function TableFindKey( table, val )
    if table == nil then
        print( "nil" )
        return nil
    end

    for k, v in pairs( table ) do
        if v == val then
            return k
        end
    end
    return nil
end

function TableRemoveByVal( table, val)
    local key = TableFindKey(table, val)
    if type(key) == "number" then
        table.remove(table, key)
    elseif type(key) == "string" then
        table[key] = nil
    end
end

function ListInsertList(list, iList)
    for i,v in ipairs(iList) do
        table.insert(list, v)
    end
end

function ListRemoveSameValue(list)
    local values = {}
    for i=#list, 1 -1 do
        if values[list[i]] then
            table.remove(list, i)
        else
            values[list[i]] = true
        end
    end
end

function TableRemoveByTable(source, tab)
    local result = shallowcopy(source)
    for _,v in pairs(tab) do
        if result[v] then
            result[v] = nil
        end
    end
    return result
end

----------------vector--------------
function Vector_Copy(vector)
    if not vector then return nil end
    return Vector(vector.x, vector.y, vector.z)
end

function Vector_Reflect(vector1, normal)
    return vector1 - 2 * vector1:Dot(normal) * normal
end

function Vector_Angle(vector1, vector2, comZ)
    local vec1 = Vector(vector1.x, vector1.y, 0)
    local vec2 = Vector(vector2.x, vector2.y, 0)
    if comZ then
        vec1.z = vector1.z
        vec2.z = vector2.z
    end
    local cosAng = vec1:Dot(vec2) / (#vec1 * #vec2)
    if cosAng > 0 then
        cosAng = math.min(1, cosAng)
    else
        cosAng = math.max(-1, cosAng)    
    end

    return math.deg(math.acos(cosAng))
end

function Vector_Lerp(vector1, vector2, frac)
    local lenth = vector2 - vector1
    return vector1 + frac * lenth
end

----------------num-------------------

function Num_Lerp(num1, num2, frac)
    local inv = num2 - num1
    return num1 + inv * frac
end

----------------string---------------
function string.split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
       local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
       if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
       end
       nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
       nFindStartIndex = nFindLastIndex + string.len(szSeparator)
       nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

function string.trim(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1")) 
end

function serialize(obj)
    local lua = ""
    local t = type(obj)
    if t == "number" then
        lua = lua .. obj
    elseif t == "boolean" then
        lua = lua .. tostring(obj)
    elseif t == "string" then
        lua = lua .. string.format("%q", obj)
    elseif t == "table" then
        lua = lua .. "{\n   "
    for k, v in pairs(obj) do
        lua = lua .. "  " .. "[" .. serialize(k) .. "]=" .. "   " .. serialize(v) .. ",\n"
    end
    local metatable = getmetatable(obj)
        if metatable ~= nil and type(metatable.__index) == "table" then
        for k, v in pairs(metatable.__index) do
            lua = lua .. "  " .. "[" .. serialize(k) .. "]=" .. "   " .. serialize(v) .. ",\n"
        end
    end
        lua = lua .. "}"
    elseif t == "nil" then
        return nil
    else
        lua = lua .. tostring(t)
    end
    return lua
end

function unserialize(lua)
    local t = type(lua)
    if t == "nil" or lua == "" then
        return nil
    elseif t == "number" or t == "string" or t == "boolean" then
        lua = tostring(lua)
    else
        error("can not unserialize a " .. t .. " type.")
    end
    lua = "return " .. lua
    local func = loadstring(lua)
    if func == nil then
        return nil
    elseif type(func()) == "string" then
        lua = "return " .. func()
        func = loadstring(lua)
    end
    return func()
end