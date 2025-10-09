ActivePoliciesRenderer = {}
ActivePoliciesRenderer_mt = Class(ActivePoliciesRenderer)

function ActivePoliciesRenderer.new()
    local self = {}
    setmetatable(self, ActivePoliciesRenderer_mt)
    self.data = nil
    self.selectedRow = -1;
    self.indexChangedCallback = nil

    return self
end

function ActivePoliciesRenderer:setData(data)
    self.data = data
end

function ActivePoliciesRenderer:getNumberOfSections()
    return 1
end

function ActivePoliciesRenderer:getNumberOfItemsInSection(list, section)
    return #self.data
end

function ActivePoliciesRenderer:getTitleForSectionHeader(list, section)
    return ""
end

function ActivePoliciesRenderer:populateCellForItemInSection(list, section, index, cell)
    local activePolicy = self.data[index]

    cell:getAttribute("name"):setText(activePolicy:getName())
end

function ActivePoliciesRenderer:onListSelectionChanged(list, section, index)
    self.selectedRow = index
    if self.indexChangedCallback ~= nil then
        self.indexChangedCallback(index)
    end
end
