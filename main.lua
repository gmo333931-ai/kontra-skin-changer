-- Context: Luau / Roblox Client Environment
-- Target: Kontra (Roblox)
-- Description: Fully Rewritten, Bulletproof Visuals, Skins & HUD Client Suite

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Сохранение оригинальных параметров мира
local origLighting = {
    FogColor = Lighting.FogColor,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    ClockTime = Lighting.ClockTime,
    FieldOfView = Camera.FieldOfView
}

-- Хранилище подключений для чистого Unload
local Connections = {}
local function AddConn(conn)
    table.insert(Connections, conn)
    return conn
end

-- ==================== SCREEN GUI ====================
-- Удаляем старую версию, если она уже висит в памяти
if CoreGui:FindFirstChild("KontraUltimateSuite") then
    CoreGui.KontraUltimateSuite:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KontraUltimateSuite"
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
local Watermark = Instance.new("Frame")
Watermark.Name = "Watermark"
Watermark.Size = UDim2.fromOffset(250, 28)
Watermark.Position = UDim2.fromOffset(16, 16)
Watermark.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
Watermark.BackgroundTransparency = 0.15
Watermark.BorderSizePixel = 0
Watermark.Parent = ScreenGui

local WmCorner = Instance.new("UICorner")
WmCorner.CornerRadius = UDim.new(0, 6)
WmCorner.Parent = Watermark

local WmStroke = Instance.new("UIStroke")
WmStroke.Color = Color3.fromRGB(140, 85, 255)
WmStroke.Transparency = 0.4
WmStroke.Parent = Watermark

local WmLabel = Instance.new("TextLabel")
WmLabel.Size = UDim2.new(1, -12, 1, 0)
WmLabel.Position = UDim2.fromOffset(8, 0)
WmLabel.BackgroundTransparency = 1
WmLabel.Font = Enum.Font.GothamMedium
WmLabel.TextSize = 11
WmLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
WmLabel.TextXAlignment = Enum.TextXAlignment.Left
WmLabel.Text = "KONTRA CLIENT | 60 FPS"
WmLabel.Parent = Watermark

