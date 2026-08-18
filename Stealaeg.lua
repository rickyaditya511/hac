-- ============================================
-- PANDU HUB - STEAL AN EGG (FULL VERSION + LOGIC)
-- ============================================

print("=== PANDU HUB LOADING ===")

-- ============================================
-- 1. LOAD LIBRARY
-- ============================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/Library.lua"))()
if not Library then warn("Library failed") return end

local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/addons/SaveManager.lua"))()
if not SaveManager then warn("SaveManager failed") return end

local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/joustingmatch/ObsidianUltra/main/addons/ThemeManager.lua"))()
if not ThemeManager then warn("ThemeManager failed") return end

SaveManager:SetLibrary(Library)
ThemeManager:SetLibrary(Library)

-- ============================================
-- 2. DEFAULT THEME
-- ============================================

ThemeManager:SetDefaultTheme({
    FontColor = "ffffff",
    MainColor = "1e1e1e",
    AccentColor = "7d55ff",
    BackgroundColor = "121212",
    OutlineColor = "333333",
    FontFace = "Code",
    BackgroundImage = ""
})

-- ============================================
-- 3. GET SERVICES
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
-- 4. LOAD GAME MODULES
-- ============================================

local network, plotCmds, baseUpgradeClient, Ej, fuseKernelUtil, fuseKernelUtil2
local areaEggSlotIdentity, assetCmds, gears, treadmills, eggs, nETWORK_MAP
local FS, FN, FJ = {}, {}, {}

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
    
    -- Trail data
    local trails = require(networkLib.Library.Directory.Trails)
    for id, data in pairs(trails) do
        table.insert(FS, id)
        FN[id] = data.DisplayName or id
        FJ[id] = data.Price or 0
    end
    print("Game modules loaded!")
end

local gameModulesLoaded = pcall(LoadGameModules)
if not gameModulesLoaded then
    warn("Game modules not loaded, some features may not work")
end

-- ============================================
-- 5. PANDU HUB CORE
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
    TotalEggsSold = 0,
    TotalMoneyEarned = 0,
    
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
    DisconnectHandled = false,
    
    -- References
    GhostClone = nil,
    EspFolder = nil,
    RenderOverlay = nil,
    Window = nil,
    Options = {},
    Toggles = {},
    StatTexts = {},
    StatLabels = {"money", "speed", "pets", "eggs", "stolen", "session"},
    
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
-- 6. UTILITY FUNCTIONS
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

function PanduHub:Field(label, value, color)
    return string.format("<b>%s</b> %s %s", label, self:Colored("-", "#5a6070"), self:Colored(value, color))
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

function PanduHub:CopyText(text, message)
    if setclipboard then
        setclipboard(text)
    elseif toclipboard then
        toclipboard(text)
    else
        self:Notify("Clipboard not supported")
        return
    end
    if message then self:Notify(message) end
end

function PanduHub:CopyDiscord()
    self:CopyText("https://discord.gg/panduhub", "Discord invite copied!")
end

-- ============================================
-- 7. GETTER FUNCTIONS
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

function PanduHub:GetEntryPosition()
    local startArea = workspace:FindFirstChild("StartArea")
    if startArea and startArea:IsA("BasePart") then
        return Vector3.new(startArea.Position.X, self:GetLaneY(), self:GetLaneZ())
    end
    local sepLine = workspace:FindFirstChild("SeparationLine")
    if sepLine and sepLine:IsA("BasePart") then
        return Vector3.new(sepLine.Position.X, self:GetLaneY(), self:GetLaneZ())
    end
    return Vector3.new(543.5, self:GetLaneY(), self:GetLaneZ())
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

function PanduHub:GetCorridorBounds()
    local minX, maxX = math.huge, -math.huge
    local minZ, maxZ = math.huge, -math.huge
    local zones = {"Forest", "Lake", "Desert", "Jungle", "Snow", "Volcano", "Abyss Ocean", "Prehistoric", "Cosmic"}
    for _, zone in ipairs(zones) do
        local model = self:GetZoneModel(zone)
        if model then
            local bounds = model:FindFirstChild("Bounds")
            if bounds and bounds:IsA("BasePart") then
                local halfX = bounds.Size.X * 0.5
                local halfZ = bounds.Size.Z * 0.5
                minX = math.min(minX, bounds.Position.X - halfX)
                maxX = math.max(maxX, bounds.Position.X + halfX)
                minZ = math.min(minZ, bounds.Position.Z - halfZ)
                maxZ = math.max(maxZ, bounds.Position.Z + halfZ)
            end
        end
    end
    local entry = self:GetEntryPosition()
    minX = math.min(minX, entry.X - 20)
    return minX, maxX, minZ, maxZ
end

function PanduHub:ClampToCorridor(position, noClamp)
    if noClamp then return position end
    local minX, maxX, minZ, maxZ = self:GetCorridorBounds()
    return Vector3.new(
        math.clamp(position.X, minX, maxX),
        position.Y,
        math.clamp(position.Z, minZ, maxZ)
    )
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

function PanduHub:FindAreaEggRecord(uid)
    for _, egg in ipairs(self:GetAreaEggs()) do
        if egg.Uid == uid then return egg end
    end
    return nil
end

function PanduHub:GetEggPosition(egg)
    local cframe = egg.BottomCFrame or egg.BoundsCFrame
    if not cframe then return nil end
    local pos = cframe.Position
    local _, _, minZ, maxZ = self:GetCorridorBounds()
    return Vector3.new(pos.X, pos.Y + 2, math.clamp(pos.Z, minZ, maxZ))
end

function PanduHub:GetSlotEggPosition(eggObject)
    local hitbox = eggObject:FindFirstChild("Hitbox") or eggObject:FindFirstChild("CustomBoundingBox") or eggObject:FindFirstChildOfClass("BasePart")
    if hitbox then return hitbox.Position end
    return eggObject:GetPivot().Position
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

function PanduHub:MatchesMutationFilter(listName, data)
    if not self:MultiHasAny(listName) then return true end
    local selected = self:MultiSelected(listName)
    local mutations = self:RecordMutations(data)
    for _, mut in ipairs(mutations) do
        if selected[mut] then return true end
    end
    return false
end

function PanduHub:MatchesEggFilters(data, rarityFilter, rarityList, mutationList)
    local rarity = self:ResolveRarity(data.AssetCategory)
    if rarityFilter then
        if not self:SelectionAllows(rarityFilter, rarity) then return false end
    end
    if rarityList and self:MultiHasAny(rarityList) then
        if not self:MultiSelected(rarityList)[rarity] then return false end
    end
    if mutationList and not self:MatchesMutationFilter(mutationList, data) then
        return false
    end
    return true
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
-- 8. MOVEMENT FUNCTIONS
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
    local clamped = self:ClampToCorridor(target, useTween == true)
    local root = self:GetRoot()
    if not root then return false end
    if not self:RawTeleport(clamped) then
        task.wait()
        return false
    end
    return true
end

function PanduHub:GroundedY(x, z, fallbackY)
    local root = self:GetRoot()
    if not root then return fallbackY or 71 end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {}
    if Workspace.Character then
        table.insert(params.FilterDescendantsInstances, Workspace.Character)
    end
    if PanduHub.GhostClone then
        table.insert(params.FilterDescendantsInstances, PanduHub.GhostClone)
    end
    local startY = root.Position.Y or fallbackY or 71
    local ray = workspace:Raycast(Vector3.new(x, startY + 60, z), Vector3.new(0, -600, 0), params)
    if ray then
        local humanoid = self:GetHumanoid()
        local hipHeight = humanoid and humanoid.HipHeight or 2
        return ray.Position.Y + hipHeight + 2
    end
    return (root and root.Position.Y) or fallbackY or 71
