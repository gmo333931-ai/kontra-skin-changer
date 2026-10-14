--[[
    KONTRA CLIENT v4
    No FOV (anti-kick), extended safe visuals
]]

local Players      = game:GetService("Players")
local Lighting     = game:GetService("Lighting")
local Tween        = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local Run          = game:GetService("RunService")
local CoreGui      = game:GetService("CoreGui")

local LP  = Players.LocalPlayer
local Cam = workspace.CurrentCamera

local O = {
    FogC = Lighting.FogColor, FogS = Lighting.FogStart, FogE = Lighting.FogEnd,
    Clock = Lighting.ClockTime, Bright = Lighting.Brightness, Shadow = Lighting.GlobalShadows,
}

local _C, _FX = {}, {}
local function C(c) table.insert(_C, c) return c end
local function AddFX(cls, p) local i = Instance.new(cls); for k,v in pairs(p) do i[k]=v end; i.Parent = Lighting; table.insert(_FX, i); return i end
local function RemFX(i) if i then for x=#_FX,1,-1 do if _FX[x]==i then table.remove(_FX,x) end end; i:Destroy() end; return nil end

pcall(function() if CoreGui:FindFirstChild("KontraV4") then CoreGui.KontraV4:Destroy() end end)

local G = Instance.new("ScreenGui")
G.Name = "KontraV4"; G.ResetOnSpawn = false; G.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(G); G.Parent = CoreGui
    elseif gethui then G.Parent = gethui()
    else G.Parent = CoreGui end
end)
if not G.Parent then G.Parent = LP:WaitForChild("PlayerGui") end

local T = {
    bg = Color3.fromRGB(12,12,18), panel = Color3.fromRGB(18,18,26),
    card = Color3.fromRGB(24,24,34), hover = Color3.fromRGB(32,32,44),
    accent = Color3.fromRGB(120,75,255), accent2 = Color3.fromRGB(180,120,255),
    dim = Color3.fromRGB(44,44,58), text = Color3.fromRGB(235,235,250),
    sub = Color3.fromRGB(130,130,155), red = Color3.fromRGB(210,50,60),
}

-- ══════════════════════════════════════════
--  WATERMARK
-- ══════════════════════════════════════════
local WM = Instance.new("Frame")
WM.Size = UDim2.fromOffset(280,26); WM.Position = UDim2.fromOffset(12,12)
WM.BackgroundColor3 = T.bg; WM.BackgroundTransparency = 0.15; WM.BorderSizePixel = 0; WM.Parent = G
Instance.new("UICorner", WM).CornerRadius = UDim.new(0,6)
local wms = Instance.new("UIStroke", WM); wms.Color = T.accent; wms.Transparency = 0.5

local WMT = Instance.new("TextLabel")
WMT.Size = UDim2.new(1,-14,1,0); WMT.Position = UDim2.fromOffset(8,0)
WMT.BackgroundTransparency = 1; WMT.Font = Enum.Font.GothamMedium; WMT.TextSize = 11
WMT.TextColor3 = T.text; WMT.TextXAlignment = Enum.TextXAlignment.Left
WMT.Text = "KONTRA v4"; WMT.Parent = WM

