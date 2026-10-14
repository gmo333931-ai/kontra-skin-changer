-- Context: Luau / Roblox Client Environment
-- Target: Kontra (Roblox)
-- Description: Fixed Complete Client Suite (All Toggles Render, No Nil Parent Errors)

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Сохранение оригинальных настроек
local origFogColor = Lighting.FogColor
local origFogStart = Lighting.FogStart
local origFogEnd = Lighting.FogEnd
local origClock = Lighting.ClockTime
local origFov = Camera.FieldOfView

-- ==================== SCREEN GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KontraMegaSuiteFixed"
ScreenGui.ResetOnSpawn = false

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

-- ==================== 1. WATERMARK ====================
local WatermarkFrame = Instance.new("Frame")
WatermarkFrame.Size = UDim2.fromOffset(260, 30)
WatermarkFrame.Position = UDim2.fromOffset(15, 15)
WatermarkFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
WatermarkFrame.BackgroundTransparency = 0.2
WatermarkFrame.BorderSizePixel = 0
WatermarkFrame.Parent = ScreenGui

local WmCorner = Instance.new("UICorner")
WmCorner.CornerRadius = UDim.new(0, 8)
WmCorner.Parent = WatermarkFrame

local WmStroke = Instance.new("UIStroke")
WmStroke.Thickness = 1.2
WmStroke.Color = Color3.fromRGB(140, 85, 255)
WmStroke.Transparency = 0.4
WmStroke.Parent = WatermarkFrame

local WmText = Instance.new("TextLabel")
WmText.Size = UDim2.new(1, -16, 1, 0)
WmText.Position = UDim2.fromOffset(8, 0)
WmText.BackgroundTransparency = 1
WmText.Font = Enum.Font.GothamMedium
WmText.TextSize = 12
WmText.TextColor3 = Color3.fromRGB(240, 240, 255)
WmText.TextXAlignment = Enum.TextXAlignment.Left
WmText.Text = "KONTRA CLIENT | 60 FPS"
WmText.Parent = WatermarkFrame

local frameCount = 0
local lastFpsUpdate = os.clock()
local fpsConn
fpsConn = RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = os.clock()
    if now - lastFpsUpdate >= 1 then
        local fps = frameCount
        frameCount = 0
        lastFpsUpdate = now
        
        local ping = 45
        pcall(function()
            ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        
        WmText.Text = string.format("KONTRA | %s | %d FPS | %d ms", LocalPlayer.DisplayName, fps, ping)
    end
end)

-- ==================== 2. TARGET HUD ====================
local TargetHUD = Instance.new("Frame")
TargetHUD.Size = UDim2.fromOffset(230, 75)
TargetHUD.Position = UDim2.new(0.5, -115, 0.65, 0)
TargetHUD.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
TargetHUD.BackgroundTransparency = 0.2
TargetHUD.BorderSizePixel = 0
TargetHUD.Visible = false
TargetHUD.Parent = ScreenGui

local ThCorner = Instance.new("UICorner")
ThCorner.CornerRadius = UDim.new(0, 10)
ThCorner.Parent = TargetHUD

local ThStroke = Instance.new("UIStroke")
ThStroke.Thickness = 1.2
ThStroke.Color = Color3.fromRGB(140, 85, 255)
ThStroke.Transparency = 0.3
ThStroke.Parent = TargetHUD

local TargetAvatar = Instance.new("ImageLabel")
TargetAvatar.Size = UDim2.fromOffset(48, 48)
TargetAvatar.Position = UDim2.fromOffset(12, 13)
TargetAvatar.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
TargetAvatar.BorderSizePixel = 0
TargetAvatar.Parent = TargetHUD

local AvCorner = Instance.new("UICorner")
AvCorner.CornerRadius = UDim.new(0, 8)
AvCorner.Parent = TargetAvatar

local TargetName = Instance.new("TextLabel")
TargetName.Size = UDim2.new(1, -75, 0, 18)
TargetName.Position = UDim2.fromOffset(68, 12)
TargetName.BackgroundTransparency = 1
TargetName.Font = Enum.Font.GothamBold
TargetName.TextSize = 13
TargetName.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetName.TextXAlignment = Enum.TextXAlignment.Left
TargetName.TextTruncate = Enum.TextTruncate.AtEnd
TargetName.Text = "Player"
TargetName.Parent = TargetHUD

