--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║               UILibrary - Premium Edition                   ║
    ║            by Rylax0322 · Spring Animation                 ║
    ╚══════════════════════════════════════════════════════════════╝
    Version: 7.0 Final
    Lines: 8500+
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
    self._stiffness = config.Stiffness or 170
    self._damping = config.Damping or 16
    self._mass = config.Mass or 1
    self._precision = config.Precision or 0.0001
    
    -- Runtime
    self._active = false
    self._callbacks = {}
    self._connection = nil
    self._id = HttpService:GenerateGUID(false)
    self._lastTime = tick()
    
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
        
        dt = math.min(dt, 0.05)
        
        if dt <= 0 then return end
        
        local displacement = self._target - self._value
        local springForce = displacement * self._stiffness
        local dampingForce = self._velocity * self._damping
        local netForce = springForce - dampingForce
        
        local acceleration = netForce / self._mass
        self._velocity = self._velocity + acceleration * dt
        self._value = self._value + self._velocity * dt
        
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

function Util.Tween(obj, tweenInfo, properties)
    local tween = TweenService:Create(obj, tweenInfo, properties)
    tween:Play()
    return tween
end

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
            
            if bounds then
                local screenSize = Camera.ViewportSize
                newX = math.clamp(newX, bounds.MinX or -frame.AbsoluteSize.X/2, bounds.MaxX or screenSize.X - frame.AbsoluteSize.X/2)
                newY = math.clamp(newY, bounds.MinY or 0, bounds.MaxY or screenSize.Y - frame.AbsoluteSize.Y/2)
            end
            
            frame.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        end
    end)
end

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

function Util.IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function Util.IsTablet()
    return Util.IsMobile() and Camera.ViewportSize.X > 768
end

function Util.IsPhone()
    return Util.IsMobile() and Camera.ViewportSize.X <= 768
end

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

function Util.GetTextSize(text, fontSize, font, maxWidth)
    return TextService:GetTextSize(text, fontSize, font, Vector2.new(maxWidth or math.huge, math.huge))
end

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

function ThemeSystem.Register(name, theme)
    ThemeSystem._themes[name] = theme
end

function ThemeSystem.Set(name)
    if ThemeSystem._themes[name] then
        ThemeSystem._current = ThemeSystem._themes[name]
        ThemeSystem._notifyListeners()
    end
end

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

function ThemeSystem.OnChange(callback)
    table.insert(ThemeSystem._changeListeners, callback)
end

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
-- END OF CHAT 1/9
-- ============================================================
-- ============================================================
-- UTILITY LIBRARY
-- ============================================================
local Util = {}

function Util.Create(className, properties, children)
    local instance = Instance.new(className)
    if properties then
        for prop, value in pairs(properties) do
            if prop ~= "ThemeTag" and prop ~= "Children" then
                pcall(function() instance[prop] = value end)
            end
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

function Util.Tween(obj, tweenInfo, properties)
    local tween = TweenService:Create(obj, tweenInfo, properties)
    tween:Play()
    return tween
end

function Util.MakeDraggable(frame, handle, bounds)
    local dragging, dragStart, startPos, dragInput
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
            if bounds then
                local screenSize = Camera.ViewportSize
                newX = math.clamp(newX, bounds.MinX or -frame.AbsoluteSize.X/2, bounds.MaxX or screenSize.X - frame.AbsoluteSize.X/2)
                newY = math.clamp(newY, bounds.MinY or 0, bounds.MaxY or screenSize.Y - frame.AbsoluteSize.Y/2)
            end
            frame.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        end
    end)
end

function Util.MakeResizable(frame, handle, minW, minH, maxW, maxH)
    local resizing, resizeStart, startSize
    minW = minW or 420; minH = minH or 300; maxW = maxW or 1200; maxH = maxH or 900
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
            local newW = math.clamp(startSize.Width.Offset + delta.X, minW, maxW)
            local newH = math.clamp(startSize.Height.Offset + delta.Y, minH, maxH)
            frame.Size = UDim2.new(0, newW, 0, newH)
        end
    end)
end

function Util.IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

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

function Util.GenerateGUID()
    return HttpService:GenerateGUID(false)
end

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

function Util.SafeCallback(callback, ...)
    if not callback then return end
    local success, err = pcall(callback, ...)
    if not success then
        warn("[UILibrary] Callback error:", err)
    end
end

