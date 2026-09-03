print("[ASTRO] Loading Dupe Edition...")

-- FALLBACK UNTUK FUNGSI EXPLOIT (CEGAH ERROR)
local function ensureFunction(name)
    if type(_G[name]) ~= "function" then
        _G[name] = function(...) 
            warn("[ASTRO] Function " .. name .. " not available, using dummy")
            return nil 
        end
    end
end

-- Fungsi exploit yang umum digunakan
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
ensureFunction("keypress")
ensureFunction("keyrelease")

-- Drawing fallback (untuk FOV circles dll)
if type(Drawing) ~= "table" then
    Drawing = {}
    function Drawing.new(class)
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

-- ============================================================
-- LOAD LIBRARY DENGAN RETRY
-- ============================================================
local Library = nil
local SaveManager = nil
local ThemeManager = nil

local function loadWithRetry(url, maxRetry)
    maxRetry = maxRetry or 5
    for i = 1, maxRetry do
        local success, result = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        if success and result then
            return result
        end
        print("[ASTRO] Retry load " .. url .. " (" .. i .. "/" .. maxRetry .. ")")
        task.wait(2)
    end
    return nil
end

print("[ASTRO] Loading Library...")
Library = loadWithRetry("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/Library.lua")
if not Library then
    error("[ASTRO] Library gagal dimuat! Periksa koneksi internet.")
end

print("[ASTRO] Loading SaveManager...")
SaveManager = loadWithRetry("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/addons/SaveManager.lua")

print("[ASTRO] Loading ThemeManager...")
ThemeManager = loadWithRetry("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/addons/ThemeManager.lua")

-- ============================================================
-- ASTRO CORE
-- ============================================================
local ASTRO = {
    Name = "ASTRO Dupe",
    SubName = "Mine a Mountain",
    Version = "6.0.0",
    Loaded = false,
    Library = Library,
    SaveManager = SaveManager,
    ThemeManager = ThemeManager,
    Window = nil,
    Tabs = {},
    Options = {},
    Toggles = {},
    Unloaded = false,
    -- ===== KONFIGURASI (SEMUA FITUR) =====
    Config = {
        -- Drop Selection
        selectedCrystals = {},
        selectedRunes = {},
        selectedRarities = {},
        selectedRunesToCollect = {},
        kickDropMethod = "Drop Only",
        isAutoDropOnKick = false,
        crystalDropAmount = nil,
        runeDropAmount = nil,
        -- Auto Collect
        isAutoCollect = false,
        collectRadius = 100,
        -- Rejoin
        isAutoRejoin = false,
        rejoinDelay = 5,
        rejoinMethod = "Current Server",
        privateServerLink = "",
        -- Spoofers
        deviceSpoof = false,
        deviceTarget = "Controller",
        nameSpoof = false,
        spoofedName = "ZytheraX",
        nameSpoofMode = "Both",
        nameSpoofBadge = true,
        levelSpoof = false,
        levelVal = 996,
        winstreakSpoof = false,
        winstreakVal = 56,
        -- Auto Weapon Pick
        autoWeapon = false,
        weaponSlots = {},
        -- Proximity
        proximity = false,
        proximityDistance = 30,
        -- Anti AFK
        antiAFK = false,
    },
    State = {
        connectionTriggered = false,
        scanRuneLock = false,
        lastRuneScanTime = 0,
        crystalDropCache = {},
        runeDropCache = {},
        crystalOptions = {},
        runeOptions = {},
        collectRuneOptions = {},
        rarityList = {"Common","Uncommon","Rare","Epic","Legendary","Mythic","Empyrean","Pulsar","Quasar"},
        dropRemote = nil,
        holdRemote = nil,
        deviceSpoofLoop = nil,
        levelSpoofLoop = nil,
        antiAFKConn = nil,
        proximityLastAlert = 0,
        autoWeaponLoop = nil,
    },
}

-- ============================================================
-- SERVICES
-- ============================================================
local lp = game:GetService("Players").LocalPlayer
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TCS = game:GetService("TextChatService")
local VU = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")

-- ============================================================
-- NOTIFIKASI
-- ============================================================
local function Notify(text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "ASTRO Dupe",
            Description = tostring(text),
            Duration = duration or 3
        })
    end)
    if ASTRO.Library and ASTRO.Library.Notify then
        ASTRO.Library:Notify({ Title = "ASTRO", Description = text, Time = duration or 3 })
    end
end

-- ============================================================
-- DETEKSI CRYSTAL & RUNE
-- ============================================================
local function isCrystalTool(child)
    if not child:IsA("Tool") then return false end
    return child:GetAttribute("CrystalName") ~= nil
        or child:GetAttribute("Tier") ~= nil
        or child.Name:find("Crystal") ~= nil
end

local function isRuneTool(child)
    if not child:IsA("Tool") then return false end
    return child:GetAttribute("RuneId") ~= nil
        or child:GetAttribute("RuneName") ~= nil
        or child:GetAttribute("IsRune") == true
        or child.Name:find("Rune", 1, true) ~= nil
end

-- ============================================================
-- REMOTES
-- ============================================================
local function getDropRemote()
    if ASTRO.State.dropRemote and ASTRO.State.dropRemote.Parent then
        return ASTRO.State.dropRemote
    end
    local r = RS:FindFirstChild("Remotes")
    ASTRO.State.dropRemote = r and r:FindFirstChild("CrystalDropRequest")
    return ASTRO.State.dropRemote
end

