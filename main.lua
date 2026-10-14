-- Context: Luau / Roblox Client Environment
-- Target: Kontra (Roblox)
-- Description: Ultimate All-in-One Client Suite (Seasons, Particles, Skins, Head Dots, HUD & Movement)

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Сохранение оригинальных параметров мира
local OriginalSettings = {
    FogColor = Lighting.FogColor,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    ClockTime = Lighting.ClockTime,
    Brightness = Lighting.Brightness,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

-- Хранилище всех активных подключений для чистого Unload
local Connections = {}
local function TrackConnection(conn)
    table.insert(Connections, conn)
    return conn
end

-- ==================== УДАЛЕНИЕ СТАРЫХ ВЕРСИЙ ====================
pcall(function()
    if CoreGui:FindFirstChild("KontraUltimateV5") then
        CoreGui.KontraUltimateV5:Destroy()
    end
end)

-- ==================== SCREENGUI SETUP ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KontraUltimateV5"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui
    end
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Палитра темы
local Theme = {
    Bg = Color3.fromRGB(15, 15, 22),
    Panel = Color3.fromRGB(22, 22, 32),
    Card = Color3.fromRGB(28, 28, 40),
    CardHover = Color3.fromRGB(36, 36, 52),
    Accent = Color3.fromRGB(140, 85, 255),
    AccentGlow = Color3.fromRGB(190, 130, 255),
    Dim = Color3.fromRGB(48, 48, 64),
    Text = Color3.fromRGB(240, 240, 255),
    SubText = Color3.fromRGB(145, 145, 175),
    Red = Color3.fromRGB(220, 50, 65)
}

-- ==================== 1. WATERMARK ====================
local Watermark = Instance.new("Frame")
Watermark.Size = UDim2.fromOffset(275, 28)
Watermark.Position = UDim2.fromOffset(14, 14)
Watermark.BackgroundColor3 = Theme.Bg
Watermark.BackgroundTransparency = 0.15
Watermark.BorderSizePixel = 0
Watermark.Parent = ScreenGui

Instance.new("UICorner", Watermark).CornerRadius = UDim.new(0, 6)
local WmStroke = Instance.new("UIStroke", Watermark)
WmStroke.Color = Theme.Accent
WmStroke.Transparency = 0.45

local WmText = Instance.new("TextLabel")
WmText.Size = UDim2.new(1, -14, 1, 0)
WmText.Position = UDim2.fromOffset(8, 0)
WmText.BackgroundTransparency = 1
WmText.Font = Enum.Font.GothamMedium
WmText.TextSize = 11
WmText.TextColor3 = Theme.Text
WmText.TextXAlignment = Enum.TextXAlignment.Left
WmText.Text = "KONTRA CLIENT v5 | INITIALIZING..."
WmText.Parent = Watermark

local fpsCounter = 0
local lastFpsTime = os.clock()
TrackConnection(RunService.RenderStepped:Connect(function()
    fpsCounter = fpsCounter + 1
    local now = os.clock()
    if now - lastFpsTime >= 1 then
        local fps = fpsCounter
        fpsCounter = 0
        lastFpsTime = now
        local ping = 40
        pcall(function()
            ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        WmText.Text = string.format("KONTRA v5 | %s | %d FPS | %d ms", LocalPlayer.DisplayName, fps, ping)
    end
end))

-- ==================== 2. TARGET HUD ====================
local TargetHUD = Instance.new("Frame")
TargetHUD.Size = UDim2.fromOffset(220, 68)
TargetHUD.Position = UDim2.new(0.5, -110, 0.64, 0)
TargetHUD.BackgroundColor3 = Theme.Bg
TargetHUD.BackgroundTransparency = 0.15
TargetHUD.BorderSizePixel = 0
TargetHUD.Visible = false
TargetHUD.Parent = ScreenGui

Instance.new("UICorner", TargetHUD).CornerRadius = UDim.new(0, 10)
local ThStroke = Instance.new("UIStroke", TargetHUD)
ThStroke.Color = Theme.Accent
ThStroke.Transparency = 0.35

local TargetAvatar = Instance.new("ImageLabel")
TargetAvatar.Size = UDim2.fromOffset(42, 42)
TargetAvatar.Position = UDim2.fromOffset(10, 13)
TargetAvatar.BackgroundColor3 = Theme.Card
TargetAvatar.BorderSizePixel = 0
TargetAvatar.Parent = TargetHUD
Instance.new("UICorner", TargetAvatar).CornerRadius = UDim.new(0, 6)

local TargetName = Instance.new("TextLabel")
TargetName.Size = UDim2.new(1, -66, 0, 16)
TargetName.Position = UDim2.fromOffset(58, 10)
TargetName.BackgroundTransparency = 1
TargetName.Font = Enum.Font.GothamBold
TargetName.TextSize = 12
TargetName.TextColor3 = Theme.Text
TargetName.TextXAlignment = Enum.TextXAlignment.Left
TargetName.TextTruncate = Enum.TextTruncate.AtEnd
TargetName.Text = ""
TargetName.Parent = TargetHUD

local TargetDist = Instance.new("TextLabel")
TargetDist.Size = UDim2.new(1, -66, 0, 14)
TargetDist.Position = UDim2.fromOffset(58, 26)
TargetDist.BackgroundTransparency = 1
TargetDist.Font = Enum.Font.Gotham
TargetDist.TextSize = 10
TargetDist.TextColor3 = Theme.SubText
TargetDist.TextXAlignment = Enum.TextXAlignment.Left
TargetDist.Text = ""
TargetDist.Parent = TargetHUD

local HealthBg = Instance.new("Frame")
HealthBg.Size = UDim2.new(1, -68, 0, 6)
HealthBg.Position = UDim2.fromOffset(58, 46)
HealthBg.BackgroundColor3 = Theme.Dim
HealthBg.BorderSizePixel = 0
HealthBg.Parent = TargetHUD
Instance.new("UICorner", HealthBg).CornerRadius = UDim.new(1, 0)

local HealthFill = Instance.new("Frame")
HealthFill.Size = UDim2.new(1, 0, 1, 0)
HealthFill.BackgroundColor3 = Theme.Accent
HealthFill.BorderSizePixel = 0
HealthFill.Parent = HealthBg
Instance.new("UICorner", HealthFill).CornerRadius = UDim.new(1, 0)

local targetHudActive = true
local cachedTarget = nil

TrackConnection(RunService.RenderStepped:Connect(function()
    if not targetHudActive then
        TargetHUD.Visible = false
        return
    end

    local origin = Camera.CFrame.Position
    local dir = Camera.CFrame.LookVector * 280
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    if LocalPlayer.Character then
        params.FilterDescendantsInstances = {LocalPlayer.Character}
    end

    local hit = workspace:Raycast(origin, dir, params)
    local found = nil

    if hit and hit.Instance then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and hit.Instance:IsDescendantOf(p.Character) then
                found = p
                break
            end
        end
    end

    if found and found.Character then
        local hum = found.Character:FindFirstChildOfClass("Humanoid")
        local root = found.Character:FindFirstChild("HumanoidRootPart")
        if hum and hum.Health > 0 and root then
            TargetHUD.Visible = true
            TargetName.Text = found.DisplayName
            local dist = math.floor((root.Position - origin).Magnitude)
            TargetDist.Text = string.format("%d studs | %d HP", dist, math.floor(hum.Health))

            local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            TweenService:Create(HealthFill, TweenInfo.new(0.12), {Size = UDim2.new(ratio, 0, 1, 0)}):Play()

            if cachedTarget ~= found then
                cachedTarget = found
                task.spawn(function()
                    pcall(function()
                        local thumb = Players:GetUserThumbnailAsync(found.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                        TargetAvatar.Image = thumb
                    end)
                end)
            end
            return
        end
    end

    TargetHUD.Visible = false
end))

-- ==================== 3. SPECTATOR LIST ====================
local SpecFrame = Instance.new("Frame")
SpecFrame.Size = UDim2.fromOffset(175, 95)
SpecFrame.Position = UDim2.new(1, -195, 0.4, 0)
SpecFrame.BackgroundColor3 = Theme.Bg
SpecFrame.BackgroundTransparency = 0.15
SpecFrame.BorderSizePixel = 0
SpecFrame.Visible = false
SpecFrame.Parent = ScreenGui

Instance.new("UICorner", SpecFrame).CornerRadius = UDim.new(0, 8)
local SfStroke = Instance.new("UIStroke", SpecFrame)
SfStroke.Color = Theme.Accent
SfStroke.Transparency = 0.4

local SfTitle = Instance.new("TextLabel")
SfTitle.Size = UDim2.new(1, -10, 0, 22)
SfTitle.Position = UDim2.fromOffset(8, 3)
SfTitle.BackgroundTransparency = 1
SfTitle.Font = Enum.Font.GothamBold
SfTitle.TextSize = 11
SfTitle.TextColor3 = Theme.Text
SfTitle.TextXAlignment = Enum.TextXAlignment.Left
SfTitle.Text = "SPECTATORS (0)"
SfTitle.Parent = SpecFrame

local SfScroll = Instance.new("ScrollingFrame")
SfScroll.Size = UDim2.new(1, -8, 1, -26)
SfScroll.Position = UDim2.fromOffset(4, 24)
SfScroll.BackgroundTransparency = 1
SfScroll.BorderSizePixel = 0
SfScroll.ScrollBarThickness = 2
SfScroll.Parent = SpecFrame

local SfLayout = Instance.new("UIListLayout")
SfLayout.Padding = UDim.new(0, 2)
SfLayout.Parent = SfScroll

task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        for _, child in ipairs(SfScroll:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end

        local count = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local sv = p:FindFirstChild("Spectating") or p:FindFirstChild("SpectateTarget")
                if sv and (sv.Value == LocalPlayer or sv.Value == LocalPlayer.Character) then
                    count = count + 1
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 0, 15)
                    label.BackgroundTransparency = 1
                    label.Font = Enum.Font.Gotham
                    label.TextSize = 10
                    label.TextColor3 = Theme.SubText
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Text = "• " .. p.DisplayName
                    label.Parent = SfScroll
                end
            end
        end
        SfTitle.Text = string.format("SPECTATORS (%d)", count)
        task.wait(1.5)
    end
end)

-- ==================== 4. HEAD DOTS (МАРКЕРЫ НАД ГОЛОВОЙ) ====================
local headDotsActive = false

local function CreateHeadDot(char, player)
    if player == LocalPlayer or not char then return end
    local head = char:WaitForChild("Head", 5)
    if not head then return end

    local existing = head:FindFirstChild("ClientHeadDot")
    if existing then existing:Destroy() end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ClientHeadDot"
    billboard.Adornee = head
    billboard.Size = UDim2.fromOffset(10, 10)
    billboard.StudsOffset = Vector3.new(0, 2.2, 0)
    billboard.AlwaysOnTop = false -- Не видно сквозь стены (безопасно)
    billboard.LightInfluence = 0
    billboard.Parent = head

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(1, 0, 1, 0)
    dot.BackgroundColor3 = Color3.fromRGB(150, 90, 255)
    dot.BorderSizePixel = 0
    dot.Parent = billboard
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.3
    stroke.Parent = dot
end

local function ClearAllHeadDots()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head and head:FindFirstChild("ClientHeadDot") then
                head.ClientHeadDot:Destroy()
            end
        end
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(function(c)
            task.wait(0.5)
            if headDotsActive then CreateHeadDot(c, p) end
        end)
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        task.wait(0.5)
        if headDotsActive then CreateHeadDot(c, p) end
    end)
end)

