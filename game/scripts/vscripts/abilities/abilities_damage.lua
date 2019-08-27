-- Function	=	leech_seed_damage
-- ability	=	table: 0x033f2f60
-- damage=30
-- target_points	=	table: 0x033be738
-- caster_entindex	=	370
-- target_entities	=	table: 0x033cc098
-- target	=	table: 0x033acd08
-- Target	=	TARGET
-- caster	=	table: 0x033b7950
-- ScriptFile	=	scripts/vscripts/abilities/modifier_abilites_damage.lua
-- damage	=	30
require("abilities/ability_ray")
require("abilities/element_comb")

LinkLuaModifier( "modifier_phy_motion", "abilities/motion/modifier_phy_motion", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier( "modifier_preview_model", "abilities/modifier/modifier_preview_model", LUA_MODIFIER_MOTION_VERTICAL)

LinkLuaModifier( "modifier_turn_channel", "abilities/modifier/modifier_turn_channel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_stun", "abilities/modifier/modifier_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_zidanshijian", "abilities/modifier/modifier_zidanshijian", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_xiashendongjie", "abilities/modifier/modifier_xiashendongjie", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_ziyu", "abilities/modifier/modifier_ziyu", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_molihuiji", "abilities/modifier/modifier_molihuiji", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_frozen", "abilities/modifier/modifier_frozen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_moveslow", "abilities/modifier/modifier_moveslow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_yinli", "abilities/modifier/modifier_yinli", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_molihudun", "abilities/modifier/modifier_molihudun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_huaxing", "abilities/modifier/modifier_huaxing", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_shijianjiasu", "abilities/modifier/modifier_shijianjiasu", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_zhenshi", "abilities/modifier/modifier_zhenshi", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_yijiechuansuo", "abilities/modifier/modifier_yijiechuansuo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_fengzhiyi", "abilities/modifier/modifier_fengzhiyi", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_jixing", "abilities/modifier/modifier_jixing", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_jianrenfengbao", "abilities/modifier/modifier_jianrenfengbao", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_yinnibufa", "abilities/modifier/modifier_yinnibufa", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_roudanzhanche", "abilities/modifier/modifier_roudanzhanche", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_playact", "abilities/modifier/modifier_playact", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_ranshao", "abilities/modifier/modifier_ranshao", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_zhenchashouwei", "abilities/modifier/modifier_zhenchashouwei", LUA_MODIFIER_MOTION_NONE)

function test(kv)
    for i=0, kv.caster:GetAbilityCount() - 1 do
        local ability = kv.caster:GetAbilityByIndex(i)
        if ability then
            ability:EndCooldown()
        end
    end

    local testUnitList = {
        {Vector(-2368, -1280, 128), Vector(0, 330, 0)},
        {Vector(-1792, -1480, 128), Vector(0, 135, 0)},
        {Vector(-1920, -896, 128), Vector(0, 315, 0)},
    }

    for i,v in ipairs(testUnitList) do
        local args = {}
        args.unit_radius = 50
        args.unit_mass = 100
        args.unit_team = DOTA_TEAM_BADGUYS
        args.unit_name = "testUnit"
        args.unit_phyType = "PLAYER"
        args.unit_ai = "ai_test"
        args.unit_hight = 200
        args.spawnPos = v[1]
        args.unit_angle = v[2]
        local unit = SpawnCostomUnit(args)
        --LearnAbilities(unit, {dianlichongying=1})
        --unit:SetTeam(DOTA_TEAM_GOODGUYS)
        --unit:SetControllableByPlayer(0, true)
    end

    
    

    for _, type_list in pairs(NATUREL_TYPE_LISTS) do
        --spawner_manager:SpawnList(type_list)
    end


    local buffArgs = {}
    buffArgs.modifierName = "jixing"
    buffArgs.duration = 100
    buffArgs.stackCount = 50
    buffArgs.target = kv.caster
    buffArgs.caster = kv.caster
    --abilities_buff_target_buff(buffArgs)

    local checkKeys = {"StopAnimation", "GetSequence","IsSequenceFinished","SetSkin","SequenceDuration","StopAnimation","SetActivityType","SetMaterialGroup"}
    -- for k,v in pairs(checkKeys) do
    --     print(v, kv.caster[v])
    -- end

    --ui_manager.RegisterNpcBubble(0)
    ui_manager.UpdateAbilitiesView(0)
    --ui_manager.UpdatePointScore("SUPPLY_POINT", 30)

    --kv.caster:SetAbsOrigin(Vector(0, 0, 0))
    -- for _, unit in pairs(spawner_manager.npcCache) do
    --     unit:SetAbsOrigin(Vector(0, 0, 0))
    -- end
    --ui_manager.ShowGameEndView(DOTA_TEAM_GOODGUYS)
    --GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)

    -- local countElement = {}
    -- for k,v in pairs(ELEMENTS_TO_ABILITY) do
    --     local strArr = string.split(k, "A")
    --     for i,ele in ipairs(strArr) do
    --         countElement[ele] = countElement[ele] or 0
    --         countElement[ele] = countElement[ele] + 1
    --     end
    -- end
    -- for k,v in pairs(countElement) do
    --     print(k,v)
    -- end

    --kv.caster:SetAbsOrigin(Vector(0, 0, 0))

    -- EmitSoundOn("valve_dota_001.music.roshan_end",  kv.caster)
    -- local effArgs = {}
    -- effArgs.eff = "particles/yanhuo.vpcf"
    -- effArgs.cps = "ent,0,target,PATTACH_ABSORIGIN_FOLLOW,attach_hitloc"
    -- effArgs.target = kv.caster
    -- effArgs.autoDel = "5"
    -- abilities_eff_CreateEff(effArgs)

    --ui_manager.AddScrollMsg( {key = "kill_count10", args = {playerName = PlayerResource:GetPlayerName(0)}})
    --player_manager.InitPlayerData(0)
    -- local effArgs = {}
    -- effArgs.eff = "particles/moguangzhan.vpcf"
    -- effArgs.caster = kv.caster
    -- effArgs.target = kv.caster
    -- effArgs.Target = "CASTER"
    -- effArgs.cps = "nm,1,1,1,1"
    -- abilities_eff_CreateEff(effArgs)
    --LearnAbilities(kv.caster, {roudanzhanche=1})
    --ui_manager.UpdateAbilitiesView(0)
    --ui_manager.AddScrollMsg( {key = "high_dmg", args = {playerNameAtk = "aaaa", playerNameHurt = "bbbb", dmg = 213123}})
end

function ability_add_coefficient(kv)
    if kv.caster.costomAttribute then
        kv.caster:RemoveItem(kv.ability)
        local coefficient = {}
        coefficient[kv.element] = kv.caster.costomAttribute.coefficient[kv.element] + kv.elementAddValue
        kv.caster.costomAttribute:ChangeCoefficient(coefficient) 
    end
end

function ability_add_mana(kv)
    local targetEnt = kv.target
    if targetEnt == nil and kv.Target == "CASTER" then
        targetEnt = kv.caster
    end

    local value = GetAdditionValue(kv.addManaValue, kv.caster)
    value = math.min(value, targetEnt:GetMaxMana() - targetEnt:GetMana())

    targetEnt:GiveMana(value)
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, targetEnt, value, nil)
end

