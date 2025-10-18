RTEventLogRenderer = {}
RTEventLogRenderer_mt = Class(RTEventLogRenderer)

function RTEventLogRenderer.new()
    local self = {}
    setmetatable(self, RTEventLogRenderer_mt)
    self.data = nil
    self.selectedRow = -1;
    self.indexChangedCallback = nil

    return self
end

function RTEventLogRenderer:setData(data)
    self.data = data
end

function RTEventLogRenderer:getNumberOfSections()
    return 1
end

function RTEventLogRenderer:getNumberOfItemsInSection(list, section)
    return #self.data
end

function RTEventLogRenderer:getTitleForSectionHeader(list, section)
    return ""
end

function RTEventLogRenderer:populateCellForItemInSection(list, section, index, cell)
    local eventLogItem = self.data[index]

    cell:getAttribute("timestamp"):setText(eventLogItem:getTimeStampString())
    cell:getAttribute("eventType"):setText(g_i18n:getText(RTEventLogItem.EVENT_TYPE_LABELS[eventLogItem.eventType]))
    cell:getAttribute("detail"):setText(eventLogItem.detail)
end

function RTEventLogRenderer:onListSelectionChanged(list, section, index)
    self.selectedRow = index
    if self.indexChangedCallback ~= nil then
        self.indexChangedCallback(index)
    end
end
