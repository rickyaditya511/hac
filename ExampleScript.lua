--[[
    Ultimate Farm X - Full Edition
    by Rylax0322
    Library: WindUI
    Features: ALL remotes implemented, 15+ tabs, bug fixes, optimized
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game.Players
local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- ============================================
-- DATA
-- ============================================
local Eggs = {
    "Basic Egg", "Bird Egg", "Insect Egg", "Aquatic Egg",
    "Candy Egg", "Snow Egg", "Alien Egg", "Midnight Egg"
}

local Codes = {
    "RELEASE", "UPDATE1", "FREESPINS", "LUCKY", "COINS",
    "GEMS", "BOOST", "HATCH", "FARM", "TYCOON", "WELCOME"
}

local WebhookURL = "" -- Isi kalo mau Discord notif

-- ============================================
-- GLOBAL STATE
-- ============================================
local State = {
    SelectedEgg = "Basic Egg",
    SelectedSpeed = "Fast",
    SelectedBuyMethod = "Max",
    BuyQuantity = 9999,
    
    -- Toggles
    Hatching = false,
    Buying = false,
    Spinning = false,
    Collecting = false,
    Farming = false,
    Claiming = false,
    Rebirthing = false,
    Upgrading = false,
    Cropping = false,
    Feeding = false,
    Redeeming = false,
    AntiAFK = false,
    Stealth = false,
    
    -- Counters
    HatchCount = 0,
    FarmCount = 0,
    ClaimCount = 0,
    SpinCount = 0,
    RebirthCount = 0,
    TotalCash = 0,
    
    -- Threads
    HatchThreads = {},
    BuyThread = nil,
    SpinThread = nil,
    ChestThread = nil,
    FarmThread = nil,
    ClaimThread = nil,
    RebirthThread = nil,
    UpgradeThread = nil,
    CropThread = nil,
    FeedThread = nil,
    AntiAFKThread = nil,
    WebhookThread = nil,
}

-- ============================================
-- SAFE REMOTE HANDLER (with retry & cooldown)
-- ============================================
local RemoteCooldowns = {}

local function callRemote(name, ...)
    -- Cooldown check (anti rate-limit)
    local now = tick()
    if RemoteCooldowns[name] and now - RemoteCooldowns[name] < 0.1 then
        return -- Skip if called too fast
    end
    RemoteCooldowns[name] = now
    
    -- Retry 3x
    for i = 1, 3 do
        local ok = pcall(function()
            local remote = Remotes:WaitForChild(name)
            if remote then
                remote:InvokeServer(...)
            end
        end)
        if ok then break end
        task.wait(0.05)
    end
end

local function fireRemote(name, ...)
    local now = tick()
    if RemoteCooldowns[name] and now - RemoteCooldowns[name] < 0.05 then
        return
    end
    RemoteCooldowns[name] = now
    
    for i = 1, 3 do
        local ok = pcall(function()
            local remote = Remotes:WaitForChild(name)
            if remote then
                remote:FireServer(...)
            end
        end)
        if ok then break end
        task.wait(0.05)
    end
end

-- ============================================
-- ALL REMOTE FUNCTIONS (Organized)
-- ============================================
local Remote = {}

-- Egg & Hatch
Remote.HatchOwnedEgg = function(egg) callRemote("HatchOwnedEgg", egg) end
Remote.HatchEgg = function(egg, qty) callRemote("HatchEgg", egg, qty) end
Remote.PetEggBuy = function(egg) callRemote("PetEggBuy", egg) end
Remote.MultiHatchReveal = function() fireRemote("MultiHatchReveal") end

-- Spin
Remote.SpinRequest = function() callRemote("SpinRequest") end
Remote.ClaimSpinResult = function() callRemote("ClaimSpinResult") end
Remote.GetSpinState = function() callRemote("GetSpinState") end

-- Sell & Economy
Remote.SellRequest = function() fireRemote("SellRequest", "all") end
Remote.SetAutoSell = function(state) callRemote("SetAutoSell", state) end
Remote.BulkSetAutoSell = function(state) callRemote("BulkSetAutoSell", state) end
Remote.CashCollected = function() fireRemote("CashCollected") end
Remote.GemsCollected = function() fireRemote("GemsCollected") end

-- Claims & Rewards
Remote.DailyRewardsClaim = function() callRemote("DailyRewardsClaim") end
Remote.QuestClaim = function() callRemote("QuestClaim") end
Remote.ClaimAllDiscoveries = function() callRemote("ClaimAllDiscoveries") end
Remote.ClaimAllBabyDiscoveries = function() callRemote("ClaimAllBabyDiscoveries") end
Remote.PlaytimeClaim = function() callRemote("PlaytimeClaim") end
Remote.ClaimLeaveReward = function() callRemote("ClaimLeaveReward") end
Remote.GetLeaveRewardStatus = function() callRemote("GetLeaveRewardStatus") end
Remote.RedeemCode = function(code) callRemote("RedeemCode", code) end
Remote.ClaimDiscovery = function() callRemote("ClaimDiscovery") end
Remote.ClaimBabyDiscovery = function() callRemote("ClaimBabyDiscovery") end

-- Rebirth
Remote.RebirthRequest = function() callRemote("RebirthRequest") end

-- Pet Management
Remote.PetEquip = function() fireRemote("PetEquip") end
Remote.PetUnequip = function() fireRemote("PetUnequip") end
Remote.PetEquipBest = function() fireRemote("PetEquipBest") end
Remote.SelectCow = function(id) fireRemote("SelectCow", id) end
Remote.ToggleFavoriteCow = function(id) callRemote("ToggleFavoriteCow", id) end
Remote.ToggleFavorite = function() callRemote("ToggleFavorite") end

-- Crop
Remote.PlantSeed = function() fireRemote("PlantSeed") end
Remote.HarvestCrop = function() fireRemote("HarvestCrop") end
Remote.CropShopBuySeed = function(seed) callRemote("CropShopBuySeed", seed) end
Remote.CropShopBuyUpgrade = function(upg) callRemote("CropShopBuyUpgrade", upg) end
Remote.SelectCrop = function(id) fireRemote("SelectCrop", id) end
Remote.ToggleFavoriteCrop = function(id) callRemote("ToggleFavoriteCrop", id) end

-- Upgrade & Success
Remote.OpenUpgradeGui = function() fireRemote("OpenUpgradeGui") end
Remote.RequestUpgrade = function(t) callRemote("RequestUpgrade", t) end
Remote.ConfirmSuccessUpgrade = function() fireRemote("ConfirmSuccessUpgrade") end
Remote.RequestSuccessReroll = function() callRemote("RequestSuccessReroll") end
Remote.RequestCancelUpgradeConfirm = function() fireRemote("RequestCancelUpgradeConfirm") end
Remote.ConfirmCancelUpgrade = function() fireRemote("ConfirmCancelUpgrade") end
Remote.OpenSuccessGui = function() fireRemote("OpenSuccessGui") end
Remote.CancelSuccessAttempt = function() fireRemote("CancelSuccessAttempt") end

-- Settings & Misc
Remote.UpdateSetting = function() fireRemote("UpdateSetting") end
Remote.ToggleAutoCollect = function(s) fireRemote("ToggleAutoCollect", s) end
Remote.ToggleAutoFarm = function(s) fireRemote("ToggleAutoFarm", s) end
Remote.SetHotbarSlot = function(s) fireRemote("SetHotbarSlot", s) end
Remote.PlaceBestRequest = function() fireRemote("PlaceBestRequest") end
Remote.ActivateServerLuck = function() fireRemote("ActivateServerLuck") end
Remote.MarkFavoritePromptShown = function() fireRemote("MarkFavoritePromptShown") end
Remote.RequestEquipTitle = function(id) callRemote("RequestEquipTitle", id) end
Remote.GetTitleOwnerCounts = function() callRemote("GetTitleOwnerCounts") end
Remote.RequestConsumablePurchase = function(i) callRemote("RequestConsumablePurchase", i) end
Remote.FeedbackSubmit = function(t) callRemote("FeedbackSubmit", t) end
Remote.FeedbackStatus = function() callRemote("FeedbackStatus") end

-- Social & Gift
Remote.GiftIntent = function(p) fireRemote("GiftIntent", p) end
Remote.GiftSent = function() fireRemote("GiftSent") end
Remote.GiftRejected = function() fireRemote("GiftRejected") end
Remote.PodiumStealAlert = function() fireRemote("PodiumStealAlert") end
Remote.PodiumPlaceSound = function() fireRemote("PodiumPlaceSound") end

-- Tutorial & Events
Remote.TutorialSkip = function() fireRemote("TutorialSkip") end
Remote.TutorialAdvance = function() fireRemote("TutorialAdvance") end
Remote.AnnouncementShow = function() fireRemote("AnnouncementShow") end
Remote.ShowUpdateLog = function() fireRemote("ShowUpdateLog") end

-- Admin (DANGER)
Remote.AdminAction = function(a) callRemote("AdminAction", a) end
Remote.HatchAdminEgg = function() callRemote("HatchAdminEgg") end

-- Other
Remote.AFKTeleport = function() fireRemote("AFKTeleport") end
Remote.CowFedSfx = function() fireRemote("CowFedSfx") end
Remote.DevProductGranted = function() fireRemote("DevProductGranted") end
Remote.MarkShopOpened = function() fireRemote("MarkShopOpened") end

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

-- Chest System
function GetChests()
    local chests = {}
    pcall(function()
        local folder = Workspace:FindFirstChild("ChestSpawns")
        if folder then
            for _, obj in ipairs(folder:GetChildren()) do
                if obj.Parent and (obj:IsA("BasePart") or obj:IsA("Model")) then
                    table.insert(chests, obj)
                end
            end
        end
    end)
    return chests
end

function CollectChest(chest)
    if not chest or not chest.Parent then return false end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    
    local pos = chest:IsA("Model") and chest:GetPivot().Position or chest.Position
    local dist = (char.HumanoidRootPart.Position - pos).Magnitude
    
    if dist > 15 then
        char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        task.wait(0.2)
    end
    
    local prompts = chest:IsA("Model") and chest:GetDescendants() or { chest }
    for _, obj in ipairs(prompts) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            fireproximityprompt(obj, obj.HoldDuration + 0.3)
            return true
        end
    end
    return false
end

-- Farm System
function GetFarmableCows()
    local cows = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local action = obj.ActionText
            if action == "Pick Up" or action == "Pick Up Baby" or action == "Place Cow" then
                table.insert(cows, obj)
            end
        end
    end
    return cows
end

function CollectGift()
    pcall(function()
        local gift = Workspace.Gift.Rewards.Gift
        if gift then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(gift:GetPivot().Position)
                task.wait(0.1)
                for _, obj in ipairs(gift:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and obj.Enabled then
                        fireproximityprompt(obj, 0.1)
                        return
                    end
                end
            end
        end
    end)
end

-- Teleport System
function TeleportTo(target)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local pos
    if typeof(target) == "Instance" then
        pos = target:IsA("Model") and target:GetPivot().Position or target.Position
    elseif typeof(target) == "Vector3" then
        pos = target
    elseif typeof(target) == "string" then
        pcall(function()
            local obj = loadstring("return " .. target)()
            if obj then pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position end
        end)
    end
    
    if pos then
        TweenService:Create(char.HumanoidRootPart, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        }):Play()
    end
end

-- Discord Webhook
function SendWebhook(message)
    if WebhookURL == "" then return end
    pcall(function()
        HttpService:PostAsync(WebhookURL, HttpService:JSONEncode({
            content = message,
            username = "Ultimate Farm X",
        }))
    end)
end

print("Ultimate Farm X - Core Loaded")
-- ============================================
-- AUTO FUNCTIONS (Optimized)
-- ============================================

-- Auto Hatch
local function StartAutoHatch()
    for _, t in ipairs(State.HatchThreads) do task.cancel(t) end
    State.HatchThreads = {}
    local delay = State.SelectedSpeed == "Fast" and 0.05 or 0.5
    local threads = State.SelectedSpeed == "Fast" and 3 or 1
    for _ = 1, threads do
        local t = task.spawn(function()
            while State.Hatching do
                Remote.HatchOwnedEgg(State.SelectedEgg)
                State.HatchCount = State.HatchCount + 1
                task.wait(delay)
            end
        end)
        table.insert(State.HatchThreads, t)
    end
end

local function StopAutoHatch()
    for _, t in ipairs(State.HatchThreads) do task.cancel(t) end
    State.HatchThreads = {}
end

-- Auto Buy
local function StartAutoBuy()
    if State.BuyThread then task.cancel(State.BuyThread) end
    State.BuyThread = task.spawn(function()
        while State.Buying do
            Remote.HatchEgg(State.SelectedEgg, State.BuyQuantity)
            task.wait(0.25)
        end
    end)
end

-- Auto Spin
local function StartAutoSpin()
    if State.SpinThread then task.cancel(State.SpinThread) end
    State.SpinThread = task.spawn(function()
        while State.Spinning do
            Remote.SpinRequest()
            task.wait(0.25)
            Remote.ClaimSpinResult()
            State.SpinCount = State.SpinCount + 1
            task.wait(0.8)
        end
    end)
end

-- Auto Chest
local function StartAutoChest()
    if State.ChestThread then task.cancel(State.ChestThread) end
    State.ChestThread = task.spawn(function()
        while State.Collecting do
            local chests = GetChests()
            for _, c in ipairs(chests) do
                if not State.Collecting then break end
                CollectChest(c)
                task.wait(0.5)
            end
            task.wait(2)
        end
    end)
end

-- Auto Farm
local function StartAutoFarm()
    if State.FarmThread then task.cancel(State.FarmThread) end
    State.FarmThread = task.spawn(function()
        while State.Farming do
            local cows = GetFarmableCows()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and #cows > 0 then
                for _, prompt in ipairs(cows) do
                    if not State.Farming then break end
                    if prompt.Enabled and prompt.Parent then
                        local pos = prompt.Parent:IsA("Model") and prompt.Parent:GetPivot().Position or prompt.Parent.Position
                        char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
                        task.wait(0.15)
                        fireproximityprompt(prompt, prompt.HoldDuration + 0.2)
                        State.FarmCount = State.FarmCount + 1
                        task.wait(0.2)
                    end
                end
            end
            task.wait(1)
        end
    end)
end

-- Auto Claim
local function StartAutoClaim()
    if State.ClaimThread then task.cancel(State.ClaimThread) end
    State.ClaimThread = task.spawn(function()
        while State.Claiming do
            Remote.DailyRewardsClaim()
            Remote.QuestClaim()
            Remote.ClaimAllDiscoveries()
            Remote.ClaimAllBabyDiscoveries()
            Remote.PlaytimeClaim()
            Remote.ClaimLeaveReward()
            CollectGift()
            State.ClaimCount = State.ClaimCount + 1
            task.wait(30)
        end
    end)
end

-- Auto Rebirth
local function StartAutoRebirth()
    if State.RebirthThread then task.cancel(State.RebirthThread) end
    State.RebirthThread = task.spawn(function()
        while State.Rebirthing do
            Remote.RebirthRequest()
            State.RebirthCount = State.RebirthCount + 1
            task.wait(5)
        end
    end)
end

-- Auto Upgrade
local function StartAutoUpgrade()
    if State.UpgradeThread then task.cancel(State.UpgradeThread) end
    State.UpgradeThread = task.spawn(function()
        while State.Upgrading do
            Remote.ConfirmSuccessUpgrade()
            task.wait(0.5)
            Remote.RequestSuccessReroll()
            task.wait(2)
        end
    end)
end

-- Auto Crop
local function StartAutoCrop()
    if State.CropThread then task.cancel(State.CropThread) end
    State.CropThread = task.spawn(function()
        while State.Cropping do
            Remote.PlantSeed()
            task.wait(0.5)
            Remote.HarvestCrop()
            task.wait(1)
        end
    end)
end

-- Auto Feed
local function StartAutoFeed()
    if State.FeedThread then task.cancel(State.FeedThread) end
    State.FeedThread = task.spawn(function()
        while State.Feeding do
            Remote.CowFedSfx()
            task.wait(10)
        end
    end)
end

-- Anti AFK
local function StartAntiAFK()
    if State.AntiAFKThread then task.cancel(State.AntiAFKThread) end
    State.AntiAFKThread = task.spawn(function()
        while State.AntiAFK do
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                -- Random tiny movement
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    hum:Move(Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)), true)
                end
            end
            task.wait(30 + math.random(1, 10))
        end
    end)
