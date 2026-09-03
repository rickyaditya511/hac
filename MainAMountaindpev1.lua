local ASTRO = {
    Name = "ASTRO Dupe",
    SubName = "Mine a Mountain",
    Version = "4.1.1",
    Loaded = false,
    Library = nil,
    SaveManager = nil,
    ThemeManager = nil,
    Window = nil,
    Tabs = {},
    Options = {},
    Toggles = {},
    Unloaded = false,
    Services = {},
    -- Konfigurasi (disimpan)
    Config = {
        selectedCrystals = {},
        selectedRunes = {},
        selectedRarities = {},
        selectedRunesToCollect = {},
        kickDropMethod = "Drop Only",
        isAutoDropOnKick = false,
        isAutoCollect = false,
        isAutoRejoin = false,
        rejoinDelay = 5,
        rejoinMethod = "Current Server",
        privateServerLink = "",
        collectRadius = 100,
        crystalDropAmount = nil,
        runeDropAmount = nil,
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
    },
}

-- ============================================================
-- LOAD DEPENDENCIES
-- ============================================================
local function LoadDependencies()
    local success, result

    success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/Library.lua"))()
    end)
    if not success or not result then warn("[ASTRO] Failed to load Library") return false end
    ASTRO.Library = result

    success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/addons/SaveManager.lua"))()
    end)
    if not success or not result then warn("[ASTRO] Failed to load SaveManager") return false end
    ASTRO.SaveManager = result

    success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/addons/ThemeManager.lua"))()
    end)
    if not success or not result then warn("[ASTRO] Failed to load ThemeManager") return false end
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
    local CoreGui = game:GetService("CoreGui")
    local GuiService = game:GetService("GuiService")

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
        CoreGui = CoreGui,
        GuiService = GuiService,
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
-- CREATE WINDOW
-- ============================================================
local function CreateMainWindow()
    local Library = ASTRO.Library
    local window = Library:CreateWindow({
        Title = "ASTRO Dupe",
        Footer = "Mine a Mountain",
        Size = UDim2.fromOffset(620, 700),
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
-- SETUP TABS (Ikon Unicode rapi)
-- ============================================================
local function SetupTabs()
    local window = ASTRO.Window
    local tabs = {}

    tabs.Dupe = window:AddTab("◆ Dupe")
    tabs.Collect = window:AddTab("⬡ Collect")
    tabs.Rejoin = window:AddTab("⟳ Rejoin")
    tabs.Misc = window:AddTab("⚙ Misc")
    tabs.Settings = window:AddTab("▦ Settings")
    tabs.Info = window:AddTab("ℹ Info")

    ASTRO.Tabs = tabs
    return tabs
end

-- ============================================================
-- CORE UTILITIES
-- ============================================================
local function Notify(text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "ASTRO Dupe",
            Description = tostring(text),
            Duration = duration or 3
        })
    end)
    if ASTRO.Library and ASTRO.Library.Notify then
        ASTRO.Library:Notify({ Title = "ASTRO", Description = text, Time = duration or 3 })
    end
end

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

local function getDropRemote()
    local RS = ASTRO.Services.ReplicatedStorage
    if ASTRO.State.dropRemote and ASTRO.State.dropRemote.Parent then
        return ASTRO.State.dropRemote
    end
    local r = RS:FindFirstChild("Remotes")
    ASTRO.State.dropRemote = r and r:FindFirstChild("CrystalDropRequest")
    return ASTRO.State.dropRemote
end

local function getHoldRemote()
    local RS = ASTRO.Services.ReplicatedStorage
    if ASTRO.State.holdRemote and ASTRO.State.holdRemote.Parent then
        return ASTRO.State.holdRemote
    end
    local r = RS:FindFirstChild("Remotes")
    ASTRO.State.holdRemote = r and r:FindFirstChild("CrystalHoldComplete")
    return ASTRO.State.holdRemote
end

local function readCountFromAttr(tool)
    local attrNames = {"Amount","Count","UsesLeft","Stack","Quantity","StackSize","Uses","Charges","Stacks"}
    for _, attr in ipairs(attrNames) do
        local val = tool:GetAttribute(attr)
        if type(val) == "number" and val > 0 then return math.floor(val) end
    end
    return nil
end

