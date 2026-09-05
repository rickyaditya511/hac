local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/Library.lua"))()
if not Library then return end

local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/addons/SaveManager.lua"))()
if not SaveManager then return end

local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/addons/ThemeManager.lua"))()
if not ThemeManager then return end

SaveManager:SetLibrary(Library)
ThemeManager:SetLibrary(Library)

ThemeManager:SetDefaultTheme({
    FontColor = "ffffff",
    MainColor = "0d0d0d",
    AccentColor = "#6c5ce7",
    BackgroundColor = "0a0a0a",
    OutlineColor = "1a1a1a",
    FontFace = "Code",
})

-- ============================================================
-- [2] SERVICES & GLOBALS
-- ============================================================
local S = {
    Players           = game:GetService("Players"),
    RunService        = game:GetService("RunService"),
    Workspace         = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    UserInputService  = game:GetService("UserInputService"),
    TweenService      = game:GetService("TweenService"),
    HttpService       = game:GetService("HttpService"),
    TeleportService   = game:GetService("TeleportService"),
    Lighting          = game:GetService("Lighting"),
}
local LP = S.Players.LocalPlayer
while not LP do task.wait(0.1) LP = S.Players.LocalPlayer end

local CONFIG_FOLDER = "ASTRO"
local CONFIG_PATH   = CONFIG_FOLDER .. "/StealAnEgg.json"

pcall(function()
    if isfolder and not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
end)

local LoadedCfg = {}
pcall(function()
    if isfile and isfile(CONFIG_PATH) then
        local raw = readfile(CONFIG_PATH)
        if raw and raw ~= "" then LoadedCfg = S.HttpService:JSONDecode(raw) end
    end
end)
if type(LoadedCfg) ~= "table" then LoadedCfg = {} end

local PLACE_ID      = 107778070777162
local SAFEZONE_POS  = Vector3.new(512, 68, -363)
local ZONE_RADIUS   = 200
local SCAN_CHUNK_SIZE    = 50
local PLOT_GRID_COLS     = 8
local PLOT_GRID_ROWS     = 6
local PLOT_GRID_SPACING  = 5

-- ============================================================
-- [3] CONFIGURATION
-- ============================================================
local Cfg = {
    walkSpeed        = math.clamp(tonumber(LoadedCfg.walkSpeed) or 35, 1, 150),
    selectedAreas    = type(LoadedCfg.selectedAreas)=="table"    and LoadedCfg.selectedAreas    or {["All"]=true},
    selectedRarities = type(LoadedCfg.selectedRarities)=="table" and LoadedCfg.selectedRarities or {["All"]=true},
    minWeight        = tonumber(LoadedCfg.minWeight) or 0,
    farmPriority     = LoadedCfg.farmPriority or "Nearest",
    instantSteal     = LoadedCfg.instantSteal ~= false,
    autoFarm         = LoadedCfg.autoFarm == true,
    antiBoss         = LoadedCfg.antiBoss == true,
    autoTreadmill    = LoadedCfg.autoTreadmill == true,
}

local PlotCfg = {
    selectedRarities = type(LoadedCfg.plotRarities)=="table"  and LoadedCfg.plotRarities  or {["All"]=true},
    minWeight        = tonumber(LoadedCfg.plotMinWeight)       or 0,
    autoPlace        = LoadedCfg.plotAutoPlace                 == true,
    autoHatch        = LoadedCfg.plotAutoHatch                 == true,
}

local ShopCfg = {
    sellEggRarities  = type(LoadedCfg.sellEggRarities)=="table"  and LoadedCfg.sellEggRarities  or {},
    sellPetRarities  = type(LoadedCfg.sellPetRarities)=="table"  and LoadedCfg.sellPetRarities  or {},
    autoSellAll      = LoadedCfg.autoSellAll == true,
    autoUpgradePlot  = LoadedCfg.autoUpgradePlot == true,
    autoUpgradeTread = LoadedCfg.autoUpgradeTread == true,
    selectedPetFuse  = tostring(LoadedCfg.selectedPetFuse or "None"),
    autoFuse         = LoadedCfg.autoFuse == true,
}

local MiscCfg = {
    fpsBoost         = LoadedCfg.fpsBoost == true,
    ultraFps         = LoadedCfg.ultraFps == true,
    hopDelay         = tonumber(LoadedCfg.hopDelay) or 30,
    hopMethod        = LoadedCfg.hopMethod or "Small Server",
    autoHop          = LoadedCfg.autoHop == true,
}

local ZONES = {
    ["Forest"]         = Vector3.new(597, 71, -330),
    ["Lake"]           = Vector3.new(743, 71, -409),
    ["Desert"]         = Vector3.new(950, 71, -325),
    ["Jungle"]         = Vector3.new(1189, 71, -408),
    ["Snow"]           = Vector3.new(1492, 71, -317),
    ["Volcano"]        = Vector3.new(1880, 71, -396),
    ["Abyss Ocean"]    = Vector3.new(2281, 71, -330),
    ["Prehistoric"]    = Vector3.new(2813, 71, -395),
    ["Cosmic"]         = Vector3.new(3392, 71, -327),
    ["Cherry Blossom"] = Vector3.new(4028, 71, -396),
    ["Titan Temple"]   = Vector3.new(4798, 71, -328),
}
local ZONE_NAMES    = {"All","Forest","Lake","Desert","Jungle","Snow","Volcano","Abyss Ocean","Prehistoric","Cosmic","Cherry Blossom","Titan Temple"}
local RARITIES      = {"All","Common","Uncommon","Rare","SuperRare","Epic","Legendary","Mythic","Cosmic","Secret","Exotic","Exclusive","Limited","Superior","Eternal","Divine","Titan","BrainrotGod"}
local SELL_RARITIES = {"Common","Uncommon","Rare","SuperRare","Epic","Legendary","Mythic","Cosmic","Secret","Exotic","Exclusive","Limited","Superior","Eternal","Divine","Titan","BrainrotGod"}

local RARITY_ORDER = {
    Common=1, Basic=1, Uncommon=2, Celestial=2, SuperRare=3,
    Rare=4, Epic=5, Legendary=6,
    Mythic=7, Mythical=7, Rainbow=7, Prismatic=7,
    Cosmic=8, Exclusive=8, Admin=8, Limited=8,
    Secret=9, Exotic=9, Eternal=9,
    Superior=10, Transcendent=10, Divine=10,
    Titan=11, BrainrotGod=12,
}

-- ============================================================
-- [4] SAVE / LOAD
-- ============================================================
local function saveConfig()
    pcall(function()
        if isfolder and makefolder and not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
        writefile(CONFIG_PATH, S.HttpService:JSONEncode({
            walkSpeed        = Cfg.walkSpeed,
            selectedAreas    = Cfg.selectedAreas,
            selectedRarities = Cfg.selectedRarities,
            minWeight        = Cfg.minWeight,
            farmPriority     = Cfg.farmPriority,
            instantSteal     = Cfg.instantSteal,
            autoFarm         = Cfg.autoFarm,
            antiBoss         = Cfg.antiBoss,
            autoTreadmill    = Cfg.autoTreadmill,
            plotRarities     = PlotCfg.selectedRarities,
            plotMinWeight    = PlotCfg.minWeight,
            plotAutoPlace    = PlotCfg.autoPlace,
            plotAutoHatch    = PlotCfg.autoHatch,
            sellEggRarities  = ShopCfg.sellEggRarities,
            sellPetRarities  = ShopCfg.sellPetRarities,
            autoSellAll      = ShopCfg.autoSellAll,
            autoUpgradePlot  = ShopCfg.autoUpgradePlot,
            autoUpgradeTread = ShopCfg.autoUpgradeTread,
            selectedPetFuse  = ShopCfg.selectedPetFuse,
            autoFuse         = ShopCfg.autoFuse,
            fpsBoost         = MiscCfg.fpsBoost,
            ultraFps         = MiscCfg.ultraFps,
            hopDelay         = MiscCfg.hopDelay,
            hopMethod        = MiscCfg.hopMethod,
            autoHop          = MiscCfg.autoHop,
        }))
    end)
end

-- ============================================================
-- [5] AFK PREVENTION
-- ============================================================
do
    local function silenceIdle()
        local ok, list = pcall(function() return getconnections(LP.Idled) end)
        if ok and type(list)=="table" then
            for _, c in ipairs(list) do pcall(function() c:Disable() end) end
        end
    end
    silenceIdle()
    LP.Idled:Connect(function()
        silenceIdle()
        pcall(function()
            local cam = workspace.CurrentCamera
            if cam then
                local cf = cam.CFrame
                cam.CFrame = cf * CFrame.Angles(0, 0.001, 0)
                task.wait(0.1)
                cam.CFrame = cf
            end
        end)
    end)
end

-- ============================================================
-- [6] REMOTES
-- ============================================================
local NET     = S.ReplicatedStorage:FindFirstChild("Network")
local PKG_NET = S.ReplicatedStorage:FindFirstChild("Packages") and S.ReplicatedStorage.Packages:FindFirstChild("Networking")

local function getRemote(name)
    if PKG_NET and PKG_NET:FindFirstChild(name) then return PKG_NET:FindFirstChild(name) end
    if NET and NET:FindFirstChild(name) then return NET:FindFirstChild(name) end
    return nil
end

local function _pnet(name)
    local PKG = S.ReplicatedStorage:FindFirstChild("Packages")
    local NET2 = PKG and PKG:FindFirstChild("Networking")
    if NET2 then
        local r = NET2:FindFirstChild(name)
        if r then return r end
    end
    return getRemote(name)
end

local RMT = {
    CarryEgg          = _pnet("RF/EggWorld/AskFieldEggCarry") or getRemote("Eggs: RequestAreaEggCarry"),
    DropEgg           = _pnet("RF/EggWorld/AskFieldEggDrop")  or getRemote("Eggs: RequestAreaEggDrop"),
    RuntimeSnapshot   = _pnet("RF/EggWorld/AskLiveSnapshot"),
    PlaceEgg          = _pnet("RF/EggWorld/AskPlaceEgg"),
    Hatch             = _pnet("RF/EggWorld/AskHatch"),
    FinishHatch       = _pnet("RF/EggWorld/AskFinishHatch"),
    FuseryLoadPet     = _pnet("RF/Fusery/LoadPet"),
    FuseryBeginFuse   = _pnet("RF/Fusery/BeginFuse"),
    FuseryFinishReveal= _pnet("RF/Fusery/FinishReveal"),
    BaseUpgrade       = _pnet("RE/Homestead/AskBaseTierRaise"),
    TreadmillUpgrade  = _pnet("RF/Treadmill/AskTierRaise"),
    SellPet      = nil,
    SellEveryPet = nil,
    IntReady     = getRemote("ClientCharacter: Ready"),
    IntHeartbeat = getRemote("ClientCharacter: IntegrityHeartbeat"),
    IntSync      = getRemote("ClientCharacter: Sync"),
    IntViolation = getRemote("ClientCharacter: IntegrityViolation"),
}

pcall(function()
    local Remotes = require(S.ReplicatedStorage.Shared.Remotes)
    if Remotes.PetSatchel then
        RMT.SellPet      = Remotes.PetSatchel.SellPet
        RMT.SellEveryPet = Remotes.PetSatchel.SellEveryPet
    end
end)
if not RMT.SellPet      then RMT.SellPet      = _pnet("RE/PetSatchel/SellPet")      end
if not RMT.SellEveryPet then RMT.SellEveryPet = _pnet("RE/PetSatchel/SellEveryPet") end

-- ============================================================
-- [7] INTEGRITY BYPASS
-- ============================================================
local function setupIntegrity()
    local function fireReady()
        pcall(function() if RMT.IntReady then RMT.IntReady:FireServer() end end)
    end
    fireReady()
    if RMT.IntHeartbeat then
        RMT.IntHeartbeat.OnClientEvent:Connect(function(...)
            local a = table.pack(...)
            task.delay(math.random()*0.05, function()
                pcall(function()
                    if RMT.IntSync then RMT.IntSync:InvokeServer(table.unpack(a,1,a.n)) end
                end)
            end)
        end)
    end
    if RMT.IntViolation then RMT.IntViolation.OnClientEvent:Connect(function() end) end
    LP.CharacterAdded:Connect(function() task.wait(0.5); fireReady() end)