-- ==================== 5. AUTO BUNNYHOP ====================
local bhopActive = false

TrackConnection(RunService.Stepped:Connect(function()
    if not bhopActive then return end
    pcall(function()
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local state = hum:GetState()
                    if state == Enum.HumanoidStateType.Running
                    or state == Enum.HumanoidStateType.RunningNoPhysics
                    or state == Enum.HumanoidStateType.Landed then
                        hum.Jump = true
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end
    end)
end))

-- ==================== 6. НАДЕЖНЫЙ СКИН ЧЕНДЖЕР ====================
local skinActive = false
local discoActive = false
local currentSkinColor = Color3.fromRGB(255, 45, 120)
local currentSkinMaterial = Enum.Material.Neon

local function PaintWeaponModel(model, col, mat)
    if not model then return end
    for _, p in ipairs(model:GetDescendants()) do
        local name = p.Name:lower()
        local isLimb = name:find("arm") or name:find("hand") or name:find("torso")
                    or name:find("head") or name:find("leg") or name:find("humanoid")

        if not isLimb then
            if p:IsA("BasePart") then
                p.Color = col
                p.Material = mat
                if p:IsA("MeshPart") and p.TextureID ~= "" then
                    p.TextureID = ""
                end
            end
            if p:IsA("SpecialMesh") then
                pcall(function() p.TextureId = "" end)
            end
            if p:IsA("Decal") or p:IsA("Texture") then
                pcall(function() p.Transparency = 1 end)
            end
        end
    end
