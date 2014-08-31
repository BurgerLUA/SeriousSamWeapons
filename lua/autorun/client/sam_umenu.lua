function SS_SettingsPanel(Panel)
	Panel:AddControl("Label", {Text = "Server"})
	Panel:AddControl("CheckBox", {Label = "Unlimited Ammo", Command = "ss_unlimitedammo"})
	Panel:AddControl("Label", {Text = "Client"})
	Panel:AddControl("CheckBox", {Label = "Fire Lighting", Command = "ss_firelight"})
	Panel:AddControl("Slider", {Label = "Crosshair", Command = "ss_crosshair", Type = "Integer", Min = 0, Max = 7})
end

function SS_PopulateToolMenu()
	spawnmenu.AddToolMenuOption("Utilities", "Serious Sam", "SSSettings", "Settings", "", "", SS_SettingsPanel)
end

hook.Add("PopulateToolMenu", "SS_PopulateToolMenu", SS_PopulateToolMenu)