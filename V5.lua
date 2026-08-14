local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local ok, VRS = pcall(function()
    return game:GetService("VirtualInputManager")
end)
if not ok then VRS = nil end

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- =========================================================
-- [ЭКРАННЫЕ ФУНКЦИИ И КЛИК]
-- =========================================================
local function GetScreenCenter()
    if not camera then return Vector2.new(0, 0) end
    return Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
end

local function MoveMouseToAbs(x, y)
    pcall(function()
        if camera then
            local vp = camera.ViewportSize
            x = math.clamp(x, 0, vp.X)
            y = math.clamp(y, 0, vp.Y)
        end

        x = math.floor(x + 0.5)
        y = math.floor(y + 0.5)

        if mousemoveabs then
            mousemoveabs(x, y)
            return
        end

        if setmouseposition then
            setmouseposition(x, y)
            return
        end

        if VRS and VRS.SendMouseMoveEvent then
            VRS:SendMouseMoveEvent(x, y, game)
            return
        end

        if _G.XenoV5.AllowRelativeMouse and mousemoverel then
            local cur = UserInputService:GetMouseLocation()
            mousemoverel(x - cur.X, y - cur.Y)
        end
    end)
end

local function TryActivateTool()
    pcall(function()
        local char = player.Character
        if not char then return end

        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            tool:Activate()
        end
    end)
end

local function DoMouseClickAt(x, y)
    pcall(function()
        if x and y then
            MoveMouseToAbs(x, y)
        end

        if mouse1click then
            mouse1click()
            return
        end

        if mouse1press and mouse1release then
            mouse1press()
            task.delay(0.03, function()
                pcall(function()
                    mouse1release()
                end)
            end)
            return
        end

        if VRS and VRS.SendMouseButtonEvent then
            local clickX = x or mouse.X
            local clickY = y or mouse.Y

            if camera then
                local vp = camera.ViewportSize
                clickX = math.clamp(clickX, 0, vp.X)
                clickY = math.clamp(clickY, 0, vp.Y)
            end

            clickX = math.floor(clickX + 0.5)
            clickY = math.floor(clickY + 0.5)

            VRS:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
            task.delay(0.03, function()
                pcall(function()
                    VRS:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
                end)
            end)
            return
        end

        TryActivateTool()
    end)
end

local function DoMouseClick()
    DoMouseClickAt(mouse.X, mouse.Y)
end

-- =========================================================
-- [ГЛОБАЛЬНЫЕ НАСТРОЙКИ]
-- =========================================================
_G.XenoV5 = {
    ESP_Murderer = false,
    ESP_Sheriff = false,
    ESP_Innocent = false,
    ESP_Gun = false,
    Tracers = false,
    Chams = false,
    Fullbright = false,
    AlwaysDay = false,
    AlwaysNight = false,
    FOV = 70,

    Fling = false,
    FlingMurderer = false,
    FlingSheriff = false,

    GunAimbot = false,
    AimbotSmooth = 10,
    AimbotFOV = 360,
    AutoShoot = false,
    AutoGrabGun = false,
    AllowRelativeMouse = false,

    MurdererAura = false,
    KillAuraRange = 20,
    HitboxExpander = false,

    SpeedHack = false,
    SpeedValue = 25,
    InfJump = false,
    Noclip = false,
    Fly = false,
    FlySpeed = 50,
    Spin = false,
    AntiFling = false,
    CtrlClickTP = false,

    AutoFarmCoins = false,
    RemoveDoors = false,
    WaterWalk = false,

    SheriffAutoKill = false,
    Tornado = false,
    ChatSpam = false,
    SpamText = "Xeno V5 Titan dominates this server!",
    FakeLag = false,

    FlingActive = true
}

_G.IsTeleporting = false

local origAmbient = Lighting.Ambient
local origBrightness = Lighting.Brightness
local origTime = Lighting.ClockTime

-- =========================================================
-- [УВЕДОМЛЕНИЯ]
-- =========================================================
local function Notify(title, text, duration)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "☣️ " .. title,
            Text = text,
            Duration = duration or 3,
            Icon = "rbxassetid://6023426923"
        })
    end)
end

-- =========================================================
-- [GUI]
-- =========================================================
local uiName = "XenoV5_Titan_Pro"
if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
if player.PlayerGui:FindFirstChild(uiName) then player.PlayerGui[uiName]:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = uiName
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success = pcall(function()
    screenGui.Parent = CoreGui
end)
if not success then
    screenGui.Parent = player.PlayerGui
end

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

local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "XENO V5.7 FULL FIX | MM2"
title.TextColor3 = Color3.fromRGB(0, 255, 128)
title.Font = Enum.Font.GothamBlack
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local dragging, dragInput, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
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
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

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

local toggleRegistry = {}

local function UpdateToggleVisual(flag, state)
    pcall(function()
        for _, data in pairs(toggleRegistry) do
            if data.flag == flag then
                TweenService:Create(data.circle, TweenInfo.new(0.2), {
                    Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                }):Play()

                TweenService:Create(data.btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = state and Color3.fromRGB(0, 255, 128) or Color3.fromRGB(50, 50, 50)
                }):Play()
            end
        end
    end)