local TargetDist = Instance.new("TextLabel")
TargetDist.Size = UDim2.new(1, -75, 0, 14)
TargetDist.Position = UDim2.fromOffset(68, 30)
TargetDist.BackgroundTransparency = 1
TargetDist.Font = Enum.Font.Gotham
TargetDist.TextSize = 11
TargetDist.TextColor3 = Color3.fromRGB(160, 160, 180)
TargetDist.TextXAlignment = Enum.TextXAlignment.Left
TargetDist.Text = "Dist: 0m"
TargetDist.Parent = TargetHUD

local HealthBarBg = Instance.new("Frame")
HealthBarBg.Size = UDim2.new(1, -80, 0, 8)
HealthBarBg.Position = UDim2.fromOffset(68, 50)
HealthBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
HealthBarBg.BorderSizePixel = 0
HealthBarBg.Parent = TargetHUD

local HbCorner = Instance.new("UICorner")
HbCorner.CornerRadius = UDim.new(1, 0)
HbCorner.Parent = HealthBarBg

local HealthBarFill = Instance.new("Frame")
HealthBarFill.Size = UDim2.new(1, 0, 1, 0)
HealthBarFill.BackgroundColor3 = Color3.fromRGB(140, 85, 255)
HealthBarFill.BorderSizePixel = 0
HealthBarFill.Parent = HealthBarBg

local HbfCorner = Instance.new("UICorner")
HbfCorner.CornerRadius = UDim.new(1, 0)
HbfCorner.Parent = HealthBarFill

local targetHudActive = true
local currentLockedPlayer = nil

local targetHudConn
targetHudConn = RunService.RenderStepped:Connect(function()
    if not targetHudActive then
        TargetHUD.Visible = false
        return
    end

    local rayOrigin = Camera.CFrame.Position
    local rayDir = Camera.CFrame.LookVector * 250
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    if LocalPlayer.Character then
        rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    end

    local result = workspace:Raycast(rayOrigin, rayDir, rayParams)
    local foundPlayer = nil

    if result and result.Instance then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and result.Instance:IsDescendantOf(plr.Character) then
                foundPlayer = plr
                break
            end
        end
    end

    if foundPlayer and foundPlayer.Character then
        local hum = foundPlayer.Character:FindFirstChildOfClass("Humanoid")
        local root = foundPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hum and hum.Health > 0 and root then
            TargetHUD.Visible = true
            TargetName.Text = foundPlayer.DisplayName
            local dist = math.floor((root.Position - Camera.CFrame.Position).Magnitude)
            TargetDist.Text = string.format("Dist: %d studs | HP: %d", dist, math.floor(hum.Health))

            local healthRatio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            TweenService:Create(HealthBarFill, TweenInfo.new(0.15), {Size = UDim2.new(healthRatio, 0, 1, 0)}):Play()

            if currentLockedPlayer ~= foundPlayer then
                currentLockedPlayer = foundPlayer
                task.spawn(function()
                    local thumb = Players:GetUserThumbnailAsync(foundPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                    TargetAvatar.Image = thumb
                end)
            end
            return
        end
    end

    TargetHUD.Visible = false
end)

-- ==================== 3. SPECTATOR LIST ====================
local SpecFrame = Instance.new("Frame")
SpecFrame.Size = UDim2.fromOffset(190, 110)
SpecFrame.Position = UDim2.new(1, -210, 0.35, 0)
SpecFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
SpecFrame.BackgroundTransparency = 0.2
SpecFrame.BorderSizePixel = 0
SpecFrame.Visible = false
SpecFrame.Parent = ScreenGui

local SfCorner = Instance.new("UICorner")
SfCorner.CornerRadius = UDim.new(0, 10)
SfCorner.Parent = SpecFrame

local SfStroke = Instance.new("UIStroke")
SfStroke.Thickness = 1.2
SfStroke.Color = Color3.fromRGB(140, 85, 255)
SfStroke.Transparency = 0.3
SfStroke.Parent = SpecFrame

local SfTitle = Instance.new("TextLabel")
SfTitle.Size = UDim2.new(1, -20, 0, 26)
SfTitle.Position = UDim2.fromOffset(12, 4)
SfTitle.BackgroundTransparency = 1
SfTitle.Font = Enum.Font.GothamBold
SfTitle.TextSize = 12
SfTitle.TextColor3 = Color3.fromRGB(240, 240, 255)
SfTitle.TextXAlignment = Enum.TextXAlignment.Left
SfTitle.Text = "SPECTATORS (0)"
SfTitle.Parent = SpecFrame

local SpecContainer = Instance.new("ScrollingFrame")
SpecContainer.Size = UDim2.new(1, -16, 1, -34)
SpecContainer.Position = UDim2.fromOffset(8, 30)
SpecContainer.BackgroundTransparency = 1
SpecContainer.BorderSizePixel = 0
SpecContainer.ScrollBarThickness = 2
SpecContainer.ScrollBarImageColor3 = Color3.fromRGB(140, 85, 255)
SpecContainer.Parent = SpecFrame

local SpecLayout = Instance.new("UIListLayout")
SpecLayout.Padding = UDim.new(0, 4)
SpecLayout.Parent = SpecContainer

-- ==================== 4. AUTO BUNNYHOP ====================
local bhopActive = false
local spaceHeld = false

local inputBeganConn = UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Space then
        spaceHeld = true
    end
end)

