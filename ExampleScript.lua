--[[
    Script: Egg Manager v7.0
    Author: Rylax0322
    Library: UILibrary v7.0 (Self-made)
    Features: Hatch, Shop, Spin, Chest, Sell, Settings
]]

-- Load library
local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/rickyaditya511/hac/main/UILibrary.lua"
))()

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Workspace = game:GetService("Workspace")
local Players = game.Players
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- ============================================
-- DATA
-- ============================================
local Eggs = {
    "Basic", "Elemental", "Runic", "Obsidian",
    "Galaxy", "Astral", "Celestial", "Spirit",
    "Fruit", "IceCream", "Alien", "Dino"
}

local Speeds = {
    { Name = "Slow", Delay = 1, Threads = 1 },
    { Name = "Normal", Delay = 0.3, Threads = 1 },
    { Name = "Fast", Delay = 0.05, Threads = 3 },
    { Name = "Insane", Delay = 0, Threads = 5 }
}

-- ============================================
-- STATE
-- ============================================
local SelectedEgg = "Basic"
local SelectedSpeed = "Fast"
local ShopQuantity = 9999
local SpinDelay = 1.5
local ChestDelay = 0.5

local HatchThreads = {}
local AutoHatching = false
local AutoBuying = false
local BuyThread = nil
local AutoSpinning = false
local SpinThread = nil
local AutoChesting = false
local ChestThread = nil
local AutoSellActive = false
local SellThread = nil

-- ============================================
-- REMOTE FUNCTIONS
-- ============================================
local function HatchEgg(egg)
    pcall(function()
        Remotes:WaitForChild("HatchOwnedEgg"):InvokeServer(egg)
    end)
end

local function BuyEgg(egg, qty)
    pcall(function()
        Remotes:WaitForChild("HatchEgg"):InvokeServer(egg, qty)
    end)
end

local function DoSpin()
    pcall(function()
        Remotes:WaitForChild("SpinRequest"):InvokeServer()
    end)
end

local function ClaimSpin()
    pcall(function()
        Remotes:WaitForChild("ClaimSpinResult"):InvokeServer()
    end)
end

local function GetSpinState()
    local success, result = pcall(function()
        return Remotes:WaitForChild("GetSpinState"):InvokeServer()
    end)
    return success and result or "Unknown"
end

local function SellAllPets()
    pcall(function()
        Remotes:WaitForChild("SellRequest"):FireServer("all")
    end)
end

local function GetChests()
    local chests = {}
    pcall(function()
        local folder = Workspace:FindFirstChild("ChestSpawns")
        if folder then
            for _, obj in ipairs(folder:GetChildren()) do
                if obj:IsA("BasePart") or obj:IsA("Model") then
                    table.insert(chests, obj)
                end
            end
        end
    end)
    return chests
end

local function CollectChest(chest)
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end

        local pos = chest:IsA("Model") and chest:GetPivot().Position or chest.Position
        char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))

        task.wait(0.2)
        local prompts = chest:IsA("Model") and chest:GetDescendants() or { chest }
        for _, obj in ipairs(prompts) do
            if obj:IsA("ProximityPrompt") then
                fireproximityprompt(obj, obj.HoldDuration + 0.3)
            end
        end
    end)
end

-- ============================================
-- AUTO FUNCTIONS
-- ============================================
local function StopAutoHatch()
    for _, t in ipairs(HatchThreads) do
        task.cancel(t)
    end
    HatchThreads = {}
end

local function StartAutoHatch()
    StopAutoHatch()
    local speedCfg = nil
    for _, s in ipairs(Speeds) do
        if s.Name == SelectedSpeed then speedCfg = s; break end
    end
    if not speedCfg then return end

    for _ = 1, speedCfg.Threads do
        local t = task.spawn(function()
            while AutoHatching do
                HatchEgg(SelectedEgg)
                if speedCfg.Delay > 0 then
                    task.wait(speedCfg.Delay)
                else
                    task.wait()
                end
            end
        end)
        table.insert(HatchThreads, t)
    end
end

