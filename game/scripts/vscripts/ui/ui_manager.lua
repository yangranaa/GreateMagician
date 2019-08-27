if ui_manager == nil then
	_G.ui_manager = class({})
end

ui_manager.toolUnit = {[DOTA_TEAM_GOODGUYS] = {}, [DOTA_TEAM_BADGUYS] = {}}
function ui_manager.ShowErrorMsg(playerID, errMsg)
    local data = {}
    data.errMsg = errMsg
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "show_error_msg", data)
end

function ui_manager.GetAbilityIns(abilityName, team)
    local findAbility = nil
    if #ui_manager.toolUnit[team] == 0 then
        table.insert(ui_manager.toolUnit[team], CreateUnitByName("abilities_unit", Vector(9999, 9999, 0), false, nil, nil, team))
    end

    for _, unit in ipairs(ui_manager.toolUnit[team]) do
        findAbility = unit:FindAbilityByName(abilityName)
        if findAbility then
            break
        end
    end
    if not findAbility then
        local toolUnit = ui_manager.toolUnit[team][#ui_manager.toolUnit[team]]
        findAbility = toolUnit:AddAbility(abilityName)
        if not findAbility then
            table.insert(ui_manager.toolUnit[team], CreateUnitByName("abilities_unit", Vector(-9999, -9999, 0), false, nil, nil, team))
            toolUnit = ui_manager.toolUnit[team][#ui_manager.toolUnit[team]]
            findAbility = toolUnit:AddAbility(abilityName)
        end
        findAbility:SetLevel(1)
    end

    return findAbility
end

function ui_manager.ClearElement(unitID)
    local data = {}
    data.unitID = unitID
    CustomGameEventManager:Send_ServerToAllClients("clear_element", data)
end

function ui_manager.AddElementCast(unitID, element)
    local data = {}
    data.unitID = unitID
    data.element = element
    CustomGameEventManager:Send_ServerToAllClients("add_element_cast", data)
end

function ui_manager.RegisterElementCast(unitID)
    local data = {}
    data.unitID = unitID
    CustomGameEventManager:Send_ServerToAllClients("register_element_cast", data)
end

function ui_manager.RegisterAttributeTip()
    ui_manager.AttributeTipLisID = CustomGameEventManager:RegisterListener("attribute_tip", ui_manager.OnShowAttributeTip)
end

function ui_manager.OnShowAttributeTip(number, args)
    local unit = EntIndexToHScript(args.unitID)
    local data = {}
    if unit.costomAttribute then
        data.coefficient = {}
        for element, _ in pairs(element_menu) do
            data.coefficient[element] = GetCoefficient(element, unit)
        end

        data.info = {}
        if unit.gift then
            table.insert(data.info, {"gift", unit.gift})
        end
    else
        data.hide = 1
    end

    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(tonumber(args.PlayerID)), "attribute_tip", data)
end

function ui_manager.RegisterShopBuy()
    ui_manager.ShopBuyLisID = CustomGameEventManager:RegisterListener("item_buy", ui_manager.OnItemBuy)
end

function ui_manager.OnItemBuy(number, args)
    local playerID = tonumber(args.PlayerID)
    if PlayerResource:GetGold(playerID) >= ELEMENT_GOLD_COST then
        local player = PlayerResource:GetPlayer(playerID)
        PlayerResource:SpendGold(playerID, ELEMENT_GOLD_COST, DOTA_ModifyGold_AbilityCost)
        local itemArgs = {}
        itemArgs["item_element_" .. args.ele] = {1, {1, 1}, nil, nil, true}
        DropItemByUnit(player:GetAssignedHero(), itemArgs)
    else

    end
end

function ui_manager.CloseHeroSelectView(playerID)
    CustomUI:DynamicHud_Destroy(playerID, "hero_select")
end

function ui_manager.ShowHeroSelectView(playerID)
    ui_manager.CloseHeroSelectView(playerID)
    CustomUI:DynamicHud_Create(playerID, "hero_select", "file://{resources}/layout/custom_game/hero_select.xml", nil)
    local heroData = player_manager.playerDatas[playerID].heroData
    local data = {}
    data.selHero = heroData.selHero
    data.heroList = heroData.heroList
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "hero_select", data)
    if not ui_manager.heroSelLisID then
        ui_manager.heroSelLisID = CustomGameEventManager:RegisterListener("hero_select", ui_manager.OnHeroSelect)
    end
