local coregui = game:GetService("CoreGui")
local player = game:GetService("Players").LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local mouse = player:GetMouse()
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")

-- Configurations
local Config = {
    -- ESP Settings
    Box = true,
    BoxOutline = true,
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxOutlineColor = Color3.fromRGB(0, 0, 0),
    HealthBar = true,
    HealthBarSide = "Left",
    HealthBarOutlineToggle = true,
    HealthBarOutlineThickness = 3,    
    HealthBarThickness = 2,    
    Names = true,
    NamesOutline = false,
    NamesColor = Color3.fromRGB(255, 255, 255),
    NamesOutlineColor = Color3.fromRGB(0, 0, 0),
    NamesFont = 2,
    NamesSize = 13,
    MaxDistance = 200,
    
    -- Movement Settings
    SpinbotEnabled = false,
    SpinbotSpeed = 20,
    BunnyHopEnabled = false,
    BunnyHopKey = "Space",
    WalkSpeedEnabled = false,
    WalkSpeed = 16,
    ForceThirdPerson = false,
    ThirdPersonDistance = 5,
    
    -- Bullet Tracers
    BulletTracersEnabled = false,
    BulletTracerColor = Color3.fromRGB(255, 0, 0),
    BulletTracerThickness = 1,
    
    -- Aimbot Settings
    AimbotEnabled = false,
    AimbotKey = "RightMouseButton",
    AimbotFOV = 100,
    AimbotSmoothness = 10,
    AimbotHitPart = "Head",
    SilentAimEnabled = false,
    HitboxExpansion = 100, -- New setting for hitbox expansion
    ShowFOV = true,
    FOVColor = Color3.fromRGB(255, 255, 255)
}

-- GUI Variables
local guiEnabled = true
local espEnabled = true

-- Backtrack Variables
local backtrackEnabled = true
local maxBacktrackTicks = 12
local backtrackRecords = {} -- Stores position history for all players
local tickRate = 0.016666666666666666 -- 60 ticks per second (1/60)

-- Movement Variables
local spinbotConnection = nil
local bhopActive = false
local originalWalkspeed = 16
local bhopConnection = nil
local thirdPersonConnection = nil

-- Bullet Tracer Variables
local bulletTracerConnections = {}

-- Aimbot Variables
local aimbotConnection = nil
local silentAimConnection = nil
local fovCircle = nil
local target = nil
local originalNamecall = nil

-- Keybind options
local keybindOptions = {
    "Space", "LeftShift", "RightShift", "LeftControl", "RightControl", 
    "Q", "E", "F", "C", "V", "X", "Z"
}

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleESP"
screenGui.Parent = coregui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 650) -- Increased height for new features
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -325)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.Text = "Simple ESP & Tools"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 18
closeButton.Parent = mainFrame

closeButton.MouseButton1Click:Connect(function()
    guiEnabled = not guiEnabled
    mainFrame.Visible = guiEnabled
end)

local tabSelector = Instance.new("Frame")
tabSelector.Size = UDim2.new(1, 0, 0, 30)
tabSelector.Position = UDim2.new(0, 0, 0, 30)
tabSelector.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
tabSelector.BorderSizePixel = 0
tabSelector.Parent = mainFrame

local espTabButton = Instance.new("TextButton")
espTabButton.Size = UDim2.new(0.25, 0, 1, 0)
espTabButton.Position = UDim2.new(0, 0, 0, 0)
espTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
espTabButton.Text = "ESP"
espTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espTabButton.Font = Enum.Font.SourceSans
espTabButton.TextSize = 14
espTabButton.Parent = tabSelector

local movementTabButton = Instance.new("TextButton")
movementTabButton.Size = UDim2.new(0.25, 0, 1, 0)
movementTabButton.Position = UDim2.new(0.25, 0, 0, 0)
movementTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
movementTabButton.Text = "Movement"
movementTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
movementTabButton.Font = Enum.Font.SourceSans
movementTabButton.TextSize = 14
movementTabButton.Parent = tabSelector

local visualsTabButton = Instance.new("TextButton")
visualsTabButton.Size = UDim2.new(0.25, 0, 1, 0)
visualsTabButton.Position = UDim2.new(0.5, 0, 0, 0)
visualsTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
visualsTabButton.Text = "Visuals"
visualsTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
visualsTabButton.Font = Enum.Font.SourceSans
visualsTabButton.TextSize = 14
visualsTabButton.Parent = tabSelector

local aimbotTabButton = Instance.new("TextButton")
aimbotTabButton.Size = UDim2.new(0.25, 0, 1, 0)
aimbotTabButton.Position = UDim2.new(0.75, 0, 0, 0)
aimbotTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
aimbotTabButton.Text = "Aimbot"
aimbotTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
aimbotTabButton.Font = Enum.Font.SourceSans
aimbotTabButton.TextSize = 14
aimbotTabButton.Parent = tabSelector

local tabContent = Instance.new("Frame")
tabContent.Size = UDim2.new(1, -10, 1, -70)
tabContent.Position = UDim2.new(0, 5, 0, 65)
tabContent.BackgroundTransparency = 1
tabContent.Parent = mainFrame

-- ESP Tab Content
local espTab = Instance.new("ScrollingFrame")
espTab.Size = UDim2.new(1, 0, 1, 0)
espTab.BackgroundTransparency = 1
espTab.ScrollBarThickness = 5
espTab.Visible = true
espTab.Parent = tabContent

-- Movement Tab Content
local movementTab = Instance.new("ScrollingFrame")
movementTab.Size = UDim2.new(1, 0, 1, 0)
movementTab.BackgroundTransparency = 1
movementTab.ScrollBarThickness = 5
movementTab.Visible = false
movementTab.Parent = tabContent

