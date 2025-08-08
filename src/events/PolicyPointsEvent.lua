PolicyPointsEvent = {}
local PolicyPointsEvent_mt = Class(PolicyPointsEvent, Event)

InitEventClass(PolicyPointsEvent, "PolicyPointsEvent")

function PolicyPointsEvent.emptyNew()
    local self = Event.new(PolicyPointsEvent_mt)

    return self
end

function PolicyPointsEvent.new(farmId, pointChange, reason)
    local self = PolicyPointsEvent.emptyNew()
    self.farmId = farmId
    self.pointChange = pointChange
    self.reason = reason
    return self
end

function PolicyPointsEvent:writeStream(streamId, connection)
    streamWriteString(streamId, self.farmId)
    streamWriteInt32(streamId, self.pointChange)
    streamWriteString(streamId, self.reason)
end

function PolicyPointsEvent:readStream(streamId, connection)
    self.farmId = streamReadString(streamId)
    self.pointChange = streamReadInt32(streamId)
    self.reason = streamReadString(streamId)

    self:run(connection)
end

function PolicyPointsEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(PolicyPointsEvent.new(self.farmId, self.pointChange, self.reason))
    end

    local policySystem = g_currentMission.RedTape.PolicySystem
    policySystem:applyPoints(self.farmId, self.pointChange, self.reason)
end
