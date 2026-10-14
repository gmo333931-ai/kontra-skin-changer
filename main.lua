--[[
    KONTRA CLIENT SUITE v2
    Luau / Roblox Executor Environment
    Full rewrite — sectioned menu, extended visuals, clean unloader
]]

-- ========== SERVICES ==========
local Players       = game:GetService("Players")
local Lighting      = game:GetService("Lighting")
local TweenService  = game:GetService("TweenService")
local UIS           = game:GetService("UserInputService")
local RunService    = game:GetService("RunService")
local CoreGui       = game:GetService("CoreGui")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ========== ORIGINALS (для чистого Unload) ==========
local ORIG = {
    FogColor   = Lighting.FogColor,
    FogStart   = Lighting.FogStart,
    FogEnd     = Lighting.FogEnd,
    ClockTime  = Lighting.ClockTime,
    Brightness = Lighting.Brightness,
    FOV        = Camera.FieldOfView,
}

-- ========== CONNECTIONS TRACKER ==========
local CONNS = {}
local function Track(c) table.insert(CONNS, c) return c end

-- ========== KILL OLD VERSION ==========
if CoreGui:FindFirstChild("KontraSuiteV2") then
    CoreGui.KontraSuiteV2:Destroy()
    task.wait(0.1)
end

-- ========== SCREENGUI ==========
local Gui = Instance.new("ScreenGui")
Gui.Name = "KontraSuiteV2"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(Gui)
        Gui.Parent = CoreGui
    elseif gethui then
        Gui.Parent = gethui()
    else
        Gui.Parent = CoreGui
    end
end)

if not Gui.Parent then
    Gui.Parent = LP:WaitForChild("PlayerGui")
end

-- ========== ЦВЕТА ТЕМЫ ==========
local THEME = {
    Bg        = Color3.fromRGB(14, 14, 20),
    Card      = Color3.fromRGB(22, 22, 30),
    CardHover = Color3.fromRGB(28, 28, 38),
    Accent    = Color3.fromRGB(130, 80, 255),
    AccentDim = Color3.fromRGB(50, 50, 65),
    Text      = Color3.fromRGB(235, 235, 250),
    TextDim   = Color3.fromRGB(140, 140, 165),
    Red       = Color3.fromRGB(200, 50, 60),
    Section   = Color3.fromRGB(130, 80, 255),
}

-- ==================================================================
--  1. WATERMARK
-- ==================================================================
local WmFrame = Instance.new("Frame")
WmFrame.Size = UDim2.fromOffset(270, 26)
WmFrame.Position = UDim2.fromOffset(14, 14)
WmFrame.BackgroundColor3 = THEME.Bg
WmFrame.BackgroundTransparency = 0.18
WmFrame.BorderSizePixel = 0
WmFrame.Parent = Gui

Instance.new("UICorner", WmFrame).CornerRadius = UDim.new(0, 6)
local wmS = Instance.new("UIStroke", WmFrame)
wmS.Color = THEME.Accent
wmS.Transparency = 0.5

local WmLabel = Instance.new("TextLabel")
WmLabel.Size = UDim2.new(1, -14, 1, 0)
WmLabel.Position = UDim2.fromOffset(8, 0)
WmLabel.BackgroundTransparency = 1
WmLabel.Font = Enum.Font.GothamMedium
WmLabel.TextSize = 11
WmLabel.TextColor3 = THEME.Text
WmLabel.TextXAlignment = Enum.TextXAlignment.Left
WmLabel.Text = "KONTRA CLIENT v2"
WmLabel.Parent = WmFrame

