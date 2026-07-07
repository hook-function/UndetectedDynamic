local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local Http = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local GetIcon
local ok, Lucide = pcall(function()
	return loadstring(
		game:HttpGet("https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua")
	)()
end)
if ok then
	local cache = {}
	function GetIcon(name)
		if cache[name] then return cache[name] end
		local s, asset = pcall(Lucide.GetAsset, name)
		if s and asset then
			cache[name] = asset
			return asset
		end
		return nil
	end
else
	function GetIcon() end
end

local TInfo = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local function tween(obj, props)
	Tween:Create(obj, TInfo, props):Play()
end

local c = {
	bg = Color3.fromRGB(18, 18, 22),
	dark = Color3.fromRGB(24, 24, 30),
	darker = Color3.fromRGB(14, 14, 17),
	acc = Color3.fromRGB(99, 102, 241), -- Vibrant Violet/Indigo
	hover = Color3.fromRGB(35, 35, 45),
	txt = Color3.fromRGB(243, 244, 246),
	dim = Color3.fromRGB(156, 163, 175),
	brd = Color3.fromRGB(38, 38, 48),
	err = Color3.fromRGB(239, 68, 68),
	inp = Color3.fromRGB(28, 28, 35),
	sl = Color3.fromRGB(31, 41, 55),
}

local Lib = {
	Toggled = false, Windows = {}, Conns = {}, Opts = {},
	_cfg = {folder = "UndetectedConfigs", name = "", data = {}, auto = false},
}

function Lib:SetTheme(overrides)
	for k, v in pairs(overrides or {}) do
		if c[k] ~= nil then c[k] = v end
	end
end

-- ── Config System ──

local function cfgPath(name)
	local dir = Lib._cfg.folder .. "/settings"
	if not isfolder(dir) then
		makefolder(dir)
	end
	return dir .. "/" .. name .. ".json"
end

function Lib:CreateConfig(name)
	self._cfg.name = name or "config"
	self._cfg.data = {}
end

function Lib:SaveConfig(name)
	name = name or self._cfg.name
	if not name or name == "" then return false end
	local out = {}
	for idx, obj in pairs(self.Opts) do
		out[idx] = obj:GetValue()
	end
	local ok, json = pcall(Http.JSONEncode, Http, out)
	if not ok then return false end
	writefile(cfgPath(name), json)
	if name ~= self._cfg.name then
		self._cfg.name = name
	end
	return true
end

function Lib:LoadConfig(name)
	name = name or self._cfg.name
	if not name or name == "" then return false end
	if not isfile(cfgPath(name)) then return false end
	local ok, data = pcall(Http.JSONDecode, Http, readfile(cfgPath(name)))
	if not ok or type(data) ~= "table" then return false end
	self._cfg.data = data
	for idx, obj in pairs(self.Opts) do
		if data[idx] ~= nil then
			obj:SetValue(data[idx])
		end
	end
	if name ~= self._cfg.name then
		self._cfg.name = name
	end
	return true
end

function Lib:AutoLoadConfig(bool)
	self._cfg.auto = bool
end

function Lib:DeleteConfig(name)
	name = name or self._cfg.name
	if not name or name == "" then return false end
	if isfile(cfgPath(name)) then
		delfile(cfgPath(name))
		return true
	end
	return false
end

function Lib:ListConfigs()
	local dir = Lib._cfg.folder .. "/settings"
	if not isfolder(dir) then return {} end
	local files = listfiles(dir)
	local out = {}
	for _, f in ipairs(files) do
		local name = f:match("([^/\\]+)%.json$")
		if name then table.insert(out, name) end
	end
	return out
end

function Lib:ExportConfig(name)
	self:SaveConfig(name)
	local path = cfgPath(name or self._cfg.name)
	if isfile(path) then
		return readfile(path)
	end
	return nil
end

function Lib:ImportConfig(json)
	local ok, data = pcall(Http.JSONDecode, Http, json)
	if not ok or type(data) ~= "table" then return false end
	self._cfg.data = data
	for idx, obj in pairs(self.Opts) do
		if data[idx] ~= nil then
			obj:SetValue(data[idx])
		end
	end
	return true
end

local function regObj(id, obj)
	if id and id ~= "" then
		Lib.Opts[id] = obj
	end
end

-- Element builders -------------------------------------------------

local function mkLabel(parent, text)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, 22)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = c.dim
	l.Font = Enum.Font.GothamMedium
	l.TextSize = 12
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local function mkDivider(parent)
	local d = Instance.new("Frame")
	d.Size = UDim2.new(1, 0, 0, 1)
	d.BackgroundColor3 = c.brd
	d.BorderSizePixel = 0
	d.Parent = parent
	return d
