if player_manager == nil then
	_G.player_manager = class({})
end

function player_manager.Init()
    player_manager.infoTargets = {}
    for k,v in pairs(Entities:FindAllByClassname("info_target")) do
        player_manager.infoTargets[k] = v
        local len = #v:GetName()
        if len > 0 and len < 20 then
            player_manager.tid = v:GetName()
        elseif len > 20 then
            player_manager.SessionTicket = v:GetName()
        end
    end
    player_manager.playerDatas = {}
end

function player_manager.AddPlayerGifts(playerID, gifts, unSave)
    if not player_manager.playerDatas[playerID].heroData then
        player_manager.playerDatas[playerID].heroData = {}
        player_manager.playerDatas[playerID].heroData.selHero = 1
        player_manager.playerDatas[playerID].heroData.heroList = {}
    end

    for _, gift in pairs(gifts) do
        table.insert(player_manager.playerDatas[playerID].heroData.heroList, gift)
    end

    if not unSave then
        player_manager.SaveAllDataToServer(playerID)
    end
end

function player_manager.AddPlayerAbilities(playerID, abilities, unSave)
    if not player_manager.playerDatas[playerID].acquireAbilities then
        player_manager.playerDatas[playerID].acquireAbilities = {}
    end

    for _, abilityName in pairs(abilities) do
        player_manager.playerDatas[playerID].acquireAbilities[ABILITY_TO_ELEMENTS[abilityName]] = abilityName
    end

    if not unSave then
        player_manager.SaveAllDataToServer(playerID)
        ui_manager.UpdateAbilitiesView(playerID)
    end
end

function player_manager.InitPlayerData(playerID)
    ui_manager.RegisterNpcBubble(playerID)

    if player_manager.playerDatas[playerID] == nil then
        player_manager.playerDatas[playerID] = {}
    else
        -- reconnect
        local player = PlayerResource:GetPlayer(playerID)
        
        ui_manager.UpdateScoreBoardView(playerID)
        ui_manager.RefreshRankView()
        player_manager.RefreshCommentData()
        ui_manager.UpdateAbilitiesView(playerID)
        ui_manager.UpdateDynamic(playerID)

        for pid, _ in pairs(player_manager.playerDatas) do
            local onLinePlayer = PlayerResource:GetPlayer(pid)
            if onLinePlayer then
                ui_manager.RegisterElementCast(onLinePlayer:GetAssignedHero():GetEntityIndex())
            end
        end
        return
    end

    player_manager.LoginToDataServer(playerID)
end

function player_manager.RefreshCommentData(number, args)
    player_manager.RefreshCommentTime = GameRules:GetGameTime()
    local startPos = args and args.startPos
    player_manager.GetCharacterLeaderboard("comment_new", startPos)
    player_manager.GetCharacterLeaderboard("comment_hot", startPos)
end

function player_managerOnGen()
    -- body
end

function player_manager.LoginToDataServer(playerID)
    local req = player_manager.CreateReqHead("Server", "LoginWithServerCustomId")

    local loginData = {}
    loginData.ServerCustomId = tostring(PlayerResource:GetSteamID(playerID))
    loginData.CreateAccount = true
    loginData.TitleId = player_manager.tid
    loginData.InfoRequestParameters = {GetPlayerStatistics=true,GetCharacterList=true,GetUserData =true}

    req:SetHTTPRequestRawPostBody("application/json", json.encode(loginData))
    req:Send(function(res)
        local loginRes = json.decode(res.Body)
        if loginRes and loginRes.code == 200 then
            player_manager.playerDatas[playerID].SessionTicket = loginRes.data.SessionTicket
            player_manager.playerDatas[playerID].playFabID = loginRes.data.PlayFabId
            player_manager.playerDatas[playerID].newly = loginRes.data.NewlyCreated
            
            player_manager.ParsePlayerStatistics(playerID, loginRes.data.InfoResultPayload.PlayerStatistics)
            player_manager.ParseAllUsersCharacters(playerID, loginRes.data.InfoResultPayload.CharacterList)
            player_manager.ParsePlayerData(playerID, loginRes.data.InfoResultPayload.UserData)

            player_manager.GetLeaderboardAroundUser(playerID, "rank")
        else
            player_manager.LoginToDataServer(playerID)
        end
    end)
