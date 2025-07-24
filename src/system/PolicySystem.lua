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
    self.points = 0
    self.facts = {}
    -- self.grade = PolicySystem.COMPLIANCE_LEVEL.C

    g_messageCenter:subscribe(MessageType.HOUR_CHANGED, PolicySystem.hourChanged)
    g_messageCenter:subscribe(MessageType.PERIOD_CHANGED, PolicySystem.periodChanged)

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

    if fileExists(savegameFolderPath .. "PolicySystem.xml") then
        local xmlFile = loadXMLFile(key, savegameFolderPath .. "PolicySystem.xml");

        local i = 0
        while true do
            local policyKey = string.format(key .. ".policies.policy(%d)", i)
            if not hasXMLProperty(xmlFile, policyKey) then
                break
            end

            local policy = Policy.new()
            policy:loadFromXMLFile(xmlFile, policyKey)
            table.insert(self.policies, policy)
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
    local xmlFile = createXMLFile(key, savegameFolderPath .. "PolicySystem.xml", key);

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
    -- self:gatherFacts()
end

function PolicySystem:periodChanged()
    self:gatherFacts()

    if #self.policies < PolicySystem.DESIRED_POLICY_COUNT then
        -- generate new policies if needed
        for i = #self.policies + 1, PolicySystem.DESIRED_POLICY_COUNT do
            local policy = Policy.new()
            policy.policyIndex = PolicyIds.CROP_ROTATION -- Example, should be randomized or chosen based on facts
            table.insert(self.policies, policy)
        end
    end

    for key, policy in pairs(self.policies) do
        policy:evaluate()
    end
end

function PolicySystem:getNextPolicyIndex()
    local inUse = {}
    for _, policy in pairs(self.policies) do
        if policy.policyIndex then
            inUse[policy.policyIndex] = true
        end
    end

    for name, id in pairs(PolicyIds) do
        if not inUse[id] then
            return index
        end
    end
end

function PolicySystem:gatherFacts()
    local facts = {}

    -- gather everything we need to evaluate the policies

    -- get list of fields and the crops

    

    return facts
end

function PolicySystem:applyPoints(policy, points)
    if points > 0 then
        self.points = self.points + points
    else
        self.points = math.max(0, self.points + points)
    end

    -- g_messageCenter:publish(MessageType.POLICY_POINTS_CHANGED, self.points)
end

function PolicySystem:removePolicy(policy)
    for i, p in ipairs(self.policies) do
        if p == policy then
            table.remove(self.policies, i)
            break
        end
    end

    -- g_messageCenter:publish(MessageType.POLICY_REMOVED, policy)
end
