-- Load Library Obsidian
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/rickyaditya511/hac/refs/heads/main/Library.lua"))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- == CONFIG SYSTEM == --
local ConfigFolder = "BBQ_Mastery_Configs"
local CurrentConfigName = "Default"
local SelectedConfigName = "Default"
local pendingAutoLoad = nil

if not isfolder then
    print("⚠️ Your executor doesn't support saving configs!")
    ConfigFolder = nil
else
    if not isfolder(ConfigFolder) then
        makefolder(ConfigFolder)
    end
end

local function getConfigList()
    if not ConfigFolder then return {} end
    local configs = {}
    local files = listfiles(ConfigFolder)
    for _, file in ipairs(files) do
        local name = string.match(file, "([^/]+)%.json$")
        if name and name ~= "autoload" then
            table.insert(configs, name)
        end
    end
    table.sort(configs)
    return configs
end

local function saveConfig(configName, overwrite)
    if not ConfigFolder then 
        Library:Notify({Title = "Error", Description = "Executor tidak support save config!", Time = 3})
        return false 
    end
    
    local filePath = ConfigFolder .. "/" .. configName .. ".json"
    if isfile(filePath) and not overwrite then
        Library:Notify({Title = "Warning", Description = string.format("Config '%s' already exists! Use Save (overwrite) or different name.", configName), Time = 3})
        return false
    end
    
    local configData = {
        version = 2,
        savedAt = os.date("%Y-%m-%d %H:%M:%S"),
        toggles = Toggles,
        stackAmount = StackAmount,
        buyThreshold = BuyThreshold,
        actionDelay = ActionDelay,
        totemBuyDelay = TotemBuyDelay,
        totemBuyList = BuyTotemTargets,
        buyTargets = BuyTargets,
    }
    
    local success, err = pcall(function()
        writefile(filePath, HttpService:JSONEncode(configData))
    end)
    
    if success then
        Library:Notify({Title = "Config Saved", Description = string.format("Saved '%s'", configName), Time = 2})
        if configName == CurrentConfigName then
            if windowLabels and windowLabels.currentConfig then
                windowLabels.currentConfig:SetText("📁 Current: " .. CurrentConfigName)
            end
        end
        if windowDropdowns and windowDropdowns.configList then
            local newList = getConfigList()
            windowDropdowns.configList:SetValues(#newList > 0 and newList or {"No configs"})
            if #newList > 0 and windowDropdowns.configList.SetValue then
                windowDropdowns.configList:SetValue(SelectedConfigName)
            end
        end
        return true
    else
        Library:Notify({Title = "Error", Description = "Failed to save config: " .. tostring(err), Time = 3})
        return false
    end
end

local function createConfig(configName)
    if not ConfigFolder then return false end
    if configName == nil or configName == "" then
        Library:Notify({Title = "Error", Description = "Config name cannot be empty!", Time = 2})
        return false
    end
    local filePath = ConfigFolder .. "/" .. configName .. ".json"
    if isfile(filePath) then
        Library:Notify({Title = "Error", Description = string.format("Config '%s' already exists! Use Save instead.", configName), Time = 3})
        return false
    end
    return saveConfig(configName, true)
end

local function loadConfig(configName, skipUIDelay)
    if not ConfigFolder then return false end
    
    local filePath = ConfigFolder .. "/" .. configName .. ".json"
    if not isfile(filePath) then
        Library:Notify({Title = "Error", Description = string.format("Config '%s' not found!", configName), Time = 3})
        return false
    end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(filePath))
    end)
    
    if not success then
        Library:Notify({Title = "Error", Description = "Failed to load config (corrupted file?)", Time = 3})
        return false
    end
    
    if data.toggles then
        for k, v in pairs(data.toggles) do
            if Toggles[k] ~= nil then
                Toggles[k] = v
            end
        end
    end
    
    if data.stackAmount then StackAmount = data.stackAmount end
    if data.buyThreshold then BuyThreshold = data.buyThreshold end
    if data.actionDelay then ActionDelay = data.actionDelay end
    if data.totemBuyDelay then TotemBuyDelay = data.totemBuyDelay end
    if data.totemBuyList then BuyTotemTargets = data.totemBuyList end
    if data.buyTargets then BuyTargets = data.buyTargets end
    
    if not skipUIDelay then
        if windowSliders then
            if windowSliders.stackAmount then windowSliders.stackAmount:SetValue(StackAmount) end
            if windowSliders.buyThreshold then windowSliders.buyThreshold:SetValue(BuyThreshold) end
            if windowSliders.actionDelay then windowSliders.actionDelay:SetValue(ActionDelay) end
            if windowSliders.totemBuyDelay then windowSliders.totemBuyDelay:SetValue(TotemBuyDelay) end
        end
        
        if windowDropdowns then
            if windowDropdowns.meatSelect then
                local meatValues = {}
                for _, v in ipairs(BuyTargets) do
                    meatValues[v] = true
                end
                windowDropdowns.meatSelect:SetValue(meatValues)
            end
            if windowDropdowns.totemSelect then
                local totemValues = {}
                for _, v in ipairs(BuyTotemTargets) do
                    totemValues[v] = true
                end
                windowDropdowns.totemSelect:SetValue(totemValues)
            end
        end
        
        if windowToggleElements then
            for k, v in pairs(Toggles) do
                if windowToggleElements[k] then
                    windowToggleElements[k]:SetValue(v)
                end
            end
        end
    end
    
    CurrentConfigName = configName
    SelectedConfigName = configName
    
    if windowLabels and windowLabels.currentConfig then
        windowLabels.currentConfig:SetText("📁 Current: " .. CurrentConfigName)
    end
    if windowDropdowns and windowDropdowns.configList and windowDropdowns.configList.SetValue then
        windowDropdowns.configList:SetValue(SelectedConfigName)
    end
    if windowLabels and windowLabels.configNameInput then
        windowLabels.configNameInput:SetValue(SelectedConfigName)
    end
    
    Library:Notify({Title = "Config Loaded", Description = string.format("Loaded '%s'", configName), Time = 2})
    return true