local fc, fl = 0, os.clock()
C(Run.RenderStepped:Connect(function()
    fc = fc + 1; local n = os.clock()
    if n - fl >= 1 then
        local fps = fc; fc = 0; fl = n; local p = 0
        pcall(function() p = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        WMT.Text = string.format("KONTRA v4  |  %s  |  %d FPS  |  %dms", LP.DisplayName, fps, p)
    end
end))

-- ══════════════════════════════════════════
--  TARGET HUD
-- ══════════════════════════════════════════
local TH = Instance.new("Frame")
TH.Size = UDim2.fromOffset(215,66); TH.Position = UDim2.new(0.5,-107,0.63,0)
TH.BackgroundColor3 = T.bg; TH.BackgroundTransparency = 0.12; TH.BorderSizePixel = 0
TH.Visible = false; TH.Parent = G
Instance.new("UICorner", TH).CornerRadius = UDim.new(0,10)
Instance.new("UIStroke", TH).Color = T.accent

local THAv = Instance.new("ImageLabel")
THAv.Size = UDim2.fromOffset(40,40); THAv.Position = UDim2.fromOffset(10,13)
THAv.BackgroundColor3 = T.card; THAv.BorderSizePixel = 0; THAv.Parent = TH
Instance.new("UICorner", THAv).CornerRadius = UDim.new(0,6)

local THN = Instance.new("TextLabel")
THN.Size = UDim2.new(1,-62,0,16); THN.Position = UDim2.fromOffset(56,10)
THN.BackgroundTransparency = 1; THN.Font = Enum.Font.GothamBold; THN.TextSize = 12
THN.TextColor3 = T.text; THN.TextXAlignment = Enum.TextXAlignment.Left
THN.TextTruncate = Enum.TextTruncate.AtEnd; THN.Text = ""; THN.Parent = TH

local THI = Instance.new("TextLabel")
THI.Size = UDim2.new(1,-62,0,12); THI.Position = UDim2.fromOffset(56,26)
THI.BackgroundTransparency = 1; THI.Font = Enum.Font.Gotham; THI.TextSize = 10
THI.TextColor3 = T.sub; THI.TextXAlignment = Enum.TextXAlignment.Left; THI.Text = ""; THI.Parent = TH

local THBg = Instance.new("Frame")
THBg.Size = UDim2.new(1,-66,0,6); THBg.Position = UDim2.fromOffset(56,44)
THBg.BackgroundColor3 = T.dim; THBg.BorderSizePixel = 0; THBg.Parent = TH
Instance.new("UICorner", THBg).CornerRadius = UDim.new(1,0)

local THF = Instance.new("Frame")
THF.Size = UDim2.new(1,0,1,0); THF.BackgroundColor3 = T.accent; THF.BorderSizePixel = 0; THF.Parent = THBg
Instance.new("UICorner", THF).CornerRadius = UDim.new(1,0)

local thOn, thC = true, nil
C(Run.RenderStepped:Connect(function()
    if not thOn then TH.Visible = false return end
    local o = Cam.CFrame.Position; local d = Cam.CFrame.LookVector * 300
    local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Exclude
    if LP.Character then rp.FilterDescendantsInstances = {LP.Character} end
    local r = workspace:Raycast(o, d, rp); local fp = nil
    if r and r.Instance then
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and pl.Character and r.Instance:IsDescendantOf(pl.Character) then fp = pl break end
        end
    end
    if fp and fp.Character then
        local h = fp.Character:FindFirstChildOfClass("Humanoid")
        local rt = fp.Character:FindFirstChild("HumanoidRootPart")
        if h and h.Health > 0 and rt then
            TH.Visible = true; THN.Text = fp.DisplayName
            THI.Text = string.format("%d studs | %d HP", math.floor((rt.Position-o).Magnitude), math.floor(h.Health))
            Tween:Create(THF, TweenInfo.new(0.1), {Size = UDim2.new(math.clamp(h.Health/h.MaxHealth,0,1),0,1,0)}):Play()
            if thC ~= fp then thC = fp
                task.spawn(function() pcall(function()
                    THAv.Image = Players:GetUserThumbnailAsync(fp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                end) end)
            end return
        end
    end
    TH.Visible = false
end))

-- ══════════════════════════════════════════
--  SPECTATOR LIST
-- ══════════════════════════════════════════
local SP = Instance.new("Frame")
SP.Size = UDim2.fromOffset(170,95); SP.Position = UDim2.new(1,-190,0.4,0)
SP.BackgroundColor3 = T.bg; SP.BackgroundTransparency = 0.15; SP.BorderSizePixel = 0
SP.Visible = false; SP.Parent = G
Instance.new("UICorner", SP).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", SP).Color = T.accent

local SPT = Instance.new("TextLabel")
SPT.Size = UDim2.new(1,-10,0,20); SPT.Position = UDim2.fromOffset(8,3)
SPT.BackgroundTransparency = 1; SPT.Font = Enum.Font.GothamBold; SPT.TextSize = 10
SPT.TextColor3 = T.text; SPT.TextXAlignment = Enum.TextXAlignment.Left
SPT.Text = "SPECTATORS (0)"; SPT.Parent = SP

local SPS = Instance.new("ScrollingFrame")
SPS.Size = UDim2.new(1,-8,1,-24); SPS.Position = UDim2.fromOffset(4,22)
SPS.BackgroundTransparency = 1; SPS.BorderSizePixel = 0; SPS.ScrollBarThickness = 2; SPS.Parent = SP
Instance.new("UIListLayout", SPS).Padding = UDim.new(0,2)

task.spawn(function()
    while G and G.Parent do
        for _,ch in ipairs(SPS:GetChildren()) do if ch:IsA("TextLabel") then ch:Destroy() end end
        local ct = 0
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP then
                local sv = pl:FindFirstChild("Spectating") or pl:FindFirstChild("SpectateTarget")
                if sv and (sv.Value == LP or sv.Value == LP.Character) then
                    ct = ct + 1
                    local r = Instance.new("TextLabel"); r.Size = UDim2.new(1,0,0,14); r.BackgroundTransparency = 1
                    r.Font = Enum.Font.Gotham; r.TextSize = 10; r.TextColor3 = T.sub
                    r.TextXAlignment = Enum.TextXAlignment.Left; r.Text = "  "..pl.DisplayName; r.Parent = SPS
                end
            end
        end
        SPT.Text = string.format("SPECTATORS (%d)", ct)
        task.wait(1.5)
    end
end)

-- ══════════════════════════════════════════
--  CUSTOM CROSSHAIR OVERLAY
-- ══════════════════════════════════════════
local CrosshairFrame = Instance.new("Frame")
CrosshairFrame.Size = UDim2.fromOffset(20, 20)
CrosshairFrame.Position = UDim2.new(0.5, -10, 0.5, -10)
CrosshairFrame.BackgroundTransparency = 1
CrosshairFrame.Visible = false
CrosshairFrame.Parent = G

-- Центральная точка
local dot = Instance.new("Frame")
dot.Size = UDim2.fromOffset(4, 4)
dot.Position = UDim2.fromOffset(8, 8)
dot.BackgroundColor3 = T.accent
dot.BorderSizePixel = 0
dot.Parent = CrosshairFrame
Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

-- Линии крестика
local function MakeLine(sx, sy, px, py)
    local l = Instance.new("Frame")
    l.Size = UDim2.fromOffset(sx, sy)
    l.Position = UDim2.fromOffset(px, py)
    l.BackgroundColor3 = T.accent
    l.BorderSizePixel = 0
    l.Parent = CrosshairFrame
end
MakeLine(2, 8, 9, -2)  -- верх
MakeLine(2, 8, 9, 14)  -- низ
MakeLine(8, 2, -2, 9)  -- лево
MakeLine(8, 2, 14, 9)  -- право

-- ══════════════════════════════════════════
--  VIGNETTE OVERLAY
-- ══════════════════════════════════════════
local Vignette = Instance.new("ImageLabel")
Vignette.Size = UDim2.new(1, 0, 1, 0)
Vignette.BackgroundTransparency = 1
Vignette.Image = "rbxassetid://115339939" -- Стандартная виньетка
Vignette.ImageColor3 = Color3.fromRGB(0, 0, 0)
Vignette.ImageTransparency = 0.3
Vignette.ScaleType = Enum.ScaleType.Stretch
Vignette.Visible = false
Vignette.Parent = G

-- ══════════════════════════════════════════
--  CRT SCANLINES OVERLAY
-- ══════════════════════════════════════════
local Scanlines = Instance.new("ImageLabel")
Scanlines.Size = UDim2.new(1, 0, 1, 0)
Scanlines.BackgroundTransparency = 1
Scanlines.Image = "rbxassetid://594768795" -- Паттерн сканлайнов
Scanlines.ImageTransparency = 0.85
Scanlines.ScaleType = Enum.ScaleType.Tile
Scanlines.TileSize = UDim2.fromOffset(100, 4)
Scanlines.Visible = false
Scanlines.Parent = G

-- ══════════════════════════════════════════
--  DAMAGE FLASH (красный экран при получении урона)
-- ══════════════════════════════════════════
local DmgFlash = Instance.new("Frame")
DmgFlash.Size = UDim2.new(1,0,1,0)
DmgFlash.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
DmgFlash.BackgroundTransparency = 1
DmgFlash.BorderSizePixel = 0
DmgFlash.Visible = false
DmgFlash.Parent = G

local dmgFlashOn = false
local function FlashDamage()
    if not dmgFlashOn then return end
    DmgFlash.Visible = true
    DmgFlash.BackgroundTransparency = 0.6
    Tween:Create(DmgFlash, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
    task.delay(0.45, function() DmgFlash.Visible = false end)
end

local function HookDamageFlash(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    local lastHP = hum.Health
    hum.HealthChanged:Connect(function(newHP)
        if newHP < lastHP then FlashDamage() end
        lastHP = newHP
    end)
end

-- ══════════════════════════════════════════
--  BHOP (FIXED)
-- ══════════════════════════════════════════
local bhopOn = false
C(Run.Stepped:Connect(function()
    if not bhopOn then return end
    pcall(function()
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            local ch = LP.Character
            if ch then
                local hum = ch:FindFirstChildOfClass("Humanoid")
                if hum then
                    local st = hum:GetState()
                    if st == Enum.HumanoidStateType.Running or st == Enum.HumanoidStateType.Landed or st == Enum.HumanoidStateType.RunningNoPhysics then
                        hum.Jump = true
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end
    end)
end))

-- ══════════════════════════════════════════
--  SKIN CHANGER (FIXED)
-- ══════════════════════════════════════════
local skinOn, discoOn = false, false
local skinCol = Color3.fromRGB(255,45,120)
local skinMat = Enum.Material.Neon

local function Paint(model, col, mat)
    if not model then return end
    for _, p in ipairs(model:GetDescendants()) do
        local nm = p.Name:lower()
        local skip = nm:find("arm") or nm:find("hand") or nm:find("torso") or nm:find("head") or nm:find("leg") or nm:find("humanoid")
        if not skip then
            if p:IsA("BasePart") then p.Color = col; p.Material = mat
                if p:IsA("MeshPart") and p.TextureID ~= "" then p.TextureID = "" end
            end
            if p:IsA("SpecialMesh") then pcall(function() p.TextureId = "" end) end
            if p:IsA("Decal") or p:IsA("Texture") then pcall(function() p.Transparency = 1 end) end
        end
    end
end

C(Cam.ChildAdded:Connect(function(ch) task.wait(0.08); if skinOn and not discoOn then Paint(ch, skinCol, skinMat) end end))
C(Run.Heartbeat:Connect(function()
    if skinOn and not discoOn then
        for _, ch in ipairs(Cam:GetChildren()) do if ch:IsA("Model") then Paint(ch, skinCol, skinMat) end end
    end
end))
C(Run.RenderStepped:Connect(function()
    if discoOn then
        local col = Color3.fromHSV((os.clock()*0.5)%1, 0.9, 1)
        for _, ch in ipairs(Cam:GetChildren()) do Paint(ch, col, Enum.Material.Neon) end
    end
end))

-- ══════════════════════════════════════════
--  2D FOOTSTEP ARROWS (FIXED)
-- ══════════════════════════════════════════
local arrowOn = false
local function MakeArrow(pos)
    if not arrowOn then return end
    local cx, cy = Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.fromOffset(24,24); img.AnchorPoint = Vector2.new(0.5,0.5)
    img.BackgroundTransparency = 1; img.Image = "rbxassetid://6034818372"
    img.ImageColor3 = Color3.fromRGB(255,210,50); img.Parent = G
    local t0 = os.clock(); local cn
    cn = Run.RenderStepped:Connect(function()
        local dt = os.clock()-t0
        if dt >= 1 or not arrowOn then cn:Disconnect() img:Destroy() return end
        local rel = Cam.CFrame:VectorToObjectSpace(pos - Cam.CFrame.Position)
        local a = math.atan2(-rel.X, rel.Z)
        img.Position = UDim2.fromOffset(cx + math.sin(a)*165, cy - math.cos(a)*165)
        img.Rotation = math.deg(a) + 180; img.ImageTransparency = dt
    end)
end

task.spawn(function()
    while G and G.Parent do
        task.wait(0.4)
        if arrowOn then
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LP and pl.Character then
                    local root = pl.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local vel = root.AssemblyLinearVelocity
                        local hz = Vector3.new(vel.X, 0, vel.Z).Magnitude
                        if hz > 3 and math.abs(vel.Y) < 10 then
                            if (root.Position - Cam.CFrame.Position).Magnitude <= 80 then
                                MakeArrow(root.Position)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ══════════════════════════════════════════
--  CHARACTER TRAIL
-- ══════════════════════════════════════════
local trailOn = false
local trailInst, trailA0, trailA1 = nil, nil, nil

local function MakeTrail(char)
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not root or not head then return end

    -- Убираем старый трейл
    if trailInst then pcall(function() trailInst:Destroy() end) end
    if trailA0 then pcall(function() trailA0:Destroy() end) end
    if trailA1 then pcall(function() trailA1:Destroy() end) end

    trailA0 = Instance.new("Attachment"); trailA0.Position = Vector3.new(0, 0.5, 0); trailA0.Parent = root
    trailA1 = Instance.new("Attachment"); trailA1.Position = Vector3.new(0, -0.5, 0); trailA1.Parent = root

    trailInst = Instance.new("Trail")
    trailInst.Attachment0 = trailA0
    trailInst.Attachment1 = trailA1
    trailInst.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 80, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 180, 255)),
    })
    trailInst.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 1),
    })
    trailInst.Lifetime = 0.5
    trailInst.MinLength = 0.1
    trailInst.LightEmission = 0.6
    trailInst.Parent = root
