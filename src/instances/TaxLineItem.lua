TaxLineItem = {}
TaxLineItem_mt = Class(TaxLineItem)


function TaxLineItem.new()
    local self = {}
    setmetatable(self, TaxLineItem_mt)

    return self
end