-- Visuals Tab Content
local visualsTab = Instance.new("ScrollingFrame")
visualsTab.Size = UDim2.new(1, 0, 1, 0)
visualsTab.BackgroundTransparency = 1
visualsTab.ScrollBarThickness = 5
visualsTab.Visible = false
visualsTab.Parent = tabContent

-- Aimbot Tab Content
local aimbotTab = Instance.new("ScrollingFrame")
aimbotTab.Size = UDim2.new(1, 0, 1, 0)
aimbotTab.BackgroundTransparency = 1
aimbotTab.ScrollBarThickness = 5
aimbotTab.Visible = false
aimbotTab.Parent = tabContent

-- Tab Switching
local function switchToTab(tab)
    espTab.Visible = (tab == espTab)
    movementTab.Visible = (tab == movementTab)
    visualsTab.Visible = (tab == visualsTab)
    aimbotTab.Visible = (tab == aimbotTab)
    
    espTabButton.BackgroundColor3 = (tab == espTab) and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(50, 50, 50)
    movementTabButton.BackgroundColor3 = (tab == movementTab) and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(50, 50, 50)
    visualsTabButton.BackgroundColor3 = (tab == visualsTab) and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(50, 50, 50)
    aimbotTabButton.BackgroundColor3 = (tab == aimbotTab) and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(50, 50, 50)
end

espTabButton.MouseButton1Click:Connect(function() switchToTab(espTab) end)
movementTabButton.MouseButton1Click:Connect(function() switchToTab(movementTab) end)
visualsTabButton.MouseButton1Click:Connect(function() switchToTab(visualsTab) end)
aimbotTabButton.MouseButton1Click:Connect(function() switchToTab(aimbotTab) end)

-- Add this function near the top with other helper functions
-- Improved team check function
function IsEnemy(playerToCheck)
    -- Skip if same player
    if playerToCheck == player then return false end
    
    -- Standard team check
    if player.Team and playerToCheck.Team then
        return playerToCheck.Team ~= player.Team
    end
    
    -- Special case for FPS games without proper teams
    if playerToCheck.Character and player.Character then
        -- Check if players are on opposite teams by character appearance
        local theirShirt = playerToCheck.Character:FindFirstChildOfClass("Shirt")
        local myShirt = player.Character:FindFirstChildOfClass("Shirt")
        
        if theirShirt and myShirt and theirShirt.ShirtTemplate ~= myShirt.ShirtTemplate then
            return true
        end
        
        -- Check for different colored body parts
        local theirHead = playerToCheck.Character:FindFirstChild("Head")
        local myHead = player.Character:FindFirstChild("Head")
        
        if theirHead and myHead and theirHead.Color ~= myHead.Color then
            return true
        end
    end
    
    -- Default to enemy if no team system detected
    return true
end

