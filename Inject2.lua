-- Объединённый вариант:
-- Новый универсальный интерфейс + старый игровой функционал
-- Старое: роли Knife/Gun, телепорт с отступом, _G.TabInjected, F2
-- Новое: поиск, карточки, TP/Spectate, Noclip/ESP

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- === СТИЛЬ ===
local UI_COLOR = Color3.fromRGB(15, 15, 15)
local ACCENT_COLOR = Color3.fromRGB(0, 255, 0)
local CLOSE_COLOR = Color3.fromRGB(200, 50, 50)
local SECONDARY_TEXT = Color3.fromRGB(180, 180, 180)

-- === ГЛОБАЛЬНАЯ ПЕРЕМЕННАЯ ИЗ СТАРОГО СКРИПТА ===
_G.TabInjected = true

-- === GUI ===
local sg = Instance.new("ScreenGui")
sg.Name = "TeleportMenuSystem"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.DisplayOrder = 999999

-- Чистим старый GUI из PlayerGui, если он там был
pcall(function()
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        local old = playerGui:FindFirstChild("TeleportMenuSystem")
        if old then
            old:Destroy()
        end
    end
end)

-- Пытаемся разместить в CoreGui, если не выходит — в PlayerGui
local function cleanAndParent(parent)
    pcall(function()
        local old = parent:FindFirstChild("TeleportMenuSystem")
        if old then
            old:Destroy()
        end
    end)

    pcall(function()
        sg.Parent = parent
    end)
end

local coreSuccess, coreGui = pcall(function()
    return game:GetService("CoreGui")
end)

if coreSuccess and coreGui then
    cleanAndParent(coreGui)
end

if not sg.Parent then
    cleanAndParent(player:WaitForChild("PlayerGui"))
end

local function isAlive()
    return _G.TabInjected and sg ~= nil and sg.Parent ~= nil
end

-- === ГЛАВНОЕ ОКНО ===
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

-- === КНОПКА ЗАКРЫТИЯ ===
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

closeBtn.MouseEnter:Connect(function()
    closeBtn.TextColor3 = CLOSE_COLOR
end)

closeBtn.MouseLeave:Connect(function()
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
end)

-- === ЗАГОЛОВОК ===
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 40)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "TELEPORT (F2)"
title.TextColor3 = ACCENT_COLOR
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- === ПОИСК ===
local searchQuery = ""

local searchBar = Instance.new("TextBox")
searchBar.Size = UDim2.new(1, -20, 0, 30)
searchBar.Position = UDim2.new(0, 10, 0, 40)
searchBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
searchBar.PlaceholderText = "Search Player..."
searchBar.Text = ""
searchBar.TextColor3 = Color3.new(1, 1, 1)
searchBar.Font = Enum.Font.Gotham
searchBar.TextSize = 13
searchBar.ClearTextOnFocus = false
searchBar.Parent = frame

Instance.new("UICorner", searchBar).CornerRadius = UDim.new(0, 6)

-- === СПИСОК ИГРОКОВ ===
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -135)
scroll.Position = UDim2.new(0, 10, 0, 80)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 2
scroll.ScrollBarImageColor3 = ACCENT_COLOR
scroll.Parent = frame

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 6)

-- === СОСТОЯНИЕ ===
local isNoclip = false
local isESP = false
local spectating = nil

-- Проверка поддержки Highlight
local highlightSupported = false
pcall(function()
    local test = Instance.new("Highlight")
    highlightSupported = true
    test:Destroy()
end)

-- === ФУНКЦИИ КАМЕРЫ / ТЕЛЕПОРТА / КОЛЛИЗИИ ===

local function resetCamera()
    local cam = workspace.CurrentCamera
    local char = player.Character

    if cam and char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            cam.CameraSubject = hum
        end
    end

    spectating = nil
end

local function spectatePlayer(targetPlayer)
    local cam = workspace.CurrentCamera
    local targetChar = targetPlayer and targetPlayer.Character

    if not cam or not targetChar then
        return
    end

    local hum = targetChar:FindFirstChildOfClass("Humanoid")
    if hum then
        cam.CameraSubject = hum
        spectating = targetPlayer
    end
end

-- Телепорт как в старом скрипте: назад на 3 стада от цели
local function teleportToPlayer(targetPlayer)
    local myChar = player.Character
    local targetChar = targetPlayer and targetPlayer.Character

    if not myChar or not targetChar then
        return
    end

    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return
    end

    local goal = targetRoot.CFrame * CFrame.new(0, 0, 3)

    if myChar.PrimaryPart then
        local ok = pcall(function()
            myChar:SetPrimaryPartCFrame(goal)
        end)

        if ok then
            return
        end
    end

    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if myRoot then
        myRoot.CFrame = goal
    end
end