function ability_heal(kv)
    local targetEnt = kv.target
    if targetEnt == nil and kv.Target == "CASTER" then
        targetEnt = kv.caster
    end

    local value = GetAdditionValue(kv.healValue, kv.caster)
    if kv.healPercent then
        value = GetAdditionValue(kv.healPercent, kv.caster) * targetEnt:GetMaxHealth()
    end
    
    targetEnt:Heal(value, kv.caster)
    
    value = math.min(value, targetEnt:GetMaxHealth() - targetEnt:GetHealth())
    if value > 0 and kv.caster:IsRealHero() and targetEnt:IsRealHero()  then
        score_manager.OnHealUnit(kv.caster, targetEnt, value)
    end
    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, targetEnt, value, nil)
end

function ability_apply_damage(kv)
    local finnalDamage = kv.damage
    if kv.baseDamage and kv.damageElements then
        local result = CalculateDamage(kv.baseDamage, kv.damageElements, kv.caster, kv.target)
        finnalDamage = result.damageCount

        if kv.target.costomAttribute.unitType == COSTOM_UNIT_TYPE.PLAYER or kv.target.costomAttribute.unitType == COSTOM_UNIT_TYPE.NORMALUNIT then
            for element, partDmg in pairs(result.partDamage) do
                local numType = OVERHEAD_ALERT_DAMAGE
                local elementStrArr = string.split(element, ":")
                if elementStrArr[1] == "fire" then
                    numType = OVERHEAD_ALERT_DAMAGE
                elseif elementStrArr[1] == "water" then
                    numType = OVERHEAD_ALERT_MANA_LOSS
                elseif elementStrArr[1] == "natural" then
                    numType = OVERHEAD_ALERT_BONUS_POISON_DAMAGE
                elseif elementStrArr[1] == "vapour" then
                    numType = OVERHEAD_ALERT_MAGICAL_BLOCK
                elseif elementStrArr[1] == "ground" then
                    numType = OVERHEAD_ALERT_BLOCK
                elseif elementStrArr[1] == "thunder" then
                    numType = OVERHEAD_ALERT_BONUS_SPELL_DAMAGE
                end
                SendOverheadEventMessage(nil, numType, kv.target, partDmg, nil)
            end
        end
    elseif finnalDamage and finnalDamage > 0 then
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, kv.target, finnalDamage, nil)
    end

    if finnalDamage and finnalDamage ~= 0 then 
        local damageTable = {
            victim = kv.target,
            attacker = kv.caster,
            damage = finnalDamage,
            damage_type = kv.damageType or (kv.ability and kv.ability:GetAbilityDamageType()) or DAMAGE_TYPE_MAGICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NONE,
        }
        ApplyDamage(damageTable)

        ability_apply_modifiers(kv)
    end

    if kv.damageEff_eff then
        local effArgs = GenArgs(kv, "damageEff")
        effArgs.caster = kv.caster
        effArgs.target = kv.target
        abilities_eff_CreateEff(effArgs)
    end