-- Modified to find player closest to crosshair
-- Modified GetClosestPlayerToCursor with backtrack support (replace existing one)
function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local smallestAngle = math.huge
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    local cameraPos = camera.CFrame.Position
    local cameraLook = camera.CFrame.LookVector
    
    for _, playerToCheck in pairs(game:GetService("Players"):GetPlayers()) do
        if playerToCheck ~= player and playerToCheck.Character and playerToCheck.Character:FindFirstChild("Humanoid") and 
           playerToCheck.Character.Humanoid.Health > 0 and playerToCheck.Character:FindFirstChild(Config.AimbotHitPart) and
           IsEnemy(playerToCheck) then
            
            local part = playerToCheck.Character[Config.AimbotHitPart]
            local partPos = part.Position
            
            -- Check if we have backtrack data for this player
            if backtrackEnabled and backtrackRecords[playerToCheck] and #backtrackRecords[playerToCheck].Positions > 0 then
                -- Use position from 12 ticks ago (approximately 200ms delay)
                local tickIndex = math.min(maxBacktrackTicks, #backtrackRecords[playerToCheck].Positions)
                partPos = backtrackRecords[playerToCheck].Positions[tickIndex]
            end
            
            local vector, onScreen = camera:WorldToViewportPoint(partPos)
            
            if onScreen then
                -- Calculate angle between camera look vector and direction to player
                local directionToPlayer = (partPos - cameraPos).Unit
                local angle = math.deg(math.acos(cameraLook:Dot(directionToPlayer)))
                
                -- Also check screen distance for FOV limitation
                local screenDistance = (Vector2.new(vector.X, vector.Y) - mousePos).Magnitude
                
                if angle < Config.AimbotFOV and screenDistance < Config.AimbotFOV and angle < smallestAngle then
                    closestPlayer = playerToCheck
                    smallestAngle = angle
                end
            end
        end
    end
    
    return closestPlayer
end

-- Update the SilentAim function to use this targeting
-- Modified UpdateSilentAim with backtrack support (replace existing one)
function UpdateSilentAim()
    if silentAimConnection then
        silentAimConnection:Disconnect()
        silentAimConnection = nil
        
        if originalNamecall then
            getgenv().namecall = originalNamecall
            originalNamecall = nil
        end
    end
    
    if Config.SilentAimEnabled and Config.AimbotEnabled then
        originalNamecall = getgenv().namecall
        
        getgenv().namecall = newcclosure(function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            
            if (method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay") then
                local closestPlayer = GetClosestPlayerToCursor()
                if closestPlayer and closestPlayer.Character then
                    local hitPart = closestPlayer.Character:FindFirstChild(Config.AimbotHitPart)
                    if hitPart then
                        local targetPosition = hitPart.Position
                        
                        -- Apply backtrack if available
                        if backtrackEnabled and backtrackRecords[closestPlayer] and #backtrackRecords[closestPlayer].Positions > 0 then
                            local tickIndex = math.min(maxBacktrackTicks, #backtrackRecords[closestPlayer].Positions)
                            targetPosition = backtrackRecords[closestPlayer].Positions[tickIndex]
                            
                            -- If aiming for head, use head position from backtrack
                            if Config.AimbotHitPart == "Head" and #backtrackRecords[closestPlayer].HeadPositions >= tickIndex then
                                targetPosition = backtrackRecords[closestPlayer].HeadPositions[tickIndex]
                            end
                        end
                        
                        -- Use hitbox expansion
                        local expansion = Config.HitboxExpansion / 100
                        local partSize = hitPart.Size * (1 + expansion)
                        
                        -- Calculate random position within expanded hitbox
                        local randomOffset = Vector3.new(
                            (math.random() - 0.5) * partSize.X,
                            (math.random() - 0.5) * partSize.Y,
                            (math.random() - 0.5) * partSize.Z
                        )
                        
                        return targetPosition + randomOffset
                    end
                end
            end
            
            return originalNamecall(self, unpack(args))
        end)
        
        silentAimConnection = true
    end
end

-- Backtrack recording function (place with other utility functions)
function UpdateBacktrackRecords()
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                -- Initialize player's record if not exists
                if not backtrackRecords[player] then
                    backtrackRecords[player] = {
                        Positions = {},
                        Timestamps = {},
                        HeadPositions = {}
                    }
                end
                
                -- Add current position to history
                table.insert(backtrackRecords[player].Positions, 1, rootPart.Position)
                table.insert(backtrackRecords[player].Timestamps, 1, tick())
                
                -- Also track head position if needed
                local head = player.Character:FindFirstChild("Head")
                if head then
                    table.insert(backtrackRecords[player].HeadPositions, 1, head.Position)
                end
                
                -- Remove old records (keep only last 12 ticks)
                while #backtrackRecords[player].Positions > maxBacktrackTicks do
                    table.remove(backtrackRecords[player].Positions)
                    table.remove(backtrackRecords[player].Timestamps)
                    table.remove(backtrackRecords[player].HeadPositions)
                end
            end
        end
    end
end

-- Helper function to create toggle buttons
local function CreateToggle(parent, text, configKey, yPosition)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 30)
    toggleFrame.Position = UDim2.new(0, 0, 0, yPosition)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent
    
    local toggleText = Instance.new("TextLabel")
    toggleText.Size = UDim2.new(0.7, 0, 1, 0)
    toggleText.Position = UDim2.new(0, 0, 0, 0)
    toggleText.BackgroundTransparency = 1
    toggleText.Text = text
    toggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleText.Font = Enum.Font.SourceSans
    toggleText.TextSize = 14
    toggleText.TextXAlignment = Enum.TextXAlignment.Left
    toggleText.Parent = toggleFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0.3, -5, 1, -5)
    toggleButton.Position = UDim2.new(0.7, 0, 0, 2.5)
    toggleButton.BackgroundColor3 = Config[configKey] and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    toggleButton.Text = Config[configKey] and "ON" or "OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.SourceSans
    toggleButton.TextSize = 14
    toggleButton.Parent = toggleFrame
    
    toggleButton.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        toggleButton.BackgroundColor3 = Config[configKey] and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        toggleButton.Text = Config[configKey] and "ON" or "OFF"
        
        if configKey == "SpinbotEnabled" then
            UpdateSpinbot()
        elseif configKey == "BunnyHopEnabled" then
            UpdateBunnyHop()
        elseif configKey == "WalkSpeedEnabled" then
            UpdateWalkSpeed()
        elseif configKey == "BulletTracersEnabled" then
            if Config.BulletTracersEnabled then
                SetupBulletTracers()
            else
                CleanupBulletTracers()
            end
        elseif configKey == "AimbotEnabled" then
            UpdateAimbot()
        elseif configKey == "SilentAimEnabled" then
            UpdateSilentAim()
        elseif configKey == "ShowFOV" then
            UpdateFOVCircle()
        elseif configKey == "ForceThirdPerson" then
            UpdateThirdPerson()
        end
    end)
    
    return toggleFrame
end

