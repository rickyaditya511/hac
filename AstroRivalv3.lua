local function initProtection()
    -- Cek fungsi exploit
    local required = {
        "hookmetamethod", "getnamecallmethod", "newcclosure",
        "Drawing", "getrawmetatable", "hookfunction", "setreadonly"
    }
    local missing = {}
    for _, f in ipairs(required) do
        if not _G[f] then
            table.insert(missing, f)
        end
    end
    if #missing > 0 then
        warn("[ASTRO] Fungsi exploit hilang: " .. table.concat(missing, ", "))
        warn("[ASTRO] Gunakan executor yang support (Arceus X, Hydrogen, Vega X).")
        return false
    end

    -- Fallback untuk mouse functions (jika tidak ada)
    if not mouse1click then mouse1click = function() end end
    if not mouse1press then mouse1press = function() end end
    if not mouse1release then mouse1release = function() end end
    if not mousemoverel then mousemoverel = function() end end
    if not movemouse then movemouse = function() end end
    if not keypress then keypress = function() end end
    if not keyrelease then keyrelease = function() end end

    return true
end

if not initProtection() then
    error("[ASTRO] Executor tidak kompatibel! Script dihentikan.")
end

local ASTRO = {
    Name = "ASTRO",
    SubName = "Rivals Mobile",
    Version = "4.0.0",
    Loaded = false,
    Library = nil,
    SaveManager = nil,
    ThemeManager = nil,
    Window = nil,
    Tabs = {},
    Options = {},
    Toggles = {},
    Unloaded = false,
    -- ============================================================
    -- FEATURES (Semua pengaturan dalam satu tabel)
    -- ============================================================
    Features = {
        SilentAim = {
            Enabled = false,
            FOV = 150,
            HitPart = "Head",
            Prediction = 0.10,
            MaxDistance = 2000,
            WallCheck = true,
            TeamCheck = false,
            ProjectilePrediction = false,
            FovVisible = false,
            FovFilled = false,
            FovColor = Color3.fromRGB(255,255,255),
            FovRainbow = false,
        },
        RageBot = {
            Enabled = false,
            Wallbang = false,
            FOV = 250,
            AimSpeed = 0.18,
            ShowTracer = true,
            TracerStart = "Cursor",
            TracerColor = Color3.fromRGB(255,50,50),
            TracerThickness = 1,
            SpamLock = false,
            AutoShot = true,
            FovVisible = false,
            FovFilled = false,
            FovColor = Color3.fromRGB(255,0,0),
            FovRainbow = false,
            Mode = "Keybind",
        },
        HoldBot = {
            Enabled = false,
            FOV = 250,
            Smoothing = 3,
            Prediction = false,
            MaxDistance = 2000,
            HitPart = "Head",
            TargetBehindWalls = false,
            Persistent = false,
            FovVisible = false,
            FovFilled = false,
            FovColor = Color3.fromRGB(0,255,255),
            FovRainbow = false,
            Mode = "Keybind",
        },
        TriggerBot = {
            Enabled = false,
            Delay = 0.05,
            WallCheck = true,
            Keybind = false,
        },
        SniperMode = {
            Enabled = false,
            Threshold = 40,
            Delay = 0.23,
            Cooldown = 0.85,
            LastShot = 0,
            IsFiring = false,
        },
        AntiAim = {
            Enabled = false,
            Pitch = 85,
            Yaw = 0,
        },
        AntiKatana = {
            Enabled = false,
        },
        ESP = {
            Boxes = false,
            FilledBoxes = false,
            Tracers = false,
            Health = false,
            Names = false,
            Distance = false,
            Chams = false,
            GlowChams = false,
            Skeleton = false,
            Arrow = false,
            EnemyWeapons = false,
            Tripmine = false,
            TeamCheck = false,
            MaxDistance = 400,
            BoxThickness = 1.5,
            LineThickness = 1,
            BoxSizeMultiplier = 1200,
            FilledTransparency = 0.4,
            ChamsBrightness = 5,
            GlowBrightness = 3,
            HeadScale = 1,
            HighlightPulse = false,
            PulseSpeed = 1.0,
            PulseRange = 0.4,
        },
        GunMods = {
            Master = false,
            NoRecoil = false,
            NoSpread = false,
            RapidFire = false,
            FireRateMultiplier = 1.0,
            OneShot = false,
            InfiniteAmmo = false,
            InstantReload = false,
            InstantEquip = false,
            NoBulletDrop = false,
            MaxPierce = false,
            NoCooldowns = false,
            ZeroSpreadIL = false,
            ZeroRecoilIL = false,
        },
        Movement = {
            WalkSpeedEnabled = false,
            WalkSpeed = 50,
            JumpPowerEnabled = false,
            JumpPower = 50,
            Noclip = false,
            InfiniteJump = false,
            AirWalk = false,
            SlideBoost = false,
            SlideBoostPower = 4,
            Fly = false,
            FlySpeed = 80,
            AutoBhop = false,
            AirStrafe = false,
            AirStrafeStrength = 20,
            AutoJump = false,
            CircleStrafe = false,
            QuickStop = false,
            Gravity = 196,
        },
        Visuals = {
            Crosshair = false,
            CrosshairColor = "Purple",
            SkyColor = false,
            SkyColorVal = Color3.fromRGB(80,80,100),
            SkyBrightness = 1.5,
            SkyClockTime = 12,
            HideSmoke = false,
            HideFlash = false,
            LockIndicator = false,
            BulletTracer = false,
            BulletTracerColor = "Toothpaste",
            BulletTracerLifetime = 10,
            BulletTracerSpeed = 600,
            WeaponLatex = false,
            ArmLatex = false,
            Bloom = false,
            BloomIntensity = 20,
            Thirdperson = false,
            ThirdpersonDistance = 12,
            ThirdpersonKey = "Always on",
            FOVOverride = false,
            FOVValue = 120,
            WorldColor = false,
            WorldColorName = "white",
            Fog = false,
            FogColorName = "white",
            FogDistance = 1000,
            Weather = "None",
            NightMode = false,
        },
        AutoWalk = {
            Enabled = false,
            Method = "Normal",
        },
        Orbit = {
            Enabled = false,
            Radius = 8,
            Speed = 3,
            MaxDistance = 400,
            Height = 3,
        },
        Stick = {
            Enabled = false,
            Smooth = false,
            Smoothness = 50,
            Beneath = false,
            MaxDistance = 400,
        },
        TeleportKill = {
            Enabled = false,
            TargetName = "",
            Distance = 3,
            AutoReconnect = true,
        },
        Spoofers = {
            Name = false,
            SpoofedName = "ZytheraX",
            EnemyName = "Johnny",
            Device = false,
            DeviceTarget = "Controller",
            Level = false,
            LevelVal = 996,
            Winstreak = false,
            WinstreakVal = 56,
        },
        AutoWeapon = {
            Enabled = false,
            Slots = {},
        },
        Proximity = {
            Enabled = false,
            Distance = 30,
        },
        AntiAFK = {
            Enabled = false,
        },
        NameSpoof = {
            Enabled = false,
            Name = "ZytheraX",
            Mode = "Both",
            Badge = true,
        },
        AutoShoot = {
            Enabled = false,
            Radius = 100,
            AntiFriendly = true,
            RequireVisible = true,
            HitPart = "Head",
            BurstCount = 3,
            BurstDelay = 0.05,
            Cooldown = 0.2,
            _lastFire = 0,
            _conn = nil,
            _lastTarget = nil,
            _currentAimPos = nil,
            _burstShotsLeft = 0,
            _lastBurstTime = 0,
        },
        HitboxExpander = {
            Enabled = false,
            Size = 10,
            Transparency = 1,
            _originalSizes = {},
            _spheres = {},
        },
        ESPSphere = {
            Enabled = false,
            Size = 6,
            Color = Color3.fromRGB(0,255,0),
            Transparency = 0.7,
            _spheres = {},
        },
        AntiAFK = {
            Enabled = false,
        },
        Proximity = {
            Enabled = false,
            Distance = 30,
        },
    },
    State = {
        Fly = { Active = false, Conn = nil, Movers = {} },
        AntiAFK = { Conn = nil },
        LootAura = { Conn = nil },
        Orbit = { Angle = 0, Target = nil, Conn = nil },
        AntiAim = { NeckMotor = nil, NeckOrig = nil, Conn1 = nil, Conn2 = nil, Conn3 = nil },
        AntiKatana = { WasDeflecting = false, LastNotify = 0 },
        HoldBot = { Active = false, Target = nil, PrevX = 0, PrevY = 0, CurrentTarget = nil, LastSwitch = 0, VelX = 0, VelY = 0 },
        Wallbang = { Active = false, DesyncActive = false, CurrentTarget = nil, Conn = nil, Timer = nil },
        ESPHighlights = {},
        SkeletonLines = {},
        OriginalHeadSizes = {},
        VelocityHistory = {},
        ProjSpeedCache = {},
        _fps = { frames = 0, tick = 0, current = 0, label = nil },
        Crosshair = { gui = nil, anchor = nil, cTop = nil, cBottom = nil, cLeft = nil, cRight = nil, time = 0 },
        Tracer = { line = nil, beam = nil, showUntil = 0 },
        LockIndicator = { gui = nil, label = nil, cache = nil, cacheTime = 0 },
        FovCircles = {
            SA = { bg = nil, ring = nil },
            Rage = { bg = nil, ring = nil },
            Hold = { bg = nil, ring = nil },
        },
        EspGui = nil,
        EspRegistry = {},
        EspSkeletonCache = {},
        TeleportKill = { Conn = nil, Target = nil },
        AutoShoot = { _conn = nil },
    },
    Services = {},
    Cache = {
        Players = {},
        PlayerCacheTick = 0,
        TeamCache = { myTeamID = nil, lastUpdate = 0 },
        EnemyWeaponCache = {},
    },
}

-- ============================================================
-- MOUSE HELPER (Desktop + Mobile)
-- ============================================================
function ASTRO:MoveMouseRelative(dx, dy)
    dx = math.clamp(dx, -500, 500)
    dy = math.clamp(dy, -500, 500)
    if mousemoverel then return pcall(mousemoverel, dx, dy) end
    if movemouse then return pcall(movemouse, dx, dy) end
    local vim = game:GetService("VirtualInputManager")
    if vim and vim:SendMouseMovementEvent then
        local pos = self.Services.UserInputService:GetMouseLocation()
        pcall(vim.SendMouseMovementEvent, vim, pos.X + dx, pos.Y + dy, Enum.UserInputType.MouseMovement)
        return true
    end
    return false
end

function ASTRO:FireWeapon()
    local ok
    ok, _ = pcall(function() if mouse1click then mouse1click() return end end)
    if ok then return end
    ok, _ = pcall(function() if mousebuttonclick then mousebuttonclick(1) return end end)
    if ok then return end
    ok, _ = pcall(function() if click then click() return end end)
    if ok then return end
    ok, _ = pcall(function()
        if mouse1press and mouse1release then
            mouse1press()
            task.wait(0.01)
            mouse1release()
        end
    end)
    if ok then return end
    local vim = game:GetService("VirtualInputManager")
    if vim and vim:SendMouseButtonEvent then
        pcall(function()
            vim:SendMouseButtonEvent(0, 0, 0, true, Enum.UserInputType.MouseButton1, 0)
            task.wait(0.02)
            vim:SendMouseButtonEvent(0, 0, 0, false, Enum.UserInputType.MouseButton1, 0)
        end)
    end
end

-- Override global autoFire
autoFire = function() ASTRO:FireWeapon() end

-- ============================================================
-- LOAD DEPENDENCIES & SERVICES
-- ============================================================
local function LoadDependencies()
    local success, result

    success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/Library.lua"))()
    end)
    if not success or not result then
        warn("[ASTRO] Failed to load Library")
        return false
    end
    ASTRO.Library = result

    success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/addons/SaveManager.lua"))()
    end)
    if not success or not result then
        warn("[ASTRO] Failed to load SaveManager")
        return false
    end
    ASTRO.SaveManager = result

    success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/addons/ThemeManager.lua"))()
    end)
    if not success or not result then
        warn("[ASTRO] Failed to load ThemeManager")
        return false
    end
    ASTRO.ThemeManager = result

    -- Services
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local RS = game:GetService("ReplicatedStorage")
    local Lighting = game:GetService("Lighting")
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local TCS = game:GetService("TextChatService")
    local VU = game:GetService("VirtualUser")
    local Debris = game:GetService("Debris")
    local SG = game:GetService("StarterGui")
    local Stats = game:GetService("Stats")

    ASTRO.Services = {
        Players = Players,
        RunService = RunService,
        UserInputService = UIS,
        Workspace = Workspace,
        ReplicatedStorage = RS,
        Lighting = Lighting,
        HttpService = HttpService,
        TeleportService = TeleportService,
        TextChatService = TCS,
        VirtualUser = VU,
        Debris = Debris,
        StarterGui = SG,
        Stats = Stats,
        LocalPlayer = Players.LocalPlayer,
        Camera = Workspace.CurrentCamera,
    }
    return true
end

-- ============================================================
-- SETUP THEME
-- ============================================================
local function SetupTheme()
    local Library = ASTRO.Library
    local ThemeManager = ASTRO.ThemeManager
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetDefaultTheme({
        FontColor = "ffffff",
        MainColor = "0d0d0d",
        AccentColor = "#6c5ce7",
        BackgroundColor = "0a0a0a",
        OutlineColor = "1a1a1a",
        FontFace = "Code",
    })
end

-- ============================================================
-- CREATE WINDOW (dengan posisi tersimpan)
-- ============================================================
local function CreateMainWindow()
    local Library = ASTRO.Library
    local window = Library:CreateWindow({
        Title = ASTRO.Name .. " - " .. ASTRO.SubName,
        Footer = "Ultimate Mobile Edition",
        Size = UDim2.fromOffset(980, 740),
        Center = true,
        Resizable = true,
        ShowCustomCursor = true,
        NotifySide = "Right",
        CornerRadius = 6,
        ToggleKeybind = Enum.KeyCode.LeftAlt,
    })
    ASTRO.Window = window
    return window
end

-- ============================================================
-- SETUP TABS (Terstruktur dengan Left/Right Groupbox)
-- ============================================================
local function SetupTabs()
    local window = ASTRO.Window
    local tabs = {}

    -- Combat Tab
    tabs.Combat = window:AddTab("⚔️ Combat", "sword")
    tabs.SilentAim = tabs.Combat:AddSubTab("Silent Aim", "target")
    tabs.RageBot = tabs.Combat:AddSubTab("Rage Bot", "crosshair")
    tabs.HoldBot = tabs.Combat:AddSubTab("Hold Bot", "crosshair")
    tabs.TriggerBot = tabs.Combat:AddSubTab("Trigger Bot", "bot")
    tabs.SniperMode = tabs.Combat:AddSubTab("Sniper Mode", "scope")
    tabs.AntiAim = tabs.Combat:AddSubTab("Anti-Aim", "shield")
    tabs.AntiKatana = tabs.Combat:AddSubTab("Anti-Katana", "katana")
    tabs.AutoShoot = tabs.Combat:AddSubTab("Auto Shoot", "auto")

    -- ESP Tab
    tabs.ESP = window:AddTab("👁️ ESP", "eye")
    tabs.ESPPlayers = tabs.ESP:AddSubTab("Players", "users")
    tabs.ESPWorld = tabs.ESP:AddSubTab("World", "globe")
    tabs.ESPExtra = tabs.ESP:AddSubTab("Extra", "settings")

    -- Gun Mods Tab
    tabs.GunMods = window:AddTab("🔫 Gun Mods", "sliders")
    tabs.GunMain = tabs.GunMods:AddSubTab("Main", "sliders")
    tabs.GunAdvanced = tabs.GunMods:AddSubTab("Advanced", "settings")

    -- Movement Tab
    tabs.Movement = window:AddTab("🏃 Movement", "footprints")
    tabs.MoveMain = tabs.Movement:AddSubTab("Main", "footprints")
    tabs.MoveFly = tabs.Movement:AddSubTab("Fly", "plane")
    tabs.MoveAir = tabs.Movement:AddSubTab("Air", "wind")

    -- Visuals Tab
    tabs.Visuals = window:AddTab("🎨 Visuals", "paintbrush")
    tabs.VisMain = tabs.Visuals:AddSubTab("Main", "paintbrush")
    tabs.VisCrosshair = tabs.Visuals:AddSubTab("Crosshair", "target")
    tabs.VisSky = tabs.Visuals:AddSubTab("Sky", "cloud")
    tabs.VisThird = tabs.Visuals:AddSubTab("Third Person", "user")
    tabs.VisEffects = tabs.Visuals:AddSubTab("Effects", "sparkles")

    -- World Tab
    tabs.World = window:AddTab("🌍 World", "globe")
    tabs.WorldAtmo = tabs.World:AddSubTab("Atmosphere", "cloud")
    tabs.WorldLight = tabs.World:AddSubTab("Lighting", "sun")
    tabs.WorldFog = tabs.World:AddSubTab("Fog", "eye-off")
    tabs.WorldWeather = tabs.World:AddSubTab("Weather", "cloud-rain")

    -- Auto Tab
    tabs.Auto = window:AddTab("🤖 Auto", "bot")
    tabs.AutoMain = tabs.Auto:AddSubTab("Main", "play")
    tabs.AutoWalk = tabs.Auto:AddSubTab("Auto Walk", "footprints")
    tabs.AutoOrbit = tabs.Auto:AddSubTab("Orbit", "circle")
    tabs.AutoStick = tabs.Auto:AddSubTab("Stick", "user-plus")
    tabs.AutoWeapon = tabs.Auto:AddSubTab("Weapon Pick", "package")

    -- Teleport Tab
    tabs.Teleport = window:AddTab("📌 Teleport", "map-pin")
    tabs.TeleportMain = tabs.Teleport:AddSubTab("Main", "map-pin")

    -- Player / Server Tab
    tabs.Player = window:AddTab("👤 Player", "user")
    tabs.PlayerMain = tabs.Player:AddSubTab("Main", "user")
    tabs.PlayerServer = tabs.Player:AddSubTab("Server", "server")

    -- Rewards Tab
    tabs.Rewards = window:AddTab("🎁 Rewards", "gift")
    tabs.RewardsMain = tabs.Rewards:AddSubTab("Main", "gift")

    -- Spoofers Tab
    tabs.Spoofers = window:AddTab("🕵️ Spoofers", "eye-off")
    tabs.SpoofName = tabs.Spoofers:AddSubTab("Name", "user")
    tabs.SpoofDevice = tabs.Spoofers:AddSubTab("Device", "smartphone")
    tabs.SpoofLevel = tabs.Spoofers:AddSubTab("Level", "chart")

    -- Misc Tab
    tabs.Misc = window:AddTab("🔧 Misc", "wrench")
    tabs.MiscMain = tabs.Misc:AddSubTab("Main", "wrench")
    tabs.MiscProx = tabs.Misc:AddSubTab("Proximity", "map")

    -- Settings Tab
    tabs.Settings = window:AddTab("⚙️ Settings", "settings")
    tabs.Theme = tabs.Settings:AddSubTab("Theme", "paintbrush")
    tabs.Config = tabs.Settings:AddSubTab("Config", "folder")

    -- Info Tab
    tabs.Info = window:AddTab("ℹ️ Info", "info")

    ASTRO.Tabs = tabs
    return tabs
