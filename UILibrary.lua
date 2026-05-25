-- ╔══════════════════════════════════════════╗
-- ║         ChiyoLib UI Library v1.0         ║
-- ║     Dark Blue Theme | loadstring ready   ║
-- ╚══════════════════════════════════════════╝
-- Usage:
--   local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/REPO/main/UILibrary.lua"))()
--   local Window = UI:CreateWindow({ Title = "My Script", Game = "Kick a Lucky Block" })
--   local Tab = Window:AddTab({ Name = "Farming", Icon = "⚔️" })
--   local Section = Tab:AddSection({ Name = "Auto Farm" })
--   Section:AddToggle({ Name = "Auto Farm", Default = false, Callback = function(v) print(v) end })
--   Section:AddSlider({ Name = "Walk Speed", Min = 1, Max = 200, Default = 45, Callback = function(v) print(v) end })
--   Section:AddDropdown({ Name = "Farm Mode", Options = {"Remote","Local"}, Default = "Remote", Callback = function(v) print(v) end })
--   Section:AddButton({ Name = "Sell Now", Callback = function() print("Sold!") end })
--   Section:AddLabel({ Text = "Power: 100% | Zone: Eternal" })

local Library = {}
Library.__index = Library

-- ─── Services ───────────────────────────────────────────────────────────────
local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")
local CoreGui        = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ─── Utility ────────────────────────────────────────────────────────────────
local function Tween(obj, props, duration, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir   = dir   or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(duration, style, dir), props):Play()
end

