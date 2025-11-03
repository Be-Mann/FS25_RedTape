RTPolicyActivatedEvent = {}
local RTPolicyActivatedEvent_mt = Class(RTPolicyActivatedEvent, Event)

InitEventClass(RTPolicyActivatedEvent, "RTPolicyActivatedEvent")

function RTPolicyActivatedEvent.emptyNew()
    local self = Event.new(RTPolicyActivatedEvent_mt)

    return self
end

function RTPolicyActivatedEvent.new(policy)
    local self = RTPolicyActivatedEvent.emptyNew()
    self.policy = policy
    return self
end

function RTPolicyActivatedEvent:writeStream(streamId, connection)
    self.policy:writeStream(streamId, connection)
end

function RTPolicyActivatedEvent:readStream(streamId, connection)
    self.policy = RTPolicy.new()
    self.policy:readStream(streamId, connection)
    self:run(connection)
end

function RTPolicyActivatedEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(RTPolicyActivatedEvent.new(self.policy))
    end

    local policySystem = g_currentMission.RedTape.PolicySystem
    policySystem:registerActivatedPolicy(self.policy, false)
end
