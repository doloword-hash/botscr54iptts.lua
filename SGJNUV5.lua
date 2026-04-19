local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- =========================================================
-- [ГЛОБАЛЬНЫЕ НАСТРОЙКИ XENO V5 TITAN PRO]
-- =========================================================
_G.XenoV5 = {
    -- Visuals
    ESP_Murderer = false,
    ESP_Sheriff = false,
    ESP_Innocent = false,
    ESP_Gun = false, -- [НОВОЕ] ESP Пистолета
    Tracers = false,
    Chams = false,
    Fullbright = false,
    AlwaysDay = false,
    AlwaysNight = false,
    FOV = 70,
    
	-- Флинг (Ultimate)
    Fling = false,           -- Обычный (на всех)
    FlingMurderer = false,   -- Только на убийцу
    FlingSheriff = false,    -- Только на шерифа

    -- Combat
    GunAimbot = false,
    AutoShoot = false,
    AutoGrabGun = false,
    MurdererAura = false,
    KillAuraRange = 20,
    HitboxExpander = false,
    
    -- Movement
    SpeedHack = false,
    SpeedValue = 25,
    InfJump = false,
    Noclip = false,
    Fly = false,
    FlySpeed = 50,
    Spin = false,
    AntiFling = false,
    CtrlClickTP = false,
    
    -- World & Farming
    AutoFarmCoins = false,
    RemoveDoors = false,
    WaterWalk = false,
    
    -- Power & Troll
	SheriffAutoKill = false, -- Авто ТП и убийство
    Tornado = false,
    Fling = false,
    ChatSpam = false,
    SpamText = "Xeno V5 Titan dominates this server!",
    FakeLag = false
}

local origAmbient = Lighting.Ambient
local origBrightness = Lighting.Brightness
local origTime = Lighting.ClockTime

-- =========================================================
-- [СИСТЕМА УВЕДОМЛЕНИЙ]
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
-- [ИНТЕРФЕЙС - ФУНДАМЕНТ]
-- =========================================================
local uiName = "XenoV5_Titan_Pro"
if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
if player.PlayerGui:FindFirstChild(uiName) then player.PlayerGui[uiName]:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = uiName
screenGui.ResetOnSpawn = false
local success = pcall(function() screenGui.Parent = CoreGui end)
if not success then screenGui.Parent = player.PlayerGui end

local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 580, 0, 420)
main.Position = UDim2.new(0.5, -290, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
main.BorderSizePixel = 0
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(0, 255, 128)
stroke.Thickness = 2

-- ЗАГОЛОВОК И DRAG
local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "XENO V5.2 NAVALNIY | MM2 "
title.TextColor3 = Color3.fromRGB(0, 255, 128)
title.Font = Enum.Font.GothamBlack
title.TextSize = 16
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
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = 18
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- КОНТЕЙНЕРЫ
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 140, 1, -35)
sidebar.Position = UDim2.new(0, 0, 0, 35)
sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
sidebar.BorderSizePixel = 0

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -140, 1, -35)
content.Position = UDim2.new(0, 140, 0, 35)
content.BackgroundTransparency = 1

local pages = {}
local tabLayout = Instance.new("UIListLayout", sidebar)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 2)

-- =========================================================
-- [ГЕНЕРАТОР ЭЛЕМЕНТОВ UI]
-- =========================================================
local function CreateTab(name, icon)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = " " .. icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0

    local page = Instance.new("ScrollingFrame", content)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 128)
    
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Instance.new("UIPadding", page).PaddingTop = UDim.new(0, 10)
    Instance.new("UIPadding", page).PaddingBottom = UDim.new(0, 10)

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Page.Visible = false; p.Btn.TextColor3 = Color3.fromRGB(200,200,200) end
        page.Visible = true; btn.TextColor3 = Color3.fromRGB(0, 255, 128)
    end)
    
    table.insert(pages, {Btn = btn, Page = page, Name = name})
    return page
end

local function CreateSection(parent, text)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.95, 0, 0, 20)
    frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "[ " .. text:upper() .. " ]"
    label.TextColor3 = Color3.fromRGB(0, 200, 100)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
end

