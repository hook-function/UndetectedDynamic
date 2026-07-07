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

local TInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function tween(obj, prop, value)
	Tween:Create(obj, TInfo, {[prop] = value}):Play()
end

local c = {
	bg = Color3.fromRGB(30, 30, 35),
	dark = Color3.fromRGB(22, 22, 26),
	darker = Color3.fromRGB(18, 18, 22),
	acc = Color3.fromRGB(88, 101, 242),
	hover = Color3.fromRGB(50, 50, 58),
	txt = Color3.fromRGB(245, 245, 245),
	dim = Color3.fromRGB(150, 150, 160),
	brd = Color3.fromRGB(45, 45, 52),
	err = Color3.fromRGB(240, 71, 71),
	inp = Color3.fromRGB(25, 25, 28),
	sl = Color3.fromRGB(40, 40, 48),
}

local Lib = {
	Toggled = true, Windows = {}, Conns = {}, Opts = {},
	_cfg = {folder = "UndetectedConfigs", name = "", data = {}, auto = false},
}

function Lib:SetTheme(overrides)
	for k, v in pairs(overrides or {}) do
		if c[k] ~= nil then c[k] = v end
	end
end

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

local function addStroke(parent, color, thickness)
	local str = Instance.new("UIStroke")
	str.Color = color or c.brd
	str.Thickness = thickness or 1
	str.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	str.Parent = parent
	return str
end

local function addCorner(parent, radius)
	local cor = Instance.new("UICorner")
	cor.CornerRadius = UDim.new(0, radius or 6)
	cor.Parent = parent
	return cor
end

local function mkLabel(parent, text)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, 24)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = c.dim
	l.Font = Enum.Font.Gotham
	l.TextSize = 13
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
	b.Size = UDim2.new(1, 0, 0, 34)
	b.BackgroundColor3 = c.inp
	b.BorderSizePixel = 0
	b.Text = text
	b.TextColor3 = c.txt
	b.Font = Enum.Font.GothamSemibold
	b.TextSize = 13
	b.AutoButtonColor = false
	b.Parent = parent
	addCorner(b, 6)
	addStroke(b, c.brd)

	b.MouseEnter:Connect(function() 
		tween(b, "BackgroundColor3", c.hover) 
	end)
	b.MouseLeave:Connect(function() 
		tween(b, "BackgroundColor3", c.inp) 
	end)
	b.MouseButton1Click:Connect(function() if cb then cb() end end)
	return b
end

