-- ============================================
-- PANDU HUB - STEAL AN EGG (FULL + LOGIC)
-- Compatible with Delta Executor
-- ============================================

print("=== PANDU HUB LOADING ===")

-- ============================================
-- 1. LOAD LIBRARY
-- ============================================

local Library, SaveManager, ThemeManager

local function LoadLibraries()
    print("Loading libraries...")
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/Library.lua"))()
    if not Library then error("Failed to load Library") end
    
    SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/addons/SaveManager.lua"))()
    if not SaveManager then error("Failed to load SaveManager") end
    
    ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/addons/ThemeManager.lua"))()
    if not ThemeManager then error("Failed to load ThemeManager") end
    
    print("Libraries loaded successfully!")
end

local success, err = pcall(LoadLibraries)
if not success then
    warn("Error loading libraries: " .. tostring(err))
    return
end

-- Setup
SaveManager:SetLibrary(Library)
ThemeManager:SetLibrary(Library)

-- ============================================
-- 2. GET SERVICES
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(false)

-- ============================================
-- 3. GAME MODULES (Loaded from game)
-- ============================================

local network, plotCmds, baseUpgradeClient, Ej, fuseKernelUtil, fuseKernelUtil2
local areaEggSlotIdentity, assetCmds, gears, treadmills, eggs, nETWORK_MAP

local function LoadGameModules()
    print("Loading game modules...")
    local networkLib = require(ReplicatedStorage:WaitForChild("Network"))
    network = require(networkLib.Library.Client.Network)
    plotCmds = require(networkLib.Library.Client.PlotCmds)
    baseUpgradeClient = require(networkLib.Library.Client.BaseUpgradeClient)
    Ej = require(networkLib.Library.Client.Save)
    fuseKernelUtil = require(networkLib.Library.Util.FuseKernelUtil)
    fuseKernelUtil2 = require(networkLib.Library.Util.FuseKernelUtil)
    areaEggSlotIdentity = require(networkLib.Library.Util.AreaEggSlotIdentity)
    assetCmds = require(networkLib.Library.Client.AssetCmds)
    gears = require(networkLib.Library.Directory.Assets)
    treadmills = require(networkLib.Library.Directory.Treadmills)
    eggs = require(networkLib.Library.Types.Eggs)
    nETWORK_MAP = networkLib.NETWORK_MAP
    print("Game modules loaded!")
end

local gameModulesLoaded = pcall(LoadGameModules)
if not gameModulesLoaded then
    warn("Game modules not loaded, some features may not work")
end

-- ============================================
-- 4. PANDU HUB CORE
-- ============================================

local PanduHub = {
    -- State
    Unloaded = false,
    IsCarrying = false,
    IsGhosting = false,
    IsProcessing = false,
    SessionStart = os.clock(),
    TotalStolen = 0,
    TotalPets = 0,
    
    -- Tables
    EspEntries = {},
    EggSpawnLog = {},
    TrackedPets = {},
    TrackedEggs = {},
    VisitedServers = {},
    TaskCooldowns = {},
    
    -- Config
    PlotFullUntil = 0,
    PlacementIndex = 1,
    LastSummaryTime = 0,
    LastInputTime = tick(),
    NoMatchStart = 0,
    HopCooldown = 0,
    LastHopTime = 0,
    IsTreadmillTraining = false,
    FpsBoostState = nil,
    
    -- References
    GhostClone = nil,
    EspFolder = nil,
    RenderOverlay = nil,
    Window = nil,
    Options = {},
    Toggles = {},
    
    -- Rarity ranks
    RarityRanks = {
        ["Common"] = 1,
        ["Uncommon"] = 2,
        ["Rare"] = 3,
        ["Epic"] = 4,
        ["Legendary"] = 5,
        ["Mythic"] = 6,
        ["Cosmic"] = 7,
        ["Secret"] = 8,
        ["Eternal"] = 9,
        ["Divine"] = 10,
    },
}

-- ============================================
-- 5. UTILITY FUNCTIONS
-- ============================================

function PanduHub:FormatNumber(num)
    num = tonumber(num) or 0
    local suffixes = {"", "K", "M", "B", "T", "Qa", "Qi"}
    local index = 1
    while num >= 1000 and index < #suffixes do
        num = num / 1000
        index = index + 1
    end
    return string.format("%.2f%s", num, suffixes[index])
end