local fpsCount = 0
local fpsLast = os.clock()
Track(RunService.RenderStepped:Connect(function()
    fpsCount = fpsCount + 1
    local now = os.clock()
    if now - fpsLast >= 1 then
        local fps = fpsCount
        fpsCount = 0
        fpsLast = now
        local ping = 0
        pcall(function()
            ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        WmLabel.Text = string.format("KONTRA v2 | %s | %d FPS | %dms", LP.DisplayName, fps, ping)
    end
end))

-- ==================================================================
--  2. TARGET HUD
-- ==================================================================
local TH = Instance.new("Frame")
TH.Size = UDim2.fromOffset(220, 68)
TH.Position = UDim2.new(0.5, -110, 0.62, 0)
TH.BackgroundColor3 = THEME.Bg
TH.BackgroundTransparency = 0.15
TH.BorderSizePixel = 0
TH.Visible = false
TH.Parent = Gui

Instance.new("UICorner", TH).CornerRadius = UDim.new(0, 10)
local thS = Instance.new("UIStroke", TH)
thS.Color = THEME.Accent
thS.Transparency = 0.35

local THAvatar = Instance.new("ImageLabel")
THAvatar.Size = UDim2.fromOffset(42, 42)
THAvatar.Position = UDim2.fromOffset(10, 13)
THAvatar.BackgroundColor3 = THEME.Card
THAvatar.BorderSizePixel = 0
THAvatar.Parent = TH
Instance.new("UICorner", THAvatar).CornerRadius = UDim.new(0, 6)

local THName = Instance.new("TextLabel")
THName.Size = UDim2.new(1, -66, 0, 16)
THName.Position = UDim2.fromOffset(58, 10)
THName.BackgroundTransparency = 1
THName.Font = Enum.Font.GothamBold
THName.TextSize = 12
THName.TextColor3 = THEME.Text
THName.TextXAlignment = Enum.TextXAlignment.Left
THName.TextTruncate = Enum.TextTruncate.AtEnd
THName.Text = ""
THName.Parent = TH

local THInfo = Instance.new("TextLabel")
THInfo.Size = UDim2.new(1, -66, 0, 14)
THInfo.Position = UDim2.fromOffset(58, 26)
THInfo.BackgroundTransparency = 1
THInfo.Font = Enum.Font.Gotham
THInfo.TextSize = 10
THInfo.TextColor3 = THEME.TextDim
THInfo.TextXAlignment = Enum.TextXAlignment.Left
THInfo.Text = ""
THInfo.Parent = TH

local THBarBg = Instance.new("Frame")
THBarBg.Size = UDim2.new(1, -68, 0, 6)
THBarBg.Position = UDim2.fromOffset(58, 46)
THBarBg.BackgroundColor3 = THEME.AccentDim
THBarBg.BorderSizePixel = 0
THBarBg.Parent = TH
Instance.new("UICorner", THBarBg).CornerRadius = UDim.new(1, 0)

local THBarFill = Instance.new("Frame")
THBarFill.Size = UDim2.new(1, 0, 1, 0)
THBarFill.BackgroundColor3 = THEME.Accent
THBarFill.BorderSizePixel = 0
THBarFill.Parent = THBarBg
Instance.new("UICorner", THBarFill).CornerRadius = UDim.new(1, 0)

local thActive = true
local thCachedPlr = nil

Track(RunService.RenderStepped:Connect(function()
    if not thActive then TH.Visible = false return end

    local origin = Camera.CFrame.Position
    local dir = Camera.CFrame.LookVector * 280
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    if LP.Character then params.FilterDescendantsInstances = {LP.Character} end

    local hit = workspace:Raycast(origin, dir, params)
    local found = nil

    if hit and hit.Instance then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and hit.Instance:IsDescendantOf(p.Character) then
                found = p
                break
            end
        end
    end

    if found and found.Character then
        local hum = found.Character:FindFirstChildOfClass("Humanoid")
        local root = found.Character:FindFirstChild("HumanoidRootPart")
        if hum and hum.Health > 0 and root then
            TH.Visible = true
            THName.Text = found.DisplayName
            local d = math.floor((root.Position - origin).Magnitude)
            THInfo.Text = string.format("%d studs  |  %d HP", d, math.floor(hum.Health))
            local r = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            TweenService:Create(THBarFill, TweenInfo.new(0.12), {Size = UDim2.new(r, 0, 1, 0)}):Play()

            if thCachedPlr ~= found then
                thCachedPlr = found
                task.spawn(function()
                    pcall(function()
                        local url = Players:GetUserThumbnailAsync(found.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                        THAvatar.Image = url
                    end)
                end)
            end
            return
        end
    end
    TH.Visible = false
end))

-- ==================================================================
--  3. SPECTATOR LIST
-- ==================================================================
local SF = Instance.new("Frame")
SF.Size = UDim2.fromOffset(175, 100)
SF.Position = UDim2.new(1, -195, 0.38, 0)
SF.BackgroundColor3 = THEME.Bg
SF.BackgroundTransparency = 0.18
SF.BorderSizePixel = 0
SF.Visible = false
SF.Parent = Gui

Instance.new("UICorner", SF).CornerRadius = UDim.new(0, 8)
local sfS = Instance.new("UIStroke", SF)
sfS.Color = THEME.Accent
sfS.Transparency = 0.4

local SFTitle = Instance.new("TextLabel")
SFTitle.Size = UDim2.new(1, -12, 0, 22)
SFTitle.Position = UDim2.fromOffset(8, 3)
SFTitle.BackgroundTransparency = 1
SFTitle.Font = Enum.Font.GothamBold
SFTitle.TextSize = 11
SFTitle.TextColor3 = THEME.Text
SFTitle.TextXAlignment = Enum.TextXAlignment.Left
SFTitle.Text = "SPECTATORS (0)"
SFTitle.Parent = SF

local SFScroll = Instance.new("ScrollingFrame")
SFScroll.Size = UDim2.new(1, -10, 1, -28)
SFScroll.Position = UDim2.fromOffset(5, 24)
SFScroll.BackgroundTransparency = 1
SFScroll.BorderSizePixel = 0
SFScroll.ScrollBarThickness = 2
SFScroll.Parent = SF

local sfLayout = Instance.new("UIListLayout")
sfLayout.Padding = UDim.new(0, 3)
sfLayout.Parent = SFScroll

task.spawn(function()
    while Gui and Gui.Parent do
        for _, ch in ipairs(SFScroll:GetChildren()) do
            if ch:IsA("TextLabel") then ch:Destroy() end
        end
        local n = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                local sv = p:FindFirstChild("Spectating") or p:FindFirstChild("SpectateTarget")
                if sv and (sv.Value == LP or sv.Value == LP.Character) then
                    n = n + 1
                    local row = Instance.new("TextLabel")
                    row.Size = UDim2.new(1, 0, 0, 16)
                    row.BackgroundTransparency = 1
                    row.Font = Enum.Font.GothamMedium
                    row.TextSize = 10
                    row.TextColor3 = THEME.TextDim
                    row.TextXAlignment = Enum.TextXAlignment.Left
                    row.Text = "  " .. p.DisplayName
                    row.Parent = SFScroll
                end
            end
        end
        SFTitle.Text = string.format("SPECTATORS (%d)", n)
        task.wait(1.5)
    end
end)

-- ==================================================================
--  4. BHOP
-- ==================================================================
local bhopOn = false
local spaceDown = false

Track(UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.Space then spaceDown = true end
end))

Track(UIS.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Space then spaceDown = false end
end))

