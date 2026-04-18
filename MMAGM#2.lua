local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

_G.Xeno_Settings = {
    MurdererESP = false,
    SheriffESP = false,
    Aimbot = false,
    TornadoMode = false,
    FlingActive = false
}

local isFlingingNow = false

-- =========================================================
-- [ИНЖЕКТЫ - СЕРВИСНАЯ ЧАСТЬ]
-- =========================================================

local function InjectUltraBot()
    if _G.BotInjected then return end
    _G.BotInjected = true

    -- Ниже идет ТВОЙ оригинальный скрипт бота, я только исправил поиск Убийцы
    local playersService = game:GetService("Players")
    local runService = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")

    local botPlayer = playersService.LocalPlayer
    local char, hum, hrp
    local playerGui = botPlayer:WaitForChild("PlayerGui")

    local baseSpeed = 25 
    local speed = 25     
    local jumpInterval = 3
    local lastJumpTime = tick()
    local currentDirection = Vector3.new(0,0,0)
    local lastPos = Vector3.new(0,0,0)
    local stuckTicks = 0
    local emergencyActive = false
    local descending = false 
    local autoSpaceActive = false 

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

    botBtn.MouseButton1Click:Connect(function() botEnabled = not botEnabled; botBtn.Text = botEnabled and "БОТ: ON" or "БОТ: OFF"; botBtn.BackgroundColor3 = botEnabled and Color3.fromRGB(40, 180, 40) or Color3.fromRGB(60, 120, 255) end)
    setBtn.MouseButton1Click:Connect(function() settingsFrame.Visible = not settingsFrame.Visible; ordersFrame.Visible = false end)
    ordBtn.MouseButton1Click:Connect(function() ordersFrame.Visible = not ordersFrame.Visible; settingsFrame.Visible = false end)
    delBtn.MouseButton1Click:Connect(function() botEnabled = false; gui:Destroy(); _G.BotInjected = false end)
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
    botPlayer.CharacterAdded:Connect(onCharacterAdded)
    if botPlayer.Character then onCharacterAdded(botPlayer.Character) end

    runService.Heartbeat:Connect(function()
        if not botEnabled or not hrp or not hum or hum.Health <= 0 then return end

        if flyToSpace or flyDown or emergencyActive or descending then
            hum:ChangeState(11)
            for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
            hrp.AssemblyLinearVelocity = Vector3.new(0, (flyDown or descending) and -40 or 50, 0)
            
            if autoSpaceActive then
                local distLand = 999
                for _, p in pairs(playersService:GetPlayers()) do
                    if p ~= botPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
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
            for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
            hum:ChangeState(8)

            local target, minDist = nil, 999
            for _, p in pairs(playersService:GetPlayers()) do
                if p ~= botPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    -- ИЗМЕНЕНИЕ ЗДЕСЬ: ИЩЕМ ТОЛЬКО УБИЙЦУ (игрока с ножом)
                    local hasKnife = p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")
                    if hasKnife then
                        local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                        if d < minDist then minDist = d; target = p.Character.HumanoidRootPart end
                    end
                end
            end

            speed = baseSpeed
            if avoidPlayer and target then
                if minDist < 40 then
                    local panicBoost = math.clamp((40 - minDist) * 1.5, 0, 60)
                    speed = baseSpeed + panicBoost
                    alertLabel.Text = "🚨 ПАНИКА! УБИЙЦА: " .. math.floor(minDist) .. " 🚨"
                    alertLabel.Visible = true
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
end

local function InjectTabPlayers()
    if _G.TabInjected then return end
    _G.TabInjected = true

    local UI_COLOR = Color3.fromRGB(15, 15, 15)
    local ACCENT_COLOR = Color3.fromRGB(0, 255, 0)
    local CLOSE_COLOR = Color3.fromRGB(200, 50, 50)

    local sg = Instance.new("ScreenGui")
    sg.Name = "TeleportMenuSystem"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame", sg)
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 250, 0, 320) -- Сделал чуть шире для ролей
    frame.Position = UDim2.new(0.5, -125, 0.5, -160)
    frame.BackgroundColor3 = UI_COLOR
    frame.BorderSizePixel = 0
    frame.Active = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = ACCENT_COLOR; stroke.Thickness = 2

    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1); closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 20
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy(); _G.TabInjected = false end)
    closeBtn.MouseEnter:Connect(function() closeBtn.BackgroundColor3 = CLOSE_COLOR end)
    closeBtn.MouseLeave:Connect(function() closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -40, 0, 40); title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1; title.Text = "TELEPORT (F2)"
    title.TextColor3 = ACCENT_COLOR; title.Font = Enum.Font.GothamBold; title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left

    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, -20, 1, -60); scroll.Position = UDim2.new(0, 10, 0, 45)
    scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 2
    scroll.ScrollBarImageColor3 = ACCENT_COLOR
    local layout = Instance.new("UIListLayout", scroll); layout.Padding = UDim.new(0, 5)

    local function refresh()
        for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                local btn = Instance.new("TextButton", scroll)
                btn.Name = p.Name -- Важно для поиска
                btn.Size = UDim2.new(1, -5, 0, 30)
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                btn.Text = " [?] " .. p.DisplayName
                btn.TextColor3 = Color3.new(1, 1, 1)
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Font = Enum.Font.Gotham; btn.TextSize = 12
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                
                btn.MouseButton1Click:Connect(function()
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and player.Character then
                        player.Character:SetPrimaryPartCFrame(p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                    end
                end)
            end
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.F2 then frame.Visible = not frame.Visible end
    end)

    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dragStart, startPos = true, input.Position, frame.Position end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

    refresh()
    Players.PlayerAdded:Connect(refresh)
    Players.PlayerRemoving:Connect(refresh)

    -- === ДИНАМИЧЕСКОЕ ОБНОВЛЕНИЕ РОЛЕЙ ===
    task.spawn(function()
        while _G.TabInjected and sg and sg.Parent do
            task.wait(0.5)
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player then
                    local btn = scroll:FindFirstChild(p.Name)
                    if btn then
                        local role = "[INNOCENT]"
                        local color = Color3.fromRGB(200, 200, 200)
                        
                        if p.Character then
                            local isM = p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")
                            local isS = p.Character:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun")
                            
                            if isM then
                                role = "[MURDERER]"
                                color = Color3.fromRGB(255, 50, 50)
                            elseif isS then
                                role = "[SHERIFF]"
                                color = Color3.fromRGB(50, 150, 255)
                            end
                        end
                        btn.Text = " " .. role .. " " .. p.DisplayName
                        btn.TextColor3 = color
                    end
                end
            end
        end
    end)
