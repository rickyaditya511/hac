local function safeRequire(func, ...)
    local ok, result = pcall(func, ...)
    if not ok then
        warn("[ASTRO] Error: " .. tostring(result))
        return nil
    end
    return result
end

-- Pastikan fungsi exploit tersedia (atau buat dummy)
local function ensureFunction(name)
    if type(_G[name]) ~= "function" then
        _G[name] = function() end
        warn("[ASTRO] Fungsi " .. name .. " tidak ditemukan, dummy dibuat.")
    end
end

ensureFunction("hookmetamethod")
ensureFunction("getnamecallmethod")
ensureFunction("newcclosure")
ensureFunction("getrawmetatable")
ensureFunction("hookfunction")
ensureFunction("setreadonly")
ensureFunction("mouse1click")
ensureFunction("mouse1press")
ensureFunction("mouse1release")
ensureFunction("mousemoverel")
ensureFunction("movemouse")

-- Drawing fallback
if type(Drawing) ~= "table" then
    Drawing = setmetatable({}, {
        __index = function(_, key)
            if key == "new" then
                return function(class)
                    return {
                        Visible = false,
                        Remove = function() end,
                        Color = Color3.new(1,1,1),
                        Thickness = 1,
                        Transparency = 0,
                        Filled = false,
                        Radius = 100,
                        Position = Vector2.new(0,0),
                        From = Vector2.new(0,0),
                        To = Vector2.new(0,0),
                        PointA = Vector2.new(0,0),
                        PointB = Vector2.new(0,0),
                        PointC = Vector2.new(0,0),
                        Text = "",
                        Size = 12,
                        Center = false,
                        Outline = false,
                        Font = 0,
                    }
                end
            end
            return nil
        end
    })
    _G.Drawing = Drawing
    warn("[ASTRO] Drawing library tidak tersedia, menggunakan dummy.")
end

-- ============================================================
-- LOAD LIBRARY OBSIDIAN
-- ============================================================
local Library = safeRequire(loadstring, game:HttpGet("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/Library.lua"))
if not Library then
    error("[ASTRO] Gagal load Library. Cek koneksi internet.")
end

local SaveManager = safeRequire(loadstring, game:HttpGet("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/addons/SaveManager.lua"))
local ThemeManager = safeRequire(loadstring, game:HttpGet("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/addons/ThemeManager.lua"))

-- ============================================================
-- KONFIGURASI ASTRO LITE
-- ============================================================
local ASTRO = {
    Name = "ASTRO Lite",
    Version = "1.0.0",
    Loaded = false,
    Window = nil,
    Tabs = {},
    Options = {},
    Toggles = {},
    Unloaded = false,
    Services = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        UIS = game:GetService("UserInputService"),
        Workspace = game:GetService("Workspace"),
        RS = game:GetService("ReplicatedStorage"),
        Lighting = game:GetService("Lighting"),
        Teleport = game:GetService("TeleportService"),
    },
    Features = {
        SilentAim = { Enabled = false, FOV = 150, HitPart = "Head", MaxDistance = 2000, WallCheck = true },
        RageBot = { Enabled = false, FOV = 250, AimSpeed = 0.18, Wallbang = false, AutoShot = true },
        HoldBot = { Enabled = false, FOV = 250, Smoothing = 3, HitPart = "Head", MaxDistance = 2000 },
        TriggerBot = { Enabled = false, Delay = 0.05, WallCheck = true },
        ESP = { Boxes = false, Chams = false, Names = false, Health = false, Distance = false, Tracers = false, TeamCheck = false, MaxDistance = 400 },
        Movement = { WalkSpeed = 16, JumpPower = 50, InfiniteJump = false, Noclip = false, Fly = false, FlySpeed = 80, Gravity = 196 },
        AntiAFK = { Enabled = false },
    },
    State = {
        Fly = { Active = false, Conn = nil, Movers = {} },
    },
}

local lp = ASTRO.Services.Players.LocalPlayer
local camera = ASTRO.Services.Workspace.CurrentCamera
local Workspace = ASTRO.Services.Workspace
local UIS = ASTRO.Services.UIS
local RS = ASTRO.Services.RS
local RunService = ASTRO.Services.RunService
local Lighting = ASTRO.Services.Lighting