Track(RunService.RenderStepped:Connect(function()
    if bhopOn and spaceDown then
        local c = LP.Character
        if c then
            local h = c:FindFirstChildOfClass("Humanoid")
            if h and h.FloorMaterial ~= Enum.Material.Air then
                h.Jump = true
            end
        end
    end
end))

-- ==================================================================
--  5. СКИН ЧЕНДЖЕР & RGB DISCO
-- ==================================================================
local skinOn = false
local discoOn = false
local skinColor = Color3.fromRGB(255, 45, 120)
local skinMaterial = Enum.Material.Neon

local function PaintWeapon(model, col, mat)
    if not model then return end
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then
            local n = p.Name:lower()
            if not n:find("arm") and not n:find("hand") and not n:find("torso") and not n:find("head") then
                p.Color = col
                p.Material = mat
            end
        end
    end
end

Track(Camera.ChildAdded:Connect(function(child)
    task.wait(0.06)
    if skinOn then
        PaintWeapon(child, skinColor, skinMaterial)
    end
end))

Track(RunService.RenderStepped:Connect(function()
    if discoOn then
        local hue = (os.clock() * 0.5) % 1
        local col = Color3.fromHSV(hue, 0.9, 1)
        for _, ch in ipairs(Camera:GetChildren()) do
            PaintWeapon(ch, col, Enum.Material.Neon)
        end
    end
end))

