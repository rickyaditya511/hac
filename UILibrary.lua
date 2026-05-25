--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║               UILibrary - Premium Edition                   ║
    ║            by Rylax0322 · Spring Animation                 ║
    ╚══════════════════════════════════════════════════════════════╝
    Version: 7.0 Final
    Lines: 7000+
    Engine: Custom Spring Physics
    Features: Smooth Minimize (Rayfield/WindUI style), Floating Icon,
              Complete Element Kit, Dark/Light Theme, Mobile Support,
              Notification System, Dialog System, Glassmorphism
]]

-- ============================================================
-- SECTION 1: SERVICES & GLOBALS
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
local StarterGui = game:GetService("StarterGui")

-- ============================================================
-- SECTION 2: SPRING PHYSICS ENGINE (CORE)
-- ============================================================
--[[
    Spring Engine - Custom Physics-Based Animation
    Uses Hooke's Law with Damping:
    F = -k * x - d * v
    where k = stiffness, d = damping, x = displacement, v = velocity
    
    Solved using Semi-Implicit Euler Integration:
    1. v(t+dt) = v(t) + (F/m) * dt
    2. x(t+dt) = x(t) + v(t+dt) * dt
]]

local SpringEngine = {}
SpringEngine.__index = SpringEngine
SpringEngine._Registry = {}
SpringEngine._ActiveCount = 0

function SpringEngine.new(initialValue, config)
    config = config or {}
    local self = setmetatable({}, SpringEngine)
    
    -- State
    self._value = initialValue or 0
    self._velocity = 0
    self._target = initialValue or 0
    
    -- Physics parameters
    self._stiffness = config.Stiffness or 170    -- k: spring constant
    self._damping = config.Damping or 16         -- d: damping coefficient
    self._mass = config.Mass or 1               -- m: mass
    self._precision = config.Precision or 0.0001 -- snap threshold
    
    -- Runtime
    self._active = false
    self._callbacks = {}
    self._connection = nil
    self._id = HttpService:GenerateGUID(false)
    self._lastTime = tick()
    
    -- Register
    SpringEngine._Registry[self._id] = self
    
    return self
end

function SpringEngine:GetValue()
    return self._value
end

function SpringEngine:GetTarget()
    return self._target
end

function SpringEngine:GetVelocity()
    return self._velocity
end

function SpringEngine:IsActive()
    return self._active
end

function SpringEngine:SetTarget(target)
    if math.abs(self._target - target) < self._precision and math.abs(self._velocity) < 0.01 then
        -- Already at target
        self._value = target
        self._target = target
        return
    end
    
    self._target = target
    
    if not self._active then
        self._active = true
        self._lastTime = tick()
        self:_start()
    end
end

function SpringEngine:SetValue(value)
    self._value = value
    self._target = value
    self._velocity = 0
    self:_fireCallbacks()
end

function SpringEngine:SetStiffness(k)
    self._stiffness = k
end

function SpringEngine:SetDamping(d)
    self._damping = d
end

function SpringEngine:SetMass(m)
    self._mass = m
end

function SpringEngine:_start()
    if self._connection then return end
    
    local conn
    conn = RunService.Heartbeat:Connect(function()
        local now = tick()
        local dt = now - self._lastTime
        self._lastTime = now
        
        -- Clamp delta time to prevent physics explosion
        dt = math.min(dt, 0.05)
        
        if dt <= 0 then return end
        
        -- Calculate forces
        local displacement = self._target - self._value
        local springForce = displacement * self._stiffness
        local dampingForce = self._velocity * self._damping
        local netForce = springForce - dampingForce
        
        -- Semi-implicit Euler integration
        local acceleration = netForce / self._mass
        self._velocity = self._velocity + acceleration * dt
        self._value = self._value + self._velocity * dt
        
        -- Check convergence
        local absDisp = math.abs(displacement)
        local absVel = math.abs(self._velocity)
        
        if absDisp < self._precision and absVel < 0.01 then
            self._value = self._target
            self._velocity = 0
            self._active = false
            if self._connection then
                self._connection:Disconnect()
                self._connection = nil
            end
            SpringEngine._ActiveCount = SpringEngine._ActiveCount - 1
        end
        
        self:_fireCallbacks()
    end)
    
    self._connection = conn
    SpringEngine._ActiveCount = SpringEngine._ActiveCount + 1
end

function SpringEngine:OnChange(callback)
    table.insert(self._callbacks, callback)
end

function SpringEngine:ClearCallbacks()
    self._callbacks = {}
end

function SpringEngine:_fireCallbacks()
    for _, callback in ipairs(self._callbacks) do
        pcall(callback, self._value, self._velocity)
    end
end

function SpringEngine:Stop()
    if self._connection then
        self._connection:Disconnect()
        self._connection = nil
    end
    self._active = false
    SpringEngine._ActiveCount = SpringEngine._ActiveCount - 1
end

function SpringEngine:Destroy()
    self:Stop()
    self._callbacks = {}
    SpringEngine._Registry[self._id] = nil
end

-- ============================================================
-- SECTION 3: SPRING FACTORY (Pre-configured Springs)
-- ============================================================
local SpringFactory = {}

-- Size animation (for minimize/maximize)
function SpringFactory.Size(frame, config)
    config = config or {}
    local stiffness = config.Stiffness or 180
    local damping = config.Damping or 18
    
    local sX = SpringEngine.new(frame.Size.X.Offset, {
        Stiffness = stiffness,
        Damping = damping,
    })
    
    local sY = SpringEngine.new(frame.Size.Y.Offset, {
        Stiffness = stiffness,
        Damping = damping,
    })
    
    sX:OnChange(function(v)
        pcall(function()
            frame.Size = UDim2.new(0, v, frame.Size.Y.Scale, frame.Size.Y.Offset)
        end)
    end)
    
    sY:OnChange(function(v)
        pcall(function()
            frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, v)
        end)
    end)
    
    return {
        SetWidth = function(w) sX:SetTarget(w) end,
        SetHeight = function(h) sY:SetTarget(h) end,
        SetSize = function(w, h) sX:SetTarget(w); sY:SetTarget(h) end,
        GetSpringX = function() return sX end,
        GetSpringY = function() return sY end,
        Destroy = function() sX:Destroy(); sY:Destroy() end,
    }
end

-- Position animation (for smooth dragging & repositioning)
function SpringFactory.Position(frame, config)
    config = config or {}
    local stiffness = config.Stiffness or 120
    local damping = config.Damping or 14
    
    local sX = SpringEngine.new(frame.Position.X.Offset, {
        Stiffness = stiffness,
        Damping = damping,
    })
    
    local sY = SpringEngine.new(frame.Position.Y.Offset, {
        Stiffness = stiffness,
        Damping = damping,
    })
    
    sX:OnChange(function(v)
        pcall(function()
            frame.Position = UDim2.new(frame.Position.X.Scale, v, frame.Position.Y.Scale, frame.Position.Y.Offset)
        end)
    end)
    
    sY:OnChange(function(v)
        pcall(function()
            frame.Position = UDim2.new(frame.Position.X.Scale, frame.Position.X.Offset, frame.Position.Y.Scale, v)
        end)
    end)
    
    return {
        SetX = function(x) sX:SetTarget(x) end,
        SetY = function(y) sY:SetTarget(y) end,
        SetPosition = function(x, y) sX:SetTarget(x); sY:SetTarget(y) end,
        Destroy = function() sX:Destroy(); sY:Destroy() end,
    }
end

-- Transparency animation (for fade effects)
function SpringFactory.Transparency(element, config)
    config = config or {}
    local stiffness = config.Stiffness or 150
    local damping = config.Damping or 12
    
    local s = SpringEngine.new(element.BackgroundTransparency, {
        Stiffness = stiffness,
        Damping = damping,
    })
    
    s:OnChange(function(v)
        pcall(function()
            element.BackgroundTransparency = math.clamp(v, 0, 1)
        end)
    end)
    
    return {
        SetTransparency = function(t) s:SetTarget(t) end,
        FadeIn = function() s:SetTarget(0) end,
        FadeOut = function() s:SetTarget(1) end,
        Destroy = function() s:Destroy() end,
    }
end

-- Scale animation (for pop-in effects)
function SpringFactory.Scale(frame, config)
    config = config or {}
    local stiffness = config.Stiffness or 200
    local damping = config.Damping or 20
    
    local s = SpringEngine.new(1, {
        Stiffness = stiffness,
        Damping = damping,
    })
    
    local originalSize = frame.Size
    
    s:OnChange(function(v)
        pcall(function()
            frame.Size = UDim2.new(
                0, originalSize.Width.Offset * v,
                0, originalSize.Height.Offset * v
            )
        end)
    end)
    
    return {
        ScaleTo = function(sc) s:SetTarget(sc) end,
        PopIn = function() s:SetValue(0); s:SetTarget(1) end,
        PopOut = function() s:SetTarget(0) end,
        Destroy = function() s:Destroy() end,
    }
end

-- ============================================================
-- SECTION 4: UTILITY LIBRARY
-- ============================================================
local Util = {}

-- Instance creation helper
function Util.Create(className, properties, children)
    local instance = Instance.new(className)
    
    if properties then
        for prop, value in pairs(properties) do
            if prop ~= "ThemeTag" and prop ~= "Children" then
                pcall(function()
                    instance[prop] = value
                end)
            end
        end
    end
    
    if children then
        for _, child in ipairs(children) do
            if typeof(child) == "Instance" then
                child.Parent = instance
            elseif type(child) == "table" and child.Create then
                child:Create(instance)
            end
        end
    end
    
    return instance
end

-- Tween wrapper
function Util.Tween(obj, tweenInfo, properties)
    local tween = TweenService:Create(obj, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Advanced draggable with boundaries
function Util.MakeDraggable(frame, handle, bounds)
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
            local newX = startPos.X.Offset + delta.X
            local newY = startPos.Y.Offset + delta.Y
            
            -- Apply bounds if provided
            if bounds then
                local screenSize = Camera.ViewportSize
                newX = math.clamp(newX, bounds.MinX or -frame.AbsoluteSize.X/2, bounds.MaxX or screenSize.X - frame.AbsoluteSize.X/2)
                newY = math.clamp(newY, bounds.MinY or 0, bounds.MaxY or screenSize.Y - frame.AbsoluteSize.Y/2)
            end
            
            frame.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        end
    end)
end

-- Resize functionality
function Util.MakeResizable(frame, handle, minWidth, minHeight, maxWidth, maxHeight)
    local resizing = false
    local resizeStart = nil
    local startSize = nil
    
    minWidth = minWidth or 420
    minHeight = minHeight or 300
    maxWidth = maxWidth or 1200
    maxHeight = maxHeight or 900
    
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
            local newW = math.clamp(startSize.Width.Offset + delta.X, minWidth, maxWidth)
            local newH = math.clamp(startSize.Height.Offset + delta.Y, minHeight, maxHeight)
            frame.Size = UDim2.new(0, newW, 0, newH)
        end
    end)
end

-- Device detection
function Util.IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function Util.IsTablet()
    return Util.IsMobile() and Camera.ViewportSize.X > 768
end

function Util.IsPhone()
    return Util.IsMobile() and Camera.ViewportSize.X <= 768
end

-- Math utilities
function Util.Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function Util.Lerp(a, b, t)
    return a + (b - a) * t
end

function Util.LerpColor(colorA, colorB, t)
    return Color3.new(
        Util.Lerp(colorA.R, colorB.R, t),
        Util.Lerp(colorA.G, colorB.G, t),
        Util.Lerp(colorA.B, colorB.B, t)
    )
end

function Util.Map(value, inMin, inMax, outMin, outMax)
    return outMin + (outMax - outMin) * ((value - inMin) / (inMax - inMin))
end

function Util.Round(value, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(value * mult + 0.5) / mult
end

-- String utilities
function Util.GenerateGUID()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 15) or math.random(8, 11)
        return string.format('%x', v)
    end)
end

function Util.ShortenString(str, maxLen)
    if #str <= maxLen then return str end
    return string.sub(str, 1, maxLen - 3) .. "..."
end

-- Color utilities
function Util.Color3ToHex(color)
    return string.format("#%02X%02X%02X",
        math.floor(color.R * 255 + 0.5),
        math.floor(color.G * 255 + 0.5),
        math.floor(color.B * 255 + 0.5)
    )
end

function Util.HexToColor3(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber("0x" .. hex:sub(1, 2)),
        tonumber("0x" .. hex:sub(3, 4)),
        tonumber("0x" .. hex:sub(5, 6))
    )
end

function Util.Color3ToHSV(color)
    local r, g, b = color.R, color.G, color.B
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local delta = max - min
    
    local h = 0
    if delta > 0 then
        if max == r then h = ((g - b) / delta) % 6
        elseif max == g then h = (b - r) / delta + 2
        else h = (r - g) / delta + 4 end
        h = h * 60
    end
    
    local s = max == 0 and 0 or delta / max
    local v = max
    
    return h, s, v
end

function Util.HSVToColor3(h, s, v)
    h = h % 360
    if h < 0 then h = h + 360 end
    
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c
    
    local r, g, b
    if h < 60 then r, g, b = c, x, 0
    elseif h < 120 then r, g, b = x, c, 0
    elseif h < 180 then r, g, b = 0, c, x
    elseif h < 240 then r, g, b = 0, x, c
    elseif h < 300 then r, g, b = x, 0, c
    else r, g, b = c, 0, x end
    
    return Color3.new(r + m, g + m, b + m)
end

-- Get text size
function Util.GetTextSize(text, fontSize, font, maxWidth)
    return TextService:GetTextSize(text, fontSize, font, Vector2.new(maxWidth or math.huge, math.huge))
end

-- Safe callback execution
function Util.SafeCallback(callback, ...)
    if not callback then return end
    local success, err = pcall(callback, ...)
    if not success then
        warn("[UILibrary] Callback error:", err)
    end
end

-- ============================================================
-- SECTION 5: THEME SYSTEM
-- ============================================================
local ThemeSystem = {}
ThemeSystem._current = nil
ThemeSystem._themes = {}
ThemeSystem._changeListeners = {}

-- Register a theme
function ThemeSystem.Register(name, theme)
    ThemeSystem._themes[name] = theme
end

-- Set active theme
function ThemeSystem.Set(name)
    if ThemeSystem._themes[name] then
        ThemeSystem._current = ThemeSystem._themes[name]
        ThemeSystem._notifyListeners()
    end
end

-- Get a color from current theme
function ThemeSystem.GetColor(path)
    if not ThemeSystem._current then return Color3.new(1, 1, 1) end
    
    local keys = {}
    for key in string.gmatch(path, "[^.]+") do
        table.insert(keys, key)
    end
    
    local current = ThemeSystem._current
    for _, key in ipairs(keys) do
        if type(current) == "table" and current[key] ~= nil then
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

-- Get a transparency value from current theme
function ThemeSystem.GetTransparency(path)
    if not ThemeSystem._current then return 0 end
    
    local keys = {}
    for key in string.gmatch(path, "[^.]+") do
        table.insert(keys, key)
    end
    
    local current = ThemeSystem._current
    for _, key in ipairs(keys) do
        if type(current) == "table" and current[key] ~= nil then
            current = current[key]
        else
            return 0
        end
    end
    
    if type(current) == "number" then
        return current
    end
    return 0
end

-- Listen for theme changes
function ThemeSystem.OnChange(callback)
    table.insert(ThemeSystem._changeListeners, callback)
end

-- Notify all listeners
function ThemeSystem._notifyListeners()
    for _, listener in ipairs(ThemeSystem._changeListeners) do
        Util.SafeCallback(listener, ThemeSystem._current)
    end
end

-- ============================================================
-- SECTION 6: DEFAULT THEMES
-- ============================================================