end

function player_manager.SaveAllDataToServer(playerID)
    local req = player_manager.CreateReqHead("Client", "UpdateUserData", playerID)

    local saveData = {}
    saveData.data = {}
    saveData.Permission = "Public"

    local abilities = {}
    for elements, abilityName in pairs(player_manager.playerDatas[playerID].acquireAbilities) do
        table.insert(abilities, abilityName)
    end
    saveData.data.acquireAbilities = json.encode(abilities)
    saveData.data.heroData = json.encode(player_manager.playerDatas[playerID].heroData)
    local baseData = {}
    baseData.commentCount = player_manager.playerDatas[playerID].commentCount
    baseData.supportTime = player_manager.playerDatas[playerID].supportTime
    baseData.crystal = player_manager.playerDatas[playerID].crystal
    baseData.takeCrystalTime = player_manager.playerDatas[playerID].takeCrystalTime
    baseData.winCrystal = player_manager.playerDatas[playerID].winCrystal
    baseData.winCrystalDay = player_manager.playerDatas[playerID].winCrystalDay
    saveData.data.baseData = json.encode(baseData)
    req:SetHTTPRequestRawPostBody("application/json", json.encode(saveData))
    req:Send(function(res)
        local saveRes = json.decode(res.Body)
        if saveRes and saveRes.code == 200 then

        else
            if player_manager.playerDatas[playerID].needSave then
                player_manager.SaveAllDataToServer(playerID)
            end
        end
    end)

    ui_manager.UpdateDynamic(playerID)
end

function player_manager.ParsePlayerData(playerID, data)
    if data.baseData then
        local baseData = json.decode(data.baseData.Value)
        player_manager.playerDatas[playerID].crystal = tonumber(baseData.crystal)
        player_manager.playerDatas[playerID].takeCrystalTime = tonumber(baseData.takeCrystalTime)
        player_manager.playerDatas[playerID].supportTime = tonumber(baseData.supportTime)
        player_manager.playerDatas[playerID].commentCount = tonumber(baseData.commentCount)
        player_manager.playerDatas[playerID].winCrystal = tonumber(baseData.winCrystal)
        player_manager.playerDatas[playerID].winCrystalDay = tonumber(baseData.winCrystalDay)
    end
    player_manager.playerDatas[playerID].crystal = player_manager.playerDatas[playerID].crystal or 20
    player_manager.playerDatas[playerID].takeCrystalTime = player_manager.playerDatas[playerID].takeCrystalTime or 0
    player_manager.playerDatas[playerID].supportTime = player_manager.playerDatas[playerID].supportTime or 0
    player_manager.playerDatas[playerID].commentCount = player_manager.playerDatas[playerID].commentCount or 0
    player_manager.playerDatas[playerID].winCrystal = player_manager.playerDatas[playerID].winCrystal or 0
    player_manager.playerDatas[playerID].winCrystalDay = player_manager.playerDatas[playerID].winCrystalDay or 0

    -------------------------------------------------------------------
    if data.heroData then
        player_manager.playerDatas[playerID].heroData = json.decode(data.heroData.Value)
    end
    if player_manager.playerDatas[playerID].heroData == nil then
        player_manager.AddPlayerGifts(playerID, gift_manager.GetDefaultGift(), true)
    end

    if data.acquireAbilities then
        player_manager.AddPlayerAbilities(playerID, json.decode(data.acquireAbilities.Value), true)
    end

    if player_manager.playerDatas[playerID].acquireAbilities == nil then
        player_manager.AddPlayerAbilities(playerID, gift_manager.GetDefaultAbilities(), true)
    end
    -------------------------------------------------------------------

    if GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        ui_manager.ShowHeroSelectView(playerID)
    else
        local showSelFun = function(gameState)
            if gameState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
                ui_manager.ShowHeroSelectView(playerID)
            end
        end
        my_event.RegisterListener("game_rules_state_change", showSelFun, 1)
    end

    local player = PlayerResource:GetPlayer(playerID)

    player:SetContextThink("change_hero" .. tostring(playerID),
        function()
            if player:GetAssignedHero() ~= nil then
                local heroData = player_manager.playerDatas[playerID].heroData
                local selHero = heroData.selHero
                local unitName = heroData.heroList[selHero].unitName
                local gift = heroData.heroList[selHero].gift
                local oldHero = player:GetAssignedHero()
                PlayerResource:ReplaceHeroWith(playerID, unitName, 0, 0)
                oldHero:RemoveSelf()
                --player:GetAssignedHero():SetModel(skinModel)
                --player:GetAssignedHero():SetOriginalModel(skinModel)
                --player:GetAssignedHero():ManageModelChanges()
                --player:GetAssignedHero():SetFixedRespawnTime(0)
                --NotifyWearablesOfModelChange

                local unit = player:GetAssignedHero()
                local args = gift_manager.GenUnitGiftArgs(unit, gift)
                
                for i=0, unit:GetAbilityCount() - 1 do
                    local ability = unit:GetAbilityByIndex(i)
                    if ability then
                        ability:SetLevel(1)
                    end
                end
                
                local item = unit:GetItemInSlot(15)
                if item then
                    unit:RemoveItem(item)
                end
                unit:AddItemByName("item_show_abilities")
                unit:SwapItems(0, 15)

                SpawnCostomUnit(args)
                element_comb.AddUnit(unit)
                scene_manager:CacheHero(unit)
                score_manager.UpdatePlayerScore(playerID)

                ui_manager.UpdateAbilitiesView(playerID)
                player_manager.SaveAllDataToServer(playerID)
                return nil
            end
            return 0.1
        end,
    1)
