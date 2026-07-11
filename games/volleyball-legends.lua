repeat task.wait() until game:IsLoaded()
-- v4
getgenv().VL_version = (getgenv().VL_version or 0) + 1
local scriptVer = getgenv().VL_version

local okInit, errInit = pcall(function()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local lp = Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local Knit = require(rs.Packages.Knit)
local plrGui = lp:WaitForChild("PlayerGui")

for _, c in pairs(plrGui:GetChildren()) do
    if c:IsA("ScreenGui") and (c.Name == "Undetected Dynamic - Volleyball Legends" or c.Name == "UDVL" or c.Name == "UDVLNotifs") then c:Destroy() end
end

local c = {
    bg = Color3.fromRGB(15, 15, 18),
    surface = Color3.fromRGB(22, 22, 28),
    gb = Color3.fromRGB(38, 38, 46),
    header = Color3.fromRGB(24, 24, 30),
    acc = Color3.fromRGB(108, 120, 255),
    hover = Color3.fromRGB(48, 48, 56),
    txt = Color3.fromRGB(215, 215, 225),
    dim = Color3.fromRGB(130, 130, 140),
    brd = Color3.fromRGB(45, 45, 52),
    sl = Color3.fromRGB(50, 50, 60),
    red = Color3.fromRGB(235, 70, 70),
    tabInactive = Color3.fromRGB(100, 100, 110),
}

local colorKeys = {"bg","surface","gb","header","acc","hover","txt","dim","brd","sl","red","tabInactive"}
local colorDefaults = {}
for _, k in pairs(colorKeys) do colorDefaults[k] = c[k] end

local sg = Instance.new("ScreenGui")
sg.Name = "Undetected Dynamic - Volleyball Legends"
sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
sg.DisplayOrder = 999
sg.ResetOnSpawn = false
sg.Parent = plrGui

-- notification gui
local notifSg = Instance.new("ScreenGui")
notifSg.Name = "UDVLNotifs"
notifSg.ZIndexBehavior = Enum.ZIndexBehavior.Global
notifSg.DisplayOrder = 1000
notifSg.ResetOnSpawn = false
notifSg.Parent = plrGui
local toggles = {}

local options = {}

local colorPickers = {}
local switchKey = Enum.KeyCode.Insert
local serveKey = Enum.KeyCode.RightBracket
local toruKey = Enum.KeyCode.T
local notifEnabled = true
local notifSide = "Right"
local notifList = {}

local function restackAll()
    local sx = notifSg.AbsoluteSize.X
    if sx == 0 then sx = 800 end
    local side = notifSide == "Right"
    local targetX = side and (sx - 270) or 10
    local y = 10
    for _, n in pairs(notifList) do
        n:TweenPosition(UDim2.fromOffset(targetX, y), "Out", "Quad", 0.3, true)
        y = y + n.AbsoluteSize.Y + 6
    end
end

local function notify(text, dur)
    if not notifEnabled then return end
    dur = dur or 3
    local sx = notifSg.AbsoluteSize.X
    if sx == 0 then sx = 800 end
    local side = notifSide == "Right"
    local offX = side and (sx + 20) or -280

    local n = Instance.new("Frame")
    n.Size = UDim2.new(0, 260, 0, 34)
    n.BackgroundColor3 = c.gb
    n.BorderSizePixel = 1
    n.BorderColor3 = c.brd
    n.Parent = notifSg
    Instance.new("UICorner", n).CornerRadius = UDim.new(0, 4)
    local a = Instance.new("Frame")
    a.Size = UDim2.new(0, 2, 1, -4)
    a.Position = UDim2.new(0, 2, 0, 2)
    a.BackgroundColor3 = c.acc
    a.BorderSizePixel = 0
    a.Parent = n
    local l = Instance.new("TextLabel")
    l.Text = text
    l.TextSize = 13
    l.TextColor3 = c.txt
    l.Font = Enum.Font.Gotham
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, -10, 1, 0)
    l.Position = UDim2.new(0, 8, 0, 0)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = n

    table.insert(notifList, n)
    n.Position = UDim2.fromOffset(offX, 10)

    task.spawn(function()
        task.wait(0.05)
        restackAll()
        task.wait(dur)
        n:TweenPosition(UDim2.fromOffset(offX, n.AbsolutePosition.Y), "Out", "Quad", 0.3, true)
        task.wait(0.3)
        n:Destroy()
        for i = #notifList, 1, -1 do
            if notifList[i] == n then table.remove(notifList, i); break end
        end
        restackAll()
    end)
end

-- window
local W, H = 620, 440
local win = Instance.new("Frame")
win.Size = UDim2.new(0, W, 0, H)
win.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
win.BackgroundColor3 = c.bg
win.BorderSizePixel = 0
win.ClipsDescendants = true
win.Parent = sg

local closePanel = nil
local function showClosePanel()
    if closePanel then pcall(function() closePanel:Destroy() end); closePanel = nil end
    local ol = Instance.new("Frame")
    ol.Size = UDim2.new(1, 0, 1, 0)
    ol.BackgroundColor3 = Color3.new(0,0,0)
    ol.BackgroundTransparency = 0.35
    ol.BorderSizePixel = 0
    ol.ZIndex = 1000
    ol.Parent = win

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 340, 0, 150)
    box.Position = UDim2.new(0.5, -170, 0.5, -75)
    box.BackgroundColor3 = c.gb
    box.BackgroundTransparency = 0
    box.BorderSizePixel = 1
    box.BorderColor3 = c.acc
    box.ZIndex = 1001
    box.Parent = ol
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

    local hdrBar = Instance.new("Frame")
    hdrBar.Size = UDim2.new(1, 0, 0, 32)
    hdrBar.BackgroundColor3 = c.header
    hdrBar.BorderSizePixel = 0
    hdrBar.ZIndex = 1001
    hdrBar.Parent = box
    Instance.new("UICorner", hdrBar).CornerRadius = UDim.new(0, 8)
    local hdrClip = Instance.new("UICorner")
    hdrClip.CornerRadius = UDim.new(0, 8)
    hdrClip.Parent = box
    local hdrFill = Instance.new("Frame")
    hdrFill.Size = UDim2.new(1, 0, 0, 4)
    hdrFill.Position = UDim2.new(0, 0, 0, 28)
    hdrFill.BackgroundColor3 = c.header
    hdrFill.BorderSizePixel = 0
    hdrFill.ZIndex = 1001
    hdrFill.Parent = box

    local hdrTxt = Instance.new("TextLabel")
    hdrTxt.Size = UDim2.new(1, -12, 1, 0)
    hdrTxt.Position = UDim2.new(0, 12, 0, 0)
    hdrTxt.BackgroundTransparency = 1
    hdrTxt.Text = "Close?"
    hdrTxt.TextColor3 = c.txt
    hdrTxt.TextSize = 15
    hdrTxt.Font = Enum.Font.Gotham
    hdrTxt.TextXAlignment = Enum.TextXAlignment.Left
    hdrTxt.TextYAlignment = Enum.TextYAlignment.Center
    hdrTxt.ZIndex = 1001
    hdrTxt.Parent = hdrBar

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -24, 0, 36)
    sub.Position = UDim2.new(0, 12, 0, 42)
    sub.BackgroundTransparency = 1
    sub.Text = "Don't forget to save your config!"
    sub.TextColor3 = c.dim
    sub.TextSize = 13
    sub.Font = Enum.Font.Gotham
    sub.TextWrapped = true
    sub.TextXAlignment = Enum.TextXAlignment.Center
    sub.TextYAlignment = Enum.TextYAlignment.Center
    sub.ZIndex = 1001
    sub.Parent = box

    local btnRow = Instance.new("Frame")
    btnRow.Size = UDim2.new(1, -16, 0, 32)
    btnRow.Position = UDim2.new(0, 8, 0, 90)
    btnRow.BackgroundTransparency = 1
    btnRow.ZIndex = 1001
    btnRow.Parent = box

    local btnList = Instance.new("UIListLayout")
    btnList.FillDirection = Enum.FillDirection.Horizontal
    btnList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    btnList.SortOrder = Enum.SortOrder.LayoutOrder
    btnList.Padding = UDim.new(0, 8)
    btnList.Parent = btnRow

    local closeAction = nil
    local function mkBtn3(text, width, action, cb)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, width, 0, 30)
        btn.Text = text
        btn.TextSize = 13
        btn.TextColor3 = c.txt
        btn.BackgroundColor3 = c.surface
        btn.BorderSizePixel = 1
        btn.BorderColor3 = c.brd
        btn.Font = Enum.Font.Gotham
        btn.ZIndex = 1002
        btn.Parent = btnRow
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = c.hover end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = c.surface end)
        btn.MouseButton1Click:Connect(function()
            if cb then cb() end
            closeAction = action
            pcall(function() ol:Destroy() end)
            if closeAction == "destroy" then pcall(function() sg:Destroy() end) end
            closePanel = nil
        end)
        return btn
    end

    mkBtn3("Save and Close", 100, "destroy", function()
        local n = cfgInput.Value:match("^%s*(.-)%s*$") or "config"
        writeConfig(n, readToggleData())
    end)

    mkBtn3("Close", 70, "destroy", nil)

    mkBtn3("Cancel", 70, nil, nil)

    closePanel = ol
end

-- title bar
local tb = Instance.new("Frame")
tb.Size = UDim2.new(1, 0, 0, 30)
tb.BackgroundColor3 = c.header
tb.BorderSizePixel = 0
tb.Parent = win

local ttl = Instance.new("TextLabel")
ttl.Text = "Undetected Dynamic - Volleyball Legends"
ttl.TextSize = 15
ttl.TextColor3 = c.txt
ttl.Font = Enum.Font.Gotham
ttl.BackgroundTransparency = 1
ttl.Size = UDim2.new(1, -50, 1, 0)
ttl.Position = UDim2.new(0, 12, 0, 0)
ttl.Parent = tb

local al = Instance.new("Frame")
al.Size = UDim2.new(1, 0, 0, 2)
al.Position = UDim2.new(0, 0, 1, 0)
al.BackgroundColor3 = c.acc
al.BorderSizePixel = 0
al.Parent = tb

local function kill()
    for _, child in pairs(plrGui:GetChildren()) do
        if child:IsA("ScreenGui") and (child.Name == "Undetected Dynamic - Volleyball Legends" or child.Name == "UDVL" or child.Name == "UDVLNotifs") then
            child:Destroy()
        end
    end
end
getgenv()._VLkill = kill

local cx = Instance.new("TextButton")
cx.Size = UDim2.new(0, 28, 0, 28)
cx.Position = UDim2.new(1, -32, 0, 1)
cx.Text = "X"
cx.TextSize = 15
cx.TextColor3 = c.dim
cx.BackgroundTransparency = 1
cx.Font = Enum.Font.Gotham
cx.Parent = tb
cx.MouseEnter:Connect(function() cx.TextColor3 = c.red end)
cx.MouseLeave:Connect(function() cx.TextColor3 = c.dim end)
cx.MouseButton1Click:Connect(function()
    if win.Visible then
        showClosePanel()
    end
end)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -60, 0, 1)
minBtn.Text = "-"
minBtn.TextSize = 18
minBtn.TextColor3 = c.dim
minBtn.BackgroundTransparency = 1
minBtn.Font = Enum.Font.Gotham
minBtn.Parent = tb

local minFloat = Instance.new("TextButton")
minFloat.Size = UDim2.new(0, 38, 0, 36)
minFloat.Position = UDim2.new(0.5, -19, 1, -50)
minFloat.Text = "UD"
minFloat.TextSize = 14
minFloat.TextColor3 = Color3.new(1,1,1)
minFloat.BackgroundColor3 = c.bg
minFloat.Font = Enum.Font.GothamBold
minFloat.BorderSizePixel = 0
minFloat.Visible = false
minFloat.ZIndex = 200
minFloat.Parent = sg
Instance.new("UICorner", minFloat).CornerRadius = UDim.new(0, 6)

minBtn.MouseButton1Click:Connect(function()
    win.Visible = false; minFloat.Visible = true
end)
minFloat.MouseButton1Click:Connect(function()
    win.Visible = true; minFloat.Visible = false
end)

local fDrag
minFloat.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        local d = Vector2.new(UserInputService:GetMouseLocation().X - minFloat.AbsolutePosition.X, UserInputService:GetMouseLocation().Y - minFloat.AbsolutePosition.Y)
        fDrag = RunService.RenderStepped:Connect(function()
            minFloat.Position = UDim2.fromOffset(UserInputService:GetMouseLocation().X - d.X, UserInputService:GetMouseLocation().Y - d.Y)
        end)
    end
end)
minFloat.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 and fDrag then
        fDrag:Disconnect(); fDrag = nil
    end
end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == switchKey then
        if sg.Parent == nil then return end
        win.Visible = not win.Visible
        minFloat.Visible = not win.Visible
    end
end)

local drag
tb.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        local d = Vector2.new(UserInputService:GetMouseLocation().X - win.AbsolutePosition.X, UserInputService:GetMouseLocation().Y - win.AbsolutePosition.Y)
        drag = RunService.RenderStepped:Connect(function()
            win.Position = UDim2.fromOffset(UserInputService:GetMouseLocation().X - d.X, UserInputService:GetMouseLocation().Y - d.Y)
        end)
    end
end)
tb.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 and drag then
        drag:Disconnect(); drag = nil
    end
end)

-- tab bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 28)
tabBar.Position = UDim2.new(0, 0, 0, 30)
tabBar.BackgroundColor3 = c.surface
tabBar.BorderSizePixel = 0
tabBar.Parent = win

local tabList = Instance.new("UIListLayout")
tabList.FillDirection = Enum.FillDirection.Horizontal
tabList.Padding = UDim.new(0, 0)
tabList.SortOrder = Enum.SortOrder.LayoutOrder
tabList.Parent = tabBar

local tabPad = Instance.new("UIPadding")
tabPad.PaddingLeft = UDim.new(0, 4)
tabPad.Parent = tabBar

-- content
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -58)
content.Position = UDim2.new(0, 0, 0, 58)
content.BackgroundTransparency = 1
content.Parent = win

local tabs = {}
local tabButtons = {}
local activeTab = nil

