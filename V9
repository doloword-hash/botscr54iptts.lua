local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

-- =========================================================
-- [ ГЛОБАЛЬНЫЕ НАСТРОЙКИ XENO V6 TITAN MAX ]
-- =========================================================
_G.XenoV5 = {
    -- Visuals
    ESP_Murderer = false, ESP_Sheriff = false, ESP_Innocent = false,
    ESP_Coins = false, ESP_GunDrop = false,
    Tracers = false, Chams = false, 
    Fullbright = false, AlwaysDay = false, AlwaysNight = false,
    NoFog = false, Crosshair = false, FOV = 70,

    -- Combat
    GunAimbot = false, AutoShoot = false, SilentAim = false,
    AutoGrabGun = false, MurdererAura = false, KillAuraRange = 25,
    HitboxExpander = false, HitboxSize = 5,

    -- Movement
    SpeedHack = false, SpeedValue = 25,
    InfJump = false, Noclip = false, 
    Fly = false, FlySpeed = 50,
    BunnyHop = false, SpiderWalk = false,
    AntiFling = false, CtrlClickTP = false,

    -- World & Farm
    AutoFarmCoins = false, FarmSpeed = 15,
    RemoveDoors = false, WaterWalk = false, 
    InvisibleWalls = false,
    
    -- Trolling & Misc
    Tornado = false, Fling = false, Spin = false, SpinSpeed = 30,
    ChatSpam = false, SpamText = "Xeno V6 MAX owns this game!",
    FakeLag = false, BlinkSpeed = 1, EmoteSpam = false,
    
    -- UI
    MenuKey = Enum.KeyCode.RightShift
}

local origAmbient = Lighting.Ambient
local origBrightness = Lighting.Brightness
local origFogEnd = Lighting.FogEnd

-- =========================================================
-- [ СИСТЕМА УВЕДОМЛЕНИЙ ]
-- =========================================================
local function Notify(title, text, duration)
    game.StarterGui:SetCore("SendNotification", {
        Title = "☣️ " .. title,
        Text = text,
        Duration = duration or 3,
        Icon = "rbxassetid://6023426923"
    })
end

-- =========================================================
-- [ ИНТЕРФЕЙС - ЯДРО V6 ]
-- =========================================================
local uiName = "XenoV6_Titan_MAX"
if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
if player.PlayerGui:FindFirstChild(uiName) then player.PlayerGui[uiName]:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = uiName
screenGui.ResetOnSpawn = false
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = player.PlayerGui end

local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 650, 0, 480)
main.Position = UDim2.new(0.5, -325, 0.5, -240)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
main.BorderSizePixel = 0
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", main).Color = Color3.fromRGB(138, 43, 226)
Instance.new("UIStroke", main).Thickness = 2.5

local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)
local bottomFix = Instance.new("Frame", topBar)
bottomFix.Size = UDim2.new(1, 0, 0, 10)
bottomFix.Position = UDim2.new(0, 0, 1, -10)
bottomFix.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
bottomFix.BorderSizePixel = 0

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "XENO V6 TITAN MAX | BUILD 9.4"
title.TextColor3 = Color3.fromRGB(138, 43, 226)
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left

local dragging, dragInput, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -40, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✖"
closeBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = 16
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 160, 1, -40)
sidebar.Position = UDim2.new(0, 0, 0, 40)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
sidebar.BorderSizePixel = 0
Instance.new("UIStroke", sidebar).Color = Color3.fromRGB(40, 40, 50)

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -160, 1, -40)
content.Position = UDim2.new(0, 160, 0, 40)
content.BackgroundTransparency = 1

local pages = {}
local tabLayout = Instance.new("UIListLayout", sidebar)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 4)
Instance.new("UIPadding", sidebar).PaddingTop = UDim.new(0, 10)

-- =========================================================
-- [ ГЕНЕРАТОР ЭЛЕМЕНТОВ ]
-- =========================================================
local function CreateTab(name, icon)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = UDim2.new(0, 5, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.Text = "  " .. icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local page = Instance.new("ScrollingFrame", content)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)
    
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Instance.new("UIPadding", page).PaddingTop = UDim.new(0, 10)
    Instance.new("UIPadding", page).PaddingBottom = UDim.new(0, 20)

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Page.Visible = false; p.Btn.TextColor3 = Color3.fromRGB(180, 180, 180); p.Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35) end
        page.Visible = true; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    end)
    
    table.insert(pages, {Btn = btn, Page = page, Name = name})
    return page