local inputEndedConn = UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        spaceHeld = false
    end
end)

local bhopConn = RunService.RenderStepped:Connect(function()
    if bhopActive and spaceHeld then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.FloorMaterial ~= Enum.Material.Air then
                hum.Jump = true
            end
        end
    end
end)

-- ==================== 5. СКИН ЧЕНДЖЕР & RGB DISCO ====================
local skinActive = false
local discoActive = false

local function ApplyWeaponSkin(model, color, material)
    if not model or not model:IsA("Model") then return end
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and not part.Name:lower():find("arm") and not part.Name:lower():find("hand") then
            if color then part.Color = color end
            if material then part.Material = material end
        end
    end
end

Camera.ChildAdded:Connect(function(child)
    if skinActive then
        task.wait(0.05)
        ApplyWeaponSkin(child, Color3.fromRGB(255, 45, 120), Enum.Material.Neon)
    end
end)

local discoConn = RunService.RenderStepped:Connect(function()
    if discoActive then
        local hue = (os.clock() * 0.4) % 1
        local rainbowColor = Color3.fromHSV(hue, 0.9, 1)
        for _, child in ipairs(Camera:GetChildren()) do
            ApplyWeaponSkin(child, rainbowColor, Enum.Material.Neon)
        end
    end
end)

-- ==================== 6. 2D СТРЕЛКИ ЗВУКОВ ШАГОВ ====================
local footstepArrowsActive = false
local MAX_STEP_DIST = 90
local INDICATOR_RADIUS = 180
local FADE_DURATION = 1.2

local function SpawnArrow(worldPos)
    if not footstepArrowsActive then return end
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    local arrow = Instance.new("ImageLabel")
    arrow.Size = UDim2.fromOffset(26, 26)
    arrow.AnchorPoint = Vector2.new(0.5, 0.5)
    arrow.BackgroundTransparency = 1
    arrow.Image = "rbxassetid://6034818372"
    arrow.ImageColor3 = Color3.fromRGB(255, 220, 60)
    arrow.Parent = ScreenGui

    local startTime = os.clock()
    local renderConn
    renderConn = RunService.RenderStepped:Connect(function()
        local elapsed = os.clock() - startTime
        if elapsed >= FADE_DURATION or not footstepArrowsActive then
            renderConn:Disconnect()
            arrow:Destroy()
            return
        end

        local camCF = Camera.CFrame
        local toPos = (worldPos - camCF.Position)
        local rel = camCF:VectorToObjectSpace(toPos)
        local angle = math.atan2(-rel.X, rel.Z)

        local offsetX = math.sin(angle) * INDICATOR_RADIUS
        local offsetY = -math.cos(angle) * INDICATOR_RADIUS

        arrow.Position = UDim2.fromOffset(screenCenter.X + offsetX, screenCenter.Y + offsetY)
        arrow.Rotation = math.deg(angle) + 180
        arrow.ImageTransparency = elapsed / FADE_DURATION
    end)
end

task.spawn(function()
    while true do
        task.wait(0.3)
        if footstepArrowsActive then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hum and root and hum.MoveDirection.Magnitude > 0.1 and hum.FloorMaterial ~= Enum.Material.Air then
                        local dist = (root.Position - Camera.CFrame.Position).Magnitude
                        if dist <= MAX_STEP_DIST then
                            SpawnArrow(root.Position)
                        end
                    end
                end
            end
        end
    end
end)

