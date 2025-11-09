RTFarmStatsExtension = {}

function RTFarmStatsExtension:updateStats(statName, delta, ignoreHeroStats)
    if statName == "cutTreeCount" then
        local ig = g_currentMission.RedTape.InfoGatherer
        local gatherer = ig.gatherers[INFO_KEYS.FARMS]

        local farmId = RTFarmStatsExtension.getFarmId(self)
        local farmData = gatherer:getFarmData(farmId)
        farmData.biAnnualCutTrees = farmData.biAnnualCutTrees + delta
    end
end

function RTFarmStatsExtension.getFarmId(farmStats)
    for _, farm in pairs(g_farmManager.farmIdToFarm) do
        if farm.stats == farmStats then
            return farm.farmId
        end
    end
end

FarmStats.updateStats = Utils.appendedFunction(FarmStats.updateStats,
    RTFarmStatsExtension.updateStats)