local frameCounter = 0
local lastFpsTime = os.clock()
AddConn(RunService.RenderStepped:Connect(function()
    frameCounter = frameCounter + 1
    local now = os.clock()
    if now - lastFpsTime >= 1 then
        local fps = frameCounter
        frameCounter = 0
        lastFpsTime = now
        
        local ping = 35
        pcall(function()
            ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        
        WmLabel.Text = string.format("KONTRA | %s | %d FPS | %d ms", LocalPlayer.DisplayName, fps, ping)
    end
end))

-- ==================== 2. TARGET HUD ====================
local TargetHUD = Instance.new("Frame")
TargetHUD.Name = "TargetHUD"
TargetHUD.Size = UDim2.fromOffset(220, 70)
TargetHUD.Position = UDim2.new(0.5, -110, 0.65, 0)
TargetHUD.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
TargetHUD.BackgroundTransparency = 0.15
TargetHUD.BorderSizePixel = 0
TargetHUD.Visible = false
TargetHUD.Parent = ScreenGui

local ThCorner = Instance.new("UICorner")
ThCorner.CornerRadius = UDim.new(0, 8)
ThCorner.Parent = TargetHUD

local ThStroke = Instance.new("UIStroke")
ThStroke.Color = Color3.fromRGB(140, 85, 255)
ThStroke.Transparency = 0.35
ThStroke.Parent = TargetHUD

local TargetAvatar = Instance.new("ImageLabel")
TargetAvatar.Size = UDim2.fromOffset(44, 44)
TargetAvatar.Position = UDim2.fromOffset(10, 13)
TargetAvatar.BackgroundColor3 = Color3.fromRGB(25, 25, 34)
TargetAvatar.BorderSizePixel = 0
TargetAvatar.Parent = TargetHUD

local AvCorner = Instance.new("UICorner")
AvCorner.CornerRadius = UDim.new(0, 6)
AvCorner.Parent = TargetAvatar

local TargetName = Instance.new("TextLabel")
TargetName.Size = UDim2.new(1, -70, 0, 16)
TargetName.Position = UDim2.fromOffset(62, 12)
TargetName.BackgroundTransparency = 1
TargetName.Font = Enum.Font.GothamBold
TargetName.TextSize = 13
TargetName.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetName.TextXAlignment = Enum.TextXAlignment.Left
TargetName.TextTruncate = Enum.TextTruncate.AtEnd
TargetName.Text = "Target"
TargetName.Parent = TargetHUD

local TargetDist = Instance.new("TextLabel")
TargetDist.Size = UDim2.new(1, -70, 0, 14)
TargetDist.Position = UDim2.fromOffset(62, 28)
TargetDist.BackgroundTransparency = 1
TargetDist.Font = Enum.Font.Gotham
TargetDist.TextSize = 11
TargetDist.TextColor3 = Color3.fromRGB(160, 160, 180)
TargetDist.TextXAlignment = Enum.TextXAlignment.Left
TargetDist.Text = "Dist: 0m"
TargetDist.Parent = TargetHUD

local HealthBg = Instance.new("Frame")
HealthBg.Size = UDim2.new(1, -72, 0, 7)
HealthBg.Position = UDim2.fromOffset(62, 48)
HealthBg.BackgroundColor3 = Color3.fromRGB(36, 36, 48)
HealthBg.BorderSizePixel = 0
HealthBg.Parent = TargetHUD

local HbCorner = Instance.new("UICorner")
HbCorner.CornerRadius = UDim.new(1, 0)
HbCorner.Parent = HealthBg

local HealthFill = Instance.new("Frame")
HealthFill.Size = UDim2.new(1, 0, 1, 0)
HealthFill.BackgroundColor3 = Color3.fromRGB(140, 85, 255)
HealthFill.BorderSizePixel = 0
HealthFill.Parent = HealthBg

local HfCorner = Instance.new("UICorner")
HfCorner.CornerRadius = UDim.new(1, 0)
HfCorner.Parent = HealthFill

local targetHudActive = true
local currentTargetPlr = nil

AddConn(RunService.RenderStepped:Connect(function()
    if not targetHudActive then
        TargetHUD.Visible = false
        return
    end

    local rayOrigin = Camera.CFrame.Position
    local rayDir = Camera.CFrame.LookVector * 300
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    if LocalPlayer.Character then
        rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    end

    local result = workspace:Raycast(rayOrigin, rayDir, rayParams)
    local found = nil

    if result and result.Instance then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and result.Instance:IsDescendantOf(plr.Character) then
                found = plr
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
            local dist = math.floor((root.Position - Camera.CFrame.Position).Magnitude)
            TargetDist.Text = string.format("Dist: %d studs | HP: %d", dist, math.floor(hum.Health))

            local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            TweenService:Create(HealthFill, TweenInfo.new(0.1), {Size = UDim2.new(ratio, 0, 1, 0)}):Play()

            if currentTargetPlr ~= found then
                currentTargetPlr = found
                task.spawn(function()
                    local thumb = Players:GetUserThumbnailAsync(found.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                    TargetAvatar.Image = thumb
                end)
            end
            return
        end
    end

    TargetHUD.Visible = false
end))

-- ==================== 3. SPECTATOR LIST ====================
local SpecFrame = Instance.new("Frame")
SpecFrame.Name = "SpectatorList"
SpecFrame.Size = UDim2.fromOffset(180, 100)
SpecFrame.Position = UDim2.new(1, -200, 0.4, 0)
SpecFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
SpecFrame.BackgroundTransparency = 0.2
SpecFrame.BorderSizePixel = 0
SpecFrame.Visible = false
SpecFrame.Parent = ScreenGui

local SfCorner = Instance.new("UICorner")
SfCorner.CornerRadius = UDim.new(0, 8)
SfCorner.Parent = SpecFrame

local SfStroke = Instance.new("UIStroke")
SfStroke.Color = Color3.fromRGB(140, 85, 255)
SfStroke.Transparency = 0.4
SfStroke.Parent = SpecFrame

local SfTitle = Instance.new("TextLabel")
SfTitle.Size = UDim2.new(1, -16, 0, 24)
SfTitle.Position = UDim2.fromOffset(10, 4)
SfTitle.BackgroundTransparency = 1
SfTitle.Font = Enum.Font.GothamBold
SfTitle.TextSize = 11
SfTitle.TextColor3 = Color3.fromRGB(240, 240, 255)
SfTitle.TextXAlignment = Enum.TextXAlignment.Left
SfTitle.Text = "SPECTATORS (0)"
SfTitle.Parent = SpecFrame

local SpecContainer = Instance.new("ScrollingFrame")
SpecContainer.Size = UDim2.new(1, -12, 1, -30)
SpecContainer.Position = UDim2.fromOffset(6, 26)
SpecContainer.BackgroundTransparency = 1
SpecContainer.BorderSizePixel = 0
SpecContainer.ScrollBarThickness = 2
SpecContainer.Parent = SpecFrame

local SpecLayout = Instance.new("UIListLayout")
SpecLayout.Padding = UDim.new(0, 3)
SpecLayout.Parent = SpecContainer

-- ==================== 4. БХОП ====================
local bhopActive = false
local spaceHeld = false

AddConn(UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Space then
        spaceHeld = true
    end
end))

AddConn(UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        spaceHeld = false
    end
end))

