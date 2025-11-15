RTPlaceableHusbandryAnimalsExtension = {}

function RTPlaceableHusbandryAnimalsExtension:addAnimals(subTypeIndex, numAnimals, age)
    local existingAnimalCount = self:getNumOfAnimals()
    if existingAnimalCount == 0 then
        local ig = g_currentMission.RedTape.InfoGatherer
        local gatherer = ig.gatherers[INFO_KEYS.FARMS]
        gatherer:addProductivityException(self, 24)
    end
end

PlaceableHusbandryAnimals.addAnimals = Utils.appendedFunction(PlaceableHusbandryAnimals.addAnimals,
    RTPlaceableHusbandryAnimalsExtension.addAnimals)