end

function PanduHub:TweenTo(x, y, z)
    local root = self:GetRoot()
    if not root then return false end
    y = y or self:GroundedY(x, z, root.Position.Y)
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

function PanduHub:BuildLaneWaypoints(fromPos, targetZoneIndex)
    local waypoints = {}
    local laneZ = self:GetLaneZ()
    local laneY = self:GetLaneY()
    if math.abs(fromPos.Z - laneZ) > 8 then
        table.insert(waypoints, Vector3.new(fromPos.X, laneY, laneZ))
    end
    local currentIndex = self:GetZoneIndexByX(fromPos.X)
    local step = currentIndex <= targetZoneIndex and 1 or -1
    while (step > 0 and currentIndex <= targetZoneIndex) or (step < 0 and currentIndex >= targetZoneIndex) do
        local zone = {"Forest", "Lake", "Desert", "Jungle", "Snow", "Volcano", "Abyss Ocean", "Prehistoric", "Cosmic"}[currentIndex]
        if zone then
            local pos = self:GetZoneLaneCenter(zone)
            if pos then table.insert(waypoints, pos) end
        end
        currentIndex = currentIndex + step
    end
    return waypoints
end

-- ============================================
-- 9. EGG STEALING
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
    -- Check zones if selected
    if self:MultiHasAny("StealZones") then
        local selected = self:MultiSelected("StealZones")
        local areaName = eggData.AreaId
        if not selected[areaName] then return false end
    end
    -- Check rarities
    local rarity = self:ResolveRarity(eggData.AssetCategory)
    if self:MultiHasAny("StealRarities") then
        if not self:MultiSelected("StealRarities")[rarity] then return false end
    end
    -- Check mutations
    if self:MultiHasAny("StealMutations") then
        local mutations = self:RecordMutations(eggData)
        local selected = self:MultiSelected("StealMutations")
        local match = false
        for _, mut in ipairs(mutations) do
            if selected[mut] then match = true break end
        end
        if not match then return false end
    end
    -- Check big eggs
    if self:IsOn("StealBigEggs") then
        local scale = tonumber(eggData.AssetScale) or 0
        local minScale = tonumber(self:OptionValue("StealBigEggScale", 1.5)) or 1.5
        if scale < minScale then return false end
    end
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
    
    if self:IsCarrying() then
        self.TotalStolen = self.TotalStolen + 1
        -- Track egg spawn
        if self:IsOn("WebhookEnabled") then
            local rarity = self:ResolveRarity(target.AssetCategory)
            local name = self:GetAssetName(target.AssetCategory)
            if #self.EggSpawnLog < 100 then
                table.insert(self.EggSpawnLog, string.format("**%s** `%s` in %s", name, tostring(rarity or "?"), tostring(target.AreaId)))
            end
        end
    end
    
    return self:IsCarrying()
end

function PanduHub:RunAutoSteal()
    if self:IsCarrying() or self:StealBlockedByInventory() then return end
    local target = self:PickStealTarget()
    if target then self:StealEgg(target) end
end

-- ============================================
-- 10. EGG PLACING
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
            if placeAll or self:MatchesEggFilters(data, nil, "LifecycleRarities", "LifecycleMutations") then
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

function PanduHub:EnsureAtPlot(condition)
    if type(condition) == "function" then
        if not condition() then return false end
    end
    local basePos = self:GetBasePosition()
    local root = self:GetRoot()
    if not basePos or not root then return false end
    if baseUpgradeClient and baseUpgradeClient.IsWorldPositionWithinLocalPlotBounds(root.Position) then return true end
    self:RawTeleport(Vector3.new(558, 71, root.Position.Z))
    task.wait(0.08)
    if type(condition) == "function" and not condition() then return false end
    return true
end

function PanduHub:RunAutoPlaceEggs(force)
    if self:IsCarrying() then return end
    local ready = force == true or self:IsPlacingEnabled()
    if not ready then return end
    
    local uids = self:GetUnplacedEggUids()
    if #uids == 0 then return end
    
    if not self:EnsureAtPlot(ready) then return end
    local placements = self:GetPlacementLocalCFrames()
    if #placements == 0 then return end
    
    for _, uid in ipairs(uids) do
        if self.Unloaded or not ready then break end
        if not self:IsNearPlot() and not self:EnsureAtPlot(ready) then break end
        
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
-- 11. EGG HATCHING
-- ============================================

function PanduHub:IsAutoOpenReady()
    return self:IsOn("AutoOpenReadyEggs") and not self:IsCarrying()
end

function PanduHub:RunAutoOpenReadyEggs()
    local save = self:GetSave()
    if not save or not plotCmds then return end
    if not self:IsAutoOpenReady() then return end
    
    local hatched = false
    for uid, data in pairs(save) do
        if self.Unloaded or not self:IsAutoOpenReady() then break end
        if type(uid) == "string" and type(data) == "table" and data.Placement ~= nil then
            if self:MatchesEggFilters(data, nil, "LifecycleRarities", "LifecycleMutations") then
                local ready = false
                pcall(function() ready = plotCmds.IsLocalEggReady(uid) == true end)
                if ready then
                    local ok = false
                    pcall(function() ok = plotCmds.RequestHatchEgg(uid) == true end)
                    if ok then
                        hatched = true
                        pcall(function() plotCmds.RequestCompleteHatchEgg(uid) end)
                        task.wait(0.35)
                    end
                end
            end
        end
    end
    return hatched
end

-- ============================================
-- 12. EGG SELLING
-- ============================================

function PanduHub:GetSellableEggUids()
    local save = self:GetSave()
    if type(save) ~= "table" then return {} end
    
    local uids = {}
    for uid, data in pairs(save) do
        if type(uid) == "string" and type(data) == "table" and data.Placement == nil then
            local rarity = self:ResolveRarity(data.AssetCategory)
            local allow = true
            if self:MultiHasAny("SellEggRarities") then
                allow = self:MultiSelected("SellEggRarities")[rarity] == true
            end
            if allow then table.insert(uids, uid) end
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
-- 13. PET FUNCTIONS
-- ============================================

function PanduHub:GetSellablePets()
    local save = self:GetSave()
    if type(save) ~= "table" or type(save.Inventory) ~= "table" then return {} end
    
    local inventory = save.Inventory
    local keepMutated = self:IsOn("SellKeepMutated")
    local keepEquipped = self:IsOn("SellKeepEquipped")
    local maxScale = tonumber(self:OptionValue("SellMaxScale", 10)) or 10
    
    local sellList = {}
    local equippedUids = {}
    for _, equipped in ipairs(save.EquippedPets or {}) do
        equippedUids[equipped] = true
    end
    
    for uid, data in pairs(inventory) do
        if type(uid) == "string" and type(data) == "table" then
            local petData = self:GetPetItemData(data)
            if not petData then continue end
            
            local isEquipped = equippedUids[uid] ~= nil
            local isFavorite = petData.IsFavorite == true
            local isInFuse = petData.InFuse == true
            
            if not isFavorite and not isInFuse then
                local keep = false
                local mutations = self:RecordMutations(data)
                
                if keepMutated and #mutations > 0 then keep = true end
                if keepEquipped and isEquipped then keep = true end
                
                if not keep and self:MultiHasAny("SellMutations") then
                    local selected = self:MultiSelected("SellMutations")
                    for _, mut in ipairs(mutations) do
                        if selected[mut] then keep = true break end
                    end
                end
                
                local rarity = self:ResolveRarity(data.Category)
                local rarityAllow = true
                if self:MultiHasAny("SellRarities") then
                    rarityAllow = self:MultiSelected("SellRarities")[rarity] == true
                end
                
                local scale = tonumber(data.Scale) or 0
                local scaleOk = scale <= maxScale
                
                if not keep and rarityAllow and scaleOk then
                    table.insert(sellList, uid)
                end
            end
        end
    end
    return sellList