end

-- function player_manager.GetPlayerData(playerID)
--     local req = player_manager.CreateReqHead("Client", "GetUserData", playerID)

--     local getParms = {}
--     getParms.Keys = {}
--     table.insert(getParms.Keys, "acquireAbilities")
--     table.insert(getParms.Keys, "heroData")
--     table.insert(getParms.Keys, "commentCount")
--     table.insert(getParms.Keys, "supportTime")
--     req:SetHTTPRequestRawPostBody("application/json", json.encode(getParms))
    
--     req:Send(function(res)
--         local reciveDatas = json.decode(res.Body)
--         if reciveDatas == nil or reciveDatas.code ~= 200 then 
--             player_manager.GetPlayerData(playerID)
--             return
--         end

--         player_manager.ParsePlayerData(playerID, reciveDatas.data.Data)
--     end)
-- end

function player_manager.ParseAllUsersCharacters(playerID, data)
    player_manager.playerDatas[playerID].Characters = data
end

-- function player_manager.GetAllUsersCharacters(playerID)
--     local req = player_manager.CreateReqHead("Server", "GetAllUsersCharacters")

--     local reqData = {}
--     reqData.PlayFabId = player_manager.playerDatas[playerID].playFabID

--     req:SetHTTPRequestRawPostBody("application/json", json.encode(reqData))
--     req:Send(function(res)
--         local getRes = json.decode(res.Body)
--         if getRes and getRes.code == 200 then
--             player_manager.ParseAllUsersCharacters(playerID, getRes.data.Characters)
--         else
--             player_manager.GetAllUsersCharacters(playerID)
--         end
--     end)
-- end

function player_manager.GetLeaderboardAroundUser(playerID, rank)
    if not player_manager.playerDatas[playerID] or not player_manager.playerDatas[playerID].playFabID then
        return
    end

    local req = player_manager.CreateReqHead("Server", "GetLeaderboard")
    local reqData = {}
    reqData.StatisticName = rank or "rank"
    reqData.MaxResultsCount = 1
    reqData.PlayFabId = player_manager.playerDatas[playerID].playFabID
    reqData.ProfileConstraints = {ShowLinkedAccounts  = true}

    req:SetHTTPRequestRawPostBody("application/json", json.encode(reqData))
    req:Send(function(res)
        local reqRes = json.decode(res.Body)
        if reqRes and reqRes.code == 200 then

            local recData = reqRes.data.Leaderboard[1]
            player_manager.playerDatas[playerID].rankData = {}
            player_manager.playerDatas[playerID].rankData.pos = recData.Position
            player_manager.playerDatas[playerID].rankData.value = recData.StatValue
            player_manager.playerDatas[playerID].rankData.playerID = playerID
            player_manager.playerDatas[playerID].rankData.steamID = recData.Profile.LinkedAccounts[1].PlatformUserId
            ui_manager.RefreshRankView(player_manager.playerDatas[playerID].rankData)
        else
            player_manager.GetLeaderboardAroundUser(playerID, rank)
        end
    end)
