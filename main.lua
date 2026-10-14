-- Context: Luau / Roblox Client Environment
-- Target: Kontra (Roblox)
-- Description: Unified Hub (Visual Skin Changer + Atmosphere, Fog, Particles & UI)

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== SCREEN GUI SETUP ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KontraHubUI"
ScreenGui.ResetOnSpawn = false

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromOffset(380, 460)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1.5
UIStroke.Color = Color3.fromRGB(130, 80, 255)
UIStroke.Transparency = 0.25
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 35)
Title.Position = UDim2.fromOffset(15, 8)
Title.BackgroundTransparency = 1
Title.Text = "KONTRA CLIENT HUB"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(245, 245, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -20, 0, 18)
Subtitle.Position = UDim2.fromOffset(15, 34)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Skins & Visuals | Press [RightShift] to Toggle"
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 11
Subtitle.TextColor3 = Color3.fromRGB(150, 150, 175)
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = MainFrame

local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(1, -20, 1, -70)
ScrollList.Position = UDim2.fromOffset(10, 60)
ScrollList.BackgroundTransparency = 1
ScrollList.BorderSizePixel = 0
ScrollList.ScrollBarThickness = 4
ScrollList.ScrollBarImageColor3 = Color3.fromRGB(130, 80, 255)
ScrollList.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
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

-- Переключение меню на клавишу Right Shift
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Функция создания переключателя
local function CreateToggle(name, defaultState, onToggle)
    local state = defaultState

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 42)
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
    Label.TextSize = 13
    Label.TextColor3 = Color3.fromRGB(225, 225, 240)
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

-- ==================== SKIN CHANGER МОДУЛЬ ====================
local skinChangerActive = false

-- Базовый конфиг скинов (Цвета, материалы и кастомные текстуры)
local SkinPresets = {
    NeonCyber = {
        Color = Color3.fromRGB(255, 45, 120),
        Material = Enum.Material.Neon
    },
    GalacticPurple = {
        Color = Color3.fromRGB(140, 40, 255),
        Material = Enum.Material.ForceField
    },
    GoldGlaze = {
        Color = Color3.fromRGB(255, 200, 40),
        Material = Enum.Material.SmoothPlastic
    }
}

local currentPreset = SkinPresets.NeonCyber

local function ApplySkin(weaponModel)
    if not skinChangerActive or not weaponModel or not weaponModel:IsA("Model") then return end

    for _, part in ipairs(weaponModel:GetDescendants()) do
        if part:IsA("BasePart") and not part.Name:lower():find("arm") and not part.Name:lower():find("hand") then
            part.Color = currentPreset.Color
            part.Material = currentPreset.Material
        end
    end
end

-- Мониторинг оружия в камере
Camera.ChildAdded:Connect(function(child)
    if skinChangerActive then
        task.wait(0.05)
        ApplySkin(child)
    end
end)

-- Тумблеры скинов в меню
CreateToggle("Weapon Skin Changer (Neon Cyber)", false, function(enabled)
    skinChangerActive = enabled
    currentPreset = SkinPresets.NeonCyber
    if enabled then
        for _, child in ipairs(Camera:GetChildren()) do
            ApplySkin(child)
        end
    end
end)

CreateToggle("Weapon Skin: Galaxy ForceField", false, function(enabled)
    if enabled then
        skinChangerActive = true
        currentPreset = SkinPresets.GalacticPurple
        for _, child in ipairs(Camera:GetChildren()) do
            ApplySkin(child)
        end
    end
end)

-- ==================== ВИЗУАЛЬНЫЕ ЭФФЕКТЫ ====================

-- Неоновый фиолетовый туман
local AtmosphereInstance = nil
local originalFogColor = Lighting.FogColor
local originalFogEnd = Lighting.FogEnd

CreateToggle("Atmosphere & Fog", false, function(enabled)
    if enabled then
        Lighting.FogColor = Color3.fromRGB(45, 15, 80)
        Lighting.FogStart = 0
        Lighting.FogEnd = 160

        if not AtmosphereInstance then
            AtmosphereInstance = Instance.new("Atmosphere")
            AtmosphereInstance.Density = 0.4
            AtmosphereInstance.Color = Color3.fromRGB(120, 50, 200)
            AtmosphereInstance.Decay = Color3.fromRGB(40, 10, 60)
            AtmosphereInstance.Haze = 2
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

-- Блум и мягкое размытие
local BloomInstance = nil
local BlurInstance = nil

CreateToggle("Cinematic Bloom & Glow", false, function(enabled)
    if enabled then
        BloomInstance = Instance.new("BloomEffect")
        BloomInstance.Intensity = 1.3
        BloomInstance.Size = 22
        BloomInstance.Threshold = 0.8
        BloomInstance.Parent = Lighting

        BlurInstance = Instance.new("BlurEffect")
        BlurInstance.Size = 2
        BlurInstance.Parent = Lighting
    else
        if BloomInstance then BloomInstance:Destroy() BloomInstance = nil end
        if BlurInstance then BlurInstance:Destroy() BlurInstance = nil end
    end
end)

-- Партиклы вокруг персонажа
local activeEmitter = nil
local function SetupAura(char)
    if not char then return end
    local root = char:WaitForChild("HumanoidRootPart", 5)
    if not root then return end

    if activeEmitter then activeEmitter:Destroy() end

    activeEmitter = Instance.new("ParticleEmitter")
    activeEmitter.Name = "AuraParticles"
    activeEmitter.Texture = "rbxassetid://243098098"
    activeEmitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 100, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 200, 255))
    })
    activeEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.35),
        NumberSequenceKeypoint.new(1, 0)
    })
    activeEmitter.Lifetime = NumberRange.new(0.8, 1.4)
    activeEmitter.Rate = 20
    activeEmitter.Speed = NumberRange.new(1.2, 3.0)
    activeEmitter.SpreadAngle = Vector2.new(360, 360)
    activeEmitter.Parent = root
end

local auraEnabled = false
CreateToggle("Starlight Character Aura", false, function(enabled)
    auraEnabled = enabled
    if enabled then
        if LocalPlayer.Character then SetupAura(LocalPlayer.Character) end
    else
        if activeEmitter then activeEmitter:Destroy() activeEmitter = nil end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    if auraEnabled then
        task.wait(1)
        SetupAura(char)
    end
end)

-- Ночной режим
local originalClockTime = Lighting.ClockTime
CreateToggle("Night Mode (ClockTime 0)", false, function(enabled)
    if enabled then
        Lighting.ClockTime = 0
    else
        Lighting.ClockTime = originalClockTime
    end
end)