end

function ui_manager.OnHeroSelect(number, args)
    local heroData = player_manager.playerDatas[tonumber(args.PlayerID)].heroData
    heroData.selHero = tonumber(args.selHero)
end

function ui_manager.UpdateAbilitiesView(playerID)
    local player = PlayerResource:GetPlayer(playerID)
    local hero = player:GetAssignedHero()

    local data = {}
    data["itemEntIdx"] = {}
    for ele,_ in pairs(element_menu) do
        local item = GetInventoryItem(hero, "item_" .. ele)
        data["itemEntIdx"][ele] = item:GetEntityIndex()
    end

    data["combAbilityEntIdx"] = hero:FindAbilityByName("elementComp"):GetEntityIndex()

    data["abilitiesData"] = {}
    for eles, abilityName in pairs(player_manager.playerDatas[playerID].acquireAbilities) do
        local abilityData = {}
        abilityData.name = abilityName
        abilityData.eles = eles
        abilityData.entIdx = ui_manager.GetAbilityIns(abilityName, PlayerResource:GetTeam(playerID)):GetEntityIndex()
        table.insert(data["abilitiesData"], abilityData)
    end

    table.sort(data["abilitiesData"], function(a, b)
        return #string.split(a.eles, "A") < #string.split(b.eles, "A")
    end)

    CustomGameEventManager:Send_ServerToPlayer(player, "refresh_abilities_view", data)
end

function ui_manager.UpdateScoreBoardView(playerID, newData)
    local player = PlayerResource:GetPlayer(playerID)
    if not player then return end

    local data = {}
    
    if not newData and score_manager.scoreDatas then 
        for playerid, scoreData in pairs(score_manager.scoreDatas) do
            local team = PlayerResource:GetTeam(playerid)
            if not data[team] then
                data[team] = {}
            end
            data[team][playerid] = scoreData
        end
        CustomGameEventManager:Send_ServerToPlayer(player, "refresh_score_board_view", data)
    else
        local team = player:GetTeamNumber()
        data[team] = {}
        data[team][playerID] = {}

        for k,v in pairs(newData) do
            data[team][playerID][k] = v
        end
        CustomGameEventManager:Send_ServerToAllClients("refresh_score_board_view", data)
    end 
end

function ui_manager.RegisterCommentReresh()
    Timers:CreateTimer(function()
        if player_manager.RefreshCommentTime == nil or GameRules:GetGameTime() - player_manager.RefreshCommentTime >= 120 then
            player_manager.RefreshCommentData()
        end
        return 120
    end)

    ui_manager.refreshCommentDataLisID = CustomGameEventManager:RegisterListener("refresh_comment_data", player_manager.RefreshCommentData)
    ui_manager.publishCommentLisID = CustomGameEventManager:RegisterListener("publish_comment", ui_manager.PublishComment)
    ui_manager.supportCommentLisID = CustomGameEventManager:RegisterListener("support_comment", ui_manager.SupportComment)
end

function ui_manager.SupportComment(number, args)
    local curATime = player_manager.GetCurrentATime()
    if curATime == nil then return end
    if curATime.value - player_manager.playerDatas[tonumber(args.PlayerID)].supportTime < 86400 then
        ui_manager.ShowErrorMsg(tonumber(args.PlayerID), "supportCD")
        return
    end

    local localData = player_manager.GetLocalCharData(args.PlayFabId, args.CharacterId)
    local dataTab = {}
    dataTab.support = localData.comment.support.Value + 1
    player_manager.UpdateCharacterData(args.PlayFabId, args.CharacterId, dataTab, function(upSuc)
        if upSuc then
            local staticData = {comment_hot = dataTab.support}
            player_manager.UpdateCharacterStatistics(args.PlayFabId, args.CharacterId, staticData, function(upStaticSuc)
                local changeData = {supportTime = curATime.value}
                player_manager.ChangePlayerData(tonumber(args.PlayerID), changeData)
            end)
        end
    end)
