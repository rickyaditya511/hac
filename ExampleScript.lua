-- ============================================
-- EGG MANAGER - Using ChiyoLib UI Library
-- ============================================

local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/rickyaditya511/hac/refs/heads/main/UILibrary.lua"
))()

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Workspace = game:GetService("Workspace")
local Players = game.Players
local RunService = game:GetService("RunService")

-- Safe call wrapper
local function safeCall(func)
    return function(...)
        pcall(func, ...)
    end
end

-- ==================== DATA ====================
local eggs = {
    "Basic", "Elemental", "Runic", "Obsidian", "Galaxy", "Astral",
    "Celestial", "Spirit", "Fruit", "IceCream", "Alien", "Dino"
}

local speeds = {
    { name = "SLOW", delay = 1, threads = 1 },
    { name = "NORMAL", delay = 0.3, threads = 1 },
    { name = "FAST", delay = 0.05, threads = 3 },
    { name = "INSANE", delay = 0, threads = 5 }
}

-- ==================== STATE ====================
local selectedEgg = "Basic"
local selectedSpeed = "FAST"
local shopQuantity = 9999

local autoHatchActive = false
local autoHatchThreads = {}
local autoBuyActive = false
local autoBuyThread = nil
local autoSpinActive = false
local autoSpinThread = nil
local autoChestActive = false
local autoChestThread = nil

-- ==================== FUNCTIONS ====================
local function hatchEgg(egg)
    Remotes:WaitForChild("HatchOwnedEgg"):InvokeServer(egg)
end

local function buyEgg(egg, qty)
    Remotes:WaitForChild("HatchEgg"):InvokeServer(egg, qty)
end

local function spinOnce()
    Remotes:WaitForChild("SpinRequest"):InvokeServer()
end

local function claimSpinResult()
    Remotes:WaitForChild("ClaimSpinResult"):InvokeServer()
end

local function sellAllPets()
    Remotes:WaitForChild("SellRequest"):FireServer("all")
end

local function getChests()
    local chests = {}
    local folder = Workspace:FindFirstChild("ChestSpawns")
    if folder then
        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                table.insert(chests, obj)
            end
        end
    end
    return chests
end

local function collectChest(chest)
    local char = Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    -- Teleport
    local pos = chest:IsA("Model") and chest:GetPivot().Position or chest.Position
    char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    
    -- Trigger prompt
    task.wait(0.2)
    local prompts = chest:IsA("Model") and chest:GetDescendants() or { chest }
    for _, obj in ipairs(prompts) do
        if obj:IsA("ProximityPrompt") then
            fireproximityprompt(obj, obj.HoldDuration + 0.5)
        end
    end
end

-- ==================== AUTO FUNCTIONS ====================
local function stopAutoHatch()
    for _, t in ipairs(autoHatchThreads) do
        task.cancel(t)
    end
    autoHatchThreads = {}
end

local function startAutoHatch()
    stopAutoHatch()
    local speed = nil
    for _, s in ipairs(speeds) do
        if s.name == selectedSpeed then speed = s break end
    end
    if not speed then return end
    
    for _ = 1, speed.threads do
        local thread = task.spawn(function()
            while autoHatchActive do
                hatchEgg(selectedEgg)
                if speed.delay > 0 then
                    task.wait(speed.delay)
                else
                    task.wait()
                end
            end
        end)
        table.insert(autoHatchThreads, thread)
    end
end

local function startAutoBuy()
    if autoBuyThread then task.cancel(autoBuyThread) end
    autoBuyThread = task.spawn(function()
        while autoBuyActive do
            buyEgg(selectedEgg, shopQuantity)
            task.wait(0.3)
        end
    end)
end

local function startAutoSpin()
    if autoSpinThread then task.cancel(autoSpinThread) end
    autoSpinThread = task.spawn(function()
        while autoSpinActive do
            spinOnce()
            task.wait(0.3)
            claimSpinResult()
            task.wait(0.8)
        end
    end)
end

local function startAutoChest()
    if autoChestThread then task.cancel(autoChestThread) end
    autoChestThread = task.spawn(function()
        while autoChestActive do
            local chests = getChests()
            for _, chest in ipairs(chests) do
                if not autoChestActive then break end
                collectChest(chest)
                task.wait(0.5)
            end
            task.wait(1)
        end
    end)