end

TrackConnection(Camera.ChildAdded:Connect(function(child)
    task.wait(0.08)
    if skinActive and not discoActive then
        PaintWeaponModel(child, currentSkinColor, currentSkinMaterial)
    end
end))

TrackConnection(RunService.Heartbeat:Connect(function()
    if skinActive and not discoActive then
        for _, child in ipairs(Camera:GetChildren()) do
            if child:IsA("Model") then
                PaintWeaponModel(child, currentSkinColor, currentSkinMaterial)
            end
        end
    end
end))

TrackConnection(RunService.RenderStepped:Connect(function()
    if discoActive then
        local hue = (os.clock() * 0.5) % 1
        local col = Color3.fromHSV(hue, 0.9, 1)
        for _, child in ipairs(Camera:GetChildren()) do
            PaintWeaponModel(child, col, Enum.Material.Neon)
        end
    end
end))

-- ==================== 7. 2D СТРЕЛКИ ШАГОВ (VELOCITY) ====================
local footstepArrowsActive = false

local function SpawnFootstepArrow(worldPos)
    if not footstepArrowsActive then return end
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    local arrow = Instance.new("ImageLabel")
    arrow.Size = UDim2.fromOffset(24, 24)
    arrow.AnchorPoint = Vector2.new(0.5, 0.5)
    arrow.BackgroundTransparency = 1
    arrow.Image = "rbxassetid://6034818372"
    arrow.ImageColor3 = Color3.fromRGB(255, 215, 60)
    arrow.Parent = ScreenGui

    local startTime = os.clock()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local elapsed = os.clock() - startTime
        if elapsed >= 1.1 or not footstepArrowsActive then
            conn:Disconnect()
            arrow:Destroy()
            return
        end

        local rel = Camera.CFrame:VectorToObjectSpace(worldPos - Camera.CFrame.Position)
        local angle = math.atan2(-rel.X, rel.Z)

        arrow.Position = UDim2.fromOffset(screenCenter.X + math.sin(angle) * 165, screenCenter.Y - math.cos(angle) * 165)
        arrow.Rotation = math.deg(angle) + 180
        arrow.ImageTransparency = elapsed / 1.1
    end)
