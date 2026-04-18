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
local function InjectTabPlayers()
    if _G.TabInjected then return end
    _G.TabInjected = true
    loadstring(game:HttpGet("https://raw.githubusercontent.com/doloword-hash/botscr54iptts.lua/refs/heads/main/Inject1.lua"))()

local function InjectUltraBot()
    if _G.BotInjected then return end
    _G.BotInjected = true
    loadstring(game:HttpGet("https://raw.githubusercontent.com/doloword-hash/botscr54iptts.lua/refs/heads/main/Inject2.lua"))()

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
