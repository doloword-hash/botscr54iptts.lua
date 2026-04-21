--[[
    KILASIK's Multi-Target Fling Exploit (MM2 MOD + BEAUTIFUL UI)
    Features: Fling, MM2 Auto-Target, UICorners, UIStrokes, Image Background
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KilasikFlingGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 440)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -220)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Красивые углы и зелёная обводка для MainFrame
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 255, 127) -- Неоновый зелёный
MainStroke.Thickness = 2
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Фоновая картинка (Водяной знак)
local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.Image = "rbxassetid://6031097225" -- Можешь поменять ID на свой
BackgroundImage.ImageTransparency = 0.85 -- Полупрозрачность
BackgroundImage.ScaleType = Enum.ScaleType.Fit
BackgroundImage.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "NAVALNIY MM2 V5"
Title.TextColor3 = Color3.fromRGB(0, 255, 127)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = TitleBar
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 6)

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.new(0, 15, 0, 45)
StatusLabel.Size = UDim2.new(1, -30, 0, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Select targets to fling"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 14
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Player Selection Frame
local SelectionFrame = Instance.new("Frame")
SelectionFrame.Position = UDim2.new(0, 15, 0, 75)
SelectionFrame.Size = UDim2.new(1, -30, 0, 190)
SelectionFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SelectionFrame.BorderSizePixel = 0
SelectionFrame.Parent = MainFrame
Instance.new("UICorner", SelectionFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", SelectionFrame).Color = Color3.fromRGB(60, 60, 60)

-- Player List ScrollFrame
local PlayerScrollFrame = Instance.new("ScrollingFrame")
PlayerScrollFrame.Position = UDim2.new(0, 5, 0, 5)
PlayerScrollFrame.Size = UDim2.new(1, -10, 1, -10)
PlayerScrollFrame.BackgroundTransparency = 1
PlayerScrollFrame.BorderSizePixel = 0
PlayerScrollFrame.ScrollBarThickness = 4
PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScrollFrame.Parent = SelectionFrame

-- --- Функция создания красивых кнопок ---
local function CreateButton(name, pos, size, text, color, parent)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Position = pos
    btn.Size = size
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = parent
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

-- Кнопки управления
local StartButton = CreateButton("StartBtn", UDim2.new(0, 15, 0, 275), UDim2.new(0.5, -20, 0, 35), "START FLING", Color3.fromRGB(0, 150, 80), MainFrame)
local StopButton = CreateButton("StopBtn", UDim2.new(0.5, 5, 0, 275), UDim2.new(0.5, -20, 0, 35), "STOP FLING", Color3.fromRGB(180, 40, 40), MainFrame)

local FlingMurdererButton = CreateButton("MurdBtn", UDim2.new(0, 15, 0, 320), UDim2.new(0.5, -20, 0, 35), "FLING MURDER", Color3.fromRGB(130, 0, 130), MainFrame)
local FlingSheriffButton = CreateButton("SherBtn", UDim2.new(0.5, 5, 0, 320), UDim2.new(0.5, -20, 0, 35), "FLING SHERIFF", Color3.fromRGB(0, 100, 200), MainFrame)

local SelectAllButton = CreateButton("SelAllBtn", UDim2.new(0, 15, 0, 365), UDim2.new(0.5, -20, 0, 25), "SELECT ALL", Color3.fromRGB(60, 60, 60), MainFrame)
local DeselectAllButton = CreateButton("DesAllBtn", UDim2.new(0.5, 5, 0, 365), UDim2.new(0.5, -20, 0, 25), "DESELECT ALL", Color3.fromRGB(60, 60, 60), MainFrame)

-- Variables
local SelectedTargets = {}
local PlayerCheckboxes = {}
local FlingActive = false
getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

-- Функции логики (Оставлены без изменений для стабильности)
local function RefreshPlayerList()
    for _, child in pairs(PlayerScrollFrame:GetChildren()) do child:Destroy() end
    PlayerCheckboxes = {}
    
    local PlayerList = Players:GetPlayers()
    table.sort(PlayerList, function(a, b) return a.Name:lower() < b.Name:lower() end)
    
    local yPosition = 0
    for _, player in ipairs(PlayerList) do
        if player ~= Player then
            local PlayerEntry = Instance.new("Frame")
            PlayerEntry.Size = UDim2.new(1, -5, 0, 30)
            PlayerEntry.Position = UDim2.new(0, 0, 0, yPosition)
            PlayerEntry.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            PlayerEntry.Parent = PlayerScrollFrame
            Instance.new("UICorner", PlayerEntry).CornerRadius = UDim.new(0, 4)
            
            local Checkbox = Instance.new("TextButton")
            Checkbox.Size = UDim2.new(0, 20, 0, 20)
            Checkbox.Position = UDim2.new(0, 5, 0.5, -10)
            Checkbox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            Checkbox.Text = ""
            Checkbox.Parent = PlayerEntry
            Instance.new("UICorner", Checkbox).CornerRadius = UDim.new(0, 4)
            
            local Checkmark = Instance.new("TextLabel")
            Checkmark.Size = UDim2.new(1, 0, 1, 0)
            Checkmark.BackgroundTransparency = 1
            Checkmark.Text = "✓"
            Checkmark.TextColor3 = Color3.fromRGB(0, 255, 127)
            Checkmark.TextSize = 16
            Checkmark.Font = Enum.Font.GothamBold
            Checkmark.Visible = SelectedTargets[player.Name] ~= nil
            Checkmark.Parent = Checkbox
            
            local NameLabel = Instance.new("TextLabel")
            NameLabel.Size = UDim2.new(1, -35, 1, 0)
            NameLabel.Position = UDim2.new(0, 35, 0, 0)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Text = player.Name
            NameLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
            NameLabel.TextSize = 13
            NameLabel.Font = Enum.Font.Gotham
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.Parent = PlayerEntry
            
            local ClickArea = Instance.new("TextButton")
            ClickArea.Size = UDim2.new(1, 0, 1, 0)
            ClickArea.BackgroundTransparency = 1
            ClickArea.Text = ""
            ClickArea.ZIndex = 2
            ClickArea.Parent = PlayerEntry
            
            ClickArea.MouseButton1Click:Connect(function()
                if SelectedTargets[player.Name] then
                    SelectedTargets[player.Name] = nil
                    Checkmark.Visible = false
                else
                    SelectedTargets[player.Name] = player
                    Checkmark.Visible = true
                end
                UpdateStatus()
            end)
            
            PlayerCheckboxes[player.Name] = { Entry = PlayerEntry, Checkmark = Checkmark }
            yPosition = yPosition + 35
        end
    end
    PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition)
end

function UpdateStatus()
    local count = 0
    for _ in pairs(SelectedTargets) do count = count + 1 end
    if FlingActive then
        StatusLabel.Text = "Flinging " .. count .. " target(s)"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
    else
        StatusLabel.Text = count .. " target(s) selected" 
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

local function ToggleAllPlayers(select)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player then
            local box = PlayerCheckboxes[player.Name]
            if box then
                if select then
                    SelectedTargets[player.Name] = player
                    box.Checkmark.Visible = true
                else
                    SelectedTargets[player.Name] = nil
                    box.Checkmark.Visible = false
                end
            end
        end
    end
    UpdateStatus()
end

local function Message(Title, Text, Time)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = Title, Text = Text, Duration = Time or 5})
end