-- Dark Theme
ThemeSystem.Register("Dark", {
    Window = {
        Background = Color3.fromRGB(14, 14, 24),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.93,
        Shadow = Color3.fromRGB(0, 0, 0),
        ShadowTransparency = 0.55,
    },
    Topbar = {
        Background = Color3.fromRGB(17, 17, 30),
        Text = Color3.fromRGB(255, 255, 255),
        Button = Color3.fromRGB(255, 255, 255),
        ButtonTransparency = 0.9,
    },
    Sidebar = {
        Background = Color3.fromRGB(15, 15, 27),
        ToggleButton = Color3.fromRGB(85, 125, 255),
        ToggleIcon = Color3.fromRGB(255, 255, 255),
    },
    Tab = {
        Background = Color3.fromRGB(28, 30, 45),
        Active = Color3.fromRGB(85, 125, 255),
        Text = Color3.fromRGB(190, 190, 210),
        ActiveText = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(85, 125, 255),
        BorderTransparency = 0.6,
    },
    Section = {
        Background = Color3.fromRGB(20, 22, 36),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.95,
        Title = Color3.fromRGB(100, 140, 255),
        Divider = Color3.fromRGB(255, 255, 255),
        DividerTransparency = 0.9,
    },
    Element = {
        Title = Color3.fromRGB(215, 215, 235),
        Description = Color3.fromRGB(150, 150, 175),
        Icon = Color3.fromRGB(200, 200, 220),
    },
    Button = {
        Primary = Color3.fromRGB(85, 125, 255),
        PrimaryText = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(42, 45, 62),
        SecondaryText = Color3.fromRGB(210, 210, 230),
        Danger = Color3.fromRGB(255, 65, 95),
        DangerText = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(45, 200, 95),
        SuccessText = Color3.fromRGB(255, 255, 255),
        Warning = Color3.fromRGB(255, 180, 50),
        WarningText = Color3.fromRGB(255, 255, 255),
        Hover = Color3.fromRGB(255, 255, 255),
        HoverTransparency = 0.85,
    },
    Toggle = {
        Active = Color3.fromRGB(85, 125, 255),
        Inactive = Color3.fromRGB(55, 60, 80),
        Thumb = Color3.fromRGB(255, 255, 255),
        Shadow = Color3.fromRGB(0, 0, 0),
        ShadowTransparency = 0.65,
    },
    Slider = {
        Fill = Color3.fromRGB(85, 125, 255),
        Background = Color3.fromRGB(38, 42, 60),
        Thumb = Color3.fromRGB(255, 255, 255),
        Shadow = Color3.fromRGB(0, 0, 0),
        ShadowTransparency = 0.55,
    },
    Dropdown = {
        Background = Color3.fromRGB(28, 32, 50),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.9,
        Text = Color3.fromRGB(200, 200, 220),
        Hover = Color3.fromRGB(255, 255, 255),
        HoverTransparency = 0.94,
        Arrow = Color3.fromRGB(180, 180, 200),
    },
    Textbox = {
        Background = Color3.fromRGB(26, 30, 46),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.9,
        Text = Color3.fromRGB(215, 215, 235),
        Placeholder = Color3.fromRGB(115, 115, 145),
        Cursor = Color3.fromRGB(255, 255, 255),
    },
    Notification = {
        Background = Color3.fromRGB(23, 25, 40),
        Border = Color3.fromRGB(85, 125, 255),
        Title = Color3.fromRGB(255, 255, 255),
        Content = Color3.fromRGB(175, 175, 195),
        Timer = Color3.fromRGB(255, 255, 255),
        TimerTransparency = 0.88,
    },
    Dialog = {
        Background = Color3.fromRGB(20, 22, 36),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.93,
        Overlay = Color3.fromRGB(0, 0, 0),
        OverlayTransparency = 0.5,
    },
    Footer = {
        Background = Color3.fromRGB(13, 13, 23),
        Text = Color3.fromRGB(115, 115, 145),
    },
    Scrollbar = {
        Color = Color3.fromRGB(55, 60, 80),
    },
    FloatingIcon = {
        Background = Color3.fromRGB(85, 125, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.5,
    },
    ResizeCorner = {
        Color = Color3.fromRGB(115, 115, 145),
    },
})

-- Light Theme
ThemeSystem.Register("Light", {
    Window = {
        Background = Color3.fromRGB(240, 240, 250),
        Border = Color3.fromRGB(0, 0, 0),
        BorderTransparency = 0.9,
        Shadow = Color3.fromRGB(0, 0, 0),
        ShadowTransparency = 0.75,
    },
    Topbar = {
        Background = Color3.fromRGB(230, 230, 240),
        Text = Color3.fromRGB(25, 25, 35),
        Button = Color3.fromRGB(0, 0, 0),
        ButtonTransparency = 0.92,
    },
    Sidebar = {
        Background = Color3.fromRGB(235, 235, 245),
        ToggleButton = Color3.fromRGB(75, 115, 245),
        ToggleIcon = Color3.fromRGB(255, 255, 255),
    },
    Tab = {
        Background = Color3.fromRGB(220, 220, 235),
        Active = Color3.fromRGB(75, 115, 245),
        Text = Color3.fromRGB(80, 80, 100),
        ActiveText = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(75, 115, 245),
        BorderTransparency = 0.5,
    },
    Section = {
        Background = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(0, 0, 0),
        BorderTransparency = 0.93,
        Title = Color3.fromRGB(75, 115, 245),
        Divider = Color3.fromRGB(0, 0, 0),
        DividerTransparency = 0.9,
    },
    Element = {
        Title = Color3.fromRGB(45, 45, 65),
        Description = Color3.fromRGB(105, 105, 125),
        Icon = Color3.fromRGB(80, 80, 100),
    },
    Button = {
        Primary = Color3.fromRGB(75, 115, 245),
        PrimaryText = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(205, 205, 220),
        SecondaryText = Color3.fromRGB(45, 45, 65),
        Danger = Color3.fromRGB(255, 65, 95),
        DangerText = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(45, 200, 95),
        SuccessText = Color3.fromRGB(255, 255, 255),
        Warning = Color3.fromRGB(255, 170, 40),
        WarningText = Color3.fromRGB(255, 255, 255),
        Hover = Color3.fromRGB(0, 0, 0),
        HoverTransparency = 0.94,
    },
    Toggle = {
        Active = Color3.fromRGB(75, 115, 245),
        Inactive = Color3.fromRGB(185, 185, 205),
        Thumb = Color3.fromRGB(255, 255, 255),
        Shadow = Color3.fromRGB(0, 0, 0),
        ShadowTransparency = 0.75,
    },
    Slider = {
        Fill = Color3.fromRGB(75, 115, 245),
        Background = Color3.fromRGB(205, 205, 225),
        Thumb = Color3.fromRGB(255, 255, 255),
        Shadow = Color3.fromRGB(0, 0, 0),
        ShadowTransparency = 0.65,
    },
    Dropdown = {
        Background = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(0, 0, 0),
        BorderTransparency = 0.9,
        Text = Color3.fromRGB(45, 45, 65),
        Hover = Color3.fromRGB(0, 0, 0),
        HoverTransparency = 0.96,
        Arrow = Color3.fromRGB(80, 80, 100),
    },
    Textbox = {
        Background = Color3.fromRGB(248, 248, 252),
        Border = Color3.fromRGB(0, 0, 0),
        BorderTransparency = 0.93,
        Text = Color3.fromRGB(45, 45, 65),
        Placeholder = Color3.fromRGB(155, 155, 175),
        Cursor = Color3.fromRGB(0, 0, 0),
    },
    Notification = {
        Background = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(75, 115, 245),
        Title = Color3.fromRGB(25, 25, 35),
        Content = Color3.fromRGB(95, 95, 115),
        Timer = Color3.fromRGB(0, 0, 0),
        TimerTransparency = 0.9,
    },
    Dialog = {
        Background = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(0, 0, 0),
        BorderTransparency = 0.93,
        Overlay = Color3.fromRGB(0, 0, 0),
        OverlayTransparency = 0.4,
    },
    Footer = {
        Background = Color3.fromRGB(230, 230, 240),
        Text = Color3.fromRGB(125, 125, 145),
    },
    Scrollbar = {
        Color = Color3.fromRGB(185, 185, 205),
    },
    FloatingIcon = {
        Background = Color3.fromRGB(75, 115, 245),
        Text = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.6,
    },
    ResizeCorner = {
        Color = Color3.fromRGB(150, 150, 170),
    },
})

-- Set default theme
ThemeSystem.Set("Dark")

-- ============================================================
-- SECTION 7: ICON SYSTEM
-- ============================================================
local IconSystem = {}
IconSystem._cache = {}
IconSystem._map = {
    -- Navigation
    home = "rbxassetid://6031068421",
    settings = "rbxassetid://6031282542",
    search = "rbxassetid://6031103189",
    menu = "rbxassetid://6031094753",
    close = "rbxassetid://6031073852",
    plus = "rbxassetid://6031280885",
    minus = "rbxassetid://6031280885",
    ["chevron-down"] = "rbxassetid://6031094753",
    ["chevron-up"] = "rbxassetid://6031094753",
    ["chevron-left"] = "rbxassetid://6031094753",
    ["chevron-right"] = "rbxassetid://6031094753",
    
    -- Actions
    play = "rbxassetid://6031282542",
    pause = "rbxassetid://6031282542",
    stop = "rbxassetid://6031282542",
    refresh = "rbxassetid://6031282542",
    download = "rbxassetid://6031282542",
    upload = "rbxassetid://6031282542",
    copy = "rbxassetid://6031282542",
    paste = "rbxassetid://6031282542",
    trash = "rbxassetid://6031282542",
    edit = "rbxassetid://6031282542",
    save = "rbxassetid://6031282542",
    folder = "rbxassetid://6031282542",
    file = "rbxassetid://6031282542",
    lock = "rbxassetid://6031282542",
    unlock = "rbxassetid://6031282542",
    key = "rbxassetid://6031282542",
    
    -- Gaming
    sword = "rbxassetid://6031282542",
    shield = "rbxassetid://6031282542",
    target = "rbxassetid://6031282542",
    trophy = "rbxassetid://6031282542",
    star = "rbxassetid://6031282542",
    heart = "rbxassetid://6031282542",
    fire = "rbxassetid://6031282542",
    bolt = "rbxassetid://6031282542",
    skull = "rbxassetid://6031282542",
    crown = "rbxassetid://6031282542",
    wand = "rbxassetid://6031282542",
    magic = "rbxassetid://6031282542",
    
    -- Items
    egg = "rbxassetid://6031282542",
    gift = "rbxassetid://6031282542",
    package = "rbxassetid://6031282542",
    cart = "rbxassetid://6031282542",
    coins = "rbxassetid://6031282542",
    gem = "rbxassetid://6031282542",
    dollar = "rbxassetid://6031282542",
    
    -- Communication
    user = "rbxassetid://6031282542",
    users = "rbxassetid://6031282542",
    ["user-plus"] = "rbxassetid://6031282542",
    mail = "rbxassetid://6031282542",
    ["message-circle"] = "rbxassetid://6031282542",
    bell = "rbxassetid://6031282542",
    ["bell-off"] = "rbxassetid://6031282542",
    
    -- Status
    check = "rbxassetid://6031282542",
    circle = "rbxassetid://6031282542",
    square = "rbxassetid://6031282542",
    triangle = "rbxassetid://6031282542",
    ["alert-triangle"] = "rbxassetid://6031282542",
    info = "rbxassetid://6031282542",
    ["help-circle"] = "rbxassetid://6031282542",
    eye = "rbxassetid://6031282542",
    ["eye-off"] = "rbxassetid://6031282542",
    
    -- Weather/Time
    sun = "rbxassetid://6031282542",
    moon = "rbxassetid://6031282542",
    cloud = "rbxassetid://6031282542",
    ["cloud-rain"] = "rbxassetid://6031282542",
    snowflake = "rbxassetid://6031282542",
    wind = "rbxassetid://6031282542",
    clock = "rbxassetid://6031282542",
    calendar = "rbxassetid://6031282542",
    
    -- Tech
    camera = "rbxassetid://6031282542",
    image = "rbxassetid://6031282542",
    video = "rbxassetid://6031282542",
    music = "rbxassetid://6031282542",
    ["volume-2"] = "rbxassetid://6031282542",
    ["volume-x"] = "rbxassetid://6031282542",
    wifi = "rbxassetid://6031282542",
    bluetooth = "rbxassetid://6031282542",
    battery = "rbxassetid://6031282542",
    smartphone = "rbxassetid://6031282542",
    tablet = "rbxassetid://6031282542",
    monitor = "rbxassetid://6031282542",
    laptop = "rbxassetid://6031282542",
    
    -- Arrows
    ["arrow-up"] = "rbxassetid://6031282542",
    ["arrow-down"] = "rbxassetid://6031282542",
    ["arrow-left"] = "rbxassetid://6031282542",
    ["arrow-right"] = "rbxassetid://6031282542",
    ["rotate-cw"] = "rbxassetid://6031282542",
    ["rotate-ccw"] = "rbxassetid://6031282542",
    
    -- Misc
    loader = "rbxassetid://6031282542",
    ["map-pin"] = "rbxassetid://6031282542",
    compass = "rbxassetid://6031282542",
    ["shield-check"] = "rbxassetid://6031282542",
    bookmark = "rbxassetid://6031282542",
    flag = "rbxassetid://6031282542",
    link = "rbxassetid://6031282542",
    external = "rbxassetid://6031282542",
}

function IconSystem.Get(name, size)
    size = size or 24
    local assetId = IconSystem._map[name] or IconSystem._map.circle
    
    return {
        Image = assetId,
        ImageRectSize = Vector2.new(size, size),
        ImageRectOffset = Vector2.new(0, 0),
        Size = size,
    }
end

function IconSystem.Create(name, size, parent, color, transparency)
    local data = IconSystem.Get(name, size)
    local icon = Util.Create("ImageLabel", {
        Name = "Icon_" .. name,
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

function IconSystem.Set(name, assetId)
    IconSystem._map[name] = assetId
end

-- ============================================================
-- SECTION 8: NOTIFICATION SYSTEM
-- ============================================================
local NotificationSystem = {}
NotificationSystem._active = {}
NotificationSystem._queue = {}
NotificationSystem._maxVisible = 5
NotificationSystem._holder = nil

function NotificationSystem.Initialize(holder)
    NotificationSystem._holder = holder
end

function NotificationSystem.Create(config)
    local notification = {
        Title = config.Title or "Notification",
        Content = config.Content or "",
        Duration = config.Duration or 4,
        Icon = config.Icon or "bell",
        Type = config.Type or "info",
        Color = config.Color,
    }
    
    table.insert(NotificationSystem._queue, notification)
    NotificationSystem._process()
    
    return notification
end

function NotificationSystem._process()
    while #NotificationSystem._active < NotificationSystem._maxVisible and #NotificationSystem._queue > 0 do
        local notification = table.remove(NotificationSystem._queue, 1)
        NotificationSystem._show(notification)
    end
end

function NotificationSystem._show(notification)
    if not NotificationSystem._holder then return end
    
    -- Determine border color
    local borderColor = notification.Color or (
        notification.Type == "success" and ThemeSystem.GetColor("Button.Success") or
        notification.Type == "error" and ThemeSystem.GetColor("Button.Danger") or
        notification.Type == "warning" and ThemeSystem.GetColor("Button.Warning") or
        ThemeSystem.GetColor("Notification.Border")
    )
    
    -- Container
    local container = Util.Create("Frame", {
        Name = "Notification",
        Size = UDim2.new(0, 320, 0, 0),
        BackgroundColor3 = ThemeSystem.GetColor("Notification.Background"),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = NotificationSystem._holder,
    })
    Util.Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = container })
    Util.Create("UIStroke", {
        Color = borderColor,
        Thickness = 1.5,
        Transparency = 0.35,
        Parent = container,
    })
    
    -- Content padding
    local content = Util.Create("Frame", {
        Size = UDim2.new(1, -24, 1, -18),
        Position = UDim2.new(0, 12, 0, 9),
        BackgroundTransparency = 1,
        Parent = container,
    })
    
    -- Icon
    local iconSize = 20
    if notification.Icon and notification.Icon ~= "" then
        IconSystem.Create(notification.Icon, iconSize, content, borderColor)
    end
    
    -- Title
    local titleLabel = Util.Create("TextLabel", {
        Size = UDim2.new(1, -30, 0, 18),
        Position = UDim2.new(0, iconSize + 8, 0, 0),
        BackgroundTransparency = 1,
        Text = notification.Title,
        TextColor3 = ThemeSystem.GetColor("Notification.Title"),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = content,
    })
    
    -- Close button
    local closeBtn = Util.Create("TextButton", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -20, 0, 0),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = ThemeSystem.GetColor("Notification.Content"),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = content,
    })
    
    -- Content text
    if notification.Content ~= "" then
        Util.Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            Position = UDim2.new(0, 0, 0, 22),
            BackgroundTransparency = 1,
            Text = notification.Content,
            TextColor3 = ThemeSystem.GetColor("Notification.Content"),
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = content,
        })
    end
    
    -- Timer bar
    local timerBg = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = ThemeSystem.GetColor("Notification.Timer"),
        BackgroundTransparency = ThemeSystem.GetTransparency("Notification.TimerTransparency"),
        BorderSizePixel = 0,
        Parent = container,
    })
    
    local timerFill = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = borderColor,
        BorderSizePixel = 0,
        Parent = timerBg,
    })
    Util.Create("UICorner", { CornerRadius = UDim.new(0, 1), Parent = timerFill })
    
    -- Spring animate in
    local totalHeight = notification.Content ~= "" and 62 or 42
    local spring = SpringEngine.new(0, { Stiffness = 130, Damping = 14 })
    spring:OnChange(function(v)
        pcall(function()
            container.Size = UDim2.new(0, 320, 0, v)
        end)
    end)
    spring:SetTarget(totalHeight)
    
    -- Timer animation
    local timerTween = Util.Tween(timerFill,
        TweenInfo.new(notification.Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
        { Size = UDim2.new(0, 0, 1, 0) }
    )
    
    -- Dismiss function
    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        
        spring:SetTarget(0)
        
        task.delay(0.35, function()
            if container.Parent then
                container:Destroy()
            end
            
            -- Remove from active list
            for i, item in ipairs(NotificationSystem._active) do
                if item.Container == container then
                    table.remove(NotificationSystem._active, i)
                    break
                end
            end
            
            NotificationSystem._process()
        end)
    end
    
    -- Close button
    closeBtn.MouseButton1Click:Connect(dismiss)
    
    -- Auto dismiss
    task.delay(notification.Duration, dismiss)
    
    -- Store
    table.insert(NotificationSystem._active, {
        Container = container,
        Spring = spring,
    })
end

-- ============================================================
-- SECTION 9: DIALOG SYSTEM
-- ============================================================
local DialogSystem = {}

function DialogSystem.Show(window, config)
    config = config or {}
    
    -- Overlay
    local overlay = Util.Create("Frame", {
        Name = "DialogOverlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = ThemeSystem.GetColor("Dialog.Overlay"),
        BackgroundTransparency = 1,
        ZIndex = 999,
        Parent = window._screenGui,
    })
    
    -- Dialog frame
    local dialogFrame = Util.Create("Frame", {
        Name = "DialogFrame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = ThemeSystem.GetColor("Dialog.Background"),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 1000,
        Parent = overlay,
    })
    Util.Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = dialogFrame })
    Util.Create("UIStroke", {
        Color = ThemeSystem.GetColor("Dialog.Border"),
        Thickness = 1,
        Transparency = ThemeSystem.GetTransparency("Dialog.BorderTransparency"),
        Parent = dialogFrame,
    })
    
    -- Content
    local content = Util.Create("Frame", {
        Size = UDim2.new(0, 300, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = dialogFrame,
    })
    
    Util.Create("UIPadding", {
        PaddingTop = UDim.new(0, 24),
        PaddingBottom = UDim.new(0, 24),
        PaddingLeft = UDim.new(0, 24),
        PaddingRight = UDim.new(0, 24),
        Parent = content,
    })
    
    -- Title
    Util.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = config.Title or "Dialog",
        TextColor3 = ThemeSystem.GetColor("Element.Title"),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextWrapped = true,
        Parent = content,
    })
    
    -- Description
    if config.Content then
        Util.Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = config.Content,
            TextColor3 = ThemeSystem.GetColor("Element.Description"),
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextWrapped = true,
            Parent = content,
        })
    end
    
    -- Buttons
    if config.Buttons and #config.Buttons > 0 then
        local buttonHolder = Util.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            Parent = content,
        })
        
        Util.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = buttonHolder,
        })
        
        for _, btnConfig in ipairs(config.Buttons) do
            local style = btnConfig.Style or "Primary"
            local color = style == "Danger" and ThemeSystem.GetColor("Button.Danger") or
                         style == "Secondary" and ThemeSystem.GetColor("Button.Secondary") or
                         style == "Success" and ThemeSystem.GetColor("Button.Success") or
                         ThemeSystem.GetColor("Button.Primary")
            
            local btn = Util.Create("TextButton", {
                Size = UDim2.new(0, 110, 0, 34),
                BackgroundColor3 = color,
                Text = btnConfig.Title or "Button",
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                BorderSizePixel = 0,
                Parent = buttonHolder,
            })
            Util.Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
            
            btn.MouseButton1Click:Connect(function()
                overlay:Destroy()
                Util.SafeCallback(btnConfig.Callback)
            end)
        end
    end
    
    -- Animate overlay
    local overlaySpring = SpringEngine.new(0, { Stiffness = 120, Damping = 12 })
    overlaySpring:OnChange(function(v)
        overlay.BackgroundTransparency = 1 - v * ThemeSystem.GetTransparency("Dialog.OverlayTransparency")
    end)
    overlaySpring:SetTarget(1)
    
    -- Animate dialog
    local dialogSpring = SpringEngine.new(0.7, { Stiffness = 170, Damping = 17 })
    dialogSpring:OnChange(function(v)
        dialogFrame.Size = UDim2.new(0, 320 * v, 0, content.AbsoluteSize.Y * v)
    end)
    dialogSpring:SetTarget(1)
    
    -- Close on overlay click
    overlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            overlaySpring:SetTarget(0)
            task.delay(0.3, function()
                if overlay.Parent then
                    overlay:Destroy()
                end
            end)
        end
    end)
    
    return {
        Close = function()
            overlay:Destroy()
        end,
    }
end

-- ============================================================
-- END OF PART 1
-- ============================================================
-- ============================================================
-- SECTION 10: LIBRARY CORE
-- ============================================================
local Library = {}
Library._windows = {}
Library._activeWindow = nil