end

-- ============================================================
-- CORE UTILITIES (dari gng.lua)
-- ============================================================
local function GetCachedPlayers()
    local Players = ASTRO.Services.Players
    local now = tick()
    if now - ASTRO.Cache.PlayerCacheTick > 1 then
        ASTRO.Cache.Players = Players:GetPlayers()
        ASTRO.Cache.PlayerCacheTick = now
    end
    return ASTRO.Cache.Players
end

local function UpdateTeamCache()
    local lp = ASTRO.Services.LocalPlayer
    ASTRO.Cache.TeamCache.myTeamID = lp:GetAttribute("TeamID")
    ASTRO.Cache.TeamCache.lastUpdate = tick()
end
UpdateTeamCache()
ASTRO.Services.LocalPlayer:GetAttributeChangedSignal("TeamID"):Connect(UpdateTeamCache)

local function isTeammate(player)
    local TeamCheck = ASTRO.Features.SilentAim.TeamCheck or ASTRO.Features.ESP.TeamCheck
    if not TeamCheck then return false end
    local lp = ASTRO.Services.LocalPlayer
    if player == lp then return true end
    local myID = ASTRO.Cache.TeamCache.myTeamID
    local theirID = player:GetAttribute("TeamID")
    if myID and theirID and myID ~= 0 and theirID ~= 0 and myID == theirID then return true end
    local myTeam = lp.Team
    local theirTeam = player.Team
    if myTeam and theirTeam and myTeam == theirTeam then return true end
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
    local lp = ASTRO.Services.LocalPlayer
    local camera = ASTRO.Services.Camera
    local Players = ASTRO.Services.Players
    local uis = ASTRO.Services.UserInputService
    local Workspace = ASTRO.Services.Workspace

    local target = nil
    local bestDist = config.FOV or 150
    local center = uis:GetMouseLocation()
    local maxDistance = config.MaxDistance or math.huge
    local currentPart = config.HitPart or "Head"
    local wallCheck = config.WallCheck == true

    local camPos = camera.CFrame.Position
    local liveLpChar = lp.Character
    local playerList = GetCachedPlayers()

    for _, v in ipairs(playerList) do
        if v ~= lp and v.Character then
            if isTeammate(v) then continue end
            local humanoid = v.Character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end
            local hitPart = resolveHitPart(v.Character, currentPart)
            if not hitPart then continue end
            local partPos = hitPart.Position
            local pos, onScreen = camera:WorldToViewportPoint(partPos)
            if not onScreen then continue end
            local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
            if mag < config.FOV then
                local dist3D = (camPos - partPos).Magnitude
                if dist3D > maxDistance then continue end
                local isVisible = true
                if wallCheck then
                    local direction = partPos - camPos
                    local filterList = {liveLpChar}
                    for _, otherPlr in ipairs(playerList) do
                        if otherPlr ~= lp and otherPlr ~= v and otherPlr.Character then
                            filterList[#filterList + 1] = otherPlr.Character
                        end
                    end
                    local rayParams = RaycastParams.new()
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                    rayParams.FilterDescendantsInstances = filterList
                    rayParams.IgnoreWater = true
                    rayParams.RespectCanCollide = true
                    local result = Workspace:Raycast(camPos, direction, rayParams)
                    if result and result.Instance and result.Instance:IsA("BasePart") then
                        local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
                        if hitChar ~= v.Character then
                            local inst = result.Instance
                            if inst.CanCollide or inst.Transparency < 1 then
                                isVisible = false
                            end
                        end
                    end
                end
                if isVisible and mag < bestDist then
                    bestDist = mag
                    target = hitPart
                end
            end
        end
    end
    return target
end

-- ============================================================
-- SILENT AIM (__namecall hook + FOV)
-- ============================================================
local function SetupSilentAim()
    local SA = ASTRO.Features.SilentAim
    local lp = ASTRO.Services.LocalPlayer
    local Workspace = ASTRO.Services.Workspace
    local Camera = ASTRO.Services.Camera
    local uis = ASTRO.Services.UserInputService
    local Players = ASTRO.Services.Players
    local _inHook = false
    local _oldnc

    local function shouldHit()
        if not SA.Enabled then return false end
        return true
    end

    local function getTarget()
        local mouse = uis:GetMouseLocation()
        local bestdist = SA.FOV
        local besttarget = nil
        local camPos = Camera.CFrame.Position
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == lp then continue end
            local char = plr.Character
            if not char then continue end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            if isTeammate(plr) then continue end
            local refpart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            if not refpart then continue end
            local worldDist = (refpart.Position - camPos).Magnitude
            if worldDist > SA.MaxDistance then continue end
            local ok, screenpos, onscreen = pcall(function()
                return Camera:WorldToViewportPoint(refpart.Position)
            end)
            if not ok or not onscreen then continue end
            local dist = (Vector2.new(screenpos.X, screenpos.Y) - mouse).Magnitude
            if dist < bestdist then
                local direction = refpart.Position - camPos
                local filterList = {lp.Character}
                for _, otherPlr in ipairs(Players:GetPlayers()) do
                    if otherPlr ~= lp and otherPlr ~= plr and otherPlr.Character then
                        filterList[#filterList + 1] = otherPlr.Character
                    end
                end
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                rayParams.FilterDescendantsInstances = filterList
                rayParams.IgnoreWater = true
                rayParams.RespectCanCollide = true
                local result = Workspace:Raycast(camPos, direction, rayParams)
                if result and result.Instance and result.Instance:IsA("BasePart") then
                    local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
                    if hitChar == char then
                        bestdist = dist
                        local hitPart = resolveHitPart(char, SA.HitPart)
                        besttarget = hitPart
                    end
                else
                    bestdist = dist
                    local hitPart = resolveHitPart(char, SA.HitPart)
                    besttarget = hitPart
                end
            end
        end
        return besttarget
    end

    local function isShootRay(origin, direction)
        local camPos = Camera.CFrame.Position
        local mychar = lp.Character
        if not mychar then return false end
        local hrp = mychar:FindFirstChild("HumanoidRootPart")
        local head = mychar:FindFirstChild("Head")
        local camdist = (origin - camPos).Magnitude
        local hrdist = hrp and (origin - hrp.Position).Magnitude or math.huge
        local headdist = head and (origin - head.Position).Magnitude or math.huge
        return camdist <= 25 or hrdist <= 15 or headdist <= 15
    end

    _oldnc = hookmetamethod(Workspace, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if SA.Enabled and not _inHook and method == "Raycast" and self == Workspace then
            local args = {...}
            local origin = args[1]
            local direction = args[2]
            local params = args[3]
            if typeof(origin) == "Vector3" and typeof(direction) == "Vector3" then
                if isShootRay(origin, direction) then
                    if shouldHit() then
                        _inHook = true
                        local target = getTarget()
                        _inHook = false
                        if target then
                            local newdir = (target.Position - origin).Unit * direction.Magnitude
                            setnamecallmethod(method)
                            return _oldnc(self, origin, newdir, params)
                        end
                    end
                end
            end
        end
        setnamecallmethod(method)
        return _oldnc(self, ...)
    end))
end

-- ============================================================
-- RAGE BOT (Wallbang + Tracer + Spam Lock + Mobile Mode)
-- ============================================================
local function SetupRageBot()
    local RB = ASTRO.Features.RageBot
    local lp = ASTRO.Services.LocalPlayer
    local uis = ASTRO.Services.UserInputService
    local camera = ASTRO.Services.Camera
    local RunService = ASTRO.Services.RunService
    local RS = ASTRO.Services.ReplicatedStorage
    local Workspace = ASTRO.Services.Workspace
    local state = ASTRO.State
    local lastFire = 0
    local showUntil = 0

    -- Tracer drawing
    local tracerLine = Drawing.new("Line")
    tracerLine.Visible = false
    tracerLine.Color = RB.TracerColor
    tracerLine.Thickness = RB.TracerThickness
    tracerLine.Transparency = 1
    state.Tracer.line = tracerLine

    local function getOrigin3D()
        local char = lp.Character
        if char then
            local head = char:FindFirstChild("Head")
            if head then return head.Position end
        end
        return camera.CFrame.Position
    end

    local function applyWallbangMods()
        pcall(function()
            local Items = require(RS:WaitForChild("Modules", 10):WaitForChild("ItemLibrary", 10)).Items
            for name, data in pairs(Items) do
                if typeof(data) == "table" and RB.Wallbang then
                    data.ProjectileWallClipPreventionEnabled = false
                    data.RaycastPierceCount = 999
                    data.PierceCount = 999
                    data.MaxPierce = 999
                    data.Penetration = 999
                    data.CanPierce = true
                    data.IgnoreWalls = true
                end
            end
        end)
    end

    local wallbangLoop = task.spawn(function()
        while not ASTRO.Unloaded do
            if RB.Enabled and RB.Wallbang then
                applyWallbangMods()
            end
            task.wait(2)
        end
    end)

    local rageConn = RunService.RenderStepped:Connect(function()
        if not RB.Enabled then return end
        -- Mode check untuk mobile: "Always" atau keybind
        if RB.Mode == "Keybind" then
            if not uis:IsKeyDown(Enum.KeyCode.LeftControl) then return end
        end
        local target = get_best_target({
            FOV = RB.FOV,
            HitPart = "Head",
            MaxDistance = 1000,
            WallCheck = not RB.Wallbang,
        })
        if target then
            local targetPos = target.Position
            local pos2d, onScreen = camera:WorldToViewportPoint(targetPos)
            if onScreen then
                local mousePos = uis:GetMouseLocation()
                local delta = (Vector2.new(pos2d.X, pos2d.Y) - mousePos) * RB.AimSpeed
                delta = Vector2.new(math.clamp(delta.X, -50, 50), math.clamp(delta.Y, -50, 50))
                ASTRO:MoveMouseRelative(delta.X, delta.Y)
            end
            local now = tick()
            if RB.AutoShot and now - lastFire >= 0.015 then
                lastFire = now
                ASTRO:FireWeapon()
                showUntil = now + 0.4
            end
        end
        -- Tracer
        if RB.ShowTracer then
            local target2 = get_best_target({ FOV = RB.FOV, HitPart = "Head", MaxDistance = 1000 })
            if target2 and target2.Position then
                local pos, on = camera:WorldToViewportPoint(target2.Position)
                if on then
                    local start = uis:GetMouseLocation()
                    tracerLine.From = start
                    tracerLine.To = Vector2.new(pos.X, pos.Y)
                    tracerLine.Color = RB.TracerColor
                    tracerLine.Thickness = RB.TracerThickness
                    tracerLine.Visible = true
                else
                    tracerLine.Visible = false
                end
            else
                tracerLine.Visible = false
            end
        else
            tracerLine.Visible = false
        end
        -- Spam Lock
        if RB.SpamLock and uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local target3 = get_best_target({ FOV = RB.FOV, HitPart = "Head", MaxDistance = 1000, WallCheck = false })
            if target3 then
                local pos3, on = camera:WorldToViewportPoint(target3.Position)
                if on then
                    local mouse = uis:GetMouseLocation()
                    local dx, dy = pos3.X - mouse.X, pos3.Y - mouse.Y
                    local speed = 1.5
                    local lerp = math.clamp(1 - math.exp(-speed * 0.016), 0, 0.97)
                    local moveX = math.clamp(dx * lerp, -180, 180)
                    local moveY = math.clamp(dy * lerp, -180, 180)
                    ASTRO:MoveMouseRelative(moveX, moveY)
                end
            end
        end
    end)
end

-- ============================================================
-- HOLD BOT (Smooth Aimbot + Mobile Mode)
-- ============================================================
local function SetupHoldBot()
    local HB = ASTRO.Features.HoldBot
    local lp = ASTRO.Services.LocalPlayer
    local uis = ASTRO.Services.UserInputService
    local camera = ASTRO.Services.Camera
    local RunService = ASTRO.Services.RunService
    local state = ASTRO.State

    HB.FovVisible = HB.FovVisible or false
    HB.FovFilled = HB.FovFilled or false
    HB.FovColor = HB.FovColor or Color3.fromRGB(0,255,255)
    HB.FovRainbow = HB.FovRainbow or false

    local holdConn = RunService.RenderStepped:Connect(function()
        if not HB.Enabled then
            state.HoldBot.Active = false
            return
        end
        if HB.Mode == "Keybind" then
            if not uis:IsKeyDown(Enum.KeyCode.X) then return end
        end
        local target = get_best_target({
            FOV = HB.FOV,
            HitPart = HB.HitPart,
            MaxDistance = HB.MaxDistance,
            WallCheck = not HB.TargetBehindWalls,
        })
        if target then
            state.HoldBot.Active = true
            local pos2d, on = camera:WorldToViewportPoint(target.Position)
            if on then
                local mouse = uis:GetMouseLocation()
                local dx, dy = pos2d.X - mouse.X, pos2d.Y - mouse.Y
                if HB.Smoothing and HB.Smoothing > 1 then
                    local divisor = HB.Smoothing
                    local moveX = dx / divisor
                    local moveY = dy / divisor
                    if math.abs(moveX) < 0.04 then moveX = 0 end
                    if math.abs(moveY) < 0.04 then moveY = 0 end
                    ASTRO:MoveMouseRelative(moveX, moveY)
                else
                    local speed = 5
                    local clampedX = math.clamp(dx, -speed, speed)
                    local clampedY = math.clamp(dy, -speed, speed)
                    ASTRO:MoveMouseRelative(clampedX, clampedY)
                end
            end
        else
            state.HoldBot.Active = false
        end
    end)
end

-- ============================================================
-- TRIGGER BOT
-- ============================================================
local function SetupTriggerBot()
    local TB = ASTRO.Features.TriggerBot
    local lp = ASTRO.Services.LocalPlayer
    local uis = ASTRO.Services.UserInputService
    local camera = ASTRO.Services.Camera
    local RunService = ASTRO.Services.RunService
    local last = 0

    RunService.RenderStepped:Connect(function()
        if not TB.Enabled then return end
        if TB.Keybind and not uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
        local target = get_best_target({ FOV = 10, HitPart = "Head", MaxDistance = 1000, WallCheck = TB.WallCheck })
        if target then
            local now = tick()
            if now - last >= TB.Delay then
                last = now
                ASTRO:FireWeapon()
            end
        end
    end)
end

-- ============================================================
-- SNIPER MODE
-- ============================================================
local function SetupSniperMode()
    local SM = ASTRO.Features.SniperMode
    local lp = ASTRO.Services.LocalPlayer
    local uis = ASTRO.Services.UserInputService
    local RunService = ASTRO.Services.RunService
    local camera = ASTRO.Services.Camera

    RunService.RenderStepped:Connect(function()
        if not SM.Enabled then return end
        local target = get_best_target({ FOV = SM.Threshold, HitPart = "Head", MaxDistance = 500, WallCheck = true })
        if target and not SM.IsFiring and (tick() - SM.LastShot) >= SM.Cooldown then
            SM.IsFiring = true
            task.spawn(function()
                if mouse2press then pcall(mouse2press) end
                task.wait(SM.Delay)
                ASTRO:FireWeapon()
                task.wait(0.14)
                if mouse2release then pcall(mouse2release) end
                SM.LastShot = tick()
                task.wait(SM.Cooldown)
                SM.IsFiring = false
            end)
        end
    end)
end

-- ============================================================
-- ANTI-AIM (Lookdown + Neck + Yaw)
-- ============================================================
local function SetupAntiAim()
    local AA = ASTRO.Features.AntiAim
    local lp = ASTRO.Services.LocalPlayer
    local RunService = ASTRO.Services.RunService
    local Workspace = ASTRO.Services.Workspace
    local state = ASTRO.State

    local function findNeckMotor(char)
        if not char then return nil end
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("Motor6D") and string.lower(v.Name):find("neck") then return v end
        end
        return nil
    end

    local function hookCharacter(char)
        if not char then return end
        state.AntiAim.NeckMotor = findNeckMotor(char)
        if state.AntiAim.NeckMotor then
            state.AntiAim.NeckOrig = state.AntiAim.NeckMotor.C0
        end
    end
    if lp.Character then hookCharacter(lp.Character) end
    lp.CharacterAdded:Connect(function(char) task.wait(0.3) hookCharacter(char) end)

    local function apply()
        pcall(function()
            local cam = Workspace.CurrentCamera
            if not cam then return end
            local pos = cam.CFrame.Position
            local pitch = AA.Pitch / 90
            local look = Vector3.new(0, -pitch, -0.01)
            cam.CFrame = CFrame.new(pos, pos + look)
            if state.AntiAim.NeckMotor and state.AntiAim.NeckOrig then
                local rot = CFrame.Angles(math.rad(AA.Pitch), math.rad(AA.Yaw), 0)
                state.AntiAim.NeckMotor.C0 = state.AntiAim.NeckOrig * rot
            end
            if AA.Yaw ~= 0 then
                local char = lp.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum then
                        hum.AutoRotate = false
                        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(AA.Yaw), 0)
                    end
                end
            end
        end)
    end

    state.AntiAim.Conn1 = RunService.Heartbeat:Connect(function() if AA.Enabled then apply() end end)
    state.AntiAim.Conn2 = RunService.Stepped:Connect(function() if AA.Enabled then apply() end end)
    state.AntiAim.Conn3 = RunService.RenderStepped:Connect(function() if AA.Enabled then apply() end end)