local function mkToggle(parent, text, opts)
	opts = opts or {}
	local def = opts.Default or false
	local cb = opts.Callback or function() end
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 32)
	row.BackgroundTransparency = 1
	row.Parent = parent

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -44, 1, 0)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = c.txt
	l.Font = Enum.Font.Gotham
	l.TextSize = 13
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = row

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(0, 34, 0, 18)
	bg.Position = UDim2.new(1, -34, 0.5, -9)
	bg.BackgroundColor3 = c.sl
	bg.BorderSizePixel = 0
	bg.Parent = row
	addCorner(bg, 9)
	addStroke(bg, c.brd)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.Position = UDim2.new(0, 3, 0.5, -6)
	knob.BackgroundColor3 = c.dim
	knob.BorderSizePixel = 0
	knob.Parent = bg
	addCorner(knob, 6)

	local state = def
	local function set(v)
		state = v
		local col = if state then c.acc else c.sl
		local kcol = if state then Color3.new(1, 1, 1) else c.dim
		local kp = if state then UDim2.new(1, -15, 0.5, -6) else UDim2.new(0, 3, 0.5, -6)
		Tween:Create(bg, TInfo, {BackgroundColor3 = col}):Play()
		Tween:Create(knob, TInfo, {BackgroundColor3 = kcol, Position = kp}):Play()
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
	local ph = opts.Placeholder or "Type here..."
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
	addCorner(box, 4)
	local s = addStroke(box, c.brd)

	box.Focused:Connect(function() tween(s, "Color", c.acc) end)
	box.FocusLost:Connect(function()
		tween(s, "Color", c.brd)
		if num then
			local n = tonumber(box.Text)
			if n then box.Text = tostring(n) else box.Text = tostring(def) end
		end
		pcall(cb, box.Text)
	end)

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
	row.Size = UDim2.new(1, 0, 0, 42)
	row.BackgroundTransparency = 1
	row.Parent = parent

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -80, 0, 20)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = c.txt
	l.Font = Enum.Font.Gotham
	l.TextSize = 13
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = row

	local vl = Instance.new("TextLabel")
	vl.Size = UDim2.new(0, 72, 0, 20)
	vl.Position = UDim2.new(1, 0, 0, 0)
	vl.AnchorPoint = Vector2.new(1, 0)
	vl.BackgroundTransparency = 1
	vl.Text = tostring(def) .. sfx
	vl.TextColor3 = c.acc
	vl.Font = Enum.Font.GothamSemibold
	vl.TextSize = 12
	vl.TextXAlignment = Enum.TextXAlignment.Right
	vl.Parent = row

	local rail = Instance.new("Frame")
	rail.Size = UDim2.new(1, 0, 0, 6)
	rail.Position = UDim2.new(0, 0, 1, -8)
	rail.BackgroundColor3 = c.sl
	rail.BorderSizePixel = 0
	rail.Parent = row
	addCorner(rail, 3)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = c.acc
	fill.BorderSizePixel = 0
	fill.Parent = rail
	addCorner(fill, 3)

	local k = Instance.new("Frame")
	k.Size = UDim2.new(0, 12, 0, 12)
	k.BackgroundColor3 = Color3.new(1, 1, 1)
	k.BorderSizePixel = 0
	k.ZIndex = 2
	k.Parent = row
	addCorner(k, 6)
	addStroke(k, c.brd)

	local val = def
	local dragging = false

	local function update(v)
		val = math.clamp(v, mn, mx)
		local t = (val - mn) / (mx - mn)
		local w = rail.AbsoluteSize.X
		fill.Size = UDim2.new(t, 0, 1, 0)
		k.Position = UDim2.new(0, rail.AbsolutePosition.X - row.AbsolutePosition.X + (w * t) - 6, 0.5, 7)
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
			local rp = rail.AbsolutePosition
			local rw = rail.AbsoluteSize.X
			local t = math.clamp((m.X - rp.X) / rw, 0, 1)
			update(mn + t * (mx - mn))
		end
	end)
	btn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local m = UIS:GetMouseLocation()
			local rp = rail.AbsolutePosition
			local rw = rail.AbsoluteSize.X
			local t = math.clamp((m.X - rp.X) / rw, 0, 1)
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
	l.Size = UDim2.new(0, 120, 1, 0)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = c.txt
	l.Font = Enum.Font.Gotham
	l.TextSize = 13
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = row

	local disp = Instance.new("TextButton")
	disp.Size = UDim2.new(1, -128, 0, 26)
	disp.Position = UDim2.new(1, 0, 0.5, 0)
	disp.AnchorPoint = Vector2.new(1, 0.5)
	disp.BackgroundColor3 = c.inp
	disp.BorderSizePixel = 0
	disp.Text = def == "" and "Select Option..." or def
	disp.TextColor3 = c.txt
	disp.Font = Enum.Font.Gotham
	disp.TextSize = 13
	disp.AutoButtonColor = false
	disp.Parent = row
	addCorner(disp, 4)
	addStroke(disp, c.brd)

	local arr = Instance.new("TextLabel")
	arr.Size = UDim2.new(0, 18, 1, 0)
	arr.Position = UDim2.new(1, -18, 0, 0)
	arr.BackgroundTransparency = 1
	arr.Text = ">"
	arr.TextColor3 = c.dim
	arr.Font = Enum.Font.Gotham
	arr.TextSize = 10
	arr.Parent = disp

	-- Absolute overlay top layout fixing ZIndex issues inside clipped scrolling frames
	local gui = parent:FindFirstAncestorOfClass("ScreenGui")
	local dd = Instance.new("ScrollingFrame")
	dd.BackgroundColor3 = c.darker
	dd.BorderSizePixel = 0
	dd.Visible = false
	dd.ScrollBarThickness = 3
	dd.ScrollBarImageColor3 = c.acc
	dd.AutomaticCanvasSize = Enum.AutomaticSize.Y
	dd.ZIndex = 10000 -- Hard override to top child level
	dd.Parent = gui or row
	addCorner(dd, 4)
	addStroke(dd, c.brd, 1.2)

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

	local function updatePosition()
		dd.Size = UDim2.new(0, disp.AbsoluteSize.X, 0, math.min(dList.AbsoluteContentSize.Y + 8, 140))
		dd.Position = UDim2.new(0, disp.AbsolutePosition.X, 0, disp.AbsolutePosition.Y + disp.AbsoluteSize.Y + 4)
	end

	local function build()
		for _, v in if dd then dd:GetChildren() else {} do
			if v:IsA("TextButton") then v:Destroy() end
		end
		for _, item in ipairs(items) do
			local ib = Instance.new("TextButton")
			ib.Size = UDim2.new(1, 0, 0, 24)
			ib.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			ib.BackgroundTransparency = 1
			ib.Text = "  " .. item
			ib.TextColor3 = c.txt
			ib.Font = Enum.Font.Gotham
			ib.TextSize = 12
			ib.TextXAlignment = Enum.TextXAlignment.Left
			ib.AutoButtonColor = false
			ib.ZIndex = 10005
			ib.Parent = dd
			addCorner(ib, 4)

			ib.MouseEnter:Connect(function() 
				tween(ib, "BackgroundTransparency", 0.9)
				tween(ib, "BackgroundColor3", c.txt)
			end)
			ib.MouseLeave:Connect(function() 
				tween(ib, "BackgroundTransparency", 1)
			end)
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
			updatePosition()
		end
	end)

	row:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		if dd.Visible then updatePosition() end
	end)

	UIS.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local p = input.Position
			local dap = dd.AbsolutePosition; local dasz = dd.AbsoluteSize
			if dd.Visible and not (p.X >= dap.X and p.X <= dap.X + dasz.X and p.Y >= dap.Y and p.Y <= dap.Y + dasz.Y) then
				if not (p.X >= disp.AbsolutePosition.X and p.X <= disp.AbsolutePosition.X + disp.AbsoluteSize.X and p.Y >= disp.AbsolutePosition.Y and p.Y <= disp.AbsolutePosition.Y + disp.AbsoluteSize.Y) then
					dd.Visible = false
				end
			end
		end
	end)

	local obj = {
		SetValue = function(v) sel = v; disp.Text = v; pcall(cb, v) end,
		GetValue = function() return sel end,
		Refresh = function(newItems)
			items = newItems
			build()
			dd.Visible = false
		end,
	}
	regObj(opts.Id or opts.id or text, obj)
	return obj