local function StartAutoBuy()
    if BuyThread then task.cancel(BuyThread) end
    BuyThread = task.spawn(function()
        while AutoBuying do
            BuyEgg(SelectedEgg, ShopQuantity)
            task.wait(0.3)
        end
    end)
end

local function StartAutoSpin()
    if SpinThread then task.cancel(SpinThread) end
    SpinThread = task.spawn(function()
        while AutoSpinning do
            DoSpin()
            task.wait(0.3)
            ClaimSpin()
            task.wait(SpinDelay)
        end
    end)
end

local function StartAutoChest()
    if ChestThread then task.cancel(ChestThread) end
    ChestThread = task.spawn(function()
        while AutoChesting do
            local chests = GetChests()
            for _, chest in ipairs(chests) do
                if not AutoChesting then break end
                CollectChest(chest)
                task.wait(ChestDelay)
            end
            task.wait(1)
        end
    end)
end

local function StartAutoSell()
    if SellThread then task.cancel(SellThread) end
    SellThread = task.spawn(function()
        while AutoSellActive do
            SellAllPets()
            task.wait(5)
        end
    end)
end

-- ============================================
-- CREATE WINDOW
-- ============================================
local Window = UI:CreateWindow({
    Title = "Rylax0322 - Egg Manager",
    Game = "Pet RNG",
    Version = "v7.0",
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift,
})

-- Enable config save (if supported)
UI.Config.AutoUpdateCheck = true

-- ============================================
-- WATERMARK
-- ============================================
UI.WatermarkSystem.Create(Window, {
    Text = "Egg Manager | Rylax0322",
    Position = "TopRight",
    Color = UI.Colors.Blue,
})

-- ============================================
-- TAB 1: HATCH
-- ============================================
local HatchTab = Window:AddTab({ Name = "Hatch", Icon = "egg" })

local HatchSection = HatchTab:AddSection({ Name = "Egg Hatcher", Side = "left" })

local EggDropdown = HatchSection:AddDropdown({
    Name = "Select Egg",
    Options = Eggs,
    Default = SelectedEgg,
    Callback = function(v)
        SelectedEgg = v
        Window:Notify({ Title = "Egg Selected", Content = v, Duration = 1.5 })
    end,
})

HatchSection:AddButton({
    Name = "Hatch Once",
    Style = "Primary",
    Callback = function()
        HatchEgg(SelectedEgg)
        Window:Notify({
            Title = "Egg Hatched",
            Content = "Hatched: " .. SelectedEgg,
            Duration = 2,
            Type = "success",
        })
    end,
})

local SpeedDropdown = HatchSection:AddDropdown({
    Name = "Speed Mode",
    Options = {"Slow", "Normal", "Fast", "Insane"},
    Default = SelectedSpeed,
    Callback = function(v)
        SelectedSpeed = v
        if AutoHatching then
            StopAutoHatch()
            StartAutoHatch()
        end
    end,
})

local HatchToggle = HatchSection:AddToggle({
    Name = "Auto Hatch",
    Default = false,
    Callback = function(v)
        AutoHatching = v
        if v then
            StartAutoHatch()
            Window:Notify({
                Title = "Auto Hatch Started",
                Content = "Speed: " .. SelectedSpeed,
                Duration = 2,
                Type = "success",
            })
        else
            StopAutoHatch()
            Window:Notify({
                Title = "Auto Hatch Stopped",
                Duration = 2,
            })
        end
    end,
})

-- Stats section
local HatchStatsSection = HatchTab:AddSection({ Name = "Hatch Stats", Side = "right" })

local HatchCount = 0
local HatchCountLabel = HatchStatsSection:AddLabel({ Text = "Total Hatched: 0" })

local LastHatchLabel = HatchStatsSection:AddLabel({ Text = "Last Hatch: None" })

HatchStatsSection:AddButton({
    Name = "Reset Counter",
    Style = "Secondary",
    Callback = function()
        HatchCount = 0
        HatchCountLabel:Set("Total Hatched: 0")
        LastHatchLabel:Set("Last Hatch: None")
    end,
})