end

-- Логика флинга теперь вшита изначально, кнопка инжекта не нужна
local function ExecuteFling(TargetPlayer)
    if isFlingingNow or not TargetPlayer then return end
    
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local tchar = TargetPlayer.Character
    local thrp = tchar and tchar:FindFirstChild("HumanoidRootPart")

    if hrp and thrp then
        isFlingingNow = true
        local OldPos = hrp.CFrame
        local currentFPDH = workspace.FallenPartsDestroyHeight
        workspace.FallenPartsDestroyHeight = 0/0
        
        local BV = Instance.new("BodyVelocity", hrp)
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        local startTime = tick()
        local angle = 0
        
        -- Цикл атаки 5 секунд
        while tick() - startTime < 5 and _G.Xeno_Settings.FlingActive do
            angle = angle + 100
            hrp.CFrame = thrp.CFrame * CFrame.new(0, 1.5, 0) * CFrame.Angles(math.rad(angle), 0, 0)
            hrp.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RunService.Heartbeat:Wait()
            if not TargetPlayer.Parent or not thrp.Parent then break end
        end

        BV:Destroy()
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.RotVelocity = Vector3.new(0,0,0)
        
        task.wait(0.1)
        hrp.CFrame = OldPos -- Возврат через 5 сек (как просил)
        workspace.FallenPartsDestroyHeight = currentFPDH
        
        task.wait(1)
        isFlingingNow = false
    end
end

-- =========================================================
-- [ИНТЕРФЕЙС XENO V3]
-- =========================================================

local xenoGui = Instance.new("ScreenGui", player.PlayerGui)
xenoGui.Name = "XenoV3_Clean"
xenoGui.ResetOnSpawn = false

local main = Instance.new("Frame", xenoGui)
main.Size = UDim2.new(0, 450, 0, 320)
main.Position = UDim2.new(0.5, -225, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", main).Color = Color3.fromRGB(0, 255, 100)

-- DRAG SYSTEM (Заголовок)
local title = Instance.new("TextButton", main)
title.Size = UDim2.new(1, 0, 0, 40); title.BackgroundTransparency = 1
title.Text = "  ☣️ XENO PREMIUM V3 ☣️"; title.TextColor3 = Color3.fromRGB(0, 255, 100)
title.Font = "GothamBlack"; title.TextXAlignment = "Left"

local dragging, dragStart, startPos
title.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dragStart, startPos = true, i.Position, main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
    local delta = i.Position - dragStart
    main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- КРЕСТИК
local close = Instance.new("TextButton", main)
close.Size = UDim2.new(0, 35, 0, 30); close.Position = UDim2.new(1, -40, 0, 5)
close.Text = "×"; close.BackgroundColor3 = Color3.fromRGB(30, 30, 30); close.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", close); close.MouseButton1Click:Connect(function() xenoGui:Destroy() end)

-- КОНТЕНТ ПО СТРАНИЦАМ
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -125, 1, -50); content.Position = UDim2.new(0, 120, 0, 45); content.BackgroundTransparency = 1
local pages = { Game = Instance.new("ScrollingFrame", content), Inject = Instance.new("ScrollingFrame", content), Power = Instance.new("ScrollingFrame", content) }
for n, p in pairs(pages) do p.Size = UDim2.new(1, 0, 1, 0); p.Visible = (n == "Game"); p.BackgroundTransparency = 1; p.ScrollBarThickness = 0; Instance.new("UIListLayout", p).Padding = UDim.new(0, 8) end