local function makeTab(name)
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = content

    local leftCont = Instance.new("Frame")
    leftCont.Size = UDim2.new(0.5, -2, 1, 0)
    leftCont.BackgroundTransparency = 1
    leftCont.Parent = page

    local leftScroll = Instance.new("ScrollingFrame")
    leftScroll.Size = UDim2.new(1, 0, 1, 0)
    leftScroll.BackgroundTransparency = 1
    leftScroll.BorderSizePixel = 0
    leftScroll.ScrollBarThickness = 4
    leftScroll.ScrollBarImageColor3 = c.acc
    leftScroll.ScrollBarImageTransparency = 0.4
    leftScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    leftScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    leftScroll.Parent = leftCont

    local leftLay = Instance.new("UIListLayout")
    leftLay.Padding = UDim.new(0, 4)
    leftLay.SortOrder = Enum.SortOrder.LayoutOrder
    leftLay.Parent = leftScroll
    local leftPad = Instance.new("UIPadding")
    leftPad.PaddingTop = UDim.new(0, 4)
    leftPad.PaddingLeft = UDim.new(0, 4)
    leftPad.PaddingRight = UDim.new(0, 2)
    leftPad.Parent = leftScroll

    local rightCont = Instance.new("Frame")
    rightCont.Size = UDim2.new(0.5, -2, 1, 0)
    rightCont.Position = UDim2.new(0.5, 2, 0, 0)
    rightCont.BackgroundTransparency = 1
    rightCont.Parent = page

    local rightScroll = Instance.new("ScrollingFrame")
    rightScroll.Size = UDim2.new(1, 0, 1, 0)
    rightScroll.BackgroundTransparency = 1
    rightScroll.BorderSizePixel = 0
    rightScroll.ScrollBarThickness = 4
    rightScroll.ScrollBarImageColor3 = c.acc
    rightScroll.ScrollBarImageTransparency = 0.4
    rightScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    rightScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    rightScroll.Parent = rightCont

    local rightLay = Instance.new("UIListLayout")
    rightLay.Padding = UDim.new(0, 4)
    rightLay.SortOrder = Enum.SortOrder.LayoutOrder
    rightLay.Parent = rightScroll
    local rightPad = Instance.new("UIPadding")
    rightPad.PaddingTop = UDim.new(0, 4)
    rightPad.PaddingLeft = UDim.new(0, 2)
    rightPad.PaddingRight = UDim.new(0, 4)
    rightPad.Parent = rightScroll

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 0, 1, 0)
    btn.AutomaticSize = Enum.AutomaticSize.X
    btn.Text = "  " .. name .. "  "
    btn.TextSize = 13
    btn.TextColor3 = c.tabInactive
    btn.BackgroundTransparency = 1
    btn.Font = Enum.Font.Gotham
    btn.LayoutOrder = #tabs
    btn.Parent = tabBar

    local tab = {
        page = page, btn = btn, name = name,
        leftScroll = leftScroll, rightScroll = rightScroll,
        leftGroupboxes = {}, rightGroupboxes = {},
    }

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.page.Visible = t.name == name
            tabButtons[t.name].TextColor3 = t.name == name and c.acc or c.tabInactive
            tabButtons[t.name].TextSize = t.name == name and 14 or 13
        end
        activeTab = name
    end)
    btn.MouseEnter:Connect(function()
        if activeTab ~= name then btn.TextColor3 = c.txt end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab ~= name then btn.TextColor3 = c.tabInactive end
    end)

    table.insert(tabs, tab)
    tabButtons[name] = btn

    if #tabs == 1 then
        page.Visible = true
        btn.TextColor3 = c.acc
        btn.TextSize = 14
        activeTab = name
    end

    -- groupbox factory
    local function makeGb(scroll)
        local gb = Instance.new("Frame")
        gb.Size = UDim2.new(1, 0, 0, 30)
        gb.BackgroundColor3 = c.gb
        gb.BorderSizePixel = 1
        gb.BorderColor3 = c.brd
        gb.ClipsDescendants = true
        gb.Parent = scroll
        Instance.new("UICorner", gb).CornerRadius = UDim.new(0, 4)

        local hdr = Instance.new("TextButton")
        hdr.Size = UDim2.new(1, 0, 0, 22)
        hdr.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
        hdr.Text = ""
        hdr.Parent = gb
        local hdrLine = Instance.new("Frame")
        hdrLine.Size = UDim2.new(1, -4, 0, 1)
        hdrLine.Position = UDim2.new(0, 2, 1, -1)
        hdrLine.BackgroundColor3 = c.brd
        hdrLine.BorderSizePixel = 0
        hdrLine.Parent = hdr

        local accBar = Instance.new("Frame")
        accBar.Size = UDim2.new(0, 2, 0, 0)
        accBar.Position = UDim2.new(0, 2, 0, 2)
        accBar.BackgroundColor3 = c.acc
        accBar.BorderSizePixel = 0
        accBar.Parent = hdr
        local accBarH = Instance.new("UIAspectRatioConstraint", accBar)
        accBarH.AspectRatio = 0.1

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Text = ""
        titleLbl.TextSize = 13
        titleLbl.TextColor3 = c.txt
        titleLbl.Font = Enum.Font.Gotham
        titleLbl.BackgroundTransparency = 1
        titleLbl.Size = UDim2.new(1, -10, 1, 0)
        titleLbl.Position = UDim2.new(0, 8, 0, 0)
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Parent = hdr

        local arrow = Instance.new("TextLabel")
        arrow.Text = "v"
        arrow.TextSize = 13
        arrow.TextColor3 = c.dim
        arrow.Font = Enum.Font.Gotham
        arrow.BackgroundTransparency = 1
        arrow.Size = UDim2.new(0, 16, 1, 0)
        arrow.Position = UDim2.new(1, -18, 0, 0)
        arrow.TextXAlignment = Enum.TextXAlignment.Center
        arrow.Parent = hdr

        local collapsed = false

        local ca = Instance.new("Frame")
        ca.Size = UDim2.new(1, 0, 0, 0)
        ca.Position = UDim2.new(0, 0, 0, 22)
        ca.BackgroundTransparency = 1
        ca.Parent = gb

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 2)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = ca
        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 2)
        pad.PaddingLeft = UDim.new(0, 8)
        pad.PaddingRight = UDim.new(0, 4)
        pad.PaddingBottom = UDim.new(0, 4)
        pad.Parent = ca

        local gbObj = { frame = gb, ca = ca, layout = layout, elements = {}, titleLbl = titleLbl, accBar = accBar, hdr = hdr, hdrLine = hdrLine, collapsed = false }

        function gbObj:Resize(animated)
            local targetH, targetCaH
            if self.collapsed then
                targetH = 22
                targetCaH = 0
            else
                local h = layout.AbsoluteContentSize.Y + 28
                if h < 30 then h = 30 end
                targetH = h
                targetCaH = targetH - 22
            end
            if animated then
                local ti = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tg = TweenService:Create(gb, ti, {Size = UDim2.new(1, 0, 0, targetH)})
                local tgCa
                if self.collapsed then
                    tgCa = TweenService:Create(ca, ti, {Size = UDim2.new(1, 0, 0, 0)})
                else
                    tgCa = TweenService:Create(ca, ti, {Size = UDim2.new(1, 0, 1, -22)})
                end
                tg:Play(); tgCa:Play()
            else
                gb.Size = UDim2.new(1, 0, 0, targetH)
                if self.collapsed then
                    ca.Size = UDim2.new(1, 0, 0, 0)
                else
                    ca.Size = UDim2.new(1, 0, 1, -22)
                end
            end
            local sf = gb.Parent
            if sf and sf:IsA("ScrollingFrame") then
                local l2 = sf:FindFirstChildOfClass("UIListLayout")
                if l2 then
                    task.delay(animated and 0.2 or 0, function()
                        sf.CanvasSize = UDim2.new(0, 0, 0, l2.AbsoluteContentSize.Y + 8)
                    end)
                end
            end
        end

        hdr.MouseButton1Click:Connect(function()
            collapsed = not collapsed
            gbObj.collapsed = collapsed
            ca.Visible = not collapsed
            local ti = TweenInfo.new(0.15, Enum.EasingStyle.Linear)
            TweenService:Create(arrow, ti, {Rotation = collapsed and -90 or 0}):Play()
            gbObj:Resize(true)
        end)
        hdr.MouseEnter:Connect(function() hdr.BackgroundColor3 = Color3.fromRGB(36, 36, 44) end)
        hdr.MouseLeave:Connect(function() hdr.BackgroundColor3 = Color3.fromRGB(26, 26, 34) end)

        function gbObj:AddToggle(idx, opts)
            opts = opts or {}
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 20)
            row.BackgroundTransparency = 1
            row.Parent = ca
            row.LayoutOrder = #gbObj.elements

            local lbl = Instance.new("TextLabel")
            lbl.Text = opts.Text or idx
            lbl.TextSize = 13
            lbl.TextColor3 = c.txt
            lbl.Font = Enum.Font.Gotham
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, -32, 1, 0)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row

            local on = opts.Default == true
            local sw = Instance.new("Frame")
            sw.Size = UDim2.new(0, 26, 0, 12)
            sw.Position = UDim2.new(1, -28, 0.5, -6)
            sw.BackgroundColor3 = on and c.acc or c.sl
            sw.BorderSizePixel = 0
            sw.Parent = row
            Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 8, 0, 8)
            knob.Position = UDim2.new(on and 1 or 0, on and -9 or 2, 0.5, -4)
            knob.BackgroundColor3 = Color3.new(1,1,1)
            knob.BorderSizePixel = 0
            knob.Parent = sw
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local obj = { Value = on, row = row, sw = sw, knob = knob }
            function obj:SetValue(v)
                on = v; self.Value = v
                sw.BackgroundColor3 = on and c.acc or c.sl
                knob:TweenPosition(UDim2.new(on and 1 or 0, on and -9 or 2, 0.5, -4), "Out", "Quad", 0.12, true)
                if opts.Callback then opts.Callback(v) end
            end

            local click = Instance.new("TextButton")
            click.Size = UDim2.new(1, 0, 1, 0)
            click.Text = ""
            click.BackgroundTransparency = 1
            click.Parent = row
            click.MouseButton1Click:Connect(function() obj:SetValue(not on) end)

            toggles[idx] = obj
            gbObj.elements[#gbObj.elements+1] = obj
            gbObj:Resize()
            return obj
        end

        function gbObj:AddSlider(idx, opts)
            opts = opts or {}
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 28)
            row.BackgroundTransparency = 1
            row.Parent = ca
            row.LayoutOrder = #gbObj.elements

            local lbl = Instance.new("TextLabel")
            lbl.Text = opts.Text or idx
            lbl.TextSize = 13
            lbl.TextColor3 = c.txt
            lbl.Font = Enum.Font.Gotham
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, -50, 0, 14)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row

            local valLbl = Instance.new("TextLabel")
            valLbl.Text = tostring(opts.Default or opts.Min or 0)
            valLbl.TextSize = 12
            valLbl.TextColor3 = c.dim
            valLbl.Font = Enum.Font.Gotham
            valLbl.BackgroundTransparency = 1
            valLbl.Size = UDim2.new(0, 44, 0, 14)
            valLbl.Position = UDim2.new(1, -46, 0, 0)
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = row

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -4, 0, 3)
            track.Position = UDim2.new(0, 0, 0, 22)
            track.BackgroundColor3 = c.sl
            track.BorderSizePixel = 0
            track.Parent = row
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(0, 0, 1, 0)
            fill.BackgroundColor3 = c.acc
            fill.BorderSizePixel = 0
            fill.Parent = track
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
            local knob2 = Instance.new("Frame")
            knob2.Size = UDim2.new(0, 6, 0, 6)
            knob2.Position = UDim2.new(0, -3, 0.5, -3)
            knob2.BackgroundColor3 = Color3.new(1,1,1)
            knob2.BorderSizePixel = 0
            knob2.Parent = track
            Instance.new("UICorner", knob2).CornerRadius = UDim.new(1, 0)

            local min = opts.Min or 0; local max = opts.Max or 100; local rounding = opts.Rounding or 1
            local decimal = opts.Decimal or (1 / (10^rounding))
            local val = opts.Default or min
            local suffix = opts.Suffix or ""

            local obj = { Value = val }
            local function updateDisplay()
                local display = string.format("%." .. rounding .. "f", val)
                valLbl.Text = display .. suffix
                local pct = (val - min) / (max - min)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                knob2.Position = UDim2.new(pct, -3, 0.5, -3)
            end
            function obj:SetValue(v)
                val = math.clamp(v, min, max)
                self.Value = val; updateDisplay()
                if opts.Callback then opts.Callback(val) end
            end
            updateDisplay()

            local dragging = false
            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    local conn
                    conn = RunService.RenderStepped:Connect(function()
                        if not dragging then conn:Disconnect() return end
                        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                            dragging = false; conn:Disconnect()
                            if opts.Finished then opts.Finished(val) end
                            return
                        end
                        local mx = UserInputService:GetMouseLocation().X
                        local ax = track.AbsolutePosition.X; local aw = track.AbsoluteSize.X
                        local pct = math.clamp((mx - ax) / aw, 0, 1)
                        local steps = 1 / decimal
                        val = math.round((min + pct * (max - min)) * steps) / steps
                        val = math.clamp(val, min, max)
                        obj.Value = val; updateDisplay()
                        if opts.Callback then opts.Callback(val) end
                    end)
                end
            end)

            options[idx] = obj
            gbObj.elements[#gbObj.elements+1] = obj
            gbObj:Resize()
            return obj
        end

        function gbObj:AddDropdown(idx, opts)
            opts = opts or {}
            local multi = opts.Multi == true
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 22)
            row.BackgroundTransparency = 1
            row.Parent = ca
            row.LayoutOrder = #gbObj.elements

            local lbl = Instance.new("TextLabel")
            lbl.Text = opts.Text or idx
            lbl.TextSize = 13
            lbl.TextColor3 = c.txt
            lbl.Font = Enum.Font.Gotham
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(0.5, -4, 1, 0)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row

            local values = opts.Values or {}
            local selected = {}
            if multi then
                if type(opts.Default) == "table" then
                    for k in pairs(opts.Default) do selected[k] = true end
                end
            else
                local defIdx = type(opts.Default) == "number" and opts.Default or (#values > 0 and 1 or nil)
                if defIdx then selected[values[defIdx]] = true end
            end
            if next(selected) == nil and #values > 0 then
                selected[values[1]] = true
            end

            local disp = Instance.new("TextButton")
            disp.Size = UDim2.new(0.5, -2, 0, 18)
            disp.Position = UDim2.new(0.5, 2, 0, 2)
            disp.Text = ""
            disp.BackgroundColor3 = c.surface
            disp.BorderSizePixel = 1
            disp.BorderColor3 = c.brd
            disp.Parent = row
            Instance.new("UICorner", disp).CornerRadius = UDim.new(0, 3)
            local dispLbl = Instance.new("TextLabel")
            dispLbl.Text = ""
            dispLbl.TextSize = 12
            dispLbl.TextColor3 = c.txt
            dispLbl.Font = Enum.Font.Gotham
            dispLbl.BackgroundTransparency = 1
            dispLbl.Size = UDim2.new(1, -6, 1, 0)
            dispLbl.Position = UDim2.new(0, 4, 0, 0)
            dispLbl.TextXAlignment = Enum.TextXAlignment.Left
            dispLbl.Parent = disp

            local ddFrame = Instance.new("Frame")
            ddFrame.Size = UDim2.new(0.5, -2, 0, 0)
            ddFrame.Position = UDim2.new(0.5, 2, 0, 20)
            ddFrame.BackgroundColor3 = c.surface
            ddFrame.BorderSizePixel = 1
            ddFrame.BorderColor3 = c.brd
            ddFrame.Visible = false
            ddFrame.ClipsDescendants = true
            ddFrame.ZIndex = 100
            ddFrame.Parent = row
            Instance.new("UICorner", ddFrame).CornerRadius = UDim.new(0, 3)
            local ddScroll = Instance.new("ScrollingFrame")
            ddScroll.Size = UDim2.new(1, 0, 1, 0)
            ddScroll.BackgroundTransparency = 1
            ddScroll.BorderSizePixel = 0
            ddScroll.ScrollBarThickness = 3
            ddScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            ddScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            ddScroll.ScrollingDirection = Enum.ScrollingDirection.Y
            ddScroll.ZIndex = 100
            ddScroll.Parent = ddFrame
            local ddList = Instance.new("UIListLayout")
            ddList.Padding = UDim.new(0, 0)
            ddList.SortOrder = Enum.SortOrder.LayoutOrder
            ddList.Parent = ddScroll

            local obj = { Value = selected }
            local function updateDisplay()
                local names = {}
                for v, active in pairs(selected) do
                    if active then names[#names+1] = v end
                end
                dispLbl.Text = #names > 0 and table.concat(names, ", ") or "---"
                if opts.Callback then
                    opts.Callback(multi and selected or (next(selected) and next(selected) or nil))
                end
            end

            local ddParentOrig = row
            local function showDropdown()
                local w = disp.AbsoluteSize.X
                local pos = disp.AbsolutePosition
                local h = math.min(#values * 18, 120)
                ddFrame.Size = UDim2.fromOffset(w, h)
                ddFrame.Position = UDim2.fromOffset(pos.X, pos.Y + disp.AbsoluteSize.Y)
                ddFrame.Parent = sg
                ddFrame.Visible = true
                ddFrame.ZIndex = 100
                for _, child in pairs(ddFrame:GetDescendants()) do
                    if child:IsA("GuiObject") then child.ZIndex = 100 end
                end
            end
            local function hideDropdown()
                ddFrame.Parent = ddParentOrig
                ddFrame.Visible = false
            end
            local function rebuildItems()
                for _, child in pairs(ddScroll:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for _, v in pairs(values) do
                    local itm = Instance.new("TextButton")
                    itm.Size = UDim2.new(1, 0, 0, 18)
                    itm.Text = "  " .. (selected[v] and "> " or "  ") .. v
                    itm.TextSize = 12
                    itm.TextColor3 = selected[v] and c.acc or c.txt
                    itm.BackgroundTransparency = 1
                    itm.Font = Enum.Font.Gotham
                    itm.TextXAlignment = Enum.TextXAlignment.Left
                    itm.Parent = ddScroll
                    itm.MouseEnter:Connect(function() itm.BackgroundTransparency = 0.85 end)
                    itm.MouseLeave:Connect(function() itm.BackgroundTransparency = 1 end)
                    itm.MouseButton1Click:Connect(function()
                        if multi then
                            selected[v] = not selected[v]
                            if not selected[v] then selected[v] = nil end
                        else
                            for k in pairs(selected) do selected[k] = nil end
                            selected[v] = true
                        end
                        updateDisplay(); rebuildItems(); showDropdown()
                    end)
                end
            end
            local function rebuildList()
                rebuildItems(); showDropdown()
            end

            disp.MouseButton1Click:Connect(function()
                if ddFrame.Visible then hideDropdown() else rebuildList() end
            end)

            updateDisplay()
            function obj:Refresh(newValues)
                if newValues then values = newValues; obj.values = values end
                if not multi then
                    for k in pairs(selected) do selected[k] = nil end
                    if #values > 0 then selected[values[1]] = true end
                end
                updateDisplay()
                rebuildItems()
            end
            options[idx] = obj
            gbObj.elements[#gbObj.elements+1] = obj
            gbObj:Resize()
            return obj
        end

        function gbObj:AddButton(opts)
            if type(opts) == "function" then opts = { Text = "Button", Func = opts } end
            opts = opts or {}
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -4, 0, 22)
            btn.Text = opts.Text or "Button"
            btn.TextSize = 13
            btn.TextColor3 = c.txt
            btn.BackgroundColor3 = c.surface
            btn.BorderSizePixel = 1
            btn.BorderColor3 = c.brd
            btn.Font = Enum.Font.Gotham
            btn.TextXAlignment = Enum.TextXAlignment.Center
            btn.Parent = ca
            btn.LayoutOrder = #gbObj.elements
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
            btn.MouseEnter:Connect(function() btn.BackgroundColor3 = c.hover end)
            btn.MouseLeave:Connect(function() btn.BackgroundColor3 = c.surface end)
            if opts.DoubleClick then
                btn.MouseButton1Click:Connect(function()
                    btn.Text = "Confirm?"
                    task.delay(0.5, function() btn.Text = opts.Text or "Button" end)
                end)
            else
                btn.MouseButton1Click:Connect(function()
                    if opts.Func then opts.Func() end
                end)
            end
            gbObj.elements[#gbObj.elements+1] = btn
            gbObj:Resize()
            return btn
        end

        function gbObj:AddLabel(text, wrap)
            local lbl = Instance.new("TextLabel")
            lbl.Text = text or ""
            lbl.TextSize = 12
            lbl.TextColor3 = c.dim
            lbl.Font = Enum.Font.Gotham
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, -4, 0, 16)
            lbl.TextWrapped = wrap == true
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = ca
            lbl.LayoutOrder = #gbObj.elements
            gbObj.elements[#gbObj.elements+1] = lbl
            gbObj:Resize()
            return lbl
        end

        function gbObj:AddInput(opts)
            opts = opts or {}
            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, -4, 0, 22)
            box.Text = opts.Default or ""
            box.TextSize = 13
            box.TextColor3 = c.txt
            box.BackgroundColor3 = c.surface
            box.BorderColor3 = c.brd
            box.BorderSizePixel = 1
            box.Font = Enum.Font.GothamMedium
            box.PlaceholderText = opts.Placeholder or ""
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.ClearTextOnFocus = false
            box.Parent = ca
            box.LayoutOrder = #gbObj.elements
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 3)
            local obj = { Value = opts.Default or "", box = box }
            box.FocusLost:Connect(function(enter)
                obj.Value = box.Text
                if opts.Callback then opts.Callback(box.Text, enter) end
            end)
            gbObj.elements[#gbObj.elements+1] = box
            gbObj:Resize()
            return obj
        end

        function gbObj:AddKeybind(idx, opts)
            opts = opts or {}
            local key = opts.Default or Enum.KeyCode.Insert
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 20)
            row.BackgroundTransparency = 1
            row.Parent = ca
            row.LayoutOrder = #gbObj.elements

            local lbl = Instance.new("TextLabel")
            lbl.Text = opts.Text or idx
            lbl.TextSize = 13
            lbl.TextColor3 = c.txt
            lbl.Font = Enum.Font.Gotham
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, -70, 1, 0)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 56, 0, 16)
            btn.Position = UDim2.new(1, -58, 0.5, -8)
            btn.Text = key.Name
            btn.TextSize = 11
            btn.TextColor3 = c.txt
            btn.BackgroundColor3 = c.surface
            btn.BorderSizePixel = 1
            btn.BorderColor3 = c.brd
            btn.Font = Enum.Font.GothamMedium
            btn.Parent = row
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)

            local listening = false
            local obj = { Value = key, _callback = opts.Callback }
            function obj:SetValue(v)
                self.Value = v; key = v
                btn.Text = v.Name
                if self._callback then task.spawn(self._callback, v) end
            end
            btn.MouseButton1Click:Connect(function()
                if listening then return end
                listening = true
                btn.Text = "..."
                btn.TextColor3 = c.acc
                local conn
                conn = UserInputService.InputBegan:Connect(function(input, gpe)
                    if gpe then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        key = input.KeyCode
                        obj.Value = key
                        btn.Text = key.Name
                        btn.TextColor3 = c.txt
                        conn:Disconnect()
                        if opts.Callback then opts.Callback(key) end
                    end
                end)
            end)

            options[idx] = obj
            gbObj.elements[#gbObj.elements+1] = row
            gbObj:Resize()
            return obj
        end

        function gbObj:AddDivider()
            local div = Instance.new("Frame")
            div.Size = UDim2.new(1, -8, 0, 1)
            div.BackgroundColor3 = c.brd
            div.BorderSizePixel = 0
            div.Parent = ca
            div.LayoutOrder = #gbObj.elements
            gbObj.elements[#gbObj.elements+1] = div
            gbObj:Resize()
            return div
        end

        function gbObj:AddColorPicker(idx, opts)
            opts = opts or {}
            local label = opts.Text or idx
            local default = opts.Default or Color3.new(1,1,1)
            local cb = opts.Callback or function() end

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 26)
            row.BackgroundTransparency = 1
            row.Parent = ca
            row.LayoutOrder = #gbObj.elements

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -34, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = label
            lbl.TextColor3 = c.txt
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row

            local swatch = Instance.new("ImageButton")
            swatch.Size = UDim2.new(0, 22, 0, 22)
            swatch.Position = UDim2.new(1, -28, 0.5, -11)
            swatch.BackgroundColor3 = default
            swatch.BorderSizePixel = 0
            swatch.AutoButtonColor = false
            swatch.Parent = row
            Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 4)
            local sws = Instance.new("UIStroke", swatch)
            sws.Color = c.brd; sws.Thickness = 1

            local col = default
            swatch.MouseButton1Click:Connect(function()
                local pk = Instance.new("Frame")
                pk.Size = UDim2.new(0, 180, 0, 160)
                pk.BackgroundColor3 = c.gb
                pk.BorderSizePixel = 0; pk.ZIndex = 20
                pk.Parent = row
                Instance.new("UICorner", pk).CornerRadius = UDim.new(0, 4)
                local pks = Instance.new("UIStroke", pk)
                pks.Color = c.brd

                local h, s, v = Color3.toHSV(col)

                local sv = Instance.new("ImageLabel")
                sv.Size = UDim2.new(0, 150, 0, 120)
                sv.Position = UDim2.new(0, 8, 0, 8)
                sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                sv.Image = "rbxassetid://4155801252"
                sv.ZIndex = 21; sv.Parent = pk

                local cur = Instance.new("Frame")
                cur.Size = UDim2.new(0, 8, 0, 8)
                cur.BackgroundColor3 = Color3.new(1,1,1)
                cur.BorderSizePixel = 1; cur.BorderColor3 = Color3.new(0,0,0)
                cur.Active = false
                cur.ZIndex = 22; cur.Parent = sv
                Instance.new("UICorner", cur).CornerRadius = UDim.new(1, 0)

                local hb = Instance.new("Frame")
                hb.Size = UDim2.new(0, 150, 0, 12)
                hb.Position = UDim2.new(0, 8, 0, 134)
                hb.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
                hb.BorderSizePixel = 0
                hb.ZIndex = 21; hb.Parent = pk
                for i = 0, 29 do
                    local seg = Instance.new("Frame")
                    seg.Size = UDim2.new(0, 5, 1, 0)
                    seg.Position = UDim2.new(0, i*5, 0, 0)
                    seg.BorderSizePixel = 0
                    seg.Active = false
                    seg.BackgroundColor3 = Color3.fromHSV(i/29, 1, 1)
                    seg.ZIndex = 22; seg.Parent = hb
                end

                local hc = Instance.new("Frame")
                hc.Size = UDim2.new(0, 4, 1, 2)
                hc.BackgroundColor3 = Color3.new(1,1,1)
                hc.BorderSizePixel = 1; hc.BorderColor3 = Color3.new(0,0,0)
                hc.Active = false
                hc.ZIndex = 23; hc.Parent = hb

                local function upd()
                    local cl = Color3.fromHSV(h, s, v)
                    col = cl; swatch.BackgroundColor3 = cl
                    sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    cur.Position = UDim2.new(s, -4, 1-v, -4)
                    hc.Position = UDim2.new(h, -2, 0, -1)
                    pcall(cb, cl)
                end

                local ds, dh, dragConn
                local function dragUpdate()
                    if ds then
                        local m = UserInputService:GetMouseLocation()
                        local ap = sv.AbsolutePosition; local asz = sv.AbsoluteSize
                        s = math.clamp((m.X - ap.X) / asz.X, 0, 1)
                        v = 1 - math.clamp((m.Y - ap.Y) / asz.Y, 0, 1)
                        upd()
                    end
                    if dh then
                        local m = UserInputService:GetMouseLocation()
                        local ap = hb.AbsolutePosition; local asz = hb.AbsoluteSize
                        h = math.clamp((m.X - ap.X) / asz.X, 0, 1)
                        upd()
                    end
                end
                sv.InputBegan:Connect(function(inp)
                    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                    ds = true; dragUpdate()
                    if not dragConn then
                        dragConn = RunService.RenderStepped:Connect(dragUpdate)
                    end
                end)
                sv.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then ds = false end
                end)
                hb.InputBegan:Connect(function(inp)
                    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                    dh = true; dragUpdate()
                    if not dragConn then
                        dragConn = RunService.RenderStepped:Connect(dragUpdate)
                    end
                end)
                hb.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dh = false end
                end)
                local cleanup = pk.Destroying:Connect(function()
                    if dragConn then dragConn:Disconnect(); dragConn = nil end
                end)
                upd()

                local bgoff = false
                local bgconn = UserInputService.InputBegan:Connect(function(inp, gpe)
                    if gpe or inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                    local m = UserInputService:GetMouseLocation(); local ap = pk.AbsolutePosition; local sz = pk.AbsoluteSize
                    if m.X < ap.X or m.X > ap.X+sz.X or m.Y < ap.Y or m.Y > ap.Y+sz.Y then bgoff = true end
                end)
                local bgrel = UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 and bgoff then
                        pk:Destroy(); bgconn:Disconnect(); bgrel:Disconnect()
                    end
                    bgoff = false
                end)
            end)

            local obj = { Value = col, _cb = cb }
            function obj:SetValue(cl)
                col = cl; obj.Value = cl; swatch.BackgroundColor3 = cl
                pcall(cb, cl)
            end
            function obj:GetValue() return col end

            colorPickers[idx] = obj
            gbObj.elements[#gbObj.elements+1] = row
            gbObj:Resize()
            return obj
        end

        function gbObj:SetTitle(text)
            titleLbl.Text = text
        end

        gbObj:Resize()
        return gbObj
    end

    function tab:AddLeftGroupbox(title)
        local gb = makeGb(leftScroll)
        gb:SetTitle(title)
        table.insert(self.leftGroupboxes, gb)
        return gb
    end
    function tab:AddRightGroupbox(title)
        local gb = makeGb(rightScroll)
        gb:SetTitle(title)
        table.insert(self.rightGroupboxes, gb)
        return gb
    end

    return tab
end

-- Safe controller getter
local function getController(name)
    local ok, ctrl = pcall(function() return Knit.GetController(name) end)
    return ok and ctrl
end
local function getService(name)
    local ok, svc = pcall(function() return Knit.GetService(name) end)
    return ok and svc
end
local function ballHitboxLoop()
    local hb = RunService.Heartbeat
    local bc, hitboxPart
    while true do
        hb:Wait()
        local enabled = toggles.HitboxToggle and toggles.HitboxToggle.Value
        if not bc then bc = getController("BallController") end
        local ball
        if bc then
            local activeId = rs:GetAttribute("ActiveBall")
            if activeId then
                local bd = bc.ActiveBalls[activeId]
                if bd and bd.Ball then ball = bd.Ball end
            end
        end
        if not ball then
            ball = workspace:FindFirstChild("Ball") or workspace:FindFirstChild("GameBall") or workspace:FindFirstChild("Volleyball")
        end
        if not enabled or not ball then
            if hitboxPart then hitboxPart:Destroy(); hitboxPart = nil end
            continue
        end
        local pp = ball:IsA("Model") and ball.PrimaryPart or (ball:IsA("BasePart") and ball)
        if not pp then continue end
        if not hitboxPart then
            hitboxPart = Instance.new("Part")
            hitboxPart.Name = "VLHitbox"
            hitboxPart.Shape = Enum.PartType.Ball
            hitboxPart.Anchored = true
            hitboxPart.CanCollide = false
            hitboxPart.CanTouch = true
            hitboxPart.Material = Enum.Material.ForceField
            hitboxPart.Parent = workspace
        end
        local scale = (options.HitboxScale and options.HitboxScale.Value) or 5
        local transp = (options.HitboxTransparency and options.HitboxTransparency.Value) or 0.65
        if hitboxPart.Size.X ~= scale then
            hitboxPart.Size = Vector3.new(scale, scale, scale)
        end
        hitboxPart.Transparency = transp
        hitboxPart.CFrame = pp.CFrame
    end
end

local function unlockCharLoop()
    while true do
        task.wait()
        local enabled = toggles.UnlockChar and toggles.UnlockChar.Value
        if not enabled then break end
        local char = lp.Character; if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and (hum:GetState() == Enum.HumanoidStateType.Jumping or hum:GetState() == Enum.HumanoidStateType.Freefall) then
            hum.AutoRotate = true
        end
    end
end

local function airRedirectLoop()
    local bv
    while true do
        RunService.Heartbeat:Wait()
        local enabled = toggles.AirRedirect and toggles.AirRedirect.Value
        if not enabled then if bv then bv:Destroy() end; break end
        local char = lp.Character; if not char then if bv then bv:Destroy() bv = nil end; continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then if bv then bv:Destroy() bv = nil end; continue end
        local st = hum:GetState()
        if st ~= Enum.HumanoidStateType.Jumping and st ~= Enum.HumanoidStateType.Freefall then
            if bv then bv:Destroy() bv = nil end; continue
        end
        local md = hum.MoveDirection
        if md.Magnitude > 0.01 then
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.P = 12500; bv.MaxForce = Vector3.new(math.huge, 0, math.huge)
                bv.Parent = hrp
            end
            local speed = (options.AirRedirectSpeed and options.AirRedirectSpeed.Value) or 50
            bv.Velocity = Vector3.new(md.X * speed, hrp.Velocity.Y, md.Z * speed)
        elseif bv then
            bv:Destroy(); bv = nil
        end
    end
end

local function fireBtn(btn)
    if not btn then return end
    firesignal(btn.MouseButton1Click, btn)
    task.wait()
    firesignal(btn.Activated, btn)
end

local function getOptVal(t)
    local v = t and t.Value or {}
    return next(v) or nil
end

local function autoReceiveLoop()
    local ic
    while true do
        task.wait()
        local enabled = toggles.AutoReceive and toggles.AutoReceive.Value
        if not enabled then break end
        local char = lp.Character; if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
        local ball = workspace:FindFirstChild("Ball"); if not ball then continue end
        local dist = (ball.Position - hrp.Position).Magnitude
        local setDist = (options.AutoSetDistance and options.AutoSetDistance.Value) or 15
        local diveDist = (options.AutoDiveDistance and options.AutoDiveDistance.Value) or 25
        if not ic then ic = getController("InputController") end
        if ic then
            if dist < setDist then
                ic:PerformAction("Set", Enum.UserInputState.Begin)
            elseif dist < diveDist then
                ic:PerformAction("Dive", Enum.UserInputState.Begin)
            end
        end
    end
end

local function infiniteJumpLoop()
    local bv, jumpedThisPress
    local jumpConn = UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        if inp.KeyCode == Enum.KeyCode.Space then
            jumpedThisPress = false
        end
    end)
    while true do
        RunService.Heartbeat:Wait()
        local enabled = toggles.InfiniteJump and toggles.InfiniteJump.Value
        if not enabled then
            if bv then bv:Destroy(); bv = nil end
            if jumpConn then jumpConn:Disconnect(); jumpConn = nil end
            break
        end
        local char = lp.Character; if not char then if bv then bv:Destroy(); bv = nil end; continue end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then if bv then bv:Destroy(); bv = nil end; continue end
        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then if bv then bv:Destroy(); bv = nil end; continue end
        local st = hum:GetState()
        local spaceDown = UserInputService:IsKeyDown(Enum.KeyCode.Space)
        if spaceDown and (st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.Jumping) and not jumpedThisPress then
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.P = 12500
                bv.MaxForce = Vector3.new(0, math.huge, 0)
                bv.Velocity = Vector3.new(0, 50, 0)
                bv.Parent = hrp
            end
            bv.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
            jumpedThisPress = true
        elseif not spaceDown then
            jumpedThisPress = false
            if bv then bv:Destroy(); bv = nil end
        end
    end
