AvailableSchemesRenderer = {}
AvailableSchemesRenderer_mt = Class(AvailableSchemesRenderer)

function AvailableSchemesRenderer:new(parent)
    local self = {}
    setmetatable(self, AvailableSchemesRenderer_mt)
    self.parent = parent
    self.data = nil
    self.selectedRow = -1;

    return self
end

function AvailableSchemesRenderer:setData(data)
    self.data = data
end

function AvailableSchemesRenderer:getNumberOfSections()
    return 1
end

function AvailableSchemesRenderer:getNumberOfItemsInSection(list, section)
    return #self.data
end

function AvailableSchemesRenderer:getTitleForSectionHeader(list, section)
    return ""
end

function AvailableSchemesRenderer:populateCellForItemInSection(list, section, index, cell)
    local scheme = self.data[index]
    local rt = g_currentMission.RedTape

    cell:getAttribute("name"):setText(scheme:getName())
end

function AvailableSchemesRenderer:onListSelectionChanged(list, section, index)
    self.selectedRow = index
end
