-- We load the custom UI framework externally from its source location.
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/hook-function/UndetectedDynamic/main/Library.lua"))()

-- Ensure saved profiles load immediately on startup if a profile exists.
Library:AutoLoadConfig(true)

-- Configures the core window boundary box, text title header, and execution properties.
local win = Library:CreateWindow({
    Title = "Undetected Dynamic",
    Size = Vector2.new(620, 440),
    ToggleKey = Enum.KeyCode.RightControl
})

-- Creates separate primary navigation layouts hosted in the layout sidebar.
local tab = win:AddTab("Main Operations")
local set = win:AddTab("Configuration")

-- Create a grouping module to neatly wrap functional game modifications
local ctrl = tab:AddCategory("Combat Features")

-- Functional Toggle component for turning operations on or off
ctrl:AddToggle("Master Switch", {
    Id = "enable",
    Default = true,
    Callback = function(value) 
        print("state: ", value) 
    end,
})

-- Linear adjustment slider to tweak numeric ranges
ctrl:AddSlider("Field of View", {
    Id = "volume",
    Min = 0, 
    Max = 120, 
    Default = 70, 
    Suffix = "°",
    Callback = function(value) 
        print("fov: ", value) 
    end,
})

-- Selection drop-down box component targeting indexed layout tables
ctrl:AddDropdown("Target Priority", {
    Id = "diff",
    Items = {"Distance", "Health", "Crosshair"},
    Default = "Crosshair",
    Callback = function(value) 
        print("target: ", value) 
    end,
})

-- Separator block and descriptive textual marker labels
ctrl:AddDivider()
ctrl:AddLabel("Visual Aesthetics")

-- Interactive context color picking palette window module
ctrl:AddColorPicker("Interface Accent", {
    Id = "color",
    Default = Color3.fromRGB(99, 102, 241),
    Callback = function(chosenColor) 
        Library:SetTheme({
            acc = chosenColor
        })
    end,
})

-- Create a specialized management container category block
local sg = set:AddCategory("Profile Engine")

-- File name assignment text entry box component
sg:AddInput("Active Config File", {
    Id = "cfg_name",
    Default = "default_profile",
})

-- Profile list presentation element
local configDropdown = sg:AddDropdown("Stored Profiles", {
    Id = "saved_configs",
    Items = Library:ListConfigs(),
    Default = "",
    Callback = function(selectedProfileName)
        if selectedProfileName and selectedProfileName ~= "" then
            -- Mirror selected text instantly onto our active configuration target text box
            Library.Opts.cfg_name:SetValue(selectedProfileName)
        end
    end
})

-- Helper routine designed to sync local changes with the list box
local function refreshProfiles()
    local activeProfiles = Library:ListConfigs()
    configDropdown:Refresh(activeProfiles)
end

-- Serialization action execute button component
sg:AddButton("Save Profile", function()
    local currentProfileName = Library.Opts.cfg_name:GetValue()
    
    if currentProfileName ~= "" then
        Library:CreateConfig(currentProfileName)
        Library:SaveConfig()
        
        -- Automatically synchronize list component contents
        refreshProfiles()
    end
end)

-- De-serialization loading trigger component button
sg:AddButton("Load Profile", function()
    local targetProfileName = Library.Opts.cfg_name:GetValue()
    
    if targetProfileName ~= "" then
        Library:LoadConfig(targetProfileName)
    end
end)

-- File drop/deletion executor trigger component button
sg:AddButton("Purge Profile", function()
    local targetedProfileName = Library.Opts.cfg_name:GetValue()
    
    if targetedProfileName ~= "" then
        Library:DeleteConfig(targetedProfileName)
        
        -- Refresh UI profile list layout automatically
        refreshProfiles()
    end
end)

-- Directory validation indexing scanner button component
sg:AddButton("Refresh Config", function()
    refreshProfiles()
end)

-- Constructs all functional instances, sets initial tab visibility, and displays the app window.
win:Build()