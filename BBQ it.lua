-- ============================================
-- BBQ MASTERY - FIXED VERSION
-- Using Rick UI Library
-- ============================================

local RickUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/rickyaditya511/hac/main/Rick_UI_fix.lua"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer

-- ============================================
-- WAIT FOR CHARACTER
-- ============================================
if not player.Character then
    player.CharacterAdded:Wait()
end
task.wait(0.5)

-- ============================================
-- CONFIGURATION
-- ============================================
local Config = {
    AutoCook = false,
    AutoPlate = false,
    AutoSell = false,
    AutoBuyMeat = false,
    AutoBuyTotem = false,
    InstantPrompt = false,
    ActionDelay = 0.3,
    BuyThreshold = 5
}

local MeatStates = {}
local LastBuyTime = {}
local BuyMeatTargets = {}
local BuyTotemTargets = {}

-- ============================================
-- REMOTE HANDLER
-- ============================================
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local function FireRemote(remoteName, ...)
    if not Remotes then return false end
    local remote = Remotes:FindFirstChild(remoteName)
    if not remote then return false end
    pcall(function() remote:FireServer(...) end)
    return true
end

-- ============================================
-- MEAT & TOTEM OPTIONS
-- ============================================
local MeatOptions = {
    "Raw Hotdog", "Raw Burger", "Raw Chicken", "Raw Salmon",
    "Raw Ribs", "Raw Prime Rib", "Raw Brisket", "Raw Lobster Tail",
    "Raw Bigfoot Filet", "Raw Dragon", "Raw Demon", "Raw Whole Unicorn"
}

local TotemOptions = {
    "Gold Totem", "Salt and Pepper Totem", "Totem of Small Growth",
    "Totem of Growth", "Totem of Great Growth", "Speed Totem",
    "Luck Totem", "Diamond Totem", "Ruby Totem"
}

-- Dynamic fetch with pcall
pcall(function()
    local MeatsFolder = ReplicatedStorage:FindFirstChild("Meats")
    if MeatsFolder then
        for _, rarity in ipairs(MeatsFolder:GetChildren()) do
            for _, tool in ipairs(rarity:GetChildren()) do
                if tool:IsA("Tool") and not table.find(MeatOptions, tool.Name) then
                    table.insert(MeatOptions, tool.Name)
                end
            end
        end
    end
    
    local TotemsFolder = ReplicatedStorage:FindFirstChild("Totems")
    if TotemsFolder then
        for _, t in ipairs(TotemsFolder:GetChildren()) do
            if not table.find(TotemOptions, t.Name) then
                table.insert(TotemOptions, t.Name)
            end
        end
    end
end)

-- Initialize targets
for _, m in ipairs(MeatOptions) do BuyMeatTargets[m] = false end
for _, t in ipairs(TotemOptions) do BuyTotemTargets[t] = false end

-- ============================================
-- INSTANT PROMPT
-- ============================================
if ProximityPromptService then
    ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, playerActed)
        if Config.InstantPrompt and playerActed == player then
            if fireproximityprompt then
                fireproximityprompt(prompt)
            elseif prompt then
                prompt.HoldDuration = 0
            end
        end
    end)
end

-- ============================================
-- REMOTE LISTENERS
-- ============================================
if Remotes then
    local cookUpdate = Remotes:FindFirstChild("CookUpdate")
    if cookUpdate then
        cookUpdate.OnClientEvent:Connect(function(spot, _, _, state)
            if spot then MeatStates[spot] = state end
        end)
    end
    
    local npcOffer = Remotes:FindFirstChild("NPCOffer")
    if npcOffer then
        npcOffer.OnClientEvent:Connect(function(_, _, _, offerId)
            if Config.AutoSell and offerId then
                task.wait(math.random(3, 6) / 10)
                FireRemote("NPCResponse", offerId, true)
            end
        end)
    end
end

-- ============================================
-- HELPER FUNCTIONS (FIXED)
-- ============================================
local function IsSpotEmpty(spot)
    if not spot then return true end
    for _, child in ipairs(spot:GetChildren()) do
        if child:IsA("Model") or child:IsA("BasePart") then return false end
        if child:IsA("ProximityPrompt") then
            local text = string.lower(child.ActionText or "")
            if text:find("pick up") or text:find("take") then return false end
        end
    end
    return true
end

local function GetAndEquipMeat(typeFilter)
    local char = player.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local bp = player:FindFirstChild("Backpack")
    if not hum or not bp then return nil end
    
    local function IsValid(tool)
        if not tool or not tool:IsA("Tool") then return false end
        local name = string.lower(tool.Name or "")
        if name:find("hammer") then return false end
        local cooked = name:find("cooked") or name:find("perfect") or name:find("[")
        local raw = name:find("raw ")
        if typeFilter == "Raw" and raw and not cooked then return true end
        if typeFilter == "Cooked" and cooked then return true end
        return false
    end
    
    for _, tool in ipairs(char:GetChildren()) do
        if IsValid(tool) then return tool end
    end
    
    for _, tool in ipairs(bp:GetChildren()) do
        if IsValid(tool) then
            hum:EquipTool(tool)
            task.wait(0.1)
            return tool
        end
    end
    return nil