local function CreateToggle(parent, text, flag, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.95, 0, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -50, 1, 0); label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1; label.Text = text
    label.TextColor3 = Color3.new(1,1,1); label.Font = Enum.Font.Gotham; label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 40, 0, 20); btn.Position = UDim2.new(1, -50, 0.5, -10)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame", btn)
    circle.Size = UDim2.new(0, 16, 0, 16); circle.Position = UDim2.new(0, 2, 0.5, -8)
    circle.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    btn.MouseButton1Click:Connect(function()
        _G.XenoV5[flag] = not _G.XenoV5[flag]
        local state = _G.XenoV5[flag]
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0, 255, 128) or Color3.fromRGB(50, 50, 50)}):Play()
        if callback then callback(state) end
    end)
end

local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = text; btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
end

local function CreateSlider(parent, text, flag, min, max, default)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.95, 0, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.5, 0, 1, 0); label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1; label.Text = text; label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.Gotham; label.TextSize = 13; label.TextXAlignment = Enum.TextXAlignment.Left
    
    local valLabel = Instance.new("TextLabel", frame)
    valLabel.Size = UDim2.new(0.2, 0, 1, 0); valLabel.Position = UDim2.new(0.5, 0, 0, 0)
    valLabel.BackgroundTransparency = 1; valLabel.Text = tostring(default); valLabel.TextColor3 = Color3.fromRGB(0,255,128)
    valLabel.Font = Enum.Font.GothamBold; valLabel.TextSize = 13
    
    local minusBtn = Instance.new("TextButton", frame)
    minusBtn.Size = UDim2.new(0, 25, 0, 25); minusBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
    minusBtn.BackgroundColor3 = Color3.fromRGB(40,40,40); minusBtn.Text = "-"; minusBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", minusBtn)
    
    local plusBtn = Instance.new("TextButton", frame)
    plusBtn.Size = UDim2.new(0, 25, 0, 25); plusBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
    plusBtn.BackgroundColor3 = Color3.fromRGB(40,40,40); plusBtn.Text = "+"; plusBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", plusBtn)
    
    _G.XenoV5[flag] = default
    local function update(change)
        local newVal = math.clamp(_G.XenoV5[flag] + change, min, max)
        _G.XenoV5[flag] = newVal; valLabel.Text = tostring(newVal)
    end
    minusBtn.MouseButton1Click:Connect(function() update(-1) end)
    plusBtn.MouseButton1Click:Connect(function() update(1) end)
end