-- Update counter on hatch
local OriginalHatchEgg = HatchEgg
HatchEgg = function(egg)
    OriginalHatchEgg(egg)
    HatchCount = HatchCount + 1
    HatchCountLabel:Set("Total Hatched: " .. HatchCount)
    LastHatchLabel:Set("Last Hatch: " .. egg)
end

-- ============================================
-- TAB 2: SHOP
-- ============================================
local ShopTab = Window:AddTab({ Name = "Shop", Icon = "cart" })

local ShopSection = ShopTab:AddSection({ Name = "Egg Shop", Side = "left" })

local ShopEggDropdown = ShopSection:AddDropdown({
    Name = "Select Egg",
    Options = Eggs,
    Default = SelectedEgg,
    Callback = function(v) SelectedEgg = v end,
})

ShopSection:AddLabel({ Text = "Quantity per purchase: " .. ShopQuantity .. " (Maximum)" })

ShopSection:AddButton({
    Name = "Buy Maximum",
    Style = "Success",
    Callback = function()
        BuyEgg(SelectedEgg, ShopQuantity)
        Window:Notify({
            Title = "Purchase Complete",
            Content = SelectedEgg .. " x" .. ShopQuantity,
            Duration = 2,
            Type = "success",
        })
    end,
})

local AutoBuyToggle = ShopSection:AddToggle({
    Name = "Auto Buy",
    Default = false,
    Callback = function(v)
        AutoBuying = v
        if v then
            StartAutoBuy()
            Window:Notify({ Title = "Auto Buy Started", Duration = 2, Type = "success" })
        else
            if BuyThread then task.cancel(BuyThread) end
            Window:Notify({ Title = "Auto Buy Stopped", Duration = 2 })
        end
    end,
})

local ShopInfoSection = ShopTab:AddSection({ Name = "Information", Side = "right" })

ShopInfoSection:AddLabel({ Text = "Shop allows you to buy eggs in bulk." })
ShopInfoSection:AddLabel({ Text = "Maximum quantity: 9999 per purchase." })
ShopInfoSection:AddLabel({ Text = "Auto buy purchases every 0.3 seconds." })

-- ============================================
-- TAB 3: SPIN
-- ============================================
local SpinTab = Window:AddTab({ Name = "Spin", Icon = "rotate-cw" })

local SpinSection = SpinTab:AddSection({ Name = "Spin Wheel", Side = "left" })

SpinSection:AddButton({
    Name = "Check Spin State",
    Style = "Secondary",
    Callback = function()
        local state = GetSpinState()
        Window:Notify({
            Title = "Spin State",
            Content = "State: " .. tostring(state),
            Duration = 3,
        })
    end,
})

SpinSection:AddButton({
    Name = "Spin & Claim",
    Style = "Primary",
    Callback = function()
        DoSpin()
        task.wait(0.3)
        ClaimSpin()
        Window:Notify({
            Title = "Spin Complete",
            Content = "Result claimed!",
            Duration = 2,
            Type = "success",
        })
    end,
})

local SpinDelaySlider = SpinSection:AddSlider({
    Name = "Spin Delay",
    Min = 0.5,
    Max = 5,
    Default = SpinDelay,
    Suffix = "s",
    Callback = function(v)
        SpinDelay = v
    end,
})

local AutoSpinToggle = SpinSection:AddToggle({
    Name = "Auto Spin",
    Default = false,
    Callback = function(v)
        AutoSpinning = v
        if v then
            StartAutoSpin()
            Window:Notify({
                Title = "Auto Spin Started",
                Content = "Delay: " .. SpinDelay .. "s",
                Duration = 2,
                Type = "success",
            })
        else
            if SpinThread then task.cancel(SpinThread) end
            Window:Notify({ Title = "Auto Spin Stopped", Duration = 2 })
        end
    end,
})

local SpinInfoSection = SpinTab:AddSection({ Name = "Spin Info", Side = "right" })

SpinInfoSection:AddLabel({ Text = "Spin to get rewards!" })
SpinInfoSection:AddLabel({ Text = "Auto spin includes spin + claim." })
SpinInfoSection:AddLabel({ Text = "Adjust delay to avoid rate limits." })