end

function ability_apply_modifiers(kv)
    if kv.modifierNames and not kv.modifierArgs then
        kv.modifierArgs = GenModifierArgs(kv, kv.modifierNames)
    end

    if kv.modifierArgs then
        for _, modifierArg in ipairs(kv.modifierArgs) do
            modifierArg.caster = kv.caster
            modifierArg.target = kv.target
            modifierArg.ability = kv.ability
            abilities_buff_target_buff(modifierArg)
        end
    end

    if kv.changeVelocity then
        abilities_change_velocity(kv)
    end
end

function abilities_round_damage(kv)
    GenAbilityArgs(kv)

    local targets = FindRoundTargets(kv)

    for _, target in pairs(targets) do
        kv.target = target
        ability_apply_damage(kv)
        kv.target = nil
    end
    return targets
end

function abilities_call_back(kv)
    abilities_eff_CreateEff(kv)
    local casterPos = kv.caster:GetAbsOrigin()
    local pos = casterPos + RandomVector(RandomFloat(120, 300))
    while not GridNav:CanFindPath(casterPos, pos) do
        pos = casterPos + RandomVector(RandomFloat(120, 300))
    end
    kv.target:SetAbsOrigin(pos)
    abilities_eff_CreateEff(kv)
end

function abilities_dominant_nartural(kv)
    if kv.target.ai and kv.target.type.dominantRate then
        local rate = GetAdditionValue(kv.dominantRate, kv.caster) * (11 - kv.target:GetLevel()) * 0.1 * kv.target.type.dominantRate
        if RandomFloat(0, 1) < rate then
            kv.target.ai:SetMaster(kv.caster)
        else
            kv.target.ai:SetAggro(kv.caster)
        end
    end
end

function abilities_lock_unit(kv)
    kv.caster.costomAttribute.lockUnit = kv.target
    kv.caster.costomAttribute.lockOffset = kv.target:GetForwardVector() * -100
    kv.caster.costomAttribute.lockOffset.z = 200
    Timers:CreateTimer(GetAdditionValue(kv.duration, kv.caster), function()
        kv.caster.costomAttribute.lockUnit = nil
        return nil
    end)
    AppPhyMotion(kv.caster)
end