end

local function deleteConfig(configName)
    if not ConfigFolder then return false end
    
    local filePath = ConfigFolder .. "/" .. configName .. ".json"
    if not isfile(filePath) then
        Library:Notify({Title = "Error", Description = string.format("Config '%s' not found!", configName), Time = 3})
        return false
    end
    
    local success, err = pcall(function()
        delfile(filePath)
    end)
    
    if success then
        Library:Notify({Title = "Config Deleted", Description = string.format("Deleted '%s'", configName), Time = 2})
        if configName == CurrentConfigName then
            CurrentConfigName = "Default"
            if windowLabels and windowLabels.currentConfig then
                windowLabels.currentConfig:SetText("📁 Current: " .. CurrentConfigName)
            end
        end
        local newList = getConfigList()
        if windowDropdowns and windowDropdowns.configList then
            windowDropdowns.configList:SetValues(#newList > 0 and newList or {"No configs"})
            if #newList > 0 then
                windowDropdowns.configList:SetValue(newList[1])
                SelectedConfigName = newList[1]
            else
                SelectedConfigName = ""
            end
        end
        return true
    else
        Library:Notify({Title = "Error", Description = "Failed to delete config", Time = 3})
        return false
    end
end

local function setAutoLoadConfig(configName)
    if not ConfigFolder then return false end
    if configName and configName ~= "" then
        local success, err = pcall(function()
            writefile(ConfigFolder .. "/autoload.txt", configName)
        end)
        if success then
            Library:Notify({Title = "Auto-Load Set", Description = string.format("Will load '%s' on next execute", configName), Time = 2})
            return true
        end
    else
        pcall(function() delfile(ConfigFolder .. "/autoload.txt") end)
        Library:Notify({Title = "Auto-Load Cleared", Description = "No auto-load on next execute", Time = 2})
        return true
    end
    return false
end

local function getAutoLoadConfig()
    if not ConfigFolder then return nil end
    local path = ConfigFolder .. "/autoload.txt"
    if isfile(path) then
        return readfile(path)
    end
    return nil
end

-- == Configuration & States ==
local Toggles = {
    AutoCook = false,
    AutoPlate = false,
    AutoSell = false,
    AutoBuy = false,
    AutoBuyTotem = false,
    StackExploit = false,
    InstantPrompt = false,
    AntiAFK = false,
}

local StackAmount = 20
local BuyThreshold = 5
local ActionDelay = 0.3
local TotemBuyDelay = 2.0
local MeatStates = {}

local windowToggleElements = {}
local windowSliders = {}
local windowDropdowns = {}
local windowLabels = {}

local MeatOptions = {
    "Raw Hotdog", "Raw Burger", "Raw Chicken", "Raw Salmon", 
    "Raw Ribs", "Raw Prime Rib", "Raw Brisket", "Raw Lobster Tail",
    "Raw Bigfoot Filet", "Raw Dragon", "Raw Demon", "Raw Whole Unicorn"
}

local TotemData = {
    {name = "Gold Totem", price = 500, value = 1},
    {name = "Salt and Pepper Totem", price = 750, value = 2},
    {name = "Totem of Small Growth", price = 1000, value = 3},
    {name = "Totem of Growth", price = 2000, value = 5},
    {name = "Totem of Great Growth", price = 5000, value = 10},
    {name = "Speed Totem", price = 1500, value = 4},
    {name = "Luck Totem", price = 3000, value = 7},
    {name = "Diamond Totem", price = 10000, value = 20},
    {name = "Ruby Totem", price = 25000, value = 50},
}

local TotemOptions = {}
for _, t in ipairs(TotemData) do
    table.insert(TotemOptions, t.name)
end

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
end)

