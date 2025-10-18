RTTaxLineItem = {}
RTTaxLineItem_mt = Class(RTTaxLineItem)


function RTTaxLineItem.new()
    local self = {}
    setmetatable(self, RTTaxLineItem_mt)

    self.amount = 0
    self.statistic = ""

    return self
end

function RTTaxLineItem:loadFromXMLFile(xmlFile, key)
    self.amount = getXMLInt(xmlFile, key .. "#amount") or 0
    self.statistic = getXMLString(xmlFile, key .. "#statistic") or ""
end

function RTTaxLineItem:saveToXmlFile(xmlFile, key)
    setXMLInt(xmlFile, key .. "#amount", self.amount)
    setXMLString(xmlFile, key .. "#statistic", self.statistic)
end