end

local function mkButton(parent, text, cb)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 32)
	b.BackgroundColor3 = c.inp
	b.BorderSizePixel = 0
	b.Text = text
	b.TextColor3 = c.txt
	b.Font = Enum.Font.GothamSemibold
	b.TextSize = 13
	b.AutoButtonColor = false
	b.Parent = parent
	
	local co = Instance.new("UICorner")
	co.CornerRadius = UDim.new(0, 6)
	co.Parent = b

	local stroke = Instance.new("UIStroke")
	stroke.Color = c.brd
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = b

	b.MouseEnter:Connect(function() 
		tween(b, {BackgroundColor3 = c.hover}) 
		tween(stroke, {Color = c.acc})
	end)
	b.MouseLeave:Connect(function() 
		tween(b, {BackgroundColor3 = c.inp}) 
		tween(stroke, {Color = c.brd})
	end)
	b.MouseButton1Click:Connect(function() if cb then cb() end end)
	return b
end

local function mkToggle(parent, text, opts)
	opts = opts or {}
	local def = opts.Default or false
	local cb = opts.Callback or function() end
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundTransparency = 1
	row.Parent = parent

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -40, 1, 0)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = c.txt
	l.Font = Enum.Font.Gotham
	l.TextSize = 13
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = row

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(0, 32, 0, 18)
	bg.Position = UDim2.new(1, -32, 0.5, -9)
	bg.BackgroundColor3 = c.sl
	bg.BorderSizePixel = 0
	bg.Parent = row
	local bgC = Instance.new("UICorner")
	bgC.CornerRadius = UDim.new(1, 0)
	bgC.Parent = bg

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new(0, 2, 0.5, -7)
	knob.BackgroundColor3 = c.dim
	knob.BorderSizePixel = 0
	knob.Parent = bg
	local kc = Instance.new("UICorner")
	kc.CornerRadius = UDim.new(1, 0)
	kc.Parent = knob

	local state = def
	local function set(v)
		state = v
		local col = if state then c.acc else c.sl
		local kcol = if state then c.txt else c.dim
		local kp = if state then UDim2.new(1, -16, 0.5, -7) else UDim2.new(0, 2, 0.5, -7)
		tween(bg, {BackgroundColor3 = col})
		tween(knob, {BackgroundColor3 = kcol, Position = kp})
		pcall(cb, state)
	end

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = row
	btn.MouseButton1Click:Connect(function() set(not state) end)

	set(def)

	local obj = {SetValue = set, GetValue = function() return state end}
	regObj(opts.Id or opts.id or text, obj)
	return obj
end

local function mkInput(parent, text, opts)
	opts = opts or {}
	local def = opts.Default or ""
	local ph = opts.Placeholder or ""
	local cb = opts.Callback or function() end
	local num = opts.Numeric or false

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 32)
	row.BackgroundTransparency = 1
	row.Parent = parent

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(0, 100, 1, 0)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = c.txt
	l.Font = Enum.Font.Gotham
	l.TextSize = 13
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = row

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -108, 0, 26)
	box.Position = UDim2.new(1, 0, 0.5, 0)
	box.AnchorPoint = Vector2.new(1, 0.5)
	box.BackgroundColor3 = c.inp
	box.BorderSizePixel = 0
	box.Text = def
	box.TextColor3 = c.txt
	box.Font = Enum.Font.Gotham
	box.TextSize = 13
	box.PlaceholderText = ph
	box.PlaceholderColor3 = c.dim
	box.ClearTextOnFocus = false
	box.Parent = row
	
	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0, 6)
	bc.Parent = box

	local stroke = Instance.new("UIStroke")
	stroke.Color = c.brd
	stroke.Thickness = 1
	stroke.Parent = box

	box.Focused:Connect(function() tween(stroke, {Color = c.acc}) end)
	box.FocusLost:Connect(function()
		tween(stroke, {Color = c.brd})
		if num then
			local n = tonumber(box.Text)
			if n then box.Text = tostring(n) else box.Text = tostring(def) end
		end
		pcall(cb, box.Text)
	end)

	if num then box.Text = tostring(def) end

	local obj = {TextBox = box, SetValue = function(v) box.Text = tostring(v) end, GetValue = function() return box.Text end}
	regObj(opts.Id or opts.id or text, obj)
	return obj
end