-- Helper function to create sliders
local function CreateSlider(parent, text, configKey, min, max, yPosition)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 50)
    sliderFrame.Position = UDim2.new(0, 0, 0, yPosition)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent
    
    local sliderText = Instance.new("TextLabel")
    sliderText.Size = UDim2.new(1, 0, 0, 20)
    sliderText.Position = UDim2.new(0, 0, 0, 0)
    sliderText.BackgroundTransparency = 1
    sliderText.Text = text .. ": " .. Config[configKey]
    sliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
    sliderText.Font = Enum.Font.SourceSans
    sliderText.TextSize = 14
    sliderText.TextXAlignment = Enum.TextXAlignment.Left
    sliderText.Parent = sliderFrame
    
    local slider = Instance.new("TextBox")
    slider.Size = UDim2.new(1, 0, 0, 20)
    slider.Position = UDim2.new(0, 0, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    slider.TextColor3 = Color3.fromRGB(255, 255, 255)
    slider.Font = Enum.Font.SourceSans
    slider.TextSize = 14
    slider.Text = tostring(Config[configKey])
    slider.Parent = sliderFrame
    
    slider.FocusLost:Connect(function()
        local value = tonumber(slider.Text)
        if value and value >= min and value <= max then
            Config[configKey] = value
            sliderText.Text = text .. ": " .. Config[configKey]
            
            if configKey == "SpinbotSpeed" then
                UpdateSpinbot()
            elseif configKey == "WalkSpeed" then
                UpdateWalkSpeed()
            elseif configKey == "AimbotFOV" then
                UpdateFOVCircle()
            elseif configKey == "AimbotSmoothness" then
                -- No need to update anything, will be used in the aimbot loop
            elseif configKey == "ThirdPersonDistance" then
                UpdateThirdPerson()
            elseif configKey == "HitboxExpansion" then
                -- No need to update anything, will be used in silent aim
            end
        else
            slider.Text = tostring(Config[configKey])
        end
    end)
    
    return sliderFrame
end

-- Helper function to create color pickers
local function CreateColorPicker(parent, text, configKey, yPosition)
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(1, 0, 0, 50)
    colorFrame.Position = UDim2.new(0, 0, 0, yPosition)
    colorFrame.BackgroundTransparency = 1
    colorFrame.Parent = parent
    
    local colorText = Instance.new("TextLabel")
    colorText.Size = UDim2.new(0.7, 0, 0, 20)
    colorText.Position = UDim2.new(0, 0, 0, 0)
    colorText.BackgroundTransparency = 1
    colorText.Text = text
    colorText.TextColor3 = Color3.fromRGB(255, 255, 255)
    colorText.Font = Enum.Font.SourceSans
    colorText.TextSize = 14
    colorText.TextXAlignment = Enum.TextXAlignment.Left
    colorText.Parent = colorFrame
    
    local colorBox = Instance.new("TextButton")
    colorBox.Size = UDim2.new(0.3, -5, 0, 20)
    colorBox.Position = UDim2.new(0.7, 0, 0, 0)
    colorBox.BackgroundColor3 = Config[configKey]
    colorBox.Text = ""
    colorBox.Parent = colorFrame
    
    local rSlider = Instance.new("TextBox")
    rSlider.Size = UDim2.new(0.3, -5, 0, 20)
    rSlider.Position = UDim2.new(0, 0, 0, 25)
    rSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    rSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    rSlider.Font = Enum.Font.SourceSans
    rSlider.TextSize = 14
    rSlider.Text = tostring(math.floor(Config[configKey].r * 255))
    rSlider.Parent = colorFrame
    
    local gSlider = Instance.new("TextBox")
    gSlider.Size = UDim2.new(0.3, -5, 0, 20)
    gSlider.Position = UDim2.new(0.33, 0, 0, 25)
    gSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    gSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    gSlider.Font = Enum.Font.SourceSans
    gSlider.TextSize = 14
    gSlider.Text = tostring(math.floor(Config[configKey].g * 255))
    gSlider.Parent = colorFrame
    
    local bSlider = Instance.new("TextBox")
    bSlider.Size = UDim2.new(0.3, -5, 0, 20)
    bSlider.Position = UDim2.new(0.66, 0, 0, 25)
    bSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    bSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    bSlider.Font = Enum.Font.SourceSans
    bSlider.TextSize = 14
    bSlider.Text = tostring(math.floor(Config[configKey].b * 255))
    bSlider.Parent = colorFrame
    
    local function updateColor()
        local r = math.clamp(tonumber(rSlider.Text) or 0, 0, 255) / 255
        local g = math.clamp(tonumber(gSlider.Text) or 0, 0, 255) / 255
        local b = math.clamp(tonumber(bSlider.Text) or 0, 0, 255) / 255
        Config[configKey] = Color3.new(r, g, b)
        colorBox.BackgroundColor3 = Config[configKey]
        
        if configKey == "FOVColor" then
            if fovCircle then
                fovCircle.Color = Config.FOVColor
            end
        end
    end
    
    rSlider.FocusLost:Connect(updateColor)
    gSlider.FocusLost:Connect(updateColor)
    bSlider.FocusLost:Connect(updateColor)
    
    colorBox.MouseButton1Click:Connect(function()
        rSlider.Text = tostring(math.random(0, 255))
        gSlider.Text = tostring(math.random(0, 255))
        bSlider.Text = tostring(math.random(0, 255))
        updateColor()
    end)
    
    return colorFrame
end

-- Helper function to create dropdowns
local function CreateDropdown(parent, text, configKey, options, yPosition)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, 0, 0, 50)
    dropdownFrame.Position = UDim2.new(0, 0, 0, yPosition)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.Parent = parent
    
    local dropdownText = Instance.new("TextLabel")
    dropdownText.Size = UDim2.new(1, 0, 0, 20)
    dropdownText.Position = UDim2.new(0, 0, 0, 0)
    dropdownText.BackgroundTransparency = 1
    dropdownText.Text = text
    dropdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdownText.Font = Enum.Font.SourceSans
    dropdownText.TextSize = 14
    dropdownText.TextXAlignment = Enum.TextXAlignment.Left
    dropdownText.Parent = dropdownFrame
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(1, 0, 0, 25)
    dropdown.Position = UDim2.new(0, 0, 0, 25)
    dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.Font = Enum.Font.SourceSans
    dropdown.TextSize = 14
    dropdown.Text = Config[configKey]
    dropdown.Parent = dropdownFrame
    
    local dropdownOptions = Instance.new("Frame")
    dropdownOptions.Size = UDim2.new(1, 0, 0, #options * 25)
    dropdownOptions.Position = UDim2.new(0, 0, 1, 0)
    dropdownOptions.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    dropdownOptions.Visible = false
    dropdownOptions.Parent = dropdown
    
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0, 25)
        optionButton.Position = UDim2.new(0, 0, 0, (i-1)*25)
        optionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        optionButton.Font = Enum.Font.SourceSans
        optionButton.TextSize = 14
        optionButton.Text = option
        optionButton.Parent = dropdownOptions
        
        optionButton.MouseButton1Click:Connect(function()
            Config[configKey] = option
            dropdown.Text = option
            dropdownOptions.Visible = false
            
            if configKey == "BunnyHopKey" then
                UpdateBunnyHop()
            elseif configKey == "AimbotHitPart" then
                -- No need to update anything, will be used in the aimbot loop
            end
        end)
    end
    
    dropdown.MouseButton1Click:Connect(function()
        dropdownOptions.Visible = not dropdownOptions.Visible
    end)
    
    return dropdownFrame
