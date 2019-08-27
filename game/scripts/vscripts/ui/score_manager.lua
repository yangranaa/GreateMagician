if score_manager == nil then
	_G.score_manager = class({})
	score_manager.scoreDatas = {}
end

function score_manager.UpdatePlayerScore(playerID, newData)
    if not score_manager.scoreDatas[playerID] then
        local scoreData = {}
        scoreData.steamID = PlayerResource:GetSteamID(playerID)
        scoreData.heroName = PlayerResource:GetPlayer(playerID):GetAssignedHero():GetUnitName()
        scoreData.kill = 0
        scoreData.friendKill = 0
        scoreData.dead = 0
        scoreData.damage = 0
        scoreData.friendDamage = 0
        scoreData.heal = 0
        scoreData.assist = 0
        scoreData.killCount = 0
        score_manager.scoreDatas[playerID] = scoreData
        newData = scoreData
    else
        for k,v in pairs(newData or {}) do
            score_manager.scoreDatas[playerID][k] = v
        end
    end
    
    ui_manager.UpdateScoreBoardView(playerID, newData)
end

function score_manager.OnEntityHurt(attacker, beattacker, damage)
	attacker = GetRealCaster(attacker)
	local atkOwnerPlayerId = attacker:GetPlayerOwnerID()
	if atkOwnerPlayerId == -1 or not beattacker:IsRealHero() then return end
		
	damage = math.floor(damage)
	local atkData = {}
	atkData.unit = attacker
	atkData.team = attacker:GetTeamNumber()
	atkData.playerID = atkOwnerPlayerId
	atkData.time = GameRules:GetGameTime()
	atkData.damage = damage
	if not beattacker.atkers then
		beattacker.atkers = {}
	end
	beattacker.atkers[attacker] = atkData
	beattacker.lastAtker = attacker

	if damage > 1500 then
		ui_manager.AddScrollMsg( {key = "high_dmg", args = {playerNameAtk = PlayerResource:GetPlayerName(atkOwnerPlayerId), playerNameHurt = PlayerResource:GetPlayerName(beattacker:GetPlayerOwnerID()), dmg = damage}})
	end

	local newScData = {}
	if beattacker:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS and attacker:GetTeamNumber() ~= beattacker:GetTeamNumber() then
		newScData.damage = score_manager.scoreDatas[atkOwnerPlayerId].damage + damage
	else
		newScData.friendDamage = score_manager.scoreDatas[atkOwnerPlayerId].friendDamage + damage
	end
	score_manager.UpdatePlayerScore(atkOwnerPlayerId, newScData)
end

local ASSIST_TIME = 10

function score_manager.GetAssists(target)
	local result = {}
	for k,v in pairs(target.atkers or {}) do
		if v.time + ASSIST_TIME >= GameRules:GetGameTime() and v.team ~= target:GetTeamNumber() then	
			table.insert(result, v)
		end
	end
	return result
end

function score_manager.OnEntityKilled(attacker, deadUnit)
	attacker = GetRealCaster(attacker)
	local atkOwnerPlayerId = attacker:GetPlayerOwnerID()
	if atkOwnerPlayerId == -1 then return end

	local newScData = {}
	if deadUnit:IsRealHero() then
		ui_manager.AddScrollMsg( {key = "kill_msg", args = {playerNameKiller = PlayerResource:GetPlayerName(atkOwnerPlayerId), playerNameDead = PlayerResource:GetPlayerName(deadUnit:GetPlayerOwnerID())}})
		if attacker:GetTeamNumber() ~= deadUnit:GetTeamNumber() then
			newScData.kill = score_manager.scoreDatas[atkOwnerPlayerId].kill + 1
			newScData.killCount = score_manager.scoreDatas[atkOwnerPlayerId].killCount + 1 
			local assists = score_manager.GetAssists(deadUnit)
			if #assists > 0 then
				for _, atkData in pairs(assists) do
					local newAssData = {assist = score_manager.scoreDatas[atkData.playerID].assist + 1}
					score_manager.UpdatePlayerScore(atkData.playerID, newAssData)
				end
			else
				assists = score_manager.GetAssists(attacker)
				if #assists >= 3 then
					ui_manager.AddScrollMsg( {key = "tant_three", args = {playerName = PlayerResource:GetPlayerName(atkOwnerPlayerId)}})
				end
			end

			EmitSoundOn("valve_dota_001.music.roshan_end", attacker)

			local effArgs = {}
			effArgs.eff = "particles/yanhuo.vpcf"
			effArgs.cps = "ent,0,target,PATTACH_ABSORIGIN_FOLLOW,attach_hitloc"
			effArgs.target = attacker
			effArgs.autoDel = "5"
			abilities_eff_CreateEff(effArgs)
		
			if newScData.killCount == 5 then
				EmitGlobalSound("ui_flare_explode")
				ui_manager.AddScrollMsg( {key = "kill_morethan5", args = {playerName = PlayerResource:GetPlayerName(atkOwnerPlayerId)}})
			elseif newScData.killCount == 10 then
				ui_manager.AddScrollMsg( {key = "kill_count10", args = {playerName = PlayerResource:GetPlayerName(atkOwnerPlayerId)}})
			end
		else
			newScData.friendKill = score_manager.scoreDatas[atkOwnerPlayerId].friendKill + 1

			if score_manager.scoreDatas[atkOwnerPlayerId].friendKill >= score_manager.scoreDatas[atkOwnerPlayerId].kill then
				ui_manager.AddScrollMsg( {key = "shame_friend_kill", args = {playerName = PlayerResource:GetPlayerName(atkOwnerPlayerId)}})
			end
		end
		local newDeadData = {dead = score_manager.scoreDatas[deadUnit:GetPlayerOwnerID()].dead + 1, killCount = 0}
		score_manager.UpdatePlayerScore(deadUnit:GetPlayerOwnerID(), newDeadData)
	end
	
	score_manager.UpdatePlayerScore(atkOwnerPlayerId, newScData)
end

function score_manager.OnHealUnit(caster, target, value)
	local newScData = {}
	if caster:GetTeamNumber() == target:GetTeamNumber() then
		newScData.heal = score_manager.scoreDatas[caster:GetPlayerOwnerID()].heal + value
	end
	score_manager.UpdatePlayerScore(caster:GetPlayerOwnerID(), newScData)
end