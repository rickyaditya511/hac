-- BBQ MASTERY - Using Custom UILibrary
-- Example script for rickyaditya511's UILibrary

local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/rickyaditya511/hac/main/UILibrary.lua"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer

-- ==================== CONFIG ====================
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

-- ==================== OPTIONS ====================
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

-- Dynamic fetch
pcall(function()
    if ReplicatedStorage:FindFirstChild("Meats") then
        for _, rarity in ipairs(ReplicatedStorage.Meats:GetChildren()) do
            for _, tool in ipairs(rarity:GetChildren()) do
                if tool:IsA("Tool") and not table.find(MeatOptions, tool.Name) then
                    table.insert(MeatOptions, tool.Name)
                end
            end
        end
    end
    if ReplicatedStorage:FindFirstChild("Totems") then
        for _, t in ipairs(ReplicatedStorage.Totems:GetChildren()) do
            if not table.find(TotemOptions, t.Name) then
                table.insert(TotemOptions, t.Name)
            end
        end
    end
end)

local BuyTargets = {}
local BuyTotemTargets = {}
for _, m in ipairs(MeatOptions) do BuyTargets[m] = false end
for _, t in ipairs(TotemOptions) do BuyTotemTargets[t] = false end

-- ==================== INSTANT PROMPT ====================
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, playerActed)
    if Toggles.InstantPrompt and playerActed == player then
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            prompt.HoldDuration = 0
        end
    end
end)

-- ==================== REMOTE LISTENERS ====================
ReplicatedStorage.Remotes.CookUpdate.OnClientEvent:Connect(function(spot, meatName, timeVal, state)
    if spot and typeof(spot) == "Instance" then MeatStates[spot] = state end
end)

ReplicatedStorage.Remotes.NPCOffer.OnClientEvent:Connect(function(npc, price, meatName, offerId)
    if Toggles.AutoSell then
        task.wait(math.random(3, 6) / 10)
        ReplicatedStorage.Remotes.NPCResponse:FireServer(offerId, true)
    end
end)

-- ==================== HELPER ====================
local function isSpotEmpty(spot)
    for _, child in ipairs(spot:GetChildren()) do
        if child:IsA("Model") or child:IsA("BasePart") or child:IsA("UnionOperation") then return false end
        if child:GetAttribute("MeatName") ~= nil then return false end
        if child:IsA("ProximityPrompt") then
            local text = string.lower(child.ActionText)
            if text:find("pick up") or text:find("take") then return false end
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
        if not t:IsA("Tool") then return false end
        local n = string.lower(t.Name)
        if n:find("hammer") or n:find("table") or n:find("chair") then return false end
        if n:find("oven") or n:find("tent") then return false end
        if n:find("grill") and not n:find("grilled") then return false end
        local cooked = n:find("%[") or n:find("perfect") or n:find("overcooked") or n:find("cooked")
        local raw = n:find("raw ")
        if typeFilter == "Raw" and raw and not cooked then return true end
        if typeFilter == "Cooked" and cooked then return true end
        return false
    end

    for _, t in ipairs(char:GetChildren()) do if isOk(t) then return t end end
    for _, t in ipairs(bp:GetChildren()) do
        if isOk(t) then hum:EquipTool(t); task.wait(0.1); return t end
    end
    return nil
end

local function countMeatStock(n)
    local c = 0
    local function scan(f)
        for _, i in ipairs(f:GetChildren()) do
            if i:IsA("Tool") and string.find(string.lower(i.Name), string.lower(n)) then
                local match = string.match(i.Name, "%(x(%d+)%)")
                c = c + (match and tonumber(match) or 1)
            end
        end
    end
    if player.Character then scan(player.Character) end
    if player:FindFirstChild("Backpack") then scan(player:FindFirstChild("Backpack")) end
    return c
end

local function getCleanName(t)
    local clean = string.gsub(t, "%s*%(x%d+%)", "")
    return string.match(clean, "^%s*(.-)%s*$") or t
end