local BuyTargets = {MeatOptions[1]}
local BuyTotemTargets = {}
local totemBuyIndex = 1

-- == Anti AFK ==
local vu = VirtualUser
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    if Toggles.AntiAFK then
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- == Exploit: Instant Prompt ==
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, playerActed)
    if Toggles.InstantPrompt and playerActed == player then
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            prompt.HoldDuration = 0
            prompt:InputHoldBegin()
            task.wait()
            prompt:InputHoldEnd()
        end
    end
end)

-- == Clear Yard Function ==
local function clearYard()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local backpack = player:FindFirstChild("Backpack")
    
    local function equipHammer()
        if char then
            for _, t in ipairs(char:GetChildren()) do
                if string.find(string.lower(t.Name), "hammer") then return true end
            end
        end
        if backpack and hum then
            for _, t in ipairs(backpack:GetChildren()) do
                if string.find(string.lower(t.Name), "hammer") then
                    hum:EquipTool(t)
                    task.wait(0.2)
                    return true
                end
            end
        end
        return false
    end

    if not equipHammer() then
        Library:Notify({Title = "Error", Description = "You must own a Hammer to clear the yard!", Time = 3})
        return
    end

    local myLot = workspace:FindFirstChild("PlayerLots") and workspace.PlayerLots:FindFirstChild(player.Name)
    if myLot then
        Library:Notify({Title = "Clearing", Description = "Vacuuming Yard...", Time = 2})
        
        local cleared = 0
        for _, item in ipairs(myLot:GetChildren()) do
            for _, prompt in ipairs(item:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    local text = string.lower(prompt.ActionText)
                    if string.find(text, "pick") or string.find(text, "take") then
                        if fireproximityprompt then
                            fireproximityprompt(prompt)
                        else
                            prompt.HoldDuration = 0
                            prompt:InputHoldBegin()
                            task.wait(0.05)
                            prompt:InputHoldEnd()
                        end
                        cleared += 1
                        task.wait(0.05)
                    end
                end
            end
        end
        Library:Notify({Title = "Success", Description = string.format("Cleared %d items from yard!", cleared), Time = 3})
    end
end

local function getNextTotemToBuy()
    if #BuyTotemTargets == 0 then return nil end
    local totem = BuyTotemTargets[totemBuyIndex]
    totemBuyIndex = totemBuyIndex % #BuyTotemTargets + 1
    return totem
end

-- == Stack Exploit ==
local isSpamming = false
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if Toggles.StackExploit and not checkcaller() and not isSpamming then
        if method == "FireServer" or method == "InvokeServer" then
            local remoteName = tostring(self.Name)
            local blocked = {"CookUpdate", "BuyShopItem", "BuyMeat", "PlaceMeat", "NPCResponse", "GetTotemStock"}
            local isBlocked = false
            for _, b in ipairs(blocked) do
                if remoteName == b then isBlocked = true break end
            end
            if not isBlocked then
                local args = {...}
                task.spawn(function()
                    isSpamming = true
                    for i = 1, StackAmount - 1 do
                        if method == "FireServer" then
                            self:FireServer(unpack(args))
                        else
                            pcall(function() self:InvokeServer(unpack(args)) end)
                        end
                    end
                    isSpamming = false
                end)
            end
        end
    end
    return oldNamecall(self, ...)
end))