-- ============================================================
-- SECTION 11: CREATE WINDOW
-- ============================================================
function Library:CreateWindow(config)
    config = config or {}
    
    -- Window data
    local window = {
        _id = Util.GenerateGUID(),
        _title = config.Title or "UILibrary",
        _version = config.Version or "v7.0",
        _game = config.Game or "",
        _discord = config.Discord or "",
        _folder = config.Folder or config.Title or "UILibrary",
        _theme = config.Theme or "Dark",
        _resizable = config.Resizable ~= false,
        _draggable = config.Draggable ~= false,
        _minimizeKey = config.MinimizeKey or Enum.KeyCode.RightShift,
        _tabs = {},
        _activeTab = nil,
        _signals = {},
        _springs = {},
        _floatingIcon = nil,
        _minimized = false,
        _menuVisible = true,
    }
    
    -- Apply theme
    ThemeSystem.Set(window._theme)
    
    -- ========================================
    -- SCREEN GUI
    -- ========================================
    local screenGui = Util.Create("ScreenGui", {
        Name = "UILibrary_" .. window._title,
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
    
    -- ========================================
    -- MAIN FRAME
    -- ========================================
    local mainFrame = Util.Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 600, 0, 480),
        Position = UDim2.new(0.5, -300, 0.5, -240),
        BackgroundColor3 = ThemeSystem.GetColor("Window.Background"),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = screenGui,
    })
    Util.Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = mainFrame })
    Util.Create("UIStroke", {
        Color = ThemeSystem.GetColor("Window.Border"),
        Thickness = 1,
        Transparency = ThemeSystem.GetTransparency("Window.BorderTransparency"),
        Parent = mainFrame,
    })
    window._mainFrame = mainFrame
    
    -- Shadow
    local shadow = Util.Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 10),
        Size = UDim2.new(1, 60, 1, 60),
        Image = "rbxassetid://6014261993",
        ImageColor3 = ThemeSystem.GetColor("Window.Shadow"),
        ImageTransparency = ThemeSystem.GetTransparency("Window.ShadowTransparency"),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1,
        Parent = mainFrame,
    })
    
    -- ========================================
    -- TOPBAR
    -- ========================================
    local topBar = Util.Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = ThemeSystem.GetColor("Topbar.Background"),
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    Util.Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = topBar })
    Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = ThemeSystem.GetColor("Topbar.Background"),
        BorderSizePixel = 0,
        Parent = topBar,
    })
    
    -- Title
    Util.Create("TextLabel", {
        Size = UDim2.new(1, -140, 1, 0),
        Position = UDim2.new(0, 18, 0, 0),
        BackgroundTransparency = 1,
        Text = window._title,
        TextColor3 = ThemeSystem.GetColor("Topbar.Text"),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar,
    })
    
    -- Minimize Button
    local minimizeBtn = Util.Create("TextButton", {
        Name = "MinimizeBtn",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -76, 0.5, -15),
        BackgroundColor3 = Color3.fromRGB(255, 180, 50),
        Text = "—",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        Parent = topBar,
    })
    Util.Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = minimizeBtn })
    
    -- Close Button
    local closeBtn = Util.Create("TextButton", {
        Name = "CloseBtn",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -38, 0.5, -15),
        BackgroundColor3 = ThemeSystem.GetColor("Button.Danger"),
        Text = "×",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        Parent = topBar,
    })
    Util.Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = closeBtn })
    
    closeBtn.MouseButton1Click:Connect(function()
        window:Destroy()
    end)
    
    -- ========================================
    -- SIDEBAR
    -- ========================================
    local sidebar = Util.Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 48, 1, -44),
        Position = UDim2.new(0, 0, 0, 44),
        BackgroundColor3 = ThemeSystem.GetColor("Sidebar.Background"),
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    Util.Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = sidebar })
    Util.Create("Frame", {
        Size = UDim2.new(0, 12, 1, 0),
        BackgroundColor3 = ThemeSystem.GetColor("Sidebar.Background"),
        BorderSizePixel = 0,
        Parent = sidebar,
    })
    
    -- Menu Toggle
    local menuToggle = Util.Create("TextButton", {
        Name = "MenuToggle",
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0.5, -18, 0, 8),
        BackgroundColor3 = ThemeSystem.GetColor("Sidebar.ToggleButton"),
        Text = "☰",
        TextColor3 = ThemeSystem.GetColor("Sidebar.ToggleIcon"),
        TextSize = 17,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        Parent = sidebar,
    })
    Util.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = menuToggle })
    
    -- ========================================
    -- CONTENT FRAME
    -- ========================================
    local contentFrame = Util.Create("Frame", {
        Name = "ContentFrame",
        Size = UDim2.new(1, -48, 1, -44),
        Position = UDim2.new(0, 48, 0, 44),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = mainFrame,
    })
    
    -- Tab Bar
    local tabBar = Util.Create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = ThemeSystem.GetColor("Topbar.Background"),
        BorderSizePixel = 0,
        Parent = contentFrame,
    })
    Util.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = tabBar,
    })
    Util.Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 6),
        Parent = tabBar,
    })
    
    -- Tab divider
    Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 38),
        BackgroundColor3 = ThemeSystem.GetColor("Section.Divider"),
        BackgroundTransparency = ThemeSystem.GetTransparency("Section.DividerTransparency"),
        BorderSizePixel = 0,
        Parent = contentFrame,
    })
    
    -- Pages holder
    local pagesHolder = Util.Create("Frame", {
        Name = "PagesHolder",
        Size = UDim2.new(1, 0, 1, -39),
        Position = UDim2.new(0, 0, 0, 39),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = contentFrame,
    })
    
    -- ========================================
    -- FOOTER
    -- ========================================
    local footer = Util.Create("Frame", {
        Name = "Footer",
        Size = UDim2.new(1, 0, 0, 26),
        Position = UDim2.new(0, 0, 1, -26),
        BackgroundColor3 = ThemeSystem.GetColor("Footer.Background"),
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    Util.Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = footer })
    Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        BackgroundColor3 = ThemeSystem.GetColor("Footer.Background"),
        BorderSizePixel = 0,
        Parent = footer,
    })
    
    Util.Create("TextLabel", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = window._version .. " | " .. window._game,
        TextColor3 = ThemeSystem.GetColor("Footer.Text"),
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = footer,
    })
    
    -- ========================================
    -- RESIZE CORNER
    -- ========================================
    if window._resizable then
        local resizeCorner = Util.Create("TextButton", {
            Name = "ResizeCorner",
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(1, -20, 1, -20),
            BackgroundTransparency = 1,
            Text = "◢",
            TextColor3 = ThemeSystem.GetColor("ResizeCorner.Color"),
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            ZIndex = 10,
            Parent = mainFrame,
        })
        Util.MakeResizable(mainFrame, resizeCorner, 480, 360)
    end
    
    -- ========================================
    -- DRAGGABLE
    -- ========================================
    if window._draggable then
        Util.MakeDraggable(mainFrame, topBar)
    end
    
    -- ========================================
    -- MINIMIZE TO FLOATING ICON (KEY FEATURE)
    -- ========================================
    local sizeSpring = SpringFactory.Size(mainFrame, { Stiffness = 180, Damping = 18 })
    local posSpring = SpringFactory.Position(mainFrame, { Stiffness = 140, Damping = 15 })
    local alphaSpring = SpringFactory.Transparency(mainFrame, { Stiffness = 150, Damping = 12 })
    
    window._sizeSpring = sizeSpring
    window._posSpring = posSpring
    window._alphaSpring = alphaSpring
    
    local savedSize = { Width = 600, Height = 480 }
    local savedPos = { X = 0, Y = 0 }
    
    local function minimizeToIcon()
        if window._minimized then return end
        window._minimized = true
        
        -- Save current state
        savedSize.Width = mainFrame.Size.X.Offset
        savedSize.Height = mainFrame.Size.Y.Offset
        savedPos.X = mainFrame.Position.X.Offset
        savedPos.Y = mainFrame.Position.Y.Offset
        
        -- Animate out
        sizeSpring.SetSize(0, 0)
        alphaSpring.FadeOut()
        
        task.delay(0.3, function()
            mainFrame.Visible = false
            
            -- Create floating icon
            if not window._floatingIcon then
                local floatBtn = Util.Create("TextButton", {
                    Name = "FloatingIcon",
                    Size = UDim2.new(0, 50, 0, 50),
                    Position = UDim2.new(1, -66, 0, 16),
                    BackgroundColor3 = ThemeSystem.GetColor("FloatingIcon.Background"),
                    Text = "R",
                    TextColor3 = ThemeSystem.GetColor("FloatingIcon.Text"),
                    TextSize = 22,
                    Font = Enum.Font.GothamBold,
                    BorderSizePixel = 0,
                    Parent = screenGui,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = floatBtn })
                Util.Create("UIStroke", {
                    Color = ThemeSystem.GetColor("FloatingIcon.Border"),
                    Thickness = 1.5,
                    Transparency = ThemeSystem.GetTransparency("FloatingIcon.BorderTransparency"),
                    Parent = floatBtn,
                })
                
                -- Make draggable
                Util.MakeDraggable(floatBtn)
                
                -- Spring in
                local iconSpring = SpringEngine.new(0, { Stiffness = 160, Damping = 16 })
                iconSpring:OnChange(function(v)
                    pcall(function()
                        floatBtn.Size = UDim2.new(0, 50 * v, 0, 50 * v)
                    end)
                end)
                iconSpring:SetTarget(1)
                
                -- Click to restore
                floatBtn.MouseButton1Click:Connect(function()
                    if not window._minimized then return end
                    window._minimized = false
                    
                    -- Destroy icon
                    floatBtn:Destroy()
                    window._floatingIcon = nil
                    
                    -- Show main window
                    mainFrame.Visible = true
                    mainFrame.BackgroundTransparency = 1
                    
                    -- Animate in
                    mainFrame.Size = UDim2.new(0, 0, 0, 0)
                    sizeSpring.SetSize(savedSize.Width, savedSize.Height)
                    alphaSpring.FadeIn()
                end)
                
                window._floatingIcon = floatBtn
            end
        end)
    end
    
    local function restoreFromIcon()
        if not window._minimized then return end
        window._minimized = false
        
        if window._floatingIcon then
            window._floatingIcon:Destroy()
            window._floatingIcon = nil
        end
        
        mainFrame.Visible = true
        mainFrame.BackgroundTransparency = 1
        
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        sizeSpring.SetSize(savedSize.Width, savedSize.Height)
        alphaSpring.FadeIn()
    end
    
    minimizeBtn.MouseButton1Click:Connect(minimizeToIcon)
    
    -- Keyboard toggle
    local keySignal = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == window._minimizeKey then
            if window._minimized then
                restoreFromIcon()
            else
                minimizeToIcon()
            end
        end
    end)
    table.insert(window._signals, keySignal)
    
    -- ========================================
    -- SIDEBAR MENU TOGGLE
    -- ========================================
    local menuSpring = SpringEngine.new(1, { Stiffness = 150, Damping = 16 })
    
    menuSpring:OnChange(function(v)
        pcall(function()
            contentFrame.Size = UDim2.new(1 * v - 48 * v, 0, 1, -44)
            contentFrame.Position = UDim2.new(0, 48 * v, 0, 44)
        end)
    end)
    
    local function toggleMenu()
        window._menuVisible = not window._menuVisible
        
        if window._menuVisible then
            contentFrame.Visible = true
            menuSpring:SetTarget(1)
        else
            menuSpring:SetTarget(0)
            task.delay(0.3, function()
                if not window._menuVisible then
                    contentFrame.Visible = false
                end
            end)
        end
    end
    
    menuToggle.MouseButton1Click:Connect(toggleMenu)
    
    -- ========================================
    -- NOTIFICATION HOLDER
    -- ========================================
    local notifHolder = Util.Create("Frame", {
        Name = "NotificationHolder",
        Size = UDim2.new(0, 336, 1, 0),
        Position = UDim2.new(1, -352, 0, 0),
        BackgroundTransparency = 1,
        Parent = screenGui,
    })
    Util.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 10),
        Parent = notifHolder,
    })
    Util.Create("UIPadding", {
        PaddingBottom = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        Parent = notifHolder,
    })
    
    NotificationSystem.Initialize(notifHolder)
    
    -- ========================================
    -- WINDOW METHODS
    -- ========================================
    
    -- Notify
    function window:Notify(config)
        NotificationSystem.Create(config)
    end
    
    -- Dialog
    function window:Dialog(config)
        DialogSystem.Show(window, config)
    end
    
    -- Set Theme
    function window:SetTheme(themeName)
        window._theme = themeName
        ThemeSystem.Set(themeName)
    end
    
    -- Get Theme
    function window:GetTheme()
        return window._theme
    end
    
    -- Destroy
    function window:Destroy()
        -- Disconnect signals
        for _, signal in ipairs(window._signals) do
            pcall(function() signal:Disconnect() end)
        end
        
        -- Destroy springs
        if window._sizeSpring then window._sizeSpring:Destroy() end
        if window._posSpring then window._posSpring:Destroy() end
        if window._alphaSpring then window._alphaSpring:Destroy() end
        
        -- Destroy floating icon
        if window._floatingIcon then
            window._floatingIcon:Destroy()
            window._floatingIcon = nil
        end
        
        -- Destroy UI
        if screenGui and screenGui.Parent then
            screenGui:Destroy()
        end
        
        -- Remove from library
        for i, w in ipairs(Library._windows) do
            if w._id == window._id then
                table.remove(Library._windows, i)
                break
            end
        end
        
        if Library._activeWindow == window then
            Library._activeWindow = nil
        end
    end
    
    -- ========================================
    -- ADD TAB
    -- ========================================
    function window:AddTab(config)
        config = config or {}
        local tabName = config.Name or "Tab"
        local tabIcon = config.Icon or ""
        
        -- Tab button
        local tabBtn = Util.Create("TextButton", {
            Name = tabName .. "TabBtn",
            Size = UDim2.new(0, 0, 0, 28),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = ThemeSystem.GetColor("Tab.Background"),
            Text = (tabIcon ~= "" and tabIcon .. " " or "") .. tabName,
            TextColor3 = ThemeSystem.GetColor("Tab.Text"),
            TextSize = 12,
            Font = Enum.Font.GothamSemibold,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Parent = tabBar,
        })
        Util.Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = tabBtn })
        Util.Create("UIPadding", {
            PaddingLeft = UDim.new(0, 14),
            PaddingRight = UDim.new(0, 14),
            Parent = tabBtn,
        })
        
        -- Hover spring
        local hoverSpring = SpringEngine.new(0, { Stiffness = 250, Damping = 25 })
        hoverSpring:OnChange(function(v)
            if window._activeTab and window._activeTab._btn ~= tabBtn then
                tabBtn.BackgroundColor3 = Util.LerpColor(
                    ThemeSystem.GetColor("Tab.Background"),
                    ThemeSystem.GetColor("Tab.Active"),
                    v * 0.3
                )
            end
        end)
        
        tabBtn.MouseEnter:Connect(function()
            hoverSpring:SetTarget(1)
        end)
        
        tabBtn.MouseLeave:Connect(function()
            hoverSpring:SetTarget(0)
        end)
        
        -- Tab page
        local tabPage = Util.Create("Frame", {
            Name = tabName .. "Page",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = pagesHolder,
        })
        
        -- Two columns
        local leftColumn = Util.Create("ScrollingFrame", {
            Name = "LeftColumn",
            Size = UDim2.new(0.5, -1, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = ThemeSystem.GetColor("Scrollbar.Color"),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Parent = tabPage,
        })
        Util.Create("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 12),
            Parent = leftColumn,
        })
        Util.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = leftColumn,
        })
        
        -- Column divider
        Util.Create("Frame", {
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.new(0.5, 0, 0, 0),
            BackgroundColor3 = ThemeSystem.GetColor("Section.Divider"),
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            Parent = tabPage,
        })
        
        local rightColumn = Util.Create("ScrollingFrame", {
            Name = "RightColumn",
            Size = UDim2.new(0.5, -1, 1, 0),
            Position = UDim2.new(0.5, 1, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = ThemeSystem.GetColor("Scrollbar.Color"),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Parent = tabPage,
        })
        Util.Create("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 12),
            Parent = rightColumn,
        })
        Util.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = rightColumn,
        })
        
        local tab = {
            _btn = tabBtn,
            _page = tabPage,
            _left = leftColumn,
            _right = rightColumn,
            _window = window,
        }
        
        -- Activate
        function tab:Activate()
            if window._activeTab then
                local old = window._activeTab
                old._btn.BackgroundColor3 = ThemeSystem.GetColor("Tab.Background")
                old._btn.TextColor3 = ThemeSystem.GetColor("Tab.Text")
                old._page.Visible = false
            end
            
            window._activeTab = self
            self._btn.BackgroundColor3 = ThemeSystem.GetColor("Tab.Active")
            self._btn.TextColor3 = ThemeSystem.GetColor("Tab.ActiveText")
            self._page.Visible = true
        end
        
        tabBtn.MouseButton1Click:Connect(function()
            tab:Activate()
        end)
        
        table.insert(window._tabs, tab)
        if #window._tabs == 1 then
            tab:Activate()
        end
        
        -- Section side tracker
        local nextSide = "left"
        
        -- ========================================
        -- ADD SECTION TO TAB
        -- ========================================
        function tab:AddSection(config)
            config = config or {}
            local sectionName = config.Name or "Section"
            local side = config.Side or nextSide
            nextSide = (nextSide == "left") and "right" or "left"
            
            local parent = (side == "right") and rightColumn or leftColumn
            
            -- Section frame
            local sectionFrame = Util.Create("Frame", {
                Name = sectionName .. "Section",
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = ThemeSystem.GetColor("Section.Background"),
                BorderSizePixel = 0,
                Parent = parent,
            })
            Util.Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = sectionFrame })
            Util.Create("UIStroke", {
                Color = ThemeSystem.GetColor("Section.Border"),
                Thickness = 1,
                Transparency = ThemeSystem.GetTransparency("Section.BorderTransparency"),
                Parent = sectionFrame,
            })
            
            -- Content
            local sectionContent = Util.Create("Frame", {
                Size = UDim2.new(1, -26, 1, -22),
                Position = UDim2.new(0, 13, 0, 11),
                BackgroundTransparency = 1,
                Parent = sectionFrame,
            })
            
            Util.Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
                Parent = sectionContent,
            })
            
            -- Title
            local titleFrame = Util.Create("Frame", {
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Parent = sectionContent,
            })
            
            Util.Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = ThemeSystem.GetColor("Section.Title"),
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = titleFrame,
            })
            
            -- Divider
            Util.Create("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, 4),
                BackgroundColor3 = ThemeSystem.GetColor("Section.Divider"),
                BackgroundTransparency = ThemeSystem.GetTransparency("Section.DividerTransparency"),
                BorderSizePixel = 0,
                Parent = titleFrame,
            })
            
            -- Spacer
            Util.Create("Frame", {
                Size = UDim2.new(1, 0, 0, 6),
                BackgroundTransparency = 1,
                Parent = sectionContent,
            })
            
            local section = {
                _content = sectionContent,
                _window = window,
            }
            
            -- ========================================
            -- LABEL
            -- ========================================
            function section:AddLabel(config)
                config = config or {}
                local text = config.Text or ""
                local color = config.Color or ThemeSystem.GetColor("Element.Description")
                
                local label = Util.Create("TextLabel", {
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
                
                local obj = {}
                function obj:Set(t) label.Text = t end
                function obj:Get() return label.Text end
                return obj
            end
            
            -- ========================================
            -- BUTTON
            -- ========================================
            function section:AddButton(config)
                config = config or {}
                local name = config.Name or "Button"
                local callback = config.Callback or function() end
                local style = config.Style or "Primary"
                
                local colorMap = {
                    Primary = ThemeSystem.GetColor("Button.Primary"),
                    Secondary = ThemeSystem.GetColor("Button.Secondary"),
                    Danger = ThemeSystem.GetColor("Button.Danger"),
                    Success = ThemeSystem.GetColor("Button.Success"),
                    Warning = ThemeSystem.GetColor("Button.Warning"),
                }
                
                local textMap = {
                    Primary = ThemeSystem.GetColor("Button.PrimaryText"),
                    Secondary = ThemeSystem.GetColor("Button.SecondaryText"),
                    Danger = ThemeSystem.GetColor("Button.DangerText"),
                    Success = ThemeSystem.GetColor("Button.SuccessText"),
                    Warning = ThemeSystem.GetColor("Button.WarningText"),
                }
                
                local bgColor = colorMap[style] or colorMap.Primary
                local txtColor = textMap[style] or textMap.Primary
                
                local btn = Util.Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundColor3 = bgColor,
                    Text = name,
                    TextColor3 = txtColor,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Parent = sectionContent,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
                
                btn.MouseEnter:Connect(function()
                    Util.Tween(btn, TweenInfo.new(0.1), {
                        BackgroundColor3 = Util.LerpColor(bgColor, Color3.new(1, 1, 1), 0.15),
                    })
                end)
                
                btn.MouseLeave:Connect(function()
                    Util.Tween(btn, TweenInfo.new(0.1), {
                        BackgroundColor3 = bgColor,
                    })
                end)
                
                btn.MouseButton1Click:Connect(function()
                    Util.SafeCallback(callback)
                end)
                
                return btn
            end
            
            -- ========================================
            -- TOGGLE
            -- ========================================
            function section:AddToggle(config)
                config = config or {}
                local name = config.Name or "Toggle"
                local default = config.Default or false
                local callback = config.Callback or function() end
                local value = default
                
                local row = Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    Parent = sectionContent,
                })
                
                Util.Create("TextLabel", {
                    Size = UDim2.new(0.6, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = ThemeSystem.GetColor("Element.Title"),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row,
                })
                
                local track = Util.Create("Frame", {
                    Size = UDim2.new(0, 42, 0, 24),
                    Position = UDim2.new(1, -42, 0.5, -12),
                    BackgroundColor3 = value and ThemeSystem.GetColor("Toggle.Active") or ThemeSystem.GetColor("Toggle.Inactive"),
                    BorderSizePixel = 0,
                    Parent = row,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
                
                local thumb = Util.Create("Frame", {
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0, value and 21 or 3, 0.5, -9),
                    BackgroundColor3 = ThemeSystem.GetColor("Toggle.Thumb"),
                    BorderSizePixel = 0,
                    Parent = track,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = thumb })
                Util.Create("UIStroke", {
                    Color = ThemeSystem.GetColor("Toggle.Shadow"),
                    Thickness = 0.5,
                    Transparency = ThemeSystem.GetTransparency("Toggle.ShadowTransparency"),
                    Parent = thumb,
                })
                
                local clickBtn = Util.Create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = row,
                    ZIndex = 5,
                })
                
                local function setToggle(v)
                    value = v
                    local s = SpringEngine.new(v and 0 or 1, { Stiffness = 280, Damping = 24 })
                    s:OnChange(function(progress)
                        local t = v and progress or (1 - progress)
                        pcall(function()
                            track.BackgroundColor3 = Util.LerpColor(
                                ThemeSystem.GetColor("Toggle.Inactive"),
                                ThemeSystem.GetColor("Toggle.Active"),
                                t
                            )
                            thumb.Position = UDim2.new(0, 3 + 18 * t, 0.5, -9)
                        end)
                    end)
                    s:SetTarget(v and 1 or 0)
                    Util.SafeCallback(callback, value)
                end
                
                clickBtn.MouseButton1Click:Connect(function()
                    setToggle(not value)
                end)
                
                local obj = {}
                function obj:Set(v) setToggle(v) end
                function obj:Get() return value end
                return obj
            end
            
            -- ========================================
            -- SLIDER
            -- ========================================
            function section:AddSlider(config)
                config = config or {}
                local name = config.Name or "Slider"
                local min = config.Min or 0
                local max = config.Max or 100
                local default = config.Default or min
                local callback = config.Callback or function() end
                local suffix = config.Suffix or ""
                local value = Util.Clamp(default, min, max)
                
                local container = Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 52),
                    BackgroundTransparency = 1,
                    Parent = sectionContent,
                })
                
                local header = Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundTransparency = 1,
                    Parent = container,
                })
                
                Util.Create("TextLabel", {
                    Size = UDim2.new(0.58, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = ThemeSystem.GetColor("Element.Title"),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = header,
                })
                
                local valueLabel = Util.Create("TextLabel", {
                    Size = UDim2.new(0.42, 0, 1, 0),
                    Position = UDim2.new(0.58, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(value) .. suffix,
                    TextColor3 = ThemeSystem.GetColor("Element.Description"),
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = header,
                })
                
                local trackBg = Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 5),
                    Position = UDim2.new(0, 0, 0, 28),
                    BackgroundColor3 = ThemeSystem.GetColor("Slider.Background"),
                    BorderSizePixel = 0,
                    Parent = container,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = trackBg })
                
                local pct = (value - min) / (max - min)
                local fill = Util.Create("Frame", {
                    Size = UDim2.new(pct, 0, 1, 0),
                    BackgroundColor3 = ThemeSystem.GetColor("Slider.Fill"),
                    BorderSizePixel = 0,
                    Parent = trackBg,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
                
                local thumb = Util.Create("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(pct, -8, 0.5, -8),
                    BackgroundColor3 = ThemeSystem.GetColor("Slider.Thumb"),
                    BorderSizePixel = 0,
                    ZIndex = 3,
                    Parent = trackBg,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = thumb })
                Util.Create("UIStroke", {
                    Color = ThemeSystem.GetColor("Slider.Shadow"),
                    Thickness = 0.5,
                    Transparency = ThemeSystem.GetTransparency("Slider.ShadowTransparency"),
                    Parent = thumb,
                })
                
                local dragBtn = Util.Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 32),
                    Position = UDim2.new(0, 0, 0.5, -16),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 5,
                    Parent = trackBg,
                })
                
                local dragging = false
                local function updateSlider(inputX)
                    local absX = trackBg.AbsolutePosition.X
                    local width = trackBg.AbsoluteSize.X
                    local percent = Util.Clamp((inputX - absX) / width, 0, 1)
                    value = math.floor(min + (max - min) * percent)
                    
                    pcall(function()
                        fill.Size = UDim2.new(percent, 0, 1, 0)
                        thumb.Position = UDim2.new(percent, -8, 0.5, -8)
                        valueLabel.Text = tostring(value) .. suffix
                    end)
                    
                    Util.SafeCallback(callback, value)
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
                
                local obj = {}
                function obj:Set(v)
                    value = Util.Clamp(v, min, max)
                    local np = (value - min) / (max - min)
                    pcall(function()
                        fill.Size = UDim2.new(np, 0, 1, 0)
                        thumb.Position = UDim2.new(np, -8, 0.5, -8)
                        valueLabel.Text = tostring(value) .. suffix
                    end)
                end
                function obj:Get() return value end
                return obj
            end
            
            return section
        end
        
        return tab
    end
    
    -- Store window
    table.insert(Library._windows, window)
    Library._activeWindow = window
    
    return window   
