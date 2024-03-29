local list = {
-- genStart
	npc_creature_satiershushi = {
		unitName = "npc_creature_satiershushi",
		itemTable = {item_element_vapour = {0.1, {1,1}, 1, 15, true}},
		maxCount = 2.0,
		group = "satier_2",
		dominantRate = 1.0,
		spawnPos = Vector(4800, 512, 128),
		mass = 100.0,
		unitType = "NORMALUNIT",
		radius = 50.0,
		hight = 200.0,
		characters = {fortitude = 1,},
		roamer = 0.0,
		maxDistanceFromSpawn = 200.0,
		followDis = 1500.0,
		atkSearchRadius = 1500.0,
		bornAbilities = {yuansutilian = 0.5},
		atkTimeGain = {0.014,0.056},
		atkGain = {0.0405,0.054},
		hpGain = {0.09,0.135},
		manaGain = {0.09,0.135},
		coefficientRange = { natural = {0, 0},fire = {30, 63},water = {10, 21},vapour = {30, 63},thunder = {10, 21},ground = {10, 21},},
		randomLv = {1, 4},
	},
	npc_creature_satiercike = {
		unitName = "npc_creature_satiercike",
		itemTable = {item_element_vapour = {0.1, {1,1}, 1, 15, true}},
		maxCount = 2.0,
		group = "satier_2",
		dominantRate = 1.0,
		spawnPos = Vector(4800, 512, 128),
		mass = 130.0,
		unitType = "NORMALUNIT",
		radius = 50.0,
		hight = 200.0,
		characters = {fortitude = 1,},
		roamer = 0.0,
		maxDistanceFromSpawn = 200.0,
		followDis = 1500.0,
		atkSearchRadius = 1500.0,
		bornAbilities = {yinnibufa = 0.5},
		atkTimeGain = {0.014,0.056},
		atkGain = {0.0405,0.054},
		hpGain = {0.09,0.135},
		manaGain = {0.07,0.105},
		coefficientRange = { natural = {10, 21},fire = {30, 63},water = {0, 0},vapour = {20, 42},thunder = {20, 42},ground = {10, 21},},
		randomLv = {1, 4},
	},
	npc_creature_gebulinjisi = {
		unitName = "npc_creature_gebulinjisi",
		itemTable = {item_element_natural = {0.1, {1,1}, 1, 15, true}},
		maxCount = 2.0,
		group = "gebulin_2",
		dominantRate = 1.0,
		spawnPos = Vector(-640, -4864, 128),
		mass = 100.0,
		unitType = "NORMALUNIT",
		radius = 50.0,
		hight = 200.0,
		characters = {fortitude = 1,},
		roamer = 0.0,
		maxDistanceFromSpawn = 200.0,
		followDis = 1500.0,
		atkSearchRadius = 1500.0,
		bornAbilities = {conglinzhiyu=0.5},
		atkTimeGain = {0.014,0.056},
		atkGain = {0.0405,0.054},
		hpGain = {0.09,0.135},
		manaGain = {0.09,0.135},
		coefficientRange = { natural = {40, 84},fire = {10, 21},water = {10, 21},vapour = {10, 21},thunder = {10, 21},ground = {10, 21},},
		randomLv = {1, 4},
	},
	npc_creature_gebulinzhanshi = {
		unitName = "npc_creature_gebulinzhanshi",
		itemTable = {item_element_natural = {0.1, {1,1}, 1, 15, true}},
		maxCount = 2.0,
		group = "gebulin_2",
		dominantRate = 1.0,
		spawnPos = Vector(-640, -4864, 128),
		mass = 130.0,
		unitType = "NORMALUNIT",
		radius = 50.0,
		hight = 200.0,
		characters = {fortitude = 1,},
		roamer = 0.0,
		maxDistanceFromSpawn = 200.0,
		followDis = 1500.0,
		atkSearchRadius = 1500.0,
		bornAbilities = {jianrenfengbao=0.5},
		atkTimeGain = {0.014,0.056},
		atkGain = {0.0405,0.054},
		hpGain = {0.09,0.135},
		manaGain = {0.07,0.105},
		coefficientRange = { natural = {30, 63},fire = {10, 21},water = {0, 0},vapour = {10, 21},thunder = {10, 21},ground = {20, 42},},
		randomLv = {1, 4},
	},
-- genEnd
}

return list
