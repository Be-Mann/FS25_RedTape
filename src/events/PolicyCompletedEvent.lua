PolicyCompletedEvent = {}
local PolicyCompletedEvent_mt = Class(PolicyCompletedEvent, Event)

InitEventClass(PolicyCompletedEvent, "PolicyCompletedEvent")

function PolicyCompletedEvent.emptyNew()
    local self = Event.new(PolicyCompletedEvent_mt)

    return self
end

function PolicyCompletedEvent.new(policyIndex)
    local self = PolicyCompletedEvent.emptyNew()
    self.policyIndex = policyIndex
    return self
end

function PolicyCompletedEvent:writeStream(streamId, connection)
    streamWriteInt32(streamId, self.policyIndex)
end

function PolicyCompletedEvent:readStream(streamId, connection)
    self.policyIndex = streamReadInt32(streamId)
    self:run(connection)
end

function PolicyCompletedEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(PolicyCompletedEvent.new(self.policyIndex))
    end

    local policySystem = g_currentMission.RedTape.PolicySystem
    policySystem:removePolicy(self.policyIndex)
end