end

function PanduHub:SellPetUid(uid)
    if not plotCmds then return end
    pcall(function() plotCmds.RequestSellPet(uid) end)
end

function PanduHub:RunAutoSellPets()
    if self.Unloaded or not self:IsOn("AutoSellPets") or self:IsCarrying() then return end
    local pets = self:GetSellablePets()
    for _, uid in ipairs(pets) do
        if self.Unloaded or not self:IsOn("AutoSellPets") or self:IsCarrying() then break end
        self:SellPetUid(uid)
        task.wait(0.15)
    end
end

-- ============================================
-- 14. PET FUSING
-- ============================================

function PanduHub:FuseGroups(saveData)
    if type(saveData) ~= "table" or not fuseKernelUtil2 then return {} end
    local groups = {}
    local inventory = saveData.Inventory or {}
    local maxScale = tonumber(self:OptionValue("FuseMaxScale", 10)) or 10
    local keepMutated = self:IsOn("FuseKeepMutated")
    local equippedUids = {}
    for _, uid in ipairs(saveData.EquippedPets or {}) do
        equippedUids[uid] = true
    end
    
    for uid, data in pairs(inventory) do
        if type(uid) == "string" and type(data) == "table" then
            local category = data.Category
            if type(category) ~= "string" then continue end
            
            local canSelect = false
            pcall(function()
                canSelect = fuseKernelUtil2.CanSelectPet(uid, data, category, false) == true
            end)
            if not canSelect then continue end
            
            if equippedUids[uid] then continue end
            
            local mutations = self:RecordMutations(data)
            if keepMutated and #mutations > 0 then continue end
            
            if self:MultiHasAny("FuseMutations") then
                local selected = self:MultiSelected("FuseMutations")
                local matches = false
                for _, mut in ipairs(mutations) do
                    if selected[mut] then matches = true break end
                end
                if not matches then continue end
            end
            
            local rarity = self:ResolveRarity(category)
            if rarity then
                if not self:SelectionAllows("FuseRarities", rarity) then continue end
            end
            
            local scale = tonumber(data.Scale) or 0
            if scale > maxScale then continue end
            
            if not groups[category] then groups[category] = {} end
            table.insert(groups[category], {uid = uid, scale = scale})
        end
    end
    return groups
end