end

local function KillTrail()
    if trailInst then pcall(function() trailInst:Destroy() end) trailInst = nil end
    if trailA0 then pcall(function() trailA0:Destroy() end) trailA0 = nil end
    if trailA1 then pcall(function() trailA1:Destroy() end) trailA1 = nil end
end

-- ══════════════════════════════════════════
--  POINTLIGHT GLOW
-- ══════════════════════════════════════════
local glowOn = false
local glowLight = nil
local glowConn = nil

local function MakeGlow(char)
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if glowLight then pcall(function() glowLight:Destroy() end) end

    glowLight = Instance.new("PointLight")
    glowLight.Color = T.accent
    glowLight.Brightness = 2
    glowLight.Range = 18
    glowLight.Parent = root
end

-- ══════════════════════════════════════════
--  MAIN MENU
-- ══════════════════════════════════════════
local M = Instance.new("Frame")
M.Size = UDim2.fromOffset(340,470); M.Position = UDim2.fromScale(0.5,0.5)
M.AnchorPoint = Vector2.new(0.5,0.5); M.BackgroundColor3 = T.panel
M.BackgroundTransparency = 0.06; M.BorderSizePixel = 0; M.Parent = G
Instance.new("UICorner", M).CornerRadius = UDim.new(0,14)
local mst = Instance.new("UIStroke", M); mst.Thickness = 1.4; mst.Color = T.accent; mst.Transparency = 0.2