end

function player_manager.GetLeaderboard(rank)
    local req = player_manager.CreateReqHead("Server", "GetLeaderboard")
    local reqData = {}
    reqData.StartPosition = 0
    reqData.StatisticName = rank or "rank"
    reqData.MaxResultsCount = 20
    reqData.ProfileConstraints = {ShowTotalValueToDateInUsd  = true, ShowLinkedAccounts  = true}

    req:SetHTTPRequestRawPostBody("application/json", json.encode(reqData))
    req:Send(function(res)
        local reqRes = json.decode(res.Body)
        if reqRes and reqRes.code == 200 then
            player_manager.rankList = {}
            for i,v in ipairs(reqRes.data.Leaderboard) do
                local rankData = {}
                rankData.pos = v.Position
                rankData.value = v.StatValue
                rankData.steamID = v.Profile.LinkedAccounts[1].PlatformUserId
                player_manager.rankList[i] = rankData
            end
            ui_manager.RefreshRankView()
        else
            player_manager.GetLeaderboard(rank)
        end
    end)
end

function player_manager.ChangePlayerData(playerID, dataTab)
    for k,v in pairs(dataTab) do
        player_manager.playerDatas[playerID][k] = v
    end
    player_manager.SaveAllDataToServer(playerID)
end

----------------------playerStatistice

function player_manager.ParsePlayerStatistics(playerID, data)
    player_manager.playerDatas[playerID].Statistics = data
    if #player_manager.playerDatas[playerID].Statistics == 0 then
        player_manager.playerDatas[playerID].Statistics = {
            {
                StatisticName = "rank",
                Value = 1000
            }
        }
        player_manager.UpdatePlayerStatistics(playerID)
    end
end

-- function player_manager.GetPlayerStatistics(playerID)
--     local req = player_manager.CreateReqHead("Server", "GetPlayerStatistics")

--     local reqData = {}
--     reqData.PlayFabId = player_manager.playerDatas[playerID].playFabID
--     reqData.StatisticNames = {
--         "rank"
--     }

--     req:SetHTTPRequestRawPostBody("application/json", json.encode(reqData))
--     req:Send(function(res)
--         local reqRes = json.decode(res.Body)
--         if reqRes and reqRes.code == 200 then
--             player_manager.ParsePlayerStatistics(playerID, reqRes.data.Statistics)
--         else
--             player_manager.GetPlayerStatistics(playerID)
--         end
--     end)
-- end

function player_manager.UpdatePlayerStatistics(playerID)
    local req = player_manager.CreateReqHead("Server", "UpdatePlayerStatistics")
    local saveData = {}
    saveData.PlayFabId = player_manager.playerDatas[playerID].playFabID
    saveData.Statistics = player_manager.playerDatas[playerID].Statistics

    req:SetHTTPRequestRawPostBody("application/json", json.encode(saveData))
    req:Send(function(res)
        local saveRes = json.decode(res.Body)
        if saveRes and saveRes.code == 200 then

        else
            player_manager.UpdatePlayerStatistics(playerID)
        end
    end)
end

function player_manager.PlayerStatisticsChange(playerID, StatisticName, value)
    for i, statistics in ipairs(player_manager.playerDatas[playerID].Statistics) do
        if statistics.StatisticName == StatisticName then
            statistics.Value = value
        end
    end
    player_manager.UpdatePlayerStatistics(playerID)
end
--------------------------------------------