-- =========================================================
-- [ЛОГИКА GUN ESP (НОВОЕ)]
-- =========================================================
local function CreateGunESP(gun)
    if not _G.XenoV5.ESP_Gun then return end
    if gun:FindFirstChild("GunESP_Highlight") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "GunESP_Highlight"
    highlight.FillColor = Color3.fromRGB(170, 120, 255)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0.2
    highlight.Parent = gun

    local billboard = Instance.new("BillboardGui", gun)
    billboard.Name = "GunESP_Text"
    billboard.Size = UDim2.new(0, 120, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true

    local text = Instance.new("TextLabel", billboard)
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "Gun Dropped"
    text.TextColor3 = Color3.fromRGB(210, 190, 255)
    text.Font = Enum.Font.GothamBold
    text.TextScaled = true
    text.TextStrokeTransparency = 0
end

-- Авто-отлов выпадающего пистолета
workspace.DescendantAdded:Connect(function(obj)
    if obj.Name == "GunDrop" and obj:IsA("BasePart") then
        task.defer(function()
            if _G.XenoV5.ESP_Gun then CreateGunESP(obj) end
        end)
    end
end)

-- =========================================================
-- [СОЗДАНИЕ ВКЛАДОК И МЕНЮ]
-- =========================================================
local tabVisuals = CreateTab("Visuals", "👁️")
local tabCombat = CreateTab("Combat", "⚔️")
local tabMovement = CreateTab("Movement", "🏃")
local tabWorld = CreateTab("World", "🌍")
local tabMisc = CreateTab("Misc", "⚡")
local tabInjects = CreateTab("Injects", "💉")

pages[1].Btn.TextColor3 = Color3.fromRGB(0, 255, 128)
pages[1].Page.Visible = true

-- VISUALS
CreateSection(tabVisuals, "Players")
CreateToggle(tabVisuals, "Murderer ESP", "ESP_Murderer")
CreateToggle(tabVisuals, "Sheriff ESP", "ESP_Sheriff")
CreateToggle(tabVisuals, "Innocent ESP", "ESP_Innocent")
CreateToggle(tabVisuals, "Player Chams", "Chams")
CreateToggle(tabVisuals, "Player Tracers", "Tracers")

-- [НОВОЕ] Секция для предметов (Gun ESP)
CreateSection(tabVisuals, "Items")
CreateToggle(tabVisuals, "Gun ESP (Dropped)", "ESP_Gun", function(state)
    if state then
        -- Ищем пистолет, если он уже на земле
        local drop = workspace:FindFirstChild("GunDrop", true)
        if drop and drop:IsA("BasePart") then
            CreateGunESP(drop)
        end
    else
        -- Очищаем ESP при выключении
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "GunESP_Highlight" or v.Name == "GunESP_Text" then
                v:Destroy()
            end
        end
    end
end)

CreateSection(tabVisuals, "Environment")
CreateToggle(tabVisuals, "Fullbright", "Fullbright", function(state)
    Lighting.Ambient = state and Color3.new(1, 1, 1) or origAmbient
    Lighting.Brightness = state and 2 or origBrightness
end)
CreateToggle(tabVisuals, "AlwaysDay", "AlwaysDay")
CreateToggle(tabVisuals, "AlwaysNight", "AlwaysNight")
CreateSlider(tabVisuals, "Field of View", "FOV", 70, 120, 70)

-- =========================================================
-- [ SECTION: COMBAT (UPDATED) ]
-- =========================================================

-- --- РАЗДЕЛ MURDERER ---
CreateSection(tabCombat, "Murderer")
CreateToggle(tabCombat, "Kill Aura (Knife Required)", "MurdererAura")
CreateSlider(tabCombat, "Kill Aura Range", "KillAuraRange", 1, 100, 20)
CreateToggle(tabCombat, "Fling Sheriff", "FlingMurderer") -- Новое

-- --- РАЗДЕЛ SHERIFF ---
CreateSection(tabCombat, "Sheriff")
CreateToggle(tabCombat, "Gun Aimbot", "GunAimbot")
CreateToggle(tabCombat, "Auto Shoot Murderer", "AutoShoot")
CreateToggle(tabCombat, "TP To Murder", "SheriffAutoKill") -- Новое
CreateToggle(tabCombat, "Fling Murder", "FlingSheriff") -- Новое

-- --- РАЗДЕЛ GENERAL & FLING ---
CreateSection(tabCombat, "General & Fling")
CreateToggle(tabCombat, "Ultimate Fling (ALL)", "Fling") -- Тот самый мощный флинг
CreateToggle(tabCombat, "Auto Grab Gun (Safe)", "AutoGrabGun")
CreateToggle(tabCombat, "Expand Hitboxes", "HitboxExpander")

-- [УЛУЧШЕННАЯ] Кнопка моментального безопасного ТП к пистолету
CreateButton(tabCombat, "Safe TP to Dropped Gun", function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local gun = workspace:FindFirstChild("GunDrop", true)
    if not gun then 
        Notify("Error", "Gun is not dropped yet!", 2)
        return 
    end

    -- Проверка на убийцу (не прыгаем, если он в радиусе 30)
    local mdr = GetMurderer()
    if mdr and mdr:FindFirstChild("HumanoidRootPart") then
        local dist = (mdr.HumanoidRootPart.Position - gun.Position).Magnitude
        if dist < 30 then
            Notify("Danger", "Murderer is too close to the gun!", 3)
            return
        end
    end

    local originalCFrame = hrp.CFrame
    local target = gun:IsA("BasePart") and gun or gun:FindFirstChildWhichIsA("BasePart")
    
    if target then
        Notify("Action", "Grabbing gun...", 1)
        hrp.CFrame = target.CFrame + Vector3.new(0, 2, 0)
        task.wait(0.5) -- Чуть увеличил время, чтобы сервер успел засчитать подбор
        hrp.CFrame = originalCFrame
    end
end)

-- MOVEMENT
CreateSection(tabMovement, "Speed & Flight")
CreateToggle(tabMovement, "Speed Hack", "SpeedHack", function(state)
    if not state and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 16
    end
end)
CreateSlider(tabMovement, "Speed Value", "SpeedValue", 16, 100, 25)
CreateToggle(tabMovement, "Fly Mode", "Fly")

CreateSection(tabMovement, "Modifiers")
CreateToggle(tabMovement, "Infinite Jump", "InfJump")
CreateToggle(tabMovement, "Noclip (Walk through walls)", "Noclip")
CreateToggle(tabMovement, "Ctrl + Click TP", "CtrlClickTP")
CreateToggle(tabMovement, "Anti-Fling", "AntiFling")

-- WORLD
CreateSection(tabWorld, "Farming")
CreateToggle(tabWorld, "Auto Farm Coins", "AutoFarmCoins")

CreateSection(tabWorld, "Map Exploits")
CreateToggle(tabWorld, "Remove Doors", "RemoveDoors")
CreateToggle(tabWorld, "Walk on Water", "WaterWalk")
CreateButton(tabWorld, "Teleport to Lobby", function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-109, 138, 11)
        Notify("Teleport", "Moved to Lobby", 2)
    end
end)
CreateButton(tabWorld, "Teleport to Map Center", function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
        Notify("Teleport", "Moved to Map", 2)
    end
end)