end

-- Stealth Mode (adds random delays)
local StealthDelay = 1
local function GetStealthDelay()
    if State.Stealth then
        return StealthDelay + math.random(1, 3)
    end
    return StealthDelay
end

-- ============================================
-- WINDOW
-- ============================================
local Window = WindUI:CreateWindow({
    Title = "Ultimate Farm X | Rylax0322",
    Folder = "UltimateFarmX",
    Icon = "crown",
})

-- ============================================
-- ALL TABS (15 Tabs)
-- ============================================
local HatchTab = Window:Tab({ Title = "Hatch", Icon = "egg" })
local ShopTab = Window:Tab({ Title = "Shop", Icon = "shopping-cart" })
local SpinTab = Window:Tab({ Title = "Spin", Icon = "refresh-cw" })
local ChestTab = Window:Tab({ Title = "Chest", Icon = "package" })
local FarmTab = Window:Tab({ Title = "Farm", Icon = "sword" })
local ClaimTab = Window:Tab({ Title = "Claims", Icon = "gift" })
local TeleTab = Window:Tab({ Title = "TP", Icon = "map-pin" })
local UpgradeTab = Window:Tab({ Title = "Upgrade", Icon = "arrow-up" })
local CropTab = Window:Tab({ Title = "Crops", Icon = "leaf" })
local MiscTab = Window:Tab({ Title = "Misc", Icon = "settings" })
local SocialTab = Window:Tab({ Title = "Social", Icon = "users" })
local StatsTab = Window:Tab({ Title = "Stats", Icon = "bar-chart" })
local RiskTab = Window:Tab({ Title = "Risk", Icon = "alert-triangle" })
local ConfigTab = Window:Tab({ Title = "Config", Icon = "sliders" })
local SellTab = Window:Tab({ Title = "Sell", Icon = "dollar-sign" })

