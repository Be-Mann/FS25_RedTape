FarmlandGatherer = {}
FarmlandGatherer_mt = Class(FarmlandGatherer)

function FarmlandGatherer.new()
    local self = {}
    setmetatable(self, FarmlandGatherer_mt)

    self.data = {}

    return self
end

function FarmlandGatherer:hourChanged()
    -- for _, farmland in pairs(g_farmlandManager.farmlands) do
    --     if farmland.showOnFarmlandsScreen and farmland.field ~= nil then
    --         local farmlandData = self:getFarmlandData(farmland.id)
    --         local field = farmland.field
    --         local x, z = field:getCenterOfFieldWorldPosition()
    --         local fruitTypeIndexPos, growthState = FSDensityMapUtil.getFruitTypeIndexAtWorldPos(x, z)
    --         local currentFruit = g_fruitTypeManager:getFruitTypeByIndex(fruitTypeIndexPos)
    --     end
    -- end
end

function FarmlandGatherer:periodChanged()
    print("Gathering farmlands data...")
    for _, farmland in pairs(g_farmlandManager.farmlands) do
        if farmland.showOnFarmlandsScreen and farmland.field ~= nil then
            local farmlandData = self:getFarmlandData(farmland.id)
            local field = farmland.field
            local x, z = field:getCenterOfFieldWorldPosition()
            local fruitTypeIndex, growthState = FSDensityMapUtil.getFruitTypeIndexAtWorldPos(x, z)
            local currentFruit = g_fruitTypeManager:getFruitTypeByIndex(fruitTypeIndex)
            local currentMonth = g_currentMission.RedTape.periodToMonth(g_currentMission.environment.currentPeriod)

            if currentMonth == 4 then
                farmlandData.retainedSpringGrass = true
            end

            if currentFruit == nil then
                farmlandData.retainedSpringGrass = false
                farmlandData.fallowMonths = farmlandData.fallowMonths + 1
                if farmlandData.mostRecentFruit ~= "" then
                    farmlandData.previousFruit = farmlandData.mostRecentFruit
                end
                farmlandData.mostRecentFruit = ""
            else
                farmlandData.fallowMonths = 0

                if fruitTypeIndex ~= FruitType.GRASS then
                    farmlandData.retainedSpringGrass = false
                end

                -- if there is a fruit and it different from the previous one, update it
                if farmlandData.mostRecentFruit ~= "" and farmlandData.mostRecentFruit ~= currentFruit.name then
                    farmlandData.previousFruit = farmlandData.mostRecentFruit
                end
                farmlandData.mostRecentFruit = currentFruit.name
            end
            farmlandData.areaHa = field:getAreaHa()
        end
    end
end

function FarmlandGatherer:getFarmlandData(farmlandId)
    if self.data[farmlandId] == nil then
        self.data[farmlandId] = {
            fallowMonths = 0,
            mostRecentFruit = "",
            previousFruit = "",
            areaHa = 0,
            lastHarvestPeriod = -1,
            retainedSpringGrass = false
        }
    end
    return self.data[farmlandId]
end

function FarmlandGatherer:saveToXmlFile(xmlFile, key)
    local i = 0
    for farmlandId, farmlandData in pairs(self.data) do
        local farmlandKey = string.format("%s.farmlands.farmland(%d)", key, i)
        setXMLInt(xmlFile, farmlandKey .. "#id", farmlandId)
        setXMLInt(xmlFile, farmlandKey .. "#fallowMonths", farmlandData.fallowMonths)
        setXMLString(xmlFile, farmlandKey .. "#mostRecentFruit", farmlandData.mostRecentFruit)
        setXMLString(xmlFile, farmlandKey .. "#previousFruit", farmlandData.previousFruit)
        setXMLInt(xmlFile, farmlandKey .. "#areaHa", farmlandData.areaHa)
        setXMLInt(xmlFile, farmlandKey .. "#lastHarvestPeriod", farmlandData.lastHarvestPeriod)
        setXMLBool(xmlFile, farmlandKey .. "#retainedSpringGrass", farmlandData.retainedSpringGrass)
        i = i + 1
    end
end

function FarmlandGatherer:loadFromXMLFile(xmlFile, key)
    local i = 0
    while true do
        local farmlandKey = string.format("%s.farmlands.farmland(%d)", key, i)
        if not hasXMLProperty(xmlFile, farmlandKey) then
            break
        end

        local farmlandId = getXMLInt(xmlFile, farmlandKey .. "#id")
        self.data[farmlandId] = {
            fallowMonths = getXMLInt(xmlFile, farmlandKey .. "#fallowMonths"),
            mostRecentFruit = getXMLString(xmlFile, farmlandKey .. "#mostRecentFruit"),
            previousFruit = getXMLString(xmlFile, farmlandKey .. "#previousFruit"),
            areaHa = getXMLInt(xmlFile, farmlandKey .. "#areaHa"),
            lastHarvestPeriod = getXMLInt(xmlFile, farmlandKey .. "#lastHarvestPeriod"),
            retainedSpringGrass = getXMLBool(xmlFile, farmlandKey .. "#retainedSpringGrass")
        }
        i = i + 1
    end
end

function FarmlandGatherer:checkHarvestedState()
    for _, farmland in pairs(g_farmlandManager.farmlands) do
        if farmland.showOnFarmlandsScreen and farmland.field ~= nil then
            local farmlandData = self:getFarmlandData(farmland.id)
            local field = farmland.field
            local x, z = field:getCenterOfFieldWorldPosition()
            local fruitTypeIndexPos, growthState = FSDensityMapUtil.getFruitTypeIndexAtWorldPos(x, z)
            local currentFruit = g_fruitTypeManager:getFruitTypeByIndex(fruitTypeIndexPos)

            if currentFruit == nil then
                continue
            end

            if currentFruit and growthState == currentFruit.cutState then
                farmlandData.lastHarvestPeriod = g_currentMission.environment.currentPeriod
            end
        end
    end
end