local function setCharacterCollision(enabled)
    local char = player.Character
    if not char then
        return
    end

    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            if part.Parent and not part.Parent:IsA("Accessory") then
                part.CanCollide = enabled
            end
        end
    end
end

local function clearAllESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local h = p.Character:FindFirstChild("CombinedESP_Highlight")
            if h then
                h:Destroy()
            end
        end
    end
end

-- === КНОПКА ЗАКРЫТИЯ: ЛОГИКА ===
closeBtn.MouseButton1Click:Connect(function()
    _G.TabInjected = false

    resetCamera()

    if isNoclip then
        setCharacterCollision(true)
    end

    if isESP then
        clearAllESP()
    end

    sg:Destroy()
end)

-- === СТАРАЯ ФУНКЦИЯ РОЛЕЙ ===
local function getRoleInfo(p)
    local role = "[INNOCENT]"
    local color = Color3.fromRGB(200, 200, 200)

    if p.Character then
        local backpack = p:FindFirstChild("Backpack")

        local hasKnife = p.Character:FindFirstChild("Knife")
            or (backpack and backpack:FindFirstChild("Knife"))

        local hasGun = p.Character:FindFirstChild("Gun")
            or (backpack and backpack:FindFirstChild("Gun"))

        if hasKnife then
            role = "[MURDERER]"
            color = Color3.fromRGB(255, 50, 50)
        elseif hasGun then
            role = "[SHERIFF]"
            color = Color3.fromRGB(50, 150, 255)
        end
    end

    return role, color
end

-- === ОБНОВЛЕНИЕ СПИСКА ИГРОКОВ ===
local function refresh()
    if not isAlive() then
        return
    end

    for _, v in pairs(scroll:GetChildren()) do
        if v:IsA("GuiObject") then
            v:Destroy()
        end
    end

    local query = string.lower(searchQuery)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local lowerName = string.lower(p.Name)
            local lowerDisplay = string.lower(p.DisplayName)

            local visible = query == ""
                or string.find(lowerName, query, 1, true) ~= nil
                or string.find(lowerDisplay, query, 1, true) ~= nil

            if visible then
                local card = Instance.new("Frame")
                card.Name = p.Name
                card.Size = UDim2.new(1, -5, 0, 56)
                card.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                card.Parent = scroll

                Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

                local avatar = Instance.new("ImageLabel")
                avatar.Size = UDim2.new(0, 40, 0, 40)
                avatar.Position = UDim2.new(0, 6, 0.5, -20)
                avatar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=150&h=150"
                avatar.Parent = card

                Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

                local dName = Instance.new("TextLabel")
                dName.Size = UDim2.new(1, -145, 0, 16)
                dName.Position = UDim2.new(0, 54, 0, 6)
                dName.BackgroundTransparency = 1
                dName.Text = p.DisplayName
                dName.TextColor3 = Color3.new(1, 1, 1)
                dName.Font = Enum.Font.GothamBold
                dName.TextSize = 13
                dName.TextXAlignment = Enum.TextXAlignment.Left
                dName.TextTruncate = Enum.TextTruncate.AtEnd
                dName.Parent = card

                local roleText, roleColor = getRoleInfo(p)

                local roleLabel = Instance.new("TextLabel")
                roleLabel.Name = "RoleLabel"
                roleLabel.Size = UDim2.new(1, -145, 0, 14)
                roleLabel.Position = UDim2.new(0, 54, 0, 23)
                roleLabel.BackgroundTransparency = 1
                roleLabel.Text = roleText
                roleLabel.TextColor3 = roleColor
                roleLabel.Font = Enum.Font.GothamBold
                roleLabel.TextSize = 11
                roleLabel.TextXAlignment = Enum.TextXAlignment.Left
                roleLabel.TextTruncate = Enum.TextTruncate.AtEnd
                roleLabel.Parent = card

                local uName = Instance.new("TextLabel")
                uName.Size = UDim2.new(1, -145, 0, 12)
                uName.Position = UDim2.new(0, 54, 0, 38)
                uName.BackgroundTransparency = 1
                uName.Text = "@" .. p.Name
                uName.TextColor3 = SECONDARY_TEXT
                uName.Font = Enum.Font.Gotham
                uName.TextSize = 10
                uName.TextXAlignment = Enum.TextXAlignment.Left
                uName.TextTruncate = Enum.TextTruncate.AtEnd
                uName.Parent = card

                local tpBtn = Instance.new("TextButton")
                tpBtn.Size = UDim2.new(0, 34, 0, 30)
                tpBtn.Position = UDim2.new(1, -80, 0.5, -15)
                tpBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                tpBtn.Text = "TP"
                tpBtn.TextColor3 = ACCENT_COLOR
                tpBtn.Font = Enum.Font.GothamBold
                tpBtn.TextSize = 12
                tpBtn.Parent = card

                Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)

                tpBtn.MouseButton1Click:Connect(function()
                    teleportToPlayer(p)
                end)

                local specBtn = Instance.new("TextButton")
                specBtn.Size = UDim2.new(0, 34, 0, 30)
                specBtn.Position = UDim2.new(1, -41, 0.5, -15)
                specBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                specBtn.Text = "👁"
                specBtn.TextColor3 = Color3.new(1, 1, 1)
                specBtn.Font = Enum.Font.GothamBold
                specBtn.TextSize = 14
                specBtn.Parent = card

                Instance.new("UICorner", specBtn).CornerRadius = UDim.new(0, 6)

                specBtn.MouseButton1Click:Connect(function()
                    spectatePlayer(p)
                end)
            end
        end
    end

    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 5)
