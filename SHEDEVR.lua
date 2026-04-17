local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local currentState = "Idle"
local flyEnabled = false
local noclipEnabled = false
local godModeActive = false

-- UI Настройка
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "XenoMenu_Final"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 220, 0, 420) -- Увеличил высоту под все кнопки
frame.Position = UDim2.new(0.05, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
frame.Draggable = true
frame.Active = true

-- КНОПКА ЗАКРЫТИЯ
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextSize = 25
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
closeBtn.BorderSizePixel = 0
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local function createBtn(text, pos, callback)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.Position = UDim2.new(0.05, 0, 0, pos)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14
    b.MouseButton1Click:Connect(callback)
    return b
end

-- Кнопки управления
createBtn("РЕЖИМ: ТОРНАДО", 45, function() currentState = "Tornado" end)
createBtn("РЕЖИМ: КЛОН (0.02 сек)", 90, function() currentState = "Clone" end)
createBtn("РЕЖИМ: ВРАЩЕНИЕ", 135, function() currentState = "Spin" end)
createBtn("ПОЛЕТ (W,A,S,D)", 180, function() flyEnabled = not flyEnabled end)
createBtn("NOCLIP: ВКЛ/ВЫКЛ", 225, function() noclipEnabled = not noclipEnabled end)
createBtn("GOD MODE (Бессмертие)", 270, function() 
    godModeActive = not godModeActive
    if godModeActive then 
        humanoid.MaxHealth = 1e8 
        humanoid.Health = 1e8 
    end
end)
createBtn("СКОРОСТЬ: 100", 315, function() humanoid.WalkSpeed = 100 end)
createBtn("СТОП / СБРОС", 360, function() 
    currentState = "Idle" 
    flyEnabled = false 
    noclipEnabled = false
    godModeActive = false
    humanoid.WalkSpeed = 16 
    humanoid.MaxHealth = 100
    rootPart.RotVelocity = Vector3.new(0,0,0)
    rootPart.Velocity = Vector3.new(0,0,0)
end)

-- ЛОГИКА КЛОНА (0.02)
task.spawn(function()
    while true do
        if currentState == "Clone" then
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

-- ГЛАВНЫЙ ЦИКЛ (Вращение, Торнадо, Ноклип)
RunService.Stepped:Connect(function()
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

-- ЛОГИКА ПОЛЕТА
local bv = Instance.new("BodyVelocity")
local bg = Instance.new("BodyGyro")
bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)

RunService.RenderStepped:Connect(function()
    if flyEnabled then
        bv.Parent = rootPart
        bg.Parent = rootPart
        bg.CFrame = workspace.CurrentCamera.CFrame
        local direction = humanoid.MoveDirection
        local upVelocity = UserInputService:IsKeyDown(Enum.KeyCode.Space) and 50 or (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and -50 or 0)
        bv.Velocity = (direction * 100) + Vector3.new(0, upVelocity, 0)
    else
        bv.Parent = nil
        bg.Parent = nil
    end
end)

-- ЛОГИКА БЕССМЕРТИЯ (GOD MODE)
humanoid.HealthChanged:Connect(function()
    if godModeActive then
        humanoid.Health = humanoid.MaxHealth
    end
end)