end

local function tpwalkLoop()
    local conn
    while true do
        task.wait()
        local enabled = toggles.WalkSpeedToggle and toggles.WalkSpeedToggle.Value
        if not enabled then
            if conn then conn:Disconnect(); conn = nil end
            local c = lp.Character
            if c then
                local h = c:FindFirstChildOfClass("Humanoid")
                if h then h.WalkSpeed = 16 end
            end
            break
        end
        local char = lp.Character; if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then continue end
        if not conn then
            conn = RunService.Heartbeat:Connect(function()
                if not toggles.WalkSpeedToggle or not toggles.WalkSpeedToggle.Value then return end
                local c = lp.Character; if not c then return end
                local h = c:FindFirstChildOfClass("Humanoid")
                if not h then return end
                local spd = (options.WalkSpeed and options.WalkSpeed.Value) or 16
                h.WalkSpeed = spd
            end)
        end
    end
end

local function jumpPowerLoop()
    local bv
    while true do
        RunService.Heartbeat:Wait()
        local enabled = toggles.JumpPowerToggle and toggles.JumpPowerToggle.Value
        if not enabled then
            if bv then bv:Destroy(); bv = nil end
            break
        end
        local char = lp.Character; if not char then if bv then bv:Destroy(); bv = nil end; continue end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then if bv then bv:Destroy(); bv = nil end; continue end
        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then if bv then bv:Destroy(); bv = nil end; continue end
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Jumping then
            local power = (options.JumpPower and options.JumpPower.Value) or 50
            local targetVy = math.sqrt(2 * workspace.Gravity * power)
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.P = 12500
                bv.MaxForce = Vector3.new(0, math.huge, 0)
                bv.Velocity = Vector3.new(0, targetVy, 0)
                bv.Parent = hrp
            end
            bv.Velocity = Vector3.new(hrp.Velocity.X, targetVy, hrp.Velocity.Z)
        else
            if bv then bv:Destroy(); bv = nil end
        end
    end
