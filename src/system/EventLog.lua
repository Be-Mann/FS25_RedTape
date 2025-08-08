EventLog = {}
EventLog_mt = Class(EventLog)

function EventLog.new()
    local self = {}
    setmetatable(self, EventLog_mt)

    self.events = {}

    self:loadFromXMLFile()
    return self
end

function EventLog:addEvent(farmId, eventType, detail)
    local event = Event.new()
    event.farmId = farmId
    event.eventType = eventType
    event.detail = detail
    table.insert(self.events, event)
end

function EventLog:saveToXmlFile(xmlFile, key)
    local i = 0
    for _, event in pairs(self.events) do
        local eventKey = string.format("%s.events.event(%d)", key, i)
        event:saveToXmlFile(xmlFile, eventKey)
        i = i + 1
    end
end

function EventLog:loadFromXMLFile(xmlFile, key)
    local i = 0
    while true do
        local eventKey = string.format("%s.events.event(%d)", key, i)
        if not hasXMLProperty(xmlFile, eventKey) then
            break
        end
        local event = Event.new()
        event:loadFromXMLFile(xmlFile, eventKey)
        table.insert(self.events, event)
        i = i + 1
    end
end