end

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

    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do
            p.Page.Visible = false
            p.Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        page.Visible = true
        btn.TextColor3 = Color3.fromRGB(0, 255, 128)
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
    if _G.XenoV5[flag] == nil then
        _G.XenoV5[flag] = false
    end

    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.95, 0, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(1, -50, 0.5, -10)
    btn.BackgroundColor3 = _G.XenoV5[flag] and Color3.fromRGB(0, 255, 128) or Color3.fromRGB(50, 50, 50)
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame", btn)
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = _G.XenoV5[flag] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    table.insert(toggleRegistry, {flag = flag, btn = btn, circle = circle})

    btn.MouseButton1Click:Connect(function()
        _G.XenoV5[flag] = not _G.XenoV5[flag]
        UpdateToggleVisual(flag, _G.XenoV5[flag])

        if callback then
            callback(_G.XenoV5[flag])
        end
    end)

    return frame
end

local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)

    return btn
end

local function CreateSlider(parent, text, flag, min, max, default)
    if _G.XenoV5[flag] == nil then
        _G.XenoV5[flag] = default
    end

    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.95, 0, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valLabel = Instance.new("TextLabel", frame)
    valLabel.Size = UDim2.new(0.2, 0, 1, 0)
    valLabel.Position = UDim2.new(0.5, 0, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(_G.XenoV5[flag])
    valLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 13

    local minusBtn = Instance.new("TextButton", frame)
    minusBtn.Size = UDim2.new(0, 25, 0, 25)
    minusBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
    minusBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    minusBtn.Text = "-"
    minusBtn.TextColor3 = Color3.new(1, 1, 1)
    local c1 = Instance.new("UICorner", minusBtn)
    c1.CornerRadius = UDim.new(0, 6)

    local plusBtn = Instance.new("TextButton", frame)
    plusBtn.Size = UDim2.new(0, 25, 0, 25)
    plusBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
    plusBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.new(1, 1, 1)
    local c2 = Instance.new("UICorner", plusBtn)
    c2.CornerRadius = UDim.new(0, 6)

    local function update(change)
        local newVal = math.clamp(_G.XenoV5[flag] + change, min, max)
        _G.XenoV5[flag] = newVal
        valLabel.Text = tostring(newVal)
    end

    minusBtn.MouseButton1Click:Connect(function()
        update(-1)
    end)

    plusBtn.MouseButton1Click:Connect(function()
        update(1)
    end)

    return frame
end

-- =========================================================
-- [БАЗОВЫЕ ПРОВЕРКИ]
-- =========================================================
local function IsCharAlive(char)
    if not char or not char.Parent then return false end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return hum and hrp and hum.Health > 0
end

local function HasGunEquipped()
    local char = player.Character
    return char and char:FindFirstChild("Gun") ~= nil
end

local function HasGunAnywhere()
    local char = player.Character
    if char and char:FindFirstChild("Gun") then
        return true
    end

    local backpack = player:FindFirstChild("Backpack")
    if backpack and backpack:FindFirstChild("Gun") then
        return true
    end

    return false
end

local function HasKnifeEquipped()
    local char = player.Character
    return char and char:FindFirstChild("Knife") ~= nil
end

local function GetMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local char = p.Character
            if IsCharAlive(char) then
                local backpack = p:FindFirstChild("Backpack")
                if char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")) then
                    return char
                end
            end
        end
    end
    return nil
end

local function GetSheriff()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local char = p.Character
            if IsCharAlive(char) then
                local backpack = p:FindFirstChild("Backpack")
                if char:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun")) then
                    return char
                end
            end
        end
    end
    return nil
end

-- =========================================================
-- [SKID FLING - ФУНКЦИЯ ОСТАВЛЕНА]
-- =========================================================
local function SkidFling(TargetPlayer)
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local tchar = TargetPlayer and TargetPlayer.Character
    local thrp = tchar and tchar:FindFirstChild("HumanoidRootPart")
    local thum = tchar and tchar:FindFirstChildOfClass("Humanoid")

    if hrp and thrp and thum then
        local oldPos = hrp.CFrame
        local startTime = tick()

        local fly = Instance.new("BodyVelocity")
        fly.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        fly.Velocity = Vector3.new(0, 0, 0)
        fly.Parent = hrp

        hum.PlatformStand = true

        repeat
            task.wait()
            local rot = CFrame.Angles(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))
            local pos = thrp.CFrame * CFrame.new(0, 1.5, 0) * rot
            hrp.CFrame = pos
            hrp.Velocity = Vector3.new(9e7, 9e7, 9e7)
            hrp.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        until not TargetPlayer or not tchar or not thrp or (thrp.Position - hrp.Position).Magnitude > 500 or tick() - startTime > 2 or not _G.XenoV5.FlingActive

        fly:Destroy()
        hum.PlatformStand = false
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.RotVelocity = Vector3.new(0, 0, 0)

        for i = 1, 5 do
            hrp.CFrame = oldPos
            task.wait()
        end
    end
end

