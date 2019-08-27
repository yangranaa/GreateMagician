if gift_manager == nil then
	_G.gift_manager = class({})
end

function gift_manager.GenUnitGiftArgs(unit, gift)
	unit.gift = gift
	local args = {}
	args.costomUnit = unit
	args.unit_radius = 50
    args.unit_mass = 100
    args.unit_hight = 200
    args.unit_phyType = "PLAYER"

    if gift == "zirancifu" then
        args.coefficient = {natural = 60}
    elseif gift == "leidianzhangkong" then
        args.coefficient = {thunder = 60}
    elseif gift == "molihuiji" then
        local buffArgs = {}
        buffArgs.modifierName = "molihuiji"
        buffArgs.target = unit
        buffArgs.caster = unit
        abilities_buff_target_buff(buffArgs)
    elseif gift == "yixineryong" then
        args.abilitySlot = 2
    elseif gift == "shuixiqinhe" then
        args.coefficient = {water = 60}
    end
    return args
end

local defaultGiftList = {
	"zirancifu",
	"leidianzhangkong",
    "molihuiji",
    "shuixiqinhe",
}

function gift_manager.GetDefaultGift()
 	local sfList = ShuffledList(defaultGiftList)
 	local result = {}
    
    table.insert(result, {unitName = "npc_dota_hero_ogre_magi", gift = "yixineryong"})
    for i=1, 1 do
        table.insert(result, GIFT_LIST[sfList[i]])
    end
 	
 	return result
end

function gift_manager.GetUnlockGift(playerID)
	local unlockList = shallowcopy(GIFT_LIST)
	for _, v in pairs(player_manager.playerDatas[playerID].heroData.heroList) do
		unlockList[v.gift] = nil
	end
	return PickRandomValue(unlockList)
end

local defaultAbilitiesList = {
	"gaobaodilei",
	"leishu",
	"bingci",
	"yinlichang",
	"fanshebingjing",
	"huaxing",
    "ziranzhipei",
    "yinshenshu",
    "huoyanlujing",
    "jianshifangxian",
}

function gift_manager.GetDefaultAbilities()
	local sfList = ShuffledList(defaultAbilitiesList)
	local result = {}
    result[1] = "huoqiu"
    result[2] = "ziyu"
	for i=3, 8 do
		result[i] = sfList[i]
	end

    -- local i = 1
    -- for k,v in pairs(ELEMENTS_TO_ABILITY) do
    --     result[i] = v
    --     i = i + 1
    -- end
	return result
end

function gift_manager.GetCanLearnAbility(playerID)
	local learnList = TableRemoveByTable(ABILITY_TO_ELEMENTS, player_manager.playerDatas[playerID].acquireAbilities)
	return PickRandomValue(learnList)
end

GIFT_LIST = {
	zirancifu = {unitName = "npc_dota_hero_dark_willow", gift = "zirancifu"},
    leidianzhangkong = {unitName = "npc_dota_hero_storm_spirit", gift = "leidianzhangkong"},
    molihuiji = {unitName = "npc_dota_hero_enigma", gift = "molihuiji"},
    yixineryong = {unitName = "npc_dota_hero_ogre_magi", gift = "yixineryong"},
    shuixiqinhe = {unitName = "npc_dota_hero_naga_siren", gift = "shuixiqinhe"},
}

ELEMENTS_TO_ABILITY = {
    fireAfireAfireA = "huoqiu",
    fireAfireAgroundA = "gaobaodilei",
    waterAwaterAwaterA = "bingqiu",
    thunderAthunderAthunderA = "leishu",
    naturalAnaturalAnaturalA = "zhiyuguangshu",
    waterAgroundAwaterA = "fanshebingjing",
    thunderAgroundAthunderAgroundA = "zhuizongciqiu",
    thunderAwaterAgroundA = "luolei",
    fireAfireAnaturalAgroundA = "huoyanlujing",
    groundAgroundAgroundAgroundA = "jianshifangxian",
    vapourAthunderAwaterA = "jumozhan",
    naturalAgroundAnaturalA = "ziranzhipei",
    thunderAvapourAfireA = "zhaohui",
    naturalAnaturalA = "ziyu",
    groundAgroundAgroundAthunderA = "yinlichang",
    vapourAthunderAfireA = "zengyizhiqiang",
    vapourAvapourAvapourAvapourAvapourA = "kuangbaolongjuan",
    thunderAthunderAgroundAthunderAgroundA = "raoshenyoulei",
    naturalAgroundAwaterA = "molihudun",
    fireAvapourAthunderA = "mobaoshu",
    waterAwaterAgroundA = "huaxing",
    vapourAnaturalAfireA = "shijianjiasu",
    groundAwaterAfireA = "zhenshi",
    fireAthunderAwaterA = "feileishen",
    naturalAnaturalAnaturalAvapourAwaterA = "zhaohuanchongqun",
    fireAfireAthunderAgroundA = "renengdaodan",
    thunderAthunderAfireAwaterAthunderA = "dianshanleiming",
    naturalAnaturalAwaterAgroundAgroundA = "shengmingzhiquan",
    waterAnaturalA = "xianzongbiaoji",
    thunderAgroundA = "molijiance",
    vapourAvapourAthunderA = "fushen",
    vapourAwaterAfireA = "yinshenshu",
    waterAwaterAwaterAgroundA = "bingci",
    waterAwaterAfireA = "hongliu",
    vapourAvapourAvapourA = "fengzhiyi",
    fireAnaturalAvapourA = "zhenchashouwei",
}

ABILITY_TO_ELEMENTS = {}
for k,v in pairs(ELEMENTS_TO_ABILITY) do
	ABILITY_TO_ELEMENTS[v] = k
end