end

-- Create ESP Controls
local yPosition = 0
CreateToggle(espTab, "Enable ESP", "Box", yPosition)
yPosition = yPosition + 35
CreateToggle(espTab, "Box Outline", "BoxOutline", yPosition)
yPosition = yPosition + 35
CreateToggle(espTab, "Health Bar", "HealthBar", yPosition)
yPosition = yPosition + 35
CreateToggle(espTab, "Names", "Names", yPosition)
yPosition = yPosition + 35
CreateSlider(espTab, "Max Distance", "MaxDistance", 0, 1000, yPosition)
yPosition = yPosition + 55
CreateDropdown(espTab, "Health Bar Side", "HealthBarSide", {"Left", "Right", "Bottom"}, yPosition)

-- Create Movement Controls
yPosition = 0
CreateToggle(movementTab, "Spinbot", "SpinbotEnabled", yPosition)
yPosition = yPosition + 35
CreateSlider(movementTab, "Spinbot Speed", "SpinbotSpeed", 1, 100, yPosition)
yPosition = yPosition + 55
CreateToggle(movementTab, "Bunny Hop", "BunnyHopEnabled", yPosition)
yPosition = yPosition + 35
CreateDropdown(movementTab, "BunnyHop Key", "BunnyHopKey", keybindOptions, yPosition)
yPosition = yPosition + 55
CreateToggle(movementTab, "WalkSpeed", "WalkSpeedEnabled", yPosition)
yPosition = yPosition + 35
CreateSlider(movementTab, "WalkSpeed Value", "WalkSpeed", 16, 100, yPosition)
yPosition = yPosition + 55
CreateToggle(movementTab, "Force Third Person", "ForceThirdPerson", yPosition)
yPosition = yPosition + 35
CreateSlider(movementTab, "Third Person Distance", "ThirdPersonDistance", 1, 20, yPosition)

-- Create Visuals Controls
yPosition = 0
CreateToggle(visualsTab, "Bullet Tracers", "BulletTracersEnabled", yPosition)
yPosition = yPosition + 35
CreateColorPicker(visualsTab, "Tracer Color", "BulletTracerColor", yPosition)
yPosition = yPosition + 55
CreateSlider(visualsTab, "Tracer Thickness", "BulletTracerThickness", 1, 5, yPosition)

-- Create Aimbot Controls
yPosition = 0
CreateToggle(aimbotTab, "Aimbot", "AimbotEnabled", yPosition)
yPosition = yPosition + 35
-- Fixed right mouse button label
local aimbotKeyLabel = Instance.new("TextLabel")
aimbotKeyLabel.Size = UDim2.new(1, 0, 0, 25)
aimbotKeyLabel.Position = UDim2.new(0, 0, 0, yPosition)
aimbotKeyLabel.BackgroundTransparency = 1
aimbotKeyLabel.Text = "Aimbot Key: Right Mouse Button"
aimbotKeyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
aimbotKeyLabel.Font = Enum.Font.SourceSans
aimbotKeyLabel.TextSize = 14
aimbotKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
aimbotKeyLabel.Parent = aimbotTab
yPosition = yPosition + 30
CreateToggle(aimbotTab, "Silent Aim", "SilentAimEnabled", yPosition)
yPosition = yPosition + 35
CreateDropdown(aimbotTab, "Hit Part", "AimbotHitPart", {"Head", "HumanoidRootPart", "Torso"}, yPosition)
yPosition = yPosition + 55
CreateSlider(aimbotTab, "Hitbox Expansion", "HitboxExpansion", 1, 100, yPosition)  -- Changed max from 3 to 10
yPosition = yPosition + 55
CreateSlider(aimbotTab, "Aimbot FOV", "AimbotFOV", 10, 500, yPosition)
yPosition = yPosition + 55
CreateSlider(aimbotTab, "Smoothness", "AimbotSmoothness", 1, 20, yPosition)
yPosition = yPosition + 55
CreateToggle(aimbotTab, "Show FOV", "ShowFOV", yPosition)
yPosition = yPosition + 35
CreateColorPicker(aimbotTab, "FOV Color", "FOVColor", yPosition)

-- ESP Functions
function NewLine(thickness, color)
    local line = Drawing.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(0, 0)
    line.Color = color 
    line.Thickness = thickness
    line.Transparency = 1
    return line
end