-- =========================================================
-- [GUN ESP + КЭШ ПИСТОЛЕТА]
-- =========================================================
local function CreateGunESP(gun)
    if not _G.XenoV5.ESP_Gun then return end
    if not gun or not gun.Parent then return end
    if gun:FindFirstChild("GunESP_Highlight") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "GunESP_Highlight"
    highlight.Adornee = gun
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

local cachedGunDrop = nil
local gunWatchConnections = {}

local function GetGunBase(obj)
    if not obj then return nil end

    if obj:IsA("BasePart") then
        return obj
    end

    return obj:FindFirstChildWhichIsA("BasePart")
end

local function SetCachedGun(obj)
    local part = GetGunBase(obj)

    if part then
        if cachedGunDrop == part then return end
        cachedGunDrop = part

        if _G.XenoV5.ESP_Gun then
            CreateGunESP(part)
        end

        part.AncestryChanged:Connect(function()
            if cachedGunDrop == part and not part.Parent then
                cachedGunDrop = nil
            end
        end)
    else
        if obj and obj.DescendantAdded then
            if gunWatchConnections[obj] then return end

            gunWatchConnections[obj] = obj.DescendantAdded:Connect(function(child)
                if child:IsA("BasePart") then
                    SetCachedGun(child)
                end
            end)
        end
    end
end

workspace.DescendantAdded:Connect(function(obj)
    pcall(function()
        if obj.Name == "GunDrop" then
            task.defer(function()
                SetCachedGun(obj)
            end)
        end

        if _G.XenoV5.RemoveDoors and (obj.Name == "Door" or obj.Name == "MapDoor") then
            pcall(function()
                obj:Destroy()
            end)
        end
    end)
end)

task.defer(function()
    local drop = workspace:FindFirstChild("GunDrop", true)
    if drop then
        SetCachedGun(drop)
    end
end)

-- =========================================================
-- [ВКЛАДКИ]
-- =========================================================
local tabVisuals = CreateTab("Visuals", "👁️")
local tabCombat = CreateTab("Combat", "⚔️")
local tabMovement = CreateTab("Movement", "🏃")
local tabWorld = CreateTab("World", "🌍")
local tabMisc = CreateTab("Misc", "⚡")
local tabInjects = CreateTab("Injects", "💉")

pages[1].Btn.TextColor3 = Color3.fromRGB(0, 255, 128)
pages[1].Page.Visible = true

-- =========================================================
-- [VISUALS]
-- =========================================================
CreateSection(tabVisuals, "Players")
CreateToggle(tabVisuals, "Murderer ESP", "ESP_Murderer")
CreateToggle(tabVisuals, "Sheriff ESP", "ESP_Sheriff")
CreateToggle(tabVisuals, "Innocent ESP", "ESP_Innocent")
CreateToggle(tabVisuals, "Player Chams", "Chams")
CreateToggle(tabVisuals, "Player Tracers", "Tracers")

CreateSection(tabVisuals, "Items")
CreateToggle(tabVisuals, "Gun ESP (Dropped)", "ESP_Gun", function(state)
    if state then
        if cachedGunDrop then
            CreateGunESP(cachedGunDrop)
        else
            local drop = workspace:FindFirstChild("GunDrop", true)
            if drop then
                SetCachedGun(drop)
            end
        end
    else
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "GunESP_Highlight" or v.Name == "GunESP_Text" then
                pcall(function()
                    v:Destroy()
                end)
            end
        end
    end
end)

CreateSection(tabVisuals, "Environment")
CreateToggle(tabVisuals, "Fullbright", "Fullbright", function(state)
    Lighting.Ambient = state and Color3.new(1, 1, 1) or origAmbient
    Lighting.Brightness = state and 2 or origBrightness
end)
CreateToggle(tabVisuals, "Always Day", "AlwaysDay")
CreateToggle(tabVisuals, "Always Night", "AlwaysNight")
CreateSlider(tabVisuals, "Field of View", "FOV", 70, 120, 70)

-- =========================================================
-- [COMBAT]
-- =========================================================
CreateSection(tabCombat, "Murderer")
CreateToggle(tabCombat, "Kill Aura (Knife Required)", "MurdererAura")
CreateSlider(tabCombat, "Kill Aura Range", "KillAuraRange", 1, 100, 20)
CreateToggle(tabCombat, "Fling Sheriff", "FlingMurderer")

CreateSection(tabCombat, "Sheriff")
CreateToggle(tabCombat, "Smart Gun Aimbot (Only In Hands)", "GunAimbot")
CreateSlider(tabCombat, "Aimbot Sharpness (1-10)", "AimbotSmooth", 1, 10, 10)
CreateSlider(tabCombat, "Aimbot FOV Limit", "AimbotFOV", 30, 360, 360)
CreateToggle(tabCombat, "Auto Shoot Murderer", "AutoShoot")
CreateToggle(tabCombat, "TP To Murder", "SheriffAutoKill")
CreateToggle(tabCombat, "Fling Murder", "FlingSheriff")

