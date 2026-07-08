-- ====================================================================
-- UNDETECTED DYNAMIC UI LIBRARY
-- Fully Unminified, Well-Spaced, and Beginner-Friendly
-- ====================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

-- ── LUCIDE ICON FETCHING SYSTEM ──
local GetIcon
local success, Lucide = pcall(function()
	return loadstring(
		game:HttpGet("https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua")
	)()
end)

if success then
	local iconCache = {}
	function GetIcon(iconName)
		if iconCache[iconName] then 
			return iconCache[iconName] 
		end
		
		local assetSuccess, asset = pcall(Lucide.GetAsset, iconName)
		if assetSuccess and asset then
			iconCache[iconName] = asset
			return asset
		end
		return nil
	end
else
	function GetIcon() 
		return nil 
	end
end

-- ── GLOBAL TWEEN CONFIGURATION ──
local TweenConfiguration = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function tweenBackgroundColor(object, targetColor, targetTransparency)
	local tweenProperties = {
		BackgroundColor3 = targetColor, 
		BackgroundTransparency = targetTransparency
	}
	TweenService:Create(object, TweenConfiguration, tweenProperties):Play()
end

-- ── PALETTE CONFIGURATION (THEME COLORS) ──
local Theme = {
	bg = Color3.fromRGB(30, 30, 35),
	dark = Color3.fromRGB(22, 22, 26),
	darker = Color3.fromRGB(18, 18, 22),
	acc = Color3.fromRGB(88, 101, 242),
	hover = Color3.fromRGB(50, 50, 58),
	txt = Color3.fromRGB(220, 220, 225),
	dim = Color3.fromRGB(140, 140, 150),
	brd = Color3.fromRGB(40, 40, 48),
	err = Color3.fromRGB(220, 60, 60),
	inp = Color3.fromRGB(25, 25, 30),
	sl = Color3.fromRGB(40, 40, 48),
}

-- ── MAIN LIBRARY CORE OBJECT ──
local Lib = {
	Toggled = false, 
	Windows = {}, 
	Conns = {}, 
	Opts = {},
	_cfg = {
		folder = "UndetectedConfigs", 
		name = "", 
		data = {}, 
		auto = false
	},
}

function Lib:SetTheme(overrides)
	for key, value in pairs(overrides or {}) do
		if Theme[key] ~= nil then 
			Theme[key] = value 
		end
	end
end

-- ====================================================================
-- CONFIGURATION SYSTEM (NORMAL / VISUAL PATH SELECTION)
-- ====================================================================

local function getConfigurationPath(configName)
	local directory = Lib._cfg.folder .. "/settings"
	if not isfolder(directory) then
		makefolder(directory)
	end
	return directory .. "/" .. configName .. ".json"
end

function Lib:CreateConfig(configName)
	self._cfg.name = configName or "config"
	self._cfg.data = {}
end

function Lib:SaveConfig(configName)
	configName = configName or self._cfg.name
	if not configName or configName == "" then 
		return false 
	end
	
	local outputData = {}
	for index, optionObject in pairs(self.Opts) do   -- FIXED
		outputData[index] = optionObject:GetValue()
	end
	
	local encodeSuccess, jsonString = pcall(HttpService.JSONEncode, HttpService, outputData)
	if not encodeSuccess then 
		return false 
	end
	
	writefile(getConfigurationPath(configName), jsonString)
	if configName ~= self._cfg.name then
		self._cfg.name = configName
	end
	return true
end

function Lib:LoadConfig(configName)
	configName = configName or self._cfg.name
	if not configName or configName == "" then 
		return false 
	end
	if not isfile(getConfigurationPath(configName)) then 
		return false 
	end
	
	local decodeSuccess, decodedData = pcall(HttpService.JSONDecode, HttpService, readfile(getConfigurationPath(configName)))
	if not decodeSuccess or type(decodedData) ~= "table" then 
		return false 
	end
	
	self._cfg.data = decodedData
	for index, optionObject in pairs(self.Opts) do
		if decodedData[index] ~= nil then
			optionObject:SetValue(decodedData[index])
		end
	end
	
	if configName ~= self._cfg.name then
		self._cfg.name = configName
	end
	return true
end

function Lib:AutoLoadConfig(bool)
	self._cfg.auto = bool
end

function Lib:DeleteConfig(configName)
	configName = configName or self._cfg.name
	if not configName or configName == "" then 
		return false 
	end
	
	local path = getConfigurationPath(configName)
	if isfile(path) then
		delfile(path)
		return true
	end
	return false
end

function Lib:ListConfigs()
	local directory = Lib._cfg.folder .. "/settings"
	if not isfolder(directory) then 
		return {} 
	end
	
	local files = listfiles(directory)
	local configurationsList = {}
	for _, filePath in ipairs(files) do
		local configName = filePath:match("([^/\\]+)%.json$")
		if configName then 
			table.insert(configurationsList, configName) 
		end
	end
	return configurationsList
end

function Lib:ExportConfig(configName)
	self:SaveConfig(configName)
	local path = getConfigurationPath(configName or self._cfg.name)
	if isfile(path) then
		return readfile(path)
	end
	return nil
end

function Lib:ImportConfig(jsonString)
	local decodeSuccess, decodedData = pcall(HttpService.JSONDecode, HttpService, jsonString)
	if not decodeSuccess or type(decodedData) ~= "table" then 
		return false 
	end
	
	self._cfg.data = decodedData
	for index, optionObject in pairs(self.Opts) do
		if decodedData[index] ~= nil then
			optionObject:SetValue(decodedData[index])
		end
	end
	return true
end

-- INTERNAL OPTION REGISTRATION
local function registerOptionObject(uniqueId, object)
	if uniqueId and uniqueId ~= "" then
		Lib.Opts[uniqueId] = object
	end
end

-- ICON ASSET LOADER FUNCTION
local function setIconImage(imageInstance, iconName)
	local iconAsset = GetIcon(iconName)
	if iconAsset then
		imageInstance.Image = iconAsset.Url
		imageInstance.ImageRectSize = iconAsset.ImageRectSize
		imageInstance.ImageRectOffset = iconAsset.ImageRectOffset
	end
end

-- ====================================================================
-- COMPONENT GENERATORS (UI ELEMENTS)
-- ====================================================================