function CreateEsp(Player)
    local Box, BoxOutline, Name, HealthBar, HealthBarOutline = Drawing.new("Square"), Drawing.new("Square"), Drawing.new("Text"), Drawing.new("Square"), Drawing.new("Square")

    local Updater = runService.RenderStepped:Connect(function()
        if espEnabled and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.Humanoid.Health > 0 and Player.Character:FindFirstChild("Head") then
            local Target2dPosition, IsVisible = camera:WorldToViewportPoint(Player.Character.HumanoidRootPart.Position)
            local distance = (camera.CFrame.p - Player.Character.HumanoidRootPart.Position).magnitude
            local scale_factor = 1 / (Target2dPosition.Z * math.tan(math.rad(camera.FieldOfView * 0.5)) * 2) * 100
            local width, height = math.floor(40 * scale_factor), math.floor(60 * scale_factor)

            if distance <= Config.MaxDistance then
                -- Box
                if Config.Box then
                    Box.Visible = IsVisible
                    Box.Color = Config.BoxColor
                    Box.Size = Vector2.new(width, height)
                    Box.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2, Target2dPosition.Y - Box.Size.Y / 2)
                    Box.Thickness = 1
                    Box.ZIndex = 69

                    if Config.BoxOutline then
                        BoxOutline.Visible = IsVisible
                        BoxOutline.Color = Config.BoxOutlineColor
                        BoxOutline.Size = Vector2.new(width, height)
                        BoxOutline.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2, Target2dPosition.Y - Box.Size.Y / 2)
                        BoxOutline.Thickness = 3
                        BoxOutline.ZIndex = 1
                    else
                        BoxOutline.Visible = false
                    end
                else
                    Box.Visible = false
                    BoxOutline.Visible = false
                end

                -- Name
                if Config.Names then
                    Name.Visible = IsVisible
                    Name.Color = Config.NamesColor
                    Name.Text = Player.Name .. " " .. math.floor(distance) .. "m"
                    Name.Center = true
                    Name.Outline = Config.NamesOutline
                    Name.OutlineColor = Config.NamesOutlineColor
                    Name.Position = Vector2.new(Target2dPosition.X, Target2dPosition.Y - height * 0.5 - 15)
                    Name.Font = Config.NamesFont
                    Name.Size = Config.NamesSize
                else
                    Name.Visible = false
                end

                -- HealthBar
                if Config.HealthBar then
                    if Config.HealthBarOutlineToggle then
                        HealthBarOutline.Visible = IsVisible
                        HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
                        HealthBarOutline.Filled = true
                        HealthBarOutline.ZIndex = 1
                        HealthBarOutline.Size = Vector2.new(Config.HealthBarOutlineThickness, height)
                    else
                        HealthBarOutline.Visible = false
                    end

                    HealthBar.Visible = IsVisible
                    HealthBar.Color = Color3.fromRGB(255, 0, 0):lerp(Color3.fromRGB(0, 255, 0), Player.Character.Humanoid.Health / Player.Character.Humanoid.MaxHealth)
                    HealthBar.Thickness = Config.HealthBarThickness
                    HealthBar.Filled = true
                    HealthBar.ZIndex = 69

                    if Config.HealthBarSide == "Left" then
                        HealthBarOutline.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2 - 5, Target2dPosition.Y - Box.Size.Y / 2)
                        HealthBar.Size = Vector2.new(1, -(HealthBarOutline.Size.Y - 2) * (Player.Character.Humanoid.Health / Player.Character.Humanoid.MaxHealth))
                        HealthBar.Position = HealthBarOutline.Position + Vector2.new(1, -1 + HealthBarOutline.Size.Y)
                    elseif Config.HealthBarSide == "Bottom" then
                        HealthBarOutline.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2, Target2dPosition.Y - Box.Size.Y / 2) + Vector2.new(0, height + 2)
                        HealthBar.Size = Vector2.new((HealthBarOutline.Size.X - 2) * (Player.Character.Humanoid.Health / Player.Character.Humanoid.MaxHealth), 1)
                        HealthBar.Position = HealthBarOutline.Position + Vector2.new(1, -1 + HealthBarOutline.Size.Y)
                    elseif Config.HealthBarSide == "Right" then
                        HealthBarOutline.Position = Vector2.new(Target2dPosition.X - Box.Size.X / 2 + width + 1, Target2dPosition.Y - Box.Size.Y / 2)
                        HealthBar.Size = Vector2.new(1, -(HealthBarOutline.Size.Y - 2) * (Player.Character.Humanoid.Health / Player.Character.Humanoid.MaxHealth))
                        HealthBar.Position = HealthBarOutline.Position + Vector2.new(1, -1 + HealthBarOutline.Size.Y)
                    end
                else
                    HealthBar.Visible = false
                    HealthBarOutline.Visible = false
                end
            else
                Box.Visible = false
                BoxOutline.Visible = false
                Name.Visible = false
                HealthBar.Visible = false
                HealthBarOutline.Visible = false
            end
        else
            Box.Visible = false
            BoxOutline.Visible = false
            Name.Visible = false
            HealthBar.Visible = false
            HealthBarOutline.Visible = false
        end
    end)

    game:GetService("Players").PlayerRemoving:Connect(function(RemovedPlayer)
        if RemovedPlayer == Player then
            Updater:Disconnect()
            Box:Remove()
            BoxOutline:Remove()
            Name:Remove()
            HealthBar:Remove()
            HealthBarOutline:Remove()
        end
    end)
end

-- Initialize ESP for all players
for _, v in pairs(game:GetService("Players"):GetPlayers()) do
    if v ~= player then
        CreateEsp(v)
    end
end

game:GetService("Players").PlayerAdded:Connect(function(newPlayer)
    newPlayer.CharacterAdded:Wait()
    CreateEsp(newPlayer)
end)

