local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Обновление ссылок при респавне
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
end)

local currentState = "Idle"
local flyEnabled = false
local noclipEnabled = false
local godModeActive = false

-- ИНТЕРФЕЙС
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "XenoMenu_V2"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false -- Меню не пропадает после смерти

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 220, 0, 430)
frame.Position = UDim2.new(0.05, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Закругление углов
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

-- Зеленая неоновая обводка
local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(0, 255, 100)
frameStroke.Thickness = 2
frameStroke.Parent = frame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "ROSTICCKK MENU [F3]"
title.TextColor3 = Color3.fromRGB(0, 255, 100)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- КНОПКА ЗАКРЫТИЯ (теперь просто скрывает)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.BackgroundTransparency = 1
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

-- ОТКРЫТИЕ/ЗАКРЫТИЕ НА F3
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F3 then
        frame.Visible = not frame.Visible
    end
end)

-- ФУНКЦИЯ СОЗДАНИЯ КНОПОК
local function createBtn(text, pos, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.85, 0, 0, 35)
    b.Position = UDim2.new(0.075, 0, 0, pos)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    b.TextColor3 = Color3.fromRGB(220, 220, 220)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 12
    b.Parent = frame

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = b

    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(0, 255, 100)
    bStroke.Thickness = 1
    bStroke.Transparency = 0.6
    bStroke.Parent = b

    b.MouseButton1Click:Connect(callback)
    return b
end

-- Кнопки
createBtn("🌪️ ТОРНАДО", 50, function() currentState = "Tornado" end)
createBtn("👥 КЛОН-МОД", 95, function() currentState = "Clone" end)
createBtn("🔄 ВРАЩЕНИЕ", 140, function() currentState = "Spin" end)
createBtn("✈️ ПОЛЕТ (W,A,S,D)", 185, function() flyEnabled = not flyEnabled end)
createBtn("👻 NOCLIP", 230, function() noclipEnabled = not noclipEnabled end)
createBtn("🛡️ GOD MODE", 275, function() 
    godModeActive = not godModeActive
    if godModeActive then 
        humanoid.MaxHealth = math.huge 
        humanoid.Health = math.huge 
    end
end)
createBtn("⚡ СКОРОСТЬ 100", 320, function() humanoid.WalkSpeed = 100 end)
createBtn("🛑 СБРОС", 365, function() 
    currentState = "Idle" 
    flyEnabled = false 
    noclipEnabled = false
    godModeActive = false
    humanoid.WalkSpeed = 16 
    humanoid.MaxHealth = 100
    rootPart.Velocity = Vector3.new(0,0,0)
end)

-- ЛОГИКА РАБОТЫ (Клоны, Полет, Ноклип)
task.spawn(function()
    while true do
        if currentState == "Clone" and rootPart then
            local currentCF = rootPart.CFrame
            rootPart.CFrame = currentCF * CFrame.new(5, 0, 0)
            RunService.RenderStepped:Wait()
            rootPart.CFrame = currentCF
            task.wait(0.02)
        else
            task.wait(0.5)
        end
    end
end)

RunService.Stepped:Connect(function()
    if not character or not rootPart then return end
    
    if currentState == "Spin" then
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(50), 0)
    elseif currentState == "Tornado" then
        local t = tick() * 30
        rootPart.CFrame = rootPart.CFrame * CFrame.new(math.cos(t) * 5, 0, math.sin(t) * 5)
    end
    
    if noclipEnabled or flyEnabled or currentState ~= "Idle" then
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

local bv = Instance.new("BodyVelocity")
local bg = Instance.new("BodyGyro")
bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)

RunService.RenderStepped:Connect(function()
    if flyEnabled and rootPart then
        bv.Parent = rootPart
        bg.Parent = rootPart
        bg.CFrame = workspace.CurrentCamera.CFrame
        local direction = humanoid.MoveDirection
        local up = UserInputService:IsKeyDown(Enum.KeyCode.Space) and 50 or (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and -50 or 0)
        bv.Velocity = (direction * 100) + Vector3.new(0, up, 0)
    else
        bv.Parent = nil
        bg.Parent = nil
    end
    
    if godModeActive and humanoid then
        humanoid.Health = humanoid.MaxHealth
    end
end)