local function mkLabel(parent, text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Theme.dim
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local function mkDivider(parent)
	local divider = Instance.new("Frame")
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.BackgroundColor3 = Theme.brd
	divider.BorderSizePixel = 0
	divider.Parent = parent
	return divider
end

local function mkButton(parent, text, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 32)
	button.BackgroundColor3 = Theme.inp
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Theme.txt
	button.Font = Enum.Font.GothamSemibold
	button.TextSize = 13
	button.AutoButtonColor = false
	button.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = button
	
	button.MouseEnter:Connect(function() 
		tweenBackgroundColor(button, Theme.hover, 0) 
	end)
	button.MouseLeave:Connect(function() 
		tweenBackgroundColor(button, Theme.inp, 0) 
	end)
	button.MouseButton1Click:Connect(function() 
		if callback then 
			callback() 
		end 
	end)
	
	return button
end

local function mkToggle(parent, text, options)
	options = options or {}
	local defaultState = options.Default or false
	local callback = options.Callback or function() end
	
	local rowFrame = Instance.new("Frame")
	rowFrame.Size = UDim2.new(1, 0, 0, 28)
	rowFrame.BackgroundTransparency = 1
	rowFrame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -34, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Theme.txt
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = rowFrame

	local background = Instance.new("Frame")
	background.Size = UDim2.new(0, 28, 0, 16)
	background.Position = UDim2.new(1, -28, 0.5, -8)
	background.BackgroundColor3 = Theme.sl
	background.BorderSizePixel = 0
	background.Parent = rowFrame
	
	local backgroundCorner = Instance.new("UICorner")
	backgroundCorner.CornerRadius = UDim.new(0, 8)
	backgroundCorner.Parent = background

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.Position = UDim2.new(0, 2, 0.5, -6)
	knob.BackgroundColor3 = Theme.dim
	knob.BorderSizePixel = 0
	knob.Parent = background
	
	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(0, 6)
	knobCorner.Parent = knob

	local currentState = defaultState
	local function updateToggleState(value)
		currentState = value
		
		local targetBgColor
		local targetKnobColor
		local targetKnobPosition
		
		if currentState then
			targetBgColor = Theme.acc
			targetKnobColor = Theme.txt
			targetKnobPosition = UDim2.new(1, -14, 0.5, -6)
		else
			targetBgColor = Theme.sl
			targetKnobColor = Theme.dim
			targetKnobPosition = UDim2.new(0, 2, 0.5, -6)
		end
		
		TweenService:Create(background, TweenConfiguration, {BackgroundColor3 = targetBgColor}):Play()
		TweenService:Create(knob, TweenConfiguration, {BackgroundColor3 = targetKnobColor, Position = targetKnobPosition}):Play()
		
		pcall(callback, currentState)
	end

	local clickButton = Instance.new("TextButton")
	clickButton.Size = UDim2.new(1, 0, 1, 0)
	clickButton.BackgroundTransparency = 1
	clickButton.Text = ""
	clickButton.AutoButtonColor = false
	clickButton.Parent = rowFrame
	
	clickButton.MouseButton1Click:Connect(function() 
		updateToggleState(not currentState) 
	end)

	updateToggleState(defaultState)

	local toggleObject = {
		SetValue = updateToggleState, 
		GetValue = function() 
			return currentState 
		end
	}
	
	local registrationId = options.Id or options.id or text
	registerOptionObject(registrationId, toggleObject)
	return toggleObject
end

local function mkInput(parent, text, options)
	options = options or {}
	local defaultValue = options.Default or ""
	local placeholder = options.Placeholder or ""
	local callback = options.Callback or function() end
	local isNumeric = options.Numeric or false

	local rowFrame = Instance.new("Frame")
	rowFrame.Size = UDim2.new(1, 0, 0, 28)
	rowFrame.BackgroundTransparency = 1
	rowFrame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 80, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Theme.txt
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = rowFrame

	local textbox = Instance.new("TextBox")
	textbox.Size = UDim2.new(1, -88, 0, 24)
	textbox.Position = UDim2.new(1, -8, 0.5, -12)
	textbox.AnchorPoint = Vector2.new(1, 0.5)
	textbox.BackgroundColor3 = Theme.inp
	textbox.BorderSizePixel = 0
	textbox.Text = defaultValue
	textbox.TextColor3 = Theme.txt
	textbox.Font = Enum.Font.Gotham
	textbox.TextSize = 13
	textbox.PlaceholderText = placeholder
	textbox.PlaceholderColor3 = Theme.dim
	textbox.ClearTextOnFocus = false
	textbox.Parent = rowFrame
	
	local textCorner = Instance.new("UICorner")
	textCorner.CornerRadius = UDim.new(0, 4)
	textCorner.Parent = textbox

	if isNumeric then 
		textbox.Text = tostring(defaultValue) 
	end

	textbox.FocusLost:Connect(function()
		if isNumeric then
			local numericValue = tonumber(textbox.Text)
			if numericValue then 
				textbox.Text = tostring(numericValue) 
			else 
				textbox.Text = tostring(defaultValue) 
			end
		end
		pcall(callback, textbox.Text)
	end)

	local inputObject = {
		TextBox = textbox, 
		SetValue = function(newValue) 
			textbox.Text = tostring(newValue) 
		end, 
		GetValue = function() 
			return textbox.Text 
		end
	}
	
	local registrationId = options.Id or options.id or text
	registerOptionObject(registrationId, inputObject)
	return inputObject
end

local function mkSlider(parent, text, options)
	options = options or {}
	local minimum = options.Min or 0
	local maximum = options.Max or 100
	local defaultValue = options.Default or minimum
	local suffix = options.Suffix or ""
	local callback = options.Callback or function() end
	local isPrecise = options.Precise or false

	local rowFrame = Instance.new("Frame")
	rowFrame.Size = UDim2.new(1, 0, 0, 36)
	rowFrame.BackgroundTransparency = 1
	rowFrame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -80, 0, 18)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Theme.txt
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = rowFrame

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 72, 0, 18)
	valueLabel.Position = UDim2.new(1, -72, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(defaultValue) .. suffix
	valueLabel.TextColor3 = Theme.txt
	valueLabel.Font = Enum.Font.Gotham
	valueLabel.TextSize = 12
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = rowFrame

	local rail = Instance.new("Frame")
	rail.Size = UDim2.new(1, 0, 0, 6)
	rail.Position = UDim2.new(0, 0, 1, -6)
	rail.BackgroundColor3 = Theme.sl
	rail.BorderSizePixel = 0
	rail.Parent = rowFrame
	
	local railCorner = Instance.new("UICorner")
	railCorner.CornerRadius = UDim.new(0, 3)
	railCorner.Parent = rail

	local fillFrame = Instance.new("Frame")
	fillFrame.Size = UDim2.new(0, 0, 1, 0)
	fillFrame.BackgroundColor3 = Theme.acc
	fillFrame.BorderSizePixel = 0
	fillFrame.Parent = rail
	
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 3)
	fillCorner.Parent = fillFrame

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.BackgroundColor3 = Theme.txt
	knob.BorderSizePixel = 0
	knob.ZIndex = 2
	knob.Parent = rowFrame
	
	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(0, 6)
	knobCorner.Parent = knob

	local currentSliderValue = defaultValue
	local dragging = false

	local function updateSlider(newValue)
		currentSliderValue = math.clamp(newValue, minimum, maximum)
		local percentage = (currentSliderValue - minimum) / (maximum - minimum)
		local railWidth = rail.AbsoluteSize.X
		
		fillFrame.Size = UDim2.new(0, railWidth * percentage, 1, 0)
		knob.Position = UDim2.new(0, rail.AbsolutePosition.X - rowFrame.AbsolutePosition.X + railWidth * percentage - 6, 0.5, -6)
		
		local displayString
		if isPrecise then
			displayString = string.format("%.1f", currentSliderValue)
		else
			displayString = tostring(math.floor(currentSliderValue))
		end
		
		valueLabel.Text = displayString .. suffix
		pcall(callback, currentSliderValue)
	end

	local interactionButton = Instance.new("TextButton")
	interactionButton.Size = UDim2.new(1, 0, 1, 0)
	interactionButton.BackgroundTransparency = 1
	interactionButton.Text = ""
	interactionButton.AutoButtonColor = false
	interactionButton.ZIndex = 1
	interactionButton.Parent = rowFrame

	interactionButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			local mouseLocation = UserInputService:GetMouseLocation()
			local railPosition = rail.AbsolutePosition
			local railWidth = rail.AbsoluteSize.X
			local percentage = math.clamp((mouseLocation.X - railPosition.X) / railWidth, 0, 1)
			updateSlider(minimum + percentage * (maximum - minimum))
		end
	end)
	
	interactionButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then 
			dragging = false 
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local mouseLocation = UserInputService:GetMouseLocation()
			local railPosition = rail.AbsolutePosition
			local railWidth = rail.AbsoluteSize.X
			local percentage = math.clamp((mouseLocation.X - railPosition.X) / railWidth, 0, 1)
			updateSlider(minimum + percentage * (maximum - minimum))
		end
	end)

	updateSlider(defaultValue)
	
	local sliderObject = {
		SetValue = function(newValue) 
			updateSlider(newValue) 
		end, 
		GetValue = function() 
			return currentSliderValue 
		end
	}
	
	local registrationId = options.Id or options.id or text
	registerOptionObject(registrationId, sliderObject)
	return sliderObject
