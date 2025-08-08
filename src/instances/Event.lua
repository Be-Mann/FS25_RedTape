Event = {}
Event_mt = Class(Event)

Event.EVENT_TYPE = {
    NONE = 1,
    POLICY_POINTS = 2,
    POLICY_ACTIVATED = 3,
}

function Event.new()
    local self = {}
    setmetatable(self, Event_mt)

    self.farmId = nil
    self.eventType = Event.EVENT_TYPE.NONE
    self.detail = ""

    return self
end

function Event:saveToXmlFile(xmlFile, key)
    setXMLInt(xmlFile, key .. "#farmId", self.farmId)
    setXMLInt(xmlFile, key .. "#eventType", self.eventType)
    setXMLString(xmlFile, key .. "#detail", self.detail)
end

function Event:loadFromXMLFile(xmlFile, key)
    self.farmId = getXMLInt(xmlFile, key .. "#farmId")
    self.eventType = getXMLInt(xmlFile, key .. "#eventType")
    self.detail = getXMLString(xmlFile, key .. "#detail")
end