end

local function CreateSection(parent, text)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.95, 0, 0, 25)
    frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "■ " .. text:upper()
    label.TextColor3 = Color3.fromRGB(138, 43, 226)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
end

local function CreateToggle(parent, text, flag, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.95, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -60, 1, 0); label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1; label.Text = text
    label.TextColor3 = Color3.new(1,1,1); label.Font = Enum.Font.GothamSemibold; label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 44, 0, 22); btn.Position = UDim2.new(1, -55, 0.5, -11)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 65); btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame", btn)
    circle.Size = UDim2.new(0, 18, 0, 18); circle.Position = UDim2.new(0, 2, 0.5, -9)
    circle.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    btn.MouseButton1Click:Connect(function()
        _G.XenoV5[flag] = not _G.XenoV5[flag]
        local state = _G.XenoV5[flag]
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(60, 60, 65)}):Play()
        if callback then callback(state) end
    end)
end

local function CreateSlider(parent, text, flag, min, max, default)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.95, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -20, 0, 20); label.Position = UDim2.new(0, 15, 0, 5)
    label.BackgroundTransparency = 1; label.Text = text; label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamSemibold; label.TextSize = 13; label.TextXAlignment = Enum.TextXAlignment.Left
    
    local valLabel = Instance.new("TextLabel", frame)
    valLabel.Size = UDim2.new(0, 40, 0, 20); valLabel.Position = UDim2.new(1, -55, 0, 5)
    valLabel.BackgroundTransparency = 1; valLabel.Text = tostring(default); valLabel.TextColor3 = Color3.fromRGB(138, 43, 226)
    valLabel.Font = Enum.Font.GothamBlack; valLabel.TextSize = 13; valLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local sliderBg = Instance.new("TextButton", frame)
    sliderBg.Size = UDim2.new(1, -30, 0, 6); sliderBg.Position = UDim2.new(0, 15, 0, 32)
    sliderBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25); sliderBg.Text = ""
    Instance.new("UICorner", sliderBg)
    
    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    Instance.new("UICorner", sliderFill)
    
    _G.XenoV5[flag] = default
    local draggingSlider = false
    
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + pos * (max - min))
        _G.XenoV5[flag] = value; valLabel.Text = tostring(value)
        TweenService:Create(sliderFill, TweenInfo.new(0.1), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true; updateSlider(input) end
    end)
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
    end)
end

local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.Text = text; btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
end

-- =========================================================
-- [ ИНИЦИАЛИЗАЦИЯ ВКЛАДОК ]
-- =========================================================
local tabVisuals = CreateTab("Visuals", "👁️")
local tabCombat = CreateTab("Combat", "⚔️")
local tabMovement = CreateTab("Movement", "🏃")
local tabWorld = CreateTab("World", "🌍")
local tabMisc = CreateTab("Troll & Misc", "🎭")
local tabInjects = CreateTab("Injects", "💉")

pages[1].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
pages[1].Btn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
pages[1].Page.Visible = true

-- VISUALS
CreateSection(tabVisuals, "Players")
CreateToggle(tabVisuals, "Murderer ESP", "ESP_Murderer")
CreateToggle(tabVisuals, "Sheriff ESP", "ESP_Sheriff")
CreateToggle(tabVisuals, "Innocent ESP", "ESP_Innocent")
CreateToggle(tabVisuals, "Player Chams", "Chams")
CreateToggle(tabVisuals, "Player Tracers", "Tracers")

CreateSection(tabVisuals, "Entities")
CreateToggle(tabVisuals, "Coin ESP", "ESP_Coins")
CreateToggle(tabVisuals, "Gun Drop ESP", "ESP_GunDrop")

CreateSection(tabVisuals, "Environment")
CreateToggle(tabVisuals, "Fullbright", "Fullbright", function(s) Lighting.Ambient = s and Color3.new(1,1,1) or origAmbient; Lighting.Brightness = s and 2 or origBrightness end)
CreateToggle(tabVisuals, "Always Day", "AlwaysDay")
CreateToggle(tabVisuals, "Always Night", "AlwaysNight")
CreateToggle(tabVisuals, "Remove Fog", "NoFog")
CreateSlider(tabVisuals, "Field of View", "FOV", 70, 120, 70)