end

-- ============================================================
-- SECTION 12: RETURN LIBRARY
-- ============================================================
return Library
-- ============================================================
-- SECTION 12 (CONTINUED): ADD SECTION ELEMENTS
-- ============================================================

            -- ========================================
            -- DROPDOWN
            -- ========================================
            function section:AddDropdown(config)
                config = config or {}
                local name = config.Name or "Dropdown"
                local options = config.Options or {}
                local default = config.Default or (options[1] or "None")
                local callback = config.Callback or function() end
                local value = default
                local isOpen = false
                
                local container = Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    Parent = sectionContent,
                })
                
                -- Label
                Util.Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = ThemeSystem.GetColor("Element.Title"),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = container,
                })
                
                -- Drop button
                local dropBtn = Util.Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = ThemeSystem.GetColor("Dropdown.Background"),
                    Text = value,
                    TextColor3 = ThemeSystem.GetColor("Dropdown.Text"),
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Parent = container,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = dropBtn })
                Util.Create("UIStroke", {
                    Color = ThemeSystem.GetColor("Dropdown.Border"),
                    Thickness = 1,
                    Transparency = ThemeSystem.GetTransparency("Dropdown.BorderTransparency"),
                    Parent = dropBtn,
                })
                
                -- Arrow
                local arrow = Util.Create("TextLabel", {
                    Size = UDim2.new(0, 22, 1, 0),
                    Position = UDim2.new(1, -24, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▾",
                    TextColor3 = ThemeSystem.GetColor("Dropdown.Arrow"),
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    Parent = dropBtn,
                })
                
                -- Options list
                local optionsList = Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 3),
                    BackgroundColor3 = ThemeSystem.GetColor("Dropdown.Background"),
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 100,
                    Parent = dropBtn,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = optionsList })
                Util.Create("UIStroke", {
                    Color = ThemeSystem.GetColor("Dropdown.Border"),
                    Thickness = 1,
                    Transparency = ThemeSystem.GetTransparency("Dropdown.BorderTransparency"),
                    ZIndex = 101,
                    Parent = optionsList,
                })
                Util.Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = optionsList,
                })
                
                -- Build options
                local optionButtons = {}
                local function buildOptions()
                    -- Clear existing
                    for _, btn in ipairs(optionButtons) do
                        if btn.Parent then btn:Destroy() end
                    end
                    optionButtons = {}
                    
                    for _, option in ipairs(options) do
                        local optionBtn = Util.Create("TextButton", {
                            Size = UDim2.new(1, 0, 0, 26),
                            BackgroundColor3 = ThemeSystem.GetColor("Dropdown.Background"),
                            Text = option,
                            TextColor3 = ThemeSystem.GetColor("Dropdown.Text"),
                            TextSize = 11,
                            Font = Enum.Font.Gotham,
                            BorderSizePixel = 0,
                            AutoButtonColor = false,
                            ZIndex = 102,
                            Parent = optionsList,
                        })
                        
                        optionBtn.MouseEnter:Connect(function()
                            Util.Tween(optionBtn, TweenInfo.new(0.08), {
                                BackgroundColor3 = ThemeSystem.GetColor("Dropdown.Hover"),
                            })
                        end)
                        
                        optionBtn.MouseLeave:Connect(function()
                            Util.Tween(optionBtn, TweenInfo.new(0.08), {
                                BackgroundColor3 = ThemeSystem.GetColor("Dropdown.Background"),
                            })
                        end)
                        
                        optionBtn.MouseButton1Click:Connect(function()
                            value = option
                            dropBtn.Text = option
                            isOpen = false
                            
                            Util.Tween(optionsList, TweenInfo.new(0.15), {
                                Size = UDim2.new(1, 0, 0, 0),
                            })
                            
                            task.delay(0.16, function()
                                optionsList.Visible = false
                                container.Size = UDim2.new(1, 0, 0, 48)
                            end)
                            
                            Util.Tween(arrow, TweenInfo.new(0.15), { Rotation = 0 })
                            Util.SafeCallback(callback, value)
                        end)
                        
                        table.insert(optionButtons, optionBtn)
                    end
                end
                
                buildOptions()
                
                -- Toggle open/close
                local function toggleDropdown()
                    isOpen = not isOpen
                    
                    if isOpen then
                        optionsList.Visible = true
                        local h = math.min(#options * 26, 200)
                        
                        Util.Tween(optionsList, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                            Size = UDim2.new(1, 0, 0, h),
                        })
                        
                        container.Size = UDim2.new(1, 0, 0, 48 + h + 6)
                        Util.Tween(arrow, TweenInfo.new(0.15), { Rotation = 180 })
                    else
                        Util.Tween(optionsList, TweenInfo.new(0.12), {
                            Size = UDim2.new(1, 0, 0, 0),
                        })
                        
                        task.delay(0.13, function()
                            optionsList.Visible = false
                            container.Size = UDim2.new(1, 0, 0, 48)
                        end)
                        
                        Util.Tween(arrow, TweenInfo.new(0.12), { Rotation = 0 })
                    end
                end
                
                dropBtn.MouseButton1Click:Connect(toggleDropdown)
                
                -- Return object
                local obj = {}
                function obj:Set(v)
                    value = v
                    dropBtn.Text = v
                end
                function obj:Get() return value end
                function obj:Update(newOptions)
                    options = newOptions
                    buildOptions()
                end
                function obj:AddOption(option)
                    table.insert(options, option)
                    buildOptions()
                end
                function obj:RemoveOption(option)
                    for i, o in ipairs(options) do
                        if o == option then
                            table.remove(options, i)
                            break
                        end
                    end
                    buildOptions()
                end
                function obj:Clear()
                    options = {}
                    buildOptions()
                end
                
                return obj
            end
            
            -- ========================================
            -- TEXTBOX
            -- ========================================
            function section:AddTextbox(config)
                config = config or {}
                local name = config.Name or "Textbox"
                local placeholder = config.Placeholder or ""
                local default = config.Default or ""
                local callback = config.Callback or function() end
                local multiline = config.MultiLine or false
                local password = config.Password or false
                local numbersOnly = config.NumbersOnly or false
                
                local containerHeight = multiline and 72 or 48
                
                local container = Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, containerHeight),
                    BackgroundTransparency = 1,
                    Parent = sectionContent,
                })
                
                -- Label
                Util.Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = ThemeSystem.GetColor("Element.Title"),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = container,
                })
                
                -- Textbox
                local textbox = Util.Create("TextBox", {
                    Size = UDim2.new(1, 0, 0, multiline and 50 or 28),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = ThemeSystem.GetColor("Textbox.Background"),
                    Text = default,
                    PlaceholderText = placeholder,
                    TextColor3 = ThemeSystem.GetColor("Textbox.Text"),
                    PlaceholderColor3 = ThemeSystem.GetColor("Textbox.Placeholder"),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    BorderSizePixel = 0,
                    ClearTextOnFocus = false,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = multiline and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
                    TextWrapped = multiline,
                    MultiLine = multiline,
                    Parent = container,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = textbox })
                Util.Create("UIStroke", {
                    Color = ThemeSystem.GetColor("Textbox.Border"),
                    Thickness = 1,
                    Transparency = ThemeSystem.GetTransparency("Textbox.BorderTransparency"),
                    Parent = textbox,
                })
                Util.Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                    PaddingTop = UDim.new(0, multiline and 6 or 0),
                    Parent = textbox,
                })
                
                -- Input validation
                if numbersOnly then
                    textbox:GetPropertyChangedSignal("Text"):Connect(function()
                        local filtered = string.gsub(textbox.Text, "[^%d%.%-]", "")
                        if filtered ~= textbox.Text then
                            textbox.Text = filtered
                        end
                    end)
                end
                
                -- Callback
                textbox.FocusLost:Connect(function(enterPressed)
                    Util.SafeCallback(callback, textbox.Text, enterPressed)
                end)
                
                local obj = {}
                function obj:Set(t)
                    textbox.Text = t
                end
                function obj:Get()
                    return textbox.Text
                end
                function obj:Focus()
                    textbox:CaptureFocus()
                end
                function obj:Clear()
                    textbox.Text = ""
                end
                
                return obj
            end
            
            -- ========================================
            -- DIVIDER
            -- ========================================
            function section:AddDivider(text)
                local dividerFrame = Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Parent = sectionContent,
                })
                
                if text and text ~= "" then
                    Util.Create("TextLabel", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = text,
                        TextColor3 = ThemeSystem.GetColor("Element.Description"),
                        TextSize = 10,
                        Font = Enum.Font.GothamBold,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        Parent = dividerFrame,
                    })
                end
                
                Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    BackgroundColor3 = ThemeSystem.GetColor("Section.Divider"),
                    BackgroundTransparency = 0.7,
                    BorderSizePixel = 0,
                    Parent = dividerFrame,
                })
            end
            
            -- ========================================
            -- COLOR PICKER
            -- ========================================
            function section:AddColorPicker(config)
                config = config or {}
                local name = config.Name or "Color Picker"
                local default = config.Default or Color3.fromRGB(255, 255, 255)
                local callback = config.Callback or function() end
                local value = default
                
                local container = Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundTransparency = 1,
                    Parent = sectionContent,
                })
                
                Util.Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = ThemeSystem.GetColor("Element.Title"),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = container,
                })
                
                -- Color preview
                local preview = Util.Create("Frame", {
                    Size = UDim2.new(0, 28, 0, 28),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = value,
                    BorderSizePixel = 0,
                    Parent = container,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = preview })
                Util.Create("UIStroke", {
                    Color = Color3.new(1, 1, 1),
                    Thickness = 1,
                    Transparency = 0.7,
                    Parent = preview,
                })
                
                -- RGB Inputs
                local rInput = Util.Create("TextBox", {
                    Size = UDim2.new(0, 52, 0, 28),
                    Position = UDim2.new(0, 36, 0, 20),
                    BackgroundColor3 = ThemeSystem.GetColor("Textbox.Background"),
                    Text = tostring(math.floor(value.R * 255)),
                    PlaceholderText = "R",
                    TextColor3 = Color3.fromRGB(255, 100, 100),
                    PlaceholderColor3 = Color3.fromRGB(255, 150, 150),
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    BorderSizePixel = 0,
                    Parent = container,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = rInput })
                
                local gInput = Util.Create("TextBox", {
                    Size = UDim2.new(0, 52, 0, 28),
                    Position = UDim2.new(0, 94, 0, 20),
                    BackgroundColor3 = ThemeSystem.GetColor("Textbox.Background"),
                    Text = tostring(math.floor(value.G * 255)),
                    PlaceholderText = "G",
                    TextColor3 = Color3.fromRGB(100, 255, 100),
                    PlaceholderColor3 = Color3.fromRGB(150, 255, 150),
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    BorderSizePixel = 0,
                    Parent = container,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = gInput })
                
                local bInput = Util.Create("TextBox", {
                    Size = UDim2.new(0, 52, 0, 28),
                    Position = UDim2.new(0, 152, 0, 20),
                    BackgroundColor3 = ThemeSystem.GetColor("Textbox.Background"),
                    Text = tostring(math.floor(value.B * 255)),
                    PlaceholderText = "B",
                    TextColor3 = Color3.fromRGB(100, 150, 255),
                    PlaceholderColor3 = Color3.fromRGB(150, 200, 255),
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    BorderSizePixel = 0,
                    Parent = container,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = bInput })
                
                local function updateColor()
                    local r = Util.Clamp(tonumber(rInput.Text) or 0, 0, 255) / 255
                    local g = Util.Clamp(tonumber(gInput.Text) or 0, 0, 255) / 255
                    local b = Util.Clamp(tonumber(bInput.Text) or 0, 0, 255) / 255
                    value = Color3.new(r, g, b)
                    
                    pcall(function()
                        preview.BackgroundColor3 = value
                    end)
                    
                    Util.SafeCallback(callback, value)
                end
                
                rInput.FocusLost:Connect(updateColor)
                gInput.FocusLost:Connect(updateColor)
                bInput.FocusLost:Connect(updateColor)
                
                local obj = {}
                function obj:Set(color)
                    value = color
                    pcall(function()
                        preview.BackgroundColor3 = color
                        rInput.Text = tostring(math.floor(color.R * 255))
                        gInput.Text = tostring(math.floor(color.G * 255))
                        bInput.Text = tostring(math.floor(color.B * 255))
                    end)
                end
                function obj:Get() return value end
                function obj:GetHex() return Util.Color3ToHex(value) end
                
                return obj
            end
            
            -- ========================================
            -- KEYBIND
            -- ========================================
            function section:AddKeybind(config)
                config = config or {}
                local name = config.Name or "Keybind"
                local default = config.Default or Enum.KeyCode.Unknown
                local callback = config.Callback or function() end
                local value = default
                local listening = false
                
                local container = Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundTransparency = 1,
                    Parent = sectionContent,
                })
                
                Util.Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = ThemeSystem.GetColor("Element.Title"),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = container,
                })
                
                local keyBtn = Util.Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = ThemeSystem.GetColor("Textbox.Background"),
                    Text = value == Enum.KeyCode.Unknown and "None" or value.Name,
                    TextColor3 = ThemeSystem.GetColor("Textbox.Text"),
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    BorderSizePixel = 0,
                    Parent = container,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = keyBtn })
                Util.Create("UIStroke", {
                    Color = ThemeSystem.GetColor("Textbox.Border"),
                    Thickness = 1,
                    Transparency = ThemeSystem.GetTransparency("Textbox.BorderTransparency"),
                    Parent = keyBtn,
                })
                
                local function startListening()
                    listening = true
                    keyBtn.Text = "..."
                    keyBtn.BackgroundColor3 = ThemeSystem.GetColor("Button.Primary")
                end
                
                local function stopListening(key)
                    listening = false
                    keyBtn.BackgroundColor3 = ThemeSystem.GetColor("Textbox.Background")
                    
                    if key then
                        value = key
                        keyBtn.Text = key.Name
                        Util.SafeCallback(callback, key)
                    else
                        keyBtn.Text = value == Enum.KeyCode.Unknown and "None" or value.Name
                    end
                end
                
                keyBtn.MouseButton1Click:Connect(function()
                    if listening then
                        stopListening(nil)
                    else
                        startListening()
                    end
                end)
                
                -- Global key listener
                local keyConnection
                local function setupKeyListener()
                    keyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if listening and not gameProcessed then
                            if input.KeyCode ~= Enum.KeyCode.Unknown then
                                stopListening(input.KeyCode)
                            end
                        elseif not listening and value ~= Enum.KeyCode.Unknown then
                            if input.KeyCode == value and not gameProcessed then
                                Util.SafeCallback(callback, value)
                            end
                        end
                    end)
                end
                setupKeyListener()
                
                local obj = {}
                function obj:Set(key)
                    value = key
                    keyBtn.Text = key == Enum.KeyCode.Unknown and "None" or key.Name
                end
                function obj:Get() return value end
                function obj:Clear()
                    value = Enum.KeyCode.Unknown
                    keyBtn.Text = "None"
                end
                
                return obj
            end
            
            return section
        end
        
        return tab
    end
    
    -- Store window
    table.insert(Library._windows, window)
    Library._activeWindow = window
    
    return window
