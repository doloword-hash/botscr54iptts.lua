-- Глобальные настройки цветов
local BACKGROUND_COLOR = Color3.fromRGB(15, 15, 15)
local ACCENT_COLOR = Color3.fromRGB(0, 255, 0)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)

local function createCrosshair(parent, style)
	-- Очистка старого прицела
	for _, child in ipairs(parent:GetChildren()) do
		if child.Name == "Line" or child.Name == "Dot" then child:Destroy() end
	end
	
	if style == "None" then return end

	local function drawLine(name, size, pos)
		local f = Instance.new("Frame")
		f.Name = "Line"
		f.Size = size
		f.Position = pos
		f.BackgroundColor3 = ACCENT_COLOR
		f.BorderSizePixel = 0
		f.Parent = parent
	end

	if style == "Standard" then
		drawLine("L", UDim2.new(0, 10, 0, 2), UDim2.new(0, -14, 0, -1))
		drawLine("R", UDim2.new(0, 10, 0, 2), UDim2.new(0, 4, 0, -1))
		drawLine("T", UDim2.new(0, 2, 0, 10), UDim2.new(0, -1, 0, -14))
		drawLine("B", UDim2.new(0, 2, 0, 10), UDim2.new(0, -1, 0, 4))
	elseif style == "Dot" then
		local d = Instance.new("Frame")
		d.Name = "Dot"
		d.Size = UDim2.new(0, 4, 0, 4)
		d.Position = UDim2.new(0, -2, 0, -2)
		d.BackgroundColor3 = ACCENT_COLOR
		d.BorderSizePixel = 0
		Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
		d.Parent = parent
	elseif style == "Circle" then
		local d = Instance.new("Frame")
		d.Name = "Dot"
		d.Size = UDim2.new(0, 12, 0, 12)
		d.Position = UDim2.new(0, -6, 0, -6)
		d.BackgroundTransparency = 1
		local stroke = Instance.new("UIStroke", d)
		stroke.Color = ACCENT_COLOR
		stroke.Thickness = 2
		Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
		d.Parent = parent
	elseif style == "Heavy" then
		drawLine("L", UDim2.new(0, 15, 0, 4), UDim2.new(0, -20, 0, -2))
		drawLine("R", UDim2.new(0, 15, 0, 4), UDim2.new(0, 5, 0, -2))
		drawLine("T", UDim2.new(0, 4, 0, 15), UDim2.new(0, -2, 0, -20))
		drawLine("B", UDim2.new(0, 4, 0, 15), UDim2.new(0, -2, 0, 5))
	end
end

local function onPlayerAdded(player)
	local playerGui = player:WaitForChild("PlayerGui")
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CrosshairSystem"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- Центр для прицела
	local chCenter = Instance.new("Frame")
	chCenter.Name = "CrosshairCenter"
	chCenter.Size = UDim2.new(0, 0, 0, 0)
	chCenter.Position = UDim2.new(0.5, 0, 0.5, 0)
	chCenter.BackgroundTransparency = 1
	chCenter.Parent = screenGui
	
	createCrosshair(chCenter, "Standard") -- По умолчанию

	-- МЕНЮ СПРАВА
	local menu = Instance.new("Frame")
	menu.Name = "SettingsMenu"
	menu.Size = UDim2.new(0, 200, 0, 300)
	menu.Position = UDim2.new(1, -220, 0.5, -150)
	menu.BackgroundColor3 = BACKGROUND_COLOR
	menu.BorderSizePixel = 0
	menu.Parent = screenGui
	
	-- Стили меню
	Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 15)
	local stroke = Instance.new("UIStroke", menu)
	stroke.Color = ACCENT_COLOR
	stroke.Thickness = 2

	-- Заголовок
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundTransparency = 1
	title.Text = "ПРИЦЕЛ"
	title.TextColor3 = ACCENT_COLOR
	title.TextSize = 20
	title.Font = Enum.Font.GothamBold
	title.Parent = menu

	-- Кнопка закрытия
	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 30, 0, 30)
	close.Position = UDim2.new(1, -35, 0, 5)
	close.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	close.Text = "X"
	close.TextColor3 = TEXT_COLOR
	Instance.new("UICorner", close)
	close.Parent = menu
	close.MouseButton1Click:Connect(function() menu.Visible = false end)

	-- Список кнопок для выбора прицела
	local styles = {"Standard", "Dot", "Circle", "Heavy", "None"}
	local displayNames = {
		Standard = "Стандарт",
		Dot = "Точка",
		Circle = "Круг",
		Heavy = "Тяжелый",
		None = "Выключить"
	}

	for i, styleName in ipairs(styles) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.8, 0, 0, 35)
		btn.Position = UDim2.new(0.1, 0, 0, 50 + (i-1)*45)
		btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		btn.Text = displayNames[styleName]
		btn.TextColor3 = TEXT_COLOR
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 14
		Instance.new("UICorner", btn)
		
		-- Обводка кнопки
		local bStroke = Instance.new("UIStroke", btn)
		bStroke.Color = Color3.fromRGB(60, 60, 60)
		
		btn.Parent = menu
		
		btn.MouseButton1Click:Connect(function()
			createCrosshair(chCenter, styleName)
		end)
	end
end

game.Players.PlayerAdded:Connect(onPlayerAdded)
for _, p in ipairs(game.Players:GetPlayers()) do onPlayerAdded(p) end