end

local function mkDropdown(parent, text, options)
	options = options or {}
	local dropdownItems = options.Items or {}
	local defaultSelected = options.Default or ""
	local callback = options.Callback or function() end

	local rowFrame = Instance.new("Frame")
	rowFrame.Size = UDim2.new(1, 0, 0, 28)
	rowFrame.BackgroundTransparency = 1
	rowFrame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 80, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Theme.txt
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = rowFrame

	local displayButton = Instance.new("TextButton")
	displayButton.Size = UDim2.new(1, -88, 0, 24)
	displayButton.Position = UDim2.new(1, -8, 0.5, -12)
	displayButton.AnchorPoint = Vector2.new(1, 0.5)
	displayButton.BackgroundColor3 = Theme.inp
	displayButton.BorderSizePixel = 0
	displayButton.Text = (defaultSelected == "" and "Select..." or defaultSelected)
	displayButton.TextColor3 = Theme.txt
	displayButton.Font = Enum.Font.Gotham
	displayButton.TextSize = 13
	displayButton.AutoButtonColor = false
	displayButton.Parent = rowFrame
	
	local displayCorner = Instance.new("UICorner")
	displayCorner.CornerRadius = UDim.new(0, 4)
	displayCorner.Parent = displayButton

	local arrowIndicator = Instance.new("TextLabel")
	arrowIndicator.Size = UDim2.new(0, 18, 1, 0)
	arrowIndicator.Position = UDim2.new(1, -18, 0, 0)
	arrowIndicator.BackgroundTransparency = 1
	arrowIndicator.Text = "▼"
	arrowIndicator.TextColor3 = Theme.dim
	arrowIndicator.Font = Enum.Font.Gotham
	arrowIndicator.TextSize = 10
	arrowIndicator.Parent = displayButton

	local dropdownListFrame = Instance.new("ScrollingFrame")
	dropdownListFrame.Size = UDim2.new(1, -88, 0, 0)
	dropdownListFrame.Position = UDim2.new(1, -8, 1, 2)
	dropdownListFrame.AnchorPoint = Vector2.new(1, 0)
	dropdownListFrame.BackgroundColor3 = Theme.darker
	dropdownListFrame.BorderSizePixel = 0
	dropdownListFrame.Visible = false
	dropdownListFrame.ScrollBarThickness = 2
	dropdownListFrame.ScrollBarImageColor3 = Theme.brd
	dropdownListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	dropdownListFrame.ZIndex = 20
	dropdownListFrame.Parent = rowFrame
	
	local listPadding = Instance.new("UIPadding")
	listPadding.PaddingTop = UDim.new(0, 2)
	listPadding.PaddingBottom = UDim.new(0, 2)
	listPadding.Parent = dropdownListFrame
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 2)
	listLayout.Parent = dropdownListFrame

	local currentSelectedValue = defaultSelected

	local function buildDropdownItems()
		for _, childInstance in ipairs(dropdownListFrame:GetChildren()) do
			if childInstance:IsA("TextButton") or childInstance:IsA("UIListLayout") or childInstance:IsA("UIPadding") then 
				childInstance:Destroy() 
			end
		end
		
		local freshListLayout = Instance.new("UIListLayout")
		freshListLayout.Padding = UDim.new(0, 2)
		freshListLayout.Parent = dropdownListFrame
		
		local freshPadding = Instance.new("UIPadding")
		freshPadding.PaddingTop = UDim.new(0, 2)
		freshPadding.PaddingBottom = UDim.new(0, 2)
		freshPadding.Parent = dropdownListFrame
		
		for _, itemName in ipairs(dropdownItems) do
			local itemButton = Instance.new("TextButton")
			itemButton.Size = UDim2.new(1, -4, 0, 24)
			itemButton.Position = UDim2.new(0, 2, 0, 0)
			itemButton.BackgroundTransparency = 1
			itemButton.BorderSizePixel = 0
			itemButton.Text = itemName
			itemButton.TextColor3 = Theme.txt
			itemButton.Font = Enum.Font.Gotham
			itemButton.TextSize = 13
			itemButton.AutoButtonColor = false
			itemButton.ZIndex = 21
			itemButton.Parent = dropdownListFrame
			
			itemButton.MouseEnter:Connect(function() 
				tweenBackgroundColor(itemButton, Theme.hover, 0) 
			end)
			itemButton.MouseLeave:Connect(function() 
				tweenBackgroundColor(itemButton, Theme.darker, 1) 
			end)
			itemButton.MouseButton1Click:Connect(function()
				currentSelectedValue = itemName
				displayButton.Text = itemName
				dropdownListFrame.Visible = false
				pcall(callback, itemName)
			end)
		end
		dropdownListFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
	end

	buildDropdownItems()

	displayButton.MouseButton1Click:Connect(function()
		dropdownListFrame.Visible = not dropdownListFrame.Visible
		if dropdownListFrame.Visible then
			dropdownListFrame.Size = UDim2.new(1, -88, 0, math.min(listLayout.AbsoluteContentSize.Y + 4, 150))
		end
	end)

	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local mousePosition = input.Position
			local rowPos = rowFrame.AbsolutePosition
			local rowSize = rowFrame.AbsoluteSize
			local dropPos = dropdownListFrame.AbsolutePosition
			local dropSize = dropdownListFrame.AbsoluteSize
			
			local clickedInsideRow = (mousePosition.X >= rowPos.X and mousePosition.X <= rowPos.X + rowSize.X and mousePosition.Y >= rowPos.Y and mousePosition.Y <= rowPos.Y + rowSize.Y)
			local clickedInsideDropdown = (mousePosition.X >= dropPos.X and mousePosition.X <= dropPos.X + dropSize.X and mousePosition.Y >= dropPos.Y and mousePosition.Y <= dropPos.Y + dropSize.Y)
			
			if dropdownListFrame.Visible and not (clickedInsideRow or clickedInsideDropdown) then 
				dropdownListFrame.Visible = false 
			end
		end
	end)

	local dropdownObject = {
		SetValue = function(newValue) 
			currentSelectedValue = newValue
			displayButton.Text = newValue
			pcall(callback, newValue) 
		end,
		GetValue = function() 
			return currentSelectedValue 
		end,
		Refresh = function(newItemsList)
			dropdownItems = newItemsList
			buildDropdownItems()
			dropdownListFrame.Visible = false
		end,
	}
	
	local registrationId = options.Id or options.id or text
	registerOptionObject(registrationId, dropdownObject)
	return dropdownObject
