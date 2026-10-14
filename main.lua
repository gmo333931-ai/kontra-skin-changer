-- Context: Luau / Roblox Client Environment
-- Target: Kontra (Roblox)
-- Description: Dark Glassmorphic Visuals Menu (Atmosphere, Fog, Particles, Effects)

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- 1. Подготовка ScreenGui с защитой
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KontraVisualsUI"
ScreenGui.ResetOnSpawn = false

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

-- 2. Главный фрейм меню (Темный стеклянный стиль)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromOffset(360, 420)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1.5
UIStroke.Color = Color3.fromRGB(130, 80, 255)
UIStroke.Transparency = 0.3
UIStroke.Parent = MainFrame

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 45)
Title.Position = UDim2.fromOffset(15, 5)
Title.BackgroundTransparency = 1
Title.Text = "KONTRA VISUALS"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(240, 240, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -20, 0, 20)
Subtitle.Position = UDim2.fromOffset(15, 30)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Press [RightShift] to Toggle Menu"
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 11
Subtitle.TextColor3 = Color3.fromRGB(150, 150, 170)
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = MainFrame

-- Скролл-список для опций
local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(1, -20, 1, -65)
ScrollList.Position = UDim2.fromOffset(10, 55)
ScrollList.BackgroundTransparency = 1
ScrollList.BorderSizePixel = 0
ScrollList.ScrollBarThickness = 3
ScrollList.ScrollBarImageColor3 = Color3.fromRGB(130, 80, 255)
ScrollList.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollList

-- Dragging (перемещение окна мышью)
local isDragging = false
local dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- Хоткей закрытия/открытия (Right Shift)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- 3. Функция создания кнопки-переключателя (Toggle)
local function CreateToggle(name, defaultState, onToggle)
    local state = defaultState

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 42)
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
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
    Label.TextSize = 13
    Label.TextColor3 = Color3.fromRGB(220, 220, 235)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Button

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.fromOffset(36, 18)
    Indicator.Position = UDim2.new(1, -48, 0.5, -9)
    Indicator.BackgroundColor3 = state and Color3.fromRGB(130, 80, 255) or Color3.fromRGB(50, 50, 65)
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
        local targetColor = state and Color3.fromRGB(130, 80, 255) or Color3.fromRGB(50, 50, 65)
        local targetPos = state and UDim2.fromOffset(19, 2) or UDim2.fromOffset(3, 2)

        TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = targetPos}):Play()
        onToggle(state)
    end)

    if defaultState then
        onToggle(true)
    end
end

-- ==================== ВИЗУАЛЬНЫЕ ЭФФЕКТЫ ====================

-- 1. Киберпанк / Неоновый туман (Atmosphere & Fog)
local AtmosphereInstance = nil
local originalFogColor = Lighting.FogColor
local originalFogEnd = Lighting.FogEnd

CreateToggle("Cyberpunk Purple Fog", false, function(enabled)
    if enabled then
        Lighting.FogColor = Color3.fromRGB(45, 15, 80)
        Lighting.FogStart = 0
        Lighting.FogEnd = 140

        if not AtmosphereInstance then
            AtmosphereInstance = Instance.new("Atmosphere")
            AtmosphereInstance.Density = 0.45
            AtmosphereInstance.Offset = 0.25
            AtmosphereInstance.Color = Color3.fromRGB(120, 50, 200)
            AtmosphereInstance.Decay = Color3.fromRGB(40, 10, 60)
            AtmosphereInstance.Glare = 0.3
            AtmosphereInstance.Haze = 2.5
            AtmosphereInstance.Parent = Lighting
        end
    else
        Lighting.FogColor = originalFogColor
        Lighting.FogEnd = originalFogEnd
        if AtmosphereInstance then
            AtmosphereInstance:Destroy()
            AtmosphereInstance = nil
        end
    end
end)

-- 2. Кинематографичный Bloom & Blur
local BloomInstance = nil
local BlurInstance = nil

CreateToggle("Cinematic Bloom & Soft Blur", false, function(enabled)
    if enabled then
        BloomInstance = Instance.new("BloomEffect")
        BloomInstance.Intensity = 1.4
        BloomInstance.Size = 24
        BloomInstance.Threshold = 0.8
        BloomInstance.Parent = Lighting

        BlurInstance = Instance.new("BlurEffect")
        BlurInstance.Size = 2.5
        BlurInstance.Parent = Lighting
    else
        if BloomInstance then BloomInstance:Destroy() BloomInstance = nil end
        if BlurInstance then BlurInstance:Destroy() BlurInstance = nil end
    end
end)

-- 3. Насыщенная цветокоррекция (ColorCorrection)
local ColorCorrect = nil
CreateToggle("Vibrant HDR Colors", false, function(enabled)
    if enabled then
        ColorCorrect = Instance.new("ColorCorrectionEffect")
        ColorCorrect.Brightness = 0.05
        ColorCorrect.Contrast = 0.25
        ColorCorrect.Saturation = 0.4
        ColorCorrect.TintColor = Color3.fromRGB(245, 240, 255)
        ColorCorrect.Parent = Lighting
    else
        if ColorCorrect then ColorCorrect:Destroy() ColorCorrect = nil end
    end
end)

-- 4. Магические светящиеся партиклы вокруг персонажа
local activeEmitter = nil
local function AttachParticles(char)
    if not char then return end
    local root = char:WaitForChild("HumanoidRootPart", 5)
    if not root then return end

    if activeEmitter then activeEmitter:Destroy() end

    activeEmitter = Instance.new("ParticleEmitter")
    activeEmitter.Name = "CustomAuraParticles"
    activeEmitter.Texture = "rbxassetid://243098098" -- Звездочки/светящиеся искры
    activeEmitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 100, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 200, 255))
    })
    activeEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(1, 0)
    })
    activeEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    activeEmitter.Lifetime = NumberRange.new(0.8, 1.5)
    activeEmitter.Rate = 22
    activeEmitter.Speed = NumberRange.new(1.5, 3.5)
    activeEmitter.SpreadAngle = Vector2.new(360, 360)
    activeEmitter.Parent = root
end

local particlesEnabled = false
CreateToggle("Starlight Character Aura", false, function(enabled)
    particlesEnabled = enabled
    if enabled then
        if LocalPlayer.Character then
            AttachParticles(LocalPlayer.Character)
        end
    else
        if activeEmitter then
            activeEmitter:Destroy()
            activeEmitter = nil
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    if particlesEnabled then
        task.wait(1)
        AttachParticles(char)
    end
end)

-- 5. Ночной режим неба (Midnight Sky)
local originalClockTime = Lighting.ClockTime
CreateToggle("Midnight Moon Theme", false, function(enabled)
    if enabled then
        Lighting.ClockTime = 0
    else
        Lighting.ClockTime = originalClockTime
    end
end)
