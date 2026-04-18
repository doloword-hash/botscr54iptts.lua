local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Header = Instance.new("Frame")
local HeaderCorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local ContentScroll = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local StopAllBtn = Instance.new("TextButton")

-- Настройки GUI 
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "RostickkBS_Menu"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -200)
MainFrame.Size = UDim2.new(0, 250, 0, 450)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainFrame

-- Заголовок 
Header.Name = "Header"
Header.Parent = MainFrame
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BorderSizePixel = 0

HeaderCorner.CornerRadius = UDim.new(0, 15)
HeaderCorner.Parent = Header

Title.Parent = Header
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "ROSTICKK BS" 
Title.TextColor3 = Color3.fromRGB(0, 255, 120)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- Кнопка закрыть (X) 
CloseBtn.Parent = Header
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.TextSize = 25
CloseBtn.BackgroundTransparency = 1
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Кнопка остановки всех скриптов 
StopAllBtn.Parent = MainFrame
StopAllBtn.Position = UDim2.new(0, 10, 0, 45)
StopAllBtn.Size = UDim2.new(1, -20, 0, 30)
StopAllBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
StopAllBtn.Text = "STOP ALL"
StopAllBtn.TextColor3 = Color3.new(1,1,1)
StopAllBtn.Font = Enum.Font.GothamBold
local StopCorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0, 8)
StopCorner.Parent = StopAllBtn

_G.RostickkActive = true
StopAllBtn.MouseButton1Click:Connect(function()
    _G.RostickkActive = false
    print("Все функции Rostickk BS остановлены")
end)

-- Скролл 
ContentScroll.Parent = MainFrame
ContentScroll.Position = UDim2.new(0, 5, 0, 85)
ContentScroll.Size = UDim2.new(1, -10, 1, -95)
ContentScroll.BackgroundTransparency = 1
ContentScroll.ScrollBarThickness = 4
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 900)

UIListLayout.Parent = ContentScroll
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function addFunc(name, code)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = name
    btn.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 8)
    bc.Parent = btn
    btn.Parent = ContentScroll 
    btn.MouseButton1Click:Connect(function()
        _G.RostickkActive = true
        code()
    end)
end

-- --- СПИСОК ФУНКЦИЙ ---

addFunc("1. Вертолет (Паранойя)", function() 
    while _G.RostickkActive do
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(45), 0)
        task.wait()
    end
end)

addFunc("2. Неоновое тело (FIX)", function()
    local char = game.Players.LocalPlayer.Character
    local neonPart = Instance.new("Part")
    neonPart.Name = "NeonGlow"
    neonPart.Size = Vector3.new(2, 2, 1)
    neonPart.Material = Enum.Material.Neon
    neonPart.Color = Color3.fromRGB(0, 255, 120)
    neonPart.CanCollide = false
    neonPart.Parent = char
    local weld = Instance.new("Weld")
    weld.Part0 = char.HumanoidRootPart
    weld.Part1 = neonPart
    weld.Parent = neonPart
end)

addFunc("3. Огромная голова (ORB FIX)", function()
    local head = game.Players.LocalPlayer.Character:FindFirstChild("Head")
    if head then
        local orb = Instance.new("Part", head)
        orb.Shape = Enum.PartType.Ball
        orb.Size = Vector3.new(10, 10, 10)
        orb.CanCollide = false
        local weld = Instance.new("Weld", orb)
        weld.Part0 = head
        weld.Part1 = orb
    end
end)

addFunc("4. Растянуть шляпы", function()
    for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
        if v:IsA("SpecialMesh") and v.Parent.Name ~= "Head" then
            v.Scale *= Vector3.new(1, 5, 1)
        end
    end
end)

addFunc("5. Уйти в пол", function()
    game.Players.LocalPlayer.Character.Humanoid.HipHeight = -1.5
end)

addFunc("6. Высокий рост (STRETCH FIX)", function()
    local char = game.Players.LocalPlayer.Character
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            v.Size *= Vector3.new(1, 3, 1)
        end
    end
end)

addFunc("7. Сломанная шея", function() 
    game.Players.LocalPlayer.Character.Head.Neck.C0 *= CFrame.Angles(1.5, 0, 0)
end)

addFunc("8. Мун волк (Moonwalk)", function()
    local player = game.Players.LocalPlayer
    game:GetService("RunService").RenderStepped:Connect(function()
        if _G.RostickkActive and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if player.Character.Humanoid.MoveDirection.Magnitude > 0 then
                player.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(180), 0)
            end
        end
    end)
end)

addFunc("9. Прозрачность 50%", function()
    for _, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if v:IsA("BasePart") then v.Transparency = 0.5 end
    end
end)

addFunc("10. Синее небо", function()
    game.Lighting.Ambient = Color3.new(0, 0, 1)
end)

addFunc("11. Удалить аксессуары", function()
    for _, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if v:IsA("Accessory") then v:Destroy() end
    end
end)

addFunc("12. Танец на голове", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.Angles(math.rad(180), 0, 0)
end)

addFunc("13. Прыгающий интерфейс", function()
    while _G.RostickkActive do
        MainFrame.Position = MainFrame.Position + UDim2.new(0, math.random(-5,5), 0, math.random(-5,5))
        task.wait(0.1)
    end
end)

addFunc("14. Убрать текстуры мира", function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end
    end
end)

addFunc("15. Чёрная кожа", function()
    for _, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if v:IsA("BasePart") then v.Color = Color3.new(0,0,0) end
    end
end)

addFunc("16. Ускорить анимации (FIX)", function()
    local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, track in pairs(hum:GetPlayingAnimationTracks()) do
            track:AdjustSpeed(5)
        end
    end
end)

addFunc("17. Режим 'Призрак' (FIX)", function()
    game:GetService("RunService").Stepped:Connect(function()
        if _G.RostickkActive then
            for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)
end)

addFunc("18. Диско-небо", function()
    while _G.RostickkActive do
        game.Lighting.OutdoorAmbient = Color3.new(math.random(), math.random(), math.random())
        task.wait(0.2)
    end
end)

addFunc("19. Длинная рука", function()
    local arm = game.Players.LocalPlayer.Character:FindFirstChild("Right Arm") or game.Players.LocalPlayer.Character:FindFirstChild("RightUpperArm")
    if arm then arm.Size *= Vector3.new(1, 3, 1) end
end)

addFunc("20. Танцующая камера", function() 
    while _G.RostickkActive do
        workspace.CurrentCamera.FieldOfView = math.random(70, 110)
        task.wait(0.1)
    end
end)
