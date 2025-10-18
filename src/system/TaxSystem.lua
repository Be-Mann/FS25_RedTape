RTTaxSystem = {}
RTTaxSystem_mt = Class(RTTaxSystem)

RTTaxSystem.TAX_CALCULATION_MONTH = 4
RTTaxSystem.TAX_PAYMENT_MONTH = 9

RTTaxSystem.LINE_ITEM_CATEGORIES = {
    INCOME = "income",
    EXPENSES = "expenses",
    NONE = "none"
}

function RTTaxSystem.new()
    local self = {}
    setmetatable(self, RTTaxSystem_mt)
    self.lineItems = {}
    self.taxStatements = {}

    return self
end

function RTTaxSystem:loadFromXMLFile(xmlFile)
    if (not g_currentMission:getIsServer()) then return end

    local key = RedTape.SaveKey .. ".taxSystem"

    -- initialize as nested table: lineItems[farmId][month] = TaxLineItem
    self.lineItems = {}

    local i = 0
    while true do
        local lineItemKey = string.format("%s.lineItems.lineItem(%d)", key, i)
        if not hasXMLProperty(xmlFile, lineItemKey) then
            break
        end

        local farmId = getXMLInt(xmlFile, lineItemKey .. "#farmId")
        local month = getXMLInt(xmlFile, lineItemKey .. "#month")

        if self.lineItems[farmId] == nil then
            self.lineItems[farmId] = {}
        end
        if self.lineItems[farmId][month] == nil then
            self.lineItems[farmId][month] = {}
        end

        local lineItem = RTTaxLineItem.new()
        lineItem:loadFromXMLFile(xmlFile, lineItemKey)

        table.insert(self.lineItems[farmId][month], lineItem)

        i = i + 1
    end
end

function RTTaxSystem:saveToXmlFile(xmlFile)
    if (not g_currentMission:getIsServer()) then return end

    local key = RedTape.SaveKey .. ".taxSystem"

    local i = 0
    for farmId, months in pairs(self.lineItems) do
        for month, lineItems in pairs(months) do
            for _, lineItem in ipairs(lineItems) do
                local lineItemKey = string.format("%s.lineItems.lineItem(%d)", key, i)
                setXMLInt(xmlFile, lineItemKey .. "#farmId", farmId)
                setXMLInt(xmlFile, lineItemKey .. "#month", month)
                lineItem:saveToXmlFile(xmlFile, lineItemKey)
                i = i + 1
            end
        end
    end
end

function RTTaxSystem:hourChanged()
end

function RTTaxSystem:periodChanged()
    local month = RedTape.periodToMonth(g_currentMission.environment.currentPeriod)
    if month == RTTaxSystem.TAX_CALCULATION_MONTH then
        self:createAnnualTaxStatements()
    end

    local cumulativeMonth = RedTape.getCumulativeMonth()
    local oldestHistoryMonth = cumulativeMonth - 24

    -- Clean up old tax line items
    for farmId, months in pairs(self.lineItems) do
        for month, _ in pairs(months) do
            if month < oldestHistoryMonth then
                self.lineItems[farmId][month] = nil
            end
        end
    end
end

function RTTaxSystem:recordLineItem(farmId, amount, statistic)
    local cumulativeMonth = RedTape.getCumulativeMonth()
    self.lineItems[farmId] = self.lineItems[farmId] or {}

    if self.lineItems[farmId][cumulativeMonth] == nil then
        self.lineItems[farmId][cumulativeMonth] = {}
    end

    local lineItem = RTTaxLineItem.new()
    lineItem.amount = amount
    lineItem.statistic = statistic

    table.insert(self.lineItems[farmId][cumulativeMonth], lineItem)
end

function RTTaxSystem:getTaxRate(farmId)
    -- For simplicity, return a flat tax rate of 20%
    return 0.2
end

function RTTaxSystem:categoriseLineItem(farmId, lineItem)
    local expenseStats = {
        "test"
    }

    local incomeStats = {
        "income"
    }

    if RedTape.tableContains(expenseStats, lineItem.statistic) then
        return RTTaxSystem.LINE_ITEM_CATEGORIES.EXPENSES
    elseif RedTape.tableContains(incomeStats, lineItem.statistic) then
        return RTTaxSystem.LINE_ITEM_CATEGORIES.INCOME
    end

    return RTTaxSystem.LINE_ITEM_CATEGORIES.NONE
end

function RTTaxSystem:createAnnualTaxStatements()
    for farmId, months in pairs(self.lineItems) do
        local taxStatement = RTTaxStatement.new()
        taxStatement.farmId = farmId

        for month, lineItems in pairs(months) do
            for _, lineItem in ipairs(lineItems) do
                local category = self:categoriseLineItem(farmId, lineItem)
                if category == RTTaxSystem.LINE_ITEM_CATEGORIES.INCOME then
                    taxStatement.totalIncome = taxStatement.totalIncome + math.abs(lineItem.amount)
                elseif category == RTTaxSystem.LINE_ITEM_CATEGORIES.EXPENSES then
                    taxStatement.totalExpenses = taxStatement.totalExpenses + math.abs(lineItem.amount)
                end
            end
        end

        g_client:getServerConnection():sendEvent(RTNewTaxStatementEvent.new(taxStatement))
    end
end

-- Called via NewTaxStatementEvent to store on client and server
function RTTaxSystem:storeTaxStatement(taxStatement)
    local farmId = taxStatement.farmId

    -- Replace existing statement for farmId if exists
    for i, existingStatement in ipairs(self.taxStatements) do
        if existingStatement.farmId == farmId then
            self.taxStatements[i] = taxStatement
            return
        end
    end

    table.insert(self.taxStatements, taxStatement)
end