-- Movement Functions
function GetKeyCodeFromString(keyName)
    local keyMap = {
        ["Space"] = Enum.KeyCode.Space,
        ["LeftShift"] = Enum.KeyCode.LeftShift,
        ["RightShift"] = Enum.KeyCode.RightShift,
        ["LeftControl"] = Enum.KeyCode.LeftControl,
        ["RightControl"] = Enum.KeyCode.RightControl,
        ["Q"] = Enum.KeyCode.Q,
        ["E"] = Enum.KeyCode.E,
        ["F"] = Enum.KeyCode.F,
        ["C"] = Enum.KeyCode.C,
        ["V"] = Enum.KeyCode.V,
        ["X"] = Enum.KeyCode.X,
        ["Z"] = Enum.KeyCode.Z,
        ["LeftAlt"] = Enum.KeyCode.LeftAlt,
        ["RightAlt"] = Enum.KeyCode.RightAlt,
        ["RightMouseButton"] = Enum.UserInputType.MouseButton2
    }
    return keyMap[keyName] or Enum.KeyCode.Space
end

function UpdateSpinbot()
    if spinbotConnection then
        spinbotConnection:Disconnect()
        spinbotConnection = nil
    end
    
    if Config.SpinbotEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        spinbotConnection = runService.RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(Config.SpinbotSpeed), 0)
            end
        end)
    end
end

-- Improved Bunny Hop Function
function UpdateBunnyHop()
    if bhopConnection then
        bhopConnection:Disconnect()
        bhopConnection = nil
    end
    
    if Config.BunnyHopEnabled then
        local keyCode = GetKeyCodeFromString(Config.BunnyHopKey)
        
        -- Store the original jump power
        local originalJumpPower = player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").JumpPower or 50
        
        bhopConnection = runService.Heartbeat:Connect(function()
            if bhopActive and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                
                -- Check if we're on the ground
                if humanoid.FloorMaterial ~= Enum.Material.Air then
                    -- Increase jump power for better bhop effect
                    humanoid.JumpPower = originalJumpPower * 1.2
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    
                    -- Optional: Add slight forward velocity for momentum
                    if player.Character:FindFirstChild("HumanoidRootPart") then
                        local rootPart = player.Character.HumanoidRootPart
                        local lookVector = rootPart.CFrame.LookVector
                        rootPart.Velocity = rootPart.Velocity + (lookVector * 5)
                    end
                else
                    -- Reset jump power when not jumping
                    humanoid.JumpPower = originalJumpPower
                end
            end
        end)
        
        -- Input handling
        uis.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == keyCode then
                bhopActive = true
            end
        end)
        
        uis.InputEnded:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == keyCode then
                bhopActive = false
                
                -- Reset jump power when stopping
                if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                    player.Character:FindFirstChildOfClass("Humanoid").JumpPower = originalJumpPower
                end
            end
        end)
    else
        bhopActive = false
    end
end

function UpdateWalkSpeed()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        if Config.WalkSpeedEnabled then
            player.Character.Humanoid.WalkSpeed = Config.WalkSpeed
        else
            player.Character.Humanoid.WalkSpeed = originalWalkspeed
        end
    end
end

-- Force Third Person Function
function UpdateThirdPerson()
    if thirdPersonConnection then
        thirdPersonConnection:Disconnect()
        thirdPersonConnection = nil
    end
    
    if Config.ForceThirdPerson and player.Character and player.Character:FindFirstChild("Humanoid") then
        -- Force camera mode to classic (required for third person to work)
        local humanoid = player.Character.Humanoid
        humanoid.CameraMode = Enum.CameraMode.Classic
        
        thirdPersonConnection = runService.RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                -- Set camera offset for third person view
                humanoid.CameraOffset = Vector3.new(0, 0, -Config.ThirdPersonDistance)
                
                -- Force camera subject to humanoid root part
                if player.Character:FindFirstChild("HumanoidRootPart") then
                    camera.CameraSubject = player.Character.HumanoidRootPart
                end
            end
        end)
    elseif player.Character and player.Character:FindFirstChild("Humanoid") then
        -- Reset to first person
        player.Character.Humanoid.CameraOffset = Vector3.new(0, 0, 0)
        player.Character.Humanoid.CameraMode = Enum.CameraMode.Classic
    end
end

-- Bullet Tracer Functions
function SetupBulletTracers()
    CleanupBulletTracers()
    
    if not Config.BulletTracersEnabled then return end
    
    -- Listen for new bullets
    local function processBullet(bullet)
        if bullet:IsA("BasePart") and (bullet.Name == "Bullet" or bullet.Name == "Projectile") then
            local tracer = NewLine(Config.BulletTracerThickness, Config.BulletTracerColor)
            local lastPosition = bullet.Position
            
            local connection
            connection = runService.RenderStepped:Connect(function()
                if bullet and bullet.Parent then
                    local startPos, startVisible = camera:WorldToViewportPoint(lastPosition)
                    local endPos, endVisible = camera:WorldToViewportPoint(bullet.Position)
                    
                    if startVisible and endVisible then
                        tracer.From = Vector2.new(startPos.X, startPos.Y)
                        tracer.To = Vector2.new(endPos.X, endPos.Y)
                        tracer.Visible = true
                    else
                        tracer.Visible = false
                    end
                    
                    lastPosition = bullet.Position
                else
                    tracer.Visible = false
                    tracer:Remove()
                    if connection then
                        connection:Disconnect()
                    end
                end
            end)
            
            table.insert(bulletTracerConnections, connection)
        end
    end
    
    -- Process existing bullets
    for _, v in pairs(workspace:GetDescendants()) do
        processBullet(v)
    end
    
    -- Listen for new bullets
    local bulletAddedConnection = workspace.DescendantAdded:Connect(processBullet)
    table.insert(bulletTracerConnections, bulletAddedConnection)
end