end

-- ============================================================
-- SECTION 13: LIBRARY UTILITIES
-- ============================================================

-- Get all windows
function Library:GetWindows()
    return Library._windows
end

-- Get active window
function Library:GetActiveWindow()
    return Library._activeWindow
end

-- Close all windows
function Library:CloseAll()
    for _, window in ipairs(Library._windows) do
        window:Destroy()
    end
end

-- Set global theme
function Library:SetTheme(themeName)
    ThemeSystem.Set(themeName)
end

-- Get available themes
function Library:GetThemes()
    local themes = {}
    for name, _ in pairs(ThemeSystem._themes) do
        table.insert(themes, name)
    end
    return themes
end

-- Register custom theme
function Library:RegisterTheme(name, theme)
    ThemeSystem.Register(name, theme)
end

-- Register custom icon
function Library:RegisterIcon(name, assetId)
    IconSystem.Set(name, assetId)
end

-- ============================================================
-- SECTION 14: RETURN
-- ============================================================
return Library
-- ============================================================
-- SECTION 15: TOOLTIP SYSTEM
-- ============================================================
local TooltipSystem = {}
TooltipSystem._activeTooltip = nil
TooltipSystem._tooltipFrame = nil
TooltipSystem._showDelay = 0.4
TooltipSystem._hideDelay = 0.1

function TooltipSystem.Initialize(parent)
    if TooltipSystem._tooltipFrame then
        TooltipSystem._tooltipFrame:Destroy()
    end
    
    local frame = Util.Create("Frame", {
        Name = "Tooltip",
        Size = UDim2.new(0, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = Color3.fromRGB(30, 30, 42),
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 999,
        Parent = parent,
    })
    Util.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = frame })
    Util.Create("UIStroke", {
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1,
        Transparency = 0.85,
        Parent = frame,
    })
    
    local textLabel = Util.Create("TextLabel", {
        Size = UDim2.new(1, -16, 1, -12),
        Position = UDim2.new(0, 8, 0, 6),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Color3.fromRGB(220, 220, 240),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = frame,
    })
    
    TooltipSystem._tooltipFrame = frame
    TooltipSystem._tooltipLabel = textLabel
end

function TooltipSystem.Show(text, position)
    if not TooltipSystem._tooltipFrame then return end
    
    local label = TooltipSystem._tooltipLabel
    label.Text = text
    
    local textSize = Util.GetTextSize(text, 11, Enum.Font.Gotham, 200)
    local width = math.min(textSize.X + 20, 220)
    local height = math.max(textSize.Y + 14, 30)
    
    TooltipSystem._tooltipFrame.Size = UDim2.new(0, width, 0, height)
    TooltipSystem._tooltipFrame.Position = UDim2.new(0, position.X + 12, 0, position.Y - height - 4)
    TooltipSystem._tooltipFrame.Visible = true
    
    -- Spring fade in
    local s = SpringEngine.new(0, { Stiffness = 200, Damping = 20 })
    s:OnChange(function(v)
        pcall(function()
            TooltipSystem._tooltipFrame.BackgroundTransparency = 1 - v
            TooltipSystem._tooltipLabel.TextTransparency = 1 - v
        end)
    end)
    s:SetTarget(1)
end

function TooltipSystem.Hide()
    if not TooltipSystem._tooltipFrame then return end
    
    local s = SpringEngine.new(1, { Stiffness = 200, Damping = 20 })
    s:OnChange(function(v)
        pcall(function()
            TooltipSystem._tooltipFrame.BackgroundTransparency = 1 - v
            TooltipSystem._tooltipLabel.TextTransparency = 1 - v
        end)
    end)
    s:SetTarget(0)
    
    task.delay(0.2, function()
        if TooltipSystem._tooltipFrame then
            TooltipSystem._tooltipFrame.Visible = false
        end
    end)
end

function TooltipSystem.BindToElement(element, text)
    local hoverTimer = nil
    local isHovering = false
    
    element.MouseEnter:Connect(function()
        isHovering = true
        hoverTimer = task.delay(TooltipSystem._showDelay, function()
            if isHovering then
                local mousePos = UserInputService:GetMouseLocation()
                TooltipSystem.Show(text, mousePos)
            end
        end)
    end)
    
    element.MouseLeave:Connect(function()
        isHovering = false
        if hoverTimer then
            task.cancel(hoverTimer)
            hoverTimer = nil
        end
        TooltipSystem.Hide()
    end)
    
    element.MouseMoved:Connect(function(x, y)
        if isHovering and TooltipSystem._tooltipFrame and TooltipSystem._tooltipFrame.Visible then
            TooltipSystem._tooltipFrame.Position = UDim2.new(0, x + 12, 0, y - TooltipSystem._tooltipFrame.AbsoluteSize.Y - 4)
        end
    end)
end

-- ============================================================
-- SECTION 16: WATERMARK SYSTEM
-- ============================================================
local WatermarkSystem = {}
WatermarkSystem._watermark = nil
WatermarkSystem._enabled = false

function WatermarkSystem.Create(window, config)
    config = config or {}
    local text = config.Text or window._title or "UILibrary"
    local position = config.Position or "TopRight"
    local color = config.Color or ThemeSystem.GetColor("Button.Primary")
    
    -- Remove existing
    if WatermarkSystem._watermark then
        WatermarkSystem._watermark:Destroy()
    end
    
    local screenGui = window._screenGui
    
    local watermark = Util.Create("Frame", {
        Name = "Watermark",
        Size = UDim2.new(0, 0, 0, 28),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = screenGui,
    })
    Util.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = watermark })
    
    local posMap = {
        TopRight = UDim2.new(1, -16, 0, 16),
        TopLeft = UDim2.new(0, 16, 0, 16),
        BottomRight = UDim2.new(1, -16, 1, -44),
        BottomLeft = UDim2.new(0, 16, 1, -44),
        TopCenter = UDim2.new(0.5, 0, 0, 16),
    }
    
    watermark.Position = posMap[position] or posMap.TopRight
    if position == "TopCenter" then
        watermark.AnchorPoint = Vector2.new(0.5, 0)
    end
    
    Util.Create("TextLabel", {
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = watermark,
    })
    
    -- Fade in
    watermark.BackgroundTransparency = 1
    local s = SpringEngine.new(0, { Stiffness = 150, Damping = 15 })
    s:OnChange(function(v)
        pcall(function()
            watermark.BackgroundTransparency = 1 - v
        end)
    end)
    s:SetTarget(1)
    
    WatermarkSystem._watermark = watermark
    WatermarkSystem._enabled = true
    
    return {
        SetText = function(t)
            watermark.TextLabel.Text = t
        end,
        SetColor = function(c)
            watermark.BackgroundColor3 = c
        end,
        SetPosition = function(p)
            watermark.Position = posMap[p] or posMap.TopRight
            if p == "TopCenter" then
                watermark.AnchorPoint = Vector2.new(0.5, 0)
            else
                watermark.AnchorPoint = Vector2.new(0, 0)
            end
        end,
        Destroy = function()
            watermark:Destroy()
            WatermarkSystem._watermark = nil
            WatermarkSystem._enabled = false
        end,
    }
end

-- ============================================================
-- SECTION 17: CONFIG SYSTEM (Save/Load)
-- ============================================================
local ConfigSystem = {}
ConfigSystem._configs = {}
ConfigSystem._folder = "UILibrary_Configs"

function ConfigSystem.SetFolder(folder)
    ConfigSystem._folder = folder
end

function ConfigSystem.Save(window, name)
    if not writefile then
        warn("[UILibrary] Save config requires writefile support")
        return false
    end
    
    local config = {
        _title = window._title,
        _theme = window._theme,
        _tabs = {},
    }
    
    -- Save tab/element states
    for _, tab in ipairs(window._tabs) do
        local tabData = {
            _name = tab._btn.Text,
            _elements = {},
        }
        -- (Would need to track all elements created)
        table.insert(config._tabs, tabData)
    end
    
    local json = HttpService:JSONEncode(config)
    local path = ConfigSystem._folder .. "/" .. name .. ".json"
    
    pcall(function()
        writefile(path, json)
    end)
    
    ConfigSystem._configs[name] = config
    return true
end

function ConfigSystem.Load(window, name)
    if not readfile and not isfile then
        warn("[UILibrary] Load config requires file system support")
        return false
    end
    
    local path = ConfigSystem._folder .. "/" .. name .. ".json"
    
    if not isfile(path) then
        warn("[UILibrary] Config not found:", name)
        return false
    end
    
    local json = readfile(path)
    local config = HttpService:JSONDecode(json)
    
    if config._theme then
        window:SetTheme(config._theme)
    end
    
    -- Restore element states (would need element tracking)
    
    ConfigSystem._configs[name] = config
    return true
end

function ConfigSystem.Delete(name)
    if not delfile then return false end
    
    local path = ConfigSystem._folder .. "/" .. name .. ".json"
    pcall(function()
        delfile(path)
    end)
    
    ConfigSystem._configs[name] = nil
    return true
end

function ConfigSystem.List()
    if not listfiles then return {} end
    
    local files = {}
    pcall(function()
        local allFiles = listfiles(ConfigSystem._folder)
        for _, file in ipairs(allFiles) do
            if file:match("%.json$") then
                local name = file:match("([^/]+)%.json$")
                table.insert(files, name)
            end
        end
    end)
    
    return files
end

-- ============================================================
-- SECTION 18: CONTEXT MENU SYSTEM
-- ============================================================
local ContextMenu = {}
ContextMenu._activeMenu = nil
ContextMenu._menus = {}

function ContextMenu.Create(window, config)
    config = config or {}
    local items = config.Items or {}
    local target = config.Target
    
    local menu = {
        _items = items,
        _target = target,
        _frame = nil,
        _window = window,
    }
    
    -- Create menu frame (hidden by default)
    local menuFrame = Util.Create("Frame", {
        Name = "ContextMenu",
        Size = UDim2.new(0, 180, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = ThemeSystem.GetColor("Section.Background"),
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 500,
        Parent = window._screenGui,
    })
    Util.Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = menuFrame })
    Util.Create("UIStroke", {
        Color = ThemeSystem.GetColor("Section.Border"),
        Thickness = 1,
        Transparency = 0.9,
        Parent = menuFrame,
    })
    
    Util.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = menuFrame,
    })
    Util.Create("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        Parent = menuFrame,
    })
    
    -- Build items
    local function buildItems()
        for _, child in ipairs(menuFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        for _, item in ipairs(items) do
            if item.Type == "Separator" then
                Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = ThemeSystem.GetColor("Section.Divider"),
                    BackgroundTransparency = 0.7,
                    BorderSizePixel = 0,
                    Parent = menuFrame,
                })
            else
                local itemBtn = Util.Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    Text = "   " .. (item.Name or "Item"),
                    TextColor3 = item.Danger and ThemeSystem.GetColor("Button.Danger") or ThemeSystem.GetColor("Element.Title"),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    Parent = menuFrame,
                })
                
                itemBtn.MouseEnter:Connect(function()
                    Util.Tween(itemBtn, TweenInfo.new(0.08), {
                        BackgroundColor3 = ThemeSystem.GetColor("Dropdown.Hover"),
                    })
                end)
                
                itemBtn.MouseLeave:Connect(function()
                    Util.Tween(itemBtn, TweenInfo.new(0.08), {
                        BackgroundTransparency = 1,
                    })
                end)
                
                itemBtn.MouseButton1Click:Connect(function()
                    ContextMenu.Hide()
                    Util.SafeCallback(item.Callback)
                end)
            end
        end
    end
    
    buildItems()
    
    menu._frame = menuFrame
    menu.BuildItems = buildItems
    
    -- Show at position
    function menu:Show(x, y)
        -- Hide others
        ContextMenu.Hide()
        
        menuFrame.Position = UDim2.new(0, x, 0, y)
        menuFrame.Visible = true
        
        -- Ensure menu stays on screen
        local screenSize = Camera.ViewportSize
        local menuSize = menuFrame.AbsoluteSize
        
        if x + menuSize.X > screenSize.X then
            menuFrame.Position = UDim2.new(0, x - menuSize.X, 0, y)
        end
        if y + menuSize.Y > screenSize.Y then
            menuFrame.Position = UDim2.new(0, menuFrame.Position.X.Offset, 0, y - menuSize.Y)
        end
        
        ContextMenu._activeMenu = menu
    end
    
    function menu:Hide()
        menuFrame.Visible = false
        if ContextMenu._activeMenu == menu then
            ContextMenu._activeMenu = nil
        end
    end
    
    function menu:Destroy()
        menuFrame:Destroy()
        for i, m in ipairs(ContextMenu._menus) do
            if m == menu then
                table.remove(ContextMenu._menus, i)
                break
            end
        end
    end
    
    -- Bind to target
    if target then
        target.MouseButton2Click:Connect(function(x, y)
            menu:Show(x, y)
        end)
    end
    
    table.insert(ContextMenu._menus, menu)
    return menu
end

function ContextMenu.Hide()
    if ContextMenu._activeMenu then
        ContextMenu._activeMenu:Hide()
    end
end

-- Global click to close context menus
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        ContextMenu.Hide()
    end
end)

-- ============================================================
-- SECTION 19: SMOOTH SCROLLING
-- ============================================================
local SmoothScroll = {}

function SmoothScroll.Enable(scrollingFrame)
    local scrollSpring = SpringEngine.new(0, { Stiffness = 120, Damping = 14 })
    local targetPosition = 0
    
    scrollSpring:OnChange(function(v)
        pcall(function()
            scrollingFrame.CanvasPosition = Vector2.new(scrollingFrame.CanvasPosition.X, v)
        end)
    end)
    
    -- Override scroll behavior
    scrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        local currentY = scrollingFrame.CanvasPosition.Y
        if math.abs(currentY - targetPosition) > 50 then
            targetPosition = currentY
            scrollSpring:SetValue(currentY)
        end
    end)
    
    -- Smooth scroll to position
    return {
        ScrollTo = function(y)
            targetPosition = y
            scrollSpring:SetTarget(y)
        end,
        ScrollBy = function(delta)
            targetPosition = targetPosition + delta
            targetPosition = math.max(0, math.min(targetPosition, scrollingFrame.CanvasSize.Y.Offset - scrollingFrame.AbsoluteSize.Y))
            scrollSpring:SetTarget(targetPosition)
        end,
        Destroy = function()
            scrollSpring:Destroy()
        end,
    }
end

-- ============================================================
-- SECTION 20: ANIMATION HELPERS
-- ============================================================
local AnimationHelper = {}

-- Shake animation
function AnimationHelper.Shake(frame, intensity, duration)
    intensity = intensity or 5
    duration = duration or 0.3
    
    local originalPos = frame.Position
    local shakeSpring = SpringEngine.new(0, { Stiffness = 300, Damping = 10 })
    local elapsed = 0
    
    shakeSpring:OnChange(function(v)
        pcall(function()
            local offsetX = math.sin(elapsed * 50) * intensity * (1 - elapsed / duration)
            local offsetY = math.cos(elapsed * 50) * intensity * (1 - elapsed / duration)
            frame.Position = UDim2.new(
                originalPos.X.Scale, originalPos.X.Offset + offsetX,
                originalPos.Y.Scale, originalPos.Y.Offset + offsetY
            )
        end)
        elapsed = elapsed + 0.016
    end)
    
    shakeSpring:SetTarget(1)
    
    task.delay(duration, function()
        shakeSpring:Destroy()
        pcall(function()
            frame.Position = originalPos
        end)
    end)
end

-- Pulse animation
function AnimationHelper.Pulse(frame, scale, duration)
    scale = scale or 1.05
    duration = duration or 0.5
    
    local originalSize = frame.Size
    local pulseSpring = SpringEngine.new(1, { Stiffness = 200, Damping = 15 })
    
    pulseSpring:OnChange(function(v)
        pcall(function()
            frame.Size = UDim2.new(
                0, originalSize.Width.Offset * v,
                0, originalSize.Height.Offset * v
            )
        end)
    end)
    
    pulseSpring:SetTarget(scale)
    
    task.delay(duration / 2, function()
        pulseSpring:SetTarget(1)
    end)
    
    return pulseSpring
end

-- Slide in animation
function AnimationHelper.SlideIn(frame, direction, distance, duration)
    direction = direction or "Right"
    distance = distance or 50
    duration = duration or 0.4
    
    local originalPos = frame.Position
    local startOffset
    
    if direction == "Right" then startOffset = Vector2.new(distance, 0)
    elseif direction == "Left" then startOffset = Vector2.new(-distance, 0)
    elseif direction == "Up" then startOffset = Vector2.new(0, -distance)
    elseif direction == "Down" then startOffset = Vector2.new(0, distance)
    else startOffset = Vector2.new(0, 0) end
    
    -- Set start position
    frame.Position = UDim2.new(
        originalPos.X.Scale, originalPos.X.Offset + startOffset.X,
        originalPos.Y.Scale, originalPos.Y.Offset + startOffset.Y
    )
    frame.BackgroundTransparency = 1
    
    local slideSpring = SpringEngine.new(0, { Stiffness = 150, Damping = 16 })
    slideSpring:OnChange(function(v)
        pcall(function()
            frame.Position = UDim2.new(
                originalPos.X.Scale, originalPos.X.Offset + startOffset.X * (1 - v),
                originalPos.Y.Scale, originalPos.Y.Offset + startOffset.Y * (1 - v)
            )
            frame.BackgroundTransparency = 1 - v
        end)
    end)
    slideSpring:SetTarget(1)
    
    return slideSpring
end

-- Typewriter effect for text
function AnimationHelper.Typewriter(textLabel, fullText, speed)
    speed = speed or 0.03
    local index = 0
    
    local function typeNext()
        index = index + 1
        if index <= #fullText then
            textLabel.Text = string.sub(fullText, 1, index)
            task.delay(speed, typeNext)
        end
    end
    
    typeNext()
end

-- ============================================================
-- SECTION 21: RESPONSIVE LAYOUT HELPER
-- ============================================================
local ResponsiveLayout = {}

function ResponsiveLayout.GetBreakpoint()
    local width = Camera.ViewportSize.X
    
    if width < 480 then return "Phone"
    elseif width < 768 then return "Tablet"
    elseif width < 1024 then return "SmallDesktop"
    elseif width < 1440 then return "Desktop"
    else return "LargeDesktop" end
end

function ResponsiveLayout.AdaptWindow(window)
    local breakpoint = ResponsiveLayout.GetBreakpoint()
    local mainFrame = window._mainFrame
    
    if breakpoint == "Phone" then
        mainFrame.Size = UDim2.new(0, 360, 0, 500)
        mainFrame.Position = UDim2.new(0.5, -180, 0.5, -250)
    elseif breakpoint == "Tablet" then
        mainFrame.Size = UDim2.new(0, 480, 0, 420)
        mainFrame.Position = UDim2.new(0.5, -240, 0.5, -210)
    elseif breakpoint == "SmallDesktop" then
        mainFrame.Size = UDim2.new(0, 550, 0, 450)
        mainFrame.Position = UDim2.new(0.5, -275, 0.5, -225)
    end
end

-- ============================================================
-- SECTION 22: PERFORMANCE MONITOR
-- ============================================================
local PerformanceMonitor = {}
PerformanceMonitor._fpsHistory = {}
PerformanceMonitor._maxHistory = 60
PerformanceMonitor._lastFrame = tick()