CreateSection(tabCombat, "General & Fling")
CreateToggle(tabCombat, "Ultimate Fling (ALL)", "Fling")
CreateToggle(tabCombat, "Auto Grab Gun (Safe)", "AutoGrabGun")
CreateToggle(tabCombat, "Expand Hitboxes", "HitboxExpander")

CreateButton(tabCombat, "Safe TP to Dropped Gun", function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local gunObj = cachedGunDrop or workspace:FindFirstChild("GunDrop", true)
    local target = GetGunBase(gunObj)

    if not target then
        Notify("Error", "Gun is not dropped yet!", 2)
        return
    end

    local mdr = GetMurderer()
    if mdr and mdr:FindFirstChild("HumanoidRootPart") then
        local dist = (mdr.HumanoidRootPart.Position - target.Position).Magnitude
        if dist < 30 then
            Notify("Danger", "Murderer is too close to the gun!", 3)
            return
        end
    end

    local originalCFrame = hrp.CFrame
    Notify("Action", "Grabbing gun...", 1)
    hrp.CFrame = target.CFrame + Vector3.new(0, 2, 0)
    task.wait(0.5)
    hrp.CFrame = originalCFrame
end)

-- =========================================================
-- [MOVEMENT]
-- =========================================================
CreateSection(tabMovement, "Speed & Flight")
CreateToggle(tabMovement, "Speed Hack", "SpeedHack", function(state)
    if not state and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 16
    end
end)
CreateSlider(tabMovement, "Speed Value", "SpeedValue", 16, 100, 25)
CreateToggle(tabMovement, "Fly Mode", "Fly")
CreateSlider(tabMovement, "Fly Speed", "FlySpeed", 10, 200, 50)

CreateSection(tabMovement, "Modifiers")
CreateToggle(tabMovement, "Infinite Jump", "InfJump")
CreateToggle(tabMovement, "Noclip (Walk through walls)", "Noclip")
CreateToggle(tabMovement, "Ctrl + Click TP", "CtrlClickTP")
CreateToggle(tabMovement, "Anti-Fling", "AntiFling")

-- =========================================================
-- [WORLD]
-- =========================================================
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

-- =========================================================
-- [MISC]
-- =========================================================
CreateSection(tabMisc, "Trolling")
CreateToggle(tabMisc, "Spinbot", "Spin")
CreateToggle(tabMisc, "Tornado Mode", "Tornado")
CreateToggle(tabMisc, "Loop Fling All", "Fling")
CreateToggle(tabMisc, "Fake Lag (Blink)", "FakeLag")
CreateToggle(tabMisc, "Chat Spammer", "ChatSpam")

-- =========================================================
-- [INJECTS]
-- =========================================================
CreateSection(tabInjects, "Main Injects")

CreateButton(tabInjects, "Inject Bot", function()
    Notify("Injects", "Bot Injected Successfully!", 3)
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/doloword-hash/botscr54iptts.lua/refs/heads/main/Inject1.lua'))()
    end)
end)

CreateButton(tabInjects, "Tab Teleport", function()
    Notify("Injects", "Tab Teleport Injected Successfully!", 3)
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/doloword-hash/botscr54iptts.lua/refs/heads/main/Inject2.lua'))()
    end)
end)

CreateButton(tabInjects, "Fling Script", function()
    Notify("Injects", "Fling Injected Successfully!", 3)
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/doloword-hash/botscr54iptts.lua/refs/heads/main/KILASIKFLING.lua'))()
    end)
end)

local ExtraInjectBtn = CreateButton(tabInjects, "SuperTAB", function()
    Notify("Injects", "SuperTAB inject slot ready!", 2)
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/doloword-hash/botscr54iptts.lua/refs/heads/main/Multi%20inject%203'))()
    end)
end)

local ExtraCorner = Instance.new("UICorner")
ExtraCorner.CornerRadius = UDim.new(0, 4)
ExtraCorner.Parent = ExtraInjectBtn

-- =========================================================
-- [VISUALS / ESP / TRACERS]
-- =========================================================
local mdrChar, shfChar = nil, nil

local function GetTracerAttachment(part)
    if not part then return nil end

    local att = part:FindFirstChild("XenoTracerAttachment")
    if not att then
        att = Instance.new("Attachment")
        att.Name = "XenoTracerAttachment"
        att.Position = Vector3.new(0, 0, 0)
        att.Parent = part
    end

    return att
end