AddConn(RunService.RenderStepped:Connect(function()
    if bhopActive and spaceHeld then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.FloorMaterial ~= Enum.Material.Air then
                hum.Jump = true
            end
        end
    end
end))

-- ==================== 5. СКИН ЧЕНДЖЕР & RGB ====================
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

AddConn(Camera.ChildAdded:Connect(function(child)
    if skinActive then
        task.wait(0.05)
        ApplyWeaponSkin(child, Color3.fromRGB(255, 45, 120), Enum.Material.Neon)
    end
end))

AddConn(RunService.RenderStepped:Connect(function()
    if discoActive then
        local hue = (os.clock() * 0.4) % 1
        local col = Color3.fromHSV(hue, 0.9, 1)
        for _, child in ipairs(Camera:GetChildren()) do
            ApplyWeaponSkin(child, col, Enum.Material.Neon)
        end
    end
end))

-- ==================== 6. 2D СТРЕЛКИ ЗВУКОВ ШАГОВ ====================
local footstepArrowsActive = false
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
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local elapsed = os.clock() - startTime
        if elapsed >= 1.2 or not footstepArrowsActive then
            conn:Disconnect()
            arrow:Destroy()
            return
        end

        local camCF = Camera.CFrame
        local rel = camCF:VectorToObjectSpace(worldPos - camCF.Position)
        local angle = math.atan2(-rel.X, rel.Z)

        local offsetX = math.sin(angle) * 180
        local offsetY = -math.cos(angle) * 180

        arrow.Position = UDim2.fromOffset(screenCenter.X + offsetX, screenCenter.Y + offsetY)
        arrow.Rotation = math.deg(angle) + 180
        arrow.ImageTransparency = elapsed / 1.2
    end)
end

task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        task.wait(0.35)
        if footstepArrowsActive then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hum and root and hum.MoveDirection.Magnitude > 0.1 and hum.FloorMaterial ~= Enum.Material.Air then
                        local dist = (root.Position - Camera.CFrame.Position).Magnitude
                        if dist <= 85 then
                            SpawnArrow(root.Position)
                        end
                    end
                end
            end
        end
    end
end)

-- ==================== 7. ГЛАВНОЕ МЕНЮ ====================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(360, 480)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MfCorner = Instance.new("UICorner")
MfCorner.CornerRadius = UDim.new(0, 12)
MfCorner.Parent = MainFrame

local MfStroke = Instance.new("UIStroke")
MfStroke.Thickness = 1.5
MfStroke.Color = Color3.fromRGB(140, 85, 255)
MfStroke.Transparency = 0.25
MfStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 30)
Title.Position = UDim2.fromOffset(15, 8)
Title.BackgroundTransparency = 1
Title.Text = "KONTRA CLIENT SUITE"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(245, 245, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -20, 0, 16)
Subtitle.Position = UDim2.fromOffset(15, 34)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Press [RightShift] to Toggle Menu"
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 11
Subtitle.TextColor3 = Color3.fromRGB(150, 150, 175)
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = MainFrame

local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Name = "ScrollList"
ScrollList.Size = UDim2.new(1, -20, 1, -65)
ScrollList.Position = UDim2.fromOffset(10, 58)
ScrollList.BackgroundTransparency = 1
ScrollList.BorderSizePixel = 0
ScrollList.ScrollBarThickness = 4
ScrollList.ScrollBarImageColor3 = Color3.fromRGB(140, 85, 255)
ScrollList.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollList

-- Автоматический расчет высоты скролла без багов
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end)

-- Dragging мышью
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

AddConn(UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end))

AddConn(UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end))

