RTSnowSystemExtension = {}

function RTSnowSystemExtension:removeAll(force)
    local rt = g_currentMission.RedTape
    if not rt.missionStarted then
        return
    end

    if self.isServer then
        rt.SchemeSystem:onSnowEnded()
        rt.InfoGatherer.gatherers[INFO_KEYS.FARMS]:onSnowEnded()
    end
end

SnowSystem.removeAll = Utils.appendedFunction(SnowSystem.removeAll,
    RTSnowSystemExtension.removeAll)

function RTSnowSystemExtension:applySnow(delta)
    local rt = g_currentMission.RedTape
    if not rt.missionStarted then
        return
    end

    if self.isServer then
        if delta > 0 then
            rt.InfoGatherer.gatherers[INFO_KEYS.FARMS]:onSnowApplied()
            rt.SchemeSystem:onSnowApplied()
        end
    end
end

SnowSystem.applySnow = Utils.appendedFunction(SnowSystem.applySnow,
    RTSnowSystemExtension.applySnow)
