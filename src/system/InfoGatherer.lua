InfoGatherer = {}
InfoGatherer_mt = Class(InfoGatherer)

InfoGatherer.RETENTION_YEARS = 5

INFO_KEYS = {
    FARMLANDS = "farmlands",
}

function InfoGatherer.new()
    local self = {}
    setmetatable(self, InfoGatherer_mt)

    self.data = self:initData()
    self.turnedOnSprayers = {}

    return self
end

function InfoGatherer:runConstantChecks()
    -- print("Running constant checks...")
    self:checkSprayers()
end

function InfoGatherer:checkSprayers()
    local checkFillTypes = { FillType.FERTILIZER }
    local checkRadius = 10

    for uniqueId, sprayer in pairs(self.turnedOnSprayers) do
        local sprayType = sprayer:getActiveSprayType()
        if sprayType == nil then
            continue
        end

        local fillUnitIndex = sprayer:getSprayerFillUnitIndex()
        local fillType = sprayer:getFillUnitFillType(fillUnitIndex)

        if not RedTape:tableHasValue(checkFillTypes, fillType) then
            print("Ignoring sprayer fill type " .. fillType)
            continue
        end

        local usageScale = sprayer.spec_sprayer.usageScale
        local workingWidth
        if usageScale.workAreaIndex == nil then
            workingWidth = usageScale.workingWidth
        else
            workingWidth = self:getWorkAreaWidth(usageScale.workAreaIndex)
        end

        self:checkWaterByRaycast(sprayer, workingWidth + checkRadius)
    end
end

function InfoGatherer:checkWaterByRaycast(sprayer, length)
    local raycastResult = {
        raycastCallback = function(self, hitObjectId, x, y, z, distance, nx, ny, nz, subShapeIndex, shapeId, isLast)
            local mask = getCollisionFilterGroup(hitObjectId)
            if mask == CollisionFlag.WATER then
                self.foundWater = true
            end
        end
    }

    local x, y, z = localToWorld(sprayer.rootNode, 0, sprayer.size.height + 1, 0)
    local dx, dy, dz = localDirectionToWorld(sprayer.rootNode, 0, -0.5, -1)

    drawDebugArrow(x, y, z, dx * length, dy * length, dz * length, 0.3, 0.3, 0.3, 0.8, 0, 0, true)
    raycastClosest(x, y, z, dx, dy, dz, length, "raycastCallback", raycastResult,
        CollisionFlag.WATER + CollisionFlag.TERRAIN)

    if raycastResult.foundWater then
        print("Water found for sprayer " .. sprayer:getName())
    else
        print("No water found for sprayer " .. sprayer:getName())
    end
end

-- function InfoGatherer:checkWaterOverlap(sprayer, workingWidth)
--     local sizeX, sizeY, sizeZ = workingWidth / 2, 10, workingWidth / 2
--     local x, y, z = localToWorld(sprayer.rootNode, 0, sprayer.size.height * 0.5, 0)
--     local rx, ry, rz = getWorldRotation(sprayer.rootNode)
--     local dx, dy, dz = localDirectionToWorld(sprayer.rootNode, 0, 0, 0)
--     local hitCount = overlapBox(x + dx, y + dy, z + dz, rx, ry, rz, sizeX, sizeY, sizeZ, "onWaterRaycastCallback",
--         self, CollisionFlag.WATER, true, true, true, true)

--     DebugUtil.drawOverlapBox(x + dx, y + dy, z + dz, rx, ry, rz, sizeX, sizeY, sizeZ)
--     print(hitCount)
-- end

function InfoGatherer:onWaterRaycastCallback(hitObjectId, x, y, z, distance)
    print("water hit")
    return false
end

function InfoGatherer:initData()
    local data = {}
    for _, value in pairs(INFO_KEYS) do
        data[value] = {}
    end
    return data
end

function InfoGatherer:getPreviousPeriod()
    local previousPeriod = g_currentMission.environment.currentPeriod - 1
    if previousPeriod < 1 then return 12 end
    return previousPeriod
end

function InfoGatherer:gatherData()
    print("Gathering data for policies...")
    local currentMonth = RedTape.periodToMonth(g_currentMission.environment.currentPeriod)
    --self:stubCurrentMonth(data, g_currentMission.environment.currentYear, currentMonth)

    self:getFarmlands()


    -- self:removeOldData(data)
    return
end

-- function InfoGatherer:removeOldData(data)
--     local currentYear = g_currentMission.environment.currentYear

--     for _, value in pairs(INFO_KEYS) do
--         for year, _ in pairs(data[value]) do
--             if year < currentYear - InfoGatherer.RETENTION_YEARS then
--                 data[value][year] = nil
--             end
--         end
--     end
-- end

-- function InfoGatherer:stubCurrentMonth(data, year, month)
--     for _, value in pairs(INFO_KEYS) do
--         if data[value][year] == nil then
--             data[value][year] = {}
--         end
--         if data[value][year][month] == nil then
--             data[value][year][month] = {}
--         end
--     end
-- end

function InfoGatherer:getFarmlands()
    print("Gathering farmlands data...")
    for _, farmland in pairs(g_farmlandManager.farmlands) do
        if farmland.showOnFarmlandsScreen and farmland.field ~= nil then
            if self.data[INFO_KEYS.FARMLANDS][farmland.id] == nil then
                self.data[INFO_KEYS.FARMLANDS][farmland.id] = { fallowMonths = 0 }
            end

            local farmlandData = self.data[INFO_KEYS.FARMLANDS][farmland.id]

            local field = farmland.field
            local x, z = field:getCenterOfFieldWorldPosition()
            local fruitTypeIndexPos, growthState = FSDensityMapUtil.getFruitTypeIndexAtWorldPos(x, z)
            local currentFruit = g_fruitTypeManager:getFruitTypeByIndex(fruitTypeIndexPos)

            if currentFruit == nil then
                farmlandData.fallowMonths = farmlandData.fallowMonths + 1
                if farmlandData.mostRecentFruit ~= nil then
                    farmlandData.previousFruit = farmlandData.mostRecentFruit
                end
                farmlandData.mostRecentFruit = nil
            else
                farmlandData.fallowMonths = 0

                -- if there is a fruit and it different from the previous one, update it
                if farmlandData.mostRecentFruit ~= nil and farmlandData.mostRecentFruit ~= fruitTypeIndexPos then
                    farmlandData.previousFruit = farmlandData.mostRecentFruit
                end
                farmlandData.mostRecentFruit = fruitTypeIndexPos
            end
            farmlandData.areaHa = field:getAreaHa()
        end
    end

    return data
end