local bar = Instance.new("Frame")
bar.Size = UDim2.new(1,-24,0,3); bar.Position = UDim2.fromOffset(12,8)
bar.BackgroundColor3 = T.accent; bar.BorderSizePixel = 0; bar.Parent = M
Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)
local gr = Instance.new("UIGradient", bar)
gr.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, T.accent), ColorSequenceKeypoint.new(1, T.accent2)})

local ttl = Instance.new("TextLabel")
ttl.Size = UDim2.new(1,-24,0,24); ttl.Position = UDim2.fromOffset(14,16)
ttl.BackgroundTransparency = 1; ttl.Text = "KONTRA CLIENT v4"
ttl.Font = Enum.Font.GothamBold; ttl.TextSize = 16; ttl.TextColor3 = T.text
ttl.TextXAlignment = Enum.TextXAlignment.Left; ttl.Parent = M

local stl = Instance.new("TextLabel")
stl.Size = UDim2.new(1,-24,0,14); stl.Position = UDim2.fromOffset(14,37)
stl.BackgroundTransparency = 1; stl.Text = "[RShift] Toggle  •  Drag to move"
stl.Font = Enum.Font.Gotham; stl.TextSize = 10; stl.TextColor3 = T.sub
stl.TextXAlignment = Enum.TextXAlignment.Left; stl.Parent = M

