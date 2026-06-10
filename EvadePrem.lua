-- Load Library Obsidian
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/rickyaditya511/hac/refs/heads/main/Library.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ================================
--          ANTI AFK
-- ================================
local vu = VirtualUser
player.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), camera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), camera.CFrame)
end)

-- ================================
--          VARIABLES
-- ================================
local features = {
    bhop = false,
    trimp = false,
    carry = false,
    revive = false,
    fly = false,
    slide = false,
    flySpeed = 1.5,
}

-- Floating button references
local bhopFloatBtn = nil
local trimpFloatBtn = nil
local carryFloatBtn = nil
local reviveFloatBtn = nil
local lagFloatBtn = nil

-- Helper functions
local function getChar() return player.Character end
local function getHum() local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end

-- Floating button creator
local function createFloatingButton(name, callback)
    local btn = Library:AddDraggableButton(name .. ": OFF", callback, true, false)
    btn.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    btn.Button.TextColor3 = Color3.new(1, 1, 1)
    btn.Button.TextScaled = true
    btn.Button.Font = Enum.Font.GothamBold
    return btn
end

-- ================================
--          BHOP
-- ================================
local function bhopLoop()
    while features.bhop do
        RunService.Heartbeat:Wait()
        local hum = getHum()
        local root = getRoot()
        if hum and root then
            local ray = Ray.new(root.Position, Vector3.new(0, -5, 0))
            local hit = workspace:FindPartOnRay(ray, getChar())
            if hit then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end

local function toggleBhopFloat()
    if bhopFloatBtn then
        bhopFloatBtn.Button:Destroy()
        bhopFloatBtn = nil
        features.bhop = false
        return
    end
    bhopFloatBtn = createFloatingButton("Bhop", function()
        features.bhop = not features.bhop
        if features.bhop then
            task.spawn(bhopLoop)
            bhopFloatBtn:SetText("Bhop: ON")
            bhopFloatBtn.Button.BackgroundColor3 = Color3.fromRGB(0, 160, 90)
        else
            bhopFloatBtn:SetText("Bhop: OFF")
            bhopFloatBtn.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        end
    end)
end

-- ================================
--          TRIMP
-- ================================
local trimpPower = 85
local function trimpLoop()
    while features.trimp do
        local root = getRoot()
        if root then
            local vel = root.Velocity
            if vel.Y < -8 then
                local ray = Ray.new(root.Position, Vector3.new(0, -12, 0))
                local hit = workspace:FindPartOnRay(ray, getChar())
                if hit then
                    root.Velocity = Vector3.new(vel.X, trimpPower, vel.Z)
                    local p = Instance.new("ParticleEmitter")
                    p.Texture = "rbxassetid://241594180"
                    p.Lifetime = NumberRange.new(0.3)
                    p.Speed = NumberRange.new(0)
                    p.Rate = 150
                    p.Parent = root
                    Debris:AddItem(p, 0.3)
                end
            end
        end
        task.wait()
    end
end

local function toggleTrimpFloat()
    if trimpFloatBtn then
        trimpFloatBtn.Button:Destroy()
        trimpFloatBtn = nil
        features.trimp = false
        return
    end
    trimpFloatBtn = createFloatingButton("Trimp", function()
        features.trimp = not features.trimp
        if features.trimp then
            task.spawn(trimpLoop)
            trimpFloatBtn:SetText("Trimp: ON")
            trimpFloatBtn.Button.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
        else
            trimpFloatBtn:SetText("Trimp: OFF")
            trimpFloatBtn.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        end
    end)
end

-- ================================
--          AUTO CARRY
-- ================================
local carryCooldown = false
local function doCarry(target)
    if carryCooldown then return end
    carryCooldown = true
    pcall(function()
        ReplicatedStorage.Events.Character.Interact:FireServer("Carry", nil, target)
    end)
    task.wait(0.35)
    carryCooldown = false
end

local function carryLoop()
    while features.carry do
        local root = getRoot()
        if root then
            local nearest = nil
            local nearestDist = 20
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local tarRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                    if tarRoot then
                        local dist = (root.Position - tarRoot.Position).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearest = plr.Name
                        end
                    end
                end
            end
            if nearest then doCarry(nearest) end
        end
        task.wait(0.5)
    end
end