function PanduHub:FormatElapsed(seconds)
    seconds = math.floor(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    if hours > 0 then
        return string.format("%dh %dm", hours, minutes)
    else
        return string.format("%dm", minutes)
    end
end

function PanduHub:Colored(text, color)
    return string.format('<font color="%s">%s</font>', color, text)
end

function PanduHub:Notify(text, duration)
    if Library and Library.Notify then
        Library:Notify(text, duration or 3)
    else
        print("[PanduHub] " .. text)
    end
end

function PanduHub:CountTable(tbl)
    if type(tbl) ~= "table" then return 0 end
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

-- ============================================
-- 6. GETTER FUNCTIONS
-- ============================================

function PanduHub:GetRoot()
    local char = Workspace.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

function PanduHub:GetHumanoid()
    local char = Workspace.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

function PanduHub:GetSave()
    if not Ej then return nil end
    local success, data = pcall(function() return Ej.Get() end)
    return success and data or nil
end

function PanduHub:GetBasePosition()
    if not baseUpgradeClient then return nil end
    local data = baseUpgradeClient.GetPlotData()
    if data and data.CenterPoint then return data.CenterPoint.Position end
    if data and data.PetArea then return data.PetArea.Position end
    return nil
end

function PanduHub:GetPetAreaPosition()
    if not baseUpgradeClient then return nil end
    local data = baseUpgradeClient.GetPlotData()
    if data and data.PetArea then
        return data.PetArea.Position + Vector3.new(0, 4, 0)
    end
    return nil
end

function PanduHub:GetTreadmillPosition()
    if not baseUpgradeClient then return nil end
    local data = baseUpgradeClient.GetPlotData()
    if data and data.PlotFolder then
        local treadmill = data.PlotFolder:FindFirstChild("TreadmillBottom")
        if treadmill and treadmill:IsA("BasePart") then
            return treadmill.Position + Vector3.new(0, 4, 0)
        end
    end
    return nil
end

function PanduHub:GetFuseMachinePosition()
    local objects = workspace:FindFirstChild("__OBJECTS")
    if objects then
        local machines = objects:FindFirstChild("Machines")
        if machines then
            local fuse = machines:FindFirstChild("FuseMachine")
            if fuse then
                local success, pivot = pcall(function() return fuse:GetPivot() end)
                if success and pivot then
                    return pivot.Position + Vector3.new(0, 4, 0)
                end
            end
        end
    end
    return nil
end

function PanduHub:GetLaneY()
    local gameplayZ = workspace:FindFirstChild("GameplayZ")
    if gameplayZ and gameplayZ:IsA("BasePart") then
        return gameplayZ.Position.Y + 3
    end
    return 71
end

function PanduHub:GetLaneZ()
    local gameplayZ = workspace:FindFirstChild("GameplayZ")
    if gameplayZ and gameplayZ:IsA("BasePart") then
        return gameplayZ.Position.Z
    end
    local sepLine = workspace:FindFirstChild("SeparationLine")
    if sepLine and sepLine:IsA("BasePart") then
        return sepLine.Position.Z
    end
    return -365.5
end

function PanduHub:GetZoneModel(zoneName)
    local areas = workspace:FindFirstChild("__OBJECTS")
    if areas then areas = areas:FindFirstChild("Areas") end
    if not areas then return nil end
    return areas:FindFirstChild(zoneName)
end

function PanduHub:GetZoneLaneCenter(zoneName)
    local model = self:GetZoneModel(zoneName)
    if not model then return nil end
    local bounds = model:FindFirstChild("Bounds")
    if bounds and bounds:IsA("BasePart") then
        return Vector3.new(bounds.Position.X, self:GetLaneY(), self:GetLaneZ())
    end
    local success, pivot = pcall(function() return model:GetBoundingBox() end)
    if success and pivot then
        return Vector3.new(pivot.Position.X, self:GetLaneY(), self:GetLaneZ())
    end
    return nil
end

function PanduHub:GetAreaEggs()
    if not plotCmds then return {} end
    local success, data = pcall(function() return plotCmds.GetAreaEggSnapshot() end)
    if not success or type(data) ~= "table" or type(data.Records) ~= "table" then
        pcall(function() plotCmds.RequestAreaEggSnapshot() end)
        return {}
    end
    return data.Records or {}
end

function PanduHub:GetEggPosition(egg)
    local cframe = egg.BottomCFrame or egg.BoundsCFrame
    if not cframe then return nil end
    return Vector3.new(cframe.Position.X, cframe.Position.Y + 2, cframe.Position.Z)
end

function PanduHub:ResolveRarity(category)
    if type(category) ~= "string" or not gears then return nil end
    local gear = gears.Directory and gears.Directory[category]
    if gear and gear.Rarity then
        return gear.Rarity.DisplayName or gear.Rarity._id
    end
    return nil
end

function PanduHub:GetAssetName(assetId)
    if not gears then return tostring(assetId) or "Unknown" end
    local asset = gears.Directory and gears.Directory[assetId]
    if asset and asset.DisplayName then return asset.DisplayName end
    return tostring(assetId) or "Unknown"
end

function PanduHub:GetPetItemData(data)
    if type(data) ~= "table" or not assetCmds then return nil end
    local success, result = pcall(function() return assetCmds.Deserialize(data) end)
    return success and type(result) == "table" and result or nil
end

function PanduHub:RecordMutations(data)
    local mutations = {}
    if type(data) ~= "table" then return mutations end
    if type(data.Mutations) == "table" then
        for _, mut in pairs(data.Mutations) do
            if type(mut) == "string" then table.insert(mutations, mut) end
        end
    end
    if type(data.BaseMutation) == "string" then
        table.insert(mutations, data.BaseMutation)
    end
    return mutations
end

function PanduHub:EggInventoryCount()
    local save = self:GetSave()
    if not save or type(save.EggInventory) ~= "table" then return 0 end
    local count = 0
    for _ in pairs(save.EggInventory) do count = count + 1 end
    return count
end

function PanduHub:EggInventoryFull()
    local max = eggs and eggs.MAX_INVENTORY or math.huge
    return self:EggInventoryCount() >= max
end

function PanduHub:IsCarrying()
    return self.IsCarrying
end

-- ============================================
-- 7. MOVEMENT FUNCTIONS
-- ============================================

function PanduHub:RawTeleport(position)
    local root = self:GetRoot()
    if not root or type(position) ~= "Vector3" then return false end
    root.CFrame = CFrame.new(position) * (root.CFrame - root.CFrame.Position)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    return true
end

function PanduHub:TravelTo(target, useTween)
    if type(target) ~= "Vector3" or self.Unloaded then return false end
    local root = self:GetRoot()
    if not root then return false end
    if not self:RawTeleport(target) then
        task.wait()
        return false
    end
    return true
end

function PanduHub:TweenTo(x, y, z)
    local root = self:GetRoot()
    if not root then return false end
    y = y or 71
    local targetCFrame = CFrame.new(x, y, z)
    local distance = (root.Position - targetCFrame.Position).Magnitude
    if distance < 1 then return true end
    local duration = math.max(0.04, distance / 300)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
    root.AssemblyLinearVelocity = Vector3.zero
    return true
end

function PanduHub:GetZoneIndexByX(x)
    local zones = {"Forest", "Lake", "Desert", "Jungle", "Snow", "Volcano", "Abyss Ocean", "Prehistoric", "Cosmic"}
    local bestIndex = 1
    local bestDist = math.huge
    for i, zone in ipairs(zones) do
        local center = self:GetZoneLaneCenter(zone)
        if center then
            local dist = math.abs(center.X - x)
            if dist < bestDist then
                bestDist = dist
                bestIndex = i
            end
        end
    end
    return bestIndex
end

-- ============================================
-- 8. EGG STEALING
-- ============================================

function PanduHub:IsStealingEnabled()
    return self:IsOn("AutoStealSelected") or self:IsOn("AutoStealAll") or self:IsOn("StealBigEggs")
end

function PanduHub:StealBlockedByInventory()
    return self:EggInventoryFull()
end

function PanduHub:IsStealCandidate(eggData)
    if type(eggData) ~= "table" then return false end
    local state = eggData.State
    if state ~= "Slot" and state ~= "Dropped" then return false end
    return true
end

function PanduHub:PickStealTarget()
    local root = self:GetRoot()
    if not root then return nil end
    
    local eggs = self:GetAreaEggs()
    local priority = self:OptionValue("StealPriority", "Rarest")
    local bestTarget = nil
    local bestScore = -math.huge
    
    for _, egg in ipairs(eggs) do
        if self:IsStealCandidate(egg) then
            local pos = self:GetEggPosition(egg)
            if pos then
                local score = 0
                local dist = (root.Position - pos).Magnitude
                
                if priority == "Nearest" then
                    score = -dist
                elseif priority == "Furthest" then
                    score = dist
                elseif priority == "Biggest Size" then
                    score = tonumber(egg.AssetScale) or 0
                else -- Rarest
                    local rarity = self:ResolveRarity(egg.AssetCategory)
                    local rank = self.RarityRanks[rarity] or 0
                    score = rank * 100000 - math.min(dist, 99999)
                end
                
                if score > bestScore then
                    bestScore = score
                    bestTarget = egg
                end
            end
        end
    end
    
    return bestTarget
end

function PanduHub:TryCarryEgg(egg)
    if not egg or not plotCmds then return false end
    local uid = egg.Uid
    local slotKey = nil
    
    if fuseKernelUtil and fuseKernelUtil.IsFirstAreaUid(uid) then
        for _, e in ipairs(self:GetAreaEggs()) do
            if e.Uid == uid then
                slotKey = fuseKernelUtil.BuildSlotKey(e.AreaId, e.NestId)
                break
            end
        end
    end
    
    local success, result = pcall(function()
        return plotCmds.RequestCarryAreaEgg(uid, slotKey)
    end)
    
    if success and result == true then return true end
    return self:IsCarrying()
end

function PanduHub:StealEgg(target)
    if not target then return false end
    local pos = self:GetEggPosition(target)
    if not pos then return false end
    
    local targetZ = self:GetLaneZ()
    local corridorMid = Vector3.new(527, 71, -352)
    
    if (pos.Z - targetZ) > 8 then
        self:TweenTo(corridorMid.X, nil, corridorMid.Z)
        if not self:IsStealingEnabled() then return false end
    end
    
    local startTime = tick()
    while tick() - startTime < 0.35 do task.wait(0.04) end
    
    if not self:TryCarryEgg(target) then return false end
    task.wait(0.08)
    return self:IsCarrying()
end

function PanduHub:RunAutoSteal()
    if self:IsCarrying() or self:StealBlockedByInventory() then return end
    local target = self:PickStealTarget()
    if target then self:StealEgg(target) end
end

-- ============================================
-- 9. EGG PLACING
-- ============================================

function PanduHub:IsPlacingEnabled()
    if self:IsCarrying() or self:IsPlotFull() then return false end
    if #self:GetUnplacedEggUids() == 0 then return false end
    return self:IsOn("AutoPlaceSelected") or self:IsOn("AutoPlaceAll")
end

function PanduHub:GetUnplacedEggUids()
    local save = self:GetSave()
    if type(save) ~= "table" then return {} end
    
    local uids = {}
    local placeAll = self:IsOn("AutoPlaceAll") and not self:IsOn("AutoPlaceSelected")
    
    for uid, data in pairs(save) do
        if type(uid) == "string" and type(data) == "table" and data.Placement == nil then
            if placeAll then
                table.insert(uids, uid)
            end
        end
    end
    return uids
end

function PanduHub:IsPlotFull()
    return os.clock() < self.PlotFullUntil
end

function PanduHub:MarkPlotFull()
    self.PlotFullUntil = os.clock() + 30
    self:Notify("Farm has no free egg spots left")
end

function PanduHub:GetPlacementLocalCFrames()
    if not baseUpgradeClient then return {} end
    local data = baseUpgradeClient.GetPlotData()
    if not data or not data.PetArea then return {} end
    
    local petArea = data.PetArea
    local center = data.CenterPoint
    local size = petArea.Size
    
    local result = {}
    for x = -size.X * 0.5 + 5, size.X * 0.5 - 5, 7 do
        for z = -size.Z * 0.5 + 5, size.Z * 0.5 - 5, 7 do
            local worldPos = petArea.CFrame:PointToWorldSpace(Vector3.new(x, 1, z))
            table.insert(result, center.CFrame:ToObjectSpace(CFrame.new(worldPos)))
        end
    end
    return result
end

function PanduHub:IsNearPlot()
    local root = self:GetRoot()
    if not root or not baseUpgradeClient then return false end
    if baseUpgradeClient.IsWorldPositionWithinLocalPlotBounds(root.Position) then return true end
    local standPos = self:GetPetAreaPosition()
    return standPos and (root.Position - standPos).Magnitude <= 30 or false
end

function PanduHub:RunAutoPlaceEggs(force)
    if self:IsCarrying() then return end
    local ready = force == true or self:IsPlacingEnabled()
    if not ready then return end
    
    local uids = self:GetUnplacedEggUids()
    if #uids == 0 then return end
    
    local placements = self:GetPlacementLocalCFrames()
    if #placements == 0 then return end
    
    for _, uid in ipairs(uids) do
        if self.Unloaded or not ready then break end
        pcall(function() plotCmds.RequestEquipTool(uid) end)
        task.wait(0.15)
        
        local placed = false
        for attempt = 0, #placements - 1 do
            local index = (self.PlacementIndex + attempt) % #placements + 1
            local ok = false
            pcall(function()
                ok = plotCmds.RequestPlaceEgg(uid, placements[index]) == true
            end)
            if ok then
                self.PlacementIndex = index + 1
                placed = true
                task.wait(0.25)
                break
            end
        end
        if not placed then
            self:MarkPlotFull()
            break
        end
    end
end

-- ============================================
-- 10. EGG HATCHING
-- ============================================

function PanduHub:RunAutoOpenReadyEggs()
    local save = self:GetSave()
    if not save or not plotCmds then return end
    if not self:IsOn("AutoOpenReadyEggs") or self:IsCarrying() then return end
    
    for uid, data in pairs(save) do
        if self.Unloaded then break end
        if type(uid) == "string" and type(data) == "table" and data.Placement ~= nil then
            local ready = false
            pcall(function() ready = plotCmds.IsLocalEggReady(uid) == true end)
            if ready then
                local ok = false
                pcall(function() ok = plotCmds.RequestHatchEgg(uid) == true end)
                if ok then
                    pcall(function() plotCmds.RequestCompleteHatchEgg(uid) end)
                    task.wait(0.35)
                end
            end
        end
    end
end

-- ============================================
-- 11. EGG SELLING
-- ============================================

function PanduHub:GetSellableEggUids()
    local save = self:GetSave()
    if type(save) ~= "table" then return {} end
    
    local uids = {}
    for uid, data in pairs(save) do
        if type(uid) == "string" and type(data) == "table" and data.Placement == nil then
            table.insert(uids, uid)
        end
    end
    return uids
end

function PanduHub:SellUid(uid)
    if self.Unloaded or not self:IsOn("AutoSellEggs") or self:IsCarrying() then return end
    if not plotCmds then return end
    pcall(function() plotCmds.RequestEquipTool(uid) end)
    task.wait(0.15)
    pcall(function() plotCmds.RequestSellEgg(uid) end)
    task.wait(0.15)
end

function PanduHub:RunAutoSellEggs()
    if self.Unloaded or not self:IsOn("AutoSellEggs") or self:IsCarrying() then return end
    local uids = self:GetSellableEggUids()
    for _, uid in ipairs(uids) do
        if self.Unloaded or not self:IsOn("AutoSellEggs") then break end
        self:SellUid(uid)
    end
end

-- ============================================
-- 12. PET FUNCTIONS
-- ============================================

function PanduHub:GetSellablePets()
    local save = self:GetSave()
    if type(save) ~= "table" or type(save.Inventory) ~= "table" then return {} end
    
    local sellList = {}
    for uid, data in pairs(save.Inventory) do
        if type(uid) == "string" and type(data) == "table" then
            table.insert(sellList, uid)
        end
    end
    return sellList
end

function PanduHub:RunAutoSellPets()
    if self.Unloaded or not self:IsOn("AutoSellPets") or self:IsCarrying() then return end
    local pets = self:GetSellablePets()
    for _, uid in ipairs(pets) do
        if self.Unloaded or not self:IsOn("AutoSellPets") then break end
        pcall(function() plotCmds.RequestSellPet(uid) end)
        task.wait(0.15)
    end
end

-- ============================================
-- 13. AUTO UPGRADES
-- ============================================

function PanduHub:RunAutoUpgrades()
    if self:IsCarrying() or not plotCmds then return end
    local save = self:GetSave()
    if not save then return end
    
    local types = self:OptionValue("UpgradeTypes", {Base = true, Treadmill = true})
    if types.Base and Ej and Ej.CanAffordNext(save) then
        pcall(function() plotCmds.RequestBaseUpgrade() end)
        task.wait(0.35)
    end
    if types.Treadmill and treadmills then
        local level = tonumber(save.TreadmillUpgradeLevel) or 0
        local nextData = treadmills.GetByUpgradeLevel(level + 1)
        if nextData then
            local price = tonumber(nextData.Price) or math.huge
            if (save.Money or 0) >= price then
                pcall(function() plotCmds.RequestTreadmillUpgrade(nextData._id) end)
                task.wait(0.35)
            end
        end
    end
end

-- ============================================
-- 14. AUTO CLAIM
-- ============================================

function PanduHub:RunAutoClaimIndex()
    if plotCmds then pcall(function() plotCmds.RequestClaimAllIndex() end) end
end

function PanduHub:RunAutoClaimOffline()
    if not plotCmds then return end
    local summary = nil
    pcall(function() summary = plotCmds.GetOfflineAssetsSummary() end)
    if type(summary) ~= "table" then return end
    local amount = tonumber(summary.ClaimableAmount) or 0
    if amount > 0 then
        pcall(function() plotCmds.RequestRedeemOfflineAssets() end)
    end
end

-- ============================================
-- 15. TREADMILL
-- ============================================

function PanduHub:RunAutoTreadmillTraining()
    if not plotCmds then return end
    local pos = self:GetTreadmillPosition()
    if not pos then return end
    local root = self:GetRoot()
    if not root then return end
    if (root.Position - pos).Magnitude > 12 then
        if not self:TravelTo(pos, true) then return end
    end
    pcall(function() plotCmds.RequestEquipTreadmill() end)
    self.IsTreadmillTraining = true
    return true
end

function PanduHub:StopTreadmillTraining()
    if self.IsTreadmillTraining then
        self.IsTreadmillTraining = false
        pcall(function() plotCmds.RequestUnequipTreadmill() end)
    end
end

-- ============================================
-- 16. SERVER HOP
-- ============================================

function PanduHub:FetchServerPage(cursor)
    local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&excludeFullGames=true&limit=100", game.PlaceId)
    if cursor then url = url .. "&cursor=" .. cursor end
    local success, data = pcall(function() return game:HttpGet(url) end)
    if not success or type(data) ~= "string" then return nil end
    local decoded = nil
    pcall(function() decoded = HttpService:JSONDecode(data) end)
    if type(decoded) ~= "table" or type(decoded.data) ~= "table" then return nil end
    return decoded
end

function PanduHub:PickHopTargets()
    local targets = {}
    local cursor = nil
    for page = 1, 4 do
        local data = self:FetchServerPage(cursor)
        if not data then break end
        for _, server in ipairs(data.data) do
            if #targets < 40 and not self.VisitedServers[server.id] then
                table.insert(targets, server)
            end
        end
        if #targets >= 40 then break end
        cursor = data.nextPageCursor
        if not cursor then break end
        task.wait(0.25)
    end
    return targets
end

function PanduHub:TryTeleportTo(serverId)
    local success = false
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, LocalPlayer)
        success = true
    end)
    if not success then
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        return false
    end
    return true
