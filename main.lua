local Library = loadstring(game:HttpGet("raw url of your Library.lua"))()

-- optional: custom theme
Library:SetTheme({
	acc = Color3.fromRGB(255, 100, 100),
	bg = Color3.fromRGB(20, 20, 25),
})

-- create config (optional name)
Library:CreateConfig("my_settings")
Library:AutoLoadConfig(true)

local win = Library:CreateWindow({
	Title = "Undetected Dynamic",
	Size = Vector2.new(620, 450),
	-- ToggleKey = Enum.KeyCode.LeftShift, -- custom toggle key
})

local tab = win:AddTab("Main")
local set = win:AddTab("Settings")

-- ─── MAIN ───

local ctrl = tab:AddCategory("Controls")

ctrl:AddButton("Click Me", function()
	print("clicked")
end)

ctrl:AddToggle("Enable", {
	Default = true,
	Callback = function(v) print("toggle:", v) end,
})

ctrl:AddSlider("Volume", {
	Min = 0, Max = 100, Default = 50, Suffix = "%",
	Callback = function(v) print("vol:", v) end,
})

ctrl:AddInput("Name", {
	Default = "Player",
	Placeholder = "enter name",
	Callback = function(v) print("input:", v) end,
})

ctrl:AddDropdown("Difficulty", {
	Items = {"Easy", "Normal", "Hard"},
	Default = "Normal",
	Callback = function(v) print("diff:", v) end,
})

ctrl:AddColorPicker("Color", {
	Default = Color3.fromRGB(88, 101, 242),
	Callback = function(c) print("color:", c) end,
})

ctrl:AddDivider()
ctrl:AddLabel("Status: Ready")

-- ─── SETTINGS ───

local sg = set:AddCategory("General")

sg:AddToggle("Dark Mode", {Default = true})

sg:AddSlider("Sensitivity", {
	Min = 1, Max = 10, Default = 5, Precise = true,
	Callback = function(v) print("sens:", v) end,
})

-- config buttons
sg:AddDivider()
sg:AddLabel("Configuration")

sg:AddButton("Save Config", function()
	Library:SaveConfig()
	print("saved")
end)

sg:AddButton("Load Config", function()
	Library:LoadConfig()
	print("loaded")
end)

sg:AddButton("Export Config", function()
	local json = Library:ExportConfig()
	print("exported:", json)
	setclipboard and setclipboard(json)
end)

sg:AddInput("Import Config", {
	Placeholder = "paste json here",
	Callback = function(v)
		Library:ImportConfig(v)
		print("imported")
	end,
})

-- change toggle key
sg:AddDivider()
sg:AddLabel("Keybind")

sg:AddButton("Set Toggle to F2", function()
	win:SetToggleKey(Enum.KeyCode.F2)
	print("toggle changed to F2")
end)

sg:AddButton("Set Toggle to F3", function()
	win:SetToggleKey(Enum.KeyCode.F3)
	print("toggle changed to F3")
end)

win:Build()