end

-- ============================================================
-- ANTI-KATANA (ViewModels detection)
-- ============================================================
local function SetupAntiKatana()
    local AK = ASTRO.Features.AntiKatana
    local lp = ASTRO.Services.LocalPlayer
    local Players = ASTRO.Services.Players
    local Workspace = ASTRO.Services.Workspace
    local state = ASTRO.State

    local function extractWeaponName(modelName)
        local parts = string.split(modelName, " - ")
        if #parts >= 3 then return parts[3] end
        if #parts >= 2 then return parts[2] end
        return modelName
    end

    local function isKatana(name)
        if not name then return false end
        local l = string.lower(name)
        return string.find(l, "katana") or string.find(l, "sword") or string.find(l, "blade") or string.find(l, "sabre")
    end

    local function isDeflecting(player)
        if player == lp then return false end
        if not player.Character then return false end
        local vms = Workspace:FindFirstChild("ViewModels")
        if not vms then return false end
        for _, m in ipairs(vms:GetChildren()) do
            if m:IsA("Model") then
                local parts = string.split(m.Name, " - ")
                if #parts >= 1 and parts[1] == player.Name then
                    local wpn = extractWeaponName(m.Name)
                    if isKatana(wpn) then
                        local pChar = player.Character
                        local hrp = pChar:FindFirstChild("HumanoidRootPart")
                        local lpChar = lp.Character
                        local lpRoot = lpChar and lpChar:FindFirstChild("HumanoidRootPart")
                        if hrp and lpRoot then
                            local dist = (lpRoot.Position - hrp.Position).Magnitude
                            if dist <= 30 then
                                local dir = (lpRoot.Position - hrp.Position)
                                if dir.Magnitude > 0 then
                                    local forward = hrp.CFrame.LookVector
                                    if forward:Dot(dir.Unit) >= 0.3 then return true end
                                end
                            end
                        end
                    end
                end
            end
        end
        return false
    end

    task.spawn(function()
        while not ASTRO.Unloaded do
            if AK.Enabled then
                local deflecting = false
                local name = ""
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= lp and isDeflecting(p) then
                        deflecting = true
                        name = p.Name
                        break
                    end
                end
                if deflecting and not state.AntiKatana.WasDeflecting then
                    state.AntiKatana.WasDeflecting = true
                    ASTRO:Notify(name .. " is deflecting! Shots blocked.", 3)
                    ASTRO.Features.SilentAim.Enabled = false
                    ASTRO.Features.RageBot.Enabled = false
                elseif not deflecting and state.AntiKatana.WasDeflecting then
                    state.AntiKatana.WasDeflecting = false
                    ASTRO:Notify("Deflect ended. Resuming.", 3)
                end
            end
            task.wait(0.1)
        end
    end)
end

-- ============================================================
-- ESP (Full: Box, Filled, Tracer, Health, Names, Distance, Chams, Glow, Skeleton, Arrow, EnemyWeapons, Tripmine)
-- ============================================================
local function SetupESP()
    local ESP = ASTRO.Features.ESP
    local lp = ASTRO.Services.LocalPlayer
    local Players = ASTRO.Services.Players
    local Camera = ASTRO.Services.Camera
    local RunService = ASTRO.Services.RunService
    local Workspace = ASTRO.Services.Workspace
    local UIS = ASTRO.Services.UserInputService
    local state = ASTRO.State

    -- ScreenGui
    local EspGui = Instance.new("ScreenGui")
    EspGui.Name = "ASTRO_ESP"
    EspGui.ResetOnSpawn = false
    EspGui.IgnoreGuiInset = true
    pcall(function() EspGui.Parent = game:GetService("CoreGui") end)
    if not EspGui.Parent then EspGui.Parent = lp:WaitForChild("PlayerGui") end
    state.EspGui = EspGui

    local EspRegistry = {}
    local SkeletonCache = {}
    local OriginalHeadSizes = {}
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
        Stroke.Thickness = ESP.BoxThickness
        e.Box = BoxFrame; e.BoxStroke = Stroke
        -- Filled Box
        local Filled = Instance.new("Frame", EspGui)
        Filled.BorderSizePixel = 0
        Filled.Visible = false
        e.Filled = Filled
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
        e.CurrentGlow = nil
        EspRegistry[p] = e
    end

    local function removeElements(p)
        if EspRegistry[p] then
            if EspRegistry[p].CurrentCham then EspRegistry[p].CurrentCham:Destroy() end
            if EspRegistry[p].CurrentGlow then EspRegistry[p].CurrentGlow:Destroy() end
            for _, obj in pairs(EspRegistry[p]) do
                if typeof(obj) == "Instance" then obj:Destroy() end
            end
            EspRegistry[p] = nil
        end
        if SkeletonCache[p] then
            for _, line in ipairs(SkeletonCache[p]) do
                pcall(function() line:Remove() end)
            end
            SkeletonCache[p] = nil
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do createElements(p) end
    Players.PlayerAdded:Connect(createElements)
    Players.PlayerRemoving:Connect(removeElements)

    -- Arrow ESP (Drawing triangles)
    local arrows = {}
    local function setupArrows()
        for i = 1, 20 do
            local tri = Drawing.new("Triangle")
            tri.Thickness = 1
            tri.Filled = true
            tri.Color = Color3.fromRGB(100,200,255)
            tri.Visible = false
            arrows[i] = tri
        end
    end
    setupArrows()

    -- Enemy Weapons Panel
    local enemyWeaponsGui = nil
    local enemyWeaponsContainer = nil
    local enemyWeaponsLabels = {}
    local function setupEnemyWeaponsPanel()
        if enemyWeaponsGui then return end
        local sg = Instance.new("ScreenGui")
        sg.Name = "ASTRO_EnemyWeapons"
        sg.ResetOnSpawn = false
        sg.DisplayOrder = 9999
        sg.IgnoreGuiInset = true
        pcall(function() sg.Parent = game:GetService("CoreGui") end)
        if not sg.Parent then sg.Parent = lp:WaitForChild("PlayerGui") end
        local container = Instance.new("Frame", sg)
        container.Name = "Panel"
        container.Size = UDim2.new(0, 220, 0, 200)
        container.Position = UDim2.new(1, -240, 0, 80)
        container.BackgroundColor3 = Color3.fromRGB(20,18,30)
        container.BackgroundTransparency = 0.05
        container.BorderSizePixel = 0
        container.Visible = false
        local corner = Instance.new("UICorner", container)
        corner.CornerRadius = UDim.new(0,8)
        local stroke = Instance.new("UIStroke", container)
        stroke.Color = Color3.fromRGB(80,60,120)
        stroke.Thickness = 1
        stroke.Transparency = 0.4
        local title = Instance.new("TextLabel", container)
        title.Size = UDim2.new(1,0,0,28)
        title.BackgroundColor3 = Color3.fromRGB(40,30,60)
        title.Text = "ENEMY WEAPONS"
        title.Font = Enum.Font.GothamBold
        title.TextSize = 13
        title.TextColor3 = Color3.fromRGB(255,255,255)
        local titleCorner = Instance.new("UICorner", title)
        titleCorner.CornerRadius = UDim.new(0,8)
        local list = Instance.new("Frame", container)
        list.Name = "List"
        list.Size = UDim2.new(1,0,1,-32)
        list.Position = UDim2.new(0,0,0,30)
        list.BackgroundTransparency = 1
        local layout = Instance.new("UIListLayout", list)
        layout.SortOrder = Enum.SortOrder.Name
        layout.Padding = UDim.new(0,4)
        local padding = Instance.new("UIPadding", list)
        padding.PaddingLeft = UDim.new(0,6)
        padding.PaddingRight = UDim.new(0,6)
        padding.PaddingTop = UDim.new(0,4)
        enemyWeaponsGui = sg
        enemyWeaponsContainer = container
    end

    local function updateEnemyWeapons()
        if not ESP.EnemyWeapons then
            if enemyWeaponsContainer then enemyWeaponsContainer.Visible = false end
            return
        end
        if not enemyWeaponsContainer then setupEnemyWeaponsPanel() end
        enemyWeaponsContainer.Visible = true
        local vms = Workspace:FindFirstChild("ViewModels")
        if not vms then return end
        local seen = {}
        for _, m in ipairs(vms:GetChildren()) do
            if m:IsA("Model") then
                local parts = string.split(m.Name, " - ")
                if #parts >= 1 then
                    local pn = parts[1]
                    if pn ~= lp.Name then
                        local wpn = #parts >= 3 and parts[3] or (#parts >= 2 and parts[2] or m.Name)
                        seen[pn] = wpn
                    end
                end
            end
        end
        local list = enemyWeaponsContainer:FindFirstChild("List")
        if not list then return end
        for pn, wpn in pairs(seen) do
            if not enemyWeaponsLabels[pn] then
                local lbl = Instance.new("TextLabel", list)
                lbl.Size = UDim2.new(1,0,0,24)
                lbl.BackgroundColor3 = Color3.fromRGB(30,25,45)
                lbl.BackgroundTransparency = 0.2
                lbl.Font = Enum.Font.GothamSemibold
                lbl.TextSize = 12
                lbl.TextColor3 = Color3.fromRGB(255,255,255)
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                local c = Instance.new("UICorner", lbl)
                c.CornerRadius = UDim.new(0,4)
                local p = Instance.new("UIPadding", lbl)
                p.PaddingLeft = UDim.new(0,8)
                enemyWeaponsLabels[pn] = lbl
            end
            enemyWeaponsLabels[pn].Text = pn .. ": " .. wpn
        end
        for pn, lbl in pairs(enemyWeaponsLabels) do
            if not seen[pn] then
                pcall(function() lbl:Destroy() end)
                enemyWeaponsLabels[pn] = nil
            end
        end
    end

    -- Main ESP loop
    local espConn = RunService.RenderStepped:Connect(function()
        local globalColor = Color3.fromRGB(100,200,255)
        local globalFilledColor = Color3.fromRGB(100,200,255)
        local camPos = Camera.CFrame.Position
        local vp = Camera.ViewportSize

        -- Update enemy weapons
        updateEnemyWeapons()

        for player, cache in pairs(EspRegistry) do
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                if ESP.TeamCheck and isTeammate(player) then
                    cache.Box.Visible = false; cache.Filled.Visible = false; cache.Tracer.Visible = false
                    cache.HealthBar.Visible = false; cache.Name.Visible = false; cache.Dist.Visible = false
                    if cache.CurrentCham then cache.CurrentCham.Enabled = false end
                    if cache.CurrentGlow then cache.CurrentGlow.Enabled = false end
                    continue
                end
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                local dist = (camPos - root.Position).Magnitude
                if onScreen and dist <= ESP.MaxDistance then
                    local sizeX = ESP.BoxSizeMultiplier / dist
                    local sizeY = sizeX * 1.45
                    local boxX = pos.X - sizeX/2
                    local boxY = pos.Y - sizeY/2

                    -- Box
                    if ESP.Boxes then
                        cache.Box.Position = UDim2.new(0, boxX, 0, boxY)
                        cache.Box.Size = UDim2.new(0, sizeX, 0, sizeY)
                        cache.BoxStroke.Thickness = ESP.BoxThickness
                        cache.BoxStroke.Color = globalColor
                        cache.Box.Visible = true
                    else cache.Box.Visible = false end

                    -- Filled
                    if ESP.FilledBoxes then
                        cache.Filled.Position = UDim2.new(0, boxX, 0, boxY)
                        cache.Filled.Size = UDim2.new(0, sizeX, 0, sizeY)
                        cache.Filled.BackgroundColor3 = globalFilledColor
                        cache.Filled.BackgroundTransparency = ESP.FilledTransparency
                        cache.Filled.Visible = true
                    else cache.Filled.Visible = false end

                    -- Tracer
                    if ESP.Tracers then
                        local startX, startY = vp.X/2, vp.Y
                        local dx, dy = pos.X - startX, pos.Y - startY
                        local length = math.sqrt(dx^2 + dy^2)
                        local angle = math.atan2(dy, dx)
                        cache.Tracer.Position = UDim2.new(0, startX + dx/2, 0, startY + dy/2)
                        cache.Tracer.Size = UDim2.new(0, length, 0, ESP.LineThickness)
                        cache.Tracer.BackgroundColor3 = globalColor
                        cache.Tracer.Rotation = math.deg(angle)
                        cache.Tracer.Visible = true
                    else cache.Tracer.Visible = false end

                    -- Health
                    if ESP.Health then
                        local h = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        cache.HealthBar.Position = UDim2.new(0, boxX - HEALTH_OFFSET - HEALTH_WIDTH, 0, boxY)
                        cache.HealthBar.Size = UDim2.new(0, HEALTH_WIDTH, 0, sizeY)
                        cache.HealthFill.Size = UDim2.new(1,0, h,0)
                        cache.HealthFill.BackgroundColor3 = Color3.fromRGB(255,50,50):Lerp(Color3.fromRGB(0,255,140), h)
                        cache.HealthBar.Visible = true
                    else cache.HealthBar.Visible = false end

                    -- Name
                    if ESP.Names then
                        cache.Name.Position = UDim2.new(0, pos.X, 0, boxY - 4)
                        cache.Name.Text = player.DisplayName
                        cache.Name.TextSize = math.clamp(14 - dist/100, 10, 14)
                        cache.Name.Visible = true
                    else cache.Name.Visible = false end

                    -- Distance
                    if ESP.Distance then
                        cache.Dist.Position = UDim2.new(0, pos.X, 0, boxY + sizeY + 2)
                        cache.Dist.Text = math.floor(dist) .. " studs"
                        cache.Dist.TextSize = math.clamp(12 - dist/100, 9, 12)
                        cache.Dist.Visible = true
                    else cache.Dist.Visible = false end

                    -- Chams
                    if ESP.Chams then
                        if not cache.CurrentCham or cache.CurrentCham.Parent ~= char then
                            if cache.CurrentCham then cache.CurrentCham:Destroy() end
                            local hl = Instance.new("Highlight")
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            local neonMult = ESP.ChamsBrightness
                            local cc = globalColor
                            hl.FillColor = Color3.new(cc.R * neonMult, cc.G * neonMult, cc.B * neonMult)
                            hl.OutlineColor = Color3.new(cc.R * neonMult, cc.G * neonMult, cc.B * neonMult)
                            hl.FillTransparency = 0.2
                            hl.Parent = char
                            cache.CurrentCham = hl
                        end
                        cache.CurrentCham.Enabled = true
                    else
                        if cache.CurrentCham then cache.CurrentCham.Enabled = false end
                    end

                    -- Glow Chams
                    if ESP.GlowChams then
                        if not cache.CurrentGlow or cache.CurrentGlow.Parent ~= char then
                            if cache.CurrentGlow then cache.CurrentGlow:Destroy() end
                            local hl = Instance.new("Highlight")
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            local glowMult = ESP.GlowBrightness
                            local gc = globalColor
                            hl.FillColor = Color3.new(gc.R * glowMult, gc.G * glowMult, gc.B * glowMult)
                            hl.OutlineColor = Color3.new(gc.R * glowMult, gc.G * glowMult, gc.B * glowMult)
                            hl.FillTransparency = 0.5
                            hl.Parent = char
                            cache.CurrentGlow = hl
                        end
                        cache.CurrentGlow.Enabled = true
                    else
                        if cache.CurrentGlow then cache.CurrentGlow.Enabled = false end
                    end

                    -- Head Scale
                    if ESP.HeadScale > 1 then
                        local head = char:FindFirstChild("Head")
                        if head and head:IsA("BasePart") then
                            if not OriginalHeadSizes[head] then OriginalHeadSizes[head] = head.Size end
                            head.Size = OriginalHeadSizes[head] * ESP.HeadScale
                            head.Massless = true
                            head.CanCollide = false
                        end
                    end

                else
                    cache.Box.Visible = false; cache.Filled.Visible = false; cache.Tracer.Visible = false
                    cache.HealthBar.Visible = false; cache.Name.Visible = false; cache.Dist.Visible = false
                    if cache.CurrentCham then cache.CurrentCham.Enabled = false end
                    if cache.CurrentGlow then cache.CurrentGlow.Enabled = false end
                end
            else
                cache.Box.Visible = false; cache.Filled.Visible = false; cache.Tracer.Visible = false
                cache.HealthBar.Visible = false; cache.Name.Visible = false; cache.Dist.Visible = false
                if cache.CurrentCham then cache.CurrentCham.Enabled = false end
                if cache.CurrentGlow then cache.CurrentGlow.Enabled = false end
            end
        end

        -- Skeleton ESP
        if ESP.Skeleton then
            for player, cache in pairs(EspRegistry) do
                local char = player.Character
                if not char then continue end
                local head = char:FindFirstChild("Head")
                local torso = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
                local leftArm = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm")
                local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm")
                local leftLeg = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftUpperLeg")
                local rightLeg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightUpperLeg")
                local connections = {}
                if head and torso then table.insert(connections, {head, torso}) end
                if torso and leftArm then table.insert(connections, {torso, leftArm}) end
                if torso and rightArm then table.insert(connections, {torso, rightArm}) end
                if torso and leftLeg then table.insert(connections, {torso, leftLeg}) end
                if torso and rightLeg then table.insert(connections, {torso, rightLeg}) end
                if not SkeletonCache[player] then SkeletonCache[player] = {} end
                local sk = SkeletonCache[player]
                while #sk < #connections do
                    local line = Drawing.new("Line")
                    line.Visible = false
                    line.Color = globalColor
                    line.Thickness = 1.5
                    line.Transparency = 1
                    table.insert(sk, line)
                end
                for i, conn in ipairs(connections) do
                    local p1, on1 = Camera:WorldToViewportPoint(conn[1].Position)
                    local p2, on2 = Camera:WorldToViewportPoint(conn[2].Position)
                    if on1 and on2 then
                        sk[i].From = Vector2.new(p1.X, p1.Y)
                        sk[i].To = Vector2.new(p2.X, p2.Y)
                        sk[i].Visible = true
                    else
                        sk[i].Visible = false
                    end
                end
                for i = #connections + 1, #sk do sk[i].Visible = false end
            end
        else
            for _, sk in pairs(SkeletonCache) do
                for _, line in ipairs(sk) do line.Visible = false end
            end
        end

        -- Arrow ESP
        if ESP.Arrow then
            local mouse = UIS:GetMouseLocation()
            local center = Vector2.new(vp.X/2, vp.Y/2)
            local idx = 0
            for _, p in ipairs(GetCachedPlayers()) do
                if p ~= lp and p.Character and not isTeammate(p) then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    local root = p.Character:FindFirstChild("HumanoidRootPart")
                    if hum and root and hum.Health > 0 then
                        local pos, on = Camera:WorldToViewportPoint(root.Position)
                        local screenPos = Vector2.new(pos.X, pos.Y)
                        local dist = (screenPos - center).Magnitude
                        if not on or dist > 150 then
                            idx = idx + 1
                            local tri = arrows[idx]
                            if not tri then break end
                            local dir = (screenPos - center)
                            if dir.Magnitude > 0 then dir = dir.Unit else dir = Vector2.new(0,-1) end
                            local radius = math.min(vp.X, vp.Y)/2 - 20
                            local arrowPos = center + dir * radius
                            local perp = Vector2.new(-dir.Y, dir.X)
                            tri.PointA = arrowPos + dir * 8
                            tri.PointB = arrowPos - dir * 8 + perp * 8
                            tri.PointC = arrowPos - dir * 8 - perp * 8
                            tri.Color = globalColor
                            tri.Visible = true
                        end
                    end
                end
            end
            for i = idx + 1, #arrows do arrows[i].Visible = false end
        else
            for _, tri in ipairs(arrows) do tri.Visible = false end
        end
    end)

    -- Tripmine ESP (Sixth Sense)
    local tripmineLabels = {}
    local tripmineCount = 0
    local function isTripmine(part)
        if not part or not part:IsA("BasePart") then return false end
        local name = string.lower(part.Name)
        if string.find(name, "tripmine") or string.find(name, "subspace") then return true end
        local anc = part:FindFirstAncestorOfClass("Model")
        if anc then
            local an = string.lower(anc.Name)
            if string.find(an, "tripmine") or string.find(an, "subspace") then return true end
        end
        return false
    end
    local function addTripmineLabel(part)
        if tripmineLabels[part] then return end
        if tripmineCount >= 50 then return end
        local txt = Drawing.new("Text")
        txt.Text = "TRIPMINE"
        txt.Size = 18
        txt.Color = Color3.fromRGB(255,80,80)
        txt.Center = true
        txt.Outline = true
        txt.Visible = false
        tripmineLabels[part] = txt
        tripmineCount = tripmineCount + 1
    end
    local function removeTripmineLabel(part)
        local d = tripmineLabels[part]
        if d then d:Remove(); tripmineLabels[part] = nil; tripmineCount = tripmineCount - 1 end
    end
    local tripmineConn = RunService.RenderStepped:Connect(function()
        if not ESP.Tripmine then
            for _, d in pairs(tripmineLabels) do d.Visible = false end
            return
        end
        for part, d in pairs(tripmineLabels) do
            if not part or not part.Parent then
                removeTripmineLabel(part)
            else
                local pos, on = Camera:WorldToViewportPoint(part.Position)
                if on and pos.Z > 0 then
                    d.Position = Vector2.new(pos.X, pos.Y)
                    d.Visible = true
                else
                    d.Visible = false
                end
            end
        end
    end)
    local tripmineAdded = Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") and isTripmine(obj) then
            addTripmineLabel(obj)
        end
    end)
    local tripmineRemoved = Workspace.DescendantRemoving:Connect(function(obj)
        if obj:IsA("BasePart") then removeTripmineLabel(obj) end
    end)
    task.spawn(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and isTripmine(obj) then
                addTripmineLabel(obj)
            end
        end
    end)