end

local function mkColorPicker(parent, text, opts)
	opts = opts or {}
	local def = opts.Default or Color3.fromRGB(255, 255, 255)
	local cb = opts.Callback or function() end

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 32)
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
	sw.Size = UDim2.new(0, 24, 0, 20)
	sw.Position = UDim2.new(1, 0, 0.5, 0)
	sw.AnchorPoint = Vector2.new(1, 0.5)
	sw.BackgroundColor3 = def
	sw.BorderSizePixel = 0
	sw.AutoButtonColor = false
	sw.Parent = row
	addCorner(sw, 4)
	addStroke(sw, c.brd)

	local col = def

	sw.MouseButton1Click:Connect(function()
		local gui = row:FindFirstAncestorOfClass("ScreenGui") or Players.LocalPlayer:WaitForChild("PlayerGui")
		local pk = Instance.new("Frame")
		pk.Size = UDim2.new(0, 180, 0, 160)
		pk.BackgroundColor3 = c.darker
		pk.BorderSizePixel = 0
		pk.ZIndex = 50000
		pk.Position = UDim2.new(0, sw.AbsolutePosition.X - 190, 0, sw.AbsolutePosition.Y)
		pk.Parent = gui
		addCorner(pk, 6)
		addStroke(pk, c.brd, 1.5)

		local h, s, v = Color3.toHSV(col)

		local sv = Instance.new("ImageLabel")
		sv.Size = UDim2.new(0, 164, 0, 115)
		sv.Position = UDim2.new(0, 8, 0, 8)
		sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		sv.Image = "rbxassetid://4155801252"
		sv.ZIndex = 50001
		sv.Parent = pk
		addCorner(sv, 4)

		local cur = Instance.new("Frame")
		cur.Size = UDim2.new(0, 8, 0, 8)
		cur.BackgroundColor3 = Color3.new(1, 1, 1)
		cur.ZIndex = 50002
		cur.Parent = sv
		addCorner(cur, 4)
		addStroke(cur, Color3.new(0, 0, 0))

		local hb = Instance.new("Frame")
		hb.Size = UDim2.new(0, 164, 0, 12)
		hb.Position = UDim2.new(0, 8, 0, 134)
		hb.ZIndex = 50001
		hb.Parent = pk
		addCorner(hb, 2)

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
		hc.Position = UDim2.new(0, 0, 0, -1)
		hc.BackgroundColor3 = Color3.new(1, 1, 1)
		hc.ZIndex = 50002
		hc.Parent = hb
		addCorner(hc, 2)
		addStroke(hc, Color3.new(0, 0, 0))

		local function upd()
			local cl = Color3.fromHSV(h, s, v)
			col = cl; sw.BackgroundColor3 = cl
			sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			cur.Position = UDim2.new(s, -4, 1 - v, -4)
			hc.Position = UDim2.new(h, -2, 0, -1)
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

		hb.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				dh = true
				local m = UIS:GetMouseLocation()
				h = math.clamp((m.X - hb.AbsolutePosition.X) / hb.AbsoluteSize.X, 0, 1)
				upd()
			end
		end)

		UIS.InputChanged:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseMovement then
				local m = UIS:GetMouseLocation()
				if ds then
					s = math.clamp((m.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
					v = 1 - math.clamp((m.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
					upd()
				end
				if dh then
					h = math.clamp((m.X - hb.AbsolutePosition.X) / hb.AbsoluteSize.X, 0, 1)
					upd()
				end
			end
		end)

		UIS.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local p = input.Position
				if not (p.X >= pk.AbsolutePosition.X and p.X <= pk.AbsolutePosition.X + pk.AbsoluteSize.X and p.Y >= pk.AbsolutePosition.Y and p.Y <= pk.AbsolutePosition.Y + pk.AbsoluteSize.Y) then
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
	local onChange = opts.OnChange or function() end

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 32)
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
	btn.Size = UDim2.new(0, 40, 0, 22)
	btn.Position = UDim2.new(1, 0, 0.5, 0)
	btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.BackgroundColor3 = c.inp
	btn.BorderSizePixel = 0
	btn.Text = def
	btn.TextColor3 = c.acc
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 12
	btn.AutoButtonColor = false
	btn.Parent = row
	addCorner(btn, 4)
	addStroke(btn, c.brd)

	local key = def

	local function updateSize()
		local x = TextService:GetTextSize(btn.Text, btn.TextSize, btn.Font, Vector2.new(200, 30)).X
		btn.Size = UDim2.new(0, x + 16, 0, 22)
	end

	local picking = false
	btn.MouseButton1Click:Connect(function()
		if picking then return end
		picking = true
		btn.Text = "..."
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
		updateSize()
		picking = false
		pcall(cb, key)
		pcall(onChange, key)
	end)

	updateSize()

	local obj = {
		SetValue = function(v) key = v; btn.Text = v; updateSize() end,
		GetValue = function() return key end,
	}
	regObj(opts.Id or opts.id or text, obj)
	return obj
end

local function makeCategory(tab, name)
	local page = tab.Content
	local cat = Instance.new("Frame")
	cat.Size = UDim2.new(1, 0, 0, 32)
	cat.BackgroundColor3 = c.darker
	cat.BorderSizePixel = 0
	cat.Parent = page
	addCorner(cat, 6)
	addStroke(cat, c.brd)

	local hdr = Instance.new("TextButton")
	hdr.Size = UDim2.new(1, 0, 0, 32)
	hdr.BackgroundTransparency = 1
	hdr.Text = ""
	hdr.AutoButtonColor = false
	hdr.ZIndex = 2
	hdr.Parent = cat

	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.new(0, 16, 0, 32)
	arrow.Position = UDim2.new(0, 8, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text = ">"
	arrow.TextColor3 = c.dim
	arrow.Font = Enum.Font.Gotham
	arrow.TextSize = 12
	arrow.Rotation = 90
	arrow.Parent = hdr

	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.new(1, -40, 1, 0)
	tl.Position = UDim2.new(0, 28, 0, 0)
	tl.BackgroundTransparency = 1
	tl.Text = name
	tl.TextColor3 = c.txt
	tl.Font = Enum.Font.GothamSemibold
	tl.TextSize = 13
	tl.TextXAlignment = Enum.TextXAlignment.Left
	tl.Parent = hdr

	local cont = Instance.new("Frame")
	cont.Size = UDim2.new(1, 0, 0, 0)
	cont.Position = UDim2.new(0, 0, 0, 32)
	cont.BackgroundTransparency = 1
	cont.ClipsDescendants = true
	cont.Parent = cat

	local lst = Instance.new("UIListLayout")
	lst.Padding = UDim.new(0, 6)
	lst.SortOrder = Enum.SortOrder.LayoutOrder
	lst.Parent = cont
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 10)
	pad.PaddingRight = UDim.new(0, 10)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingTop = UDim.new(0, 4)
	pad.Parent = cont

	local con = {
		Category = cat, Container = cont, Header = hdr,
		Tab = tab, Expanded = true, Name = name,
	}

	local function resize()
		if con.Expanded then
			local ch = lst.AbsoluteContentSize.Y + 12
			cont.Size = UDim2.new(1, 0, 0, ch)
			cat.Size = UDim2.new(1, 0, 0, 32 + ch)
		end
	end

	lst:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)

	hdr.MouseButton1Click:Connect(function()
		con.Expanded = not con.Expanded
		local ch = lst.AbsoluteContentSize.Y + 12
		local targetH = if con.Expanded then ch else 0
		local targetRot = if con.Expanded then 90 else 0
		
		Tween:Create(cont, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, targetH)}):Play()
		Tween:Create(arrow, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Rotation = targetRot}):Play()
		Tween:Create(cat, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 32 + targetH)}):Play()
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

