--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║               UILibrary - Premium Edition                   ║
    ║            by Rylax0322 · Spring Animation                 ║
    ╚══════════════════════════════════════════════════════════════╝
    Version: 4.0
    License: MIT
    
    This is a full-featured Roblox UI library with:
    • Spring-based minimize/maximize (smooth like Rayfield)
    • Floating icon when minimized  
    • Draggable, Resizable window
    • Tab & Section system (2 columns)
    • Elements: Button, Toggle, Slider, Dropdown, Textbox, Label, Divider
    • Notification system with spring animation
    • Dialog system
    • Theme engine (Dark/Light/Custom)
    • Mobile & PC support
    • Custom Icon system
    • Glassmorphism effects
]]

-- ============================================================
-- SECTION 1: SERVICES & INITIALIZATION
-- ============================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- ============================================================
-- SECTION 2: SPRING PHYSICS ENGINE
-- ============================================================
--[[
    Spring Engine - Physics-based animation system
    Uses Hooke's Law: F = -k * x
    With damping: F_damp = -d * v
    
    Stiffness (k): How fast spring returns to target
    Damping (d): How quickly oscillation settles
    
    Default values tuned for smooth UI:
    - Window: stiffness=180, damping=18 (snappy)
    - Notifications: stiffness=120, damping=15 (gentle)
    - Hover: stiffness=200, damping=25 (immediate)
]]
local SpringEngine = {}
SpringEngine.__index = SpringEngine

function SpringEngine.new(initialValue, stiffness, damping)
    local self = setmetatable({}, SpringEngine)
    self.Value = initialValue or 0
    self.Velocity = 0
    self.Target = initialValue or 0
    self.Stiffness = stiffness or 180
    self.Damping = damping or 18
    self.Active = false
    self.Listeners = {}
    self.Connection = nil
    return self
end

function SpringEngine:SetTarget(target)
    self.Target = target
    if not self.Active then
        self.Active = true
        self:StartSimulation()
    end
end

function SpringEngine:SetValue(value)
    self.Value = value
    self.Target = value
    self.Velocity = 0
    self:NotifyListeners()
end

function SpringEngine:StartSimulation()
    if self.Connection then return end
    
    local lastTime = tick()
    self.Connection = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        local deltaTime = currentTime - lastTime
        lastTime = currentTime
        
        -- Cap deltaTime to prevent physics explosion on lag spikes
        deltaTime = math.min(deltaTime, 0.05)
        
        -- Skip if deltaTime is too small
        if deltaTime <= 0 then return end
        
        -- Semi-implicit Euler integration
        -- 1. Calculate force
        local displacement = self.Target - self.Value
        local springForce = displacement * self.Stiffness
        local dampingForce = self.Velocity * self.Damping
        
        -- 2. Update velocity
        self.Velocity = self.Velocity + (springForce - dampingForce) * deltaTime
        
        -- 3. Update position
        self.Value = self.Value + self.Velocity * deltaTime
        
        -- Check if we're close enough to target to snap
        local absDisplacement = math.abs(displacement)
        local absVelocity = math.abs(self.Velocity)
        
        if absDisplacement < 0.001 and absVelocity < 0.01 then
            self.Value = self.Target
            self.Velocity = 0
            self.Active = false
            self:NotifyListeners()
            
            if self.Connection then
                self.Connection:Disconnect()
                self.Connection = nil
            end
            return
        end
        
        self:NotifyListeners()
    end)
end

function SpringEngine:NotifyListeners()
    for _, listener in ipairs(self.Listeners) do
        listener(self.Value)
    end
end

function SpringEngine:OnChange(callback)
    table.insert(self.Listeners, callback)
end

function SpringEngine:Destroy()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    self.Listeners = {}
end

-- ============================================================
-- SECTION 3: SPRING-BASED ANIMATION CONTROLLER
-- ============================================================
--[[
    AnimationController - Manages spring-driven UI animations
    Handles: size, position, transparency, color transitions
]]
local AnimationController = {}
AnimationController.__index = AnimationController

function AnimationController.new()
    local self = setmetatable({}, AnimationController)
    self.Springs = {}
    self.Connections = {}
    return self
end

function AnimationController:AnimateSize(frame, targetSize, stiffness, damping)
    local key = frame.Name .. "_Size_X"
    if not self.Springs[key] then
        local spring = SpringEngine.new(frame.Size.X.Offset, stiffness or 180, damping or 18)
        spring:OnChange(function(value)
            frame.Size = UDim2.new(0, value, frame.Size.Y.Scale, frame.Size.Y.Offset)
        end)
        self.Springs[key] = spring
    end
    
    self.Springs[key]:SetTarget(targetSize.X.Offset)
    
    -- Also animate Y if needed
    local keyY = frame.Name .. "_Size_Y"
    if targetSize.Y.Offset ~= frame.Size.Y.Offset then
        if not self.Springs[keyY] then
            local springY = SpringEngine.new(frame.Size.Y.Offset, stiffness or 180, damping or 18)
            springY:OnChange(function(value)
                frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, value)
            end)
            self.Springs[keyY] = springY
        end
        self.Springs[keyY]:SetTarget(targetSize.Y.Offset)
    end
end

function AnimationController:AnimatePosition(frame, targetPosition, stiffness, damping)
    local key = frame.Name .. "_Pos"
    if not self.Springs[key] then
        local spring = SpringEngine.new(0, stiffness or 120, damping or 15)
        spring:OnChange(function(value)
            -- Interpolate between start and target
            local t = math.clamp(value, 0, 1)
            local x = self._startPos.X.Offset + (targetPosition.X.Offset - self._startPos.X.Offset) * t
            local y = self._startPos.Y.Offset + (targetPosition.Y.Offset - self._startPos.Y.Offset) * t
            frame.Position = UDim2.new(0, x, 0, y)
        end)
        self.Springs[key] = spring
        self._startPositions = self._startPositions or {}
        self._startPositions[key] = frame.Position
    end
    
    self._startPositions[key] = frame.Position
    self.Springs[key]:SetTarget(1)
end

function AnimationController:AnimateTransparency(element, targetTransparency, stiffness, damping)
    local key = element.Name .. "_Transp"
    if not self.Springs[key] then
        local current = element.BackgroundTransparency
        local spring = SpringEngine.new(current, stiffness or 150, damping or 12)
        spring:OnChange(function(value)
            element.BackgroundTransparency = math.clamp(value, 0, 1)
        end)
        self.Springs[key] = spring
    end
    
    self.Springs[key]:SetTarget(targetTransparency)
end

function AnimationController:Destroy()
    for _, spring in pairs(self.Springs) do
        spring:Destroy()
    end
    for _, conn in ipairs(self.Connections) do
        conn:Disconnect()
    end
end

-- ============================================================
-- SECTION 4: UTILITY FUNCTIONS
-- ============================================================
local Utility = {}

function Utility.Create(className, properties, children)
    local instance = Instance.new(className)
    
    for property, value in pairs(properties or {}) do
        if property ~= "ThemeTag" and property ~= "Children" then
            instance[property] = value
        end
    end
    
    if children then
        for _, child in ipairs(children) do
            if typeof(child) == "Instance" then
                child.Parent = instance
            end
        end
    end
    
    return instance
end

function Utility.MakeDraggable(frame, handle)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local dragInput = nil
    
    handle = handle or frame
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Utility.MakeResizable(frame, handle, minWidth, minHeight)
    local resizing = false
    local resizeStart = nil
    local startSize = nil
    
    minWidth = minWidth or 400
    minHeight = minHeight or 300
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStart = input.Position
            startSize = frame.Size
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeStart
            local newWidth = math.max(minWidth, startSize.Width.Offset + delta.X)
            local newHeight = math.max(minHeight, startSize.Height.Offset + delta.Y)
            frame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)
end

function Utility.IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function Utility.GenerateGUID()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 15) or math.random(8, 11)
        return string.format('%x', v)
    end)
end

function Utility.Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function Utility.Lerp(a, b, t)
    return a + (b - a) * t
end

function Utility.LerpColor(colorA, colorB, t)
    return Color3.new(
        Utility.Lerp(colorA.R, colorB.R, t),
        Utility.Lerp(colorA.G, colorB.G, t),
        Utility.Lerp(colorA.B, colorB.B, t)
    )
end