local function toggleCarryFloat()
    if carryFloatBtn then
        carryFloatBtn.Button:Destroy()
        carryFloatBtn = nil
        features.carry = false
        return
    end
    carryFloatBtn = createFloatingButton("Carry", function()
        features.carry = not features.carry
        if features.carry then
            task.spawn(carryLoop)
            carryFloatBtn:SetText("Carry: ON")
            carryFloatBtn.Button.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        else
            carryFloatBtn:SetText("Carry: OFF")
            carryFloatBtn.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        end
    end)
end

-- ================================
--          AUTO REVIVE
-- ================================
local reviveCooldown = false
local function doRevive(target)
    if reviveCooldown then return end
    reviveCooldown = true
    local remote = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Character") and ReplicatedStorage.Events.Character:FindFirstChild("Interact")
    if remote then
        pcall(function() remote:FireServer("Revive", true, target) end)
    end
    task.wait(0.5)
    reviveCooldown = false
end

local function reviveLoop()
    while features.revive do
        local root = getRoot()
        if root then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health <= 0 then
                        local tarRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                        if tarRoot and (root.Position - tarRoot.Position).Magnitude <= 15 then
                            doRevive(plr.Name)
                            break
                        end
                    end
                end
            end
        end
        task.wait(0.6)
    end
end

local function toggleReviveFloat()
    if reviveFloatBtn then
        reviveFloatBtn.Button:Destroy()
        reviveFloatBtn = nil
        features.revive = false
        return
    end
    reviveFloatBtn = createFloatingButton("Revive", function()
        features.revive = not features.revive
        if features.revive then
            task.spawn(reviveLoop)
            reviveFloatBtn:SetText("Revive: ON")
            reviveFloatBtn.Button.BackgroundColor3 = Color3.fromRGB(0, 160, 90)
        else
            reviveFloatBtn:SetText("Revive: OFF")
            reviveFloatBtn.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        end
    end)
end

-- ================================
--          FLY
-- ================================
local flyBodyVel, flyBodyGyro = nil, nil

local function startFly()
    local root = getRoot()
    local hum = getHum()
    if not (root and hum) then return end
    features.fly = true
    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.P = 9e4
    flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBodyVel.Parent = root
    flyBodyGyro.Parent = root
    hum.PlatformStand = true
    hum.AutoRotate = false
    task.spawn(function()
        while features.fly do
            local cf = camera.CFrame
            local moveDir = hum.MoveDirection
            local forward = cf:VectorToWorldSpace(Vector3.new(0, 0, -1))
            local right = cf:VectorToWorldSpace(Vector3.new(1, 0, 0))
            local vel = (forward * 40 * features.flySpeed * -moveDir.Z) + (right * 40 * features.flySpeed * -moveDir.X)
            flyBodyVel.Velocity = flyBodyVel.Velocity:Lerp(vel, 0.2)
            flyBodyGyro.CFrame = CFrame.new(Vector3.new(), cf:VectorToWorldSpace(Vector3.new(0, 0, -1)))
            task.wait()
        end
    end)
end

local function stopFly()
    features.fly = false
    if flyBodyVel then flyBodyVel:Destroy() end
    if flyBodyGyro then flyBodyGyro:Destroy() end
    local hum = getHum()
    if hum then
        hum.PlatformStand = false
        hum.AutoRotate = true
    end
end

-- ================================
--          INFINITE SLIDE
-- ================================
local slideFriction = -8
local slideConnection = nil

local function getSlideTable()
    for _, obj in ipairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "Friction") and rawget(obj, "AirStrafeAcceleration") then
            return obj
        end
    end
    return nil
end

local function updateSlideFriction()
    local mt = getSlideTable()
    if not mt then return end
    local gameFolder = workspace:FindFirstChild("Game")
    local playersFolder = gameFolder and gameFolder:FindFirstChild("Players")
    local myData = playersFolder and playersFolder:FindFirstChild(player.Name)
    if myData then
        local state = myData:GetAttribute("State")
        if state == "Slide" then
            pcall(function() myData:SetAttribute("State", "EmotingSlide") end)
        elseif state == "EmotingSlide" then
            mt.Friction = slideFriction
        else
            mt.Friction = 5
        end
    else
        mt.Friction = 5
    end
end

local function enableSlide()
    if slideConnection then return end
    slideConnection = RunService.Heartbeat:Connect(updateSlideFriction)
    player.CharacterAdded:Connect(function() task.wait(0.2) updateSlideFriction() end)