local tabMt = {}
function tabMt:AddCategory(name) return makeCategory(self, name) end
function tabMt:AddLabel(text) return mkLabel(self.Content, text) end
function tabMt:AddDivider() return mkDivider(self.Content) end
function tabMt:AddButton(text, cb) return mkButton(self.Content, text, cb) end
function tabMt:AddToggle(text, opts) return mkToggle(self.Content, text, opts) end
function tabMt:AddInput(text, opts) return mkInput(self.Content, text, opts) end
function tabMt:AddSlider(text, opts) return mkSlider(self.Content, text, opts) end
function tabMt:AddDropdown(text, opts) return mkDropdown(self.Content, text, opts) end
function tabMt:AddColorPicker(text, opts) return mkColorPicker(self.Content, text, opts) end
function tabMt:AddKeybind(text, opts) return mkKeybind(self.Content, text, opts) end

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

function winMt:SetToggleKey(keyCode) self.ToggleKey = keyCode end
function winMt:Build() self:_build() end

function Lib:CreateWindow(opts)
	opts = opts or {}
	local title = opts.Title or "Premium Suite"
	local size = opts.Size or Vector2.new(550, 380)
	local toggleKey = opts.ToggleKey or Enum.KeyCode.RightControl

	local win = setmetatable({
		Title = title, Size = size, ToggleKey = toggleKey,
		SidebarExpanded = true, Tabs = {},
		MainFrame = nil, Sidebar = nil, MainContent = nil, ScreenGui = nil,
		ActiveTab = nil, _mobileBtn = nil,
	}, {__index = winMt})

	win._build = function()
		local gui = Instance.new("ScreenGui")
		gui.Name = "Obsidian_" .. math.random(1000, 9999)
		gui.ResetOnSpawn = false
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.DisplayOrder = 999
		gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		win.ScreenGui = gui

		local mf = Instance.new("Frame")
		mf.Size = UDim2.new(0, size.X, 0, size.Y)
		mf.Position = UDim2.new(0.5, -size.X / 2, 0.5, -size.Y / 2)
		mf.BackgroundColor3 = c.bg
		mf.BorderSizePixel = 0
		mf.Active = true
		mf.Parent = gui
		win.MainFrame = mf
		addCorner(mf, 6)
		addStroke(mf, c.brd)

		local tb = Instance.new("Frame")
		tb.Size = UDim2.new(1, 0, 0, 38)
		tb.BackgroundColor3 = c.dark
		tb.BorderSizePixel = 0
		tb.Parent = mf
		addCorner(tb, 6)

		local gapFill = Instance.new("Frame")
		gapFill.Size = UDim2.new(1, 0, 0, 6)
		gapFill.Position = UDim2.new(0, 0, 1, -6)
		gapFill.BackgroundColor3 = c.dark
		gapFill.BorderSizePixel = 0
		gapFill.Parent = tb

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -80, 1, 0)
		lbl.Position = UDim2.new(0, 38, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = title
		lbl.TextColor3 = c.txt
		lbl.Font = Enum.Font.GothamSemibold
		lbl.TextSize = 14
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = tb

		local x = Instance.new("TextButton")
		x.Size = UDim2.new(0, 38, 0, 38)
		x.Position = UDim2.new(1, 0, 0, 0)
		x.AnchorPoint = Vector2.new(1, 0)
		x.BackgroundTransparency = 1
		x.Text = ">"
		x.TextColor3 = c.dim
		x.Font = Enum.Font.Gotham
		x.TextSize = 14
		x.AutoButtonColor = false
		x.ZIndex = 3
		x.Parent = tb

		local uic = GetIcon("menu")
		local toggle = Instance.new("ImageButton")
		toggle.Size = UDim2.new(0, 22, 0, 22)
		toggle.Position = UDim2.new(0, 8, 0.5, -11)
		toggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		toggle.BackgroundTransparency = 1
		toggle.Image = uic and uic.Url or ""
		if uic then
			toggle.ImageRectSize = uic.ImageRectSize
			toggle.ImageRectOffset = uic.ImageRectOffset
		end
		toggle.ImageColor3 = c.txt
		toggle.ScaleType = Enum.ScaleType.Fit
		toggle.AutoButtonColor = false
		toggle.ZIndex = 10
		toggle.Parent = tb

		local ca = Instance.new("Frame")
		ca.Size = UDim2.new(1, 0, 1, -38)
		ca.Position = UDim2.new(0, 0, 0, 38)
		ca.BackgroundTransparency = 1
		ca.Parent = mf

		local sb = Instance.new("Frame")
		sb.Size = UDim2.new(0, 150, 1, 0)
		sb.BackgroundColor3 = c.darker
		sb.BorderSizePixel = 0
		sb.Parent = ca
		win.Sidebar = sb

		local si = Instance.new("Frame")
		si.Size = UDim2.new(1, -12, 1, -12)
		si.Position = UDim2.new(0, 6, 0, 6)
		si.BackgroundTransparency = 1
		si.Parent = sb

		local sList = Instance.new("UIListLayout")
		sList.Padding = UDim.new(0, 4)
		sList.Parent = si

		local sd = Instance.new("Frame")
		sd.Size = UDim2.new(0, 1, 1, 0)
		sd.Position = UDim2.new(0, 150, 0, 0)
		sd.BackgroundColor3 = c.brd
		sd.BorderSizePixel = 0
		sd.ZIndex = 5
		sd.Parent = ca

		local mc = Instance.new("Frame")
		mc.Size = UDim2.new(1, -151, 1, 0)
		mc.Position = UDim2.new(0, 151, 0, 0)
		mc.BackgroundColor3 = c.bg
		mc.BorderSizePixel = 0
		mc.Parent = ca
		win.MainContent = mc

		for i, tab in ipairs(win.Tabs) do
			local iname = i == 1 and "layers" or "sliders"
			local ia = GetIcon(iname)

			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 32)
			btn.BackgroundColor3 = c.darker
			btn.BorderSizePixel = 0
			btn.Text = ""
			btn.AutoButtonColor = false
			btn.ClipsDescendants = true
			btn.Parent = si
			addCorner(btn, 4)

			local ic = Instance.new("ImageLabel")
			ic.Size = UDim2.new(0, 16, 0, 16)
			-- Adjusted layout scaling behavior for cleaner collapsing states
			ic.Position = UDim2.new(0, 8, 0.5, -8)
			ic.BackgroundTransparency = 1
			ic.Image = ia and ia.Url or ""
			if ia then
				ic.ImageRectSize = ia.ImageRectSize
				ic.ImageRectOffset = ia.ImageRectOffset
			end
			ic.ImageColor3 = c.dim
			ic.ScaleType = Enum.ScaleType.Fit
			ic.Parent = btn

			local tabLbl = Instance.new("TextLabel")
			tabLbl.Size = UDim2.new(1, -32, 1, 0)
			tabLbl.Position = UDim2.new(0, 32, 0, 0)
			tabLbl.BackgroundTransparency = 1
			tabLbl.Text = tab.Name
			tabLbl.TextColor3 = c.dim
			tabLbl.Font = Enum.Font.GothamSemibold
			tabLbl.TextSize = 13
			tabLbl.TextXAlignment = Enum.TextXAlignment.Left
			tabLbl.Parent = btn

			tab.Button = btn; tab.Label = tabLbl; tab.Icon = ic

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
			pp.PaddingTop = UDim.new(0, 10)
			pp.PaddingLeft = UDim.new(0, 10)
			pp.PaddingRight = UDim.new(0, 10)
			pp.PaddingBottom = UDim.new(0, 10)
			pp.Parent = page
			local pl = Instance.new("UIListLayout")
			pl.Padding = UDim.new(0, 6)
			pl.SortOrder = Enum.SortOrder.LayoutOrder
			pl.Parent = page

			tab.Content = page

			for _, cat in ipairs(tab.Categories) do
				if cat.Category and cat.Category.Parent ~= page then
					cat.Category.Parent = page
				end
			end

			btn.MouseEnter:Connect(function() 
				if win.ActiveTab ~= tab then 
					tween(btn, "BackgroundColor3", c.hover) 
				end 
			end)
			btn.MouseLeave:Connect(function()
				if win.ActiveTab ~= tab then 
					tween(btn, "BackgroundColor3", c.darker) 
				end
			end)
			btn.MouseButton1Click:Connect(function()
				if win.ActiveTab then
					tween(win.ActiveTab.Button, "BackgroundColor3", c.darker)
					tween(win.ActiveTab.Label, "TextColor3", c.dim)
					tween(win.ActiveTab.Icon, "ImageColor3", c.dim)
					win.ActiveTab.Content.Visible = false
				end
				win.ActiveTab = tab
				tween(btn, "BackgroundColor3", c.inp)
				tween(tabLbl, "TextColor3", c.acc)
				tween(ic, "ImageColor3", c.acc)
				tab.Content.Visible = true
			end)
		end

		if #win.Tabs > 0 then
			win.ActiveTab = win.Tabs[1]
			win.Tabs[1].Button.BackgroundColor3 = c.inp
			win.Tabs[1].Label.TextColor3 = c.acc
			win.Tabs[1].Icon.ImageColor3 = c.acc
			win.Tabs[1].Content.Visible = true
		end

		local function toggleSidebar(expand)
			win.SidebarExpanded = expand
			local w = if expand then 150 else 36
			sb:TweenSize(UDim2.new(0, w, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
			sd:TweenPosition(UDim2.new(0, w, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
			mc:TweenSizeAndPosition(UDim2.new(1, -(w + 1), 1, 0), UDim2.new(0, w + 1, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
			
			local lt = if expand then 0 else 1
			for _, t in ipairs(win.Tabs) do
				Tween:Create(t.Label, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {TextTransparency = lt}):Play()
				-- Center icons precisely to layout frame grids when sidebar collapses
				local posTarget = if expand then UDim2.new(0, 8, 0.5, -8) else UDim2.new(0.5, -8, 0.5, -8)
				Tween:Create(t.Icon, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Position = posTarget}):Play()
			end
		end

		toggle.MouseButton1Click:Connect(function() toggleSidebar(not win.SidebarExpanded) end)

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

		x.MouseButton1Click:Connect(function() win:Destroy(); Lib.Toggled = false end)
		x.MouseEnter:Connect(function() tween(x, "TextColor3", c.err) end)
		x.MouseLeave:Connect(function() tween(x, "TextColor3", c.dim) end)

		table.insert(Lib.Conns, UIS.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == win.ToggleKey then
				gui.Enabled = not gui.Enabled; Lib.Toggled = gui.Enabled
			end
		end))

		if UIS.TouchEnabled then
			local mb = Instance.new("ImageButton")
			mb.Size = UDim2.new(0, 36, 0, 36)
			mb.Position = UDim2.new(0, 8, 0.5, -18)
			mb.BackgroundColor3 = c.acc
			mb.BorderSizePixel = 0
			mb.Image = uic and uic.Url or ""
			if uic then
				mb.ImageRectSize = uic.ImageRectSize
				mb.ImageRectOffset = uic.ImageRectOffset
			end
			mb.ImageColor3 = Color3.new(1, 1, 1)
			mb.BackgroundTransparency = 0.3
			mb.AutoButtonColor = false
			mb.ZIndex = 100
			mb.Parent = gui
			addCorner(mb, 8)
			win._mobileBtn = mb

			mb.MouseButton1Click:Connect(function()
				local on = not mf.Visible
				mf.Visible = on
				mb.Visible = not on
			end)
			mf.Visible = false
		end

		if Lib._cfg.auto then
			task.spawn(function() task.wait() Lib:LoadConfig() end)
		end
	end

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