function Utility.ColorToHex(color)
    return string.format("#%02X%02X%02X", 
        math.floor(color.R * 255), 
        math.floor(color.G * 255), 
        math.floor(color.B * 255)
    )
end

function Utility.HexToColor(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber("0x" .. hex:sub(1, 2)),
        tonumber("0x" .. hex:sub(3, 4)),
        tonumber("0x" .. hex:sub(5, 6))
    )
end

-- ============================================================
-- SECTION 5: ICON SYSTEM
-- ============================================================
local IconSystem = {}
IconSystem.Cache = {}

-- Built-in icon mapping (simplified Lucide icons)
IconSystem.Icons = {
    -- Navigation
    ["home"] = "rbxassetid://6031068421",
    ["settings"] = "rbxassetid://6031282542",
    ["search"] = "rbxassetid://6031103189",
    ["menu"] = "rbxassetid://6031094753",
    ["x"] = "rbxassetid://6031073852",
    ["plus"] = "rbxassetid://6031280885",
    ["minus"] = "rbxassetid://6031280885",
    ["chevron-down"] = "rbxassetid://6031094753",
    ["chevron-up"] = "rbxassetid://6031094753",
    ["chevron-left"] = "rbxassetid://6031094753",
    ["chevron-right"] = "rbxassetid://6031094753",
    
    -- Actions
    ["play"] = "rbxassetid://6031282542",
    ["pause"] = "rbxassetid://6031282542",
    ["refresh"] = "rbxassetid://6031282542",
    ["download"] = "rbxassetid://6031282542",
    ["upload"] = "rbxassetid://6031282542",
    ["copy"] = "rbxassetid://6031282542",
    ["trash"] = "rbxassetid://6031282542",
    ["edit"] = "rbxassetid://6031282542",
    ["save"] = "rbxassetid://6031282542",
    ["folder"] = "rbxassetid://6031282542",
    ["file"] = "rbxassetid://6031282542",
    
    -- Gaming
    ["sword"] = "rbxassetid://6031282542",
    ["shield"] = "rbxassetid://6031282542",
    ["target"] = "rbxassetid://6031282542",
    ["trophy"] = "rbxassetid://6031282542",
    ["star"] = "rbxassetid://6031282542",
    ["heart"] = "rbxassetid://6031282542",
    ["fire"] = "rbxassetid://6031282542",
    ["zap"] = "rbxassetid://6031282542",
    ["skull"] = "rbxassetid://6031282542",
    ["crown"] = "rbxassetid://6031282542",
    
    -- Pets/Eggs
    ["egg"] = "rbxassetid://6031282542",
    ["gift"] = "rbxassetid://6031282542",
    ["package"] = "rbxassetid://6031282542",
    ["shopping-cart"] = "rbxassetid://6031282542",
    ["coins"] = "rbxassetid://6031282542",
    ["gem"] = "rbxassetid://6031282542",
    ["wand"] = "rbxassetid://6031282542",
    
    -- Communication
    ["user"] = "rbxassetid://6031282542",
    ["users"] = "rbxassetid://6031282542",
    ["mail"] = "rbxassetid://6031282542",
    ["bell"] = "rbxassetid://6031282542",
    ["message-circle"] = "rbxassetid://6031282542",
    
    -- Security
    ["key"] = "rbxassetid://6031282542",
    ["lock"] = "rbxassetid://6031282542",
    ["unlock"] = "rbxassetid://6031282542",
    ["eye"] = "rbxassetid://6031282542",
    ["eye-off"] = "rbxassetid://6031282542",
    ["shield-check"] = "rbxassetid://6031282542",
    
    -- Weather
    ["sun"] = "rbxassetid://6031282542",
    ["moon"] = "rbxassetid://6031282542",
    ["cloud"] = "rbxassetid://6031282542",
    ["cloud-rain"] = "rbxassetid://6031282542",
    ["snowflake"] = "rbxassetid://6031282542",
    ["wind"] = "rbxassetid://6031282542",
    
    -- Arrows
    ["arrow-up"] = "rbxassetid://6031282542",
    ["arrow-down"] = "rbxassetid://6031282542",
    ["arrow-left"] = "rbxassetid://6031282542",
    ["arrow-right"] = "rbxassetid://6031282542",
    ["rotate-cw"] = "rbxassetid://6031282542",
    ["rotate-ccw"] = "rbxassetid://6031282542",
    
    -- Misc
    ["check"] = "rbxassetid://6031282542",
    ["circle"] = "rbxassetid://6031282542",
    ["square"] = "rbxassetid://6031282542",
    ["triangle"] = "rbxassetid://6031282542",
    ["alert-triangle"] = "rbxassetid://6031282542",
    ["info"] = "rbxassetid://6031282542",
    ["help-circle"] = "rbxassetid://6031282542",
    ["loader"] = "rbxassetid://6031282542",
    ["clock"] = "rbxassetid://6031282542",
    ["calendar"] = "rbxassetid://6031282542",
    ["map-pin"] = "rbxassetid://6031282542",
    ["compass"] = "rbxassetid://6031282542",
    ["camera"] = "rbxassetid://6031282542",
    ["image"] = "rbxassetid://6031282542",
    ["video"] = "rbxassetid://6031282542",
    ["music"] = "rbxassetid://6031282542",
    ["volume-2"] = "rbxassetid://6031282542",
    ["volume-x"] = "rbxassetid://6031282542",
    ["wifi"] = "rbxassetid://6031282542",
    ["bluetooth"] = "rbxassetid://6031282542",
    ["battery"] = "rbxassetid://6031282542",
    ["smartphone"] = "rbxassetid://6031282542",
    ["tablet"] = "rbxassetid://6031282542",
    ["monitor"] = "rbxassetid://6031282542",
    ["laptop"] = "rbxassetid://6031282542",
}

function IconSystem.Get(iconName, size)
    size = size or 24
    local assetId = IconSystem.Icons[iconName] or IconSystem.Icons["circle"]
    
    return {
        Image = assetId,
        ImageRectSize = Vector2.new(size, size),
        ImageRectOffset = Vector2.new(0, 0),
        Size = size,
    }
end

function IconSystem.Create(iconName, size, parent, color, transparency)
    local data = IconSystem.Get(iconName, size)
    local icon = Utility.Create("ImageLabel", {
        Name = "Icon_" .. iconName,
        Image = data.Image,
        ImageRectSize = data.ImageRectSize,
        ImageRectOffset = data.ImageRectOffset,
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1,
        ImageColor3 = color or Color3.new(1, 1, 1),
        ImageTransparency = transparency or 0,
        Parent = parent,
    })
    return icon
end

-- ============================================================
-- SECTION 6: THEME ENGINE
-- ============================================================
local ThemeEngine = {}
ThemeEngine.CurrentTheme = nil