local SL = Instance.new("ScrollingFrame")
SL.Size = UDim2.new(1,-16,1,-62); SL.Position = UDim2.fromOffset(8,56)
SL.BackgroundTransparency = 1; SL.BorderSizePixel = 0; SL.ScrollBarThickness = 3
SL.ScrollBarImageColor3 = T.accent; SL.Parent = M

local LL = Instance.new("UIListLayout"); LL.Padding = UDim.new(0,4); LL.SortOrder = Enum.SortOrder.LayoutOrder; LL.Parent = SL
LL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SL.CanvasSize = UDim2.new(0,0,0,LL.AbsoluteContentSize.Y + 12)
end)

local dg, ds, dp = false, nil, nil
M.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then
    dg = true; ds = i.Position; dp = M.Position
    i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dg = false end end)
end end)
C(UIS.InputChanged:Connect(function(i) if dg and i.UserInputType == Enum.UserInputType.MouseMovement then
    local d = i.Position - ds; M.Position = UDim2.new(dp.X.Scale, dp.X.Offset+d.X, dp.Y.Scale, dp.Y.Offset+d.Y)
end end))
C(UIS.InputBegan:Connect(function(i,g) if not g and i.KeyCode == Enum.KeyCode.RightShift then M.Visible = not M.Visible end end))