end

task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        task.wait(0.38)
        if footstepArrowsActive then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local root = p.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local vel = root.AssemblyLinearVelocity
                        local horizontalSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude
                        if horizontalSpeed > 3.2 and math.abs(vel.Y) < 10 then
                            local dist = (root.Position - Camera.CFrame.Position).Magnitude
                            if dist <= 85 then
                                SpawnFootstepArrow(root.Position)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ==================== 8. ВИЗУАЛЬНЫЕ ЭФФЕКТЫ И СЕЗОНЫ ====================
local LightingEffects = {}
local function CreateLightingEffect(className, props)
    local effect = Instance.new(className)
    for k, v in pairs(props) do effect[k] = v end
    effect.Parent = Lighting
    table.insert(LightingEffects, effect)
    return effect
end

local function RemoveLightingEffect(effect)
    if effect then
        for i = #LightingEffects, 1, -1 do
            if LightingEffects[i] == effect then
                table.remove(LightingEffects, i)
            end
        end
        effect:Destroy()
    end
    return nil
end

-- ==================== 9. ГЛАВНОЕ МЕНЮ ИНТЕРФЕЙСА ====================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromOffset(350, 480)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Theme.Panel
MainFrame.BackgroundTransparency = 0.08
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local MfStroke = Instance.new("UIStroke", MainFrame)
MfStroke.Thickness = 1.5
MfStroke.Color = Theme.Accent
MfStroke.Transparency = 0.2

