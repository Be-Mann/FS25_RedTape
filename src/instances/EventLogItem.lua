EventLogItem = {}
EventLogItem_mt = Class(EventLogItem)

EventLogItem.EVENT_TYPE = {
    NONE = 1,
    POLICY_POINTS = 2,
    POLICY_ACTIVATED = 3,
}

function EventLogItem.new()
    local self = {}
    setmetatable(self, EventLogItem_mt)

    self.farmId = nil
    self.eventType = EventLogItem.EVENT_TYPE.NONE
    self.detail = ""

    return self
end

function EventLogItem:saveToXmlFile(xmlFile, key)
    setXMLInt(xmlFile, key .. "#farmId", self.farmId)
    setXMLInt(xmlFile, key .. "#eventType", self.eventType)
    setXMLString(xmlFile, key .. "#detail", self.detail)
end

function EventLogItem:loadFromXMLFile(xmlFile, key)
    self.farmId = getXMLInt(xmlFile, key .. "#farmId")
    self.eventType = getXMLInt(xmlFile, key .. "#eventType")
    self.detail = getXMLString(xmlFile, key .. "#detail")
end
