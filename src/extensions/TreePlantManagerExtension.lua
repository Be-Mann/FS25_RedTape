RTTreePlantManagerExtension = {}

function RTTreePlantManagerExtension:plantTree(treeTypeIndex, x, y, z, rx, ry, rz, growthStateI, variationIndex,
                                               isGrowing, nextGrowthTargetHour, existingSplitShapeFileId)
    if (not g_currentMission:getIsServer()) then return end

    local rt = g_currentMission.RedTape
    if not rt.missionStarted then return end

    local farmland = g_farmlandManager:getFarmlandAtWorldPosition(x, z)
    if farmland ~= nil then
        local ig = g_currentMission.RedTape.InfoGatherer
        local gatherer = ig.gatherers[INFO_KEYS.FARMS]

        local farmData = gatherer:getFarmData(farmland.farmId)
        farmData.biAnnualPlantedTrees = farmData.biAnnualPlantedTrees + 1
    end
end

TreePlantManager.plantTree = Utils.appendedFunction(TreePlantManager.plantTree,
    RTTreePlantManagerExtension.plantTree)