-- == Remote Listeners ==
ReplicatedStorage.Remotes.CookUpdate.OnClientEvent:Connect(function(spot, meatName, timeVal, state)
    if spot and typeof(spot) == "Instance" then MeatStates[spot] = state end
end)

ReplicatedStorage.Remotes.NPCOffer.OnClientEvent:Connect(function(npc, price, meatName, offerId)
    if Toggles.AutoSell then
        task.wait(math.random(2, 5) / 10)
        ReplicatedStorage.Remotes.NPCResponse:FireServer(offerId, true)
    end
end)

-- == Helper Functions ==
local function isSpotEmpty(spot)
    for _, child in ipairs(spot:GetChildren()) do
        if child:IsA("Model") or child:IsA("BasePart") or child:IsA("UnionOperation") or child:GetAttribute("MeatName") ~= nil then 
            return false 
        end
        if child:IsA("ProximityPrompt") then
            local actionText = string.lower(child.ActionText)
            if string.find(actionText, "pick up") or string.find(actionText, "take") then 
                return false 
            end
        end
    end
    return true
end

local function getAndEquipMeat(typeFilter)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local backpack = player:FindFirstChild("Backpack")
    if not hum or not backpack then return nil end

    local function isCorrectMeat(tool)
        if not tool:IsA("Tool") then return false end
        local name = string.lower(tool.Name)
        if string.find(name, "hammer") or string.find(name, "table") or string.find(name, "chair") or 
           string.find(name, "oven") or string.find(name, "tent") then return false end
        if string.find(name, "grill") and not string.find(name, "grilled") then return false end
        
        local isCooked = string.find(name, "%[") or string.find(name, "perfect") or 
                         string.find(name, "overcooked") or string.find(name, "cooked")
        local isRaw = string.find(name, "raw ")
        
        if typeFilter == "Raw" and isRaw and not isCooked then return true
        elseif typeFilter == "Cooked" and isCooked then return true end
        return false
    end

    for _, t in ipairs(char:GetChildren()) do 
        if isCorrectMeat(t) then return t end 
    end
    for _, t in ipairs(backpack:GetChildren()) do
        if isCorrectMeat(t) then
            hum:EquipTool(t)
            task.wait(0.1)
            return t
        end
    end
    return nil
end

local function countMeatStock(targetName)
    local count = 0
    local tLower = string.lower(targetName)
    local function scan(folder)
        for _, item in ipairs(folder:GetChildren()) do
            if item:IsA("Tool") and string.find(string.lower(item.Name), tLower) then
                local match = string.match(item.Name, "%(x(%d+)%)")
                if match then count = count + tonumber(match) else count = count + 1 end
            end
        end
    end
    if player.Character then scan(player.Character) end
    if player:FindFirstChild("Backpack") then scan(player.Backpack) end
    return count
end

local function getCleanName(toolName)
    local clean = string.gsub(toolName, "%s*%(x%d+%)", "")
    return string.match(clean, "^%s*(.-)%s*$") or clean
end