local function UpdateVisuals()
    mdrChar = nil
    shfChar = nil

    local localChar = player.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    local localAttach = GetTracerAttachment(localRoot)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local char = p.Character

            if IsCharAlive(char) then
                local root = char:FindFirstChild("HumanoidRootPart")
                local backpack = p:FindFirstChild("Backpack")

                local hasKnife = char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife"))
                local hasGun = char:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun"))

                local hl = char:FindFirstChild("XenoESP_HL")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "XenoESP_HL"
                    hl.Parent = char
                end

                hl.DepthMode = _G.XenoV5.Chams and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded

                if hasKnife then
                    mdrChar = char
                    hl.Enabled = _G.XenoV5.ESP_Murderer
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 80, 80)
                elseif hasGun then
                    shfChar = char
                    hl.Enabled = _G.XenoV5.ESP_Sheriff
                    hl.FillColor = Color3.fromRGB(0, 100, 255)
                    hl.OutlineColor = Color3.fromRGB(120, 180, 255)
                else
                    hl.Enabled = _G.XenoV5.ESP_Innocent
                    hl.FillColor = Color3.fromRGB(0, 255, 0)
                    hl.OutlineColor = Color3.fromRGB(120, 255, 120)
                end

                local beam = char:FindFirstChild("XenoTracer")

                if _G.XenoV5.Tracers and localAttach and root then
                    local targetAttach = GetTracerAttachment(root)

                    if not beam then
                        beam = Instance.new("Beam")
                        beam.Name = "XenoTracer"
                        beam.Parent = char
                    end

                    beam.Attachment0 = localAttach
                    beam.Attachment1 = targetAttach
                    beam.FaceCamera = true
                    beam.Width0 = 0.12
                    beam.Width1 = 0.12
                    beam.LightEmission = 1
                    beam.Transparency = NumberSequence.new(0)
                    beam.Color = ColorSequence.new(hl.FillColor)
                    beam.Enabled = true
                else
                    if beam then
                        beam.Enabled = false
                    end
                end

                if _G.XenoV5.HitboxExpander and root then
                    root.Size = Vector3.new(6, 6, 6)
                    root.Transparency = 0.7
                    root.CanCollide = true
                elseif root then
                    root.Size = Vector3.new(2, 2, 1)
                    root.Transparency = 1
                    root.CanCollide = true
                end
            end
        end
    end
end

-- =========================================================
-- [FLY]
-- =========================================================
local flying = false
local flyBv, flyBg