local function mkSlider(parent, text, opts)
	opts = opts or {}
	local mn = opts.Min or 0
	local mx = opts.Max or 100
	local def = opts.Default or mn
	local sfx = opts.Suffix or ""
	local cb = opts.Callback or function() end
	local precise = opts.Precise or false

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 38)
	row.BackgroundTransparency = 1
	row.Parent = parent

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -80, 0, 18)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = c.txt
	l.Font = Enum.Font.Gotham
	l.TextSize = 13
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = row

	local vl = Instance.new("TextLabel")
	vl.Size = UDim2.new(0, 72, 0, 18)
	vl.Position = UDim2.new(1, 0, 0, 0)
	vl.AnchorPoint = Vector2.new(1, 0)
	vl.BackgroundTransparency = 1
	vl.Text = tostring(def) .. sfx
	vl.TextColor3 = c.acc
	vl.Font = Enum.Font.GothamBold
	vl.TextSize = 12
	vl.TextXAlignment = Enum.TextXAlignment.Right
	vl.Parent = row

	local rail = Instance.new("Frame")
	rail.Size = UDim2.new(1, 0, 0, 6)
	rail.Position = UDim2.new(0, 0, 1, -6)
	rail.BackgroundColor3 = c.sl
	rail.BorderSizePixel = 0
	rail.Parent = row
	local rc = Instance.new("UICorner")
	rc.CornerRadius = UDim.new(1, 0)
	rc.Parent = rail

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = c.acc
	fill.BorderSizePixel = 0
	fill.Parent = rail
	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(1, 0)
	fc.Parent = fill

	local k = Instance.new("Frame")
	k.Size = UDim2.new(0, 12, 0, 12)
	k.BackgroundColor3 = c.txt
	k.BorderSizePixel = 0
	k.ZIndex = 2
	k.Parent = row
	local kc = Instance.new("UICorner")
	kc.CornerRadius = UDim.new(1, 0)
	kc.Parent = k

	local val = def
	local dragging = false

	local function update(v)
		val = math.clamp(v, mn, mx)
		local t = (val - mn) / (mx - mn)
		local w = rail.AbsoluteSize.X
		fill.Size = UDim2.new(t, 0, 1, 0)
		k.Position = UDim2.new(t, -6, 1, -9)
		local str = if precise then string.format("%.1f", val) else tostring(math.floor(val))
		vl.Text = str .. sfx
		pcall(cb, val)
	end

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.ZIndex = 1
	btn.Parent = row

	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			local m = UIS:GetMouseLocation()
			local t = math.clamp((m.X - rail.AbsolutePosition.X) / rail.AbsoluteSize.X, 0, 1)
			update(mn + t * (mx - mn))
		end
	end)
	btn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local m = UIS:GetMouseLocation()
			local t = math.clamp((m.X - rail.AbsolutePosition.X) / rail.AbsoluteSize.X, 0, 1)
			update(mn + t * (mx - mn))
		end
	end)

	update(def)
	local obj = {SetValue = function(v) update(v) end, GetValue = function() return val end}
	regObj(opts.Id or opts.id or text, obj)
	return obj
end