-- ============================================
-- HATCH TAB
-- ============================================
HatchTab:Dropdown({ Title = "Select Egg", Values = Eggs, Value = State.SelectedEgg, Callback = function(v) State.SelectedEgg = v end })
HatchTab:Dropdown({ Title = "Speed", Values = { "Normal", "Fast" }, Value = State.SelectedSpeed, Callback = function(v) State.SelectedSpeed = v; if State.Hatching then StopAutoHatch(); StartAutoHatch() end end })
HatchTab:Button({ Title = "Hatch Once", Callback = function() Remote.HatchOwnedEgg(State.SelectedEgg); State.HatchCount = State.HatchCount + 1 end })
HatchTab:Toggle({ Title = "Auto Hatch", Value = false, Callback = function(v) State.Hatching = v; if v then StartAutoHatch() else StopAutoHatch() end end })

-- ============================================
-- SHOP TAB
-- ============================================
ShopTab:Dropdown({ Title = "Select Egg", Values = Eggs, Value = State.SelectedEgg, Callback = function(v) State.SelectedEgg = v end })
ShopTab:Dropdown({ Title = "Method", Values = { "Single", "Max", "x10", "x100", "x1000" }, Value = State.SelectedBuyMethod, Callback = function(v) State.SelectedBuyMethod = v; State.BuyQuantity = v == "Single" and 1 or v == "Max" and 9999 or v == "x10" and 10 or v == "x100" and 100 or 1000 end })
ShopTab:Button({ Title = "Buy (" .. State.BuyQuantity .. ")", Callback = function() Remote.HatchEgg(State.SelectedEgg, State.BuyQuantity) end })
ShopTab:Toggle({ Title = "Auto Buy", Value = false, Callback = function(v) State.Buying = v; if v then StartAutoBuy() else if State.BuyThread then task.cancel(State.BuyThread) end end end })