local function HandleFly()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local hrp = char.HumanoidRootPart
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end

    if _G.XenoV5.Fly and not flying then
        flying = true

        flyBv = Instance.new("BodyVelocity")
        flyBv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBv.Velocity = Vector3.new(0, 0, 0)
        flyBv.Parent = hrp

        flyBg = Instance.new("BodyGyro")
        flyBg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        flyBg.D = 50
        flyBg.Parent = hrp

        hum.PlatformStand = true

    elseif not _G.XenoV5.Fly and flying then
        flying = false

        if flyBv then flyBv:Destroy(); flyBv = nil end
        if flyBg then flyBg:Destroy(); flyBg = nil end

        hum.PlatformStand = false
    end

    if flying and flyBv and flyBg then
        flyBg.CFrame = camera.CFrame

        local dir = Vector3.new(0, 0, 0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end

        if dir.Magnitude > 0 then
            flyBv.Velocity = dir.Unit * _G.XenoV5.FlySpeed
        else
            flyBv.Velocity = Vector3.new(0, 0, 0)
        end
    end
end

-- =========================================================
-- [WATER WALK]
-- =========================================================
local function HandleWaterWalk()
    if not _G.XenoV5.WaterWalk then return end

    local char = player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local okRay, result = pcall(function()
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {char}

        local filterOK = pcall(function()
            params.FilterType = Enum.RaycastFilterType.Exclude
        end)
        if not filterOK then
            params.FilterType = Enum.RaycastFilterType.Blacklist
        end

        return workspace:Raycast(hrp.Position, Vector3.new(0, -4, 0), params)
    end)

    if okRay and result then
        local isWater = result.Material == Enum.Material.Water
            or result.Instance.Name:lower():find("water") ~= nil

        if isWater then
            hrp.CFrame = CFrame.new(hrp.Position.X, result.Position.Y + 2.5, hrp.Position.Z)
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
        end
    end
end

-- =========================================================
-- [SMART AIMBOT]
-- =========================================================
local lastGunShot = 0
local lastSheriffKill = 0
local lastAura = 0
local fakeLagBusy = false
local doorsCleaned = false
local lastGunSearch = 0
local cachedCoinContainer = nil
local spinAngle = 0

local AUTO_SHOOT_COOLDOWN = 0.16

local aimMemory = {
    target = nil,
    lastPos = nil,
    lastTime = 0,
    smoothVel = Vector3.new(0, 0, 0)
}

local function GetSmoothVelocity(part)
    local now = tick()
    local pos = part.Position

    if aimMemory.target ~= part or not aimMemory.lastPos or now - aimMemory.lastTime > 0.25 or now - aimMemory.lastTime <= 0.0001 then
        aimMemory.target = part
        aimMemory.lastPos = pos
        aimMemory.lastTime = now
        aimMemory.smoothVel = part.AssemblyLinearVelocity or part.Velocity or Vector3.new(0, 0, 0)
        return aimMemory.smoothVel
    end

    local dt = now - aimMemory.lastTime
    local instVel = (pos - aimMemory.lastPos) / dt

    if instVel.Magnitude > 140 then
        instVel = instVel.Unit * 140
    end

    aimMemory.smoothVel = aimMemory.smoothVel:Lerp(instVel, 0.45)
    aimMemory.lastPos = pos
    aimMemory.lastTime = now

    return aimMemory.smoothVel
end

local function IsTargetAirborne(char)
    local okAir, airborne = pcall(function()
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return false end

        local params = RaycastParams.new()

        local filters = {char}
        if player.Character then
            table.insert(filters, player.Character)
        end

        params.FilterDescendantsInstances = filters

        local filterOK = pcall(function()
            params.FilterType = Enum.RaycastFilterType.Exclude
        end)
        if not filterOK then
            params.FilterType = Enum.RaycastFilterType.Blacklist
        end

        local result = workspace:Raycast(root.Position - Vector3.new(0, 1, 0), Vector3.new(0, -4.5, 0), params)
        return result == nil
    end)

    return okAir and airborne or false
end

local function GetSmartAimPosition(targetChar, targetPart)
    local basePos = targetPart.Position
    local vel = GetSmoothVelocity(targetPart)

    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local dist = myRoot and (myRoot.Position - basePos).Magnitude or 60

    local ping = 0
    local pingOK, pingVal = pcall(function()
        return player:GetNetworkPing()
    end)
    if pingOK and type(pingVal) == "number" then
        ping = pingVal
    end

    local predictTime = math.clamp(0.035 + ping * 1.35 + dist / 1600, 0, 0.22)

    if vel.Magnitude < 2 then
        predictTime = math.min(predictTime, 0.02)
    end

    local predicted = basePos + vel * predictTime

    if math.abs(vel.Y) > 6 and IsTargetAirborne(targetChar) then
        predicted = predicted - Vector3.new(0, 0.5 * workspace.Gravity * predictTime * predictTime, 0)
    end

    if predicted ~= predicted then
        predicted = basePos
    end

    return predicted
end

local function AimAndShoot()
    camera = workspace.CurrentCamera
    if not camera then return end

    local needAim = _G.XenoV5.GunAimbot or _G.XenoV5.AutoShoot or _G.XenoV5.SheriffAutoKill
    if not needAim then
        aimMemory.target = nil
        return
    end

    if not HasGunEquipped() then
        aimMemory.target = nil
        return
    end

    local target = mdrChar or GetMurderer()
    if not IsCharAlive(target) then
        aimMemory.target = nil
        return
    end

    local part = target:FindFirstChild("HumanoidRootPart")
        or target:FindFirstChild("Torso")
        or target:FindFirstChild("Head")

    if not part then return end

    local fov = _G.XenoV5.AimbotFOV or 360
    local checkPos, checkOnScreen = camera:WorldToViewportPoint(part.Position)

    if fov < 360 then
        if not checkOnScreen then return end
        local distFromCenter = (Vector2.new(checkPos.X, checkPos.Y) - GetScreenCenter()).Magnitude
        if distFromCenter > fov then return end
    end

    local aimPos = GetSmartAimPosition(target, part)

    if (camera.CFrame.Position - aimPos).Magnitude < 0.1 then
        return
    end

    local goal = CFrame.lookAt(camera.CFrame.Position, aimPos)
    local sharp = math.clamp((_G.XenoV5.AimbotSmooth or 10) / 10, 0.05, 1)

    if _G.XenoV5.AutoShoot or _G.XenoV5.SheriffAutoKill or sharp >= 0.95 then
        camera.CFrame = goal
    else
        camera.CFrame = camera.CFrame:Lerp(goal, sharp)
    end

    local shootPos, shootOnScreen = camera:WorldToViewportPoint(aimPos)
    local shouldShoot = _G.XenoV5.AutoShoot or _G.XenoV5.SheriffAutoKill

    if shouldShoot and shootOnScreen and tick() - lastGunShot > AUTO_SHOOT_COOLDOWN then
        lastGunShot = tick()

        local sx = shootPos.X
        local sy = shootPos.Y

        task.delay(0.01, function()
            DoMouseClickAt(sx, sy)
        end)
    end
end

local aimBindOK = pcall(function()
    RunService:UnbindFromRenderStep("XenoAimbot")
    RunService:BindToRenderStep("XenoAimbot", Enum.RenderPriority.Camera.Value + 1, function()
        pcall(AimAndShoot)
    end)
end)

if not aimBindOK then
    RunService.RenderStepped:Connect(function()
        pcall(AimAndShoot)
    end)
end

-- =========================================================
-- [ОСНОВНОЙ RENDER]
-- =========================================================
RunService.RenderStepped:Connect(function()
    pcall(function()
        camera = workspace.CurrentCamera

        UpdateVisuals()
        HandleFly()
        HandleWaterWalk()

        if _G.XenoV5.AlwaysDay then Lighting.ClockTime = 12 end
        if _G.XenoV5.AlwaysNight then Lighting.ClockTime = 0 end

        if camera and camera.FieldOfView ~= _G.XenoV5.FOV then
            camera.FieldOfView = _G.XenoV5.FOV
        end

        local char = player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum then return end

        if _G.XenoV5.SpeedHack then
            hum.WalkSpeed = _G.XenoV5.SpeedValue
        end

        if _G.XenoV5.Spin then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(30), 0)
        end

        local murderer = mdrChar or GetMurderer()
        local sheriff = shfChar or GetSheriff()

        if _G.XenoV5.Tornado and IsCharAlive(murderer) then
            local mRoot = murderer:FindFirstChild("HumanoidRootPart")
            if mRoot then
                spinAngle = spinAngle + 0.2
                local orbit = mRoot.Position + Vector3.new(math.cos(spinAngle) * 15, 5, math.sin(spinAngle) * 15)
                hrp.CFrame = CFrame.lookAt(orbit, mRoot.Position)
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        end

        if _G.XenoV5.FakeLag and hrp and not fakeLagBusy then
            if math.random(1, 10) > 8 then
                fakeLagBusy = true
                hrp.Anchored = true

                task.delay(0.1, function()
                    pcall(function()
                        hrp.Anchored = false
                    end)
                    fakeLagBusy = false
                end)
            end
        end

        local targetFling = nil

        if _G.XenoV5.FlingMurderer and IsCharAlive(murderer) then
            targetFling = murderer
        elseif _G.XenoV5.FlingSheriff and IsCharAlive(sheriff) then
            targetFling = sheriff
        end

        if _G.XenoV5.Fling or targetFling then
            hum.PlatformStand = true

            local thrust = hrp:FindFirstChild("UltBodyThrust")
            if not thrust then
                thrust = Instance.new("BodyThrust")
                thrust.Name = "UltBodyThrust"
                thrust.Parent = hrp
            end

            thrust.Force = Vector3.new(9999, 9999, 9999)
            thrust.Location = hrp.Position + Vector3.new(0, 1.5, 0)

            local spin = hrp:FindFirstChild("UltAngularVel")
            if not spin then
                spin = Instance.new("BodyAngularVelocity")
                spin.Name = "UltAngularVel"
                spin.Parent = hrp
            end

            spin.AngularVelocity = Vector3.new(0, 99999, 0)
            spin.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)

            for _, p in pairs(char:GetChildren()) do
                if p:IsA("BasePart") then
                    p.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                    p.CanCollide = false
                end
            end

            if targetFling and targetFling:FindFirstChild("HumanoidRootPart") then
                hrp.CFrame = targetFling.HumanoidRootPart.CFrame
            end
        else
            local thrust = hrp:FindFirstChild("UltBodyThrust")
            if thrust then thrust:Destroy() end

            local spin = hrp:FindFirstChild("UltAngularVel")
            if spin then spin:Destroy() end

            hum.PlatformStand = false

            for _, p in pairs(char:GetChildren()) do
                if p:IsA("BasePart") then
                    p.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                    if not _G.XenoV5.Noclip then
                        p.CanCollide = true
                    end
                end
            end
        end

        if _G.XenoV5.SheriffAutoKill and HasGunEquipped() and IsCharAlive(murderer) then
            if tick() - lastSheriffKill > 0.25 then
                lastSheriffKill = tick()
                hrp.CFrame = murderer.HumanoidRootPart.CFrame * CFrame.new(0, 5, -12)
            end
        end
    end)
