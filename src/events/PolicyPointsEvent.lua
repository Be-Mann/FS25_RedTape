RTPolicyPointsEvent = {}
local RTPolicyPointsEvent_mt = Class(RTPolicyPointsEvent, Event)

InitEventClass(RTPolicyPointsEvent, "RTPolicyPointsEvent")

function RTPolicyPointsEvent.emptyNew()
    local self = Event.new(RTPolicyPointsEvent_mt)

    return self
end

function RTPolicyPointsEvent.new(farmId, pointChange, policyName)
    local self = RTPolicyPointsEvent.emptyNew()
    self.farmId = farmId
    self.pointChange = pointChange
    self.policyName = policyName
    return self
end

function RTPolicyPointsEvent:writeStream(streamId, connection)
    streamWriteInt32(streamId, self.farmId)
    streamWriteInt32(streamId, self.pointChange)
    streamWriteString(streamId, self.policyName)
end

function RTPolicyPointsEvent:readStream(streamId, connection)
    self.farmId = streamReadInt32(streamId)
    self.pointChange = streamReadInt32(streamId)
    self.policyName = streamReadString(streamId)

    self:run(connection)
end

function RTPolicyPointsEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(RTPolicyPointsEvent.new(self.farmId, self.pointChange, self.policyName))
    end

    local reason = string.format(g_i18n:getText("rt_policy_reason_evaluation"), self.pointChange, self.policyName)
    g_currentMission.RedTape.PolicySystem:applyPoints(self.farmId, self.pointChange, reason)
end