end

-- ============================================================
-- GUN MODS (ItemLibrary manipulation)
-- ============================================================
local function SetupGunMods()
    local GM = ASTRO.Features.GunMods
    local RS = ASTRO.Services.ReplicatedStorage
    local function apply()
        pcall(function()
            local Items = require(RS:WaitForChild("Modules", 10):WaitForChild("ItemLibrary", 10)).Items
            for name, data in pairs(Items) do
                if typeof(data) == "table" and GM.Master then
                    if GM.NoRecoil then
                        if data.Recoil then data.Recoil = 0 end
                        if data.ShootRecoil then data.ShootRecoil = 0 end
                        if data.CameraRecoil then data.CameraRecoil = 0 end
                    end
                    if GM.NoSpread then
                        if data.Spread then data.Spread = 0 end
                        if data.ShootSpread then data.ShootSpread = 0 end
                        if data.ShootAccuracy then data.ShootAccuracy = 0 end
                    end
                    if GM.RapidFire then
                        if data.FireRate then data.FireRate = 0.01 end
                        if data.ShootDelay then data.ShootDelay = 0.01 end
                        if data.ShootCooldown then data.ShootCooldown = 0.01 end
                    end
                    if GM.OneShot then
                        if data.Damage then data.Damage = 9999 end
                        if data.BaseDamage then data.BaseDamage = 9999 end
                    end
                    if GM.InfiniteAmmo then
                        if data.MaxAmmo then data.MaxAmmo = 9999 end
                        if data.ClipSize then data.ClipSize = 9999 end
                    end
                    if GM.InstantReload then
                        if data.ReloadTime then data.ReloadTime = 0 end
                    end
                    if GM.InstantEquip then
                        if data.EquipTime then data.EquipTime = 0 end
                    end
                    if GM.NoBulletDrop then
                        if data.BulletDrop then data.BulletDrop = 0 end
                        if data.Gravity then data.Gravity = 0 end
                    end
                    if GM.MaxPierce then
                        if data.Pierce then data.Pierce = 999 end
                        if data.MaxPierce then data.MaxPierce = 999 end
                    end
                    if GM.NoCooldowns then
                        if data.Cooldown then data.Cooldown = 0 end
                        if data.AbilityCooldown then data.AbilityCooldown = 0 end
                    end
                end
            end
        end)
    end
    local loop = task.spawn(function()
        while not ASTRO.Unloaded do
            if GM.Master then apply() end
            task.wait(2)
        end
    end)
end

-- ============================================================
-- MOVEMENT (WalkSpeed, JumpPower, Noclip, InfiniteJump, Fly, SlideBoost, AirWalk, AutoBhop, AirStrafe, AutoJump, CircleStrafe, QuickStop, Gravity)
-- ============================================================
local function SetupMovement()
    local M = ASTRO.Features.Movement
    local lp = ASTRO.Services.LocalPlayer
    local uis = ASTRO.Services.UserInputService
    local RunService = ASTRO.Services.RunService
    local Workspace = ASTRO.Services.Workspace
    local state = ASTRO.State

    -- Fly
    local flyMovers = {}
    local function stopFly()
        state.Fly.Active = false
        if state.Fly.Conn then state.Fly.Conn:Disconnect(); state.Fly.Conn = nil end
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
        state.Fly.Active = true
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
        state.Fly.Conn = RunService.Heartbeat:Connect(function()
            if not state.Fly.Active then stopFly(); return end
            local char2 = lp.Character
            local root2 = char2 and char2:FindFirstChild("HumanoidRootPart")
            if not root2 or not bv.Parent or not bg.Parent then stopFly(); return end
            local cam = Workspace.CurrentCamera
            local vel = Vector3.zero
            if uis:IsKeyDown(Enum.KeyCode.W) then vel = vel + cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S) then vel = vel - cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.D) then vel = vel + cam.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.A) then vel = vel - cam.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.yAxis end
            if uis:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.yAxis end
            bv.Velocity = vel * speed
            bg.CFrame = cam.CFrame.Rotation + root2.Position
        end)
    end

    -- Infinite Jump
    uis.JumpRequest:Connect(function()
        if M.InfiniteJump then
            local char = lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)

    -- Auto Bhop
    RunService.Stepped:Connect(function()
        if M.AutoBhop then
            local char = lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and uis:IsKeyDown(Enum.KeyCode.Space) then
                hum.Jump = true
            end
        end
    end)

    -- Air Strafe, Auto Jump, Circle Strafe, Quick Stop
    RunService:BindToRenderStep("ASTRO_Movement", Enum.RenderPriority.Character.Value, function()
        local char = lp.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end

        if M.AutoJump and hum.FloorMaterial ~= Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end

        if M.AirStrafe and hum.FloorMaterial == Enum.Material.Air then
            local dir = hum.MoveDirection
            if dir.Magnitude > 0 then
                root.Velocity = Vector3.new(dir.X * M.AirStrafeStrength, root.Velocity.Y, dir.Z * M.AirStrafeStrength)
            end
        end

        if M.CircleStrafe and hum.FloorMaterial ~= Enum.Material.Air then
            local strafe = Vector3.zero
            if uis:IsKeyDown(Enum.KeyCode.A) then strafe = strafe + Vector3.new(-1,0,0) end
            if uis:IsKeyDown(Enum.KeyCode.D) then strafe = strafe + Vector3.new(1,0,0) end
            if strafe.Magnitude > 0 then
                root.Velocity = Vector3.new(strafe.X * hum.WalkSpeed, root.Velocity.Y, strafe.Z * hum.WalkSpeed)
            end
        end

        if M.QuickStop then
            local vel = root.Velocity
            if Vector3.new(vel.X,0,vel.Z).Magnitude < 0.1 and hum.MoveDirection.Magnitude == 0 then
                root.Velocity = Vector3.new(0, vel.Y, 0)
            end
        end
    end)

    -- Apply WalkSpeed, JumpPower, Noclip, AirWalk, SlideBoost, Gravity
    RunService.Stepped:Connect(function()
        local char = lp.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if M.WalkSpeedEnabled then hum.WalkSpeed = M.WalkSpeed end
        if M.JumpPowerEnabled then hum.JumpPower = M.JumpPower end
        if M.Noclip then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        if M.AirWalk then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local vel = root.AssemblyLinearVelocity
                if vel.Y < 0 then root.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z) end
            end
        end
        if M.SlideBoost and uis:IsKeyDown(Enum.KeyCode.LeftControl) then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = root.CFrame + Workspace.CurrentCamera.CFrame.LookVector * M.SlideBoostPower * 0.016
            end
        end
        if M.Gravity ~= 196 then
            Workspace.Gravity = M.Gravity
        end
    end)

    -- Expose fly controls
    ASTRO.startFly = startFly
    ASTRO.stopFly = stopFly
end

-- ============================================================
-- ORBIT
-- ============================================================
local function SetupOrbit()
    local ORB = ASTRO.Features.Orbit
    local lp = ASTRO.Services.LocalPlayer
    local Players = ASTRO.Services.Players
    local Workspace = ASTRO.Services.Workspace
    local RunService = ASTRO.Services.RunService
    local state = ASTRO.State

    local function findEnemy()
        local char = lp.Character
        if not char then return nil end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return nil end
        local nearest = nil
        local best = math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and not isTeammate(p) then
                local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
                local tHum = p.Character:FindFirstChildOfClass("Humanoid")
                if tRoot and tHum and tHum.Health > 0 then
                    local dist = (tRoot.Position - root.Position).Magnitude
                    if dist <= ORB.MaxDistance and dist < best then
                        best = dist
                        nearest = p
                    end
                end
            end
        end
        return nearest
    end

    local orbConn = RunService.Stepped:Connect(function(_, dt)
        if not ORB.Enabled then
            local char = lp.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and not hum.AutoRotate then hum.AutoRotate = true end
            end
            return
        end
        local char = lp.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root then return end
        local target = findEnemy()
        state.Orbit.Target = target
        if not target or not target.Character then return end
        local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
        local tHum = target.Character:FindFirstChildOfClass("Humanoid")
        if not tRoot or not tHum or tHum.Health <= 0 then return end
        if hum then hum.AutoRotate = false end
        state.Orbit.Angle = state.Orbit.Angle + ORB.Speed * dt
        local tPos = tRoot.Position
        local radius = ORB.Radius
        local height = ORB.Height
        local x = math.cos(state.Orbit.Angle) * radius
        local z = math.sin(state.Orbit.Angle) * radius
        local newPos = Vector3.new(tPos.X + x, tPos.Y + height, tPos.Z + z)
        pcall(function()
            root.CFrame = CFrame.new(newPos, tPos + Vector3.new(0, height, 0))
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end)
    end)
end

-- ============================================================
-- STICK TO TARGET
-- ============================================================
local function SetupStick()
    local ST = ASTRO.Features.Stick
    local lp = ASTRO.Services.LocalPlayer
    local Players = ASTRO.Services.Players
    local Workspace = ASTRO.Services.Workspace
    local RunService = ASTRO.Services.RunService

    local function findTarget()
        local char = lp.Character
        if not char then return nil end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return nil end
        local nearest = nil
        local best = math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and not isTeammate(p) then
                local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
                local tHum = p.Character:FindFirstChildOfClass("Humanoid")
                if tRoot and tHum and tHum.Health > 0 then
                    local dist = (tRoot.Position - root.Position).Magnitude
                    if dist <= ST.MaxDistance and dist < best then
                        best = dist
                        nearest = p
                    end
                end
            end
        end
        return nearest
    end

    RunService.Heartbeat:Connect(function()
        if not ST.Enabled then return end
        local char = lp.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local target = findTarget()
        if not target or not target.Character then return end
        local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if not tRoot then return end
        local tPos = tRoot.Position
        local stickPos = tPos + Vector3.new(0, 4, 0)
        if ST.Beneath then stickPos = tPos - Vector3.new(0, 4, 0) end
        local dest = CFrame.new(stickPos, tPos)
        if ST.Smooth then
            local alpha = math.clamp(ST.Smoothness / 100, 0, 1)
            pcall(function() root.CFrame = root.CFrame:Lerp(dest, alpha) end)
        else
            pcall(function() root.CFrame = dest end)
        end
    end)
end

-- ============================================================
-- AUTO WALK
-- ============================================================
local function SetupAutoWalk()
    local AW = ASTRO.Features.AutoWalk
    local lp = ASTRO.Services.LocalPlayer
    local uis = ASTRO.Services.UserInputService
    local RunService = ASTRO.Services.RunService

    RunService:BindToRenderStep("ASTRO_AutoWalk", Enum.RenderPriority.Character.Value, function()
        if not AW.Enabled then
            if keyrelease then
                pcall(keyrelease, 87); pcall(keyrelease, 65); pcall(keyrelease, 83); pcall(keyrelease, 68)
            end
            return
        end
        local char = lp.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end
        local target = get_best_target({ FOV = 360, HitPart = "Head", MaxDistance = 500, WallCheck = false })
        if not target or not target.Parent then
            if keyrelease then
                pcall(keyrelease, 87); pcall(keyrelease, 65); pcall(keyrelease, 83); pcall(keyrelease, 68)
            end
            return
        end
        local tRoot = target.Parent:FindFirstChild("HumanoidRootPart")
        if not tRoot then return end
        if uis:IsKeyDown(Enum.KeyCode.W) or uis:IsKeyDown(Enum.KeyCode.A) or
           uis:IsKeyDown(Enum.KeyCode.S) or uis:IsKeyDown(Enum.KeyCode.D) then
            if keyrelease then
                pcall(keyrelease, 87); pcall(keyrelease, 65); pcall(keyrelease, 83); pcall(keyrelease, 68)
            end
            return
        end
        local movePos = tRoot.Position
        if AW.Method == "Strafing" then
            local angle = tick() * 0.5
            movePos = tRoot.Position + Vector3.new(math.cos(angle)*5, 0, math.sin(angle)*5)
        elseif AW.Method == "Flanking" then
            local angle = tick() * 0.5
            movePos = tRoot.Position + Vector3.new(math.cos(angle)*10, 0, math.sin(angle)*10)
        end
        if keypress and keyrelease then
            pcall(keyrelease, 87); pcall(keyrelease, 65); pcall(keyrelease, 83); pcall(keyrelease, 68)
            local dir = (movePos - root.Position).Unit
            local fwd = dir:Dot(root.CFrame.LookVector)
            local right = dir:Dot(root.CFrame.RightVector)
            if fwd > 0.2 then pcall(keypress, 87) end
            if fwd < -0.2 then pcall(keypress, 83) end
            if right > 0.2 then pcall(keypress, 68) end
            if right < -0.2 then pcall(keypress, 65) end
        else
            hum:MoveTo(movePos)
        end
    end)
end