local function createTab(name, icon, y)
    local b = Instance.new("TextButton", main); b.Size = UDim2.new(0, 105, 0, 35); b.Position = UDim2.new(0, 8, 0, y)
    b.Text = icon.." "..name; b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() for _, pg in pairs(pages) do pg.Visible = false end pages[name].Visible = true end)
end
createTab("Game", "🎮", 50); createTab("Inject", "💉", 95); createTab("Power", "⚡", 140)

local function createTgl(name, key, parent)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1, -5, 0, 40); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", b)
    b.Text = "✖️ "..name; b.TextColor3 = Color3.fromRGB(255, 80, 80); b.Font = "GothamBold"
    b.MouseButton1Click:Connect(function()
        _G.Xeno_Settings[key] = not _G.Xeno_Settings[key]
        b.Text = (_G.Xeno_Settings[key] and "✔️ " or "✖️ ")..name
        b.TextColor3 = _G.Xeno_Settings[key] and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 80, 80)
    end)
end

-- ВКЛАДКА GAME
createTgl("Murderer ESP", "MurdererESP", pages.Game)
createTgl("Sheriff ESP", "SheriffESP", pages.Game)
createTgl("Silent Aim", "Aimbot", pages.Game)

-- ВКЛАДКА INJECT
local function injBtn(txt, fn, parent)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1, -5, 0, 40); b.Text = "💉 "..txt; b.BackgroundColor3 = Color3.fromRGB(35,35,35); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(fn)
end
injBtn("INJECT BOT", InjectUltraBot, pages.Inject)
injBtn("INJECT TAB SYSTEM", InjectTabPlayers, pages.Inject)

-- ВКЛАДКА POWER
createTgl("TORNADO SPIN", "TornadoMode", pages.Power)
createTgl("LOOP FLING MURDER", "FlingActive", pages.Power)

-- =========================================================
-- [ОБРАБОТКА ЛОГИКИ]
-- =========================================================
if _G.Xeno_Settings.TornadoMode and murderer and player.Character then

    local hrp = player.Character:FindFirstChild("HumanoidRootPart")

    local mdrRoot = murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart")

    

    if hrp and mdrRoot then

        tornadoAngle = tornadoAngle + 0.15 -- Скорость вращения

        local radius = 18 -- Дистанция от убийцы

        

        -- Вычисляем позицию на круге вокруг маньяка

        local orbitPos = mdrRoot.Position + Vector3.new(

            math.cos(tornadoAngle) * radius, 

            0, 

            math.sin(tornadoAngle) * radius

        )

        

        -- Поворачиваем игрока лицом к маньяку и перемещаем в точку орбиты

        hrp.CFrame = CFrame.lookAt(hrp.Position, mdrRoot.Position)

        hrp.Velocity = (orbitPos - hrp.Position) * 20

    end

end

local tAngle = 0
RunService.RenderStepped:Connect(function()
    local mdr = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local isM = p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")
            local isS = p.Character:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun")
            
            -- ESP (Маньяк и Шериф)
            local h = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character)
            if isM and _G.Xeno_Settings.MurdererESP then 
                h.Enabled = true; h.FillColor = Color3.new(1, 0, 0); mdr = p
            elseif isS and _G.Xeno_Settings.SheriffESP then 
                h.Enabled = true; h.FillColor = Color3.new(0, 0.5, 1)
            else h.Enabled = false end
        end
    end

    -- Silent Aim
    if _G.Xeno_Settings.Aimbot and mdr and player.Character:FindFirstChild("Gun") then
        camera.CFrame = CFrame.new(camera.CFrame.Position, mdr.Character.HumanoidRootPart.Position)
    end

    -- Tornado Mode
    if _G.Xeno_Settings.TornadoMode and mdr and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        tAngle = tAngle + 0.15
        local orbit = mdr.Character.HumanoidRootPart.Position + Vector3.new(math.cos(tAngle)*18, 0, math.sin(tAngle)*18)
        hrp.CFrame = CFrame.lookAt(hrp.Position, mdr.Character.HumanoidRootPart.Position)
        hrp.Velocity = (orbit - hrp.Position) * 20
    end
end)

-- Цикл Авто-Флинга
RunService.Heartbeat:Connect(function()
    if _G.Xeno_Settings.FlingActive and not isFlingingNow then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and (p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")) then
                ExecuteFling(p)
                break
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.F4 then main.Visible = not main.Visible end end)
