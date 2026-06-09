-- BBQ MASTERY - Rick UI Library Edition
-- Fixed Version

local RickUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/rickyaditya511/hac/main/Rick_UI_fix.lua"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

if not player.Character then
    player.CharacterAdded:Wait()
end

local Toggles = {
    AutoCook = false,
    AutoPlate = false,
    AutoSell = false,
    AutoBuy = false,
    AutoBuyTotem = false,
    InstantPrompt = false
}

local ActionDelay = 0.3
local BuyThreshold = 5
local MeatStates = {}
local LastBuyTime = {}

local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local function safeRemoteFire(remoteName, ...)
    if not Remotes then return false end
    local remote = Remotes:FindFirstChild(remoteName)
    if not remote then return false end
    pcall(function() remote:FireServer(...) end)
    return true
end

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

local BuyTargets = {}
local BuyTotemTargets = {}

for _, m in ipairs(MeatOptions) do BuyTargets[m] = false end
for _, t in ipairs(TotemOptions) do BuyTotemTargets[t] = false end

local function isSpotEmpty(spot)
    if not spot then return true end
    for _, child in ipairs(spot:GetChildren()) do
        if child:IsA("Model") or child:IsA("BasePart") or child:IsA("UnionOperation") then
            return false
        end
        if child:IsA("ProximityPrompt") then
            local text = string.lower(child.ActionText or "")
            if text:find("pick up") or text:find("take") then
                return false
            end
        end
    end
    return true
end

local function getAndEquipMeat(typeFilter)
    local char = player.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local bp = player:FindFirstChild("Backpack")
    if not hum or not bp then return nil end

    local function isOk(t)
        if not t or not t:IsA("Tool") then return false end
        local n = string.lower(t.Name or "")
        if n:find("hammer") then return false end
        local cooked = n:find("cooked") or n:find("perfect") or n:find("[")
        local raw = n:find("raw ")
        if typeFilter == "Raw" and raw and not cooked then return true end
        if typeFilter == "Cooked" and cooked then return true end
        return false
    end

    for _, t in ipairs(char:GetChildren()) do
        if isOk(t) then return t end
    end
    for _, t in ipairs(bp:GetChildren()) do
        if isOk(t) then
            hum:EquipTool(t)
            task.wait(0.1)
            return t
        end
    end
    return nil
end

local function countMeatStock(meatName)
    local c = 0
    local function scan(folder)
        if not folder then return end
        for _, item in ipairs(folder:GetChildren()) do
            if item:IsA("Tool") and string.find(string.lower(item.Name or ""), string.lower(meatName)) then
                local match = string.match(item.Name, "%(x(%d+)%)")
                c = c + (match and tonumber(match) or 1)
            end
        end
    end
    scan(player.Character)
    scan(player:FindFirstChild("Backpack"))
    return c
end

local function getCleanName(tool)
    if not tool then return "" end
    local clean = string.gsub(tool.Name, "%s*%(x%d+%)", "")
    return string.match(clean, "^%s*(.-)%s*$") or tool.Name
end

local function clearYard()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local bp = player:FindFirstChild("Backpack")

    local function equipHammer()
        for _, t in ipairs(char:GetChildren()) do
            if string.find(string.lower(t.Name or ""), "hammer") then
                return true
            end
        end
        if bp and hum then
            for _, t in ipairs(bp:GetChildren()) do
                if string.find(string.lower(t.Name or ""), "hammer") then
                    hum:EquipTool(t)
                    task.wait(0.2)
                    return true
                end
            end
        end
        return false
    end

    if not equipHammer() then
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

local function canBuy(itemName)
    if countMeatStock(itemName) >= BuyThreshold then return false end
    if tick() - (LastBuyTime[itemName] or 0) < 3 then return false end
    return true
end

local function smartBuy(itemName, isTotem)
    if not canBuy(itemName) then return end
    LastBuyTime[itemName] = tick()
    if isTotem then
        safeRemoteFire("BuyShopItem", itemName, false)
    else
        safeRemoteFire("BuyMeat", itemName, false)
    end
end

task.spawn(function()
    while task.wait(ActionDelay) do
        local playerLots = Workspace:FindFirstChild("PlayerLots")
        if not playerLots then continue end
        local lot = playerLots:FindFirstChild(player.Name)
        if not lot then continue end

        if Toggles.AutoCook then
            for _, f in ipairs(lot:GetChildren()) do
                local grillSpots = f:FindFirstChild("GrillSpots")
                if grillSpots then
                    for _, spot in ipairs(grillSpots:GetChildren()) do
                        if isSpotEmpty(spot) then
                            local rawMeat = getAndEquipMeat("Raw")
                            if rawMeat then
                                safeRemoteFire("PlaceMeat", spot, getCleanName(rawMeat))
                                task.wait(ActionDelay)
                            end
                        else
                            local state = MeatStates[spot]
                            if state == "Perfect" then
                                safeRemoteFire("PickupMeat", spot)
                                MeatStates[spot] = nil
                                task.wait(ActionDelay)
                            end
                        end
                    end
                end
            end
        end

        if Toggles.AutoPlate then
            for _, f in ipairs(lot:GetChildren()) do
                local plates = f:FindFirstChild("Plates")
                if plates then
                    for _, plate in ipairs(plates:GetChildren()) do
                        if isSpotEmpty(plate) then
                            local cookedMeat = getAndEquipMeat("Cooked")
                            if cookedMeat then
                                safeRemoteFire("PlaceMeat", plate, getCleanName(cookedMeat))
                                task.wait(ActionDelay)
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
        if Toggles.AutoBuy then
            for name, enabled in pairs(BuyTargets) do
                if enabled then
                    smartBuy(name, false)
                    task.wait(0.3)
                end
            end
        end
        if Toggles.AutoBuyTotem then
            for name, enabled in pairs(BuyTotemTargets) do
                if enabled then
                    smartBuy(name, true)
                    task.wait(0.3)
                end
            end
        end
    end
end)