local ord = 0
local function NO() ord = ord+1 return ord end

local function Section(txt)
    local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,20); f.BackgroundTransparency = 1; f.LayoutOrder = NO(); f.Parent = SL
    local l = Instance.new("TextLabel"); l.Size = UDim2.new(1,-8,1,0); l.Position = UDim2.fromOffset(4,0)
    l.BackgroundTransparency = 1; l.Font = Enum.Font.GothamBold; l.TextSize = 10
    l.TextColor3 = T.accent; l.TextXAlignment = Enum.TextXAlignment.Left; l.Text = "━  "..txt:upper(); l.Parent = f
    local ln = Instance.new("Frame"); ln.Size = UDim2.new(1,-8,0,1); ln.Position = UDim2.new(0,4,1,-1)
    ln.BackgroundColor3 = T.dim; ln.BackgroundTransparency = 0.5; ln.BorderSizePixel = 0; ln.Parent = f
end

local function Toggle(name, def, cb)
    local st = def
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1,-4,0,32)
    btn.BackgroundColor3 = T.card; btn.BorderSizePixel = 0; btn.Text = ""; btn.AutoButtonColor = false
    btn.LayoutOrder = NO(); btn.Parent = SL
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,7)

    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1,-54,1,0); lbl.Position = UDim2.fromOffset(10,0)
    lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 11
    lbl.TextColor3 = T.text; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = btn

    local tr = Instance.new("Frame"); tr.Size = UDim2.fromOffset(32,16)
    tr.Position = UDim2.new(1,-42,0.5,-8); tr.BackgroundColor3 = st and T.accent or T.dim
    tr.BorderSizePixel = 0; tr.Parent = btn
    Instance.new("UICorner", tr).CornerRadius = UDim.new(1,0)

    local kn = Instance.new("Frame"); kn.Size = UDim2.fromOffset(12,12)
    kn.Position = st and UDim2.fromOffset(17,2) or UDim2.fromOffset(3,2)
    kn.BackgroundColor3 = Color3.new(1,1,1); kn.BorderSizePixel = 0; kn.Parent = tr
    Instance.new("UICorner", kn).CornerRadius = UDim.new(1,0)

    btn.MouseButton1Click:Connect(function()
        st = not st
        Tween:Create(tr, TweenInfo.new(0.15), {BackgroundColor3 = st and T.accent or T.dim}):Play()
        Tween:Create(kn, TweenInfo.new(0.15), {Position = st and UDim2.fromOffset(17,2) or UDim2.fromOffset(3,2)}):Play()
        pcall(cb, st)
    end)
    btn.MouseEnter:Connect(function() Tween:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = T.hover}):Play() end)
    btn.MouseLeave:Connect(function() Tween:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = T.card}):Play() end)
    if def then pcall(cb, true) end
end

-- ══════════════════════════════════════════
--  ВСЕ ПУНКТЫ
-- ══════════════════════════════════════════

Section("Weapon Skins")
Toggle("Neon Cyber Pink", false, function(v) skinOn=v; discoOn=false; skinCol=Color3.fromRGB(255,45,120); skinMat=Enum.Material.Neon end)
Toggle("Ice Diamond", false, function(v) skinOn=v; discoOn=false; skinCol=Color3.fromRGB(120,220,255); skinMat=Enum.Material.Glass end)
Toggle("Gold Prestige", false, function(v) skinOn=v; discoOn=false; skinCol=Color3.fromRGB(255,195,40); skinMat=Enum.Material.SmoothPlastic end)
Toggle("ForceField Galaxy", false, function(v) skinOn=v; discoOn=false; skinCol=Color3.fromRGB(140,40,255); skinMat=Enum.Material.ForceField end)
Toggle("Lava Inferno", false, function(v) skinOn=v; discoOn=false; skinCol=Color3.fromRGB(255,80,20); skinMat=Enum.Material.Neon end)
Toggle("Emerald Toxic", false, function(v) skinOn=v; discoOn=false; skinCol=Color3.fromRGB(40,255,80); skinMat=Enum.Material.Neon end)
Toggle("RGB Rainbow Disco", false, function(v) discoOn=v; if v then skinOn=false end end)