------------------------------------character------------------------------
function player_manager.GrantCharacterToUser(playerID, CharacterName, CharacterType, callBack)
    local req = player_manager.CreateReqHead("Server", "GrantCharacterToUser")

    local reqData = {}
    reqData.PlayFabId = player_manager.playerDatas[playerID].playFabID
    reqData.CharacterName = CharacterName
    reqData.CharacterType = CharacterType

    req:SetHTTPRequestRawPostBody("application/json", json.encode(reqData))
    req:Send(function(res)
        local saveRes = json.decode(res.Body)
        if saveRes and saveRes.code == 200 then
            table.insert(player_manager.playerDatas[playerID].Characters, {
                CharacterId = saveRes.data.CharacterId,
                CharacterName = CharacterName,
                CharacterType = CharacterType,
            })
            if callBack then
                callBack()
            end
        else
            player_manager.GrantCharacterToUser(playerID, CharacterName, CharacterType, callBack)
        end
    end)
end

function player_manager.GetLocalCharData(PlayFabId, CharacterId)
    return player_manager.cacheCharData[PlayFabId] and player_manager.cacheCharData[PlayFabId][CharacterId]
end

function player_manager.GetCharacterData(PlayFabId, CharacterId, getTime)
    if getTime < player_manager.lastGetRankTime then
        return
    end

    local req = player_manager.CreateReqHead("Server", "GetCharacterData")

    local reqData = {}
    reqData.PlayFabId = PlayFabId
    reqData.CharacterId = CharacterId
    reqData.Keys = {"comment", "timeStr", "support", "steamID"}

    req:SetHTTPRequestRawPostBody("application/json", json.encode(reqData))
    req:Send(function(res)
        local reqRes = json.decode(res.Body)
        if reqRes and reqRes.code == 200 then
            if getTime >= player_manager.lastGetRankTime then
                player_manager.cacheCharData[PlayFabId][CharacterId].comment = reqRes.data.Data
                ui_manager.RefreshCommentView(PlayFabId, CharacterId)
            end
        else
            player_manager.GetCharacterData(PlayFabId, CharacterId, getTime)
        end
    end)
end

function player_manager.AddNewComment(playerID, comment)
    if not player_manager.playerDatas[playerID].Characters then
        return
    end
    local curATime = player_manager.GetCurrentATime()
    if not curATime then return end

    if player_manager.playerDatas[playerID].waitPublish then ui_manager.ShowErrorMsg(playerID, "publishCD") return end

    player_manager.playerDatas[playerID].waitPublish = true
    local idx = player_manager.playerDatas[playerID].commentCount % MAX_COMMENT_COUNT + 1
    if player_manager.playerDatas[playerID].Characters[idx] then
        local dataTab = {}
        dataTab.comment = comment
        dataTab.time = curATime.value - 63671184000
        dataTab.timeStr = curATime.str
        dataTab.support = 0
        dataTab.steamID = tostring(PlayerResource:GetSteamID(playerID))
        local playFabID = player_manager.playerDatas[playerID].playFabID
        local CharacterId = player_manager.playerDatas[playerID].Characters[idx].CharacterId
        player_manager.UpdateCharacterData(playFabID, CharacterId, dataTab, function(isCharDataSave)
            if isCharDataSave then
                local rankData = {comment_hot = 0, comment_new = dataTab.time}
                player_manager.UpdateCharacterStatistics(playFabID, CharacterId, rankData, function(isHotComSave)
                    player_manager.playerDatas[playerID].waitPublish = false
                    if isHotComSave then
                        local changeData = {commentCount = player_manager.playerDatas[playerID].commentCount + 1}
                        player_manager.ChangePlayerData(playerID, changeData)
                    end
                end)
            else
                player_manager.playerDatas[playerID].waitPublish = false
            end
        end)
    else
        player_manager.GrantCharacterToUser(playerID, "comment" .. idx, "comment", function()
            player_manager.playerDatas[playerID].waitPublish = false
            player_manager.AddNewComment(playerID, comment)
        end)
    end
end

