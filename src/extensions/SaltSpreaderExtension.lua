RTSaltSpreaderExtension = {}

function RTSaltSpreaderExtension:processSaltSpreaderArea(superFunc, workArea)
    if self.isServer then
        local rt = g_currentMission.RedTape
        local snowOnGround = rt.InfoGatherer.gatherers[INFO_KEYS.FARMS].snowOnGround
        if not snowOnGround then
            return superFunc(self, workArea)
        end

        local x, y, z = getWorldTranslation(self.rootNode)

        for _, spline in pairs(g_currentMission.aiSystem.roadSplines) do
            local splineX, splineY, splineZ = getClosestSplinePosition(spline, x, y, z, 0.5)
            local distance = MathUtil.vector3Length(x - splineX, y - splineY, z - splineZ)

            if distance < 2 then
                local gridX, gridY, gridZ = RedTape.getGridPosition(splineX, splineY, splineZ, 10)
                local farmId = self:getOwnerFarmId()
                local farmGatherer = g_currentMission.RedTape.InfoGatherer.gatherers[INFO_KEYS.FARMS]
                farmGatherer:recordSaltSpread(gridX, gridY, gridZ, spline, farmId)
            end
        end
    end
    return superFunc(self, workArea)
end

SaltSpreader.processSaltSpreaderArea = Utils.overwrittenFunction(SaltSpreader.processSaltSpreaderArea,
    RTSaltSpreaderExtension.processSaltSpreaderArea)