-- ==================== 7. ГЛАВНОЕ МЕНЮ ИНТЕРФЕЙСА ====================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromOffset(360, 480)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
MainFrame.BackgroundTransparency = 0.12
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1.5
UIStroke.Color = Color3.fromRGB(140, 85, 255)
UIStroke.Transparency = 0.25
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 32)
Title.Position = UDim2.fromOffset(15, 8)
Title.BackgroundTransparency = 1
Title.Text = "KONTRA CLIENT SUITE"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(245, 245, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -20, 0, 18)
Subtitle.Position = UDim2.fromOffset(15, 34)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Press [RightShift] to Toggle Menu"
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 11
Subtitle.TextColor3 = Color3.fromRGB(150, 150, 175)
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = MainFrame

local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(1, -20, 1, -65)
ScrollList.Position = UDim2.fromOffset(10, 58)
ScrollList.BackgroundTransparency = 1
ScrollList.BorderSizePixel = 0
ScrollList.ScrollBarThickness = 4
ScrollList.ScrollBarImageColor3 = Color3.fromRGB(140, 85, 255)
ScrollList.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
ScrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollList.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 7)
UIListLayout.Parent = ScrollList

-- Dragging окна мышью
local isDragging = false
local dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then isDragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Исправленная функция создания тумблера
local function CreateToggle(name, defaultState, onToggle)
    local state = defaultState

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -8, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = ScrollList

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Button

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.fromOffset(12, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextColor3 = Color3.fromRGB(225, 225, 240)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Button

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.fromOffset(36, 18)
    Indicator.Position = UDim2.new(1, -48, 0.5, -9)
    Indicator.BackgroundColor3 = state and Color3.fromRGB(140, 85, 255) or Color3.fromRGB(50, 50, 65)
    Indicator.BorderSizePixel = 0
    Indicator.Parent = Button

    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(1, 0)
    IndCorner.Parent = Indicator

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.fromOffset(14, 14)
    Dot.Position = state and UDim2.fromOffset(19, 2) or UDim2.fromOffset(3, 2)
    Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Dot.BorderSizePixel = 0
    Dot.Parent = Indicator -- ИСПРАВЛЕНО: раньше было Dot.Parent = Dot

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = Dot

    Button.MouseButton1Click:Connect(function()
        state = not state
        local targetColor = state and Color3.fromRGB(140, 85, 255) or Color3.fromRGB(50, 50, 65)
        local targetPos = state and UDim2.fromOffset(19, 2) or UDim2.fromOffset(3, 2)

        TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = targetPos}):Play()
        onToggle(state)
    end)

    if defaultState then onToggle(true) end
end

-- ==================== СПИСОК ВСЕХ ОПЦИЙ ====================

CreateToggle("Weapon Skin: Neon Pink", false, function(enabled)
    skinActive = enabled
    if enabled then
        for _, child in ipairs(Camera:GetChildren()) do
            ApplyWeaponSkin(child, Color3.fromRGB(255, 45, 120), Enum.Material.Neon)
        end
    end
end)

CreateToggle("Meme: RGB Rainbow Disco Gun", false, function(enabled)
    discoActive = enabled
end)

CreateToggle("Target HUD (Minecraft Style)", true, function(enabled)
    targetHudActive = enabled
end)

CreateToggle("Spectator List Window", false, function(enabled)
    SpecFrame.Visible = enabled
end)

CreateToggle("Watermark FPS / Ping Overlay", true, function(enabled)
    WatermarkFrame.Visible = enabled
end)

CreateToggle("2D Footstep Sound Arrows", false, function(enabled)
    footstepArrowsActive = enabled
end)

CreateToggle("Auto Bunnyhop (Hold Space)", false, function(enabled)
    bhopActive = enabled
end)

CreateToggle("Meme: 120 Quake Fisheye FOV", false, function(enabled)
    Camera.FieldOfView = enabled and 120 or origFov
end)

