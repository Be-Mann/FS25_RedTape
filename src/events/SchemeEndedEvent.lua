RTSchemeEndedEvent = {}
local RTSchemeEndedEvent_mt = Class(RTSchemeEndedEvent, Event)

InitEventClass(RTSchemeEndedEvent, "SchemeEndedEvent")

function RTSchemeEndedEvent.emptyNew()
    local self = Event.new(RTSchemeEndedEvent_mt)

    return self
end

function RTSchemeEndedEvent.new(id, farmId)
    local self = RTSchemeEndedEvent.emptyNew()
    self.id = id
    self.farmId = farmId
    return self
end

function RTSchemeEndedEvent:writeStream(streamId, connection)
    streamWriteString(streamId, self.id)
    streamWriteInt32(streamId, self.farmId)
end

function RTSchemeEndedEvent:readStream(streamId, connection)
    self.id = streamReadString(streamId)
    self.farmId = streamReadInt32(streamId)
    self:run(connection)
end

function RTSchemeEndedEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(RTSchemeEndedEvent.new(self.id, self.farmId))
    end

    local schemeSystem = g_currentMission.RedTape.SchemeSystem
    schemeSystem:endActiveScheme(self.id, self.farmId)
end