-- ============================================================
-- THEME SYSTEM
-- ============================================================
local ThemeSystem = {}
ThemeSystem._current = nil
ThemeSystem._themes = {}
ThemeSystem._changeListeners = {}

function ThemeSystem.Register(name, theme)
    ThemeSystem._themes[name] = theme
end

function ThemeSystem.Set(name)
    if ThemeSystem._themes[name] then
        ThemeSystem._current = ThemeSystem._themes[name]
        ThemeSystem._notifyListeners()
    end
end

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

function ThemeSystem.OnChange(callback)
    table.insert(ThemeSystem._changeListeners, callback)
end

function ThemeSystem._notifyListeners()
    for _, listener in ipairs(ThemeSystem._changeListeners) do
        Util.SafeCallback(listener, ThemeSystem._current)
    end
end

-- Register Dark Theme
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

-- Register Light Theme
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

ThemeSystem.Set("Dark")

-- ============================================================
-- ICON SYSTEM
-- ============================================================
local IconSystem = {}
IconSystem._map = {
    home = "rbxassetid://6031068421",
    settings = "rbxassetid://6031282542",
    search = "rbxassetid://6031103189",
    menu = "rbxassetid://6031094753",
    close = "rbxassetid://6031073852",
    plus = "rbxassetid://6031280885",
    ["chevron-down"] = "rbxassetid://6031094753",
    ["chevron-up"] = "rbxassetid://6031094753",
    play = "rbxassetid://6031282542",
    refresh = "rbxassetid://6031282542",
    copy = "rbxassetid://6031282542",
    trash = "rbxassetid://6031282542",
    edit = "rbxassetid://6031282542",
    folder = "rbxassetid://6031282542",
    file = "rbxassetid://6031282542",
    lock = "rbxassetid://6031282542",
    key = "rbxassetid://6031282542",
    sword = "rbxassetid://6031282542",
    shield = "rbxassetid://6031282542",
    target = "rbxassetid://6031282542",
    trophy = "rbxassetid://6031282542",
    star = "rbxassetid://6031282542",
    heart = "rbxassetid://6031282542",
    fire = "rbxassetid://6031282542",
    skull = "rbxassetid://6031282542",
    crown = "rbxassetid://6031282542",
    egg = "rbxassetid://6031282542",
    gift = "rbxassetid://6031282542",
    package = "rbxassetid://6031282542",
    cart = "rbxassetid://6031282542",
    coins = "rbxassetid://6031282542",
    gem = "rbxassetid://6031282542",
    dollar = "rbxassetid://6031282542",
    user = "rbxassetid://6031282542",
    users = "rbxassetid://6031282542",
    mail = "rbxassetid://6031282542",
    bell = "rbxassetid://6031282542",
    check = "rbxassetid://6031282542",
    circle = "rbxassetid://6031282542",
    ["alert-triangle"] = "rbxassetid://6031282542",
    info = "rbxassetid://6031282542",
    eye = "rbxassetid://6031282542",
    sun = "rbxassetid://6031282542",
    moon = "rbxassetid://6031282542",
    clock = "rbxassetid://6031282542",
    calendar = "rbxassetid://6031282542",
    camera = "rbxassetid://6031282542",
    ["rotate-cw"] = "rbxassetid://6031282542",
    ["arrow-up"] = "rbxassetid://6031282542",
    ["arrow-down"] = "rbxassetid://6031282542",
    loader = "rbxassetid://6031282542",
    ["map-pin"] = "rbxassetid://6031282542",
    wifi = "rbxassetid://6031282542",
    smartphone = "rbxassetid://6031282542",
    monitor = "rbxassetid://6031282542",
}

function IconSystem.Get(name, size)
    size = size or 24
    local id = IconSystem._map[name] or IconSystem._map.circle
    return {
        Image = id,
        ImageRectSize = Vector2.new(size, size),
        ImageRectOffset = Vector2.new(0, 0),
    }
end

