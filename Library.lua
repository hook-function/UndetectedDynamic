local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local Http = game:GetService("HttpService")

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
local function tweenBg(obj, color, trans)
	Tween:Create(obj, TInfo, {BackgroundColor3 = color, BackgroundTransparency = trans}):Play()
end

local c = {
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

-- register stateful elements by string id
local function regObj(id, obj)
	if id and id ~= "" then
		Lib.Opts[id] = obj
	end
end

local function setIcon(img, name)
	local a = GetIcon(name)
	if a then
		img.Image = a.Url
		img.ImageRectSize = a.ImageRectSize
		img.ImageRectOffset = a.ImageRectOffset
	end
end

-- Element builders -------------------------------------------------

local function mkLabel(parent, text)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, 20)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = c.dim
	l.Font = Enum.Font.Gotham
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
	co.CornerRadius = UDim.new(0, 4)
	co.Parent = b
	b.MouseEnter:Connect(function() tweenBg(b, c.hover, 0) end)
	b.MouseLeave:Connect(function() tweenBg(b, c.inp, 0) end)
	b.MouseButton1Click:Connect(function() if cb then cb() end end)
	return b
end

local function mkToggle(parent, text, opts)
	opts = opts or {}
	local def = opts.Default or false
	local cb = opts.Callback or function() end
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 28)
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

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(0, 28, 0, 16)
	bg.Position = UDim2.new(1, -28, 0.5, -8)
	bg.BackgroundColor3 = c.sl
	bg.BorderSizePixel = 0
	bg.Parent = row
	local bgC = Instance.new("UICorner")
	bgC.CornerRadius = UDim.new(0, 8)
	bgC.Parent = bg

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.Position = UDim2.new(0, 2, 0.5, -6)
	knob.BackgroundColor3 = c.dim
	knob.BorderSizePixel = 0
	knob.Parent = bg
	local kc = Instance.new("UICorner")
	kc.CornerRadius = UDim.new(0, 6)
	kc.Parent = knob

	local state = def
	local function set(v)
		state = v
		local col = if state then c.acc else c.sl
		local kcol = if state then c.txt else c.dim
		local kp = if state then UDim2.new(1, -14, 0.5, -6) else UDim2.new(0, 2, 0.5, -6)
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
	local ph = opts.Placeholder or ""
	local cb = opts.Callback or function() end
	local num = opts.Numeric or false

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 28)
	row.BackgroundTransparency = 1
	row.Parent = parent

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(0, 80, 1, 0)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = c.txt
	l.Font = Enum.Font.Gotham
	l.TextSize = 13
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = row

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -88, 0, 24)
	box.Position = UDim2.new(1, -8, 0.5, -12)
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
	bc.CornerRadius = UDim.new(0, 4)
	bc.Parent = box

	if num then box.Text = tostring(def) end

	box.FocusLost:Connect(function()
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
	row.Size = UDim2.new(1, 0, 0, 36)
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
	vl.Position = UDim2.new(1, -72, 0, 0)
	vl.BackgroundTransparency = 1
	vl.Text = tostring(def) .. sfx
	vl.TextColor3 = c.txt
	vl.Font = Enum.Font.Gotham
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
	rc.CornerRadius = UDim.new(0, 3)
	rc.Parent = rail

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = c.acc
	fill.BorderSizePixel = 0
	fill.Parent = rail
	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(0, 3)
	fc.Parent = fill

	local k = Instance.new("Frame")
	k.Size = UDim2.new(0, 12, 0, 12)
	k.BackgroundColor3 = c.txt
	k.BorderSizePixel = 0
	k.ZIndex = 2
	k.Parent = row
	local kc = Instance.new("UICorner")
	kc.CornerRadius = UDim.new(0, 6)
	kc.Parent = k

	local val = def
	local dragging = false

	local function update(v)
		val = math.clamp(v, mn, mx)
		local t = (val - mn) / (mx - mn)
		local w = rail.AbsoluteSize.X
		fill.Size = UDim2.new(0, w * t, 1, 0)
		k.Position = UDim2.new(0, rail.AbsolutePosition.X - row.AbsolutePosition.X + w * t - 6, 0.5, -6)
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
	row.Size = UDim2.new(1, 0, 0, 28)
	row.BackgroundTransparency = 1
	row.Parent = parent

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(0, 80, 1, 0)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = c.txt
	l.Font = Enum.Font.Gotham
	l.TextSize = 13
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = row

	local disp = Instance.new("TextButton")
	disp.Size = UDim2.new(1, -88, 0, 24)
	disp.Position = UDim2.new(1, -8, 0.5, -12)
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
	dc.CornerRadius = UDim.new(0, 4)
	dc.Parent = disp

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
	dd.Size = UDim2.new(1, -88, 0, 0)
	dd.Position = UDim2.new(1, -8, 1, 2)
	dd.AnchorPoint = Vector2.new(1, 0)
	dd.BackgroundColor3 = c.darker
	dd.BorderSizePixel = 0
	dd.Visible = false
	dd.ScrollBarThickness = 2
	dd.ScrollBarImageColor3 = c.brd
	dd.AutomaticCanvasSize = Enum.AutomaticSize.Y
	dd.ZIndex = 20
	dd.Parent = row
	local dPad = Instance.new("UIPadding")
	dPad.PaddingTop = UDim.new(0, 2)
	dPad.PaddingBottom = UDim.new(0, 2)
	dPad.Parent = dd
	local dList = Instance.new("UIListLayout")
	dList.Padding = UDim.new(0, 2)
	dList.Parent = dd

	local sel = def

	local function build()
		for _, v in ipairs(dd:GetChildren()) do
			if v:IsA("TextButton") or v:IsA("UIListLayout") or v:IsA("UIPadding") then v:Destroy() end
		end
		local nl = Instance.new("UIListLayout")
		nl.Padding = UDim.new(0, 2)
		nl.Parent = dd
		local np = Instance.new("UIPadding")
		np.PaddingTop = UDim.new(0, 2)
		np.PaddingBottom = UDim.new(0, 2)
		np.Parent = dd
		for _, item in ipairs(items) do
			local ib = Instance.new("TextButton")
			ib.Size = UDim2.new(1, -4, 0, 24)
			ib.Position = UDim2.new(0, 2, 0, 0)
			ib.BackgroundTransparency = 1
			ib.BorderSizePixel = 0
			ib.Text = item
			ib.TextColor3 = c.txt
			ib.Font = Enum.Font.Gotham
			ib.TextSize = 13
			ib.AutoButtonColor = false
			ib.ZIndex = 21
			ib.Parent = dd
			ib.MouseEnter:Connect(function() tweenBg(ib, c.hover, 0) end)
			ib.MouseLeave:Connect(function() tweenBg(ib, c.darker, 1) end)
			ib.MouseButton1Click:Connect(function()
				sel = item; disp.Text = item; dd.Visible = false
				pcall(cb, item)
			end)
		end
		dd.CanvasSize = UDim2.new(0, 0, 0, dList.AbsoluteContentSize.Y)
	end

	build()

	disp.MouseButton1Click:Connect(function()
		dd.Visible = not dd.Visible
		if dd.Visible then
			dd.Size = UDim2.new(1, -88, 0, math.min(dList.AbsoluteContentSize.Y + 4, 150))
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
			) then dd.Visible = false end
		end
	end)

	local obj = {SetValue = function(v) sel = v; disp.Text = v; pcall(cb, v) end, GetValue = function() return sel end}
	regObj(opts.Id or opts.id or text, obj)
	return obj