-- ============================================================
-- MOUSE HELPER (Mobile friendly)
-- ============================================================
function ASTRO:MoveMouse(dx, dy)
    dx = math.clamp(dx, -500, 500)
    dy = math.clamp(dy, -500, 500)
    if mousemoverel then return pcall(mousemoverel, dx, dy) end
    if movemouse then return pcall(movemouse, dx, dy) end
    local vim = game:GetService("VirtualInputManager")
    if vim and vim:SendMouseMovementEvent then
        local pos = UIS:GetMouseLocation()
        pcall(vim.SendMouseMovementEvent, vim, pos.X + dx, pos.Y + dy, Enum.UserInputType.MouseMovement)
        return true
    end
    return false
end

function ASTRO:Click()
    if mouse1click then return pcall(mouse1click) end
    if mouse1press and mouse1release then
        pcall(mouse1press)
        task.wait(0.01)
        pcall(mouse1release)
        return true
    end
    local vim = game:GetService("VirtualInputManager")
    if vim and vim:SendMouseButtonEvent then
        pcall(vim.SendMouseButtonEvent, vim, 0, 0, 0, true, Enum.UserInputType.MouseButton1, 0)
        task.wait(0.02)
        pcall(vim.SendMouseButtonEvent, vim, 0, 0, 0, false, Enum.UserInputType.MouseButton1, 0)
    end
end

-- ============================================================
-- CORE UTILITIES
-- ============================================================
local function GetPlayers()
    return ASTRO.Services.Players:GetPlayers()
end

local function isTeammate(player)
    if not ASTRO.Features.ESP.TeamCheck then return false end
    if player == lp then return true end
    local myTeam = lp:GetAttribute("TeamID")
    local theirTeam = player:GetAttribute("TeamID")
    if myTeam and theirTeam and myTeam ~= 0 and theirTeam ~= 0 and myTeam == theirTeam then return true end
    return false
end

local function resolveHitPart(char, userPick)
    if not char then return nil end
    if userPick ~= "Head" then
        return char:FindFirstChild(userPick)
    end
    local parts = {"HitboxHead", "PhysicalHitboxHead", "Head", "HumanoidRootPart"}
    for _, name in ipairs(parts) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then return part end
    end
    return nil
end

local function get_best_target(config)
    local target = nil
    local bestDist = config.FOV or 150
    local center = UIS:GetMouseLocation()
    local maxDistance = config.MaxDistance or math.huge
    local currentPart = config.HitPart or "Head"
    local wallCheck = config.WallCheck == true

    local camPos = camera.CFrame.Position
    local liveLpChar = lp.Character
    local playerList = GetPlayers()

    for _, v in ipairs(playerList) do
        if v ~= lp and v.Character then
            if isTeammate(v) then continue end
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            local hitPart = resolveHitPart(v.Character, currentPart)
            if not hitPart then continue end
            local pos, onScreen = camera:WorldToViewportPoint(hitPart.Position)
            if not onScreen then continue end
            local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
            if mag < config.FOV then
                local dist3D = (camPos - hitPart.Position).Magnitude
                if dist3D > maxDistance then continue end
                local visible = true
                if wallCheck then
                    local dir = hitPart.Position - camPos
                    local filter = {liveLpChar}
                    for _, other in ipairs(playerList) do
                        if other ~= lp and other ~= v and other.Character then
                            filter[#filter + 1] = other.Character
                        end
                    end
                    local params = RaycastParams.new()
                    params.FilterType = Enum.RaycastFilterType.Exclude
                    params.FilterDescendantsInstances = filter
                    params.IgnoreWater = true
                    params.RespectCanCollide = true
                    local result = Workspace:Raycast(camPos, dir, params)
                    if result and result.Instance and result.Instance:IsA("BasePart") then
                        local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
                        if hitChar ~= v.Character then
                            visible = false
                        end
                    end
                end
                if visible and mag < bestDist then
                    bestDist = mag
                    target = hitPart
                end
            end
        end
    end
    return target
end

-- ============================================================
-- SILENT AIM (hookmetamethod)
-- ============================================================
local _sa_oldnc = nil
local _sa_inHook = false

function SetupSilentAim()
    local SA = ASTRO.Features.SilentAim
    if not SA then return end

    _sa_oldnc = hookmetamethod(Workspace, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if SA.Enabled and not _sa_inHook and method == "Raycast" and self == Workspace then
            local args = {...}
            local origin = args[1]
            local direction = args[2]
            local params = args[3]
            if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
                -- Deteksi jika ini tembakan dari player
                local camPos = camera.CFrame.Position
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local head = char and char:FindFirstChild("Head")
                local distCam = (origin - camPos).Magnitude
                local distHrp = hrp and (origin - hrp.Position).Magnitude or math.huge
                local distHead = head and (origin - head.Position).Magnitude or math.huge
                if distCam <= 25 or distHrp <= 15 or distHead <= 15 then
                    _sa_inHook = true
                    local target = get_best_target({
                        FOV = SA.FOV,
                        HitPart = SA.HitPart,
                        MaxDistance = SA.MaxDistance,
                        WallCheck = SA.WallCheck,
                    })
                    _sa_inHook = false
                    if target then
                        local newdir = (target.Position - origin).Unit * direction.Magnitude
                        setnamecallmethod(method)
                        return _sa_oldnc(self, origin, newdir, params)
                    end
                end
            end
        end
        setnamecallmethod(method)
        return _sa_oldnc(self, ...)
    end))