end

function ui_manager.PublishComment(number, args)
    player_manager.AddNewComment(tonumber(args.PlayerID), args.comment)
end

function ui_manager.RefreshCommentView(PlayFabId, CharacterId)
    local data = player_manager.GetLocalCharData(PlayFabId, CharacterId)
    CustomGameEventManager:Send_ServerToAllClients("refresh_comment_view", data)
end

function ui_manager.RegisterRankReresh()
    Timers:CreateTimer(function()
        if ui_manager.RefreshRankTime == nil or GameRules:GetGameTime() - ui_manager.RefreshRankTime >= 50 then
            player_manager.GetLeaderboard("rank")
            ui_manager.RefreshRankTime = GameRules:GetGameTime()
        end

        for playerID, _ in pairs(player_manager.playerDatas) do
            if PlayerResource:GetPlayer(playerID) then
                player_manager.GetLeaderboardAroundUser(playerID, "rank")
            end
        end

        return 50
    end)
end

function ui_manager.RefreshRankView(playerData)
    local data = playerData or player_manager.rankList
    CustomGameEventManager:Send_ServerToAllClients("refresh_rank_view", data)
end

function ui_manager.ShowGameEndView(winTeam)
    player_manager.GetCurrentATime()
    local winDay = player_manager.cacheAccountTime[1] * 10000 + player_manager.cacheAccountTime[2] * 100 + player_manager.cacheAccountTime[3] + 1
    local loseTeam = winTeam == DOTA_TEAM_GOODGUYS and DOTA_TEAM_BADGUYS or DOTA_TEAM_GOODGUYS
    local data = {}
    for playerID, scoreData in pairs(score_manager.scoreDatas) do
        if not data[PlayerResource:GetTeam(playerID)] then
            data[PlayerResource:GetTeam(playerID)] = {}
        end
        data[PlayerResource:GetTeam(playerID)][playerID] = scoreData
        data[PlayerResource:GetTeam(playerID)][playerID].rank = 0
        data[PlayerResource:GetTeam(playerID)][playerID].crystal = 0
    end

    local teamValue = {[DOTA_TEAM_GOODGUYS] = {valueCount = 0, playerCount = 0}, [DOTA_TEAM_BADGUYS] = {valueCount = 0, playerCount = 0}}
    for playerID, playerData in pairs(player_manager.playerDatas) do
        if playerData.rankData then       
            teamValue[PlayerResource:GetTeam(playerID)].valueCount = teamValue[PlayerResource:GetTeam(playerID)].valueCount + playerData.rankData.value
            teamValue[PlayerResource:GetTeam(playerID)].playerCount = teamValue[PlayerResource:GetTeam(playerID)].playerCount + 1
        end
    end

    if teamValue[loseTeam].valueCount == 0 or teamValue[loseTeam].playerCount == 0 then
        CustomGameEventManager:Send_ServerToAllClients("show_end_view", data)
        return
    end

    local valueRate = (teamValue[winTeam].valueCount / teamValue[loseTeam].valueCount) <= 0.9 and 0.03 or 0.02
    local baseValue = teamValue[loseTeam].valueCount / teamValue[winTeam].playerCount * valueRate
    for playerID, playerData in pairs(player_manager.playerDatas) do
        if playerData.rankData then
            local playerTeam = PlayerResource:GetTeam(playerID)
            if winTeam == playerTeam then
                data[playerTeam][playerID].rank = (1 + (1 / teamValue[playerTeam].playerCount - playerData.rankData.value / teamValue[playerTeam].valueCount)) * baseValue
                local upData = {}
                if playerData.winCrystalDay ~= winDay then
                    upData.winCrystalDay = winDay
                    upData.winCrystal = 1
                else
                    if playerData.winCrystal < DAY_MAX_WIN_CRYSTAL then
                        upData.winCrystal = playerData.winCrystal + 1
                    end
                end
                if upData.winCrystal then
                    upData.crystal = playerData.crystal + 1
                     data[PlayerResource:GetTeam(playerID)][playerID].crystal = 1
                end
                if TableCount(upData) > 0 then
                    player_manager.ChangePlayerData(playerID, upData)
                end
            else
                data[playerTeam][playerID].rank = -(1 - (1 / teamValue[playerTeam].playerCount - playerData.rankData.value / teamValue[playerTeam].valueCount)) * baseValue
            end
            data[playerTeam][playerID].rank = math.ceil(data[playerTeam][playerID].rank)
            player_manager.PlayerStatisticsChange(playerID, "rank", data[playerTeam][playerID].rank + playerData.rankData.value)
        end
    end

    CustomGameEventManager:Send_ServerToAllClients("show_end_view", data)