local function readCountFromUI()
    local lp = ASTRO.Services.LocalPlayer
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
    -- cek attribute di obj langsung
    local tierName = obj:GetAttribute("TierName")
    if type(tierName) == "string" and tierName ~= "" then
        return tierName
    end
    local rarityAttr = obj:GetAttribute("Rarity")
    if type(rarityAttr) == "string" and rarityAttr ~= "" then
        return rarityAttr
    end
    local rarityName = obj:GetAttribute("RarityName")
    if type(rarityName) == "string" and rarityName ~= "" then
        return rarityName
    end
    local tierNum = obj:GetAttribute("Tier")
    if type(tierNum) == "number" and tierNum > 0 then
        if tierNum <= #ASTRO.State.rarityList then
            return ASTRO.State.rarityList[tierNum]
        end
    end

    -- cek parent model (jika obj adalah part)
    local parent = obj.Parent
    if parent and parent:IsA("Model") then
        tierName = parent:GetAttribute("TierName")
        if type(tierName) == "string" and tierName ~= "" then return tierName end
        rarityAttr = parent:GetAttribute("Rarity")
        if type(rarityAttr) == "string" and rarityAttr ~= "" then return rarityAttr end
        rarityName = parent:GetAttribute("RarityName")
        if type(rarityName) == "string" and rarityName ~= "" then return rarityName end
        tierNum = parent:GetAttribute("Tier")
        if type(tierNum) == "number" and tierNum > 0 then
            if tierNum <= #ASTRO.State.rarityList then
                return ASTRO.State.rarityList[tierNum]
            end
        end
    end

    -- default Common
    return "Common"
end

local function rarityAllowed(obj)
    local selectedRarities = ASTRO.Config.selectedRarities
    if #selectedRarities == 0 then return true end
    local r = getCrystalRarity(obj)
    for _, sel in ipairs(selectedRarities) do
        if sel == r then return true end
    end
    return false
end

local function isRuneInWorld(obj)
    if obj:GetAttribute("RuneId")   ~= nil then return true end
    if obj:GetAttribute("IsRune")   == true then return true end
    if obj:GetAttribute("RuneName") ~= nil then return true end
    if obj.Name:find(" Rune", 1, true) ~= nil then return true end
    return false
end

local function runeNameAllowed(obj)
    local selectedRunesToCollect = ASTRO.Config.selectedRunesToCollect
    if #selectedRunesToCollect == 0 then return true end
    for _, name in ipairs(selectedRunesToCollect) do
        if obj.Name == name then return true end
    end
    return false
end

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
    local lp = ASTRO.Services.LocalPlayer
    local state = ASTRO.State
    table.clear(state.crystalOptions)
    table.clear(state.runeOptions)
    table.clear(state.collectRuneOptions)
    local crystalMap, runeMap = {}, {}

    local function checkItem(child)
        if isRuneTool(child) then
            if not runeMap[child.Name] then
                runeMap[child.Name] = true
                table.insert(state.runeOptions, child.Name)
                table.insert(state.collectRuneOptions, child.Name)
            end
        elseif isCrystalTool(child) then
            if not crystalMap[child.Name] then
                crystalMap[child.Name] = true
                table.insert(state.crystalOptions, child.Name)
            end
        end
    end

    local bp = lp:FindFirstChildOfClass("Backpack")
    if bp then for _, c in ipairs(bp:GetChildren()) do checkItem(c) end end
    local char = lp.Character
    if char then for _, c in ipairs(char:GetChildren()) do checkItem(c) end end

    table.sort(state.crystalOptions)
    table.sort(state.runeOptions)
    table.sort(state.collectRuneOptions)
end

local function buildCrystalCache()
    local lp = ASTRO.Services.LocalPlayer
    local state = ASTRO.State
    local config = ASTRO.Config
    table.clear(state.crystalDropCache)

    if #config.selectedCrystals == 0 then return end

    local targetSet = {}
    for _, name in ipairs(config.selectedCrystals) do
        targetSet[name] = true
    end

    local function countFrom(container)
        if not container then return end
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Tool") and isCrystalTool(child) and targetSet[child.Name] then
                state.crystalDropCache[child.Name] = (state.crystalDropCache[child.Name] or 0) + 1
            end
        end
    end

    countFrom(lp:FindFirstChildOfClass("Backpack"))
    countFrom(lp.Character)
end

local function buildRuneCache()
    local lp = ASTRO.Services.LocalPlayer
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
        local TS = ASTRO.Services.TeleportService
        local placeId = game.PlaceId
        local lp = ASTRO.Services.LocalPlayer

        while task.wait(3) do
            if config.rejoinMethod == "Current Server" then
                pcall(function()
                    TS:TeleportToPlaceInstance(placeId, game.JobId, lp)
                end)
            elseif config.rejoinMethod == "Random Server" then
                pcall(function() TS:Teleport(placeId, lp) end)
            elseif config.rejoinMethod == "Private Server Link" then
                if config.privateServerLink ~= "" then
                    local code = config.privateServerLink:match("privateServerLinkCode=([^&]+)")
                    if code then
                        pcall(function()
                            TS:TeleportToPrivateServer(placeId, code, {lp})
                        end)
                    else
                        pcall(function()
                            TS:TeleportToPrivateServer(placeId, config.privateServerLink, {lp})
                        end)
                    end
                end
            end
        end
    end)
