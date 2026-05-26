--[[
    UILibrary - Fixed Edition
    by Rylax0322
    No sidebar bug, smooth minimize, all elements work
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Spring Engine
local SpringEngine = {}
SpringEngine.__index = SpringEngine
SpringEngine._Registry = {}

function SpringEngine.new(initial, config)
    config = config or {}
    local self = setmetatable({}, SpringEngine)
    self.Value = initial or 0
    self.Velocity = 0
    self.Target = initial or 0
    self.Stiffness = config.Stiffness or 170
    self.Damping = config.Damping or 16
    self.Mass = config.Mass or 1
    self.Precision = config.Precision or 0.0001
    self.Active = false
    self.Callbacks = {}
    self.Connection = nil
    return self
end

function SpringEngine:SetTarget(target)
    self.Target = target
    if not self.Active then
        self.Active = true
        if self.Connection then self.Connection:Disconnect() end
        local lastTime = tick()
        self.Connection = RunService.Heartbeat:Connect(function()
            local dt = math.min(tick() - lastTime, 0.05)
            lastTime = tick()
            if dt <= 0 then return end
            local force = (self.Target - self.Value) * self.Stiffness
            local damping = self.Velocity * self.Damping
            self.Velocity = self.Velocity + (force - damping) / self.Mass * dt
            self.Value = self.Value + self.Velocity * dt
            if math.abs(self.Target - self.Value) < self.Precision and math.abs(self.Velocity) < 0.01 then
                self.Value = self.Target
                self.Velocity = 0
                self.Active = false
                self.Connection:Disconnect()
                self.Connection = nil
            end
            for _, cb in ipairs(self.Callbacks) do pcall(cb, self.Value) end
        end)
    end
end

function SpringEngine:OnChange(cb) table.insert(self.Callbacks, cb) end
function SpringEngine:Destroy() if self.Connection then self.Connection:Disconnect() end end

-- Utility
local Util = {}
function Util.Create(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do pcall(function() obj[k] = v end) end
    if children then for _, c in ipairs(children) do if typeof(c) == "Instance" then c.Parent = obj end end end
    return obj
end

function Util.Tween(obj, info, props) TweenService:Create(obj, info, props):Play() end
function Util.Clamp(v, min, max) return math.max(min, math.min(max, v)) end
function Util.LerpColor(a, b, t) return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t) end

function Util.MakeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle = handle or frame
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Theme
local Theme = {
    Background = Color3.fromRGB(14, 14, 24),
    Topbar = Color3.fromRGB(17, 17, 30),
    Tab = Color3.fromRGB(28, 30, 45),
    TabActive = Color3.fromRGB(85, 125, 255),
    Section = Color3.fromRGB(20, 22, 36),
    SectionTitle = Color3.fromRGB(100, 140, 255),
    Text = Color3.fromRGB(220, 220, 240),
    TextDim = Color3.fromRGB(150, 150, 175),
    Primary = Color3.fromRGB(85, 125, 255),
    PrimaryText = Color3.fromRGB(255, 255, 255),
    Secondary = Color3.fromRGB(42, 45, 62),
    SecondaryText = Color3.fromRGB(210, 210, 230),
    Danger = Color3.fromRGB(255, 65, 95),
    DangerText = Color3.fromRGB(255, 255, 255),
    Success = Color3.fromRGB(45, 200, 95),
    SuccessText = Color3.fromRGB(255, 255, 255),
    ToggleActive = Color3.fromRGB(85, 125, 255),
    ToggleInactive = Color3.fromRGB(55, 60, 80),
    SliderFill = Color3.fromRGB(85, 125, 255),
    SliderBg = Color3.fromRGB(38, 42, 60),
    DropdownBg = Color3.fromRGB(28, 32, 50),
    TextboxBg = Color3.fromRGB(26, 30, 46),
    NotifBg = Color3.fromRGB(23, 25, 40),
    NotifBorder = Color3.fromRGB(85, 125, 255),
    Footer = Color3.fromRGB(13, 13, 23),
    Scrollbar = Color3.fromRGB(55, 60, 80),
    FloatBg = Color3.fromRGB(85, 125, 255),
}

-- Notification System
local NotifSystem = {}
NotifSystem.Active = {}
NotifSystem.Queue = {}
NotifSystem.Holder = nil

function NotifSystem.Init(holder) NotifSystem.Holder = holder end

function NotifSystem.Show(cfg)
    if not NotifSystem.Holder then return end
    local c = Util.Create("Frame", {
        Size = UDim2.new(0, 300, 0, 0),
        BackgroundColor3 = Theme.NotifBg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = NotifSystem.Holder,
    })
    Util.Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = c })
    Util.Create("UIStroke", { Color = Theme.NotifBorder, Thickness = 1.5, Transparency = 0.4, Parent = c })
    
    local content = Util.Create("Frame", {
        Size = UDim2.new(1, -20, 1, -14),
        Position = UDim2.new(0, 10, 0, 7),
        BackgroundTransparency = 1,
        Parent = c,
    })
    
    Util.Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 18),
        BackgroundTransparency = 1,
        Text = cfg.Title or "Notification",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = content,
    })
    
    if cfg.Content and cfg.Content ~= "" then
        Util.Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            Position = UDim2.new(0, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = cfg.Content,
            TextColor3 = Theme.TextDim,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = content,
        })
    end
    
    local closeBtn = Util.Create("TextButton", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -18, 0, 0),
        BackgroundTransparency = 1,
        Text = "x",
        TextColor3 = Theme.TextDim,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Parent = content,
    })
    
    local h = cfg.Content ~= "" and 58 or 38
    local s = SpringEngine.new(0, { Stiffness = 130, Damping = 14 })
    s:OnChange(function(v) pcall(function() c.Size = UDim2.new(0, 300, 0, v) end) end)
    s:SetTarget(h)
    
    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        s:SetTarget(0)
        task.delay(0.35, function() if c.Parent then c:Destroy() end end)
    end
    
    closeBtn.MouseButton1Click:Connect(dismiss)
    task.delay(cfg.Duration or 3, dismiss)
