PolicySystem = {}
PolicySystem_mt = Class(PolicySystem)

PolicySystem.COMPLIANCE_LEVEL = {
    D = 1,
    C = 2,
    B = 3,
    A = 4
}
PolicySystem.DESIRED_POLICY_COUNT = 4

function PolicySystem.new()
    local self = {}
    setmetatable(self, PolicySystem_mt)
    self.policies = {}
    self.points = {}

    self:loadFromXMLFile()
    return self
end

function PolicySystem:loadFromXMLFile()
    if (not g_currentMission:getIsServer()) then return end

    local savegameFolderPath = g_currentMission.missionInfo.savegameDirectory;
    if savegameFolderPath == nil then
        savegameFolderPath = ('%ssavegame%d'):format(getUserProfileAppPath(), g_currentMission.missionInfo.savegameIndex)
    end
    savegameFolderPath = savegameFolderPath .. "/"
    local key = "PolicySystem"

    if fileExists(savegameFolderPath .. "RedTape.xml") then
        local xmlFile = loadXMLFile(key, savegameFolderPath .. "RedTape.xml");

        local i = 0
        while true do
            local policyKey = string.format(key .. ".policies.policy(%d)", i)
            if not hasXMLProperty(xmlFile, policyKey) then
                break
            end

            local policy = Policy.new()
            policy:loadFromXMLFile(xmlFile, policyKey)
            g_client:getServerConnection():sendEvent(PolicyActivatedEvent.new(policy))
            i = i + 1
        end

        delete(xmlFile)
    end
end

function PolicySystem:saveToXmlFile()
    if (not g_currentMission:getIsServer()) then return end

    local savegameFolderPath = g_currentMission.missionInfo.savegameDirectory .. "/"
    if savegameFolderPath == nil then
        savegameFolderPath = ('%ssavegame%d'):format(getUserProfileAppPath(),
            g_currentMission.missionInfo.savegameIndex .. "/")
    end

    local key = "PolicySystem";
    local xmlFile = createXMLFile(key, savegameFolderPath .. "RedTape.xml", key);

    local i = 0
    for _, group in pairs(self.policies) do
        local groupKey = string.format("%s.policies.policy(%d)", key, i)
        group:saveToXmlFile(xmlFile, groupKey)
        i = i + 1
    end

    saveXMLFile(xmlFile);
    delete(xmlFile);
end

function PolicySystem:hourChanged()
    -- local self = g_currentMission.RedTape.PolicySystem
end

function PolicySystem:periodChanged()
    local policySystem = g_currentMission.RedTape.PolicySystem

    local complete = {}
    for _, policy in ipairs(policySystem.policies) do
        policy:evaluate()
        if policy.isComplete then table.insert(complete, policy) end
    end

    for i, p in pairs(complete) do
        p:complete()
        policySystem:removePolicy(p)
    end

    policySystem:generatePolicies()
end

function PolicySystem:generatePolicies()
    if #self.policies < PolicySystem.DESIRED_POLICY_COUNT then
        print("Generating new policies...")
        -- generate new policies if needed
        for i = #self.policies + 1, PolicySystem.DESIRED_POLICY_COUNT do
            print("Creating policy " .. i)
            local policy = Policy.new()
            policy.policyIndex = self:getNextPolicyIndex()
            if policy.policyIndex == nil then
                print("No more policies available, stopping generation.")
                break
            else
                print("Assigned policy index: " .. policy.policyIndex)
            end
            policy:activate()
            g_client:getServerConnection():sendEvent(PolicyActivatedEvent.new(policy))
        end
    end
end

function PolicySystem:getNextPolicyIndex()
    local inUse = {}
    for _, policy in pairs(self.policies) do
        if policy.policyIndex then
            inUse[policy.policyIndex] = true
        end
    end

    local availablePolicies = {}
    for id, policy in pairs(Policies) do
        if not inUse[id] then
            table.insert(availablePolicies, policy)
        end
    end

    if #availablePolicies == 0 then
        return nil
    end

    print("Available policies: " .. #availablePolicies)

    -- sum the probabilities of available policies
    local totalProbability = 0
    for _, policy in pairs(availablePolicies) do
        totalProbability = totalProbability + policy.probability
    end

    print("Total probability: " .. totalProbability)

    if totalProbability == 0 then
        return nil -- No available policies to choose from
    end

    -- Choose a random policy based on their probabilities
    local randomValue = math.random() * totalProbability
    local cumulativeProbability = 0
    for _, policy in pairs(availablePolicies) do
        cumulativeProbability = cumulativeProbability + policy.probability
        if randomValue <= cumulativeProbability then
            print("Selected policy: " .. g_i18n:getText(policy.name))
            return policy.id -- Return the ID of the selected policy
        end
    end
    print("No policy selected, returning nil")

    return nil
end

-- Called from PolicyActivatedEvent, runs on client
function PolicySystem:registerActivatedPolicy(policy)
    table.insert(self.policies, policy)
    g_currentMission.RedTape.EventLog:addEvent(policy.farmId, EventLogItem.EVENT_TYPE.POLICY_ACTIVATED,
        string.format(g_i18n:getText("rt_notify_active_policy"), policy:getName()))
end

-- Called from PolicyPointsEvent, runs on client
function PolicySystem:applyPoints(farmId, points, reason)
    if self.points[farmId] == nil then
        self.points[farmId] = 0
    end

    self.points[farmId] = math.max(0, self.points[farmId] + points)
    g_currentMission.RedTape.EventLog:addEvent(farmId, EventLogItem.EVENT_TYPE.POLICY_POINTS, reason)
end

function PolicySystem:removePolicy(policy)
    for i, p in ipairs(self.policies) do
        if p == policy then
            print("Removing policy: " .. p.policyIndex)
            table.remove(self.policies, i)
            break
        end
    end

    -- g_messageCenter:publish(MessageType.POLICY_REMOVED, policy)
end
