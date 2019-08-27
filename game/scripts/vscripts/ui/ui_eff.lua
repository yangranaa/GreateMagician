function showCombEff(kv)
	if kv.activator then
		local nFXIndex = ParticleManager:CreateParticle("particles/combuieff.vpcf", PATTACH_ABSORIGIN_FOLLOW, kv.activator)
		ParticleManager:ReleaseParticleIndex(nFXIndex)
	end
end

local selHeroEffIdx = nil
function showSelHeroEff(kv)
	if kv.activator then
		if selHeroEffIdx then
			ParticleManager:DestroyParticle(selHeroEffIdx, true)
			ParticleManager:ReleaseParticleIndex(selHeroEffIdx)
		end
		selHeroEffIdx = ParticleManager:CreateParticle("particles/select_hero_eff.vpcf", PATTACH_ABSORIGIN_FOLLOW, kv.activator)
	end
end