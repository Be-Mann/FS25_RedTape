FSBaseMissionExtension = {}

function FSBaseMissionExtension:removeKnownSplitShape(shape)
    if shape ~= nil and shape ~= 0 and entityExists(shape) then
        if getHasClassId(shape, ClassIds.MESH_SPLIT_SHAPE) then
            if getSplitType(shape) ~= 0 then
                local isSplit = getIsSplitShapeSplit(shape)
                local isStatic = getRigidBodyType(shape) == RigidBodyType.STATIC
                -- local isDynamic = getRigidBodyType(shape) == RigidBodyType.DYNAMIC

                local isTree = isStatic and not isSplit
                -- local isStump = isStatic and isSplit
                -- local isBranch = isDynamic and isSplit

                if isTree then
                    local x, y, z = getWorldTranslation(shape)
                    local farmland = g_farmlandManager:getFarmlandAtWorldPosition(x, z)
                    if farmland ~= nil then
                        local ig = g_currentMission.RedTape.InfoGatherer
                        local gatherer = ig.gatherers[INFO_KEYS.FARMS]

                        local farmData = gatherer:getFarmData(farmland.farmId)
                        farmData.biAnnualCutTrees = farmData.biAnnualCutTrees + 1
                    end
                end
            end
        end
    end
end

FSBaseMission.removeKnownSplitShape = Utils.prependedFunction(FSBaseMission.removeKnownSplitShape,
    FSBaseMissionExtension.removeKnownSplitShape)