end

local function CountMeatStock(meatName)
    local count = 0
    local function Scan(folder)
        if not folder then return end
        for _, item in ipairs(folder:GetChildren()) do
            if item:IsA("Tool") then
                local itemName = string.lower(item.Name or "")
                local targetName = string.lower(meatName)
                if string.find(itemName, targetName, 1, true) then
                    local match = string.match(item.Name, "%(x(%d+)%)")
                    count = count + (match and tonumber(match) or 1)
                end
            end
        end
    end
    Scan(player.Character)
    Scan(player:FindFirstChild("Backpack"))
    return count
end

local function GetCleanName(tool)
    if not tool then return "" end
    local name = tool.Name
    -- Remove (x123) suffix safely
    name = name:gsub("%s*%([xX]%d+%)", "")
    -- Trim whitespace
    name = name:match("^%s*(.-)%s*$") or name
    return name
end

local function CanBuy(itemName)
    if CountMeatStock(itemName) >= Config.BuyThreshold then return false end
    if tick() - (LastBuyTime[itemName] or 0) < 3 then return false end
    return true
end

local function SmartBuy(itemName, isTotem)
    if not CanBuy(itemName) then return end
    LastBuyTime[itemName] = tick()
    if isTotem then
        FireRemote("BuyShopItem", itemName, false)
    else
        FireRemote("BuyMeat", itemName, false)
    end
end

-- ============================================
-- CLEAR YARD FUNCTION
-- ============================================
local function ClearYard()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local bp = player:FindFirstChild("Backpack")
    
    local function EquipHammer()
        for _, tool in ipairs(char:GetChildren()) do
            if string.find(string.lower(tool.Name or ""), "hammer") then return true end
        end
        if bp and hum then
            for _, tool in ipairs(bp:GetChildren()) do
                if string.find(string.lower(tool.Name or ""), "hammer") then
                    hum:EquipTool(tool)
                    task.wait(0.2)
                    return true
                end
            end
        end
        return false
    end
    
    if not EquipHammer() then
        RickUI:Notify({Title = "Error", Content = "Need Hammer in inventory!", Duration = 3})
        return
    end
    
    local playerLots = Workspace:FindFirstChild("PlayerLots")
    if playerLots then
        local lot = playerLots:FindFirstChild(player.Name)
        if lot then
            for _, item in ipairs(lot:GetChildren()) do
                for _, prompt in ipairs(item:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        local text = string.lower(prompt.ActionText or "")
                        if text:find("pick") or text:find("take") then
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            elseif prompt then
                                prompt:InputHoldBegin()
                                task.wait(0.05)
                                prompt:InputHoldEnd()
                            end
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
    end
    
    RickUI:Notify({Title = "Yard Cleared", Content = "All items picked up!", Duration = 2})
end

-- ============================================
-- MAIN LOOPS
-- ============================================
task.spawn(function()
    while task.wait(Config.ActionDelay) do
        local playerLots = Workspace:FindFirstChild("PlayerLots")
        if not playerLots then continue end
        local lot = playerLots:FindFirstChild(player.Name)
        if not lot then continue end
        
        if Config.AutoCook then
            for _, furniture in ipairs(lot:GetChildren()) do
                local grillSpots = furniture:FindFirstChild("GrillSpots")
                if grillSpots then
                    for _, spot in ipairs(grillSpots:GetChildren()) do
                        if IsSpotEmpty(spot) then
                            local rawMeat = GetAndEquipMeat("Raw")
                            if rawMeat then
                                FireRemote("PlaceMeat", spot, GetCleanName(rawMeat))
                                task.wait(Config.ActionDelay)
                            end
                        elseif MeatStates[spot] == "Perfect" then
                            FireRemote("PickupMeat", spot)
                            MeatStates[spot] = nil
                            task.wait(Config.ActionDelay)
                        end
                    end
                end
            end
        end
        
        if Config.AutoPlate then
            for _, furniture in ipairs(lot:GetChildren()) do
                local plates = furniture:FindFirstChild("Plates")
                if plates then
                    for _, plate in ipairs(plates:GetChildren()) do
                        if IsSpotEmpty(plate) then
                            local cookedMeat = GetAndEquipMeat("Cooked")
                            if cookedMeat then
                                FireRemote("PlaceMeat", plate, GetCleanName(cookedMeat))
                                task.wait(Config.ActionDelay)
                            end
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if Config.AutoBuyMeat then
            for name, enabled in pairs(BuyMeatTargets) do
                if enabled then
                    SmartBuy(name, false)
                    task.wait(0.3)
                end
            end
        end
        if Config.AutoBuyTotem then
            for name, enabled in pairs(BuyTotemTargets) do
                if enabled then
                    SmartBuy(name, true)
                    task.wait(0.3)
                end
            end
        end
    end
end)

-- ============================================
-- UI BUILD
-- ============================================
local Window = RickUI:CreateWindow({
    Title = "BBQ Mastery",
    SubText = "Automation Script",
    Accent = Color3.fromRGB(255, 100, 50),
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BBQMastery",
        FileName = "config"
    }
})