end

-- ============================================================
-- RAGE BOT
-- ============================================================
function SetupRageBot()
    local RB = ASTRO.Features.RageBot
    local lastFire = 0

    RunService.RenderStepped:Connect(function()
        if not RB.Enabled then return end
        local target = get_best_target({
            FOV = RB.FOV,
            HitPart = "Head",
            MaxDistance = 1000,
            WallCheck = not RB.Wallbang,
        })
        if target then
            local pos, on = camera:WorldToViewportPoint(target.Position)
            if on then
                local mouse = UIS:GetMouseLocation()
                local dx, dy = pos.X - mouse.X, pos.Y - mouse.Y
                dx, dy = dx * RB.AimSpeed, dy * RB.AimSpeed
                dx = math.clamp(dx, -50, 50)
                dy = math.clamp(dy, -50, 50)
                ASTRO:MoveMouse(dx, dy)
            end
            if RB.AutoShot and tick() - lastFire >= 0.015 then
                lastFire = tick()
                ASTRO:Click()
            end
        end
    end)
end

-- ============================================================
-- HOLD BOT
-- ============================================================
function SetupHoldBot()
    local HB = ASTRO.Features.HoldBot

    RunService.RenderStepped:Connect(function()
        if not HB.Enabled then return end
        local target = get_best_target({
            FOV = HB.FOV,
            HitPart = HB.HitPart,
            MaxDistance = HB.MaxDistance,
            WallCheck = true,
        })
        if target then
            local pos, on = camera:WorldToViewportPoint(target.Position)
            if on then
                local mouse = UIS:GetMouseLocation()
                local dx, dy = pos.X - mouse.X, pos.Y - mouse.Y
                if HB.Smoothing > 1 then
                    local div = HB.Smoothing
                    dx, dy = dx / div, dy / div
                    if math.abs(dx) < 0.04 then dx = 0 end
                    if math.abs(dy) < 0.04 then dy = 0 end
                else
                    dx = math.clamp(dx, -5, 5)
                    dy = math.clamp(dy, -5, 5)
                end
                ASTRO:MoveMouse(dx, dy)
            end
        end
    end)
end

-- ============================================================
-- TRIGGER BOT
-- ============================================================
function SetupTriggerBot()
    local TB = ASTRO.Features.TriggerBot
    local last = 0

    RunService.RenderStepped:Connect(function()
        if not TB.Enabled then return end
        local target = get_best_target({
            FOV = 10,
            HitPart = "Head",
            MaxDistance = 1000,
            WallCheck = TB.WallCheck,
        })
        if target and tick() - last >= TB.Delay then
            last = tick()
            ASTRO:Click()
        end
    end)
end