end
setupIntegrity()

-- ============================================================
-- [8] CHARACTER UTILITIES
-- ============================================================
local Runtime = {
    rootPart      = nil,
    humanoid      = nil,
    farming       = false,
    isAutoWalking = false,
    steals             = 0,
    statusText         = "Idle",
    StatusLbl          = nil,
    carryEscapeActive  = false,
    pendingCallbacks   = {},
}

local bypassDone = false

local function UpdateStatus(txt)
    Runtime.statusText = txt
    if Runtime.StatusLbl then
        Runtime.StatusLbl.Text = string.format("Status: %s  |  Steals: %d", Runtime.statusText, Runtime.steals)
    end
end

local function getChar() return LP.Character end

local function getRoot()
    if Runtime.rootPart and Runtime.rootPart.Parent then return Runtime.rootPart end
    local char = getChar()
    if char then Runtime.rootPart = char:FindFirstChild("HumanoidRootPart") end
    return Runtime.rootPart
end

local function getHumanoid()
    local char = getChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function applyBacBypass(char)
    if not char then return end
    if bypassDone then return end
    local h = char:FindFirstChildOfClass("Humanoid")
    if not h then return end
    local cam  = workspace.CurrentCamera
    local anim = char:FindFirstChild("Animate")
    local ws, jp, jh, hp, mhp = h.WalkSpeed, h.JumpPower, h.JumpHeight, h.Health, h.MaxHealth

    if anim and anim:IsA("LocalScript") then anim.Disabled = true end
    local animator = h:FindFirstChildOfClass("Animator")
    if animator then
        for _, t in ipairs(animator:GetPlayingAnimationTracks()) do t:Stop(0) end
    end

    h.Archivable = true
    local clone = h:Clone()
    for _, c in ipairs(clone:GetChildren()) do if c:IsA("Animator") then c:Destroy() end end

    h.Name = "_OldHumanoid"; clone.Name = "Humanoid"; clone.Parent = char
    Instance.new("Animator").Parent = clone
    clone.WalkSpeed = ws; clone.JumpPower = jp; clone.JumpHeight = jh
    clone.MaxHealth = mhp; clone.Health = math.min(hp, mhp)

    if cam then cam.CameraSubject = clone end
    h:Destroy()

    if anim and anim:IsA("LocalScript") then
        task.wait()
        anim.Disabled = false
        task.defer(function()
            if anim.Parent then anim.Disabled = true; task.wait(); anim.Disabled = false end
        end)
    end
    task.defer(function() if clone.Parent then clone:ChangeState(Enum.HumanoidStateType.Running) end end)
    bypassDone = true
    return clone
end

local function ensureCharacter(timeout)
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if char and root and hum and root.Parent and hum.Health > 0 then
        Runtime.rootPart = root
        return char, root, hum
    end

    timeout = timeout or 8
    local start = tick()
    while (not char or not root or not hum or not root.Parent or hum.Health <= 0) and (tick() - start < timeout) do
        task.wait(0.1)
        char = LP.Character
        root = char and char:FindFirstChild("HumanoidRootPart")
        hum  = char and char:FindFirstChildOfClass("Humanoid")
    end
    if root then Runtime.rootPart = root end
    return char, root, hum
end

local doFarmLoop -- forward declaration

local function bindChar(char)
    if not char then Runtime.rootPart = nil; return end
    Runtime.rootPart = char:WaitForChild("HumanoidRootPart", 5)
    task.spawn(function() pcall(applyBacBypass, char) end)
end

if LP.Character then bindChar(LP.Character) end
LP.CharacterAdded:Connect(function(char)
    Runtime.rootPart = nil
    bypassDone = false
    task.spawn(function()
        local c, r, h = ensureCharacter(10)
        bindChar(c)
        task.wait(0.5)
        if Cfg.autoFarm and not Runtime.farming then
            task.spawn(doFarmLoop)
        end
    end)
end)

local function isCarryingEgg(otherChar)
    local char = otherChar or getChar()
    if not char then return false end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") and obj.Name:lower():find("egg") then return true end
    end
    for _, obj in ipairs(char:GetDescendants()) do
        if (obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Model")) and obj.Parent == char then
            local n = obj.Name:lower()
            if n:find("egg") and not n:find("zone") and not n:find("root") and not n:find("prompt") then
                return true
            end
        end
    end
    if char:GetAttribute("CarryingEgg") or char:GetAttribute("IsCarrying") or char:GetAttribute("HoldingEgg") then
        return true
    end
    return false
end

-- ============================================================
-- [9] INFINITE YIELD TPWALK ENGINE (TranslateBy)
-- ============================================================
local TPWalkConn = nil
local function setupTPWalkEngine()
    if TPWalkConn then
        TPWalkConn:Disconnect()
        TPWalkConn = nil
    end

    TPWalkConn = S.RunService.Heartbeat:Connect(function(delta)
        local char = LP.Character
        local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")
        if char and humanoid and humanoid.Parent and not Runtime.isAutoWalking then
            if humanoid.MoveDirection.Magnitude > 0 then
                char:TranslateBy(humanoid.MoveDirection * Cfg.walkSpeed * delta * 10)
            end
        end
    end)
end
setupTPWalkEngine()

local function forceUnequipTools()
    local char = LP.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    local ok = pcall(function() hum:UnequipTools() end)
    return ok
end

local function tpWalk(targetPos, stopDist, keepUnequipped, shouldContinue)
    stopDist = stopDist or 4
    Runtime.isAutoWalking = true

    local timeout = tick() + 25
    local lastUnequip = 0
    if keepUnequipped then
        forceUnequipTools()
        lastUnequip = tick()
    end

    while tick() < timeout and (Cfg.autoFarm or PlotCfg.autoPlace) do
        if shouldContinue then
            local okCheck, keepGoing = pcall(shouldContinue)
            if not okCheck or not keepGoing then
                Runtime.isAutoWalking = false
                local cancelRoot = getRoot()
                if cancelRoot then
                    pcall(function()
                        cancelRoot.AssemblyLinearVelocity = Vector3.zero
                        cancelRoot.AssemblyAngularVelocity = Vector3.zero
                    end)
                end
                return false
            end
        end

        local char = getChar()
        local root = getRoot()
        local hum  = getHumanoid()
        if not char or not root or not hum or hum.Health <= 0 then
            task.wait(0.05)
            char, root, hum = ensureCharacter(5)
            if not char or not root or not hum then
                Runtime.isAutoWalking = false
                return false
            end
        end

        if keepUnequipped and (tick() - lastUnequip >= 0.10) then
            forceUnequipTools()
            lastUnequip = tick()
        end

        if isPlayerOnTreadmill and isPlayerOnTreadmill() then
            releaseTreadmill()
        end

        local currentPos = root.Position
        local dist = (currentPos - targetPos).Magnitude

        if dist <= stopDist then
            root.AssemblyLinearVelocity = Vector3.zero
            if keepUnequipped then forceUnequipTools() end
            Runtime.isAutoWalking = false
            return true
        end

        local dt = S.RunService.Heartbeat:Wait()
        local dir = (targetPos - currentPos).Unit
        local step = Cfg.walkSpeed * dt * 10
        local moveAmt = math.min(step, dist)
        char:TranslateBy(dir * moveAmt)
    end

    Runtime.isAutoWalking = false
    if keepUnequipped then forceUnequipTools() end
    local root = getRoot()
    return (root and (root.Position - targetPos).Magnitude <= stopDist + 2) or false
end

-- ============================================================
-- [10] TREADMILL & ANTI-BOSS
-- ============================================================
local function isPlayerOnTreadmill()
    local root = getRoot()
    if not root then return false end
    local plots = S.Workspace:FindFirstChild("Plots")
    if plots then
        for _, p in ipairs(plots:GetChildren()) do
            local tb = p:FindFirstChild("TreadmillBottom")
            if tb and (root.Position - tb.Position).Magnitude <= 12 then
                return true, tb
            end
        end
    end
    return false
end

local function releaseTreadmill()
    pcall(function()
        local rf = S.ReplicatedStorage.Packages.Networking:FindFirstChild("RF/Treadmill/AskDoff")
        if rf then rf:InvokeServer() end
    end)
    pcall(function()
        local tc = require(LP.PlayerScripts.Game.Plots.TreadmillCharacterPresentationController)
        if tc and tc.Stop then tc.Stop() end
    end)
    local root = getRoot()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.Jump = true end) end
    if root then root.AssemblyLinearVelocity = Vector3.new(0, 20, 0) end
end

local AntiBossState = {
    enabled      = false,
    teleporting  = false,
    connection   = nil,
    targetPos    = SAFEZONE_POS,
    spamDelay    = 0.01,
    cycleId      = 0,
}

local function stopAntiBossSpamTeleport()
    AntiBossState.teleporting = false
    if AntiBossState.connection then
        pcall(function() AntiBossState.connection:Disconnect() end)
        AntiBossState.connection = nil
    end
end

local function startAntiBossSpamTeleport()
    stopAntiBossSpamTeleport()
    AntiBossState.enabled = true
    AntiBossState.teleporting = true
    AntiBossState.targetPos = SAFEZONE_POS
    AntiBossState.cycleId = AntiBossState.cycleId + 1
    local myCycle = AntiBossState.cycleId

    AntiBossState.connection = S.RunService.Heartbeat:Connect(function()
        if not AntiBossState.teleporting or not Cfg.antiBoss or not Cfg.autoFarm or myCycle ~= AntiBossState.cycleId then
            return
        end
        local root = getRoot()
        if not root then return end
        local jitter = Vector3.new(
            math.random(-20, 20) / 10,
            math.random(-20, 20) / 10,
            math.random(-20, 20) / 10
        )
        pcall(function()
            root.CFrame = CFrame.new(AntiBossState.targetPos + jitter)
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end)
    end)
end

local function triggerAntiBossSpamTeleport()
    if not Cfg.antiBoss or not Cfg.autoFarm then return false end
    if AntiBossState.teleporting then return true end
    startAntiBossSpamTeleport()
    local thisCycle = AntiBossState.cycleId
    task.delay(0.65, function()
        if thisCycle ~= AntiBossState.cycleId then return end
        stopAntiBossSpamTeleport()
    end)
    return true
end

local function waitForAntiBossTeleport()
    local started = tick()
    while AntiBossState.teleporting and Cfg.autoFarm and tick() - started < 2 do
        task.wait(0.05)
    end
    task.wait(0.30)
end

local function instantCarryEscape()
    if not Cfg.autoFarm then return false end
    if Runtime.carryEscapeActive then return true end
    Runtime.carryEscapeActive = true
    Runtime.steals = Runtime.steals + 1
    ScanCache.lastScan = 0
    ScanCache.eggs = {}

    if Cfg.antiBoss then
        UpdateStatus(string.format("ANTI BOSS → SPAM SAFEZONE! [%d]", Runtime.steals))
        triggerAntiBossSpamTeleport()
        waitForAntiBossTeleport()
        if Cfg.autoFarm then
            UpdateStatus(string.format("ANTI BOSS → TPWALK SAFEZONE [%d]", Runtime.steals))
            tpWalk(SAFEZONE_POS, 5)
        end
    else
        UpdateStatus(string.format("CARRY CONFIRMED → SAFEZONE! [%d]", Runtime.steals))
        tpWalk(SAFEZONE_POS, 5)
    end

    stopAntiBossSpamTeleport()
    forceUnequipTools()
    task.wait(0.05)
    forceUnequipTools()
    Runtime.carryEscapeActive = false
    return true
end

-- ============================================================
-- [11] EGG DETECTION ENGINE
-- ============================================================
local AssetRarityCache = {}
local AssetNumberCache = {}
local AssetRarityBuilt = false

