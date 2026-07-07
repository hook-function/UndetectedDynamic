local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/hook-function/UndetectedDynamic/refs/heads/main/Library.lua"))()

Library:AutoLoadConfig(true)

local win = Library:CreateWindow({
	Title = "Undetected Dynamic",
	Size = Vector2.new(620, 450),
})

local tab = win:AddTab("Main")
local set = win:AddTab("Settings")

-- ─── MAIN ───

local ctrl = tab:AddCategory("Controls")

ctrl:AddButton("Click Me", function()
	print("clicked")
end)

ctrl:AddToggle("Enable", {
	Id = "enable",
	Default = true,
	Callback = function(v) print("toggle:", v) end,
})

ctrl:AddSlider("Volume", {
	Id = "volume",
	Min = 0, Max = 100, Default = 50, Suffix = "%",
	Callback = function(v) print("vol:", v) end,
})

ctrl:AddInput("Name", {
	Id = "name",
	Default = "Player",
	Placeholder = "enter name",
	Callback = function(v) print("input:", v) end,
})

ctrl:AddDropdown("Difficulty", {
	Id = "diff",
	Items = {"Easy", "Normal", "Hard"},
	Default = "Normal",
	Callback = function(v) print("diff:", v) end,
})

ctrl:AddColorPicker("Color", {
	Id = "color",
	Default = Color3.fromRGB(88, 101, 242),
	Callback = function(c) print("color:", c) end,
})

ctrl:AddDivider()
ctrl:AddLabel("Status: Ready")

-- ─── SETTINGS ───

local sg = set:AddCategory("General")

sg:AddToggle("Dark Mode", {
	Id = "darkmode",
	Default = true,
})

sg:AddSlider("Sensitivity", {
	Id = "sens",
	Min = 1, Max = 10, Default = 5, Precise = true,
	Callback = function(v) print("sens:", v) end,
})

-- config section
sg:AddDivider()
sg:AddLabel("Configuration")

sg:AddInput("Config Name", {
	Id = "cfg_name",
	Default = "my_config",
	Placeholder = "config name",
})

sg:AddButton("Save Config", function()
	local name = Library.Opts.cfg_name:GetValue()
	Library:CreateConfig(name)
	Library:SaveConfig()
	print("saved:", name)
end)

sg:AddButton("Load Config", function()
	local name = Library.Opts.cfg_name:GetValue()
	Library:LoadConfig(name)
	print("loaded:", name)
end)

sg:AddButton("Delete Config", function()
	local name = Library.Opts.cfg_name:GetValue()
	Library:DeleteConfig(name)
	print("deleted:", name)
end)

sg:AddButton("Refresh Config List", function()
	local list = Library:ListConfigs()
	print("configs:", table.concat(list, ", "))
end)

sg:AddDivider()
sg:AddLabel("Keybind")

sg:AddButton("Toggle Key: F2", function()
	win:SetToggleKey(Enum.KeyCode.F2)
	print("toggle key -> F2")
end)

sg:AddButton("Toggle Key: RightControl", function()
	win:SetToggleKey(Enum.KeyCode.RightControl)
	print("toggle key -> RightControl")
end)

win:Build()