-- ============================================================
-- ESP (Box, Chams, Names, Health, Distance, Tracers)
-- ============================================================
function SetupESP()
    local ESP = ASTRO.Features.ESP
    local EspGui = Instance.new("ScreenGui")
    EspGui.Name = "ASTRO_ESP"
    EspGui.ResetOnSpawn = false
    EspGui.IgnoreGuiInset = true
    pcall(function() EspGui.Parent = game:GetService("CoreGui") end)
    if not EspGui.Parent then EspGui.Parent = lp:WaitForChild("PlayerGui") end

    local EspRegistry = {}
    local HEALTH_WIDTH = 3
    local HEALTH_OFFSET = 5

    local function createElements(p)
        if p == lp or EspRegistry[p] then return end
        local e = {}
        -- Box
        local BoxFrame = Instance.new("Frame", EspGui)
        BoxFrame.BackgroundTransparency = 1
        BoxFrame.Visible = false
        local Outline = Instance.new("Frame", BoxFrame)
        Outline.Size = UDim2.new(1,0,1,0)
        Outline.BackgroundTransparency = 1
        local Stroke = Instance.new("UIStroke", Outline)
        Stroke.Thickness = 1.5
        e.Box = BoxFrame; e.BoxStroke = Stroke
        -- Tracer
        local Tracer = Instance.new("Frame", EspGui)
        Tracer.AnchorPoint = Vector2.new(0.5,0.5)
        Tracer.BorderSizePixel = 0
        Tracer.Visible = false
        e.Tracer = Tracer
        -- Health
        local HealthContainer = Instance.new("Frame", EspGui)
        HealthContainer.BackgroundColor3 = Color3.fromRGB(0,0,0)
        HealthContainer.BackgroundTransparency = 0.3
        HealthContainer.BorderSizePixel = 0
        HealthContainer.Visible = false
        local HealthFill = Instance.new("Frame", HealthContainer)
        HealthFill.BorderSizePixel = 0
        HealthFill.AnchorPoint = Vector2.new(0,1)
        HealthFill.Position = UDim2.new(0,0,1,0)
        e.HealthBar = HealthContainer; e.HealthFill = HealthFill
        -- Name
        local NameLabel = Instance.new("TextLabel", EspGui)
        NameLabel.BackgroundTransparency = 1
        NameLabel.AnchorPoint = Vector2.new(0.5,1)
        NameLabel.TextColor3 = Color3.fromRGB(255,255,255)
        NameLabel.Font = Enum.Font.FredokaOne
        NameLabel.TextSize = 13
        NameLabel.Visible = false
        local NameStroke = Instance.new("UIStroke", NameLabel)
        NameStroke.Color = Color3.fromRGB(0,0,0)
        NameStroke.Thickness = 1.5
        e.Name = NameLabel
        -- Distance
        local DistLabel = Instance.new("TextLabel", EspGui)
        DistLabel.BackgroundTransparency = 1
        DistLabel.AnchorPoint = Vector2.new(0.5,0)
        DistLabel.TextColor3 = Color3.fromRGB(235,235,235)
        DistLabel.Font = Enum.Font.FredokaOne
        DistLabel.TextSize = 11
        DistLabel.Visible = false
        local DistStroke = Instance.new("UIStroke", DistLabel)
        DistStroke.Color = Color3.fromRGB(0,0,0)
        DistStroke.Thickness = 1.5
        e.Dist = DistLabel
        -- Chams
        e.CurrentCham = nil
        EspRegistry[p] = e
    end

    local function removeElements(p)
        if EspRegistry[p] then
            if EspRegistry[p].CurrentCham then EspRegistry[p].CurrentCham:Destroy() end
            for _, obj in pairs(EspRegistry[p]) do
                if typeof(obj) == "Instance" then obj:Destroy() end
            end
            EspRegistry[p] = nil
        end
    end

    for _, p in ipairs(GetPlayers()) do createElements(p) end
    ASTRO.Services.Players.PlayerAdded:Connect(createElements)
    ASTRO.Services.Players.PlayerRemoving:Connect(removeElements)

    RunService.RenderStepped:Connect(function()
        local color = Color3.fromRGB(100,200,255)
        local camPos = camera.CFrame.Position
        local vp = camera.ViewportSize

        for player, cache in pairs(EspRegistry) do
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                if ESP.TeamCheck and isTeammate(player) then
                    cache.Box.Visible = false; cache.Tracer.Visible = false
                    cache.HealthBar.Visible = false; cache.Name.Visible = false; cache.Dist.Visible = false
                    if cache.CurrentCham then cache.CurrentCham.Enabled = false end
                    continue
                end
                local pos, onScreen = camera:WorldToViewportPoint(root.Position)
                local dist = (camPos - root.Position).Magnitude
                if onScreen and dist <= ESP.MaxDistance then
                    local sizeX = 1200 / dist
                    local sizeY = sizeX * 1.45
                    local boxX = pos.X - sizeX/2
                    local boxY = pos.Y - sizeY/2

                    if ESP.Boxes then
                        cache.Box.Position = UDim2.new(0, boxX, 0, boxY)
                        cache.Box.Size = UDim2.new(0, sizeX, 0, sizeY)
                        cache.BoxStroke.Color = color
                        cache.Box.Visible = true
                    else cache.Box.Visible = false end

                    if ESP.Tracers then
                        local startX, startY = vp.X/2, vp.Y
                        local dx, dy = pos.X - startX, pos.Y - startY
                        local length = math.sqrt(dx^2 + dy^2)
                        local angle = math.atan2(dy, dx)
                        cache.Tracer.Position = UDim2.new(0, startX + dx/2, 0, startY + dy/2)
                        cache.Tracer.Size = UDim2.new(0, length, 0, 1)
                        cache.Tracer.BackgroundColor3 = color
                        cache.Tracer.Rotation = math.deg(angle)
                        cache.Tracer.Visible = true
                    else cache.Tracer.Visible = false end

                    if ESP.Health then
                        local h = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        cache.HealthBar.Position = UDim2.new(0, boxX - HEALTH_OFFSET - HEALTH_WIDTH, 0, boxY)
                        cache.HealthBar.Size = UDim2.new(0, HEALTH_WIDTH, 0, sizeY)
                        cache.HealthFill.Size = UDim2.new(1,0, h,0)
                        cache.HealthFill.BackgroundColor3 = Color3.fromRGB(255,50,50):Lerp(Color3.fromRGB(0,255,140), h)
                        cache.HealthBar.Visible = true
                    else cache.HealthBar.Visible = false end

                    if ESP.Names then
                        cache.Name.Position = UDim2.new(0, pos.X, 0, boxY - 4)
                        cache.Name.Text = player.DisplayName
                        cache.Name.Visible = true
                    else cache.Name.Visible = false end

                    if ESP.Distance then
                        cache.Dist.Position = UDim2.new(0, pos.X, 0, boxY + sizeY + 2)
                        cache.Dist.Text = math.floor(dist) .. " studs"
                        cache.Dist.Visible = true
                    else cache.Dist.Visible = false end

                    if ESP.Chams then
                        if not cache.CurrentCham or cache.CurrentCham.Parent ~= char then
                            if cache.CurrentCham then cache.CurrentCham:Destroy() end
                            local hl = Instance.new("Highlight")
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.FillColor = Color3.fromRGB(0,200,255)
                            hl.OutlineColor = Color3.fromRGB(0,200,255)
                            hl.FillTransparency = 0.2
                            hl.Parent = char
                            cache.CurrentCham = hl
                        end
                        cache.CurrentCham.Enabled = true
                    else
                        if cache.CurrentCham then cache.CurrentCham.Enabled = false end
                    end
                else
                    cache.Box.Visible = false; cache.Tracer.Visible = false
                    cache.HealthBar.Visible = false; cache.Name.Visible = false; cache.Dist.Visible = false
                    if cache.CurrentCham then cache.CurrentCham.Enabled = false end
                end
            else
                cache.Box.Visible = false; cache.Tracer.Visible = false
                cache.HealthBar.Visible = false; cache.Name.Visible = false; cache.Dist.Visible = false
                if cache.CurrentCham then cache.CurrentCham.Enabled = false end
            end
        end
    end)