function PanduHub:PickFuseGroup(saveData)
    local groups = self:FuseGroups(saveData)
    if not groups or next(groups) == nil then return nil end
    
    local keepPer = tonumber(self:OptionValue("FuseKeepPerCategory", 0)) or 0
    local target = self:OptionValue("FuseTarget", "Highest Rarity")
    local bestGroup = nil
    local bestScore = -math.huge
    
    for category, pets in pairs(groups) do
        table.sort(pets, function(a, b) return a.scale < b.scale end)
        if #pets - keepPer >= 3 then
            local rarity = self:ResolveRarity(category) or "Common"
            local rank = self.RarityRanks[rarity] or 0
            local score = 0
            if target == "Most Duplicates" then
                score = #pets
            elseif target == "Lowest Rarity" then
                score = -rank
            else -- Highest Rarity
                score = rank
            end
            if score > bestScore then
                bestScore = score
                bestGroup = category
            end
        end
    end
    if not bestGroup then return nil end
    
    local pets = groups[bestGroup]
    table.sort(pets, function(a, b) return a.scale < b.scale end)
    local result = {}
    for i = 1, math.min(#pets - keepPer, #pets) do
        table.insert(result, pets[i].uid)
    end
    return result
end

function PanduHub:FusePrice(saveData, uids)
    if type(saveData) ~= "table" or type(uids) ~= "table" or not fuseKernelUtil2 then return nil end
    local inventory = saveData.Inventory or {}
    local petData = {}
    for i, uid in ipairs(uids) do
        local data = inventory[uid]
        if not data then return nil end
        petData[i] = self:GetPetItemData(data)
        if not petData[i] then return nil end
    end
    local success, price = pcall(function()
        return fuseKernelUtil2.CalculateFusePrice(petData)
    end)
    if success then return tonumber(price) end
    return nil
end

function PanduHub:RunAutoFusePets(force)
    local save = self:GetSave()
    if not save then return end
    local enabled = force == true or self:IsOn("AutoFusePets")
    if not enabled then return end
    if save.FusionLocked == true then return end
    
    local uids = self:PickFuseGroup(save)
    if not uids or #uids < 3 then return end
    
    local price = self:FusePrice(save, uids)
    if not price then return end
    local money = tonumber(save.Money) or 0
    if money < price then return end
    
    local pos = self:GetFuseMachinePosition()
    if not pos then return end
    if not self:TravelTo(pos, true) then return end
    
    if save.FusionInfoAcknowledged ~= true then
        pcall(function() plotCmds.RequestAcknowledgeFusionInfo() end)
    end
    
    for _, uid in ipairs(uids) do
        if self.Unloaded or not enabled then return end
        pcall(function() plotCmds.RequestInsertFuseMob(uid) end)
        task.wait(0.2)
    end
    
    pcall(function() plotCmds.RequestStartFuse() end)
    self:Notify("Fusing " .. #uids .. " pets...")
    return true
end

-- ============================================
-- 15. AUTO UPGRADES
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
-- 16. AUTO CLAIM
-- ============================================

function PanduHub:RunAutoClaimIndex()
    if plotCmds then pcall(function() plotCmds.RequestClaimAllIndex() end) end
end

function PanduHub:RunAutoClaimGroupReward()
    local save = self:GetSave()
    if not save or not plotCmds then return end
    if save.ClaimedGroupReward == true then return end
    local inGroup = false
    pcall(function() inGroup = LocalPlayer:IsInGroupAsync(123456) == true end) -- Ganti dengan group ID
    pcall(function() plotCmds.RequestClaimGroupReward(inGroup) end)
end

function PanduHub:RunClaimOfflineEarnings()
    if not plotCmds then return end
    local summary = nil
    pcall(function() summary = plotCmds.GetOfflineAssetsSummary() end)
    if type(summary) ~= "table" then return end
    local amount = tonumber(summary.ClaimableAmount) or 0
    if amount > 0 then
        pcall(function() plotCmds.RequestRedeemOfflineAssets() end)
        self:Notify("Claimed " .. self:FormatNumber(amount) .. " offline earnings")
    end
end

-- ============================================
-- 17. AUTO EQUIP BEST
-- ============================================

function PanduHub:RunAutoEquipBest()
    if self:IsCarrying() or not plotCmds then return end
    pcall(function() plotCmds.RequestEquipBestPets() end)
end

-- ============================================
-- 18. TRAIL FUNCTIONS
-- ============================================

function PanduHub:RunAutoBuyTrail()
    if self:IsCarrying() then return end
    local save = self:GetSave()
    if not save or type(save.TrailInventory) ~= "table" then return end
    
    local wanted = self:MultiSelected("TrailWanted")
    if not self:MultiHasAny("TrailWanted") then return end
    
    local trailInventory = save.TrailInventory
    for trailId, trailData in pairs(FS or {}) do
        if wanted[trailId] and not trailInventory[trailData] then
            local price = FJ and FJ[trailId] or 0
            if (save.Money or 0) >= price then
                pcall(function() plotCmds.RequestPurchaseTrail(trailData) end)
                task.wait(0.35)
                save = self:GetSave()
                if save then trailInventory = save.TrailInventory or {} end
            end
        end
    end
end

function PanduHub:RunAutoEquipBestTrail()
    local save = self:GetSave()
    if not save or type(save.TrailInventory) ~= "table" then return end
    
    local bestScore = -1
    local bestTrail = nil
    for trailId, trailData in pairs(FS or {}) do
        local data = save.TrailInventory[trailData]
        if data then
            local score = FJ and FJ[trailId] or 0
            if score > bestScore then
                bestScore = score
                bestTrail = trailData
            end
        end
    end
    if bestTrail and save.EquippedTrail ~= bestTrail then
        pcall(function() plotCmds.RequestEquipTrail(bestTrail) end)
    end
end

-- ============================================
-- 19. GEAR FUNCTIONS
-- ============================================

function PanduHub:GearBaseName(name)
    return tostring(name):gsub("%s*%[X%d+%]%s*$", "")
end

function PanduHub:RunAutoEquipBestGear()
    local character = Workspace.Character
    local backpack = workspace:FindFirstChildOfClass("Backpack")
    local humanoid = self:GetHumanoid()
    if not character or not backpack or not humanoid then return end
    
    local bestScore = -1
    local bestTool = nil
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local score = 0
            -- Get gear score from game data
            if gears and gears.Directory then
                local gearData = gears.Directory[self:GearBaseName(tool.Name)]
                if gearData and gearData.Rarity then
                    local rarity = gearData.Rarity.DisplayName
                    score = self.RarityRanks[rarity] or 0
                end
            end
            if score > bestScore then
                bestScore = score
                bestTool = tool
            end
        end
    end
    
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            local score = 0
            if gears and gears.Directory then
                local gearData = gears.Directory[self:GearBaseName(tool.Name)]
                if gearData and gearData.Rarity then
                    local rarity = gearData.Rarity.DisplayName
                    score = self.RarityRanks[rarity] or 0
                end
            end
            if score >= bestScore then return end
        end
    end
    
    if bestTool then
        pcall(function() humanoid:EquipTool(bestTool) end)
    end
end

-- ============================================
-- 20. TREADMILL
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
-- 21. SERVER HOP
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

function PanduHub:RememberVisited(serverId)
    if serverId and serverId ~= "" then
        self.VisitedServers[serverId] = true
    end
end

function PanduHub:ServerHop(reason)
    if self.HopCooldown > os.clock() then return end
    self.HopCooldown = os.clock() + 10
    self:Notify("Server hopping: " .. tostring(reason or "Manual"))
    
    local targets = self:PickHopTargets()
    if not targets or #targets == 0 then
        self:Notify("Server hop failed, no targets found")
        return
    end
    
    for i, server in ipairs(targets) do
        if i > 3 then break end
        self:RememberVisited(server.id)
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
            self.LastHopTime = os.clock()
            self:ServerHop("Interval reached")
        end
    elseif mode == "After Steal Count" then
        if self.TotalStolen >= value then
            self.TotalStolen = 0
            self:ServerHop(string.format("Stole %d eggs", value))
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
-- 22. GHOST MODE
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
    if self.GhostConnection then
        self.GhostConnection:Disconnect()
        self.GhostConnection = nil
    end
    if self.GhostClone then
        self.GhostClone:Destroy()
        self.GhostClone = nil
    end
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
    self.GhostConnection = RunService.Stepped:Connect(function()
        local char = Workspace.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Dead then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            end
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanTouch = false
                end
            end
        end
    end)
end

-- ============================================
-- 23. ESP FUNCTIONS
-- ============================================

function PanduHub:EspDistanceLimit()
    return tonumber(self:OptionValue("EspDistance", 2000)) or 2000
end

function PanduHub:WithinEspRange(position)
    local root = self:GetRoot()
    if not root then return false end
    return (root.Position - position).Magnitude <= self:EspDistanceLimit()
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
    anchor.CanQuery = false
    anchor.CanTouch = false
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
    label.RichText = false
    label.Parent = billboard
    
    entry = {anchor = anchor, billboard = billboard, label = label, highlight = nil}
    self.EspEntries[id] = entry
    return entry
end

function PanduHub:ReleaseEsp(id)
    local entry = self.EspEntries[id]
    if not entry then return end
    if entry.highlight then entry.highlight:Destroy() end
    if entry.billboard then entry.billboard:Destroy() end
    if entry.anchor then entry.anchor:Destroy() end
    self.EspEntries[id] = nil
end

function PanduHub:DrawEspAt(id, position, text, color, adornee)
    local entry = self:EnsureEspEntry(id, color)
    entry.anchor.CFrame = CFrame.new(position)
    entry.label.Text = text
    entry.label.TextColor3 = color
    if adornee then
        if not entry.highlight then
            local highlight = Instance.new("Highlight")
            highlight.FillTransparency = 0.6
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = self.EspFolder
            entry.highlight = highlight
        end
        entry.highlight.Adornee = adornee
        entry.highlight.FillColor = color
        entry.highlight.OutlineColor = color
    else
        if entry.highlight then
            entry.highlight:Destroy()
            entry.highlight = nil
        end
    end
end

function PanduHub:CollectEggEsp()
    if not self:IsOn("EspWorldEggs") and not self:IsOn("EspCarriedEggs") then return end
    
    for _, egg in ipairs(self:GetAreaEggs()) do
        local cframe = egg.BottomCFrame or egg.BoundsCFrame
        if cframe then
            local state = egg.State
            local isSlot = state == "Slot"
            local isDropped = state == "Dropped"
            local isCarried = state == "Carried"
            
            if (isSlot and self:IsOn("EspWorldEggs")) or
               ((isDropped or isCarried) and self:IsOn("EspCarriedEggs")) then
                local pos = cframe.Position
                if self:WithinEspRange(pos) then
                    local rarity = self:ResolveRarity(egg.AssetCategory)
                    local name = self:GetAssetName(egg.AssetCategory) or tostring(egg.AssetCategory)
                    local rarityStr = rarity or "?"
                    local label = string.format("%s [%s]", name, tostring(rarityStr))
                    if isDropped or isCarried then
                        label = string.format("%s\n%s", label, tostring(state))
                    end
                    self:DrawEspAt("egg_" .. egg.Uid, pos, label, self:GetEspColor(rarity))
                end
            end
        end
    end
end

function PanduHub:CollectGuardEsp()
    if not self:IsOn("EspGuards") then return end
    local objects = workspace:FindFirstChild("__OBJECTS")
    if not objects then return end
    local guards = objects:FindFirstChild("Guards")
    if not guards then return end
    
    for _, guard in ipairs(guards:GetChildren()) do
        local guardPart = guard:FindFirstChild("Guard")
        if guardPart then
            local success, pivot = pcall(function() return guardPart:GetPivot() end)
            if success and pivot and self:WithinEspRange(pivot.Position) then
                local state = guardPart:GetAttribute("GuardState") or "Idle"
                self:DrawEspAt(
                    "guard_" .. guard.Name,
                    pivot.Position,
                    string.format("Guard %s\n%s", guard.Name, tostring(state)),
                    Color3.fromRGB(255, 140, 90),
                    guardPart
                )
            end
        end
    end
end

function PanduHub:CollectPetEsp()
    if not self:IsOn("EspPets") then return end
    local renderedAssets = workspace:FindFirstChild("ClientRenderedAssets")
    if not renderedAssets then return end
    
    local snapshot = {}
    pcall(function()
        local data = areaEggSlotIdentity and areaEggSlotIdentity.GetRuntimeSnapshot()
        if data then
            for _, areaData in pairs(data) do
                if type(areaData) == "table" and type(areaData.Records) == "table" then
                    for uid, record in pairs(areaData.Records) do
                        snapshot[uid] = record
                    end
                end
            end
        end
    end)
    
    for _, pet in ipairs(renderedAssets:GetChildren()) do
        local uid = pet:GetAttribute("UID")
        if type(uid) == "string" then
            local success, pivot = pcall(function() return pet:GetPivot() end)
            if success and pivot and self:WithinEspRange(pivot.Position) then
                local data = snapshot[uid]
                local category = data and data.Category
                local itemData = nil
                if category then
                    itemData = gears and gears.Directory and gears.Directory[category]
                end
                local rarity = self:ResolveRarity(category)
                local name = itemData and itemData.DisplayName or tostring(category) or "Pet"
                local rarityStr = rarity or "?"
                local label = string.format("%s [%s]", name, tostring(rarityStr))
                if data and data.MoneyPerSecond then
                    label = string.format("%s\n%s/s", label, self:FormatNumber(data.MoneyPerSecond))
                end
                self:DrawEspAt("pet_" .. pet.Name, pivot.Position, label, self:GetEspColor(rarity), pet)
            end
        end
    end
end

function PanduHub:CollectPlayerEsp()
    if not self:IsOn("EspPlayers") then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root and self:WithinEspRange(root.Position) then
                    local dist = 0
                    local myRoot = self:GetRoot()
                    if myRoot then dist = (myRoot.Position - root.Position).Magnitude end
                    self:DrawEspAt(
                        "player_" .. player.Name,
                        root.Position,
                        string.format("%s\n%d studs", player.DisplayName, math.floor(dist)),
                        Color3.fromRGB(120, 190, 255),
                        char
                    )
                end
            end
        end
    end
end

function PanduHub:CollectMachineEsp()
    if not self:IsOn("EspMachines") then return end
    local objects = workspace:FindFirstChild("__OBJECTS")
    if not objects then return end
    local machines = objects:FindFirstChild("Machines")
    if not machines then return end
    
    for _, machine in ipairs(machines:GetChildren()) do
        local success, pivot = pcall(function() return machine:GetPivot() end)
        if success and pivot and self:WithinEspRange(pivot.Position) then
            self:DrawEspAt(
                "machine_" .. machine.Name,
                pivot.Position,
                machine.Name,
                Color3.fromRGB(230, 200, 120),
                machine
            )
        end
    end
end

function PanduHub:CollectPlotEsp()
    if not self:IsOn("EspPlots") then return end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return end
    
    for _, plot in ipairs(plots:GetChildren()) do
        local sign = plot:FindFirstChild("PlotSign") or plot:FindFirstChild("CenterPoint")
        if sign and sign:IsA("BasePart") and self:WithinEspRange(sign.Position) then
            local owner = "Empty"
            local slotNum = tonumber(plot.Name)
            if slotNum and baseUpgradeClient then
                local userId = nil
                pcall(function() userId = baseUpgradeClient.GetSlotOwner(slotNum) end)
                if userId then
                    local player = Players:GetPlayerByUserId(userId)
                    owner = player and player.DisplayName or "User " .. tostring(userId)
                end
            end
            self:DrawEspAt(
                "plot_" .. plot.Name,
                sign.Position,
                string.format("Plot %s\n%s", plot.Name, owner),
                Color3.fromRGB(200, 170, 255)
            )
        end
    end
end

function PanduHub:RunEsp()
    if self:IsOn("EspWorldEggs") or self:IsOn("EspCarriedEggs") or
       self:IsOn("EspGuards") or self:IsOn("EspPets") or
       self:IsOn("EspPlayers") or self:IsOn("EspMachines") or
       self:IsOn("EspPlots") then
        pcall(function()
            self:CollectEggEsp()
            self:CollectGuardEsp()
            self:CollectPetEsp()
            self:CollectPlayerEsp()
            self:CollectMachineEsp()
            self:CollectPlotEsp()
        end)
    else
        if next(self.EspEntries) ~= nil then
            pcall(function() self:ClearAllEsp() end)
        end
    end
end

function PanduHub:ClearAllEsp()
    for id in pairs(self.EspEntries) do
        self:ReleaseEsp(id)
    end
end

-- ============================================
-- 24. WEBHOOK FUNCTIONS
-- ============================================

function PanduHub:WebhookPing()
    local pingId = self:OptionValue("WebhookPingId", "")
    if not pingId or pingId == "" then return nil end
    local cleaned = tostring(pingId):gsub("%D", "")
    if cleaned == "" then return nil end
    return string.format("<@%s>", cleaned)
end

function PanduHub:SendWebhookEmbed(embed, ping)
    if not self:IsOn("WebhookEnabled") then return false end
    local url = self:OptionValue("WebhookUrl", "")
    if not url or url == "" then return false end
    
    local data = {username = "Pandu Hub", embeds = {embed}}
    if ping then data.content = self:WebhookPing() end
    
    local body = nil
    pcall(function() body = HttpService:JSONEncode(data) end)
    if not body then return false end
    
    local requestFunc = syn and syn.request or http and http.request or http_request or request
    if type(requestFunc) ~= "function" then return false end
    
    local success = pcall(function()
        requestFunc({
            Url = url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = body
        })
    end)
    return success
end

function PanduHub:EmbedField(name, value, inline)
    return {name = name, value = value, inline = inline ~= false}
end

function PanduHub:BuildSummaryEmbed()
    local save = self:GetSave()
    if not save then return {} end
    
    local elapsed = math.floor(os.clock() - self.SessionStart)
    local elapsedStr = self:FormatElapsed(elapsed)
    local fields = {}
    
    table.insert(fields, self:EmbedField("Money", "`" .. self:FormatNumber(save.Money) .. "`"))
    table.insert(fields, self:EmbedField("Speed Power", "`" .. self:FormatNumber(save.SpeedPower) .. "`"))
    if save.Rebirth then
        table.insert(fields, self:EmbedField("Rebirth", "`" .. tostring(save.Rebirth) .. "`"))
    end
    if save.BaseUpgradeLevel then
        table.insert(fields, self:EmbedField("Base Level", "`" .. tostring(save.BaseUpgradeLevel) .. "`"))
    end
    if save.TreadmillUpgradeLevel then
        table.insert(fields, self:EmbedField("Treadmill Level", "`" .. tostring(save.TreadmillUpgradeLevel) .. "`"))
    end
    table.insert(fields, self:EmbedField("Eggs Stolen", "`" .. tostring(self.TotalStolen) .. "`"))
    table.insert(fields, self:EmbedField("Pets Obtained", "`" .. tostring(self.TotalPets) .. "`"))
    table.insert(fields, self:EmbedField("Session Time", "`" .. elapsedStr .. "`"))
    
    if #self.EggSpawnLog > 0 then
        local spawns = {}
        for i = 1, math.min(#self.EggSpawnLog, 15) do
            table.insert(spawns, self.EggSpawnLog[i])
        end
        if #self.EggSpawnLog > 15 then
            table.insert(spawns, "... and " .. (#self.EggSpawnLog - 15) .. " more")
        end
        table.insert(fields, self:EmbedField("Egg Spawns (" .. #self.EggSpawnLog .. ")", table.concat(spawns, "\n"), false))
    end
    
    return {
        author = {name = "Pandu Hub | Summary"},
        title = "Session Summary",
        description = "**Player** `" .. LocalPlayer.Name .. "`",
        color = 0x7d55ff,
        fields = fields,
        footer = {text = "Pandu Hub"},
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
end

function PanduHub:SendSummary()
    local embed = self:BuildSummaryEmbed()
    return self:SendWebhookEmbed(embed, true)
end

function PanduHub:TrackWebhookEvents()
    local save = self:GetSave()
    if not save then return end
    
    if type(save.Inventory) == "table" then
        for uid, data in pairs(save.Inventory) do
            if not self.TrackedPets[uid] then
                self.TrackedPets[uid] = true
                self.TotalPets = self.TotalPets + 1
            end
        end
    end
    
    local eggs = self:GetAreaEggs()
    local currentEggs = {}
    for _, egg in ipairs(eggs) do
        currentEggs[egg.Uid] = true
        if not self.TrackedEggs[egg.Uid] then
            self.TrackedEggs[egg.Uid] = true
            if self:IsOn("WebhookEggSpawns") then
                local rarity = self:ResolveRarity(egg.AssetCategory)
                if self:SpawnPassesFilter(rarity) and #self.EggSpawnLog < 60 then
                    local name = self:GetAssetName(egg.AssetCategory)
                    local rarityStr = rarity or "?"
                    table.insert(self.EggSpawnLog, string.format(
                        "**%s** `%s` in %s",
                        name, tostring(rarityStr), tostring(egg.AreaId)
                    ))
                end
            end
        end
    end
    for uid in pairs(self.TrackedEggs) do
        if not currentEggs[uid] then
            self.TrackedEggs[uid] = nil
        end
    end
end

function PanduHub:RunWebhookSummary()
    local interval = tonumber(self:OptionValue("WebhookInterval", 15)) or 15
    if os.clock() - self.LastSummaryTime >= interval * 60 then
        self.LastSummaryTime = os.clock()
        self:SendSummary()
    end
end

function PanduHub:SpawnPassesFilter(rarity)
    if not self:MultiHasAny("WebhookRarities") then return true end
    return self:MultiSelected("WebhookRarities")[rarity] == true
end

-- ============================================
-- 25. ANTI-AFK & MOVEMENT OVERRIDES
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
    pcall(function()
        local notification = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if notification then notification.Enabled = not enabled end
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
    
    if self:IsOn("NoClip") then
        local character = Workspace.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end

-- ============================================
-- 26. RENDER OVERLAY
-- ============================================

function PanduHub:BuildRenderOverlay()
    if self.RenderOverlay and self.RenderOverlay.Parent then return end
    
    local screen = Instance.new("ScreenGui")
    screen.Name = "PanduRenderInfo"
    screen.IgnoreGuiInset = true
    screen.ResetOnSpawn = false
    screen.DisplayOrder = 500
    screen.Parent = CoreGui
    
    local main = Instance.new("Frame")
    main.Size = UDim2.fromScale(1, 1)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    main.BorderSizePixel = 0
    main.Parent = screen
    
    local title = Instance.new("TextLabel")
    title.AnchorPoint = Vector2.new(0.5, 1)
    title.Position = UDim2.fromScale(0.5, 0.5)
    title.Size = UDim2.fromOffset(400, 30)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamMedium
    title.TextSize = 24
    title.TextColor3 = Color3.fromRGB(226, 230, 238)
    title.Text = "Pandu Hub"
    title.Parent = main
    
    local version = Instance.new("TextLabel")
    version.AnchorPoint = Vector2.new(0.5, 0)
    version.Position = UDim2.new(0.5, 0, 0.5, 6)
    version.Size = UDim2.fromOffset(400, 22)
    version.BackgroundTransparency = 1
    version.Font = Enum.Font.Code
    version.TextSize = 15
    version.TextColor3 = Color3.fromRGB(110, 193, 255)
    version.Text = "1.0"
    version.Parent = main
    
    local statsFrame = Instance.new("Frame")
    statsFrame.AnchorPoint = Vector2.new(0, 1)
    statsFrame.Position = UDim2.new(0, 28, 1, -28)
    statsFrame.Size = UDim2.fromOffset(240, #self.StatLabels * 19)
    statsFrame.BackgroundTransparency = 1
    statsFrame.Parent = main
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = statsFrame
    
    self.StatTexts = {}
    for i, label in ipairs(self.StatLabels) do
        local text = Instance.new("TextLabel")
        text.BackgroundTransparency = 1
        text.Size = UDim2.new(1, 0, 0, 17)
        text.Font = Enum.Font.Code
        text.TextSize = 13
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.TextColor3 = Color3.fromRGB(120, 124, 134)
        text.Text = label
        text.LayoutOrder = i
        text.Parent = statsFrame
        self.StatTexts[label] = text
    end
    
    self.RenderOverlay = screen
end

function PanduHub:DestroyRenderOverlay()
    if self.RenderOverlay then
        pcall(function() self.RenderOverlay:Destroy() end)
        self.RenderOverlay = nil
    end
    table.clear(self.StatTexts)
end

function PanduHub:UpdateRenderOverlay()
    if not self.RenderOverlay or not self.RenderOverlay.Parent then
        self:BuildRenderOverlay()
    end
    
    local save = self:GetSave()
    if not save then return end
    
    local elapsed = math.floor(os.clock() - self.SessionStart)
    local elapsedStr = self:FormatElapsed(elapsed)
    
    local stats = {
        money = self:FormatNumber(save.Money),
        speed = self:FormatNumber(save.SpeedPower),
        pets = tostring(self:CountTable(save.Inventory)),
        eggs = tostring(self:EggInventoryCount()),
        stolen = tostring(self.TotalStolen),
        session = elapsedStr
    }
    
    for label, text in pairs(self.StatTexts) do
        if text and text.Parent then
            local value = stats[label] or "-"
            text.Text = string.format("%-8s %s", label, tostring(value))
        end
    end
end

function PanduHub:ApplyRendering(disable)
    pcall(function()
        ReplicatedStorage:Set3dRenderingEnabled(not disable)
    end)
    if disable then
        self:BuildRenderOverlay()
        self:UpdateRenderOverlay()
    else
        self:DestroyRenderOverlay()
    end
end

-- ============================================
-- 27. FPS BOOST
-- ============================================

function PanduHub:SetEffectEnabled(effect, enabled)
    pcall(function() effect.Enabled = enabled end)
end

function PanduHub:EnableFpsBoost()
    if self.FpsBoostState then return end
    
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    local qualityLevel = nil
    pcall(function() qualityLevel = settings().Rendering.QualityLevel end)
    
    self.FpsBoostState = {
        QualityLevel = qualityLevel,
        GlobalShadows = VirtualUser.GlobalShadows,
        FogEnd = VirtualUser.FogEnd,
        Terrain = terrain,
        WaterWaveSize = terrain and terrain.WaterWaveSize or nil,
        WaterReflectance = terrain and terrain.WaterReflectance or nil,
        Effects = {}
    }
    
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    VirtualUser.GlobalShadows = false
    VirtualUser.FogEnd = 1000000
    if terrain then
        terrain.WaterWaveSize = 0
        terrain.WaterReflectance = 0
    end
    
    local effectTypes = {
        ParticleEmitter = true,
        Trail = true,
        Smoke = true,
        Fire = true,
        Sparkles = true
    }
    
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if effectTypes[descendant.ClassName] and descendant.Enabled then
            table.insert(self.FpsBoostState.Effects, descendant)
            self:SetEffectEnabled(descendant, false)
        end
    end
    
    self.FpsBoostConnection = workspace.DescendantAdded:Connect(function(child)
        if effectTypes[child.ClassName] and self:IsOn("FpsBoost") then
            self:SetEffectEnabled(child, false)
        end
    end)
end

function PanduHub:DisableFpsBoost()
    if self.FpsBoostConnection then
        self.FpsBoostConnection:Disconnect()
        self.FpsBoostConnection = nil
    end
    
    local state = self.FpsBoostState
    if not state then return end
    self.FpsBoostState = nil
    
    if state.QualityLevel then
        pcall(function() settings().Rendering.QualityLevel = state.QualityLevel end)
    end
    VirtualUser.GlobalShadows = state.GlobalShadows
    VirtualUser.FogEnd = state.FogEnd
    if state.Terrain and state.Terrain.Parent then
        state.Terrain.WaterWaveSize = state.WaterWaveSize
        state.Terrain.WaterReflectance = state.WaterReflectance
    end
    for _, effect in ipairs(state.Effects) do
        self:SetEffectEnabled(effect, true)
    end
end

function PanduHub:ApplyFpsBoost(enabled)
    if enabled then self:EnableFpsBoost() else self:DisableFpsBoost() end
end

function PanduHub:ApplyFpsCap(fps)
    local setCap = setfpscap or syn and syn.set_fps_cap
    if type(setCap) ~= "function" then
        if not self.FpsCapNotified then
            self.FpsCapNotified = true
            self:Notify("FPS cap is not supported by your executor")
        end
        return
    end
    fps = tonumber(fps) or 60
    pcall(setCap, math.clamp(fps, 15, 360))
end

-- ============================================
-- 28. DISCONNECT HANDLER
-- ============================================

function PanduHub:HandleDisconnect(reason)
    if self.DisconnectHandled then return end
    self.DisconnectHandled = true
    
    if self:IsOn("WebhookDisconnectAlerts") then
        local embed = {
            author = {name = "Pandu Hub | Disconnected"},
            title = "Disconnected",
            description = string.format("**Player** `%s`\n**Reason** %s", LocalPlayer.Name, tostring(reason or "Connection lost")),
            color = 0xe74c3c,
            footer = {text = "Pandu Hub"},
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
        self:SendWebhookEmbed(embed, true)
    end
    
    if self:IsOn("AutoReconnect") then
        task.delay(2, function() self:ServerHop("Auto reconnect") end)
    end
end

-- ============================================
-- 29. TASK MANAGEMENT
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
        Ready = function() return PanduHub:IsAutoOpenReady() end,
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
-- 30. UI WRAPPER FUNCTIONS
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

function PanduHub:MultiSelected(name)
    if self.Options and self.Options[name] and type(self.Options[name].Value) == "table" then
        return self.Options[name].Value
    end
    return {}
end

function PanduHub:MultiHasAny(name)
    if self.Options and self.Options[name] and type(self.Options[name].Value) == "table" then
        return next(self.Options[name].Value) ~= nil
    end
    return false
end

function PanduHub:SelectionAllows(listName, value)
    if not self:MultiHasAny(listName) then return true end
    return self:MultiSelected(listName)[value] == true
end

-- ============================================
-- 31. INIT
-- ============================================

function PanduHub:Init()
    print("Initializing Pandu Hub...")
    
    -- Create UI
    self:CreateUI()
    
    -- Setup default theme
    ThemeManager:SetDefaultTheme({
        FontColor = "ffffff",
        MainColor = "1e1e1e",
        AccentColor = "7d55ff",
        BackgroundColor = "121212",
        OutlineColor = "333333",
        FontFace = "Code",
        BackgroundImage = ""
    })
    
    -- Apply ThemeManager to Settings tab
    ThemeManager:ApplyToTab(self.Tabs.Settings, "paintbrush")
    
    -- Setup SaveManager
    SaveManager:SetFolder("PanduHub")
    SaveManager:SetIgnoreIndexes({
        "SaveManager_ConfigList",
        "SaveManager_ConfigName",
        "ThemeManager_ThemeList",
        "ThemeManager_CustomThemeList",
        "ThemeManager_CustomThemeName",
        "WebhookUrl",
    })
    SaveManager:BuildConfigSection(self.Tabs.Settings, "folder-cog")
    SaveManager:LoadAutoloadConfig()
    
    -- Keybind
    Library.ToggleKeybind = Enum.KeyCode.LeftAlt
    
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
    
    UserInputService.InputChanged:Connect(function(input)
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
                pcall(function() self:RunAutoEquipBest() end)
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
            task.wait(5)
            if self:IsOn("AutoEquipBestTrail") then
                pcall(function() self:RunAutoEquipBestTrail() end)
            end
            if self:IsOn("AutoEquipBestGear") then
                pcall(function() self:RunAutoEquipBestGear() end)
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            task.wait(20)
            if self:IsOn("AutoClaimGroupReward") then
                pcall(function() self:RunAutoClaimGroupReward() end)
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            task.wait(1)
            if self:IsOn("EspWorldEggs") or self:IsOn("EspCarriedEggs") or
               self:IsOn("EspGuards") or self:IsOn("EspPets") or
               self:IsOn("EspPlayers") or self:IsOn("EspMachines") or
               self:IsOn("EspPlots") then
                pcall(function() self:RunEsp() end)
            else
                if next(self.EspEntries) ~= nil then
                    pcall(function() self:ClearAllEsp() end)
                end
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            task.wait(5)
            if self:IsOn("WebhookEnabled") then
                pcall(function() self:TrackWebhookEvents() end)
                pcall(function() self:RunWebhookSummary() end)
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            local interval = tonumber(self:OptionValue("FuseInterval", 8)) or 8
            task.wait(interval)
            if self:IsOn("AutoFusePets") and not self.IsProcessing and not self:IsCarrying() then
                self.IsProcessing = true
                pcall(function() self:RunAutoFusePets() end)
                self.IsProcessing = false
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            task.wait(1)
            if self:IsOn("AutoDeleteOwnPets") then
                pcall(function()
                    local renderedAssets = workspace:FindFirstChild("ClientRenderedAssets")
                    if renderedAssets then
                        for _, pet in ipairs(renderedAssets:GetChildren()) do
                            if pet:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
                                pcall(function() pet:Destroy() end)
                            end
                        end
                    end
                end)
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            task.wait(15)
            if self:IsOn("AutoClaimOffline") then
                pcall(function() self:RunClaimOfflineEarnings() end)
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
            task.wait(6)
            if self:IsOn("AutoBuyTrail") and not self:IsCarrying() then
                pcall(function() self:RunAutoBuyTrail() end)
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            task.wait(2)
            if self:IsOn("AntiAfk") then
                local idleTime = tick() - self.LastInputTime
                if idleTime >= 300 then
                    pcall(function() self:AntiAfkTap() end)
                end
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
            task.wait(1)
            if self:IsOn("DisableRendering") then
                pcall(function() self:UpdateRenderOverlay() end)
            else
                if self.RenderOverlay then
                    pcall(function() self:DestroyRenderOverlay() end)
                end
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            task.wait(0.5)
            if self:IsOn("FpsBoost") then
                self:ApplyFpsBoost(true)
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            task.wait(1)
            if self:IsOn("AutoReconnect") or self:IsOn("WebhookDisconnectAlerts") then
                local promptGui = CoreGui:FindFirstChild("RobloxPromptGui")
                if promptGui then
                    local promptOverlay = promptGui:FindFirstChild("promptOverlay")
                    if promptOverlay then
                        for _, child in ipairs(promptOverlay:GetChildren()) do
                            if child.Name:find("ErrorPrompt") and child.Visible then
                                self:HandleDisconnect("Roblox error prompt")
                                break
                            end
                        end
                    end
                end
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            task.wait(0.2)
            if self:IsStealingEnabled() then
                if not self.IsGhosting then
                    self:SetGhostState(true)
                end
            else
                if self.IsGhosting then
                    self:SetGhostState(false)
                end
            end
        end
    end)
    
    task.spawn(function()
        while not self.Unloaded do
            task.wait(0.2)
            if not self.IsProcessing then
                if self:IsOn("AutoDropEgg") and self:IsCarrying() then
                    self.IsProcessing = true
                    pcall(function()
                        if plotCmds then plotCmds.RequestDropHeldAreaEgg() end
                    end)
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
    
    -- FPS cap
    self:ApplyFpsCap(self:OptionValue("FpsCap", 60))
    
    -- Auto execute on teleport
    if self:IsOn("AutoExecute") then
        local queueFunc = syn and syn.queue_on_teleport or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
        if queueFunc then
            Workspace.OnTeleport:Connect(function()
                if self:IsOn("AutoExecute") then
                    queueFunc('loadstring(game:HttpGet("https://raw.githubusercontent.com/panduhub/stealanegg/main/stealanegg.lua"))()')
                end
            end)
        end
    end
    
    -- Session time display
    task.spawn(function()
        while not self.Unloaded do
            task.wait(1)
            if self.RenderOverlay then
                self:UpdateRenderOverlay()
            end
        end
    end)
    
    self:Notify("Pandu Hub loaded successfully!")
    self:Notify("Press LeftAlt to toggle UI")
end

-- ============================================
-- 32. CREATE UI
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
    
    -- Store tabs
    self.Tabs = {
        Main = MainTab,
        Steal = StealTab,
        Lifecycle = LifecycleTab,
        Pets = PetsTab,
        Shop = ShopTab,
        Visuals = VisualsTab,
        Esp = EspTab,
        Movement = MovementTab,
        Webhook = WebhookTab,
        Priority = PriorityTab,
        Settings = SettingsTab,
        Info = InfoTab
    }
    
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
    self.Options["HopValue"] = HopGroup:AddSlider("HopValue", {Text = "Threshold", Min = 1, Max = 200, Default = 15, Rounding = 0})
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
            local pos = nil
            if target == "Base" then pos = self:GetBasePosition()
            elseif target == "Pet Area" then pos = self:GetPetAreaPosition()
            elseif target == "Treadmill" then pos = self:GetTreadmillPosition()
            elseif target == "Fuse Machine" then pos = self:GetFuseMachinePosition()
            elseif target == "Lobby Entry" then pos = self:GetEntryPosition()
            end
            if pos and self:TravelTo(pos, true) then
                self:Notify("Teleported to " .. target)
            else
                self:Notify("Failed to teleport")
            end
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
    WebhookGroup:AddButton("Send Summary Now", function()
        local success = self:SendSummary()
        self:Notify(success and "Summary sent" or "Webhook send failed")
    end)
    
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
    self.Toggles["AntiAfk"] = MenuGroup:AddToggle("AntiAfk", {Text = "Anti-AFK", Default = true})
    self.Toggles["AntiGameplayPause"] = MenuGroup:AddToggle("AntiGameplayPause", {Text = "No Gameplay Paused", Default = true})
    self.Toggles["AutoHideUi"] = MenuGroup:AddToggle("AutoHideUi", {Text = "Auto Hide UI", Default = false, Callback = function(v) if v then task.defer(function() self.Window:Toggle(false) end) end end})
    self.Toggles["AutoReconnect"] = MenuGroup:AddToggle("AutoReconnect", {Text = "Auto Reconnect", Default = false})
    self.Toggles["AutoExecute"] = MenuGroup:AddToggle("AutoExecute", {Text = "Auto Execute", Default = false})
    self.Toggles["DisableRendering"] = MenuGroup:AddToggle("DisableRendering", {Text = "Disable 3D Rendering", Default = false})
    
    local PerfGroup = SettingsTab:AddRightGroupbox("Performance", "gauge")
    self.Toggles["FpsBoost"] = PerfGroup:AddToggle("FpsBoost", {Text = "FPS Boost", Default = false})
    self.Toggles["AutoDeleteOwnPets"] = PerfGroup:AddToggle("AutoDeleteOwnPets", {Text = "Auto Delete Own Pets", Default = false})
    self.Options["FpsCap"] = PerfGroup:AddSlider("FpsCap", {Text = "FPS Cap", Min = 15, Max = 360, Default = 60, Suffix = " fps", Rounding = 0})
    
    -- INFO TAB
    local InfoGroup = InfoTab:AddLeftGroupbox("Info", "info")
    InfoGroup:AddLabel("Pandu Hub - Steal an Egg", true)
    InfoGroup:AddLabel("Version: 1.0", true)
    InfoGroup:AddLabel("Made with Obsidian Library", true)
    InfoGroup:AddDivider()
    InfoGroup:AddButton("Copy Discord Invite", function() self:CopyDiscord() end)
    
    local DiscordGroup = InfoTab:AddLeftGroupbox("Discord", "discord")
    DiscordGroup:AddButton("Join Discord to Make Money", function() self:CopyDiscord() end)
    DiscordGroup:AddButton("Join Discord for Keyless Scripts", function() self:CopyDiscord() end)
    
    local DonationGroup = InfoTab:AddRightGroupbox("Donations", "heart")
    DonationGroup:AddLabel("All donations are optional but appreciated.", true)
    DonationGroup:AddLabel("If you donate you get a special role, just PING after you donate.", true)
    DonationGroup:AddDivider()
    
    print("UI created successfully!")
end

-- ============================================
-- 33. START
-- ============================================

PanduHub:Init()

getgenv().PanduHub = PanduHub
getgenv().UnloadPandu = function()
    PanduHub.Unloaded = true
    PanduHub:Notify("Pandu Hub unloaded")
end

print("========================================")
print("PANDU HUB LOADED SUCCESSFULLY!")
print("Press LeftAlt to toggle UI")
print("========================================")