local function Create(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    return obj
end

local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle = handle or frame

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos  = frame.Position
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

-- ─── THEME ──────────────────────────────────────────────────────────────────
local Theme = {
    Background     = Color3.fromRGB(18, 20, 30),       -- main bg
    Panel          = Color3.fromRGB(22, 25, 38),       -- panel bg
    Sidebar        = Color3.fromRGB(16, 18, 28),       -- sidebar bg
    Header         = Color3.fromRGB(14, 16, 24),       -- topbar
    Border         = Color3.fromRGB(40, 45, 65),       -- border
    Accent         = Color3.fromRGB(80, 130, 240),     -- blue accent
    AccentDark     = Color3.fromRGB(50, 90, 190),      -- darker blue
    AccentGlow     = Color3.fromRGB(100, 160, 255),    -- glow
    Toggle_ON      = Color3.fromRGB(80, 130, 240),
    Toggle_OFF     = Color3.fromRGB(40, 45, 65),
    Text           = Color3.fromRGB(220, 225, 240),
    TextDim        = Color3.fromRGB(120, 130, 160),
    TextMuted      = Color3.fromRGB(70, 80, 110),
    Button         = Color3.fromRGB(30, 36, 58),
    ButtonHover    = Color3.fromRGB(40, 50, 80),
    Divider        = Color3.fromRGB(30, 35, 55),
    SliderFill     = Color3.fromRGB(80, 130, 240),
    SliderBg       = Color3.fromRGB(30, 35, 55),
    InputBg        = Color3.fromRGB(20, 23, 36),
    SectionTitle   = Color3.fromRGB(90, 140, 255),
    Red            = Color3.fromRGB(255, 80, 100),
    Green          = Color3.fromRGB(80, 220, 130),
    FooterBg       = Color3.fromRGB(12, 14, 22),
    TabActive      = Color3.fromRGB(80, 130, 240),
    TabInactive    = Color3.fromRGB(40, 45, 65),
    ScrollBar      = Color3.fromRGB(50, 60, 90),
}

-- ═══════════════════════════════════════════════════════════════════════════
--  CreateWindow
-- ═══════════════════════════════════════════════════════════════════════════
function Library:CreateWindow(config)
    config = config or {}
    local Title    = config.Title   or "ChiyoLib"
    local Game     = config.Game    or "Unknown Game"
    local Discord  = config.Discord or "discord.gg/chiyo"
    local Version  = config.Version or "v1.0"
    local MinimizeKey = config.MinimizeKey or Enum.KeyCode.RightShift

    -- ── ScreenGui ──────────────────────────────────────────────────────────
    local ScreenGui = Create("ScreenGui", {
        Name             = "ChiyoLib_" .. Title,
        ResetOnSpawn     = false,
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
    })

    -- Try CoreGui first, fallback to PlayerGui
    pcall(function()
        if syn then
            syn.protect_gui(ScreenGui)
        end
        ScreenGui.Parent = CoreGui
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- ── Main Frame ─────────────────────────────────────────────────────────
    local MainFrame = Create("Frame", {
        Name            = "MainFrame",
        Size            = UDim2.new(0, 480, 0, 420),
        Position        = UDim2.new(0.5, -240, 0.5, -210),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        Parent          = ScreenGui,
    })
    Create("UICorner",   { CornerRadius = UDim.new(0, 10), Parent = MainFrame })
    Create("UIStroke",   { Color = Theme.Border, Thickness = 1, Parent = MainFrame })

    -- Drop shadow
    local Shadow = Create("ImageLabel", {
        Name              = "Shadow",
        AnchorPoint       = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position          = UDim2.new(0.5, 0, 0.5, 6),
        Size              = UDim2.new(1, 30, 1, 30),
        Image             = "rbxassetid://6014261993",
        ImageColor3       = Color3.fromRGB(0,0,0),
        ImageTransparency = 0.5,
        ScaleType         = Enum.ScaleType.Slice,
        SliceCenter       = Rect.new(49, 49, 450, 450),
        ZIndex            = 0,
        Parent            = MainFrame,
    })

    -- ── Top Bar ────────────────────────────────────────────────────────────
    local TopBar = Create("Frame", {
        Name             = "TopBar",
        Size             = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel  = 0,
        Parent           = MainFrame,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = TopBar })

    -- Fix bottom corners of topbar
    Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 10),
        Position         = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel  = 0,
        Parent           = TopBar,
    })

    -- Logo / Toggle button (the C button)
    local LogoBtn = Create("TextButton", {
        Name             = "LogoBtn",
        Size             = UDim2.new(0, 28, 0, 28),
        Position         = UDim2.new(0, 4, 0.5, -14),
        BackgroundColor3 = Theme.Accent,
        Text             = "C",
        TextColor3       = Color3.fromRGB(255,255,255),
        TextSize         = 14,
        Font             = Enum.Font.GothamBold,
        BorderSizePixel  = 0,
        Parent           = TopBar,
    })
    Create("UICorner",  { CornerRadius = UDim.new(1, 0), Parent = LogoBtn })
    Create("UIStroke",  { Color = Color3.fromRGB(120,170,255), Thickness = 1.5, Parent = LogoBtn })

    -- Title
    Create("TextLabel", {
        Name             = "TitleLabel",
        Size             = UDim2.new(0, 200, 1, 0),
        Position         = UDim2.new(0, 40, 0, 0),
        BackgroundTransparency = 1,
        Text             = Title,
        TextColor3       = Theme.Text,
        TextSize         = 13,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Parent           = TopBar,
    })

    -- Search bar in topbar
    local SearchBox = Create("TextBox", {
        Name             = "SearchBox",
        Size             = UDim2.new(0, 140, 0, 22),
        Position         = UDim2.new(0.5, -70, 0.5, -11),
        BackgroundColor3 = Theme.InputBg,
        Text             = "",
        PlaceholderText  = "🔍 Search",
        TextColor3       = Theme.TextDim,
        PlaceholderColor3 = Theme.TextMuted,
        TextSize         = 11,
        Font             = Enum.Font.Gotham,
        BorderSizePixel  = 0,
        ClearTextOnFocus = false,
        Parent           = TopBar,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = SearchBox })
    Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = SearchBox })

    -- Close button
    local CloseBtn = Create("TextButton", {
        Name             = "CloseBtn",
        Size             = UDim2.new(0, 22, 0, 22),
        Position         = UDim2.new(1, -28, 0.5, -11),
        BackgroundColor3 = Theme.Red,
        Text             = "✕",
        TextColor3       = Color3.fromRGB(255,255,255),
        TextSize         = 11,
        Font             = Enum.Font.GothamBold,
        BorderSizePixel  = 0,
        Parent           = TopBar,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = CloseBtn })

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainFrame, { Size = UDim2.new(0, 480, 0, 0) }, 0.25)
        wait(0.26)
        ScreenGui:Destroy()
    end)

    -- ── Content area (below topbar) ────────────────────────────────────────
    local ContentFrame = Create("Frame", {
        Name             = "ContentFrame",
        Size             = UDim2.new(1, 0, 1, -36),
        Position         = UDim2.new(0, 0, 0, 36),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        Parent           = MainFrame,
    })

    -- ── Sidebar ────────────────────────────────────────────────────────────
    local Sidebar = Create("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, 36, 1, -24),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel  = 0,
        Parent           = ContentFrame,
    })
    Create("UIListLayout", {
        SortOrder      = Enum.SortOrder.LayoutOrder,
        Padding        = UDim.new(0, 6),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent         = Sidebar,
    })
    Create("UIPadding", { PaddingTop = UDim.new(0, 8), Parent = Sidebar })

    -- ── Tab bar (horizontal, above columns) ───────────────────────────────
    local TabBar = Create("Frame", {
        Name             = "TabBar",
        Size             = UDim2.new(1, -36, 0, 28),
        Position         = UDim2.new(0, 36, 0, 0),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel  = 0,
        Parent           = ContentFrame,
    })
    Create("UIListLayout", {
        FillDirection  = Enum.FillDirection.Horizontal,
        SortOrder      = Enum.SortOrder.LayoutOrder,
        Padding        = UDim.new(0, 2),
        Parent         = TabBar,
    })
    Create("UIPadding", { PaddingLeft = UDim.new(0,6), PaddingTop = UDim.new(0,3), Parent = TabBar })

    -- Divider under tabbar
    Create("Frame", {
        Size             = UDim2.new(1, -36, 0, 1),
        Position         = UDim2.new(0, 36, 0, 28),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel  = 0,
        Parent           = ContentFrame,
    })

    -- ── Tab pages container ────────────────────────────────────────────────
    local PagesHolder = Create("Frame", {
        Name             = "PagesHolder",
        Size             = UDim2.new(1, -36, 1, -29),
        Position         = UDim2.new(0, 36, 0, 29),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent           = ContentFrame,
    })

    -- ── Footer ─────────────────────────────────────────────────────────────
    local Footer = Create("Frame", {
        Name             = "Footer",
        Size             = UDim2.new(1, 0, 0, 22),
        Position         = UDim2.new(0, 0, 1, -22),
        BackgroundColor3 = Theme.FooterBg,
        BorderSizePixel  = 0,
        Parent           = MainFrame,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = Footer })
    Create("Frame", { -- fix top corners
        Size             = UDim2.new(1, 0, 0, 10),
        BackgroundColor3 = Theme.FooterBg,
        BorderSizePixel  = 0,
        Parent           = Footer,
    })
    Create("TextLabel", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = Discord .. "  |  " .. Version .. "  |  Game: " .. Game,
        TextColor3       = Theme.TextMuted,
        TextSize         = 9,
        Font             = Enum.Font.Gotham,
        Parent           = Footer,
    })

    -- ── Draggable ──────────────────────────────────────────────────────────
    MakeDraggable(MainFrame, TopBar)

    -- ── Minimize / Toggle ──────────────────────────────────────────────────
    local isVisible = true
    local function ToggleVisibility()
        isVisible = not isVisible
        if isVisible then
            MainFrame.Visible = true
            Tween(MainFrame, { Size = UDim2.new(0, 480, 0, 420) }, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            Tween(MainFrame, { Size = UDim2.new(0, 480, 0, 0) }, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            wait(0.19)
            MainFrame.Visible = false
        end
    end

    LogoBtn.MouseButton1Click:Connect(ToggleVisibility)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == MinimizeKey then
            ToggleVisibility()
        end
    end)

    -- ── Notification system ────────────────────────────────────────────────
    local NotifHolder = Create("Frame", {
        Name             = "NotifHolder",
        Size             = UDim2.new(0, 220, 1, 0),
        Position         = UDim2.new(1, -230, 0, 0),
        BackgroundTransparency = 1,
        Parent           = ScreenGui,
    })
    Create("UIListLayout", {
        SortOrder        = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding          = UDim.new(0, 6),
        Parent           = NotifHolder,
    })
    Create("UIPadding", { PaddingBottom = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = NotifHolder })

    -- ══════════════════════════════════════════════════════════════════════
    --  Window Object
    -- ══════════════════════════════════════════════════════════════════════
    local Window = {}
    local Tabs = {}
    local ActiveTab = nil

    local function SetActiveTab(tab)
        if ActiveTab then
            ActiveTab._btn.BackgroundColor3 = Theme.Panel
            ActiveTab._btn.TextColor3 = Theme.TextDim
            Tween(ActiveTab._btn, { BackgroundColor3 = Theme.Panel }, 0.15)
            ActiveTab._page.Visible = false
        end
        ActiveTab = tab
        Tween(tab._btn, { BackgroundColor3 = Theme.Accent }, 0.15)
        tab._btn.TextColor3 = Theme.Text
        tab._page.Visible = true
    end

    -- ─── AddTab ───────────────────────────────────────────────────────────
    function Window:AddTab(cfg)
        cfg = cfg or {}
        local name = cfg.Name or "Tab"
        local icon = cfg.Icon or ""

        -- Tab button
        local Btn = Create("TextButton", {
            Name             = name .. "Btn",
            Size             = UDim2.new(0, 80, 0, 22),
            BackgroundColor3 = Theme.Panel,
            Text             = icon .. " " .. name,
            TextColor3       = Theme.TextDim,
            TextSize         = 11,
            Font             = Enum.Font.GothamSemibold,
            BorderSizePixel  = 0,
            AutoButtonColor  = false,
            Parent           = TabBar,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = Btn })

        -- Hover
        Btn.MouseEnter:Connect(function()
            if ActiveTab and ActiveTab._btn ~= Btn then
                Tween(Btn, { BackgroundColor3 = Theme.ButtonHover }, 0.1)
            end
        end)
        Btn.MouseLeave:Connect(function()
            if ActiveTab and ActiveTab._btn ~= Btn then
                Tween(Btn, { BackgroundColor3 = Theme.Panel }, 0.1)
            end
        end)

        -- Page (two columns: left + right)
        local Page = Create("Frame", {
            Name             = name .. "Page",
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible          = false,
            Parent           = PagesHolder,
        })

        -- Left column
        local LeftScroll = Create("ScrollingFrame", {
            Name             = "LeftScroll",
            Size             = UDim2.new(0.5, -1, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.ScrollBar,
            CanvasSize       = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent           = Page,
        })
        Create("UIPadding", { PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,6), PaddingTop = UDim.new(0,8), Parent = LeftScroll })
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,6), Parent = LeftScroll })

        -- Divider
        Create("Frame", {
            Size             = UDim2.new(0, 1, 1, 0),
            Position         = UDim2.new(0.5, 0, 0, 0),
            BackgroundColor3 = Theme.Divider,
            BorderSizePixel  = 0,
            Parent           = Page,
        })

        -- Right column
        local RightScroll = Create("ScrollingFrame", {
            Name             = "RightScroll",
            Size             = UDim2.new(0.5, -1, 1, 0),
            Position         = UDim2.new(0.5, 1, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.ScrollBar,
            CanvasSize       = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent           = Page,
        })
        Create("UIPadding", { PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,10), PaddingTop = UDim.new(0,8), Parent = RightScroll })
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,6), Parent = RightScroll })

        local Tab = { _btn = Btn, _page = Page }
        local sectionSide = "left" -- alternate sides

        Btn.MouseButton1Click:Connect(function() SetActiveTab(Tab) end)
        table.insert(Tabs, Tab)
        if #Tabs == 1 then SetActiveTab(Tab) end

        -- ─── AddSection ───────────────────────────────────────────────────
        function Tab:AddSection(scfg)
            scfg = scfg or {}
            local sname = scfg.Name or "Section"
            local side  = scfg.Side or sectionSide
            sectionSide = (sectionSide == "left") and "right" or "left"

            local parent = (side == "right") and RightScroll or LeftScroll

            -- Section container
            local SectionFrame = Create("Frame", {
                Name             = sname .. "Section",
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Panel,
                BorderSizePixel  = 0,
                Parent           = parent,
            })
            Create("UICorner",  { CornerRadius = UDim.new(0, 7), Parent = SectionFrame })
            Create("UIStroke",  { Color = Theme.Border, Thickness = 1, Parent = SectionFrame })
            Create("UIPadding", {
                PaddingLeft   = UDim.new(0, 10),
                PaddingRight  = UDim.new(0, 10),
                PaddingTop    = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 8),
                Parent        = SectionFrame,
            })

            local SectionList = Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding   = UDim.new(0, 6),
                Parent    = SectionFrame,
            })

            -- Section title
            local TitleRow = Create("Frame", {
                Name             = "TitleRow",
                Size             = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Parent           = SectionFrame,
            })
            Create("TextLabel", {
                Size             = UDim2.new(0.7, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = sname,
                TextColor3       = Theme.SectionTitle,
                TextSize         = 11,
                Font             = Enum.Font.GothamBold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = TitleRow,
            })
            -- Divider under title
            Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                Position         = UDim2.new(0, 0, 1, 2),
                BackgroundColor3 = Theme.Divider,
                BorderSizePixel  = 0,
                Parent           = TitleRow,
            })

            local Section = {}

            -- ── helpers ────────────────────────────────────────────────────
            local function MakeRow(name)
                local row = Create("Frame", {
                    Name             = name .. "Row",
                    Size             = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Parent           = SectionFrame,
                })
                local lbl = Create("TextLabel", {
                    Size             = UDim2.new(0.65, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = name,
                    TextColor3       = Theme.TextDim,
                    TextSize         = 11,
                    Font             = Enum.Font.Gotham,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Parent           = row,
                })
                return row, lbl
            end

            -- ── AddToggle ─────────────────────────────────────────────────
            function Section:AddToggle(tcfg)
                tcfg = tcfg or {}
                local tname    = tcfg.Name     or "Toggle"
                local default  = tcfg.Default  or false
                local callback = tcfg.Callback or function() end
                local value    = default

                local row, lbl = MakeRow(tname)
                row.Size = UDim2.new(1, 0, 0, 24)

                -- Track
                local Track = Create("Frame", {
                    Name             = "Track",
                    Size             = UDim2.new(0, 34, 0, 18),
                    Position         = UDim2.new(1, -34, 0.5, -9),
                    BackgroundColor3 = value and Theme.Toggle_ON or Theme.Toggle_OFF,
                    BorderSizePixel  = 0,
                    Parent           = row,
                })
                Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = Track })
                Create("UIStroke", { Color = value and Theme.AccentGlow or Theme.Border, Thickness = 1, Parent = Track })

                -- Thumb
                local Thumb = Create("Frame", {
                    Size             = UDim2.new(0, 12, 0, 12),
                    Position         = UDim2.new(0, value and 18 or 2, 0.5, -6),
                    BackgroundColor3 = Color3.fromRGB(255,255,255),
                    BorderSizePixel  = 0,
                    Parent           = Track,
                })
                Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = Thumb })

                local Btn = Create("TextButton", {
                    Size             = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = "",
                    Parent           = row,
                    ZIndex           = 5,
                })

                local function SetToggle(v)
                    value = v
                    Tween(Track, { BackgroundColor3 = v and Theme.Toggle_ON or Theme.Toggle_OFF }, 0.15)
                    Tween(Thumb, { Position = UDim2.new(0, v and 18 or 2, 0.5, -6) }, 0.15)
                    local stroke = Track:FindFirstChildOfClass("UIStroke")
                    if stroke then Tween(stroke, { Color = v and Theme.AccentGlow or Theme.Border }, 0.15) end
                    pcall(callback, v)
                end

                Btn.MouseButton1Click:Connect(function() SetToggle(not value) end)

                local ToggleObj = {}
                function ToggleObj:Set(v) SetToggle(v) end
                function ToggleObj:Get() return value end
                return ToggleObj
            end

            -- ── AddSlider ─────────────────────────────────────────────────
            function Section:AddSlider(scfg2)
                scfg2 = scfg2 or {}
                local sname2   = scfg2.Name     or "Slider"
                local min      = scfg2.Min      or 0
                local max      = scfg2.Max      or 100
                local default2 = scfg2.Default  or min
                local callback = scfg2.Callback or function() end
                local suffix   = scfg2.Suffix   or ""
                local value    = math.clamp(default2, min, max)

                local Container = Create("Frame", {
                    Name             = sname2 .. "SliderContainer",
                    Size             = UDim2.new(1, 0, 0, 44),
                    BackgroundTransparency = 1,
                    Parent           = SectionFrame,
                })

                -- Label + value
                local HeaderRow = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Parent           = Container,
                })
                Create("TextLabel", {
                    Size             = UDim2.new(0.7, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text             = sname2,
                    TextColor3       = Theme.TextDim,
                    TextSize         = 11,
                    Font             = Enum.Font.Gotham,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Parent           = HeaderRow,
                })
                local ValLabel = Create("TextLabel", {
                    Size             = UDim2.new(0.3, 0, 1, 0),
                    Position         = UDim2.new(0.7, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text             = tostring(value) .. suffix,
                    TextColor3       = Theme.TextMuted,
                    TextSize         = 10,
                    Font             = Enum.Font.Gotham,
                    TextXAlignment   = Enum.TextXAlignment.Right,
                    Parent           = HeaderRow,
                })

                -- Track background
                local TrackBg = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 4),
                    Position         = UDim2.new(0, 0, 0, 22),
                    BackgroundColor3 = Theme.SliderBg,
                    BorderSizePixel  = 0,
                    Parent           = Container,
                })
                Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = TrackBg })

                -- Fill
                local pct = (value - min) / (max - min)
                local Fill = Create("Frame", {
                    Size             = UDim2.new(pct, 0, 1, 0),
                    BackgroundColor3 = Theme.SliderFill,
                    BorderSizePixel  = 0,
                    Parent           = TrackBg,
                })
                Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = Fill })

                -- Knob
                local Knob = Create("Frame", {
                    Size             = UDim2.new(0, 12, 0, 12),
                    Position         = UDim2.new(pct, -6, 0.5, -6),
                    BackgroundColor3 = Color3.fromRGB(255,255,255),
                    BorderSizePixel  = 0,
                    ZIndex           = 3,
                    Parent           = TrackBg,
                })
                Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = Knob })
                Create("UIStroke", { Color = Theme.Accent, Thickness = 1.5, Parent = Knob })

                -- Invisible drag button
                local DragBtn = Create("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 24),
                    Position         = UDim2.new(0, 0, 0.5, -12),
                    BackgroundTransparency = 1,
                    Text             = "",
                    ZIndex           = 5,
                    Parent           = TrackBg,
                })

                local dragging = false
                local function UpdateSlider(inputX)
                    local abs = TrackBg.AbsolutePosition.X
                    local w   = TrackBg.AbsoluteSize.X
                    local p   = math.clamp((inputX - abs) / w, 0, 1)
                    value = math.floor(min + (max - min) * p)
                    Fill.Size = UDim2.new(p, 0, 1, 0)
                    Tween(Knob, { Position = UDim2.new(p, -6, 0.5, -6) }, 0.05)
                    ValLabel.Text = tostring(value) .. suffix
                    pcall(callback, value)
                end

                DragBtn.MouseButton1Down:Connect(function()
                    dragging = true
                    UpdateSlider(Mouse.X)
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                local SliderObj = {}
                function SliderObj:Set(v)
                    value = math.clamp(v, min, max)
                    local p2 = (value - min)/(max - min)
                    Fill.Size = UDim2.new(p2, 0, 1, 0)
                    Knob.Position = UDim2.new(p2, -6, 0.5, -6)
                    ValLabel.Text = tostring(value) .. suffix
                end
                function SliderObj:Get() return value end
                return SliderObj
            end

            -- ── AddDropdown ───────────────────────────────────────────────
            function Section:AddDropdown(dcfg)
                dcfg = dcfg or {}
                local dname    = dcfg.Name     or "Dropdown"
                local options  = dcfg.Options  or {}
                local default3 = dcfg.Default  or (options[1] or "---")
                local callback = dcfg.Callback or function() end
                local value    = default3
                local open     = false

                local Container = Create("Frame", {
                    Name             = dname .. "DDContainer",
                    Size             = UDim2.new(1, 0, 0, 42),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    ZIndex           = 10,
                    Parent           = SectionFrame,
                })

                Create("TextLabel", {
                    Size             = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text             = dname,
                    TextColor3       = Theme.TextDim,
                    TextSize         = 11,
                    Font             = Enum.Font.Gotham,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    ZIndex           = 10,
                    Parent           = Container,
                })

                -- Main button
                local DropBtn = Create("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 22),
                    Position         = UDim2.new(0, 0, 0, 18),
                    BackgroundColor3 = Theme.InputBg,
                    Text             = value,
                    TextColor3       = Theme.TextDim,
                    TextSize         = 11,
                    Font             = Enum.Font.Gotham,
                    BorderSizePixel  = 0,
                    AutoButtonColor  = false,
                    ZIndex           = 10,
                    Parent           = Container,
                })
                Create("UICorner", { CornerRadius = UDim.new(0,5), Parent = DropBtn })
                Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = DropBtn })

                -- Arrow
                local Arrow = Create("TextLabel", {
                    Size             = UDim2.new(0, 20, 1, 0),
                    Position         = UDim2.new(1, -22, 0, 0),
                    BackgroundTransparency = 1,
                    Text             = "▾",
                    TextColor3       = Theme.TextMuted,
                    TextSize         = 12,
                    Font             = Enum.Font.GothamBold,
                    ZIndex           = 11,
                    Parent           = DropBtn,
                })

                -- Options list
                local OptionsList = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 0),
                    Position         = UDim2.new(0, 0, 1, 2),
                    BackgroundColor3 = Theme.Panel,
                    BorderSizePixel  = 0,
                    ClipsDescendants = true,
                    ZIndex           = 20,
                    Visible          = false,
                    Parent           = DropBtn,
                })
                Create("UICorner", { CornerRadius = UDim.new(0,5), Parent = OptionsList })
                Create("UIStroke", { Color = Theme.Border, Thickness = 1, Parent = OptionsList })
                Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = OptionsList })

                for _, opt in ipairs(options) do
                    local OptBtn = Create("TextButton", {
                        Size             = UDim2.new(1, 0, 0, 22),
                        BackgroundColor3 = Theme.Panel,
                        Text             = opt,
                        TextColor3       = Theme.TextDim,
                        TextSize         = 11,
                        Font             = Enum.Font.Gotham,
                        BorderSizePixel  = 0,
                        AutoButtonColor  = false,
                        ZIndex           = 21,
                        Parent           = OptionsList,
                    })
                    OptBtn.MouseEnter:Connect(function() Tween(OptBtn, { BackgroundColor3 = Theme.ButtonHover }, 0.1) end)
                    OptBtn.MouseLeave:Connect(function() Tween(OptBtn, { BackgroundColor3 = Theme.Panel }, 0.1) end)
                    OptBtn.MouseButton1Click:Connect(function()
                        value = opt
                        DropBtn.Text = opt
                        open = false
                        Tween(OptionsList, { Size = UDim2.new(1, 0, 0, 0) }, 0.15)
                        task.delay(0.16, function() OptionsList.Visible = false end)
                        Tween(Arrow, { Rotation = 0 }, 0.15)
                        Container.Size = UDim2.new(1, 0, 0, 42)
                        pcall(callback, value)
                    end)
                end

                DropBtn.MouseButton1Click:Connect(function()
                    open = not open
                    local targetH = #options * 22
                    if open then
                        OptionsList.Visible = true
                        OptionsList.Size = UDim2.new(1, 0, 0, 0)
                        Tween(OptionsList, { Size = UDim2.new(1, 0, 0, targetH) }, 0.18, Enum.EasingStyle.Back)
                        Tween(Arrow, { Rotation = 180 }, 0.15)
                        Container.Size = UDim2.new(1, 0, 0, 42 + targetH + 4)
                    else
                        Tween(OptionsList, { Size = UDim2.new(1, 0, 0, 0) }, 0.15)
                        task.delay(0.16, function() OptionsList.Visible = false end)
                        Tween(Arrow, { Rotation = 0 }, 0.15)
                        Container.Size = UDim2.new(1, 0, 0, 42)
                    end
                end)

                local DDObj = {}
                function DDObj:Set(v) value = v; DropBtn.Text = v end
                function DDObj:Get() return value end
                return DDObj
            end

            -- ── AddButton ─────────────────────────────────────────────────
            function Section:AddButton(bcfg)
                bcfg = bcfg or {}
                local bname    = bcfg.Name     or "Button"
                local callback = bcfg.Callback or function() end
                local color    = bcfg.Color    or Theme.Accent

                local Btn = Create("TextButton", {
                    Name             = bname .. "Btn",
                    Size             = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = color,
                    Text             = bname,
                    TextColor3       = Color3.fromRGB(255,255,255),
                    TextSize         = 12,
                    Font             = Enum.Font.GothamBold,
                    BorderSizePixel  = 0,
                    AutoButtonColor  = false,
                    Parent           = SectionFrame,
                })
                Create("UICorner", { CornerRadius = UDim.new(0,6), Parent = Btn })

                Btn.MouseEnter:Connect(function() Tween(Btn, { BackgroundColor3 = Theme.AccentGlow }, 0.1) end)
                Btn.MouseLeave:Connect(function() Tween(Btn, { BackgroundColor3 = color }, 0.1) end)
                Btn.MouseButton1Click:Connect(function()
                    Tween(Btn, { BackgroundColor3 = Theme.AccentDark }, 0.05)
                    task.delay(0.1, function() Tween(Btn, { BackgroundColor3 = color }, 0.1) end)
                    pcall(callback)
                end)

                return Btn
            end

            -- ── AddLabel ──────────────────────────────────────────────────
            function Section:AddLabel(lcfg)
                lcfg = lcfg or {}
                local text  = lcfg.Text  or ""
                local color = lcfg.Color or Theme.TextMuted

                local Lbl = Create("TextLabel", {
                    Name             = "Label",
                    Size             = UDim2.new(1, 0, 0, 0),
                    AutomaticSize    = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Text             = text,
                    TextColor3       = color,
                    TextSize         = 10,
                    Font             = Enum.Font.Gotham,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    TextWrapped      = true,
                    Parent           = SectionFrame,
                })

                local LblObj = {}
                function LblObj:Set(t) Lbl.Text = t end
                return LblObj
            end

            -- ── AddDivider ────────────────────────────────────────────────
            function Section:AddDivider(dname2)
                local D = Create("Frame", {
                    Name             = "Divider",
                    Size             = UDim2.new(1, 0, 0, 14),
                    BackgroundTransparency = 1,
                    Parent           = SectionFrame,
                })
                if dname2 then
                    Create("TextLabel", {
                        Size             = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text             = dname2,
                        TextColor3       = Theme.TextMuted,
                        TextSize         = 9,
                        Font             = Enum.Font.GothamBold,
                        TextXAlignment   = Enum.TextXAlignment.Center,
                        Parent           = D,
                    })
                end
                Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 1),
                    Position         = UDim2.new(0, 0, 0.5, 0),
                    BackgroundColor3 = Theme.Divider,
                    BorderSizePixel  = 0,
                    Parent           = D,
                    ZIndex           = 0,
                })
            end

            return Section
        end -- AddSection

        return Tab
    end -- AddTab

    -- ── Notify ────────────────────────────────────────────────────────────
    function Window:Notify(ncfg)
        ncfg = ncfg or {}
        local title    = ncfg.Title   or "Notification"
        local desc     = ncfg.Desc    or ""
        local duration = ncfg.Duration or 3
        local color    = ncfg.Color   or Theme.Accent

        local NFrame = Create("Frame", {
            Size             = UDim2.new(1, 0, 0, 60),
            BackgroundColor3 = Theme.Panel,
            BorderSizePixel  = 0,
            BackgroundTransparency = 1,
            Parent           = NotifHolder,
        })
        Create("UICorner", { CornerRadius = UDim.new(0,8), Parent = NFrame })
        Create("UIStroke", { Color = color, Thickness = 1, Parent = NFrame })

        -- Accent bar
        Create("Frame", {
            Size             = UDim2.new(0, 3, 1, 0),
            BackgroundColor3 = color,
            BorderSizePixel  = 0,
            Parent           = NFrame,
        })
        Create("UICorner", { CornerRadius = UDim.new(0,4), Parent = NFrame:FindFirstChild("Frame") })

        Create("TextLabel", {
            Size             = UDim2.new(1, -16, 0, 20),
            Position         = UDim2.new(0, 12, 0, 8),
            BackgroundTransparency = 1,
            Text             = title,
            TextColor3       = Theme.Text,
            TextSize         = 12,
            Font             = Enum.Font.GothamBold,
            TextXAlignment   = Enum.TextXAlignment.Left,
            Parent           = NFrame,
        })
        Create("TextLabel", {
            Size             = UDim2.new(1, -16, 0, 30),
            Position         = UDim2.new(0, 12, 0, 26),
            BackgroundTransparency = 1,
            Text             = desc,
            TextColor3       = Theme.TextDim,
            TextSize         = 10,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
            TextWrapped      = true,
            Parent           = NFrame,
        })

        Tween(NFrame, { BackgroundTransparency = 0 }, 0.2)
        task.delay(duration, function()
            Tween(NFrame, { BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0) }, 0.2)
            task.delay(0.21, function() NFrame:Destroy() end)
        end)
    end

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    return Window
end

return Library