function abilities_delay_exc(kv)
    if kv.waring_eff then
        local waringEffArgs = GenArgs(kv, "waring")
        waringEffArgs.caster = kv.caster
        waringEffArgs.Target = kv.Target
        waringEffArgs.target_points = kv.target_points
        kv.waringEffIdx = abilities_eff_CreateEff(waringEffArgs)
    end
    
    GenAbilityArgs(kv)

    kv.center = kv.center or (kv.target_points and kv.target_points[1])

    Timers:CreateTimer(GetAdditionValue(kv.delay_time, kv.caster), function()
        if kv.waringEffIdx then
            ParticleManager:DestroyParticle(kv.waringEffIdx, false)
            ParticleManager:ReleaseParticleIndex(kv.waringEffIdx)
        end

        for _,funName in ipairs(string.split(kv.delay_funs, "|")) do
            local DFArgs = GenArgs(kv, funName)
            DFArgs.caster = kv.caster
            DFArgs.Target = kv.Target
            DFArgs.target_points = kv.target_points
            DFArgs.target = kv.target
            _G[funName](DFArgs)
        end
    end)
end

function abilities_learn_ability(kv)
    local target = kv.target
    if target == nil and kv.Target == "CASTER" then
        target = kv.caster
    end
    LearnAbilities(target, kv.abilities)
end

function abilities_change_velocity(kv)
    local targetEnt = kv.target
    if targetEnt == nil and kv.Target == "CASTER" then
        targetEnt = kv.caster
    end

    if not IsValidEntity(targetEnt) or not targetEnt:IsAlive() then
        return
    end

    local addVelocity = kv.addVelocity
    if not addVelocity then
        if kv.hDir == "targetFow" then
            local addDir = nil
            addDir = targetEnt:GetForwardVector()
            addVelocity = addDir * tonumber(kv.hVelocity)
            addVelocity.z = tonumber(kv.vVelocity)
        elseif kv.chDir == "c2t" then
            local vec = (targetEnt:GetAbsOrigin() - kv.caster:GetAbsOrigin()):Normalized()
            if vec.z < 0 then 
                vec.z = 0.15 
            else
                vec.z = vec.z + 0.1
            end
            kv.speed = kv.speed and GetAdditionValue(kv.speed, kv.caster)
            kv.force = kv.force and GetAdditionValue(kv.force, kv.caster)
            addVelocity = vec * (kv.speed or (kv.force / targetEnt.costomAttribute.mass))
        end
    end
    targetEnt.costomAttribute.velocity = targetEnt.costomAttribute.velocity + addVelocity

    if kv.usePM then
        AppPhyMotion(targetEnt)
    end
end

function emit_sound(kv)
    if kv.emit_sound then
        local soundStrArr = string.split(kv.emit_sound, ",")
        if soundStrArr[1] == "onEnt" then
            EmitSoundOn(soundStrArr[3], kv[soundStrArr[2]])
        elseif soundStrArr[1] == "onLoc" then
            EmitSoundOnLocationWithCaster(kv.center or kv.target_points[1], soundStrArr[3], kv[soundStrArr[2]])
        end
    end
end

function stop_sound(kv)
    if kv.stop_sound then
        local soundStrArr = string.split(kv.stop_sound, ",")
        if soundStrArr[1] == "onEnt" then
            StopSoundOn(soundStrArr[3], kv[soundStrArr[2]])
        end
    end
end

function summon_round_unit(kv)
    local targetPos = kv.caster:GetAbsOrigin()
    local count = GetAdditionValue(kv.unit_count, kv.caster)
    local posRadius = GetAdditionValue(kv.unit_lockDis or kv.pos_radius, kv.caster)
    local firstPos = targetPos + Vector(posRadius, 0, 0)
    local angDif = 360 / count
    for i=1, count do
        local args = shallowcopy(kv)
        args.curlockAngle = angDif * (i - 1)
        args.spawnPos = RotatePosition(targetPos, QAngle(0, args.curlockAngle, 0), firstPos)
        local unit = SpawnCostomUnit(args)

        if unit.costomAttribute and unit.costomAttribute.unitType ~= COSTOM_UNIT_TYPE.GROUND then
            AppPhyMotion(unit)
        end
    end
end

function summon_line_unit(kv)
    local radius = GetAdditionValue(kv.unit_radius, kv.caster)
    local count = GetAdditionValue(kv.unit_count, kv.caster)
    local vec = (kv.ability.secPoint - kv.ability.firstPoint)
    vec.z = 0
    vec = vec:Normalized()
    for i=1, count do
        local args = shallowcopy(kv)
        args.spawnPos = kv.ability.firstPoint + ((i - 1) * vec * radius * 2)
        local unit = SpawnCostomUnit(args)
    end
end

