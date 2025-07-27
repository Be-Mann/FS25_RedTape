InfoGatherer = {}
InfoGatherer_mt = Class(InfoGatherer)

INFO_KEYS = {
    FIELDS = "field",
}

function InfoGatherer.new()
    local self = {}
    setmetatable(self, InfoGatherer_mt)
    return self
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

function InfoGatherer:gatherData(data)
    print("Gathering data for policies...")
    self:getFarmlands(data)
    return data
end

function InfoGatherer:getFarmlands(data)
    print("Gathering farmlands data...")
    local currentPeriod = g_currentMission.environment.currentPeriod
    data[INFO_KEYS.FIELDS][currentPeriod] = {}
    for _, farmland in pairs(g_farmlandManager.farmlands) do
        if farmland.showOnFarmlandsScreen and farmland.field ~= nil then
            local field = farmland.field
            local x, z = field:getCenterOfFieldWorldPosition()
            local fruitTypeIndexPos, growthState = FSDensityMapUtil.getFruitTypeIndexAtWorldPos(x, z)
            local fruit = g_fruitTypeManager:getFruitTypeByIndex(fruitTypeIndexPos)
            local fruitName = fruit.fillType.title
            data[INFO_KEYS.FIELDS][currentPeriod] = {
                fruit = fruitName,
            }
        end
    end

    -- Simulate gathering farmlands data
    return data
end
