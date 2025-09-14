InfoGatherer = {}
InfoGatherer_mt = Class(InfoGatherer)

InfoGatherer.RETENTION_YEARS = 5

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

function InfoGatherer.new()
    local self = {}
    setmetatable(self, InfoGatherer_mt)

    self.gatherers = {
        [INFO_KEYS.FARMLANDS] = FarmlandGatherer.new(),
        [INFO_KEYS.FARMS] = FarmGatherer.new(),
    }

    return self
end

function InfoGatherer:loadFromXMLFile()
    if not g_currentMission:getIsServer() then return end

    local savegameFolderPath = g_currentMission.missionInfo.savegameDirectory
    if savegameFolderPath == nil then
        savegameFolderPath = ('%ssavegame%d'):format(getUserProfileAppPath(), g_currentMission.missionInfo.savegameIndex)
    end
    savegameFolderPath = savegameFolderPath .. "/"
    local key = "InfoGatherer"

    if fileExists(savegameFolderPath .. "RedTape.xml") then
        local xmlFile = loadXMLFile(key, savegameFolderPath .. "RedTape.xml")

        for infoKey, gatherer in pairs(self.gatherers) do
            local gathererKey = key .. ".gatherers"
            if gatherer.loadFromXMLFile ~= nil then
                gatherer:loadFromXMLFile(xmlFile, gathererKey)
            end
        end

        delete(xmlFile)
    end
end

function InfoGatherer:saveToXmlFile()
    if (not g_currentMission:getIsServer()) then return end

    local savegameFolderPath = g_currentMission.missionInfo.savegameDirectory .. "/"
    if savegameFolderPath == nil then
        savegameFolderPath = ('%ssavegame%d'):format(getUserProfileAppPath(),
            g_currentMission.missionInfo.savegameIndex .. "/")
    end

    local key = "InfoGatherer";
    local xmlFile = createXMLFile(key, savegameFolderPath .. "RedTape.xml", key);

    for _, gatherer in self.gatherers do
        gatherer:saveToXmlFile(xmlFile, key .. ".gatherers")
    end

    saveXMLFile(xmlFile);
    delete(xmlFile);
end

function InfoGatherer:runConstantChecks()
    self.gatherers[INFO_KEYS.FARMS]:checkSprayers()
end

function InfoGatherer:runInfrequentChecks()
    self.gatherers[INFO_KEYS.FARMLANDS]:checkHarvestedState()
end

function InfoGatherer:hourChanged()
    for _, gatherer in pairs(self.gatherers) do
        gatherer:hourChanged()
    end
end

function InfoGatherer:periodChanged()
    for _, gatherer in pairs(self.gatherers) do
        gatherer:periodChanged()
    end
end