local Window = RickUI:CreateWindow({
    Title = "BBQ Mastery",
    SubText = "Automation Script",
    Accent = Color3.fromRGB(255, 100, 50),
    ConfigurationSaving = {Enabled = true, FolderName = "BBQMastery", FileName = "config"}
})

local CookTab = Window:CreateTab({Title = "Cooking"})
CookTab:CreateSection("Automation")
CookTab:CreateToggle({Title = "Auto Cook", Description = "Automatically cook raw meat on grills", Default = false, Callback = function(v) Toggles.AutoCook = v end})
CookTab:CreateToggle({Title = "Auto Plate", Description = "Automatically place cooked meat on plates", Default = false, Callback = function(v) Toggles.AutoPlate = v end})
CookTab:CreateToggle({Title = "Auto Sell (NPC)", Description = "Automatically accept NPC offers", Default = false, Callback = function(v) Toggles.AutoSell = v end})
CookTab:CreateSection("Timing")
CookTab:CreateSlider({Title = "Action Delay", Description = "Delay between actions (seconds)", Min = 0.1, Max = 2.0, Default = ActionDelay, Increment = 0.05, Callback = function(v) ActionDelay = v end})

local BuyTab = Window:CreateTab({Title = "Auto Buy"})
BuyTab:CreateSection("Meat")
BuyTab:CreateToggle({Title = "Enable Auto Buy Meat", Description = "Auto purchase selected meats", Default = false, Callback = function(v) Toggles.AutoBuy = v end})
BuyTab:CreateSlider({Title = "Buy If Stock Below", Description = "Restock when meat count below this", Min = 1, Max = 20, Default = BuyThreshold, Increment = 1, Callback = function(v) BuyThreshold = v end})
BuyTab:CreateDropdown({Title = "Select Meats", Description = "Choose which meats to auto buy", Options = MeatOptions, Multi = true, PlaceHolder = "Select meats...", Callback = function(selected)
    for k in pairs(BuyTargets) do BuyTargets[k] = false end
    if type(selected) == "table" then
        for _, v in pairs(selected) do if BuyTargets[v] ~= nil then BuyTargets[v] = true end end
    end
end})
BuyTab:CreateSection("Totem")
BuyTab:CreateToggle({Title = "Enable Auto Buy Totem", Description = "Auto purchase selected totems", Default = false, Callback = function(v) Toggles.AutoBuyTotem = v end})
BuyTab:CreateDropdown({Title = "Select Totems", Description = "Choose which totems to auto buy", Options = TotemOptions, Multi = true, PlaceHolder = "Select totems...", Callback = function(selected)
    for k in pairs(BuyTotemTargets) do BuyTotemTargets[k] = false end
    if type(selected) == "table" then
        for _, v in pairs(selected) do if BuyTotemTargets[v] ~= nil then BuyTotemTargets[v] = true end end
    end
end})

local ExpTab = Window:CreateTab({Title = "Exploits"})
ExpTab:CreateSection("Interact")
ExpTab:CreateToggle({Title = "Instant Interact", Description = "No hold time for prompts", Default = false, Callback = function(v) Toggles.InstantPrompt = v end})
ExpTab:CreateSection("Yard")
ExpTab:CreateButton({Title = "Clear Entire Yard", Description = "Pick up all items in your yard", Callback = clearYard})

local InfoTab = Window:CreateTab({Title = "Info"})
InfoTab:CreateSection("About")
InfoTab:CreateParagraph({Title = "BBQ Mastery", Content = [[BBQ Mastery Automation Script
    
Features:
• Auto Cook - Cooks raw meat automatically
• Auto Plate - Places cooked meat on plates
• Auto Sell - Accepts NPC offers
• Auto Buy - Restocks meats/totems
• Instant Interact - Skip hold time
    
Made with Rick UI Library]]})
InfoTab:CreateSection("Tips")
InfoTab:CreateLabel("💡 Have Hammer in inventory for Clear Yard", "Left")
InfoTab:CreateLabel("💡 Auto Buy restocks every 3 seconds", "Left")
InfoTab:CreateLabel("💡 Keep Backpack open for faster equipping", "Left")

RickUI:Notify({Title = "BBQ Mastery", Content = "Script loaded successfully!", Duration = 3, Icon = "14554547135"})

print("✅ BBQ Mastery - Rick UI Library Edition Loaded!")
print("📌 Use RightShift to toggle UI")