end)

-- =========================================================
-- [ANTI-FLING - РАБОЧИЙ КЭШИРОВАННЫЙ ВАРИАНТ]
-- =========================================================
local antiFlingParts = {}
local antiFlingConnections = {}

local function SetupAntiFlingCharacter(char)
    if not char or antiFlingParts[char] then
        return
    end

    antiFlingParts[char] = {}

    local function addPart(part)
        if part:IsA("BasePart") then
            table.insert(antiFlingParts[char], part)
        end
    end

    for _, part in pairs(char:GetDescendants()) do
        addPart(part)
    end

    local conn = {}

    conn.DescendantAdded = char.DescendantAdded:Connect(function(part)
        if antiFlingParts[char] then
            addPart(part)
        end
    end)

    conn.AncestryChanged = char.AncestryChanged:Connect(function()
        if not char.Parent then
            antiFlingParts[char] = nil

            if antiFlingConnections[char] then
                pcall(function()
                    antiFlingConnections[char].DescendantAdded:Disconnect()
                end)

                pcall(function()
                    antiFlingConnections[char].AncestryChanged:Disconnect()
                end)

                antiFlingConnections[char] = nil
            end
        end
    end)

    antiFlingConnections[char] = conn
end

RunService.RenderStepped:Connect(function()
    if not _G.XenoV5.AntiFling then
        return
    end

    pcall(function()
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= player and v.Character then
                local char = v.Character

                SetupAntiFlingCharacter(char)

                local parts = antiFlingParts[char]
                if parts then
                    for i = #parts, 1, -1 do
                        local part = parts[i]

                        if not part or not part.Parent then
                            table.remove(parts, i)
                        else
                            part.CanCollide = false
                            part.Velocity = Vector3.new(0, 0, 0)
                            part.RotVelocity = Vector3.new(0, 0, 0)
                        end
                    end
                end
            end
        end
    end)
end)

-- =========================================================
-- [HEARTBEAT]
-- =========================================================
RunService.Heartbeat:Connect(function()
    pcall(function()
        if _G.XenoV5.Noclip and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end

        if _G.XenoV5.RemoveDoors then
            if not doorsCleaned then
                doorsCleaned = true
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name == "Door" or v.Name == "MapDoor" then
                        pcall(function()
                            v:Destroy()
                        end)
                    end
                end
            end
        else
            doorsCleaned = false
        end
    end)
end)