-- ==================================================================
--  6. 2D СТРЕЛКИ ШАГОВ
-- ==================================================================
local arrowsOn = false

local function MakeArrow(worldPos)
    if not arrowsOn then return end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.fromOffset(24, 24)
    img.AnchorPoint = Vector2.new(0.5, 0.5)
    img.BackgroundTransparency = 1
    img.Image = "rbxassetid://6034818372"
    img.ImageColor3 = Color3.fromRGB(255, 220, 60)
    img.Parent = Gui

    local t0 = os.clock()
    local c
    c = RunService.RenderStepped:Connect(function()
        local dt = os.clock() - t0
        if dt >= 1.1 or not arrowsOn then
            c:Disconnect()
            img:Destroy()
            return
        end

        local rel = Camera.CFrame:VectorToObjectSpace(worldPos - Camera.CFrame.Position)
        local a = math.atan2(-rel.X, rel.Z)
        img.Position = UDim2.fromOffset(center.X + math.sin(a) * 170, center.Y - math.cos(a) * 170)
        img.Rotation = math.deg(a) + 180
        img.ImageTransparency = dt / 1.1
    end)
end

task.spawn(function()
    while Gui and Gui.Parent do
        task.wait(0.38)
        if arrowsOn then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChildOfClass("Humanoid")
                    local r = p.Character:FindFirstChild("HumanoidRootPart")
                    if h and r and h.MoveDirection.Magnitude > 0.1 and h.FloorMaterial ~= Enum.Material.Air then
                        if (r.Position - Camera.CFrame.Position).Magnitude <= 85 then
                            MakeArrow(r.Position)
                        end
                    end
                end
            end
        end
    end
end)

-- ==================================================================
--  7. ВИЗУАЛЬНЫЕ ЭФФЕКТЫ (Инстансы)
-- ==================================================================
local EffectInstances = {}

local function MakeEffect(className, props)
    local inst = Instance.new(className)
    for k, v in pairs(props) do
        inst[k] = v
    end
    inst.Parent = Lighting
    table.insert(EffectInstances, inst)
    return inst
end

local function KillEffect(inst)
    if inst then
        for i, e in ipairs(EffectInstances) do
            if e == inst then table.remove(EffectInstances, i) break end
        end
        inst:Destroy()
    end
    return nil
end

-- ==================================================================
--  8. ГЛАВНОЕ ОКНО МЕНЮ
-- ==================================================================
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.fromOffset(350, 470)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = THEME.Bg
Main.BackgroundTransparency = 0.08
Main.BorderSizePixel = 0
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Thickness = 1.6
mainStroke.Color = THEME.Accent
mainStroke.Transparency = 0.2

-- Фиолетовая полоска сверху (декор)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 3)
TopBar.Position = UDim2.fromOffset(0, 0)
TopBar.BackgroundColor3 = THEME.Accent
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 0, 28)
TitleLabel.Position = UDim2.fromOffset(14, 10)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "KONTRA CLIENT SUITE"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 17
TitleLabel.TextColor3 = THEME.Text
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Main

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(1, -20, 0, 14)
SubLabel.Position = UDim2.fromOffset(14, 34)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "[RightShift] Toggle  |  Drag to Move"
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextSize = 10
SubLabel.TextColor3 = THEME.TextDim
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = Main

-- Скролл-фрейм
local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "Scroll"
Scroll.Size = UDim2.new(1, -18, 1, -60)
Scroll.Position = UDim2.fromOffset(9, 54)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = THEME.Accent
Scroll.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 5)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Scroll

-- Авто-высота канваса через AbsoluteContentSize
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 16)
end)

-- Dragging
local dragging = false
local dragStart, frameStart

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        frameStart = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

Track(UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - dragStart
        Main.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + d.X, frameStart.Y.Scale, frameStart.Y.Offset + d.Y)
    end
end))

-- Открытие / закрытие по Right Shift
Track(UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end))

-- ==================================================================
--  UI BUILDER: Секция и Тумблер
-- ==================================================================
local layoutOrder = 0

