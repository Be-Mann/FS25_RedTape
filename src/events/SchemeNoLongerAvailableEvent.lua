RTSchemeNoLongerAvailableEvent = {}
local RTSchemeNoLongerAvailableEvent_mt = Class(RTSchemeNoLongerAvailableEvent, Event)

InitEventClass(RTSchemeNoLongerAvailableEvent, "RTSchemeNoLongerAvailableEvent")

function RTSchemeNoLongerAvailableEvent.emptyNew()
    local self = Event.new(RTSchemeNoLongerAvailableEvent_mt)

    return self
end

function RTSchemeNoLongerAvailableEvent.new(id)
    local self = RTSchemeNoLongerAvailableEvent.emptyNew()
    self.id = id
    return self
end

function RTSchemeNoLongerAvailableEvent:writeStream(streamId, connection)
    streamWriteString(streamId, self.id)
end

function RTSchemeNoLongerAvailableEvent:readStream(streamId, connection)
    self.id = streamReadString(streamId)
    self:run(connection)
end

function RTSchemeNoLongerAvailableEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(RTSchemeNoLongerAvailableEvent.new(self.id))
    end

    local schemeSystem = g_currentMission.RedTape.SchemeSystem
    schemeSystem:removeAvailableScheme(self.id)
end