local CookTab = Window:CreateTab({ Title = "Cooking" })
CookTab:CreateSection("Automation")
CookTab:CreateToggle({Title = "Auto Cook", Description = "Automatically cook raw meat on grills", Default = false, Callback = function(v) Config.AutoCook = v end})
CookTab:CreateToggle({Title = "Auto Plate", Description = "Automatically place cooked meat on plates", Default = false, Callback = function(v) Config.AutoPlate = v end})
CookTab:CreateToggle({Title = "Auto Sell (NPC)", Description = "Automatically accept NPC offers", Default = false, Callback = function(v) Config.AutoSell = v end})
CookTab:CreateSection("Timing")
CookTab:CreateSlider({Title = "Action Delay", Description = "Delay between actions (seconds)", Min = 0.1, Max = 2.0, Default = Config.ActionDelay, Increment = 0.05, Callback = function(v) Config.ActionDelay = v end})

local BuyTab = Window:CreateTab({ Title = "Auto Buy" })
BuyTab:CreateSection("Meat")
BuyTab:CreateToggle({Title = "Enable Auto Buy Meat", Description = "Auto purchase selected meats", Default = false, Callback = function(v) Config.AutoBuyMeat = v end})
BuyTab:CreateSlider({Title = "Buy If Stock Below", Description = "Restock when meat count below this", Min = 1, Max = 20, Default = Config.BuyThreshold, Increment = 1, Callback = function(v) Config.BuyThreshold = v end})
BuyTab:CreateDropdown({Title = "Select Meats", Description = "Choose which meats to auto buy", Options = MeatOptions, Multi = true, PlaceHolder = "Select meats...", Callback = function(selected)
    for k in pairs(BuyMeatTargets) do BuyMeatTargets[k] = false end
    if type(selected) == "table" then
        for _, v in pairs(selected) do if BuyMeatTargets[v] ~= nil then BuyMeatTargets[v] = true end end
    end
end})
BuyTab:CreateSection("Totem")
BuyTab:CreateToggle({Title = "Enable Auto Buy Totem", Description = "Auto purchase selected totems", Default = false, Callback = function(v) Config.AutoBuyTotem = v end})
BuyTab:CreateDropdown({Title = "Select Totems", Description = "Choose which totems to auto buy", Options = TotemOptions, Multi = true, PlaceHolder = "Select totems...", Callback = function(selected)
    for k in pairs(BuyTotemTargets) do BuyTotemTargets[k] = false end
    if type(selected) == "table" then
        for _, v in pairs(selected) do if BuyTotemTargets[v] ~= nil then BuyTotemTargets[v] = true end end
    end
end})

local ExpTab = Window:CreateTab({ Title = "Exploits" })
ExpTab:CreateSection("Interact")
ExpTab:CreateToggle({Title = "Instant Interact", Description = "No hold time for prompts", Default = false, Callback = function(v) Config.InstantPrompt = v end})
ExpTab:CreateSection("Yard")
ExpTab:CreateButton({Title = "Clear Entire Yard", Description = "Pick up all items in your yard", Callback = ClearYard})

local InfoTab = Window:CreateTab({ Title = "Info" })
InfoTab:CreateSection("About")
InfoTab:CreateParagraph({Title = "BBQ Mastery", Content = "BBQ Mastery Automation Script\n\nFeatures:\n• Auto Cook - Cooks raw meat automatically\n• Auto Plate - Places cooked meat on plates\n• Auto Sell - Accepts NPC offers\n• Auto Buy - Restocks meats/totems\n• Instant Interact - Skip hold time\n\nMade with Rick UI Library\nby rickyaditya511"})
InfoTab:CreateSection("Tips")
InfoTab:CreateLabel("💡 Have Hammer in inventory for Clear Yard", "Left")
InfoTab:CreateLabel("💡 Auto Buy restocks every 3 seconds", "Left")
InfoTab:CreateLabel("💡 Keep Backpack open for faster equipping", "Left")
InfoTab:CreateLabel("💡 Perfect meat sells for most profit", "Left")

RickUI:Notify({Title = "BBQ Mastery", Content = "Script loaded successfully!", Duration = 3, Icon = "14554547135"})

print("✅ BBQ Mastery - Fixed Version Loaded!")
print("📌 Use RightShift to toggle UI")