end

-- Library
local Library = {}
Library.Windows = {}

function Library:CreateWindow(config)
    config = config or {}
    local window = {
        Title = config.Title or "UILibrary",
        Version = config.Version or "v1.0",
        Game = config.Game or "",
        Theme = config.Theme or "Dark",
        Tabs = {},
        ActiveTab = nil,
        FloatingIcon = nil,
        Minimized = false,
        Signals = {},
    }
    
    local screenGui = Util.Create("ScreenGui", {
        Name = "UILibrary_" .. window.Title,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(screenGui) end; screenGui.Parent = CoreGui end)
    if not screenGui.Parent then screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
    local mainFrame = Util.Create("Frame", {
        Size = UDim2.new(0, 580, 0, 440),
        Position = UDim2.new(0.5, -290, 0.5, -220),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = screenGui,
    })
    Util.Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = mainFrame })
    
    -- Topbar
    local topBar = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Topbar,
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    Util.Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = topBar })
    
    Util.Create("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = window.Title,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar,
    })
    
    local minimizeBtn = Util.Create("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -68, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(255, 180, 50),
        Text = "-",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        Parent = topBar,
    })
    Util.Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = minimizeBtn })
    
    local closeBtn = Util.Create("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -32, 0.5, -14),
        BackgroundColor3 = Theme.Danger,
        Text = "x",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        Parent = topBar,
    })
    Util.Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = closeBtn })
    closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)
    
    -- Tab Bar
    local tabBar = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = Theme.Topbar,
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    Util.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = tabBar,
    })
    Util.Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 5),
        Parent = tabBar,
    })
    
    -- Pages Holder
    local pagesHolder = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 1, -100),
        Position = UDim2.new(0, 0, 0, 76),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = mainFrame,
    })
    
    -- Footer
    local footer = Util.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 1, -24),
        BackgroundColor3 = Theme.Footer,
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    Util.Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = footer })
    Util.Create("TextLabel", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = window.Version .. " | " .. window.Game,
        TextColor3 = Color3.fromRGB(115, 115, 145),
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = footer,
    })
    
    -- Draggable
    Util.MakeDraggable(mainFrame, topBar)
    
    -- Minimize
    local sizeSpring = SpringEngine.new(1)
    local savedSize = { W = 580, H = 440 }
    
    local function minimize()
        if window.Minimized then return end
        window.Minimized = true
        savedSize.W = mainFrame.Size.X.Offset
        savedSize.H = mainFrame.Size.Y.Offset
        
        local s = SpringEngine.new(mainFrame.Size.X.Offset)
        s:OnChange(function(v) pcall(function() mainFrame.Size = UDim2.new(0, v, 0, mainFrame.Size.Y.Offset) end) end)
        s:SetTarget(0)
        
        task.delay(0.3, function()
            mainFrame.Visible = false
            if not window.FloatingIcon then
                local fb = Util.Create("TextButton", {
                    Size = UDim2.new(0, 46, 0, 46),
                    Position = UDim2.new(1, -60, 0, 16),
                    BackgroundColor3 = Theme.FloatBg,
                    Text = "R",
                    TextColor3 = Color3.new(1, 1, 1),
                    TextSize = 20,
                    Font = Enum.Font.GothamBold,
                    BorderSizePixel = 0,
                    Parent = screenGui,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fb })
                Util.MakeDraggable(fb)
                
                fb.MouseButton1Click:Connect(function()
                    if not window.Minimized then return end
                    window.Minimized = false
                    fb:Destroy()
                    window.FloatingIcon = nil
                    mainFrame.Visible = true
                    mainFrame.Size = UDim2.new(0, 0, 0, savedSize.H)
                    local s2 = SpringEngine.new(0)
                    s2:OnChange(function(v) pcall(function() mainFrame.Size = UDim2.new(0, v, 0, savedSize.H) end) end)
                    s2:SetTarget(savedSize.W)
                end)
                
                window.FloatingIcon = fb
            end
        end)
    end
    
    minimizeBtn.MouseButton1Click:Connect(minimize)
    
    -- Notification Holder
    local notifHolder = Util.Create("Frame", {
        Size = UDim2.new(0, 320, 1, 0),
        Position = UDim2.new(1, -336, 0, 0),
        BackgroundTransparency = 1,
        Parent = screenGui,
    })
    Util.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 10),
        Parent = notifHolder,
    })
    Util.Create("UIPadding", { PaddingBottom = UDim.new(0, 16), Parent = notifHolder })
    NotifSystem.Init(notifHolder)
    
    -- Methods
    function window:Notify(cfg) NotifSystem.Show(cfg) end
    
    function window:AddTab(cfg)
        cfg = cfg or {}
        local name = cfg.Name or "Tab"
        
        local tabBtn = Util.Create("TextButton", {
            Size = UDim2.new(0, 0, 0, 26),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = Theme.Tab,
            Text = name,
            TextColor3 = Theme.TextDim,
            TextSize = 12,
            Font = Enum.Font.GothamSemibold,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Parent = tabBar,
        })
        Util.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = tabBtn })
        Util.Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = tabBtn })
        
        local page = Util.Create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = pagesHolder,
        })
        
        local leftCol = Util.Create("ScrollingFrame", {
            Size = UDim2.new(0.5, -1, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Scrollbar,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = page,
        })
        Util.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = leftCol })
        Util.Create("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 12), Parent = leftCol })
        
        Util.Create("Frame", {
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.new(0.5, 0, 0, 0),
            BackgroundColor3 = Theme.TextDim,
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            Parent = page,
        })
        
        local rightCol = Util.Create("ScrollingFrame", {
            Size = UDim2.new(0.5, -1, 1, 0),
            Position = UDim2.new(0.5, 1, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Scrollbar,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = page,
        })
        Util.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = rightCol })
        Util.Create("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 12), Parent = rightCol })
        
        local tab = { _btn = tabBtn, _page = page }
        
        function tab:Activate()
            if window.ActiveTab then
                window.ActiveTab._btn.BackgroundColor3 = Theme.Tab
                window.ActiveTab._btn.TextColor3 = Theme.TextDim
                window.ActiveTab._page.Visible = false
            end
            window.ActiveTab = self
            self._btn.BackgroundColor3 = Theme.TabActive
            self._btn.TextColor3 = Color3.new(1, 1, 1)
            self._page.Visible = true
        end
        
        tabBtn.MouseButton1Click:Connect(function() tab:Activate() end)
        table.insert(window.Tabs, tab)
        if #window.Tabs == 1 then tab:Activate() end
        
        local side = "left"
        
        function tab:AddSection(cfg)
            cfg = cfg or {}
            local sName = cfg.Name or "Section"
            local sSide = cfg.Side or side
            side = (side == "left") and "right" or "left"
            local parent = (sSide == "right") and rightCol or leftCol
            
            local section = Util.Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Section,
                BorderSizePixel = 0,
                Parent = parent,
            })
            Util.Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = section })
            
            local content = Util.Create("Frame", {
                Size = UDim2.new(1, -24, 1, -20),
                Position = UDim2.new(0, 12, 0, 10),
                BackgroundTransparency = 1,
                Parent = section,
            })
            Util.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = content })
            
            Util.Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                Text = sName,
                TextColor3 = Theme.SectionTitle,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = content,
            })
            
            Util.Create("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.TextDim,
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                Parent = content,
            })
            
            Util.Create("Frame", { Size = UDim2.new(1, 0, 0, 4), BackgroundTransparency = 1, Parent = content })
            
            local sec = {}
            
            function sec:AddButton(cfg)
                cfg = cfg or {}
                local style = cfg.Style or "Primary"
                local colors = { Primary = Theme.Primary, Secondary = Theme.Secondary, Danger = Theme.Danger, Success = Theme.Success }
                local texts = { Primary = Theme.PrimaryText, Secondary = Theme.SecondaryText, Danger = Theme.DangerText, Success = Theme.SuccessText }
                local c = colors[style] or Theme.Primary
                local t = texts[style] or Theme.PrimaryText
                
                local btn = Util.Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = c,
                    Text = cfg.Name or "Button",
                    TextColor3 = t,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Parent = content,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
                btn.MouseButton1Click:Connect(function() pcall(cfg.Callback or function() end) end)
                return btn
            end
            
            function sec:AddToggle(cfg)
                cfg = cfg or {}
                local val = cfg.Default or false
                
                local row = Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = content,
                })
                
                Util.Create("TextLabel", {
                    Size = UDim2.new(0.6, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = cfg.Name or "Toggle",
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row,
                })
                
                local track = Util.Create("Frame", {
                    Size = UDim2.new(0, 40, 0, 22),
                    Position = UDim2.new(1, -40, 0.5, -11),
                    BackgroundColor3 = val and Theme.ToggleActive or Theme.ToggleInactive,
                    BorderSizePixel = 0,
                    Parent = row,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
                
                local thumb = Util.Create("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, val and 21 or 3, 0.5, -8),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Parent = track,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = thumb })
                
                local click = Util.Create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = row,
                    ZIndex = 5,
                })
                
                local function set(v)
                    val = v
                    local s = SpringEngine.new(v and 0 or 1)
                    s:OnChange(function(p)
                        local t = v and p or (1 - p)
                        pcall(function()
                            track.BackgroundColor3 = Util.LerpColor(Theme.ToggleInactive, Theme.ToggleActive, t)
                            thumb.Position = UDim2.new(0, 3 + 18 * t, 0.5, -8)
                        end)
                    end)
                    s:SetTarget(v and 1 or 0)
                    pcall(cfg.Callback or function() end, val)
                end
                
                click.MouseButton1Click:Connect(function() set(not val) end)
                
                return { Set = function(v) set(v) end, Get = function() return val end }
            end
            
            function sec:AddSlider(cfg)
                cfg = cfg or {}
                local min = cfg.Min or 0
                local max = cfg.Max or 100
                local val = Util.Clamp(cfg.Default or min, min, max)
                local suffix = cfg.Suffix or ""
                
                local container = Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Parent = content,
                })
                
                Util.Create("TextLabel", {
                    Size = UDim2.new(0.55, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = cfg.Name or "Slider",
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = container,
                })
                
                local valLabel = Util.Create("TextLabel", {
                    Size = UDim2.new(0.45, 0, 0, 20),
                    Position = UDim2.new(0.55, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(val) .. suffix,
                    TextColor3 = Theme.TextDim,
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = container,
                })
                
                local trackBg = Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 5),
                    Position = UDim2.new(0, 0, 0, 26),
                    BackgroundColor3 = Theme.SliderBg,
                    BorderSizePixel = 0,
                    Parent = container,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = trackBg })
                
                local pct = (val - min) / (max - min)
                local fill = Util.Create("Frame", {
                    Size = UDim2.new(pct, 0, 1, 0),
                    BackgroundColor3 = Theme.SliderFill,
                    BorderSizePixel = 0,
                    Parent = trackBg,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
                
                local thumb = Util.Create("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(pct, -8, 0.5, -8),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 3,
                    Parent = trackBg,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = thumb })
                
                local dragBtn = Util.Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0.5, -15),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 5,
                    Parent = trackBg,
                })
                
                local dragging = false
                local function update(inputX)
                    local percent = Util.Clamp((inputX - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
                    val = math.floor(min + (max - min) * percent)
                    pcall(function()
                        fill.Size = UDim2.new(percent, 0, 1, 0)
                        thumb.Position = UDim2.new(percent, -8, 0.5, -8)
                        valLabel.Text = tostring(val) .. suffix
                    end)
                    pcall(cfg.Callback or function() end, val)
                end
                
                dragBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true; update(input.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        update(input.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                
                return { Set = function(v) val = Util.Clamp(v, min, max) end, Get = function() return val end }
            end
            
            function sec:AddDropdown(cfg)
                cfg = cfg or {}
                local options = cfg.Options or {}
                local val = cfg.Default or (options[1] or "")
                local open = false
                
                local container = Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 44),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    Parent = content,
                })
                
                Util.Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text = cfg.Name or "Dropdown",
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = container,
                })
                
                local dropBtn = Util.Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    Position = UDim2.new(0, 0, 0, 18),
                    BackgroundColor3 = Theme.DropdownBg,
                    Text = val,
                    TextColor3 = Theme.TextDim,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Parent = container,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = dropBtn })
                
                local arrow = Util.Create("TextLabel", {
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -22, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "v",
                    TextColor3 = Theme.TextDim,
                    TextSize = 10,
                    Font = Enum.Font.GothamBold,
                    Parent = dropBtn,
                })
                
                local list = Util.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 2),
                    BackgroundColor3 = Theme.DropdownBg,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 50,
                    Parent = dropBtn,
                })
                Util.Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = list })
                Util.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })
                
                for _, opt in ipairs(options) do
                    local ob = Util.Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 24),
                        BackgroundColor3 = Theme.DropdownBg,
                        Text = opt,
                        TextColor3 = Theme.TextDim,
                        TextSize = 11,
                        Font = Enum.Font.Gotham,
                        BorderSizePixel = 0,
                        ZIndex = 51,
                        Parent = list,
                    })
                    ob.MouseButton1Click:Connect(function()
                        val = opt; dropBtn.Text = opt; open = false
                        Util.Tween(list, TweenInfo.new(0.12), { Size = UDim2.new(1, 0, 0, 0) })
                        task.delay(0.13, function() list.Visible = false; container.Size = UDim2.new(1, 0, 0, 44) end)
                        Util.Tween(arrow, TweenInfo.new(0.12), { Rotation = 0 })
                        pcall(cfg.Callback or function() end, val)
                    end)
                end
                
                dropBtn.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        list.Visible = true
                        local h = math.min(#options * 24, 180)
                        Util.Tween(list, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, h) })
                        container.Size = UDim2.new(1, 0, 0, 44 + h + 4)
                        Util.Tween(arrow, TweenInfo.new(0.15), { Rotation = 180 })
                    else
                        Util.Tween(list, TweenInfo.new(0.12), { Size = UDim2.new(1, 0, 0, 0) })
                        task.delay(0.13, function() list.Visible = false; container.Size = UDim2.new(1, 0, 0, 44) end)
                        Util.Tween(arrow, TweenInfo.new(0.12), { Rotation = 0 })
                    end
                end)
                
                return { Set = function(v) val = v; dropBtn.Text = v end, Get = function() return val end }
            end
            
            return sec
        end
        
        return tab
    end
    
    table.insert(Library.Windows, window)
    return window
end

return Library