Section("HUD & Info")
Toggle("Target HUD", true, function(v) thOn=v end)
Toggle("Spectator List", false, function(v) SP.Visible=v end)
Toggle("Watermark (FPS/Ping)", true, function(v) WM.Visible=v end)
Toggle("Footstep Sound Arrows", false, function(v) arrowOn=v end)
Toggle("Custom Crosshair", false, function(v) CrosshairFrame.Visible=v end)

Section("Movement")
Toggle("Auto Bunnyhop (Hold Space)", false, function(v) bhopOn=v end)

Section("Screen Effects")
Toggle("Vignette (Dark Edges)", false, function(v) Vignette.Visible=v end)
Toggle("CRT Scanlines Overlay", false, function(v) Scanlines.Visible=v end)
Toggle("Damage Flash (Red Screen)", false, function(v)
    dmgFlashOn = v
    if v and LP.Character then HookDamageFlash(LP.Character) end
end)

Section("World Visuals")

local atmo = nil
Toggle("Purple Cyberpunk Fog", false, function(v)
    if v then Lighting.FogColor=Color3.fromRGB(40,12,75); Lighting.FogStart=0; Lighting.FogEnd=160
        atmo = AddFX("Atmosphere",{Density=0.4,Color=Color3.fromRGB(110,45,200),Haze=2})
    else Lighting.FogColor=O.FogC; Lighting.FogStart=O.FogS; Lighting.FogEnd=O.FogE; atmo=RemFX(atmo) end
end)

local blm, blr = nil, nil
Toggle("Cinematic Bloom & Blur", false, function(v)
    if v then blm=AddFX("BloomEffect",{Intensity=1.3,Size=22,Threshold=0.8}); blr=AddFX("BlurEffect",{Size=2.5})
    else blm=RemFX(blm); blr=RemFX(blr) end
end)

local cc = nil
Toggle("Vibrant HDR Colors", false, function(v)
    if v then cc=AddFX("ColorCorrectionEffect",{Brightness=0.04,Contrast=0.22,Saturation=0.45})
    else cc=RemFX(cc) end
end)

local sr = nil
Toggle("Sun Rays (God Rays)", false, function(v)
    if v then sr=AddFX("SunRaysEffect",{Intensity=0.12,Spread=0.8}) else sr=RemFX(sr) end
end)

local dof = nil
Toggle("Depth of Field (Bokeh)", false, function(v)
    if v then dof=AddFX("DepthOfFieldEffect",{FarIntensity=0.2,FocusDistance=30,InFocusRadius=50})
    else dof=RemFX(dof) end
end)

Toggle("Midnight Moon", false, function(v) Lighting.ClockTime = v and 0 or O.Clock end)
Toggle("Fullbright (No Shadows)", false, function(v)
    if v then Lighting.Brightness=3; Lighting.ClockTime=12; Lighting.FogEnd=100000; Lighting.GlobalShadows=false
    else Lighting.Brightness=O.Bright; Lighting.ClockTime=O.Clock; Lighting.FogEnd=O.FogE; Lighting.GlobalShadows=O.Shadow end
end)

Section("Character FX")

Toggle("Purple Starlight Aura", false, function(v)
    if v then local ch=LP.Character; if ch and ch:FindFirstChild("HumanoidRootPart") then
        local e=Instance.new("ParticleEmitter"); e.Name="PurpleAura"; e.Texture="rbxassetid://243098098"
        e.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(170,90,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(70,190,255))})
        e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.3),NumberSequenceKeypoint.new(1,0)})
        e.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})
        e.Lifetime=NumberRange.new(0.7,1.2); e.Rate=20; e.Speed=NumberRange.new(1.5,3)
        e.SpreadAngle=Vector2.new(360,360); e.Parent=ch.HumanoidRootPart
    end else local ch=LP.Character; if ch then
        for _,d in ipairs(ch:GetDescendants()) do if d.Name=="PurpleAura" then d:Destroy() end end
    end end
end)

Toggle("Skull Flame Aura", false, function(v)
    if v then local ch=LP.Character; if ch and ch:FindFirstChild("HumanoidRootPart") then
        local e=Instance.new("ParticleEmitter"); e.Name="SkullAura"; e.Texture="rbxassetid://6031075938"
        e.Color=ColorSequence.new(Color3.fromRGB(255,70,70))
        e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.45),NumberSequenceKeypoint.new(1,0)})
        e.Lifetime=NumberRange.new(0.5,1); e.Rate=16; e.Speed=NumberRange.new(2,4)
        e.SpreadAngle=Vector2.new(360,360); e.Parent=ch.HumanoidRootPart
    end else local ch=LP.Character; if ch then
        for _,d in ipairs(ch:GetDescendants()) do if d.Name=="SkullAura" then d:Destroy() end end
    end end
