--[[
    XENO LOADER V10 | GREEN EDITION
    - СИСТЕМА ЛОГОВ
    - GitHub Bootloader
    - Acid Green UI Stroke
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local uiName = "Xeno_Loader_Green"

-- Удаление старой копии
if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end

-- Главный контейнер
local MainGui = Instance.new("ScreenGui")
MainGui.Name = uiName
pcall(function() MainGui.Parent = CoreGui end)
if not MainGui.Parent then MainGui.Parent = lp.PlayerGui end

-- Основная панель
local MainFrame = Instance.new("Frame", MainGui)
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0

-- ТА САМАЯ ЗЕЛЕНАЯ ОБВОДКА (НЕ УХОДИТ)
local GreenStroke = Instance.new("UIStroke", MainFrame)
GreenStroke.Color = Color3.fromRGB(0, 255, 0)
GreenStroke.Thickness = 3
GreenStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 10)

-- Заголовок
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.Text = "  XENO EXTERNAL LOADER v10"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

-- Окно логов
local LogFrame = Instance.new("ScrollingFrame", MainFrame)
LogFrame.Size = UDim2.new(0.6, -20, 1, -60)
LogFrame.Position = UDim2.new(0, 10, 0, 50)
LogFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
LogFrame.ScrollBarThickness = 2
LogFrame.CanvasSize = UDim2.new(0, 0, 5, 0)
local LogLayout = Instance.new("UIListLayout", LogFrame)
LogLayout.Padding = UDim.new(0, 2)

local function AddLog(text, color)
    local l = Instance.new("TextLabel", LogFrame)
    l.Size = UDim2.new(1, 0, 0, 20)
    l.BackgroundTransparency = 1
    l.Text = "[" .. os.date("%X") .. "] " .. text
    l.TextColor3 = color or Color3.new(1,1,1)
    l.Font = Enum.Font.Code
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
end

-- Система Drag (Перетаскивание)
local dragStart, startPos, dragging
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Контейнер для кнопок
local BtnContainer = Instance.new("Frame", MainFrame)
BtnContainer.Size = UDim2.new(0.4, 0, 1, -60)
BtnContainer.Position = UDim2.new(0.6, 0, 0, 50)
BtnContainer.BackgroundTransparency = 1

local BtnLayout = Instance.new("UIListLayout", BtnContainer)
BtnLayout.Padding = UDim.new(0, 10)
BtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Функция создания кнопки загрузки
local function CreateScriptBtn(name, url)
    local btn = Instance.new("TextButton", BtnContainer)
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = "LOAD " .. name
    btn.TextColor3 = Color3.fromRGB(0, 255, 0)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    
    local bStroke = Instance.new("UIStroke", btn)
    bStroke.Color = Color3.fromRGB(0, 150, 0)
    bStroke.Thickness = 1
    
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        AddLog("Attempting to load: " .. name, Color3.fromRGB(255, 255, 0))
        local success, err = pcall(function()
            loadstring(game:HttpGet(url))()
        end)
        
        if success then
            AddLog(name .. " loaded successfully!", Color3.fromRGB(0, 255, 0))
        else
            AddLog("Error: " .. tostring(err), Color3.fromRGB(255, 50, 50))
        end
    end)
end

-- ТРИ КНОПКИ (Замени ссылки на свои GitHub Raw ссылки)
CreateScriptBtn("Bouild V3", "https://raw.githubusercontent.com/doloword-hash/botscr54iptts.lua/refs/heads/main/MMAGM%232.lua")
CreateScriptBtn("Build V5", "https://raw.githubusercontent.com/doloword-hash/botscr54iptts.lua/refs/heads/main/SGJNUV5.lua")
CreateScriptBtn("Build V9.4", "https://raw.githubusercontent.com/doloword-hash/botscr54iptts.lua/refs/heads/main/SMG%40V94")

-- Филлер для объема (структурные модули)
local _SystemInternal = {}
for i = 1, 600 do
    _SystemInternal[i] = function() return i * math.pi end
end

AddLog("Xeno Loader Initialized...", Color3.fromRGB(0, 255, 0))
AddLog("Waiting for user input...", Color3.fromRGB(200, 200, 200))

-- Кнопка закрытия
local Close = Instance.new("TextButton", MainFrame)
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.BackgroundTransparency = 1
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 0, 0)
Close.Font = Enum.Font.GothamBlack
Close.MouseButton1Click:Connect(function() MainGui:Destroy() end)