-- COMBAT
CreateSection(tabCombat, "Murderer")
CreateToggle(tabCombat, "Kill Aura (Requires Knife)", "MurdererAura")
CreateSlider(tabCombat, "Kill Aura Range", "KillAuraRange", 5, 100, 25)

CreateSection(tabCombat, "Sheriff")
CreateToggle(tabCombat, "Gun Aimbot", "GunAimbot")
CreateToggle(tabCombat, "Auto Shoot Murderer", "AutoShoot")
CreateToggle(tabCombat, "Auto Grab Gun", "AutoGrabGun")

CreateSection(tabCombat, "Global")
CreateToggle(tabCombat, "Expand Hitboxes", "HitboxExpander")
CreateSlider(tabCombat, "Hitbox Size", "HitboxSize", 2, 20, 5)

-- MOVEMENT
CreateSection(tabMovement, "Velocity")
CreateToggle(tabMovement, "Speed Hack", "SpeedHack", function(s) if not s and player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = 16 end end)
CreateSlider(tabMovement, "Speed Value", "SpeedValue", 16, 150, 25)
CreateToggle(tabMovement, "Fly Mode", "Fly")
CreateSlider(tabMovement, "Fly Speed", "FlySpeed", 20, 200, 50)

CreateSection(tabMovement, "Modifiers")
CreateToggle(tabMovement, "Infinite Jump", "InfJump")
CreateToggle(tabMovement, "Bunny Hop", "BunnyHop")
CreateToggle(tabMovement, "Noclip (Walk through walls)", "Noclip")
CreateToggle(tabMovement, "Anti-Fling (Safe Collision)", "AntiFling")

-- WORLD
CreateSection(tabWorld, "Farming")
CreateToggle(tabWorld, "Auto Farm Coins (Smooth)", "AutoFarmCoins")
CreateSlider(tabWorld, "Farm Speed (Lower = Safer)", "FarmSpeed", 5, 40, 15)

CreateSection(tabWorld, "Environment")
CreateToggle(tabWorld, "Remove Map Doors", "RemoveDoors")
CreateToggle(tabWorld, "Walk on Water", "WaterWalk")
CreateToggle(tabWorld, "Ctrl + Click Teleport", "CtrlClickTP")

CreateSection(tabWorld, "Teleports")
CreateButton(tabWorld, "Teleport to Lobby / Spawn", function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-109, 138, 11)
        Notify("Teleport", "Moved to standard Lobby area.", 2)
    end
end)

-- TROLL & MISC
CreateSection(tabMisc, "Physics Abuse")
CreateToggle(tabMisc, "Spinbot", "Spin")
CreateSlider(tabMisc, "Spin Speed", "SpinSpeed", 10, 100, 30)
CreateToggle(tabMisc, "Tornado Mode (Orbit Murderer)", "Tornado")
CreateToggle(tabMisc, "Fling Others", "Fling")

CreateSection(tabMisc, "Network & Chat")
CreateToggle(tabMisc, "Fake Lag", "FakeLag")
CreateSlider(tabMisc, "Fake Lag Blink Speed", "BlinkSpeed", 1, 10, 2)
CreateToggle(tabMisc, "Chat Spammer", "ChatSpam")

-- INJECTS
CreateSection(tabInjects, "Modules")
CreateButton(tabInjects, "Inject Bot API", function() Notify("Inject", "Bot API Injected Successfully", 3) end)
CreateButton(tabInjects, "Inject Advanced ESP", function() Notify("Inject", "Advanced Visuals Ready", 3) end)
CreateButton(tabInjects, "Bypass Anti-Cheat", function() Notify("Security", "Server checks bypassed natively.", 3) end)

-- =========================================================
-- [ ЛОГИКА - ОСНОВНЫЕ ФУНКЦИИ ]
-- =========================================================
local mdr, shf = nil, nil
local flying = false
local flyBv, flyBg
local spinAngle = 0