local TopGlow = Instance.new("Frame")
TopGlow.Size = UDim2.new(1, -24, 0, 3)
TopGlow.Position = UDim2.fromOffset(12, 8)
TopGlow.BackgroundColor3 = Theme.Accent
TopGlow.BorderSizePixel = 0
TopGlow.Parent = MainFrame
Instance.new("UICorner", TopGlow).CornerRadius = UDim.new(1, 0)

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1, -24, 0, 24)
HeaderTitle.Position = UDim2.fromOffset(14, 16)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "KONTRA CLIENT v5"
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 16
HeaderTitle.TextColor3 = Theme.Text
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = MainFrame

local HeaderSub = Instance.new("TextLabel")
HeaderSub.Size = UDim2.new(1, -24, 0, 14)
HeaderSub.Position = UDim2.fromOffset(14, 38)
HeaderSub.BackgroundTransparency = 1
HeaderSub.Text = "[RightShift] Toggle  •  Seasons & Visuals Suite"
HeaderSub.Font = Enum.Font.Gotham
HeaderSub.TextSize = 10
HeaderSub.TextColor3 = Theme.SubText
HeaderSub.TextXAlignment = Enum.TextXAlignment.Left
HeaderSub.Parent = MainFrame

local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(1, -16, 1, -64)
ScrollList.Position = UDim2.fromOffset(8, 58)
ScrollList.BackgroundTransparency = 1
ScrollList.BorderSizePixel = 0
ScrollList.ScrollBarThickness = 3
ScrollList.ScrollBarImageColor3 = Theme.Accent
ScrollList.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 4)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = ScrollList

ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 16)
end)

-- Dragging мышью
local isDragging = false
local dragStart, frameStart
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        frameStart = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then isDragging = false end
        end)
    end
end)

TrackConnection(UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
    end
end))

TrackConnection(UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end))

-- Конструкторы UI
local layoutOrder = 0
local function NextOrder()
    layoutOrder = layoutOrder + 1
    return layoutOrder
end

local function CreateSection(title)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 22)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = NextOrder()
    frame.Parent = ScrollList

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -8, 1, 0)
    label.Position = UDim2.fromOffset(4, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.TextColor3 = Theme.Accent
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = "━  " .. title:upper()
    label.Parent = frame

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -8, 0, 1)
    line.Position = UDim2.new(0, 4, 1, -2)
    line.BackgroundColor3 = Theme.Dim
    line.BackgroundTransparency = 0.5
    line.BorderSizePixel = 0
    line.Parent = frame
end

local function CreateToggle(name, defaultState, callback)
    local state = defaultState

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 34)
    btn.BackgroundColor3 = Theme.Card
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = NextOrder()
    btn.Parent = ScrollList
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -54, 1, 0)
    lbl.Position = UDim2.fromOffset(10, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.TextColor3 = Theme.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn

    local track = Instance.new("Frame")
    track.Size = UDim2.fromOffset(32, 16)
    track.Position = UDim2.new(1, -42, 0.5, -8)
    track.BackgroundColor3 = state and Theme.Accent or Theme.Dim
    track.BorderSizePixel = 0
    track.Parent = btn
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(12, 12)
    knob.Position = state and UDim2.fromOffset(17, 2) or UDim2.fromOffset(3, 2)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(track, TweenInfo.new(0.15), {
            BackgroundColor3 = state and Theme.Accent or Theme.Dim
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = state and UDim2.fromOffset(17, 2) or UDim2.fromOffset(3, 2)
        }):Play()
        pcall(callback, state)
    end)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.CardHover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Card}):Play()
    end)

    if defaultState then pcall(callback, true) end
end

-- ==================== НАПОЛНЕНИЕ МЕНЮ ====================

-- ─── СЕЗОНЫ ГОДА (НОВОЕ) ───
CreateSection("Seasons & Weather")

local winterAtmo = nil
local winterColor = nil
local snowEmitter = nil