end

local function bypassLowSpikeLoop()
    local rfirst = game:GetService("ReplicatedFirst")
    local Handlers
    while true do
        RunService.Heartbeat:Wait()
        if not (toggles.BypassLowSpike and toggles.BypassLowSpike.Value) then break end
        local char = lp.Character; if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then continue end
        local ball = workspace:FindFirstChild("Ball")
        if not ball then continue end
        local pp = ball:IsA("Model") and ball.PrimaryPart or (ball:IsA("BasePart") and ball)
        if not pp then continue end
        local dist = (pp.Position - char:GetPivot().Position).Magnitude
        if dist > 35 then continue end
        if not Handlers then
            local ok, h = pcall(function() return require(rfirst.Controllers.GameController.Handlers) end)
            if ok then Handlers = h end
        end
        if Handlers and Handlers.States then
            pcall(function() Handlers.States.IsBusy:set(false) end)
            pcall(function() Handlers.States.IsStunned:set(false) end)
        end
        if hum:GetState() ~= Enum.HumanoidStateType.Jumping and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

local function setDiveBoost(val)
    local ok, State = pcall(function() return require(rs.Common.State) end)
    if not ok then return end
    local mid = State.Id and State.Id.Multiplier
    if mid then State.set(lp, mid, "DiveSpeed", val) end
end

local function noCDFactory(toggleName)
    local rfirst = game:GetService("ReplicatedFirst")
    local Handlers
    return function()
        while true do
            RunService.Heartbeat:Wait()
            local en = toggles[toggleName] and toggles[toggleName].Value
            if not en then break end
            lp:SetAttribute("Context_SpawnCooldown", nil)
            lp:SetAttribute("Context_ServeCooldown", nil)
            if not Handlers then
                local ok, h = pcall(function() return require(rfirst.Controllers.GameController.Handlers) end)
                if ok then Handlers = h end
            end
            if Handlers and Handlers.States and Handlers.States.IsBusy then
                Handlers.States.IsBusy:set(false)
            end
        end
    end
end

local function jumpSetAimbotLoop()
    local rfirst = game:GetService("ReplicatedFirst")
    local Handlers
    while true do
        RunService.Heartbeat:Wait()
        local enabled = toggles.JumpSetAimbot and toggles.JumpSetAimbot.Value
        if not enabled then break end
        local char = lp.Character; if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then continue end
        if hum:GetState() ~= Enum.HumanoidStateType.Jumping and hum:GetState() ~= Enum.HumanoidStateType.Freefall then continue end
        if not Handlers then
            local ok, h = pcall(function() return require(rfirst.Controllers.GameController.Handlers) end)
            if ok then Handlers = h end
        end
        if not Handlers then continue end
        local nearest, bestDist, bestVel
        local team = lp.Team
        for _, pl in pairs(Players:GetPlayers()) do
            if pl ~= lp and pl.Team == team then
                local c = pl.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                if r then
                    local d = (r.Position - hrp.Position).Magnitude
                    if not bestDist or d < bestDist then
                        bestDist = d; nearest = r; bestVel = c and c:FindFirstChildOfClass("Humanoid") and c:FindFirstChildOfClass("Humanoid").RootPart and c:FindFirstChildOfClass("Humanoid").RootPart.Velocity or Vector3.new()
                    end
                end
            end
        end
        if not nearest then continue end
        local pred = (options.JumpSetPrediction and options.JumpSetPrediction.Value) or 0
        local lead = pred > 0 and (bestDist / 20) * pred or 0
        local targetPos = nearest.Position + bestVel * lead
        local dir = (targetPos - hrp.Position) * Vector3.new(1, 0, 1)
        if dir.Magnitude > 0.5 then
            Handlers.Values.TiltDirection = dir.Unit + Vector3.new(0, 1, 0)
        end
    end
end