-- == Main Automation Loops ==
task.spawn(function()
    while task.wait(ActionDelay) do
        local myLot = workspace:FindFirstChild("PlayerLots") and workspace.PlayerLots:FindFirstChild(player.Name)
        if not myLot then continue end
        
        if Toggles.AutoCook then
            for _, furniture in ipairs(myLot:GetChildren()) do
                local grills = furniture:FindFirstChild("GrillSpots")
                if grills then
                    for _, spot in ipairs(grills:GetChildren()) do
                        if isSpotEmpty(spot) then
                            local rawMeat = getAndEquipMeat("Raw")
                            if rawMeat then
                                ReplicatedStorage.Remotes.PlaceMeat:FireServer(spot, getCleanName(rawMeat.Name))
                                task.wait(ActionDelay)
                            end
                        else
                            local state = MeatStates[spot]
                            if state == "Perfect" then
                                ReplicatedStorage.Remotes.PickupMeat:FireServer(spot)
                                MeatStates[spot] = nil
                                task.wait(ActionDelay)
                            end
                        end
                    end
                end
            end
        end
        
        if Toggles.AutoPlate then
            for _, furniture in ipairs(myLot:GetChildren()) do
                local plates = furniture:FindFirstChild("Plates")
                if plates then
                    for _, plate in ipairs(plates:GetChildren()) do
                        if isSpotEmpty(plate) then
                            local cookedMeat = getAndEquipMeat("Cooked")
                            if cookedMeat then
                                ReplicatedStorage.Remotes.PlaceMeat:FireServer(plate, getCleanName(cookedMeat.Name))
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
    while task.wait(1.5) do
        if Toggles.AutoBuy and #BuyTargets > 0 then
            for _, targetMeat in ipairs(BuyTargets) do
                if countMeatStock(targetMeat) < BuyThreshold then
                    ReplicatedStorage.Remotes.BuyMeat:FireServer(targetMeat, false)
                    task.wait(0.3)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(TotemBuyDelay) do
        if Toggles.AutoBuyTotem and #BuyTotemTargets > 0 then
            local totem = getNextTotemToBuy()
            if totem then
                ReplicatedStorage.Remotes.BuyShopItem:FireServer(totem, false)
            end
        end
    end
end)

-- == MODERN GUI OBSIDIAN ==
local autoLoadName = getAutoLoadConfig()
if autoLoadName and autoLoadName ~= "" then
    pendingAutoLoad = autoLoadName
end

-- ========== WINDOW DENGAN ICON CANNABIS (DAUN GANJA) ==========
local Window = Library:CreateWindow({
    Title = "BBQ MASTERY",
    Footer = "Auto Cook | Auto Sell | Auto Totem | Config System",
    Center = true,
    Size = UDim2.fromOffset(620, 620),
    Resizable = true,
    EnableSidebarResize = true,
    ShowCustomCursor = true,
    Font = Enum.Font.GothamBold,
    Icon = "cannabis",  -- Icon daun ganja dari Lucide (PASTI MUNCUL)
    CornerRadius = 8,
    NotifySide = "Right",
})

-- ========== TAB 1: BBQ Automation ==========
local MeatTab = Window:AddTab("BBQ", "flame")

local AutoGroup = MeatTab:AddLeftGroupbox("Automation", "settings")

local autoCookToggle = AutoGroup:AddToggle("Auto Cook", {
    Text = "Auto Cook (Perfect)",
    Default = Toggles.AutoCook,
    Tooltip = "Automatically cooks meat until Perfect",
    Callback = function(state) Toggles.AutoCook = state end
})
windowToggleElements.AutoCook = autoCookToggle

local autoPlateToggle = AutoGroup:AddToggle("Auto Plate", {
    Text = "Auto Plate",
    Default = Toggles.AutoPlate,
    Tooltip = "Automatically plates cooked meat",
    Callback = function(state) Toggles.AutoPlate = state end
})
windowToggleElements.AutoPlate = autoPlateToggle

local autoSellToggle = AutoGroup:AddToggle("Auto Sell", {
    Text = "Auto Sell (NPC)",
    Default = Toggles.AutoSell,
    Tooltip = "Automatically accepts NPC sell offers",
    Risky = true,
    Callback = function(state) Toggles.AutoSell = state end
})
windowToggleElements.AutoSell = autoSellToggle

local MeatGroup = MeatTab:AddRightGroupbox("Meat Management", "drumstick")

local autoBuyToggle = MeatGroup:AddToggle("Auto Buy Meat", {
    Text = "Auto Buy Meat",
    Default = Toggles.AutoBuy,
    Callback = function(state) Toggles.AutoBuy = state end
})
windowToggleElements.AutoBuy = autoBuyToggle