end

local function mkColorPicker(parent, text, opts)
	opts = opts or {}
	local def = opts.Default or Color3.fromRGB(255, 255, 255)
	local cb = opts.Callback or function() end

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 28)
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
	sw.Size = UDim2.new(0, 22, 0, 22)
	sw.Position = UDim2.new(1, -28, 0.5, -11)
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
		local pk = Instance.new("Frame")
		pk.Size = UDim2.new(0, 180, 0, 160)
		pk.BackgroundColor3 = c.darker
		pk.BorderSizePixel = 0
		pk.ZIndex = 20
		pk.Parent = row
		local pkC = Instance.new("UICorner")
		pkC.CornerRadius = UDim.new(0, 4)
		pkC.Parent = pk
		local pkS = Instance.new("UIStroke")
		pkS.Color = c.brd
		pkS.Parent = pk

		local h, s, v = Color3.toHSV(col)

		local sv = Instance.new("ImageLabel")
		sv.Size = UDim2.new(0, 150, 0, 120)
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
		hb.Size = UDim2.new(0, 150, 0, 12)
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
				local ap = sv.AbsolutePosition; local asz = sv.AbsoluteSize
				s = math.clamp((m.X - ap.X) / asz.X, 0, 1)
				v = 1 - math.clamp((m.Y - ap.Y) / asz.Y, 0, 1)
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
				local ap = hb.AbsolutePosition; local asz = hb.AbsoluteSize
				h = math.clamp((m.X - ap.X) / asz.X, 0, 1)
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
					local ap = sv.AbsolutePosition; local asz = sv.AbsoluteSize
					s = math.clamp((m.X - ap.X) / asz.X, 0, 1)
					v = 1 - math.clamp((m.Y - ap.Y) / asz.Y, 0, 1)
					upd()
				end
				if dh then
					local m = UIS:GetMouseLocation()
					local ap = hb.AbsolutePosition; local asz = hb.AbsoluteSize
					h = math.clamp((m.X - ap.X) / asz.X, 0, 1)
					upd()
				end
			end
		end)

		upd()
	end)

	local obj = {SetValue = function(cl) col = cl; sw.BackgroundColor3 = cl; pcall(cb, cl) end, GetValue = function() return col end}
	regObj(opts.Id or opts.id or text, obj)
	return obj