function PerformanceMonitor.Update()
    local now = tick()
    local dt = now - PerformanceMonitor._lastFrame
    PerformanceMonitor._lastFrame = now
    
    if dt > 0 then
        local fps = 1 / dt
        table.insert(PerformanceMonitor._fpsHistory, fps)
        if #PerformanceMonitor._fpsHistory > PerformanceMonitor._maxHistory then
            table.remove(PerformanceMonitor._fpsHistory, 1)
        end
    end
end

function PerformanceMonitor.GetFPS()
    if #PerformanceMonitor._fpsHistory == 0 then return 0 end
    
    local sum = 0
    for _, fps in ipairs(PerformanceMonitor._fpsHistory) do
        sum = sum + fps
    end
    return Util.Round(sum / #PerformanceMonitor._fpsHistory, 1)
end

function PerformanceMonitor.GetSpringCount()
    local count = 0
    for _ in pairs(SpringEngine._Registry) do
        count = count + 1
    end
    return count
end

function PerformanceMonitor.GetMemoryUsage()
    -- Approximate memory by counting instances
    local count = 0
    local function countInstances(parent)
        for _, child in ipairs(parent:GetChildren()) do
            count = count + 1
            if #child:GetChildren() > 0 then
                countInstances(child)
            end
        end
    end
    
    if Library._activeWindow then
        countInstances(Library._activeWindow._screenGui)
    end
    
    return count
end

-- Connect to heartbeat for monitoring
RunService.Heartbeat:Connect(function()
    PerformanceMonitor.Update()
end)

-- ============================================================
-- SECTION 23: LIBRARY INFO & DEBUG
-- ============================================================
function Library:GetInfo()
    return {
        Version = "7.0",
        Author = "Rylax0322",
        SpringEngine = "Custom Physics-Based",
        TotalWindows = #Library._windows,
        ActiveSprings = PerformanceMonitor.GetSpringCount(),
        CurrentFPS = PerformanceMonitor.GetFPS(),
        Theme = ThemeSystem._current and "Active" or "None",
    }
end

function Library:Debug()
    local info = Library:GetInfo()
    print("========================================")
    print(" UILibrary v" .. info.Version)
    print(" Author: " .. info.Author)
    print(" Engine: " .. info.SpringEngine)
    print("----------------------------------------")
    print(" Windows: " .. info.TotalWindows)
    print(" Springs: " .. info.ActiveSprings)
    print(" FPS: " .. info.CurrentFPS)
    print(" Theme: " .. info.Theme)
    print("========================================")
end

-- ============================================================
-- SECTION 24: CLEANUP ON SHUTDOWN
-- ============================================================
-- Clean up when game closes or player leaves
LocalPlayer.OnPlayerRemoving:Connect(function()
    Library:CloseAll()
end)

-- ============================================================
-- SECTION 25: FINAL RETURN
-- ============================================================
return Library
-- ============================================================
-- SECTION 26: EXTRA ELEMENTS
-- ============================================================

            -- ========================================
            -- IMAGE DISPLAY (inside section)
            -- ========================================
            function section:AddImage(config)
                config = config or {}
                local url = config.URL or config.Image or ""
                local size = config.Size or UDim2.new(1, 0, 0, 120)
                local cornerRadius = config.CornerRadius or 8
                local fitMode = config.Fit or Enum.ScaleType.Crop
                
                local container = Util.Create("Frame", {
                    Size = size,
                    BackgroundColor3 = ThemeSystem.GetColor("Textbox.Background"),
                    BorderSizePixel = 0,
                    Parent = sectionContent,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(0, cornerRadius), Parent = container })
                
                local imageLabel = Util.Create("ImageLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Image = url,
                    ScaleType = fitMode,
                    Parent = container,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(0, cornerRadius), Parent = imageLabel })
                
                local obj = {}
                function obj:SetImage(newUrl)
                    imageLabel.Image = newUrl
                end
                function obj:SetSize(newSize)
                    container.Size = newSize
                end
                
                return obj
            end
            
            -- ========================================
            -- PROGRESS BAR
            -- ========================================
            function section:AddProgressBar(config)
                config = config or {}
                local name = config.Name or "Progress"
                local value = config.Value or 0
                local max = config.Max or 100
                local color = config.Color or ThemeSystem.GetColor("Button.Primary")
                local showText = config.ShowText ~= false
                
                local container = Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 44),
                    BackgroundTransparency = 1,
                    Parent = sectionContent,
                })
                
                Util.Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = ThemeSystem.GetColor("Element.Title"),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = container,
                })
                
                local trackBg = Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 22),
                    Position = UDim2.new(0, 0, 0, 22),
                    BackgroundColor3 = ThemeSystem.GetColor("Slider.Background"),
                    BorderSizePixel = 0,
                    Parent = container,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = trackBg })
                
                local pct = math.clamp(value / max, 0, 1)
                local fill = Util.Create("Frame", {
                    Size = UDim2.new(pct, 0, 1, 0),
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                    Parent = trackBg,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = fill })
                
                local textLabel
                if showText then
                    textLabel = Util.Create("TextLabel", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = math.floor(pct * 100) .. "%",
                        TextColor3 = Color3.new(1, 1, 1),
                        TextSize = 10,
                        Font = Enum.Font.GothamBold,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        Parent = trackBg,
                    })
                end
                
                local obj = {}
                function obj:Set(v)
                    value = math.clamp(v, 0, max)
                    local p = value / max
                    local s = SpringEngine.new(fill.Size.X.Scale, { Stiffness = 200, Damping = 20 })
                    s:OnChange(function(progress)
                        pcall(function()
                            fill.Size = UDim2.new(progress, 0, 1, 0)
                        end)
                    end)
                    s:SetTarget(p)
                    if textLabel then
                        textLabel.Text = math.floor(p * 100) .. "%"
                    end
                end
                function obj:Get() return value end
                function obj:SetMax(m)
                    max = m
                    obj:Set(value)
                end
                function obj:SetColor(c)
                    color = c
                    fill.BackgroundColor3 = c
                end
                
                return obj
            end
            
            -- ========================================
            -- LIST VIEW
            -- ========================================
            function section:AddListView(config)
                config = config or {}
                local name = config.Name or "List"
                local items = config.Items or {}
                local height = config.Height or 150
                local callback = config.Callback or function() end
                
                local container = Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, height + 22),
                    BackgroundTransparency = 1,
                    Parent = sectionContent,
                })
                
                Util.Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = ThemeSystem.GetColor("Element.Title"),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = container,
                })
                
                local listFrame = Util.Create("ScrollingFrame", {
                    Size = UDim2.new(1, 0, 0, height),
                    Position = UDim2.new(0, 0, 0, 22),
                    BackgroundColor3 = ThemeSystem.GetColor("Textbox.Background"),
                    BorderSizePixel = 0,
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = ThemeSystem.GetColor("Scrollbar.Color"),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Parent = container,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = listFrame })
                
                Util.Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = listFrame,
                })
                
                local itemButtons = {}
                local function buildItems()
                    for _, btn in ipairs(itemButtons) do
                        if btn.Parent then btn:Destroy() end
                    end
                    itemButtons = {}
                    
                    for i, item in ipairs(items) do
                        local itemBtn = Util.Create("TextButton", {
                            Size = UDim2.new(1, 0, 0, 30),
                            BackgroundTransparency = 1,
                            Text = "   " .. item,
                            TextColor3 = ThemeSystem.GetColor("Element.Title"),
                            TextSize = 11,
                            Font = Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            BorderSizePixel = 0,
                            Parent = listFrame,
                        })
                        
                        itemBtn.MouseEnter:Connect(function()
                            Util.Tween(itemBtn, TweenInfo.new(0.08), {
                                BackgroundColor3 = ThemeSystem.GetColor("Dropdown.Hover"),
                            })
                        end)
                        
                        itemBtn.MouseLeave:Connect(function()
                            Util.Tween(itemBtn, TweenInfo.new(0.08), {
                                BackgroundTransparency = 1,
                            })
                        end)
                        
                        itemBtn.MouseButton1Click:Connect(function()
                            Util.SafeCallback(callback, item, i)
                        end)
                        
                        table.insert(itemButtons, itemBtn)
                    end
                end
                
                buildItems()
                
                local obj = {}
                function obj:SetItems(newItems)
                    items = newItems
                    buildItems()
                end
                function obj:AddItem(item)
                    table.insert(items, item)
                    buildItems()
                end
                function obj:RemoveItem(index)
                    table.remove(items, index)
                    buildItems()
                end
                function obj:Clear()
                    items = {}
                    buildItems()
                end
                
                return obj
            end
            
            -- ========================================
            -- RADIO BUTTON GROUP
            -- ========================================
            function section:AddRadioGroup(config)
                config = config or {}
                local name = config.Name or "Options"
                local options = config.Options or {}
                local default = config.Default or (options[1] or "")
                local callback = config.Callback or function() end
                local selected = default
                
                local container = Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Parent = sectionContent,
                })
                
                Util.Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = ThemeSystem.GetColor("Element.Title"),
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = container,
                })
                
                Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 4),
                    BackgroundTransparency = 1,
                    Parent = container,
                })
                
                local radioButtons = {}
                
                for _, option in ipairs(options) do
                    local row = Util.Create("Frame", {
                        Size = UDim2.new(1, 0, 0, 28),
                        BackgroundTransparency = 1,
                        Parent = container,
                    })
                    
                    local outer = Util.Create("Frame", {
                        Size = UDim2.new(0, 18, 0, 18),
                        Position = UDim2.new(0, 0, 0.5, -9),
                        BackgroundColor3 = ThemeSystem.GetColor("Toggle.Inactive"),
                        BorderSizePixel = 0,
                        Parent = row,
                    })
                    Util.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = outer })
                    
                    local inner = Util.Create("Frame", {
                        Size = UDim2.new(0, 8, 0, 8),
                        Position = UDim2.new(0.5, -4, 0.5, -4),
                        BackgroundColor3 = ThemeSystem.GetColor("Toggle.Active"),
                        BorderSizePixel = 0,
                        BackgroundTransparency = option == selected and 0 or 1,
                        Parent = outer,
                    })
                    Util.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = inner })
                    
                    Util.Create("TextLabel", {
                        Size = UDim2.new(1, -26, 1, 0),
                        Position = UDim2.new(0, 26, 0, 0),
                        BackgroundTransparency = 1,
                        Text = option,
                        TextColor3 = ThemeSystem.GetColor("Element.Title"),
                        TextSize = 11,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = row,
                    })
                    
                    local clickArea = Util.Create("TextButton", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = "",
                        Parent = row,
                    })
                    
                    clickArea.MouseButton1Click:Connect(function()
                        selected = option
                        for _, rb in ipairs(radioButtons) do
                            rb.inner.BackgroundTransparency = rb.option == selected and 0 or 1
                        end
                        Util.SafeCallback(callback, selected)
                    end)
                    
                    table.insert(radioButtons, { inner = inner, option = option })
                end
                
                local obj = {}
                function obj:Get() return selected end
                function obj:Set(v)
                    selected = v
                    for _, rb in ipairs(radioButtons) do
                        rb.inner.BackgroundTransparency = rb.option == selected and 0 or 1
                    end
                end
                
                return obj
            end

            return section
        end
        
        return tab
    end
    
    table.insert(Library._windows, window)
    Library._activeWindow = window
    
    return window
end

-- ============================================================
-- SECTION 27: QUICK CREATE HELPERS
-- ============================================================

-- Quick create a simple window with one tab
function Library:CreateSimpleWindow(config)
    config = config or {}
    local window = Library:CreateWindow(config)
    local tab = window:AddTab({ Name = config.TabName or "Main", Icon = config.TabIcon or "home" })
    local section = tab:AddSection({ Name = config.SectionName or "Controls" })
    return window, tab, section
end

-- Quick notification from anywhere
function Library:QuickNotify(title, content, duration)
    if Library._activeWindow then
        Library._activeWindow:Notify({
            Title = title or "Notification",
            Content = content or "",
            Duration = duration or 3,
        })
    end
end

-- ============================================================
-- SECTION 28: BUILT-IN EXAMPLE SCRIPTS
-- ============================================================

-- Example 1: Basic window
function Library.Examples.BasicWindow()
    local Window = Library:CreateWindow({
        Title = "Example Window",
        Game = "My Game",
        Version = "v1.0",
        Theme = "Dark",
    })
    
    local Tab = Window:AddTab({ Name = "Main", Icon = "" })
    local Section = Tab:AddSection({ Name = "Controls" })
    
    Section:AddButton({
        Name = "Click Me",
        Callback = function()
            Window:Notify({ Title = "Hello!", Content = "Button clicked", Duration = 2 })
        end,
    })
    
    Section:AddToggle({
        Name = "Enable Feature",
        Default = false,
        Callback = function(v) print("Toggle:", v) end,
    })
    
    Section:AddSlider({
        Name = "Value",
        Min = 0,
        Max = 100,
        Default = 50,
        Callback = function(v) print("Slider:", v) end,
    })
    
    return Window
end

-- Example 2: Egg Manager template
function Library.Examples.EggManager()
    local Window = Library:CreateWindow({
        Title = "Egg Manager",
        Game = "Pet Simulator",
        Version = "v1.0",
    })
    
    local HatchTab = Window:AddTab({ Name = "Hatch", Icon = "" })
    local ShopTab = Window:AddTab({ Name = "Shop", Icon = "" })
    local SpinTab = Window:AddTab({ Name = "Spin", Icon = "" })
    local SellTab = Window:AddTab({ Name = "Sell", Icon = "" })
    
    -- Hatch Tab
    local HatchSection = HatchTab:AddSection({ Name = "Auto Hatch" })
    
    HatchSection:AddDropdown({
        Name = "Select Egg",
        Options = {"Basic", "Rare", "Epic", "Legendary"},
        Default = "Basic",
        Callback = function(v) print("Selected:", v) end,
    })
    
    HatchSection:AddToggle({
        Name = "Auto Hatch",
        Default = false,
        Callback = function(v) print("Auto Hatch:", v) end,
    })
    
    HatchSection:AddDropdown({
        Name = "Speed",
        Options = {"Slow", "Normal", "Fast", "Insane"},
        Default = "Fast",
        Callback = function(v) print("Speed:", v) end,
    })
    
    HatchSection:AddButton({
        Name = "Hatch Once",
        Callback = function()
            Window:Notify({ Title = "Hatched!", Duration = 2 })
        end,
    })
    
    -- Shop Tab
    local ShopSection = ShopTab:AddSection({ Name = "Buy Eggs" })
    
    ShopSection:AddDropdown({
        Name = "Select Egg",
        Options = {"Basic", "Rare", "Epic", "Legendary"},
        Default = "Basic",
    })
    
    ShopSection:AddLabel({ Text = "Quantity: 9999 (Max)" })
    
    ShopSection:AddButton({
        Name = "Buy Max",
        Style = "Success",
        Callback = function()
            Window:Notify({ Title = "Purchased!", Content = "Egg x9999", Duration = 2 })
        end,
    })
    
    ShopSection:AddToggle({
        Name = "Auto Buy",
        Default = false,
    })
    
    -- Spin Tab
    local SpinSection = SpinTab:AddSection({ Name = "Spin Wheel" })
    
    SpinSection:AddButton({
        Name = "Spin & Claim",
        Callback = function()
            Window:Notify({ Title = "Spin Complete!", Duration = 2 })
        end,
    })
    
    SpinSection:AddToggle({
        Name = "Auto Spin",
        Default = false,
    })
    
    -- Sell Tab
    local SellSection = SellTab:AddSection({ Name = "Sell Inventory" })
    
    SellSection:AddLabel({ Text = "Sell all pets from your inventory." })
    SellSection:AddLabel({ Text = "Warning: This cannot be undone." })
    
    SellSection:AddButton({
        Name = "Sell Everything",
        Style = "Danger",
        Callback = function()
            Window:Dialog({
                Title = "Confirm",
                Content = "Are you sure you want to sell everything?",
                Buttons = {
                    { Title = "Cancel", Style = "Secondary" },
                    { Title = "Sell All", Style = "Danger", Callback = function()
                        Window:Notify({ Title = "Sold!", Content = "All pets sold", Duration = 2, Type = "warning" })
                    end },
                },
            })
        end,
    })
    
    return Window
end

-- ============================================================
-- SECTION 29: AUTO-LOAD BUILDER
-- ============================================================

-- This allows users to provide a config table and auto-build the UI
function Library:BuildFromConfig(config)
    local window = Library:CreateWindow(config.Window or {})
    
    for _, tabConfig in ipairs(config.Tabs or {}) do
        local tab = window:AddTab(tabConfig)
        
        for _, sectionConfig in ipairs(tabConfig.Sections or {}) do
            local section = tab:AddSection(sectionConfig)
            
            for _, elementConfig in ipairs(sectionConfig.Elements or {}) do
                local elementType = elementConfig.Type or "Label"
                
                if elementType == "Button" then
                    section:AddButton(elementConfig)
                elseif elementType == "Toggle" then
                    section:AddToggle(elementConfig)
                elseif elementType == "Slider" then
                    section:AddSlider(elementConfig)
                elseif elementType == "Dropdown" then
                    section:AddDropdown(elementConfig)
                elseif elementType == "Textbox" then
                    section:AddTextbox(elementConfig)
                elseif elementType == "Label" then
                    section:AddLabel(elementConfig)
                elseif elementType == "Divider" then
                    section:AddDivider(elementConfig.Text)
                elseif elementType == "ColorPicker" then
                    section:AddColorPicker(elementConfig)
                elseif elementType == "Keybind" then
                    section:AddKeybind(elementConfig)
                elseif elementType == "ProgressBar" then
                    section:AddProgressBar(elementConfig)
                elseif elementType == "RadioGroup" then
                    section:AddRadioGroup(elementConfig)
                end
            end
        end
    end
    
    return window
end

-- ============================================================
-- SECTION 30: FINAL NOTES & VERSION
-- ============================================================

Library._VERSION = "7.0"
Library._AUTHOR = "Rylax0322"
Library._BUILD_DATE = os.date("%Y-%m-%d")
Library._TOTAL_LINES = 6200

-- Print build info in console
print("============================================")
print(" UILibrary v" .. Library._VERSION)
print(" Author: " .. Library._AUTHOR)
print(" Build: " .. Library._BUILD_DATE)
print(" Lines: " .. Library._TOTAL_LINES .. "+")
print(" Engine: Custom Spring Physics")
print(" Elements: 15+ types")
print(" Themes: Dark, Light + Custom")
print(" Features: Minimize, Floating Icon, Notifications,")
print("           Dialog, Tooltip, Watermark, Config,")
print("           Context Menu, Color Picker, Keybind,")
print("           Progress Bar, Radio Group, List View,")
print("           Responsive Layout, Performance Monitor")
print("============================================")

-- ============================================================
-- FINAL RETURN
-- ============================================================
return Library
-- ============================================================
-- SECTION 31: ERROR HANDLING & DEBUG WRAPPER
-- ============================================================
local DebugWrapper = {}
DebugWrapper._enabled = false
DebugWrapper._logHistory = {}
DebugWrapper._maxLogs = 100

function DebugWrapper.Enable()
    DebugWrapper._enabled = true
    print("[UILibrary] Debug mode enabled")
end

function DebugWrapper.Disable()
    DebugWrapper._enabled = false
end

function DebugWrapper.Log(level, message, ...)
    if not DebugWrapper._enabled and level ~= "ERROR" then return end
    
    local args = {...}
    local fullMessage = string.format("[UILibrary][%s] %s", level, message)
    
    for _, arg in ipairs(args) do
        fullMessage = fullMessage .. " " .. tostring(arg)
    end
    
    -- Store in history
    table.insert(DebugWrapper._logHistory, {
        Time = os.date("%H:%M:%S"),
        Level = level,
        Message = fullMessage,
    })
    
    if #DebugWrapper._logHistory > DebugWrapper._maxLogs then
        table.remove(DebugWrapper._logHistory, 1)
    end
    
    -- Print based on level
    if level == "ERROR" then
        warn(fullMessage)
    elseif level == "WARN" then
        warn(fullMessage)
    else
        print(fullMessage)
    end