end

-- ============================================================
-- MOVEMENT (Fly, Speed, Jump, Noclip, Gravity)
-- ============================================================
function SetupMovement()
    local M = ASTRO.Features.Movement
    local flyMovers = {}

    local function stopFly()
        ASTRO.State.Fly.Active = false
        if ASTRO.State.Fly.Conn then
            ASTRO.State.Fly.Conn:Disconnect()
            ASTRO.State.Fly.Conn = nil
        end
        for _, m in pairs(flyMovers) do
            if m and m.Parent then m:Destroy() end
        end
        flyMovers = {}
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end

    local function startFly(speed)
        local char = lp.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        stopFly()
        ASTRO.State.Fly.Active = true
        hum.PlatformStand = true
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.one * 9e9
        bv.Velocity = Vector3.zero
        bv.Parent = root
        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.one * 9e9
        bg.P = 9e4
        bg.CFrame = root.CFrame
        bg.Parent = root
        flyMovers = {bv, bg}
        ASTRO.State.Fly.Conn = RunService.Heartbeat:Connect(function()
            if not ASTRO.State.Fly.Active then stopFly(); return end
            local char2 = lp.Character
            local root2 = char2 and char2:FindFirstChild("HumanoidRootPart")
            if not root2 or not bv.Parent or not bg.Parent then stopFly(); return end
            local cam = Workspace.CurrentCamera
            local vel = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then vel = vel + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then vel = vel - cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then vel = vel + cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then vel = vel - cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.yAxis end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.yAxis end
            bv.Velocity = vel * speed
            bg.CFrame = cam.CFrame.Rotation + root2.Position
        end)
    end

    -- Infinite Jump
    UIS.JumpRequest:Connect(function()
        if M.InfiniteJump then
            local char = lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)

    -- Noclip, WalkSpeed, JumpPower, Gravity
    RunService.Stepped:Connect(function()
        local char = lp.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        if M.WalkSpeed ~= 16 then
            hum.WalkSpeed = M.WalkSpeed
        end
        if M.JumpPower ~= 50 then
            hum.JumpPower = M.JumpPower
        end
        if M.Noclip then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        if M.Gravity ~= 196 then
            Workspace.Gravity = M.Gravity
        end
    end)

    -- Expose fly
    ASTRO.startFly = startFly
    ASTRO.stopFly = stopFly