ThemeEngine.Themes = {
    Dark = {
        Window = {
            Background = Color3.fromRGB(15, 15, 25),
            Border = Color3.fromRGB(255, 255, 255),
            BorderTransparency = 0.92,
            Shadow = Color3.fromRGB(0, 0, 0),
            ShadowTransparency = 0.6,
        },
        Topbar = {
            Background = Color3.fromRGB(18, 18, 32),
            Text = Color3.fromRGB(255, 255, 255),
            ButtonHover = Color3.fromRGB(255, 255, 255),
            ButtonHoverTransparency = 0.9,
        },
        Sidebar = {
            Background = Color3.fromRGB(16, 16, 28),
            ToggleButton = Color3.fromRGB(80, 120, 255),
            ToggleIcon = Color3.fromRGB(255, 255, 255),
        },
        Tab = {
            Background = Color3.fromRGB(30, 32, 48),
            Active = Color3.fromRGB(80, 120, 255),
            Text = Color3.fromRGB(200, 200, 220),
            ActiveText = Color3.fromRGB(255, 255, 255),
        },
        Section = {
            Background = Color3.fromRGB(22, 24, 38),
            Border = Color3.fromRGB(255, 255, 255),
            BorderTransparency = 0.94,
            Title = Color3.fromRGB(100, 140, 255),
            Divider = Color3.fromRGB(255, 255, 255),
            DividerTransparency = 0.9,
        },
        Element = {
            Title = Color3.fromRGB(220, 220, 240),
            Description = Color3.fromRGB(160, 160, 180),
            Icon = Color3.fromRGB(200, 200, 220),
        },
        Button = {
            Primary = Color3.fromRGB(80, 120, 255),
            PrimaryText = Color3.fromRGB(255, 255, 255),
            Secondary = Color3.fromRGB(45, 48, 65),
            SecondaryText = Color3.fromRGB(220, 220, 240),
            Danger = Color3.fromRGB(255, 70, 100),
            DangerText = Color3.fromRGB(255, 255, 255),
            Success = Color3.fromRGB(50, 200, 100),
            SuccessText = Color3.fromRGB(255, 255, 255),
            Hover = Color3.fromRGB(255, 255, 255),
            HoverTransparency = 0.85,
        },
        Toggle = {
            Active = Color3.fromRGB(80, 120, 255),
            Inactive = Color3.fromRGB(60, 65, 85),
            Thumb = Color3.fromRGB(255, 255, 255),
            Shadow = Color3.fromRGB(0, 0, 0),
            ShadowTransparency = 0.7,
        },
        Slider = {
            Fill = Color3.fromRGB(80, 120, 255),
            Background = Color3.fromRGB(40, 45, 65),
            Thumb = Color3.fromRGB(255, 255, 255),
            Shadow = Color3.fromRGB(0, 0, 0),
            ShadowTransparency = 0.6,
        },
        Dropdown = {
            Background = Color3.fromRGB(30, 35, 55),
            Border = Color3.fromRGB(255, 255, 255),
            BorderTransparency = 0.9,
            Text = Color3.fromRGB(200, 200, 220),
            Hover = Color3.fromRGB(255, 255, 255),
            HoverTransparency = 0.95,
            Arrow = Color3.fromRGB(180, 180, 200),
        },
        Textbox = {
            Background = Color3.fromRGB(28, 32, 48),
            Border = Color3.fromRGB(255, 255, 255),
            BorderTransparency = 0.9,
            Text = Color3.fromRGB(220, 220, 240),
            Placeholder = Color3.fromRGB(120, 120, 150),
        },
        Notification = {
            Background = Color3.fromRGB(25, 27, 42),
            Border = Color3.fromRGB(80, 120, 255),
            Title = Color3.fromRGB(255, 255, 255),
            Content = Color3.fromRGB(180, 180, 200),
            Timer = Color3.fromRGB(255, 255, 255),
            TimerTransparency = 0.85,
        },
        Footer = {
            Background = Color3.fromRGB(14, 14, 24),
            Text = Color3.fromRGB(120, 120, 150),
        },
        Scrollbar = {
            Color = Color3.fromRGB(60, 65, 85),
        },
        FloatingIcon = {
            Background = Color3.fromRGB(80, 120, 255),
            Text = Color3.fromRGB(255, 255, 255),
            Border = Color3.fromRGB(255, 255, 255),
            BorderTransparency = 0.5,
        },
    },
    
    Light = {
        Window = {
            Background = Color3.fromRGB(245, 245, 250),
            Border = Color3.fromRGB(0, 0, 0),
            BorderTransparency = 0.9,
            Shadow = Color3.fromRGB(0, 0, 0),
            ShadowTransparency = 0.8,
        },
        Topbar = {
            Background = Color3.fromRGB(235, 235, 242),
            Text = Color3.fromRGB(30, 30, 40),
            ButtonHover = Color3.fromRGB(0, 0, 0),
            ButtonHoverTransparency = 0.9,
        },
        Sidebar = {
            Background = Color3.fromRGB(240, 240, 247),
            ToggleButton = Color3.fromRGB(70, 110, 245),
            ToggleIcon = Color3.fromRGB(255, 255, 255),
        },
        Tab = {
            Background = Color3.fromRGB(225, 225, 238),
            Active = Color3.fromRGB(70, 110, 245),
            Text = Color3.fromRGB(90, 90, 110),
            ActiveText = Color3.fromRGB(255, 255, 255),
        },
        Section = {
            Background = Color3.fromRGB(255, 255, 255),
            Border = Color3.fromRGB(0, 0, 0),
            BorderTransparency = 0.93,
            Title = Color3.fromRGB(70, 110, 245),
            Divider = Color3.fromRGB(0, 0, 0),
            DividerTransparency = 0.9,
        },
        Element = {
            Title = Color3.fromRGB(50, 50, 70),
            Description = Color3.fromRGB(110, 110, 130),
            Icon = Color3.fromRGB(80, 80, 100),
        },
        Button = {
            Primary = Color3.fromRGB(70, 110, 245),
            PrimaryText = Color3.fromRGB(255, 255, 255),
            Secondary = Color3.fromRGB(210, 210, 225),
            SecondaryText = Color3.fromRGB(50, 50, 70),
            Danger = Color3.fromRGB(255, 70, 100),
            DangerText = Color3.fromRGB(255, 255, 255),
            Success = Color3.fromRGB(50, 200, 100),
            SuccessText = Color3.fromRGB(255, 255, 255),
            Hover = Color3.fromRGB(0, 0, 0),
            HoverTransparency = 0.95,
        },
        Toggle = {
            Active = Color3.fromRGB(70, 110, 245),
            Inactive = Color3.fromRGB(190, 190, 210),
            Thumb = Color3.fromRGB(255, 255, 255),
            Shadow = Color3.fromRGB(0, 0, 0),
            ShadowTransparency = 0.8,
        },
        Slider = {
            Fill = Color3.fromRGB(70, 110, 245),
            Background = Color3.fromRGB(210, 210, 230),
            Thumb = Color3.fromRGB(255, 255, 255),
            Shadow = Color3.fromRGB(0, 0, 0),
            ShadowTransparency = 0.7,
        },
        Dropdown = {
            Background = Color3.fromRGB(255, 255, 255),
            Border = Color3.fromRGB(0, 0, 0),
            BorderTransparency = 0.9,
            Text = Color3.fromRGB(50, 50, 70),
            Hover = Color3.fromRGB(0, 0, 0),
            HoverTransparency = 0.96,
            Arrow = Color3.fromRGB(90, 90, 110),
        },
        Textbox = {
            Background = Color3.fromRGB(248, 248, 252),
            Border = Color3.fromRGB(0, 0, 0),
            BorderTransparency = 0.93,
            Text = Color3.fromRGB(50, 50, 70),
            Placeholder = Color3.fromRGB(160, 160, 180),
        },
        Notification = {
            Background = Color3.fromRGB(255, 255, 255),
            Border = Color3.fromRGB(70, 110, 245),
            Title = Color3.fromRGB(30, 30, 40),
            Content = Color3.fromRGB(100, 100, 120),
            Timer = Color3.fromRGB(0, 0, 0),
            TimerTransparency = 0.9,
        },
        Footer = {
            Background = Color3.fromRGB(235, 235, 242),
            Text = Color3.fromRGB(130, 130, 150),
        },
        Scrollbar = {
            Color = Color3.fromRGB(190, 190, 210),
        },
        FloatingIcon = {
            Background = Color3.fromRGB(70, 110, 245),
            Text = Color3.fromRGB(255, 255, 255),
            Border = Color3.fromRGB(255, 255, 255),
            BorderTransparency = 0.6,
        },
    }
}

function ThemeEngine.SetTheme(themeName)
    if ThemeEngine.Themes[themeName] then
        ThemeEngine.CurrentTheme = ThemeEngine.Themes[themeName]
    else
        ThemeEngine.CurrentTheme = ThemeEngine.Themes.Dark
    end
end

function ThemeEngine.GetColor(path)
    local keys = {}
    for key in string.gmatch(path, "[^.]+") do
        table.insert(keys, key)
    end
    
    local current = ThemeEngine.CurrentTheme
    if not current then return Color3.new(1, 1, 1) end
    
    for _, key in ipairs(keys) do
        if current[key] then
            current = current[key]
        else
            return Color3.new(1, 1, 1)
        end
    end
    
    if typeof(current) == "Color3" then
        return current
    end
    return Color3.new(1, 1, 1)
end

function ThemeEngine.GetTransparency(path)
    local fullPath = path .. "Transparency"
    local keys = {}
    for key in string.gmatch(fullPath, "[^.]+") do
        table.insert(keys, key)
    end
    
    local current = ThemeEngine.CurrentTheme
    if not current then return 0 end
    
    for _, key in ipairs(keys) do
        if current[key] ~= nil then
            current = current[key]
        else
            return 0
        end
    end
    
    if typeof(current) == "number" then
        return current
    end
    return 0
end

-- Initialize with Dark theme
ThemeEngine.SetTheme("Dark")