local function clearYard()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local bp = player:FindFirstChild("Backpack")

    local function equipHammer()
        if char then
            for _, t in ipairs(char:GetChildren()) do
                if string.find(string.lower(t.Name), "hammer") then return true end
            end
        end
        if bp and hum then
            for _, t in ipairs(bp:GetChildren()) do
                if string.find(string.lower(t.Name), "hammer") then
                    hum:EquipTool(t); task.wait(0.2); return true
                end
            end
        end
        return false
    end

    if not equipHammer() then return end

    local lot = workspace:WaitForChild("PlayerLots"):FindFirstChild(player.Name)
    if lot then
        for _, item in ipairs(lot:GetChildren()) do
            for _, prompt in ipairs(item:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    local text = string.lower(prompt.ActionText)
                    if text:find("pick") or text:find("take") then
                        if fireproximityprompt then
                            fireproximityprompt(prompt)
                        else
                            prompt.HoldDuration = 0
                            prompt:InputHoldBegin(); task.wait(0.05); prompt:InputHoldEnd()
                        end
                        task.wait(0.05)
                    end
                end
            end
        end
    end
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
        pcall(function() ReplicatedStorage.Remotes.BuyShopItem:FireServer(itemName, false) end)
    else
        pcall(function() ReplicatedStorage.Remotes.BuyMeat:FireServer(itemName, false) end)
    end
end

-- ==================== MAIN LOOPS ====================
task.spawn(function()
    while task.wait(ActionDelay) do
        local lot = workspace:WaitForChild("PlayerLots"):FindFirstChild(player.Name)
        if not lot then continue end

        if Toggles.AutoCook then
            for _, f in ipairs(lot:GetChildren()) do
                local g = f:FindFirstChild("GrillSpots")
                if g then
                    for _, s in ipairs(g:GetChildren()) do
                        if isSpotEmpty(s) then
                            local r = getAndEquipMeat("Raw")
                            if r then
                                ReplicatedStorage.Remotes.PlaceMeat:FireServer(s, getCleanName(r.Name))
                                task.wait(ActionDelay)
                            end
                        else
                            local st = MeatStates[s]
                            if not st then
                                local mp = s:FindFirstChildWhichIsA("BasePart") or s:FindFirstChildWhichIsA("UnionOperation")
                                if mp then
                                    local bb = mp:FindFirstChild("CookBillboard")
                                    if bb and bb:FindFirstChild("BG") and bb.BG:FindFirstChild("StateLabel") then
                                        st = bb.BG.StateLabel.Text
                                    end
                                end
                            end
                            if st == "Perfect" then
                                ReplicatedStorage.Remotes.PickupMeat:FireServer(s)
                                MeatStates[s] = nil
                                task.wait(ActionDelay)
                            end
                        end
                    end
                end
            end
        end

        if Toggles.AutoPlate then
            for _, f in ipairs(lot:GetChildren()) do
                local p = f:FindFirstChild("Plates")
                if p then
                    for _, pl in ipairs(p:GetChildren()) do
                        if isSpotEmpty(pl) then
                            local ck = getAndEquipMeat("Cooked")
                            if ck then
                                ReplicatedStorage.Remotes.PlaceMeat:FireServer(pl, getCleanName(ck.Name))
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
            for n, e in pairs(BuyTargets) do
                if e then smartBuy(n, false); task.wait(0.3) end
            end
        end
        if Toggles.AutoBuyTotem then
            for n, e in pairs(BuyTotemTargets) do
                if e then smartBuy(n, true); task.wait(0.3) end
            end
        end
    end
end)

-- ==================== UI ====================
local Window = UILibrary:CreateWindow({
    Title = "BBQ Mastery",
    Size = UDim2.new(0, 480, 0, 550),
    Theme = "Dark",
})

-- Tab 1: Cooking
local CookTab = Window:CreateTab("Cooking")

CookTab:CreateSection("Automation")
CookTab:CreateToggle({
    Title = "Auto Cook",
    Default = false,
    Callback = function(v) Toggles.AutoCook = v end,
})

CookTab:CreateToggle({
    Title = "Auto Plate",
    Default = false,
    Callback = function(v) Toggles.AutoPlate = v end,
})

CookTab:CreateToggle({
    Title = "Auto Sell (NPC)",
    Default = false,
    Callback = function(v) Toggles.AutoSell = v end,
})

CookTab:CreateSection("Timing")
CookTab:CreateSlider({
    Title = "Action Delay",
    Min = 0.1,
    Max = 2.0,
    Default = ActionDelay,
    Callback = function(v) ActionDelay = v end,
})

-- Tab 2: Auto Buy
local BuyTab = Window:CreateTab("Auto Buy")

BuyTab:CreateSection("Meat")
BuyTab:CreateToggle({
    Title = "Enable Auto Buy Meat",
    Default = false,
    Callback = function(v) Toggles.AutoBuy = v end,
})

BuyTab:CreateSlider({
    Title = "Buy If Stock Below",
    Min = 1,
    Max = 20,
    Default = BuyThreshold,
    Callback = function(v) BuyThreshold = v end,
})

BuyTab:CreateDropdown({
    Title = "Select Meats",
    Options = MeatOptions,
    Multi = true,
    Default = {},
    Callback = function(selected)
        for k in pairs(BuyTargets) do BuyTargets[k] = false end
        if type(selected) == "table" then
            for _, v in pairs(selected) do
                if BuyTargets[v] ~= nil then BuyTargets[v] = true end
            end
        end
    end,
})

BuyTab:CreateSection("Totem")
BuyTab:CreateToggle({
    Title = "Enable Auto Buy Totem",
    Default = false,
    Callback = function(v) Toggles.AutoBuyTotem = v end,
})

BuyTab:CreateDropdown({
    Title = "Select Totems",
    Options = TotemOptions,
    Multi = true,
    Default = {},
    Callback = function(selected)
        for k in pairs(BuyTotemTargets) do BuyTotemTargets[k] = false end
        if type(selected) == "table" then
            for _, v in pairs(selected) do
                if BuyTotemTargets[v] ~= nil then BuyTotemTargets[v] = true end
            end
        end
    end,
})

-- Tab 3: Exploits
local ExpTab = Window:CreateTab("Exploits")

ExpTab:CreateSection("Interact")
ExpTab:CreateToggle({
    Title = "Instant Interact",
    Default = false,
    Callback = function(v) Toggles.InstantPrompt = v end,
})

ExpTab:CreateSection("Yard")
ExpTab:CreateButton({
    Title = "Clear Entire Yard",
    Callback = clearYard,
})

-- Tab 4: Info
local InfoTab = Window:CreateTab("Info")

InfoTab:CreateSection("About")
InfoTab:CreateLabel("BBQ Mastery - UILibrary Edition")
InfoTab:CreateLabel("Made with custom UILibrary")
InfoTab:CreateLabel("by rickyaditya511")

InfoTab:CreateSection("Tips")
InfoTab:CreateLabel("Have Backpack & Hammer ready")
InfoTab:CreateLabel("Auto Buy restocks every 3s")
InfoTab:CreateLabel("Clear Yard picks up all items")

-- Notification
UILibrary:Notify({
    Title = "BBQ Mastery Loaded!",
    Content = "All features ready!",
    Duration = 5,
})

print("✅ BBQ Mastery - UILibrary Edition Loaded!")
