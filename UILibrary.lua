local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local Util = {}
function Util.Create(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do pcall(function() obj[k] = v end) end
    if children then for _, c in ipairs(children) do if typeof(c) == "Instance" then c.Parent = obj end end end
    return obj
end
function Util.Tween(obj, info, props) TweenService:Create(obj, info, props):Play() end

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

local Theme = {
    Bg = Color3.fromRGB(14,14,24), Top = Color3.fromRGB(17,17,30), Tab = Color3.fromRGB(28,30,45),
    TabOn = Color3.fromRGB(85,125,255), Sec = Color3.fromRGB(20,22,36), Title = Color3.fromRGB(100,140,255),
    Text = Color3.fromRGB(220,220,240), Dim = Color3.fromRGB(150,150,175),
    Pri = Color3.fromRGB(85,125,255), PriT = Color3.new(1,1,1), Dan = Color3.fromRGB(255,65,95), DanT = Color3.new(1,1,1),
    TogOn = Color3.fromRGB(85,125,255), TogOff = Color3.fromRGB(55,60,80), Thumb = Color3.new(1,1,1),
    Slider = Color3.fromRGB(85,125,255), SliderBg = Color3.fromRGB(38,42,60),
    DD = Color3.fromRGB(28,32,50), Notif = Color3.fromRGB(23,25,40), Foot = Color3.fromRGB(13,13,23),
}

local Library = {}

function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local win = { Title = cfg.Title or "UI" }
    
    local sgui = Util.Create("ScreenGui", { Name = "UI", ResetOnSpawn = false, ZIndexBehavior = "Sibling" })
    pcall(function() if syn then syn.protect_gui(sgui) end; sgui.Parent = CoreGui end)
    if not sgui.Parent then sgui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
    local main = Util.Create("Frame", { Size = UDim2.new(0,560,0,420), Position = UDim2.new(0.5,-280,0.5,-210), BackgroundColor3 = Theme.Bg, BorderSizePixel = 0, ClipsDescendants = true, Parent = sgui })
    Util.Create("UICorner", { CornerRadius = UDim.new(0,12), Parent = main })
    
    local top = Util.Create("Frame", { Size = UDim2.new(1,0,0,38), BackgroundColor3 = Theme.Top, BorderSizePixel = 0, Parent = main })
    Util.Create("UICorner", { CornerRadius = UDim.new(0,12), Parent = top })
    Util.Create("Frame", { Size = UDim2.new(1,0,0,12), Position = UDim2.new(0,0,1,-12), BackgroundColor3 = Theme.Top, BorderSizePixel = 0, Parent = top })
    
    Util.Create("TextLabel", { Size = UDim2.new(1,-60,1,0), Position = UDim2.new(0,14,0,0), BackgroundTransparency = 1, Text = win.Title, TextColor3 = Color3.new(1,1,1), TextSize = 14, Font = Enum.Font.GothamBold, TextXAlignment = "Left", Parent = top })
    
    local closeBtn = Util.Create("TextButton", { Size = UDim2.new(0,26,0,26), Position = UDim2.new(1,-34,0.5,-13), BackgroundColor3 = Theme.Dan, Text = "x", TextColor3 = Color3.new(1,1,1), TextSize = 14, Font = Enum.Font.GothamBold, BorderSizePixel = 0, Parent = top })
    Util.Create("UICorner", { CornerRadius = UDim.new(0,8), Parent = closeBtn })
    closeBtn.MouseButton1Click:Connect(function() sgui:Destroy() end)
    
    local tabBar = Util.Create("Frame", { Size = UDim2.new(1,0,0,34), Position = UDim2.new(0,0,0,38), BackgroundColor3 = Theme.Top, BorderSizePixel = 0, Parent = main })
    Util.Create("UIListLayout", { FillDirection = "Horizontal", SortOrder = "LayoutOrder", Padding = UDim.new(0,4), Parent = tabBar })
    Util.Create("UIPadding", { PaddingLeft = UDim.new(0,8), PaddingTop = UDim.new(0,5), Parent = tabBar })
    
    local pages = Util.Create("Frame", { Size = UDim2.new(1,0,1,-72), Position = UDim2.new(0,0,0,72), BackgroundTransparency = 1, ClipsDescendants = true, Parent = main })
    
    local footer = Util.Create("Frame", { Size = UDim2.new(1,0,0,22), Position = UDim2.new(0,0,1,-22), BackgroundColor3 = Theme.Foot, BorderSizePixel = 0, Parent = main })
    Util.Create("UICorner", { CornerRadius = UDim.new(0,12), Parent = footer })
    
    Util.MakeDraggable(main, top)
    
    -- Notification holder
    local notifs = Util.Create("Frame", { Size = UDim2.new(0,300,1,0), Position = UDim2.new(1,-316,0,0), BackgroundTransparency = 1, Parent = sgui })
    Util.Create("UIListLayout", { SortOrder = "LayoutOrder", VerticalAlignment = "Bottom", Padding = UDim.new(0,8), Parent = notifs })
    
    function win:Notify(cfg)
        local c = Util.Create("Frame", { Size = UDim2.new(0,280,0,0), BackgroundColor3 = Theme.Notif, BorderSizePixel = 0, ClipsDescendants = true, Parent = notifs })
        Util.Create("UICorner", { CornerRadius = UDim.new(0,8), Parent = c })
        local cnt = Util.Create("Frame", { Size = UDim2.new(1,-16,1,-12), Position = UDim2.new(0,8,0,6), BackgroundTransparency = 1, Parent = c })
        Util.Create("TextLabel", { Size = UDim2.new(1,-20,0,16), BackgroundTransparency = 1, Text = cfg.Title or "", TextColor3 = Color3.new(1,1,1), TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = "Left", Parent = cnt })
        if cfg.Content then Util.Create("TextLabel", { Size = UDim2.new(1,0,0,14), Position = UDim2.new(0,0,0,18), BackgroundTransparency = 1, Text = cfg.Content, TextColor3 = Theme.Dim, TextSize = 10, Font = Enum.Font.Gotham, TextXAlignment = "Left", Parent = cnt }) end
        Util.Tween(c, TweenInfo.new(0.25), { Size = UDim2.new(0,280,0,cfg.Content and 50 or 32) })
        task.delay(cfg.Duration or 3, function() Util.Tween(c, TweenInfo.new(0.2), { Size = UDim2.new(0,280,0,0) }) task.delay(0.2, function() c:Destroy() end) end)
    end
    
    local tabs = {}
    local activeTab = nil
    
    function win:AddTab(cfg)
        local name = cfg.Name or "Tab"
        local btn = Util.Create("TextButton", { Size = UDim2.new(0,0,0,24), AutomaticSize = "X", BackgroundColor3 = Theme.Tab, Text = name, TextColor3 = Theme.Dim, TextSize = 11, Font = Enum.Font.GothamSemibold, BorderSizePixel = 0, AutoButtonColor = false, Parent = tabBar })
        Util.Create("UICorner", { CornerRadius = UDim.new(0,6), Parent = btn })
        Util.Create("UIPadding", { PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10), Parent = btn })
        
        local page = Util.Create("Frame", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false, Parent = pages })
        
        local left = Util.Create("ScrollingFrame", { Size = UDim2.new(0.5,-1,1,0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = "Y", Parent = page })
        Util.Create("UIListLayout", { SortOrder = "LayoutOrder", Padding = UDim.new(0,8), Parent = left })
        Util.Create("UIPadding", { PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,5), PaddingTop = UDim.new(0,10), Parent = left })
        
        Util.Create("Frame", { Size = UDim2.new(0,1,1,0), Position = UDim2.new(0.5,0,0,0), BackgroundColor3 = Theme.Dim, BackgroundTransparency = 0.7, BorderSizePixel = 0, Parent = page })
        
        local right = Util.Create("ScrollingFrame", { Size = UDim2.new(0.5,-1,1,0), Position = UDim2.new(0.5,1,0,0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = "Y", Parent = page })
        Util.Create("UIListLayout", { SortOrder = "LayoutOrder", Padding = UDim.new(0,8), Parent = right })
        Util.Create("UIPadding", { PaddingLeft = UDim.new(0,5), PaddingRight = UDim.new(0,10), PaddingTop = UDim.new(0,10), Parent = right })
        
        local tab = { _btn = btn, _page = page }
        
        function tab:Activate()
            if activeTab then activeTab._btn.BackgroundColor3 = Theme.Tab; activeTab._page.Visible = false end
            activeTab = self; self._btn.BackgroundColor3 = Theme.TabOn; self._page.Visible = true
        end
        
        btn.MouseButton1Click:Connect(function() tab:Activate() end)
        table.insert(tabs, tab)
        if #tabs == 1 then tab:Activate() end
        
        local side = "left"
        
        function tab:AddSection(cfg)
            local sName = cfg.Name or "Section"
            local sSide = cfg.Side or side
            side = (side == "left") and "right" or "left"
            local parent = (sSide == "right") and right or left
            
            local sec = Util.Create("Frame", { Size = UDim2.new(1,0,0,0), AutomaticSize = "Y", BackgroundColor3 = Theme.Sec, BorderSizePixel = 0, Parent = parent })
            Util.Create("UICorner", { CornerRadius = UDim.new(0,8), Parent = sec })
            
            local cnt = Util.Create("Frame", { Size = UDim2.new(1,-20,1,-16), Position = UDim2.new(0,10,0,8), BackgroundTransparency = 1, Parent = sec })
            Util.Create("UIListLayout", { SortOrder = "LayoutOrder", Padding = UDim.new(0,6), Parent = cnt })
            
            Util.Create("TextLabel", { Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, Text = sName, TextColor3 = Theme.Title, TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = "Left", Parent = cnt })
            Util.Create("Frame", { Size = UDim2.new(1,0,0,1), BackgroundColor3 = Theme.Dim, BackgroundTransparency = 0.5, BorderSizePixel = 0, Parent = cnt })
            Util.Create("Frame", { Size = UDim2.new(1,0,0,4), BackgroundTransparency = 1, Parent = cnt })
            
            local section = {}
            
            function section:AddButton(cfg)
                local btn = Util.Create("TextButton", { Size = UDim2.new(1,0,0,30), BackgroundColor3 = Theme.Pri, Text = cfg.Name or "Btn", TextColor3 = Theme.PriT, TextSize = 12, Font = Enum.Font.GothamBold, BorderSizePixel = 0, AutoButtonColor = false, Parent = cnt })
                Util.Create("UICorner", { CornerRadius = UDim.new(0,7), Parent = btn })
                btn.MouseButton1Click:Connect(function() pcall(cfg.Callback or function() end) end)
                return btn
            end
            
            function section:AddToggle(cfg)
                local val = cfg.Default or false
                local row = Util.Create("Frame", { Size = UDim2.new(1,0,0,28), BackgroundTransparency = 1, Parent = cnt })
                Util.Create("TextLabel", { Size = UDim2.new(0.6,0,1,0), BackgroundTransparency = 1, Text = cfg.Name or "Toggle", TextColor3 = Theme.Text, TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = "Left", Parent = row })
                
                local track = Util.Create("Frame", { Size = UDim2.new(0,38,0,20), Position = UDim2.new(1,-38,0.5,-10), BackgroundColor3 = val and Theme.TogOn or Theme.TogOff, BorderSizePixel = 0, Parent = row })
                Util.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = track })
                
                local thumb = Util.Create("Frame", { Size = UDim2.new(0,14,0,14), Position = UDim2.new(0,val and 21 or 3,0.5,-7), BackgroundColor3 = Theme.Thumb, BorderSizePixel = 0, Parent = track })
                Util.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = thumb })
                
                local click = Util.Create("TextButton", { Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = row, ZIndex = 5 })
                
                local function set(v)
                    val = v
                    Util.Tween(track, TweenInfo.new(0.15), { BackgroundColor3 = v and Theme.TogOn or Theme.TogOff })
                    Util.Tween(thumb, TweenInfo.new(0.15), { Position = UDim2.new(0, v and 21 or 3, 0.5, -7) })
                    pcall(cfg.Callback or function() end, val)
                end
                
                click.MouseButton1Click:Connect(function() set(not val) end)
                return { Set = function(v) set(v) end, Get = function() return val end }
            end
            
            function section:AddSlider(cfg)
                local min = cfg.Min or 0; local max = cfg.Max or 100; local val = math.clamp(cfg.Default or min, min, max)
                local con = Util.Create("Frame", { Size = UDim2.new(1,0,0,46), BackgroundTransparency = 1, Parent = cnt })
                Util.Create("TextLabel", { Size = UDim2.new(0.5,0,0,18), BackgroundTransparency = 1, Text = cfg.Name or "Slider", TextColor3 = Theme.Text, TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = "Left", Parent = con })
                local vLabel = Util.Create("TextLabel", { Size = UDim2.new(0.5,0,0,18), Position = UDim2.new(0.5,0,0,0), BackgroundTransparency = 1, Text = tostring(val) .. (cfg.Suffix or ""), TextColor3 = Theme.Dim, TextSize = 10, Font = Enum.Font.Gotham, TextXAlignment = "Right", Parent = con })
                
                local tBg = Util.Create("Frame", { Size = UDim2.new(1,0,0,5), Position = UDim2.new(0,0,0,24), BackgroundColor3 = Theme.SliderBg, BorderSizePixel = 0, Parent = con })
                Util.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = tBg })
                local pct = (val-min)/(max-min)
                local fill = Util.Create("Frame", { Size = UDim2.new(pct,0,1,0), BackgroundColor3 = Theme.Slider, BorderSizePixel = 0, Parent = tBg })
                Util.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = fill })
                local thumb = Util.Create("Frame", { Size = UDim2.new(0,14,0,14), Position = UDim2.new(pct,-7,0.5,-7), BackgroundColor3 = Theme.Thumb, BorderSizePixel = 0, ZIndex = 3, Parent = tBg })
                Util.Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = thumb })
                
                local drag = Util.Create("TextButton", { Size = UDim2.new(1,0,0,28), Position = UDim2.new(0,0,0.5,-14), BackgroundTransparency = 1, Text = "", ZIndex = 5, Parent = tBg })
                local dragging = false
                local function upd(x) local p = math.clamp((x - tBg.AbsolutePosition.X) / tBg.AbsoluteSize.X, 0, 1); val = math.floor(min + (max-min) * p); fill.Size = UDim2.new(p,0,1,0); thumb.Position = UDim2.new(p,-7,0.5,-7); vLabel.Text = tostring(val) .. (cfg.Suffix or ""); pcall(cfg.Callback or function() end, val) end
                drag.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; upd(i.Position.X) end end)
                UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i.Position.X) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
                return { Set = function(v) val = math.clamp(v, min, max) end, Get = function() return val end }
            end
            
            function section:AddDropdown(cfg)
                local opts = cfg.Options or {}; local val = cfg.Default or (opts[1] or ""); local open = false
                local con = Util.Create("Frame", { Size = UDim2.new(1,0,0,42), BackgroundTransparency = 1, ClipsDescendants = false, Parent = cnt })
                Util.Create("TextLabel", { Size = UDim2.new(1,0,0,16), BackgroundTransparency = 1, Text = cfg.Name or "DD", TextColor3 = Theme.Text, TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = "Left", Parent = con })
                local db = Util.Create("TextButton", { Size = UDim2.new(1,0,0,24), Position = UDim2.new(0,0,0,18), BackgroundColor3 = Theme.DD, Text = val, TextColor3 = Theme.Dim, TextSize = 11, Font = Enum.Font.Gotham, BorderSizePixel = 0, AutoButtonColor = false, Parent = con })
                Util.Create("UICorner", { CornerRadius = UDim.new(0,6), Parent = db })
                local list = Util.Create("Frame", { Size = UDim2.new(1,0,0,0), Position = UDim2.new(0,0,1,2), BackgroundColor3 = Theme.DD, BorderSizePixel = 0, ClipsDescendants = true, Visible = false, ZIndex = 50, Parent = db })
                Util.Create("UICorner", { CornerRadius = UDim.new(0,6), Parent = list })
                Util.Create("UIListLayout", { SortOrder = "LayoutOrder", Parent = list })
                for _, o in ipairs(opts) do local ob = Util.Create("TextButton", { Size = UDim2.new(1,0,0,22), BackgroundColor3 = Theme.DD, Text = o, TextColor3 = Theme.Dim, TextSize = 11, Font = Enum.Font.Gotham, BorderSizePixel = 0, ZIndex = 51, Parent = list }); ob.MouseButton1Click:Connect(function() val = o; db.Text = o; open = false; Util.Tween(list, TweenInfo.new(0.12), { Size = UDim2.new(1,0,0,0) }); task.delay(0.13, function() list.Visible = false; con.Size = UDim2.new(1,0,0,42) end); pcall(cfg.Callback or function() end, val) end) end
                db.MouseButton1Click:Connect(function() open = not open; if open then list.Visible = true; local h = math.min(#opts * 22, 160); Util.Tween(list, TweenInfo.new(0.2), { Size = UDim2.new(1,0,0,h) }); con.Size = UDim2.new(1,0,0,42+h+4) else Util.Tween(list, TweenInfo.new(0.12), { Size = UDim2.new(1,0,0,0) }); task.delay(0.13, function() list.Visible = false; con.Size = UDim2.new(1,0,0,42) end) end end)
                return { Set = function(v) val = v; db.Text = v end, Get = function() return val end }
            end
            
            return section
        end
        
        return tab
    end
    
    return win
end

return Library