local function mkDropdown(parent, text, opts)
	opts = opts or {}
	local items = opts.Items or {}
	local def = opts.Default or ""
	local cb = opts.Callback or function() end

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 32)
	row.BackgroundTransparency = 1
	row.Parent = parent

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(0, 100, 1, 0)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = c.txt
	l.Font = Enum.Font.Gotham
	l.TextSize = 13
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = row

	local disp = Instance.new("TextButton")
	disp.Size = UDim2.new(1, -108, 0, 26)
	disp.Position = UDim2.new(1, 0, 0.5, 0)
	disp.AnchorPoint = Vector2.new(1, 0.5)
	disp.BackgroundColor3 = c.inp
	disp.BorderSizePixel = 0
	disp.Text = def == "" and "Select..." or def
	disp.TextColor3 = c.txt
	disp.Font = Enum.Font.Gotham
	disp.TextSize = 13
	disp.AutoButtonColor = false
	disp.Parent = row
	local dc = Instance.new("UICorner")
	dc.CornerRadius = UDim.new(0, 6)
	dc.Parent = disp

	local stroke = Instance.new("UIStroke")
	stroke.Color = c.brd
	stroke.Thickness = 1
	stroke.Parent = disp

	local arr = Instance.new("TextLabel")
	arr.Size = UDim2.new(0, 18, 1, 0)
	arr.Position = UDim2.new(1, -18, 0, 0)
	arr.BackgroundTransparency = 1
	arr.Text = "▼"
	arr.TextColor3 = c.dim
	arr.Font = Enum.Font.Gotham
	arr.TextSize = 10
	arr.Parent = disp

	local dd = Instance.new("ScrollingFrame")
	dd.Size = UDim2.new(1, -108, 0, 0)
	dd.Position = UDim2.new(1, 0, 1, 4)
	dd.AnchorPoint = Vector2.new(1, 0)
	dd.BackgroundColor3 = c.darker
	dd.BorderSizePixel = 0
	dd.Visible = false
	dd.ScrollBarThickness = 2
	dd.ScrollBarImageColor3 = c.brd
	dd.AutomaticCanvasSize = Enum.AutomaticSize.Y
	dd.ZIndex = 20
	dd.Parent = row
	
	local dco = Instance.new("UICorner")
	dco.CornerRadius = UDim.new(0, 6)
	dco.Parent = dd
	local dsk = Instance.new("UIStroke")
	dsk.Color = c.brd
	dsk.Parent = dd

	local dList = Instance.new("UIListLayout")
	dList.Padding = UDim.new(0, 2)
	dList.Parent = dd
	local dPad = Instance.new("UIPadding")
	dPad.PaddingTop = UDim.new(0, 4)
	dPad.PaddingBottom = UDim.new(0, 4)
	dPad.PaddingLeft = UDim.new(0, 4)
	dPad.PaddingRight = UDim.new(0, 4)
	dPad.Parent = dd

	local sel = def

	local function build()
		for _, v in ipairs(dd:GetChildren()) do
			if v:IsA("TextButton") then v:Destroy() end
		end
		for _, item in ipairs(items) do
			local ib = Instance.new("TextButton")
			ib.Size = UDim2.new(1, 0, 0, 24)
			ib.BackgroundTransparency = 1
			ib.BorderSizePixel = 0
			ib.Text = item
			ib.TextColor3 = c.txt
			ib.Font = Enum.Font.Gotham
			ib.TextSize = 13
			ib.AutoButtonColor = false
			ib.ZIndex = 21
			ib.Parent = dd
			
			local ibc = Instance.new("UICorner")
			ibc.CornerRadius = UDim.new(0, 4)
			ibc.Parent = ib

			ib.MouseEnter:Connect(function() tween(ib, {BackgroundTransparency = 0, BackgroundColor3 = c.hover}) end)
			ib.MouseLeave:Connect(function() tween(ib, {BackgroundTransparency = 1}) end)
			ib.MouseButton1Click:Connect(function()
				sel = item; disp.Text = item; dd.Visible = false
				pcall(cb, item)
			end)
		end
	end

	build()

	disp.MouseButton1Click:Connect(function()
		dd.Visible = not dd.Visible
		if dd.Visible then
			tween(stroke, {Color = c.acc})
			dd.Size = UDim2.new(1, -108, 0, math.min(dList.AbsoluteContentSize.Y + 8, 150))
		else
			tween(stroke, {Color = c.brd})
		end
	end)

	UIS.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local p = input.Position
			local ap = row.AbsolutePosition; local asz = row.AbsoluteSize
			local dap = dd.AbsolutePosition; local dasz = dd.AbsoluteSize
			if dd.Visible and not (
				(p.X >= ap.X and p.X <= ap.X + asz.X and p.Y >= ap.Y and p.Y <= ap.Y + asz.Y) or
				(p.X >= dap.X and p.X <= dap.X + dasz.X and p.Y >= dap.Y and p.Y <= dap.Y + dasz.Y)
			) then 
				dd.Visible = false 
				tween(stroke, {Color = c.brd})
			end
		end
	end)

	local obj = {SetValue = function(v) sel = v; disp.Text = v; pcall(cb, v) end, GetValue = function() return sel end, Refresh = function(_, newItems) items = newItems or {}; build() end}
	regObj(opts.Id or opts.id or text, obj)
	return obj
end

