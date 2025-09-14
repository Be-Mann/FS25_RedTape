-- A selected scheme is when a scheme is chosen by a farm
SchemeSelectedEvent = {}
local SchemeSelectedEvent_mt = Class(SchemeSelectedEvent, Event)

InitEventClass(SchemeSelectedEvent, "SchemeSelectedEvent")

function SchemeSelectedEvent.emptyNew()
    local self = Event.new(SchemeSelectedEvent_mt)

    return self
end

function SchemeSelectedEvent.new(scheme, farmId)
    local self = SchemeSelectedEvent.emptyNew()
    self.scheme = scheme
    self.farmId = farmId
    return self
end

function SchemeSelectedEvent:writeStream(streamId, connection)
    self.scheme:writeStream(streamId, connection)
    streamWriteInt32(streamId, self.farmId)
end

function SchemeSelectedEvent:readStream(streamId, connection)
    self.scheme = Scheme.new()
    self.scheme:readStream(streamId, connection)
    self.farmId = streamReadInt32(streamId)
    self:run(connection)
end

function SchemeSelectedEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(SchemeSelectedEvent.new(self.scheme))
    end

    local schemeSystem = g_currentMission.RedTape.SchemeSystem
    schemeSystem:registerSelectedScheme(self.scheme, self.farmId)
end