end

-- ============================================================
-- ANTI AFK
-- ============================================================
function SetupAntiAFK()
    local AFK = ASTRO.Features.AntiAFK
    local vu = game:GetService("VirtualUser")
    task.spawn(function()
        while not ASTRO.Unloaded do
            if AFK.Enabled then
                pcall(function()
                    vu:CaptureController()
                    vu:ClickButton2(Vector2.zero)
                end)
                task.wait(60)
            else
                task.wait(1)
            end
        end
    end)
end

-- ============================================================
-- CREATE WINDOW & UI
-- ============================================================
function ASTRO:CreateUI()
    local window = Library:CreateWindow({
        Title = self.Name,
        Footer = "Rivals Mobile Lite",
        Size = UDim2.fromOffset(560, 500),
        Center = true,
        Resizable = false,
        ShowCustomCursor = true,
        NotifySide = "Right",
        CornerRadius = 6,
        ToggleKeybind = Enum.KeyCode.LeftAlt,
    })
    self.Window = window

    -- Tabs
    local tabs = {}
    tabs.Aim = window:AddTab("🎯 Aim")
    tabs.ESP = window:AddTab("👁️ ESP")
    tabs.Misc = window:AddTab("🔧 Misc")
    tabs.Settings = window:AddTab("⚙️ Settings")
    self.Tabs = tabs

    -- ===== AIM TAB =====
    -- Silent Aim
    local saGroup = tabs.Aim:AddLeftGroupbox("Silent Aim", "target")
    saGroup:AddToggle("SilentAim", { Text = "Enable", Default = false, Callback = function(v) self.Features.SilentAim.Enabled = v end })
    saGroup:AddSlider("SA_FOV", { Text = "FOV", Default = 150, Min = 50, Max = 500, Rounding = 0, Callback = function(v) self.Features.SilentAim.FOV = v end })
    saGroup:AddDropdown("SA_HitPart", { Text = "Hit Part", Values = {"Head","UpperTorso","LowerTorso"}, Default = 1, Callback = function(v) self.Features.SilentAim.HitPart = v end })
    saGroup:AddSlider("SA_MaxDist", { Text = "Max Distance", Default = 2000, Min = 100, Max = 5000, Rounding = 0, Callback = function(v) self.Features.SilentAim.MaxDistance = v end })
    saGroup:AddToggle("SA_WallCheck", { Text = "Wall Check", Default = true, Callback = function(v) self.Features.SilentAim.WallCheck = v end })

    -- Rage Bot
    local rageGroup = tabs.Aim:AddRightGroupbox("Rage Bot", "crosshair")
    rageGroup:AddToggle("RageBot", { Text = "Enable", Default = false, Callback = function(v) self.Features.RageBot.Enabled = v end })
    rageGroup:AddSlider("RageFOV", { Text = "FOV", Default = 250, Min = 50, Max = 500, Rounding = 0, Callback = function(v) self.Features.RageBot.FOV = v end })
    rageGroup:AddSlider("RageSpeed", { Text = "Aim Speed", Default = 0.18, Min = 0.01, Max = 0.5, Rounding = 2, Callback = function(v) self.Features.RageBot.AimSpeed = v end })
    rageGroup:AddToggle("RageWallbang", { Text = "Wallbang", Default = false, Callback = function(v) self.Features.RageBot.Wallbang = v end })
    rageGroup:AddToggle("RageAutoShot", { Text = "Auto Shoot", Default = true, Callback = function(v) self.Features.RageBot.AutoShot = v end })

    -- Hold Bot
    local holdGroup = tabs.Aim:AddLeftGroupbox("Hold Bot", "crosshair")
    holdGroup:AddToggle("HoldBot", { Text = "Enable", Default = false, Callback = function(v) self.Features.HoldBot.Enabled = v end })
    holdGroup:AddSlider("HoldFOV", { Text = "FOV", Default = 250, Min = 50, Max = 500, Rounding = 0, Callback = function(v) self.Features.HoldBot.FOV = v end })
    holdGroup:AddSlider("HoldSmooth", { Text = "Smoothing", Default = 3, Min = 1, Max = 20, Rounding = 0, Callback = function(v) self.Features.HoldBot.Smoothing = v end })
    holdGroup:AddDropdown("HoldHitPart", { Text = "Hit Part", Values = {"Head","UpperTorso","LowerTorso"}, Default = 1, Callback = function(v) self.Features.HoldBot.HitPart = v end })
    holdGroup:AddSlider("HoldMaxDist", { Text = "Max Distance", Default = 2000, Min = 100, Max = 3000, Rounding = 0, Callback = function(v) self.Features.HoldBot.MaxDistance = v end })

    -- Trigger Bot
    local trigGroup = tabs.Aim:AddRightGroupbox("Trigger Bot", "bot")
    trigGroup:AddToggle("TriggerBot", { Text = "Enable", Default = false, Callback = function(v) self.Features.TriggerBot.Enabled = v end })
    trigGroup:AddSlider("TriggerDelay", { Text = "Delay (s)", Default = 0.05, Min = 0.01, Max = 0.3, Rounding = 2, Callback = function(v) self.Features.TriggerBot.Delay = v end })
    trigGroup:AddToggle("TriggerWall", { Text = "Wall Check", Default = true, Callback = function(v) self.Features.TriggerBot.WallCheck = v end })

    -- ===== ESP TAB =====
    local espGroup = tabs.ESP:AddLeftGroupbox("ESP Settings", "eye")
    espGroup:AddToggle("EspBoxes", { Text = "Boxes", Default = false, Callback = function(v) self.Features.ESP.Boxes = v end })
    espGroup:AddToggle("EspChams", { Text = "Chams", Default = false, Callback = function(v) self.Features.ESP.Chams = v end })
    espGroup:AddToggle("EspNames", { Text = "Names", Default = false, Callback = function(v) self.Features.ESP.Names = v end })
    espGroup:AddToggle("EspHealth", { Text = "Health Bars", Default = false, Callback = function(v) self.Features.ESP.Health = v end })
    espGroup:AddToggle("EspDistance", { Text = "Distance", Default = false, Callback = function(v) self.Features.ESP.Distance = v end })
    espGroup:AddToggle("EspTracers", { Text = "Tracers", Default = false, Callback = function(v) self.Features.ESP.Tracers = v end })
    espGroup:AddToggle("EspTeamCheck", { Text = "Team Check", Default = false, Callback = function(v) self.Features.ESP.TeamCheck = v end })
    espGroup:AddSlider("EspMaxDist", { Text = "Max Distance", Default = 400, Min = 100, Max = 2000, Rounding = 0, Callback = function(v) self.Features.ESP.MaxDistance = v end })

    -- ===== MISC TAB =====
    local movGroup = tabs.Misc:AddLeftGroupbox("Movement", "footprints")
    movGroup:AddSlider("WalkSpeed", { Text = "Walk Speed", Default = 16, Min = 16, Max = 200, Rounding = 0, Callback = function(v) self.Features.Movement.WalkSpeed = v end })
    movGroup:AddSlider("JumpPower", { Text = "Jump Power", Default = 50, Min = 1, Max = 300, Rounding = 0, Callback = function(v) self.Features.Movement.JumpPower = v end })
    movGroup:AddToggle("InfiniteJump", { Text = "Infinite Jump", Default = false, Callback = function(v) self.Features.Movement.InfiniteJump = v end })
    movGroup:AddToggle("Noclip", { Text = "Noclip", Default = false, Callback = function(v) self.Features.Movement.Noclip = v end })
    movGroup:AddToggle("Fly", { Text = "Fly (WASD + Space/Shift)", Default = false, Callback = function(v)
        self.Features.Movement.Fly = v
        if v then self:startFly(self.Features.Movement.FlySpeed) else self:stopFly() end
    end })
    movGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 80, Min = 10, Max = 500, Rounding = 0, Callback = function(v)
        self.Features.Movement.FlySpeed = v
        if self.Features.Movement.Fly then self:stopFly(); task.wait(0.05); self:startFly(v) end
    end })
    movGroup:AddSlider("Gravity", { Text = "Gravity", Default = 196, Min = 10, Max = 400, Rounding = 0, Callback = function(v) self.Features.Movement.Gravity = v end })
    movGroup:AddToggle("AntiAFK", { Text = "Anti AFK", Default = false, Callback = function(v) self.Features.AntiAFK.Enabled = v end })

    -- ===== SETTINGS TAB =====
    local setGroup = tabs.Settings:AddLeftGroupbox("UI", "settings")
    setGroup:AddSlider("UIScale", { Text = "UI Scale (Mobile)", Default = 100, Min = 50, Max = 150, Rounding = 0, Suffix = "%", Callback = function(v)
        if self._UIScale then self._UIScale.Scale = v / 100 end
    end })
    setGroup:AddToggle("KeybindMenu", { Text = "Open Keybind Menu", Default = false, Callback = function(v) Library.KeybindFrame.Visible = v end })
    setGroup:AddButton("Unload UI", function() self:Destroy() end)

    -- UI Scale instance
    self._UIScale = Instance.new("UIScale", self.Window.Holder)
    self._UIScale.Scale = 1

    -- Info
    local infoGroup = tabs.Settings:AddRightGroupbox("Info", "info")
    infoGroup:AddLabel(self.Name .. " v" .. self.Version, true)
    infoGroup:AddLabel("Optimized for Mobile", true)
    infoGroup:AddLabel("Press LeftAlt to toggle menu", true)