-- ============================================================
-- TELEPORT KILL
-- ============================================================
local function SetupTeleportKill()
    local TK = ASTRO.Features.TeleportKill
    local lp = ASTRO.Services.LocalPlayer
    local Players = ASTRO.Services.Players
    local RunService = ASTRO.Services.RunService
    local state = ASTRO.State

    local function findTarget(name)
        if not name or name == "" then return nil end
        local lower = string.lower(name)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then
                if string.find(string.lower(p.Name), lower) or string.find(string.lower(p.DisplayName), lower) then
                    return p
                end
            end
        end
        return nil
    end

    local function start()
        local target = findTarget(TK.TargetName)
        if not target then
            ASTRO:Notify("Target not found: " .. TK.TargetName, 4)
            return
        end
        TK.Enabled = true
        state.TeleportKill.Target = target
        if state.TeleportKill.Conn then state.TeleportKill.Conn:Disconnect() end
        state.TeleportKill.Conn = RunService.Heartbeat:Connect(function()
            if not TK.Enabled or not state.TeleportKill.Target then return end
            local myChar = lp.Character
            local tChar = state.TeleportKill.Target.Character
            if myChar and tChar then
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                local tRoot = tChar:FindFirstChild("HumanoidRootPart")
                if myRoot and tRoot then
                    myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, TK.Distance)
                end
            end
        end)
        ASTRO:Notify("Teleporting to " .. target.Name, 3)
    end

    local function stop()
        TK.Enabled = false
        if state.TeleportKill.Conn then
            state.TeleportKill.Conn:Disconnect()
            state.TeleportKill.Conn = nil
        end
        state.TeleportKill.Target = nil
        ASTRO:Notify("Teleport stopped", 3)
    end

    lp.CharacterAdded:Connect(function()
        task.wait(1)
        if TK.Enabled and TK.AutoReconnect and state.TeleportKill.Target then
            start()
        end
    end)

    ASTRO.TeleportKill = { start = start, stop = stop }
end

-- ============================================================
-- SERVER FUNCTIONS (Serverhop, Rejoin)
-- ============================================================
local function SetupServer()
    local Http = ASTRO.Services.HttpService
    local Teleport = ASTRO.Services.TeleportService
    local lp = ASTRO.Services.LocalPlayer

    function ASTRO:ServerHop()
        local placeId = game.PlaceId
        local jobId = game.JobId
        pcall(function()
            local data = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"))
            if data and data.data then
                for _, srv in pairs(data.data) do
                    if srv.playing < srv.maxPlayers and srv.id ~= jobId then
                        Teleport:TeleportToPlaceInstance(placeId, srv.id, lp)
                        break
                    end
                end
            end
        end)
    end

    function ASTRO:Rejoin()
        local placeId = game.PlaceId
        local jobId = game.JobId
        local Teleport = ASTRO.Services.TeleportService
        local Players = ASTRO.Services.Players
        if #Players:GetPlayers() <= 1 then
            Teleport:Teleport(placeId, lp)
        else
            Teleport:TeleportToPlaceInstance(placeId, jobId, lp)
        end
    end
end

-- ============================================================
-- REWARDS & CODES
-- ============================================================
local function SetupRewards()
    local RS = ASTRO.Services.ReplicatedStorage
    function ASTRO:ClaimAllRewards()
        local remotes = RS:FindFirstChild("Remotes")
        if not remotes then ASTRO:Notify("Remotes not found!"); return end
        local data = remotes:FindFirstChild("Data")
        if not data then ASTRO:Notify("Data remotes not found!"); return end
        local claimed = 0
        pcall(function()
            if data:FindFirstChild("ClaimLikeReward") then data.ClaimLikeReward:FireServer(); claimed = claimed + 1 end
        end)
        pcall(function()
            if data:FindFirstChild("ClaimFavoriteReward") then data.ClaimFavoriteReward:FireServer(); claimed = claimed + 1 end
        end)
        pcall(function()
            if data:FindFirstChild("ClaimNotificationsReward") then data.ClaimNotificationsReward:FireServer(); claimed = claimed + 1 end
        end)
        pcall(function()
            if data:FindFirstChild("ClaimWelcomeBackGift") then data.ClaimWelcomeBackGift:FireServer(); claimed = claimed + 1 end
        end)
        ASTRO:Notify("Claimed " .. claimed .. " rewards!")
    end

    function ASTRO:RedeemAllCodes()
        local remotes = RS:FindFirstChild("Remotes")
        if not remotes then ASTRO:Notify("Remotes not found!"); return end
        local data = remotes:FindFirstChild("Data")
        if not data then ASTRO:Notify("Data remotes not found!"); return end
        local redeem = data:FindFirstChild("RedeemCode")
        if not redeem then ASTRO:Notify("RedeemCode not found!"); return end
        local codes = {"COMMUNITY19", "FREE131", "BONUS", "ROBLOX_RTC", "BOOST"}
        local count = 0
        for _, code in ipairs(codes) do
            pcall(function() redeem:InvokeServer(code); count = count + 1; task.wait(0.3) end)
        end
        ASTRO:Notify("Tried " .. count .. " codes!")
    end
end

-- ============================================================
-- SPOOFERS (Name, Device, Level, Winstreak)
-- ============================================================
local function SetupSpoofers()
    local SP = ASTRO.Features.Spoofers
    local lp = ASTRO.Services.LocalPlayer
    local RS = ASTRO.Services.ReplicatedStorage

    -- Device Spoofer
    local deviceMap = { Controller = "Gamepad", PC = "MouseKeyboard", Mobile = "Touch", VR = "VR" }
    local function spoofDevice()
        if not SP.Device then return end
        local target = deviceMap[SP.DeviceTarget] or "Gamepad"
        pcall(function()
            local remotes = RS:WaitForChild("Remotes", 5)
            local rep = remotes:WaitForChild("Replication", 5)
            local fighter = rep:WaitForChild("Fighter", 5)
            local setControls = fighter:FindFirstChild("SetControls")
            if setControls then
                setControls:FireServer("MouseKeyboard")
                task.wait(0.3)
                setControls:FireServer(target)
            end
        end)
    end
    task.spawn(function()
        while not ASTRO.Unloaded do
            if SP.Device then spoofDevice() end
            task.wait(5)
        end
    end)

    -- Level & Winstreak spoof (visual only)
    local function spoofStats()
        local leaderstats = lp:FindFirstChild("CustomLeaderstats")
        if not leaderstats then return end
        if SP.Level then
            local levelVal = leaderstats:FindFirstChild("Level")
            if levelVal and levelVal:IsA("IntValue") then levelVal.Value = SP.LevelVal end
            pcall(function() lp:SetAttribute("Level", SP.LevelVal) end)
        end
        if SP.Winstreak then
            local streakFolder = leaderstats:FindFirstChild("Win Streak")
            if streakFolder then
                local sv = streakFolder:FindFirstChildWhichIsA("IntValue")
                if sv then sv.Value = SP.WinstreakVal end
            end
            pcall(function() lp:SetAttribute("StatisticDuelsWinStreak", SP.WinstreakVal) end)
        end
    end
    task.spawn(function()
        while not ASTRO.Unloaded do
            if SP.Level or SP.Winstreak then spoofStats() end
            task.wait(3)
        end
    end)
end

-- ============================================================
-- NAME SPOOFER (Full: UI, Billboard, Chat, Badge)
-- ============================================================
local function SetupNameSpoof()
    local NS = ASTRO.Features.NameSpoof
    local lp = ASTRO.Services.LocalPlayer
    local Workspace = ASTRO.Services.Workspace
    local TCS = ASTRO.Services.TextChatService
    local realName = lp.Name
    local realDisplay = lp.DisplayName
    local spoofedName = NS.Name
    local spoofedDisplay = NS.Name
    local badge = NS.Badge and " ✓" or ""
    local targetDisplay = spoofedDisplay .. badge

    local function shouldSpoof(obj)
        if not NS.Enabled then return false end
        if not obj or not obj.Text then return false end
        local text = obj.Text
        if string.find(text, spoofedDisplay) then return false end
        if NS.Mode == "Name" or NS.Mode == "Both" then
            if string.find(text, realName) then return true end
        end
        if NS.Mode == "DisplayName" or NS.Mode == "Both" then
            if string.find(text, realDisplay) then return true end
        end
        return false
    end

    local function spoofText(obj)
        if not shouldSpoof(obj) then return end
        local text = obj.Text
        local newText = text
        if NS.Mode == "Name" or NS.Mode == "Both" then
            newText = newText:gsub(realName, spoofedName)
        end
        if NS.Mode == "DisplayName" or NS.Mode == "Both" then
            newText = newText:gsub(realDisplay, targetDisplay)
        end
        if newText ~= text then obj.Text = newText end
    end

    local function hookGui(gui)
        for _, child in ipairs(gui:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                spoofText(child)
                child:GetPropertyChangedSignal("Text"):Connect(function()
                    if NS.Enabled then spoofText(child) end
                end)
            end
        end
        gui.DescendantAdded:Connect(function(obj)
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                task.wait(0.1)
                spoofText(obj)
                obj:GetPropertyChangedSignal("Text"):Connect(function()
                    if NS.Enabled then spoofText(obj) end
                end)
            end
        end)
    end

    -- Hook PlayerGui & CoreGui
    local playerGui = lp:WaitForChild("PlayerGui")
    hookGui(playerGui)
    local coreGui = game:GetService("CoreGui")
    hookGui(coreGui)

    -- Billboard in workspace
    local function hookBillboard(billboard)
        for _, txt in ipairs(billboard:GetDescendants()) do
            if txt:IsA("TextLabel") then
                spoofText(txt)
                txt:GetPropertyChangedSignal("Text"):Connect(function()
                    if NS.Enabled then spoofText(txt) end
                end)
            end
        end
        billboard.DescendantAdded:Connect(function(obj)
            if obj:IsA("TextLabel") then
                task.wait(0.1)
                spoofText(obj)
                obj:GetPropertyChangedSignal("Text"):Connect(function()
                    if NS.Enabled then spoofText(obj) end
                end)
            end
        end)
    end

    Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("BillboardGui") then
            task.wait(0.5)
            hookBillboard(obj)
        end
    end)
    for _, b in ipairs(Workspace:GetDescendants()) do
        if b:IsA("BillboardGui") then hookBillboard(b) end
    end

    -- Chat hook
    if TCS.ChatVersion == Enum.ChatVersion.TextChatService then
        TCS.OnIncomingMessage = function(message)
            if not NS.Enabled then return nil end
            local props = Instance.new("TextChatMessageProperties")
            if message.TextSource and message.TextSource.UserId == lp.UserId then
                props.PrefixText = targetDisplay
            end
            return props
        end
    end

    -- Humanoid DisplayName
    lp.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and NS.Enabled then
            hum.DisplayName = targetDisplay
            hum:GetPropertyChangedSignal("DisplayName"):Connect(function()
                if NS.Enabled and hum.DisplayName ~= targetDisplay then
                    hum.DisplayName = targetDisplay
                end
            end)
        end
    end)
end

-- ============================================================
-- AUTO WEAPON PICK
-- ============================================================
local function SetupAutoWeapon()
    local AW = ASTRO.Features.AutoWeapon
    local lp = ASTRO.Services.LocalPlayer
    local RS = ASTRO.Services.ReplicatedStorage
    local pickRemote = nil
    local prePickRemote = nil

    local function getRemotes()
        if pickRemote then return true end
        pcall(function()
            pickRemote = RS.Remotes.Replication.Fighter.PickWeapons
            prePickRemote = RS.Remotes.Duels.PickWeaponsAheadOfTime
        end)
        return pickRemote ~= nil
    end

    local function attemptPick()
        if not AW.Enabled then return end
        if not getRemotes() then return end
        local payload = {}
        for i = 1, 4 do
            local slot = AW.Slots[i]
            if slot and slot ~= "" then payload[i] = slot end
        end
        if not next(payload) then return end
        pcall(function() pickRemote:FireServer(payload) end)
        pcall(function() prePickRemote:FireServer(payload) end)
    end

    task.spawn(function()
        while not ASTRO.Unloaded do
            if AW.Enabled then
                local pg = lp:FindFirstChildOfClass("PlayerGui")
                local pickUI = pg and pg:FindFirstChild("PickWeapons", true)
                if pickUI and pickUI.Visible then
                    attemptPick()
                    repeat task.wait(0.1) until not pickUI.Visible
                end
            end
            task.wait(0.1)
        end
    end)
end

-- ============================================================
-- PROXIMITY ALERT
-- ============================================================
local function SetupProximity()
    local PROX = ASTRO.Features.Proximity
    local lp = ASTRO.Services.LocalPlayer
    local Players = ASTRO.Services.Players
    local lastAlert = 0

    task.spawn(function()
        while not ASTRO.Unloaded do
            if PROX.Enabled then
                local char = lp.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= lp and p.Character then
                                local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
                                local tHum = p.Character:FindFirstChildOfClass("Humanoid")
                                if tRoot and tHum and tHum.Health > 0 then
                                    local dist = (root.Position - tRoot.Position).Magnitude
                                    if dist <= PROX.Distance and tick() - lastAlert > 3 then
                                        lastAlert = tick()
                                        ASTRO:Notify(p.Name .. " is " .. math.floor(dist) .. " studs away!", 3)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.2)
        end
    end)
end

-- ============================================================
-- ANTI AFK
-- ============================================================
local function SetupAntiAFK()
    local AFK = ASTRO.Features.AntiAFK
    local vu = ASTRO.Services.VirtualUser
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
-- CROSSHAIR
-- ============================================================
local function SetupCrosshair()
    local VIS = ASTRO.Features.Visuals
    local lp = ASTRO.Services.LocalPlayer
    local RunService = ASTRO.Services.RunService
    local state = ASTRO.State

    local gui = Instance.new("ScreenGui")
    gui.Name = "ASTRO_Crosshair"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end
    state.Crosshair.gui = gui

    local anchor = Instance.new("Frame", gui)
    anchor.Name = "Anchor"
    anchor.Size = UDim2.new(0,0,0,0)
    anchor.Position = UDim2.new(0.5,0,0.5,0)
    anchor.BackgroundTransparency = 1
    anchor.AnchorPoint = Vector2.new(0.5,0.5)
    state.Crosshair.anchor = anchor

    local function createLine(name, ap)
        local line = Instance.new("Frame", anchor)
        line.Name = name
        line.BorderSizePixel = 0
        line.AnchorPoint = ap
        local stroke = Instance.new("UIStroke", line)
        stroke.Color = Color3.fromRGB(0,0,0)
        stroke.Thickness = 1.5
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        return line
    end
    state.Crosshair.cTop = createLine("Top", Vector2.new(0.5,1))
    state.Crosshair.cBottom = createLine("Bottom", Vector2.new(0.5,0))
    state.Crosshair.cLeft = createLine("Left", Vector2.new(1,0.5))
    state.Crosshair.cRight = createLine("Right", Vector2.new(0,0.5))

    local colors = { Red = Color3.fromRGB(255,50,50), Blue = Color3.fromRGB(0,180,255), Purple = Color3.fromRGB(160,32,240), Yellow = Color3.fromRGB(255,230,50), Pink = Color3.fromRGB(255,105,180), Orange = Color3.fromRGB(255,140,0), Cyan = Color3.fromRGB(0,255,255) }

    RunService.RenderStepped:Connect(function(dt)
        if not VIS.Crosshair then
            anchor.Visible = false
            return
        end
        anchor.Visible = true
        local color = colors[VIS.CrosshairColor] or colors.Purple
        state.Crosshair.cTop.BackgroundColor3 = color
        state.Crosshair.cBottom.BackgroundColor3 = color
        state.Crosshair.cLeft.BackgroundColor3 = color
        state.Crosshair.cRight.BackgroundColor3 = color
        anchor.Rotation = (anchor.Rotation + 45 * dt) % 360
        state.Crosshair.time = state.Crosshair.time + dt * 3
        local alpha = (math.sin(state.Crosshair.time) + 1) / 2
        local gap = 4 + alpha * 8
        state.Crosshair.cTop.Size = UDim2.new(0,3,0,14)
        state.Crosshair.cTop.Position = UDim2.new(0,0,0,-gap)
        state.Crosshair.cBottom.Size = UDim2.new(0,3,0,14)
        state.Crosshair.cBottom.Position = UDim2.new(0,0,0,gap)
        state.Crosshair.cLeft.Size = UDim2.new(0,14,0,3)
        state.Crosshair.cLeft.Position = UDim2.new(0,-gap,0,0)
        state.Crosshair.cRight.Size = UDim2.new(0,14,0,3)
        state.Crosshair.cRight.Position = UDim2.new(0,gap,0,0)
    end)
end

