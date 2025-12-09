RTPlaceableHusbandryExtension = {}

function RTPlaceableHusbandryExtension:addHusbandryFillLevelFromTool(superFunc, farmId, deltaFillLevel, fillTypeIndex,
                                                                     fillPositionData, toolType, extraAttributes)
    local qtyAdded = superFunc(self, farmId, deltaFillLevel, fillTypeIndex, fillPositionData, toolType, extraAttributes)

    if fillTypeIndex == FillType.MANURE and qtyAdded > 0 then
        local rt = g_currentMission.RedTape
        local farmData = rt.InfoGatherer.gatherers[INFO_KEYS.FARMS]:getFarmData(farmId)
        local produceHistory = farmData.produceHistory
        local cumulativeMonth = RedTape.getCumulativeMonth()
        if produceHistory[cumulativeMonth] == nil then
            produceHistory[cumulativeMonth] = {}
        end
        local fillTypeName = g_fillTypeManager:getFillTypeNameByIndex(fillTypeIndex)
        if produceHistory[cumulativeMonth][fillTypeName] == nil then
            produceHistory[cumulativeMonth][fillTypeName] = qtyAdded
        else
            produceHistory[cumulativeMonth][fillTypeName] = produceHistory[cumulativeMonth][fillTypeName] + qtyAdded
        end
    end

    return qtyAdded
end

PlaceableHusbandry.addHusbandryFillLevelFromTool = Utils.overwrittenFunction(
    PlaceableHusbandry.addHusbandryFillLevelFromTool,
    RTPlaceableHusbandryExtension.addHusbandryFillLevelFromTool)