-- ============================================================
-- SECTION 7: NOTIFICATION SYSTEM
-- ============================================================
local NotificationSystem = {}
NotificationSystem.Active = {}
NotificationSystem.Queue = {}
NotificationSystem.MaxVisible = 5
NotificationSystem.Holder = nil

function NotificationSystem.Initialize(holder)
    NotificationSystem.Holder = holder
end

function NotificationSystem.Create(config)
    local notification = {
        Title = config.Title or "Notification",
        Content = config.Content or "",
        Duration = config.Duration or 4,
        Icon = config.Icon or "bell",
        Type = config.Type or "info", -- info, success, warning, error
    }
    
    table.insert(NotificationSystem.Queue, notification)
    NotificationSystem.ProcessQueue()
    
    return notification
end

function NotificationSystem.ProcessQueue()
    while #NotificationSystem.Active < NotificationSystem.MaxVisible and #NotificationSystem.Queue > 0 do
        local notification = table.remove(NotificationSystem.Queue, 1)
        NotificationSystem.Show(notification)
    end
end

function NotificationSystem.Show(notification)
    if not NotificationSystem.Holder then return end
    
    local theme = ThemeEngine.CurrentTheme.Notification
    
    -- Container
    local container = Utility.Create("Frame", {
        Name = "Notification",
        Size = UDim2.new(0, 300, 0, 0),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = NotificationSystem.Holder,
    })
    Utility.Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = container })
    
    -- Border
    local borderColor = notification.Type == "success" and ThemeEngine.CurrentTheme.Button.Success or
                       notification.Type == "error" and ThemeEngine.CurrentTheme.Button.Danger or
                       notification.Type == "warning" and Color3.fromRGB(255, 180, 50) or
                       theme.Border
    
    Utility.Create("UIStroke", {
        Color = borderColor,
        Thickness = 1.5,
        Transparency = 0.3,
        Parent = container,
    })
    
    -- Content
    local content = Utility.Create("Frame", {
        Size = UDim2.new(1, -20, 1, -16),
        Position = UDim2.new(0, 10, 0, 8),
        BackgroundTransparency = 1,
        Parent = container,
    })
    
    -- Title
    local titleLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, -30, 0, 18),
        BackgroundTransparency = 1,
        Text = notification.Title,
        TextColor3 = theme.Title,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = content,
    })
    
    -- Close button
    local closeBtn = Utility.Create("TextButton", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -20, 0, 0),
        BackgroundTransparency = 1,
        Text = "✕",
        TextColor3 = theme.Content,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Parent = content,
    })
    
    -- Content text
    local contentLabel
    if notification.Content ~= "" then
        contentLabel = Utility.Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            Position = UDim2.new(0, 0, 0, 22),
            BackgroundTransparency = 1,
            Text = notification.Content,
            TextColor3 = theme.Content,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = content,
        })
    end
    
    -- Timer bar
    local timerBg = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = theme.Timer,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Parent = container,
    })
    
    local timerFill = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = borderColor,
        BorderSizePixel = 0,
        Parent = timerBg,
    })
    Utility.Create("UICorner", { CornerRadius = UDim.new(0, 1), Parent = timerFill })
    
    -- Total height
    local totalHeight = notification.Content ~= "" and 58 or 38
    
    -- Spring animation for entry
    local springY = SpringEngine.new(0, 140, 14)
    springY:OnChange(function(value)
        container.Size = UDim2.new(0, 300, 0, value)
    end)
    springY:SetTarget(totalHeight)
    
    -- Timer animation
    local timerTween = TweenService:Create(timerFill, 
        TweenInfo.new(notification.Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In), 
        { Size = UDim2.new(0, 0, 1, 0) }
    )
    timerTween:Play()
    
    -- Close button handler
    closeBtn.MouseButton1Click:Connect(function()
        NotificationSystem.Dismiss(container, springY)
    end)
    
    -- Auto dismiss
    task.delay(notification.Duration, function()
        NotificationSystem.Dismiss(container, springY)
    end)
    
    table.insert(NotificationSystem.Active, { container = container, spring = springY })
end

function NotificationSystem.Dismiss(container, spring)
    if not container.Parent then return end
    
    spring:SetTarget(0)
    
    task.delay(0.3, function()
        if container.Parent then
            container:Destroy()
        end
        
        -- Remove from active
        for i, item in ipairs(NotificationSystem.Active) do
            if item.container == container then
                table.remove(NotificationSystem.Active, i)
                break
            end
        end
        
        NotificationSystem.ProcessQueue()
    end)
end

-- ============================================================
-- SECTION 8: DIALOG SYSTEM
-- ============================================================
local DialogSystem = {}

function DialogSystem.Show(window, config)
    config = config or {}
    
    local screenGui = window._screenGui
    
    -- Overlay
    local overlay = Utility.Create("Frame", {
        Name = "DialogOverlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 1000,
        Parent = screenGui,
    })
    
    -- Dialog frame
    local dialogFrame = Utility.Create("Frame", {
        Name = "DialogFrame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = ThemeEngine.GetColor("Section.Background"),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 1001,
        Parent = overlay,
    })
    Utility.Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = dialogFrame })
    Utility.Create("UIStroke", {
        Color = ThemeEngine.GetColor("Section.Border"),
        Thickness = 1,
        Transparency = 0.9,
        Parent = dialogFrame,
    })
    
    -- Content
    local content = Utility.Create("Frame", {
        Size = UDim2.new(0, 260, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = dialogFrame,
    })
    
    Utility.Create("UIPadding", {
        PaddingTop = UDim.new(0, 20),
        PaddingBottom = UDim.new(0, 20),
        PaddingLeft = UDim.new(0, 20),
        PaddingRight = UDim.new(0, 20),
        Parent = content,
    })
    
    -- Title
    local titleLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = config.Title or "Dialog",
        TextColor3 = ThemeEngine.GetColor("Element.Title"),
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextWrapped = true,
        Parent = content,
    })
    
    -- Body
    if config.Content then
        Utility.Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Position = UDim2.new(0, 0, 0, titleLabel.AbsoluteSize.Y + 8),
            BackgroundTransparency = 1,
            Text = config.Content,
            TextColor3 = ThemeEngine.GetColor("Element.Description"),
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextWrapped = true,
            Parent = content,
        })
    end
    
    -- Buttons
    if config.Buttons and #config.Buttons > 0 then
        local buttonHolder = Utility.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 34),
            Position = UDim2.new(0, 0, 1, -54),
            BackgroundTransparency = 1,
            Parent = content,
        })
        
        local buttonLayout = Utility.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = buttonHolder,
        })
        
        for _, btnConfig in ipairs(config.Buttons) do
            local style = btnConfig.Style or "Primary"
            local color = style == "Danger" and ThemeEngine.CurrentTheme.Button.Danger or
                         style == "Secondary" and ThemeEngine.CurrentTheme.Button.Secondary or
                         ThemeEngine.CurrentTheme.Button.Primary
            
            local btn = Utility.Create("TextButton", {
                Size = UDim2.new(0, 100, 0, 30),
                BackgroundColor3 = color,
                Text = btnConfig.Title or "Button",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                BorderSizePixel = 0,
                Parent = buttonHolder,
            })
            Utility.Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
            
            btn.MouseButton1Click:Connect(function()
                overlay:Destroy()
                if btnConfig.Callback then
                    pcall(btnConfig.Callback)
                end
            end)
        end
    end
    
    -- Animate in
    local springAlpha = SpringEngine.new(0, 120, 12)
    springAlpha:OnChange(function(value)
        overlay.BackgroundTransparency = 1 - value * 0.6
    end)
    springAlpha:SetTarget(1)
    
    local springScale = SpringEngine.new(0.8, 160, 16)
    springScale:OnChange(function(value)
        dialogFrame.Size = UDim2.new(0, 280 * value, 0, content.AbsoluteSize.Y * value)
    end)
    springScale:SetTarget(1)
    
    -- Close on overlay click
    overlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            springAlpha:SetTarget(0)
            task.delay(0.3, function()
                overlay:Destroy()
            end)
        end
    end)
end

-- ============================================================
-- END OF PART 1
-- Continue to Part 2 for Window, Tab, Section, Elements
-- ============================================================
-- ============================================================
-- SECTION 9: MAIN LIBRARY CLASS
-- ============================================================
local Library = {}
Library.Windows = {}
Library.ActiveWindow = nil