-- MISC
CreateSection(tabMisc, "Trolling")
CreateToggle(tabMisc, "Spinbot", "Spin")
CreateToggle(tabMisc, "Tornado Mode", "Tornado")
CreateToggle(tabMisc, "Loop Fling All", "Fling")
CreateToggle(tabMisc, "Fake Lag (Blink)", "FakeLag")
CreateToggle(tabMisc, "Chat Spammer", "ChatSpam")

-- INJECTS
CreateSection(tabInjects, "Main Injects")
CreateButton(tabInjects, "Inject Bot", function()  
    Notify("Injects", "Bot Injected Successfully!", 3) 
    
    -- === ВСТАВЛЯЙ СВОЙ СКРИПТ БОТА НИЖЕ ЭТОЙ СТРОКИ ===
    loadstring(game:HttpGet('https://raw.githubusercontent.com/doloword-hash/botscr54iptts.lua/refs/heads/main/Inject1.lua'))()
    -- === КОНЕЦ ТВОЕГО СКРИПТА ===
end)
CreateButton(tabInjects, "Tab Teleport", function()  
    Notify("Injects", "Tab Teleport Loaded!", 3) 
    
    -- === ВСТАВЛЯЙ СВОЙ СКРИПТ ТЕЛЕПОРТА НИЖЕ ЭТОЙ СТРОКИ ===
    loadstring(game:HttpGet('https://raw.githubusercontent.com/doloword-hash/botscr54iptts.lua/refs/heads/main/Inject2.lua'))()
    -- === КОНЕЦ ТВОЕГО СКРИПТА ===
end)

-- =========================================================
-- [ЛОГИКА ХАКА И ФУНКЦИИ]
-- =========================================================

local mdr, shf = nil, nil
local flying = false
local flyBv, flyBg

-- FLY FUNC
local function HandleFly()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    if _G.XenoV5.Fly and not flying then
        flying = true; flyBv = Instance.new("BodyVelocity", hrp); flyBg = Instance.new("BodyGyro", hrp)
        flyBv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); flyBg.D = 50
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

-- ESP & CHAMS
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
            
            local root = char.HumanoidRootPart
            local attach0 = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart:FindFirstChild("RootRigAttachment")
            local attach1 = root:FindFirstChild("RootRigAttachment")
            
            if attach0 and attach1 then
                local beam = char:FindFirstChild("XenoTracer") or Instance.new("Beam", char)
                beam.Name = "XenoTracer"; beam.Attachment0 = attach0; beam.Attachment1 = attach1
                beam.FaceCamera = true; beam.Width0 = 0.1; beam.Width1 = 0.1
                beam.Color = ColorSequence.new(hl.FillColor); beam.Enabled = _G.XenoV5.Tracers
            end
            
            if _G.XenoV5.HitboxExpander then
                root.Size = Vector3.new(5, 5, 5); root.Transparency = 0.7; root.CanCollide = false
            else
                root.Size = Vector3.new(2, 2, 1); root.Transparency = 1
            end
        end
    end