local function getHoldRemote()
    if ASTRO.State.holdRemote and ASTRO.State.holdRemote.Parent then
        return ASTRO.State.holdRemote
    end
    local r = RS:FindFirstChild("Remotes")
    ASTRO.State.holdRemote = r and r:FindFirstChild("CrystalHoldComplete")
    return ASTRO.State.holdRemote
end

-- ============================================================
== - BACA JUMLAH ITEM
-- ============================================================
local function readCountFromAttr(tool)
    local attrNames = {"Amount","Count","UsesLeft","Stack","Quantity","StackSize","Uses","Charges","Stacks"}
    for _, attr in ipairs(attrNames) do
        local val = tool:GetAttribute(attr)
        if type(val) == "number" and val > 0 then return math.floor(val) end
    end
    return nil
end

local function readCountFromUI()
    local playerGui = lp:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return nil end
    local function searchLabels(parent, depth)
        if depth > 6 then return nil end
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("TextLabel") then
                local lname = child.Name:lower()
                if lname:find("uses") or lname:find("count")
                    or lname:find("amount") or lname:find("stack") then
                    local num = tonumber(child.Text)
                    if num and num > 0 then return math.floor(num) end
                end
            end
            local found = searchLabels(child, depth + 1)
            if found then return found end
        end
        return nil
    end
    return searchLabels(playerGui, 0)
end

-- ============================================================
-- RARITY DETECTION (FIXED)
-- ============================================================
local function getCrystalRarity(obj)
    local function checkAttrs(inst)
        if not inst then return nil end
        for _, attr in ipairs({"TierName", "RarityName", "Rarity", "Tier"}) do
            local val = inst:GetAttribute(attr)
            if val ~= nil then
                if type(val) == "string" and val ~= "" then return val
                elseif type(val) == "number" and val > 0 then
                    local list = ASTRO.State.rarityList
                    if val <= #list then return list[val]
                end
            end
        end
        return nil
    end

    local rarity = checkAttrs(obj)
    if rarity then return rarity end
    local parent = obj.Parent
    if parent and parent:IsA("Model") then
        rarity = checkAttrs(parent)
        if rarity then return rarity end
    end
    return nil
end

local function rarityAllowed(obj)
    local selected = ASTRO.Config.selectedRarities
    if #selected == 0 then return true end
    local r = getCrystalRarity(obj)
    if not r then return false end
    for _, s in ipairs(selected) do
        if s == r then return true end
    end
    return false
end

-- ============================================================
== - PICKUP FUNCTION
-- ============================================================
local function fireCrystalPickup(part)
    local hold = getHoldRemote()
    if hold then pcall(function() hold:FireServer(part) end) end
    local prompt = part:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        pcall(function()
            prompt.HoldDuration = 0
            prompt.RequiresLineOfSight = false
            prompt.Enabled = true
            prompt.MaxActivationDistance = 9999
        end)
        if typeof(fireproximityprompt) == "function" then
            pcall(function() fireproximityprompt(prompt, 1) end)
            pcall(function() fireproximityprompt(prompt, 0) end)
        end
        pcall(function() prompt:InputHoldBegin(); prompt:InputHoldEnd() end)
    end
    local det = part:FindFirstChildWhichIsA("ClickDetector", true)
    if det and typeof(fireclickdetector) == "function" then
        pcall(function() fireclickdetector(det, 0) end)
    end
end

local function fireRunePickup(obj)
    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
        or (obj:IsA("BasePart") and obj:FindFirstChildOfClass("ProximityPrompt"))
    if prompt then
        pcall(function()
            prompt.HoldDuration = 0
            prompt.RequiresLineOfSight = false
            prompt.Enabled = true
            prompt.MaxActivationDistance = 9999
        end)
        if typeof(fireproximityprompt) == "function" then
            pcall(function() fireproximityprompt(prompt, 1) end)
            pcall(function() fireproximityprompt(prompt, 0) end)
        end
        pcall(function() prompt:InputHoldBegin(); prompt:InputHoldEnd() end)
    end
    local hold = getHoldRemote()
    if hold then
        if obj:IsA("BasePart") then
            pcall(function() hold:FireServer(obj) end)
        else
            local part = obj:FindFirstChildWhichIsA("BasePart", true)
            if part then pcall(function() hold:FireServer(part) end) end
        end
    end
end

-- ============================================================
-- SCAN FUNCTIONS
-- ============================================================
local function scanInventory()
    table.clear(ASTRO.State.crystalOptions)
    table.clear(ASTRO.State.runeOptions)
    table.clear(ASTRO.State.collectRuneOptions)
    local crystalMap, runeMap = {}, {}

    local function checkItem(child)
        if isRuneTool(child) then
            if not runeMap[child.Name] then
                runeMap[child.Name] = true
                table.insert(ASTRO.State.runeOptions, child.Name)
                table.insert(ASTRO.State.collectRuneOptions, child.Name)
            end
        elseif isCrystalTool(child) then
            if not crystalMap[child.Name] then
                crystalMap[child.Name] = true
                table.insert(ASTRO.State.crystalOptions, child.Name)
            end
        end
    end

    local bp = lp:FindFirstChildOfClass("Backpack")
    if bp then for _, c in ipairs(bp:GetChildren()) do checkItem(c) end end
    local char = lp.Character
    if char then for _, c in ipairs(char:GetChildren()) do checkItem(c) end end

    table.sort(ASTRO.State.crystalOptions)
    table.sort(ASTRO.State.runeOptions)
    table.sort(ASTRO.State.collectRuneOptions)