local function mkColorPicker(parent, text, opts)
	opts = opts or {}
	local def = opts.Default or Color3.fromRGB(255, 255, 255)
	local cb = opts.Callback or function() end

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundTransparency = 1
	row.Parent = parent

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -34, 1, 0)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = c.txt
	l.Font = Enum.Font.Gotham
	l.TextSize = 13
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = row

	local sw = Instance.new("ImageButton")
	sw.Size = UDim2.new(0, 24, 0, 18)
	sw.Position = UDim2.new(1, 0, 0.5, 0)
	sw.AnchorPoint = Vector2.new(1, 0.5)
	sw.BackgroundColor3 = def
	sw.BorderSizePixel = 0
	sw.AutoButtonColor = false
	sw.Parent = row
	local swc = Instance.new("UICorner")
	swc.CornerRadius = UDim.new(0, 4)
	swc.Parent = sw
	local sws = Instance.new("UIStroke")
	sws.Color = c.brd
	sws.Thickness = 1
	sws.Parent = sw

	local col = def

	sw.MouseButton1Click:Connect(function()
		local gui = row:FindFirstAncestorOfClass("ScreenGui") or Players.LocalPlayer:WaitForChild("PlayerGui")
		local pk = Instance.new("Frame")
		pk.Size = UDim2.new(0, 180, 0, 160)
		pk.BackgroundColor3 = c.darker
		pk.BorderSizePixel = 0
		pk.ZIndex = 20
		pk.Parent = gui
		local pkC = Instance.new("UICorner")
		pkC.CornerRadius = UDim.new(0, 6)
		pkC.Parent = pk
		local pkS = Instance.new("UIStroke")
		pkS.Color = c.brd
		pkS.Parent = pk

		local h, s, v = Color3.toHSV(col)

		local sv = Instance.new("ImageLabel")
		sv.Size = UDim2.new(0, 164, 0, 115)
		sv.Position = UDim2.new(0, 8, 0, 8)
		sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		sv.Image = "rbxassetid://4155801252"
		sv.ZIndex = 21
		sv.Parent = pk

		local cur = Instance.new("Frame")
		cur.Size = UDim2.new(0, 8, 0, 8)
		cur.BackgroundColor3 = Color3.new(1, 1, 1)
		cur.BorderSizePixel = 1
		cur.BorderColor3 = Color3.new(0, 0, 0)
		cur.ZIndex = 22
		cur.Parent = sv
		local curC = Instance.new("UICorner")
		curC.CornerRadius = UDim.new(1, 0)
		curC.Parent = cur

		local hb = Instance.new("Frame")
		hb.Size = UDim2.new(0, 164, 0, 12)
		hb.Position = UDim2.new(0, 8, 0, 134)
		hb.BackgroundTransparency = 1
		hb.ZIndex = 21
		hb.Parent = pk
		local hg = Instance.new("UIGradient")
		hg.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		})
		hg.Parent = hb

		local hc = Instance.new("Frame")
		hc.Size = UDim2.new(0, 4, 1, 2)
		hc.BackgroundColor3 = Color3.new(1, 1, 1)
		hc.BorderSizePixel = 1
		hc.BorderColor3 = Color3.new(0, 0, 0)
		hc.ZIndex = 22
		hc.Parent = hb

		local function upd()
			local cl = Color3.fromHSV(h, s, v)
			col = cl; sw.BackgroundColor3 = cl
			sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			cur.Position = UDim2.new(s, -cur.AbsoluteSize.X / 2, 1 - v, -cur.AbsoluteSize.Y / 2)
			hc.Position = UDim2.new(h, -hc.AbsoluteSize.X / 2, 0, 0)
			pcall(cb, cl)
		end

		local ds, dh
		sv.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				ds = true
				local m = UIS:GetMouseLocation()
				s = math.clamp((m.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
				v = 1 - math.clamp((m.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
				upd()
			end
		end)
		sv.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then ds = false end
		end)

		hb.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				dh = true
				local m = UIS:GetMouseLocation()
				h = math.clamp((m.X - hb.AbsolutePosition.X) / hb.AbsoluteSize.X, 0, 1)
				upd()
			end
		end)
		hb.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then dh = false end
		end)

		UIS.InputChanged:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseMovement then
				if ds then
					local m = UIS:GetMouseLocation()
					s = math.clamp((m.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
					v = 1 - math.clamp((m.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
					upd()
				end
				if dh then
					local m = UIS:GetMouseLocation()
					h = math.clamp((m.X - hb.AbsolutePosition.X) / hb.AbsoluteSize.X, 0, 1)
					upd()
				end
			end
		end)

		UIS.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local p = input.Position
				local ap = pk.AbsolutePosition; local asz = pk.AbsoluteSize
				if not (p.X >= ap.X and p.X <= ap.X + asz.X and p.Y >= ap.Y and p.Y <= ap.Y + asz.Y) then
					pk:Destroy()
				end
			end
		end)

		upd()
	end)

	local obj = {SetValue = function(cl) col = cl; sw.BackgroundColor3 = cl; pcall(cb, cl) end, GetValue = function() return col end}
	regObj(opts.Id or opts.id or text, obj)
	return obj
end

local function mkKeybind(parent, text, opts)
	opts = opts or {}
	local def = opts.Default or "None"
	local cb = opts.Callback or function() end

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundTransparency = 1
	row.Parent = parent

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -34, 1, 0)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = c.txt
	l.Font = Enum.Font.Gotham
	l.TextSize = 13
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = row

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 44, 0, 22)
	btn.Position = UDim2.new(1, 0, 0.5, 0)
	btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.BackgroundColor3 = c.inp
	btn.BorderSizePixel = 0
	btn.Text = def
	btn.TextColor3 = c.dim
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 12
	btn.AutoButtonColor = false
	btn.Parent = row
	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0, 4)
	bc.Parent = btn
	local stroke = Instance.new("UIStroke")
	stroke.Color = c.brd
	stroke.Parent = btn

	local key = def

	local function updateSize()
		local strSize = TextService:GetTextSize(btn.Text, btn.TextSize, btn.Font, Vector2.new(200, 22))
		btn.Size = UDim2.new(0, strSize.X + 14, 0, 22)
	end

	local picking = false
	btn.MouseButton1Click:Connect(function()
		if picking then return end
		picking = true
		btn.Text = "..."
		btn.TextColor3 = c.acc
		updateSize()
		local inp = UIS.InputBegan:Wait()
		local newKey
		if inp.UserInputType == Enum.UserInputType.Keyboard then
			newKey = inp.KeyCode == Enum.KeyCode.Escape and "None" or inp.KeyCode.Name
		elseif inp.UserInputType == Enum.UserInputType.MouseButton1 then
			newKey = "MB1"
		elseif inp.UserInputType == Enum.UserInputType.MouseButton2 then
			newKey = "MB2"
		else
			newKey = "None"
		end
		key = newKey
		btn.Text = key
		btn.TextColor3 = c.dim
		updateSize()
		picking = false
		pcall(cb, key)
	end)

	updateSize()

	local obj = {
		SetValue = function(v) key = v; btn.Text = v; updateSize() end,
		GetValue = function() return key end,
	}
	regObj(opts.Id or opts.id or text, obj)
	return obj