end

local function disableSlide()
    if slideConnection then slideConnection:Disconnect() end
    slideConnection = nil
    local mt = getSlideTable()
    if mt then mt.Friction = 5 end
end

-- ================================
--          LAG SWITCH
-- ================================
local function lagSwitch()
    task.wait(0.5)
end

local function toggleLagFloat()
    if lagFloatBtn then
        lagFloatBtn.Button:Destroy()
        lagFloatBtn = nil
        return
    end
    lagFloatBtn = createFloatingButton("Lag Switch", function()
        lagSwitch()
    end)
    lagFloatBtn:SetText("Lag Switch")
end

-- ================================
--          TELEPORT
-- ================================
local function roofTeleport()
    local root = getRoot()
    if root then
        root.CFrame = root.CFrame + Vector3.new(0, 500, 0)
    end
end

local function tpToDowned()
    local root = getRoot()
    if not root then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health == 0 and plr.Character:FindFirstChild("HumanoidRootPart") then
            root.CFrame = plr.Character.HumanoidRootPart.CFrame
            task.wait(0.1)
            break
        end
    end
end

local clickTpEnabled = false
local clickConnection = nil
local function enableClickTP()
    if clickConnection then return end
    local mouse = player:GetMouse()
    clickConnection = mouse.Button1Down:Connect(function()
        if clickTpEnabled then
            local root = getRoot()
            if root then
                root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end
    end)
end
local function disableClickTP()
    if clickConnection then clickConnection:Disconnect() end
    clickConnection = nil
end

local afkEnabled = false
local afkPart = nil
local afkConnection = nil
local function startAFK()
    if afkPart then afkPart:Destroy() end
    afkPart = Instance.new("Part")
    afkPart.Size = Vector3.new(5, 1, 5)
    afkPart.Position = Vector3.new(0, -1000, 0)
    afkPart.Anchored = true
    afkPart.CanCollide = true
    afkPart.Transparency = 1
    afkPart.Parent = workspace
    afkConnection = RunService.Heartbeat:Connect(function()
        local root = getRoot()
        if root and afkPart then
            root.CFrame = afkPart.CFrame + Vector3.new(0, 3, 0)
        end
    end)
end
local function stopAFK()
    if afkConnection then afkConnection:Disconnect() end
    if afkPart then afkPart:Destroy() end
    afkPart = nil
end

-- ================================
--          GUI OBSIDIAN
-- ================================
local Window = Library:CreateWindow({
    Title = "Astro",
    Footer = "Evade v1. | By Astro",
    Icon = 9513555266,
    IconSize = UDim2.fromOffset(50, 50),
    NotifySide = "Right",
    EnableSidebarResize = true,
    EnableCompacting = true,
    SidebarCompacted = true,
    Size = UDim2.fromOffset(480, 950),
    CornerRadius = 10,
    AutoShow = true,
})

-- ========== MAIN TAB ==========
local mainTab = Window:AddTab("", "zap")

-- LEFT SIDE ATAS - MOVEMENT
local moveGroup = mainTab:AddLeftGroupbox("MOVEMENT", "zap")
moveGroup:AddToggle("Auto Bhop", { Text = "Auto Bhop", Default = false, Callback = function(v) features.bhop = v; if v then task.spawn(bhopLoop) end end })
moveGroup:AddButton("Float: Bhop", { Text = "Float: Bhop", Callback = toggleBhopFloat })
moveGroup:AddDivider()
moveGroup:AddToggle("Auto Trimp", { Text = "Auto Trimp", Default = false, Callback = function(v) features.trimp = v; if v then task.spawn(trimpLoop) end end })
moveGroup:AddButton("Float: Trimp", { Text = "Float: Trimp", Callback = toggleTrimpFloat })
moveGroup:AddDivider()
moveGroup:AddToggle("Auto Carry", { Text = "Auto Carry", Default = false, Callback = function(v) features.carry = v; if v then task.spawn(carryLoop) end end })
moveGroup:AddButton("Float: Carry", { Text = "Float: Carry", Callback = toggleCarryFloat })
moveGroup:AddDivider()
moveGroup:AddToggle("Auto Revive", { Text = "Auto Revive", Default = false, Callback = function(v) features.revive = v; if v then task.spawn(reviveLoop) end end })
moveGroup:AddButton("Float: Revive", { Text = "Float: Revive", Callback = toggleReviveFloat })

