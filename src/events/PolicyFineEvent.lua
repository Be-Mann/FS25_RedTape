RTPolicyFineEvent = {}
local RTPolicyFineEvent_mt = Class(RTPolicyFineEvent, Event)

InitEventClass(RTPolicyFineEvent, "RTPolicyFineEvent")

function RTPolicyFineEvent.emptyNew()
    local self = Event.new(RTPolicyFineEvent_mt)

    return self
end

function RTPolicyFineEvent.new(farmId, policyIndex, amount)
    local self = RTPolicyFineEvent.emptyNew()
    self.farmId = farmId
    self.policyIndex = policyIndex
    self.amount = math.abs(amount)
    return self
end

function RTPolicyFineEvent:writeStream(streamId, connection)
    streamWriteString(streamId, self.farmId)
    streamWriteInt32(streamId, self.policyIndex)
    streamWriteInt32(streamId, self.amount)
end

function RTPolicyFineEvent:readStream(streamId, connection)
    self.farmId = streamReadString(streamId)
    self.policyIndex = streamReadInt32(streamId)
    self.amount = streamReadInt32(streamId)

    self:run(connection)
end

function RTPolicyFineEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(RTPolicyFineEvent.new(self.farmId, self.policyIndex, self.amount))
    end

    g_currentMission.RedTape.PolicySystem:recordFine(self.farmId, self.policyIndex, self.amount)
end