end

local function mkColorPicker(parent, text, options)
	options = options or {}
	local defaultColor = options.Default or Color3.fromRGB(255, 255, 255)
	local callback = options.Callback or function() end

	local rowFrame = Instance.new("Frame")
	rowFrame.Size = UDim2.new(1, 0, 0, 28)
	rowFrame.BackgroundTransparency = 1
	rowFrame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -34, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Theme.txt
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = rowFrame

	local swatchButton = Instance.new("ImageButton")
	swatchButton.Size = UDim2.new(0, 22, 0, 22)
	swatchButton.Position = UDim2.new(1, -28, 0.5, -11)
	swatchButton.BackgroundColor3 = defaultColor
	swatchButton.BorderSizePixel = 0
	swatchButton.AutoButtonColor = false
	swatchButton.Parent = rowFrame
	
	local swatchCorner = Instance.new("UICorner")
	swatchCorner.CornerRadius = UDim.new(0, 4)
	swatchCorner.Parent = swatchButton
	
	local swatchStroke = Instance.new("UIStroke")
	swatchStroke.Color = Theme.brd
	swatchStroke.Thickness = 1
	swatchStroke.Parent = swatchButton

	local selectedColor = defaultColor

	swatchButton.MouseButton1Click:Connect(function()
		local screenGui = rowFrame:FindFirstAncestorOfClass("ScreenGui") or Players.LocalPlayer:WaitForChild("PlayerGui")
		
		-- Destroy active instance if open already
		if screenGui:FindFirstChild("ColorPickerPanelInstance") then
			screenGui.ColorPickerPanelInstance:Destroy()
			return
		end
		
		local panelFrame = Instance.new("Frame")
		panelFrame.Name = "ColorPickerPanelInstance"
		panelFrame.Size = UDim2.new(0, 180, 0, 160)
		panelFrame.BackgroundColor3 = Theme.darker
		panelFrame.BorderSizePixel = 0
		panelFrame.ZIndex = 20
		panelFrame.Parent = screenGui
		
		local panelCorner = Instance.new("UICorner")
		panelCorner.CornerRadius = UDim.new(0, 4)
		panelCorner.Parent = panelFrame
		
		local panelStroke = Instance.new("UIStroke")
		panelStroke.Color = Theme.brd
		panelStroke.Parent = panelFrame

		-- Position picker window dynamically next to the clicked row
		panelFrame.Position = UDim2.new(0, swatchButton.AbsolutePosition.X - 190, 0, swatchButton.AbsolutePosition.Y)

		local hue, saturation, value = Color3.toHSV(selectedColor)

		local saturationValueWindow = Instance.new("ImageLabel")
		saturationValueWindow.Size = UDim2.new(0, 150, 0, 120)
		saturationValueWindow.Position = UDim2.new(0, 8, 0, 8)
		saturationValueWindow.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
		saturationValueWindow.Image = "rbxassetid://4155801252"
		saturationValueWindow.ZIndex = 21
		saturationValueWindow.Parent = panelFrame

		local cursor = Instance.new("Frame")
		cursor.Size = UDim2.new(0, 8, 0, 8)
		cursor.BackgroundColor3 = Color3.new(1, 1, 1)
		cursor.BorderSizePixel = 1
		cursor.BorderColor3 = Color3.new(0, 0, 0)
		cursor.ZIndex = 22
		cursor.Parent = saturationValueWindow
		
		local cursorCorner = Instance.new("UICorner")
		cursorCorner.CornerRadius = UDim.new(1, 0)
		cursorCorner.Parent = cursor

		local hueBar = Instance.new("Frame")
		hueBar.Size = UDim2.new(0, 150, 0, 12)
		hueBar.Position = UDim2.new(0, 8, 0, 134)
		hueBar.BackgroundTransparency = 1
		hueBar.ZIndex = 21
		hueBar.Parent = panelFrame
		
		local hueGradient = Instance.new("UIGradient")
		hueGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		})
		hueGradient.Parent = hueBar

		local hueCursor = Instance.new("Frame")
		hueCursor.Size = UDim2.new(0, 4, 1, 2)
		hueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
		hueCursor.BorderSizePixel = 1
		hueCursor.BorderColor3 = Color3.new(0, 0, 0)
		hueCursor.ZIndex = 22
		hueCursor.Parent = hueBar

		local function updatePanelColors()
			local computedColor = Color3.fromHSV(hue, saturation, value)
			selectedColor = computedColor
			swatchButton.BackgroundColor3 = computedColor
			saturationValueWindow.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
			
			cursor.Position = UDim2.new(saturation, -cursor.AbsoluteSize.X / 2, 1 - value, -cursor.AbsoluteSize.Y / 2)
			hueCursor.Position = UDim2.new(hue, -hueCursor.AbsoluteSize.X / 2, 0, 0)
			
			pcall(callback, computedColor)
		end

		local isDraggingSaturationValue = false
		local isDraggingHue = false

		saturationValueWindow.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				isDraggingSaturationValue = true
				local mouseLocation = UserInputService:GetMouseLocation()
				local winPos = saturationValueWindow.AbsolutePosition
				local winSize = saturationValueWindow.AbsoluteSize
				
				saturation = math.clamp((mouseLocation.X - winPos.X) / winSize.X, 0, 1)
				value = 1 - math.clamp((mouseLocation.Y - winPos.Y) / winSize.Y, 0, 1)
				updatePanelColors()
			end
		end)
		
		saturationValueWindow.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then 
				isDraggingSaturationValue = false 
			end
		end)

		hueBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				isDraggingHue = true
				local mouseLocation = UserInputService:GetMouseLocation()
				local barPos = hueBar.AbsolutePosition
				local barSize = hueBar.AbsoluteSize
				
				hue = math.clamp((mouseLocation.X - barPos.X) / barSize.X, 0, 1)
				updatePanelColors()
			end
		end)
		
		hueBar.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then 
				isDraggingHue = false 
			end
		end)

		local windowInputConnection
		windowInputConnection = UserInputService.InputChanged:Connect(function(input)
			if not panelFrame or not panelFrame.Parent then
				windowInputConnection:Disconnect()
				return
			end
			
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				if isDraggingSaturationValue then
					local mouseLocation = UserInputService:GetMouseLocation()
					local winPos = saturationValueWindow.AbsolutePosition
					local winSize = saturationValueWindow.AbsoluteSize
					
					saturation = math.clamp((mouseLocation.X - winPos.X) / winSize.X, 0, 1)
					value = 1 - math.clamp((mouseLocation.Y - winPos.Y) / winSize.Y, 0, 1)
					updatePanelColors()
				end
				
				if isDraggingHue then
					local mouseLocation = UserInputService:GetMouseLocation()
					local barPos = hueBar.AbsolutePosition
					local barSize = hueBar.AbsoluteSize
					
					hue = math.clamp((mouseLocation.X - barPos.X) / barSize.X, 0, 1)
					updatePanelColors()
				end
			end
		end)

		-- Auto-close picker frame if user clicks anywhere else outside the widget
		local closeDetectionConnection
		closeDetectionConnection = UserInputService.InputBegan:Connect(function(input)
			if not panelFrame or not panelFrame.Parent then
				closeDetectionConnection:Disconnect()
				return
			end
			
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local mousePos = input.Position
				local pPos = panelFrame.AbsolutePosition
				local pSize = panelFrame.AbsoluteSize
				local sPos = swatchButton.AbsolutePosition
				local sSize = swatchButton.AbsoluteSize
				
				local clickedPanel = (mousePos.X >= pPos.X and mousePos.X <= pPos.X + pSize.X and mousePos.Y >= pPos.Y and mousePos.Y <= pPos.Y + pSize.Y)
				local clickedSwatch = (mousePos.X >= sPos.X and mousePos.X <= sPos.X + sSize.X and mousePos.Y >= sPos.Y and mousePos.Y <= sPos.Y + sSize.Y)
				
				if not (clickedPanel or clickedSwatch) then
					panelFrame:Destroy()
					closeDetectionConnection:Disconnect()
				end
			end
		end)

		updatePanelColors()
	end)

	local colorPickerObject = {
		SetValue = function(newColor3) 
			selectedColor = newColor3
			swatchButton.BackgroundColor3 = newColor3
			pcall(callback, newColor3) 
		end, 
		GetValue = function() 
			return selectedColor 
		end
	}
	
	local registrationId = options.Id or options.id or text
	registerOptionObject(registrationId, colorPickerObject)
	return colorPickerObject
