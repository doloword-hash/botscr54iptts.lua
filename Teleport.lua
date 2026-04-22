local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- === НАСТРОЙКИ СТИЛЯ (Твои оригинальные) ===
local UI_COLOR = Color3.fromRGB(15, 15, 15)
local ACCENT_COLOR = Color3.fromRGB(0, 255, 0)
local CLOSE_COLOR = Color3.fromRGB(200, 50, 50) 
local SECONDARY_TEXT = Color3.fromRGB(180, 180, 180)

-- === ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ===
local isNoclip = false
local isESP = false
local spectating = nil
local searchQuery = ""

-- Создаем GUI
local sg = Instance.new("ScreenGui")
sg.Name = "TeleportMenuSystem"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
local success, result = pcall(function() return game:GetService("CoreGui") end)
sg.Parent = success and result or player:WaitForChild("PlayerGui")

-- Главное окно (Чуть увеличил высоту для новых кнопок)
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 280, 0, 450)
frame.Position = UDim2.new(0.5, -140, 0.5, -225)
frame.BackgroundColor3 = UI_COLOR
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = sg

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = ACCENT_COLOR
stroke.Thickness = 2

-- КНОПКА ЗАКРЫТИЯ
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

closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 40)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Teleport (F2)"
title.TextColor3 = ACCENT_COLOR
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- === ПОИСК ИГРОКОВ ===
local searchBar = Instance.new("TextBox")
searchBar.Size = UDim2.new(1, -20, 0, 30)
searchBar.Position = UDim2.new(0, 10, 0, 40)
searchBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
searchBar.PlaceholderText = "Search Player..."
searchBar.Text = ""
searchBar.TextColor3 = Color3.new(1, 1, 1)
searchBar.Font = Enum.Font.Gotham
searchBar.TextSize = 13
searchBar.Parent = frame
Instance.new("UICorner", searchBar).CornerRadius = UDim.new(0, 6)

-- Список игроков
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -135) -- Оставили место снизу для утилит
scroll.Position = UDim2.new(0, 10, 0, 80)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 2
scroll.ScrollBarImageColor3 = ACCENT_COLOR
scroll.Parent = frame

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 8)

-- Функция создания карточки игрока
local function refresh()
	for _, v in pairs(scroll:GetChildren()) do
		if v:IsA("GuiObject") then v:Destroy() end
	end
	
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player then
			-- Логика фильтрации поиска
			local lowerSearch = string.lower(searchQuery)
			local lowerName = string.lower(p.Name)
			local lowerDisp = string.lower(p.DisplayName)
			
			if searchQuery == "" or string.find(lowerName, lowerSearch) or string.find(lowerDisp, lowerSearch) then
				
				local btn = Instance.new("Frame")
				btn.Name = p.Name
				btn.Size = UDim2.new(1, -5, 0, 50)
				btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
				btn.Parent = scroll
				Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
				
				local avatar = Instance.new("ImageLabel")
				avatar.Size = UDim2.new(0, 40, 0, 40)
				avatar.Position = UDim2.new(0, 5, 0.5, -20)
				avatar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=150&h=150"
				avatar.Parent = btn
				Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
				
				local dName = Instance.new("TextLabel")
				dName.Size = UDim2.new(1, -130, 0, 20)
				dName.Position = UDim2.new(0, 50, 0, 8)
				dName.BackgroundTransparency = 1
				dName.Text = p.DisplayName
				dName.TextColor3 = Color3.new(1, 1, 1)
				dName.Font = Enum.Font.GothamBold
				dName.TextSize = 13
				dName.TextXAlignment = Enum.TextXAlignment.Left
				dName.Parent = btn
				
				local uName = Instance.new("TextLabel")
				uName.Size = UDim2.new(1, -130, 0, 20)
				uName.Position = UDim2.new(0, 50, 0, 24)
				uName.BackgroundTransparency = 1
				uName.Text = "@" .. p.Name
				uName.TextColor3 = SECONDARY_TEXT
				uName.Font = Enum.Font.Gotham
				uName.TextSize = 11
				uName.TextXAlignment = Enum.TextXAlignment.Left
				uName.Parent = btn
				
				-- Кнопка Телепорта (TP)
				local tpBtn = Instance.new("TextButton")
				tpBtn.Size = UDim2.new(0, 30, 0, 30)
				tpBtn.Position = UDim2.new(1, -75, 0.5, -15)
				tpBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				tpBtn.Text = "TP"
				tpBtn.TextColor3 = ACCENT_COLOR
				tpBtn.Font = Enum.Font.GothamBold
				tpBtn.TextSize = 12
				tpBtn.Parent = btn
				Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)
				
				tpBtn.MouseButton1Click:Connect(function()
					if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
						player.Character:MoveTo(p.Character.HumanoidRootPart.Position)
					end
				end)

				-- Кнопка Spectate (Наблюдение)
				local specBtn = Instance.new("TextButton")
				specBtn.Size = UDim2.new(0, 30, 0, 30)
				specBtn.Position = UDim2.new(1, -40, 0.5, -15)
				specBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				specBtn.Text = "👁"
				specBtn.TextColor3 = Color3.new(1, 1, 1)
				specBtn.Font = Enum.Font.GothamBold
				specBtn.TextSize = 14
				specBtn.Parent = btn
				Instance.new("UICorner", specBtn).CornerRadius = UDim.new(0, 6)

				specBtn.MouseButton1Click:Connect(function()
					if p.Character and p.Character:FindFirstChild("Humanoid") then
						camera.CameraSubject = p.Character.Humanoid
						spectating = p
					end
				end)
			end
		end
	end
	scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end