end

-- RENDERSTEPPED LOOP (Aimbots, Visuals, Spin)
local spinAngle = 0
local function GetMurderer()
    for _, p in pairs(game:GetService("Players"):GetPlayers()) do
        if p.Character and (p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")) then
            return p.Character
        end
    end
    return nil
end

local function GetSheriff()
    for _, p in pairs(game:GetService("Players"):GetPlayers()) do
        if p.Character and (p.Character:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun")) then
            return p.Character
        end
    end
    return nil
end
-- [ ОСНОВНОЙ ЦИКЛ ]
local function SkidFling(TargetPlayer)
    local char = player.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    local tchar = TargetPlayer.Character
    local thrp = tchar and tchar:FindFirstChild("HumanoidRootPart")
    local thum = tchar and tchar:FindFirstChildOfClass("Humanoid")

    if hrp and thrp and thum then
        local oldPos = hrp.CFrame
        local startTime = tick()
        
        -- [ СИЛОВЫЕ УСТАНОВКИ ИЗ ОРИГИНАЛА ]
        local fly = Instance.new("BodyVelocity")
        fly.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        fly.Velocity = Vector3.new(0, 0, 0)
        fly.Parent = hrp

        hum.PlatformStand = true -- Отключаем анимации, чтобы физика работала на 100%

        -- Цикл атаки
        repeat
            task.wait()
            -- Создаем хаотичное движение вокруг цели
            local rot = CFrame.Angles(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))
            local pos = thrp.CFrame * CFrame.new(0, 1.5, 0) * rot
            
            hrp.CFrame = pos
            
            -- Накачка импульса (Те самые 9e7)
            hrp.Velocity = Vector3.new(9e7, 9e7, 9e7)
            hrp.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
            
            -- Проверка: если цель улетела очень далеко или умерла
        until not TargetPlayer or not tchar or not thrp or (thrp.Position - hrp.Position).Magnitude > 500 or tick() - startTime > 2 or not _G.XenoV5.FlingActive

        -- [ ОЧИСТКА ]
        fly:Destroy()
        hum.PlatformStand = false
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.RotVelocity = Vector3.new(0, 0, 0)
        
        -- Плавный возврат
        for i = 1, 5 do
            hrp.CFrame = oldPos
            task.wait()
        end
    end
end
RunService.RenderStepped:Connect(function()
    pcall(function()
        if UpdateVisuals then UpdateVisuals() end
        if HandleFly then HandleFly() end
        
        if _G.XenoV5.AlwaysDay then Lighting.ClockTime = 12 end
        if _G.XenoV5.AlwaysNight then Lighting.ClockTime = 0 end
        if camera.FieldOfView ~= _G.XenoV5.FOV then camera.FieldOfView = _G.XenoV5.FOV end
        
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum then return end
        
        if _G.XenoV5.SpeedHack and hum then hum.WalkSpeed = _G.XenoV5.SpeedValue end
        if _G.XenoV5.Spin and hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(30), 0) end
        
        local mdr = GetMurderer()
        local shr = GetSheriff()
        
        if char:FindFirstChild("Gun") and mdr and mdr:FindFirstChild("HumanoidRootPart") then
            if _G.XenoV5.GunAimbot then camera.CFrame = CFrame.new(camera.CFrame.Position, mdr.HumanoidRootPart.Position) end
            if _G.XenoV5.AutoShoot then if mouse1click then mouse1click() end end
        end
        
        if _G.XenoV5.Tornado and mdr and mdr:FindFirstChild("HumanoidRootPart") and hrp then
            spinAngle = (spinAngle or 0) + 0.2
            local mRoot = mdr.HumanoidRootPart
            local orbit = mRoot.Position + Vector3.new(math.cos(spinAngle)*15, 5, math.sin(spinAngle)*15)
            hrp.CFrame = CFrame.lookAt(orbit, mRoot.Position); hrp.Velocity = Vector3.new(0,0,0)
        end
        
        if _G.XenoV5.FakeLag and hrp then
            if math.random(1, 10) > 8 then hrp.Anchored = true; task.wait(0.1); hrp.Anchored = false end
        end

        -- [ ELITE ANTI-FLING ]
        if _G.XenoV5.AntiFling then
            for _, v in pairs(game:GetService("Players"):GetPlayers()) do
                if v ~= player and v.Character then
                    for _, part in pairs(v.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                            part.Velocity = Vector3.new(0, 0, 0)
                            part.RotVelocity = Vector3.new(0, 0, 0)
                        end
                    end
                end
            end
        end

        -- [ ULTIMATE FLING (ИЗ ТВОЕЙ ССЫЛКИ) ]
        local targetFling = nil
        if _G.XenoV5.FlingMurderer and mdr then targetFling = mdr
        elseif _G.XenoV5.FlingSheriff and shr then targetFling = shr end

        if _G.XenoV5.Fling or targetFling then
            hum.PlatformStand = true -- Делаем персонажа снарядом
            
            -- Добавляем хаотичный импульс (BodyThrust)
            local thrust = hrp:FindFirstChild("UltBodyThrust") or Instance.new("BodyThrust", hrp)
            thrust.Name = "UltBodyThrust"
            thrust.Force = Vector3.new(9999, 9999, 9999)
            thrust.Location = hrp.Position + Vector3.new(0, 1.5, 0)
            
            -- Бешеное вращение (BodyAngularVelocity)
            local spin = hrp:FindFirstChild("UltAngularVel") or Instance.new("BodyAngularVelocity", hrp)
            spin.Name = "UltAngularVel"
            spin.AngularVelocity = Vector3.new(0, 99999, 0)
            spin.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            
            -- Убираем трение
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                    part.CanCollide = false
                end
            end

            -- Авто-наведение для ролевого флинга
            if targetFling and targetFling:FindFirstChild("HumanoidRootPart") then
                hrp.CFrame = targetFling.HumanoidRootPart.CFrame
            end
        else
            -- Чистим всё, если флинг выключен
            if hrp:FindFirstChild("UltBodyThrust") then hrp.UltBodyThrust:Destroy() end
            if hrp:FindFirstChild("UltAngularVel") then hrp.UltAngularVel:Destroy() end
            hum.PlatformStand = false
        end

        -- [ SHERIFF AUTO KILL ]
        if _G.XenoV5.SheriffAutoKill and mdr and mdr:FindFirstChild("HumanoidRootPart") then
            if char:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun") then
                hrp.CFrame = mdr.HumanoidRootPart.CFrame * CFrame.new(0, 5, -12)
                camera.CFrame = CFrame.new(camera.CFrame.Position, mdr.HumanoidRootPart.Position)
                if mouse1click then mouse1click() end
            end
        end

    end)
end)

-- KILL AURA И AUTO FARM COINS (В ОТДЕЛЬНЫХ ПОТОКАХ)
task.spawn(function()
    while true do
        task.wait(0.05)
        pcall(function()
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- [ ИСПРАВЛЕННАЯ KILL AURA С ПОЛЗУНКОМ ]
            if _G.XenoV5.MurdererAura and char:FindFirstChild("Knife") then
                for _, target in pairs(Players:GetPlayers()) do
                    if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHrp = target.Character.HumanoidRootPart
                        local dist = (hrp.Position - targetHrp.Position).Magnitude
                        if dist <= _G.XenoV5.KillAuraRange then
                            hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 1.2) -- ТП за спину
                            mouse1click() -- Удар
                        end
                    end
                end
            end

            -- [ ИСПРАВЛЕННЫЙ АВТО ФАРМ МОНЕТ ]
            if _G.XenoV5.AutoFarmCoins then
                local coinContainer = workspace:FindFirstChild("Normal") and workspace.Normal:FindFirstChild("CoinContainer")
                if coinContainer then
                    local coins = coinContainer:GetChildren()
                    if #coins > 0 then
                        local targetCoin = nil
                        for _, c in pairs(coins) do
                            if c.Name == "Coin_Server" then targetCoin = c; break end
                        end
                        
                        if targetCoin then
                            local dist = (hrp.Position - targetCoin.Position).Magnitude
                            local tweenTime = dist / 40 -- Скорость полета
                            local tween = TweenService:Create(hrp, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = targetCoin.CFrame})
                            tween:Play()
                            tween.Completed:Wait()

                            -- Проверка на полный мешок
                            local bag = player.PlayerGui:FindFirstChild("MainGUI") and player.PlayerGui.MainGUI:FindFirstChild("Game") and player.PlayerGui.MainGUI.Game:FindFirstChild("Cashbag")
                            if bag and bag:FindFirstChild("Full") and bag.Full.Visible then
                                char:BreakJoints() -- Мешок полон -> умираем
                            end
                        end
                    end
                end
            end
            
            -- [ ПРОДВИНУТЫЙ AUTO GRAB GUN ]
            if _G.XenoV5.AutoGrabGun and not _G.IsTeleporting then
                local drop = workspace:FindFirstChild("GunDrop", true)
                
                if drop and drop:IsA("BasePart") then
                    -- 1. Проверяем, где убийца
                    local murderer = nil
                    for _, p in pairs(game:GetService("Players"):GetPlayers()) do
                        -- Ищем игрока, у которого в руках или в рюкзаке нож
                        if p.Character and (p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")) then
                            murderer = p.Character
                            break
                        end
                    end

                    -- 2. Проверяем дистанцию (безопасно ли?)
                    local isSafe = true
                    if murderer and murderer:FindFirstChild("HumanoidRootPart") then
                        local distToGun = (murderer.HumanoidRootPart.Position - drop.Position).Magnitude
                        if distToGun < 10 then -- Если убийца ближе 35 метров к пушке — не прыгаем
                            isSafe = false
                        end
                    end

                    -- 3. Если безопасно, выполняем маневр
                    if isSafe then
                        _G.IsTeleporting = true -- Включаем "замок"
                        local oldPos = hrp.CFrame -- Запоминаем твою позицию
                        
                        hrp.CFrame = drop.CFrame -- ТП к пушке
                        task.wait(0.2) -- Ждем ровно 1 секунду
                        
                        hrp.CFrame = oldPos -- ТП обратно на старое место
                        task.wait(0.5) -- Небольшая пауза перед следующей попыткой
                        _G.IsTeleporting = false -- Выключаем "замок"
                    end
                end
            end
        end)
    end
end)