end

local function mkKeybind(parent, text, options)
	options = options or {}
	local defaultBind = options.Default or "None"
	local callback = options.Callback or function() end
	local onChange = options.OnChange or function() end

	local rowFrame = Instance.new("Frame")
	rowFrame.Size = UDim2.new(1, 0, 0, 28)
	rowFrame.BackgroundTransparency = 1
	rowFrame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -34, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Theme.txt
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = rowFrame

	local bindButton = Instance.new("TextButton")
	bindButton.Size = UDim2.new(0, 0, 0, 22)
	bindButton.Position = UDim2.new(1, -6, 0.5, -11)
	bindButton.AnchorPoint = Vector2.new(1, 0.5)
	bindButton.BackgroundColor3 = Theme.inp
	bindButton.BorderSizePixel = 0
	bindButton.Text = defaultBind
	bindButton.TextColor3 = Theme.txt
	bindButton.Font = Enum.Font.Gotham
	bindButton.TextSize = 13
	bindButton.AutoButtonColor = false
	bindButton.Parent = rowFrame
	
	local bindCorner = Instance.new("UICorner")
	bindCorner.CornerRadius = UDim.new(0, 4)
	bindCorner.Parent = bindButton

	local activeKeyName = defaultBind

	local function updateButtonSize()
		local textSizeVector = TextService:GetTextSize(bindButton.Text, bindButton.TextSize, bindButton.Font, Vector2.new(200, 30))
		bindButton.Size = UDim2.new(0, textSizeVector.X + 14, 0, 22)
	end

	local isPickingKey = false
	bindButton.MouseButton1Click:Connect(function()
		if isPickingKey then 
			return 
		end
		
		isPickingKey = true
		local legacyText = bindButton.Text
		bindButton.Text = "..."
		updateButtonSize()
		
		local inputEvent = UserInputService.InputBegan:Wait()
		local selectedKeyName
		
		if inputEvent.UserInputType == Enum.UserInputType.Keyboard then
			if inputEvent.KeyCode == Enum.KeyCode.Escape then
				selectedKeyName = "None"
			else
				selectedKeyName = inputEvent.KeyCode.Name
			end
		elseif inputEvent.UserInputType == Enum.UserInputType.MouseButton1 then
			selectedKeyName = "MB1"
		elseif inputEvent.UserInputType == Enum.UserInputType.MouseButton2 then
			selectedKeyName = "MB2"
		else
			selectedKeyName = legacyText
		end
		
		activeKeyName = selectedKeyName
		bindButton.Text = activeKeyName
		updateButtonSize()
		isPickingKey = false
		
		pcall(callback, activeKeyName)
		pcall(onChange, activeKeyName)
	end)

	updateButtonSize()

	local keybindObject = {
		SetValue = function(newBindValue) 
			activeKeyName = newBindValue
			bindButton.Text = newBindValue
			updateButtonSize() 
		end,
		GetValue = function() 
			return activeKeyName 
		end,
	}
	
	local registrationId = options.Id or options.id or text
	registerOptionObject(registrationId, keybindObject)
	return keybindObject
end

-- ====================================================================
-- CATEGORY CORE BUILDER & CLASS METHODS
-- ====================================================================

