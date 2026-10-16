-- ════════════════════════════════════════════════════════════════
--  Eddie's Premium Hub  |  Universal All-In-One
--  UI     : WindUI Style  ·  Premium Gold Theme
--  Build  : 2026.04.23.3
--  Notes  : aimbot FOV circle fixed, camera FOV slider added.
--           keyless. loadstring-safe.
-- ════════════════════════════════════════════════════════════════

local function __main()
    local Players          = game:GetService("Players")
    local RunService       = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService     = game:GetService("TweenService")
    local CoreGui          = game:GetService("CoreGui")
    local Lighting         = game:GetService("Lighting")
    local VirtualUser      = game:GetService("VirtualUser")
    local Teams            = game:GetService("Teams")

    local LocalPlayer      = Players.LocalPlayer
    local Camera           = workspace.CurrentCamera
    local Workspace        = workspace
    local mouse            = LocalPlayer:GetMouse()

    local GUIParent = CoreGui
    if not GUIParent then GUIParent = LocalPlayer:WaitForChild("PlayerGui") end

    pcall(function()
        for _, g in ipairs(GUIParent:GetChildren()) do
            if g.Name == "EddiesGui" or g.Name == "EddiesFloat" or g.Name == "EddiesLoader" then
                g:Destroy()
            end
        end
    end)

    -- ── Premium Gold palette ────────────────────────────────────
    local C = {
        bg        = Color3.fromRGB(18, 16, 14),
        glass     = Color3.fromRGB(28, 24, 20),
        glassHi   = Color3.fromRGB(40, 34, 26),
        card      = Color3.fromRGB(34, 30, 24),
        cardHov   = Color3.fromRGB(46, 40, 30),
        accent    = Color3.fromRGB(255, 200, 80),
        accentB   = Color3.fromRGB(180, 130, 40),
        accentSoft= Color3.fromRGB(255, 225, 150),
        border    = Color3.fromRGB(80, 68, 45),
        borderSoft= Color3.fromRGB(60, 50, 34),
        text      = Color3.fromRGB(255, 245, 220),
        dim       = Color3.fromRGB(180, 160, 120),
        white     = Color3.fromRGB(255, 255, 255),
        on        = Color3.fromRGB(255, 200, 80),
        off       = Color3.fromRGB(50, 42, 30),
        red       = Color3.fromRGB(255, 100, 100),
        green     = Color3.fromRGB(120, 230, 160),
        yellow    = Color3.fromRGB(255, 220, 100),
    }

    -- ── state ───────────────────────────────────────────────────
    local State = {
        AimbotEnabled   = false, AimbotKey = nil, AimbotSmooth = 8,
        AimbotFOV       = 110,   ShowFOV = true, AimbotTarget = "Head",
        LockTeammates   = true,
        CameraFOV       = 70,
        TriggerEnabled  = false, TriggerKey = nil, TriggerAlwaysOn = false,
        WalkSpeed       = 16,    JumpPower = 50,
        InfJump         = false, Noclip = false, Fly = false, FlySpeed = 80,
        Sprint          = false, SprintSpeed = 60,
        Fullbright      = false, NoFog = false,
        ESP             = false, ESPTeam = false, FPSBoost = false,
        AntiAFK         = false, AutoClick = false, AutoClickRate = 0.1,
        UIKey           = Enum.KeyCode.Q,
    }

    -- ── helpers ─────────────────────────────────────────────────
    local function corner(o, r)
        local c = Instance.new("UICorner", o)
        c.CornerRadius = UDim.new(0, r or 10)
        return c
    end
    local function stroke(o, col, thick, trans)
        local s = Instance.new("UIStroke", o)
        s.Color = col or C.border
        s.Thickness = thick or 1
        s.Transparency = trans or 0
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        return s
    end
    local function gradient(o, c1, c2, rot)
        local g = Instance.new("UIGradient", o)
        g.Color = ColorSequence.new(c1, c2)
        g.Rotation = rot or 0
        return g
    end

    -- ── FOV circle (aimbot range) ───────────────────────────────
    local FOVCircle = nil
    pcall(function()
        if Drawing and Drawing.new then
            FOVCircle = Drawing.new("Circle")
            FOVCircle.Color = C.accent
            FOVCircle.Thickness = 1.5
            FOVCircle.NumSides = 64
            FOVCircle.Filled = false
            FOVCircle.Transparency = 1
            FOVCircle.Visible = false
        end
    end)

    -- ════════════════════════════════════════════════════════════
    --  BOOT SPLASH
    -- ════════════════════════════════════════════════════════════
    local splash = Instance.new("ScreenGui")
    splash.Name = "EddiesLoader"
    splash.ResetOnSpawn = false
    splash.DisplayOrder = 1000
    splash.IgnoreGuiInset = true
    splash.Parent = GUIParent

    local veil = Instance.new("Frame", splash)
    veil.Size = UDim2.new(1,0,1,0)
    veil.BackgroundColor3 = Color3.fromRGB(0,0,0)
    veil.BackgroundTransparency = 1
    veil.BorderSizePixel = 0
    TweenService:Create(veil, TweenInfo.new(0.45), {BackgroundTransparency = 0.55}):Play()

    local boot = Instance.new("Frame", splash)
    boot.AnchorPoint = Vector2.new(0.5, 0.5)
    boot.Position = UDim2.new(0.5, 0, 0.65, 0)
    boot.Size = UDim2.new(0, 460, 0, 220)
    boot.BackgroundColor3 = C.glass
    boot.BackgroundTransparency = 0.08
    boot.BorderSizePixel = 0
    boot.ClipsDescendants = true
    corner(boot, 18)
    stroke(boot, C.border, 1)

    local glow = Instance.new("Frame", boot)
    glow.Size = UDim2.new(1, 0, 0, 3)
    glow.BackgroundColor3 = C.accent
    glow.BorderSizePixel = 0
    gradient(glow, C.accentSoft, C.accentB, 0)

    local mark = Instance.new("Frame", boot)
    mark.Size = UDim2.new(0, 54, 0, 54)
    mark.Position = UDim2.new(0, 28, 0, 30)
    mark.BackgroundColor3 = C.accentB
    mark.BorderSizePixel = 0
    corner(mark, 14)
    gradient(mark, C.accentSoft, C.accentB, 45)

    local markTxt = Instance.new("TextLabel", mark)
    markTxt.Size = UDim2.new(1,0,1,0)
    markTxt.BackgroundTransparency = 1
    markTxt.Text = "E"
    markTxt.TextColor3 = C.bg
    markTxt.Font = Enum.Font.GothamBlack
    markTxt.TextSize = 32

    local bTitle = Instance.new("TextLabel", boot)
    bTitle.Size = UDim2.new(1, -110, 0, 26)
    bTitle.Position = UDim2.new(0, 96, 0, 36)
    bTitle.BackgroundTransparency = 1
    bTitle.Text = "Eddie's Premium Hub"
    bTitle.TextColor3 = C.text
    bTitle.Font = Enum.Font.GothamBlack
    bTitle.TextSize = 18
    bTitle.TextXAlignment = Enum.TextXAlignment.Left

    local bTag = Instance.new("TextLabel", boot)
    bTag.Size = UDim2.new(1, -110, 0, 16)
    bTag.Position = UDim2.new(0, 96, 0, 60)
    bTag.BackgroundTransparency = 1
    bTag.Text = "WindUI  ·  Premium  ·  Universal"
    bTag.TextColor3 = C.accent
    bTag.Font = Enum.Font.GothamBold
    bTag.TextSize = 11
    bTag.TextXAlignment = Enum.TextXAlignment.Left

    local bStatus = Instance.new("TextLabel", boot)
    bStatus.Size = UDim2.new(1, -56, 0, 16)
    bStatus.Position = UDim2.new(0, 28, 0, 110)
    bStatus.BackgroundTransparency = 1
    bStatus.Text = "Booting..."
    bStatus.TextColor3 = C.dim
    bStatus.Font = Enum.Font.Gotham
    bStatus.TextSize = 11
    bStatus.TextXAlignment = Enum.TextXAlignment.Left

    local track = Instance.new("Frame", boot)
    track.Size = UDim2.new(1, -56, 0, 6)
    track.Position = UDim2.new(0, 28, 0, 134)
    track.BackgroundColor3 = C.off
    track.BorderSizePixel = 0
    corner(track, 3)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0
    corner(fill, 3)
    gradient(fill, C.accentSoft, C.accentB, 0)

    local pct = Instance.new("TextLabel", boot)
    pct.Size = UDim2.new(1, -56, 0, 16)
    pct.Position = UDim2.new(0, 28, 0, 148)
    pct.BackgroundTransparency = 1
    pct.Text = "0%"
    pct.TextColor3 = C.accent
    pct.Font = Enum.Font.GothamBold
    pct.TextSize = 10
    pct.TextXAlignment = Enum.TextXAlignment.Right

    local stamp = Instance.new("TextLabel", boot)
    stamp.Size = UDim2.new(1, -56, 0, 16)
    stamp.Position = UDim2.new(0, 28, 1, -26)
    stamp.BackgroundTransparency = 1
    stamp.Text = "v1.0  ·  premium"
    stamp.TextColor3 = C.border
    stamp.Font = Enum.Font.Gotham
    stamp.TextSize = 9
    stamp.TextXAlignment = Enum.TextXAlignment.Right

    TweenService:Create(boot, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    task.wait(0.6)

    local BOOT_STEPS = {
        { sub = "Loading services",   t = 0.30 },
        { sub = "Hooking input",      t = 0.30 },
        { sub = "Building interface", t = 0.40 },
        { sub = "Ready",              t = 0.25 },
    }

    for i, step in ipairs(BOOT_STEPS) do
        bStatus.Text = step.sub .. "..."
        local p = i / #BOOT_STEPS
        TweenService:Create(fill, TweenInfo.new(step.t, Enum.EasingStyle.Quad), {
            Size = UDim2.new(p, 0, 1, 0)
        }):Play()
        pct.Text = math.floor(p * 100) .. "%"
        task.wait(step.t)
    end

    bStatus.Text = "Ready"
    bStatus.TextColor3 = C.green
    task.wait(0.3)

    TweenService:Create(boot, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 0, -0.4, 0)
    }):Play()
    TweenService:Create(veil, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
    task.wait(0.42)
    splash:Destroy()

    -- ════════════════════════════════════════════════════════════
    --  MAIN WINDOW
    -- ════════════════════════════════════════════════════════════
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "EddiesGui"
    Gui.ResetOnSpawn = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Gui.DisplayOrder = 999
    Gui.IgnoreGuiInset = true
    Gui.Parent = GUIParent

    local Win = Instance.new("Frame", Gui)
    Win.Size = UDim2.new(0, 500, 0, 360)
    Win.Position = UDim2.new(0.5, -250, 0.5, -180)
    Win.BackgroundColor3 = C.glass
    Win.BackgroundTransparency = 0.06
    Win.BorderSizePixel = 0
    Win.ClipsDescendants = true
    Win.Active = true
    corner(Win, 16)
    local winStroke = stroke(Win, C.border, 1)

    local winGlow = Instance.new("Frame", Win)
    winGlow.Size = UDim2.new(1, 0, 0, 1)
    winGlow.Position = UDim2.new(0, 0, 0, 0)
    winGlow.BackgroundColor3 = C.accentSoft
    winGlow.BackgroundTransparency = 0.4
    winGlow.BorderSizePixel = 0
    winGlow.ZIndex = 3

    local TBar = Instance.new("Frame", Win)
    TBar.Size = UDim2.new(1, 0, 0, 44)
    TBar.BackgroundColor3 = C.glassHi
    TBar.BackgroundTransparency = 0.35
    TBar.BorderSizePixel = 0

    local TBarDiv = Instance.new("Frame", TBar)
    TBarDiv.Size = UDim2.new(1, 0, 0, 1)
    TBarDiv.Position = UDim2.new(0, 0, 1, -1)
    TBarDiv.BackgroundColor3 = C.borderSoft
    TBarDiv.BorderSizePixel = 0

    local mark2 = Instance.new("Frame", TBar)
    mark2.Size = UDim2.new(0, 26, 0, 26)
    mark2.Position = UDim2.new(0, 16, 0.5, -13)
    mark2.BackgroundColor3 = C.accentB
    mark2.BorderSizePixel = 0
    corner(mark2, 8)
    gradient(mark2, C.accentSoft, C.accentB, 45)

    local mark2Txt = Instance.new("TextLabel", mark2)
    mark2Txt.Size = UDim2.new(1,0,1,0)
    mark2Txt.BackgroundTransparency = 1
    mark2Txt.Text = "E"
    mark2Txt.TextColor3 = C.bg
    mark2Txt.Font = Enum.Font.GothamBlack
    mark2Txt.TextSize = 14

    local TTitle = Instance.new("TextLabel", TBar)
    TTitle.Size = UDim2.new(1, -220, 1, 0)
    TTitle.Position = UDim2.new(0, 52, 0, 0)
    TTitle.BackgroundTransparency = 1
    TTitle.Text = "Eddie's Premium Hub"
    TTitle.TextColor3 = C.text
    TTitle.Font = Enum.Font.GothamBlack
    TTitle.TextSize = 14
    TTitle.TextXAlignment = Enum.TextXAlignment.Left

    local TBadge = Instance.new("Frame", TBar)
    TBadge.Size = UDim2.new(0, 66, 0, 18)
    TBadge.Position = UDim2.new(0, 176, 0.5, -9)
    TBadge.BackgroundColor3 = C.accentB
    TBadge.BackgroundTransparency = 0.35
    TBadge.BorderSizePixel = 0
    corner(TBadge, 9)
    stroke(TBadge, C.accent, 1, 0.3)
    local TBadgeTxt = Instance.new("TextLabel", TBadge)
    TBadgeTxt.Size = UDim2.new(1,0,1,0)
    TBadgeTxt.BackgroundTransparency = 1
    TBadgeTxt.Text = "PREMIUM"
    TBadgeTxt.TextColor3 = C.accent
    TBadgeTxt.Font = Enum.Font.GothamBlack
    TBadgeTxt.TextSize = 9

    local function headerBtn(xOff, lbl, isClose)
        local b = Instance.new("TextButton", TBar)
        b.Size = UDim2.new(0, 24, 0, 24)
        b.Position = UDim2.new(1, xOff, 0.5, -12)
        b.BackgroundColor3 = isClose and C.red or C.card
        b.BackgroundTransparency = 0.55
        b.BorderSizePixel = 0
        b.Text = lbl
        b.TextColor3 = isClose and C.white or C.dim
        b.Font = Enum.Font.GothamBold
        b.TextSize = 12
        b.AutoButtonColor = false
        corner(b, 8)
        stroke(b, isClose and C.red or C.borderSoft, 1, 0.3)
        return b
    end

    local HideBtn  = headerBtn(-36, "−", false)
    local CloseBtn = headerBtn(-68, "×", true)

    local Sidebar = Instance.new("Frame", Win)
    Sidebar.Size = UDim2.new(0, 118, 1, -76)
    Sidebar.Position = UDim2.new(0, 0, 0, 44)
    Sidebar.BackgroundColor3 = C.glassHi
    Sidebar.BackgroundTransparency = 0.55
    Sidebar.BorderSizePixel = 0

    local SideDiv = Instance.new("Frame", Win)
    SideDiv.Size = UDim2.new(0, 1, 1, -76)
    SideDiv.Position = UDim2.new(0, 118, 0, 44)
    SideDiv.BackgroundColor3 = C.borderSoft
    SideDiv.BorderSizePixel = 0

    local ContentArea = Instance.new("Frame", Win)
    ContentArea.Size = UDim2.new(1, -119, 1, -76)
    ContentArea.Position = UDim2.new(0, 119, 0, 44)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ClipsDescendants = true

    local Footer = Instance.new("Frame", Win)
    Footer.Size = UDim2.new(1, 0, 0, 32)
    Footer.Position = UDim2.new(0, 0, 1, -32)
    Footer.BackgroundColor3 = C.glassHi
    Footer.BackgroundTransparency = 0.45
    Footer.BorderSizePixel = 0

    local FooterDiv = Instance.new("Frame", Footer)
    FooterDiv.Size = UDim2.new(1, 0, 0, 1)
    FooterDiv.Position = UDim2.new(0, 0, 0, 0)
    FooterDiv.BackgroundColor3 = C.borderSoft
    FooterDiv.BorderSizePixel = 0

    local FOwner = Instance.new("TextLabel", Footer)
    FOwner.Size = UDim2.new(0.5, -12, 1, 0)
    FOwner.Position = UDim2.new(0, 16, 0, 0)
    FOwner.BackgroundTransparency = 1
    FOwner.Text = "Eddie's Premium Hub  ·  keyless"
    FOwner.TextColor3 = C.dim
    FOwner.Font = Enum.Font.GothamBold
    FOwner.TextSize = 10
    FOwner.TextXAlignment = Enum.TextXAlignment.Left

    local FStats = Instance.new("TextLabel", Footer)
    FStats.Size = UDim2.new(0.5, -12, 1, 0)
    FStats.Position = UDim2.new(0.5, 0, 0, 0)
    FStats.BackgroundTransparency = 1
    FStats.Text = "premium gold edition"
    FStats.TextColor3 = C.dim
    FStats.Font = Enum.Font.Gotham
    FStats.TextSize = 10
    FStats.TextXAlignment = Enum.TextXAlignment.Right

    local FloatGui = Instance.new("ScreenGui")
    FloatGui.Name = "EddiesFloat"
    FloatGui.ResetOnSpawn = false
    FloatGui.DisplayOrder = 998
    FloatGui.Parent = GUIParent
    FloatGui.Enabled = false

    local FloatBtn = Instance.new("TextButton", FloatGui)
    FloatBtn.Size = UDim2.new(0, 190, 0, 36)
    FloatBtn.Position = UDim2.new(1, -206, 0, 14)
    FloatBtn.BackgroundColor3 = C.glass
    FloatBtn.BackgroundTransparency = 0.1
    FloatBtn.BorderSizePixel = 0
    FloatBtn.Text = ""
    FloatBtn.AutoButtonColor = false
    corner(FloatBtn, 18)
    local fStroke = stroke(FloatBtn, C.border, 1)

    local fMark = Instance.new("Frame", FloatBtn)
    fMark.Size = UDim2.new(0, 22, 0, 22)
    fMark.Position = UDim2.new(0, 8, 0.5, -11)
    fMark.BackgroundColor3 = C.accentB
    fMark.BorderSizePixel = 0
    corner(fMark, 7)
    gradient(fMark, C.accentSoft, C.accentB, 45)

    local fMarkTxt = Instance.new("TextLabel", fMark)
    fMarkTxt.Size = UDim2.new(1,0,1,0)
    fMarkTxt.BackgroundTransparency = 1
    fMarkTxt.Text = "E"
    fMarkTxt.TextColor3 = C.bg
    fMarkTxt.Font = Enum.Font.GothamBlack
    fMarkTxt.TextSize = 12

    local fTxt = Instance.new("TextLabel", FloatBtn)
    fTxt.Size = UDim2.new(1, -40, 1, 0)
    fTxt.Position = UDim2.new(0, 36, 0, 0)
    fTxt.BackgroundTransparency = 1
    fTxt.Text = "Eddie's Premium Hub"
    fTxt.TextColor3 = C.text
    fTxt.Font = Enum.Font.GothamBold
    fTxt.TextSize = 12
    fTxt.TextXAlignment = Enum.TextXAlignment.Left

    HideBtn.MouseButton1Click:Connect(function() Gui.Enabled = false; FloatGui.Enabled = true end)
    CloseBtn.MouseButton1Click:Connect(function() Gui:Destroy(); FloatGui:Destroy() end)
    FloatBtn.MouseButton1Click:Connect(function() Gui.Enabled = true; FloatGui.Enabled = false end)

    local dragOn, dragStart, winStart = false, nil, nil
    TBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragOn = true; dragStart = inp.Position; winStart = Win.Position
        end
    end)
    TBar.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragOn = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not dragOn then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
            Win.Position = UDim2.new(
                winStart.X.Scale, winStart.X.Offset + (inp.Position.X - dragStart.X),
                winStart.Y.Scale, winStart.Y.Offset + (inp.Position.Y - dragStart.Y)
            )
        end
    end)

    -- ════════════════════════════════════════════════════════════
    --  TAB SYSTEM
    -- ════════════════════════════════════════════════════════════
    local tabs, tabBtns = {}, {}
    local activePage = nil

    local sidePad = Instance.new("UIPadding", Sidebar)
    sidePad.PaddingTop = UDim.new(0, 12)
    sidePad.PaddingLeft = UDim.new(0, 10)
    sidePad.PaddingRight = UDim.new(0, 10)
    local sideList = Instance.new("UIListLayout", Sidebar)
    sideList.SortOrder = Enum.SortOrder.LayoutOrder
    sideList.Padding = UDim.new(0, 6)

    local function setPage(name)
        if activePage == name then return end
        activePage = name
        for n, pg in pairs(tabs) do pg.Visible = (n == name) end
        for n, btn in pairs(tabBtns) do
            local on = (n == name)
            TweenService:Create(btn, TweenInfo.new(0.18), {
                BackgroundTransparency = on and 0.15 or 1,
                BackgroundColor3 = on and C.accentB or C.card,
            }):Play()
            local ico = btn:FindFirstChild("Ico")
            local lb  = btn:FindFirstChild("Lbl")
            if ico then ico.TextColor3 = on and C.white or C.dim end
            if lb  then lb.TextColor3  = on and C.white or C.dim end
            local s = btn:FindFirstChildOfClass("UIStroke")
            if s then
                TweenService:Create(s, TweenInfo.new(0.18), {
                    Color = on and C.accent or C.borderSoft,
                    Transparency = on and 0 or 0.5,
                }):Play()
            end
        end
    end

    local function addTab(name, icon, order)
        local btn = Instance.new("TextButton", Sidebar)
        btn.Size = UDim2.new(1, 0, 0, 36)
        btn.BackgroundColor3 = C.card
        btn.BackgroundTransparency = 1
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.LayoutOrder = order
        corner(btn, 10)
        local s = stroke(btn, C.borderSoft, 1, 0.5)

        local ico = Instance.new("TextLabel", btn)
        ico.Name = "Ico"
        ico.Size = UDim2.new(0, 22, 0, 22)
        ico.Position = UDim2.new(0, 8, 0.5, -11)
        ico.BackgroundTransparency = 1
        ico.Text = icon
        ico.TextSize = 14
        ico.Font = Enum.Font.GothamBold
        ico.TextColor3 = C.dim

        local lb = Instance.new("TextLabel", btn)
        lb.Name = "Lbl"
        lb.Size = UDim2.new(1, -40, 1, 0)
        lb.Position = UDim2.new(0, 36, 0, 0)
        lb.BackgroundTransparency = 1
        lb.Text = name
        lb.TextSize = 12
        lb.Font = Enum.Font.GothamBold
        lb.TextColor3 = C.dim
        lb.TextXAlignment = Enum.TextXAlignment.Left

        btn.MouseButton1Click:Connect(function() setPage(name) end)
        btn.MouseEnter:Connect(function()
            if activePage ~= name then
                TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundTransparency = 0.7 }):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if activePage ~= name then
                TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundTransparency = 1 }):Play()
            end
        end)

        local pg = Instance.new("ScrollingFrame", ContentArea)
        pg.Size = UDim2.new(1, 0, 1, 0)
        pg.BackgroundTransparency = 1
        pg.BorderSizePixel = 0
        pg.ScrollBarThickness = 2
        pg.ScrollBarImageColor3 = C.border
        pg.ScrollBarImageTransparency = 0.5
        pg.AutomaticCanvasSize = Enum.AutomaticSize.Y
        pg.CanvasSize = UDim2.new(0, 0, 0, 0)
        pg.Visible = false
        local pl = Instance.new("UIListLayout", pg)
        pl.SortOrder = Enum.SortOrder.LayoutOrder
        pl.Padding = UDim.new(0, 5)
        local pp = Instance.new("UIPadding", pg)
        pp.PaddingTop = UDim.new(0, 12)
        pp.PaddingLeft = UDim.new(0, 12)
        pp.PaddingRight = UDim.new(0, 12)
        pp.PaddingBottom = UDim.new(0, 12)

        tabs[name] = pg
        tabBtns[name] = btn
        return pg
    end

    local rowOrder = 0
    local function nxt() rowOrder = rowOrder + 1; return rowOrder end

    local function secLabel(pg, text)
        local l = Instance.new("TextLabel", pg)
        l.Size = UDim2.new(1, 0, 0, 20)
        l.BackgroundTransparency = 1
        l.Text = text:upper()
        l.TextColor3 = C.accentSoft
        l.Font = Enum.Font.GothamBold
        l.TextSize = 10
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.LayoutOrder = nxt()
    end

    local function toggleRow(pg, label, default, cb)
        local row = Instance.new("Frame", pg)
        row.Size = UDim2.new(1, 0, 0, 34)
        row.BackgroundColor3 = C.card
        row.BackgroundTransparency = 0.25
        row.BorderSizePixel = 0
        row.LayoutOrder = nxt()
        corner(row, 10)
        stroke(row, C.borderSoft, 1, 0.5)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -70, 1, 0)
        lbl.Position = UDim2.new(0, 14, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = C.text
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local sw = Instance.new("Frame", row)
        sw.Size = UDim2.new(0, 40, 0, 22)
        sw.Position = UDim2.new(1, -54, 0.5, -11)
        sw.BackgroundColor3 = default and C.on or C.off
        sw.BackgroundTransparency = default and 0 or 0.3
        sw.BorderSizePixel = 0
        corner(sw, 11)
        stroke(sw, default and C.accent or C.borderSoft, 1, 0.3)

        local knob = Instance.new("Frame", sw)
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        knob.BackgroundColor3 = C.white
        knob.BorderSizePixel = 0
        corner(knob, 8)

        local st = default
        local clk = Instance.new("TextButton", row)
        clk.Size = UDim2.new(1, 0, 1, 0)
        clk.BackgroundTransparency = 1
        clk.Text = ""
        clk.ZIndex = 2
        clk.MouseButton1Click:Connect(function()
            st = not st
            TweenService:Create(sw, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                BackgroundColor3 = st and C.on or C.off,
                BackgroundTransparency = st and 0 or 0.3,
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.22, Enum.EasingStyle.Back), {
                Position = st and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
            }):Play()
            cb(st)
        end)
    end

    local function sliderRow(pg, label, min, max, default, cb)
        local row = Instance.new("Frame", pg)
        row.Size = UDim2.new(1, 0, 0, 48)
        row.BackgroundColor3 = C.card
        row.BackgroundTransparency = 0.25
        row.BorderSizePixel = 0
        row.LayoutOrder = nxt()
        corner(row, 10)
        stroke(row, C.borderSoft, 1, 0.5)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0.6, 0, 0, 18)
        lbl.Position = UDim2.new(0, 14, 0, 8)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = C.text
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local val = Instance.new("TextLabel", row)
        val.Size = UDim2.new(0.4, -14, 0, 18)
        val.Position = UDim2.new(0.6, 0, 0, 8)
        val.BackgroundTransparency = 1
        val.Text = tostring(default)
        val.TextColor3 = C.accent
        val.Font = Enum.Font.GothamBold
        val.TextSize = 12
        val.TextXAlignment = Enum.TextXAlignment.Right

        local track = Instance.new("Frame", row)
        track.Size = UDim2.new(1, -28, 0, 6)
        track.Position = UDim2.new(0, 14, 0, 32)
        track.BackgroundColor3 = C.off
        track.BorderSizePixel = 0
        corner(track, 3)

        local fill = Instance.new("Frame", track)
        fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
        fill.BackgroundColor3 = C.accent
        fill.BorderSizePixel = 0
        corner(fill, 3)
        gradient(fill, C.accentSoft, C.accentB, 0)

        local knob = Instance.new("Frame", track)
        knob.Size = UDim2.new(0, 12, 0, 12)
        knob.Position = UDim2.new((default-min)/(max-min), -6, 0.5, -6)
        knob.BackgroundColor3 = C.white
        knob.BorderSizePixel = 0
        corner(knob, 6)

        local dragging = false
        local clk = Instance.new("TextButton", row)
        clk.Size = UDim2.new(1, 0, 1, 0)
        clk.BackgroundTransparency = 1
        clk.Text = ""
        clk.ZIndex = 2

        local function update(input)
            local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local v = math.floor(min + (max-min) * rel)
            val.Text = tostring(v)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -6, 0.5, -6)
            cb(v)
        end

        clk.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; update(input)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    local function buttonRow(pg, label, col, cb)
        local row = Instance.new("TextButton", pg)
        row.Size = UDim2.new(1, 0, 0, 34)
        row.BackgroundColor3 = C.card
        row.BackgroundTransparency = 0.25
        row.BorderSizePixel = 0
        row.LayoutOrder = nxt()
        row.Text = ""
        row.AutoButtonColor = false
        corner(row, 10)
        stroke(row, C.borderSoft, 1, 0.5)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -20, 1, 0)
        lbl.Position = UDim2.new(0, 14, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = col or C.text
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        row.MouseButton1Click:Connect(function() if cb then cb() end end)
    end

    local function keybindRow(pg, label, defaultKey, cb)
        local row = Instance.new("Frame", pg)
        row.Size = UDim2.new(1, 0, 0, 34)
        row.BackgroundColor3 = C.card
        row.BackgroundTransparency = 0.25
        row.BorderSizePixel = 0
        row.LayoutOrder = nxt()
        corner(row, 10)
        stroke(row, C.borderSoft, 1, 0.5)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0.5, 0, 1, 0)
        lbl.Position = UDim2.new(0, 14, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = C.text
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local kb = Instance.new("TextButton", row)
        kb.Size = UDim2.new(0, 90, 0, 24)
        kb.Position = UDim2.new(1, -104, 0.5, -12)
        kb.BackgroundColor3 = C.off
        kb.BackgroundTransparency = 0.2
        kb.BorderSizePixel = 0
        kb.Text = defaultKey
        kb.TextColor3 = C.accent
        kb.Font = Enum.Font.GothamBold
        kb.TextSize = 11
        kb.AutoButtonColor = false
        corner(kb, 8)
        stroke(kb, C.borderSoft, 1, 0.4)

        local listening = false
        kb.MouseButton1Click:Connect(function()
            if listening then return end
            listening = true
            kb.Text = "Press..."
            kb.TextColor3 = C.yellow
            local conn
            conn = UserInputService.InputBegan:Connect(function(input, gp)
                if gp then return end
                if input.UserInputType == Enum.UserInputType.Keyboard
                or input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.MouseButton2
                or input.UserInputType == Enum.UserInputType.MouseButton3 then
                    local key = input.UserInputType ~= Enum.UserInputType.Keyboard and input.UserInputType or input.KeyCode
                    local name = input.UserInputType == Enum.UserInputType.Keyboard
                        and tostring(input.KeyCode):gsub("Enum.KeyCode.","")
                        or tostring(input.UserInputType):gsub("Enum.UserInputType.","")
                    kb.Text = name
                    kb.TextColor3 = C.green
                    listening = false
                    cb(key)
                    conn:Disconnect()
                end
            end)
        end)
    end

    -- ════════════════════════════════════════════════════════════
    --  PAGES
    -- ════════════════════════════════════════════════════════════
    local aimPage = addTab("Aimbot", "🎯", 1)
    secLabel(aimPage, "Aimbot")
    toggleRow(aimPage, "Enable Aimbot", false, function(v) State.AimbotEnabled = v end)
    keybindRow(aimPage, "Aim Key", "NONE", function(k) State.AimbotKey = k end)
    secLabel(aimPage, "Filters")
    toggleRow(aimPage, "Lock Teammates", true, function(v) State.LockTeammates = v end)
    secLabel(aimPage, "Settings")
    sliderRow(aimPage, "FOV Radius", 10, 500, 110, function(v) State.AimbotFOV = v end)
    sliderRow(aimPage, "Smoothness", 1, 20, 8, function(v) State.AimbotSmooth = v end)
    toggleRow(aimPage, "Show FOV Circle", true, function(v) State.ShowFOV = v end)

    local trigPage = addTab("Trigger", "⚡", 2)
    secLabel(trigPage, "Triggerbot")
    toggleRow(trigPage, "Enable Trigger", false, function(v) State.TriggerEnabled = v end)
    keybindRow(trigPage, "Trigger Key", "NONE", function(k) State.TriggerKey = k end)
    toggleRow(trigPage, "Always On", false, function(v) State.TriggerAlwaysOn = v end)

    local movPage = addTab("Movement", "🏃", 3)
    secLabel(movPage, "Character")
    sliderRow(movPage, "Walk Speed", 16, 200, 16, function(v)
        State.WalkSpeed = v
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and not State.Sprint then hum.WalkSpeed = v end
    end)
    sliderRow(movPage, "Jump Power", 50, 300, 50, function(v)
        State.JumpPower = v
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
    end)
    secLabel(movPage, "Abilities")
    toggleRow(movPage, "Infinite Jump", false, function(v) State.InfJump = v end)
    toggleRow(movPage, "Noclip", false, function(v) State.Noclip = v end)
    toggleRow(movPage, "Sprint", false, function(v) State.Sprint = v end)
    sliderRow(movPage, "Sprint Speed", 30, 300, 60, function(v) State.SprintSpeed = v end)
    toggleRow(movPage, "Fly", false, function(v)
        State.Fly = v
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if v then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "EPHFly"
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bv.Velocity = Vector3.new(0,0,0)
            bv.Parent = hrp
            local bg = Instance.new("BodyGyro")
            bg.Name = "EPHFlyGyro"
            bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
            bg.P = 1000
            bg.D = 50
            bg.CFrame = hrp.CFrame
            bg.Parent = hrp
        else
            for _, n in ipairs({"EPHFly","EPHFlyGyro"}) do
                local o = hrp:FindFirstChild(n)
                if o then o:Destroy() end
            end
        end
    end)
    sliderRow(movPage, "Fly Speed", 10, 400, 80, function(v) State.FlySpeed = v end)

    local visPage = addTab("Visuals", "👁", 4)
    secLabel(visPage, "Camera")
    sliderRow(visPage, "Camera FOV", 40, 120, 70, function(v) State.CameraFOV = v end)
    buttonRow(visPage, "Reset Camera FOV", C.dim, function()
        State.CameraFOV = 70
        Camera.FieldOfView = 70
    end)
    secLabel(visPage, "ESP")
    toggleRow(visPage, "Player ESP", false, function(v) State.ESP = v end)
    toggleRow(visPage, "Show Teammates", false, function(v) State.ESPTeam = v end)
    secLabel(visPage, "Lighting")
    toggleRow(visPage, "Fullbright", false, function(v)
        State.Fullbright = v
        if v then
            Lighting.Ambient = Color3.fromRGB(255,255,255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
            Lighting.Brightness = 2
        else
            Lighting.Ambient = Color3.fromRGB(70,70,70)
            Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
            Lighting.Brightness = 1
        end
    end)
    toggleRow(visPage, "No Fog", false, function(v)
        State.NoFog = v
        Lighting.FogEnd = v and 9e9 or 100000
    end)
    secLabel(visPage, "Performance")
    toggleRow(visPage, "FPS Boost", false, function(v)
        State.FPSBoost = v
        if v then
            Lighting.GlobalShadows = false
            pcall(function() Lighting.ShadowSoftness = 0 end)
        else
            Lighting.GlobalShadows = true
        end
    end)

    local utilPage = addTab("Utility", "🛠", 5)
    secLabel(utilPage, "Automation")
    toggleRow(utilPage, "Anti-AFK", false, function(v) State.AntiAFK = v end)
    toggleRow(utilPage, "Auto Clicker", false, function(v) State.AutoClick = v end)
    sliderRow(utilPage, "Auto Click Rate (ms)", 10, 500, 100, function(v)
        State.AutoClickRate = v / 1000
    end)
    secLabel(utilPage, "Server")
    buttonRow(utilPage, "Rejoin Server", C.text, function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
    buttonRow(utilPage, "Server Hop", C.text, function()
        local TeleportService = game:GetService("TeleportService")
        local HttpService = game:GetService("HttpService")
        pcall(function()
            local servers = HttpService:JSONDecode(game:HttpGet(
                "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            ))
            for _, s in ipairs(servers.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                    break
                end
            end
        end)
    end)

    local cfgPage = addTab("Settings", "⚙", 6)
    secLabel(cfgPage, "Keybinds")
    keybindRow(cfgPage, "Toggle UI", "Q", function(k) State.UIKey = k end)
    secLabel(cfgPage, "Info")
    local infoLbl = Instance.new("TextLabel", cfgPage)
    infoLbl.Size = UDim2.new(1, 0, 0, 60)
    infoLbl.BackgroundTransparency = 1
    infoLbl.Text = "Eddie's Premium Hub\nWindUI · Premium Gold Edition\nKeyless · Free"
    infoLbl.TextColor3 = C.dim
    infoLbl.Font = Enum.Font.Gotham
    infoLbl.TextSize = 11
    infoLbl.TextXAlignment = Enum.TextXAlignment.Left
    infoLbl.TextYAlignment = Enum.TextYAlignment.Top
    infoLbl.LayoutOrder = nxt()

    setPage("Aimbot")

    -- ════════════════════════════════════════════════════════════
    --  ESP SYSTEM
    -- ════════════════════════════════════════════════════════════
    local ESPTable, PlayerCache = {}, {}

    local function isTeammate(p)
        return LocalPlayer.Team and p.Team == LocalPlayer.Team
    end

    local function createESP(player)
        if player == LocalPlayer then return end
        local function onChar(char)
            local root = char:WaitForChild("HumanoidRootPart", 5)
            if not root then return end
            local box = Instance.new("BoxHandleAdornment", Workspace)
            box.Adornee = char
            box.Size = Vector3.new(4, 6, 2)
            box.AlwaysOnTop = true
            box.ZIndex = 5
            box.Transparency = 0.5
            box.Color3 = C.accent
            box.Visible = false
            ESPTable[player] = { Box = box, Char = char }
        end
        if player.Character then onChar(player.Character) end
        player.CharacterAdded:Connect(onChar)
    end

    local function addPlayer(p)
        if p ~= LocalPlayer then
            PlayerCache[p] = true
            createESP(p)
        end
    end

    local function removePlayer(p)
        PlayerCache[p] = nil
        if ESPTable[p] then
            for _, v in pairs(ESPTable[p]) do
                if typeof(v) == "Instance" then v:Destroy() end
            end
            ESPTable[p] = nil
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do addPlayer(p) end
    Players.PlayerAdded:Connect(addPlayer)
    Players.PlayerRemoving:Connect(removePlayer)

    -- ════════════════════════════════════════════════════════════
    --  AIMBOT + TRIGGER
    -- ════════════════════════════════════════════════════════════
    local isSimulating = false

    local function isKeyHeld(key)
        if not key then return false end
        if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
            return UserInputService:IsKeyDown(key)
        elseif key == Enum.UserInputType.MouseButton1 then
            return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        elseif key == Enum.UserInputType.MouseButton2 then
            return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        elseif key == Enum.UserInputType.MouseButton3 then
            return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton3)
        end
        return false
    end

    local function getTargetPart(char)
        return char:FindFirstChild(State.AimbotTarget == "Head" and "Head" or "HumanoidRootPart")
    end

    local function findClosestTarget()
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local best, bestDist = nil, State.AimbotFOV
        for p in pairs(PlayerCache) do
            local char = p.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                local part = getTargetPart(char)
                if hum and hum.Health > 0 and part then
                    if not (State.LockTeammates and isTeammate(p)) then
                        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                            if dist < bestDist then
                                best = part
                                bestDist = dist
                            end
                        end
                    end
                end
            end
        end
        return best
    end

    local function isLookingAtEnemy()
        local unitRay = Camera:ScreenPointToRay(mouse.X, mouse.Y)
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = { LocalPlayer.Character }
        params.FilterType = Enum.RaycastFilterType.Exclude
        local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, params)
        if not result then return nil end
        local model = result.Instance:FindFirstAncestorOfClass("Model")
        if not model then return nil end
        local hum = model:FindFirstChildOfClass("Humanoid")
        if not hum then return nil end
        local targetPlayer = Players:GetPlayerFromCharacter(model)
        if targetPlayer and (State.LockTeammates and isTeammate(targetPlayer)) then return nil end
        return model
    end

    local function startSimulate()
        if isSimulating then return end
        isSimulating = true
        pcall(function() mouse1press() end)
    end

    local function stopSimulate()
        if not isSimulating then return end
        isSimulating = false
        pcall(function() mouse1release() end)
    end

    UserInputService.JumpRequest:Connect(function()
        if State.InfJump then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)

    LocalPlayer.Idled:Connect(function()
        if State.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end)

    -- ════════════════════════════════════════════════════════════
    --  RENDER LOOP
    -- ════════════════════════════════════════════════════════════
    local espTick, aimTick, trigTick, clickTick = 0, 0, 0, 0
    local ESP_INTERVAL = 0.1
    local AIM_INTERVAL = 0.02
    local TRIG_INTERVAL = 0.05

    RunService.RenderStepped:Connect(function(dt)
        espTick = espTick + dt
        aimTick = aimTick + dt
        trigTick = trigTick + dt
        clickTick = clickTick + dt

        local doESP = espTick >= ESP_INTERVAL
        local doAim = aimTick >= AIM_INTERVAL
        local doTrig = trigTick >= TRIG_INTERVAL
        if doESP then espTick = 0 end
        if doAim then aimTick = 0 end
        if doTrig then trigTick = 0 end

        -- Aimbot FOV circle
        if FOVCircle then
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            FOVCircle.Radius = State.AimbotFOV
            FOVCircle.Color = C.accent
            FOVCircle.Visible = State.ShowFOV and State.AimbotEnabled
        end

        -- Camera FOV (screen widening)
        if Camera.FieldOfView ~= State.CameraFOV then
            Camera.FieldOfView = State.CameraFOV
        end

        if doESP then
            for p in pairs(PlayerCache) do
                local e = ESPTable[p]
                if e and e.Char then
                    local hum = e.Char:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 then
                        local tOK = not isTeammate(p) or State.ESPTeam
                        e.Box.Visible = State.ESP and tOK
                    else
                        e.Box.Visible = false
                    end
                end
            end
        end

        if State.AimbotEnabled and (State.AimbotKey == nil or isKeyHeld(State.AimbotKey)) then
            local target = findClosestTarget()
            if target then
                local camPos = Camera.CFrame.Position
                local goal = CFrame.new(camPos, target.Position)
                local smooth = math.clamp(State.AimbotSmooth, 1, 20)
                Camera.CFrame = Camera.CFrame:Lerp(goal, 1 / smooth)
            end
        end

        if State.TriggerEnabled then
            local active = State.TriggerAlwaysOn
            if not active and State.TriggerKey then
                active = isKeyHeld(State.TriggerKey)
            end
            if active and isLookingAtEnemy() then
                startSimulate()
            else
                stopSimulate()
            end
        else
            stopSimulate()
        end

        if State.AutoClick and clickTick >= State.AutoClickRate then
            clickTick = 0
            pcall(function() mouse1click() end)
        end

        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if State.Noclip and char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end

        if State.Sprint and hum then
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                hum.WalkSpeed = State.SprintSpeed
            else
                hum.WalkSpeed = State.WalkSpeed
            end
        end

        if State.Fly and hrp then
            local bv = hrp:FindFirstChild("EPHFly")
            local bg = hrp:FindFirstChild("EPHFlyGyro")
            if bv and bg and hum then
                local cam = Camera.CFrame
                local move = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
                bv.Velocity = move * State.FlySpeed
                bg.CFrame = cam
                hum.PlatformStand = true
            end
        else
            if hum and hum.PlatformStand then hum.PlatformStand = false end
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum.WalkSpeed = State.WalkSpeed
            hum.JumpPower = State.JumpPower
        end
    end)

    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == State.UIKey then
            Gui.Enabled = not Gui.Enabled
            if Gui.Enabled then FloatGui.Enabled = false end
        end
    end)
end

local ok, err = pcall(__main)
if not ok then warn("[Eddie's Premium Hub] Error: " .. tostring(err)) end
