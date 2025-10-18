RTFarmExtension = {}

function RTFarmExtension.changeBalance(farm, amount, moneyType)
    if g_currentMission:getIsServer() then
        local farmId = farm.farmId
        local statistic = moneyType.statistic
    end
end

Farm.changeBalance = Utils.appendedFunction(Farm.changeBalance, RTFarmExtension.changeBalance)