local function ToggleWinter(v)
    if v then
        Lighting.FogColor = Color3.fromRGB(200, 220, 245)
        Lighting.FogStart = 0
        Lighting.FogEnd = 140
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 205, 235)

        winterAtmo = CreateLightingEffect("Atmosphere", {
            Density = 0.45,
            Color = Color3.fromRGB(195, 220, 245),
            Decay = Color3.fromRGB(150, 180, 215),
            Haze = 2.5
        })
        winterColor = CreateLightingEffect("ColorCorrectionEffect", {
            TintColor = Color3.fromRGB(215, 235, 255),
            Contrast = 0.15,
            Saturation = -0.2
        })

        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            snowEmitter = Instance.new("ParticleEmitter")
            snowEmitter.Name = "WinterSnow"
            snowEmitter.Texture = "rbxassetid://243098098"
            snowEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
            snowEmitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(1, 0.1)})
            snowEmitter.Lifetime = NumberRange.new(2, 3.5)
            snowEmitter.Rate = 35
            snowEmitter.Speed = NumberRange.new(3, 6)
            snowEmitter.Acceleration = Vector3.new(0, -6, 0)
            snowEmitter.SpreadAngle = Vector2.new(180, 180)
            snowEmitter.Parent = char.HumanoidRootPart
        end
    else
        Lighting.FogColor = OriginalSettings.FogColor
        Lighting.FogStart = OriginalSettings.FogStart
        Lighting.FogEnd = OriginalSettings.FogEnd
        Lighting.OutdoorAmbient = OriginalSettings.OutdoorAmbient
        winterAtmo = RemoveLightingEffect(winterAtmo)
        winterColor = RemoveLightingEffect(winterColor)
        if snowEmitter then snowEmitter:Destroy() snowEmitter = nil end
    end
end

CreateToggle("Winter Frost & Snowfall", false, ToggleWinter)

local springAtmo = nil
local springColor = nil
local sakuraEmitter = nil

local function ToggleSpring(v)
    if v then
        Lighting.FogColor = Color3.fromRGB(255, 220, 235)
        Lighting.FogStart = 10
        Lighting.FogEnd = 200

        springAtmo = CreateLightingEffect("Atmosphere", {
            Density = 0.35,
            Color = Color3.fromRGB(255, 210, 230),
            Decay = Color3.fromRGB(220, 170, 200),
            Haze = 1.8
        })
        springColor = CreateLightingEffect("ColorCorrectionEffect", {
            TintColor = Color3.fromRGB(255, 240, 245),
            Brightness = 0.04,
            Saturation = 0.3,
            Contrast = 0.1
        })

        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            sakuraEmitter = Instance.new("ParticleEmitter")
            sakuraEmitter.Name = "SpringSakura"
            sakuraEmitter.Texture = "rbxassetid://258128463" -- Мягкие розовые лепестки
            sakuraEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 175, 205))
            sakuraEmitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0.2)})
            sakuraEmitter.Lifetime = NumberRange.new(2.5, 4)
            sakuraEmitter.Rate = 22
            sakuraEmitter.Speed = NumberRange.new(2, 4)
            sakuraEmitter.Acceleration = Vector3.new(2, -3, 1)
            sakuraEmitter.SpreadAngle = Vector2.new(180, 180)
            sakuraEmitter.Parent = char.HumanoidRootPart
        end
    else
        Lighting.FogColor = OriginalSettings.FogColor
        Lighting.FogStart = OriginalSettings.FogStart
        Lighting.FogEnd = OriginalSettings.FogEnd
        springAtmo = RemoveLightingEffect(springAtmo)
        springColor = RemoveLightingEffect(springColor)
        if sakuraEmitter then sakuraEmitter:Destroy() sakuraEmitter = nil end
    end
end

CreateToggle("Spring Blossom & Sakura", false, ToggleSpring)

-- ─── СКИНЫ ОРУЖИЯ ───
CreateSection("Weapon Skins")

CreateToggle("Neon Cyber Pink", false, function(v)
    skinActive = v; discoActive = false
    currentSkinColor = Color3.fromRGB(255, 45, 120)
    currentSkinMaterial = Enum.Material.Neon
end)

CreateToggle("Ice Diamond Crystal", false, function(v)
    skinActive = v; discoActive = false
    currentSkinColor = Color3.fromRGB(120, 220, 255)
    currentSkinMaterial = Enum.Material.Glass
end)

CreateToggle("Gold Prestige", false, function(v)
    skinActive = v; discoActive = false
    currentSkinColor = Color3.fromRGB(255, 195, 40)
    currentSkinMaterial = Enum.Material.SmoothPlastic
end)

CreateToggle("ForceField Galaxy", false, function(v)
    skinActive = v; discoActive = false
    currentSkinColor = Color3.fromRGB(140, 40, 255)
    currentSkinMaterial = Enum.Material.ForceField
end)