local function makeCategory(tabInstance, categoryName)
	local targetPage = tabInstance.Content
	
	local categoryBox = Instance.new("Frame")
	categoryBox.Size = UDim2.new(1, 0, 0, 34)
	categoryBox.BackgroundColor3 = Theme.darker
	categoryBox.BorderSizePixel = 0
	categoryBox.Parent = targetPage

	local categoryCorner = Instance.new("UICorner")
	categoryCorner.CornerRadius = UDim.new(0, 4)
	categoryCorner.Parent = categoryBox

	local headerButton = Instance.new("TextButton")
	headerButton.Size = UDim2.new(1, 0, 0, 34)
	headerButton.BackgroundTransparency = 1
	headerButton.Text = ""
	headerButton.AutoButtonColor = false
	headerButton.ZIndex = 2
	headerButton.Parent = categoryBox

	local arrowIndicator = Instance.new("TextLabel")
	arrowIndicator.Size = UDim2.new(0, 16, 0, 34)
	arrowIndicator.Position = UDim2.new(0, 8, 0, 0)
	arrowIndicator.BackgroundTransparency = 1
	arrowIndicator.Text = ">"
	arrowIndicator.TextColor3 = Theme.dim
	arrowIndicator.Font = Enum.Font.Gotham
	arrowIndicator.TextSize = 13
	arrowIndicator.Rotation = 90
	arrowIndicator.Parent = headerButton

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -34, 1, 0)
	titleLabel.Position = UDim2.new(0, 26, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = categoryName
	titleLabel.TextColor3 = Theme.txt
	titleLabel.Font = Enum.Font.GothamSemibold
	titleLabel.TextSize = 13
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = headerButton

	local containerFrame = Instance.new("Frame")
	containerFrame.Size = UDim2.new(1, 0, 0, 0)
	containerFrame.Position = UDim2.new(0, 0, 0, 34)
	containerFrame.BackgroundTransparency = 1
	containerFrame.Parent = categoryBox

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 4)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = containerFrame
	
	local internalPadding = Instance.new("UIPadding")
	internalPadding.PaddingLeft = UDim.new(0, 10)
	internalPadding.PaddingRight = UDim.new(0, 10)
	internalPadding.PaddingBottom = UDim.new(0, 6)
	internalPadding.Parent = containerFrame

	local categoryObject = {
		Category = categoryBox, 
		Container = containerFrame, 
		Header = headerButton,
		Tab = tabInstance, 
		Expanded = true, 
		Name = categoryName,
	}

	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if categoryObject.Expanded then
			local contentHeight = listLayout.AbsoluteContentSize.Y
			containerFrame.Size = UDim2.new(1, 0, 0, contentHeight)
			categoryBox.Size = UDim2.new(1, 0, 0, 34 + contentHeight + 6)
		end
	end)

	headerButton.MouseButton1Click:Connect(function()
		categoryObject.Expanded = not categoryObject.Expanded
		local contentHeight = listLayout.AbsoluteContentSize.Y
		
		local targetContainerHeight = 0
		if categoryObject.Expanded then
			targetContainerHeight = contentHeight
		end
		
		local easingStyleSelection = Enum.EasingStyle.Quad
		if categoryObject.Expanded then
			easingStyleSelection = Enum.EasingStyle.Elastic
		end
		
		TweenService:Create(containerFrame, TweenInfo.new(0.3, easingStyleSelection, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 0, targetContainerHeight)
		}):Play()
		
		local targetRotation = 0
		if categoryObject.Expanded then
			targetRotation = 90
		end
		
		TweenService:Create(arrowIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
			Rotation = targetRotation
		}):Play()
		
		if categoryObject.Expanded then
			categoryBox:TweenSize(UDim2.new(1, 0, 0, 34 + contentHeight + 6), Enum.EasingDirection.Out, Enum.EasingStyle.Elastic, 0.3, true)
		else
			categoryBox:TweenSize(UDim2.new(1, 0, 0, 34 + 0 + 6), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
		end
	end)

	categoryObject.AddLabel = function(self, labelText) return mkLabel(containerFrame, labelText) end
	categoryObject.AddDivider = function(self) return mkDivider(containerFrame) end
	categoryObject.AddButton = function(self, btnText, fn) return mkButton(containerFrame, btnText, fn) end
	categoryObject.AddToggle = function(self, togText, o) return mkToggle(containerFrame, togText, o) end
	categoryObject.AddInput = function(self, inpText, o) return mkInput(containerFrame, inpText, o) end
	categoryObject.AddSlider = function(self, sldText, o) return mkSlider(containerFrame, sldText, o) end
	categoryObject.AddDropdown = function(self, drpText, o) return mkDropdown(containerFrame, drpText, o) end
	categoryObject.AddColorPicker = function(self, clrText, o) return mkColorPicker(containerFrame, clrText, o) end
	categoryObject.AddKeybind = function(self, bndText, o) return mkKeybind(containerFrame, bndText, o) end

	table.insert(tabInstance.Categories, categoryObject)
	return categoryObject
end

-- ====================================================================
-- TAB METHODS METATABLE
-- ====================================================================
local TabMethods = {}

function TabMethods:AddCategory(categoryName)
	return makeCategory(self, categoryName)
end

function TabMethods:AddLabel(text)
	return mkLabel(self.Content, text)
end

function TabMethods:AddDivider()
	return mkDivider(self.Content)
end

function TabMethods:AddButton(text, callback)
	return mkButton(self.Content, text, callback)
end

function TabMethods:AddToggle(text, options)
	return mkToggle(self.Content, text, options)
end

function TabMethods:AddInput(text, options)
	return mkInput(self.Content, text, options)
end

function TabMethods:AddSlider(text, options)
	return mkSlider(self.Content, text, options)
end

function TabMethods:AddDropdown(text, options)
	return mkDropdown(self.Content, text, options)
end

function TabMethods:AddColorPicker(text, options)
	return mkColorPicker(self.Content, text, options)
end

function TabMethods:AddKeybind(text, options)
	return mkKeybind(self.Content, text, options)
end

-- ====================================================================
-- WINDOW METHODS METATABLE
-- ====================================================================
local WindowMethods = {}

function WindowMethods:AddTab(tabName)
	local freshTabStructure = setmetatable({
		Name = tabName, 
		Button = nil, 
		Content = nil, 
		Label = nil, 
		Icon = nil,
		Categories = {}, 
		Elements = {},
	}, { __index = TabMethods })
	
	table.insert(self.Tabs, freshTabStructure)
	return freshTabStructure
end

function WindowMethods:Destroy()
	if self.MainFrame then 
		self.MainFrame:Destroy() 
	end
	if self._mobileBtn then 
		self._mobileBtn:Destroy() 
	end
	self.ScreenGui = nil
end

function WindowMethods:SetToggleKey(keyCode)
	self.ToggleKey = keyCode
end

function WindowMethods:Build()
	self:_build()
end