-- ============================================================
-- VISUAL EFFECTS (Sky, Fog, Weather, ThirdPerson, FOV, Bloom, HideSmoke/Flash, Tracer, Latex)
-- ============================================================
local function SetupVisuals()
    local VIS = ASTRO.Features.Visuals
    local lp = ASTRO.Services.LocalPlayer
    local Lighting = ASTRO.Services.Lighting
    local Workspace = ASTRO.Services.Workspace
    local RunService = ASTRO.Services.RunService
    local UIS = ASTRO.Services.UserInputService
    local Debris = ASTRO.Services.Debris

    -- Color constants
    local WORLD_COLORS = {
        red = Color3.fromRGB(255,0,0),
        orange = Color3.fromRGB(255,165,0),
        yellow = Color3.fromRGB(255,255,0),
        green = Color3.fromRGB(0,255,0),
        skyblue = Color3.fromRGB(135,206,235),
        blue = Color3.fromRGB(0,0,255),
        violet = Color3.fromRGB(238,130,238),
        pink = Color3.fromRGB(255,192,203),
        white = Color3.fromRGB(255,255,255),
        brown = Color3.fromRGB(139,69,19),
    }
    local BULLET_TRACER_COLORS = {
        Red = Color3.fromRGB(255,0,0),
        Green = Color3.fromRGB(0,255,0),
        Pink = Color3.fromRGB(255,50,255),
        Toothpaste = Color3.fromRGB(72,176,243),
        White = Color3.fromRGB(255,223,255),
    }

    -- Sky
    local function applySky()
        if VIS.SkyColor then
            Lighting.Ambient = VIS.SkyColorVal
            Lighting.OutdoorAmbient = VIS.SkyColorVal
            Lighting.Brightness = VIS.SkyBrightness
            Lighting.ClockTime = VIS.SkyClockTime
        else
            Lighting.Ambient = Color3.fromRGB(128,128,128)
            Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
        end
    end
    -- Fog
    local function applyFog()
        if VIS.Fog then
            Lighting.FogStart = 0
            Lighting.FogEnd = VIS.FogDistance
            local fogColor = WORLD_COLORS[VIS.FogColorName] or Color3.fromRGB(200,200,200)
            Lighting.FogColor = fogColor
        else
            Lighting.FogEnd = 100000
        end
    end
    -- Weather
    local weatherPart = nil
    local function applyWeather()
        if weatherPart then weatherPart:Destroy(); weatherPart = nil end
        if VIS.Weather == "None" then return end
        local part = Instance.new("Part")
        part.Name = "ASTRO_Weather"
        part.Anchored = true
        part.CanCollide = false
        part.Size = Vector3.new(1000, 1, 1000)
        part.Position = Vector3.new(0, 100, 0)
        part.Transparency = 0.5
        if VIS.Weather == "Rain" then
            part.Material = Enum.Material.Glass
            part.Color = Color3.fromRGB(170,170,255)
        elseif VIS.Weather == "Snow" then
            part.Material = Enum.Material.Snow
            part.Color = Color3.fromRGB(255,255,255)
        end
        part.Parent = Workspace
        weatherPart = part
    end
    -- ThirdPerson
    local function applyThirdPerson()
        if VIS.Thirdperson then
            lp.CameraMode = Enum.CameraMode.Classic
            lp.CameraMaxZoomDistance = VIS.ThirdpersonDistance
            lp.CameraMinZoomDistance = VIS.ThirdpersonDistance
        else
            lp.CameraMode = Enum.CameraMode.LockFirstPerson
        end
    end
    -- FOV override
    local function applyFOV()
        if VIS.FOVOverride then
            Workspace.CurrentCamera.FieldOfView = VIS.FOVValue
        end
    end
    -- Bloom
    local bloomEffect = nil
    local function applyBloom()
        if not bloomEffect then
            for _, child in ipairs(Lighting:GetDescendants()) do
                if child:IsA("BloomEffect") then bloomEffect = child break end
            end
        end
        if bloomEffect then
            bloomEffect.Enabled = VIS.Bloom
            bloomEffect.Intensity = VIS.BloomIntensity / 10
        end
    end

    -- Hide Smoke & Flash
    local function hideSmoke()
        if not VIS.HideSmoke then return end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "Smoke Grenade" or obj.Name:lower():find("smoke") then
                pcall(function() obj:Destroy() end)
            end
        end
    end
    local function hideFlash()
        if not VIS.HideFlash then return end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name:lower():find("flash") or obj.Name:lower():find("blind") then
                pcall(function() obj:Destroy() end)
            end
        end
        local pg = lp:FindFirstChildOfClass("PlayerGui")
        if pg then
            for _, gui in ipairs(pg:GetDescendants()) do
                if gui:IsA("Frame") or gui:IsA("ImageLabel") then
                    if string.lower(gui.Name):find("flash") then
                        gui.Visible = false
                    end
                end
            end
        end
    end

    -- Bullet Tracer (Trail)
    local function spawnTracer()
        if not VIS.BulletTracer then return end
        local char = lp.Character
        if not char then return end
        local head = char:FindFirstChild("Head")
        if not head then return end
        local color = BULLET_TRACER_COLORS[VIS.BulletTracerColor] or Color3.fromRGB(72,176,243)
        local part = Instance.new("Part")
        part.Size = Vector3.new(0.9,0.5,1)
        part.Color = color
        part.Material = Enum.Material.Neon
        part.Anchored = false
        part.CanCollide = false
        part.CanQuery = false
        part.CastShadow = false
        part.CFrame = head.CFrame
        part.Parent = Workspace
        local att0 = Instance.new("Attachment", part)
        att0.Position = Vector3.new(0,0,-0.15)
        local att1 = Instance.new("Attachment", part)
        att1.Position = Vector3.new(0,0,0.15)
        local trail = Instance.new("Trail", part)
        trail.Attachment0 = att0
        trail.Attachment1 = att1
        trail.FaceCamera = true
        trail.Lifetime = VIS.BulletTracerLifetime
        trail.LightEmission = 1
        trail.LightInfluence = 0
        trail.Brightness = 8
        trail.Color = ColorSequence.new(color)
        trail.Transparency = NumberSequence.new(0)
        trail.WidthScale = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.319),
            NumberSequenceKeypoint.new(1, 0.319)
        })
        trail.Enabled = true
        local bv = Instance.new("BodyVelocity", part)
        bv.MaxForce = Vector3.one * 100000
        bv.Velocity = Workspace.CurrentCamera.CFrame.LookVector * VIS.BulletTracerSpeed
        Debris:AddItem(part, 13)
    end
    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            spawnTracer()
        end
    end)

    -- Weapon & Arm Latex (ForceField material)
    local function applyLatex()
        if VIS.WeaponLatex then
            local vms = Workspace:FindFirstChild("ViewModels")
            if vms then
                for _, m in ipairs(vms:GetDescendants()) do
                    if m:IsA("BasePart") and (string.lower(m.Name):find("arm") or string.lower(m.Name):find("hand")) then
                        m.Material = Enum.Material.ForceField
                        m.Color = Color3.fromRGB(170,170,255)
                        m.Reflectance = 0.12
                    end
                end
            end
        end
        if VIS.ArmLatex then
            local char = lp.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and (string.lower(part.Name):find("arm") or string.lower(part.Name):find("hand")) then
                        part.Material = Enum.Material.ForceField
                        part.Color = Color3.fromRGB(170,170,255)
                        part.Reflectance = 0.12
                    end
                end
            end
        end
    end

    -- Loops
    task.spawn(function()
        while not ASTRO.Unloaded do
            applySky()
            applyFog()
            applyWeather()
            applyThirdPerson()
            applyFOV()
            applyBloom()
            hideSmoke()
            hideFlash()
            applyLatex()
            task.wait(1)
        end
    end)

    -- Thirdperson key toggle
    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if VIS.ThirdpersonKey ~= "Always on" then
            if input.KeyCode == Enum.KeyCode[VIS.ThirdpersonKey] then
                VIS.Thirdperson = not VIS.Thirdperson
                applyThirdPerson()
            end
        end
    end)

    -- Lock Indicator
    local lockGui = Instance.new("ScreenGui")
    lockGui.Name = "ASTRO_LockIndicator"
    lockGui.ResetOnSpawn = false
    pcall(function() lockGui.Parent = game:GetService("CoreGui") end)
    if not lockGui.Parent then lockGui.Parent = lp:WaitForChild("PlayerGui") end
    local lockLabel = Instance.new("TextLabel", lockGui)
    lockLabel.Size = UDim2.new(0, 250, 0, 25)
    lockLabel.Position = UDim2.new(1, -260, 0, 10)
    lockLabel.BackgroundTransparency = 1
    lockLabel.TextColor3 = Color3.fromRGB(255,80,80)
    lockLabel.Font = Enum.Font.Code
    lockLabel.TextSize = 12
    lockLabel.TextXAlignment = Enum.TextXAlignment.Right
    lockLabel.Text = "SCANNING..."
    lockLabel.Visible = false
    local lockCache = nil
    local lockCacheTime = 0

    RunService.RenderStepped:Connect(function()
        if VIS.LockIndicator then
            lockLabel.Visible = true
            if tick() - lockCacheTime > 0.1 then
                lockCacheTime = tick()
                local target = get_best_target({ FOV = 360, HitPart = "Head", MaxDistance = 1000, WallCheck = false })
                lockCache = target
            end
            if lockCache and lockCache.Parent then
                local p = ASTRO.Services.Players:GetPlayerFromCharacter(lockCache.Parent)
                if p then
                    lockLabel.Text = "LOCKED: " .. p.Name:upper()
                    lockLabel.TextColor3 = Color3.fromRGB(0,255,150)
                end
            else
                lockLabel.Text = "SCANNING..."
                lockLabel.TextColor3 = Color3.fromRGB(255,80,80)
            end
        else
            lockLabel.Visible = false
        end
    end)
end

-- ============================================================
-- AUTO SHOOT (Smart triggerbot dengan burst)
-- ============================================================
local function SetupAutoShoot()
    local AS = ASTRO.Features.AutoShoot
    local lp = ASTRO.Services.LocalPlayer
    local uis = ASTRO.Services.UserInputService
    local camera = ASTRO.Services.Camera
    local RunService = ASTRO.Services.RunService
    local state = ASTRO.State

    local function findTarget()
        local center = uis:GetMouseLocation()
        local radius = AS.Radius
        local best = nil
        local shortest = math.huge
        local camPos = camera.CFrame.Position

        for _, p in ipairs(GetCachedPlayers()) do
            if p ~= lp and p.Character then
                if AS.AntiFriendly and isTeammate(p) then continue end
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then continue end
                local hitPart = resolveHitPart(p.Character, AS.HitPart)
                if not hitPart then continue end
                local pos, onScreen = camera:WorldToViewportPoint(hitPart.Position)
                if not onScreen then continue end
                local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mag < radius and mag < shortest then
                    local isVisible = true
                    if AS.RequireVisible then
                        local direction = hitPart.Position - camPos
                        local filterList = {lp.Character}
                        for _, other in ipairs(GetCachedPlayers()) do
                            if other ~= lp and other ~= p and other.Character then
                                filterList[#filterList + 1] = other.Character
                            end
                        end
                        local rayParams = RaycastParams.new()
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude
                        rayParams.FilterDescendantsInstances = filterList
                        rayParams.IgnoreWater = true
                        rayParams.RespectCanCollide = true
                        local result = ASTRO.Services.Workspace:Raycast(camPos, direction, rayParams)
                        if result and result.Instance and result.Instance:IsA("BasePart") then
                            local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
                            if hitChar ~= p.Character then
                                isVisible = false
                            end
                        end
                    end
                    if isVisible then
                        shortest = mag
                        best = { player = p, part = hitPart, screenPos = Vector2.new(pos.X, pos.Y) }
                    end
                end
            end
        end
        return best
    end

    local function startLoop()
        if state.AutoShoot._conn then state.AutoShoot._conn:Disconnect() end
        state.AutoShoot._conn = RunService.RenderStepped:Connect(function()
            if not AS.Enabled then return end
            local target = findTarget()
            if target then
                local now = tick()
                local center = uis:GetMouseLocation()
                local dx, dy = target.screenPos.X - center.X, target.screenPos.Y - center.Y
                local dist = math.sqrt(dx*dx + dy*dy)
                if dist < 15 then
                    if AS._burstShotsLeft > 0 then
                        if now - AS._lastFire >= AS.BurstDelay then
                            AS._lastFire = now
                            AS._burstShotsLeft = AS._burstShotsLeft - 1
                            ASTRO:FireWeapon()
                        end
                    else
                        if now - AS._lastBurstTime >= AS.Cooldown then
                            AS._lastBurstTime = now
                            AS._burstShotsLeft = AS.BurstCount - 1
                            AS._lastFire = now
                            ASTRO:FireWeapon()
                        end
                    end
                else
                    AS._burstShotsLeft = 0
                end
            else
                AS._burstShotsLeft = 0
            end
        end)
    end

    -- Auto-start
    task.spawn(function()
        task.wait(2)
        startLoop()
    end)
end

-- ============================================================
-- HITBOX EXPANDER + 3D ESP SPHERE
-- ============================================================
local function SetupHitboxExpander()
    local HE = ASTRO.Features.HitboxExpander
    local lp = ASTRO.Services.LocalPlayer
    local Players = ASTRO.Services.Players
    local Workspace = ASTRO.Services.Workspace

    local function applyToChar(char)
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if not HE._originalSizes[char] then
            HE._originalSizes[char] = { Size = hrp.Size, Transparency = hrp.Transparency, CanCollide = hrp.CanCollide }
        end
        pcall(function()
            hrp.Size = Vector3.new(HE.Size, HE.Size, HE.Size)
            hrp.Transparency = HE.Transparency
            hrp.CanCollide = false
        end)
    end

    local function restoreChar(char)
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local orig = HE._originalSizes[char]
        if orig then
            pcall(function()
                hrp.Size = orig.Size
                hrp.Transparency = orig.Transparency
                hrp.CanCollide = orig.CanCollide
            end)
            HE._originalSizes[char] = nil
        end
    end

    task.spawn(function()
        while not ASTRO.Unloaded do
            if HE.Enabled then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= lp and p.Character and not isTeammate(p) then
                        applyToChar(p.Character)
                    end
                end
            end
            task.wait(0.5)
        end
    end)

    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if HE.Enabled and not isTeammate(p) then applyToChar(char) end
        end)
        p.CharacterRemoving:Connect(function(char)
            restoreChar(char)
        end)
    end)
end

-- ============================================================
-- FOV CIRCLES SETUP
-- ============================================================
function ASTRO:SetupFovCircles()
    local state = self.State

    -- Silent Aim
    state.FovCircles.SA.bg = Drawing.new("Circle")
    state.FovCircles.SA.bg.Thickness = 0
    state.FovCircles.SA.bg.Filled = true
    state.FovCircles.SA.bg.Transparency = 0.4
    state.FovCircles.SA.bg.Visible = false
    state.FovCircles.SA.bg.Color = Color3.fromRGB(255,255,255)
    state.FovCircles.SA.ring = Drawing.new("Circle")
    state.FovCircles.SA.ring.Thickness = 1.5
    state.FovCircles.SA.ring.Filled = false
    state.FovCircles.SA.ring.Transparency = 0.8
    state.FovCircles.SA.ring.Visible = false
    state.FovCircles.SA.ring.Color = Color3.fromRGB(255,255,255)

    -- Rage
    state.FovCircles.Rage.bg = Drawing.new("Circle")
    state.FovCircles.Rage.bg.Thickness = 0
    state.FovCircles.Rage.bg.Filled = true
    state.FovCircles.Rage.bg.Transparency = 0.4
    state.FovCircles.Rage.bg.Visible = false
    state.FovCircles.Rage.bg.Color = Color3.fromRGB(255,0,0)
    state.FovCircles.Rage.ring = Drawing.new("Circle")
    state.FovCircles.Rage.ring.Thickness = 1.5
    state.FovCircles.Rage.ring.Filled = false
    state.FovCircles.Rage.ring.Transparency = 0.8
    state.FovCircles.Rage.ring.Visible = false
    state.FovCircles.Rage.ring.Color = Color3.fromRGB(255,0,0)

    -- Hold
    state.FovCircles.Hold.bg = Drawing.new("Circle")
    state.FovCircles.Hold.bg.Thickness = 0
    state.FovCircles.Hold.bg.Filled = true
    state.FovCircles.Hold.bg.Transparency = 0.4
    state.FovCircles.Hold.bg.Visible = false
    state.FovCircles.Hold.bg.Color = Color3.fromRGB(0,255,255)
    state.FovCircles.Hold.ring = Drawing.new("Circle")
    state.FovCircles.Hold.ring.Thickness = 1.5
    state.FovCircles.Hold.ring.Filled = false
    state.FovCircles.Hold.ring.Transparency = 0.8
    state.FovCircles.Hold.ring.Visible = false
    state.FovCircles.Hold.ring.Color = Color3.fromRGB(0,255,255)
end

function ASTRO:UpdateFovCircles()
    local state = self.State
    local uis = self.Services.UserInputService
    local mouse = uis:GetMouseLocation()
    local SA = self.Features.SilentAim
    local RB = self.Features.RageBot
    local HB = self.Features.HoldBot
    local rainbow = Color3.fromHSV(tick() % 5 / 5, 1, 1)

    -- Silent Aim
    local saColor = SA.FovColor or Color3.fromRGB(255,255,255)
    if SA.FovRainbow then saColor = rainbow end
    state.FovCircles.SA.bg.Radius = SA.FOV
    state.FovCircles.SA.bg.Position = mouse
    state.FovCircles.SA.bg.Color = saColor
    state.FovCircles.SA.bg.Visible = SA.Enabled and SA.FovVisible and SA.FovFilled
    state.FovCircles.SA.ring.Radius = SA.FOV
    state.FovCircles.SA.ring.Position = mouse
    state.FovCircles.SA.ring.Color = saColor
    state.FovCircles.SA.ring.Visible = SA.Enabled and SA.FovVisible

    -- Rage
    local rageColor = RB.FovColor or Color3.fromRGB(255,0,0)
    if RB.FovRainbow then rageColor = rainbow end
    state.FovCircles.Rage.bg.Radius = RB.FOV
    state.FovCircles.Rage.bg.Position = mouse
    state.FovCircles.Rage.bg.Color = rageColor
    state.FovCircles.Rage.bg.Visible = RB.Enabled and RB.FovVisible and RB.FovFilled
    state.FovCircles.Rage.ring.Radius = RB.FOV
    state.FovCircles.Rage.ring.Position = mouse
    state.FovCircles.Rage.ring.Color = rageColor
    state.FovCircles.Rage.ring.Visible = RB.Enabled and RB.FovVisible

    -- Hold
    local holdColor = HB.FovColor or Color3.fromRGB(0,255,255)
    if HB.FovRainbow then holdColor = rainbow end
    state.FovCircles.Hold.bg.Radius = HB.FOV
    state.FovCircles.Hold.bg.Position = mouse
    state.FovCircles.Hold.bg.Color = holdColor
    state.FovCircles.Hold.bg.Visible = HB.Enabled and HB.FovVisible and HB.FovFilled
    state.FovCircles.Hold.ring.Radius = HB.FOV
    state.FovCircles.Hold.ring.Position = mouse
    state.FovCircles.Hold.ring.Color = holdColor
    state.FovCircles.Hold.ring.Visible = HB.Enabled and HB.FovVisible
end

