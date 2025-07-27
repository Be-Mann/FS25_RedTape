Policy = {}
Policy_mt = Class(Policy)

-- Policy.EVALUATION_RESULT = {
--     COMPLIANT = 1,
--     NON_COMPLIANT = 2,
--     NO_RESULT = 3,
--     COMPLETE = 4
-- }

function Policy.new()
    local self = {}
    setmetatable(self, Policy_mt)

    self.policyIndex = nil
    self.nextEvaluationPeriod = nil
    self.evaluationCount = 0
    self.policySystem = g_currentMission.RedTape.PolicySystem

    return self
end

function Policy:saveToXmlFile(xmlFile, key)
    -- setXMLString(xmlFile, key .. "#id", self.id)
end

function Policy:loadFromXMLFile(xmlFile, key)
    -- self.id = getXMLString(xmlFile, key .. "#id")
end

function Policy:activate()
    local policyInfo = Policies[self.policyIndex]

    if policyInfo.evaluationInterval > 0 then
        self.nextEvaluationPeriod = g_currentMission.environment.currentPeriod + policyInfo.evaluationInterval
    end

    policyInfo.activate(policyInfo, self)

    print("Policy activated: " .. policyInfo.name)
    g_currentMission:addIngameNotification(FSBaseMission.INGAME_NOTIFICATION_CRITICAL,
        string.format(g_i18n:getText("rt_notify_active_policy"), policyInfo.name))
end

function Policy:evaluate()
    local policyInfo = Policies[self.policyIndex]
    local currentPeriod = g_currentMission.environment.currentPeriod
    if currentPeriod ~= self.nextEvaluationPeriod then
        return 0, false
    end

    for _, farm in pairs(g_farmManager.getFarms()) do
        local points = policyInfo.evaluate(policyInfo, self, farm.id)
        if points ~= 0 then self.policySystem:applyPoints(self, points, farm.id) end
    end

    self.evaluationCount = self.evaluationCount + 1
    local complete = self.evaluationCount >= policyInfo.maxEvaluationCount

    if not complete then
        self.nextEvaluationPeriod = currentPeriod + policyInfo.evaluationInterval
    end
end

function Policy:complete()
    local policyInfo = Policies[self.policyIndex]
    return policyInfo.complete(policyInfo, self)
end