SpinInfoSection:AddProgressBar({
    Name = "Spin Progress",
    Value = 0,
    Max = 100,
    Color = UI.Colors.Purple,
})

-- ============================================
-- TAB 4: CHEST
-- ============================================
local ChestTab = Window:AddTab({ Name = "Chest", Icon = "package" })

local ChestSection = ChestTab:AddSection({ Name = "Chest Collector", Side = "left" })

local ChestCountLabel = ChestSection:AddLabel({ Text = "Chests found: 0" })

ChestSection:AddButton({
    Name = "Refresh Chest List",
    Style = "Secondary",
    Callback = function()
        local chests = GetChests()
        ChestCountLabel:Set("Chests found: " .. #chests)
        Window:Notify({
            Title = "Chests Found",
            Content = "Found " .. #chests .. " chests",
            Duration = 2,
        })
    end,
})

ChestSection:AddButton({
    Name = "Collect All Chests",
    Style = "Primary",
    Callback = function()
        local chests = GetChests()
        for i, chest in ipairs(chests) do
            CollectChest(chest)
            task.wait(0.3)
        end
        Window:Notify({
            Title = "Collection Complete",
            Content = "Collected " .. #chests .. " chests",
            Duration = 2,
            Type = "success",
        })
    end,
})

local ChestDelaySlider = ChestSection:AddSlider({
    Name = "Collection Delay",
    Min = 0.1,
    Max = 3,
    Default = ChestDelay,
    Suffix = "s",
    Callback = function(v)
        ChestDelay = v
    end,
})

local AutoChestToggle = ChestSection:AddToggle({
    Name = "Auto Collect",
    Default = false,
    Callback = function(v)
        AutoChesting = v
        if v then
            StartAutoChest()
            Window:Notify({
                Title = "Auto Collect Started",
                Content = "Delay: " .. ChestDelay .. "s",
                Duration = 2,
                Type = "success",
            })
        else
            if ChestThread then task.cancel(ChestThread) end
            Window:Notify({ Title = "Auto Collect Stopped", Duration = 2 })
        end
    end,
})

local ChestListSection = ChestTab:AddSection({ Name = "Chest List", Side = "right" })

local ChestListView = ChestListSection:AddListView({
    Name = "Nearby Chests",
    Items = {},
    Height = 150,
    Callback = function(chestName, index)
        local chests = GetChests()
        if chests[index] then
            CollectChest(chests[index])
            Window:Notify({ Title = "Collecting", Content = chestName, Duration = 2 })
        end
    end,
})

-- Update chest list periodically
task.spawn(function()
    while Window._mainFrame and Window._mainFrame.Parent do
        local chests = GetChests()
        local chestNames = {}
        for i, chest in ipairs(chests) do
            table.insert(chestNames, "Chest #" .. i .. " - " .. chest.Name)
        end
        ChestListView:SetItems(chestNames)
        ChestCountLabel:Set("Chests found: " .. #chests)
        task.wait(3)
    end
end)

-- ============================================
-- TAB 5: SELL
-- ============================================
local SellTab = Window:AddTab({ Name = "Sell", Icon = "dollar" })

local SellSection = SellTab:AddSection({ Name = "Sell Inventory", Side = "left" })

SellSection:AddLabel({ Text = "Sell all pets from your inventory." })
SellSection:AddLabel({ Text = "Warning: This action cannot be undone!" })

SellSection:AddButton({
    Name = "Sell Everything",
    Style = "Danger",
    Callback = function()
        Window:Dialog({
            Title = "Confirm Sale",
            Content = "Are you sure you want to sell ALL pets? This cannot be undone!",
            Buttons = {
                { Title = "Cancel", Style = "Secondary" },
                { Title = "Sell All", Style = "Danger", Callback = function()
                    SellAllPets()
                    Window:Notify({
                        Title = "Inventory Cleared",
                        Content = "All pets have been sold.",
                        Duration = 3,
                        Type = "warning",
                    })
                end },
            },
        })
    end,
})

local AutoSellToggle = SellSection:AddToggle({
    Name = "Auto Sell (every 5s)",
    Default = false,
    Callback = function(v)
        AutoSellActive = v
        if v then
            StartAutoSell()
            Window:Notify({ Title = "Auto Sell Started", Duration = 2, Type = "warning" })
        else
            if SellThread then task.cancel(SellThread) end
            Window:Notify({ Title = "Auto Sell Stopped", Duration = 2 })
        end
    end,
})

local SellInfoSection = SellTab:AddSection({ Name = "Sell Information", Side = "right" })

SellInfoSection:AddLabel({ Text = "Selling pets gives you coins." })
SellInfoSection:AddLabel({ Text = "Use wisely - rare pets are valuable!" })
SellInfoSection:AddLabel({ Text = "Auto sell runs every 5 seconds." })

-- ============================================
-- TAB 6: SETTINGS
-- ============================================
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings" })

local ThemeSection = SettingsTab:AddSection({ Name = "Appearance", Side = "left" })

ThemeSection:AddDropdown({
    Name = "Theme",
    Options = {"Dark", "Light", "Midnight", "Emerald", "Rose"},
    Default = "Dark",
    Callback = function(v)
        Window:SetTheme(v)
        Window:Notify({ Title = "Theme Changed", Content = v .. " theme applied", Duration = 2 })
    end,
})

ThemeSection:AddColorPicker({
    Name = "Accent Color",
    Default = UI.Colors.Blue,
    Callback = function(color)
        -- Store accent preference
    end,
})

local MiscSection = SettingsTab:AddSection({ Name = "Misc", Side = "right" })

MiscSection:AddKeybind({
    Name = "Toggle GUI",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key)
        Window:Notify({ Title = "Keybind Set", Content = "GUI toggle: " .. key.Name, Duration = 2 })
    end,
})

MiscSection:AddToggle({
    Name = "Show Notifications",
    Default = true,
    Callback = function(v)
        UI.Config.NotificationsEnabled = v
    end,
})

MiscSection:AddButton({
    Name = "Reset All Settings",
    Style = "Warning",
    Callback = function()
        Window:Dialog({
            Title = "Reset Settings?",
            Content = "This will reset all settings to default.",
            Buttons = {
                { Title = "Cancel", Style = "Secondary" },
                { Title = "Reset", Style = "Danger", Callback = function()
                    SelectedEgg = "Basic"
                    SelectedSpeed = "Fast"
                    SpinDelay = 1.5
                    ChestDelay = 0.5
                    EggDropdown:Set("Basic")
                    SpeedDropdown:Set("Fast")
                    SpinDelaySlider:Set(1.5)
                    ChestDelaySlider:Set(0.5)
                    Window:Notify({ Title = "Settings Reset", Duration = 2, Type = "success" })
                end },
            },
        })
    end,
})

MiscSection:AddButton({
    Name = "Show Library Info",
    Style = "Secondary",
    Callback = function()
        UI:Debug()
        Window:Notify({ Title = "Info Printed", Content = "Check console (F9)", Duration = 3 })
    end,
})

-- ============================================
-- LOADED NOTIFICATION
-- ============================================
task.delay(0.5, function()
    Window:Notify({
        Title = "Egg Manager v7.0",
        Content = "by Rylax0322 | Library loaded",
        Duration = 4,
        Type = "success",
    })
    
    print("========================================")
    print(" Egg Manager v7.0 Loaded!")
    print(" Author: Rylax0322")
    print(" Eggs: " .. #Eggs .. " available")
    print(" Speed Modes: Slow, Normal, Fast, Insane")
    print(" Tabs: Hatch, Shop, Spin, Chest, Sell, Settings")
    print("========================================")
    print(" Press RightShift to minimize/restore")
    print(" Click sidebar button to toggle menu")
    print(" Drag corner to resize window")
    print("========================================")
end)

-- ============================================
-- AUTO-SAVE (if supported)
-- ============================================
if writefile then
    task.delay(2, function()
        UI.ConfigSystem.Save(Window, "EggManager_AutoSave")
    end)
end

-- ============================================
-- CLEANUP ON CLOSE
-- ============================================
-- (Library handles this automatically)