end

-- ============================================================
-- KICK DETECTION TRIGGER
-- ============================================================
local function triggerDropAndRejoin()
    if ASTRO.State.connectionTriggered then return end
    ASTRO.State.connectionTriggered = true

    local config = ASTRO.Config

    if config.isAutoDropOnKick then
        if config.kickDropMethod == "Reset Then Drop" then
            executeDropItems()
            local char = ASTRO.Services.LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum.Health = 0 end) end
        else
            executeDropItems()
        end
    end

    handleRejoin()
end

local function setupKickListeners()
    local GuiService = ASTRO.Services.GuiService
    local CoreGui = ASTRO.Services.CoreGui

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
-- AUTO COLLECT LOOP (dengan Rarity Filter yang benar)
-- ============================================================
local function startAutoCollectLoop()
    task.spawn(function()
        while not ASTRO.Unloaded do
            task.wait(0.25)
            if not ASTRO.Config.isAutoCollect then continue end

            local lp = ASTRO.Services.LocalPlayer
            local Workspace = ASTRO.Services.Workspace
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

            -- Collect crystals dengan filter rarity
            for _, container in ipairs(containers) do
                for _, child in ipairs(container:GetChildren()) do
                    if not ASTRO.Config.isAutoCollect then break end
                    if not child:IsA("BasePart") then continue end
                    local isValid = child:GetAttribute("Value") ~= nil
                        and (child:GetAttribute("CrystalName") ~= nil or child:GetAttribute("Tier") ~= nil)
                    if not isValid then continue end
                    if child:GetAttribute("Collected") == true then continue end
                    -- CEK RARITY DENGAN FUNGSI YANG SUDAH DIPERBAIKI
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

            -- Collect runes
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
                    if obj:IsA("BasePart") then
                        pos = obj.Position
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
-- BUILD UI (Sama dengan ASTRO Rival)
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
        local lp = ASTRO.Services.LocalPlayer
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

    -- ===== MISC TAB =====
    local miscGroup = Tabs.Misc:AddLeftGroupbox("Drop on Kick", "settings")

    miscGroup:AddToggle("AutoDropOnKick", {
        Text = "Auto Drop on Kick",
        Default = Config.isAutoDropOnKick,
        Callback = function(v)
            Config.isAutoDropOnKick = v
        end
    })

    miscGroup:AddDropdown("KickDropMethod", {
        Text = "Drop Method on Kick",
        Values = {"Drop Only", "Reset Then Drop"},
        Multi = false,
        Default = Config.kickDropMethod,
        Callback = function(v)
            Config.kickDropMethod = v
        end
    })

    -- ===== SETTINGS TAB =====
    local ThemeManager = ASTRO.ThemeManager
    local SaveManager = ASTRO.SaveManager
    ThemeManager:ApplyToTab(Tabs.Settings)
    SaveManager:SetLibrary(Library)
    SaveManager:SetFolder(ASTRO.Name)
    SaveManager:SetSubFolder(tostring(game.PlaceId))
    SaveManager:BuildConfigSection(Tabs.Settings)
    SaveManager:LoadAutoloadConfig()

    -- ===== INFO TAB =====
    local infoGroup = Tabs.Info:AddLeftGroupbox("About", "info")
    infoGroup:AddLabel(ASTRO.Name .. " - " .. ASTRO.SubName, true)
    infoGroup:AddLabel("Version: " .. ASTRO.Version, true)
    infoGroup:AddLabel("Dupe & Auto Collect System", true)
    infoGroup:AddLabel("Based on D-Hub Dupe", true)
    infoGroup:AddLabel("Powered by Obsidian Library", true)
end

-- ============================================================
-- INIT
-- ============================================================
function ASTRO:Init()
    if self.Loaded then return self end
    print("[ASTRO] Loading Dupe Edition...")

    if not LoadDependencies() then return nil end
    SetupTheme()
    CreateMainWindow()
    SetupTabs()

    scanInventory()
    self:BuildUI()
    setupKickListeners()
    startAutoCollectLoop()

    task.spawn(function()
        task.wait(1.5)
        buildAllCache()
        Notify("ASTRO Dupe loaded", 3)
    end)

    self.Loaded = true
    self.Library.ToggleKeybind = Enum.KeyCode.LeftAlt
    print("[ASTRO] Dupe Edition loaded! Press LeftAlt to toggle UI.")
    Notify("ASTRO Dupe Ready", 3)

    return self
end

function ASTRO:Destroy()
    self.Unloaded = true
    self.Loaded = false
    if self.Window then self.Window:Destroy() end
    print("[ASTRO] Unloaded.")
end

return ASTRO:Init()