end)

Toggle("Character Trail", false, function(v)
    trailOn = v
    if v then MakeTrail(LP.Character) else KillTrail() end
end)

Toggle("Body Glow Light", false, function(v)
    glowOn = v
    if v then MakeGlow(LP.Character) else if glowLight then glowLight:Destroy() glowLight=nil end end
end)

Toggle("RGB Body Glow", false, function(v)
    if v then
        MakeGlow(LP.Character)
        glowConn = Run.RenderStepped:Connect(function()
            if glowLight and glowLight.Parent then
                glowLight.Color = Color3.fromHSV((os.clock()*0.5)%1, 0.9, 1)
            end
        end)
        C(glowConn)
    else
        if glowConn then glowConn:Disconnect() glowConn=nil end
        if glowLight then glowLight:Destroy() glowLight=nil end
    end
end)

-- Respawn hooks
LP.CharacterAdded:Connect(function(char)
    task.wait(1)
    if trailOn then MakeTrail(char) end
    if glowOn then MakeGlow(char) end
    if dmgFlashOn then HookDamageFlash(char) end
end)
-- ══════════════════════════════════════════
--  HEAD DOT MARKERS (кружок над головой)
-- ══════════════════════════════════════════
local dotsOn = false
local dotFolder = Instance.new("Folder")
dotFolder.Name = "HeadDots"
dotFolder.Parent = G

local function AddDot(char, plr)
    if plr == LP then return end
    if not char then return end
    local head = char:WaitForChild("Head", 5)
    if not head then return end

    -- Удаляем старый если есть
    local old = head:FindFirstChild("DotGui")
    if old then old:Destroy() end

    local bb = Instance.new("BillboardGui")
    bb.Name = "DotGui"
    bb.Adornee = head
    bb.Size = UDim2.fromOffset(12, 12)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = false  -- НЕ видно сквозь стены
    bb.LightInfluence = 0
    bb.Parent = head

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(1, 0, 1, 0)
    circle.BackgroundColor3 = Color3.fromRGB(140, 85, 255)
    circle.BorderSizePixel = 0
    circle.Parent = bb

    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.4
    stroke.Parent = circle
end

local function RemoveDot(char)
    if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        local d = head:FindFirstChild("DotGui")
        if d then d:Destroy() end
    end
end

local function RemoveAllDots()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            RemoveDot(plr.Character)
        end
    end
end

local function SetupDotsForPlayer(plr)
    if plr == LP then return end
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if dotsOn then AddDot(char, plr) end
    end)
    if plr.Character and dotsOn then
        AddDot(plr.Character, plr)
    end
end

for _, plr in ipairs(Players:GetPlayers()) do SetupDotsForPlayer(plr) end
Players.PlayerAdded:Connect(SetupDotsForPlayer)
-- ══════════════════════════════════════════
--  UNLOAD
-- ══════════════════════════════════════════
Section("")

local ub = Instance.new("TextButton"); ub.Size = UDim2.new(1,-4,0,36)
ub.BackgroundColor3 = T.red; ub.BorderSizePixel = 0; ub.Text = "  UNLOAD SCRIPT"
ub.Font = Enum.Font.GothamBold; ub.TextSize = 12; ub.TextColor3 = Color3.new(1,1,1)
ub.LayoutOrder = NO(); ub.Parent = SL
Instance.new("UICorner", ub).CornerRadius = UDim.new(0,8)

ub.MouseButton1Click:Connect(function()
    for _,c in ipairs(_C) do pcall(function() c:Disconnect() end) end
    for _,e in ipairs(_FX) do pcall(function() e:Destroy() end) end
    KillTrail()
    pcall(function() if glowLight then glowLight:Destroy() end end)
    pcall(function() if glowConn then glowConn:Disconnect() end end)

    Lighting.FogColor=O.FogC; Lighting.FogStart=O.FogS; Lighting.FogEnd=O.FogE
    Lighting.ClockTime=O.Clock; Lighting.Brightness=O.Bright; Lighting.GlobalShadows=O.Shadow

    G:Destroy()
    print("[Kontra v4] Unloaded.")
end)

print("[Kontra v4] Loaded — "..ord.." items.")