end

function ui_manager.RegisterNpcBubble(playerID)
    local data = {}
    for _, unit in pairs(spawner_manager.npcCache) do
        data[unit:GetEntityIndex()] = unit.type.insName
    end
    
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "register_bubble", data)
end

function ui_manager.RegisterSpeechEvent()
    ui_manager.speechEventLisID = CustomGameEventManager:RegisterListener("speech_event", ui_manager.HandleSpeechEvent)
end

function ui_manager.HandleSpeechEvent(num, data)
    local playerID = tonumber(data.PlayerID)
    if not player_manager.playerDatas[playerID] or not player_manager.playerDatas[playerID].crystal then
        ui_manager.ShowErrorMsg(playerID, "no_user_data")
        return
    end

    if data.op == "buy_ability" then
        if player_manager.playerDatas[playerID].crystal < ABILITY_CRYSTAL_COST then
            ui_manager.ShowErrorMsg(playerID, "no_enough_crystal")
            return
        end

        local elements, newAbility = gift_manager.GetCanLearnAbility(playerID)
        if not elements then
            ui_manager.ShowErrorMsg(playerID, "all_learned")
            return
        end
        player_manager.AddPlayerAbilities(playerID, {newAbility})
        local effArgs = {}
        effArgs.eff = "particles/xuexijineng.vpcf"
        effArgs.cps = "ent,0,target,PATTACH_ABSORIGIN_FOLLOW,attach_hitloc"
        effArgs.target = PlayerResource:GetPlayer(playerID):GetAssignedHero()
        effArgs.autoDel = "5"
        abilities_eff_CreateEff(effArgs)

        local changeData = {crystal = player_manager.playerDatas[playerID].crystal - ABILITY_CRYSTAL_COST}
        player_manager.ChangePlayerData(playerID, changeData)
    elseif data.op == "buy_gift" then
        if player_manager.playerDatas[playerID].crystal < GIFT_CRYSTAL_COST then
            ui_manager.ShowErrorMsg(playerID, "no_enough_crystal")
            return
        end
        
        local gift = gift_manager.GetUnlockGift(playerID)
        if not gift then
            ui_manager.ShowErrorMsg(playerID, "all_gift_unlock")
            return
        end
        player_manager.AddPlayerGifts(playerID, {gift}, true)
        local effArgs = {}
        effArgs.eff = "particles/xuexijineng.vpcf"
        effArgs.cps = "ent,0,target,PATTACH_ABSORIGIN_FOLLOW,attach_hitloc"
        effArgs.target = PlayerResource:GetPlayer(playerID):GetAssignedHero()
        effArgs.autoDel = "5"
        abilities_eff_CreateEff(effArgs)

        local changeData = {crystal = player_manager.playerDatas[playerID].crystal - GIFT_CRYSTAL_COST}
        player_manager.ChangePlayerData(playerID, changeData)
    elseif data.op == "take_crystal" then
        local curATime = player_manager.GetCurrentATime()
        local rankData = player_manager.playerDatas[playerID] and player_manager.playerDatas[playerID].rankData
        if not curATime or not rankData then
            ui_manager.ShowErrorMsg(playerID, "no_user_data")
            return
        end

        local takeValue = 0
        local takeTime = curATime.value
        if player_manager.playerDatas[playerID].takeCrystalTime == 0 then
            takeValue = 150
        else
            local dayV = rankData.pos < 1000 and 3 or rankData.pos < 10000 and 2 or 1
            local intV, floatV = math.modf((curATime.value - player_manager.playerDatas[playerID].takeCrystalTime) / 86400)
            takeValue = dayV * intV
            takeTime = math.floor(curATime.value - floatV * 86400)
        end

        if takeValue <= 0 then
            ui_manager.ShowErrorMsg(playerID, "less_to_take")
            return
        end
    
        ui_manager.AddScrollMsg({key="award_suc", args = {playerName = PlayerResource:GetPlayerName(playerID), crystal = takeValue} })

        local effArgs = {}
        effArgs.eff = "particles/crystal_get.vpcf"
        effArgs.cps = "ent,0,target,PATTACH_OVERHEAD_FOLLOW,attach_hitloc"
        effArgs.target = PlayerResource:GetPlayer(playerID):GetAssignedHero()
        effArgs.autoDel = "2"
        abilities_eff_CreateEff(effArgs)

        local changeData = {crystal = player_manager.playerDatas[playerID].crystal + takeValue, takeCrystalTime = takeTime}
        player_manager.ChangePlayerData(playerID, changeData)
    end