local function buildAssetRarityCache()
    if AssetRarityBuilt and next(AssetRarityCache) then return end
    pcall(function()
        local rs = S.ReplicatedStorage
        local assetsMod = (rs:FindFirstChild("Data") and rs.Data:FindFirstChild("Assets"))
            or (rs:FindFirstChild("Directory") and rs.Directory:FindFirstChild("Assets"))
            or (rs:FindFirstChild("Shared") and rs.Shared:FindFirstChild("Assets"))
        if assetsMod then
            local assets = require(assetsMod)
            local dir = assets and (assets.Directory or assets)
            if type(dir) == "table" then
                for petName, data in pairs(dir) do
                    if type(data) == "table" then
                        local rarity = data.Rarity
                        local rid = nil
                        local rnum = 1
                        if type(rarity) == "table" then
                            rid = rarity._id or rarity.id or rarity.Name or rarity.DisplayName or rarity.Title
                            rnum = rarity.RarityNumber or rnum
                        elseif type(rarity) == "string" then
                            rid = rarity
                        end
                        if not rid and data.RarityName then rid = tostring(data.RarityName) end
                        if rid then
                            local rStr = tostring(rid)
                            local pLower = tostring(petName):lower()
                            AssetRarityCache[pLower] = rStr
                            AssetRarityCache[pLower:gsub("%s+", "")] = rStr
                            AssetRarityCache[pLower:gsub("_", "")] = rStr
                            AssetNumberCache[pLower] = tonumber(rnum) or 1
                        end
                    end
                end
                AssetRarityBuilt = true
            end
        end
    end)
end

local function getRarityFromModel(model)
    if not model then return "Common" end
    local name = model.Name or ""
    if AssetRarityCache[name:lower()] then return AssetRarityCache[name:lower()] end
    for r, _ in pairs(RARITY_ORDER) do
        if name:lower():find(r:lower(), 1, true) then return r end
    end
    return "Common"
end

local function isAreaAllowedExact(areaName, eggPos)
    if Cfg.selectedAreas["All"] == true then return true end
    if not next(Cfg.selectedAreas) then return true end
    local aLower = tostring(areaName or ""):lower():gsub("%s+", "")
    for selArea, active in pairs(Cfg.selectedAreas) do
        if active and selArea ~= "All" then
            local sLower = selArea:lower():gsub("%s+", "")
            if aLower == sLower or aLower:find(sLower, 1, true) or sLower:find(aLower, 1, true) then
                return true
            end
            local zonePos = ZONES[selArea]
            if zonePos and eggPos and (eggPos - zonePos).Magnitude <= 350 then
                return true
            end
        end
    end
    return false
end

local function isRarityAllowedExact(rarityName)
    if Cfg.selectedRarities["All"] == true then return true end
    if not next(Cfg.selectedRarities) then return true end
    local rLower = tostring(rarityName or ""):lower():gsub("%s+", "")
    for selRarity, active in pairs(Cfg.selectedRarities) do
        if active and selRarity ~= "All" then
            local sLower = selRarity:lower():gsub("%s+", "")
            if rLower == sLower or rLower:find(sLower, 1, true) or sLower:find(rLower, 1, true) then
                return true
            end
        end
    end
    return false
end

local function isBlacklistedModel(model)
    if not model or not model:IsA("Model") then return true end
    local n = model.Name:lower()
    if n:find("chest") or n:find("box") or n:find("crate") or n:find("treasure")
        or n:find("stand") or n:find("portal") or n:find("door") or n:find("gate")
        or n:find("leaderboard") or n:find("dummy") or n:find("pedestal")
        or n:find("wheel") or n:find("spin") or n:find("reward") or n:find("statue")
        or n:find("tree") or n:find("rock") or n:find("terrain") or n:find("mesh")
        or n:find("machine") or n:find("treadmill") or n:find("fuse") or n:find("sign")
        or n:find("monster") or n:find("parasite")
    then
        return true
    end
    if model:FindFirstChildOfClass("Humanoid") or model:FindFirstChildOfClass("AnimationController") then
        return true
    end
    return false
end