local function NextOrder()
    layoutOrder = layoutOrder + 1
    return layoutOrder
end

local function CreateSection(text)
    local sec = Instance.new("TextLabel")
    sec.Size = UDim2.new(1, -4, 0, 22)
    sec.BackgroundTransparency = 1
    sec.Font = Enum.Font.GothamBold
    sec.TextSize = 11
    sec.TextColor3 = THEME.Section
    sec.TextXAlignment = Enum.TextXAlignment.Left
    sec.Text = "  " .. text:upper()
    sec.LayoutOrder = NextOrder()
    sec.Parent = Scroll
end

local function CreateToggle(name, default, callback)
    local state = default

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -4, 0, 36)
    Btn.BackgroundColor3 = THEME.Card
    Btn.BorderSizePixel = 0
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.LayoutOrder = NextOrder()
    Btn.Parent = Scroll

    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 7)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -56, 1, 0)
    Lbl.Position = UDim2.fromOffset(10, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = name
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 12
    Lbl.TextColor3 = THEME.Text
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Btn

    local Track_ = Instance.new("Frame")
    Track_.Size = UDim2.fromOffset(34, 16)
    Track_.Position = UDim2.new(1, -44, 0.5, -8)
    Track_.BackgroundColor3 = state and THEME.Accent or THEME.AccentDim
    Track_.BorderSizePixel = 0
    Track_.Parent = Btn
    Instance.new("UICorner", Track_).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.fromOffset(12, 12)
    Knob.Position = state and UDim2.fromOffset(19, 2) or UDim2.fromOffset(3, 2)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Track_
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    Btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(Track_, TweenInfo.new(0.18), {
            BackgroundColor3 = state and THEME.Accent or THEME.AccentDim
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.18), {
            Position = state and UDim2.fromOffset(19, 2) or UDim2.fromOffset(3, 2)
        }):Play()
        pcall(callback, state)
    end)

    -- Hover
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundColor3 = THEME.CardHover}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundColor3 = THEME.Card}):Play()
    end)

    if default then pcall(callback, true) end
end

-- ==================================================================
--  ВСЕ ОПЦИИ
-- ==================================================================

-- ─── SKINS ───
CreateSection("Weapon Skins")

CreateToggle("Neon Cyber Pink", false, function(v)
    skinOn = v
    if v then
        discoOn = false
        for _, ch in ipairs(Camera:GetChildren()) do
            PaintWeapon(ch, Color3.fromRGB(255, 45, 120), Enum.Material.Neon)
        end
    end
end)

CreateToggle("Meme: RGB Rainbow Disco", false, function(v)
    discoOn = v
    if v then skinOn = false end
end)

CreateToggle("Ice Diamond Skin", false, function(v)
    if v then
        skinOn = true
        discoOn = false
        skinColor = Color3.fromRGB(120, 220, 255)
        skinMaterial = Enum.Material.Glass
        for _, ch in ipairs(Camera:GetChildren()) do
            PaintWeapon(ch, skinColor, skinMaterial)
        end
    else
        skinOn = false
    end
end)

CreateToggle("Gold Prestige Skin", false, function(v)
    if v then
        skinOn = true
        discoOn = false
        skinColor = Color3.fromRGB(255, 195, 40)
        skinMaterial = Enum.Material.SmoothPlastic
        for _, ch in ipairs(Camera:GetChildren()) do
            PaintWeapon(ch, skinColor, skinMaterial)
        end
    else
        skinOn = false
    end
end)

-- ─── HUD ───
CreateSection("HUD & Info")

CreateToggle("Target HUD (Minecraft Style)", true, function(v)
    thActive = v
end)

CreateToggle("Spectator List", false, function(v)
    SF.Visible = v
end)

CreateToggle("Watermark FPS / Ping", true, function(v)
    WmFrame.Visible = v
end)

CreateToggle("2D Footstep Sound Arrows", false, function(v)
    arrowsOn = v
end)

-- ─── MOVEMENT ───
CreateSection("Movement")

CreateToggle("Auto Bunnyhop (Hold Space)", false, function(v)
    bhopOn = v
end)

-- ─── FOV ───
CreateSection("Camera & FOV")

