-- A payout when a scheme is evaluated
RTNewTaxStatementEvent = {}
local RTNewTaxStatementEvent_mt = Class(RTNewTaxStatementEvent, Event)

InitEventClass(RTNewTaxStatementEvent, "RTNewTaxStatementEvent")

function RTNewTaxStatementEvent.emptyNew()
    local self = Event.new(RTNewTaxStatementEvent_mt)

    return self
end

function RTNewTaxStatementEvent.new(statement)
    local self = RTNewTaxStatementEvent.emptyNew()
    self.statement = statement
    return self
end

function RTNewTaxStatementEvent:writeStream(streamId, connection)
    self.statement:writeStream(streamId, connection)
end

function RTNewTaxStatementEvent:readStream(streamId, connection)
    self.statement = RTTaxStatement.new()
    self.statement:readStream(streamId, connection)
    self:run(connection)
end

function RTNewTaxStatementEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(RTNewTaxStatementEvent.new(self.statement))
    end

    local taxSystem = g_currentMission.RedTape.TaxSystem
    taxSystem:storeTaxStatement(self.statement)
end