local function isDroppedEggModel(model)
    if not model or not model:IsA("Model") then return false end
    if isBlacklistedModel(model) then return false end
    for _, plr in ipairs(S.Players:GetPlayers()) do
        if plr.Character == model then return false end
    end
    local hasBox = (model:FindFirstChild("Hitbox") ~= nil)
        or (model:FindFirstChild("CustomBoundingBox") ~= nil)
        or (model:GetAttribute("AssetCategory") ~= nil)
        or (model:GetAttribute("FirstAreaSlotKey") ~= nil)
        or (model:GetAttribute("SlotKey") ~= nil)
        or (model:GetAttribute("Uid") ~= nil)
    if not hasBox and not model.PrimaryPart and not model:FindFirstChildWhichIsA("BasePart") then return false end
    local hasEggPrompt = false
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            local at = (desc.ActionText or ""):lower()
            local ot = (desc.ObjectText or ""):lower()
            if at:find("open") or at:find("unlock") or at:find("talk") or at:find("buy") then
                return false
            end
            if at:find("steal") or at:find("take") or at:find("carry") or at:find("pick") or at:find("grab")
                or ot:find("egg")
            then
                hasEggPrompt = true
                break
            end
        end
    end
    local hasEggAttr = false
    local ok, attrs = pcall(function() return model:GetAttributes() end)
    if ok and attrs then
        if attrs.FirstAreaSlotKey or attrs.SlotKey or attrs.Uid or attrs.AssetCategory or attrs.EggType or attrs.Weight then
            hasEggAttr = true
        end
    end
    local isGuid = model.Name:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
        or (#model.Name == 32 and model.Name:match("^%x+$") ~= nil)
    return hasEggPrompt or hasEggAttr or isGuid
end

local function getZoneFromPos(pos)
    local closest, closestDist = nil, math.huge
    for zoneName, zonePos in pairs(ZONES) do
        local d = (pos - zonePos).Magnitude
        if d < closestDist then
            closestDist = d
            closest = zoneName
        end
    end
    if closestDist <= 350 then return closest end
    return nil
end

local function getAccurateWeight(eggModel)
    if not eggModel then return 1 end
    local bbox = eggModel:FindFirstChild("CustomBoundingBox")
    if bbox and bbox:IsA("BasePart") then
        local s = bbox.Size
        return s.X * s.Y * s.Z, bbox
    end
    local hitbox = eggModel:FindFirstChild("Hitbox")
    if hitbox and hitbox:IsA("BasePart") then
        local s = hitbox.Size
        return s.X * s.Y * s.Z, hitbox
    end
    if eggModel.PrimaryPart then
        local s = eggModel.PrimaryPart.Size
        return s.X * s.Y * s.Z, eggModel.PrimaryPart
    end
    for _, d in ipairs(eggModel:GetChildren()) do
        if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
            local s = d.Size
            return s.X * s.Y * s.Z, d
        end
    end
    return 1, eggModel:FindFirstChildWhichIsA("BasePart")
end

local function getEggPrompt(hitboxPos)
    local closest, closestDist = nil, math.huge
    for _, obj in ipairs(S.Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local part = obj.Parent
            if part and part:IsA("BasePart") then
                local inPlot = false
                local ancestor = part.Parent
                while ancestor do
                    if ancestor.Name == "Plots" then inPlot = true; break end
                    ancestor = ancestor.Parent
                end
                if not inPlot then
                    local d = (part.Position - hitboxPos).Magnitude
                    if d < 45 and d < closestDist then
                        closest = obj
                        closestDist = d
                    end
                end
            end
        end
    end
    return closest
end

local ScanCache = { eggs = {}, lastScan = 0, scanning = false }
local SCAN_INTERVAL = 0.8

local function scanEggsAsync(callback)
    if ScanCache.scanning then return end
    local now = tick()
    if now - ScanCache.lastScan < SCAN_INTERVAL and #ScanCache.eggs > 0 then
        callback(ScanCache.eggs)
        return
    end
    ScanCache.scanning = true
    task.spawn(function()
        buildAssetRarityCache()
        local rootPos = getRoot() and getRoot().Position or Vector3.zero
        local results = {}

        local rs = S.ReplicatedStorage
        local Assets = nil
        pcall(function() Assets = require(rs.Data.Assets) end)
        local assetsDir = Assets and (Assets.Directory or Assets)

        local records = nil
        pcall(function()
            local EggState = require(rs.Client.EggState)
            local snap = EggState.ReadFieldEggs()
            records = snap and snap.Records
        end)
        if not records or #records == 0 then
            pcall(function()
                local rf = rs:FindFirstChild("Packages")
                    and rs.Packages:FindFirstChild("Networking")
                    and rs.Packages.Networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
                if rf then
                    local snap = rf:InvokeServer()
                    records = snap and snap.Records
                end
            end)
        end

        if records and #records > 0 then
            for _, rec in ipairs(records) do
                if not Cfg.autoFarm then break end
                if type(rec) == "table" and (rec.State == "Slot" or rec.State == "Dropped" or rec.State == "Carry" or rec.State == nil) and rec.Uid then
                    local cat = tostring(rec.AssetCategory or "")
                    local area = tostring(rec.AreaId or "")
                    local assetData = assetsDir and assetsDir[cat]
                    local rarity = (assetData and assetData.Rarity and assetData.Rarity._id)
                        or AssetRarityCache[cat:lower()]
                        or "Common"
                    local rarityNum = (assetData and assetData.Rarity and assetData.Rarity.RarityNumber)
                        or AssetNumberCache[cat:lower()]
                        or RARITY_ORDER[rarity] or 1
                    local mutations = rec.Mutations or {}
                    local mutationScore = #mutations * 10
                    if rec.BaseMutation and rec.BaseMutation ~= "" and rec.BaseMutation ~= "None" then
                        mutationScore = mutationScore + 25
                    end
                    local model = S.Workspace.AreaEggSlotsClient:FindFirstChild(rec.Uid)
                        or S.Workspace:FindFirstChild(rec.Uid)
                        or S.Workspace:FindFirstChild(rec.Uid, true)
                    local pos = rec.BottomCFrame and rec.BottomCFrame.Position
                    if model then
                        local part = model:FindFirstChild("Hitbox")
                            or model:FindFirstChild("CustomBoundingBox")
                            or model.PrimaryPart
                            or model:FindFirstChildWhichIsA("BasePart")
                        if part then pos = part.Position end
                    end
                    pos = pos or Vector3.zero
                    if not isAreaAllowedExact(area, pos) then continue end
                    if not isRarityAllowedExact(rarity) then continue end
                    local weight = 1
                    if model then weight = getAccurateWeight(model) end
                    if Cfg.minWeight > 0 and weight < Cfg.minWeight then continue end
                    local dist = (pos - rootPos).Magnitude
                    table.insert(results, {
                        uid          = rec.Uid,
                        model        = model,
                        pos          = pos,
                        zone         = area,
                        rarity       = rarity,
                        rarityNum    = rarityNum,
                        category     = cat,
                        weight       = weight,
                        mutations    = mutations,
                        baseMutation = rec.BaseMutation,
                        slotKey      = tostring(rec.NestId or rec.Uid),
                        score        = rarityNum * 100 + mutationScore,
                        dist         = dist,
                    })
                end
            end
        end

        local foundUids = {}
        for _, r in ipairs(results) do foundUids[r.uid] = true end

        local function tryAddDroppedEgg(child)
            if not isDroppedEggModel(child) then return end
            if foundUids[child.Name] then return end
            foundUids[child.Name] = true
            local part = child:FindFirstChild("Hitbox")
                or child:FindFirstChild("CustomBoundingBox")
                or child.PrimaryPart
                or child:FindFirstChildWhichIsA("BasePart")
            if not part then return end
            local pos = part.Position
            local zone = getZoneFromPos(pos) or "Unknown"
            local cat = tostring(child:GetAttribute("AssetCategory") or "")
            if cat == "" then
                for name, _ in pairs(assetsDir or {}) do
                    if child.Name:lower():find(name:lower(), 1, true) then cat = name; break end
                end
            end
            if cat == "" then cat = child.Name end
            local rarity = AssetRarityCache[cat:lower()] or "Common"
            local rarityNum = AssetNumberCache[cat:lower()] or RARITY_ORDER[rarity] or 1
            if isAreaAllowedExact(zone, pos) and isRarityAllowedExact(rarity) then
                table.insert(results, {
                    uid       = child.Name,
                    model     = child,
                    pos       = pos,
                    zone      = zone,
                    rarity    = rarity,
                    rarityNum = rarityNum,
                    category  = cat,
                    weight    = getAccurateWeight(child),
                    mutations = {},
                    slotKey   = tostring(child:GetAttribute("FirstAreaSlotKey") or child.Name),
                    score     = rarityNum * 100,
                    dist      = (pos - rootPos).Magnitude,
                    isDropped = true,
                })
            end
        end

        for _, child in ipairs(S.Workspace:GetChildren()) do tryAddDroppedEgg(child) end
        local objs = S.Workspace:FindFirstChild("__OBJECTS")
        if objs then
            for _, desc in ipairs(objs:GetDescendants()) do
                if desc:IsA("Model") then tryAddDroppedEgg(desc) end
            end
        end
        local aesc = S.Workspace:FindFirstChild("AreaEggSlotsClient")
        if aesc then
            for _, child in ipairs(aesc:GetChildren()) do
                if child:IsA("Model") and not foundUids[child.Name] then tryAddDroppedEgg(child) end
            end
        end

        if Cfg.farmPriority == "Hugest" then
            table.sort(results, function(a, b) return a.weight > b.weight end)
        elseif Cfg.farmPriority == "Rarest" then
            table.sort(results, function(a, b)
                if a.score ~= b.score then return a.score > b.score end
                return a.dist < b.dist
            end)
        else
            table.sort(results, function(a, b) return a.dist < b.dist end)
        end

        ScanCache.eggs = results
        ScanCache.lastScan = tick()
        ScanCache.scanning = false
        callback(results)
    end)
end

-- ============================================================
-- [12] INSTANT PROMPT LOGIC
-- ============================================================
local function setPromptInstant(prompt)
    if Cfg.instantSteal then pcall(function() prompt.HoldDuration = 0 end) end
end

local function applyInstantToAll()
    if not Cfg.instantSteal then return end
    for _, obj in ipairs(S.Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then setPromptInstant(obj) end
    end
end

S.Workspace.DescendantAdded:Connect(function(d)
    if d:IsA("ProximityPrompt") then setPromptInstant(d) end
end)

-- ============================================================
-- [13] PLOT ENGINE
-- ============================================================
local PlotRuntime = {
    placing     = false,
    hatching    = false,
    placedCount = 0,
    statusText  = "Idle",
    StatusLbl2  = nil,
    penInfo     = nil,
    placeGeneration = 0,
    placeOwner      = nil,
}

local function UpdatePlotStatus(txt)
    PlotRuntime.statusText = txt
    if PlotRuntime.StatusLbl2 then
        PlotRuntime.StatusLbl2.Text = string.format("Plot: %s  |  Placed: %d", txt, PlotRuntime.placedCount)
    end
end

local function parseCFrameString(str)
    if typeof(str) == "CFrame" then return str end
    if type(str) ~= "string" then return nil end
    local nums = {}
    for n in str:gmatch("[%-]?%d+%.?%d*[eE]?[+-]?%d*") do nums[#nums+1] = tonumber(n) end
    if #nums >= 12 then
        return CFrame.new(nums[1],nums[2],nums[3],nums[4],nums[5],nums[6],nums[7],nums[8],nums[9],nums[10],nums[11],nums[12])
    elseif #nums >= 3 then
        return CFrame.new(nums[1], nums[2], nums[3])
    end
    return nil
end

local function findMyPlot()
    if PlotRuntime.penInfo and PlotRuntime.penInfo.plot and PlotRuntime.penInfo.plot.Parent then
        return PlotRuntime.penInfo
    end
    local plots = S.Workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local myName = LP.Name:lower()
    local myDisp = LP.DisplayName:lower()
    for _, plot in ipairs(plots:GetChildren()) do
        local isOwner = false
        local sign = plot:FindFirstChild("PlotSign")
        if sign then
            for _, desc in ipairs(sign:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Text ~= "" then
                    local t = desc.Text:lower()
                    if t:find(myName, 1, true) or t:find(myDisp, 1, true) then
                        isOwner = true
                        break
                    end
                end
            end
        end
        local attr = plot:GetAttribute("Owner") or plot:GetAttribute("PlayerName")
        if attr and tostring(attr):lower() == myName then isOwner = true end
        if isOwner then
            local toUpdate = plot:FindFirstChild("ToUpdate")
            if toUpdate then
                local petArea     = toUpdate:FindFirstChild("PetArea")
                local centerPoint = toUpdate:FindFirstChild("CenterPoint")
                if petArea and centerPoint then
                    local info = {
                        plot        = plot,
                        petArea     = petArea,
                        centerPoint = centerPoint,
                        petAreaPos  = petArea.Position,
                        petAreaSize = petArea.Size,
                    }
                    PlotRuntime.penInfo = info
                    return info
                end
            end
        end
    end
    return nil
end

local function getUnplacedEggs()
    buildAssetRarityCache()
    local results = {}
    local okEggs, ownerEggs = pcall(function()
        local es = require(S.ReplicatedStorage.Client.EggState)
        return es.ReadOwnerEggs(LP.UserId)
    end)
    if okEggs and type(ownerEggs) == "table" and next(ownerEggs) then
        for recordId, record in pairs(ownerEggs) do
            if not record.Placement then
                local cat = tostring(record.AssetCategory or "Egg")
                local rarity = AssetRarityCache[cat:lower()] or getRarityFromModel({Name = cat})
                local weight = tonumber(record.AssetScale or record.Weight) or 0
                if PlotCfg.minWeight > 0 and weight < PlotCfg.minWeight then continue end
                if not PlotCfg.selectedRarities["All"] and next(PlotCfg.selectedRarities) then
                    local allowed = false
                    local rLower = tostring(rarity):lower()
                    local cLower = tostring(cat):lower()
                    for selRarity, active in pairs(PlotCfg.selectedRarities) do
                        if active and selRarity ~= "All" then
                            local sLower = selRarity:lower()
                            if rLower:find(sLower, 1, true) or sLower:find(rLower, 1, true) or cLower:find(sLower, 1, true) then
                                allowed = true
                                break
                            end
                        end
                    end
                    if not allowed then continue end
                end
                table.insert(results, {
                    id       = recordId,
                    uid      = recordId,
                    category = cat,
                    rarity   = rarity or "Common",
                    weight   = weight,
                    record   = record,
                })
            end
        end
        return results
    end
    local snap = nil
    if RMT.RuntimeSnapshot then
        local ok, s = pcall(function() return RMT.RuntimeSnapshot:InvokeServer() end)
        if ok and type(s) == "table" then snap = s end
    end
    if not snap then return {} end
    for _, entry in ipairs(snap) do
        if entry.OwnerUserId == LP.UserId and type(entry.Records) == "table" then
            for recordId, record in pairs(entry.Records) do
                if not record.Placement then
                    local cat = tostring(record.AssetCategory or "Egg")
                    local rarity = AssetRarityCache[cat:lower()] or getRarityFromModel({Name = cat})
                    local weight = tonumber(record.AssetScale or record.Weight) or 0
                    if PlotCfg.minWeight > 0 and weight < PlotCfg.minWeight then continue end
                    if not PlotCfg.selectedRarities["All"] and next(PlotCfg.selectedRarities) then
                        local allowed = false
                        local rLower = tostring(rarity):lower()
                        local cLower = tostring(cat):lower()
                        for selRarity, active in pairs(PlotCfg.selectedRarities) do
                            if active and selRarity ~= "All" then
                                local sLower = selRarity:lower()
                                if rLower:find(sLower, 1, true) or sLower:find(rLower, 1, true) or cLower:find(sLower, 1, true) then
                                    allowed = true
                                    break
                                end
                            end
                        end
                        if not allowed then continue end
                    end
                    table.insert(results, {
                        id       = recordId,
                        uid      = recordId,
                        category = cat,
                        rarity   = rarity or "Common",
                        weight   = weight,
                        record   = record,
                    })
                end
            end
        end
    end
    return results
end

local function doPlotPlaceOnce(mode, generation)
    mode = mode or "manual"
    local function plotStillAllowed()
        if generation and generation ~= PlotRuntime.placeGeneration then return false end
        if mode == "standalone" then return PlotCfg.autoPlace and not Cfg.autoFarm end
        if mode == "farm" then return PlotCfg.autoPlace and Cfg.autoFarm end
        if mode == "manual" then return not Cfg.autoFarm end
        return false
    end
    if not plotStillAllowed() then return false end
    PlotRuntime.placeOwner = mode
    if isPlayerOnTreadmill() then releaseTreadmill() end
    local penInfo = findMyPlot()
    if not penInfo or not plotStillAllowed() then return false end
    local unplaced = getUnplacedEggs()
    if #unplaced == 0 then return false end
    local occupiedKeys = {}
    pcall(function()
        local es = require(S.ReplicatedStorage.Client.EggState)
        local ownerEggs = es.ReadOwnerEggs(LP.UserId)
        if type(ownerEggs) == "table" then
            for _, record in pairs(ownerEggs) do
                if record.Placement and record.Placement.LocalCFrame then
                    local cf = record.Placement.LocalCFrame
                    if typeof(cf) == "CFrame" then
                        local key = string.format("%d_%d",
                            math.floor(cf.X / 5 + 0.5) * 5,
                            math.floor(cf.Z / 5 + 0.5) * 5)
                        occupiedKeys[key] = true
                    elseif type(cf) == "string" then
                        local pcf = parseCFrameString(cf)
                        if pcf then
                            local key = string.format("%d_%d",
                                math.floor(pcf.X / 5 + 0.5) * 5,
                                math.floor(pcf.Z / 5 + 0.5) * 5)
                            occupiedKeys[key] = true
                        end
                    end
                end
            end
        end
    end)
    if not next(occupiedKeys) and RMT.RuntimeSnapshot then
        pcall(function()
            local snap = RMT.RuntimeSnapshot:InvokeServer()
            if type(snap) == "table" then
                for _, entry in ipairs(snap) do
                    if entry.OwnerUserId == LP.UserId and type(entry.Records) == "table" then
                        for _, record in pairs(entry.Records) do
                            if record.Placement and record.Placement.LocalCFrame then
                                local cf = record.Placement.LocalCFrame
                                if typeof(cf) == "CFrame" then
                                    local key = string.format("%d_%d",
                                        math.floor(cf.X / 5 + 0.5) * 5,
                                        math.floor(cf.Z / 5 + 0.5) * 5)
                                    occupiedKeys[key] = true
                                elseif type(cf) == "string" then
                                    local pcf = parseCFrameString(cf)
                                    if pcf then
                                        local key = string.format("%d_%d",
                                            math.floor(pcf.X / 5 + 0.5) * 5,
                                            math.floor(pcf.Z / 5 + 0.5) * 5)
                                        occupiedKeys[key] = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
    local SPACING   = 5
    local Y_OFFSET  = -0.025
    local gridSlots = {}
    for z = -15, 15, SPACING do
        for x = -20, 20, SPACING do
            local key = string.format("%d_%d", x, z)
            if not occupiedKeys[key] then
                table.insert(gridSlots, {x = x, z = z})
            end
        end
    end
    if #gridSlots == 0 then
        UpdatePlotStatus("Pen is full!")
        return false
    end
    local petArea = penInfo.petArea
    UpdatePlotStatus("Entering PetArea...")
    local reachedPetArea = tpWalk(
        petArea.Position + Vector3.new(0, 2, 0),
        4,
        false,
        plotStillAllowed
    )
    if not reachedPetArea or not plotStillAllowed() then
        PlotRuntime.placeOwner = nil
        return false
    end
    local root = getRoot()
    if root then
        root.CFrame = CFrame.new(petArea.Position + Vector3.new(0, 2, 0))
        root.AssemblyLinearVelocity = Vector3.zero
    end
    if not plotStillAllowed() then
        PlotRuntime.placeOwner = nil
        return false
    end
    task.wait(0.2)
    if not plotStillAllowed() then
        PlotRuntime.placeOwner = nil
        return false
    end
    local placedInCycle = 0
    local slotIdx = 1
    for _, egg in ipairs(unplaced) do
        if not plotStillAllowed() then break end
        for attempt = 1, 5 do
            if not plotStillAllowed() then break end
            if slotIdx > #gridSlots then break end
            local slot = gridSlots[slotIdx]
            slotIdx = slotIdx + 1
            local localCF = CFrame.new(slot.x, Y_OFFSET, slot.z)
            if not plotStillAllowed() then break end
            local ok, res = pcall(function()
                local es = require(S.ReplicatedStorage.Client.EggState)
                return es.PlantEgg(egg.id, localCF)
            end)
            if not ok or res ~= true then
                pcall(function()
                    local rf = S.ReplicatedStorage.Packages.Networking:FindFirstChild("RF/EggWorld/AskPlaceEgg")
                    if rf then
                        local r = rf:InvokeServer(egg.id, localCF)
                        if r == true or (type(r) == "table" and r.success == true) then
                            res = true
                            ok = true
                        end
                    end
                end)
            end
            if ok and (res == true or (type(res) == "table" and res.success == true)) then
                placedInCycle = placedInCycle + 1
                PlotRuntime.placedCount = PlotRuntime.placedCount + 1
                UpdatePlotStatus(string.format("Placed %s [%d]", egg.category, PlotRuntime.placedCount))
                local key = string.format("%d_%d", slot.x, slot.z)
                occupiedKeys[key] = true
                task.wait(0.08)
                break
            end
            task.wait(0.05)
        end
    end
    PlotRuntime.placeOwner = nil
    return placedInCycle > 0
end

local function doPlotPlaceLoop()
    if PlotRuntime.placing then return end
    PlotRuntime.placing = true
    PlotRuntime.placeGeneration = PlotRuntime.placeGeneration + 1
    local myGeneration = PlotRuntime.placeGeneration
    PlotRuntime.placeOwner = "standalone"
    UpdatePlotStatus("Starting...")
    local function standaloneAlive()
        return myGeneration == PlotRuntime.placeGeneration
            and PlotCfg.autoPlace
            and not Cfg.autoFarm
    end
    while standaloneAlive() do
        local unplaced = getUnplacedEggs()
        if not standaloneAlive() then break end
        if #unplaced == 0 then
            UpdatePlotStatus("No unplaced eggs")
            local waitUntil = tick() + 2
            while standaloneAlive() and tick() < waitUntil do
                task.wait(0.05)
            end
            continue
        end
        local ok = doPlotPlaceOnce("standalone", myGeneration)
        if not standaloneAlive() then break end
        if ok then
            UpdatePlotStatus(string.format("OK [%d]", PlotRuntime.placedCount))
            tpWalk(SAFEZONE_POS, 5, false, standaloneAlive)
        else
            if standaloneAlive() then
                UpdatePlotStatus("Pen full / retry")
                local waitUntil = tick() + 2.5
                while standaloneAlive() and tick() < waitUntil do
                    task.wait(0.05)
                end
            end
        end
        local waitUntil = tick() + 0.5
        while standaloneAlive() and tick() < waitUntil do
            task.wait(0.05)
        end
    end
    if myGeneration == PlotRuntime.placeGeneration then
        PlotRuntime.placeOwner = nil
    end
    PlotRuntime.placing = false
    UpdatePlotStatus("Idle")
end

local function doHatchLoop()
    if PlotRuntime.hatching then return end
    PlotRuntime.hatching = true
    while PlotCfg.autoHatch do
        local hatched = 0
        pcall(function()
            local pg = LP:FindFirstChild("PlayerGui")
            local growing = pg and pg:FindFirstChild("GrowingEggs")
            local frame = growing and growing:FindFirstChild("Frame")
            local sf = frame and frame:FindFirstChild("ScrollingFrame")
            if sf then
                for _, child in ipairs(sf:GetChildren()) do
                    if not PlotCfg.autoHatch then break end
                    if child:IsA("GuiObject") and child.Name ~= "Template" and child.Name ~= "EmptyLast" then
                        local spacer = child:FindFirstChild("Spacer")
                        local openBtn = spacer and spacer:FindFirstChild("Open")
                        if openBtn and openBtn.Visible then
                            local price = openBtn:FindFirstChild("Price")
                            if price and (price.Text == "Open" or price.Text:lower():find("open") or price.Text:lower():find("hatch")) then
                                local uid = child.Name
                                pcall(function()
                                    local mod = require(S.ReplicatedStorage.Shared.Eggs.PlacedEggRenderer)
                                    mod.ActivateLocalEgg(uid)
                                end)
                                pcall(function() if RMT.Hatch then RMT.Hatch:InvokeServer(uid) end end)
                                task.wait(0.08)
                                pcall(function() if RMT.FinishHatch then RMT.FinishHatch:InvokeServer(uid) end end)
                                hatched = hatched + 1
                                task.wait(0.15)
                            end
                        end
                    end
                end
            end
        end)
        pcall(function()
            local rs = S.ReplicatedStorage
            local EggState = require(rs.Client.EggState)
            local PlacedEggRenderer = require(rs.Shared.Eggs.PlacedEggRenderer)
            local owned = EggState.ReadOwnedEggs()
            if type(owned) == "table" then
                for uid, rec in pairs(owned) do
                    if not PlotCfg.autoHatch then break end
                    if rec.Placement and EggState.IsReadyToHatch(uid) then
                        pcall(function() PlacedEggRenderer.ActivateLocalEgg(uid) end)
                        pcall(function() if RMT.Hatch then RMT.Hatch:InvokeServer(uid) end end)
                        task.wait(0.08)
                        pcall(function() if RMT.FinishHatch then RMT.FinishHatch:InvokeServer(uid) end end)
                        hatched = hatched + 1
                        task.wait(0.15)
                    end
                end
            end
        end)
        pcall(function()
            local folder = S.Workspace:FindFirstChild("PlacedEggRenders")
            local userId = tostring(LP.UserId)
            if folder then
                for _, egg in ipairs(folder:GetChildren()) do
                    if not PlotCfg.autoHatch then break end
                    if egg.Name:sub(1, #userId) == userId then
                        for _, d in ipairs(egg:GetDescendants()) do
                            if d:IsA("ProximityPrompt") then
                                local at = (d.ActionText or ""):lower()
                                local ot = (d.ObjectText or ""):lower()
                                if at:find("hatch") or at:find("open") or ot:find("hatch") then
                                    if Cfg.instantSteal then d.HoldDuration = 0 end
                                    pcall(function() fireproximityprompt(d) end)
                                    hatched = hatched + 1
                                    task.wait(0.2)
                                end
                            end
                        end
                    end
                end
            end
        end)
        if hatched > 0 then
            UpdatePlotStatus(string.format("Hatched %d!", hatched))
        end
        task.wait(2)
    end
    PlotRuntime.hatching = false
end

-- ============================================================
-- [14] SHOP ENGINE (Sell)
-- ============================================================
local function isRarityInSellFilter(rarityName, filterTable)
    if not next(filterTable) then return false end
    if filterTable["All"] then return true end
    local rLower = tostring(rarityName or ""):lower():gsub("%s+", "")
    for selRarity, active in pairs(filterTable) do
        if active and selRarity ~= "All" then
            local sLower = selRarity:lower():gsub("%s+", "")
            if rLower == sLower or rLower:find(sLower, 1, true) or sLower:find(rLower, 1, true) then
                return true
            end
        end
    end
    return false
end

local function doSellEggCycle()
    if not ShopCfg.autoSellAll then return end
    if not next(ShopCfg.sellEggRarities) then return end
    local Save = nil
    pcall(function() Save = require(S.ReplicatedStorage.Shared.Save).Get() end)
    if not Save or not Save.EggInventory then return end
    local EggState = nil
    pcall(function() EggState = require(S.ReplicatedStorage.Client.EggState) end)
    if not EggState or not EggState.WearEggTool then return end
    if not RMT.SellPet then return end
    buildAssetRarityCache()
    for uid, eggData in pairs(Save.EggInventory) do
        if not ShopCfg.autoSellAll then break end
        if eggData.Placement then continue end
        local cat = tostring(eggData.AssetCategory or "")
        local rarity = AssetRarityCache[cat:lower()] or getRarityFromModel({Name = cat})
        if not isRarityInSellFilter(rarity, ShopCfg.sellEggRarities) then continue end
        pcall(function() EggState.WearEggTool(uid) end)
        task.wait(0.08)
        pcall(function() RMT.SellPet:FireServer({ uid }) end)
        task.wait(0.08)
    end
end

local function doSellPetCycle()
    if not ShopCfg.autoSellAll then return end
    if not next(ShopCfg.sellPetRarities) then return end
    local Save = nil
    pcall(function() Save = require(S.ReplicatedStorage.Shared.Save).Get() end)
    if not Save or not Save.Inventory then return end
    if not RMT.SellEveryPet then return end
    buildAssetRarityCache()
    local equipped = Save.EquippedAssets or {}
    local uidsToSell = {}
    for uid, petData in pairs(Save.Inventory) do
        if petData.InFuse then continue end
        if petData.IsFavorite then continue end
        if table.find(equipped, uid) then continue end
        local cat = tostring(petData.Category or "")
        local rarity = AssetRarityCache[cat:lower()] or getRarityFromModel({Name = cat})
        if isRarityInSellFilter(rarity, ShopCfg.sellPetRarities) then
            table.insert(uidsToSell, uid)
        end
    end
    if #uidsToSell > 0 then
        pcall(function() RMT.SellEveryPet:FireServer(uidsToSell) end)
    end
end

local function doSellCycle()
    doSellEggCycle()
    doSellPetCycle()
end

local function doAutoUpgradePlot()
    if ShopCfg.autoUpgradePlot and RMT.BaseUpgrade then
        pcall(function() RMT.BaseUpgrade:FireServer() end)
    end
end

local function doAutoUpgradeTreadmill()
    if ShopCfg.autoUpgradeTread and RMT.TreadmillUpgrade then
        pcall(function() RMT.TreadmillUpgrade:InvokeServer() end)
    end
end

local function getFusePetOptions()
    local Save = nil
    pcall(function() Save = require(S.ReplicatedStorage.Shared.Save).Get() end)
    local counts = {}
    if Save and Save.Inventory then
        for uid, item in pairs(Save.Inventory) do
            if not item.InFuse and not item.IsFavorite then
                local cat = tostring(item.Category or "Unknown")
                counts[cat] = (counts[cat] or 0) + 1
            end
        end
    end
    local options = {}
    for cat, count in pairs(counts) do
        table.insert(options, {cat = cat, count = count, label = string.format("%s (x%d)", cat, count)})
    end
    table.sort(options, function(a, b) return a.count > b.count end)
    local labels = {"None"}
    for _, opt in ipairs(options) do table.insert(labels, opt.label) end
    return labels, counts
end

local function doFuseOnce()
    if not ShopCfg.autoFuse or ShopCfg.selectedPetFuse == "" or ShopCfg.selectedPetFuse == "None" then return false end
    local chosenCategory = ShopCfg.selectedPetFuse:match("^(.-)%s*%(x%d+%)") or ShopCfg.selectedPetFuse
    if chosenCategory == "" or chosenCategory == "None" then return false end
    local Save = nil
    pcall(function() Save = require(S.ReplicatedStorage.Shared.Save).Get() end)
    if not Save or not Save.Inventory then return false end
    local matchingUids = {}
    for uid, item in pairs(Save.Inventory) do
        if not item.InFuse and not item.IsFavorite and item.Category == chosenCategory then
            table.insert(matchingUids, uid)
            if #matchingUids >= 3 then break end
        end
    end
    if #matchingUids < 3 then return false, "Need at least 3 pets" end
    if RMT.FuseryLoadPet and RMT.FuseryBeginFuse then
        for i = 1, 3 do
            pcall(function() RMT.FuseryLoadPet:InvokeServer(matchingUids[i]) end)
            task.wait(0.1)
        end
        local ok = pcall(function() return RMT.FuseryBeginFuse:InvokeServer() end)
        task.wait(0.2)
        if RMT.FuseryFinishReveal then pcall(function() RMT.FuseryFinishReveal:InvokeServer() end) end
        return ok, "Fuse done for " .. chosenCategory
    end
    return false, "Fusery remote missing"
end

-- ============================================================
-- [15] MISC ENGINE (FPS, ULTRA FPS, SERVER HOP)
-- ============================================================
local FpsState = {
    enabled = false,
    savedShadows = nil,
    savedWater = nil,
    savedParticles = {},
    savedPostFx = {},
    conn = nil,
}

local function applyFpsBoost(enabled)
    FpsState.enabled = enabled
    local Lighting = S.Lighting
    local POST = {BloomEffect=true, BlurEffect=true, ColorCorrectionEffect=true, DepthOfFieldEffect=true, SunRaysEffect=true}
    local KILL = {ParticleEmitter=true, Trail=true, Beam=true, Smoke=true, Fire=true, Sparkles=true}
    if enabled then
        pcall(function()
            if FpsState.savedShadows == nil then FpsState.savedShadows = Lighting.GlobalShadows end
            Lighting.GlobalShadows = false
        end)
        pcall(function()
            if S.Workspace.Terrain then
                if FpsState.savedWater == nil then FpsState.savedWater = S.Workspace.Terrain.WaterWaveSpeed end
                S.Workspace.Terrain.Decoration = false
                S.Workspace.Terrain.WaterWaveSize = 0
                S.Workspace.Terrain.WaterWaveSpeed = 0
            end
        end)
        for _, obj in ipairs(S.Workspace:GetDescendants()) do
            if KILL[obj.ClassName] then
                FpsState.savedParticles[obj] = obj.Enabled
                pcall(function() obj.Enabled = false end)
            elseif POST[obj.ClassName] then
                FpsState.savedPostFx[obj] = obj.Enabled
                pcall(function() obj.Enabled = false end)
            end
        end
        for _, obj in ipairs(Lighting:GetDescendants()) do
            if POST[obj.ClassName] then
                FpsState.savedPostFx[obj] = obj.Enabled
                pcall(function() obj.Enabled = false end)
            end
        end
        if not FpsState.conn then
            FpsState.conn = S.Workspace.DescendantAdded:Connect(function(obj)
                if not FpsState.enabled then return end
                if KILL[obj.ClassName] or POST[obj.ClassName] then pcall(function() obj.Enabled = false end) end
            end)
        end
    else
        pcall(function() if FpsState.savedShadows ~= nil then Lighting.GlobalShadows = FpsState.savedShadows end end)
        pcall(function()
            if S.Workspace.Terrain and FpsState.savedWater ~= nil then
                S.Workspace.Terrain.Decoration = true
                S.Workspace.Terrain.WaterWaveSpeed = FpsState.savedWater
            end
        end)
        for obj, was in pairs(FpsState.savedParticles) do if obj and obj.Parent then pcall(function() obj.Enabled = was end) end end
        for obj, was in pairs(FpsState.savedPostFx) do if obj and obj.Parent then pcall(function() obj.Enabled = was end) end end
        table.clear(FpsState.savedParticles)
        table.clear(FpsState.savedPostFx)
        if FpsState.conn then FpsState.conn:Disconnect(); FpsState.conn = nil end
    end
end

local UltraFpsState = {
    enabled = false,
    conn = nil,
}

local function applyUltraFps(enabled)
    UltraFpsState.enabled = enabled
    if enabled then
        local function processObject(p)
            if not p then return end
            if p:IsA("Decal") or p:IsA("Texture") then
                pcall(function() p.Transparency = 1 end)
            elseif p:IsA("BasePart") then
                local anc = p.Parent
                local isProtected = false
                while anc do
                    if anc == LP.Character
                        or anc:IsA("Tool")
                        or anc.Name == "Plots"
                        or anc.Name == "AreaEggSlotsClient"
                        or anc.Name == "__OBJECTS"
                        or anc.Name == "Characters"
                        or (typeof(anc.FindFirstChildOfClass) == "function" and anc:FindFirstChildOfClass("Humanoid"))
                    then
                        isProtected = true
                        break
                    end
                    anc = anc.Parent
                end
                if not isProtected then
                    pcall(function()
                        p.CastShadow = false
                        p.Transparency = 1
                    end)
                end
            end
        end
        for _, d in ipairs(S.Workspace:GetDescendants()) do
            processObject(d)
        end
        if not UltraFpsState.conn then
            UltraFpsState.conn = S.Workspace.DescendantAdded:Connect(function(d)
                if not UltraFpsState.enabled then return end
                task.wait(0.05)
                pcall(processObject, d)
            end)
        end
    else
        if UltraFpsState.conn then
            UltraFpsState.conn:Disconnect()
            UltraFpsState.conn = nil
        end
    end
end

local HopState = { lastHopCheck = tick() }

local function executeServerHop(method)
    method = method or MiscCfg.hopMethod or "Small Server"
    local placeId = PLACE_ID or game.PlaceId
    local currentJobId = game.JobId
    UpdateStatus("Searching small server...")
    local targetServer = nil

    if method == "Small Server" then
        local cursor = ""
        local minPlayers = math.huge
        for page = 1, 5 do
            local url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100%s",
                tostring(placeId),
                cursor ~= "" and ("&cursor=" .. cursor) or "")
            local ok, res = pcall(function() return game:HttpGet(url) end)
            if not ok or type(res) ~= "string" or res == "" then break end
            local okJson, data = pcall(function() return S.HttpService:JSONDecode(res) end)
            if not okJson or not data or not data.data then break end
            for _, s in ipairs(data.data) do
                local plrs = tonumber(s.playing) or 0
                local maxP = tonumber(s.maxPlayers) or 12
                if s.id ~= currentJobId and plrs > 0 and plrs < maxP then
                    if plrs < minPlayers then
                        minPlayers = plrs
                        targetServer = s
                        if plrs <= 1 then break end
                    end
                end
            end
            if minPlayers <= 1 then break end
            if data.nextPageCursor and data.nextPageCursor ~= "" and data.nextPageCursor ~= "null" then
                cursor = data.nextPageCursor
            else
                break
            end
        end
    else
        local url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=100", tostring(placeId))
        local ok, res = pcall(function() return game:HttpGet(url) end)
        if ok and type(res) == "string" and res ~= "" then
            local okJson, data = pcall(function() return S.HttpService:JSONDecode(res) end)
            if okJson and data and data.data then
                local valid = {}
                for _, s in ipairs(data.data) do
                    local plrs = tonumber(s.playing) or 0
                    local maxP = tonumber(s.maxPlayers) or 12
                    if s.id ~= currentJobId and plrs > 0 and plrs < maxP then table.insert(valid, s) end
                end
                if #valid > 0 then targetServer = valid[math.random(1, #valid)] end
            end
        end
    end

    if targetServer and targetServer.id then
        task.wait(0.5)
        pcall(function() S.TeleportService:TeleportToPlaceInstance(placeId, targetServer.id, LP) end)
        return true
    end
    pcall(function() S.TeleportService:Teleport(placeId, LP) end)
    return false
end

-- ============================================================
-- [16] FARM LOOP
-- ============================================================
local function attemptPickup(target)
    local walkTarget = target.pos
    local prompt = getEggPrompt(target.pos)
    if prompt and prompt.Parent and prompt.Parent:IsA("BasePart") then
        walkTarget = prompt.Parent.Position
    end
    applyInstantToAll()
    local pickStart = tick()
    local PICK_TIMEOUT = 2.0

    while tick() - pickStart < PICK_TIMEOUT and Cfg.autoFarm do
        local root = getRoot()
        if root and (root.Position - walkTarget).Magnitude > 6 then
            root.CFrame = CFrame.new(walkTarget + Vector3.new(0, 3, 0))
            root.AssemblyLinearVelocity = Vector3.zero
        end
        if isCarryingEgg() then
            instantCarryEscape()
            return true
        end
        local eggStateSuccess = false
        pcall(function()
            local rs = S.ReplicatedStorage
            local EggState = require(rs.Client.EggState)
            if EggState and EggState.CarryFieldEgg then
                local res = EggState.CarryFieldEgg(target.uid, target.slotKey)
                if res == true then eggStateSuccess = true end
            end
        end)
        if eggStateSuccess or isCarryingEgg() then
            instantCarryEscape()
            return true
        end
        S.RunService.Heartbeat:Wait()
        if isCarryingEgg() then
            instantCarryEscape()
            return true
        end
        local remoteSuccess = false
        if RMT.CarryEgg then
            pcall(function()
                local res = RMT.CarryEgg:InvokeServer({
                    FirstAreaSlotKey = target.slotKey,
                    Uid              = target.uid,
                })
                if res == true or (type(res) == "table" and (res.success == true or res.Success == true)) then
                    remoteSuccess = true
                end
            end)
        end
        if remoteSuccess or isCarryingEgg() then
            instantCarryEscape()
            return true
        end
        if prompt and prompt.Parent and prompt:IsDescendantOf(S.Workspace) then
            if Cfg.instantSteal then pcall(function() prompt.HoldDuration = 0 end) end
            pcall(function() fireproximityprompt(prompt) end)
        else
            prompt = getEggPrompt(walkTarget)
        end
        local confirmStart = tick()
        while tick() - confirmStart < 0.20 and Cfg.autoFarm do
            if isCarryingEgg() then
                instantCarryEscape()
                return true
            end
            S.RunService.Heartbeat:Wait()
        end
        if not target.model or not target.model.Parent or not target.model:IsDescendantOf(S.Workspace) then
            local finalCheck = tick()
            while tick() - finalCheck < 0.20 and Cfg.autoFarm do
                if isCarryingEgg() then
                    instantCarryEscape()
                    return true
                end
                S.RunService.Heartbeat:Wait()
            end
            return false
        end
        S.RunService.Heartbeat:Wait()
    end
    if isCarryingEgg() then
        instantCarryEscape()
        return true
    end
    return false
end

doFarmLoop = function()
    if Runtime.farming then return end
    Runtime.farming = true
    PlotRuntime.placeGeneration = PlotRuntime.placeGeneration + 1
    PlotRuntime.placeOwner = nil
    UpdateStatus("Waiting for Character...")
    ensureCharacter(15)
    UpdateStatus("BAC Bypass...")
    pcall(applyBacBypass, LP.Character)
    buildAssetRarityCache()
    task.wait(0.3)

    while Cfg.autoFarm do
        local curChar = LP.Character
        local curRoot = getRoot()
        local curHum  = getHumanoid()
        if not curChar or not curRoot or not curHum or not curRoot.Parent or curHum.Health <= 0 then
            UpdateStatus("Respawning...")
            ensureCharacter(10)
            task.wait(0.5)
        end
        UpdateStatus("→ Safezone")
        tpWalk(SAFEZONE_POS, 5)
        if not Cfg.autoFarm then break end
        if PlotCfg.autoPlace then
            local unplaced = getUnplacedEggs()
            if #unplaced > 0 then
                UpdateStatus("Safezone: Placing eggs to pen...")
                PlotRuntime.placeGeneration = PlotRuntime.placeGeneration + 1
                local farmPlotGeneration = PlotRuntime.placeGeneration
                doPlotPlaceOnce("farm", farmPlotGeneration)
                UpdateStatus("Returning to safezone...")
                tpWalk(SAFEZONE_POS, 5)
                task.wait(0.15)
            end
        end
        UpdateStatus("Scanning...")
        local eggs = nil
        local scanDone = false
        scanEggsAsync(function(result)
            eggs = result
            scanDone = true
        end)
        local waitStart = tick()
        while not scanDone and tick() - waitStart < 5 do task.wait(0.05) end
        if not eggs or #eggs == 0 then
            if Cfg.autoTreadmill then
                local penInfo = findMyPlot()
                local tb = penInfo and penInfo.plot and penInfo.plot:FindFirstChild("TreadmillBottom")
                if tb then
                    UpdateStatus("No eggs: Moving to Treadmill...")
                    tpWalk(tb.Position + Vector3.new(0, 2, 0), 4)
                    while Cfg.autoFarm and Cfg.autoTreadmill do
                        task.wait(1.0)
                        local scanDoneInner = false
                        local innerEggs = nil
                        scanEggsAsync(function(res) innerEggs = res; scanDoneInner = true end)
                        local wStart = tick()
                        while not scanDoneInner and tick() - wStart < 4 do task.wait(0.05) end
                        if innerEggs and #innerEggs > 0 then
                            eggs = innerEggs
                            break
                        end
                        UpdateStatus("Treadmill: Scanning for eggs...")
                    end
                else
                    UpdateStatus("No eggs found, waiting in Safezone...")
                    task.wait(1.5)
                end
            else
                UpdateStatus("No eggs found, waiting in Safezone...")
                task.wait(1.5)
            end
            if not eggs or #eggs == 0 then continue end
        end
        if isPlayerOnTreadmill() then
            UpdateStatus("Egg detected! Releasing treadmill...")
            releaseTreadmill()
            tpWalk(SAFEZONE_POS, 5)
            task.wait(0.2)
        end
        local target = eggs[1]
        local rarityDisplay = target.rarity or "?"
        local zoneDisplay   = target.zone or "Unknown"
        local catDisplay    = target.category or "Egg"
        UpdateStatus(string.format("[%s] %s | %s | %.1f kg", rarityDisplay, catDisplay, zoneDisplay, target.weight))
        local walkTarget = target.pos
        local prompt = getEggPrompt(target.pos)
        if prompt and prompt.Parent and prompt.Parent:IsA("BasePart") then
            walkTarget = prompt.Parent.Position
        end
        forceUnequipTools()
        tpWalk(walkTarget, 4, true)
        if not Cfg.autoFarm then break end
        if not target.model or not target.model.Parent or not target.model:IsDescendantOf(S.Workspace) then
            UpdateStatus("Egg gone, rescanning...")
            ScanCache.lastScan = 0
            task.wait(0.1)
            continue
        end
        UpdateStatus("Stealing: " .. catDisplay .. " [" .. rarityDisplay .. "]")
        local pickedUp = attemptPickup(target)
        if not Cfg.autoFarm then break end
        if not pickedUp then
            UpdateStatus("Pickup failed → Rescanning...")
            ScanCache.lastScan = 0
            ScanCache.eggs = {}
            task.wait(0.05)
            continue
        end
        if PlotCfg.autoPlace then
            local unplaced = getUnplacedEggs()
            if #unplaced > 0 then
                UpdateStatus("Safezone: Placing eggs to pen...")
                PlotRuntime.placeGeneration = PlotRuntime.placeGeneration + 1
                local farmPlotGeneration = PlotRuntime.placeGeneration
                doPlotPlaceOnce("farm", farmPlotGeneration)
                UpdateStatus("Returning to safezone...")
                tpWalk(SAFEZONE_POS, 5)
                task.wait(0.15)
            end
        end
        if ShopCfg.autoSellAll then doSellCycle() end
        task.wait(0.05)
    end
    Runtime.farming = false
    UpdateStatus("Idle")
end

-- ============================================================
-- [17] BACKGROUND LOOPS (upgrades, fuse, hop)
-- ============================================================
task.spawn(function()
    while true do
        task.wait(3)
        pcall(function()
            if ShopCfg.autoUpgradePlot then doAutoUpgradePlot() end
            if ShopCfg.autoUpgradeTread then doAutoUpgradeTreadmill() end
            if ShopCfg.autoFuse then doFuseOnce() end
            if MiscCfg.autoHop then
                local delaySec = (MiscCfg.hopDelay or 30) * 60
                if tick() - HopState.lastHopCheck >= delaySec then
                    HopState.lastHopCheck = tick()
                    executeServerHop(MiscCfg.hopMethod)
                end
            end
        end)
    end
end)

-- ============================================================
-- [18] NOTIFY HELPER
-- ============================================================
local function Notify(text, dur)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "ASTRO", Text = tostring(text), Duration = dur or 3
        })
    end)
end

-- ============================================================
-- [19] ANTI-STUN HEARTBEAT
-- ============================================================
S.RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                if hum.PlatformStand then hum.PlatformStand = false end
            end)
            local st = hum:GetState()
            if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end
end)

-- ============================================================
-- [20] BUILD OBSIDIAN UI
-- ============================================================
local function buildUI()
    local Window = Library:CreateWindow({
        Title = "ASTRO",
        Footer = "Steal An Egg",
        Size = UDim2.fromOffset(920, 720),
        Center = true,
        Resizable = true,
        ShowCustomCursor = true,
        NotifySide = "Right",
        CornerRadius = 8,
        ToggleKeybind = Enum.KeyCode.LeftAlt,
    })

    -- Helper to save config after UI interaction
    local function applyAndSave()
        saveConfig()
    end

    -- ------------------------------------------------------------------
    -- TAB: AUTO FARM
    -- ------------------------------------------------------------------
    local AutoTab = Window:AddTab("Auto Farm", "bot")
    local FarmSub = AutoTab:AddSubTab("Farm", "play")
    local SpeedSub = AutoTab:AddSubTab("Speed", "gauge")
    local ExtraSub = AutoTab:AddSubTab("Extra", "wrench")

    -- Farm Sub-tab
    local farmGroup = FarmSub:AddLeftGroupbox("Farm Settings", "settings")

    -- Status label
    local statusLbl = farmGroup:AddLabel("Status: Idle | Steals: 0", true)
    Runtime.StatusLbl = statusLbl

    farmGroup:AddDivider()

    farmGroup:AddToggle("AutoFarm", {
        Text = "Auto Farm Eggs",
        Default = Cfg.autoFarm,
        Callback = function(v)
            Cfg.autoFarm = v
            PlotRuntime.placeGeneration = PlotRuntime.placeGeneration + 1
            PlotRuntime.placeOwner = nil
            if v and not Runtime.farming then
                task.spawn(doFarmLoop)
            elseif not v and PlotCfg.autoPlace and not PlotRuntime.placing then
                task.spawn(doPlotPlaceLoop)
            end
            applyAndSave()
        end
    })

    farmGroup:AddToggle("Anti Boss", {
        Text = "Anti Boss",
        Default = Cfg.antiBoss,
        Callback = function(v)
            Cfg.antiBoss = v
            if not v then stopAntiBossSpamTeleport() end
            applyAndSave()
        end
    })

    farmGroup:AddToggle("Instant Steal", {
        Text = "Instant Steal (0s Prompt)",
        Default = Cfg.instantSteal,
        Callback = function(v)
            Cfg.instantSteal = v
            if v then applyInstantToAll() end
            applyAndSave()
        end
    })

    farmGroup:AddToggle("Auto Treadmill", {
        Text = "Auto Treadmill (When Waiting)",
        Default = Cfg.autoTreadmill,
        Callback = function(v)
            Cfg.autoTreadmill = v
            if not v and isPlayerOnTreadmill() then releaseTreadmill() end
            applyAndSave()
        end
    })

    -- Rarity, Area, Min Weight, Priority
    farmGroup:AddDivider()

    -- Multi-select Areas
    -- We'll use the Library's built-in dropdown for multi-select? The tutorial shows dropdown for single select. For multi-select they use a custom. We'll replicate using the Library's dropdown with values and multi flag.
    -- Actually the tutorial shows Dropdown with Multi = true. We'll use that.
    local areaDropdown = farmGroup:AddDropdown("Select Area", {
        Text = "Area",
        Values = ZONE_NAMES,
        Multi = true,
        Searchable = true,
        Default = 1, -- default "All"
        Callback = function(value)
            -- value is table of selected strings
            local newTbl = {}
            for _, v in ipairs(value) do newTbl[v] = true end
            Cfg.selectedAreas = newTbl
            applyAndSave()
        end
    })
    -- Set initial selection from Cfg.selectedAreas
    local initialAreas = {}
    for i, name in ipairs(ZONE_NAMES) do
        if Cfg.selectedAreas[name] then table.insert(initialAreas, name) end
    end
    if #initialAreas == 0 then table.insert(initialAreas, "All") end
    areaDropdown:SetValue(initialAreas)

    local rarityDropdown = farmGroup:AddDropdown("Select Rarity", {
        Text = "Rarity",
        Values = RARITIES,
        Multi = true,
        Searchable = true,
        Default = 1,
        Callback = function(value)
            local newTbl = {}
            for _, v in ipairs(value) do newTbl[v] = true end
            Cfg.selectedRarities = newTbl
            applyAndSave()
        end
    })
    local initialRarities = {}
    for i, name in ipairs(RARITIES) do
        if Cfg.selectedRarities[name] then table.insert(initialRarities, name) end
    end
    if #initialRarities == 0 then table.insert(initialRarities, "All") end
    rarityDropdown:SetValue(initialRarities)

    farmGroup:AddInput("Min Weight", {
        Text = "Min Weight",
        Default = tostring(Cfg.minWeight),
        Placeholder = "0 = All",
        Finished = true,
        Callback = function(text)
            local num = tonumber(text)
            if num then Cfg.minWeight = math.max(0, num) end
            applyAndSave()
        end
    })

    farmGroup:AddDropdown("Farm Priority", {
        Text = "Priority",
        Values = {"Nearest", "Hugest", "Rarest"},
        Default = Cfg.farmPriority,
        Callback = function(v)
            Cfg.farmPriority = v
            applyAndSave()
        end
    })

    farmGroup:AddDivider()

    farmGroup:AddButton("Reset Steal Counter", function()
        Runtime.steals = 0
        UpdateStatus(Runtime.statusText)
        Notify("Counter reset", 2)
    end)

    farmGroup:AddButton("Force Re-Scan", function()
        ScanCache.lastScan = 0
        Notify("Cache cleared, next cycle re-scans", 2)
    end)

    -- Speed Sub-tab
    local speedGroup = SpeedSub:AddLeftGroupbox("Infinite Yield Engine", "sliders")
    speedGroup:AddSlider("Walk Speed", {
        Text = "TPWalk Speed",
        Default = Cfg.walkSpeed,
        Min = 1,
        Max = 150,
        Rounding = 0,
        Suffix = " studs/s",
        Callback = function(v)
            Cfg.walkSpeed = v
            applyAndSave()
        end
    })

    -- Extra Sub-tab (misc controls)
    local extraGroup = ExtraSub:AddLeftGroupbox("Extra", "star")

    -- Plot and Shop toggles might be here or separate tabs. We'll keep them separate.

    -- ------------------------------------------------------------------
    -- TAB: PLOT
    -- ------------------------------------------------------------------
    local PlotTab = Window:AddTab("Plot", "map")
    local PlaceSub = PlotTab:AddSubTab("Place", "package")
    local HatchSub = PlotTab:AddSubTab("Hatch", "egg")

    -- Place sub-tab
    local placeGroup = PlaceSub:AddLeftGroupbox("Plot Manager", "map")
    local plotStatus = placeGroup:AddLabel("Plot: Idle | Placed: 0", true)
    PlotRuntime.StatusLbl2 = plotStatus

    placeGroup:AddDivider()

    local plotRarityDropdown = placeGroup:AddDropdown("Rarity To Place", {
        Text = "Rarity",
        Values = RARITIES,
        Multi = true,
        Searchable = true,
        Default = 1,
        Callback = function(value)
            local newTbl = {}
            for _, v in ipairs(value) do newTbl[v] = true end
            PlotCfg.selectedRarities = newTbl
            applyAndSave()
        end
    })
    local initialPlotRarities = {}
    for i, name in ipairs(RARITIES) do
        if PlotCfg.selectedRarities[name] then table.insert(initialPlotRarities, name) end
    end
    if #initialPlotRarities == 0 then table.insert(initialPlotRarities, "All") end
    plotRarityDropdown:SetValue(initialPlotRarities)

    placeGroup:AddInput("Min Weight To Place", {
        Text = "Min Weight",
        Default = tostring(PlotCfg.minWeight),
        Placeholder = "0 = place all",
        Finished = true,
        Callback = function(text)
            local num = tonumber(text)
            if num then PlotCfg.minWeight = math.max(0, num) end
            applyAndSave()
        end
    })

    placeGroup:AddDivider()

    placeGroup:AddToggle("Auto Place Eggs", {
        Text = "Auto Place",
        Default = PlotCfg.autoPlace,
        Callback = function(v)
            PlotCfg.autoPlace = v
            PlotRuntime.placeGeneration = PlotRuntime.placeGeneration + 1
            PlotRuntime.placeOwner = nil
            if v and not PlotRuntime.placing and not Cfg.autoFarm then
                task.spawn(doPlotPlaceLoop)
            elseif not v then
                UpdatePlotStatus("Idle")
            end
            applyAndSave()
        end
    })

    placeGroup:AddButton("Place Eggs Now", function()
        if Cfg.autoFarm then
            Notify("Stop Auto Farm before manual Plot placement.", 3)
            return
        end
        PlotRuntime.placeGeneration = PlotRuntime.placeGeneration + 1
        local manualGeneration = PlotRuntime.placeGeneration
        local ok = doPlotPlaceOnce("manual", manualGeneration)
        Notify(ok and "Placed eggs successfully!" or "Could not place (full / none)", 3)
    end)

    placeGroup:AddButton("Reset Placed Counter", function()
        PlotRuntime.placedCount = 0
        UpdatePlotStatus(PlotRuntime.statusText)
        Notify("Plot counter reset", 2)
    end)

    -- Hatch sub-tab
    local hatchGroup = HatchSub:AddLeftGroupbox("Hatch Settings", "egg")
    hatchGroup:AddToggle("Auto Hatch Eggs", {
        Text = "Auto Hatch",
        Default = PlotCfg.autoHatch,
        Callback = function(v)
            PlotCfg.autoHatch = v
            if v and not PlotRuntime.hatching then task.spawn(doHatchLoop) end
            applyAndSave()
        end
    })

    -- ------------------------------------------------------------------
    -- TAB: SHOP
    -- ------------------------------------------------------------------
    local ShopTab = Window:AddTab("Shop", "store")
    local SellSub = ShopTab:AddSubTab("Sell", "dollar")
    local UpgradeSub = ShopTab:AddSubTab("Upgrade", "arrow-up")
    local FuseSub = ShopTab:AddSubTab("Fuse", "merge")

    -- Sell sub-tab
    local sellGroup = SellSub:AddLeftGroupbox("Auto Sell", "dollar")

    -- Egg rarity to sell (multi-select with default None)
    local eggSellDropdown = sellGroup:AddDropdown("Egg Rarity to Sell", {
        Text = "Egg Rarity",
        Values = SELL_RARITIES,
        Multi = true,
        Searchable = true,
        Callback = function(value)
            local newTbl = {}
            for _, v in ipairs(value) do newTbl[v] = true end
            ShopCfg.sellEggRarities = newTbl
            applyAndSave()
        end
    })
    -- Set initial: if empty, select "None" (we'll add "None" as option? Actually we can treat empty as None)
    local initialSellEgg = {}
    for i, name in ipairs(SELL_RARITIES) do
        if ShopCfg.sellEggRarities[name] then table.insert(initialSellEgg, name) end
    end
    eggSellDropdown:SetValue(initialSellEgg) -- if empty, shows none selected

    local petSellDropdown = sellGroup:AddDropdown("Pet Rarity to Sell", {
        Text = "Pet Rarity",
        Values = SELL_RARITIES,
        Multi = true,
        Searchable = true,
        Callback = function(value)
            local newTbl = {}
            for _, v in ipairs(value) do newTbl[v] = true end
            ShopCfg.sellPetRarities = newTbl
            applyAndSave()
        end
    })
    local initialSellPet = {}
    for i, name in ipairs(SELL_RARITIES) do
        if ShopCfg.sellPetRarities[name] then table.insert(initialSellPet, name) end
    end
    petSellDropdown:SetValue(initialSellPet)

    sellGroup:AddToggle("Auto Sell (aktif saat farm)", {
        Text = "Auto Sell",
        Default = ShopCfg.autoSellAll,
        Callback = function(v)
            ShopCfg.autoSellAll = v
            applyAndSave()
        end
    })

    sellGroup:AddButton("Sell Now", function()
        task.spawn(doSellCycle)
        Notify("Sell cycle started!", 2)
    end)

    -- Upgrade sub-tab
    local upgradeGroup = UpgradeSub:AddLeftGroupbox("Auto Upgrade", "arrow-up")
    upgradeGroup:AddToggle("Auto Upgrade Plot", {
        Text = "Upgrade Plot",
        Default = ShopCfg.autoUpgradePlot,
        Callback = function(v)
            ShopCfg.autoUpgradePlot = v
            applyAndSave()
        end
    })
    upgradeGroup:AddToggle("Auto Upgrade Treadmill", {
        Text = "Upgrade Treadmill",
        Default = ShopCfg.autoUpgradeTread,
        Callback = function(v)
            ShopCfg.autoUpgradeTread = v
            applyAndSave()
        end
    })

    -- Fuse sub-tab
    local fuseGroup = FuseSub:AddLeftGroupbox("Auto Fuse", "merge")
    -- We'll get fuse options dynamically
    local fuseOptions, _ = getFusePetOptions()
    local fuseDropdown = fuseGroup:AddDropdown("Select Pet To Fuse", {
        Text = "Pet",
        Values = fuseOptions,
        Default = ShopCfg.selectedPetFuse ~= "" and ShopCfg.selectedPetFuse or "None",
        Callback = function(v)
            ShopCfg.selectedPetFuse = v
            applyAndSave()
        end
    })

    fuseGroup:AddToggle("Auto Fuse", {
        Text = "Fuse Pet",
        Default = ShopCfg.autoFuse,
        Callback = function(v)
            ShopCfg.autoFuse = v
            if v then
                local ok, msg = doFuseOnce()
                Notify(msg or (ok and "Fusing..." or "Fuse failed"), 3)
            end
            applyAndSave()
        end
    })

    -- Refresh fuse options periodically
    task.spawn(function()
        while true do
            task.wait(15)
            local newOpts, _ = getFusePetOptions()
            fuseDropdown:Refresh(newOpts, ShopCfg.selectedPetFuse)
        end
    end)

    -- ------------------------------------------------------------------
    -- TAB: MISC
    -- ------------------------------------------------------------------
    local MiscTab = Window:AddTab("Misc", "settings")
    local PerfSub = MiscTab:AddSubTab("Performance", "gauge")
    local HopSub = MiscTab:AddSubTab("Server Hop", "rocket")

    -- Performance sub-tab
    local perfGroup = PerfSub:AddLeftGroupbox("Performance", "gauge")
    perfGroup:AddToggle("FPS Boost", {
        Text = "FPS Boost",
        Default = MiscCfg.fpsBoost,
        Callback = function(v)
            MiscCfg.fpsBoost = v
            applyFpsBoost(v)
            applyAndSave()
        end
    })
    perfGroup:AddToggle("Ultra FPS Boost", {
        Text = "Ultra FPS Boost (Invisible Parts)",
        Default = MiscCfg.ultraFps,
        Callback = function(v)
            MiscCfg.ultraFps = v
            applyUltraFps(v)
            applyAndSave()
        end
    })

    -- Server Hop sub-tab
    local hopGroup = HopSub:AddLeftGroupbox("Server Hop", "rocket")
    hopGroup:AddSlider("Hop Delay (Minutes)", {
        Text = "Delay",
        Default = MiscCfg.hopDelay,
        Min = 1,
        Max = 120,
        Rounding = 0,
        Callback = function(v)
            MiscCfg.hopDelay = v
            applyAndSave()
        end
    })

    hopGroup:AddDropdown("Hop Method", {
        Text = "Method",
        Values = {"Small Server", "Random Server"},
        Default = MiscCfg.hopMethod,
        Callback = function(v)
            MiscCfg.hopMethod = v
            applyAndSave()
        end
    })

    hopGroup:AddToggle("Auto Hop Server", {
        Text = "Auto Hop",
        Default = MiscCfg.autoHop,
        Callback = function(v)
            MiscCfg.autoHop = v
            if v then HopState.lastHopCheck = tick() end
            applyAndSave()
        end
    })

    hopGroup:AddButton("Hop Now", function()
        Notify("Hopping to another server...", 3)
        task.delay(1, function()
            executeServerHop(MiscCfg.hopMethod)
        end)
    end)

    -- ------------------------------------------------------------------
    -- TAB: INFO
    -- ------------------------------------------------------------------
    local InfoTab = Window:AddTab("Info", "info")
    local infoGroup = InfoTab:AddLeftGroupbox("About", "info")
    infoGroup:AddLabel("ASTRO - Steal An Egg", true)
    infoGroup:AddLabel("Version 2.1")
    infoGroup:AddLabel("TPWalk: Infinite Yield TranslateBy Engine")
    infoGroup:AddLabel("Sell Egg: WearEggTool → SellPet")
    infoGroup:AddLabel("Sell Pet: SellEveryPet (batch)")
    infoGroup:AddLabel("PlaceId: " .. PLACE_ID)
    infoGroup:AddLabel("Player: " .. LP.Name .. " (" .. LP.UserId .. ")")
    infoGroup:AddLabel("Safezone: 512, 68, -363")
    infoGroup:AddLabel("Scan Chunk: " .. SCAN_CHUNK_SIZE .. " eggs/frame")
    infoGroup:AddLabel("Plot Grid: " .. PLOT_GRID_COLS .. "x" .. PLOT_GRID_ROWS .. " @ " .. PLOT_GRID_SPACING .. " spacing")

    -- ------------------------------------------------------------------
    -- SETTINGS TAB (Theme & Config)
    -- ------------------------------------------------------------------
    local SettingsTab = Window:AddTab("Settings", "settings")
    local ThemeSub = SettingsTab:AddSubTab("Theme", "paintbrush")
    local ConfigSub = SettingsTab:AddSubTab("Config", "folder")

    ThemeManager:ApplyToTab(ThemeSub)
    SaveManager:SetFolder("ASTRO")
    SaveManager:SetSubFolder(tostring(PLACE_ID))
    SaveManager:BuildConfigSection(ConfigSub)
    SaveManager:LoadAutoloadConfig()

    -- Set toggle keybind
    Library.ToggleKeybind = Enum.KeyCode.LeftAlt

    -- Notify start
    Notify("ASTRO Loaded!", 3)
end

-- ============================================================
-- [21] LAUNCH
-- ============================================================
task.spawn(function()
    task.wait(0.5)
    ensureCharacter(5)
    if Cfg.instantSteal then applyInstantToAll() end
    if Cfg.autoFarm and not Runtime.farming then task.spawn(doFarmLoop) end
    if PlotCfg.autoPlace and not PlotRuntime.placing and not Cfg.autoFarm then task.spawn(doPlotPlaceLoop) end
    if PlotCfg.autoHatch and not PlotRuntime.hatching then task.spawn(doHatchLoop) end
    if MiscCfg.fpsBoost then applyFpsBoost(true) end
    if MiscCfg.ultraFps then applyUltraFps(true) end
    if ShopCfg.autoSellAll then task.spawn(function() task.wait(0.5); doSellCycle() end) end
    if ShopCfg.autoFuse then task.spawn(function() task.wait(0.5); doFuseOnce() end) end
end)

buildUI()