local meatDropdownElement = MeatGroup:AddDropdown("Auto Buy Meats", {
    Text = "Select meats to auto-buy",
    Values = MeatOptions,
    Multi = true,
    Callback = function(values)
        BuyTargets = {}
        if type(values) == "table" then
            for v, active in pairs(values) do
                if active then table.insert(BuyTargets, v) end
            end
        end
    end
})
windowDropdowns.meatSelect = meatDropdownElement

if BuyTargets[1] then
    meatDropdownElement:SetValue({ [BuyTargets[1]] = true })
end

local thresholdSlider = MeatGroup:AddSlider("Buy Threshold", {
    Text = "Stock threshold",
    Default = BuyThreshold,
    Min = 1,
    Max = 50,
    Suffix = " items",
    Callback = function(value) BuyThreshold = value end
})
windowSliders.buyThreshold = thresholdSlider

local actionDelaySlider = MeatGroup:AddSlider("Action Delay", {
    Text = "Action delay (cook/plate)",
    Default = ActionDelay,
    Min = 0.1,
    Max = 2,
    Rounding = 1,
    Suffix = " sec",
    Callback = function(value) ActionDelay = value end
})
windowSliders.actionDelay = actionDelaySlider

-- ========== TAB 2: Totems ==========
local TotemTab = Window:AddTab("Totems", "diamond")

local TotemBuyGroup = TotemTab:AddLeftGroupbox("Totem Buying", "shopping-cart")

local autoBuyTotemToggle = TotemBuyGroup:AddToggle("Auto Buy Totems", {
    Text = "Auto Buy Totems (Round-robin)",
    Default = Toggles.AutoBuyTotem,
    Tooltip = "Automatically buys selected totems in rotation",
    Callback = function(state) Toggles.AutoBuyTotem = state end
})
windowToggleElements.AutoBuyTotem = autoBuyTotemToggle

local totemSelectDropdown = TotemBuyGroup:AddDropdown("Select Totems", {
    Text = "Choose totems to buy",
    Values = TotemOptions,
    Multi = true,
    Callback = function(values)
        BuyTotemTargets = {}
        if type(values) == "table" then
            for v, active in pairs(values) do
                if active then table.insert(BuyTotemTargets, v) end
            end
        end
        totemBuyIndex = 1
    end
})
windowDropdowns.totemSelect = totemSelectDropdown

local totemDelaySlider = TotemBuyGroup:AddSlider("Totem Buy Delay", {
    Text = "Delay between totem purchases",
    Default = TotemBuyDelay,
    Min = 0.5,
    Max = 5,
    Rounding = 1,
    Suffix = " sec",
    Callback = function(value) TotemBuyDelay = value end
})
windowSliders.totemBuyDelay = totemDelaySlider

-- ========== TAB 3: Exploits ==========
local ExploitTab = Window:AddTab("Exploits", "zap")

local ExploitGroup = ExploitTab:AddLeftGroupbox("Advanced Exploits", "zap")

local stackToggle = ExploitGroup:AddToggle("Totem Multi-Place", {
    Text = "Totem Stack Exploit",
    Default = Toggles.StackExploit,
    Risky = true,
    Tooltip = "Places multiple totems at once (use with caution)",
    Callback = function(state) 
        Toggles.StackExploit = state
        if state then
            Library:Notify({
                Title = "Warning",
                Description = "Stack Exploit ON - Place totem quickly then turn OFF!",
                Time = 4
            })
        end
    end
})
windowToggleElements.StackExploit = stackToggle

local stackSlider = ExploitGroup:AddSlider("Stack Amount", {
    Text = "Number to stack",
    Default = StackAmount,
    Min = 2,
    Max = 500,
    Suffix = "x",
    Callback = function(value) StackAmount = value end
})
windowSliders.stackAmount = stackSlider

local instantToggle = ExploitGroup:AddToggle("Instant Interact", {
    Text = "Instant Prompts",
    Default = Toggles.InstantPrompt,
    Risky = true,
    Tooltip = "Interact with prompts instantly (no hold time)",
    Callback = function(state) Toggles.InstantPrompt = state end
})
windowToggleElements.InstantPrompt = instantToggle