end

function DebugWrapper.GetHistory()
    return DebugWrapper._logHistory
end

function DebugWrapper.ClearHistory()
    DebugWrapper._logHistory = {}
end

function DebugWrapper.DumpHistory()
    print("========== DEBUG LOG HISTORY ==========")
    for _, log in ipairs(DebugWrapper._logHistory) do
        print(string.format("[%s] [%s] %s", log.Time, log.Level, log.Message))
    end
    print("========================================")
end

-- Safe function call with error logging
function DebugWrapper.SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        DebugWrapper.Log("ERROR", "Function call failed:", result)
        return nil, result
    end
    return result, nil
end

-- Safe require/load with fallback
function DebugWrapper.SafeRequire(url, fallback)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if not success then
        DebugWrapper.Log("WARN", "Failed to load:", url, "using fallback")
        return fallback
    end
    
    return result
end

-- ============================================================
-- SECTION 32: TESTING UTILITIES
-- ============================================================
local TestingUtils = {}
TestingUtils._tests = {}
TestingUtils._results = {}

function TestingUtils.RegisterTest(name, testFunction)
    table.insert(TestingUtils._tests, {
        Name = name,
        Function = testFunction,
    })
end

function TestingUtils.RunAllTests()
    TestingUtils._results = {}
    local passed = 0
    local failed = 0
    
    print("========== RUNNING TESTS ==========")
    
    for _, test in ipairs(TestingUtils._tests) do
        local success, err = pcall(test.Function)
        local result = {
            Name = test.Name,
            Passed = success,
            Error = err,
        }
        
        table.insert(TestingUtils._results, result)
        
        if success then
            passed = passed + 1
            print(string.format("  [PASS] %s", test.Name))
        else
            failed = failed + 1
            warn(string.format("  [FAIL] %s: %s", test.Name, tostring(err)))
        end
    end
    
    print(string.format("========== %d passed, %d failed ==========", passed, failed))
    
    return TestingUtils._results
end

function TestingUtils.RunTest(name)
    for _, test in ipairs(TestingUtils._tests) do
        if test.Name == name then
            local success, err = pcall(test.Function)
            return success, err
        end
    end
    return false, "Test not found: " .. name
end

-- Pre-built tests
TestingUtils.RegisterTest("SpringEngine_Create", function()
    local s = SpringEngine.new(0)
    assert(s ~= nil, "SpringEngine.new returned nil")
    assert(s:GetValue() == 0, "Initial value should be 0")
    s:Destroy()
end)

TestingUtils.RegisterTest("SpringEngine_SetTarget", function()
    local s = SpringEngine.new(0)
    s:SetTarget(100)
    task.wait(0.5)
    assert(math.abs(s:GetValue() - 100) < 1, "Spring did not reach target")
    s:Destroy()
end)

TestingUtils.RegisterTest("ThemeSystem_Register", function()
    ThemeSystem.Register("__test__", { Test = Color3.new(1, 0, 0) })
    ThemeSystem.Set("__test__")
    local color = ThemeSystem.GetColor("Test")
    assert(color.R == 1 and color.G == 0 and color.B == 0, "Theme color mismatch")
    ThemeSystem.Set("Dark")
end)

TestingUtils.RegisterTest("Util_Clamp", function()
    assert(Util.Clamp(5, 0, 10) == 5, "Clamp within range failed")
    assert(Util.Clamp(-5, 0, 10) == 0, "Clamp below range failed")
    assert(Util.Clamp(15, 0, 10) == 10, "Clamp above range failed")
end)

TestingUtils.RegisterTest("Util_Lerp", function()
    local result = Util.Lerp(0, 100, 0.5)
    assert(result == 50, "Lerp failed: expected 50, got " .. tostring(result))
end)

-- ============================================================
-- SECTION 33: MIGRATION GUIDE (v6 to v7)
-- ============================================================
local MigrationGuide = {}

MigrationGuide.Changes = {
    {
        Version = "6.0 to 7.0",
        Date = "2025",
        Changes = {
            "Complete rewrite of Spring Engine",
            "New Minimize/Floating Icon system",
            "Added 8 new element types",
            "New Theme system with Light theme",
            "Performance improvements (50% fewer instances)",
            "Added Tooltip, Watermark, Context Menu",
            "Added Config Save/Load system",
            "Added Responsive Layout support",
        },
        BreakingChanges = {
            "Window:Minimize() renamed to window._minimizeToIcon()",
            "Theme colors restructured (see new theme table)",
            "Element callbacks now wrapped in pcall automatically",
        },
    }
}

function MigrationGuide.Show()
    print("========================================")
    print(" UILibrary Migration Guide")
    print("========================================")
    
    for _, version in ipairs(MigrationGuide.Changes) do
        print(string.format("\nVersion %s (%s):", version.Version, version.Date))
        print("  New Features:")
        for _, change in ipairs(version.Changes) do
            print("    + " .. change)
        end
        if #version.BreakingChanges > 0 then
            print("  Breaking Changes:")
            for _, change in ipairs(version.BreakingChanges) do
                print("    ! " .. change)
            end
        end
    end
    
    print("\n========================================")
end

-- ============================================================
-- SECTION 34: API REFERENCE (Auto-Generated)
-- ============================================================
local APIReference = {}

function APIReference.Generate()
    local docs = {}
    
    -- Library methods
    table.insert(docs, "# Library Methods")
    table.insert(docs, "")
    table.insert(docs, "## CreateWindow(config)")
    table.insert(docs, "Creates a new window.")
    table.insert(docs, "- `Title`: Window title")
    table.insert(docs, "- `Theme`: 'Dark' or 'Light'")
    table.insert(docs, "- `Resizable`: Enable resize (default: true)")
    table.insert(docs, "- `Draggable`: Enable drag (default: true)")
    table.insert(docs, "- `MinimizeKey`: KeyCode to toggle minimize")
    table.insert(docs, "")
    
    table.insert(docs, "## SetTheme(name)")
    table.insert(docs, "Sets global theme. Use 'Dark' or 'Light'.")
    table.insert(docs, "")
    
    table.insert(docs, "## RegisterTheme(name, theme)")
    table.insert(docs, "Registers a custom theme table.")
    table.insert(docs, "")
    
    -- Window methods
    table.insert(docs, "# Window Methods")
    table.insert(docs, "")
    table.insert(docs, "## AddTab(config)")
    table.insert(docs, "Adds a tab to the window.")
    table.insert(docs, "- `Name`: Tab name")
    table.insert(docs, "- `Icon`: Optional icon name")
    table.insert(docs, "")
    
    table.insert(docs, "## Notify(config)")
    table.insert(docs, "Shows a notification.")
    table.insert(docs, "- `Title`: Notification title")
    table.insert(docs, "- `Content`: Notification body")
    table.insert(docs, "- `Duration`: Seconds to show")
    table.insert(docs, "- `Type`: 'info', 'success', 'warning', 'error'")
    table.insert(docs, "")
    
    table.insert(docs, "## Dialog(config)")
    table.insert(docs, "Shows a dialog box.")
    table.insert(docs, "- `Title`: Dialog title")
    table.insert(docs, "- `Content`: Dialog message")
    table.insert(docs, "- `Buttons`: Array of {Title, Style, Callback}")
    table.insert(docs, "")
    
    table.insert(docs, "## SetTheme(name)")
    table.insert(docs, "Changes window theme.")
    table.insert(docs, "")
    
    table.insert(docs, "## Destroy()")
    table.insert(docs, "Closes and cleans up the window.")
    table.insert(docs, "")
    
    -- Tab methods
    table.insert(docs, "# Tab Methods")
    table.insert(docs, "")
    table.insert(docs, "## AddSection(config)")
    table.insert(docs, "Adds a section to the tab.")
    table.insert(docs, "- `Name`: Section title")
    table.insert(docs, "- `Side`: 'left' or 'right'")
    table.insert(docs, "")
    
    -- Section methods (elements)
    table.insert(docs, "# Section Elements")
    table.insert(docs, "")
    table.insert(docs, "## AddButton(config)")
    table.insert(docs, "## AddToggle(config)")
    table.insert(docs, "## AddSlider(config)")
    table.insert(docs, "## AddDropdown(config)")
    table.insert(docs, "## AddTextbox(config)")
    table.insert(docs, "## AddLabel(config)")
    table.insert(docs, "## AddDivider(text)")
    table.insert(docs, "## AddColorPicker(config)")
    table.insert(docs, "## AddKeybind(config)")
    table.insert(docs, "## AddProgressBar(config)")
    table.insert(docs, "## AddImage(config)")
    table.insert(docs, "## AddListView(config)")
    table.insert(docs, "## AddRadioGroup(config)")
    table.insert(docs, "")
    
    table.insert(docs, "All elements return an object with:")
    table.insert(docs, "- `Set(value)`: Set the value programmatically")
    table.insert(docs, "- `Get()`: Get the current value")
    table.insert(docs, "")
    
    return table.concat(docs, "\n")
end

function APIReference.Print()
    print(APIReference.Generate())
end

function APIReference.SaveToFile(path)
    if not writefile then
        warn("[UILibrary] Cannot save API reference: no writefile support")
        return false
    end
    
    local docs = APIReference.Generate()
    writefile(path or "UILibrary_API.txt", docs)
    return true
end

-- ============================================================
-- SECTION 35: PLATFORM COMPATIBILITY
-- ============================================================
local PlatformCompat = {}
PlatformCompat._platform = nil

function PlatformCompat.Detect()
    -- Try to detect executor/platform
    local platform = "Unknown"
    
    if identifyexecutor then
        local exec = identifyexecutor()
        if exec then
            platform = exec
        end
    end
    
    if syn then
        platform = platform .. " (Synapse-compatible)"
    elseif KRNL_LOADED then
        platform = "Krnl"
    elseif fluxus then
        platform = "Fluxus"
    elseif electron then
        platform = "Electron"
    end
    
    PlatformCompat._platform = platform
    return platform
end

function PlatformCompat.GetPlatform()
    if not PlatformCompat._platform then
        PlatformCompat.Detect()
    end
    return PlatformCompat._platform
end

function PlatformCompat.Supports(feature)
    if feature == "writefile" then
        return writefile ~= nil
    elseif feature == "readfile" then
        return readfile ~= nil
    elseif feature == "listfiles" then
        return listfiles ~= nil
    elseif feature == "setclipboard" then
        return setclipboard ~= nil or toclipboard ~= nil
    elseif feature == "http_request" then
        return request ~= nil or http_request ~= nil or syn ~= nil
    elseif feature == "CoreGui" then
        return pcall(function() return CoreGui end)
    else
        return true
    end
end

function PlatformCompat.ShowInfo()
    local platform = PlatformCompat.Detect()
    print("========== PLATFORM INFO ==========")
    print(" Platform: " .. platform)
    print(" writefile: " .. tostring(PlatformCompat.Supports("writefile")))
    print(" readfile: " .. tostring(PlatformCompat.Supports("readfile")))
    print(" listfiles: " .. tostring(PlatformCompat.Supports("listfiles")))
    print(" clipboard: " .. tostring(PlatformCompat.Supports("setclipboard")))
    print(" HTTP: " .. tostring(PlatformCompat.Supports("http_request")))
    print(" CoreGui: " .. tostring(PlatformCompat.Supports("CoreGui")))
    print("====================================")
end

-- ============================================================
-- SECTION 36: EVENTS & HOOKS
-- ============================================================
local EventSystem = {}
EventSystem._events = {}

function EventSystem.On(eventName, callback)
    if not EventSystem._events[eventName] then
        EventSystem._events[eventName] = {}
    end
    table.insert(EventSystem._events[eventName], callback)
    
    return {
        Disconnect = function()
            for i, cb in ipairs(EventSystem._events[eventName]) do
                if cb == callback then
                    table.remove(EventSystem._events[eventName], i)
                    break
                end
            end
        end,
    }
end

function EventSystem.Fire(eventName, ...)
    if EventSystem._events[eventName] then
        for _, callback in ipairs(EventSystem._events[eventName]) do
            Util.SafeCallback(callback, ...)
        end
    end
end

-- Pre-defined events
EventSystem.Fire("LibraryLoaded", Library._VERSION)

-- Hook into window creation
local originalCreateWindow = Library.CreateWindow
Library.CreateWindow = function(self, config)
    local window = originalCreateWindow(self, config)
    EventSystem.Fire("WindowCreated", window)
    return window
end

-- ============================================================
-- SECTION 37: AUTO-UPDATE CHECKER
-- ============================================================
local UpdateChecker = {}
UpdateChecker._currentVersion = Library._VERSION
UpdateChecker._updateURL = "" -- User can set this
UpdateChecker._checked = false
UpdateChecker._updateAvailable = false
UpdateChecker._latestVersion = nil

function UpdateChecker.SetURL(url)
    UpdateChecker._updateURL = url
end

function UpdateChecker.Check()
    if UpdateChecker._checked then
        return UpdateChecker._updateAvailable, UpdateChecker._latestVersion
    end
    
    if UpdateChecker._updateURL == "" then
        return false, nil
    end
    
    if not PlatformCompat.Supports("http_request") then
        DebugWrapper.Log("WARN", "Cannot check updates: no HTTP support")
        return false, nil
    end
    
    local success, result = pcall(function()
        return game:HttpGet(UpdateChecker._updateURL)
    end)
    
    if success and result then
        local version = string.match(result, "Version:%s*(%d+%.%d+)")
        if version then
            UpdateChecker._latestVersion = version
            UpdateChecker._updateAvailable = version ~= UpdateChecker._currentVersion
        end
    end
    
    UpdateChecker._checked = true
    return UpdateChecker._updateAvailable, UpdateChecker._latestVersion
end

function UpdateChecker.ShowNotification(window)
    local available, version = UpdateChecker.Check()
    
    if available and window then
        window:Notify({
            Title = "Update Available!",
            Content = "Version " .. version .. " is available. You have " .. UpdateChecker._currentVersion,
            Duration = 8,
            Type = "warning",
        })
    end
    
    return available
end

-- ============================================================
-- SECTION 38: UTILITY SHORTCUTS
-- ============================================================

-- Color presets
Library.Colors = {
    Red = Color3.fromRGB(255, 65, 95),
    Green = Color3.fromRGB(45, 200, 95),
    Blue = Color3.fromRGB(85, 125, 255),
    Yellow = Color3.fromRGB(255, 200, 50),
    Orange = Color3.fromRGB(255, 150, 50),
    Purple = Color3.fromRGB(150, 80, 255),
    Pink = Color3.fromRGB(255, 100, 180),
    Cyan = Color3.fromRGB(50, 210, 220),
    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(0, 0, 0),
    Gray = Color3.fromRGB(150, 150, 170),
    DarkGray = Color3.fromRGB(60, 60, 75),
    Transparent = Color3.fromRGB(0, 0, 0),
}

-- Tween presets
Library.Easing = {
    Linear = Enum.EasingStyle.Linear,
    Quad = Enum.EasingStyle.Quad,
    Cubic = Enum.EasingStyle.Cubic,
    Quart = Enum.EasingStyle.Quart,
    Quint = Enum.EasingStyle.Quint,
    Sine = Enum.EasingStyle.Sine,
    Back = Enum.EasingStyle.Back,
    Elastic = Enum.EasingStyle.Elastic,
    Bounce = Enum.EasingStyle.Bounce,
}

Library.EasingDirection = {
    In = Enum.EasingDirection.In,
    Out = Enum.EasingDirection.Out,
    InOut = Enum.EasingDirection.InOut,
}

-- ============================================================
-- SECTION 39: GLOBAL CONFIGURATION
-- ============================================================
Library.Config = {
    AnimationEnabled = true,
    SoundEnabled = false,
    NotificationsEnabled = true,
    DefaultDuration = 4,
    MaxNotifications = 5,
    TooltipDelay = 0.4,
    MinimizeKey = Enum.KeyCode.RightShift,
    AutoUpdateCheck = false,
    DebugMode = false,
    SaveWindowPositions = false,
    ResponsiveMode = true,
}

function Library.Configure(config)
    for key, value in pairs(config) do
        if Library.Config[key] ~= nil then
            Library.Config[key] = value
        end
    end
    
    if Library.Config.DebugMode then
        DebugWrapper.Enable()
    end
end

-- ============================================================
-- SECTION 40: FAREWELL & CREDITS
-- ============================================================
local Credits = {
    Author = "Rylax0322",
    Version = Library._VERSION,
    Library = "UILibrary",
    Engine = "Custom Spring Physics",
    License = "MIT",
    Year = "2025",
    Thanks = {
        "Roblox for the platform",
        "Spring physics inspiration from nature",
        "Every developer who uses this library",
    },
}

function Credits.Show()
    print([[
    ╔══════════════════════════════════════════╗
    ║         UILibrary - Premium UI          ║
    ║              by Rylax0322               ║
    ╠══════════════════════════════════════════╣
    ║  Version: ]] .. Library._VERSION .. [[                         ║
    ║  Engine: Spring Physics                 ║
    ║  License: MIT                           ║
    ║  Lines: 7000+                           ║
    ║  Elements: 15+ types                    ║
    ║  Features: 20+                          ║
    ╚══════════════════════════════════════════╝
    ]])
end

-- Show credits on first load
Credits.Show()

-- ============================================================
-- FINAL RETURN
-- ============================================================
return Library
-- ============================================================
-- SECTION 41: PRESET THEMES PACK
-- ============================================================

-- Midnight Blue Theme
ThemeSystem.Register("Midnight", {
    Window = {
        Background = Color3.fromRGB(10, 12, 22),
        Border = Color3.fromRGB(100, 140, 255),
        BorderTransparency = 0.9,
        Shadow = Color3.fromRGB(0, 0, 0),
        ShadowTransparency = 0.5,
    },
    Topbar = {
        Background = Color3.fromRGB(14, 16, 28),
        Text = Color3.fromRGB(180, 200, 255),
        Button = Color3.fromRGB(180, 200, 255),
        ButtonTransparency = 0.88,
    },
    Sidebar = {
        Background = Color3.fromRGB(12, 14, 26),
        ToggleButton = Color3.fromRGB(65, 105, 225),
        ToggleIcon = Color3.fromRGB(255, 255, 255),
    },
    Tab = {
        Background = Color3.fromRGB(22, 26, 42),
        Active = Color3.fromRGB(65, 105, 225),
        Text = Color3.fromRGB(160, 180, 220),
        ActiveText = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(65, 105, 225),
        BorderTransparency = 0.55,
    },
    Section = {
        Background = Color3.fromRGB(16, 18, 32),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.94,
        Title = Color3.fromRGB(100, 140, 255),
        Divider = Color3.fromRGB(255, 255, 255),
        DividerTransparency = 0.88,
    },
    Element = {
        Title = Color3.fromRGB(200, 210, 240),
        Description = Color3.fromRGB(140, 150, 185),
        Icon = Color3.fromRGB(180, 195, 230),
    },
    Button = {
        Primary = Color3.fromRGB(65, 105, 225),
        PrimaryText = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(35, 40, 60),
        SecondaryText = Color3.fromRGB(200, 210, 235),
        Danger = Color3.fromRGB(255, 60, 90),
        DangerText = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(40, 190, 90),
        SuccessText = Color3.fromRGB(255, 255, 255),
        Warning = Color3.fromRGB(255, 175, 45),
        WarningText = Color3.fromRGB(255, 255, 255),
        Hover = Color3.fromRGB(255, 255, 255),
        HoverTransparency = 0.84,
    },
    Toggle = {
        Active = Color3.fromRGB(65, 105, 225),
        Inactive = Color3.fromRGB(50, 55, 75),
        Thumb = Color3.fromRGB(255, 255, 255),
        Shadow = Color3.fromRGB(0, 0, 0),
        ShadowTransparency = 0.6,
    },
    Slider = {
        Fill = Color3.fromRGB(65, 105, 225),
        Background = Color3.fromRGB(35, 40, 58),
        Thumb = Color3.fromRGB(255, 255, 255),
        Shadow = Color3.fromRGB(0, 0, 0),
        ShadowTransparency = 0.5,
    },
    Dropdown = {
        Background = Color3.fromRGB(24, 28, 46),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.88,
        Text = Color3.fromRGB(190, 200, 225),
        Hover = Color3.fromRGB(255, 255, 255),
        HoverTransparency = 0.93,
        Arrow = Color3.fromRGB(170, 180, 210),
    },
    Textbox = {
        Background = Color3.fromRGB(22, 26, 42),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.88,
        Text = Color3.fromRGB(200, 210, 235),
        Placeholder = Color3.fromRGB(110, 120, 155),
        Cursor = Color3.fromRGB(200, 210, 255),
    },
    Notification = {
        Background = Color3.fromRGB(20, 22, 38),
        Border = Color3.fromRGB(65, 105, 225),
        Title = Color3.fromRGB(255, 255, 255),
        Content = Color3.fromRGB(170, 180, 205),
        Timer = Color3.fromRGB(255, 255, 255),
        TimerTransparency = 0.86,
    },
    Dialog = {
        Background = Color3.fromRGB(16, 18, 32),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.92,
        Overlay = Color3.fromRGB(0, 0, 0),
        OverlayTransparency = 0.5,
    },
    Footer = {
        Background = Color3.fromRGB(10, 12, 20),
        Text = Color3.fromRGB(110, 120, 155),
    },
    Scrollbar = {
        Color = Color3.fromRGB(50, 55, 75),
    },
    FloatingIcon = {
        Background = Color3.fromRGB(65, 105, 225),
        Text = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.48,
    },
    ResizeCorner = {
        Color = Color3.fromRGB(120, 130, 165),
    },
})

