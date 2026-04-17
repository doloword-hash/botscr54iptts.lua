local playersService = game:GetService("Players")
local runService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = playersService.LocalPlayer
local char, hum, hrp
local playerGui = player:WaitForChild("PlayerGui")

-- --- НАСТРОЙКИ ---
local baseSpeed = 25 -- Базовая скорость из слайдера
local speed = 25     -- Текущая скорость (с учетом паники)
local jumpInterval = 3
local lastJumpTime = tick()
local currentDirection = Vector3.new(0,0,0)
local lastPos = Vector3.new(0,0,0)
local stuckTicks = 0
local emergencyActive = false
local descending = false 
local autoSpaceActive = false -- Флаг автоматического взлета

-- --- СОСТОЯНИЯ ---
local botEnabled, moveToPlayer, avoidPlayer, flyToSpace, flyDown, autoJumpEnabled = false, false, false, false, false, false
local showRays = false 
local explorerMode = false
local explorerTurnCooldown = 0
local wallMemory = {L = false, R = false}

local visibleWhiskerAngles = {
    {name = "MainCenter", angle = 0, dist = 12},
    {name = "LeftDiag", angle = 45, dist = 9},
    {name = "RightDiag", angle = -45, dist = 9},
    {name = "LeftWall", angle = 90, dist = 7},
    {name = "RightWall", angle = -90, dist = 7},
}

-- --- GUI ---
local gui = playerGui:FindFirstChild("Bot_Ultra_V16_5") or Instance.new("ScreenGui", playerGui)
gui.Name = "Bot_Ultra_V16_5"; gui.ResetOnSpawn = false

local alertLabel = gui:FindFirstChild("Alert") or Instance.new("TextLabel", gui)
alertLabel.Name = "Alert"; alertLabel.Size = UDim2.new(0, 400, 0, 60); alertLabel.Position = UDim2.new(0.5, -200, 0.15, 0)
alertLabel.BackgroundColor3 = Color3.new(0,0,0); alertLabel.BackgroundTransparency = 0.4; alertLabel.TextColor3 = Color3.new(1,0,0)
alertLabel.Font = "GothamBold"; alertLabel.TextSize = 25; alertLabel.Visible = false
if not alertLabel:FindFirstChild("UICorner") then Instance.new("UICorner", alertLabel) end

local function makeFrame(size, pos, color)
    local f = Instance.new("Frame", gui); f.Size = size; f.Position = pos; f.BackgroundColor3 = color; f.Visible = false
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10); return f
end

local function makeButton(text, color, parent)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(0.9, 0, 0, 32); b.BackgroundColor3 = color; b.Text = text; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 10
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8); return b
end

-- Панели
local mainFrame = makeFrame(UDim2.new(0, 180, 0, 185), UDim2.new(1, -200, 0.4, 0), Color3.fromRGB(20, 20, 20)); mainFrame.Visible = true
local mainLayout = Instance.new("UIListLayout", mainFrame); mainLayout.Padding = UDim.new(0, 5); mainLayout.HorizontalAlignment = "Center"; mainLayout.VerticalAlignment = "Center"

local botBtn = makeButton("БОТ: OFF", Color3.fromRGB(60, 120, 255), mainFrame)
local setBtn = makeButton("НАСТРОЙКИ", Color3.fromRGB(100, 100, 100), mainFrame)
local ordBtn = makeButton("ПРИКАЗЫ", Color3.fromRGB(150, 80, 200), mainFrame)
local delBtn = makeButton("УДАЛИТЬ", Color3.fromRGB(200, 50, 50), mainFrame)

local ordersFrame = makeFrame(UDim2.new(0, 200, 0, 260), UDim2.new(0.5, -100, 0.25, 0), Color3.fromRGB(30, 30, 30))
local ordLayout = Instance.new("UIListLayout", ordersFrame); ordLayout.Padding = UDim.new(0, 6); ordLayout.HorizontalAlignment = "Center"; ordLayout.VerticalAlignment = "Center"