-- =========================================================
-- [INPUT]
-- =========================================================
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

mouse.Button1Down:Connect(function()
    if _G.XenoV5.CtrlClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if mouse.Hit and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end
end)

-- =========================================================
-- [KILL AURA LOOP]
-- =========================================================
task.spawn(function()
    while true do
        task.wait(0.1)

        pcall(function()
            if not _G.XenoV5.MurdererAura then return end
            if not HasKnifeEquipped() then return end

            local char = player.Character
            if not char then return end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            if tick() - lastAura < 0.15 then return end

            for _, target in pairs(Players:GetPlayers()) do
                if target ~= player and IsCharAlive(target.Character) then
                    local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
                    if targetHrp then
                        local dist = (hrp.Position - targetHrp.Position).Magnitude
                        if dist <= _G.XenoV5.KillAuraRange then
                            hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 1.2)

                            if camera then
                                camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetHrp.Position)
                            end

                            local center = GetScreenCenter()
                            DoMouseClickAt(center.X, center.Y)

                            lastAura = tick()
                            break
                        end
                    end
                end
            end
        end)
    end
end)

-- =========================================================
-- [AUTO FARM COINS LOOP]
-- =========================================================
task.spawn(function()
    while true do
        task.wait(0.5)

        pcall(function()
            if not _G.XenoV5.AutoFarmCoins then
                cachedCoinContainer = nil
                return
            end

            local char = player.Character
            if not char then return end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            if not cachedCoinContainer or not cachedCoinContainer.Parent then
                local normal = workspace:FindFirstChild("Normal")
                cachedCoinContainer = normal and normal:FindFirstChild("CoinContainer")
            end

            if cachedCoinContainer then
                local targetCoin = nil

                for _, c in pairs(cachedCoinContainer:GetChildren()) do
                    if c.Name == "Coin_Server" and c:IsA("BasePart") then
                        targetCoin = c
                        break
                    end
                end

                if targetCoin then
                    local dist = (hrp.Position - targetCoin.Position).Magnitude
                    local tweenTime = math.clamp(dist / 40, 0.1, 5)

                    local tween = TweenService:Create(
                        hrp,
                        TweenInfo.new(tweenTime, Enum.EasingStyle.Linear),
                        {CFrame = targetCoin.CFrame}
                    )

                    tween:Play()
                    tween.Completed:Wait()

                    local playerGui = player:FindFirstChild("PlayerGui")
                    local mainGui = playerGui and playerGui:FindFirstChild("MainGUI")
                    local gameGui = mainGui and mainGui:FindFirstChild("Game")
                    local cashbag = gameGui and gameGui:FindFirstChild("Cashbag")

                    if cashbag then
                        local full = cashbag:FindFirstChild("Full")
                        if full and full.Visible then
                            pcall(function()
                                char:BreakJoints()
                            end)
                        end
                    end
                end
            end
        end)
    end
end)

-- =========================================================
-- [AUTO GRAB GUN LOOP]
-- =========================================================
task.spawn(function()
    while true do
        task.wait(0.25)

        pcall(function()
            if not _G.XenoV5.AutoGrabGun then return end
            if _G.IsTeleporting then return end
            if HasGunAnywhere() then return end

            local char = player.Character
            if not char then return end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            if not cachedGunDrop and tick() - lastGunSearch > 5 then
                lastGunSearch = tick()
                local drop = workspace:FindFirstChild("GunDrop", true)
                if drop then
                    SetCachedGun(drop)
                end
            end

            if cachedGunDrop and cachedGunDrop.Parent then
                local murderer = GetMurderer()
                local isSafe = true

                if murderer and murderer:FindFirstChild("HumanoidRootPart") then
                    local distToGun = (murderer.HumanoidRootPart.Position - cachedGunDrop.Position).Magnitude
                    if distToGun < 10 then
                        isSafe = false
                    end
                end

                if isSafe then
                    _G.IsTeleporting = true

                    local oldPos = hrp.CFrame
                    hrp.CFrame = cachedGunDrop.CFrame + Vector3.new(0, 2, 0)
                    task.wait(0.2)
                    hrp.CFrame = oldPos

                    task.wait(0.5)
                    _G.IsTeleporting = false
                end
            end
        end)
    end
end)

-- =========================================================
-- [CHAT SPAMMER]
-- =========================================================
task.spawn(function()
    while true do
        if _G.XenoV5.ChatSpam then
            pcall(function()
                local chatEvents = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                if chatEvents then
                    local sayEvent = chatEvents:FindFirstChild("SayMessageRequest")
                    if sayEvent then
                        sayEvent:FireServer(_G.XenoV5.SpamText, "All")
                    end
                end
            end)
        end

        task.wait(2.5)
    end
end)

Notify("Injected", "Xeno V5.7 FULL FIX loaded! Press F4 / RightShift to toggle UI.", 5)