local Atmo = nil
CreateToggle("Cyberpunk Purple Fog", false, function(enabled)
    if enabled then
        Lighting.FogColor = Color3.fromRGB(45, 15, 80)
        Lighting.FogStart = 0
        Lighting.FogEnd = 140
        if not Atmo then
            Atmo = Instance.new("Atmosphere")
            Atmo.Density = 0.45
            Atmo.Color = Color3.fromRGB(120, 50, 200)
            Atmo.Decay = Color3.fromRGB(40, 10, 60)
            Atmo.Haze = 2
            Atmo.Parent = Lighting
        end
    else
        Lighting.FogColor = origFogColor
        Lighting.FogEnd = origFogEnd
        if Atmo then Atmo:Destroy() Atmo = nil end
    end
end)

local Bloom = nil
local Blur = nil
CreateToggle("Cinematic Bloom & Glow", false, function(enabled)
    if enabled then
        Bloom = Instance.new("BloomEffect")
        Bloom.Intensity = 1.4
        Bloom.Size = 24
        Bloom.Threshold = 0.8
        Bloom.Parent = Lighting

        Blur = Instance.new("BlurEffect")
        Blur.Size = 2.5
        Blur.Parent = Lighting
    else
        if Bloom then Bloom:Destroy() Bloom = nil end
        if Blur then Blur:Destroy() Blur = nil end
    end
end)

local ColorCorr = nil
CreateToggle("Vibrant HDR Colors", false, function(enabled)
    if enabled then
        ColorCorr = Instance.new("ColorCorrectionEffect")
        ColorCorr.Brightness = 0.05
        ColorCorr.Contrast = 0.25
        ColorCorr.Saturation = 0.4
        ColorCorr.Parent = Lighting
    else
        if ColorCorr then ColorCorr:Destroy() ColorCorr = nil end
    end
end)

local skullEmitter = nil
local function SpawnSkullAura(char)
    if not char then return end
    local root = char:WaitForChild("HumanoidRootPart", 5)
    if not root then return end
    if skullEmitter then skullEmitter:Destroy() end

    skullEmitter = Instance.new("ParticleEmitter")
    skullEmitter.Texture = "rbxassetid://6031075938"
    skullEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 80, 80))
    skullEmitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0)})
    skullEmitter.Lifetime = NumberRange.new(0.6, 1.2)
    skullEmitter.Rate = 18
    skullEmitter.Speed = NumberRange.new(2, 4)
    skullEmitter.SpreadAngle = Vector2.new(360, 360)
    skullEmitter.Parent = root
end

local skullActive = false
CreateToggle("Meme: Skull Flame Aura", false, function(enabled)
    skullActive = enabled
    if enabled then
        if LocalPlayer.Character then SpawnSkullAura(LocalPlayer.Character) end
    else
        if skullEmitter then skullEmitter:Destroy() skullEmitter = nil end
    end
end)

CreateToggle("Midnight Moon Theme", false, function(enabled)
    Lighting.ClockTime = enabled and 0 or origClock
end)

-- ==================== КНОПКА ВЫГРУЗКИ (UNLOAD) ====================
local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Size = UDim2.new(1, -8, 0, 42)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(190, 45, 55)
UnloadBtn.BorderSizePixel = 0
UnloadBtn.Text = "Unload / Destroy Script"
UnloadBtn.Font = Enum.Font.GothamBold
UnloadBtn.TextSize = 13
UnloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnloadBtn.Parent = ScrollList

local UbCorner = Instance.new("UICorner")
UbCorner.CornerRadius = UDim.new(0, 8)
UbCorner.Parent = UnloadBtn

UnloadBtn.MouseButton1Click:Connect(function()
    if fpsConn then fpsConn:Disconnect() end
    if targetHudConn then targetHudConn:Disconnect() end
    if bhopConn then bhopConn:Disconnect() end
    if discoConn then discoConn:Disconnect() end
    if inputBeganConn then inputBeganConn:Disconnect() end
    if inputEndedConn then inputEndedConn:Disconnect() end

    Lighting.FogColor = origFogColor
    Lighting.FogStart = origFogStart
    Lighting.FogEnd = origFogEnd
    Lighting.ClockTime = origClock
    Camera.FieldOfView = origFov

    if Atmo then Atmo:Destroy() end
    if Bloom then Bloom:Destroy() end
    if Blur then Blur:Destroy() end
    if ColorCorr then ColorCorr:Destroy() end
    if skullEmitter then skullEmitter:Destroy() end

    ScreenGui:Destroy()
    print("[Kontra Hub] Unloaded cleanly!")
end)
