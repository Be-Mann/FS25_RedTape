RTRandomEventsSystem = {}

RTRandomEventsSystem_mt = Class(RTRandomEventsSystem)

function RTRandomEventsSystem.new()
    local self = {}
    setmetatable(self, RTRandomEventsSystem_mt)
    self.events = {}

    return self
end

function RTRandomEventsSystem:loadFromXMLFile(xmlFile, key)

end

function RTRandomEventsSystem:saveToXMLFile(xmlFile, key)

end

function RTRandomEventsSystem:writeInitialClientState(streamId, connection)

end

function RTRandomEventsSystem:readInitialClientState(streamId, connection)

end

function RTRandomEventsSystem:hourChanged()

end

function RTRandomEventsSystem:periodChanged()
    local eventSystem = g_currentMission.RedTape.RandomEventsSystem

    for _, event in ipairs(eventSystem.events) do
        -- event:periodChanged()
    end

    eventSystem:generateRandomEvents()
end

function RTRandomEventsSystem:generateRandomEvents()

end