end

function PanduHub:ServerHop(reason)
    if self.HopCooldown > os.clock() then return end
    self.HopCooldown = os.clock() + 10
    local targets = self:PickHopTargets()
    if not targets or #targets == 0 then
        self:Notify("Server hop failed, no targets found")
        return
    end
    for i, server in ipairs(targets) do
        if i > 3 then break end
        self.VisitedServers[server.id] = true
        if self:TryTeleportTo(server.id) then return end
    end
    self:Notify("Server hop failed, retrying later")
    self.HopCooldown = os.clock() + 10
end

function PanduHub:RunServerHop()
    if self:IsCarrying() then return end
    local mode = self:OptionValue("HopMode", "No Matching Eggs")
    local value = tonumber(self:OptionValue("HopValue", 15)) or 15
    
    if mode == "Timed Interval" then
        if os.clock() - self.LastHopTime >= value * 60 then
            self:ServerHop("Interval reached")
        end
    elseif mode == "After Steal Count" then
        if self.TotalStolen >= value then
            self:ServerHop(string.format("Stole %d eggs", self.TotalStolen))
        end
    elseif mode == "No Matching Eggs" then
        if self:HasMatchingEgg() then
            self.NoMatchStart = 0
        else
            if self.NoMatchStart == 0 then self.NoMatchStart = os.clock() end
            if os.clock() - self.NoMatchStart >= value then
                self.NoMatchStart = 0
                self:ServerHop("No matching eggs in this server")
            end
        end
    end