-- LEFT SIDE BAWAH - MOVEMENT SETTINGS
local moveSettingsGroup = mainTab:AddLeftGroupbox("MOVEMENT SETTINGS", "settings")

local moveSettings = { Speed = 1500, JumpCap = 1, StrafeAcc = 187 }
local function findMoveTable()
    for _, obj in ipairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "Speed") and rawget(obj, "JumpCap") and rawget(obj, "AirStrafeAcceleration") then
            return obj
        end
    end
    return nil
end
local function applyMoveSettings()
    local mt = findMoveTable()
    if mt then
        mt.Speed = moveSettings.Speed
        mt.JumpCap = moveSettings.JumpCap
        mt.AirStrafeAcceleration = moveSettings.StrafeAcc
    end
end
player.CharacterAdded:Connect(function() task.wait(1) applyMoveSettings() end)

moveSettingsGroup:AddInput("Speed", { Text = "Speed Value", Placeholder = "1500", Numeric = true, Finished = true, Callback = function(v) local n = tonumber(v); if n then moveSettings.Speed = n; applyMoveSettings() end end })
moveSettingsGroup:AddInput("Jump Cap", { Text = "Jump Cap", Placeholder = "1", Numeric = true, Finished = true, Callback = function(v) local n = tonumber(v); if n then moveSettings.JumpCap = n; applyMoveSettings() end end })
moveSettingsGroup:AddInput("Strafe Acceleration", { Text = "Strafe Acceleration", Placeholder = "187", Numeric = true, Finished = true, Callback = function(v) local n = tonumber(v); if n then moveSettings.StrafeAcc = n; applyMoveSettings() end end })

-- RIGHT SIDE ATAS - FLIGHT
local flyGroup = mainTab:AddRightGroupbox("FLIGHT", "wing")
flyGroup:AddToggle("Fly Mode", { Text = "Fly Mode", Default = false, Callback = function(v) if v then startFly() else stopFly() end end })
flyGroup:AddInput("Fly Speed", { Text = "Speed", Placeholder = "1.5", Numeric = true, Finished = true, Callback = function(v) local n = tonumber(v); if n then features.flySpeed = n end end })

-- RIGHT SIDE TENGAH - SLIDE
local slideGroup = mainTab:AddRightGroupbox("SLIDE", "mountain")
slideGroup:AddToggle("Infinite Slide", { Text = "Infinite Slide", Default = false, Callback = function(v) if v then enableSlide() else disableSlide() end end })
slideGroup:AddSlider("Friction", { Text = "Friction Value", Min = -15, Max = 10, Default = slideFriction, Callback = function(v) slideFriction = v; if features.slide then updateSlideFriction() end end })

-- RIGHT SIDE BAWAH - UTILITY
local utilGroup = mainTab:AddRightGroupbox("UTILITY", "settings")
utilGroup:AddButton("Lag Switch", { Text = "Lag Switch (0.5s)", Callback = lagSwitch })
utilGroup:AddButton("Float: Lag Switch", { Text = "Float: Lag Switch", Callback = toggleLagFloat })

-- ========== TELEPORT TAB ==========
local tpTab = Window:AddTab("", "map-pin")

local tpGroup = tpTab:AddLeftGroupbox("TELEPORTS", "navigation")
tpGroup:AddButton("Roof Teleport", { Text = "Roof Teleport", Callback = roofTeleport })
tpGroup:AddButton("TP to Downed Player", { Text = "TP to Downed Player", Callback = tpToDowned })
tpGroup:AddToggle("Click Teleport", { Text = "Click Teleport", Default = false, Callback = function(v) clickTpEnabled = v; if v then enableClickTP() else disableClickTP() end end })
tpGroup:AddToggle("AFK Money", { Text = "AFK Money", Default = false, Callback = function(v) if v then startAFK() else stopAFK() end end })