end

-- ==================== CREATE WINDOW ====================
local Window = UI:CreateWindow({
    Title = "Egg Manager",
    Game = "Pet RNG",
    Discord = "discord.gg/example",
    Version = "v1.0",
    MinimizeKey = Enum.KeyCode.RightShift,
})

-- ==================== TAB 1: HATCH ====================
local HatchTab = Window:AddTab({ Name = "🎲 Hatch", Icon = "🥚" })

-- Egg Selector Section
local EggSelectSection = HatchTab:AddSection({ Name = "Select Egg", Side = "left" })

local EggDropdown = EggSelectSection:AddDropdown({
    Name = "Egg",
    Options = eggs,
    Default = selectedEgg,
    Callback = function(v)
        selectedEgg = v
        print("Selected egg:", v)
    end,
})

EggSelectSection:AddButton({
    Name = "🎲 Hatch Once",
    Color = Color3.fromRGB(0, 180, 255),
    Callback = function()
        hatchEgg(selectedEgg)
        Window:Notify({
            Title = "Hatched!",
            Desc = "Hatched: " .. selectedEgg,
            Duration = 2,
        })
    end,
})

-- Speed Selector
EggSelectSection:AddDropdown({
    Name = "Speed Mode",
    Options = { "SLOW", "NORMAL", "FAST", "INSANE" },
    Default = selectedSpeed,
    Callback = function(v)
        selectedSpeed = v
        if autoHatchActive then
            stopAutoHatch()
            startAutoHatch()
        end
    end,
})

-- Auto Hatch Section
local AutoSection = HatchTab:AddSection({ Name = "Auto Hatch", Side = "right" })

AutoSection:AddToggle({
    Name = "Auto Hatch",
    Default = false,
    Callback = function(v)
        autoHatchActive = v
        if v then
            startAutoHatch()
            Window:Notify({
                Title = "Auto Hatch ON",
                Desc = "Speed: " .. selectedSpeed,
                Duration = 2,
                Color = Color3.fromRGB(80, 220, 130),
            })
        else
            stopAutoHatch()
        end
    end,
})

AutoSection:AddLabel({ Text = "Status: " .. (autoHatchActive and "🟢 Active" or "🔴 Inactive") })
AutoSection:AddLabel({ Text = "Egg: " .. selectedEgg .. " | Speed: " .. selectedSpeed })

-- ==================== TAB 2: SHOP ====================
local ShopTab = Window:AddTab({ Name = "🛒 Shop", Icon = "💰" })

local BuySection = ShopTab:AddSection({ Name = "Buy Eggs", Side = "left" })

BuySection:AddDropdown({
    Name = "Egg",
    Options = eggs,
    Default = selectedEgg,
    Callback = function(v)
        selectedEgg = v
    end,
})

BuySection:AddLabel({ Text = "Quantity: " .. shopQuantity .. " (MAX)" })

BuySection:AddButton({
    Name = "🛒 Buy Max",
    Color = Color3.fromRGB(255, 170, 0),
    Callback = function()
        buyEgg(selectedEgg, shopQuantity)
        Window:Notify({
            Title = "Bought!",
            Desc = selectedEgg .. " x" .. shopQuantity,
            Duration = 2,
            Color = Color3.fromRGB(255, 170, 0),
        })
    end,
})

local AutoBuySection = ShopTab:AddSection({ Name = "Auto Buy", Side = "right" })

AutoBuySection:AddToggle({
    Name = "Auto Buy",
    Default = false,
    Callback = function(v)
        autoBuyActive = v
        if v then
            startAutoBuy()
            Window:Notify({
                Title = "Auto Buy ON",
                Desc = "Buying: " .. selectedEgg,
                Duration = 2,
                Color = Color3.fromRGB(80, 220, 130),
            })
        else
            if autoBuyThread then
                task.cancel(autoBuyThread)
                autoBuyThread = nil
            end
        end
    end,
})

AutoBuySection:AddLabel({ Text = "Status: " .. (autoBuyActive and "🟢 Active" or "🔴 Inactive") })