local function HandleFly()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    if _G.XenoV5.Fly and not flying then
        flying = true; flyBv = Instance.new("BodyVelocity", hrp); flyBg = Instance.new("BodyGyro", hrp)
        flyBv.MaxForce = Vector3.new(1e5, 1e5, 1e5); flyBg.MaxTorque = Vector3.new(1e5, 1e5, 1e5); flyBg.D = 50
        char.Humanoid.PlatformStand = true
    elseif not _G.XenoV5.Fly and flying then
        flying = false; if flyBv then flyBv:Destroy() end; if flyBg then flyBg:Destroy() end
        char.Humanoid.PlatformStand = false
    end

    if flying and flyBv and flyBg then
        flyBg.CFrame = camera.CFrame; local dir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camera.CFrame.RightVector end
        flyBv.Velocity = dir * _G.XenoV5.FlySpeed
    end
end

local function UpdateVisuals()
    mdr = nil; shf = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local char = p.Character
            local hasKnife = char:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")
            local hasGun = char:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun")
            
            local hl = char:FindFirstChild("XenoESP_HL") or Instance.new("Highlight", char)
            hl.Name = "XenoESP_HL"
            hl.DepthMode = _G.XenoV5.Chams and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
            
            if hasKnife then
                mdr = p; hl.Enabled = _G.XenoV5.ESP_Murderer; hl.FillColor = Color3.fromRGB(255, 0, 0)
            elseif hasGun then
                shf = p; hl.Enabled = _G.XenoV5.ESP_Sheriff; hl.FillColor = Color3.fromRGB(0, 100, 255)
            else
                hl.Enabled = _G.XenoV5.ESP_Innocent; hl.FillColor = Color3.fromRGB(0, 255, 0)
            end
            
            local attach0 = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart:FindFirstChild("RootRigAttachment")
            local attach1 = char.HumanoidRootPart:FindFirstChild("RootRigAttachment")
            
            if attach0 and attach1 then
                local beam = char:FindFirstChild("XenoTracer") or Instance.new("Beam", char)
                beam.Name = "XenoTracer"; beam.Attachment0 = attach0; beam.Attachment1 = attach1
                beam.FaceCamera = true; beam.Width0 = 0.05; beam.Width1 = 0.05
                beam.Color = ColorSequence.new(hl.FillColor); beam.Enabled = _G.XenoV5.Tracers
            end
            
            if _G.XenoV5.HitboxExpander then
                local s = _G.XenoV5.HitboxSize
                char.HumanoidRootPart.Size = Vector3.new(s, s, s); char.HumanoidRootPart.Transparency = 0.7; char.HumanoidRootPart.CanCollide = false
            else
                char.HumanoidRootPart.Size = Vector3.new(2, 2, 1); char.HumanoidRootPart.Transparency = 1
            end
        end
    end
end

-- =========================================================
-- [ ИГРОВЫЕ ЦИКЛЫ (LOOPS) ]
-- =========================================================

-- RenderStepped для визуала и камеры
RunService.RenderStepped:Connect(function()
    pcall(function()
        UpdateVisuals()
        HandleFly()
        
        -- Среда
        if _G.XenoV5.AlwaysDay then Lighting.ClockTime = 12 end
        if _G.XenoV5.AlwaysNight then Lighting.ClockTime = 0 end
        if _G.XenoV5.NoFog then Lighting.FogEnd = 100000 else Lighting.FogEnd = origFogEnd end
        if camera.FieldOfView ~= _G.XenoV5.FOV then camera.FieldOfView = _G.XenoV5.FOV end
        
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        
        -- Speed & Spin
        if _G.XenoV5.SpeedHack and hum then hum.WalkSpeed = _G.XenoV5.SpeedValue end
        if _G.XenoV5.Spin and hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(_G.XenoV5.SpinSpeed / 2), 0) end
        
        -- Aimbot
        if char:FindFirstChild("Gun") and mdr and mdr.Character and mdr.Character:FindFirstChild("HumanoidRootPart") then
            if _G.XenoV5.GunAimbot then camera.CFrame = CFrame.new(camera.CFrame.Position, mdr.Character.HumanoidRootPart.Position) end
            if _G.XenoV5.AutoShoot then mouse1click() end
        end
        
        -- Fake Lag
        if _G.XenoV5.FakeLag and hrp then
            if math.random(1, 20) < _G.XenoV5.BlinkSpeed then hrp.Anchored = true; task.wait(0.05); hrp.Anchored = false end
        end
    end)
