RTReportRenderer = {}
RTReportRenderer_mt = Class(RTReportRenderer)

function RTReportRenderer.new()
    local self = {}
    setmetatable(self, RTReportRenderer_mt)
    self.data = nil
    self.selectedRow = -1;
    self.indexChangedCallback = nil

    return self
end

function RTReportRenderer:setData(data)
    self.data = data
end

function RTReportRenderer:getNumberOfSections()
    return 1
end

function RTReportRenderer:getNumberOfItemsInSection(list, section)
    return #self.data
end

function RTReportRenderer:getTitleForSectionHeader(list, section)
    return ""
end

function RTReportRenderer:populateCellForItemInSection(list, section, index, cell)
    local reportItem = self.data[index]
    cell:getAttribute("cell1"):setText(reportItem.cell1)
    cell:getAttribute("cell2"):setText(reportItem.cell2)
    cell:getAttribute("cell3"):setText(reportItem.cell3)
end

function RTReportRenderer:onListSelectionChanged(list, section, index)
    self.selectedRow = index
    if self.indexChangedCallback ~= nil then
        self.indexChangedCallback(index)
    end
end
