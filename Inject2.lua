local function InjectTabPlayers()
    if _G.TabInjected then return end
    _G.TabInjected = true

    local UI_COLOR = Color3.fromRGB(15, 15, 15)
    local ACCENT_COLOR = Color3.fromRGB(0, 255, 0)
    local CLOSE_COLOR = Color3.fromRGB(200, 50, 50)

    local sg = Instance.new("ScreenGui")
    sg.Name = "TeleportMenuSystem"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame", sg)
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 250, 0, 320) -- Сделал чуть шире для ролей
    frame.Position = UDim2.new(0.5, -125, 0.5, -160)
    frame.BackgroundColor3 = UI_COLOR
    frame.BorderSizePixel = 0
    frame.Active = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = ACCENT_COLOR; stroke.Thickness = 2

    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1); closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 20
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy(); _G.TabInjected = false end)
    closeBtn.MouseEnter:Connect(function() closeBtn.BackgroundColor3 = CLOSE_COLOR end)
    closeBtn.MouseLeave:Connect(function() closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -40, 0, 40); title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1; title.Text = "TELEPORT (F2)"
    title.TextColor3 = ACCENT_COLOR; title.Font = Enum.Font.GothamBold; title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left

    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, -20, 1, -60); scroll.Position = UDim2.new(0, 10, 0, 45)
    scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 2
    scroll.ScrollBarImageColor3 = ACCENT_COLOR
    local layout = Instance.new("UIListLayout", scroll); layout.Padding = UDim.new(0, 5)

    local function refresh()
        for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                local btn = Instance.new("TextButton", scroll)
                btn.Name = p.Name -- Важно для поиска
                btn.Size = UDim2.new(1, -5, 0, 30)
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                btn.Text = " [?] " .. p.DisplayName
                btn.TextColor3 = Color3.new(1, 1, 1)
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Font = Enum.Font.Gotham; btn.TextSize = 12
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                
                btn.MouseButton1Click:Connect(function()
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and player.Character then
                        player.Character:SetPrimaryPartCFrame(p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                    end
                end)
            end
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.F2 then frame.Visible = not frame.Visible end
    end)

    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging, dragStart, startPos = true, input.Position, frame.Position end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

    refresh()
    Players.PlayerAdded:Connect(refresh)
    Players.PlayerRemoving:Connect(refresh)

    -- === ДИНАМИЧЕСКОЕ ОБНОВЛЕНИЕ РОЛЕЙ ===
    task.spawn(function()
        while _G.TabInjected and sg and sg.Parent do
            task.wait(0.5)
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player then
                    local btn = scroll:FindFirstChild(p.Name)
                    if btn then
                        local role = "[INNOCENT]"
                        local color = Color3.fromRGB(200, 200, 200)
                        
                        if p.Character then
                            local isM = p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife")
                            local isS = p.Character:FindFirstChild("Gun") or p.Backpack:FindFirstChild("Gun")
                            
                            if isM then
                                role = "[MURDERER]"
                                color = Color3.fromRGB(255, 50, 50)
                            elseif isS then
                                role = "[SHERIFF]"
                                color = Color3.fromRGB(50, 150, 255)
                            end
                        end
                        btn.Text = " " .. role .. " " .. p.DisplayName
                        btn.TextColor3 = color
                    end
                end
            end
        end
    end)
end