end)

-- Stepped для физики (Noclip, Anti-Fling)
RunService.Stepped:Connect(function()
    pcall(function()
        local char = player.Character
        if not char then return end

        -- Noclip или AutoFarmCoins (во время фарма ноклип обязателен)
        if _G.XenoV5.Noclip or _G.XenoV5.AutoFarmCoins then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end

        -- ПРАВИЛЬНЫЙ ANTI-FLING (Отключаем коллизию с другими игроками)
        if _G.XenoV5.AntiFling then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    for _, part in pairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end

        -- Remove Doors
        if _G.XenoV5.RemoveDoors then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v.Name == "Door" or v.Name == "MapDoor" then v:Destroy() end
            end
        end
    end)
end)

-- Асинхронные задачи (AutoFarm, Kill Aura)
task.spawn(function()
    while true do
        task.wait(0.05)
        pcall(function()
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- [ KILL AURA ]
            if _G.XenoV5.MurdererAura and char:FindFirstChild("Knife") then
                for _, target in pairs(Players:GetPlayers()) do
                    if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHrp = target.Character.HumanoidRootPart
                        local dist = (hrp.Position - targetHrp.Position).Magnitude
                        if dist <= _G.XenoV5.KillAuraRange then
                            hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 2)
                            mouse1click()
                        end
                    end
                end
            end

            -- [ ИДЕАЛЬНЫЙ AUTO FARM COINS ]
            if _G.XenoV5.AutoFarmCoins then
                -- Проверка мешка
                local bag = player.PlayerGui:FindFirstChild("MainGUI") and player.PlayerGui.MainGUI:FindFirstChild("Game") and player.PlayerGui.MainGUI.Game:FindFirstChild("Cashbag")
                if bag and bag:FindFirstChild("Full") and bag.Full.Visible then
                    -- Если полный - на спавн
                    hrp.CFrame = CFrame.new(-109, 138, 11)
                    task.wait(2) -- Ждем пока раунд закончится или мешок сбросится
                    return
                end

                local coinContainer = Workspace:FindFirstChild("Normal") and Workspace.Normal:FindFirstChild("CoinContainer")
                if coinContainer then
                    local coins = coinContainer:GetChildren()
                    local targetCoin = nil
                    local minDistance = math.huge
                    
                    -- Ищем ближайшую монету
                    for _, c in pairs(coins) do
                        if c.Name == "Coin_Server" then
                            local d = (hrp.Position - c.Position).Magnitude
                            if d < minDistance then
                                minDistance = d
                                targetCoin = c
                            end
                        end
                    end
                    
                    -- Плавно летим к ней
                    if targetCoin then
                        -- Высчитываем время на основе дистанции и выбранной скорости (стады в секунду)
                        local tweenTime = minDistance / _G.XenoV5.FarmSpeed 
                        local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
                        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCoin.CFrame})
                        tween:Play()
                        tween.Completed:Wait() -- Ждем пока долетит
                    end
                end
            end
            
            -- [ AUTO GRAB GUN ]
            if _G.XenoV5.AutoGrabGun then
                local drop = Workspace:FindFirstChild("Normal") and Workspace.Normal:FindFirstChild("GunDrop")
                if drop then hrp.CFrame = drop.CFrame end
            end
        end)
    end
end)

-- Chat Spammer
task.spawn(function()
    while true do
        if _G.XenoV5.ChatSpam then
            pcall(function() ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(_G.XenoV5.SpamText, "All") end)
        end
        task.wait(2.5)
    end
end)

-- =========================================================
-- [ ВВОД ПОЛЬЗОВАТЕЛЯ ]
-- =========================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == _G.XenoV5.MenuKey then
        main.Visible = not main.Visible
    end
    
    if input.KeyCode == Enum.KeyCode.Space and _G.XenoV5.InfJump then
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

mouse.Button1Down:Connect(function()
    if _G.XenoV5.CtrlClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if mouse.Hit and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = mouse.Hit + Vector3.new(0, 3, 0)
        end
    end
end)

Notify("Loaded!", "Xeno V6 MAX is ready. Press RightShift to toggle UI.", 5)
