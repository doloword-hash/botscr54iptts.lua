local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local noclipConnections = {}

-- Функция управления ноуклипом
local function setNoclip(player, state)
    if state then
        if noclipConnections[player.UserId] then noclipConnections[player.UserId]:Disconnect() end
        
        noclipConnections[player.UserId] = RunService.Stepped:Connect(function()
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnections[player.UserId] then
            noclipConnections[player.UserId]:Disconnect()
            noclipConnections[player.UserId] = nil
        end
    end
end

local function createNoclipBtn(player)
    local sg = Instance.new("ScreenGui")
    sg.Name = "SmartNoclip_V5"
    sg.ResetOnSpawn = false
    sg.Parent = player:WaitForChild("PlayerGui")

    -- Контейнер для кнопок (чтобы они двигались вместе)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 130, 0, 80)
    container.Position = UDim2.new(1, 0, 0.25, 0)
    container.AnchorPoint = Vector2.new(1, 0.5)
    container.BackgroundTransparency = 1
    container.Parent = sg

    -- Маленькая кнопка закрытия (Крестик)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -5, 0, 0) -- Сверху справа
    closeBtn.AnchorPoint = Vector2.new(1, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(20, 10, 10)
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = container

    local closeCorner = Instance.new("UICorner", closeBtn)
    closeCorner.CornerRadius = UDim.new(0, 6)
    
    local closeStroke = Instance.new("UIStroke", closeBtn)
    closeStroke.Color = Color3.fromRGB(255, 50, 50)
    closeStroke.Transparency = 0.6

    -- Основная кнопка Noclip
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.Position = UDim2.new(0, 0, 1, 0)
    btn.AnchorPoint = Vector2.new(0, 1) -- Прижата к низу контейнера
    btn.BackgroundColor3 = Color3.fromRGB(15, 20, 15)
    btn.BackgroundTransparency = 0.2
    btn.Text = "NOCLIP: OFF"
    btn.TextColor3 = Color3.fromRGB(255, 80, 80)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = container

    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 10)

    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Thickness = 2
    btnStroke.Color = Color3.fromRGB(255, 80, 80)
    btnStroke.Transparency = 0.5

    local active = false

    -- Логика кнопки Noclip
    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            btn.Text = "NOCLIP: ON"
            btn.TextColor3 = Color3.fromRGB(0, 255, 120)
            btnStroke.Color = Color3.fromRGB(0, 255, 120)
            setNoclip(player, true)
        else
            btn.Text = "NOCLIP: OFF"
            btn.TextColor3 = Color3.fromRGB(255, 80, 80)
            btnStroke.Color = Color3.fromRGB(255, 80, 80)
            setNoclip(player, false)
        end
    end)

    -- Логика удаления GUI
    closeBtn.MouseButton1Click:Connect(function()
        setNoclip(player, false) -- На всякий случай выключаем ноуклип перед удалением
        sg:Destroy()
    end)

    -- Анимации наведения для крестика
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1, TextColor3 = Color3.new(1, 0, 0)}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3, TextColor3 = Color3.fromRGB(255, 50, 50)}):Play()
    end)
end

Players.PlayerAdded:Connect(createNoclipBtn)
Players.PlayerRemoving:Connect(function(p) setNoclip(p, false) end)

for _, player in pairs(Players:GetPlayers()) do
    createNoclipBtn(player)
end