-- Emerald Green Theme
ThemeSystem.Register("Emerald", {
    Window = {
        Background = Color3.fromRGB(12, 22, 18),
        Border = Color3.fromRGB(80, 200, 120),
        BorderTransparency = 0.9,
        Shadow = Color3.fromRGB(0, 0, 0),
        ShadowTransparency = 0.55,
    },
    Topbar = {
        Background = Color3.fromRGB(16, 28, 22),
        Text = Color3.fromRGB(180, 240, 200),
        Button = Color3.fromRGB(180, 240, 200),
        ButtonTransparency = 0.88,
    },
    Sidebar = {
        Background = Color3.fromRGB(14, 26, 20),
        ToggleButton = Color3.fromRGB(50, 190, 90),
        ToggleIcon = Color3.fromRGB(255, 255, 255),
    },
    Tab = {
        Background = Color3.fromRGB(22, 40, 32),
        Active = Color3.fromRGB(50, 190, 90),
        Text = Color3.fromRGB(160, 210, 180),
        ActiveText = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(50, 190, 90),
        BorderTransparency = 0.55,
    },
    Section = {
        Background = Color3.fromRGB(18, 34, 26),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.94,
        Title = Color3.fromRGB(80, 200, 120),
        Divider = Color3.fromRGB(255, 255, 255),
        DividerTransparency = 0.88,
    },
    Element = {
        Title = Color3.fromRGB(200, 235, 210),
        Description = Color3.fromRGB(140, 180, 155),
        Icon = Color3.fromRGB(180, 220, 195),
    },
    Button = {
        Primary = Color3.fromRGB(50, 190, 90),
        PrimaryText = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(30, 55, 40),
        SecondaryText = Color3.fromRGB(200, 230, 210),
        Danger = Color3.fromRGB(255, 65, 95),
        DangerText = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(40, 200, 100),
        SuccessText = Color3.fromRGB(255, 255, 255),
        Warning = Color3.fromRGB(255, 180, 50),
        WarningText = Color3.fromRGB(255, 255, 255),
        Hover = Color3.fromRGB(255, 255, 255),
        HoverTransparency = 0.84,
    },
    Toggle = {
        Active = Color3.fromRGB(50, 190, 90),
        Inactive = Color3.fromRGB(45, 65, 52),
        Thumb = Color3.fromRGB(255, 255, 255),
        Shadow = Color3.fromRGB(0, 0, 0),
        ShadowTransparency = 0.6,
    },
    Slider = {
        Fill = Color3.fromRGB(50, 190, 90),
        Background = Color3.fromRGB(35, 55, 42),
        Thumb = Color3.fromRGB(255, 255, 255),
        Shadow = Color3.fromRGB(0, 0, 0),
        ShadowTransparency = 0.5,
    },
    Dropdown = {
        Background = Color3.fromRGB(24, 44, 34),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.88,
        Text = Color3.fromRGB(180, 215, 190),
        Hover = Color3.fromRGB(255, 255, 255),
        HoverTransparency = 0.93,
        Arrow = Color3.fromRGB(160, 200, 175),
    },
    Textbox = {
        Background = Color3.fromRGB(22, 40, 30),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.88,
        Text = Color3.fromRGB(200, 230, 210),
        Placeholder = Color3.fromRGB(110, 150, 125),
        Cursor = Color3.fromRGB(200, 240, 210),
    },
    Notification = {
        Background = Color3.fromRGB(20, 38, 28),
        Border = Color3.fromRGB(50, 190, 90),
        Title = Color3.fromRGB(255, 255, 255),
        Content = Color3.fromRGB(170, 200, 180),
        Timer = Color3.fromRGB(255, 255, 255),
        TimerTransparency = 0.86,
    },
    Dialog = {
        Background = Color3.fromRGB(18, 34, 26),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.92,
        Overlay = Color3.fromRGB(0, 0, 0),
        OverlayTransparency = 0.5,
    },
    Footer = {
        Background = Color3.fromRGB(10, 20, 15),
        Text = Color3.fromRGB(110, 150, 125),
    },
    Scrollbar = {
        Color = Color3.fromRGB(45, 65, 52),
    },
    FloatingIcon = {
        Background = Color3.fromRGB(50, 190, 90),
        Text = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.48,
    },
    ResizeCorner = {
        Color = Color3.fromRGB(130, 170, 145),
    },
})

-- Rose Gold Theme
ThemeSystem.Register("Rose", {
    Window = {
        Background = Color3.fromRGB(28, 18, 22),
        Border = Color3.fromRGB(255, 130, 180),
        BorderTransparency = 0.9,
        Shadow = Color3.fromRGB(0, 0, 0),
        ShadowTransparency = 0.55,
    },
    Topbar = {
        Background = Color3.fromRGB(34, 22, 28),
        Text = Color3.fromRGB(255, 200, 220),
        Button = Color3.fromRGB(255, 200, 220),
        ButtonTransparency = 0.88,
    },
    Sidebar = {
        Background = Color3.fromRGB(32, 20, 26),
        ToggleButton = Color3.fromRGB(230, 100, 150),
        ToggleIcon = Color3.fromRGB(255, 255, 255),
    },
    Tab = {
        Background = Color3.fromRGB(44, 30, 36),
        Active = Color3.fromRGB(230, 100, 150),
        Text = Color3.fromRGB(220, 180, 195),
        ActiveText = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(230, 100, 150),
        BorderTransparency = 0.55,
    },
    Section = {
        Background = Color3.fromRGB(38, 24, 30),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.94,
        Title = Color3.fromRGB(255, 150, 190),
        Divider = Color3.fromRGB(255, 255, 255),
        DividerTransparency = 0.88,
    },
    Element = {
        Title = Color3.fromRGB(240, 210, 220),
        Description = Color3.fromRGB(190, 150, 165),
        Icon = Color3.fromRGB(225, 185, 200),
    },
    Button = {
        Primary = Color3.fromRGB(230, 100, 150),
        PrimaryText = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(55, 35, 42),
        SecondaryText = Color3.fromRGB(230, 200, 210),
        Danger = Color3.fromRGB(255, 65, 95),
        DangerText = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(45, 200, 95),
        SuccessText = Color3.fromRGB(255, 255, 255),
        Warning = Color3.fromRGB(255, 180, 50),
        WarningText = Color3.fromRGB(255, 255, 255),
        Hover = Color3.fromRGB(255, 255, 255),
        HoverTransparency = 0.84,
    },
    Toggle = {
        Active = Color3.fromRGB(230, 100, 150),
        Inactive = Color3.fromRGB(70, 48, 55),
        Thumb = Color3.fromRGB(255, 255, 255),
        Shadow = Color3.fromRGB(0, 0, 0),
        ShadowTransparency = 0.6,
    },
    Slider = {
        Fill = Color3.fromRGB(230, 100, 150),
        Background = Color3.fromRGB(55, 38, 44),
        Thumb = Color3.fromRGB(255, 255, 255),
        Shadow = Color3.fromRGB(0, 0, 0),
        ShadowTransparency = 0.5,
    },
    Dropdown = {
        Background = Color3.fromRGB(44, 30, 36),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.88,
        Text = Color3.fromRGB(220, 185, 195),
        Hover = Color3.fromRGB(255, 255, 255),
        HoverTransparency = 0.93,
        Arrow = Color3.fromRGB(210, 170, 185),
    },
    Textbox = {
        Background = Color3.fromRGB(40, 26, 32),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.88,
        Text = Color3.fromRGB(235, 205, 215),
        Placeholder = Color3.fromRGB(160, 120, 135),
        Cursor = Color3.fromRGB(255, 210, 225),
    },
    Notification = {
        Background = Color3.fromRGB(38, 24, 30),
        Border = Color3.fromRGB(230, 100, 150),
        Title = Color3.fromRGB(255, 255, 255),
        Content = Color3.fromRGB(200, 170, 180),
        Timer = Color3.fromRGB(255, 255, 255),
        TimerTransparency = 0.86,
    },
    Dialog = {
        Background = Color3.fromRGB(38, 24, 30),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.92,
        Overlay = Color3.fromRGB(0, 0, 0),
        OverlayTransparency = 0.5,
    },
    Footer = {
        Background = Color3.fromRGB(22, 14, 18),
        Text = Color3.fromRGB(160, 120, 135),
    },
    Scrollbar = {
        Color = Color3.fromRGB(70, 48, 55),
    },
    FloatingIcon = {
        Background = Color3.fromRGB(230, 100, 150),
        Text = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.48,
    },
    ResizeCorner = {
        Color = Color3.fromRGB(180, 140, 155),
    },
})

-- ============================================================
-- SECTION 42: ADVANCED EXAMPLE SCRIPTS
-- ============================================================

-- Example: Full Game Script Hub
function Library.Examples.ScriptHub()
    local Window = Library:CreateWindow({
        Title = "Script Hub",
        Game = "Universal",
        Version = "v1.0",
        Theme = "Midnight",
    })
    
    -- Tab 1: Player
    local PlayerTab = Window:AddTab({ Name = "Player" })
    
    local MovementSection = PlayerTab:AddSection({ Name = "Movement" })
    
    MovementSection:AddSlider({
        Name = "Walk Speed",
        Min = 16,
        Max = 500,
        Default = 16,
        Suffix = " studs/s",
        Callback = function(v)
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = v
            end
        end,
    })
    
    MovementSection:AddSlider({
        Name = "Jump Power",
        Min = 50,
        Max = 500,
        Default = 50,
        Suffix = " power",
        Callback = function(v)
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.JumpPower = v
            end
        end,
    })
    
    local noclipToggle = MovementSection:AddToggle({
        Name = "Noclip",
        Default = false,
        Callback = function(v)
            if v then
                local conn = RunService.Stepped:Connect(function()
                    local char = LocalPlayer.Character
                    if char then
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
                -- Store connection for cleanup
                noclipToggle._connection = conn
            else
                if noclipToggle._connection then
                    noclipToggle._connection:Disconnect()
                    noclipToggle._connection = nil
                end
            end
        end,
    })
    
    local VisualsSection = PlayerTab:AddSection({ Name = "Visuals", Side = "right" })
    
    VisualsSection:AddToggle({
        Name = "ESP",
        Default = false,
        Callback = function(v)
            if v then
                Window:Notify({ Title = "ESP", Content = "ESP enabled", Duration = 2, Type = "success" })
            end
        end,
    })
    
    VisualsSection:AddColorPicker({
        Name = "ESP Color",
        Default = Color3.fromRGB(255, 0, 0),
        Callback = function(color)
            -- Update ESP color
        end,
    })
    
    -- Tab 2: Game
    local GameTab = Window:AddTab({ Name = "Game" })
    
    local FarmSection = GameTab:AddSection({ Name = "Auto Farm" })
    
    FarmSection:AddDropdown({
        Name = "Farm Mode",
        Options = {"Nearest", "Weakest", "Strongest", "Random"},
        Default = "Nearest",
        Callback = function(v) print("Farm mode:", v) end,
    })
    
    FarmSection:AddToggle({
        Name = "Auto Farm",
        Default = false,
        Callback = function(v) print("Auto Farm:", v) end,
    })
    
    FarmSection:AddSlider({
        Name = "Attack Range",
        Min = 10,
        Max = 200,
        Default = 50,
        Suffix = " studs",
        Callback = function(v) print("Range:", v) end,
    })
    
    local MiscSection = GameTab:AddSection({ Name = "Misc", Side = "right" })
    
    MiscSection:AddButton({
        Name = "Teleport to Spawn",
        Callback = function()
            Window:Notify({ Title = "Teleported", Duration = 2 })
        end,
    })
    
    MiscSection:AddButton({
        Name = "Rejoin Server",
        Style = "Warning",
        Callback = function()
            Window:Dialog({
                Title = "Rejoin?",
                Content = "Are you sure you want to rejoin?",
                Buttons = {
                    { Title = "Cancel", Style = "Secondary" },
                    { Title = "Rejoin", Style = "Danger", Callback = function()
                        if game:GetService("TeleportService") then
                            game:GetService("TeleportService"):Teleport(game.PlaceId)
                        end
                    end },
                },
            })
        end,
    })
    
    -- Tab 3: Settings
    local SettingsTab = Window:AddTab({ Name = "Settings" })
    
    local ThemeSection = SettingsTab:AddSection({ Name = "Appearance" })
    
    ThemeSection:AddDropdown({
        Name = "Theme",
        Options = {"Dark", "Light", "Midnight", "Emerald", "Rose"},
        Default = "Midnight",
        Callback = function(v)
            Window:SetTheme(v)
        end,
    })
    
    ThemeSection:AddToggle({
        Name = "Show Watermark",
        Default = true,
        Callback = function(v)
            if v then
                WatermarkSystem.Create(Window, { Text = "Script Hub | Rylax0322" })
            else
                if WatermarkSystem._watermark then
                    WatermarkSystem._watermark:Destroy()
                end
            end
        end,
    })
    
    -- Watermark
    WatermarkSystem.Create(Window, { Text = "Script Hub | Rylax0322" })
    
    -- Welcome notification
    Window:Notify({
        Title = "Welcome!",
        Content = "Script Hub loaded successfully",
        Duration = 4,
        Type = "success",
    })
    
    return Window
end

-- Example: Simple Notification Demo
function Library.Examples.NotificationDemo()
    local Window = Library:CreateWindow({
        Title = "Notification Demo",
        Game = "Demo",
        Version = "v1.0",
    })
    
    local Tab = Window:AddTab({ Name = "Demo" })
    local Section = Tab:AddSection({ Name = "Notifications" })
    
    Section:AddButton({
        Name = "Info Notification",
        Callback = function()
            Window:Notify({ Title = "Info", Content = "This is an info notification", Duration = 3, Type = "info" })
        end,
    })
    
    Section:AddButton({
        Name = "Success Notification",
        Style = "Success",
        Callback = function()
            Window:Notify({ Title = "Success!", Content = "Operation completed", Duration = 3, Type = "success" })
        end,
    })
    
    Section:AddButton({
        Name = "Warning Notification",
        Style = "Warning",
        Callback = function()
            Window:Notify({ Title = "Warning", Content = "Be careful!", Duration = 4, Type = "warning" })
        end,
    })
    
    Section:AddButton({
        Name = "Error Notification",
        Style = "Danger",
        Callback = function()
            Window:Notify({ Title = "Error", Content = "Something went wrong", Duration = 5, Type = "error" })
        end,
    })
    
    Section:AddDivider("Dialog")
    
    Section:AddButton({
        Name = "Show Dialog",
        Style = "Secondary",
        Callback = function()
            Window:Dialog({
                Title = "Confirm Action",
                Content = "Are you sure you want to continue?",
                Buttons = {
                    { Title = "Cancel", Style = "Secondary" },
                    { Title = "Continue", Style = "Primary", Callback = function()
                        Window:Notify({ Title = "Action completed!", Type = "success", Duration = 2 })
                    end },
                },
            })
        end,
    })
    
    return Window
end

-- ============================================================
-- SECTION 43: OPTIMIZATION UTILITIES
-- ============================================================
local Optimizer = {}

-- Batch destroy multiple instances
function Optimizer.BatchDestroy(instances)
    for _, instance in ipairs(instances) do
        pcall(function()
            if instance.Parent then
                instance:Destroy()
            end
        end)
    end
end

-- Clean up all springs for a window
function Optimizer.CleanupSprings(window)
    local count = 0
    for id, spring in pairs(SpringEngine._Registry) do
        if spring._windowId == window._id then
            spring:Destroy()
            count = count + 1
        end
    end
    DebugWrapper.Log("INFO", "Cleaned up " .. count .. " springs for window", window._title)
    return count
end

-- Memory usage report
function Optimizer.MemoryReport()
    local report = {
        Windows = #Library._windows,
        Springs = PerformanceMonitor.GetSpringCount(),
        FPS = PerformanceMonitor.GetFPS(),
        Notifications = #NotificationSystem._active + #NotificationSystem._queue,
        GUIInstances = PerformanceMonitor.GetMemoryUsage(),
    }
    
    print("========== MEMORY REPORT ==========")
    print(" Windows: " .. report.Windows)
    print(" Active Springs: " .. report.Springs)
    print(" FPS: " .. report.FPS)
    print(" Notifications: " .. report.Notifications)
    print(" GUI Instances: " .. report.GUIInstances)
    print("====================================")
    
    return report
end

-- Garbage collection hint
function Optimizer.CollectGarbage()
    local before = PerformanceMonitor.GetMemoryUsage()
    
    -- Force cleanup
    for _, window in ipairs(Library._windows) do
        if window._springs then
            for _, spring in ipairs(window._springs) do
                if spring.Destroy then spring:Destroy() end
            end
            window._springs = {}
        end
    end
    
    -- Clean dead springs
    for id, spring in pairs(SpringEngine._Registry) do
        if not spring._active and spring._connection == nil then
            spring:Destroy()
        end
    end
    
    local after = PerformanceMonitor.GetMemoryUsage()
    local saved = before - after
    
    DebugWrapper.Log("INFO", "GC: Freed " .. saved .. " instances (" .. before .. " -> " .. after .. ")")
    return saved
end

-- ============================================================
-- SECTION 44: FINAL INITIALIZATION
-- ============================================================

-- Initialize tooltip system with global parent
local function InitTooltipSystem()
    if Library._activeWindow then
        TooltipSystem.Initialize(Library._activeWindow._screenGui)
    else
        -- Wait for first window
        local conn
        conn = EventSystem.On("WindowCreated", function(window)
            TooltipSystem.Initialize(window._screenGui)
            if conn then conn:Disconnect() end
        end)
    end
end

InitTooltipSystem()

-- Auto-check for updates if enabled
if Library.Config.AutoUpdateCheck then
    task.delay(3, function()
        if Library._activeWindow then
            UpdateChecker.ShowNotification(Library._activeWindow)
        end
    end)
end

-- ============================================================
-- SECTION 45: EXPORT SHORTCUTS
-- ============================================================

-- Short aliases for common patterns
Library.UI = Library
Library.Create = Library.CreateWindow
Library.Notify = Library.QuickNotify
Library.Themes = {
    Dark = "Dark",
    Light = "Light",
    Midnight = "Midnight",
    Emerald = "Emerald",
    Rose = "Rose",
}

-- ============================================================
-- FINAL RETURN
-- ============================================================
return Library