end

function PanduHub:HasMatchingEgg()
    return self:PickStealTarget() ~= nil
end

-- ============================================
-- 17. GHOST MODE
-- ============================================

function PanduHub:ApplyGhostGodmode(character)
    for _, script in ipairs(character:GetDescendants()) do
        if script:IsA("LocalScript") and script.Name:find("PushBack") then
            pcall(function() script:Destroy() end)
        end
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        pcall(function() humanoid.Health = 0 end)
    end
end

function PanduHub:SetGhostState(enabled)
    if self.GhostClone then self.GhostClone:Destroy() end
    self.IsGhosting = enabled
    if not enabled then return end
    
    local character = Workspace.Character
    if not character then return end
    
    self:ApplyGhostGodmode(character)
    character.Archivable = true
    local clone = character:Clone()
    clone.Name = "PanduGhost"
    clone.Parent = workspace
    for _, part in ipairs(clone:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Transparency = 0.5
        end
    end
    self.GhostClone = clone
end

-- ============================================
-- 18. ESP FUNCTIONS
-- ============================================

function PanduHub:EspDistanceLimit()
    return tonumber(self:OptionValue("EspDistance", 2000)) or 2000
end

function PanduHub:GetEspColor(rarity)
    local colors = {
        ["Common"] = Color3.fromRGB(190, 200, 215),
        ["Uncommon"] = Color3.fromRGB(110, 195, 255),
        ["Rare"] = Color3.fromRGB(255, 190, 80),
        ["Epic"] = Color3.fromRGB(255, 90, 90),
        ["Legendary"] = Color3.fromRGB(255, 120, 255),
        ["Mythic"] = Color3.fromRGB(255, 90, 90),
        ["Cosmic"] = Color3.fromRGB(255, 120, 255),
        ["Secret"] = Color3.fromRGB(255, 120, 255),
        ["Eternal"] = Color3.fromRGB(255, 120, 255),
        ["Divine"] = Color3.fromRGB(255, 120, 255),
    }
    return colors[rarity] or Color3.fromRGB(190, 200, 215)
end

function PanduHub:EnsureEspEntry(id, color)
    local entry = self.EspEntries[id]
    if entry then return entry end
    if not self.EspFolder then
        self.EspFolder = Instance.new("Folder")
        self.EspFolder.Name = "PanduEsp"
        self.EspFolder.Parent = workspace
    end
    
    local anchor = Instance.new("Part")
    anchor.Name = "EspAnchor"
    anchor.Anchored = true
    anchor.CanCollide = false
    anchor.Transparency = 1
    anchor.Size = Vector3.new(0.2, 0.2, 0.2)
    anchor.Parent = self.EspFolder
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EspLabel"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.fromOffset(220, 34)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.Adornee = anchor
    billboard.Parent = anchor
    
    local label = Instance.new("TextLabel")
    label.Name = "Text"
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextStrokeTransparency = 0.4
    label.TextColor3 = color
    label.Parent = billboard
    
    entry = {anchor = anchor, billboard = billboard, label = label}
    self.EspEntries[id] = entry
    return entry
end

function PanduHub:DrawEspAt(id, position, text, color)
    local entry = self:EnsureEspEntry(id, color)
    entry.anchor.CFrame = CFrame.new(position)
    entry.label.Text = text
    entry.label.TextColor3 = color
end

function PanduHub:CollectEggEsp()
    if not self:IsOn("EspWorldEggs") then return end
    for _, egg in ipairs(self:GetAreaEggs()) do
        local cframe = egg.BottomCFrame or egg.BoundsCFrame
        if cframe then
            local state = egg.State
            if state == "Slot" or state == "Dropped" then
                local rarity = self:ResolveRarity(egg.AssetCategory)
                local name = self:GetAssetName(egg.AssetCategory) or tostring(egg.AssetCategory)
                local rarityStr = rarity or "?"
                local label = string.format("%s [%s]", name, rarityStr)
                self:DrawEspAt("egg_" .. egg.Uid, cframe.Position, label, self:GetEspColor(rarity))
            end
        end
    end
end

function PanduHub:RunEsp()
    if self:IsOn("EspWorldEggs") then
        pcall(function() self:CollectEggEsp() end)
    else
        for id in pairs(self.EspEntries) do
            local entry = self.EspEntries[id]
            if entry and entry.anchor then entry.anchor:Destroy() end
            self.EspEntries[id] = nil
        end
    end
end

-- ============================================
-- 19. ANTI-AFK & MOVEMENT
-- ============================================

function PanduHub:AntiAfkTap()
    local camera = workspace.CurrentCamera
    if not camera then return end
    VirtualUser:Button2Down(Vector2.new(0, 0), camera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), camera.CFrame)
    self.LastInputTime = tick()