-- Надежная функция создания кнопки-тумблера
local function CreateToggle(name, defaultState, callback)
    local state = defaultState

    local Button = Instance.new("TextButton")
    Button.Name = "Toggle_" .. name
    Button.Size = UDim2.new(1, -6, 0, 38)
    Button.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
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
    Dot.Parent = Indicator

    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = Dot

    Button.MouseButton1Click:Connect(function()
        state = not state
        local targetColor = state and Color3.fromRGB(140, 85, 255) or Color3.fromRGB(50, 50, 65)
        local targetPos = state and UDim2.fromOffset(19, 2) or UDim2.fromOffset(3, 2)

        TweenService:Create(Indicator, TweenInfo.new(0.18), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(Dot, TweenInfo.new(0.18), {Position = targetPos}):Play()
        pcall(callback, state)
    end)

    if defaultState then
        pcall(callback, true)
    end
end

-- ==================== ДОБАВЛЕНИЕ ВСЕХ ПУНКТОВ ====================

-- 1. Скины оружия
CreateToggle("Weapon Skin: Neon Pink", false, function(val)
    skinActive = val
    if val then
        for _, child in ipairs(Camera:GetChildren()) do
            ApplyWeaponSkin(child, Color3.fromRGB(255, 45, 120), Enum.Material.Neon)
        end
    end
end)

CreateToggle("Meme: RGB Rainbow Disco Gun", false, function(val)
    discoActive = val
end)

-- 2. HUD и инфо
CreateToggle("Target HUD (Minecraft Style)", true, function(val)
    targetHudActive = val
end)

CreateToggle("Spectator List Window", false, function(val)
    SpecFrame.Visible = val
end)

CreateToggle("Watermark FPS / Ping", true, function(val)
    Watermark.Visible = val
end)

CreateToggle("2D Footstep Sound Arrows", false, function(val)
    footstepArrowsActive = val
end)

-- 3. Движение
CreateToggle("Auto Bunnyhop (Hold Space)", false, function(val)
    bhopActive = val
end)

-- 4. Визуалы и мемы
CreateToggle("Meme: 120 Quake Fisheye FOV", false, function(val)
    Camera.FieldOfView = val and 120 or origLighting.FieldOfView
end)

local Atmo = nil
CreateToggle("Cyberpunk Purple Fog", false, function(val)
    if val then
        Lighting.FogColor = Color3.fromRGB(45, 15, 80)
        Lighting.FogStart = 0
        Lighting.FogEnd = 140
        if not Atmo then
            Atmo = Instance.new("Atmosphere")
            Atmo.Density = 0.45
            Atmo.Color = Color3.fromRGB(120, 50, 200)
            Atmo.Parent = Lighting
        end
    else
        Lighting.FogColor = origLighting.FogColor
        Lighting.FogEnd = origLighting.FogEnd
        if Atmo then Atmo:Destroy() Atmo = nil end
    end
end)

local Bloom = nil
local Blur = nil
CreateToggle("Cinematic Bloom & Glow", false, function(val)
    if val then
        Bloom = Instance.new("BloomEffect")
        Bloom.Intensity = 1.4
        Bloom.Size = 24
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
CreateToggle("Vibrant HDR Colors", false, function(val)
    if val then
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
CreateToggle("Meme: Skull Flame Aura", false, function(val)
    if val then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            skullEmitter = Instance.new("ParticleEmitter")
            skullEmitter.Texture = "rbxassetid://6031075938"
            skullEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 80, 80))
            skullEmitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0)})
            skullEmitter.Rate = 18
            skullEmitter.Parent = char.HumanoidRootPart
        end
    else
        if skullEmitter then skullEmitter:Destroy() skullEmitter = nil end
    end
end)

CreateToggle("Midnight Moon Theme", false, function(val)
    Lighting.ClockTime = val and 0 or origLighting.ClockTime
end)

-- ==================== КНОПКА ВЫГРУЗКИ (UNLOAD) ====================
local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Name = "UnloadBtn"
UnloadBtn.Size = UDim2.new(1, -6, 0, 40)
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
    for _, conn in ipairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end

    Lighting.FogColor = origLighting.FogColor
    Lighting.FogStart = origLighting.FogStart
    Lighting.FogEnd = origLighting.FogEnd
    Lighting.ClockTime = origLighting.ClockTime
    Camera.FieldOfView = origLighting.FieldOfView

    if Atmo then Atmo:Destroy() end
    if Bloom then Bloom:Destroy() end
    if Blur then Blur:Destroy() end
    if ColorCorr then ColorCorr:Destroy() end
    if skullEmitter then skullEmitter:Destroy() end

    ScreenGui:Destroy()
    print("[Kontra Hub] Cleanly Unloaded!")
end)

print("[Kontra Hub] Successfully loaded all modules and UI!")