local playerGroup = tpTab:AddRightGroupbox("PLAYERS", "users")
playerGroup:AddButton("Teleport to Player", {
    Text = "Teleport to Player",
    Callback = function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "TPMenu"
        gui.Parent = player.PlayerGui
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 260, 0, 420)
        frame.Position = UDim2.new(0.5, -130, 0.5, -210)
        frame.BackgroundColor3 = Color3.fromRGB(20,20,25)
        frame.Parent = gui
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = frame
        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 6)
        list.Parent = frame
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 12)
        padding.PaddingBottom = UDim.new(0, 12)
        padding.PaddingLeft = UDim.new(0, 12)
        padding.PaddingRight = UDim.new(0, 12)
        padding.Parent = frame
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 38)
                btn.Text = plr.Name
                btn.BackgroundColor3 = Color3.fromRGB(35,35,42)
                btn.TextColor3 = Color3.new(1,1,1)
                btn.Font = Enum.Font.GothamSemibold
                btn.Parent = frame
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 8)
                btnCorner.Parent = btn
                btn.MouseButton1Click:Connect(function()
                    local root = getRoot()
                    local targetRoot = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if root and targetRoot then
                        root.CFrame = targetRoot.CFrame
                    end
                    gui:Destroy()
                end)
            end
        end
        local close = Instance.new("TextButton")
        close.Size = UDim2.new(0, 32, 0, 32)
        close.Position = UDim2.new(1, -38, 0, 4)
        close.BackgroundTransparency = 1
        close.Text = "✕"
        close.TextColor3 = Color3.fromRGB(255,80,80)
        close.Font = Enum.Font.GothamBold
        close.TextSize = 18
        close.Parent = frame
        close.MouseButton1Click:Connect(function() gui:Destroy() end)
    end
})

-- ========== VISUALS TAB ==========
local visTab = Window:AddTab("", "eye")

local gfxGroup = visTab:AddLeftGroupbox("GRAPHICS", "settings")
gfxGroup:AddButton("Low Graphics V1", {
    Text = "Low Graphics V1",
    Callback = function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false
            end
        end
    end
})
gfxGroup:AddButton("Low Graphics V2", {
    Text = "Low Graphics V2",
    Callback = function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj:Destroy()
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false
            end
        end
        Lighting.FogStart = 0
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    end
})
gfxGroup:AddButton("Increase Brightness", {
    Text = "Increase Brightness",
    Callback = function() Lighting.Brightness = (Lighting.Brightness or 2) + 1 end
})

local lightGroup = visTab:AddRightGroupbox("LIGHTING", "sun")
lightGroup:AddButton("Day", { Text = "Day", Callback = function() Lighting.ClockTime = 12 end })
lightGroup:AddButton("Night", { Text = "Night", Callback = function() Lighting.ClockTime = 0 end })
lightGroup:AddButton("Remove Darkness", {
    Text = "Remove Darkness",
    Callback = function()
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
        Lighting.Brightness = 3
        Lighting.GlobalShadows = false
        Lighting.ExposureCompensation = 1
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or effect:IsA("Atmosphere") then
                effect:Destroy()
            end
        end
    end
})

-- ========== COSMETICS TAB ==========
local cosTab = Window:AddTab("", "crown")
local cosGroup = cosTab:AddLeftGroupbox("COSMETICS", "crown")
cosGroup:AddToggle("Korblox Leg", {
    Text = "Korblox Leg",
    Default = false,
    Callback = function(v)
        pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/jgYCL9vF", true))() end)
    end
})
cosGroup:AddToggle("Headless", {
    Text = "Headless",
    Default = false,
    Callback = function(v)
        pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/jgYCL9vF", true))() end)
    end
})

-- ========== INFO TAB ==========
local infoTab = Window:AddTab("", "info")
local infoGroup = infoTab:AddLeftGroupbox("INFORMATION", "info")
infoGroup:AddLabel("▸ Auto Bhop - Jump automatically when on ground")
infoGroup:AddLabel("▸ Auto Trimp - Bounce boost when falling")
infoGroup:AddLabel("▸ Auto Carry - Carry nearby players")
infoGroup:AddLabel("▸ Auto Revive - Revive downed players")
infoGroup:AddLabel("▸ Fly Mode - WASD flight control")
infoGroup:AddLabel("▸ Infinite Slide - Extended slide duration")
infoGroup:AddLabel("")
infoGroup:AddLabel("Premium Script • By Astro")
infoGroup:AddLabel("Version 1.0.0")

-- Notifikasi
Library:Notify({
    Title = "Astro",
    Description = "Evade Hub • Premium Loaded",
    Time = 3,
})

print("✅ Astro Evade Hub Loaded!")