local followBtn = makeButton("К игроку: OFF", Color3.fromRGB(60, 60, 60), ordersFrame)
local avoidBtn = makeButton("Убегать: OFF", Color3.fromRGB(60, 60, 60), ordersFrame)
local jumpBtn = makeButton("Авто-прыжок: OFF", Color3.fromRGB(60, 60, 60), ordersFrame)
local explorerBtn = makeButton("Исследователь: OFF", Color3.fromRGB(40, 100, 100), ordersFrame)
local spaceBtn = makeButton("В КОСМОС: OFF", Color3.fromRGB(0, 100, 200), ordersFrame)
local downBtn = makeButton("В НЕДРА: OFF", Color3.fromRGB(150, 50, 0), ordersFrame)

local settingsFrame = makeFrame(UDim2.new(0, 220, 0, 200), UDim2.new(0.5, -110, 0.3, 0), Color3.fromRGB(35, 35, 35))
local setLayout = Instance.new("UIListLayout", settingsFrame); setLayout.Padding = UDim.new(0, 5); setLayout.HorizontalAlignment = "Center"; setLayout.VerticalAlignment = "Center"

local function createSlider(name, min, max, default, parent, callback)
    local container = Instance.new("Frame", parent); container.Size = UDim2.new(0.9, 0, 0, 45); container.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", container); label.Size = UDim2.new(1, 0, 0, 20); label.BackgroundTransparency = 1; label.TextColor3 = Color3.new(1,1,1); label.Font = "GothamBold"; label.Text = name .. ": " .. default; label.TextSize = 10
    local bg = Instance.new("Frame", container); bg.Size = UDim2.new(0.9, 0, 0, 5); bg.Position = UDim2.new(0.05, 0, 0.7, 0); bg.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1); Instance.new("UICorner", bg)
    local fill = Instance.new("Frame", bg); fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(60, 120, 255); Instance.new("UICorner", fill)
    local btn = Instance.new("TextButton", bg); btn.Size = UDim2.new(0, 12, 0, 12); btn.Position = UDim2.new((default-min)/(max-min), -6, 0.5, -6); btn.Text = ""; Instance.new("UICorner", btn, {CornerRadius = UDim.new(1,0)})
    
    local drag = false
    btn.MouseButton1Down:Connect(function() drag = true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
    UIS.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
        local percent = math.clamp((UIS:GetMouseLocation().X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (percent * (max - min))); fill.Size = UDim2.new(percent, 0, 1, 0); btn.Position = UDim2.new(percent, -6, 0.5, -6); label.Text = name .. ": " .. val; callback(val)
    end end)
end

createSlider("СКОРОСТЬ", 1, 100, baseSpeed, settingsFrame, function(v) baseSpeed = v end)
createSlider("ЧАСТОТА ПРЫЖКА", 1, 15, jumpInterval, settingsFrame, function(v) jumpInterval = v end)
local rayBtn = makeButton("ЛАЗЕРЫ: OFF", Color3.fromRGB(60, 60, 60), settingsFrame)

-- Функции кнопок
botBtn.MouseButton1Click:Connect(function() botEnabled = not botEnabled; botBtn.Text = botEnabled and "БОТ: ON" or "БОТ: OFF"; botBtn.BackgroundColor3 = botEnabled and Color3.fromRGB(40, 180, 40) or Color3.fromRGB(60, 120, 255) end)
setBtn.MouseButton1Click:Connect(function() settingsFrame.Visible = not settingsFrame.Visible; ordersFrame.Visible = false end)
ordBtn.MouseButton1Click:Connect(function() ordersFrame.Visible = not ordersFrame.Visible; settingsFrame.Visible = false end)
delBtn.MouseButton1Click:Connect(function() botEnabled = false; gui:Destroy() end)
jumpBtn.MouseButton1Click:Connect(function() autoJumpEnabled = not autoJumpEnabled; jumpBtn.Text = autoJumpEnabled and "Авто-прыжок: ON" or "Авто-прыжок: OFF"; jumpBtn.BackgroundColor3 = autoJumpEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(60, 60, 60) end)
explorerBtn.MouseButton1Click:Connect(function() explorerMode = not explorerMode; explorerBtn.Text = explorerMode and "Исследователь: ON" or "Исследователь: OFF" end)
followBtn.MouseButton1Click:Connect(function() moveToPlayer = not moveToPlayer; avoidPlayer = false; followBtn.Text = moveToPlayer and "К игроку: ON" or "К игроку: OFF"; avoidBtn.Text = "Убегать: OFF" end)
avoidBtn.MouseButton1Click:Connect(function() avoidPlayer = not avoidPlayer; moveToPlayer = false; avoidBtn.Text = avoidPlayer and "Убегать: ON" or "Убегать: OFF"; followBtn.Text = "К игроку: OFF" end)
rayBtn.MouseButton1Click:Connect(function() showRays = not showRays; rayBtn.Text = showRays and "ЛАЗЕРЫ: ON" or "ЛАЗЕРЫ: OFF" end)
spaceBtn.MouseButton1Click:Connect(function() flyToSpace = not flyToSpace; flyDown = false; spaceBtn.Text = flyToSpace and "В КОСМОС: ON" or "В КОСМОС: OFF" end)
downBtn.MouseButton1Click:Connect(function() flyDown = not flyDown; flyToSpace = false; downBtn.Text = flyDown and "В НЕДРА: ON" or "В НЕДРА: OFF" end)

local function getLaser(name)
    if not hrp then return nil end
    local b = hrp:FindFirstChild(name) or Instance.new("Beam", hrp)
    b.Name = name; b.Width0, b.Width1 = 0.05, 0.05; b.FaceCamera = true; b.Texture = "rbxassetid://4034441"
    if not b.Attachment0 then
        local a0, a1 = Instance.new("Attachment", hrp), Instance.new("Attachment", hrp)
        a0.Name = name.."A0"; a1.Name = name.."A1"; b.Attachment0, b.Attachment1 = a0, a1
    end
    return b
end

local function onCharacterAdded(newChar)
    char = newChar; hum = char:WaitForChild("Humanoid"); hrp = char:WaitForChild("HumanoidRootPart")
    currentDirection = hrp.CFrame.LookVector; lastPos = hrp.Position
end
player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then onCharacterAdded(player.Character) end

-- --- ГЛАВНЫЙ ЦИКЛ ---
runService.Heartbeat:Connect(function()
    if not botEnabled or not hrp or not hum or hum.Health <= 0 then return end

    if flyToSpace or flyDown or emergencyActive or descending then
        hum:ChangeState(11)
        for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        hrp.AssemblyLinearVelocity = Vector3.new(0, (flyDown or descending) and -40 or 50, 0)
        
        -- Если авто-взлет активен, проверяем дистанцию для приземления
        if autoSpaceActive then
            local targetLand, distLand = nil, 999
            for _, p in pairs(playersService:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if d < distLand then distLand = d end
                end
            end
            if distLand > 25 then 
                autoSpaceActive = false; flyToSpace = false; descending = true 
                alertLabel.Visible = false
            end
        end

        if descending and workspace:Raycast(hrp.Position, Vector3.new(0, -6, 0)) then descending = false end
    else
        -- ОБЫЧНЫЙ РЕЖИМ
        for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
        hum:ChangeState(8)

        local target, minDist = nil, 999
        for _, p in pairs(playersService:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                if d < minDist then minDist = d; target = p.Character.HumanoidRootPart end
            end
        end

        -- ЛОГИКА ПАНИКИ И УБЕГАНИЯ
        speed = baseSpeed
        if avoidPlayer and target then
            if minDist < 40 then
                -- Плавное ускорение: чем ближе, тем быстрее (+ до 50 к скорости)
                local panicBoost = math.clamp((40 - minDist) * 1.5, 0, 60)
                speed = baseSpeed + panicBoost
                alertLabel.Text = "🚨 ПАНИКА! ДИСТАНЦИЯ: " .. math.floor(minDist) .. " 🚨"
                alertLabel.Visible = true
                
                -- Автоматический взлет при критической близости
                if minDist < 8 then
                    autoSpaceActive = true
                    flyToSpace = true
                end
            else
                alertLabel.Visible = false
            end
        end

        local wishDir = currentDirection
        if moveToPlayer and target then wishDir = (target.Position - hrp.Position).Unit
        elseif avoidPlayer and target and minDist < 40 then wishDir = (hrp.Position - target.Position).Unit end

        -- ОБХОД ПРЕПЯТСТВИЙ
        local rayParams = RaycastParams.new(); rayParams.FilterDescendantsInstances = {char}
        local turnWeight, hitAny, sideHits = 0, false, {L = false, R = false}

        local kneeRay = workspace:Raycast(hrp.Position + Vector3.new(0,-1,0), currentDirection * 6, rayParams)
        local headRay = workspace:Raycast(hrp.Position + Vector3.new(0, 2, 0), currentDirection * 6, rayParams)
        if kneeRay and not headRay then hum:ChangeState(Enum.HumanoidStateType.Jumping) end

        for _, cfg in ipairs(visibleWhiskerAngles) do
            local laser = getLaser(cfg.name)
            local origin = hrp.Position + Vector3.new(0, 1.5, 0)
            local dir = (CFrame.new(Vector3.zero, currentDirection) * CFrame.Angles(0, math.rad(cfg.angle), 0)).LookVector
            local ray = workspace:Raycast(origin, dir * cfg.dist, rayParams)

            if ray then
                hitAny = true
                if math.abs(cfg.angle) <= 45 then turnWeight = turnWeight + (cfg.angle >= 0 and -1.2 or 1.2) end
                if cfg.angle > 45 then sideHits.L = true elseif cfg.angle < -45 then sideHits.R = true end
            end

            if laser then
                laser.Enabled = showRays; laser.Attachment0.WorldPosition = origin
                if ray then 
                    laser.Attachment1.WorldPosition = ray.Position; laser.Color = ColorSequence.new(Color3.new(1,0,0))
                else 
                    laser.Attachment1.WorldPosition = origin + dir * cfg.dist; laser.Color = ColorSequence.new(Color3.new(0,1,0))
                end
            end
        end

        if hitAny then
            wishDir = (CFrame.new(Vector3.zero, currentDirection) * CFrame.Angles(0, math.rad(turnWeight * 40), 0)).LookVector
        elseif explorerMode and tick() > explorerTurnCooldown then
            if wallMemory.L and not sideHits.L then wishDir = (CFrame.new(Vector3.zero, currentDirection) * CFrame.Angles(0, math.rad(90), 0)).LookVector; explorerTurnCooldown = tick() + 0.6
            elseif wallMemory.R and not sideHits.R then wishDir = (CFrame.new(Vector3.zero, currentDirection) * CFrame.Angles(0, math.rad(-90), 0)).LookVector; explorerTurnCooldown = tick() + 0.6 end
        end

        wallMemory = sideHits; currentDirection = currentDirection:Lerp(wishDir, 0.15).Unit

        if autoJumpEnabled and tick() - lastJumpTime > jumpInterval then
            hum:ChangeState(Enum.HumanoidStateType.Jumping); lastJumpTime = tick()
        end

        hrp.AssemblyLinearVelocity = Vector3.new(currentDirection.X * speed, hrp.AssemblyLinearVelocity.Y, currentDirection.Z * speed)
        hrp.CFrame = hrp.CFrame:Lerp(CFrame.lookAt(hrp.Position, hrp.Position + Vector3.new(currentDirection.X, 0, currentDirection.Z)), 0.2)
    end
end)