function Library:CreateWindow(config)
    config = config or {}
    
    local window = {}
    window.Title = config.Title or "UILibrary"
    window.Version = config.Version or "v4.0"
    window.Game = config.Game or "Unknown Game"
    window.Discord = config.Discord or ""
    window.Folder = config.Folder or window.Title
    window.MinimizeKey = config.MinimizeKey or Enum.KeyCode.RightShift
    window.Resizable = config.Resizable ~= false
    window.Draggable = config.Draggable ~= false
    window.ThemeName = config.Theme or "Dark"
    
    -- Set theme
    ThemeEngine.SetTheme(window.ThemeName)
    window.Theme = ThemeEngine.CurrentTheme
    
    -- Animation controller for this window
    window._animController = AnimationController.new()
    window._tabs = {}
    window._activeTab = nil
    window._isMinimized = false
    window._floatingIcon = nil
    window._signals = {}
    
    -- Create ScreenGui
    local screenGui = Utility.Create("ScreenGui", {
        Name = "RylaxUI_" .. window.Title,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(screenGui)
        end
        screenGui.Parent = CoreGui
    end)
    
    if not screenGui.Parent then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    window._screenGui = screenGui
    
    -- ==================== MAIN FRAME ====================
    local mainFrame = Utility.Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 580, 0, 460),
        Position = UDim2.new(0.5, -290, 0.5, -230),
        BackgroundColor3 = ThemeEngine.GetColor("Window.Background"),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = screenGui,
    })
    Utility.Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = mainFrame })
    Utility.Create("UIStroke", {
        Color = ThemeEngine.GetColor("Window.Border"),
        Thickness = 1,
        Transparency = ThemeEngine.GetTransparency("Window.Border"),
        Parent = mainFrame,
    })
    window._mainFrame = mainFrame
    
    -- Drop shadow
    local shadow = Utility.Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 8),
        Size = UDim2.new(1, 50, 1, 50),
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = ThemeEngine.GetTransparency("Window.Shadow"),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1,
        Parent = mainFrame,
    })
    
    -- ==================== TOPBAR ====================
    local topBar = Utility.Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = ThemeEngine.GetColor("Topbar.Background"),
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    Utility.Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = topBar })
    Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = ThemeEngine.GetColor("Topbar.Background"),
        BorderSizePixel = 0,
        Parent = topBar,
    })
    
    -- Title
    Utility.Create("TextLabel", {
        Size = UDim2.new(1, -130, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = window.Title,
        TextColor3 = ThemeEngine.GetColor("Topbar.Text"),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar,
    })
    
    -- ==================== MINIMIZE BUTTON (KEY FEATURE) ====================
    local minimizeBtn = Utility.Create("TextButton", {
        Name = "MinimizeBtn",
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -72, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(255, 180, 50),
        Text = "─",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        Parent = topBar,
    })
    Utility.Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = minimizeBtn })
    
    -- Close button
    local closeBtn = Utility.Create("TextButton", {
        Name = "CloseBtn",
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -36, 0.5, -14),
        BackgroundColor3 = ThemeEngine.GetColor("Button.Danger"),
        Text = "✕",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        Parent = topBar,
    })
    Utility.Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = closeBtn })
    
    closeBtn.MouseButton1Click:Connect(function()
        window:Destroy()
    end)
    
    -- ==================== SIDEBAR ====================
    local sidebar = Utility.Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 46, 1, -42),
        Position = UDim2.new(0, 0, 0, 42),
        BackgroundColor3 = ThemeEngine.GetColor("Sidebar.Background"),
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    Utility.Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = sidebar })
    Utility.Create("Frame", {
        Size = UDim2.new(0, 12, 1, 0),
        BackgroundColor3 = ThemeEngine.GetColor("Sidebar.Background"),
        BorderSizePixel = 0,
        Parent = sidebar,
    })
    
    -- Menu toggle button
    local menuToggle = Utility.Create("TextButton", {
        Name = "MenuToggle",
        Size = UDim2.new(0, 34, 0, 34),
        Position = UDim2.new(0.5, -17, 0, 8),
        BackgroundColor3 = ThemeEngine.GetColor("Sidebar.ToggleButton"),
        Text = "☰",
        TextColor3 = ThemeEngine.GetColor("Sidebar.ToggleIcon"),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        Parent = sidebar,
    })
    Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = menuToggle })
    
    -- ==================== CONTENT AREA ====================
    local contentFrame = Utility.Create("Frame", {
        Name = "ContentFrame",
        Size = UDim2.new(1, -46, 1, -42),
        Position = UDim2.new(0, 46, 0, 42),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = mainFrame,
    })
    
    -- Tab bar
    local tabBar = Utility.Create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = ThemeEngine.GetColor("Topbar.Background"),
        BorderSizePixel = 0,
        Parent = contentFrame,
    })
    Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = tabBar,
    })
    Utility.Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 6),
        Parent = tabBar,
    })
    
    -- Tab divider
    Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundColor3 = ThemeEngine.GetColor("Section.Divider"),
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Parent = contentFrame,
    })
    
    -- Pages holder
    local pagesHolder = Utility.Create("Frame", {
        Name = "PagesHolder",
        Size = UDim2.new(1, 0, 1, -37),
        Position = UDim2.new(0, 0, 0, 37),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = contentFrame,
    })
    
    -- ==================== FOOTER ====================
    local footer = Utility.Create("Frame", {
        Name = "Footer",
        Size = UDim2.new(1, 0, 0, 26),
        Position = UDim2.new(0, 0, 1, -26),
        BackgroundColor3 = ThemeEngine.GetColor("Footer.Background"),
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    Utility.Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = footer })
    Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        BackgroundColor3 = ThemeEngine.GetColor("Footer.Background"),
        BorderSizePixel = 0,
        Parent = footer,
    })
    
    Utility.Create("TextLabel", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = window.Version .. " | " .. window.Game,
        TextColor3 = ThemeEngine.GetColor("Footer.Text"),
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = footer,
    })
    
    -- ==================== RESIZE CORNER ====================
    if window.Resizable then
        local resizeCorner = Utility.Create("TextButton", {
            Name = "ResizeCorner",
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(1, -20, 1, -20),
            BackgroundTransparency = 1,
            Text = "◢",
            TextColor3 = ThemeEngine.GetColor("Footer.Text"),
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            ZIndex = 10,
            Parent = mainFrame,
        })
        Utility.MakeResizable(mainFrame, resizeCorner, 460, 340)
    end
    
    -- ==================== DRAGGABLE ====================
    if window.Draggable then
        Utility.MakeDraggable(mainFrame, topBar)
    end
    
    -- ==================== MINIMIZE TO FLOATING ICON (SPRING ANIMATION) ====================
    -- This is the KEY feature: smooth minimize/maximize like Rayfield
    local minimizeSpring = SpringEngine.new(1, 170, 17)
    local isMinimizing = false
    local savedSize, savedPosition
    local floatSpring = SpringEngine.new(0, 130, 14)
    
    minimizeSpring:OnChange(function(scale)
        if not mainFrame.Parent then return end
        
        -- Animate scale
        mainFrame.Size = UDim2.new(
            0, savedSize.Width.Offset * scale,
            0, savedSize.Height.Offset * scale
        )
        
        -- Animate position to center when minimizing
        if scale < 1 then
            local targetX = 0.5 - (savedSize.Width.Offset * scale) / (screenGui.AbsoluteSize.X * 2)
            local targetY = 0.5 - (savedSize.Height.Offset * scale) / (screenGui.AbsoluteSize.Y * 2)
            mainFrame.Position = UDim2.new(targetX, 0, targetY, 0)
        end
        
        -- Animate transparency
        mainFrame.BackgroundTransparency = 1 - scale
        topBar.BackgroundTransparency = 1 - scale
    end)
    
    local function minimizeToIcon()
        if isMinimizing then return end
        isMinimizing = true
        
        -- Save current state
        savedSize = mainFrame.Size
        savedPosition = mainFrame.Position
        
        -- Spring animate main window to zero
        minimizeSpring:SetTarget(0)
        
        -- Wait for animation
        task.delay(0.35, function()
            mainFrame.Visible = false
            isMinimizing = false
            
            -- Create floating icon
            if not window._floatingIcon then
                window._floatingIcon = Utility.Create("TextButton", {
                    Name = "FloatingIcon",
                    Size = UDim2.new(0, 48, 0, 48),
                    Position = UDim2.new(1, -64, 0, 16),
                    BackgroundColor3 = ThemeEngine.GetColor("FloatingIcon.Background"),
                    Text = "🥚",
                    TextColor3 = ThemeEngine.GetColor("FloatingIcon.Text"),
                    TextSize = 22,
                    Font = Enum.Font.GothamBold,
                    BorderSizePixel = 0,
                    Parent = screenGui,
                })
                Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = window._floatingIcon })
                Utility.Create("UIStroke", {
                    Color = ThemeEngine.GetColor("FloatingIcon.Border"),
                    Thickness = 1.5,
                    Transparency = ThemeEngine.GetTransparency("FloatingIcon.Border"),
                    Parent = window._floatingIcon,
                })
                
                Utility.MakeDraggable(window._floatingIcon)
                
                -- Spring in
                local iconSpring = SpringEngine.new(0, 150, 15)
                iconSpring:OnChange(function(value)
                    window._floatingIcon.Size = UDim2.new(0, 48 * value, 0, 48 * value)
                    window._floatingIcon.BackgroundTransparency = 1 - value
                end)
                iconSpring:SetTarget(1)
                
                -- Click to restore
                window._floatingIcon.MouseButton1Click:Connect(function()
                    restoreFromIcon()
                end)
            end
        end)
    end
    
    local function restoreFromIcon()
        if isMinimizing then return end
        isMinimizing = true
        
        -- Destroy floating icon
        if window._floatingIcon then
            window._floatingIcon:Destroy()
            window._floatingIcon = nil
        end
        
        -- Show main window
        mainFrame.Visible = true
        
        -- Spring animate back to original
        minimizeSpring:SetTarget(1)
        
        task.delay(0.35, function()
            isMinimizing = false
            mainFrame.Size = savedSize
            mainFrame.Position = savedPosition
            mainFrame.BackgroundTransparency = 0
            topBar.BackgroundTransparency = 0
        end)
    end
    
    minimizeBtn.MouseButton1Click:Connect(minimizeToIcon)
    
    -- Keyboard toggle
    local keyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == window.MinimizeKey then
            if window._floatingIcon then
                restoreFromIcon()
            else
                minimizeToIcon()
            end
        end
    end)
    table.insert(window._signals, keyConnection)
    
    -- ==================== SIDEBAR MENU TOGGLE ====================
    local menuVisible = true
    local menuSpring = SpringEngine.new(1, 150, 16)
    
    menuSpring:OnChange(function(value)
        local targetWidth = (1 * value) - (46 * value)
        contentFrame.Size = UDim2.new(targetWidth, 0, 1, -42)
        contentFrame.Position = UDim2.new(0, 46 * value, 0, 42)
    end)
    
    local function toggleMenu()
        menuVisible = not menuVisible
        if menuVisible then
            contentFrame.Visible = true
            menuSpring:SetTarget(1)
        else
            menuSpring:SetTarget(0)
            task.delay(0.3, function()
                if not menuVisible then
                    contentFrame.Visible = false
                end
            end)
        end
    end
    
    menuToggle.MouseButton1Click:Connect(toggleMenu)
    
    -- ==================== NOTIFICATION HOLDER ====================
    local notifHolder = Utility.Create("Frame", {
        Name = "NotificationHolder",
        Size = UDim2.new(0, 320, 1, 0),
        Position = UDim2.new(1, -336, 0, 0),
        BackgroundTransparency = 1,
        Parent = screenGui,
    })
    Utility.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 10),
        Parent = notifHolder,
    })
    Utility.Create("UIPadding", {
        PaddingBottom = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        Parent = notifHolder,
    })
    
    NotificationSystem.Initialize(notifHolder)
    
    -- ==================== WINDOW METHODS ====================
    function window:AddTab(config)
        config = config or {}
        local tabName = config.Name or "Tab"
        local tabIcon = config.Icon or "circle"
        
        -- Tab button
        local tabBtn = Utility.Create("TextButton", {
            Name = tabName .. "Btn",
            Size = UDim2.new(0, 0, 0, 26),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = ThemeEngine.GetColor("Tab.Background"),
            Text = (tabIcon and tabIcon ~= "") and tabIcon .. " " .. tabName or tabName,
            TextColor3 = ThemeEngine.GetColor("Tab.Text"),
            TextSize = 12,
            Font = Enum.Font.GothamSemibold,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Parent = tabBar,
        })
        Utility.Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = tabBtn })
        Utility.Create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            Parent = tabBtn,
        })
        
        -- Hover
        tabBtn.MouseEnter:Connect(function()
            if window._activeTab and window._activeTab._btn ~= tabBtn then
                local spring = SpringEngine.new(0, 200, 20)
                spring:OnChange(function(value)
                    tabBtn.BackgroundColor3 = Utility.LerpColor(
                        ThemeEngine.GetColor("Tab.Background"),
                        ThemeEngine.GetColor("Tab.Active"),
                        value * 0.3
                    )
                end)
                spring:SetTarget(1)
            end
        end)
        
        tabBtn.MouseLeave:Connect(function()
            if window._activeTab and window._activeTab._btn ~= tabBtn then
                tabBtn.BackgroundColor3 = ThemeEngine.GetColor("Tab.Background")
            end
        end)
        
        -- Tab page
        local tabPage = Utility.Create("Frame", {
            Name = tabName .. "Page",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = pagesHolder,
        })
        
        -- Two columns
        local leftColumn = Utility.Create("ScrollingFrame", {
            Name = "LeftColumn",
            Size = UDim2.new(0.5, -1, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = ThemeEngine.GetColor("Scrollbar.Color"),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Parent = tabPage,
        })
        Utility.Create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 12),
            Parent = leftColumn,
        })
        Utility.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = leftColumn,
        })
        
        -- Column divider
        Utility.Create("Frame", {
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.new(0.5, 0, 0, 0),
            BackgroundColor3 = ThemeEngine.GetColor("Section.Divider"),
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            Parent = tabPage,
        })
        
        local rightColumn = Utility.Create("ScrollingFrame", {
            Name = "RightColumn",
            Size = UDim2.new(0.5, -1, 1, 0),
            Position = UDim2.new(0.5, 1, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = ThemeEngine.GetColor("Scrollbar.Color"),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Parent = tabPage,
        })
        Utility.Create("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 12),
            Parent = rightColumn,
        })
        Utility.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = rightColumn,
        })
        
        local tab = {
            _btn = tabBtn,
            _page = tabPage,
            _leftColumn = leftColumn,
            _rightColumn = rightColumn,
        }
        
        function tab:Activate()
            if window._activeTab then
                window._activeTab._btn.BackgroundColor3 = ThemeEngine.GetColor("Tab.Background")
                window._activeTab._btn.TextColor3 = ThemeEngine.GetColor("Tab.Text")
                window._activeTab._page.Visible = false
            end
            window._activeTab = self
            self._btn.BackgroundColor3 = ThemeEngine.GetColor("Tab.Active")
            self._btn.TextColor3 = ThemeEngine.GetColor("Tab.ActiveText")
            self._page.Visible = true
        end
        
        tabBtn.MouseButton1Click:Connect(function()
            tab:Activate()
        end)
        
        table.insert(window._tabs, tab)
        if #window._tabs == 1 then
            tab:Activate()
        end
        
        local sectionSide = "left"
        
        -- ==================== ADD SECTION ====================
        function tab:AddSection(config)
            config = config or {}
            local sectionName = config.Name or "Section"
            local side = config.Side or sectionSide
            sectionSide = (sectionSide == "left") and "right" or "left"
            local parent = (side == "right") and rightColumn or leftColumn
            
            -- Section frame
            local sectionFrame = Utility.Create("Frame", {
                Name = sectionName .. "Section",
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = ThemeEngine.GetColor("Section.Background"),
                BorderSizePixel = 0,
                Parent = parent,
            })
            Utility.Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = sectionFrame })
            Utility.Create("UIStroke", {
                Color = ThemeEngine.GetColor("Section.Border"),
                Thickness = 1,
                Transparency = ThemeEngine.GetTransparency("Section.Border"),
                Parent = sectionFrame,
            })
            
            -- Content
            local sectionContent = Utility.Create("Frame", {
                Size = UDim2.new(1, -24, 1, -20),
                Position = UDim2.new(0, 12, 0, 10),
                BackgroundTransparency = 1,
                Parent = sectionFrame,
            })
            
            Utility.Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
                Parent = sectionContent,
            })
            
            -- Title
            local titleFrame = Utility.Create("Frame", {
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                Parent = sectionContent,
            })
            
            Utility.Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = ThemeEngine.GetColor("Section.Title"),
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = titleFrame,
            })
            
            -- Divider
            Utility.Create("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, 3),
                BackgroundColor3 = ThemeEngine.GetColor("Section.Divider"),
                BackgroundTransparency = ThemeEngine.GetTransparency("Section.Divider"),
                BorderSizePixel = 0,
                Parent = titleFrame,
            })
            
            -- Spacer
            Utility.Create("Frame", {
                Size = UDim2.new(1, 0, 0, 6),
                BackgroundTransparency = 1,
                Parent = sectionContent,
            })
            
            local section = {}
            section._frame = sectionFrame
            section._content = sectionContent
            
            -- ==================== LABEL ====================
            function section:AddLabel(config)
                config = config or {}
                local text = config.Text or ""
                local color = config.Color or ThemeEngine.GetColor("Element.Description")
                
                local label = Utility.Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = color,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    RichText = true,
                    Parent = sectionContent,
                })
                
                local labelObj = {}
                function labelObj:Set(t) label.Text = t end
                function labelObj:Get() return label.Text end
                return labelObj
            end
            
            -- ==================== BUTTON ====================
            function section:AddButton(config)
                config = config or {}
                local name = config.Name or "Button"
                local callback = config.Callback or function() end
                local style = config.Style or "Primary"
                
                local colorMap = {
                    Primary = ThemeEngine.CurrentTheme.Button.Primary,
                    Secondary = ThemeEngine.CurrentTheme.Button.Secondary,
                    Danger = ThemeEngine.CurrentTheme.Button.Danger,
                    Success = ThemeEngine.CurrentTheme.Button.Success,
                }
                
                local textMap = {
                    Primary = ThemeEngine.CurrentTheme.Button.PrimaryText,
                    Secondary = ThemeEngine.CurrentTheme.Button.SecondaryText,
                    Danger = ThemeEngine.CurrentTheme.Button.DangerText,
                    Success = ThemeEngine.CurrentTheme.Button.SuccessText,
                }
                
                local color = colorMap[style] or colorMap.Primary
                local textColor = textMap[style] or textMap.Primary
                
                local btn = Utility.Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = color,
                    Text = name,
                    TextColor3 = textColor,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Parent = sectionContent,
                })
                Utility.Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
                
                btn.MouseEnter:Connect(function()
                    Utility.Tween(btn, TweenInfo.new(0.12), {
                        BackgroundColor3 = Utility.LerpColor(color, Color3.new(1, 1, 1), 0.15),
                    })
                end)
                
                btn.MouseLeave:Connect(function()
                    Utility.Tween(btn, TweenInfo.new(0.12), {
                        BackgroundColor3 = color,
                    })
                end)
                
                btn.MouseButton1Click:Connect(function()
                    pcall(callback)
                end)
                
                return btn
            end
            
            -- ==================== TOGGLE ====================
            function section:AddToggle(config)
                config = config or {}
                local name = config.Name or "Toggle"
                local defaultValue = config.Default or false
                local callback = config.Callback or function() end
                local value = defaultValue
                
                local row = Utility.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = sectionContent,
                })
                
                Utility.Create("TextLabel", {
                    Size = UDim2.new(0.62, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = ThemeEngine.GetColor("Element.Title"),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row,
                })
                
                local track = Utility.Create("Frame", {
                    Size = UDim2.new(0, 40, 0, 22),
                    Position = UDim2.new(1, -40, 0.5, -11),
                    BackgroundColor3 = value and ThemeEngine.GetColor("Toggle.Active") or ThemeEngine.GetColor("Toggle.Inactive"),
                    BorderSizePixel = 0,
                    Parent = row,
                })
                Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
                
                local thumb = Utility.Create("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, value and 21 or 3, 0.5, -8),
                    BackgroundColor3 = ThemeEngine.GetColor("Toggle.Thumb"),
                    BorderSizePixel = 0,
                    Parent = track,
                })
                Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = thumb })
                Utility.Create("UIStroke", {
                    Color = ThemeEngine.GetColor("Toggle.Shadow"),
                    Thickness = 0.5,
                    Transparency = ThemeEngine.GetTransparency("Toggle.Shadow"),
                    Parent = thumb,
                })
                
                local clickBtn = Utility.Create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = row,
                    ZIndex = 5,
                })
                
                local function setToggle(v)
                    value = v
                    local spring = SpringEngine.new(value and 0 or 1, 250, 22)
                    spring:OnChange(function(progress)
                        local t = value and progress or (1 - progress)
                        track.BackgroundColor3 = Utility.LerpColor(
                            ThemeEngine.GetColor("Toggle.Inactive"),
                            ThemeEngine.GetColor("Toggle.Active"),
                            t
                        )
                        thumb.Position = UDim2.new(0, 3 + 18 * t, 0.5, -8)
                    end)
                    spring:SetTarget(value and 1 or 0)
                    pcall(callback, value)
                end
                
                clickBtn.MouseButton1Click:Connect(function()
                    setToggle(not value)
                end)
                
                local toggleObj = {}
                function toggleObj:Set(v) setToggle(v) end
                function toggleObj:Get() return value end
                return toggleObj
            end
            
            -- ==================== SLIDER ====================
            function section:AddSlider(config)
                config = config or {}
                local name = config.Name or "Slider"
                local min = config.Min or 0
                local max = config.Max or 100
                local default = config.Default or min
                local callback = config.Callback or function() end
                local suffix = config.Suffix or ""
                local value = Utility.Clamp(default, min, max)
                
                local container = Utility.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Parent = sectionContent,
                })
                
                local header = Utility.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundTransparency = 1,
                    Parent = container,
                })
                
                Utility.Create("TextLabel", {
                    Size = UDim2.new(0.6, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = ThemeEngine.GetColor("Element.Title"),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = header,
                })
                
                local valueLabel = Utility.Create("TextLabel", {
                    Size = UDim2.new(0.4, 0, 1, 0),
                    Position = UDim2.new(0.6, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(value) .. suffix,
                    TextColor3 = ThemeEngine.GetColor("Element.Description"),
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = header,
                })
                
                local trackBg = Utility.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 5),
                    Position = UDim2.new(0, 0, 0, 28),
                    BackgroundColor3 = ThemeEngine.GetColor("Slider.Background"),
                    BorderSizePixel = 0,
                    Parent = container,
                })
                Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = trackBg })
                
                local pct = (value - min) / (max - min)
                local fill = Utility.Create("Frame", {
                                        Size = UDim2.new(pct, 0, 1, 0),
                    BackgroundColor3 = ThemeEngine.GetColor("Slider.Fill"),
                    BorderSizePixel = 0,
                    Parent = trackBg,
                })
                Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
                
                local thumb = Utility.Create("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(pct, -8, 0.5, -8),
                    BackgroundColor3 = ThemeEngine.GetColor("Slider.Thumb"),
                    BorderSizePixel = 0,
                    ZIndex = 3,
                    Parent = trackBg,
                })
                Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = thumb })
                Utility.Create("UIStroke", {
                    Color = ThemeEngine.GetColor("Slider.Shadow"),
                    Thickness = 0.5,
                    Transparency = ThemeEngine.GetTransparency("Slider.Shadow"),
                    Parent = thumb,
                })
                
                local dragBtn = Utility.Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0.5, -15),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 5,
                    Parent = trackBg,
                })
                
                local dragging = false
                local function updateSlider(inputX)
                    local absX = trackBg.AbsolutePosition.X
                    local width = trackBg.AbsoluteSize.X
                    local percent = Utility.Clamp((inputX - absX) / width, 0, 1)
                    value = math.floor(min + (max - min) * percent)
                    
                    fill.Size = UDim2.new(percent, 0, 1, 0)
                    thumb.Position = UDim2.new(percent, -8, 0.5, -8)
                    valueLabel.Text = tostring(value) .. suffix
                    pcall(callback, value)
                end
                
                dragBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or
                       input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        updateSlider(input.Position.X)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                       input.UserInputType == Enum.UserInputType.Touch) then
                        updateSlider(input.Position.X)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or
                       input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                
                local sliderObj = {}
                function sliderObj:Set(v)
                    value = Utility.Clamp(v, min, max)
                    local np = (value - min) / (max - min)
                    fill.Size = UDim2.new(np, 0, 1, 0)
                    thumb.Position = UDim2.new(np, -8, 0.5, -8)
                    valueLabel.Text = tostring(value) .. suffix
                end
                function sliderObj:Get() return value end
                return sliderObj
            end
            
            -- ==================== DROPDOWN ====================
            function section:AddDropdown(config)
                config = config or {}
                local name = config.Name or "Dropdown"
                local options = config.Options or {}
                local default = config.Default or (options[1] or "None")
                local callback = config.Callback or function() end
                local value = default
                local isOpen = false
                
                local container = Utility.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 46),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    Parent = sectionContent,
                })
                
                Utility.Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = ThemeEngine.GetColor("Element.Title"),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = container,
                })
                
                local dropBtn = Utility.Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = ThemeEngine.GetColor("Dropdown.Background"),
                    Text = value,
                    TextColor3 = ThemeEngine.GetColor("Dropdown.Text"),
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Parent = container,
                })
                Utility.Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = dropBtn })
                Utility.Create("UIStroke", {
                    Color = ThemeEngine.GetColor("Dropdown.Border"),
                    Thickness = 1,
                    Transparency = ThemeEngine.GetTransparency("Dropdown.Border"),
                    Parent = dropBtn,
                })
                
                local arrow = Utility.Create("TextLabel", {
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -22, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▾",
                    TextColor3 = ThemeEngine.GetColor("Dropdown.Arrow"),
                    TextSize = 11,
                    Font = Enum.Font.GothamBold,
                    Parent = dropBtn,
                })
                
                local optionsList = Utility.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 3),
                    BackgroundColor3 = ThemeEngine.GetColor("Dropdown.Background"),
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 50,
                    Parent = dropBtn,
                })
                Utility.Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = optionsList })
                Utility.Create("UIStroke", {
                    Color = ThemeEngine.GetColor("Dropdown.Border"),
                    Thickness = 1,
                    Transparency = ThemeEngine.GetTransparency("Dropdown.Border"),
                    ZIndex = 51,
                    Parent = optionsList,
                })
                Utility.Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = optionsList,
                })
                
                for _, option in ipairs(options) do
                    local optionBtn = Utility.Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 24),
                        BackgroundColor3 = ThemeEngine.GetColor("Dropdown.Background"),
                        Text = option,
                        TextColor3 = ThemeEngine.GetColor("Dropdown.Text"),
                        TextSize = 11,
                        Font = Enum.Font.Gotham,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                        ZIndex = 52,
                        Parent = optionsList,
                    })
                    
                    optionBtn.MouseEnter:Connect(function()
                        Utility.Tween(optionBtn, TweenInfo.new(0.08), {
                            BackgroundColor3 = ThemeEngine.GetColor("Dropdown.Hover"),
                        })
                    end)
                    
                    optionBtn.MouseLeave:Connect(function()
                        Utility.Tween(optionBtn, TweenInfo.new(0.08), {
                            BackgroundColor3 = ThemeEngine.GetColor("Dropdown.Background"),
                        })
                    end)
                    
                    optionBtn.MouseButton1Click:Connect(function()
                        value = option
                        dropBtn.Text = option
                        isOpen = false
                        Utility.Tween(optionsList, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, 0) })
                        task.delay(0.16, function()
                            optionsList.Visible = false
                            container.Size = UDim2.new(1, 0, 0, 46)
                        end)
                        Utility.Tween(arrow, TweenInfo.new(0.15), { Rotation = 0 })
                        pcall(callback, value)
                    end)
                end
                
                dropBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        optionsList.Visible = true
                        local h = #options * 24
                        Utility.Tween(optionsList, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                            Size = UDim2.new(1, 0, 0, h),
                        })
                        container.Size = UDim2.new(1, 0, 0, 46 + h + 6)
                        Utility.Tween(arrow, TweenInfo.new(0.15), { Rotation = 180 })
                    else
                        Utility.Tween(optionsList, TweenInfo.new(0.12), { Size = UDim2.new(1, 0, 0, 0) })
                        task.delay(0.13, function()
                            optionsList.Visible = false
                            container.Size = UDim2.new(1, 0, 0, 46)
                        end)
                        Utility.Tween(arrow, TweenInfo.new(0.12), { Rotation = 0 })
                    end
                end)
                
                local dropdownObj = {}
                function dropdownObj:Set(v) value = v; dropBtn.Text = v end
                function dropdownObj:Get() return value end
                return dropdownObj
            end
            
            -- ==================== TEXTBOX ====================
            function section:AddTextbox(config)
                config = config or {}
                local name = config.Name or "Textbox"
                local placeholder = config.Placeholder or ""
                local callback = config.Callback or function() end
                local multiline = config.MultiLine or false
                
                local container = Utility.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, multiline and 64 or 46),
                    BackgroundTransparency = 1,
                    Parent = sectionContent,
                })
                
                Utility.Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = ThemeEngine.GetColor("Element.Title"),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = container,
                })
                
                local textbox = Utility.Create("TextBox", {
                    Size = UDim2.new(1, 0, 0, multiline and 42 or 26),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = ThemeEngine.GetColor("Textbox.Background"),
                    Text = "",
                    PlaceholderText = placeholder,
                    TextColor3 = ThemeEngine.GetColor("Textbox.Text"),
                    PlaceholderColor3 = ThemeEngine.GetColor("Textbox.Placeholder"),
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    BorderSizePixel = 0,
                    ClearTextOnFocus = false,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
                    TextWrapped = multiline,
                    MultiLine = multiline,
                    Parent = container,
                })
                Utility.Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = textbox })
                Utility.Create("UIStroke", {
                    Color = ThemeEngine.GetColor("Textbox.Border"),
                    Thickness = 1,
                    Transparency = ThemeEngine.GetTransparency("Textbox.Border"),
                    Parent = textbox,
                })
                Utility.Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                    Parent = textbox,
                })
                
                textbox.FocusLost:Connect(function(enterPressed)
                    pcall(callback, textbox.Text)
                end)
                
                local textboxObj = {}
                function textboxObj:Set(t) textbox.Text = t end
                function textboxObj:Get() return textbox.Text end
                return textboxObj
            end
            
            -- ==================== DIVIDER ====================
            function section:AddDivider(text)
                local dividerFrame = Utility.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Parent = sectionContent,
                })
                
                if text and text ~= "" then
                    Utility.Create("TextLabel", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = text,
                        TextColor3 = ThemeEngine.GetColor("Element.Description"),
                        TextSize = 10,
                        Font = Enum.Font.GothamBold,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        Parent = dividerFrame,
                    })
                end
                
                Utility.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    BackgroundColor3 = ThemeEngine.GetColor("Section.Divider"),
                    BackgroundTransparency = 0.7,
                    BorderSizePixel = 0,
                    Parent = dividerFrame,
                })
            end
            
            return section
        end
        
        return tab
    end
    
    -- ==================== WINDOW: NOTIFICATION ====================
    function window:Notify(config)
        NotificationSystem.Create(config)
    end
    
    -- ==================== WINDOW: DIALOG ====================
    function window:Dialog(config)
        DialogSystem.Show(window, config)
    end
    
    -- ==================== WINDOW: SET THEME ====================
    function window:SetTheme(themeName)
        ThemeEngine.SetTheme(themeName)
        window.Theme = ThemeEngine.CurrentTheme
        -- Note: Existing elements won't auto-update theme
        -- User should recreate window for theme change
    end
    
    -- ==================== WINDOW: DESTROY ====================
    function window:Destroy()
        -- Disconnect signals
        for _, signal in ipairs(window._signals) do
            pcall(function() signal:Disconnect() end)
        end
        
        -- Destroy floating icon
        if window._floatingIcon then
            window._floatingIcon:Destroy()
            window._floatingIcon = nil
        end
        
        -- Destroy UI
        if screenGui and screenGui.Parent then
            screenGui:Destroy()
        end
        
        -- Clean animation controller
        window._animController:Destroy()
        
        -- Remove from library
        for i, win in ipairs(Library.Windows) do
            if win == window then
                table.remove(Library.Windows, i)
                break
            end
        end
        
        if Library.ActiveWindow == window then
            Library.ActiveWindow = nil
        end
    end
    
    -- ==================== STORE & RETURN ====================
    table.insert(Library.Windows, window)
    Library.ActiveWindow = window
    
    return window
end

-- ============================================================
-- SECTION 10: RETURN LIBRARY
-- ============================================================
return Library