end

-- Category system ---------------------------------------------------

local function makeCategory(tab, name)
	local page = tab.Content
	local cat = Instance.new("Frame")
	cat.Size = UDim2.new(1, 0, 0, 36)
	cat.BackgroundColor3 = c.darker
	cat.BorderSizePixel = 0
	cat.ClipsDescendants = true
	cat.Parent = page

	local catC = Instance.new("UICorner")
	catC.CornerRadius = UDim.new(0, 6)
	catC.Parent = cat
	local stroke = Instance.new("UIStroke")
	stroke.Color = c.brd
	stroke.Parent = cat

	local hdr = Instance.new("TextButton")
	hdr.Size = UDim2.new(1, 0, 0, 36)
	hdr.BackgroundTransparency = 1
	hdr.Text = ""
	hdr.AutoButtonColor = false
	hdr.ZIndex = 2
	hdr.Parent = cat

	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.new(0, 16, 0, 36)
	arrow.Position = UDim2.new(0, 10, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text = "→"
	arrow.TextColor3 = c.dim
	arrow.Font = Enum.Font.GothamBold
	arrow.TextSize = 13
	arrow.Rotation = 90
	arrow.Parent = hdr

	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.new(1, -34, 1, 0)
	tl.Position = UDim2.new(0, 32, 0, 0)
	tl.BackgroundTransparency = 1
	tl.Text = name
	tl.TextColor3 = c.txt
	tl.Font = Enum.Font.GothamSemibold
	tl.TextSize = 13
	tl.TextXAlignment = Enum.TextXAlignment.Left
	tl.Parent = hdr

	local cont = Instance.new("Frame")
	cont.Size = UDim2.new(1, 0, 0, 0)
	cont.Position = UDim2.new(0, 0, 0, 36)
	cont.BackgroundTransparency = 1
	cont.Parent = cat

	local lst = Instance.new("UIListLayout")
	lst.Padding = UDim.new(0, 6)
	lst.SortOrder = Enum.SortOrder.LayoutOrder
	lst.Parent = cont
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 12)
	pad.PaddingRight = UDim.new(0, 12)
	pad.PaddingBottom = UDim.new(0, 10)
	pad.Parent = cont

	local con = {
		Category = cat, Container = cont, Header = hdr,
		Tab = tab, Expanded = true, Name = name,
	}

	lst:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if con.Expanded then
			local ch = lst.AbsoluteContentSize.Y
			cont.Size = UDim2.new(1, 0, 0, ch)
			cat.Size = UDim2.new(1, 0, 0, 36 + ch + 10)
		end
	end)

	hdr.MouseButton1Click:Connect(function()
		con.Expanded = not con.Expanded
		local ch = lst.AbsoluteContentSize.Y
		local h = if con.Expanded then ch else 0
		
		tween(cont, {Size = UDim2.new(1, 0, 0, h)})
		tween(arrow, {Rotation = if con.Expanded then 90 else 0})
		tween(cat, {Size = UDim2.new(1, 0, 0, if con.Expanded then (36 + ch + 10) else 36)})
	end)

	con.AddLabel = function(_, txt) return mkLabel(cont, txt) end
	con.AddDivider = function() return mkDivider(cont) end
	con.AddButton = function(_, txt, fn) return mkButton(cont, txt, fn) end
	con.AddToggle = function(_, txt, o) return mkToggle(cont, txt, o) end
	con.AddInput = function(_, txt, o) return mkInput(cont, txt, o) end
	con.AddSlider = function(_, txt, o) return mkSlider(cont, txt, o) end
	con.AddDropdown = function(_, txt, o) return mkDropdown(cont, txt, o) end
	con.AddColorPicker = function(_, txt, o) return mkColorPicker(cont, txt, o) end
	con.AddKeybind = function(_, txt, o) return mkKeybind(cont, txt, o) end

	table.insert(tab.Categories, con)
	return con