function CleanupBulletTracers()
    for _, connection in ipairs(bulletTracerConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    bulletTracerConnections = {}
end

-- Aimbot Functions
function UpdateFOVCircle()
    if fovCircle then
        fovCircle:Remove()
        fovCircle = nil
    end
    
    if Config.ShowFOV and Config.AimbotEnabled then
        fovCircle = Drawing.new("Circle")
        fovCircle.Visible = true
        fovCircle.Thickness = 1
        fovCircle.Color = Config.FOVColor
        fovCircle.Transparency = 1
        fovCircle.Filled = false
        fovCircle.Radius = Config.AimbotFOV
        fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        
        runService.RenderStepped:Connect(function()
            fovCircle.Radius = Config.AimbotFOV
            fovCircle.Color = Config.FOVColor
            fovCircle.Visible = Config.ShowFOV and Config.AimbotEnabled
        end)
    end
end

function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 and v.Character:FindFirstChild(Config.AimbotHitPart) then
            local part = v.Character[Config.AimbotHitPart]
            local vector, onScreen = camera:WorldToViewportPoint(part.Position)
            
            if onScreen then
                local distance = (Vector2.new(vector.X, vector.Y) - Vector2.new(mouse.X, mouse.Y)).magnitude
                
                if distance < Config.AimbotFOV and distance < shortestDistance then
                    closestPlayer = v
                    shortestDistance = distance
                end
            end
        end
    end
    
    return closestPlayer
end

function UpdateAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    
    if Config.AimbotEnabled then
        aimbotConnection = runService.RenderStepped:Connect(function()
            if uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local closestPlayer = GetClosestPlayerToCursor()
                
                if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild(Config.AimbotHitPart) then
                    target = closestPlayer
                    local part = closestPlayer.Character[Config.AimbotHitPart]
                    local cameraPosition = camera.CFrame.Position
                    local partPosition = part.Position
                    
                    -- Calculate the direction to the target
                    local direction = (partPosition - cameraPosition).unit
                    
                    -- Smooth the aim
                    local currentLook = camera.CFrame.LookVector
                    local smoothness = Config.AimbotSmoothness
                    local smoothedLook = currentLook:Lerp(direction, 1 / smoothness)
                    
                    -- Set the camera to look at the target
                    camera.CFrame = CFrame.new(cameraPosition, cameraPosition + smoothedLook)
                else
                    target = nil
                end
            else
                target = nil
            end
        end)
    else
        target = nil
    end
    
    UpdateFOVCircle()
end

function UpdateSilentAim()
    if silentAimConnection then
        silentAimConnection:Disconnect()
        silentAimConnection = nil
        
        if originalNamecall then
            getgenv().namecall = originalNamecall
            originalNamecall = nil
        end
    end
    
    if Config.SilentAimEnabled and Config.AimbotEnabled then
        originalNamecall = getgenv().namecall
        
        getgenv().namecall = newcclosure(function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            
            if method == "FindPartOnRayWithIgnoreList" and target and target.Character then
                local hitPart = target.Character:FindFirstChild(Config.AimbotHitPart)
                if hitPart then
                    -- Use the Config.HitboxExpansion value (now set to 40)
                    local expansionMultiplier = Config.HitboxExpansion
                    local partSize = hitPart.Size
                    local expandedSize = partSize * expansionMultiplier
                    
                    -- Create expanded hitbox
                    local expandedCFrame = hitPart.CFrame
                    local expandedPart = Instance.new("Part")
                    expandedPart.Size = expandedSize
                    expandedPart.CFrame = expandedCFrame
                    expandedPart.Transparency = 1
                    expandedPart.CanCollide = false
                    expandedPart.Anchored = true
                    expandedPart.Parent = workspace
                    
                    -- Return position within the expanded hitbox
                    local randomOffset = Vector3.new(
                        (math.random() - 0.5) * expandedSize.X,
                        (math.random() - 0.5) * expandedSize.Y,
                        (math.random() - 0.5) * expandedSize.Z
                    )
                    local guaranteedHitPosition = hitPart.Position + randomOffset
                    
                    expandedPart:Destroy()
                    
                    return guaranteedHitPosition
                end
            end
            
            return originalNamecall(self, unpack(args))
        end)
        
        silentAimConnection = true
        
        -- Visual feedback for expanded hitboxes
        if target and target.Character and target.Character:FindFirstChild(Config.AimbotHitPart) then
            local part = target.Character[Config.AimbotHitPart]
            part.Size = part.Size * Config.HitboxExpansion
            part.Transparency = 0.7
        end
    else
        -- Reset visual hitboxes when disabled
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild(Config.AimbotHitPart) then
                local part = player.Character[Config.AimbotHitPart]
                part.Size = part.Size / Config.HitboxExpansion
                part.Transparency = 0
            end
        end
    end
end

-- Character added/removed events
player.CharacterAdded:Connect(function(character)
    originalWalkspeed = character:WaitForChild("Humanoid").WalkSpeed
    UpdateWalkSpeed()
    UpdateThirdPerson()
end)

-- Toggle GUI with key
uis.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        guiEnabled = not guiEnabled
        mainFrame.Visible = guiEnabled
    end
end)

local backtrackUpdateConnection = runService.Heartbeat:Connect(function()
    UpdateBacktrackRecords()
end)

-- Cleanup connection when script ends
game:GetService("Players").PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player then
        if backtrackUpdateConnection then
            backtrackUpdateConnection:Disconnect()
        end
    end
end)

-- Initialize features (your existing initialization code)
UpdateSpinbot()
UpdateBunnyHop()
UpdateWalkSpeed()
UpdateThirdPerson()
SetupBulletTracers()
UpdateAimbot()
UpdateSilentAim()