-- ==================== TAB 3: SPIN ====================
local SpinTab = Window:AddTab({ Name = "🎰 Spin", Icon = "🎪" })

local SpinSection = SpinTab:AddSection({ Name = "Spin Controls", Side = "left" })

SpinSection:AddButton({
    Name = "🎰 Spin",
    Color = Color3.fromRGB(150, 50, 255),
    Callback = function()
        spinOnce()
        task.wait(0.3)
        claimSpinResult()
        Window:Notify({
            Title = "Spun!",
            Desc = "Spin completed",
            Duration = 2,
            Color = Color3.fromRGB(150, 50, 255),
        })
    end,
})

SpinSection:AddButton({
    Name = "🏆 Claim Result",
    Color = Color3.fromRGB(50, 200, 100),
    Callback = function()
        claimSpinResult()
    end,
})

local AutoSpinSection = SpinTab:AddSection({ Name = "Auto Spin", Side = "right" })

AutoSpinSection:AddToggle({
    Name = "Auto Spin",
    Default = false,
    Callback = function(v)
        autoSpinActive = v
        if v then
            startAutoSpin()
        else
            if autoSpinThread then
                task.cancel(autoSpinThread)
                autoSpinThread = nil
            end
        end
    end,
})

AutoSpinSection:AddLabel({ Text = "Status: " .. (autoSpinActive and "🟢 Active" or "🔴 Inactive") })

-- ==================== TAB 4: CHEST ====================
local ChestTab = Window:AddTab({ Name = "📦 Chest", Icon = "🎁" })

local ChestSection = ChestTab:AddSection({ Name = "Chest Collector", Side = "left" })

ChestSection:AddButton({
    Name = "🔄 Refresh Chests",
    Callback = function()
        local chests = getChests()
        Window:Notify({
            Title = "Chests Found",
            Desc = "Found: " .. #chests .. " chests",
            Duration = 2,
        })
    end,
})

ChestSection:AddButton({
    Name = "📦 Collect All Chests",
    Color = Color3.fromRGB(255, 170, 0),
    Callback = function()
        local chests = getChests()
        for i, chest in ipairs(chests) do
            collectChest(chest)
            task.wait(0.3)
        end
        Window:Notify({
            Title = "Collected!",
            Desc = "Collected " .. #chests .. " chests",
            Duration = 2,
            Color = Color3.fromRGB(80, 220, 130),
        })
    end,
})

local AutoChestSection = ChestTab:AddSection({ Name = "Auto Collect", Side = "right" })

AutoChestSection:AddToggle({
    Name = "Auto Collect Chests",
    Default = false,
    Callback = function(v)
        autoChestActive = v
        if v then
            startAutoChest()
        else
            if autoChestThread then
                task.cancel(autoChestThread)
                autoChestThread = nil
            end
        end
    end,
})

AutoChestSection:AddLabel({ Text = "Status: " .. (autoChestActive and "🟢 Active" or "🔴 Inactive") })

-- ==================== TAB 5: SELL ====================
local SellTab = Window:AddTab({ Name = "💰 Sell", Icon = "💵" })

local SellSection = SellTab:AddSection({ Name = "Sell Pets", Side = "left" })

SellSection:AddButton({
    Name = "💰 SELL ALL",
    Color = Color3.fromRGB(255, 50, 50),
    Callback = function()
        sellAllPets()
        Window:Notify({
            Title = "Sold!",
            Desc = "All pets sold!",
            Duration = 2,
            Color = Color3.fromRGB(80, 220, 130),
        })
    end,
})

SellSection:AddLabel({ Text = "Sells all pets in inventory using SellRequest('all')" })
SellSection:AddLabel({ Text = "⚠️ This action cannot be undone!" })

-- ==================== NOTIFICATION ====================
task.delay(1, function()
    Window:Notify({
        Title = "Egg Manager Loaded!",
        Desc = "All features ready. Press RightShift to minimize.",
        Duration = 5,
        Color = Color3.fromRGB(80, 130, 240),
    })
end)

print("✅ Egg Manager loaded with ChiyoLib!")
print("🥚 " .. #eggs .. " eggs | 5 tabs | Full features")