CreateToggle("Wide FOV (105)", false, function(v)
    Camera.FieldOfView = v and 105 or ORIG.FOV
end)

CreateToggle("Meme: Quake Fisheye (120)", false, function(v)
    Camera.FieldOfView = v and 120 or ORIG.FOV
end)

-- ─── VISUALS ───
CreateSection("Visual Effects")

local fogAtmo = nil
CreateToggle("Cyberpunk Purple Fog", false, function(v)
    if v then
        Lighting.FogColor = Color3.fromRGB(40, 12, 75)
        Lighting.FogStart = 0
        Lighting.FogEnd = 160
        fogAtmo = MakeEffect("Atmosphere", {
            Density = 0.42,
            Color = Color3.fromRGB(110, 45, 200),
            Decay = Color3.fromRGB(35, 8, 55),
            Haze = 2.2,
        })
    else
        Lighting.FogColor = ORIG.FogColor
        Lighting.FogStart = ORIG.FogStart
        Lighting.FogEnd = ORIG.FogEnd
        fogAtmo = KillEffect(fogAtmo)
    end
end)

local bloom, blur = nil, nil
CreateToggle("Cinematic Bloom & Blur", false, function(v)
    if v then
        bloom = MakeEffect("BloomEffect", {Intensity = 1.3, Size = 22, Threshold = 0.8})
        blur = MakeEffect("BlurEffect", {Size = 2.5})
    else
        bloom = KillEffect(bloom)
        blur = KillEffect(blur)
    end
end)

local colorCorr = nil
CreateToggle("Vibrant HDR Colors", false, function(v)
    if v then
        colorCorr = MakeEffect("ColorCorrectionEffect", {
            Brightness = 0.04,
            Contrast = 0.22,
            Saturation = 0.45,
        })
    else
        colorCorr = KillEffect(colorCorr)
    end
end)

local sunRays = nil
CreateToggle("Sun Rays (God Rays)", false, function(v)
    if v then
        sunRays = MakeEffect("SunRaysEffect", {
            Intensity = 0.12,
            Spread = 0.8,
        })
    else
        sunRays = KillEffect(sunRays)
    end
end)

local dof = nil
CreateToggle("Depth of Field (Bokeh)", false, function(v)
    if v then
        dof = MakeEffect("DepthOfFieldEffect", {
            FarIntensity = 0.2,
            FocusDistance = 30,
            InFocusRadius = 50,
            NearIntensity = 0,
        })
    else
        dof = KillEffect(dof)
    end
end)

CreateToggle("Midnight Moon Theme", false, function(v)
    Lighting.ClockTime = v and 0 or ORIG.ClockTime
end)

CreateToggle("Fullbright (Remove Shadows)", false, function(v)
    if v then
        Lighting.Brightness = 3
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = ORIG.Brightness
        Lighting.ClockTime = ORIG.ClockTime
        Lighting.FogEnd = ORIG.FogEnd
        Lighting.GlobalShadows = true
    end
end)

-- ─── MEME AURAS ───
CreateSection("Meme & Fun")

local purpleAura = nil
CreateToggle("Purple Starlight Aura", false, function(v)
    if v then
        local c = LP.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            purpleAura = Instance.new("ParticleEmitter")
            purpleAura.Texture = "rbxassetid://243098098"
            purpleAura.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 90, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 190, 255)),
            })
            purpleAura.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.35),
                NumberSequenceKeypoint.new(1, 0),
            })
            purpleAura.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1),
            })
            purpleAura.Lifetime = NumberRange.new(0.7, 1.3)
            purpleAura.Rate = 20
            purpleAura.Speed = NumberRange.new(1.5, 3)
            purpleAura.SpreadAngle = Vector2.new(360, 360)
            purpleAura.Parent = c.HumanoidRootPart
        end
    else
        if purpleAura then purpleAura:Destroy() purpleAura = nil end
    end
end)