end

local function buildCrystalCache()
    table.clear(ASTRO.State.crystalDropCache)
    local config = ASTRO.Config
    if #config.selectedCrystals == 0 then return end

    local targetSet = {}
    for _, name in ipairs(config.selectedCrystals) do targetSet[name] = true end

    local function countFrom(container)
        if not container then return end
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Tool") and isCrystalTool(child) and targetSet[child.Name] then
                ASTRO.State.crystalDropCache[child.Name] = (ASTRO.State.crystalDropCache[child.Name] or 0) + 1
            end
        end
    end

    countFrom(lp:FindFirstChildOfClass("Backpack"))
    countFrom(lp.Character)
end

local function buildRuneCache()
    local state = ASTRO.State
    local config = ASTRO.Config
    local now = os.clock()

    if state.scanRuneLock or (now - state.lastRuneScanTime) < 3 then return end
    state.scanRuneLock = true
    table.clear(state.runeDropCache)

    if #config.selectedRunes == 0 then
        state.scanRuneLock = false
        return
    end

    task.spawn(function()
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local bp = lp:FindFirstChildOfClass("Backpack")
        local targetSet = {}
        for _, name in ipairs(config.selectedRunes) do targetSet[name] = true end
        local toolsToScan = {}

        local function collectFrom(container)
            if not container then return end
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("Tool") and isRuneTool(child)
                    and targetSet[child.Name]
                    and not toolsToScan[child.Name] then
                    toolsToScan[child.Name] = child
                end
            end
        end

        collectFrom(bp)
        collectFrom(char)

        for runeName, runeTool in pairs(toolsToScan) do
            local count = readCountFromAttr(runeTool)
            if count then
                state.runeDropCache[runeName] = count
            elseif hum then
                pcall(function() hum:EquipTool(runeTool) end)
                task.wait(0.15)
                local uiCount = readCountFromUI()
                state.runeDropCache[runeName] = uiCount or 1
                pcall(function() hum:UnequipTools() end)
                task.wait(0.05)
            else
                state.runeDropCache[runeName] = 1
            end
        end

        state.lastRuneScanTime = os.clock()
        state.scanRuneLock = false
    end)
end

local function buildAllCache()
    buildCrystalCache()
    buildRuneCache()
end

-- ============================================================
-- EXECUTE DROP
-- ============================================================
local function executeDropItems()
    local remote = getDropRemote()
    if not remote then return end
    local state = ASTRO.State
    local config = ASTRO.Config

    local hasCrystal = next(state.crystalDropCache) ~= nil
    local hasRune = next(state.runeDropCache) ~= nil
    if not hasCrystal and not hasRune then return end

    local cAmt = config.crystalDropAmount
    local rAmt = config.runeDropAmount

    if hasCrystal then
        task.spawn(function()
            for crystalName, count in pairs(state.crystalDropCache) do
                local willDrop = cAmt and math.min(count, cAmt) or count
                for i = 1, willDrop do
                    pcall(function() remote:FireServer(crystalName) end)
                end
            end
        end)
    end

    if hasRune then
        task.spawn(function()
            for runeName, count in pairs(state.runeDropCache) do
                local willDrop = rAmt and math.min(count, rAmt) or count
                for i = 1, willDrop do
                    pcall(function() remote:FireServer(runeName) end)
                end
            end
        end)
    end
end

-- ============================================================
-- REJOIN HANDLER
-- ============================================================
local function handleRejoin()
    local config = ASTRO.Config
    if not config.isAutoRejoin then return end

    task.spawn(function()
        task.wait(config.rejoinDelay)
        while task.wait(3) do
            if config.rejoinMethod == "Current Server" then
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
                end)
            elseif config.rejoinMethod == "Random Server" then
                pcall(function() TeleportService:Teleport(game.PlaceId, lp) end)
            elseif config.rejoinMethod == "Private Server Link" then
                if config.privateServerLink ~= "" then
                    local code = config.privateServerLink:match("privateServerLinkCode=([^&]+)")
                    if code then
                        pcall(function()
                            TeleportService:TeleportToPrivateServer(game.PlaceId, code, {lp})
                        end)
                    else
                        pcall(function()
                            TeleportService:TeleportToPrivateServer(game.PlaceId, config.privateServerLink, {lp})
                        end)
                    end
                end
            end
        end
    end)
end

-- ============================================================
-- KICK DETECTION
-- ============================================================
local function triggerDropAndRejoin()
    if ASTRO.State.connectionTriggered then return end
    ASTRO.State.connectionTriggered = true

    local config = ASTRO.Config
    if config.isAutoDropOnKick then
        if config.kickDropMethod == "Reset Then Drop" then
            executeDropItems()
            local char = lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum.Health = 0 end) end
        else
            executeDropItems()
        end
    end
    handleRejoin()
end

