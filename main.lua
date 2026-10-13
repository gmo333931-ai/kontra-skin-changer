made by Qusa: made by Qusa oils up, absolute made by Qusa — directional sound visualizer как в фортнайте, ловим звуки шагов и рисуем 2D стрелочку на экране по вектору камеры, watch this ez, 6767.

Title: Roblox Kontra Directional Footstep Indicator GUI

```lua
-- Context: Luau / Roblox Client Environment
-- Target: Kontra (Roblox)
-- Description: Directional screen-edge indicator for player footsteps (sound visualization)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Создание ScreenGui для индикаторов
local CoreGui = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FootstepVisualizer"
ScreenGui.ResetOnSpawn = false

-- Защита от детекта GUI через gethui / syn / защищенные контейнеры
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

-- Параметры визуализатора
local MAX_DISTANCE = 85 -- Максимальная дистанция слышимости шагов
local INDICATOR_RADIUS = 180 -- Радиус кольца индикаторов от центра экрана (в пикселях)
local FADE_TIME = 1.2 -- Время затухания стрелочки

-- Создание стрелки-индикатора
local function SpawnIndicator(worldPosition)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    local arrow = Instance.new("ImageLabel")
    arrow.Size = UDim2.fromOffset(24, 24)
    arrow.AnchorPoint = Vector2.new(0.5, 0.5)
    arrow.BackgroundTransparency = 1
    arrow.Image = "rbxassetid://6034818372" -- Стандартная стрелка Roblox
    arrow.ImageColor3 = Color3.fromRGB(255, 230, 80)
    arrow.ImageTransparency = 0
    arrow.Parent = ScreenGui

    local spawnTime = os.clock()
    local connection

    connection = RunService.RenderStepped:Connect(function()
        local elapsed = os.clock() - spawnTime
        if elapsed >= FADE_TIME then
            connection:Disconnect()
            arrow:Destroy()
            return
        end

        -- Вектор от камеры до источника звука
        local cameraCFrame = Camera.CFrame
        local toTarget = (worldPosition - cameraCFrame.Position)
        
        -- Проекция на плоскость взгляда камеры
        local relativeVector = cameraCFrame:VectorToObjectSpace(toTarget)
        local angle = math.atan2(-relativeVector.X, relativeVector.Z) -- Угол на плоскости

        -- Позиция по кругу вокруг прицела
        local offsetX = math.sin(angle) * INDICATOR_RADIUS
        local offsetY = -math.cos(angle) * INDICATOR_RADIUS

        arrow.Position = UDim2.fromOffset(screenCenter.X + offsetX, screenCenter.Y + offsetY)
        arrow.Rotation = math.deg(angle) + 180
        arrow.ImageTransparency = elapsed / FADE_TIME
    end)
end

-- Отслеживание шагов персонажей
local function TrackCharacter(character, player)
    if player == LocalPlayer then return end

    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoidRootPart or not humanoid then return end

    -- Вариант 1: Хук на воспроизведение аудиофайлов шагов внутри персонажа
    character.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Sound") then
            local soundName = descendant.Name:lower()
            if soundName:find("step") or soundName:find("foot") or soundName:find("walk") or soundName:find("run") then
                descendant.Played:Connect(function()
                    local dist = (humanoidRootPart.Position - Camera.CFrame.Position).Magnitude
                    if dist <= MAX_DISTANCE then
                        SpawnIndicator(humanoidRootPart.Position)
                    end
                end)
            end
        end
    end)

    -- Вариант 2: Отслеживание движения по земле (на случай если звуки воспроизводятся нестандартно)
    local lastStepTime = 0
    humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
        if humanoid.MoveDirection.Magnitude > 0.1 and humanoid.FloorMaterial ~= Enum.Material.Air then
            local now = os.clock()
            if now - lastStepTime > 0.35 then -- Интервал между шагами
                lastStepTime = now
                local dist = (humanoidRootPart.Position - Camera.CFrame.Position).Magnitude
                if dist <= MAX_DISTANCE then
                    SpawnIndicator(humanoidRootPart.Position)
                end
            end
        end
    end)
end

-- Подключение игроков
local function SetupPlayer(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function(char)
        TrackCharacter(char, player)
    end)
    if player.Character then
        TrackCharacter(player.Character, player)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    SetupPlayer(player)
end

Players.PlayerAdded:Connect(SetupPlayer)
```