function IconSystem.Create(name, size, parent, color, transparency)
    local data = IconSystem.Get(name, size)
    return Util.Create("ImageLabel", {
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
end
-- ============================================================
-- NOTIFICATION SYSTEM
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
    
    local borderColor = notification.Color or (
        notification.Type == "success" and ThemeSystem.GetColor("Button.Success") or
        notification.Type == "error" and ThemeSystem.GetColor("Button.Danger") or
        notification.Type == "warning" and ThemeSystem.GetColor("Button.Warning") or
        ThemeSystem.GetColor("Notification.Border")
    )
    
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
    
    local content = Util.Create("Frame", {
        Size = UDim2.new(1, -24, 1, -18),
        Position = UDim2.new(0, 12, 0, 9),
        BackgroundTransparency = 1,
        Parent = container,
    })
    
    local iconSize = 20
    if notification.Icon and notification.Icon ~= "" then
        IconSystem.Create(notification.Icon, iconSize, content, borderColor)
    end
    
    Util.Create("TextLabel", {
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
    
    local totalHeight = notification.Content ~= "" and 62 or 42
    local spring = SpringEngine.new(0, { Stiffness = 130, Damping = 14 })
    spring:OnChange(function(v)
        pcall(function()
            container.Size = UDim2.new(0, 320, 0, v)
        end)
    end)
    spring:SetTarget(totalHeight)
    
    local timerTween = Util.Tween(timerFill,
        TweenInfo.new(notification.Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
        { Size = UDim2.new(0, 0, 1, 0) }
    )
    
    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        spring:SetTarget(0)
        task.delay(0.35, function()
            if container.Parent then
                container:Destroy()
            end
            for i, item in ipairs(NotificationSystem._active) do
                if item.Container == container then
                    table.remove(NotificationSystem._active, i)
                    break
                end
            end
            NotificationSystem._process()
        end)
    end
    
    closeBtn.MouseButton1Click:Connect(dismiss)
    task.delay(notification.Duration, dismiss)
    
    table.insert(NotificationSystem._active, {
        Container = container,
        Spring = spring,
    })
end

-- ============================================================
-- DIALOG SYSTEM
-- ============================================================
local DialogSystem = {}

function DialogSystem.Show(window, config)
    config = config or {}
    
    local overlay = Util.Create("Frame", {
        Name = "DialogOverlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = ThemeSystem.GetColor("Dialog.Overlay"),
        BackgroundTransparency = 1,
        ZIndex = 999,
        Parent = window._screenGui,
    })
    
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
    
    local overlaySpring = SpringEngine.new(0, { Stiffness = 120, Damping = 12 })
    overlaySpring:OnChange(function(v)
        overlay.BackgroundTransparency = 1 - v * ThemeSystem.GetTransparency("Dialog.OverlayTransparency")
    end)
    overlaySpring:SetTarget(1)
    
    local dialogSpring = SpringEngine.new(0.7, { Stiffness = 170, Damping = 17 })
    dialogSpring:OnChange(function(v)
        dialogFrame.Size = UDim2.new(0, 320 * v, 0, content.AbsoluteSize.Y * v)
    end)
    dialogSpring:SetTarget(1)
    
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
-- LIBRARY CORE
-- ============================================================
local Library = {}
Library._windows = {}
Library._activeWindow = nil
-- ============================================================
-- CREATE WINDOW
-- ============================================================
function Library:CreateWindow(config)
    config = config or {}
    
    local window = {
        _id = Util.GenerateGUID(),
        _title = config.Title or "UILibrary",
        _version = config.Version or "v7.0",
        _game = config.Game or "",
        _theme = config.Theme or "Dark",
        _resizable = config.Resizable ~= false,
        _draggable = config.Draggable ~= false,
        _minimizeKey = config.MinimizeKey or Enum.KeyCode.RightShift,
        _tabs = {},
        _activeTab = nil,
        _signals = {},
        _floatingIcon = nil,
        _minimized = false,
        _menuVisible = true,
    }
    
    ThemeSystem.Set(window._theme)
    
    local screenGui = Util.Create("ScreenGui", {
        Name = "UILibrary_" .. window._title,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(screenGui) end
        screenGui.Parent = CoreGui
    end)
    if not screenGui.Parent then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    window._screenGui = screenGui
    
    -- Main Frame
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
    Util.Create("ImageLabel", {
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
    
    -- TopBar
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
    closeBtn.MouseButton1Click:Connect(function() window:Destroy() end)
    
    -- Sidebar
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
    
    -- Content Frame
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
    
    Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 38),
        BackgroundColor3 = ThemeSystem.GetColor("Section.Divider"),
        BackgroundTransparency = ThemeSystem.GetTransparency("Section.DividerTransparency"),
        BorderSizePixel = 0,
        Parent = contentFrame,
    })
    
    -- Pages Holder
    local pagesHolder = Util.Create("Frame", {
        Name = "PagesHolder",
        Size = UDim2.new(1, 0, 1, -39),
        Position = UDim2.new(0, 0, 0, 39),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = contentFrame,
    })
    
    -- Footer
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
    
    -- Resize Corner
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
    
    -- Draggable
    if window._draggable then
        Util.MakeDraggable(mainFrame, topBar)
    end
    
    -- ========================================
    -- MINIMIZE TO FLOATING ICON
    -- ========================================
    local sizeSpring = SpringFactory.Size(mainFrame, { Stiffness = 180, Damping = 18 })
    local alphaSpring = SpringFactory.Transparency(mainFrame, { Stiffness = 150, Damping = 12 })
    local savedSize = { Width = 600, Height = 480 }
    
    local function minimizeToIcon()
        if window._minimized then return end
        window._minimized = true
        
        savedSize.Width = mainFrame.Size.X.Offset
        savedSize.Height = mainFrame.Size.Y.Offset
        
        sizeSpring.SetSize(0, 0)
        alphaSpring.FadeOut()
        
        task.delay(0.3, function()
            mainFrame.Visible = false
            
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
                
                Util.MakeDraggable(floatBtn)
                
                local iconSpring = SpringEngine.new(0, { Stiffness = 160, Damping = 16 })
                iconSpring:OnChange(function(v)
                    pcall(function()
                        floatBtn.Size = UDim2.new(0, 50 * v, 0, 50 * v)
                    end)
                end)
                iconSpring:SetTarget(1)
                
                floatBtn.MouseButton1Click:Connect(function()
                    if not window._minimized then return end
                    window._minimized = false
                    floatBtn:Destroy()
                    window._floatingIcon = nil
                    mainFrame.Visible = true
                    mainFrame.BackgroundTransparency = 1
                    mainFrame.Size = UDim2.new(0, 0, 0, 0)
                    sizeSpring.SetSize(savedSize.Width, savedSize.Height)
                    alphaSpring.FadeIn()
                end)
                
                window._floatingIcon = floatBtn
            end
        end)
    end
    
    minimizeBtn.MouseButton1Click:Connect(minimizeToIcon)
    
    -- Keyboard toggle
    local keySignal = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == window._minimizeKey then
            if window._minimized then
                if window._floatingIcon then
                    window._floatingIcon:Destroy()
                    window._floatingIcon = nil
                end
                window._minimized = false
                mainFrame.Visible = true
                mainFrame.BackgroundTransparency = 1
                mainFrame.Size = UDim2.new(0, 0, 0, 0)
                sizeSpring.SetSize(savedSize.Width, savedSize.Height)
                alphaSpring.FadeIn()
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
    function window:Notify(config)
        NotificationSystem.Create(config)
    end
    
    function window:Dialog(config)
        DialogSystem.Show(window, config)
    end
    
    function window:SetTheme(themeName)
        window._theme = themeName
        ThemeSystem.Set(themeName)
    end
    
    function window:GetTheme()
        return window._theme
    end
    
    function window:Destroy()
        for _, signal in ipairs(window._signals) do
            pcall(function() signal:Disconnect() end)
        end
        
        if window._sizeSpring then window._sizeSpring:Destroy() end
        if window._alphaSpring then window._alphaSpring:Destroy() end
        
        if window._floatingIcon then
            window._floatingIcon:Destroy()
            window._floatingIcon = nil
        end
        
        if screenGui and screenGui.Parent then
            screenGui:Destroy()
        end
        
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
    
    tabBtn.MouseEnter:Connect(function() hoverSpring:SetTarget(1) end)
    tabBtn.MouseLeave:Connect(function() hoverSpring:SetTarget(0) end)
    
    local tabPage = Util.Create("Frame", {
        Name = tabName .. "Page",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = pagesHolder,
    })
    
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
    }
    
    function tab:Activate()
        if window._activeTab then
            window._activeTab._btn.BackgroundColor3 = ThemeSystem.GetColor("Tab.Background")
            window._activeTab._btn.TextColor3 = ThemeSystem.GetColor("Tab.Text")
            window._activeTab._page.Visible = false
        end
        window._activeTab = self
        self._btn.BackgroundColor3 = ThemeSystem.GetColor("Tab.Active")
        self._btn.TextColor3 = ThemeSystem.GetColor("Tab.ActiveText")
        self._page.Visible = true
    end
    
    tabBtn.MouseButton1Click:Connect(function() tab:Activate() end)
    
    table.insert(window._tabs, tab)
    if #window._tabs == 1 then tab:Activate() end
    
    local nextSide = "left"
    
    -- ========================================
    -- ADD SECTION
    -- ========================================
    function tab:AddSection(config)
        config = config or {}
        local sectionName = config.Name or "Section"
        local side = config.Side or nextSide
        nextSide = (nextSide == "left") and "right" or "left"
        local parent = (side == "right") and rightColumn or leftColumn
        
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
        
        Util.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, 4),
            BackgroundColor3 = ThemeSystem.GetColor("Section.Divider"),
            BackgroundTransparency = ThemeSystem.GetTransparency("Section.DividerTransparency"),
            BorderSizePixel = 0,
            Parent = titleFrame,
        })
        
        Util.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 6),
            BackgroundTransparency = 1,
            Parent = sectionContent,
        })
        
        local section = { _content = sectionContent, _window = window }
        
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
                Util.Tween(btn, TweenInfo.new(0.1), { BackgroundColor3 = bgColor })
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
            local defaultValue = config.Default or false
            local callback = config.Callback or function() end
            local value = defaultValue
            
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
            
            clickBtn.MouseButton1Click:Connect(function() setToggle(not value) end)
            
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
            local defaultValue = config.Default or min
            local callback = config.Callback or function() end
            local suffix = config.Suffix or ""
            local value = Util.Clamp(defaultValue, min, max)
            
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
                end
                
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
                
                local obj = {}
                function obj:Set(v) value = v; dropBtn.Text = v end
                function obj:Get() return value end
                return obj
            end
            
            -- ========================================
            -- TEXTBOX
            -- ========================================
            function section:AddTextbox(config)
                config = config or {}
                local name = config.Name or "Textbox"
                local placeholder = config.Placeholder or ""
                local defaultValue = config.Default or ""
                local callback = config.Callback or function() end
                local multiline = config.MultiLine or false
                
                local containerHeight = multiline and 72 or 48
                
                local container = Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, containerHeight),
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
                
                local textbox = Util.Create("TextBox", {
                    Size = UDim2.new(1, 0, 0, multiline and 50 or 28),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = ThemeSystem.GetColor("Textbox.Background"),
                    Text = defaultValue,
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
                
                textbox.FocusLost:Connect(function(enterPressed)
                    Util.SafeCallback(callback, textbox.Text, enterPressed)
                end)
                
                local obj = {}
                function obj:Set(t) textbox.Text = t end
                function obj:Get() return textbox.Text end
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
                local name = config.Name or "Color"
                local default = config.Default or Color3.new(1, 1, 1)
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
                function obj:Set(c)
                    value = c
                    pcall(function()
                        preview.BackgroundColor3 = c
                        rInput.Text = tostring(math.floor(c.R * 255))
                        gInput.Text = tostring(math.floor(c.G * 255))
                        bInput.Text = tostring(math.floor(c.B * 255))
                    end)
                end
                function obj:Get() return value end
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
                function obj:Set(k)
                    value = k
                    keyBtn.Text = k == Enum.KeyCode.Unknown and "None" or k.Name
                end
                function obj:Get() return value end
                return obj
            end
            
            -- ========================================
            -- PROGRESS BAR
            -- ========================================
            function section:AddProgressBar(config)
                config = config or {}
                local name = config.Name or "Progress"
                local currentValue = config.Value or 0
                local maxValue = config.Max or 100
                local barColor = config.Color or ThemeSystem.GetColor("Button.Primary")
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
                
                local pct = math.clamp(currentValue / maxValue, 0, 1)
                local fill = Util.Create("Frame", {
                    Size = UDim2.new(pct, 0, 1, 0),
                    BackgroundColor3 = barColor,
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
                local currentVal = currentValue
                
                function obj:Set(v)
                    currentVal = math.clamp(v, 0, maxValue)
                    local p = currentVal / maxValue
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
                
                function obj:Get() return currentVal end
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
-- LIBRARY METHODS
-- ============================================================
function Library:SetTheme(name)
    ThemeSystem.Set(name)
end

function Library:GetWindows()
    return Library._windows
end

function Library:GetActiveWindow()
    return Library._activeWindow
end

function Library:CloseAll()
    for _, window in ipairs(Library._windows) do
        window:Destroy()
    end
end

-- ============================================================
-- RETURN
-- ============================================================
return Library
