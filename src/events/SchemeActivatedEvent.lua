-- An activated scheme is when a scheme becomes available to farms for selection
SchemeActivatedEvent = {}
local SchemeActivatedEvent_mt = Class(SchemeActivatedEvent, Event)

InitEventClass(SchemeActivatedEvent, "SchemeActivatedEvent")

function SchemeActivatedEvent.emptyNew()
    local self = Event.new(SchemeActivatedEvent_mt)

    return self
end

function SchemeActivatedEvent.new(scheme)
    local self = SchemeActivatedEvent.emptyNew()
    self.scheme = scheme
    return self
end

function SchemeActivatedEvent:writeStream(streamId, connection)
    self.scheme:writeStream(streamId, connection)
end

function SchemeActivatedEvent:readStream(streamId, connection)
    self.scheme = Scheme.new()
    self.scheme:readStream(streamId, connection)
    self:run(connection)
end

function SchemeActivatedEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(SchemeActivatedEvent.new(self.scheme))
    end

    local schemeSystem = g_currentMission.RedTape.SchemeSystem
    schemeSystem:registerActivatedScheme(self.scheme)
end