function player_manager.UpdateCharacterData(PlayFabId, CharacterId, dataTab, callBack)
    local req = player_manager.CreateReqHead("Server", "UpdateCharacterData")

    local saveData = {}
    saveData.PlayFabId = PlayFabId
    saveData.CharacterId = CharacterId
    saveData.Data = dataTab

    req:SetHTTPRequestRawPostBody("application/json", json.encode(saveData))
    req:Send(function(res)
        local saveRes = json.decode(res.Body)
        if saveRes and saveRes.code == 200 then
            if callBack then
                callBack(true)
            end
        else
            if callBack then
                callBack(false)
            end
            --player_manager.UpdateCharacterData(PlayFabId, CharacterId, dataTab, callBack)
        end
    end)
end

function player_manager.UpdateCharacterStatistics(playFabID, CharacterId, rankData, callBack)
    local req = player_manager.CreateReqHead("Server", "UpdateCharacterStatistics")

    local saveData = {}
    saveData.PlayFabId = playFabID
    saveData.CharacterId = CharacterId
    saveData.CharacterStatistics = rankData
    req:SetHTTPRequestRawPostBody("application/json", json.encode(saveData))
    req:Send(function(res)
        local saveRes = json.decode(res.Body)
        if saveRes and saveRes.code == 200 then
            if callBack then
                callBack(true)
            end
            for rank,_ in pairs(rankData) do
                player_manager.GetCharacterLeaderboard(rank)
            end
        else
            if callBack then
                callBack(false)
            end
            --player_manager.UpdateCharacterStatistics(playFabID, CharacterId, rank, value, callBack)
        end
    end)
end

function player_manager.GetCharacterLeaderboard(rank, start)
    local req = player_manager.CreateReqHead("Server", "GetCharacterLeaderboard")

    local reqData = {}
    reqData.StatisticName = rank
    reqData.MaxResultsCount = 50
    reqData.StartPosition = start or 0

    player_manager.lastGetRankTime = GameRules:GetGameTime()
    req:SetHTTPRequestRawPostBody("application/json", json.encode(reqData))
    req:Send(function(res)
        local reqRes = json.decode(res.Body)
        if reqRes and reqRes.code == 200 then
            player_manager.cacheCharData = player_manager.cacheCharData or {}
            for k,v in pairs(reqRes.data.Leaderboard) do
                player_manager.cacheCharData[v.PlayFabId] = player_manager.cacheCharData[v.PlayFabId] or {}
                player_manager.cacheCharData[v.PlayFabId][v.CharacterId] = player_manager.cacheCharData[v.PlayFabId][v.CharacterId] or {PlayFabId = v.PlayFabId, CharacterId = v.CharacterId}
                player_manager.cacheCharData[v.PlayFabId][v.CharacterId][rank] = v.Position

                player_manager.GetCharacterData(v.PlayFabId, v.CharacterId, player_manager.lastGetRankTime)
            end
        else
            player_manager.GetCharacterLeaderboard(rank, start)
        end
    end)
end
--------------------------------------------------------------

--------------------------------------------public-------------------

function player_manager.CacheAccountTime()
    local req = player_manager.CreateReqHead("Server", "GetTime")
    req:SetHTTPRequestRawPostBody("application/json", json.encode({}))
    req:Send(function(res)
        local tabRes = json.decode(res.Body)
        if tabRes and tabRes.code == 200 then
            local timeStr = string.gsub(tabRes.data.Time, "Z", "")
            local timeStrArr = string.split(timeStr, "T")
            player_manager.cacheAccountTime = {}
            local dataStrArr = string.split(timeStrArr[1], "-")
            local timeStrArr = string.split(timeStrArr[2], ":")
            ListInsertList(player_manager.cacheAccountTime, dataStrArr)
            ListInsertList(player_manager.cacheAccountTime, timeStrArr)
            player_manager.cacheGameTime = GameRules:GetGameTime()
            for i,v in ipairs(player_manager.cacheAccountTime) do
                player_manager.cacheAccountTime[i] = tonumber(v)
            end
            player_manager.cacheAccountTime[4] = player_manager.cacheAccountTime[4] + 8
            player_manager.cacheAccountTime[6] = math.floor(player_manager.cacheAccountTime[6])
        else
            player_manager.CacheAccountTime()
        end
    end)
end