local skullAura = nil
CreateToggle("Skull Flame Aura", false, function(v)
    if v then
        local c = LP.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            skullAura = Instance.new("ParticleEmitter")
            skullAura.Texture = "rbxassetid://6031075938"
            skullAura.Color = ColorSequence.new(Color3.fromRGB(255, 70, 70))
            skullAura.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.45),
                NumberSequenceKeypoint.new(1, 0),
            })
            skullAura.Lifetime = NumberRange.new(0.5, 1.1)
            skullAura.Rate = 16
            skullAura.Speed = NumberRange.new(2, 4)
            skullAura.SpreadAngle = Vector2.new(360, 360)
            skullAura.Parent = c.HumanoidRootPart
        end
    else
        if skullAura then skullAura:Destroy() skullAura = nil end
    end
end)

local rgbAura = nil
local rgbAuraConn = nil
CreateToggle("RGB Rainbow Body Aura", false, function(v)
    if v then
        local c = LP.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            rgbAura = Instance.new("ParticleEmitter")
            rgbAura.Texture = "rbxassetid://243098098"
            rgbAura.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.3),
                NumberSequenceKeypoint.new(1, 0),
            })
            rgbAura.Lifetime = NumberRange.new(0.6, 1)
            rgbAura.Rate = 24
            rgbAura.Speed = NumberRange.new(2, 3.5)
            rgbAura.SpreadAngle = Vector2.new(360, 360)
            rgbAura.Parent = c.HumanoidRootPart

            rgbAuraConn = RunService.RenderStepped:Connect(function()
                if rgbAura and rgbAura.Parent then
                    local hue = (os.clock() * 0.6) % 1
                    local col = Color3.fromHSV(hue, 0.9, 1)
                    rgbAura.Color = ColorSequence.new(col)
                end
            end)
            Track(rgbAuraConn)
        end
    else
        if rgbAuraConn then rgbAuraConn:Disconnect() rgbAuraConn = nil end
        if rgbAura then rgbAura:Destroy() rgbAura = nil end
    end
end)

-- ==================================================================
--  UNLOAD BUTTON
-- ==================================================================
CreateSection("")

local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Size = UDim2.new(1, -4, 0, 38)
UnloadBtn.BackgroundColor3 = THEME.Red
UnloadBtn.BorderSizePixel = 0
UnloadBtn.Text = "  UNLOAD / DESTROY SCRIPT"
UnloadBtn.Font = Enum.Font.GothamBold
UnloadBtn.TextSize = 12
UnloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnloadBtn.TextXAlignment = Enum.TextXAlignment.Center
UnloadBtn.LayoutOrder = NextOrder()
UnloadBtn.Parent = Scroll

Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 8)

UnloadBtn.MouseButton1Click:Connect(function()
    -- Disconnect all tracked connections
    for _, c in ipairs(CONNS) do
        pcall(function() c:Disconnect() end)
    end

    -- Kill all lighting effects
    for _, e in ipairs(EffectInstances) do
        pcall(function() e:Destroy() end)
    end

    -- Kill auras
    if purpleAura then pcall(function() purpleAura:Destroy() end) end
    if skullAura then pcall(function() skullAura:Destroy() end) end
    if rgbAura then pcall(function() rgbAura:Destroy() end) end
    if rgbAuraConn then pcall(function() rgbAuraConn:Disconnect() end) end

    -- Restore original lighting
    Lighting.FogColor = ORIG.FogColor
    Lighting.FogStart = ORIG.FogStart
    Lighting.FogEnd = ORIG.FogEnd
    Lighting.ClockTime = ORIG.ClockTime
    Lighting.Brightness = ORIG.Brightness
    Lighting.GlobalShadows = true
    Camera.FieldOfView = ORIG.FOV

    -- Nuke entire GUI
    Gui:Destroy()
    print("[Kontra Suite v2] Unloaded cleanly.")
end)

-- ==================================================================
--  RESPAWN HOOKS (восстановление аур после смерти)
-- ==================================================================
LP.CharacterAdded:Connect(function(char)
    task.wait(1)
    if purpleAura and not purpleAura.Parent then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then purpleAura.Parent = root end
    end
    if skullAura and not skullAura.Parent then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then skullAura.Parent = root end
    end
    if rgbAura and not rgbAura.Parent then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then rgbAura.Parent = root end
    end
end)

print("[Kontra Suite v2] All modules loaded. " .. layoutOrder .. " items created.")
