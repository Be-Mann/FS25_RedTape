SchemeSystem = {}
SchemeSystem_mt = Class(SchemeSystem)

function SchemeSystem.new()
    local self = {}
    setmetatable(self, SchemeSystem_mt)
    self.schemes = {}

    self:loadFromXMLFile()

    return self
end

function SchemeSystem:loadFromXMLFile()
    if (not g_currentMission:getIsServer()) then return end

    local savegameFolderPath = g_currentMission.missionInfo.savegameDirectory;
    if savegameFolderPath == nil then
        savegameFolderPath = ('%ssavegame%d'):format(getUserProfileAppPath(), g_currentMission.missionInfo.savegameIndex)
    end
    savegameFolderPath = savegameFolderPath .. "/"
    local key = "SchemeSystem"

    if fileExists(savegameFolderPath .. "RedTape.xml") then
        local xmlFile = loadXMLFile(key, savegameFolderPath .. "RedTape.xml");

        local i = 0
        while true do
            local schemeKey = string.format(key .. ".schemes.scheme(%d)", i)
            if not hasXMLProperty(xmlFile, schemeKey) then
                break
            end

            local scheme = Scheme.new()
            scheme:loadFromXMLFile(xmlFile, schemeKey)
            table.insert(self.schemes, scheme)
            i = i + 1
        end

        delete(xmlFile)
    end
end

function SchemeSystem:saveToXmlFile()
    if (not g_currentMission:getIsServer()) then return end

    local savegameFolderPath = g_currentMission.missionInfo.savegameDirectory .. "/"
    if savegameFolderPath == nil then
        savegameFolderPath = ('%ssavegame%d'):format(getUserProfileAppPath(),
            g_currentMission.missionInfo.savegameIndex .. "/")
    end

    local key = "SchemeSystem";
    local xmlFile = createXMLFile(key, savegameFolderPath .. "RedTape.xml", key);

    local i = 0
    for _, scheme in pairs(self.schemes) do
        local schemeKey = string.format("%s.schemes.scheme(%d)", key, i)
        scheme:saveToXmlFile(xmlFile, schemeKey)
        i = i + 1
    end

    saveXMLFile(xmlFile);
    delete(xmlFile);
end

function SchemeSystem:hourChanged()
end

function SchemeSystem:periodChanged()
    local schemeSystem = g_currentMission.RedTape.SchemeSystem
end