local function setupKickListeners()
    GuiService.ErrorMessageChanged:Connect(function()
        local ok, msg = pcall(function() return GuiService:GetErrorMessage() end)
        if not ok or type(msg) ~= "string" or msg == "" then return end
        msg = msg:lower()
        if msg:find("same account") or msg:find("another device")
            or msg:find("profile session") or msg:find("please rejoin")
            or msg:find("error code: 267") or msg:find("(267)") then
            triggerDropAndRejoin()
        end
    end)

    task.spawn(function()
        while not ASTRO.Unloaded do
            if ASTRO.State.connectionTriggered then break end
            pcall(function()
                local promptGui = CoreGui:FindFirstChild("RobloxPromptGui")
                if promptGui then
                    local overlay = promptGui:FindFirstChild("promptOverlay")
                    if overlay then
                        for _, child in ipairs(overlay:GetChildren()) do
                            if child.Name:find("ErrorPrompt") then
                                for _, label in ipairs(child:GetDescendants()) do
                                    if label:IsA("TextLabel") then
                                        local text = label.Text:lower()
                                        if text:find("profile session") or text:find("please rejoin")
                                            or text:find("267") or text:find("same account")
                                            or text:find("another device") then
                                            triggerDropAndRejoin(); return
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                for _, child in ipairs(CoreGui:GetChildren()) do
                    if child:IsA("ScreenGui") and child.Enabled then
                        local lname = child.Name:lower()
                        if lname:find("disconnect") or lname:find("error") then
                            for _, label in ipairs(child:GetDescendants()) do
                                if label:IsA("TextLabel") then
                                    local text = label.Text:lower()
                                    if text:find("profile session") or text:find("please rejoin")
                                        or text:find("267") or text:find("same account")
                                        or text:find("another device") then
                                        triggerDropAndRejoin(); return
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
end

-- ============================================================
-- AUTO COLLECT LOOP
-- ============================================================
local function startAutoCollectLoop()
    task.spawn(function()
        while not ASTRO.Unloaded do
            task.wait(0.25)
            if not ASTRO.Config.isAutoCollect then continue end

            local char = lp.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            local containers = {Workspace}
            local dropped = Workspace:FindFirstChild("DroppedCrystals") or Workspace:FindFirstChild("Crystals")
            if dropped then table.insert(containers, dropped) end
            local things = Workspace:FindFirstChild("Things")
            if things then
                local dc = things:FindFirstChild("DroppedCrystals") or things:FindFirstChild("Crystals")
                if dc then table.insert(containers, dc) end
            end

            local radius = ASTRO.Config.collectRadius or 100

            for _, container in ipairs(containers) do
                for _, child in ipairs(container:GetChildren()) do
                    if not ASTRO.Config.isAutoCollect then break end
                    if not child:IsA("BasePart") then continue end
                    local isValid = child:GetAttribute("Value") ~= nil
                        and (child:GetAttribute("CrystalName") ~= nil or child:GetAttribute("Tier") ~= nil)
                    if not isValid then continue end
                    if child:GetAttribute("Collected") == true then continue end
                    if not rarityAllowed(child) then continue end
                    local dist = (child.Position - root.Position).Magnitude
                    if dist > radius then continue end
                    root.CFrame = CFrame.new(child.Position + Vector3.new(0, 3, 0))
                    task.wait(0.05)
                    fireCrystalPickup(child)
                    task.wait(0.1)
                end
            end

            if not ASTRO.Config.isAutoCollect then continue end

            local runeContainers = {}
            local droppedRunes = Workspace:FindFirstChild("DroppedRunes")
            if droppedRunes then table.insert(runeContainers, droppedRunes) end
            if things then
                local dr = things:FindFirstChild("DroppedRunes")
                if dr then table.insert(runeContainers, dr) end
            end
            if #runeContainers == 0 then table.insert(runeContainers, Workspace) end

            for _, container in ipairs(runeContainers) do
                for _, obj in ipairs(container:GetChildren()) do
                    if not ASTRO.Config.isAutoCollect then break end
                    if not isRuneInWorld(obj) then continue end
                    if not runeNameAllowed(obj) then continue end
                    local pos = nil
                    if obj:IsA("BasePart") then pos = obj.Position
                    elseif obj:IsA("Model") then
                        local pp = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                        if pp then pos = pp.Position end
                    end
                    if not pos then continue end
                    local dist = (pos - root.Position).Magnitude
                    if dist > radius then continue end
                    root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                    task.wait(0.05)
                    fireRunePickup(obj)
                    task.wait(0.1)
                end
            end
        end
    end)
end

-- ============================================================
-- DEVICE SPOOFER
-- ============================================================
local deviceMap = { Controller = "Gamepad", PC = "MouseKeyboard", Mobile = "Touch", VR = "VR" }

local function spoofDevice()
    if not ASTRO.Config.deviceSpoof then return end
    local target = deviceMap[ASTRO.Config.deviceTarget] or "Gamepad"
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

local function startDeviceSpoofLoop()
    if ASTRO.State.deviceSpoofLoop then return end
    ASTRO.State.deviceSpoofLoop = task.spawn(function()
        while not ASTRO.Unloaded do
            if ASTRO.Config.deviceSpoof then spoofDevice() end
            task.wait(5)
        end
    end)
end

-- ============================================================
-- NAME SPOOFER
-- ============================================================
local function spoofNameText(obj)
    if not obj or not obj.Text then return end
    local config = ASTRO.Config
    if not config.nameSpoof then return end
    local realName = lp.Name
    local realDisplay = lp.DisplayName
    local spoofedName = config.spoofedName
    local badge = config.nameSpoofBadge and " ✓" or ""
    local targetDisplay = spoofedName .. badge

    local text = obj.Text
    local newText = text
    if config.nameSpoofMode == "Name" or config.nameSpoofMode == "Both" then
        newText = newText:gsub(realName, spoofedName)
    end
    if config.nameSpoofMode == "DisplayName" or config.nameSpoofMode == "Both" then
        newText = newText:gsub(realDisplay, targetDisplay)
    end
    if newText ~= text then obj.Text = newText
end

local function hookNameSpoof(gui)
    for _, child in ipairs(gui:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            spoofNameText(child)
            child:GetPropertyChangedSignal("Text"):Connect(function()
                if ASTRO.Config.nameSpoof then spoofNameText(child) end
            end)
        end
    end
    gui.DescendantAdded:Connect(function(obj)
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            task.wait(0.1)
            spoofNameText(obj)
            obj:GetPropertyChangedSignal("Text"):Connect(function()
                if ASTRO.Config.nameSpoof then spoofNameText(obj) end
            end)
        end
    end)
end

local function startNameSpoof()
    local playerGui = lp:WaitForChild("PlayerGui")
    hookNameSpoof(playerGui)
    hookNameSpoof(CoreGui)

    Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("BillboardGui") then
            task.wait(0.5)
            for _, txt in ipairs(obj:GetDescendants()) do
                if txt:IsA("TextLabel") then
                    spoofNameText(txt)
                    txt:GetPropertyChangedSignal("Text"):Connect(function()
                        if ASTRO.Config.nameSpoof then spoofNameText(txt) end
                    end)
                end
            end
        end
    end)

    if TCS.ChatVersion == Enum.ChatVersion.TextChatService then
        TCS.OnIncomingMessage = function(message)
            if not ASTRO.Config.nameSpoof then return nil end
            local props = Instance.new("TextChatMessageProperties")
            if message.TextSource and message.TextSource.UserId == lp.UserId then
                local badge = ASTRO.Config.nameSpoofBadge and " ✓" or ""
                props.PrefixText = ASTRO.Config.spoofedName .. badge
            end
            return props
        end
    end

    lp.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and ASTRO.Config.nameSpoof then
            local badge = ASTRO.Config.nameSpoofBadge and " ✓" or ""
            hum.DisplayName = ASTRO.Config.spoofedName .. badge
            hum:GetPropertyChangedSignal("DisplayName"):Connect(function()
                if ASTRO.Config.nameSpoof then
                    local b2 = ASTRO.Config.nameSpoofBadge and " ✓" or ""
                    hum.DisplayName = ASTRO.Config.spoofedName .. b2
                end
            end)
        end
    end)
end

-- ============================================================
-- LEVEL & WINSTREAK SPOOFER
-- ============================================================
local function spoofLevelStats()
    local leaderstats = lp:FindFirstChild("CustomLeaderstats")
    if not leaderstats then return
    if ASTRO.Config.levelSpoof then
        local levelVal = leaderstats:FindFirstChild("Level")
        if levelVal and levelVal:IsA("IntValue") then levelVal.Value = ASTRO.Config.levelVal
        pcall(function() lp:SetAttribute("Level", ASTRO.Config.levelVal) end)
    end
    if ASTRO.Config.winstreakSpoof then
        local streakFolder = leaderstats:FindFirstChild("Win Streak")
        if streakFolder then
            local sv = streakFolder:FindFirstChildWhichIsA("IntValue")
            if sv then sv.Value = ASTRO.Config.winstreakVal
        end
        pcall(function() lp:SetAttribute("StatisticDuelsWinStreak", ASTRO.Config.winstreakVal) end)
    end
end

local function startLevelSpoofLoop()
    if ASTRO.State.levelSpoofLoop then return end
    ASTRO.State.levelSpoofLoop = task.spawn(function()
        while not ASTRO.Unloaded do
            if ASTRO.Config.levelSpoof or ASTRO.Config.winstreakSpoof then spoofLevelStats() end
            task.wait(3)
        end
    end)
end

-- ============================================================
-- AUTO WEAPON PICK
-- ============================================================
local function autoWeaponPick()
    if not ASTRO.Config.autoWeapon then return end
    local pickRemote = nil
    local prePickRemote = nil
    pcall(function()
        pickRemote = RS.Remotes.Replication.Fighter.PickWeapons
        prePickRemote = RS.Remotes.Duels.PickWeaponsAheadOfTime
    end)
    if not pickRemote then return end

    local payload = {}
    for i = 1, 4 do
        local slot = ASTRO.Config.weaponSlots[i]
        if slot and slot ~= "" then payload[i] = slot end
    end
    if not next(payload) then return end

    local pg = lp:FindFirstChildOfClass("PlayerGui")
    local pickUI = pg and pg:FindFirstChild("PickWeapons", true)
    if pickUI and pickUI.Visible then
        pcall(function() pickRemote:FireServer(payload) end)
        pcall(function() prePickRemote:FireServer(payload) end)
    end
end

local function startAutoWeaponLoop()
    if ASTRO.State.autoWeaponLoop then return end
    ASTRO.State.autoWeaponLoop = task.spawn(function()
        while not ASTRO.Unloaded do
            if ASTRO.Config.autoWeapon then autoWeaponPick() end
            task.wait(0.1)
        end
    end)
end

-- ============================================================
-- PROXIMITY ALERT
-- ============================================================
local function startProximityLoop()
    task.spawn(function()
        while not ASTRO.Unloaded do
            if ASTRO.Config.proximity then
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
                                    if dist <= ASTRO.Config.proximityDistance and tick() - ASTRO.State.proximityLastAlert > 3 then
                                        ASTRO.State.proximityLastAlert = tick()
                                        Notify(p.Name .. " is " .. math.floor(dist) .. " studs away!", 3)
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
local function startAntiAFK()
    if ASTRO.State.antiAFKConn then return end
    ASTRO.State.antiAFKConn = task.spawn(function()
        while not ASTRO.Unloaded do
            if ASTRO.Config.antiAFK then
                pcall(function()
                    VU:CaptureController()
                    VU:ClickButton2(Vector2.zero)
                end)
                task.wait(60)
            else
                task.wait(1)
            end
        end
    end)
end

-- ============================================================
-- CLAIM REWARDS & REDEEM CODES
-- ============================================================
local function claimAllRewards()
    local remotes = RS:FindFirstChild("Remotes")
    if not remotes then Notify("Remotes not found!"); return end
    local data = remotes:FindFirstChild("Data")
    if not data then Notify("Data remotes not found!"); return end
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
    Notify("Claimed " .. claimed .. " rewards!", 4)
end

local function redeemAllCodes()
    local remotes = RS:FindFirstChild("Remotes")
    if not remotes then Notify("Remotes not found!"); return end
    local data = remotes:FindFirstChild("Data")
    if not data then Notify("Data remotes not found!"); return end
    local redeem = data:FindFirstChild("RedeemCode")
    if not redeem then Notify("RedeemCode not found!"); return end
    local codes = {"COMMUNITY19", "FREE131", "BONUS", "ROBLOX_RTC", "BOOST"}
    local count = 0
    for _, code in ipairs(codes) do
        pcall(function() redeem:InvokeServer(code); count = count + 1; task.wait(0.3) end)
    end
    Notify("Tried " .. count .. " codes!", 4)
end

-- ============================================================
-- SETUP THEME
-- ============================================================
local function SetupTheme()
    if ASTRO.ThemeManager then
        ASTRO.ThemeManager:SetLibrary(ASTRO.Library)
        ASTRO.ThemeManager:SetDefaultTheme({
            FontColor = "ffffff",
            MainColor = "0d0d0d",
            AccentColor = "#6c5ce7",
            BackgroundColor = "0a0a0a",
            OutlineColor = "1a1a1a",
            FontFace = "Code",
        })
    end
end

-- ============================================================
-- CREATE WINDOW
-- ============================================================
local function CreateMainWindow()
    local window = ASTRO.Library:CreateWindow({
        Title = "ASTRO Dupe",
        Footer = "Mine a Mountain",
        Size = UDim2.fromOffset(640, 750),
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
-- SETUP TABS (ASTRO style)
-- ============================================================
local function SetupTabs()
    local window = ASTRO.Window
    local tabs = {}
    tabs.Dupe = window:AddTab("◆ Dupe")
    tabs.Collect = window:AddTab("⬡ Collect")
    tabs.Rejoin = window:AddTab("⟳ Rejoin")
    tabs.Spoofers = window:AddTab("🕶 Spoofers")
    tabs.Rewards = window:AddTab("🎁 Rewards")
    tabs.Misc = window:AddTab("⚙ Misc")
    tabs.Settings = window:AddTab("▦ Settings")
    tabs.Info = window:AddTab("ℹ Info")
    ASTRO.Tabs = tabs
    return tabs
end

-- ============================================================
-- BUILD UI
-- ============================================================
function ASTRO:BuildUI()
    local Library = ASTRO.Library
    local Tabs = ASTRO.Tabs
    local Options = ASTRO.Options
    local Toggles = ASTRO.Toggles
    local Config = ASTRO.Config
    local State = ASTRO.State

    -- ===== DUPE TAB =====
    local dupeGroup = Tabs.Dupe:AddLeftGroupbox("Drop Selection", "package")

    dupeGroup:AddDropdown("CrystalsToDrop", {
        Text = "Crystals",
        Values = State.crystalOptions,
        Multi = true,
        Searchable = true,
        AllowNull = true,
        Default = Config.selectedCrystals,
        Callback = function(sel)
            Config.selectedCrystals = sel
            buildCrystalCache()
        end
    })

    dupeGroup:AddInput("CrystalDropAmount", {
        Text = "Crystal Drop Amount",
        Default = Config.crystalDropAmount and tostring(Config.crystalDropAmount) or "",
        Placeholder = "All",
        Finished = true,
        Callback = function(val)
            if val == "" or val:lower() == "all" then
                Config.crystalDropAmount = nil
            else
                local num = tonumber(val)
                if num and num > 0 then Config.crystalDropAmount = math.floor(num) end
            end
            buildCrystalCache()
        end
    })

    dupeGroup:AddLabel("Cache: scan to update", true)

    dupeGroup:AddDropdown("RunesToDrop", {
        Text = "Runes",
        Values = State.runeOptions,
        Multi = true,
        Searchable = true,
        AllowNull = true,
        Default = Config.selectedRunes,
        Callback = function(sel)
            Config.selectedRunes = sel
            State.lastRuneScanTime = 0
            task.spawn(function() task.wait(0.1); buildRuneCache() end)
        end
    })

    dupeGroup:AddInput("RuneDropAmount", {
        Text = "Rune Drop Amount",
        Default = Config.runeDropAmount and tostring(Config.runeDropAmount) or "",
        Placeholder = "All",
        Finished = true,
        Callback = function(val)
            if val == "" or val:lower() == "all" then
                Config.runeDropAmount = nil
            else
                local num = tonumber(val)
                if num and num > 0 then Config.runeDropAmount = math.floor(num) end
            end
            buildRuneCache()
        end
    })

    dupeGroup:AddLabel("Cache: scan to update", true)

    dupeGroup:AddButton("Scan Inventory", function()
        scanInventory()
        pcall(function()
            if Options.CrystalsToDrop then Options.CrystalsToDrop:SetValues(State.crystalOptions) end
            if Options.RunesToDrop then Options.RunesToDrop:SetValues(State.runeOptions) end
            if Options.RunesToCollect then Options.RunesToCollect:SetValues(State.collectRuneOptions) end
        end)
        buildAllCache()
        Notify("Inventory scanned", 2)
    end)

    dupeGroup:AddButton("Scan Cache (Count)", function()
        State.lastRuneScanTime = 0
        buildAllCache()
        Notify("Cache updated", 2)
    end)

    dupeGroup:AddButton("Reset Drop Amount → All", function()
        Config.crystalDropAmount = nil
        Config.runeDropAmount = nil
        pcall(function()
            if Options.CrystalDropAmount then Options.CrystalDropAmount:SetValue("") end
            if Options.RuneDropAmount then Options.RuneDropAmount:SetValue("") end
        end)
        buildAllCache()
        Notify("Drop amount reset to All", 2)
    end)

    dupeGroup:AddDivider()

    dupeGroup:AddButton("Manual Drop", function()
        task.spawn(function()
            executeDropItems()
            Notify("Manual drop completed", 2)
        end)
    end)

    dupeGroup:AddButton("Reset Character", function()
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.Health = 0 end) end
    end)

    -- ===== COLLECT TAB =====
    local collectGroup = Tabs.Collect:AddLeftGroupbox("Auto Collect", "users")

    collectGroup:AddToggle("AutoCollect", {
        Text = "Enable Auto Collect",
        Default = Config.isAutoCollect,
        Callback = function(v)
            Config.isAutoCollect = v
        end
    })

    collectGroup:AddDropdown("RaritiesToCollect", {
        Text = "Rarity Filter",
        Values = State.rarityList,
        Multi = true,
        Searchable = true,
        AllowNull = true,
        Default = Config.selectedRarities,
        Callback = function(sel)
            Config.selectedRarities = sel
        end
    })

    collectGroup:AddDropdown("RunesToCollect", {
        Text = "Runes to Collect",
        Values = State.collectRuneOptions,
        Multi = true,
        Searchable = true,
        AllowNull = true,
        Default = Config.selectedRunesToCollect,
        Callback = function(sel)
            Config.selectedRunesToCollect = sel
        end
    })

    collectGroup:AddSlider("CollectRadius", {
        Text = "Collect Radius",
        Default = Config.collectRadius,
        Min = 10,
        Max = 5000,
        Rounding = 0,
        Suffix = " studs",
        Callback = function(v)
            Config.collectRadius = math.floor(v)
        end
    })

    -- ===== REJOIN TAB =====
    local rejoinGroup = Tabs.Rejoin:AddLeftGroupbox("Rejoin Settings", "server")

    rejoinGroup:AddToggle("AutoRejoin", {
        Text = "Enable Auto Rejoin",
        Default = Config.isAutoRejoin,
        Callback = function(v)
            Config.isAutoRejoin = v
        end
    })

    rejoinGroup:AddSlider("RejoinDelay", {
        Text = "Rejoin Delay",
        Default = Config.rejoinDelay,
        Min = 1,
        Max = 30,
        Rounding = 0,
        Suffix = " s",
        Callback = function(v)
            Config.rejoinDelay = math.floor(v)
        end
    })

    rejoinGroup:AddDropdown("RejoinMethod", {
        Text = "Rejoin Method",
        Values = {"Current Server", "Private Server Link", "Random Server"},
        Multi = false,
        Default = Config.rejoinMethod,
        Callback = function(v)
            Config.rejoinMethod = v
        end
    })

    rejoinGroup:AddInput("PrivateServerLink", {
        Text = "Private Server Link",
        Default = Config.privateServerLink,
        Placeholder = "Paste full URL",
        Finished = true,
        Callback = function(v)
            Config.privateServerLink = v
        end
    })

    -- ===== SPOOFERS TAB =====
    local deviceGroup = Tabs.Spoofers:AddLeftGroupbox("Device Spoofer", "smartphone")
    deviceGroup:AddToggle("DeviceSpoof", {
        Text = "Enable Device Spoof",
        Default = Config.deviceSpoof,
        Callback = function(v)
            Config.deviceSpoof = v
            if v then startDeviceSpoofLoop() end
        end
    })
    deviceGroup:AddDropdown("DeviceTarget", {
        Text = "Target Device",
        Values = {"Controller", "PC", "Mobile", "VR"},
        Multi = false,
        Default = Config.deviceTarget,
        Callback = function(v)
            Config.deviceTarget = v
        end
    })

    local nameGroup = Tabs.Spoofers:AddRightGroupbox("Name Spoofer", "user")
    nameGroup:AddToggle("NameSpoof", {
        Text = "Enable Name Spoof",
        Default = Config.nameSpoof,
        Callback = function(v)
            Config.nameSpoof = v
            if v then startNameSpoof() end
        end
    })
    nameGroup:AddInput("SpoofedName", {
        Text = "Spoofed Name",
        Default = Config.spoofedName,
        Finished = true,
        Callback = function(v)
            Config.spoofedName = v
        end
    })
    nameGroup:AddDropdown("NameSpoofMode", {
        Text = "Spoof Mode",
        Values = {"Both", "Name", "DisplayName"},
        Multi = false,
        Default = Config.nameSpoofMode,
        Callback = function(v)
            Config.nameSpoofMode = v
        end
    })
    nameGroup:AddToggle("NameSpoofBadge", {
        Text = "Add Verified Badge ✓",
        Default = Config.nameSpoofBadge,
        Callback = function(v)
            Config.nameSpoofBadge = v
        end
    })

    local levelGroup = Tabs.Spoofers:AddLeftGroupbox("Level / Winstreak", "chart")
    levelGroup:AddToggle("LevelSpoof", {
        Text = "Spoof Level",
        Default = Config.levelSpoof,
        Callback = function(v)
            Config.levelSpoof = v
            if v then startLevelSpoofLoop() end
        end
    })
    levelGroup:AddSlider("LevelVal", {
        Text = "Level",
        Default = Config.levelVal,
        Min = 1,
        Max = 9999,
        Rounding = 0,
        Callback = function(v)
            Config.levelVal = math.floor(v)
        end
    })
    levelGroup:AddToggle("WinstreakSpoof", {
        Text = "Spoof Winstreak",
        Default = Config.winstreakSpoof,
        Callback = function(v)
            Config.winstreakSpoof = v
            if v then startLevelSpoofLoop() end
        end
    })
    levelGroup:AddSlider("WinstreakVal", {
        Text = "Winstreak",
        Default = Config.winstreakVal,
        Min = 0,
        Max = 9999,
        Rounding = 0,
        Callback = function(v)
            Config.winstreakVal = math.floor(v)
        end
    })

    -- ===== REWARDS TAB =====
    local rewardsGroup = Tabs.Rewards:AddLeftGroupbox("Claim Rewards", "gift")
    rewardsGroup:AddButton("Claim All Rewards", function() claimAllRewards() end)

    local codesGroup = Tabs.Rewards:AddRightGroupbox("Redeem Codes", "code")
    codesGroup:AddButton("Redeem All Codes", function() redeemAllCodes() end)

    -- ===== MISC TAB =====
    local miscGroup = Tabs.Misc:AddLeftGroupbox("Misc", "wrench")

    miscGroup:AddToggle("AutoWeaponPick", {
        Text = "Auto Weapon Pick",
        Default = Config.autoWeapon,
        Callback = function(v)
            Config.autoWeapon = v
            if v then startAutoWeaponLoop() end
        end
    })
    for i = 1, 4 do
        miscGroup:AddInput("WeaponSlot"..i, {
            Text = "Weapon Slot "..i,
            Default = Config.weaponSlots[i] or "",
            Placeholder = "e.g. Bow, Handgun",
            Finished = true,
            Callback = function(v)
                Config.weaponSlots[i] = v
            end
        })
    end

    miscGroup:AddDivider()

    miscGroup:AddToggle("ProximityAlert", {
        Text = "Proximity Alert",
        Default = Config.proximity,
        Callback = function(v)
            Config.proximity = v
        end
    })
    miscGroup:AddSlider("ProximityDistance", {
        Text = "Alert Distance",
        Default = Config.proximityDistance,
        Min = 10,
        Max = 200,
        Rounding = 0,
        Suffix = " studs",
        Callback = function(v)
            Config.proximityDistance = math.floor(v)
        end
    })

    miscGroup:AddDivider()

    miscGroup:AddToggle("AntiAFK", {
        Text = "Anti AFK",
        Default = Config.antiAFK,
        Callback = function(v)
            Config.antiAFK = v
            if v then startAntiAFK() end
        end
    })

    -- ===== SETTINGS TAB =====
    if ASTRO.ThemeManager then
        ASTRO.ThemeManager:ApplyToTab(Tabs.Settings)
    end
    if ASTRO.SaveManager then
        ASTRO.SaveManager:SetLibrary(Library)
        ASTRO.SaveManager:SetFolder("ASTRO Dupe")
        ASTRO.SaveManager:SetSubFolder(tostring(game.PlaceId))
        ASTRO.SaveManager:BuildConfigSection(Tabs.Settings)
        ASTRO.SaveManager:LoadAutoloadConfig()
    end

    -- ===== INFO TAB =====
    local infoGroup = Tabs.Info:AddLeftGroupbox("About", "info")
    infoGroup:AddLabel("ASTRO Dupe - Mine a Mountain", true)
    infoGroup:AddLabel("Version: " .. ASTRO.Version, true)
    infoGroup:AddLabel("All features from D-Hub Dupe", true)
    infoGroup:AddLabel("Powered by Obsidian Library", true)
end

-- ============================================================
-- INIT
-- ============================================================
function ASTRO:Init()
    if self.Loaded then return self end

    SetupTheme()
    CreateMainWindow()
    SetupTabs()

    scanInventory()
    self:BuildUI()
    setupKickListeners()
    startAutoCollectLoop()
    startProximityLoop()

    task.spawn(function()
        task.wait(1.5)
        buildAllCache()
        Notify("ASTRO Dupe Full loaded", 3)
    end)

    self.Loaded = true
    self.Library.ToggleKeybind = Enum.KeyCode.LeftAlt
    print("[ASTRO] Full Dupe Edition loaded! Press LeftAlt to toggle UI.")
    Notify("ASTRO Dupe Full Ready", 3)

    return self
end

function ASTRO:Destroy()
    self.Unloaded = true
    self.Loaded = false
    if self.Window then self.Window:Destroy() end
    print("[ASTRO] Unloaded.")
end

return ASTRO:Init()