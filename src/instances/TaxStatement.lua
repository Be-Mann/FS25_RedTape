RTTaxStatement = {}
RTTaxStatement_mt = Class(RTTaxStatement)

function RTTaxStatement.new()
    local self = {}
    setmetatable(self, RTTaxStatement_mt)

    self.farmId = -1
    self.month = RedTape.getCumulativeMonth()
    self.totalIncome = 0
    self.totalExpenses = 0
    self.notes = {}

    return self
end

function RTTaxStatement:saveToXmlFile(xmlFile, key)
    setXMLInt(xmlFile, key .. "#farmId", self.farmId)
    setXMLInt(xmlFile, key .. "#month", self.month)
    setXMLInt(xmlFile, key .. "#totalIncome", self.totalIncome)
    setXMLInt(xmlFile, key .. "#totalExpenses", self.totalExpenses)


    local notesKey = key .. ".notes"
    for i, note in ipairs(self.notes) do
        local noteKey = string.format("%s.note(%d)", notesKey, i - 1)
        setXMLString(xmlFile, noteKey, note)
    end
end

function RTTaxStatement:loadFromXMLFile(xmlFile, key)
    self.farmId = getXMLInt(xmlFile, key .. "#farmId")
    self.month = getXMLInt(xmlFile, key .. "#month")
    self.totalIncome = getXMLInt(xmlFile, key .. "#totalIncome")
    self.totalExpenses = getXMLInt(xmlFile, key .. "#totalExpenses")

    self.notes = {}
    local notesKey = key .. ".notes"
    local i = 0
    while true do
        local noteKey = string.format("%s.note(%d)", notesKey, i)
        if not hasXMLProperty(xmlFile, noteKey) then
            break
        end

        local note = getXMLString(xmlFile, noteKey)
        table.insert(self.notes, note)

        i = i + 1
    end
end

function RTTaxStatement:writeStream(streamId, connection)
    streamWriteInt32(streamId, self.farmId)
    streamWriteInt32(streamId, self.totalIncome)
    streamWriteInt32(streamId, self.totalExpenses)

    streamWriteInt32(streamId, #self.notes)
    for _, note in ipairs(self.notes) do
        streamWriteString(streamId, note)
    end
end

function RTTaxStatement:readStream(streamId, connection)
    self.farmId = streamReadInt32(streamId)
    self.totalIncome = streamReadInt32(streamId)
    self.totalExpenses = streamReadInt32(streamId)

    local notesCount = streamReadInt32(streamId)
    self.notes = {}
    for i = 1, notesCount do
        local note = streamReadString(streamId)
        table.insert(self.notes, note)
    end
end