local function spikeAimbotLoop()
    local rfirst = game:GetService("ReplicatedFirst")
    local Handlers
    local spiked = false
    while true do
        RunService.Heartbeat:Wait()
        local enabled = toggles.SpikeAimbot and toggles.SpikeAimbot.Value
        if not enabled then break end
        local char = lp.Character; if not char then spiked = false; continue end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then spiked = false; continue end
        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then spiked = false; continue end
        if hum:GetState() ~= Enum.HumanoidStateType.Jumping and hum:GetState() ~= Enum.HumanoidStateType.Freefall then spiked = false; continue end
        local ic = getController("InputController")
        if not ic then continue end
        if not spiked then
            local floor = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("BallNoCollide") and workspace.Map.BallNoCollide:FindFirstChild("Floor")
            local net = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("BallNoCollide") and workspace.Map.BallNoCollide:FindFirstChild("Net")
            if not floor or not net then continue end
            local netZ = net.Position.Z
            local halfCourt = floor.Size.Z / 2
            local oppDir = hrp.Position.Z > netZ and -1 or 1
            local pts = {
                {X = floor.Position.X + oppDir * 10, Z = netZ + oppDir * halfCourt * 0.85},
                {X = floor.Position.X - oppDir * 10, Z = netZ + oppDir * halfCourt * 0.85},
                {X = floor.Position.X, Z = netZ + oppDir * halfCourt * 0.85},
                {X = floor.Position.X + oppDir * 10, Z = netZ + oppDir * halfCourt * 0.4},
                {X = floor.Position.X - oppDir * 10, Z = netZ + oppDir * halfCourt * 0.4},
            }
            local bestScore, bestTarget
            for _, pt in pairs(pts) do
                local minDistToOpp = math.huge
                for _, pl in pairs(Players:GetPlayers()) do
                    if pl ~= lp and pl.Team ~= lp.Team then
                        local r = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
                        if r then
                            local d = (Vector3.new(pt.X, r.Position.Y, pt.Z) - r.Position).Magnitude
                            if d < minDistToOpp then minDistToOpp = d end
                        end
                    end
                end
                if minDistToOpp > (bestScore or 0) then
                    bestScore = minDistToOpp; bestTarget = pt
                end
            end
            if bestTarget then
                hum.AutoRotate = true
                local targetDir = (Vector3.new(bestTarget.X, hrp.Position.Y, bestTarget.Z) - hrp.Position) * Vector3.new(1, 0, 1)
                if targetDir.Magnitude > 0.5 then
                    if not Handlers then
                        local ok, h = pcall(function() return require(rfirst.Controllers.GameController.Handlers) end)
                        if ok then Handlers = h end
                    end
                    if Handlers then
                        Handlers.Values.TiltDirection = targetDir.Unit + Vector3.new(0, 1, 0)
                    end
                end
            end
            local ball = workspace:FindFirstChild("Ball")
            if not ball then continue end
            local pp = ball:IsA("Model") and ball.PrimaryPart or (ball:IsA("BasePart") and ball)
            if pp and (pp.Position - hrp.Position).Magnitude < 25 then
                ic:PerformAction("Spike", Enum.UserInputState.Begin)
                task.wait(0.05)
                ic:PerformAction("Spike", Enum.UserInputState.End)
                spiked = true
            end
        else
            if hum:GetState() ~= Enum.HumanoidStateType.Jumping and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                spiked = false
            end
        end
    end
end

local function doPowerfulServe()
    local inputCtrl = getController("InputController")
    if not inputCtrl then return end
    local gameCtrl = getController("GameController")
    inputCtrl:PerformAction("Ultimate", Enum.UserInputState.Begin)
    task.wait(0.1)
    if gameCtrl and gameCtrl.Charge then
        pcall(function() gameCtrl.Charge:set(1) end)
    end
    task.wait(0.15)
    inputCtrl:PerformAction("Ultimate", Enum.UserInputState.End)
    inputCtrl:PerformAction("Spike", Enum.UserInputState.Begin)
    RunService.Heartbeat:Wait()
    inputCtrl:PerformAction("Spike", Enum.UserInputState.End)
end

-- Style Modifiers
local function doToruServe()
    local ic = getController("InputController")
    if not ic then return end
    local State = require(rs.Common.State)
    ic:PerformAction("Toss", Enum.UserInputState.Begin)
    local tossT = tick()
    while tick() - tossT < 0.6 do
        RunService.Heartbeat:Wait()
        local ball = workspace:FindFirstChild("Ball")
        if ball then
            local pp = ball:IsA("Model") and ball.PrimaryPart or (ball:IsA("BasePart") and ball)
            if pp and pp.Velocity.Y < 0 and pp.Velocity.Y > -5 then break end
        end
    end
    State.set(lp, State.Id.Special, "Charge", 10000)
    ic:PerformAction("Ultimate", Enum.UserInputState.Begin)
    RunService.Heartbeat:Wait()
    ic:PerformAction("Ultimate", Enum.UserInputState.End)
    notify("Timeskip Okazu Super Toss")
end

local function shoyoModifier()
    local State = require(rs.Common.State)
    while true do
        RunService.Heartbeat:Wait()
        if not (toggles.ShoyoMod and toggles.ShoyoMod.Value) then break end
        local char = lp.Character; if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then continue end
        local md = hum.MoveDirection
        if md.Magnitude > 0 or hum:GetState() == Enum.HumanoidStateType.Jumping then
            State.set(lp, State.Id.Special, "Charge", 10000)
        end
    end
end

local function kuraiModifier()
    local State = require(rs.Common.State)
    while true do
        RunService.Heartbeat:Wait()
        if not (toggles.KuraiMod and toggles.KuraiMod.Value) then break end
        local char = lp.Character; if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then continue end
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Jumping or st == Enum.HumanoidStateType.Freefall then
            State.set(lp, State.Id.Special, "Charge", 10000)
            local ic = getController("InputController")
            if ic then
                ic:PerformAction("Ultimate", Enum.UserInputState.Begin)
                task.wait(0.05)
                ic:PerformAction("Ultimate", Enum.UserInputState.End)
            end
        end
    end
end

local function kijoModifier()
    local rfirst = game:GetService("ReplicatedFirst")
    local Handlers
    local State = require(rs.Common.State)
    local side = "Left"
    while true do
        RunService.Heartbeat:Wait()
        if not (toggles.KijoMod and toggles.KijoMod.Value) then break end
        local char = lp.Character; if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then continue end
        local st = hum:GetState()
        if st ~= Enum.HumanoidStateType.Jumping and st ~= Enum.HumanoidStateType.Freefall then continue end
        local ball = workspace:FindFirstChild("Ball")
        if not ball then continue end
        local pp = ball:IsA("Model") and ball.PrimaryPart or (ball:IsA("BasePart") and ball)
        if not pp or (pp.Position - hrp.Position).Magnitude > 35 then continue end
        if not Handlers then
            local ok, h = pcall(function() return require(rfirst.Controllers.GameController.Handlers) end)
            if ok then Handlers = h end
        end
        if not Handlers then continue end
        State.set(lp, State.Id.Special, "Charge", 10000)
        local kijoData = options.KijoModSide
        side = kijoData and kijoData.Value or "Left"
        local right = hrp.CFrame.RightVector * Vector3.new(1, 0, 1)
        if right.Magnitude > 0.01 then
            right = right.Unit
            if side == "Left" then right = -right end
            Handlers.Values.TiltDirection = Vector3.new(right.X, 1, right.Z)
        end
    end
end

-- Auto Play
local function autoPlayLoop()
    local playCD = 0
    while true do
        task.wait(0.1)
        if getgenv().VL_version ~= scriptVer then break end
        if not (toggles.AutoPlay and toggles.AutoPlay.Value) then break end
        local int = plrGui:FindFirstChild("Interface")
        if not int then continue end
        local lobby = int:FindFirstChild("Lobby")
        if not lobby then continue end
        local gm = lobby:FindFirstChild("Gamemodes")
        local ss = int:FindFirstChild("SlotSelect")
        local ts = int:FindFirstChild("TeamSelection")
        local gf = int:FindFirstChild("Game")
        playCD = playCD - 0.1

        if gf and gf.Visible then
        elseif ss and ss.Visible then
            local targetSlot = getOptVal(options.AutoPlaySlot) or "Any"
            for _, c in pairs(ss:GetDescendants()) do
                if c:IsA("ImageButton") and c.Visible then
                    local slotNum = tonumber(c.Name)
                    if targetSlot ~= "Any" and slotNum ~= tonumber(targetSlot) then continue end
                    local slotFree = true
                    for _, t in pairs(c:GetDescendants()) do
                        if t:IsA("TextLabel") and t.Text:find("@") then slotFree = false; break end
                    end
                    if slotFree then fireBtn(c); break end
                end
            end
        elseif ts and ts.Visible then
            local team = getOptVal(options.AutoPlayTeam) or "Home"
            local targetSlot = getOptVal(options.AutoPlaySlot) or "Any"
            local teamFrame = ts:FindFirstChild(team == "Home" and "1" or "2")
            if teamFrame then
                local th = teamFrame:FindFirstChild("TeamHolder")
                if th then
                    for _, c in pairs(th:GetChildren()) do
                        if c:IsA("ImageButton") and c.Visible then
                            local slotNum = tonumber(c.Name)
                            if targetSlot ~= "Any" and slotNum ~= tonumber(targetSlot) then continue end
                            local hasName = false
                            for _, t in pairs(c:GetDescendants()) do
                                if t:IsA("TextLabel") and t.Text:find("@") then hasName = true; break end
                            end
                            if not hasName then fireBtn(c); break end
                        end
                    end
                end
            end
        elseif gm and gm.Visible then
            local server = getOptVal(options.AutoPlayServer) or "Regular"
            local sf = gm:FindFirstChild("Body") and gm.Body:FindFirstChild("Body") and gm.Body.Body:FindFirstChild("ScrollingFrame")
            if sf then
                local page = sf:FindFirstChild("Page1")
                if page then
                    local btn = page:FindFirstChild(server == "Regular" and "ModeRegular" or "ModePro")
                    if btn and btn.Visible then
                        local locked = btn:FindFirstChild("Locked")
                        if not (locked and locked.Visible) then
                            fireBtn(btn)
                        end
                    end
                end
            end
        else
            local handled = false
            for _, popup in pairs({"JoinProServer","JoinAfkServer","JoinSeasonalServer"}) do
                local p = lobby:FindFirstChild(popup)
                if p and p.Visible then
                    local enter = p:FindFirstChild("BGFrame") and p.BGFrame:FindFirstChild("ReturnMenu") and p.BGFrame.ReturnMenu:FindFirstChild("EnterButton")
                    if enter and enter.Visible then
                        fireBtn(enter); handled = true; break
                    end
                end
            end
            if not handled and lobby.Visible and playCD <= 0 then
                local playBtn = lobby:FindFirstChild("Buttons") and lobby.Buttons:FindFirstChild("Play")
                if playBtn and playBtn.Visible then
                    fireBtn(playBtn)
                    playCD = 1
                end
            end
        end
    end
end

-- Auto Queue
local modeButtonMap = {
    Hardcore = {"Page2", "ModeHardcore"},
    Chaos = {"Page2", "Seasonal"},
    Mini1v1 = {"Page2a", "Seasonal1"},
    Casual1v1 = {"Page4", "Mode1v1"},
    Casual2v2 = {"Page4", "Mode2v2"},
    Casual3v3 = {"Page4", "Mode3v3"},
    Casual4v4 = {"Page4", "Mode4v4"},
    Ranked1v1 = {"Page4", "Mode1v1"},
    Ranked2v2 = {"Page4", "Mode2v2"},
    Ranked3v3 = {"Page4", "Mode3v3"},
    Ranked4v4 = {"Page4", "Mode4v4"},
    Mode6v6 = {"Page5", "Mode6v6"},
}
local function autoQueueLoop()
    local playCD = 0
    while true do
        task.wait(0.1)
        if getgenv().VL_version ~= scriptVer then break end
        if not (toggles.AutoQueue and toggles.AutoQueue.Value) then break end
        local int = plrGui:FindFirstChild("Interface")
        if not int then continue end
        local lobby = int:FindFirstChild("Lobby")
        if not lobby then continue end
        local modeName = getOptVal(options.AutoQueueMode) or "Casual2v2"
        local modePath = modeButtonMap[modeName]
        local gm = lobby:FindFirstChild("Gamemodes")
        local gf = int:FindFirstChild("Game")
        playCD = playCD - 0.1

        if gf and gf.Visible then
        elseif gm and gm.Visible and modePath then
            local sf = gm:FindFirstChild("Body") and gm.Body:FindFirstChild("Body") and gm.Body.Body:FindFirstChild("ScrollingFrame")
            local page = sf and sf:FindFirstChild(modePath[1])
            local btn = page and page:FindFirstChild(modePath[2])
            if btn and btn.Visible then
                local locked = btn:FindFirstChild("Locked")
                if not (locked and locked.Visible) then fireBtn(btn) end
            end
        else
            local handled = false
            for _, popup in pairs({"JoinProServer","JoinAfkServer","JoinSeasonalServer"}) do
                local p = lobby:FindFirstChild(popup)
                if p and p.Visible and p:FindFirstChild("BGFrame") and p.BGFrame:FindFirstChild("ReturnMenu") and p.BGFrame.ReturnMenu:FindFirstChild("EnterButton") then
                    local enter = p.BGFrame.ReturnMenu.EnterButton
                    if enter.Visible then fireBtn(enter); handled = true; break end
                end
            end
            if not handled and lobby.Visible and playCD <= 0 then
                local playBtn = lobby:FindFirstChild("Buttons") and lobby.Buttons:FindFirstChild("Play")
                if playBtn and playBtn.Visible then fireBtn(playBtn); playCD = 1 end
            end
        end
    end
end

local espStyleMod, espAbMod
local function ensureEspModules()
    if not espStyleMod then
        local ok, m = pcall(function() return require(rs.Content.Style) end)
        if ok then espStyleMod = m end
    end
    if not espAbMod then
        local ok, m = pcall(function() return require(rs.Content.Ability) end)
        if ok then espAbMod = m end
    end
end

