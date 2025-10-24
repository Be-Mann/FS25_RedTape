InitialClientStateEvent = {}
local InitialClientStateEvent_mt = Class(InitialClientStateEvent, Event)

InitEventClass(InitialClientStateEvent, "InitialClientStateEvent")

function InitialClientStateEvent.emptyNew()
    return Event.new(InitialClientStateEvent_mt)
end

function InitialClientStateEvent.new()
    return InitialClientStateEvent.emptyNew()
end

function InitialClientStateEvent:writeStream(streamId, connection)
    local rt = g_currentMission.RedTape

    rt.EventLog:writeInitialClientState(streamId, connection)
    rt.PolicySystem:writeInitialClientState(streamId, connection)
    rt.SchemeSystem:writeInitialClientState(streamId, connection)
    rt.TaxSystem:writeInitialClientState(streamId, connection)
end

function InitialClientStateEvent:readStream(streamId, connection)
    local rt = g_currentMission.RedTape

    rt.EventLog:readInitialClientState(streamId, connection)
    rt.PolicySystem:readInitialClientState(streamId, connection)
    rt.SchemeSystem:readInitialClientState(streamId, connection)
    rt.TaxSystem:readInitialClientState(streamId, connection)

    self:run(connection)
end

function InitialClientStateEvent:run(connection)
    g_messageCenter:publish(MessageType.EVENT_LOG_UPDATED)
    g_messageCenter:publish(MessageType.SCHEMES_UPDATED)
end
