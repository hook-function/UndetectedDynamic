local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUsername/YourRepo/main/Library.lua"))()

Library:AutoLoadConfig(true)

local win = Library:CreateWindow({
	Title = "Galaxivity Premium",
	Size = Vector2.new(620, 440),
	ToggleKey = Enum.KeyCode.RightControl
})

local tab = win:AddTab("Main Operations")
local set = win:AddTab("Configuration")

-- ─── MAIN CATEGORY ───
local ctrl = tab:AddCategory("Combat Features")

ctrl:AddToggle("Master Switch", {
	Id = "enable",
	Default = true,
	Callback = function(v) print("[Galaxivity]: Active State ->", v) end,
})

ctrl:AddSlider("Field of View", {
	Id = "volume",
	Min = 0, Max = 120, Default = 70, Suffix = "°",
	Callback = function(v) print("[Galaxivity]: FOV Adjusted ->", v) end,
})

ctrl:AddDropdown("Target Priority", {
	Id = "diff",
	Items = {"Distance", "Health", "Crosshair"},
	Default = "Crosshair",
	Callback = function(v) print("[Galaxivity]: Targeting Mode ->", v) end,
})

ctrl:AddInput("Custom Tag Label", {
	Id = "name",
	Default = "Galaxivity User",
	Placeholder = "Enter alias...",
	Callback = function(v) print("[Galaxivity]: String Variable ->", v) end,
})

ctrl:AddDivider()
ctrl:AddLabel("Visual Aesthetics")

ctrl:AddColorPicker("Interface Accent", {
	Id = "color",
	Default = Color3.fromRGB(99, 102, 241),
	Callback = function(c) 
		Library:SetTheme({acc = c})
		print("[Galaxivity]: Color Matrix Updated") 
	end,
})

ctrl:AddKeybind("Panic Keybind", {
	Id = "toggle_key",
	Default = "LeftAlt",
	Callback = function(k) print("[Galaxivity]: Termination bound to ->", k) end,
})

-- ─── SETTINGS CATEGORY ───
local sg = set:AddCategory("Profile Engine")

sg:AddInput("Active Config File", {
	Id = "cfg_name",
	Default = "default_profile",
	Placeholder = "Profile identity...",
})

local configDropdown = sg:AddDropdown("Stored Profiles", {
	Id = "saved_configs",
	Items = Library:ListConfigs(),
	Default = "",
	Callback = function(selected)
		if selected and selected ~= "" then
			Library.Opts.cfg_name:SetValue(selected)
		end
	end
})

local function refreshProfiles()
	local activeProfiles = Library:ListConfigs()
	configDropdown:Refresh(activeProfiles)
end

sg:AddButton("Save Profile", function()
	local name = Library.Opts.cfg_name:GetValue()
	if name ~= "" then
		Library:CreateConfig(name)
		Library:SaveConfig()
		refreshProfiles()
		print("[Profile Manager]: successfully serialized profile: " .. name)
	end
end)

sg:AddButton("Load Profile", function()
	local name = Library.Opts.cfg_name:GetValue()
	if name ~= "" then
		Library:LoadConfig(name)
		print("[Profile Manager]: successfully initialized profile: " .. name)
	end
end)

sg:AddButton("Purge Profile", function()
	local name = Library.Opts.cfg_name:GetValue()
	if name ~= "" then
		Library:DeleteConfig(name)
		refreshProfiles()
		print("[Profile Manager]: successfully dropped profile: " .. name)
	end
end)

sg:AddButton("Index Profiles Directory", function()
	refreshProfiles()
	print("[Profile Manager]: Files indexed successfully.")
end)

win:Build()