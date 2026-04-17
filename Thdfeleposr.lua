local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- === НАСТРОЙКИ ===
local UI_COLOR = Color3.fromRGB(15, 15, 15)
local ACCENT_COLOR = Color3.fromRGB(0, 255, 0)
local CLOSE_COLOR = Color3.fromRGB(200, 50, 50) -- Цвет крестика

-- Создаем GUI
local sg = Instance.new("ScreenGui")
sg.Name = "TeleportMenuSystem"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.Parent = player:WaitForChild("PlayerGui")

-- Главное окно
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 220, 0, 320)
frame.Position = UDim2.new(0.5, -110, 0.5, -160)
frame.BackgroundColor3 = UI_COLOR
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = sg

-- Скругление и Контур
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = ACCENT_COLOR
stroke.Thickness = 2

-- КНОПКА ЗАКРЫТИЯ (КРЕСТИК)
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.Parent = frame

Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- Удаление GUI при нажатии
closeBtn.MouseButton1Click:Connect(function()
	sg:Destroy()
end)

-- Подсветка крестика при наведении
closeBtn.MouseEnter:Connect(function() closeBtn.BackgroundColor3 = CLOSE_COLOR end)
closeBtn.MouseLeave:Connect(function() closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end)

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 40)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "TELEPORT (F2)"
title.TextColor3 = ACCENT_COLOR
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Список игроков
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -60)
scroll.Position = UDim2.new(0, 10, 0, 45)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 2
scroll.ScrollBarImageColor3 = ACCENT_COLOR
scroll.Parent = frame

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 5)

-- Функция кнопок игроков
local function refresh()
	for _, v in pairs(scroll:GetChildren()) do
		if v:IsA("TextButton") then v:Destroy() end
	end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -5, 0, 30)
			btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			btn.Text = " " .. p.DisplayName
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 13
			btn.Parent = scroll
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
			
			btn.MouseButton1Click:Connect(function()
				if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
					player.Character:MoveTo(p.Character.HumanoidRootPart.Position)
				end
			end)
		end
	end
	scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end

-- Логика F2
UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F2 then
		frame.Visible = not frame.Visible
	end
end)

-- Логика Drag (Перетаскивание)
local dragging, dragStart, startPos
frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

refresh()
Players.PlayerAdded:Connect(refresh)
Players.PlayerRemoving:Connect(refresh)
