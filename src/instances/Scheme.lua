Scheme = {}
Scheme_mt = Class(Scheme)


function Scheme.new()
    local self = {}
    setmetatable(self, Scheme_mt)

    return self
end

function Scheme:saveToXmlFile(xmlFile, key)
    -- setXMLString(xmlFile, key .. "#id", self.id)
end

function Scheme:loadFromXMLFile(xmlFile, key)
    -- self.id = getXMLString(xmlFile, key .. "#id")
end