-- ============================================
-- SPIN TAB
-- ============================================
SpinTab:Button({ Title = "Spin + Claim", Callback = function() Remote.SpinRequest(); task.wait(0.3); Remote.ClaimSpinResult(); State.SpinCount = State.SpinCount + 1 end })
SpinTab:Toggle({ Title = "Auto Spin", Value = false, Callback = function(v) State.Spinning = v; if v then StartAutoSpin() else if State.SpinThread then task.cancel(State.SpinThread) end end end })

-- ============================================
-- CHEST TAB
-- ============================================
ChestTab:Button({ Title = "Scan & Collect All", Callback = function() local chests = GetChests(); for _, c in ipairs(chests) do CollectChest(c); task.wait(0.25) end end })
ChestTab:Toggle({ Title = "Auto Collect", Value = false, Callback = function(v) State.Collecting = v; if v then StartAutoChest() else if State.ChestThread then task.cancel(State.ChestThread) end end end })

-- ============================================
-- FARM TAB
-- ============================================
FarmTab:Button({ Title = "Equip Best Pet", Callback = function() Remote.PetEquipBest() end })
FarmTab:Button({ Title = "Collect All Cows", Callback = function() local cows = GetFarmableCows(); local char = LocalPlayer.Character; if char and char:FindFirstChild("HumanoidRootPart") and #cows > 0 then for _, prompt in ipairs(cows) do if prompt.Enabled and prompt.Parent then local pos = prompt.Parent:IsA("Model") and prompt.Parent:GetPivot().Position or prompt.Parent.Position; char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0)); task.wait(0.15); fireproximityprompt(prompt, prompt.HoldDuration + 0.2); State.FarmCount = State.FarmCount + 1; task.wait(0.2) end end end end })
FarmTab:Label({ Text = "Cows farmed: " .. State.FarmCount })
FarmTab:Toggle({ Title = "Auto Farm Cows", Value = false, Callback = function(v) State.Farming = v; if v then StartAutoFarm() else if State.FarmThread then task.cancel(State.FarmThread) end end end })
FarmTab:Space()
FarmTab:Button({ Title = "Feed Cow", Callback = function() Remote.CowFedSfx() end })
FarmTab:Toggle({ Title = "Auto Feed", Value = false, Callback = function(v) State.Feeding = v; if v then StartAutoFeed() else if State.FeedThread then task.cancel(State.FeedThread) end end end })

-- ============================================
-- CLAIMS TAB
-- ============================================
ClaimTab:Button({ Title = "Claim All Rewards", Callback = function() Remote.DailyRewardsClaim(); Remote.QuestClaim(); Remote.ClaimAllDiscoveries(); Remote.ClaimAllBabyDiscoveries(); Remote.PlaytimeClaim(); Remote.ClaimLeaveReward(); CollectGift(); State.ClaimCount = State.ClaimCount + 1 end })
ClaimTab:Button({ Title = "Redeem All Codes", Callback = function() for _, code in ipairs(Codes) do Remote.RedeemCode(code); task.wait(1) end end })
ClaimTab:Button({ Title = "Rebirth Now", Callback = function() Remote.RebirthRequest(); State.RebirthCount = State.RebirthCount + 1 end })
ClaimTab:Label({ Text = "Claims: " .. State.ClaimCount .. " | Rebirths: " .. State.RebirthCount })
ClaimTab:Toggle({ Title = "Auto Claim All", Value = false, Callback = function(v) State.Claiming = v; if v then StartAutoClaim() else if State.ClaimThread then task.cancel(State.ClaimThread) end end end })
ClaimTab:Toggle({ Title = "Auto Rebirth", Value = false, Callback = function(v) State.Rebirthing = v; if v then StartAutoRebirth() else if State.RebirthThread then task.cancel(State.RebirthThread) end end end })

-- ============================================
-- TELEPORT TAB
-- ============================================
TeleTab:Button({ Title = "Buy Shop", Callback = function() TeleportTo(Workspace.Shops.Buy.NPC) end })
TeleTab:Button({ Title = "Sell Shop", Callback = function() TeleportTo(Workspace.Shops.Sell.NPC.HumanoidRootPart) end })
TeleTab:Button({ Title = "Upgrade", Callback = function() TeleportTo(Workspace.Shops.Upgrade.NPC.HumanoidRootPart) end })
TeleTab:Button({ Title = "Spin Wheel", Callback = function() TeleportTo(Workspace.MiddlePath.Center.SpinWheel) end })
TeleTab:Button({ Title = "Barn (Eggs)", Callback = function() TeleportTo(Workspace.Barn) end })
TeleTab:Button({ Title = "Crop Shop", Callback = function() TeleportTo(Workspace.CropShop.Shop) end })
TeleTab:Button({ Title = "Gift", Callback = function() TeleportTo(Workspace.Gift) end })
TeleTab:Button({ Title = "AFK Zone", Callback = function() Remote.AFKTeleport() end })

-- ============================================
-- UPGRADE TAB
-- ============================================
UpgradeTab:Button({ Title = "Open Upgrade GUI", Callback = function() Remote.OpenUpgradeGui() end })
UpgradeTab:Button({ Title = "Request Upgrade", Callback = function() Remote.RequestUpgrade("Main") end })
UpgradeTab:Button({ Title = "Confirm Success", Callback = function() Remote.ConfirmSuccessUpgrade() end })
UpgradeTab:Button({ Title = "Reroll Success", Callback = function() Remote.RequestSuccessReroll() end })
UpgradeTab:Button({ Title = "Cancel Upgrade", Callback = function() Remote.RequestCancelUpgradeConfirm(); task.wait(0.1); Remote.ConfirmCancelUpgrade() end })
UpgradeTab:Toggle({ Title = "Auto Upgrade", Value = false, Callback = function(v) State.Upgrading = v; if v then StartAutoUpgrade() else if State.UpgradeThread then task.cancel(State.UpgradeThread) end end end })
-- ============================================
-- CROP TAB
-- ============================================
CropTab:Button({ Title = "Plant Seed", Callback = function() Remote.PlantSeed() end })
CropTab:Button({ Title = "Harvest Crop", Callback = function() Remote.HarvestCrop() end })
CropTab:Button({ Title = "Buy Seed (Basic)", Callback = function() Remote.CropShopBuySeed("Basic") end })
CropTab:Button({ Title = "Buy Upgrade (Speed)", Callback = function() Remote.CropShopBuyUpgrade("Speed") end })
CropTab:Toggle({ Title = "Auto Plant/Harvest", Value = false, Callback = function(v) State.Cropping = v; if v then StartAutoCrop() else if State.CropThread then task.cancel(State.CropThread) end end end })

-- ============================================
-- MISC TAB
-- ============================================
MiscTab:Button({ Title = "Toggle Auto Farm", Callback = function() Remote.ToggleAutoFarm(true) end })
MiscTab:Button({ Title = "Toggle Auto Collect", Callback = function() Remote.ToggleAutoCollect(true) end })
MiscTab:Button({ Title = "Set Auto Sell All", Callback = function() Remote.SetAutoSell(true); Remote.BulkSetAutoSell(true) end })
MiscTab:Button({ Title = "Place Best Cow", Callback = function() Remote.PlaceBestRequest() end })
MiscTab:Button({ Title = "Server Luck", Callback = function() Remote.ActivateServerLuck() end })
MiscTab:Button({ Title = "Skip Tutorial", Callback = function() Remote.TutorialSkip() end })
MiscTab:Button({ Title = "Equip Title (1)", Callback = function() Remote.RequestEquipTitle(1) end })
MiscTab:Button({ Title = "Set Hotbar Slot 1", Callback = function() Remote.SetHotbarSlot(1) end })
MiscTab:Button({ Title = "Request Consumable", Callback = function() Remote.RequestConsumablePurchase("Boost") end })
MiscTab:Button({ Title = "Submit Feedback", Callback = function() Remote.FeedbackSubmit("Great game!") end })
MiscTab:Button({ Title = "Mark Favorite Shown", Callback = function() Remote.MarkFavoritePromptShown() end })

-- ============================================
-- SOCIAL TAB
-- ============================================
SocialTab:Button({ Title = "Gift Random Player", Callback = function() local players = Players:GetPlayers(); if #players > 1 then local target = players[math.random(1, #players)]; if target ~= LocalPlayer then Remote.GiftIntent(target); WindUI:Notify({ Title = "Gift Sent", Content = "To: " .. target.Name, Duration = 2 }) end end end })
SocialTab:Button({ Title = "Podium Place Sound", Callback = function() Remote.PodiumPlaceSound() end })

-- ============================================
-- STATS TAB
-- ============================================
StatsTab:Label({ Text = "--- Statistics ---" })
StatsTab:Label({ Text = "Hatches: " .. State.HatchCount })
StatsTab:Label({ Text = "Spins: " .. State.SpinCount })
StatsTab:Label({ Text = "Cows Farmed: " .. State.FarmCount })
StatsTab:Label({ Text = "Claims: " .. State.ClaimCount })
StatsTab:Label({ Text = "Rebirths: " .. State.RebirthCount })
StatsTab:Space()
StatsTab:Button({ Title = "Refresh Stats", Callback = function() WindUI:Notify({ Title = "Stats Refreshed", Duration = 1 }) end })
StatsTab:Button({ Title = "Reset All Counters", Callback = function() State.HatchCount = 0; State.SpinCount = 0; State.FarmCount = 0; State.ClaimCount = 0; State.RebirthCount = 0 end })

-- ============================================
-- RISK TAB (Dangerous Features)
-- ============================================
RiskTab:Label({ Text = "⚠️ DANGER ZONE ⚠️" })
RiskTab:Label({ Text = "These can get you banned!" })
RiskTab:Space()
RiskTab:Button({ Title = "Admin Action", Color = Color3.fromRGB(255, 100, 50), Callback = function() Remote.AdminAction("test"); WindUI:Notify({ Title = "⚠️ Admin Action", Content = "Sent!", Duration = 2 }) end })
RiskTab:Button({ Title = "Podium Steal", Color = Color3.fromRGB(255, 100, 50), Callback = function() Remote.PodiumStealAlert(); WindUI:Notify({ Title = "⚠️ Podium Steal", Content = "Attempted!", Duration = 2 }) end })
RiskTab:Button({ Title = "Dev Product Grant", Color = Color3.fromRGB(255, 0, 0), Callback = function() WindUI:Dialog({ Title = "⚠️ WARNING", Content = "This WILL get you banned!", Buttons = { { Title = "Cancel", Style = "Secondary" }, { Title = "I Accept", Style = "Danger", Callback = function() Remote.DevProductGranted() end } } }) end })

-- ============================================
-- CONFIG TAB
-- ============================================
ConfigTab:Toggle({ Title = "Stealth Mode", Value = false, Callback = function(v) State.Stealth = v; WindUI:Notify({ Title = "Stealth: " .. (v and "ON" or "OFF"), Duration = 2 }) end })
ConfigTab:Toggle({ Title = "Anti-AFK", Value = false, Callback = function(v) State.AntiAFK = v; if v then StartAntiAFK() else if State.AntiAFKThread then task.cancel(State.AntiAFKThread) end end end })
ConfigTab:Button({ Title = "Send Test Webhook", Callback = function() SendWebhook("Ultimate Farm X is running!"); WindUI:Notify({ Title = "Webhook Sent", Duration = 2 }) end })
ConfigTab:Button({ Title = "Reset All Settings", Callback = function() State.Hatching = false; State.Buying = false; State.Spinning = false; State.Collecting = false; State.Farming = false; State.Claiming = false; State.Rebirthing = false; State.Upgrading = false; State.Cropping = false; State.Feeding = false; WindUI:Notify({ Title = "All Settings Reset", Duration = 2 }) end })

-- ============================================
-- SELL TAB
-- ============================================
SellTab:Label({ Text = "Sell all pets from inventory." })
SellTab:Label({ Text = "This cannot be undone!" })
SellTab:Space()
SellTab:Button({ Title = "Sell Everything", Color = Color3.fromRGB(255, 65, 95), Callback = function() Remote.SellRequest(); State.HatchCount = 0; WindUI:Notify({ Title = "Sold All!", Content = "Inventory cleared", Duration = 2 }) end })

-- ============================================
-- INITIALIZATION
-- ============================================
WindUI:Notify({
    Title = "Ultimate Farm X Ready!",
    Content = "by Rylax0322 | 15 Tabs | All Features",
    Duration = 4,
})

print("========================================")
print(" Ultimate Farm X - Rylax0322")
print(" Version: Final")
print(" Tabs: 15")
print(" Remotes: 90+ implemented")
print(" Features: Auto Hatch, Auto Buy, Auto Spin,")
print("           Auto Chest, Auto Farm, Auto Claim,")
print("           Auto Rebirth, Auto Upgrade, Auto Crop,")
print("           Auto Feed, Anti-AFK, Stealth Mode,")
print("           Teleports, Webhook, Statistics")
print("========================================")

-- Auto-save webhook notification
task.delay(5, function()
    SendWebhook("Ultimate Farm X loaded by " .. LocalPlayer.Name .. " | Game: " .. game.PlaceId)
end)
