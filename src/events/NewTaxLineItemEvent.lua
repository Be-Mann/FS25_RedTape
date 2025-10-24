RTNewTaxLineItemEvent = {}
local RTNewTaxLineItemEvent_mt = Class(RTNewTaxLineItemEvent, Event)

InitEventClass(RTNewTaxLineItemEvent, "RTNewTaxLineItemEvent")

function RTNewTaxLineItemEvent.emptyNew()
    return Event.new(RTNewTaxLineItemEvent_mt)
end

function RTNewTaxLineItemEvent.new(farmId, lineItem)
    local self = RTNewTaxLineItemEvent.emptyNew()

    self.farmId = farmId
    self.lineItem = lineItem

    return self
end

function RTNewTaxLineItemEvent:writeStream(streamId, connection)
    streamWriteInt32(streamId, self.farmId)
    self.lineItem:writeStream(streamId, connection)
end

function RTNewTaxLineItemEvent:readStream(streamId, connection)
    self.farmId = streamReadInt32(streamId)
    self.lineItem = RTTaxLineItem.new()
    self.lineItem:readStream(streamId, connection)
    self:run(connection)
end

function RTNewTaxLineItemEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(RTNewTaxLineItemEvent.new(self.farmId, self.lineItem))
    end

    local taxSystem = g_currentMission.RedTape.TaxSystem
    taxSystem:recordLineItem(self.farmId, self.lineItem)
end