end


function ASTRO:Init()
    if self.Loaded then return self end
    print("[ASTRO] Loading Lite Edition...")

    -- Setup Theme
    if ThemeManager then
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetDefaultTheme({
            FontColor = "ffffff",
            MainColor = "0d0d0d",
            AccentColor = "#6c5ce7",
            BackgroundColor = "0a0a0a",
            OutlineColor = "1a1a1a",
        })
    end

    self:CreateUI()

    -- Setup features
    SetupSilentAim()
    SetupRageBot()
    SetupHoldBot()
    SetupTriggerBot()
    SetupESP()
    SetupMovement()
    SetupAntiAFK()

    -- Save/Load
    if SaveManager then
        SaveManager:SetLibrary(Library)
        SaveManager:SetFolder(self.Name)
        SaveManager:SetSubFolder(tostring(game.PlaceId))
        SaveManager:BuildConfigSection(self.Tabs.Settings)
        SaveManager:LoadAutoloadConfig()
    end

    self.Loaded = true
    self.Library = Library
    Library.ToggleKeybind = Enum.KeyCode.LeftAlt

    print("[ASTRO] Lite Edition Loaded!")
    Library:Notify({ Title = self.Name, Description = "Loaded! Press LeftAlt", Time = 3 })
    return self
end

function ASTRO:Destroy()
    self.Unloaded = true
    self.Loaded = false
    if self.Window then self.Window:Destroy() end
    print("[ASTRO] Unloaded.")
end

return ASTRO:Init()