end

-- === НИЖНЯЯ ПАНЕЛЬ УТИЛИТ ===
local utilityFrame = Instance.new("Frame")
utilityFrame.Size = UDim2.new(1, -20, 0, 45)
utilityFrame.Position = UDim2.new(0, 10, 1, -52)
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

-- === UN-SPEC ===
unspecBtn.MouseButton1Click:Connect(function()
    resetCamera()
end)

-- === NOCLIP ===
noclipBtn.MouseButton1Click:Connect(function()
    isNoclip = not isNoclip
    noclipBtn.TextColor3 = isNoclip and ACCENT_COLOR or Color3.new(1, 1, 1)

    if not isNoclip then
        setCharacterCollision(true)
    end
end)

-- === ESP ===
espBtn.MouseButton1Click:Connect(function()
    if not highlightSupported then
        return
    end

    isESP = not isESP
    espBtn.TextColor3 = isESP and ACCENT_COLOR or Color3.new(1, 1, 1)

    if not isESP then
        clearAllESP()
    end
end)

-- === NOCLIP LOOP ===
RunService.Stepped:Connect(function()
    if not isAlive() then
        return
    end

    if not isNoclip then
        return
    end

    local char = player.Character
    if not char then
        return
    end

    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)

-- === ESP LOOP ===
RunService.RenderStepped:Connect(function()
    if not isAlive() then
        return
    end

    if not isESP or not highlightSupported then
        return
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local h = p.Character:FindFirstChild("CombinedESP_Highlight")

            if not h then
                h = Instance.new("Highlight")
                h.Name = "CombinedESP_Highlight"
                h.FillColor = ACCENT_COLOR
                h.FillTransparency = 0.5
                h.OutlineColor = Color3.new(1, 1, 1)
                h.Parent = p.Character
            end

            h.Adornee = p.Character
        end
    end
end)

-- === СТАРЫЙ ЦИКЛ ОБНОВЛЕНИЯ РОЛЕЙ ===
task.spawn(function()
    while isAlive() do
        task.wait(0.5)

        if not isAlive() then
            break
        end

        if not scroll or not scroll.Parent then
            break
        end

        -- Если наблюдаем за игроком, который умер/ливнул — возвращаем камеру
        if spectating and (
            not spectating.Parent
            or not spectating.Character
            or not spectating.Character:FindFirstChildOfClass("Humanoid")
        ) then
            resetCamera()
        end

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                local card = scroll:FindFirstChild(p.Name)
                local roleLabel = card and card:FindFirstChild("RoleLabel")

                if roleLabel then
                    local roleText, roleColor = getRoleInfo(p)
                    roleLabel.Text = roleText
                    roleLabel.TextColor3 = roleColor
                end
            end
        end
    end
end)

-- === ПОИСК ===
searchBar:GetPropertyChangedSignal("Text"):Connect(function()
    if not isAlive() then
        return
    end

    searchQuery = searchBar.Text
    refresh()
end)

-- === F2 ===
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not isAlive() then
        return
    end

    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.F2 then
        frame.Visible = not frame.Visible
    end
end)

-- === ПЕРЕТАСКИВАНИЕ ОКНА ===
local dragging = false
local dragStart = nil
local startPos = nil

frame.InputBegan:Connect(function(input)
    if not isAlive() then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not isAlive() then
        return
    end

    if dragging and dragStart and startPos and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if not isAlive() then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- === ИВЕНТЫ ИГРОКОВ ===
Players.PlayerAdded:Connect(function()
    if not isAlive() then
        return
    end

    refresh()
end)

Players.PlayerRemoving:Connect(function(p)
    if not isAlive() then
        return
    end

    if p.Character then
        local h = p.Character:FindFirstChild("CombinedESP_Highlight")
        if h then
            h:Destroy()
        end
    end

    if spectating == p then
        resetCamera()
    end

    refresh()
end)

-- === СТАРТ ===
refresh()
