--[[
    ULTIMATE TESTING POLYGON V3 - MEGA MOD
    Разработчик: Gemini (Special for Kilasik)
    Особенности: 200+ строк, 5 зон, фикс телепортации.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local p = Players.LocalPlayer

-- Настройки координат
local spawnPos = Vector3.new(0, 2000, 0) -- Высота 2000, чтобы не мешать карте
local hubSize = 500

-- Очистка старых объектов
for _, obj in pairs(workspace:GetChildren()) do
    if obj.Name == "Kilasik_Polygon" then
        obj:Destroy()
    end
end

-- Создание папки-контейнера
local MainFolder = Instance.new("Model")
MainFolder.Name = "Kilasik_Polygon"
MainFolder.Parent = workspace

-- Функция для создания объектов
local function createPart(props)
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = true
    part.Parent = MainFolder
    
    for key, value in pairs(props) do
        part[key] = value
    end
    
    -- Если позиция передана как Vector3, превращаем в CFrame
    if props.Position then
        part.CFrame = CFrame.new(props.Position)
    end
    
    return part
end

-- ==========================================
-- 1. ЦЕНТРАЛЬНЫЙ ХАБ (ОСНОВАНИЕ)
-- ==========================================
createPart({
    Name = "Baseplate",
    Size = Vector3.new(hubSize, 2, hubSize),
    Position = spawnPos,
    Color = Color3.fromRGB(45, 45, 48),
    Material = Enum.Material.DiamondPlate
})

-- Декоративная разметка центра
createPart({
    Name = "CenterMark",
    Size = Vector3.new(10, 2.1, 10),
    Position = spawnPos + Vector3.new(0, 0, 0),
    Color = Color3.fromRGB(255, 255, 255),
    Material = Enum.Material.SmoothPlastic
})

-- ==========================================
-- 2. ЛАБИРИНТ (СПРАВА) - Сложная структура
-- ==========================================
local mazeOrigin = spawnPos + Vector3.new(180, 10, 0)
for i = 1, 12 do
    -- Горизонтальные стены
    createPart({
        Name = "MazeWallH",
        Size = Vector3.new(100, 20, 4),
        Position = mazeOrigin + Vector3.new(0, 0, -60 + (i * 10)),
        Color = Color3.fromRGB(80, 80, 80),
        Material = Enum.Material.Brick
    })
    -- Вертикальные вставки для сложности
    if i % 2 == 0 then
        createPart({
            Name = "MazeWallV",
            Size = Vector3.new(4, 20, 30),
            Position = mazeOrigin + Vector3.new(-20, 0, -60 + (i * 10)),
            Color = Color3.fromRGB(60, 60, 60),
            Material = Enum.Material.Cobblestone
        })
    end
end

-- ==========================================
-- 3. ПОДВЕСНОЙ МОСТ (СЛЕВА)
-- ==========================================
local bridgeStart = spawnPos + Vector3.new(-100, 0, 0)
createPart({
    Name = "PillarLeft",
    Size = Vector3.new(20, 100, 20),
    Position = bridgeStart + Vector3.new(-50, 40, 0),
    Color = Color3.fromRGB(30, 30, 30),
    Material = Enum.Material.Metal
})

for i = 1, 20 do
    createPart({
        Name = "Plank",
        Size = Vector3.new(15, 1, 5),
        Position = bridgeStart + Vector3.new(-60 - (i * 6), 90 - (i * 0.5), 0),
        Color = Color3.fromRGB(100, 70, 40),
        Material = Enum.Material.Wood
    })
end

-- ==========================================
-- 4. ПАРКУР-МАСТЕР (СПЕРЕДИ)
-- ==========================================
local parkourOrigin = spawnPos + Vector3.new(0, 5, 150)
for i = 1, 15 do
    local offset = i * 12
    local height = i * 5
    local pType = i % 3
    
    local pColor = Color3.fromRGB(255, 255, 255)
    if pType == 0 then pColor = Color3.fromRGB(255, 80, 80)
    elseif pType == 1 then pColor = Color3.fromRGB(80, 255, 80)
    else pColor = Color3.fromRGB(80, 80, 255) end

    createPart({
        Name = "JumpPad",
        Size = Vector3.new(8, 1, 8),
        Position = parkourOrigin + Vector3.new(math.sin(i) * 20, height, offset),
        Color = pColor,
        Material = Enum.Material.SmoothPlastic
    })
end

-- ==========================================
-- 5. АРЕНА ТЕСТОВ (СЗАДИ) + МАНЕКЕНЫ
-- ==========================================
local arenaPos = spawnPos + Vector3.new(0, 0, -180)
createPart({
    Name = "ArenaFloor",
    Size = Vector3.new(120, 1, 120),
    Position = arenaPos,
    Color = Color3.fromRGB(20, 20, 20),
    Material = Enum.Material.Concrete
})

-- Создание манекенов для флинга (Unanchored)
for i = 1, 10 do
    local dummy = createPart({
        Name = "DummyTarget",
        Size = Vector3.new(4, 7, 2),
        Position = arenaPos + Vector3.new(-40 + (i * 8), 5, 0),
        Color = Color3.fromRGB(200, 0, 0),
        Material = Enum.Material.Plastic
    })
    dummy.Anchored = false -- Чтобы их можно было толкать/флингать
end

-- ==========================================
-- 6. ДОПОЛНИТЕЛЬНЫЕ ФИШКИ
-- ==========================================

-- Бассейн (проверка плавания)
local water = createPart({
    Name = "TestWater",
    Size = Vector3.new(60, 20, 60),
    Position = spawnPos + Vector3.new(150, -8, -150),
    Color = Color3.fromRGB(0, 150, 255),
    Material = Enum.Material.Glass,
    Transparency = 0.5,
    CanCollide = false
})

-- Вышка наблюдения
createPart({
    Name = "Tower",
    Size = Vector3.new(10, 150, 10),
    Position = spawnPos + Vector3.new(0, 75, 0),
    Color = Color3.fromRGB(50, 50, 50),
    Material = Enum.Material.Metal
})
createPart({
    Name = "Observatory",
    Size = Vector3.new(30, 5, 30),
    Position = spawnPos + Vector3.new(0, 150, 0),
    Color = Color3.fromRGB(100, 100, 100),
    Material = Enum.Material.Glass,
    Transparency = 0.3
})

-- Прямая для замера скорости (Speed Track)
createPart({
    Name = "Track",
    Size = Vector3.new(400, 0.2, 20),
    Position = spawnPos + Vector3.new(0, 0.1, 230),
    Color = Color3.fromRGB(255, 255, 0),
    Material = Enum.Material.SmoothPlastic
})

-- ==========================================
-- ЖЕЛЕЗНАЯ ТЕЛЕПОРТАЦИЯ
-- ==========================================
local function safeTeleport()
    local attempts = 0
    local maxAttempts = 50 -- Будет пытаться 5 секунд
    
    while attempts < maxAttempts do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.CFrame = CFrame.new(spawnPos + Vector3.new(0, 10, 0))
            -- Проверка: если мы уже близко к цели, выходим из цикла
            if (p.Character.HumanoidRootPart.Position - spawnPos).Magnitude < 50 then
                print("Телепортация успешна!")
                break
            end
        end
        attempts = attempts + 1
        task.wait(0.1)
    end
end

-- Запуск телепорта
task.spawn(safeTeleport)

-- Настройка освещения для приятного вида (не неон)
local Lighting = game:GetService("Lighting")
Lighting.ClockTime = 14 -- День
Lighting.Brightness = 2
Lighting.OutdoorAmbient = Color3.fromRGB(120, 120, 120)

print("--- КИЛАСИК ПОЛИГОН ЗАГРУЖЕН ---")
print("Создано объектов: " .. #MainFolder:GetChildren())
