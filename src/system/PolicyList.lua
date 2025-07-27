PolicyIds = {
    CROP_ROTATION = 1
}

Policies = {
    [PolicyIds.CROP_ROTATION] = {
        id = PolicyIds.CROP_ROTATION,
        -- name = "Crop Rotation",
        -- description = "Encourages farmers to rotate crops to maintain soil health.",
        probability = 0.8,
        endConditions = {
            -- Define conditions for the policy to end
            -- e.g., after a certain number of periods or if certain criteria are met
        },
        periodicReward = 0,
        completeReward = 100,
        evaluationInterval = 12,
        maxEvaluationCount = 1,
        activate = function(policyInfo, policy)

        end,
        evaluate = function(policyInfo, policy, farmId)
            local data = g_currentMission.RedTape.data
            local currentPeriod = g_currentMission.environment.currentPeriod

            -- Logic to evaluate crop rotation compliance


            return policyInfo.periodicReward
        end,
        complete = function(policyInfo, policy)
            print("Crop Rotation policy completed.")

            -- Custom Logic to handle policy completion


            return policyInfo.completeReward
        end,
    }
}