function player_manager.CreateReqHead(term, funName, playerID)
    local url = string.format("https://%s.playfabapi.com/%s/%s", player_manager.tid, term, funName)
    local req = CreateHTTPRequestScriptVM("POST", url)
    req:SetHTTPRequestHeaderValue("Content-Type", "application/json")
    if term == "Server" then
        req:SetHTTPRequestHeaderValue("X-SecretKey", player_manager.SessionTicket)
    elseif playerID then
        req:SetHTTPRequestHeaderValue("X-Authentication", player_manager.playerDatas[playerID].SessionTicket)
    end
    return req
end

function player_manager.GetCurrentATime()
    if not player_manager.cacheGameTime then return nil end
    local addTime = GameRules:GetGameTime() - player_manager.cacheGameTime
    player_manager.cacheGameTime = GameRules:GetGameTime()
    player_manager.cacheAccountTime[6] = player_manager.cacheAccountTime[6] + addTime
    while player_manager.cacheAccountTime[6] >= 60 do
        player_manager.cacheAccountTime[5] = player_manager.cacheAccountTime[5] + 1
        player_manager.cacheAccountTime[6] = player_manager.cacheAccountTime[6] - 60
    end
    while player_manager.cacheAccountTime[5] >= 60 do
        player_manager.cacheAccountTime[4] = player_manager.cacheAccountTime[4] + 1
        player_manager.cacheAccountTime[5] = player_manager.cacheAccountTime[5] - 60
    end
    while player_manager.cacheAccountTime[4] >= 24 do
        player_manager.cacheAccountTime[3] = player_manager.cacheAccountTime[3] + 1
        player_manager.cacheAccountTime[4] = player_manager.cacheAccountTime[4] - 24
    end
    if player_manager.cacheAccountTime[2] == 2 then
        local isRYear = false
        if player_manager.cacheAccountTime[1] % 100 == 0 then
            isRYear = player_manager.cacheAccountTime[1] % 400 == 0
        else
            isRYear = player_manager.cacheAccountTime[1] % 4 == 0
        end
        local monthDays = isRYear and 29 or 28
        while player_manager.cacheAccountTime[3] > monthDays do
            player_manager.cacheAccountTime[2] = player_manager.cacheAccountTime[2] + 1
            player_manager.cacheAccountTime[3] = player_manager.cacheAccountTime[3] - monthDays
        end
    elseif player_manager.cacheAccountTime[2] > 7 then
        local monthDays = player_manager.cacheAccountTime[2] % 2 == 0 and 31 or 30
        while player_manager.cacheAccountTime[3] > monthDays do
            player_manager.cacheAccountTime[2] = player_manager.cacheAccountTime[2] + 1
            player_manager.cacheAccountTime[3] = player_manager.cacheAccountTime[3] - monthDays
        end
    else
        local monthDays = player_manager.cacheAccountTime[2] % 2 ~= 0 and 31 or 30
        while player_manager.cacheAccountTime[3] > monthDays do
            player_manager.cacheAccountTime[2] = player_manager.cacheAccountTime[2] + 1
            player_manager.cacheAccountTime[3] = player_manager.cacheAccountTime[3] - monthDays
        end
    end
    while player_manager.cacheAccountTime[2] > 12 do
        player_manager.cacheAccountTime[1] = player_manager.cacheAccountTime[1] + 1
        player_manager.cacheAccountTime[2] = player_manager.cacheAccountTime[4] - 12
    end

    local result = {}
    result.str = string.format("%d-%d-%d %d:%d:%d", player_manager.cacheAccountTime[1],player_manager.cacheAccountTime[2],
        player_manager.cacheAccountTime[3], player_manager.cacheAccountTime[4], player_manager.cacheAccountTime[5],
        player_manager.cacheAccountTime[6])
    result.value = math.floor(player_manager.cacheAccountTime[1] * 31536000 + player_manager.cacheAccountTime[2] * 2678400 +
        player_manager.cacheAccountTime[3] * 86400 + player_manager.cacheAccountTime[4] * 3600 + player_manager.cacheAccountTime[5] * 60
        + player_manager.cacheAccountTime[6])

    return result
end
----------------------------------------------