function abilities_summon_unit(kv)
    local unit = SpawnCostomUnit(kv)
    if (unit.costomAttribute and unit.costomAttribute.unitType ~= COSTOM_UNIT_TYPE.GROUND and not kv.unit_noUsePM) or kv.unit_usePM then
        AppPhyMotion(unit)
    end
end

function abilities_timer_exc(kv)
    local timer = Timers:CreateTimer(function()
        
    end)
    if kv.ability then
        kv.ability.timer = timer
    end
end

function abilities_drop_item(kv)
    local dorpStrArr = string.split(kv.drop_item, ",")
    local itemArgs = {}
    if dorpStrArr[1] == "randomElement" then
        local v, ele = PickRandomValue(element_menu)
        itemArgs["item_element_" .. ele] = {tonumber(dorpStrArr[2]), {tonumber(dorpStrArr[3]), tonumber(dorpStrArr[4])}, tonumber(dorpStrArr[5]), tonumber(dorpStrArr[6]), dorpStrArr[6] ~= "0"}
    end

    DropItemByUnit(kv.caster, itemArgs)
end

function abilities_ray(kv)
    GenAbilityArgs(kv)

    kv.ability.ray = ability_ray.new(kv)
end

function AppPhyMotion(unit)
    local buffArgs = {}
    buffArgs.modifierName = "phy_motion"
    buffArgs.target = unit
    abilities_buff_target_buff(buffArgs)
end

function abilities_mutilple_cast(kv)
    if not kv.ability.timesCount then
        kv.ability.timesCount = 1
    else
        kv.ability.timesCount = kv.ability.timesCount + 1
    end
    GenAbilityArgs(kv)
    
    for _,funName in ipairs(string.split(kv.funs, "|")) do
        _G[funName](kv)
    end

    if kv.stepCooldown then
        kv.ability:StartCooldown(kv.stepCooldown)
    end

    if kv.ability.timesCount >= kv.castTimes then
        RemoveAbility(kv.caster, kv.ability)
    end
end

function abilities_line_cast(kv)
    if kv.ability.firstPoint then
        GenAbilityArgs(kv)
        
        kv.ability.secPoint = kv.target_points[1]
        for _,funName in ipairs(string.split(kv.funs, "|")) do
            _G[funName](kv)
        end
        
        RemoveAbility(kv.caster, kv.ability)
    else
        kv.ability.firstPoint = kv.target_points[1]
    end
end

function abilities_channel_cast(kv)
    GenAbilityArgs(kv)
    for _,funName in ipairs(string.split(kv.channel_funs, "|")) do
        _G[funName](kv)
    end
end

function abilities_channel_end(kv)
    RemoveAbility(kv.caster, kv.ability)
end

function abilities_project_cast(kv)
    if kv.ability.unit then
        abilities_project_launch(kv)
        return
    end
    GenAbilityArgs(kv)
    
    kv.startTime = GameRules:GetGameTime()
    kv.ability.unit = SpawnCostomUnit(kv)
    AppPhyMotion(kv.ability.unit)

    kv.channelTimer = Timers:CreateTimer(function()
        if not IsValidEntity(kv.ability.unit) or not kv.ability.unit:IsAlive() then
            kv.ability.unit = nil
            RemoveAbility(kv.caster, kv.ability)
            return
        end
        if not IsValidEntity(kv.caster) or not kv.caster:IsAlive() or kv.caster:IsStunned() then
            abilities_project_launch(kv)
            return
        end
        GenChannelRate(kv, true)
        kv.ability.unit.costomAttribute:UpdateCostom(kv)
        return 0.1
    end)
end

function abilities_project_launch(kv)
    if kv.channelTimer then
        Timers:RemoveTimer(kv.channelTimer)
    end
    if IsValidEntity(kv.ability.unit) and kv.ability.unit:IsAlive() then
        local soundArgs = GenArgs(kv, "project")
        soundArgs.caster = kv.ability.unit
        emit_sound(soundArgs)

        local vec = (kv.target_points[1] - kv.caster:GetAbsOrigin())
        vec.z = 0

        kv.ability.unit.costomAttribute.velocity = vec:Normalized() * GetAdditionValue(kv.project_speed, kv.caster) * kv.ability.unit.costomAttribute.args.channelRate
        kv.ability.unit.costomAttribute.lockUnit = nil
        kv.ability.unit = nil
    end

    if IsValidEntity(kv.ability) then
        RemoveAbility(kv.caster, kv.ability)
    end
end