end

-- Category system ---------------------------------------------------

local function makeCategory(tab, name)
	local page = tab.Content
	local cat = Instance.new("Frame")
	cat.Size = UDim2.new(1, 0, 0, 34)
	cat.BackgroundColor3 = c.darker
	cat.BorderSizePixel = 0
	cat.ClipsDescendants = true
	cat.Parent = page

	local catC = Instance.new("UICorner")
	catC.CornerRadius = UDim.new(0, 4)
	catC.Parent = cat

	local hdr = Instance.new("TextButton")
	hdr.Size = UDim2.new(1, 0, 0, 34)
	hdr.BackgroundTransparency = 1
	hdr.Text = ""
	hdr.AutoButtonColor = false
	hdr.ZIndex = 2
	hdr.Parent = cat

	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.new(0, 20, 0, 34)
	arrow.Position = UDim2.new(0, 8, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text = "▼"
	arrow.TextColor3 = c.dim
	arrow.Font = Enum.Font.Gotham
	arrow.TextSize = 11
	arrow.Parent = hdr

	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.new(1, -36, 1, 0)
	tl.Position = UDim2.new(0, 30, 0, 0)
	tl.BackgroundTransparency = 1
	tl.Text = name
	tl.TextColor3 = c.txt
	tl.Font = Enum.Font.GothamSemibold
	tl.TextSize = 13
	tl.TextXAlignment = Enum.TextXAlignment.Left
	tl.Parent = hdr

	local cont = Instance.new("Frame")
	cont.Size = UDim2.new(1, 0, 0, 0)
	cont.Position = UDim2.new(0, 0, 0, 34)
	cont.BackgroundTransparency = 1
	cont.Parent = cat

	local lst = Instance.new("UIListLayout")
	lst.Padding = UDim.new(0, 4)
	lst.SortOrder = Enum.SortOrder.LayoutOrder
	lst.Parent = cont
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.Parent = cont

	local con = {
		Category = cat, Container = cont, Header = hdr,
		Tab = tab, Expanded = true, Name = name,
	}

	lst:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		local ch = lst.AbsoluteContentSize.Y
		cont.Size = UDim2.new(1, 0, 0, ch)
		if con.Expanded then
			cat.Size = UDim2.new(1, 0, 0, 34 + ch + 8)
		end
	end)

	hdr.MouseButton1Click:Connect(function()
		con.Expanded = not con.Expanded
		local h = if con.Expanded then cont.Size.Y.Offset else 0
		Tween:Create(cont, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Size = UDim2.new(1, 0, 0, h)}):Play()
		Tween:Create(arrow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Rotation = if con.Expanded then 0 else -90}):Play()
		cat.Size = UDim2.new(1, 0, 0, 34 + h + 8)
	end)

	con.AddLabel = function(_, txt) return mkLabel(cont, txt) end
	con.AddDivider = function() return mkDivider(cont) end
	con.AddButton = function(_, txt, fn) return mkButton(cont, txt, fn) end
	con.AddToggle = function(_, txt, o) return mkToggle(cont, txt, o) end
	con.AddInput = function(_, txt, o) return mkInput(cont, txt, o) end
	con.AddSlider = function(_, txt, o) return mkSlider(cont, txt, o) end
	con.AddDropdown = function(_, txt, o) return mkDropdown(cont, txt, o) end
	con.AddColorPicker = function(_, txt, o) return mkColorPicker(cont, txt, o) end

	table.insert(tab.Categories, con)
	return con
