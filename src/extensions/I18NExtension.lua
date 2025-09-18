I18NExtension = {}
local modName = g_currentModName

function I18NExtension:getText(superFunc, text, modEnv)

    if (text == "rt_ui_schemePayout" or text == "finance_schemePayout") and modEnv == nil then
        return superFunc(self, text, modName)
    end

    return superFunc(self, text, modEnv)

end

I18N.getText = Utils.overwrittenFunction(I18N.getText, I18NExtension.getText)