local antiAFKToggle = ExploitGroup:AddToggle("Anti AFK", {
    Text = "Anti AFK",
    Default = Toggles.AntiAFK,
    Tooltip = "Prevents being kicked for idle",
    Callback = function(state) Toggles.AntiAFK = state end
})
windowToggleElements.AntiAFK = antiAFKToggle

ExploitGroup:AddButton("Auto Clear Yard", {
    Text = "Auto Clear Entire Yard",
    Risky = true,
    Tooltip = "Clears all items from your lot",
    Callback = clearYard
})

-- ========== TAB 4: Info ==========
local InfoTab = Window:AddTab("Info", "info")

local StatusGroup = InfoTab:AddLeftGroupbox("Live Status", "activity")

local statusLabel = StatusGroup:AddLabel("")
local meatCountLabel = StatusGroup:AddLabel("")
local totemStatusLabel = StatusGroup:AddLabel("")

local function updateStatus()
    local active = {}
    if Toggles.AutoCook then table.insert(active, "Cook") end
    if Toggles.AutoPlate then table.insert(active, "Plate") end
    if Toggles.AutoSell then table.insert(active, "Sell") end
    if Toggles.AutoBuy then table.insert(active, "Buy Meat") end
    if Toggles.AutoBuyTotem then table.insert(active, "Totems") end
    if Toggles.StackExploit then table.insert(active, "Stack") end
    if Toggles.InstantPrompt then table.insert(active, "Instant") end
    
    local statusText = #active > 0 and table.concat(active, " | ") or "Idle"
    statusLabel:SetText("Active: " .. statusText)
    
    local meatCount = 0
    if player.Character then
        for _, t in ipairs(player.Character:GetChildren()) do
            if t:IsA("Tool") and string.find(t.Name, "Raw") then meatCount = meatCount + 1 end
        end
    end
    if player:FindFirstChild("Backpack") then
        for _, t in ipairs(player.Backpack:GetChildren()) do
            if t:IsA("Tool") and string.find(t.Name, "Raw") then meatCount = meatCount + 1 end
        end
    end
    meatCountLabel:SetText("Raw Meat: " .. meatCount)
    totemStatusLabel:SetText("Totems in queue: " .. #BuyTotemTargets)
end

task.spawn(function()
    while task.wait(1) do
        updateStatus()
    end
end)

local TipsGroup = InfoTab:AddRightGroupbox("Tips", "lightbulb")
TipsGroup:AddLabel("• Cook only works on owned grills")
TipsGroup:AddLabel("• Clear yard requires Hammer")
TipsGroup:AddLabel("• Stack Exploit: ON before placing, OFF after")
TipsGroup:AddLabel("• Totem buy uses round-robin rotation")
TipsGroup:AddLabel("• Auto Sell accepts NPC offers instantly")
TipsGroup:AddLabel("• Save configs to keep your settings!")

local CreditsGroup = InfoTab:AddRightGroupbox("Credits", "award")
CreditsGroup:AddLabel("BBQ Mastery v16.0")
CreditsGroup:AddLabel("Powered by Obsidian UI")
CreditsGroup:AddLabel("Made for BBQ Simulator")
CreditsGroup:AddLabel("")
CreditsGroup:AddLabel("Script By Rick Hub")
CreditsGroup:AddLabel("Status: Ready")
CreditsGroup:AddLabel("Config System: Active")

-- ========== TAB 5: Config ==========
local ConfigTab = Window:AddTab("Config", "settings")

local ConfigGroup = ConfigTab:AddLeftGroupbox("Config Management", "folder")

local currentConfigLabel = ConfigGroup:AddLabel("Current: " .. CurrentConfigName)
windowLabels.currentConfig = currentConfigLabel

local configNameInput = ConfigGroup:AddInput("Config Name", {
    Text = "Config Name",
    Placeholder = "Enter config name",
    Callback = function(text) 
        if text and text ~= "" then
            SelectedConfigName = text
        end
    end
})
windowLabels.configNameInput = configNameInput
if SelectedConfigName then
    configNameInput:SetValue(SelectedConfigName)
end

local configList = getConfigList()
local configDropdown = ConfigGroup:AddDropdown("Config List", {
    Text = "Available Configs",
    Values = #configList > 0 and configList or {"No configs"},
    Multi = false,
    Callback = function(value)
        if value and value ~= "No configs" then
            SelectedConfigName = value
            configNameInput:SetValue(value)
        end
    end
})
windowDropdowns.configList = configDropdown

ConfigGroup:AddButton("Create Config", {
    Text = "Create New Config",
    Callback = function()
        local newName = configNameInput.Value
        if newName == "" or newName == "No configs" then
            Library:Notify({Title = "Error", Description = "Please enter a valid config name!", Time = 2})
            return
        end
        if createConfig(newName) then
            CurrentConfigName = newName
            SelectedConfigName = newName
            currentConfigLabel:SetText("Current: " .. CurrentConfigName)
            local newList = getConfigList()
            configDropdown:SetValues(#newList > 0 and newList or {"No configs"})
            configDropdown:SetValue(newName)
        end
    end
})

ConfigGroup:AddButton("Save Config", {
    Text = "Save Config (Overwrite)",
    Callback = function()
        local targetName = configNameInput.Value
        if targetName == "" or targetName == "No configs" then
            Library:Notify({Title = "Error", Description = "Select a config from list or enter name!", Time = 2})
            return
        end
        if saveConfig(targetName, true) then            CurrentConfigName = targetName
            SelectedConfigName = targetName
            currentConfigLabel:SetText("Current: " .. CurrentConfigName)
            local newList = getConfigList()
            configDropdown:SetValues(#newList > 0 and newList or {"No configs"})
            configDropdown:SetValue(targetName)
        end
    end
})

ConfigGroup:AddButton("Load Config", {
    Text = "Load Config",
    Callback = function()
        local targetName = configNameInput.Value
        if targetName == "" or targetName == "No configs" then
            Library:Notify({Title = "Error", Description = "Select a config from list!", Time = 2})
            return
        end
        loadConfig(targetName, false)
    end
})

ConfigGroup:AddButton("Delete Config", {
    Text = "Delete Config",
    Risky = true,
    Callback = function()
        local targetName = configNameInput.Value
        if targetName == "" or targetName == "No configs" or targetName == "Default" then
            Library:Notify({Title = "Error", Description = "Cannot delete this config!", Time = 2})
            return
        end
        deleteConfig(targetName)
        local newList = getConfigList()
        if #newList > 0 then
            configNameInput:SetValue(newList[1])
            SelectedConfigName = newList[1]
        else
            configNameInput:SetValue("")
            SelectedConfigName = ""
        end
    end
})

ConfigGroup:AddButton("Refresh List", {
    Text = "Refresh Config List",
    Callback = function()
        local newList = getConfigList()
        configDropdown:SetValues(#newList > 0 and newList or {"No configs"})
        if #newList > 0 and configDropdown.SetValue then
            configDropdown:SetValue(SelectedConfigName)
        end
        Library:Notify({Title = "Refreshed", Description = string.format("Found %d configs", #newList), Time = 2})
    end
})

ConfigGroup:AddDivider({Text = "Auto-Load Settings", Margin = 10})

ConfigGroup:AddButton("Set as Auto-Load", {
    Text = "Set Current Config as Auto-Load",
    Callback = function()
        setAutoLoadConfig(CurrentConfigName)
    end
})

ConfigGroup:AddButton("Clear Auto-Load", {
    Text = "Clear Auto-Load",
    Risky = true,
    Callback = function()
        setAutoLoadConfig("")
    end
})

-- ========== LOAD AUTO-LOAD ==========
if pendingAutoLoad then
    task.spawn(function()
        task.wait(0.5)
        loadConfig(pendingAutoLoad, false)
        pendingAutoLoad = nil
        Library:Notify({Title = "Auto-Load", Description = string.format("Loaded '%s' from auto-load", autoLoadName), Time = 2})
    end)
end

-- Initial notification
Library:Notify({
    Title = "BBQ Mastery",
    Description = "Script loaded with Cannabis Icon! 🌿",
    Time = 3
})

print("✅ BBQ Mastery v16.0 (Cannabis Icon) Loaded!")
print("👑 Script By Rick Hub")