CreateToggle("Lava Inferno", false, function(v)
    skinActive = v; discoActive = false
    currentSkinColor = Color3.fromRGB(255, 75, 20)
    currentSkinMaterial = Enum.Material.Neon
end)

CreateToggle("Emerald Toxic", false, function(v)
    skinActive = v; discoActive = false
    currentSkinColor = Color3.fromRGB(35, 255, 75)
    currentSkinMaterial = Enum.Material.Neon
end)

CreateToggle("Meme: RGB Rainbow Disco", false, function(v)
    discoActive = v
    if v then skinActive = false end
end)

-- ─── HUD И МАРКЕРЫ ───
CreateSection("HUD & Markers")

CreateToggle("Target HUD (Minecraft Style)", true, function(v) targetHudActive = v end)
CreateToggle("Spectator List Window", false, function(v) SpecFrame.Visible = v end)
CreateToggle("Watermark FPS / Ping", true, function(v) Watermark.Visible = v end)
CreateToggle("2D Footstep Sound Arrows", false, function(v) footstepArrowsActive = v end)

CreateToggle("Head Dot Markers (Dots)", false, function(v)
    headDotsActive = v
    if v then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                CreateHeadDot(p.Character, p)
            end
        end
    else
        ClearAllHeadDots()
    end
end)

-- ─── ДВИЖЕНИЕ ───
CreateSection("Movement")
CreateToggle("Auto Bunnyhop (Hold Space)", false, function(v) bhopActive = v end)

-- ─── АТМОСФЕРА И СВЕТ ───
CreateSection("Lighting & Atmosphere")

local atmoPurple = nil
CreateToggle("Purple Cyberpunk Fog", false, function(v)
    if v then
        Lighting.FogColor = Color3.fromRGB(40, 12, 75)
        Lighting.FogStart = 0
        Lighting.FogEnd = 160
        atmoPurple = CreateLightingEffect("Atmosphere", {Density = 0.4, Color = Color3.fromRGB(110, 45, 200), Haze = 2})
    else
        Lighting.FogColor = OriginalSettings.FogColor
        Lighting.FogStart = OriginalSettings.FogStart
        Lighting.FogEnd = OriginalSettings.FogEnd
        atmoPurple = RemoveLightingEffect(atmoPurple)
    end
end)

local bloomInst, blurInst = nil, nil
CreateToggle("Cinematic Bloom & Glow", false, function(v)
    if v then
        bloomInst = CreateLightingEffect("BloomEffect", {Intensity = 1.3, Size = 22, Threshold = 0.8})
        blurInst = CreateLightingEffect("BlurEffect", {Size = 2.5})
    else
        bloomInst = RemoveLightingEffect(bloomInst)
        blurInst = RemoveLightingEffect(blurInst)
    end
end)

local colorHdr = nil
CreateToggle("Vibrant HDR Colors", false, function(v)
    if v then
        colorHdr = CreateLightingEffect("ColorCorrectionEffect", {Brightness = 0.04, Contrast = 0.22, Saturation = 0.45})
    else
        colorHdr = RemoveLightingEffect(colorHdr)
    end
end)

local sunRaysInst = nil
CreateToggle("Sun Rays (God Rays)", false, function(v)
    if v then
        sunRaysInst = CreateLightingEffect("SunRaysEffect", {Intensity = 0.12, Spread = 0.8})
    else
        sunRaysInst = RemoveLightingEffect(sunRaysInst)
    end
end)

CreateToggle("Midnight Moon Theme", false, function(v)
    Lighting.ClockTime = v and 0 or OriginalSettings.ClockTime
end)

CreateToggle("Fullbright (No Shadows)", false, function(v)
    if v then
        Lighting.Brightness = 3
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = OriginalSettings.Brightness
        Lighting.ClockTime = OriginalSettings.ClockTime
        Lighting.FogEnd = OriginalSettings.FogEnd
        Lighting.GlobalShadows = OriginalSettings.GlobalShadows
    end
end)

-- ─── ПАРТИКЛЫ И АУРЫ ───
CreateSection("Auras & Trails")