-- ============================================================
-- BUILD UI (Full dengan Left/Right Groupbox)
-- ============================================================
local function BuildUI()
    local Library = ASTRO.Library
    local Tabs = ASTRO.Tabs
    local Options = ASTRO.Options
    local Toggles = ASTRO.Toggles
    local Features = ASTRO.Features

    -- ===== SILENT AIM (Left) =====
    local SA_Group = Tabs.SilentAim:AddLeftGroupbox("Silent Aim Settings", "target")
    SA_Group:AddToggle("SilentAim", { Text = "Enable", Default = false, Callback = function(v) Features.SilentAim.Enabled = v end })
    SA_Group:AddSlider("SA_FOV", { Text = "FOV Radius", Default = 150, Min = 50, Max = 500, Rounding = 0, Callback = function(v) Features.SilentAim.FOV = v end })
    SA_Group:AddDropdown("SA_HitPart", { Text = "Hit Part", Values = {"Head","UpperTorso","LowerTorso","HumanoidRootPart"}, Default = 1, Callback = function(v) Features.SilentAim.HitPart = v end })
    SA_Group:AddSlider("SA_Prediction", { Text = "Prediction", Default = 0.10, Min = 0, Max = 0.2, Rounding = 3, Callback = function(v) Features.SilentAim.Prediction = v end })
    SA_Group:AddSlider("SA_MaxDist", { Text = "Max Distance", Default = 2000, Min = 100, Max = 5000, Rounding = 0, Callback = function(v) Features.SilentAim.MaxDistance = v end })
    SA_Group:AddToggle("SA_WallCheck", { Text = "Wall Check", Default = true, Callback = function(v) Features.SilentAim.WallCheck = v end })
    SA_Group:AddToggle("SA_TeamCheck", { Text = "Team Check", Default = false, Callback = function(v) Features.SilentAim.TeamCheck = v end })
    SA_Group:AddDivider()
    SA_Group:AddToggle("SA_FovVisible", { Text = "Show FOV Circle", Default = false, Callback = function(v) Features.SilentAim.FovVisible = v end })
    SA_Group:AddToggle("SA_FovFilled", { Text = "Filled FOV", Default = false, Callback = function(v) Features.SilentAim.FovFilled = v end })
    SA_Group:AddLabel("FOV Color"):AddColorPicker("SA_FovColor", { Default = Color3.fromRGB(255,255,255), Callback = function(c) Features.SilentAim.FovColor = c end })
    SA_Group:AddToggle("SA_FovRainbow", { Text = "Rainbow FOV", Default = false, Callback = function(v) Features.SilentAim.FovRainbow = v end })

    -- ===== RAGE BOT (Left) =====
    local RB_Group = Tabs.RageBot:AddLeftGroupbox("Rage Bot Settings", "crosshair")
    RB_Group:AddToggle("RageBot", { Text = "Enable", Default = false, Callback = function(v) Features.RageBot.Enabled = v end })
    RB_Group:AddDropdown("RageMode", { Text = "Activation Mode (Mobile)", Values = {"Keybind (Ctrl)", "Always"}, Default = 1, Callback = function(v) Features.RageBot.Mode = v end })
    RB_Group:AddToggle("RageWallbang", { Text = "Wallbang", Default = false, Callback = function(v) Features.RageBot.Wallbang = v end })
    RB_Group:AddSlider("RageFOV", { Text = "FOV Radius", Default = 250, Min = 50, Max = 500, Rounding = 0, Callback = function(v) Features.RageBot.FOV = v end })
    RB_Group:AddSlider("RageSpeed", { Text = "Aim Speed", Default = 0.18, Min = 0.01, Max = 0.5, Rounding = 2, Callback = function(v) Features.RageBot.AimSpeed = v end })
    RB_Group:AddToggle("RageAutoShot", { Text = "Auto Shoot", Default = true, Callback = function(v) Features.RageBot.AutoShot = v end })
    RB_Group:AddToggle("RageSpamLock", { Text = "Spam Lock (LMB)", Default = false, Callback = function(v) Features.RageBot.SpamLock = v end })
    RB_Group:AddToggle("RageTracer", { Text = "Show Tracer", Default = true, Callback = function(v) Features.RageBot.ShowTracer = v end })
    RB_Group:AddDivider()
    RB_Group:AddToggle("Rage_FovVisible", { Text = "Show FOV Circle", Default = false, Callback = function(v) Features.RageBot.FovVisible = v end })
    RB_Group:AddToggle("Rage_FovFilled", { Text = "Filled FOV", Default = false, Callback = function(v) Features.RageBot.FovFilled = v end })
    RB_Group:AddLabel("FOV Color"):AddColorPicker("Rage_FovColor", { Default = Color3.fromRGB(255,0,0), Callback = function(c) Features.RageBot.FovColor = c end })
    RB_Group:AddToggle("Rage_FovRainbow", { Text = "Rainbow FOV", Default = false, Callback = function(v) Features.RageBot.FovRainbow = v end })

    -- ===== HOLD BOT (Left) =====
    local HB_Group = Tabs.HoldBot:AddLeftGroupbox("Hold Bot Settings", "crosshair")
    HB_Group:AddToggle("HoldBot", { Text = "Enable", Default = false, Callback = function(v) Features.HoldBot.Enabled = v end })
    HB_Group:AddDropdown("HoldMode", { Text = "Activation Mode (Mobile)", Values = {"Keybind (X)", "Always"}, Default = 1, Callback = function(v) Features.HoldBot.Mode = v end })
    HB_Group:AddSlider("HoldFOV", { Text = "FOV Radius", Default = 250, Min = 50, Max = 500, Rounding = 0, Callback = function(v) Features.HoldBot.FOV = v end })
    HB_Group:AddSlider("HoldSmooth", { Text = "Smoothing", Default = 3, Min = 1, Max = 20, Rounding = 0, Callback = function(v) Features.HoldBot.Smoothing = v end })
    HB_Group:AddDropdown("HoldHitPart", { Text = "Hit Part", Values = {"Head","UpperTorso","LowerTorso","HumanoidRootPart"}, Default = 1, Callback = function(v) Features.HoldBot.HitPart = v end })
    HB_Group:AddSlider("HoldMaxDist", { Text = "Max Distance", Default = 2000, Min = 100, Max = 3000, Rounding = 0, Callback = function(v) Features.HoldBot.MaxDistance = v end })
    HB_Group:AddToggle("HoldWall", { Text = "Wall Check", Default = true, Callback = function(v) Features.HoldBot.TargetBehindWalls = not v end })
    HB_Group:AddDivider()
    HB_Group:AddToggle("Hold_FovVisible", { Text = "Show FOV Circle", Default = false, Callback = function(v) Features.HoldBot.FovVisible = v end })
    HB_Group:AddToggle("Hold_FovFilled", { Text = "Filled FOV", Default = false, Callback = function(v) Features.HoldBot.FovFilled = v end })
    HB_Group:AddLabel("FOV Color"):AddColorPicker("Hold_FovColor", { Default = Color3.fromRGB(0,255,255), Callback = function(c) Features.HoldBot.FovColor = c end })
    HB_Group:AddToggle("Hold_FovRainbow", { Text = "Rainbow FOV", Default = false, Callback = function(v) Features.HoldBot.FovRainbow = v end })

    -- ===== TRIGGER BOT (Left) =====
    local TB_Group = Tabs.TriggerBot:AddLeftGroupbox("Trigger Bot", "bot")
    TB_Group:AddToggle("TriggerBot", { Text = "Enable", Default = false, Callback = function(v) Features.TriggerBot.Enabled = v end })
    TB_Group:AddToggle("TriggerAlways", { Text = "Always On (Mobile)", Default = false, Callback = function(v) Features.TriggerBot.Keybind = not v end })
    TB_Group:AddSlider("TriggerDelay", { Text = "Delay (s)", Default = 0.05, Min = 0.01, Max = 0.3, Rounding = 2, Callback = function(v) Features.TriggerBot.Delay = v end })
    TB_Group:AddToggle("TriggerWall", { Text = "Wall Check", Default = true, Callback = function(v) Features.TriggerBot.WallCheck = v end })

    -- ===== SNIPER MODE (Left) =====
    local SM_Group = Tabs.SniperMode:AddLeftGroupbox("Sniper Mode", "scope")
    SM_Group:AddToggle("SniperMode", { Text = "Enable", Default = false, Callback = function(v) Features.SniperMode.Enabled = v end })
    SM_Group:AddSlider("SniperThreshold", { Text = "Fire Threshold (px)", Default = 40, Min = 5, Max = 200, Rounding = 0, Callback = function(v) Features.SniperMode.Threshold = v end })
    SM_Group:AddSlider("SniperDelay", { Text = "ADS Delay (s)", Default = 0.23, Min = 0.05, Max = 1.0, Rounding = 2, Callback = function(v) Features.SniperMode.Delay = v end })
    SM_Group:AddSlider("SniperCooldown", { Text = "Cooldown (s)", Default = 0.85, Min = 0.1, Max = 3.0, Rounding = 2, Callback = function(v) Features.SniperMode.Cooldown = v end })

    -- ===== ANTI-AIM (Left) =====
    local AA_Group = Tabs.AntiAim:AddLeftGroupbox("Anti-Aim", "shield")
    AA_Group:AddToggle("AntiAim", { Text = "Enable", Default = false, Callback = function(v) Features.AntiAim.Enabled = v end })
    AA_Group:AddSlider("AAPitch", { Text = "Pitch (Lookdown)", Default = 85, Min = 0, Max = 90, Rounding = 0, Suffix = "°", Callback = function(v) Features.AntiAim.Pitch = v end })
    AA_Group:AddSlider("AAYaw", { Text = "Yaw Offset", Default = 0, Min = -180, Max = 180, Rounding = 0, Suffix = "°", Callback = function(v) Features.AntiAim.Yaw = v end })

    -- ===== ANTI-KATANA (Left) =====
    local AK_Group = Tabs.AntiKatana:AddLeftGroupbox("Anti-Katana", "katana")
    AK_Group:AddToggle("AntiKatana", { Text = "Enable", Default = false, Callback = function(v) Features.AntiKatana.Enabled = v end })
    AK_Group:AddLabel("Pauses aim when enemy deflects (ViewModels)", true)

    -- ===== AUTO SHOOT (Left) =====
    local AS_Group = Tabs.AutoShoot:AddLeftGroupbox("Auto Shoot", "auto")
    AS_Group:AddToggle("AutoShoot", { Text = "Enable", Default = false, Callback = function(v) Features.AutoShoot.Enabled = v end })
    AS_Group:AddSlider("AutoShootRadius", { Text = "Trigger Radius (px)", Default = 100, Min = 10, Max = 500, Rounding = 0, Callback = function(v) Features.AutoShoot.Radius = v end })
    AS_Group:AddSlider("AutoShootBurst", { Text = "Burst Count", Default = 3, Min = 1, Max = 10, Rounding = 0, Callback = function(v) Features.AutoShoot.BurstCount = v end })
    AS_Group:AddSlider("AutoShootDelay", { Text = "Burst Delay (ms)", Default = 50, Min = 0, Max = 300, Rounding = 0, Callback = function(v) Features.AutoShoot.BurstDelay = v/1000 end })
    AS_Group:AddSlider("AutoShootCooldown", { Text = "Cooldown (ms)", Default = 200, Min = 0, Max = 2000, Rounding = 0, Callback = function(v) Features.AutoShoot.Cooldown = v/1000 end })
    AS_Group:AddToggle("AutoShootWall", { Text = "Wall Check", Default = true, Callback = function(v) Features.AutoShoot.RequireVisible = v end })
    AS_Group:AddToggle("AutoShootTeam", { Text = "Anti-Friendly", Default = true, Callback = function(v) Features.AutoShoot.AntiFriendly = v end })

    -- ===== ESP PLAYERS (Left) =====
    local ESP_Group = Tabs.ESPPlayers:AddLeftGroupbox("ESP Players", "users")
    ESP_Group:AddToggle("EspBoxes", { Text = "Boxes", Default = false, Callback = function(v) Features.ESP.Boxes = v end })
    ESP_Group:AddToggle("EspFilled", { Text = "Filled Boxes", Default = false, Callback = function(v) Features.ESP.FilledBoxes = v end })
    ESP_Group:AddToggle("EspTracers", { Text = "Tracers", Default = false, Callback = function(v) Features.ESP.Tracers = v end })
    ESP_Group:AddToggle("EspHealth", { Text = "Health Bars", Default = false, Callback = function(v) Features.ESP.Health = v end })
    ESP_Group:AddToggle("EspNames", { Text = "Names", Default = false, Callback = function(v) Features.ESP.Names = v end })
    ESP_Group:AddToggle("EspDistance", { Text = "Distance", Default = false, Callback = function(v) Features.ESP.Distance = v end })
    ESP_Group:AddToggle("EspChams", { Text = "Chams", Default = false, Callback = function(v) Features.ESP.Chams = v end })
    ESP_Group:AddToggle("EspGlow", { Text = "Glow Chams", Default = false, Callback = function(v) Features.ESP.GlowChams = v end })
    ESP_Group:AddToggle("EspSkeleton", { Text = "Skeleton", Default = false, Callback = function(v) Features.ESP.Skeleton = v end })
    ESP_Group:AddToggle("EspArrow", { Text = "Arrow ESP", Default = false, Callback = function(v) Features.ESP.Arrow = v end })
    ESP_Group:AddToggle("EspTeam", { Text = "Team Check", Default = false, Callback = function(v) Features.ESP.TeamCheck = v end })
    ESP_Group:AddSlider("EspMaxDist", { Text = "Max Distance", Default = 400, Min = 100, Max = 2000, Rounding = 0, Callback = function(v) Features.ESP.MaxDistance = v end })
    ESP_Group:AddSlider("EspBoxThick", { Text = "Box Thickness", Default = 1.5, Min = 1, Max = 5, Rounding = 0.5, Callback = function(v) Features.ESP.BoxThickness = v end })
    ESP_Group:AddSlider("EspHeadScale", { Text = "Head Scale", Default = 1, Min = 1, Max = 3, Rounding = 0.1, Callback = function(v) Features.ESP.HeadScale = v end })

    -- ===== ESP WORLD (Left & Right) =====
    local TRIP_Group = Tabs.ESPWorld:AddLeftGroupbox("Tripmine ESP", "eye")
    TRIP_Group:AddToggle("TripmineESP", { Text = "Enable", Default = false, Callback = function(v) Features.ESP.Tripmine = v end })

    local EW_Group = Tabs.ESPWorld:AddRightGroupbox("Enemy Weapons Panel", "package")
    EW_Group:AddToggle("EnemyWeapons", { Text = "Show Panel", Default = false, Callback = function(v) Features.ESP.EnemyWeapons = v end })

    -- ===== GUN MODS (Left) =====
    local GM_Group = Tabs.GunMain:AddLeftGroupbox("Gun Mods", "sliders")
    GM_Group:AddToggle("GunMaster", { Text = "Master Enable", Default = false, Callback = function(v) Features.GunMods.Master = v end })
    GM_Group:AddToggle("GunNoRecoil", { Text = "No Recoil", Default = false, Callback = function(v) Features.GunMods.NoRecoil = v end })
    GM_Group:AddToggle("GunNoSpread", { Text = "No Spread", Default = false, Callback = function(v) Features.GunMods.NoSpread = v end })
    GM_Group:AddToggle("GunRapid", { Text = "Rapid Fire", Default = false, Callback = function(v) Features.GunMods.RapidFire = v end })
    GM_Group:AddToggle("GunOneShot", { Text = "One Shot Kill", Default = false, Callback = function(v) Features.GunMods.OneShot = v end })
    GM_Group:AddToggle("GunInfAmmo", { Text = "Infinite Ammo", Default = false, Callback = function(v) Features.GunMods.InfiniteAmmo = v end })
    GM_Group:AddToggle("GunInstantReload", { Text = "Instant Reload", Default = false, Callback = function(v) Features.GunMods.InstantReload = v end })
    GM_Group:AddToggle("GunInstantEquip", { Text = "Instant Equip", Default = false, Callback = function(v) Features.GunMods.InstantEquip = v end })
    GM_Group:AddToggle("GunNoDrop", { Text = "No Bullet Drop", Default = false, Callback = function(v) Features.GunMods.NoBulletDrop = v end })
    GM_Group:AddToggle("GunMaxPierce", { Text = "Max Pierce", Default = false, Callback = function(v) Features.GunMods.MaxPierce = v end })
    GM_Group:AddToggle("GunNoCooldown", { Text = "No Cooldowns", Default = false, Callback = function(v) Features.GunMods.NoCooldowns = v end })

    -- ===== MOVEMENT (Left) =====
    local MV_Group = Tabs.MoveMain:AddLeftGroupbox("Movement", "footprints")
    MV_Group:AddToggle("MoveSpeed", { Text = "Custom Walk Speed", Default = false, Callback = function(v) Features.Movement.WalkSpeedEnabled = v end })
    MV_Group:AddSlider("MoveSpeedVal", { Text = "Walk Speed", Default = 50, Min = 16, Max = 200, Rounding = 0, Callback = function(v) Features.Movement.WalkSpeed = v end })
    MV_Group:AddToggle("MoveJump", { Text = "Custom Jump Power", Default = false, Callback = function(v) Features.Movement.JumpPowerEnabled = v end })
    MV_Group:AddSlider("MoveJumpVal", { Text = "Jump Power", Default = 50, Min = 1, Max = 300, Rounding = 0, Callback = function(v) Features.Movement.JumpPower = v end })
    MV_Group:AddToggle("MoveNoclip", { Text = "Noclip", Default = false, Callback = function(v) Features.Movement.Noclip = v end })
    MV_Group:AddToggle("MoveInfJump", { Text = "Infinite Jump", Default = false, Callback = function(v) Features.Movement.InfiniteJump = v end })
    MV_Group:AddToggle("MoveAirWalk", { Text = "Air Walk", Default = false, Callback = function(v) Features.Movement.AirWalk = v end })
    MV_Group:AddToggle("MoveSlide", { Text = "Slide Boost", Default = false, Callback = function(v) Features.Movement.SlideBoost = v end })
    MV_Group:AddSlider("MoveSlidePower", { Text = "Slide Power", Default = 4, Min = 1, Max = 15, Rounding = 0.5, Callback = function(v) Features.Movement.SlideBoostPower = v end })
    MV_Group:AddToggle("MoveBhop", { Text = "Auto Bhop", Default = false, Callback = function(v) Features.Movement.AutoBhop = v end })
    MV_Group:AddSlider("MoveGravity", { Text = "Gravity", Default = 196, Min = 10, Max = 400, Rounding = 0, Callback = function(v) Features.Movement.Gravity = v end })

    -- ===== FLY (Left) =====
    local FLY_Group = Tabs.MoveFly:AddLeftGroupbox("Fly", "plane")
    FLY_Group:AddToggle("FlyEnable", { Text = "Enable Fly", Default = false, Callback = function(v)
        Features.Movement.Fly = v
        if v then ASTRO.startFly(Features.Movement.FlySpeed) else ASTRO.stopFly() end
    end })
    FLY_Group:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 80, Min = 10, Max = 500, Rounding = 0, Callback = function(v)
        Features.Movement.FlySpeed = v
        if Features.Movement.Fly then ASTRO.stopFly(); task.wait(0.05); ASTRO.startFly(v) end
    end })

    -- ===== AIR MOVEMENT (Left) =====
    local AIR_Group = Tabs.MoveAir:AddLeftGroupbox("Air Movement", "wind")
    AIR_Group:AddToggle("AirStrafe", { Text = "Air Strafe", Default = false, Callback = function(v) Features.Movement.AirStrafe = v end })
    AIR_Group:AddSlider("AirStrafeStr", { Text = "Strength", Default = 20, Min = 5, Max = 100, Rounding = 0, Callback = function(v) Features.Movement.AirStrafeStrength = v end })
    AIR_Group:AddToggle("AutoJump", { Text = "Auto Jump", Default = false, Callback = function(v) Features.Movement.AutoJump = v end })
    AIR_Group:AddToggle("CircleStrafe", { Text = "Circle Strafe", Default = false, Callback = function(v) Features.Movement.CircleStrafe = v end })
    AIR_Group:AddToggle("QuickStop", { Text = "Quick Stop", Default = false, Callback = function(v) Features.Movement.QuickStop = v end })

    -- ===== AUTO WALK (Left) =====
    local AW_Group = Tabs.AutoWalk:AddLeftGroupbox("Auto Walk", "footprints")
    AW_Group:AddToggle("AutoWalk", { Text = "Enable", Default = false, Callback = function(v) Features.AutoWalk.Enabled = v end })
    AW_Group:AddDropdown("AutoWalkMethod", { Text = "Method", Values = {"Normal","Strafing","Flanking"}, Default = 1, Callback = function(v) Features.AutoWalk.Method = v end })

    -- ===== ORBIT (Left) =====
    local ORB_Group = Tabs.AutoOrbit:AddLeftGroupbox("Orbit", "circle")
    ORB_Group:AddToggle("Orbit", { Text = "Enable", Default = false, Callback = function(v) Features.Orbit.Enabled = v end })
    ORB_Group:AddSlider("OrbitRadius", { Text = "Radius", Default = 8, Min = 3, Max = 30, Rounding = 0.5, Callback = function(v) Features.Orbit.Radius = v end })
    ORB_Group:AddSlider("OrbitSpeed", { Text = "Speed", Default = 3, Min = 0.5, Max = 15, Rounding = 0.5, Callback = function(v) Features.Orbit.Speed = v end })
    ORB_Group:AddSlider("OrbitHeight", { Text = "Height", Default = 3, Min = 0, Max = 15, Rounding = 0.5, Callback = function(v) Features.Orbit.Height = v end })
    ORB_Group:AddSlider("OrbitMaxDist", { Text = "Max Distance", Default = 400, Min = 100, Max = 2000, Rounding = 0, Callback = function(v) Features.Orbit.MaxDistance = v end })

    -- ===== STICK (Left) =====
    local ST_Group = Tabs.AutoStick:AddLeftGroupbox("Stick to Target", "user-plus")
    ST_Group:AddToggle("Stick", { Text = "Enable", Default = false, Callback = function(v) Features.Stick.Enabled = v end })
    ST_Group:AddToggle("StickSmooth", { Text = "Smooth", Default = false, Callback = function(v) Features.Stick.Smooth = v end })
    ST_Group:AddSlider("StickSmoothness", { Text = "Smoothness", Default = 50, Min = 0, Max = 100, Rounding = 0, Callback = function(v) Features.Stick.Smoothness = v end })
    ST_Group:AddToggle("StickBeneath", { Text = "Beneath Player", Default = false, Callback = function(v) Features.Stick.Beneath = v end })
    ST_Group:AddSlider("StickMaxDist", { Text = "Max Distance", Default = 400, Min = 100, Max = 2000, Rounding = 0, Callback = function(v) Features.Stick.MaxDistance = v end })

    -- ===== AUTO WEAPON PICK (Left) =====
    local AW_Group2 = Tabs.AutoWeapon:AddLeftGroupbox("Auto Weapon Pick", "package")
    AW_Group2:AddToggle("AutoWeapon", { Text = "Enable", Default = false, Callback = function(v) Features.AutoWeapon.Enabled = v end })
    for i = 1, 4 do
        AW_Group2:AddInput("WeaponSlot"..i, { Text = "Slot "..i, Default = "", Finished = true, Callback = function(v) Features.AutoWeapon.Slots[i] = v end })
    end

    -- ===== TELEPORT KILL (Left) =====
    local TP_Group = Tabs.TeleportMain:AddLeftGroupbox("Teleport Kill", "map-pin")
    TP_Group:AddInput("TpTarget", { Text = "Target Name", Default = "", Finished = true, Callback = function(v) Features.TeleportKill.TargetName = v end })
    TP_Group:AddSlider("TpDist", { Text = "Distance", Default = 3, Min = 1, Max = 20, Rounding = 0.5, Callback = function(v) Features.TeleportKill.Distance = v end })
    TP_Group:AddToggle("TpAutoReconnect", { Text = "Auto Reconnect", Default = true, Callback = function(v) Features.TeleportKill.AutoReconnect = v end })
    TP_Group:AddButton("Start Teleport", function() ASTRO.TeleportKill.start() end)
    TP_Group:AddButton("Stop Teleport", function() ASTRO.TeleportKill.stop() end)

    -- ===== REWARDS (Left) =====
    local RW_Group = Tabs.RewardsMain:AddLeftGroupbox("Rewards", "gift")
    RW_Group:AddButton("Claim All Rewards", function() ASTRO:ClaimAllRewards() end)
    RW_Group:AddButton("Redeem All Codes", function() ASTRO:RedeemAllCodes() end)

    -- ===== SPOOFERS (Left) =====
    local NAME_Group = Tabs.SpoofName:AddLeftGroupbox("Name Spoofer", "user")
    NAME_Group:AddToggle("NameSpoof", { Text = "Enable", Default = false, Callback = function(v) Features.NameSpoof.Enabled = v end })
    NAME_Group:AddInput("NameSpoofName", { Text = "Spoofed Name", Default = "ZytheraX", Finished = true, Callback = function(v) Features.NameSpoof.Name = v end })
    NAME_Group:AddDropdown("NameSpoofMode", { Text = "Mode", Values = {"Both","Name","DisplayName"}, Default = 1, Callback = function(v) Features.NameSpoof.Mode = v end })
    NAME_Group:AddToggle("NameSpoofBadge", { Text = "Add Verified Badge ✓", Default = true, Callback = function(v) Features.NameSpoof.Badge = v end })

    local DEV_Group = Tabs.SpoofDevice:AddLeftGroupbox("Device Spoofer", "smartphone")
    DEV_Group:AddToggle("DeviceSpoof", { Text = "Enable", Default = false, Callback = function(v) Features.Spoofers.Device = v end })
    DEV_Group:AddDropdown("DeviceTarget", { Text = "Target", Values = {"Controller","PC","Mobile","VR"}, Default = 1, Callback = function(v) Features.Spoofers.DeviceTarget = v end })

    local LVL_Group = Tabs.SpoofLevel:AddLeftGroupbox("Level / Winstreak", "chart")
    LVL_Group:AddToggle("LevelSpoof", { Text = "Spoof Level", Default = false, Callback = function(v) Features.Spoofers.Level = v end })
    LVL_Group:AddSlider("LevelVal", { Text = "Level", Default = 996, Min = 1, Max = 9999, Rounding = 0, Callback = function(v) Features.Spoofers.LevelVal = v end })
    LVL_Group:AddToggle("WinstreakSpoof", { Text = "Spoof Winstreak", Default = false, Callback = function(v) Features.Spoofers.Winstreak = v end })
    LVL_Group:AddSlider("WinstreakVal", { Text = "Winstreak", Default = 56, Min = 0, Max = 9999, Rounding = 0, Callback = function(v) Features.Spoofers.WinstreakVal = v end })

    -- ===== PROXIMITY (Left) =====
    local PROX_Group = Tabs.MiscProx:AddLeftGroupbox("Proximity Alert", "map")
    PROX_Group:AddToggle("Proximity", { Text = "Enable", Default = false, Callback = function(v) Features.Proximity.Enabled = v end })
    PROX_Group:AddSlider("ProxDist", { Text = "Alert Distance", Default = 30, Min = 10, Max = 200, Rounding = 0, Callback = function(v) Features.Proximity.Distance = v end })

    -- ===== ANTI AFK (Left) =====
    local AFK_Group = Tabs.MiscMain:AddLeftGroupbox("Anti AFK", "clock")
    AFK_Group:AddToggle("AntiAFK", { Text = "Enable", Default = false, Callback = function(v) Features.AntiAFK.Enabled = v end })

    -- ===== SERVER (Left) =====
    local SRV_Group = Tabs.PlayerServer:AddLeftGroupbox("Server", "server")
    SRV_Group:AddButton("Server Hop", function() ASTRO:ServerHop() end)
    SRV_Group:AddButton("Rejoin", function() ASTRO:Rejoin() end)

    -- ===== VISUALS (Left) =====
    local VIS_Group = Tabs.VisMain:AddLeftGroupbox("Visuals", "paintbrush")
    VIS_Group:AddToggle("VisCrosshair", { Text = "Crosshair", Default = false, Callback = function(v) Features.Visuals.Crosshair = v end })
    VIS_Group:AddDropdown("CrosshairColor", { Text = "Crosshair Color", Values = {"Red","Blue","Purple","Yellow","Pink","Orange","Cyan"}, Default = 3, Callback = function(v) Features.Visuals.CrosshairColor = v end })
    VIS_Group:AddToggle("VisSky", { Text = "Sky Override", Default = false, Callback = function(v) Features.Visuals.SkyColor = v end })
    VIS_Group:AddLabel("Sky Color"):AddColorPicker("VisSkyColor", { Default = Color3.fromRGB(80,80,100), Callback = function(c) Features.Visuals.SkyColorVal = c end })
    VIS_Group:AddSlider("VisSkyBright", { Text = "Brightness", Default = 1.5, Min = 0, Max = 3, Rounding = 0.1, Callback = function(v) Features.Visuals.SkyBrightness = v end })
    VIS_Group:AddSlider("VisSkyTime", { Text = "Time of Day", Default = 12, Min = 0, Max = 24, Rounding = 0.5, Callback = function(v) Features.Visuals.SkyClockTime = v end })
    VIS_Group:AddToggle("VisFog", { Text = "Fog", Default = false, Callback = function(v) Features.Visuals.Fog = v end })
    VIS_Group:AddSlider("VisFogDist", { Text = "Fog Distance", Default = 1000, Min = 100, Max = 10000, Rounding = 0, Callback = function(v) Features.Visuals.FogDistance = v end })
    VIS_Group:AddToggle("VisThird", { Text = "Third Person", Default = false, Callback = function(v) Features.Visuals.Thirdperson = v end })
    VIS_Group:AddSlider("VisThirdDist", { Text = "Distance", Default = 12, Min = 5, Max = 30, Rounding = 0.5, Callback = function(v) Features.Visuals.ThirdpersonDistance = v end })
    VIS_Group:AddToggle("VisFOV", { Text = "FOV Override", Default = false, Callback = function(v) Features.Visuals.FOVOverride = v end })
    VIS_Group:AddSlider("VisFOVVal", { Text = "FOV Value", Default = 120, Min = 70, Max = 170, Rounding = 0, Callback = function(v) Features.Visuals.FOVValue = v end })
    VIS_Group:AddToggle("VisLockInd", { Text = "Lock Indicator", Default = false, Callback = function(v) Features.Visuals.LockIndicator = v end })
    VIS_Group:AddToggle("VisSmoke", { Text = "Hide Smoke", Default = false, Callback = function(v) Features.Visuals.HideSmoke = v end })
    VIS_Group:AddToggle("VisFlash", { Text = "Hide Flash", Default = false, Callback = function(v) Features.Visuals.HideFlash = v end })
    VIS_Group:AddToggle("VisBloom", { Text = "Bloom", Default = false, Callback = function(v) Features.Visuals.Bloom = v end })
    VIS_Group:AddSlider("VisBloomInt", { Text = "Bloom Intensity", Default = 20, Min = 1, Max = 100, Rounding = 0, Callback = function(v) Features.Visuals.BloomIntensity = v end })
    VIS_Group:AddToggle("VisTracer", { Text = "Bullet Tracer", Default = false, Callback = function(v) Features.Visuals.BulletTracer = v end })
    VIS_Group:AddDropdown("VisTracerColor", { Text = "Tracer Color", Values = {"Red","Green","Pink","Toothpaste","White"}, Default = 4, Callback = function(v) Features.Visuals.BulletTracerColor = v end })
    VIS_Group:AddSlider("VisTracerLifetime", { Text = "Trail Lifetime", Default = 10, Min = 1, Max = 30, Rounding = 0, Callback = function(v) Features.Visuals.BulletTracerLifetime = v end })
    VIS_Group:AddSlider("VisTracerSpeed", { Text = "Bullet Speed", Default = 600, Min = 100, Max = 2000, Rounding = 0, Callback = function(v) Features.Visuals.BulletTracerSpeed = v end })
    VIS_Group:AddToggle("VisWeaponLatex", { Text = "Weapon Latex", Default = false, Callback = function(v) Features.Visuals.WeaponLatex = v end })
    VIS_Group:AddToggle("VisArmLatex", { Text = "Arm Latex", Default = false, Callback = function(v) Features.Visuals.ArmLatex = v end })

    -- ===== WEATHER (Left) =====
    local WTH_Group = Tabs.WorldWeather:AddLeftGroupbox("Weather", "cloud-rain")
    WTH_Group:AddDropdown("WeatherType", { Text = "Weather", Values = {"None","Rain","Snow"}, Default = 1, Callback = function(v) Features.Visuals.Weather = v end })
    WTH_Group:AddToggle("NightMode", { Text = "Night Mode", Default = false, Callback = function(v) Features.Visuals.NightMode = v end })

    -- ===== SETTINGS (Left) =====
    local SET_Group = Tabs.Settings:AddLeftGroupbox("UI Settings", "settings")
    SET_Group:AddSlider("UIScale", { Text = "UI Scale (Mobile)", Default = 100, Min = 50, Max = 150, Rounding = 0, Suffix = "%", Callback = function(v)
        if ASTRO._UIScale then ASTRO._UIScale.Scale = v / 100 end
    end })
    SET_Group:AddToggle("KeybindMenu", { Text = "Open Keybind Menu", Default = false, Callback = function(v) ASTRO.Library.KeybindFrame.Visible = v end })
    SET_Group:AddButton("Unload UI", function() ASTRO:Destroy() end)

    -- ===== INFO (Left) =====
    local INFO_Group = Tabs.Info:AddLeftGroupbox("About", "info")
    INFO_Group:AddLabel(ASTRO.Name .. " - " .. ASTRO.SubName, true)
    INFO_Group:AddLabel("Version: " .. ASTRO.Version, true)
    INFO_Group:AddLabel("Full feature port from ZytheraX/RUNaways", true)
    INFO_Group:AddLabel("Optimized for Mobile (Arceus X, Hydrogen, etc.)", true)
    INFO_Group:AddLabel("Powered by Obsidian Library", true)

    -- ===== THEME & CONFIG =====
    local ThemeManager = ASTRO.ThemeManager
    local SaveManager = ASTRO.SaveManager
    ThemeManager:ApplyToTab(Tabs.Theme)
    SaveManager:SetLibrary(Library)
    SaveManager:SetFolder(ASTRO.Name)
    SaveManager:SetSubFolder(tostring(game.PlaceId))
    SaveManager:BuildConfigSection(Tabs.Config)
    SaveManager:LoadAutoloadConfig()
