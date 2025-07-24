Policy = {}
Policy_mt = Class(Policy)

Policy.EVALUATION_RESULT = {
    COMPLIANT = 1,
    NON_COMPLIANT = 2,
    NO_RESULT = 3,
    COMPLETE = 4
}

function Policy.new()
    local self = {}
    setmetatable(self, Policy_mt)

    self.policyIndex = nil
    self.policySystem = g_currentMission.RedTape.PolicySystem

    return self
end

function Policy:saveToXmlFile(xmlFile, key)
    -- setXMLString(xmlFile, key .. "#id", self.id)
end

function Policy:loadFromXMLFile(xmlFile, key)
    -- self.id = getXMLString(xmlFile, key .. "#id")
end

function Policy:evaluate()
    local policyInfo = Policies[self.policyIndex]
    local result = policyInfo.evaluate(self)

    if result == Policy.EVALUATION_RESULT.COMPLETE then
        self:complete()
    end
end

function Policy:complete()
    self.policySystem:applyPoints(self, self.reward)
    -- more stuff to end, deregister, etc
end