local trailInst, trailA0, trailA1 = nil, nil, nil
local function MakePlayerTrail(char)
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if trailInst then pcall(function() trailInst:Destroy() end) end

    trailA0 = Instance.new("Attachment"); trailA0.Position = Vector3.new(0, 0.5, 0); trailA0.Parent = root
    trailA1 = Instance.new("Attachment"); trailA1.Position = Vector3.new(0, -0.5, 0); trailA1.Parent = root

    trailInst = Instance.new("Trail")
    trailInst.Attachment0 = trailA0
    trailInst.Attachment1 = trailA1
    trailInst.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 80, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 180, 255))
    })
    trailInst.Lifetime = 0.5
    trailInst.MinLength = 0.1
    trailInst.LightEmission = 0.6
    trailInst.Parent = root
end

local trailActive = false
CreateToggle("Character Motion Trail", false, function(v)
    trailActive = v
    if v then MakePlayerTrail(LocalPlayer.Character)
    else if trailInst then trailInst:Destroy() trailInst = nil end end
end)

local purpleAura = nil
CreateToggle("Purple Starlight Aura", false, function(v)
    if v then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            purpleAura = Instance.new("ParticleEmitter")
            purpleAura.Texture = "rbxassetid://243098098"
            purpleAura.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 90, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 190, 255))
            })
            purpleAura.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 0)})
            purpleAura.Lifetime = NumberRange.new(0.7, 1.2)
            purpleAura.Rate = 20
            purpleAura.Speed = NumberRange.new(1.5, 3)
            purpleAura.SpreadAngle = Vector2.new(360, 360)
            purpleAura.Parent = char.HumanoidRootPart
        end
    else
        if purpleAura then purpleAura:Destroy() purpleAura = nil end
    end
end)

local skullAura = nil
CreateToggle("Skull Flame Aura", false, function(v)
    if v then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            skullAura = Instance.new("ParticleEmitter")
            skullAura.Texture = "rbxassetid://6031075938"
            skullAura.Color = ColorSequence.new(Color3.fromRGB(255, 70, 70))
            skullAura.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.45), NumberSequenceKeypoint.new(1, 0)})
            skullAura.Lifetime = NumberRange.new(0.5, 1)
            skullAura.Rate = 16
            skullAura.Speed = NumberRange.new(2, 4)
            skullAura.SpreadAngle = Vector2.new(360, 360)
            skullAura.Parent = char.HumanoidRootPart
        end
    else
        if skullAura then skullAura:Destroy() skullAura = nil end
    end
end)

-- Восстановление эффектов при респавне
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if trailActive then MakePlayerTrail(char) end
end)

-- ─── КНОПКА ВЫГРУЗКИ (UNLOAD) ───
CreateSection("")

local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Size = UDim2.new(1, -4, 0, 36)
UnloadBtn.BackgroundColor3 = Theme.Red
UnloadBtn.BorderSizePixel = 0
UnloadBtn.Text = "UNLOAD / DESTROY SCRIPT"
UnloadBtn.Font = Enum.Font.GothamBold
UnloadBtn.TextSize = 12
UnloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnloadBtn.LayoutOrder = NextOrder()
UnloadBtn.Parent = ScrollList
Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 8)

UnloadBtn.MouseButton1Click:Connect(function()
    for _, conn in ipairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    for _, effect in ipairs(LightingEffects) do
        pcall(function() effect:Destroy() end)
    end

    if trailInst then pcall(function() trailInst:Destroy() end) end
    if purpleAura then pcall(function() purpleAura:Destroy() end) end
    if skullAura then pcall(function() skullAura:Destroy() end) end
    if snowEmitter then pcall(function() snowEmitter:Destroy() end) end
    if sakuraEmitter then pcall(function() sakuraEmitter:Destroy() end) end

    ClearAllHeadDots()

    Lighting.FogColor = OriginalSettings.FogColor
    Lighting.FogStart = OriginalSettings.FogStart
    Lighting.FogEnd = OriginalSettings.FogEnd
    Lighting.ClockTime = OriginalSettings.ClockTime
    Lighting.Brightness = OriginalSettings.Brightness
    Lighting.GlobalShadows = OriginalSettings.GlobalShadows
    Lighting.OutdoorAmbient = OriginalSettings.OutdoorAmbient

    ScreenGui:Destroy()
    print("[Kontra v5] Unloaded cleanly!")
end)

print("[Kontra v5] Successfully loaded all systems and visuals!")