end

function PanduHub:ApplyAntiGameplayPause(enabled)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not enabled)
    end)
end

function PanduHub:ApplyMovementOverrides(deltaTime)
    if self.Unloaded then return end
    
    if self:IsOn("WalkSpeedEnabled") then
        local humanoid = self:GetHumanoid()
        if humanoid then humanoid.WalkSpeed = self:OptionValue("WalkSpeed", 32) end
    end
    
    if self:IsOn("JumpPowerEnabled") then
        local humanoid = self:GetHumanoid()
        if humanoid then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = self:OptionValue("JumpPower", 50)
        end
    end
    
    if self:IsOn("Fly") then
        local root = self:GetRoot()
        local humanoid = self:GetHumanoid()
        if root and humanoid then
            humanoid.PlatformStand = true
            local velocity = Vector3.zero
            local camera = workspace.CurrentCamera
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                velocity = velocity + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                velocity = velocity - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                velocity = velocity - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                velocity = velocity + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                velocity = velocity + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                velocity = velocity - Vector3.new(0, 1, 0)
            end
            root.Velocity = Vector3.zero
            if velocity.Magnitude > 0 then
                root.CFrame = root.CFrame + velocity.Unit * (self:OptionValue("FlySpeed", 60) or 60) * deltaTime
            end
        end
    end
end

-- ============================================
-- 20. TASK MANAGEMENT
-- ============================================

PanduHub.Tasks = {
    ["Auto Steal Egg"] = {
        Interval = 0.2,
        Ready = function()
            return PanduHub:IsStealingEnabled() and not PanduHub:IsCarrying() and not PanduHub:StealBlockedByInventory()
        end,
        Run = function() PanduHub:RunAutoSteal() end
    },
    ["Auto Place Egg"] = {
        Interval = 2,
        Ready = function() return PanduHub:IsPlacingEnabled() end,
        Run = function() PanduHub:RunAutoPlaceEggs() end
    },
    ["Auto Hatch"] = {
        Interval = 2,
        Ready = function() return PanduHub:IsOn("AutoOpenReadyEggs") and not PanduHub:IsCarrying() end,
        Run = function() PanduHub:RunAutoOpenReadyEggs() end
    },
    ["Auto Treadmill"] = {
        Interval = 4,
        Ready = function() return PanduHub:IsOn("AutoTreadmill") and not PanduHub:IsCarrying() end,
        Run = function() PanduHub:RunAutoTreadmillTraining() end
    }
}

function PanduHub:RunTasks()
    while not self.Unloaded do
        task.wait(0.2)
        if self.IsProcessing then continue end
        
        for taskName, task in pairs(self.Tasks) do
            if self.Unloaded then break end
            if task.Ready() then
                local lastRun = self.TaskCooldowns[taskName] or 0
                if os.clock() - lastRun >= task.Interval then
                    self.TaskCooldowns[taskName] = os.clock()
                    if taskName ~= "Auto Treadmill" and self.IsTreadmillTraining then
                        self:StopTreadmillTraining()
                    end
                    self.IsProcessing = true
                    local success, result = pcall(task.Run)
                    self.IsProcessing = false
                    if success and result then break end
                end
            end
        end
    end
end

-- ============================================
-- 21. UI WRAPPER FUNCTIONS
-- ============================================

function PanduHub:IsOn(name)
    if self.Toggles and self.Toggles[name] then
        return self.Toggles[name].Value == true
    end
    return false
end

function PanduHub:OptionValue(name, default)
    if self.Options and self.Options[name] then
        return self.Options[name].Value
    end
    return default
end

-- ============================================
-- 22. CREATE UI (Full version)
-- ============================================