-- ====================================================================
-- CORE WINDOW CREATION ENTRYPOINT
-- ====================================================================
function Lib:CreateWindow(options)
	options = options or {}
	local initialTitle = options.Title or "Undetected Dynamic"
	local panelSize = options.Size or Vector2.new(580, 400)
	local coreToggleKey = options.ToggleKey or Enum.KeyCode.RightControl

	local windowContext = setmetatable({
		Title = initialTitle, 
		Size = panelSize, 
		ToggleKey = coreToggleKey,
		SidebarExpanded = true, 
		Tabs = {},
		MainFrame = nil, 
		Sidebar = nil, 
		MainContent = nil, 
		ScreenGui = nil,
		ActiveTab = nil, 
		_mobileBtn = nil,
	}, { __index = WindowMethods })

	windowContext._build = function()
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "UI_Container_" .. math.random(1000, 9999)
		screenGui.ResetOnSpawn = false
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.DisplayOrder = 999
		screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		windowContext.ScreenGui = screenGui

		local mainFrame = Instance.new("Frame")
		mainFrame.Size = UDim2.new(0, panelSize.X, 0, panelSize.Y)
		mainFrame.Position = UDim2.new(0.5, -panelSize.X / 2, 0.5, -panelSize.Y / 2)
		mainFrame.BackgroundColor3 = Theme.bg
		mainFrame.BorderSizePixel = 0
		mainFrame.Active = true
		mainFrame.Parent = screenGui
		windowContext.MainFrame = mainFrame

		local titleBar = Instance.new("Frame")
		titleBar.Size = UDim2.new(1, 0, 0, 44)
		titleBar.BackgroundColor3 = Theme.dark
		titleBar.BorderSizePixel = 0
		titleBar.Parent = mainFrame

		local windowTitleLabel = Instance.new("TextLabel")
		windowTitleLabel.Size = UDim2.new(1, -34, 1, 0)
		windowTitleLabel.BackgroundTransparency = 1
		windowTitleLabel.Text = initialTitle
		windowTitleLabel.TextColor3 = Theme.txt
		windowTitleLabel.Font = Enum.Font.GothamSemibold
		windowTitleLabel.TextSize = 15
		windowTitleLabel.TextXAlignment = Enum.TextXAlignment.Center
		windowTitleLabel.Parent = titleBar

		local closeButton = Instance.new("TextButton")
		closeButton.Size = UDim2.new(0, 34, 1, 0)
		closeButton.Position = UDim2.new(1, -34, 0, 0)
		closeButton.BackgroundTransparency = 1
		closeButton.Text = "X"
		closeButton.TextColor3 = Theme.dim
		closeButton.Font = Enum.Font.Gotham
		closeButton.TextSize = 15
		closeButton.AutoButtonColor = false
		closeButton.ZIndex = 3
		closeButton.Parent = titleBar

		local userIconAsset = GetIcon("user")
		local sidebarToggleButton = Instance.new("ImageButton")
		sidebarToggleButton.Size = UDim2.new(0, 32, 0, 32)
		sidebarToggleButton.Position = UDim2.new(0, 8, 0.5, -16)
		sidebarToggleButton.BackgroundColor3 = Theme.darker
		sidebarToggleButton.BorderSizePixel = 0
		sidebarToggleButton.Image = (userIconAsset and userIconAsset.Url or "")
		
		if userIconAsset then
			sidebarToggleButton.ImageRectSize = userIconAsset.ImageRectSize
			sidebarToggleButton.ImageRectOffset = userIconAsset.ImageRectOffset
		end
		
		sidebarToggleButton.ImageColor3 = Theme.txt
		sidebarToggleButton.ScaleType = Enum.ScaleType.Fit
		sidebarToggleButton.AutoButtonColor = false
		sidebarToggleButton.ZIndex = 10
		sidebarToggleButton.Parent = titleBar
		
		local toggleCorner = Instance.new("UICorner")
		toggleCorner.CornerRadius = UDim.new(0, 4)
		toggleCorner.Parent = sidebarToggleButton
		
		local toggleStroke = Instance.new("UIStroke")
		toggleStroke.Color = Theme.brd
		toggleStroke.Thickness = 1.5
		toggleStroke.Parent = sidebarToggleButton

		local clientArea = Instance.new("Frame")
		clientArea.Size = UDim2.new(1, 0, 1, -44)
		clientArea.Position = UDim2.new(0, 0, 0, 44)
		clientArea.BackgroundTransparency = 1
		clientArea.Parent = mainFrame

		local sidebarFrame = Instance.new("Frame")
		sidebarFrame.Size = UDim2.new(0, 180, 1, 0)
		sidebarFrame.BackgroundColor3 = Theme.darker
		sidebarFrame.BorderSizePixel = 0
		sidebarFrame.Parent = clientArea
		windowContext.Sidebar = sidebarFrame

		local sidebarInnerFrame = Instance.new("Frame")
		sidebarInnerFrame.Size = UDim2.new(1, -8, 1, -8)
		sidebarInnerFrame.Position = UDim2.new(0, 4, 0, 4)
		sidebarInnerFrame.BackgroundTransparency = 1
		sidebarInnerFrame.Parent = sidebarFrame

		local sidebarDivider = Instance.new("Frame")
		sidebarDivider.Size = UDim2.new(0, 1, 1, 0)
		sidebarDivider.Position = UDim2.new(0, 180, 0, 0)
		sidebarDivider.BackgroundColor3 = Theme.brd
		sidebarDivider.BorderSizePixel = 0
		sidebarDivider.ZIndex = 5
		sidebarDivider.Parent = clientArea

		local mainContentContainer = Instance.new("Frame")
		mainContentContainer.Size = UDim2.new(1, -181, 1, 0)
		mainContentContainer.Position = UDim2.new(0, 181, 0, 0)
		mainContentContainer.BackgroundColor3 = Theme.bg
		mainContentContainer.BorderSizePixel = 0
		mainContentContainer.Parent = clientArea
		windowContext.MainContent = mainContentContainer

		-- Dynamically process tab headers and container panels
		for currentIdx, tabStructure in ipairs(windowContext.Tabs) do
			local backupIconName = "cog"
			if currentIdx == 1 then
				backupIconName = "user"
			end
			local finalIconAsset = GetIcon(backupIconName)

			local tabButton = Instance.new("TextButton")
			tabButton.Size = UDim2.new(1, 0, 0, 44)
			tabButton.Position = UDim2.new(0, 0, 0, (currentIdx - 1) * 50)
			tabButton.BackgroundColor3 = Theme.darker
			tabButton.BorderSizePixel = 0
			tabButton.Text = ""
			tabButton.AutoButtonColor = false
			tabButton.ClipsDescendants = true
			tabButton.Parent = sidebarInnerFrame

			local buttonCorner = Instance.new("UICorner")
			buttonCorner.CornerRadius = UDim.new(0, 4)
			buttonCorner.Parent = tabButton

			local tabIconImage = Instance.new("ImageLabel")
			tabIconImage.Size = UDim2.new(0, 24, 0, 24)
			tabIconImage.Position = UDim2.new(0, 6, 0.5, -12)
			tabIconImage.BackgroundColor3 = Theme.darker
			tabIconImage.BorderSizePixel = 0
			tabIconImage.Image = (finalIconAsset and finalIconAsset.Url or "")
			
			if finalIconAsset then
				tabIconImage.ImageRectSize = finalIconAsset.ImageRectSize
				tabIconImage.ImageRectOffset = finalIconAsset.ImageRectOffset
			end
			
			tabIconImage.ImageColor3 = Theme.txt
			tabIconImage.ScaleType = Enum.ScaleType.Fit
			tabIconImage.Parent = tabButton
			
			local tabIconCorner = Instance.new("UICorner")
			tabIconCorner.CornerRadius = UDim.new(0, 4)
			tabIconCorner.Parent = tabIconImage
			
			local tabIconStroke = Instance.new("UIStroke")
			tabIconStroke.Color = Theme.brd
			tabIconStroke.Thickness = 1
			tabIconStroke.Parent = tabIconImage

			local buttonTextLabel = Instance.new("TextLabel")
			buttonTextLabel.Size = UDim2.new(1, -40, 1, 0)
			buttonTextLabel.Position = UDim2.new(0, 40, 0, 0)
			buttonTextLabel.BackgroundTransparency = 1
			buttonTextLabel.Text = tabStructure.Name
			buttonTextLabel.TextColor3 = Theme.txt
			buttonTextLabel.Font = Enum.Font.GothamSemibold
			buttonTextLabel.TextSize = 14
			buttonTextLabel.TextXAlignment = Enum.TextXAlignment.Center
			buttonTextLabel.Parent = tabButton

			tabStructure.Button = tabButton
			tabStructure.Label = buttonTextLabel
			tabStructure.Icon = tabIconImage

			local pageScrollingFrame = Instance.new("ScrollingFrame")
			pageScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
			pageScrollingFrame.BackgroundTransparency = 1
			pageScrollingFrame.Visible = false
			pageScrollingFrame.BorderSizePixel = 0
			pageScrollingFrame.Parent = mainContentContainer
			pageScrollingFrame.ScrollBarThickness = 3
			pageScrollingFrame.ScrollBarImageColor3 = Theme.brd
			pageScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

			local pagePadding = Instance.new("UIPadding")
			pagePadding.PaddingTop = UDim.new(0, 8)
			pagePadding.PaddingLeft = UDim.new(0, 8)
			pagePadding.PaddingRight = UDim.new(0, 8)
			pagePadding.PaddingBottom = UDim.new(0, 8)
			pagePadding.Parent = pageScrollingFrame
			
			local pageListLayout = Instance.new("UIListLayout")
			pageListLayout.Padding = UDim.new(0, 6)
			pageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			pageListLayout.Parent = pageScrollingFrame
			
			pageScrollingFrame.Layout = pageListLayout
			tabStructure.Content = pageScrollingFrame

			-- Safety cross-reparenting for categories attached before window building
			for _, categoryElement in ipairs(tabStructure.Categories) do
				if categoryElement.Category and categoryElement.Category.Parent ~= pageScrollingFrame then
					categoryElement.Category.Parent = pageScrollingFrame
				end
			end

			tabButton.MouseEnter:Connect(function() 
				tweenBackgroundColor(tabButton, Theme.hover, 0) 
			end)
			tabButton.MouseLeave:Connect(function()
				if windowContext.ActiveTab ~= tabStructure then 
					tweenBackgroundColor(tabButton, Theme.darker, 0) 
				end
			end)
			tabButton.MouseButton1Click:Connect(function()
				if windowContext.ActiveTab then
					tweenBackgroundColor(windowContext.ActiveTab.Button, Theme.darker, 0)
					windowContext.ActiveTab.Content.Visible = false
				end
				windowContext.ActiveTab = tabStructure
				tweenBackgroundColor(tabButton, Theme.acc, 0)
				tabStructure.Content.Visible = true
			end)
		end

		if #windowContext.Tabs > 0 then
			windowContext.ActiveTab = windowContext.Tabs[1]
			windowContext.Tabs[1].Button.BackgroundColor3 = Theme.acc
			windowContext.Tabs[1].Content.Visible = true
		end

		-- Sidebar expand/collapse logic loop
		local function animateSidebarCollapse(shouldExpand)
			windowContext.SidebarExpanded = shouldExpand
			local calculatedWidth = 48
			if shouldExpand then
				calculatedWidth = 180
			end
			
			sidebarFrame:TweenSize(UDim2.new(0, calculatedWidth, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
			
			local toggleXOffset = (calculatedWidth - 32) / 2
			if shouldExpand then
				toggleXOffset = 8
			end
			
			sidebarToggleButton:TweenPosition(UDim2.new(0, toggleXOffset, 0.5, -16), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
			sidebarDivider:TweenPosition(UDim2.new(0, calculatedWidth, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
			mainContentContainer:TweenSizeAndPosition(UDim2.new(1, -(calculatedWidth + 1), 1, 0), UDim2.new(0, calculatedWidth + 1, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
			
			local targetTransparency = 1
			if shouldExpand then
				targetTransparency = 0
			end
			
			for _, tabNode in ipairs(windowContext.Tabs) do
				TweenService:Create(tabNode.Label, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextTransparency = targetTransparency
				}):Play()
			end
		end

		sidebarToggleButton.MouseButton1Click:Connect(function()
			animateSidebarCollapse(not windowContext.SidebarExpanded)
		end)

		-- Frame Dragging Core System Implementation
		local isDraggingWindow = false
		local draggingInputStartPosition
		local frameStartPosition

		titleBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isDraggingWindow = true
				draggingInputStartPosition = input.Position
				frameStartPosition = mainFrame.Position
				
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then 
						isDraggingWindow = false 
					end
				end)
			end
		end)
		
		table.insert(Lib.Conns, UserInputService.InputChanged:Connect(function(input)
			if isDraggingWindow and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local deltaChange = input.Position - draggingInputStartPosition
				mainFrame.Position = UDim2.new(
					frameStartPosition.X.Scale, frameStartPosition.X.Offset + deltaChange.X,
					frameStartPosition.Y.Scale, frameStartPosition.Y.Offset + deltaChange.Y
				)
			end
		end))

		closeButton.MouseButton1Click:Connect(function()
			windowContext:Destroy()
			Lib.Toggled = false
		end)
		
		closeButton.MouseEnter:Connect(function()
			closeButton.BackgroundColor3 = Theme.err
			closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		end)
		
		closeButton.MouseLeave:Connect(function()
			closeButton.BackgroundTransparency = 1
			closeButton.TextColor3 = Theme.dim
		end)

		-- Global Keyboard Toggle Input Connect
		table.insert(Lib.Conns, UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == windowContext.ToggleKey then
				screenGui.Enabled = not screenGui.Enabled
				Lib.Toggled = screenGui.Enabled
			end
		end))

		-- Touch Screens Mobile Optimization Overlay Floating Widget
		if UserInputService.TouchEnabled then
			local mobileToggleButton = Instance.new("ImageButton")
			mobileToggleButton.Size = UDim2.new(0, 36, 0, 36)
			mobileToggleButton.Position = UDim2.new(0, 8, 0.5, -18)
			mobileToggleButton.BackgroundColor3 = Theme.acc
			mobileToggleButton.BorderSizePixel = 0
			mobileToggleButton.Image = (userIconAsset and userIconAsset.Url or "")
			
			if userIconAsset then
				mobileToggleButton.ImageRectSize = userIconAsset.ImageRectSize
				mobileToggleButton.ImageRectOffset = userIconAsset.ImageRectOffset
			end
			
			mobileToggleButton.ImageColor3 = Color3.new(1, 1, 1)
			mobileToggleButton.BackgroundTransparency = 0.3
			mobileToggleButton.AutoButtonColor = false
			mobileToggleButton.ZIndex = 100
			mobileToggleButton.Parent = screenGui
			
			local mobileCorner = Instance.new("UICorner")
			mobileCorner.CornerRadius = UDim.new(0, 8)
			mobileCorner.Parent = mobileToggleButton
			windowContext._mobileBtn = mobileToggleButton

			mobileToggleButton.MouseButton1Click:Connect(function()
				local currentVisibility = not mainFrame.Visible
				mainFrame.Visible = currentVisibility
				mobileToggleButton.Visible = not currentVisibility
			end)
			
			mainFrame.Visible = false
		end

		if Lib._cfg.auto then
			task.spawn(function()
				task.wait()
				Lib:LoadConfig()
			end)
		end
	end

	table.insert(Lib.Windows, windowContext)
	return windowContext
end

function Lib:Unload()
	for _, ongoingSignal in ipairs(self.Conns) do 
		ongoingSignal:Disconnect() 
	end
	for _, openWindow in ipairs(self.Windows) do 
		openWindow:Destroy() 
	end
	
	self.Conns = {}
	self.Windows = {}
	self.Opts = {}
	getgenv().UndetectedDynamic = nil
end

getgenv().UndetectedDynamic = Lib
return Lib