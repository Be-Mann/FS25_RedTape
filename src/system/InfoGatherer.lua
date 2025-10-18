RTInfoGatherer = {}
RTInfoGatherer_mt = Class(RTInfoGatherer)

RTInfoGatherer.RETENTION_YEARS = 5

INFO_KEYS = {
    FARMLANDS = "farmlands",
    FARMS = "farms",
}

-- SAVE_FUNCTIONS = {
--     [INFO_KEYS.FARMLANDS] = function(self, xmlFile, key)
--         setXMLString(xmlFile, key, table.concat(self.data.farmlands, ","))
--     end,
--     [INFO_KEYS.FARMS] = function(self, xmlFile, key)
--         setXMLString(xmlFile, key, table.concat(self.data.farms, ","))
--     end
-- }

function RTInfoGatherer.new()
    local self = {}
    setmetatable(self, RTInfoGatherer_mt)

    self.gatherers = {
        [INFO_KEYS.FARMLANDS] = FarmlandGatherer.new(),
        [INFO_KEYS.FARMS] = FarmGatherer.new(),
    }

    return self
end

function RTInfoGatherer:loadFromXMLFile(xmlFile)
    if not g_currentMission:getIsServer() then return end

    local key = RedTape.SaveKey .. ".infoGatherer"

    for infoKey, gatherer in pairs(self.gatherers) do
        local gathererKey = key .. ".gatherers"
        if gatherer.loadFromXMLFile ~= nil then
            gatherer:loadFromXMLFile(xmlFile, gathererKey)
        end
    end
end

function RTInfoGatherer:saveToXmlFile(xmlFile)
    if (not g_currentMission:getIsServer()) then return end

    local key = RedTape.SaveKey .. ".infoGatherer"

    for _, gatherer in self.gatherers do
        gatherer:saveToXmlFile(xmlFile, key .. ".gatherers")
    end
end

function RTInfoGatherer:runConstantChecks()
    self.gatherers[INFO_KEYS.FARMS]:checkSprayers()
end

function RTInfoGatherer:runInfrequentChecks()
    self.gatherers[INFO_KEYS.FARMLANDS]:checkHarvestedState()
end

function RTInfoGatherer:hourChanged()
    for _, gatherer in pairs(self.gatherers) do
        gatherer:hourChanged()
    end
end

function RTInfoGatherer:periodChanged()
    for _, gatherer in pairs(self.gatherers) do
        gatherer:periodChanged()
    end
end

function RTInfoGatherer:resetMonthlyData()
    for _, gatherer in pairs(self.gatherers) do
        gatherer:resetMonthlyData()
    end
end