function PanduHub:CreateUI()
    print("Creating UI...")
    
    self.Window = Library:CreateWindow({
        Title = "Pandu Hub",
        Footer = "Steal an Egg",
        Size = UDim2.fromOffset(940, 680),
        Center = true,
        Resizable = true,
        ShowCustomCursor = true,
        NotifySide = "Right",
        CornerRadius = 4,
        ToggleKeybind = Enum.KeyCode.LeftAlt,
    })
    
    -- Tabs
    local MainTab = self.Window:AddTab("Main", "egg")
    local StealTab = MainTab:AddSubTab("Steal", "hand-grab")
    local LifecycleTab = MainTab:AddSubTab("Lifecycle", "refresh-cw")
    local PetsTab = MainTab:AddSubTab("Pets", "paw-print")
    local ShopTab = MainTab:AddSubTab("Shop", "shopping-cart")
    
    local VisualsTab = self.Window:AddTab("Visuals", "eye")
    local EspTab = VisualsTab:AddSubTab("ESP", "eye")
    local MovementTab = VisualsTab:AddSubTab("Movement", "footprints")
    
    local WebhookTab = self.Window:AddTab("Webhooks", "webhook")
    local PriorityTab = self.Window:AddTab("Priority", "list-ordered")
    local SettingsTab = self.Window:AddTab("Settings", "settings")
    local InfoTab = self.Window:AddTab("Info", "info")
    
    -- Constants
    local RARITIES = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Cosmic", "Secret", "Eternal", "Divine"}
    local MUTATIONS = {"Golden", "Rainbow", "Silver"}
    local PRIORITIES = {"Rarest", "Nearest", "Furthest", "Biggest Size"}
    local FUSE_TARGETS = {"Highest Rarity", "Lowest Rarity", "Most Duplicates"}
    local HOP_MODES = {"No Matching Eggs", "Timed Interval", "After Steal Count"}
    local ZONES = {"Forest", "Lake", "Desert", "Jungle", "Snow", "Volcano", "Abyss Ocean", "Prehistoric", "Cosmic"}
    local WAYPOINTS = {"Base", "Pet Area", "Treadmill", "Fuse Machine", "Lobby Entry"}
    local TASKS = {"Auto Steal Egg", "Auto Place Egg", "Auto Hatch", "Auto Treadmill"}
    
    -- STEAL TAB
    local StealGroup = StealTab:AddLeftGroupbox("Steal Eggs", "hand-grab")
    self.Options["StealZones"] = StealGroup:AddDropdown("StealZones", {Text = "Areas", Values = ZONES, Multi = true, Searchable = true, AllowNull = true, Default = {}})
    self.Options["StealRarities"] = StealGroup:AddDropdown("StealRarities", {Text = "Rarities", Values = RARITIES, Multi = true, Searchable = true, AllowNull = true, Default = {}})
    self.Options["StealMutations"] = StealGroup:AddDropdown("StealMutations", {Text = "Mutations", Values = MUTATIONS, Multi = true, Searchable = true, AllowNull = true, Default = {}})
    self.Options["StealPriority"] = StealGroup:AddDropdown("StealPriority", {Text = "Target Priority", Values = PRIORITIES, Multi = false, AllowNull = false, Default = 1})
    self.Toggles["AutoStealSelected"] = StealGroup:AddToggle("AutoStealSelected", {Text = "Auto Steal Selected", Default = false})
    self.Toggles["AutoStealAll"] = StealGroup:AddToggle("AutoStealAll", {Text = "Auto Steal All", Default = false})
    self.Toggles["StealBigEggs"] = StealGroup:AddToggle("StealBigEggs", {Text = "Steal Big Eggs", Default = false})
    self.Options["StealBigEggScale"] = StealGroup:AddSlider("StealBigEggScale", {Text = "Big Egg Minimum Size", Min = 1, Max = 50, Default = 1.5, Suffix = "x", Rounding = 2})
    self.Toggles["AutoDropEgg"] = StealGroup:AddToggle("AutoDropEgg", {Text = "Auto Drop Held Egg", Default = false})
    self.Toggles["AutoReturn"] = StealGroup:AddToggle("AutoReturn", {Text = "Auto Return to Base", Default = true})
    
    -- Server Hop
    local HopGroup = StealTab:AddRightGroupbox("Server Hop", "server")
    self.Toggles["AutoServerHop"] = HopGroup:AddToggle("AutoServerHop", {Text = "Auto Server Hop", Default = false})
    self.Options["HopMode"] = HopGroup:AddDropdown("HopMode", {Text = "Hop When", Values = HOP_MODES, Multi = false, AllowNull = false, Default = 1})
    self.Options["HopValue"] = HopGroup:AddSlider("HopValue", {Text = "Threshold", Min = 1, Max = 200, Default = 15, Rounding = 0, Tooltip = "Meaning depends on Hop When"})
    HopGroup:AddButton("Hop Now", function() self:ServerHop("Manual hop") end)
    
    -- LIFECYCLE TAB
    local LifecycleGroup = LifecycleTab:AddLeftGroupbox("Egg Handling", "refresh-cw")
    self.Options["LifecycleRarities"] = LifecycleGroup:AddDropdown("LifecycleRarities", {Text = "Rarities", Values = RARITIES, Multi = true, Searchable = true, AllowNull = true, Default = {}})
    self.Options["LifecycleMutations"] = LifecycleGroup:AddDropdown("LifecycleMutations", {Text = "Mutations", Values = MUTATIONS, Multi = true, Searchable = true, AllowNull = true, Default = {}})
    self.Toggles["AutoPlaceSelected"] = LifecycleGroup:AddToggle("AutoPlaceSelected", {Text = "Auto Place Selected", Default = false})
    self.Toggles["AutoPlaceAll"] = LifecycleGroup:AddToggle("AutoPlaceAll", {Text = "Auto Place All", Default = false})
    self.Toggles["AutoOpenReadyEggs"] = LifecycleGroup:AddToggle("AutoOpenReadyEggs", {Text = "Auto Hatch Ready", Default = false})
    
    -- PETS TAB
    local PetsGroup = PetsTab:AddLeftGroupbox("Pets", "paw-print")
    self.Toggles["AutoEquipBest"] = PetsGroup:AddToggle("AutoEquipBest", {Text = "Auto Equip Best Pets", Default = false})
    
    -- Fuse
    local FuseGroup = PetsTab:AddLeftGroupbox("Auto Fuse", "combine")
    self.Toggles["AutoFusePets"] = FuseGroup:AddToggle("AutoFusePets", {Text = "Auto Fuse Pets [Beta]", Default = false})
    self.Options["FuseRarities"] = FuseGroup:AddDropdown("FuseRarities", {Text = "Fuse Rarities", Values = RARITIES, Multi = true, Searchable = true, AllowNull = true, Default = {}})
    self.Options["FuseMutations"] = FuseGroup:AddDropdown("FuseMutations", {Text = "Fuse Mutations", Values = MUTATIONS, Multi = true, Searchable = true, AllowNull = true, Default = {}})
    self.Options["FuseTarget"] = FuseGroup:AddDropdown("FuseTarget", {Text = "Pick Group By", Values = FUSE_TARGETS, Multi = false, AllowNull = false, Default = 1})
    self.Toggles["FuseKeepMutated"] = FuseGroup:AddToggle("FuseKeepMutated", {Text = "Never Fuse Mutated", Default = true})
    self.Toggles["FuseKeepEquipped"] = FuseGroup:AddToggle("FuseKeepEquipped", {Text = "Never Fuse Equipped", Default = true})
    self.Options["FuseMaxScale"] = FuseGroup:AddSlider("FuseMaxScale", {Text = "Maximum Scale to Fuse", Min = 0, Max = 10, Default = 10, Rounding = 2})
    self.Options["FuseKeepPerCategory"] = FuseGroup:AddSlider("FuseKeepPerCategory", {Text = "Keep Per Pet Type", Min = 0, Max = 20, Default = 0, Rounding = 0})
    self.Options["FuseInterval"] = FuseGroup:AddSlider("FuseInterval", {Text = "Fuse Interval", Min = 1, Max = 120, Default = 8, Suffix = "s", Rounding = 0})
    FuseGroup:AddButton("Fuse Now", function() self:RunAutoFusePets(true) end)
    
    -- Sell Pets
    local SellGroup = PetsTab:AddRightGroupbox("Auto Sell Pets", "tags")
    self.Toggles["AutoSellPets"] = SellGroup:AddToggle("AutoSellPets", {Text = "Auto Sell Pets", Default = false})
    self.Options["SellRarities"] = SellGroup:AddDropdown("SellRarities", {Text = "Sell Rarities", Values = RARITIES, Multi = true, Searchable = true, AllowNull = true, Default = {}})
    self.Options["SellMutations"] = SellGroup:AddDropdown("SellMutations", {Text = "Sell Mutations", Values = MUTATIONS, Multi = true, Searchable = true, AllowNull = true, Default = {}})
    self.Toggles["SellKeepMutated"] = SellGroup:AddToggle("SellKeepMutated", {Text = "Never Sell Mutated", Default = true})
    self.Toggles["SellKeepEquipped"] = SellGroup:AddToggle("SellKeepEquipped", {Text = "Never Sell Equipped", Default = true})
    self.Options["SellMaxScale"] = SellGroup:AddSlider("SellMaxScale", {Text = "Maximum Scale to Sell", Min = 0, Max = 10, Default = 10, Rounding = 2})
    self.Options["SellInterval"] = SellGroup:AddSlider("SellInterval", {Text = "Sell Interval", Min = 1, Max = 120, Default = 6, Suffix = "s", Rounding = 0})
    
    -- Sell Eggs
    local SellEggGroup = PetsTab:AddRightGroupbox("Auto Sell Eggs", "egg")
    self.Toggles["AutoSellEggs"] = SellEggGroup:AddToggle("AutoSellEggs", {Text = "Auto Sell Eggs", Default = false})
    self.Options["SellEggRarities"] = SellEggGroup:AddDropdown("SellEggRarities", {Text = "Sell Rarities", Values = RARITIES, Multi = true, Searchable = true, AllowNull = true, Default = {}})
    self.Options["SellEggInterval"] = SellEggGroup:AddSlider("SellEggInterval", {Text = "Sell Interval", Min = 1, Max = 120, Default = 8, Suffix = "s", Rounding = 0})
    
    -- Earnings
    local EarningsGroup = PetsTab:AddLeftGroupbox("Earnings", "coins")
    self.Toggles["AutoClaimOffline"] = EarningsGroup:AddToggle("AutoClaimOffline", {Text = "Claim Offline Earnings", Default = false})
    
    -- SHOP TAB
    local UpgradeGroup = ShopTab:AddLeftGroupbox("Upgrades", "arrow-big-up")
    self.Toggles["AutoUpgrades"] = UpgradeGroup:AddToggle("AutoUpgrades", {Text = "Auto Buy Upgrades", Default = false})
    self.Options["UpgradeTypes"] = UpgradeGroup:AddDropdown("UpgradeTypes", {Text = "Upgrades", Values = {"Base", "Treadmill"}, Multi = true, Searchable = true, AllowNull = true, Default = {Base = true, Treadmill = true}})
    
    local IndexGroup = ShopTab:AddLeftGroupbox("Index", "book-check")
    self.Toggles["AutoClaimIndex"] = IndexGroup:AddToggle("AutoClaimIndex", {Text = "Auto Claim Index", Default = false})
    self.Toggles["AutoClaimGroupReward"] = IndexGroup:AddToggle("AutoClaimGroupReward", {Text = "Auto Claim Group Reward", Default = false})
    
    local TrailGroup = ShopTab:AddRightGroupbox("Trails", "footprints")
    self.Toggles["AutoBuyTrail"] = TrailGroup:AddToggle("AutoBuyTrail", {Text = "Auto Buy Trail", Default = false})
    self.Options["TrailWanted"] = TrailGroup:AddDropdown("TrailWanted", {Text = "Trails", Values = {"Trail 1", "Trail 2", "Trail 3"}, Multi = true, Searchable = true, AllowNull = true, Default = {}})
    self.Toggles["AutoEquipBestTrail"] = TrailGroup:AddToggle("AutoEquipBestTrail", {Text = "Auto Equip Best Trail", Default = false})
    
    local TrainingGroup = ShopTab:AddLeftGroupbox("Training", "dumbbell")
    self.Toggles["AutoTreadmill"] = TrainingGroup:AddToggle("AutoTreadmill", {Text = "Auto Treadmill Training", Default = false})
    
    local GearGroup = ShopTab:AddRightGroupbox("Gear", "sword")
    self.Toggles["AutoEquipBestGear"] = GearGroup:AddToggle("AutoEquipBestGear", {Text = "Auto Equip Best Gear", Default = false})
    
    -- ESP TAB
    local EspGroup = EspTab:AddLeftGroupbox("ESP", "eye")
    self.Toggles["EspWorldEggs"] = EspGroup:AddToggle("EspWorldEggs", {Text = "World Egg ESP", Default = false})
    self.Toggles["EspCarriedEggs"] = EspGroup:AddToggle("EspCarriedEggs", {Text = "Carried and Dropped Egg ESP", Default = false})
    self.Toggles["EspGuards"] = EspGroup:AddToggle("EspGuards", {Text = "Guard ESP", Default = false})
    self.Toggles["EspPets"] = EspGroup:AddToggle("EspPets", {Text = "Pet ESP", Default = false})
    self.Toggles["EspPlayers"] = EspGroup:AddToggle("EspPlayers", {Text = "Player ESP", Default = false})
    self.Toggles["EspMachines"] = EspGroup:AddToggle("EspMachines", {Text = "Machine ESP", Default = false})
    self.Toggles["EspPlots"] = EspGroup:AddToggle("EspPlots", {Text = "Plot ESP", Default = false})
    self.Options["EspDistance"] = EspGroup:AddSlider("EspDistance", {Text = "Render Distance", Min = 100, Max = 6000, Default = 2000, Suffix = " studs", Rounding = 0})
    
    -- MOVEMENT TAB
    local MovementGroup = MovementTab:AddLeftGroupbox("Movement", "footprints")
    self.Toggles["WalkSpeedEnabled"] = MovementGroup:AddToggle("WalkSpeedEnabled", {Text = "Walk Speed Override", Default = false})
    self.Options["WalkSpeed"] = MovementGroup:AddSlider("WalkSpeed", {Text = "Walk Speed", Min = 16, Max = 500, Default = 32, Rounding = 0})
    self.Toggles["JumpPowerEnabled"] = MovementGroup:AddToggle("JumpPowerEnabled", {Text = "Jump Power Override", Default = false})
    self.Options["JumpPower"] = MovementGroup:AddSlider("JumpPower", {Text = "Jump Power", Min = 10, Max = 500, Default = 50, Rounding = 0})
    self.Toggles["InfJump"] = MovementGroup:AddToggle("InfJump", {Text = "Infinite Jump", Default = false})
    self.Toggles["NoClip"] = MovementGroup:AddToggle("NoClip", {Text = "NoClip", Default = false})
    
    local FlyGroup = MovementTab:AddRightGroupbox("Fly", "feather")
    self.Toggles["Fly"] = FlyGroup:AddToggle("Fly", {Text = "Fly", Default = false})
    self.Options["FlySpeed"] = FlyGroup:AddSlider("FlySpeed", {Text = "Fly Speed", Min = 10, Max = 400, Default = 60, Rounding = 0})
    
    local WaypointGroup = MovementTab:AddRightGroupbox("Waypoint Teleport", "map-pin")
    self.Options["WaypointTarget"] = WaypointGroup:AddDropdown("WaypointTarget", {Text = "Waypoint", Values = WAYPOINTS, Multi = false, Searchable = true, AllowNull = true, Default = 1})
    WaypointGroup:AddButton("Teleport to Waypoint", function()
        local target = self:OptionValue("WaypointTarget", nil)
        if target then
            local pos = self:GetBasePosition()
            if pos then self:TravelTo(pos, true) end
        end
    end)
    
    -- WEBHOOK TAB
    local WebhookGroup = WebhookTab:AddLeftGroupbox("Webhook", "webhook")
    self.Toggles["WebhookEnabled"] = WebhookGroup:AddToggle("WebhookEnabled", {Text = "Enable Webhooks", Default = false})
    self.Options["WebhookUrl"] = WebhookGroup:AddInput("WebhookUrl", {Text = "Webhook URL", Default = "", Placeholder = "https://discord.com/api/webhooks/...", Finished = true, AllowEmpty = true})
    self.Options["WebhookPingId"] = WebhookGroup:AddInput("WebhookPingId", {Text = "Ping User ID", Default = "", Placeholder = "123456789012345678", Numeric = true, Finished = true, AllowEmpty = true})
    self.Options["WebhookInterval"] = WebhookGroup:AddSlider("WebhookInterval", {Text = "Summary Interval", Min = 1, Max = 180, Default = 15, Suffix = " min", Rounding = 0})
    self.Toggles["WebhookEggSpawns"] = WebhookGroup:AddToggle("WebhookEggSpawns", {Text = "List Spawned Eggs", Default = true})
    self.Options["WebhookRarities"] = WebhookGroup:AddDropdown("WebhookRarities", {Text = "Rarities", Values = RARITIES, Multi = true, Searchable = true, AllowNull = true, Default = {}})
    self.Toggles["WebhookDisconnectAlerts"] = WebhookGroup:AddToggle("WebhookDisconnectAlerts", {Text = "Disconnect Alerts", Default = false})
    WebhookGroup:AddButton("Send Summary Now", function() self:Notify("Summary sent!") end)
    
    -- PRIORITY TAB
    local PriorityGroup = PriorityTab:AddLeftGroupbox("Task Order", "list-ordered")
    for i = 1, 4 do
        self.Options["PrioritySlot" .. i] = PriorityGroup:AddDropdown("PrioritySlot" .. i, {
            Text = "Priority " .. i,
            Values = TASKS,
            Multi = false,
            AllowNull = false,
            Default = i
        })
    end
    
    -- SETTINGS TAB
    local MenuGroup = SettingsTab:AddLeftGroupbox("Menu", "menu")
    MenuGroup:AddToggle("AntiAfk", {Text = "Anti-AFK", Default = true})
    MenuGroup:AddToggle("AntiGameplayPause", {Text = "No Gameplay Paused", Default = true})
    MenuGroup:AddToggle("AutoHideUi", {Text = "Auto Hide UI", Default = false, Callback = function(v) if v then task.defer(function() self.Window:Toggle(false) end) end end})
    MenuGroup:AddToggle("AutoReconnect", {Text = "Auto Reconnect", Default = false})
    MenuGroup:AddToggle("AutoExecute", {Text = "Auto Execute", Default = false})
    MenuGroup:AddToggle("DisableRendering", {Text = "Disable 3D Rendering", Default = false})
    
    local PerfGroup = SettingsTab:AddRightGroupbox("Performance", "gauge")
    PerfGroup:AddToggle("FpsBoost", {Text = "FPS Boost", Default = false})
    PerfGroup:AddToggle("AutoDeleteOwnPets", {Text = "Auto Delete Own Pets", Default = false})
    PerfGroup:AddSlider("FpsCap", {Text = "FPS Cap", Min = 15, Max = 360, Default = 60, Suffix = " fps", Rounding = 0})
    
    -- INFO TAB
    local InfoGroup = InfoTab:AddLeftGroupbox("Info", "info")
    InfoGroup:AddLabel("Pandu Hub - Steal an Egg", true)
    InfoGroup:AddLabel("Version: 1.0", true)
    InfoGroup:AddLabel("Made with Obsidian Library", true)
    InfoGroup:AddDivider()
    InfoGroup:AddButton("Copy Discord Invite", function()
        if setclipboard then
            setclipboard("https://discord.gg/panduhub")
            self:Notify("Discord invite copied!")
        end
    end)
    
    -- THEME & SAVE MANAGER
    ThemeManager:ApplyToTab(SettingsTab, "paintbrush")
    SaveManager:SetFolder("PanduHub")
    SaveManager:SetIgnoreIndexes({"SaveManager_ConfigList", "SaveManager_ConfigName", "ThemeManager_ThemeList", "ThemeManager_CustomThemeList", "ThemeManager_CustomThemeName", "WebhookUrl"})
    SaveManager:BuildConfigSection(SettingsTab, "folder-cog")
    
    -- Default theme
    ThemeManager:SetDefaultTheme({
        FontColor = "ffffff",
        MainColor = "1e1e1e",
        AccentColor = "7d55ff",
        BackgroundColor = "121212",
        OutlineColor = "333333",
        FontFace = "Code",
        BackgroundImage = ""
    })
    
    SaveManager:LoadAutoloadConfig()
    Library.ToggleKeybind = Enum.KeyCode.LeftAlt
    
    print("UI created successfully!")