local function SkidFling(TargetPlayer)
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end
    
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")

    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then getgenv().OldPos = RootPart.CFrame end
        if THumanoid and THumanoid.Sit then return end
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end
        
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        
        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                end
            until Time + TimeToWait < tick() or not FlingActive
        end
        
        workspace.FallenPartsDestroyHeight = 0/0
        local BV = Instance.new("BodyVelocity", RootPart)
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        
        if TRootPart then SFBasePart(TRootPart)
        elseif THead then SFBasePart(THead)
        elseif Handle then SFBasePart(Handle) end
        
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        
        if getgenv().OldPos then
            repeat
                RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                Humanoid:ChangeState("GettingUp")
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new() end
                end
                task.wait()
            until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
            workspace.FallenPartsDestroyHeight = getgenv().FPDH
        end
    end
end

local function StartFling()
    if FlingActive then return end
    local count = 0 for _ in pairs(SelectedTargets) do count = count + 1 end
    if count == 0 then return end
    
    FlingActive = true
    UpdateStatus()
    spawn(function()
        while FlingActive do
            local validTargets = {}
            for name, player in pairs(SelectedTargets) do
                if player and player.Parent then validTargets[name] = player else SelectedTargets[name] = nil end
            end
            for _, player in pairs(validTargets) do
                if FlingActive then SkidFling(player) task.wait(0.1) else break end
            end
            task.wait(0.5)
        end
    end)
end

local function StopFling()
    FlingActive = false
    UpdateStatus()
end

local function FindAndFlingRole(roleItems)
    ToggleAllPlayers(false)
    local found = false
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player then
            local bp = player:FindFirstChild("Backpack")
            local char = player.Character
            for _, item in ipairs(roleItems) do
                if (bp and bp:FindFirstChild(item)) or (char and char:FindFirstChild(item)) then
                    SelectedTargets[player.Name] = player
                    if PlayerCheckboxes[player.Name] then PlayerCheckboxes[player.Name].Checkmark.Visible = true end
                    found = true
                end
            end
        end
    end
    UpdateStatus()
    if found then StartFling() else Message("Not Found", "Target not found!", 3) end
end

-- Обработчики кнопок
StartButton.MouseButton1Click:Connect(StartFling)
StopButton.MouseButton1Click:Connect(StopFling)
FlingMurdererButton.MouseButton1Click:Connect(function() FindAndFlingRole({"Knife"}) end)
FlingSheriffButton.MouseButton1Click:Connect(function() FindAndFlingRole({"Gun", "Revolver"}) end)
SelectAllButton.MouseButton1Click:Connect(function() ToggleAllPlayers(true) end)
DeselectAllButton.MouseButton1Click:Connect(function() ToggleAllPlayers(false) end)
CloseButton.MouseButton1Click:Connect(function() StopFling() ScreenGui:Destroy() end)

Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(function(player)
    SelectedTargets[player.Name] = nil
    RefreshPlayerList()
    UpdateStatus()
end)

RefreshPlayerList()
UpdateStatus()