-- HEARTBEAT (ФИЗИКА)
RunService.Heartbeat:Connect(function()
    pcall(function()
        if _G.XenoV5.Noclip and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        
        if _G.XenoV5.RemoveDoors then
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "Door" or v.Name == "MapDoor" then v:Destroy() end
            end
        end
        
        if _G.XenoV5.Fling and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local target = mdr or shf 
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local bThrust = Instance.new("BodyThrust", hrp)
                bThrust.Force = Vector3.new(9999, 9999, 9999)
                hrp.CFrame = target.Character.HumanoidRootPart.CFrame
                task.wait(0.1)
                bThrust:Destroy()
            end
        end
    end)
end)

-- ВВОД ПОЛЬЗОВАТЕЛЯ
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.F4 then
        main.Visible = not main.Visible
    end
    
    if input.KeyCode == Enum.KeyCode.Space and _G.XenoV5.InfJump then
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- CTRL + CLICK TELEPORT
mouse.Button1Down:Connect(function()
    if _G.XenoV5.CtrlClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if mouse.Hit and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = mouse.Hit + Vector3.new(0, 3, 0)
        end
    end
end)

-- CHAT SPAMMER ЦИКЛ
task.spawn(function()
    while true do
        if _G.XenoV5.ChatSpam then
            pcall(function()
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(_G.XenoV5.SpamText, "All")
            end)
        end
        task.wait(2.5)
    end
end)

Notify("Injected", "Welcome to Xeno V5 Titan PRO. Press F4 or RightShift to hide.", 5)