end

-- Tab methods -------------------------------------------------------

local tabMt = {}
function tabMt:AddCategory(name) return makeCategory(self, name) end

-- Window methods ----------------------------------------------------

local winMt = {}

function winMt:AddTab(name)
	local tab = setmetatable({
		Name = name, Button = nil, Content = nil, Label = nil, Icon = nil,
		Categories = {}, Elements = {},
	}, {__index = tabMt})
	table.insert(self.Tabs, tab)
	return tab
end

function winMt:Destroy()
	if self.MainFrame then self.MainFrame:Destroy() end
	if self._mobileBtn then self._mobileBtn:Destroy() end
	self.ScreenGui = nil
end

function winMt:SetToggleKey(keyCode)
	self.ToggleKey = keyCode
end

function winMt:Build()
	local gui = Instance.new("ScreenGui")
	gui.Name = "UI_" .. math.random(1000, 9999)
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = 999
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	self.ScreenGui = gui

	local mf = Instance.new("Frame")
	mf.Size = UDim2.new(0, self.Size.X, 0, self.Size.Y)
	mf.Position = UDim2.new(0.5, -self.Size.X / 2, 0.5, -self.Size.Y / 2)
	mf.BackgroundColor3 = c.bg
	mf.BorderSizePixel = 0
	mf.Active = true
	mf.Parent = gui
	self.MainFrame = mf

	local mfc = Instance.new("UICorner")
	mfc.CornerRadius = UDim.new(0, 10)
	mfc.Parent = mf
	local mfs = Instance.new("UIStroke")
	mfs.Color = c.brd
	mfs.Thickness = 1.5
	mfs.Parent = mf

	local tb = Instance.new("Frame")
	tb.Size = UDim2.new(1, 0, 0, 44)
	tb.BackgroundColor3 = c.dark
	tb.BorderSizePixel = 0
	tb.Parent = mf
	local tbc = Instance.new("UICorner")
	tbc.CornerRadius = UDim.new(0, 10)
	tbc.Parent = tb
	local tbf = Instance.new("Frame") -- masks bottom corners of head bar
	tbf.Size = UDim2.new(1, 0, 0, 10)
	tbf.Position = UDim2.new(0, 0, 1, -10)
	tbf.BackgroundColor3 = c.dark
	tbf.BorderSizePixel = 0
	tbf.Parent = tb

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -80, 1, 0)
	lbl.Position = UDim2.new(0, 40, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = self.Title
	lbl.TextColor3 = c.txt
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = tb

	local x = Instance.new("TextButton")
	x.Size = UDim2.new(0, 44, 1, 0)
	x.Position = UDim2.new(1, 0, 0, 0)
	x.AnchorPoint = Vector2.new(1, 0)
	x.BackgroundTransparency = 1
	x.Text = "✕"
	x.TextColor3 = c.dim
	x.Font = Enum.Font.Gotham
	x.TextSize = 14
	x.AutoButtonColor = false
	x.Parent = tb

	local ca = Instance.new("Frame")
	ca.Size = UDim2.new(1, 0, 1, -44)
	ca.Position = UDim2.new(0, 0, 0, 44)
	ca.BackgroundTransparency = 1
	ca.Parent = mf

	local sb = Instance.new("Frame")
	sb.Size = UDim2.new(0, 160, 1, 0)
	sb.BackgroundColor3 = c.darker
	sb.BorderSizePixel = 0
	sb.Parent = ca
	
	local sbc = Instance.new("UICorner")
	sbc.CornerRadius = UDim.new(0, 10)
	sbc.Parent = sb
	local sbf = Instance.new("Frame")
	sbf.Size = UDim2.new(1, 0, 0, 20)
	sbf.BackgroundColor3 = c.darker
	sbf.BorderSizePixel = 0
	sbf.Parent = sb

	local si = Instance.new("Frame")
	si.Size = UDim2.new(1, -16, 1, -16)
	si.Position = UDim2.new(0, 8, 0, 8)
	si.BackgroundTransparency = 1
	si.Parent = sb
	
	local sil = Instance.new("UIListLayout")
	sil.Padding = UDim.new(0, 4)
	sil.Parent = si

	local sd = Instance.new("Frame")
	sd.Size = UDim2.new(0, 1, 1, 0)
	sd.Position = UDim2.new(0, 160, 0, 0)
	sd.BackgroundColor3 = c.brd
	sd.BorderSizePixel = 0
	sd.Parent = ca

	local mc = Instance.new("Frame")
	mc.Size = UDim2.new(1, -161, 1, 0)
	mc.Position = UDim2.new(0, 161, 0, 0)
	mc.BackgroundTransparency = 1
	mc.Parent = ca

	for i, tab in ipairs(self.Tabs) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 34)
		btn.BackgroundColor3 = c.darker
		btn.BackgroundTransparency = 1
		btn.Text = tab.Name
		btn.TextColor3 = c.dim
		btn.Font = Enum.Font.GothamSemibold
		btn.TextSize = 13
		btn.AutoButtonColor = false
		btn.Parent = si

		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0, 6)
		bc.Parent = btn

		tab.Button = btn

		local page = Instance.new("ScrollingFrame")
		page.Size = UDim2.new(1, 0, 1, 0)
		page.BackgroundTransparency = 1
		page.Visible = false
		page.BorderSizePixel = 0
		page.Parent = mc
		page.ScrollBarThickness = 3
		page.ScrollBarImageColor3 = c.brd
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y

		local pp = Instance.new("UIPadding")
		pp.PaddingTop = UDim.new(0, 12)
		pp.PaddingLeft = UDim.new(0, 12)
		pp.PaddingRight = UDim.new(0, 12)
		pp.PaddingBottom = UDim.new(0, 12)
		pp.Parent = page
		local pl = Instance.new("UIListLayout")
		pl.Padding = UDim.new(0, 8)
		pl.SortOrder = Enum.SortOrder.LayoutOrder
		pl.Parent = page

		tab.Content = page

		for _, cat in ipairs(tab.Categories) do
			cat.Category.Parent = page
		end

		btn.MouseEnter:Connect(function()
			if self.ActiveTab ~= tab then tween(btn, {BackgroundTransparency = 0, BackgroundColor3 = c.hover, TextColor3 = c.txt}) end
		end)
		btn.MouseLeave:Connect(function()
			if self.ActiveTab ~= tab then tween(btn, {BackgroundTransparency = 1, TextColor3 = c.dim}) end
		end)
		btn.MouseButton1Click:Connect(function()
			if self.ActiveTab then
				tween(self.ActiveTab.Button, {BackgroundTransparency = 1, TextColor3 = c.dim})
				self.ActiveTab.Content.Visible = false
			end
			self.ActiveTab = tab
			tween(btn, {BackgroundTransparency = 0, BackgroundColor3 = c.acc, TextColor3 = c.txt})
			tab.Content.Visible = true
		end)
	end

	if #self.Tabs > 0 then
		self.ActiveTab = self.Tabs[1]
		self.Tabs[1].Button.BackgroundTransparency = 0
		self.Tabs[1].Button.BackgroundColor3 = c.acc
		self.Tabs[1].Button.TextColor3 = c.txt
		self.Tabs[1].Content.Visible = true
	end

	-- Dragging Mechanic
	local dragging, dragStart, startPos
	tb.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; dragStart = input.Position; startPos = mf.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	table.insert(Lib.Conns, UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			mf.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end))

	x.MouseButton1Click:Connect(function() self:Destroy() end)
	x.MouseEnter:Connect(function() tween(x, {TextColor3 = c.err}) end)
	x.MouseLeave:Connect(function() tween(x, {TextColor3 = c.dim}) end)

	table.insert(Lib.Conns, UIS.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == self.ToggleKey then
			gui.Enabled = not gui.Enabled
		end
	end))

	if Lib._cfg.auto then
		task.spawn(function()
			task.wait()
			Lib:LoadConfig()
		end)
	end
end

function Lib:CreateWindow(opts)
	opts = opts or {}
	local win = setmetatable({
		Title = opts.Title or "Undetected Dynamic",
		Size = opts.Size or Vector2.new(580, 400),
		ToggleKey = opts.ToggleKey or Enum.KeyCode.RightControl,
		Tabs = {}, MainFrame = nil, ScreenGui = nil, ActiveTab = nil,
	}, {__index = winMt})
	table.insert(Lib.Windows, win)
	return win
end

function Lib:Unload()
	for _, sig in ipairs(self.Conns) do sig:Disconnect() end
	for _, w in ipairs(self.Windows) do w:Destroy() end
	self.Conns = {}; self.Windows = {}; self.Opts = {}
	getgenv().UndetectedDynamic = nil
end

getgenv().UndetectedDynamic = Lib
return Lib