end

function ui_manager.UpdateDynamic(playerID)
    local data = {}
    data.crystal = player_manager.playerDatas[playerID].crystal
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "update_dynamic", data)
end

function ui_manager.UpdateResouceView(data)
    CustomGameEventManager:Send_ServerToAllClients("update_resource_view", data)
end

function ui_manager.AddScrollMsg(msg, playerID)
    local data = {}
    data.msg = msg
    if playerID then
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "add_scroll_msg", data)
    else
        CustomGameEventManager:Send_ServerToAllClients("add_scroll_msg", data)
    end
end

function ui_manager.ShowUIEff(playerID, data)
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "show_ui_eff", data)
end

function ui_manager.UpdatePointScore(point, score)
    local data = {score = score}
    CustomGameEventManager:Send_ServerToAllClients(point .. "_SCORE", data)
end

ui_manager.preViewUnits = {}
function ui_manager.InitPreviewUnit()
    local unitNames = {
        "mine_unit",
        "tower_unit",
        "zhenchashouwei_unit",
    }
    for i,unitName in pairs(unitNames) do
        if ui_manager.preViewUnits[unitName] == nil then
            ui_manager.preViewUnits[unitName] = CreateUnitByName(unitName, Vector(0, 0, 0), false, nil, nil, DOTA_TEAM_NEUTRALS)
            ui_manager.preViewUnits[unitName]:AddNewModifier(nil, nil, "modifier_preview_model", {})
        end
    end
    local data = {}
    for unitName, ent in pairs(ui_manager.preViewUnits) do
        data[unitName] = ent:GetEntityIndex()
    end
    CustomGameEventManager:Send_ServerToAllClients("preview_unit_cache", data)
end

function ui_manager.UpdateLocalPlayerData(playerID)
    local player = PlayerResource:GetPlayer(playerID)
    if not player then return end
    local data = {}
    data.coefficient = player:GetAssignedHero().costomAttribute.coefficient

    CustomGameEventManager:Send_ServerToPlayer(player, "update_local_data", data)
end

function ui_manager.Init()
    ui_manager.RegisterAttributeTip()
    ui_manager.RegisterShopBuy()
    ui_manager.RegisterCommentReresh()
    ui_manager.RegisterRankReresh()
    ui_manager.RegisterSpeechEvent()
end

ui_manager.Init()