-- ESP Style Name
local espLines = {}
local function espStyleNameLoop()
    ensureEspModules()
    while true do
        task.wait(0.5)
        local styleOn = toggles.ESPStyle and toggles.ESPStyle.Value
        local abOn = toggles.ESPStyleAbility and toggles.ESPStyleAbility.Value
        if not styleOn and not abOn then break end
        for _, p in pairs(Players:GetPlayers()) do
            if p == lp then continue end
            if toggles.ESPLookTeamCheck and toggles.ESPLookTeamCheck.Value then
                local isHome = p:GetAttribute("Team") == "Home"
                local myHome = lp:GetAttribute("Team") == "Home"
                if isHome == myHome then continue end
            end
            local char = p.Character
            if not char then continue end
            local hr = char:FindFirstChild("HumanoidRootPart")
            if not hr then continue end
            local styleLabel = char:FindFirstChild("StyleLabel")
            if not styleLabel then
                styleLabel = Instance.new("BillboardGui")
                styleLabel.Name = "StyleLabel"
                styleLabel.Size = UDim2.new(0, 200, 0, 50)
                styleLabel.StudsOffset = Vector3.new(0, 3, 0)
                styleLabel.AlwaysOnTop = true
                local txt = Instance.new("TextLabel")
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.TextColor3 = Color3.new(1, 1, 1)
                txt.TextStrokeTransparency = 0.3
                txt.TextSize = 14
                txt.Font = Enum.Font.Gotham
                txt.TextWrapped = true
                txt.Parent = styleLabel
                styleLabel.Parent = char
            end
            local lines = {}
            if styleOn then
                local rawId = p:GetAttribute("Gameplay_Style") or "Unknown"
                local display = rawId
                if espStyleMod then
                    local obj = espStyleMod:Get(rawId)
                    if obj and obj.DisplayName then display = obj.DisplayName end
                end
                lines[#lines+1] = p.Name .. " - " .. display
            end
            if abOn then
                local rawId = p:GetAttribute("Gameplay_Ability") or ""
                if rawId ~= "" then
                    local display = rawId
                    if espAbMod then
                        local obj = espAbMod:Get(rawId)
                        if obj and obj.DisplayName then display = obj.DisplayName end
                    end
                    lines[#lines+1] = "[" .. display .. "]"
                end
            end
            styleLabel.TextLabel.Text = table.concat(lines, " ")
            styleLabel.TextLabel.TextSize = abOn and 12 or 14
        end
    end
end

-- ESP Look Vector
local function espLookVectorLoop()
    while true do
        RunService.Heartbeat:Wait()
        if not (toggles.ESPLookVector and toggles.ESPLookVector.Value) then break end
        local maxDist = options.ESPLookDist and options.ESPLookDist.Value or 30
        for _, p in pairs(Players:GetPlayers()) do
            if p == lp then continue end
            if toggles.ESPLookTeamCheck and toggles.ESPLookTeamCheck.Value then
                local isHome = p:GetAttribute("Team") == "Home"
                local myHome = lp:GetAttribute("Team") == "Home"
                if isHome == myHome then continue end
            end
            local char = p.Character
            if not char then continue end
            local hr = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            if not hr or not head then continue end
            local myChar = lp.Character
            if not myChar then continue end
            local myHRP = myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then continue end
            local dist = (hr.Position - myHRP.Position).Magnitude
            if dist > maxDist then
                if espLines[p] then espLines[p]:Remove(); espLines[p] = nil end
                continue
            end
            if not espLines[p] or not espLines[p].Parent then
                local line = Instance.new("Part")
                line.Name = "VLESPLine"
                line.Size = Vector3.new(0.1, 0.1, 1)
                line.Anchored = true
                line.CanCollide = false
                line.Material = Enum.Material.Neon
                line.BrickColor = BrickColor.new("Bright red")
                line.Transparency = 0.3
                line.Parent = workspace
                local cyl = Instance.new("CylinderHandleAdornment")
                cyl.Radius = 0.15
                cyl.Height = 1
                cyl.Color3 = Color3.new(1, 0, 0)
                cyl.Transparency = 0.3
                cyl.AlwaysOnTop = true
                cyl.Parent = line
                espLines[p] = line
            end
            local lookVec = head.CFrame.LookVector
            local startPos = head.Position + Vector3.new(0, 0.5, 0)
            local lineLen = math.max(0.5, maxDist - dist)
            espLines[p].CFrame = CFrame.lookAt(startPos, startPos + lookVec) * CFrame.new(0, 0, lineLen/2)
            espLines[p].Size = Vector3.new(0.1, 0.1, lineLen)
            local cyl2 = espLines[p]:FindFirstChildOfClass("CylinderHandleAdornment")
            if cyl2 then cyl2.Height = lineLen end
        end
    end
end

-- Spin
-- (spin data loaded inline at each groupbox)

local autoOpenLoop, autoHatchLoop, autoPotionLoop, autoClaimLoop, autoFavouriteLoop, autoClaimCodesLoop

local M = makeTab("Main")
local P = makeTab("Player")
local S = makeTab("Misc")
local U = makeTab("UI Settings")

-- Main
local ballGB = M:AddLeftGroupbox("Ball")
ballGB:AddToggle("HitboxToggle", { Text = "Ball Hitbox", Callback = function(v) if v then task.spawn(ballHitboxLoop) end end })
ballGB:AddSlider("HitboxScale", { Text = "Scale", Default = 5, Min = 1, Max = 30 })
ballGB:AddSlider("HitboxTransparency", { Text = "Transparency", Default = 0.65, Min = 0, Max = 1 })
ballGB:AddDivider()

local autoGB = M:AddLeftGroupbox("Auto")
autoGB:AddToggle("AutoReceive", { Text = "Auto Receive", Callback = function(v) if v then pcall(task.spawn, autoReceiveLoop) end end })
autoGB:AddSlider("AutoSetDistance", { Text = "Set Distance", Default = 15, Min = 5, Max = 50 })
autoGB:AddSlider("AutoDiveDistance", { Text = "Dive Distance", Default = 25, Min = 10, Max = 80 })
autoGB:AddDivider()
autoGB:AddToggle("AutoPlay", { Text = "Auto Play", Callback = function(v) if v then pcall(task.spawn, autoPlayLoop) end end })
autoGB:AddDropdown("AutoPlayServer", { Text = "Server", Values = {"Regular", "Pro"}, Default = 1 })
autoGB:AddDropdown("AutoPlayTeam", { Text = "Team", Values = {"Home", "Away"}, Default = 1 })
autoGB:AddDropdown("AutoPlaySlot", { Text = "Slot", Values = {"Any","1","2","3","4","5","6"}, Default = 1 })
autoGB:AddDivider()
autoGB:AddToggle("AutoQueue", { Text = "Auto Queue", Callback = function(v) if v then pcall(task.spawn, autoQueueLoop) end end })
autoGB:AddDropdown("AutoQueueMode", { Text = "Mode", Values = {"Hardcore", "Chaos", "Casual1v1", "Casual2v2", "Casual3v3", "Casual4v4", "Mode6v6", "Ranked1v1", "Ranked2v2", "Ranked3v3", "Ranked4v4"}, Default = 4 })

local blatGB = M:AddRightGroupbox("Blatant")
blatGB:AddButton({ Text = "Powerful Serve", Func = doPowerfulServe })
blatGB:AddKeybind("PwrServeKey", { Text = "Keybind", Default = Enum.KeyCode.RightBracket, Callback = function(key)
    serveKey = key
    notify('Powerful Serve: ' .. key.Name)
end })
blatGB:AddDivider()
blatGB:AddToggle("SpikeNoCD", { Text = "Spike No CD", Callback = function(v) if v then task.spawn(noCDFactory("SpikeNoCD")) end end })
blatGB:AddToggle("SetNoCD", { Text = "Set No CD", Callback = function(v) if v then task.spawn(noCDFactory("SetNoCD")) end end })
blatGB:AddToggle("BumpNoCD", { Text = "Bump No CD", Callback = function(v) if v then task.spawn(noCDFactory("BumpNoCD")) end end })
blatGB:AddToggle("DiveNoCD", { Text = "Dive No CD", Callback = function(v) if v then task.spawn(noCDFactory("DiveNoCD")) end end })
blatGB:AddDivider()
blatGB:AddToggle("BypassLowSpike", { Text = "Bypass Low Spike", Callback = function(v) if v then task.spawn(bypassLowSpikeLoop) end end })

local aimGB = M:AddLeftGroupbox("Aimbot")
aimGB:AddToggle("JumpSetAimbot", { Text = "Jump Set Aimbot", Callback = function(v) if v then task.spawn(jumpSetAimbotLoop) end end })
aimGB:AddSlider("JumpSetPrediction", { Text = "Prediction", Default = 0.5, Min = 0, Max = 1, Rounding = 1, Suffix = "" })
aimGB:AddDivider()
aimGB:AddToggle("SpikeAimbot", { Text = "Spike Aimbot", Callback = function(v) if v then task.spawn(spikeAimbotLoop) end end })

local styleGB = M:AddRightGroupbox("Style Modifier")
styleGB:AddButton({ Text = "Timeskip Okazu Super Toss", Func = doToruServe })
styleGB:AddKeybind("ToruKey", { Text = "Keybind", Default = Enum.KeyCode.T, Callback = function(key)
    toruKey = key
    notify("Timeskip Okazu Key: " .. key.Name)
end })
styleGB:AddDivider()
styleGB:AddToggle("ShoyoMod", { Text = "Timeskip Hinto Super Spike", Callback = function(v) if v then task.spawn(shoyoModifier) end end })
styleGB:AddDivider()
styleGB:AddToggle("KuraiMod", { Text = "Ronin Super Spike", Callback = function(v) if v then task.spawn(kuraiModifier) end end })
styleGB:AddDivider()
styleGB:AddToggle("KijoMod", { Text = "Kijo Tilt Spike", Callback = function(v) if v then task.spawn(kijoModifier) end end })
styleGB:AddDropdown("KijoModSide", { Text = "Side", Values = {"Left", "Right"}, Default = "Left" })

-- Player
local moveGB = P:AddLeftGroupbox("Movement")
moveGB:AddToggle("InfiniteJump", { Text = "Infinite Jump", Callback = function(v) if v then task.spawn(infiniteJumpLoop) end end })
moveGB:AddToggle("WalkSpeedToggle", { Text = "Walk Speed", Callback = function(v) if v then task.spawn(tpwalkLoop) end end })
moveGB:AddSlider("WalkSpeed", { Text = "Speed", Default = 16, Min = 16, Max = 100, Rounding = 0 })
moveGB:AddToggle("JumpPowerToggle", { Text = "Jump Power", Callback = function(v) if v then task.spawn(jumpPowerLoop) end end })
moveGB:AddSlider("JumpPower", { Text = "Power", Default = 10, Min = 10, Max = 200 })
moveGB:AddSlider("DiveBoost", { Text = "Dive Boost", Default = 1, Min = 1, Max = 5, Callback = function(v) setDiveBoost(v) end })
moveGB:AddDivider()
moveGB:AddToggle("UnlockChar", { Text = "Unlock Rotation", Callback = function(v) if v then task.spawn(unlockCharLoop) end end })
moveGB:AddToggle("AirRedirect", { Text = "Air Redirect", Callback = function(v) if v then task.spawn(airRedirectLoop) end end })
moveGB:AddSlider("AirRedirectSpeed", { Text = "Air Speed", Default = 50, Min = 16, Max = 120 })

local espGB = P:AddRightGroupbox("ESP")
espGB:AddToggle("ESPStyle", { Text = "Style ESP", Callback = function(v) if v then task.spawn(espStyleNameLoop) else for _, p in pairs(Players:GetPlayers()) do local c = p.Character; if c then local l = c:FindFirstChild("StyleLabel"); if l then l:Remove() end end end end end })
espGB:AddToggle("ESPStyleAbility", { Text = "Ability ESP", Default = false })
espGB:AddToggle("ESPLookVector", { Text = "Look Vector", Callback = function(v) if v then task.spawn(espLookVectorLoop) else for _, l in pairs(espLines) do if l and l.Parent then l:Remove() end end; for k in pairs(espLines) do espLines[k] = nil end end end })
espGB:AddSlider("ESPLookDist", { Text = "Distance", Default = 30, Min = 10, Max = 50 })
espGB:AddToggle("ESPLookTeamCheck", { Text = "Team Check (Home/Away)", Default = true })

-- Spin
local abNames = {}; local stNames = {}
pcall(function()
    local am = rs:FindFirstChild("Content") and rs.Content:FindFirstChild("Ability")
    local sm = rs:FindFirstChild("Content") and rs.Content:FindFirstChild("Style")
    if am then
        local A = require(am)
        for _, v in pairs(A:GetActiveIds()) do
            local a = A:Get(v)
            if a and a.DisplayName then abNames[#abNames+1] = a.DisplayName end
        end
    end
    if sm then
        local S = require(sm)
        for _, v in pairs(S:GetActiveIds()) do
            local s = S:Get(v)
            if s and s.DisplayName then stNames[#stNames+1] = s.DisplayName end
        end
    end
end)
table.sort(abNames); table.sort(stNames)

local spinGB_L = S:AddLeftGroupbox("Ability Spin")
spinGB_L:AddToggle("AutoSpinAbility", { Text = "Auto Spin Ability", Default = false })
spinGB_L:AddDropdown("SpinAbilityTargets", { Text = "Stop On", Values = #abNames > 0 and abNames or {"(none)"}, Multi = true })
local abSlotDD = spinGB_L:AddDropdown("SpinAbilitySlot", { Text = "Slot", Values = {"1","2","3","4","5","6"}, Default = "1" })

local spinGB_R = S:AddRightGroupbox("Style Spin")
spinGB_R:AddToggle("AutoSpinStyle", { Text = "Auto Spin Style", Default = false })
spinGB_R:AddDropdown("SpinStyleTargets", { Text = "Stop On", Values = #stNames > 0 and stNames or {"(none)"}, Multi = true })
local stSlotDD = spinGB_R:AddDropdown("SpinStyleSlot", { Text = "Slot", Values = {"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18"}, Default = "1" })

local openGB_L = S:AddLeftGroupbox("Auto Open Pack")
openGB_L:AddToggle("AutoOpenPack", { Text = "Auto Open Pack", Callback = function(v) if v then pcall(task.spawn, autoOpenLoop) end end })
local openPackDD = openGB_L:AddDropdown("AutoOpenPackTypes", { Text = "Pack Types", Values = {"(loading...)"}, Multi = true })
openGB_L:AddSlider("AutoOpenAmount", { Text = "Amount", Default = 10, Min = 1, Max = 100, Rounding = 0 })
openGB_L:AddDivider()
openGB_L:AddToggle("AutoFavourite", { Text = "Auto Favourite Item", Callback = function(v) if v then pcall(task.spawn, autoFavouriteLoop) end end })

local eggGB_L = S:AddLeftGroupbox("Auto Hatch Egg")
eggGB_L:AddToggle("AutoHatchEgg", { Text = "Auto Hatch Egg", Callback = function(v) if v then pcall(task.spawn, autoHatchLoop) end end })
local eggTypesDD = eggGB_L:AddDropdown("AutoHatchEggTypes", { Text = "Egg Types", Values = {"(loading...)"}, Multi = true })
eggGB_L:AddSlider("AutoHatchAmount", { Text = "Amount", Default = 5, Min = 1, Max = 50, Rounding = 0 })

local potGB_R = S:AddRightGroupbox("Auto Consume Potion")
potGB_R:AddToggle("AutoConsumePotion", { Text = "Auto Consume Potion", Callback = function(v) if v then pcall(task.spawn, autoPotionLoop) end end })
local potTypesDD = potGB_R:AddDropdown("AutoConsumePotionTypes", { Text = "Potion Types", Values = {"(loading...)"}, Multi = true })
potGB_R:AddSlider("AutoConsumePotAmount", { Text = "Amount", Default = 3, Min = 1, Max = 50, Rounding = 0 })

local claimGB_R = S:AddRightGroupbox("Auto Claim Reward")
claimGB_R:AddToggle("AutoClaimDaily", { Text = "Auto Claim Daily Present", Callback = function(v) if v then pcall(task.spawn, autoClaimLoop) end end })
claimGB_R:AddToggle("AutoClaimLevel", { Text = "Auto Claim Level Rewards" })
claimGB_R:AddToggle("AutoClaimSeason", { Text = "Auto Claim Season Rewards" })
claimGB_R:AddToggle("AutoClaimRebirth", { Text = "Auto Claim Rebirth Reward" })
claimGB_R:AddDivider()
claimGB_R:AddToggle("AutoClaimCodes", { Text = "Auto Claim Codes", Callback = function(v) if v then task.spawn(autoClaimCodesLoop) end end })

local spinRunners = {}
local function runAbilitySpin()
    local asSvc = getService("AbilityService")
    local acCtrl = getController("AbilityController")
    if not asSvc then return end
    local ok_A, Ability = pcall(function() return require(rs.Content.Ability) end)
if not ok_A then Ability = nil end
    local running = true
    local id = {}
    table.insert(spinRunners, id)
    while running do
        if not toggles.AutoSpinAbility or not toggles.AutoSpinAbility.Value then running = false; break end
        local spins = acCtrl and acCtrl.Spins and acCtrl.Spins:get() or 0
        if spins <= 0 then task.wait(1) continue end
        local slotNum = tonumber(options.SpinAbilitySlot and options.SpinAbilitySlot.Value) or 1
        if acCtrl and acCtrl.CurrentAbilitySlot and slotNum then acCtrl.CurrentAbilitySlot:set(slotNum) end
        task.wait(0.05)
        local ok, result = pcall(function() return {asSvc:Roll(false):expect()} end)
        if ok and result and result[1] then
            local arr = result[2]; local won = arr and arr[#arr]
            if won and won ~= "" and Ability then
                local ab = Ability:Get(won)
                local name = ab and ab.DisplayName or won
                local targets = options.SpinAbilityTargets and options.SpinAbilityTargets.Value or {}
                if targets[name] then
                    toggles.AutoSpinAbility:SetValue(false)
                    notify('Got ability: ' .. name)
                    running = false; break
                end
            end
        end
        task.wait(0.5)
    end
    for i, v in pairs(spinRunners) do if v == id then table.remove(spinRunners, i) end end
end

local function runStyleSpin()
    local ssSvc = getService("StyleService")
    local scCtrl = getController("StyleController")
    if not ssSvc then return end
    local ok_S, Style = pcall(function() return require(rs.Content.Style) end)
if not ok_S then Style = nil end
    local running = true
    local id = {}
    table.insert(spinRunners, id)
    while running do
        if not toggles.AutoSpinStyle or not toggles.AutoSpinStyle.Value then running = false; break end
        local spins = scCtrl and scCtrl.Spins and scCtrl.Spins:get() or 0
        if spins <= 0 then task.wait(1) continue end
        local slotNum = tonumber(options.SpinStyleSlot and options.SpinStyleSlot.Value) or 1
        if scCtrl and scCtrl.CurrentStyleSlot and slotNum then scCtrl.CurrentStyleSlot:set(slotNum) end
        task.wait(0.05)
        local ok, result = pcall(function() return {ssSvc:Roll(false):expect()} end)
        if ok and result and result[1] then
            local arr = result[2]; local won = arr and arr[#arr]
            if won and won ~= "" and Style then
                local st = Style:Get(won)
                local name = st and st.DisplayName or won
                local targets = options.SpinStyleTargets and options.SpinStyleTargets.Value or {}
                if targets[name] then
                    toggles.AutoSpinStyle:SetValue(false)
                    notify('Got style: ' .. name)
                    running = false; break
                end
            end
        end
        task.wait(0.5)
    end
    for i, v in pairs(spinRunners) do if v == id then table.remove(spinRunners, i) end end
end

-- wire spin toggles
task.spawn(function()
    task.wait(0.1)
    if toggles.AutoSpinAbility then
        local old = toggles.AutoSpinAbility.SetValue
        toggles.AutoSpinAbility.SetValue = function(self, v)
            old(self, v)
            if v then task.spawn(runAbilitySpin) end
        end
    end
    if toggles.AutoSpinStyle then
        local old = toggles.AutoSpinStyle.SetValue
        toggles.AutoSpinStyle.SetValue = function(self, v)
            old(self, v)
            if v then task.spawn(runStyleSpin) end
        end
    end
end)

-- populate auto open pack types
task.spawn(function()
    task.wait(0.2)
    if not openPackDD then return end
    local packNames = {}; local eggNames = {}; local potNames = {}
    local entities = rs:FindFirstChild("Content") and rs.Content:FindFirstChild("Item") and rs.Content.Item:FindFirstChild("Entities")
    if entities then
        for _, c in pairs(entities:GetChildren()) do
            if c:IsA("ModuleScript") then
                local ok, item = pcall(function() return require(c) end)
                if ok and item and item.Type == "Consumable" then
                    local dn = item.DisplayName or item.Id
                    local dnLower = dn:lower()
                    if dnLower:find("egg") then
                        eggNames[#eggNames+1] = dn
                    elseif dnLower:find("potion") then
                        potNames[#potNames+1] = dn
                    else
                        packNames[#packNames+1] = dn
                    end
                end
            end
        end
    end
    -- also add packs from Products.Packs
    local ok, packs = pcall(function() return require(rs.Content.Monetization.Products.Packs) end)
    if ok and packs then
        for _, pack in pairs(packs) do
            local dn = pack.Name or ""
            local found = false
            for _, n in pairs(packNames) do
                if n:lower() == dn:lower() then found = true; break end
            end
            if not found then
                packNames[#packNames+1] = dn
            end
        end
    end
    if #packNames == 0 then
        packNames = {"Magic Pack", "Magic Pack 3", "Robux Pack", "Toxic 1 Pack"}
    end
    if #eggNames == 0 then
        eggNames = {"Diamond Egg", "Bunny Egg", "Chocolate Egg", "Easter Egg", "Golden Sun Egg", "Shiny Bunny Egg", "Shiny Chocolate Egg"}
    end
    if #potNames == 0 then
        potNames = {"Ability Potion", "Aura Potion", "Block Power Potion", "Bouncy Potion", "Height Potion", "Luck Potion", "Set Power Potion", "Speed Potion", "Spike Power Potion", "Thick Potion", "Yen Potion"}
    end
    table.sort(packNames); table.sort(eggNames); table.sort(potNames)
    openPackDD:Refresh(packNames)
    if eggTypesDD then eggTypesDD:Refresh(eggNames) end
    if potTypesDD then potTypesDD:Refresh(potNames) end
end)

-- Auto Open / Hatch / Favourite
local function getInventoryItems()
    local invSvc = getService("InventoryService")
    local icCtrl = getController("InventoryController")
    if not (invSvc and icCtrl) then return {} end
    local inv = icCtrl.Inventory and icCtrl.Inventory:get()
    if not inv then return {} end
    local items = {}
    for id, qty in pairs(inv) do
        if type(id) == "string" and qty > 0 then
            items[#items+1] = {Id = id, Qty = qty}
        end
    end
    return items
end

local function autoUseItem(itemId)
    local ps = getService("PackService")
    if ps then
        local ok = pcall(function() return ps:Open(itemId):expect() end)
        if ok then return end
    end
    local invSvc = getService("InventoryService")
    if invSvc then
        pcall(function() return invSvc:Use(itemId):expect() end)
    end
end

local function autoOpenLoop()
    while true do
        task.wait(0.3)
        if not (toggles.AutoOpenPack and toggles.AutoOpenPack.Value) then break end
        local items = getInventoryItems()
        local packTypes = options.AutoOpenPackTypes and options.AutoOpenPackTypes.Value or {}
        local maxAmount = options.AutoOpenAmount and options.AutoOpenAmount.Value or 10
        local used = 0
        for _, item in pairs(items) do
            if used >= maxAmount then break end
            local ok, rsItem = pcall(function() return require(rs.Content.Item.Entities[item.Id]) end)
            if ok and rsItem and rsItem.Type == "Consumable" then
                local dn = rsItem.DisplayName or item.Id
                if packTypes[dn] then
                    autoUseItem(item.Id)
                    used = used + 1
                    task.wait(0.5)
                end
            end
        end
        task.wait(2)
    end
end

local function autoHatchLoop()
    while true do
        task.wait(0.3)
        if not (toggles.AutoHatchEgg and toggles.AutoHatchEgg.Value) then break end
        local items = getInventoryItems()
        local eggTypes = options.AutoHatchEggTypes and options.AutoHatchEggTypes.Value or {}
        local maxAmount = options.AutoHatchAmount and options.AutoHatchAmount.Value or 5
        local used = 0
        for _, item in pairs(items) do
            if used >= maxAmount then break end
            local ok, rsItem = pcall(function() return require(rs.Content.Item.Entities[item.Id]) end)
            if ok and rsItem and rsItem.Type == "Consumable" then
                local dn = rsItem.DisplayName or item.Id
                if eggTypes[dn] then
                    autoUseItem(item.Id)
                    used = used + 1
                    task.wait(0.5)
                end
            end
        end
        task.wait(2)
    end
end

local function autoPotionLoop()
    while true do
        task.wait(0.3)
        if not (toggles.AutoConsumePotion and toggles.AutoConsumePotion.Value) then break end
        local items = getInventoryItems()
        local potTypes = options.AutoConsumePotionTypes and options.AutoConsumePotionTypes.Value or {}
        local maxAmount = options.AutoConsumePotAmount and options.AutoConsumePotAmount.Value or 3
        local used = 0
        for _, item in pairs(items) do
            if used >= maxAmount then break end
            local ok, rsItem = pcall(function() return require(rs.Content.Item.Entities[item.Id]) end)
            if ok and rsItem and rsItem.Type == "Consumable" then
                local dn = rsItem.DisplayName or item.Id
                if potTypes[dn] then
                    autoUseItem(item.Id)
                    used = used + 1
                    task.wait(0.5)
                end
            end
        end
        task.wait(2)
    end
end

local function autoClaimLoop()
    while true do
        task.wait(5)
        if not (toggles.AutoClaimDaily and toggles.AutoClaimDaily.Value) then break end
        local ss = getService("SeasonService")
        if ss then
            local ls = getService("LevelService")
            pcall(function() ss:ClaimDailyPresent(1, true):expect() end)
            if toggles.AutoClaimLevel and toggles.AutoClaimLevel.Value and ls then
                pcall(function() ls:ClaimLevelRewards() end)
            end
            if toggles.AutoClaimSeason and toggles.AutoClaimSeason.Value then
                for tier = 1, 50 do
                    local ok3, _ = pcall(function() return ss:RequestRewardClaim(tier):expect() end)
                    if not ok3 then break end
                end
            end
            if toggles.AutoClaimRebirth and toggles.AutoClaimRebirth.Value then
                pcall(function() ss:RequestRebirthReward() end)
            end
        end
        task.wait(60)
    end
end

local function autoClaimCodesLoop()
    local hardcoded = {"UPDATE_76","ENCHO_RETURNS","BALANCE_76","UPDATE_75","SPECTATING","SHOW_OFF"}
    while true do
        task.wait(120)
        if not (toggles.AutoClaimCodes and toggles.AutoClaimCodes.Value) then break end
        local cs = getService("CodeService")
        if not cs then continue end
        for _, code in pairs(hardcoded) do
            local ok, msg = pcall(function() return cs:Redeem(code):expect() end)
            if ok then print("Claimed: " .. code) end
            task.wait(2)
        end
    end
end

local function autoFavouriteLoop()
    while true do
        task.wait(1)
        if not (toggles.AutoFavourite and toggles.AutoFavourite.Value) then break end
        local icCtrl = getController("InventoryController")
        if not icCtrl then continue end
        local pcCtrl = getController("PackController")
        if pcCtrl and pcCtrl.Item then
            local item = pcCtrl.Item:get()
            if item and item.ItemName then
                pcall(function() icCtrl:TryToggleFavorite(item.ItemName) end)
                task.wait(0.5)
            end
        end
    end
end

-- UI Settings
local cfgDir = "UndetectedDynamic/games/Volleyball-Legends/config"
local function ensureDirs()
    if not isfolder then return end
    if not isfolder("UndetectedDynamic") then makefolder("UndetectedDynamic") end
    if not isfolder("UndetectedDynamic/games") then makefolder("UndetectedDynamic/games") end
    if not isfolder("UndetectedDynamic/games/Volleyball-Legends") then makefolder("UndetectedDynamic/games/Volleyball-Legends") end
    if not isfolder(cfgDir) then makefolder(cfgDir) end
end

local function readToggleData()
    local data = {}
    for idx, obj in pairs(toggles) do data["t_" .. idx] = obj.Value end
    for idx, obj in pairs(options) do
        if type(obj.Value) == "table" then
            local copy = {}; for k in pairs(obj.Value) do copy[k] = true end
            data["o_" .. idx] = copy
        else
            data["o_" .. idx] = obj.Value
        end
    end
    for _, k in pairs(colorKeys) do
        local cl = colorPickers[k] and colorPickers[k]:GetValue() or c[k]
        data["c_" .. k] = {cl.R, cl.G, cl.B}
    end
    data["_activeAutoexec"] = false
    return data
end

local function writeConfig(name, data)
    ensureDirs()
    local ok, json = pcall(HttpService.JSONEncode, HttpService, data)
    if ok and isfolder then
        writefile(cfgDir .. "/" .. name .. ".json", json)
        return true
    end
    return false
end

local function readConfig(name)
    local p = cfgDir .. "/" .. name .. ".json"
    if not isfile or not isfile(p) then return nil end
    local ok, data = pcall(HttpService.JSONDecode, HttpService, readfile(p))
    if ok and type(data) == "table" then return data end
    return nil
end

local function applyConfig(data)
    for k, v in pairs(data) do
        local key = k:match("^t_(.+)$")
        if key and toggles[key] then toggles[key]:SetValue(v) end
        local key2 = k:match("^o_(.+)$")
        if key2 and options[key2] then
            if type(v) == "table" then
                local sel = {}; for kk in pairs(v) do sel[kk] = true end
                options[key2].Value = sel
            else
                options[key2]:SetValue(v)
            end
        end
        local key3 = k:match("^c_(.+)$")
        if key3 and colorPickers[key3] and type(v) == "table" and #v == 3 then
            colorPickers[key3]:SetValue(Color3.fromRGB(v[1]*255, v[2]*255, v[3]*255))
        end
    end
end

local function listConfigs()
    if not isfolder or not listfiles then return {} end
    if not isfolder(cfgDir) then return {} end
    local names = {}
    for _, f in pairs(listfiles(cfgDir)) do
        local n = f:match("([^/\\]+)%.json$")
        if n then names[#names+1] = n end
    end
    table.sort(names)
    return names
end

local cfgGB = U:AddLeftGroupbox("Configuration")
local cfgInput = cfgGB:AddInput({ Default = "config", Placeholder = "Config name" })
cfgGB:AddButton({ Text = "Create Config", Func = function()
    local name = cfgInput.Value:match("^%s*(.-)%s*$") or "config"
    if writeConfig(name, readToggleData()) then
        notify('Created "' .. name .. '"')
        if cfgDD then cfgDD:Refresh(listConfigs()) end
    end
end })
cfgGB:AddDivider()
local cfgDD = cfgGB:AddDropdown("ConfigList", { Text = "Select Config", Values = listConfigs(), Callback = function(v)
    if v and v ~= "" then cfgInput.box.Text = v end
end })
cfgGB:AddButton({ Text = "Load Selected Config", Func = function()
    local name = cfgInput.Value:match("^%s*(.-)%s*$") or "config"
    local data = readConfig(name)
    if data then
        applyConfig(data)
        notify('Loaded "' .. name .. '"')
    end
end })
cfgGB:AddButton({ Text = "Save Selected Config", Func = function()
    local name = cfgInput.Value:match("^%s*(.-)%s*$") or "config"
    if writeConfig(name, readToggleData()) then
        notify('Saved "' .. name .. '"')
        if cfgDD then cfgDD:Refresh(listConfigs()) end
    end
end })
cfgGB:AddButton({ Text = "Delete Selected Config", DoubleClick = true, Func = function()
    local name = cfgInput.Value:match("^%s*(.-)%s*$") or "config"
    local p = cfgDir .. "/" .. name .. ".json"
    if isfile and isfile(p) then delfile(p); notify('Deleted "' .. name .. '"') end
    if cfgDD then cfgDD:Refresh(listConfigs()) end
end })
cfgGB:AddDivider()
cfgGB:AddToggle("AutoLoadCfg", { Text = "Auto Load on Start", Default = false })
cfgGB:AddToggle("AutoSaveCfg", { Text = "Auto Save Every 60s", Default = true })
cfgGB:AddDivider()
cfgGB:AddButton({ Text = "Reset to Defaults", DoubleClick = true, Func = function()
    local name = cfgInput.Value:match("^%s*(.-)%s*$") or "config"
    for _, obj in pairs(toggles) do obj:SetValue(false) end
    if writeConfig(name, readToggleData()) then
        notify('Reset "' .. name .. '" to defaults')
        if cfgDD then cfgDD:Refresh(listConfigs()) end
    end
end })
cfgGB:AddButton({ Text = "Delete All Configs", DoubleClick = true, Func = function()
    if not isfolder then return end
    if not isfolder(cfgDir) then return end
    for _, f in pairs(listfiles(cfgDir)) do
        if isfile and isfile(f) then delfile(f) end
    end
    if cfgDD then cfgDD:Refresh(listConfigs()) end
    notify("All configs deleted")
end })
U.btn.MouseButton1Click:Connect(function()
    task.wait()
    if cfgDD then cfgDD:Refresh(listConfigs()) end
end)
task.defer(function() task.wait(0.5); if cfgDD then cfgDD:Refresh(listConfigs()) end end)

-- Color Customization
local function applyColorTheme()
    for name, btn in pairs(tabButtons) do
        btn.TextColor3 = (name == activeTab) and c.acc or c.tabInactive
    end
    if tabBar then tabBar.BackgroundColor3 = c.header end
    for _, tab in pairs(tabs) do
        for _, gb in pairs(tab.leftGroupboxes) do
            if gb.frame then gb.frame.BackgroundColor3 = c.gb; gb.frame.BorderColor3 = c.brd end
            if gb.accBar then gb.accBar.BackgroundColor3 = c.acc end
            if gb.titleLbl then gb.titleLbl.TextColor3 = c.txt end
            if gb.hdrLine then gb.hdrLine.BackgroundColor3 = c.brd end
        end
        for _, gb in pairs(tab.rightGroupboxes) do
            if gb.frame then gb.frame.BackgroundColor3 = c.gb; gb.frame.BorderColor3 = c.brd end
            if gb.accBar then gb.accBar.BackgroundColor3 = c.acc end
            if gb.titleLbl then gb.titleLbl.TextColor3 = c.txt end
            if gb.hdrLine then gb.hdrLine.BackgroundColor3 = c.brd end
        end
        if tab.leftScroll then tab.leftScroll.ScrollBarImageColor3 = c.acc end
        if tab.rightScroll then tab.rightScroll.ScrollBarImageColor3 = c.acc end
    end
end
local themeGB = U:AddRightGroupbox("Color Customization")
local colorLabels = {
    bg = "Background", surface = "Surface", gb = "Groupbox",
    header = "Header", acc = "Accent", hover = "Hover",
    txt = "Text", dim = "Dim Text", brd = "Border",
    sl = "Slider", red = "Danger", tabInactive = "Inactive Tab"
}
for _, k in pairs(colorKeys) do
    themeGB:AddColorPicker(k, { Text = colorLabels[k] or k, Default = c[k], Callback = function(cl)
        c[k] = cl
        if k == "acc" or k == "header" or k == "txt" or k == "tabInactive" then applyColorTheme() end
    end })
end
themeGB:AddDivider()

-- UI Settings
local setGB = U:AddRightGroupbox("UI Settings")
setGB:AddButton({ Text = "Reset Script", DoubleClick = true, Func = function()
    local dirs = {cfgDir}
    local allData = {"UndetectedDynamic/games/Volleyball-Legends"}
    for _, d in pairs(dirs) do
        if isfolder and isfolder(d) then
            for _, f in pairs(listfiles(d)) do if isfile and isfile(f) then delfile(f) end end
        end
    end
    for _, d in pairs(allData) do
        if isfolder and isfolder(d) then
            for _, f in pairs(listfiles(d)) do if isfile and isfile(f) then delfile(f) end end
        end
    end
    for _, obj in pairs(toggles) do obj:SetValue(false) end
    notify("Script reset — config and data removed")
end })
setGB:AddToggle("NotifToggle", { Text = "Notification Toggle", Default = true, Callback = function(v) notifEnabled = v end })
setGB:AddDropdown("NotifSide", { Text = "Notification Position", Values = {"Right", "Left"}, Default = "Right", Callback = function(v) notifSide = v or "Right" end })
setGB:AddKeybind("UIToggleKey", { Text = "UI Toggle", Default = Enum.KeyCode.Insert, Callback = function(key)
    switchKey = key
    notify('UI Toggle: ' .. key.Name)
end })
setGB:AddDivider()
setGB:AddToggle("MobileMode", { Text = "Mobile Mode", Default = false, Callback = function(v)
    if v then
        task.spawn(initMobileButtons)
    else
        destroyMobileButtons()
    end
end })
setGB:AddButton({ Text = "Edit Buttons", Func = function()
    if not mbSg then notify("Enable Mobile Mode first"); return end
    toggleMbEdit()
end })

-- Mobile Button System
local mbSg, mbFrame, mbButtons, mbEditMode, mbSavedPos, mbAddBtn
local function saveBtnPositions()
    if not isfolder or not mbButtons then return end
    local dir = "UndetectedDynamic/games/Volleyball-Legends/mobile"
    if not isfolder(dir) then pcall(makefolder, dir) end
    local data = {}
    for id, mb in pairs(mbButtons) do
        if id ~= "_add" then
            data[id] = { X = mb.btn.AbsolutePosition.X, Y = mb.btn.AbsolutePosition.Y }
        end
    end
    local ok, json = pcall(HttpService.JSONEncode, HttpService, data)
    if ok then pcall(writefile, dir .. "/positions.json", json) end
end
local function loadBtnPositions()
    local dir = "UndetectedDynamic/games/Volleyball-Legends/mobile"
    if not isfile or not isfile(dir .. "/positions.json") then return {} end
    local ok, data = pcall(HttpService.JSONDecode, HttpService, readfile(dir .. "/positions.json"))
    if ok and type(data) == "table" then return data end
    return {}
end

local function makeMbBtn(info, savedPos)
    local sp = savedPos[info.id]
    local pos = sp and UDim2.fromOffset(sp.X, sp.Y) or info.pos
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = pos
    btn.Text = info.label
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = c.acc
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = mbFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local st = Instance.new("UIStroke", btn)
    st.Color = c.brd; st.Thickness = 1

    local mb = { btn = btn, id = info.id, action = info.action }
    local dragRef
    btn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then
            if mbEditMode then
                local d = Vector2.new(inp.Position.X - btn.AbsolutePosition.X, inp.Position.Y - btn.AbsolutePosition.Y)
                dragRef = inp
                local conn = RunService.RenderStepped:Connect(function()
                    if not dragRef then conn:Disconnect() return end
                    local tp = UserInputService:GetTouchPosition(0)
                    btn.Position = UDim2.fromOffset(tp.X - d.X, tp.Y - d.Y)
                end)
                inp.Ended:Connect(function() dragRef = nil; conn:Disconnect(); saveBtnPositions() end)
            else
                info.action()
            end
        end
    end)
    mbButtons[info.id] = mb
    return mb
end

function toggleMbEdit()
    if not mbSg then notify("Enable Mobile Mode first"); return end
    mbEditMode = not mbEditMode
    if mbAddBtn then mbAddBtn.Visible = mbEditMode end
    for id, mb in pairs(mbButtons) do
        if id ~= "_add" then
            mb.btn.BackgroundColor3 = mbEditMode and c.hover or c.acc
        end
    end
    if not mbEditMode then saveBtnPositions() end
    notify(mbEditMode and "Button edit mode ON" or "Button edit mode OFF")
end

local function initMobileButtons()
    if mbSg then mbSg.Enabled = true; return end
    mbSg = Instance.new("ScreenGui")
    mbSg.Name = "UDVLMobile"
    mbSg.ZIndexBehavior = Enum.ZIndexBehavior.Global
    mbSg.DisplayOrder = 1001
    mbSg.ResetOnSpawn = false
    mbSg.Parent = plrGui

    mbFrame = Instance.new("Frame")
    mbFrame.Size = UDim2.new(1, 0, 1, 0)
    mbFrame.BackgroundTransparency = 1
    mbFrame.Parent = mbSg

    mbButtons = {}
    mbEditMode = false
    mbSavedPos = loadBtnPositions()

    local defaultBtns = {
        { id = "UIToggle", label = "UI", pos = UDim2.fromOffset(10, 300), action = function()
            win.Visible = not win.Visible; minFloat.Visible = not win.Visible
        end },
        { id = "PowerServe", label = "S", pos = UDim2.fromOffset(70, 300), action = function() doPowerfulServe() end },
        { id = "ToruServe", label = "T", pos = UDim2.fromOffset(130, 300), action = function() doToruServe() end },
    }
    for _, info in pairs(defaultBtns) do makeMbBtn(info, mbSavedPos) end

    mbAddBtn = Instance.new("TextButton")
    mbAddBtn.Size = UDim2.new(0, 50, 0, 50)
    mbAddBtn.Position = UDim2.fromOffset(190, 300)
    mbAddBtn.Text = "+"
    mbAddBtn.TextSize = 20
    mbAddBtn.TextColor3 = c.txt
    mbAddBtn.BackgroundColor3 = c.gb
    mbAddBtn.Font = Enum.Font.GothamBold
    mbAddBtn.BorderSizePixel = 1
    mbAddBtn.BorderColor3 = c.brd
    mbAddBtn.Visible = false
    mbAddBtn.Parent = mbFrame
    Instance.new("UICorner", mbAddBtn).CornerRadius = UDim.new(0, 8)
    mbButtons["_add"] = { btn = mbAddBtn, id = "_add" }

    mbAddBtn.MouseButton1Click:Connect(function()
        local actions = {
            { id = "UIToggle", label = "UI Toggle", act = function() win.Visible = not win.Visible; minFloat.Visible = not win.Visible end },
            { id = "PowerServe", label = "Power Serve", act = function() doPowerfulServe() end },
            { id = "ToruServe", label = "Toru Serve", act = function() doToruServe() end },
        }
        local found = false
        for _, a in pairs(actions) do
            if not mbButtons[a.id] then
                local sp = mbSavedPos[a.id]
                local pos = sp and UDim2.fromOffset(sp.X, sp.Y) or UDim2.fromOffset(250, 300)
                makeMbBtn({ id = a.id, label = a.label:match("^(%u+)") or a.label:sub(1,2), pos = pos, action = a.act }, mbSavedPos)
                mbSavedPos[a.id] = { X = pos.X.Offset, Y = pos.Y.Offset }
                notify("Added: " .. a.label)
                found = true; break
            end
        end
        if not found then notify("All buttons already added") end
    end)
end

local function destroyMobileButtons()
    if mbSg then pcall(function() mbSg:Destroy() end) end
    mbSg = nil; mbFrame = nil; mbButtons = nil; mbAddBtn = nil
end

-- global input handler
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == serveKey then doPowerfulServe() end
    if inp.KeyCode == toruKey then doToruServe() end
end)

-- autosave loop
task.spawn(function()
    while task.wait(60) do
        local autoSave = toggles.AutoSaveCfg and toggles.AutoSaveCfg.Value
        if autoSave then
            local n = cfgInput.Value:match("^%s*(.-)%s*$") or "autosave"
            writeConfig(n, readToggleData())
        end
    end
end)

-- autoload last config
task.spawn(function()
    task.wait(0.3)
    if toggles.AutoLoadCfg and toggles.AutoLoadCfg.Value then
        local names = listConfigs()
        if #names > 0 then
            local last = names[#names]
            local data = readConfig(last)
            if data then
                applyConfig(data)
                if cfgInput then cfgInput.box.Text = last end
                if cfgDD then cfgDD.Value = {[last] = true}; end
                task.wait(0.1)
                applyColorTheme()
            end
        end
    end
end)

-- final resize
task.defer(function()
    task.wait(0.1)
    for _, tab in pairs(tabs) do
        for _, gb in pairs(tab.leftGroupboxes) do gb:Resize() end
        for _, gb in pairs(tab.rightGroupboxes) do gb:Resize() end
    end
    notify("Volleyball Legends loaded")
end)
end)
if not okInit then warn("VL init error:", errInit) end