end

-- Tab methods -------------------------------------------------------

local tabMt = {}

function tabMt:AddCategory(name)
	return makeCategory(self, name)
end

function tabMt:AddLabel(text)
	return mkLabel(self.Content, text)
end

function tabMt:AddDivider()
	return mkDivider(self.Content)
end

function tabMt:AddButton(text, cb)
	return mkButton(self.Content, text, cb)
end
function tabMt:AddToggle(text, opts)
	return mkToggle(self.Content, text, opts)
end
function tabMt:AddInput(text, opts)
	return mkInput(self.Content, text, opts)
end
function tabMt:AddSlider(text, opts)
	return mkSlider(self.Content, text, opts)
end
function tabMt:AddDropdown(text, opts)
	return mkDropdown(self.Content, text, opts)
end
function tabMt:AddColorPicker(text, opts)
	return mkColorPicker(self.Content, text, opts)
end

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
	self:_build()
end

function Lib:CreateWindow(opts)
	opts = opts or {}
	local title = opts.Title or "Undetected Dynamic"
	local size = opts.Size or Vector2.new(580, 400)
	local toggleKey = opts.ToggleKey or Enum.KeyCode.RightControl

	local win = setmetatable({
		Title = title, Size = size, ToggleKey = toggleKey,
		SidebarExpanded = true, Tabs = {},
		MainFrame = nil, Sidebar = nil, MainContent = nil, ScreenGui = nil,
		ActiveTab = nil, _mobileBtn = nil,
	}, {__index = winMt})

	win._build = function()
		local gui = Instance.new("ScreenGui")
		gui.Name = "UI_" .. math.random(1000, 9999)
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

		local tb = Instance.new("Frame")
		tb.Size = UDim2.new(1, 0, 0, 44)
		tb.BackgroundColor3 = c.dark
		tb.BorderSizePixel = 0
		tb.Parent = mf

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -34, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = title
		lbl.TextColor3 = c.txt
		lbl.Font = Enum.Font.GothamSemibold
		lbl.TextSize = 15
		lbl.TextXAlignment = Enum.TextXAlignment.Center
		lbl.Parent = tb

		local x = Instance.new("TextButton")
		x.Size = UDim2.new(0, 34, 1, 0)
		x.Position = UDim2.new(1, -34, 0, 0)
		x.BackgroundTransparency = 1
		x.Text = "X"
		x.TextColor3 = c.dim
		x.Font = Enum.Font.Gotham
		x.TextSize = 15
		x.AutoButtonColor = false
		x.ZIndex = 3
		x.Parent = tb

		local uic = GetIcon("user")
		local toggle = Instance.new("ImageButton")
		toggle.Size = UDim2.new(0, 32, 0, 32)
		toggle.Position = UDim2.new(0, 8, 0.5, -16)
		toggle.BackgroundColor3 = c.darker
		toggle.BorderSizePixel = 0
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
		local tc = Instance.new("UICorner")
		tc.CornerRadius = UDim.new(0, 4)
		tc.Parent = toggle
		local ts = Instance.new("UIStroke")
		ts.Color = c.brd
		ts.Thickness = 1.5
		ts.Parent = toggle

		local ca = Instance.new("Frame")
		ca.Size = UDim2.new(1, 0, 1, -44)
		ca.Position = UDim2.new(0, 0, 0, 44)
		ca.BackgroundTransparency = 1
		ca.Parent = mf

		local sb = Instance.new("Frame")
		sb.Size = UDim2.new(0, 180, 1, 0)
		sb.BackgroundColor3 = c.darker
		sb.BorderSizePixel = 0
		sb.Parent = ca
		win.Sidebar = sb

		local si = Instance.new("Frame")
		si.Size = UDim2.new(1, -8, 1, -8)
		si.Position = UDim2.new(0, 4, 0, 4)
		si.BackgroundTransparency = 1
		si.Parent = sb

		local sd = Instance.new("Frame")
		sd.Size = UDim2.new(0, 1, 1, 0)
		sd.Position = UDim2.new(0, 180, 0, 0)
		sd.BackgroundColor3 = c.brd
		sd.BorderSizePixel = 0
		sd.ZIndex = 5
		sd.Parent = ca

		local mc = Instance.new("Frame")
		mc.Size = UDim2.new(1, -181, 1, 0)
		mc.Position = UDim2.new(0, 181, 0, 0)
		mc.BackgroundColor3 = c.bg
		mc.BorderSizePixel = 0
		mc.Parent = ca
		win.MainContent = mc

		-- Tab buttons + pages
		for i, tab in ipairs(win.Tabs) do
			local iname = i == 1 and "user" or "cog"
			local ia = GetIcon(iname)

			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 44)
			btn.Position = UDim2.new(0, 0, 0, (i - 1) * 50)
			btn.BackgroundColor3 = c.darker
			btn.BorderSizePixel = 0
			btn.Text = ""
			btn.AutoButtonColor = false
			btn.ClipsDescendants = true
			btn.Parent = si

			local bc = Instance.new("UICorner")
			bc.CornerRadius = UDim.new(0, 4)
			bc.Parent = btn

			local ic = Instance.new("ImageLabel")
			ic.Size = UDim2.new(0, 24, 0, 24)
			ic.Position = UDim2.new(0, 6, 0.5, -12)
			ic.BackgroundColor3 = c.darker
			ic.BorderSizePixel = 0
			ic.Image = ia and ia.Url or ""
			if ia then
				ic.ImageRectSize = ia.ImageRectSize
				ic.ImageRectOffset = ia.ImageRectOffset
			end
			ic.ImageColor3 = c.txt
			ic.ScaleType = Enum.ScaleType.Fit
			ic.Parent = btn
			local icC = Instance.new("UICorner")
			icC.CornerRadius = UDim.new(0, 4)
			icC.Parent = ic
			local icS = Instance.new("UIStroke")
			icS.Color = c.brd
			icS.Thickness = 1
			icS.Parent = ic

			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, -40, 1, 0)
			lbl.Position = UDim2.new(0, 40, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = tab.Name
			lbl.TextColor3 = c.txt
			lbl.Font = Enum.Font.GothamSemibold
			lbl.TextSize = 14
			lbl.TextXAlignment = Enum.TextXAlignment.Center
			lbl.Parent = btn

			tab.Button = btn; tab.Label = lbl; tab.Icon = ic

			local page = Instance.new("ScrollingFrame")
			page.Size = UDim2.new(1, 0, 1, 0)
			page.BackgroundTransparency = 1
			page.Visible = false
			page.BorderSizePixel = 0
			page.Parent = mc
			page.ScrollBarThickness = 3
			page.ScrollBarImageColor3 = c.brd
			page.AutomaticCanvasSize = Enum.AutomaticSize.Y
			page.CanvasSize = UDim2.new(0, 0, 0, 0)

			local pp = Instance.new("UIPadding")
			pp.PaddingTop = UDim.new(0, 8)
			pp.PaddingLeft = UDim.new(0, 8)
			pp.PaddingRight = UDim.new(0, 8)
			pp.Parent = page

			tab.Content = page

			-- reparent categories created before Build
			for _, cat in ipairs(tab.Categories) do
				if cat.Category and cat.Category.Parent ~= page then
					cat.Category.Parent = page
				end
			end

			btn.MouseEnter:Connect(function() tweenBg(btn, c.hover, 0) end)
			btn.MouseLeave:Connect(function()
				if win.ActiveTab ~= tab then tweenBg(btn, c.darker, 0) end
			end)
			btn.MouseButton1Click:Connect(function()
				if win.ActiveTab then
					tweenBg(win.ActiveTab.Button, c.darker, 0)
					win.ActiveTab.Content.Visible = false
				end
				win.ActiveTab = tab
				tweenBg(btn, c.acc, 0)
				tab.Content.Visible = true
			end)
		end

		if #win.Tabs > 0 then
			win.ActiveTab = win.Tabs[1]
			win.Tabs[1].Button.BackgroundColor3 = c.acc
			win.Tabs[1].Content.Visible = true
		end

		-- Sidebar collapse
		local function toggleSidebar(expand)
			win.SidebarExpanded = expand
			local w = if expand then 180 else 48
			sb:TweenSize(UDim2.new(0, w, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
			toggle:TweenPosition(UDim2.new(0, if expand then 8 else (w - 32) / 2, 0.5, -16),
				Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
			sd:TweenPosition(UDim2.new(0, w, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
			mc:TweenSizeAndPosition(UDim2.new(1, -(w + 1), 1, 0), UDim2.new(0, w + 1, 0, 0),
				Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
			local lt = if expand then 0 else 1
			for _, t in ipairs(win.Tabs) do
				Tween:Create(t.Label, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{TextTransparency = lt}):Play()
			end
		end

		toggle.MouseButton1Click:Connect(function()
			toggleSidebar(not win.SidebarExpanded)
		end)

		-- Dragging
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
				mf.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
					startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end))

		x.MouseButton1Click:Connect(function()
			win:Destroy(); Lib.Toggled = false
		end)
		x.MouseEnter:Connect(function()
			x.BackgroundColor3 = c.err
			x.TextColor3 = Color3.fromRGB(255, 255, 255)
		end)
		x.MouseLeave:Connect(function()
			x.BackgroundTransparency = 1
			x.TextColor3 = c.dim
		end)

		-- toggle keybind
		table.insert(Lib.Conns, UIS.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == win.ToggleKey then
				gui.Enabled = not gui.Enabled; Lib.Toggled = gui.Enabled
			end
		end))

		-- Mobile: floating toggle button
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
			local mbC = Instance.new("UICorner")
			mbC.CornerRadius = UDim.new(0, 8)
			mbC.Parent = mb
			win._mobileBtn = mb

			mb.MouseButton1Click:Connect(function()
				local on = not mf.Visible
				mf.Visible = on
				mb.Visible = not on
			end)
			mf.Visible = false
		end

		if Lib._cfg.auto then
			task.spawn(function()
				task.wait()
				Lib:LoadConfig()
			end)
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