-- === ПАНЕЛЬ ПОЛЕЗНЫХ УТИЛИТ (ВНИЗУ) ===
local utilityFrame = Instance.new("Frame")
utilityFrame.Size = UDim2.new(1, -20, 0, 45)
utilityFrame.Position = UDim2.new(0, 10, 1, -50)
utilityFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
utilityFrame.Parent = frame
Instance.new("UICorner", utilityFrame).CornerRadius = UDim.new(0, 6)

local uLayout = Instance.new("UIListLayout", utilityFrame)
uLayout.FillDirection = Enum.FillDirection.Horizontal
uLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uLayout.Padding = UDim.new(0, 10)

local function createUtilBtn(text)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 75, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.Parent = utilityFrame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

local noclipBtn = createUtilBtn("NOCLIP")
local espBtn = createUtilBtn("ESP")
local unspecBtn = createUtilBtn("UN-SPEC")

-- Логика Un-Spectate (Вернуть камеру себе)
unspecBtn.MouseButton1Click:Connect(function()
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		camera.CameraSubject = player.Character.Humanoid
		spectating = nil
	end
end)

-- Логика Noclip
noclipBtn.MouseButton1Click:Connect(function()
	isNoclip = not isNoclip
	noclipBtn.TextColor3 = isNoclip and ACCENT_COLOR or Color3.new(1, 1, 1)
end)

RunService.Stepped:Connect(function()
	if isNoclip and player.Character then
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				part.CanCollide = false
			end
		end
	end
end)

-- Логика ESP (Подсветка игроков)
-- === ИСПРАВЛЕННЫЙ БЛОК ESP ===
local ESP_FOLDER = Instance.new("Folder")
ESP_FOLDER.Name = "ESP_Highlights"
-- Используем result (это и есть CoreGui), который мы получили через pcall в начале твоего скрипта
ESP_FOLDER.Parent = success and result or player:WaitForChild("PlayerGui")

espBtn.MouseButton1Click:Connect(function()
    isESP = not isESP
    espBtn.TextColor3 = isESP and ACCENT_COLOR or Color3.new(1, 1, 1)
    
    if not isESP then
        ESP_FOLDER:ClearAllChildren()
    end
end)

-- Обновление ESP в реальном времени
RunService.RenderStepped:Connect(function()
    if not isESP then return end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local highlightName = p.Name .. "_ESP"
            local highlight = ESP_FOLDER:FindFirstChild(highlightName)
            
            -- Если подсветки еще нет — создаем
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = highlightName
                highlight.FillColor = ACCENT_COLOR
                highlight.FillTransparency = 0.5
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.Parent = ESP_FOLDER
            end
            
            -- ВАЖНО: Привязываем подсветку к актуальному персонажу (исправляет баг после респавна)
            if highlight.Adornee ~= p.Character then
                highlight.Adornee = p.Character
            end
        end
    end
end)
-- === КОНЕЦ БЛОКА ESP ===

-- Обновление поиска при вводе
searchBar:GetPropertyChangedSignal("Text"):Connect(function()
	searchQuery = searchBar.Text
	refresh()
end)

-- Логика F2
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.F2 then
		frame.Visible = not frame.Visible
	end
end)

-- Логика Drag
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

-- Инициализация
refresh()
Players.PlayerAdded:Connect(refresh)
Players.PlayerRemoving:Connect(function(p)
	-- Чистим ESP и сбрасываем камеру, если игрок ливнул
	if ESP_FOLDER:FindFirstChild(p.Name .. "_ESP") then
		ESP_FOLDER[p.Name .. "_ESP"]:Destroy()
	end
	if spectating == p then
		unspecBtn.MouseButton1Click:Fire()
	end
	refresh()
end)
