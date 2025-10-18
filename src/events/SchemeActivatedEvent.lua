-- An activated scheme is when a scheme becomes available to farms for selection
RTSchemeActivatedEvent = {}
local RTSchemeActivatedEvent_mt = Class(RTSchemeActivatedEvent, Event)

InitEventClass(RTSchemeActivatedEvent, "SchemeActivatedEvent")

function RTSchemeActivatedEvent.emptyNew()
    local self = Event.new(RTSchemeActivatedEvent_mt)

    return self
end

function RTSchemeActivatedEvent.new(scheme)
    local self = RTSchemeActivatedEvent.emptyNew()
    self.scheme = scheme
    return self
end

function RTSchemeActivatedEvent:writeStream(streamId, connection)
    self.scheme:writeStream(streamId, connection)
end

function RTSchemeActivatedEvent:readStream(streamId, connection)
    self.scheme = RTScheme.new()
    self.scheme:readStream(streamId, connection)
    self:run(connection)
end

function RTSchemeActivatedEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(RTSchemeActivatedEvent.new(self.scheme))
    end

    local schemeSystem = g_currentMission.RedTape.SchemeSystem
    schemeSystem:registerActivatedScheme(self.scheme)
end