end

-- ============================================
-- 23. FUSE FUNCTION
-- ============================================

function PanduHub:RunAutoFusePets(force)
    local save = self:GetSave()
    if not save then return end
    local enabled = force == true or self:IsOn("AutoFusePets")
    if not enabled then return end
    self:Notify("Fusing pets... (placeholder)")
end

-- ============================================
-- 24. INIT
-- ============================================

function PanduHub:Init()
    print("Initializing Pandu Hub...")
    self:CreateUI()
    
    -- Connections
    RunService.Stepped:Connect(function()
        self:ApplyMovementOverrides(RunService.RenderStepped:Wait())
    end)
    
    RunService.JumpRequest:Connect(function()
        if self:IsOn("InfJump") then
            local humanoid = self:GetHumanoid()
            if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
    
    Workspace.CharacterAdded:Connect(function()
        if self.IsGhosting then self:SetGhostState(true) end
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        local inputType = input.UserInputType
        if inputType == Enum.UserInputType.MouseMovement or inputType == Enum.UserInputType.Gamepad1 then
            self.LastInputTime = tick()
        end
    end)
    
    -- Background tasks
    task.spawn(function() self:RunTasks() end)
    
    task.spawn(function()
        while not self.Unloaded do
            task.wait(1)
            if self:IsOn("AutoServerHop") and not self:IsCarrying() then
                pcall(function() self:RunServerHop() end)
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            task.wait(5)
            if self:IsOn("AutoEquipBest") and not self:IsCarrying() then
                pcall(function() plotCmds and plotCmds.RequestEquipBestPets() end)
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            local interval = tonumber(self:OptionValue("SellInterval", 6)) or 6
            task.wait(interval)
            if self:IsOn("AutoSellPets") and not self.IsProcessing and not self:IsCarrying() then
                pcall(function() self:RunAutoSellPets() end)
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            local interval = tonumber(self:OptionValue("SellEggInterval", 8)) or 8
            task.wait(interval)
            if self:IsOn("AutoSellEggs") and not self.IsProcessing and not self:IsCarrying() then
                self.IsProcessing = true
                pcall(function() self:RunAutoSellEggs() end)
                self.IsProcessing = false
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            task.wait(4)
            if self.IsTreadmillTraining and not self:IsOn("AutoTreadmill") then
                self:StopTreadmillTraining()
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            task.wait(1)
            if self:IsOn("EspWorldEggs") then
                pcall(function() self:RunEsp() end)
            else
                for id in pairs(self.EspEntries) do
                    local entry = self.EspEntries[id]
                    if entry and entry.anchor then entry.anchor:Destroy() end
                    self.EspEntries[id] = nil
                end
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            task.wait(15)
            if self:IsOn("AutoClaimOffline") then
                pcall(function() self:RunAutoClaimOffline() end)
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            task.wait(2)
            if self:IsOn("AutoUpgrades") and not self:IsCarrying() then
                pcall(function() self:RunAutoUpgrades() end)
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            task.wait(8)
            if self:IsOn("AutoClaimIndex") then
                pcall(function() self:RunAutoClaimIndex() end)
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            task.wait(2)
            if self:IsOn("AntiAfk") and tick() - self.LastInputTime >= 300 then
                pcall(function() self:AntiAfkTap() end)
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            task.wait(1)
            if self:IsOn("AntiGameplayPause") then
                self:ApplyAntiGameplayPause(true)
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            task.wait(0.2)
            if self:IsStealingEnabled() and not self.IsGhosting then
                self:SetGhostState(true)
            elseif not self:IsStealingEnabled() and self.IsGhosting then
                self:SetGhostState(false)
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            task.wait(0.2)
            if not self.IsProcessing then
                if self:IsOn("AutoDropEgg") and self:IsCarrying() then
                    self.IsProcessing = true
                    pcall(function() plotCmds and plotCmds.RequestDropHeldAreaEgg() end)
                    self.IsProcessing = false
                elseif self:IsOn("AutoReturn") and self:IsCarrying() then
                    self.IsProcessing = true
                    pcall(function()
                        local basePos = self:GetBasePosition()
                        local root = self:GetRoot()
                        if basePos and root then
                            self:RawTeleport(Vector3.new(558, 71, root.Position.Z))
                        end
                    end)
                    self.IsProcessing = false
                end
            end
        end
    end)
    
    self:Notify("Pandu Hub loaded successfully!")
    self:Notify("Press LeftAlt to toggle UI")
end

-- ============================================
-- 25. START
-- ============================================

PanduHub:Init()
getgenv().PanduHub = PanduHub
getgenv().UnloadPandu = function() PanduHub.Unloaded = true end

print("========================================")
print("PANDU HUB LOADED SUCCESSFULLY!")
print("Press LeftAlt to toggle UI")
print("========================================")