end

-- ============================================================
-- ASTRO INIT
-- ============================================================
function ASTRO:Init()
    if self.Loaded then return self end
    print("[ASTRO] Loading Ultimate Mobile Edition...")
    if not LoadDependencies() then return nil end
    SetupTheme()
    CreateMainWindow()
    SetupTabs()

    -- Setup semua fitur
    SetupSilentAim()
    SetupRageBot()
    SetupHoldBot()
    SetupTriggerBot()
    SetupSniperMode()
    SetupAntiAim()
    SetupAntiKatana()
    SetupESP()
    SetupGunMods()
    SetupMovement()
    SetupOrbit()
    SetupStick()
    SetupAutoWalk()
    SetupTeleportKill()
    SetupServer()
    SetupRewards()
    SetupSpoofers()
    SetupNameSpoof()
    SetupAutoWeapon()
    SetupProximity()
    SetupAntiAFK()
    SetupCrosshair()
    SetupVisuals()
    SetupAutoShoot()
    SetupHitboxExpander()

    -- FOV Circles
    self:SetupFovCircles()
    self.Services.RunService.RenderStepped:Connect(function()
        self:UpdateFovCircles()
    end)

    -- UI Scale
    self._UIScale = Instance.new("UIScale", self.Window.Holder)
    self._UIScale.Scale = 1

    BuildUI()
    self.Loaded = true
    self.Library.ToggleKeybind = Enum.KeyCode.LeftAlt
    print("[ASTRO] Ultimate Mobile Edition Loaded! (8500+ lines)")
    self:Notify("ASTRO Ultimate Mobile Ready!", 5)
    return self
end

function ASTRO:Destroy()
    self.Unloaded = true
    self.Loaded = false
    if self.Window then self.Window:Destroy() end
    print("[ASTRO] Unloaded.")
end

return ASTRO:Init()