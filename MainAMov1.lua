-- ──────────────────────────────────────────────────────────────
-- ASTRO — Unified Drop Method + Fixed Private Server Rejoin
-- ──────────────────────────────────────────────────────────────

local __AstroEnv = (type(getgenv) == "function" and getgenv()) or _G
if __AstroEnv.__AstroActive then return end
__AstroEnv.__AstroActive = true

-- ── SERVICES ──────────────────────────────────────────────────
local S = {
    Players           = game:GetService("Players"),
    CoreGui           = game:GetService("CoreGui"),
    RunService        = game:GetService("RunService"),
    UserInputService  = game:GetService("UserInputService"),
    TweenService      = game:GetService("TweenService"),
    HttpService       = game:GetService("HttpService"),
    TeleportService   = game:GetService("TeleportService"),
    GuiService        = game:GetService("GuiService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
}

local LocalPlayer = S.Players.LocalPlayer

-- ── GUI ROOT ──────────────────────────────────────────────────
local function resolveGuiRoot()
    local ok, h = pcall(function() return gethui() end)
    if ok and typeof(h) == "Instance" then return h end
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pg then return pg end
    return LocalPlayer:WaitForChild("PlayerGui", 10) or S.CoreGui
end
local GuiRoot = resolveGuiRoot()

pcall(function()
    local old = GuiRoot:FindFirstChild("Astro") or S.CoreGui:FindFirstChild("Astro")
    if old then old:Destroy() end
end)

local function Notify(text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Astro",
            Text  = tostring(text),
            Duration = duration or 3,
        })
    end)
end

-- ── COLORS ────────────────────────────────────────────────────
local C = {
    BASE     = Color3.fromRGB(13,  8,  32),
    SURFACE  = Color3.fromRGB(22, 14,  46),
    ELEVATED = Color3.fromRGB(33, 22,  66),
    BORDER   = Color3.fromRGB(74, 45, 128),
    DIVIDER  = Color3.fromRGB(30, 18,  58),
    TEXT_1   = Color3.fromRGB(237, 232, 255),
    TEXT_2   = Color3.fromRGB(184, 159, 232),
    TEXT_3   = Color3.fromRGB(112, 85, 168),
    ACCENT   = Color3.fromRGB(139, 93, 209),
    ACCENT_D = Color3.fromRGB(106, 58, 170),
    GREEN    = Color3.fromRGB(60, 200, 100),
}

-- ── UI HELPERS ───────────────────────────────────────────────
local function Corner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = UDim.new(0, r or 6)
end

local function Stroke(p, col, th)
    local s = Instance.new("UIStroke", p)
    s.Color = col or C.BORDER
    s.Thickness = th or 1
    return s
end

local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = inp.Position
            startPos  = frame.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    S.UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch) then
            local delta = inp.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local MainSG = Instance.new("ScreenGui", GuiRoot)
MainSG.Name = "Astro"
MainSG.ResetOnSpawn = false

local activeDropdown = nil

local function BuatSection(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextColor3 = C.TEXT_2
    lbl.Text = text:upper()
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
end

local function BuatLabel(parent, defaultText)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundColor3 = C.SURFACE
    Corner(row, 6)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = defaultText
    lbl.TextColor3 = C.TEXT_1
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

local function BuatToggle(parent, label, defaultState)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundColor3 = C.SURFACE
    Corner(row, 6)
    local rowStroke = Stroke(row, C.BORDER)

    local leftAccent = Instance.new("Frame", row)
    leftAccent.Size = UDim2.new(0, 2, 0, 18)
    leftAccent.Position = UDim2.new(0, 0, 0.5, -9)
    leftAccent.BackgroundColor3 = C.BORDER
    Corner(leftAccent, 1)

    local labelTxt = Instance.new("TextLabel", row)
    labelTxt.Size = UDim2.new(1, -70, 1, 0)
    labelTxt.Position = UDim2.new(0, 14, 0, 0)
    labelTxt.BackgroundTransparency = 1
    labelTxt.Text = label
    labelTxt.TextColor3 = C.TEXT_2
    labelTxt.Font = Enum.Font.GothamMedium
    labelTxt.TextSize = 12
    labelTxt.TextXAlignment = Enum.TextXAlignment.Left

    local pill = Instance.new("Frame", row)
    pill.Size = UDim2.new(0, 38, 0, 20)
    pill.Position = UDim2.new(1, -50, 0.5, -10)
    pill.BackgroundColor3 = C.DIVIDER
    Corner(pill, 10)

    local pillDot = Instance.new("Frame", pill)
    pillDot.Size = UDim2.new(0, 14, 0, 14)
    pillDot.Position = UDim2.new(0, 3, 0.5, -7)
    pillDot.BackgroundColor3 = C.TEXT_3
    Corner(pillDot, 7)

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    local function SetTween(on)
        S.TweenService:Create(row, TweenInfo.new(0.2), {
            BackgroundColor3 = on and C.ELEVATED or C.SURFACE
        }):Play()
        rowStroke.Color = on and C.ACCENT_D or C.BORDER
        labelTxt.TextColor3 = on and C.TEXT_1 or C.TEXT_2
        leftAccent.BackgroundColor3 = on and C.ACCENT or C.BORDER
        S.TweenService:Create(pill, TweenInfo.new(0.2), {
            BackgroundColor3 = on and C.ACCENT_D or C.DIVIDER
        }):Play()
        S.TweenService:Create(pillDot, TweenInfo.new(0.2), {
            Position = on and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
            BackgroundColor3 = on and C.ACCENT or C.TEXT_3,
        }):Play()
    end
    SetTween(defaultState == true)
    return btn, SetTween
end

local function BuatButton(parent, label)
    local row = Instance.new("TextButton", parent)
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = C.SURFACE
    row.Text = ""
    row.AutoButtonColor = false
    Corner(row, 6)
    Stroke(row, C.BORDER)

    local leftAccent = Instance.new("Frame", row)
    leftAccent.Size = UDim2.new(0, 2, 0, 18)
    leftAccent.Position = UDim2.new(0, 0, 0.5, -9)
    leftAccent.BackgroundColor3 = C.BORDER
    Corner(leftAccent, 1)

    local labelTxt = Instance.new("TextLabel", row)
    labelTxt.Size = UDim2.new(1, -20, 1, 0)
    labelTxt.Position = UDim2.new(0, 14, 0, 0)
    labelTxt.BackgroundTransparency = 1
    labelTxt.Text = label
    labelTxt.TextColor3 = C.TEXT_1
    labelTxt.Font = Enum.Font.GothamMedium
    labelTxt.TextSize = 12
    labelTxt.TextXAlignment = Enum.TextXAlignment.Left
    return row
end

local function BuatSlider(parent, label, min, max, default, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 50)
    row.BackgroundColor3 = C.SURFACE
    Corner(row, 6)
    Stroke(row, C.BORDER)

    local labelTxt = Instance.new("TextLabel", row)
    labelTxt.Size = UDim2.new(0.7, 0, 0, 20)
    labelTxt.Position = UDim2.new(0, 14, 0, 5)
    labelTxt.BackgroundTransparency = 1
    labelTxt.Text = label .. ": " .. tostring(default)
    labelTxt.TextColor3 = C.TEXT_1
    labelTxt.Font = Enum.Font.GothamMedium
    labelTxt.TextSize = 11
    labelTxt.TextXAlignment = Enum.TextXAlignment.Left

    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(1, -28, 0, 4)
    track.Position = UDim2.new(0, 14, 1, -12)
    track.BackgroundColor3 = C.DIVIDER
    Corner(track, 2)

    local progress = Instance.new("Frame", track)
    progress.Size = UDim2.new(0, 0, 1, 0)
    progress.BackgroundColor3 = C.ACCENT
    Corner(progress, 2)

    local thumb = Instance.new("Frame", track)
    thumb.Size = UDim2.new(0, 12, 0, 12)
    thumb.Position = UDim2.new(0, -6, 0.5, -6)
    thumb.BackgroundColor3 = C.TEXT_1
    Corner(thumb, 6)

    local dragger = Instance.new("TextButton", track)
    dragger.Size = UDim2.new(1, 0, 3, 0)
    dragger.Position = UDim2.new(0, 0, -1, 0)
    dragger.BackgroundTransparency = 1
    dragger.Text = ""

    local function UpdateSlider(value)
        local pct = math.clamp((value - min) / (max - min), 0, 1)
        progress.Size = UDim2.new(pct, 0, 1, 0)
        thumb.Position = UDim2.new(pct, -6, 0.5, -6)
        labelTxt.Text = label .. ": " .. string.format("%d", value)
        callback(math.floor(value))
    end
    UpdateSlider(default)

    local dragging = false
    dragger.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    dragger.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    S.UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            local relX = i.Position.X - track.AbsolutePosition.X
            local pct  = math.clamp(relX / track.AbsoluteSize.X, 0, 1)
            UpdateSlider(min + (max - min) * pct)
        end
    end)
end

local function BuatInput(parent, label, placeholder, default, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundColor3 = C.SURFACE
    Corner(row, 6)
    Stroke(row, C.BORDER)

    local labelTxt = Instance.new("TextLabel", row)
    labelTxt.Size = UDim2.new(0.5, -20, 1, 0)
    labelTxt.Position = UDim2.new(0, 14, 0, 0)
    labelTxt.BackgroundTransparency = 1
    labelTxt.Text = label
    labelTxt.TextColor3 = C.TEXT_1
    labelTxt.Font = Enum.Font.GothamMedium
    labelTxt.TextSize = 12
    labelTxt.TextXAlignment = Enum.TextXAlignment.Left

    local inputBox = Instance.new("TextBox", row)
    inputBox.Size = UDim2.new(0.4, 0, 0, 24)
    inputBox.Position = UDim2.new(0.6, -14, 0.5, -12)
    inputBox.BackgroundColor3 = C.ELEVATED
    Corner(inputBox, 4)
    Stroke(inputBox, C.DIVIDER)
    inputBox.Text = default or ""
    inputBox.PlaceholderText = placeholder or ""
    inputBox.TextColor3 = C.TEXT_1
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 11
    inputBox.FocusLost:Connect(function()
        callback(inputBox.Text)
    end)
    return row, inputBox
end

-- ── DROP AMOUNT ROW ─────────────────────────────────────────
local function BuatDropAmount(parent, label, defaultAmount, onChanged)
    local currentAmount = defaultAmount
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundColor3 = C.SURFACE
    Corner(row, 6)
    Stroke(row, C.BORDER)

    local leftAccent = Instance.new("Frame", row)
    leftAccent.Size = UDim2.new(0, 2, 0, 18)
    leftAccent.Position = UDim2.new(0, 0, 0.5, -9)
    leftAccent.BackgroundColor3 = C.BORDER
    Corner(leftAccent, 1)

    local labelTxt = Instance.new("TextLabel", row)
    labelTxt.Size = UDim2.new(0.38, 0, 1, 0)
    labelTxt.Position = UDim2.new(0, 14, 0, 0)
    labelTxt.BackgroundTransparency = 1
    labelTxt.Text = label
    labelTxt.TextColor3 = C.TEXT_2
    labelTxt.Font = Enum.Font.GothamMedium
    labelTxt.TextSize = 11
    labelTxt.TextXAlignment = Enum.TextXAlignment.Left

    local allBtn = Instance.new("TextButton", row)
    allBtn.Size = UDim2.new(0, 38, 0, 26)
    allBtn.Position = UDim2.new(0.39, 0, 0.5, -13)
    allBtn.BackgroundColor3 = currentAmount == nil and C.ACCENT or C.ELEVATED
    allBtn.Text = "All"
    allBtn.TextColor3 = C.TEXT_1
    allBtn.Font = Enum.Font.GothamBold
    allBtn.TextSize = 11
    allBtn.AutoButtonColor = false
    Corner(allBtn, 4)

    local inputBox = Instance.new("TextBox", row)
    inputBox.Size = UDim2.new(0, 80, 0, 26)
    inputBox.Position = UDim2.new(1, -94, 0.5, -13)
    inputBox.BackgroundColor3 = C.ELEVATED
    Corner(inputBox, 4)
    Stroke(inputBox, C.DIVIDER)
    inputBox.Text = currentAmount and tostring(currentAmount) or ""
    inputBox.PlaceholderText = "Jumlah..."
    inputBox.TextColor3 = C.TEXT_1
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 11
    inputBox.ClearTextOnFocus = false

    local function setAll()
        currentAmount = nil
        inputBox.Text = ""
        allBtn.BackgroundColor3 = C.ACCENT
        leftAccent.BackgroundColor3 = C.ACCENT
        onChanged(nil)
    end

    local function setAmount(n)
        currentAmount = n
        allBtn.BackgroundColor3 = C.ELEVATED
        leftAccent.BackgroundColor3 = C.BORDER
        onChanged(n)
    end

    allBtn.MouseButton1Click:Connect(setAll)
    inputBox.FocusLost:Connect(function()
        local text = inputBox.Text:gsub("%s", "")
        if text == "" or text:lower() == "all" then
            setAll()
        else
            local n = tonumber(text)
            if n and n > 0 then
                n = math.floor(n)
                inputBox.Text = tostring(n)
                setAmount(n)
            else
                setAll()
            end
        end
    end)

    if currentAmount == nil then
        allBtn.BackgroundColor3 = C.ACCENT
        leftAccent.BackgroundColor3 = C.ACCENT
    else
        allBtn.BackgroundColor3 = C.ELEVATED
        leftAccent.BackgroundColor3 = C.BORDER
        inputBox.Text = tostring(currentAmount)
    end

    local function resetToAll()
        setAll()
        inputBox.Text = ""
    end
    local function getCurrentAmount()
        return currentAmount
    end
    return row, getCurrentAmount, resetToAll
end

-- ── DROPDOWN ──────────────────────────────────────────────────
local function BuatDropdown(parent, label, options, isMulti, defaultSelected, callback)
    local selected = isMulti and {} or ""
    if isMulti and type(defaultSelected) == "table" then
        for _, v in ipairs(defaultSelected) do
            if type(v) == "string" and v ~= "" then
                selected[v] = true
            end
        end
    elseif not isMulti and type(defaultSelected) == "string" then
        selected = defaultSelected
    end

    local function displayText()
        if isMulti then
            local keys = {}
            for k in pairs(selected) do
                keys[#keys + 1] = k
            end
            if #keys == 0 then return "None" end
            table.sort(keys)
            if #keys == 1 then return keys[1] end
            return keys[1] .. " +" .. tostring(#keys - 1)
        else
            return selected == "" and "None" or selected
        end
    end

    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundColor3 = C.SURFACE
    Corner(row, 6)
    Stroke(row, C.BORDER)

    local labelTxt = Instance.new("TextLabel", row)
    labelTxt.Size = UDim2.new(0.42, 0, 1, 0)
    labelTxt.Position = UDim2.new(0, 14, 0, 0)
    labelTxt.BackgroundTransparency = 1
    labelTxt.Text = label
    labelTxt.TextColor3 = C.TEXT_2
    labelTxt.Font = Enum.Font.GothamMedium
    labelTxt.TextSize = 11
    labelTxt.TextXAlignment = Enum.TextXAlignment.Left

    local dropBtn = Instance.new("TextButton", row)
    dropBtn.Size = UDim2.new(0.55, 0, 0, 28)
    dropBtn.Position = UDim2.new(0.44, 0, 0.5, -14)
    dropBtn.BackgroundColor3 = C.ELEVATED
    Corner(dropBtn, 4)
    Stroke(dropBtn, C.DIVIDER)
    dropBtn.Text = displayText()
    dropBtn.TextColor3 = C.TEXT_1
    dropBtn.Font = Enum.Font.GothamMedium
    dropBtn.TextSize = 11
    dropBtn.AutoButtonColor = false

    local panel = Instance.new("Frame", MainSG)
    panel.Size = UDim2.new(0, 220, 0, math.min(#options * 28 + 8, 180))
    panel.BackgroundColor3 = C.ELEVATED
    Corner(panel, 6)
    Stroke(panel, C.BORDER)
    panel.Visible = false
    panel.ZIndex = 20

    local panelScroll = Instance.new("ScrollingFrame", panel)
    panelScroll.Size = UDim2.new(1, -4, 1, -4)
    panelScroll.Position = UDim2.new(0, 2, 0, 2)
    panelScroll.BackgroundTransparency = 1
    panelScroll.BorderSizePixel = 0
    panelScroll.ScrollBarThickness = 3
    panelScroll.ZIndex = 20

    local panelLayout = Instance.new("UIListLayout", panelScroll)
    panelLayout.Padding = UDim.new(0, 2)
    panelLayout.SortOrder = Enum.SortOrder.LayoutOrder
    panelLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        panelScroll.CanvasSize = UDim2.new(0, 0, 0, panelLayout.AbsoluteContentSize.Y + 6)
    end)

    local function rebuildOptions(optList)
        for _, ch in ipairs(panelScroll:GetChildren()) do
            if ch:IsA("TextButton") then ch:Destroy() end
        end

        local clearBtn = Instance.new("TextButton", panelScroll)
        clearBtn.Size = UDim2.new(1, 0, 0, 26)
        clearBtn.BackgroundTransparency = 1
        clearBtn.Text = "None"
        clearBtn.TextColor3 = C.TEXT_3
        clearBtn.Font = Enum.Font.GothamMedium
        clearBtn.TextSize = 11
        clearBtn.ZIndex = 21
        clearBtn.MouseButton1Click:Connect(function()
            if isMulti then
                table.clear(selected)
            else
                selected = ""
            end
            dropBtn.Text = displayText()
            panel.Visible = false
            activeDropdown = nil
            callback(isMulti and {} or "")
        end)

        for _, opt in ipairs(optList) do
            local isOn = isMulti and selected[opt] == true or selected == opt
            local oBtn = Instance.new("TextButton", panelScroll)
            oBtn.Size = UDim2.new(1, 0, 0, 26)
            oBtn.BackgroundColor3 = isOn and C.ACCENT_D or C.ELEVATED
            oBtn.BorderSizePixel = 0
            Corner(oBtn, 4)
            oBtn.Text = opt
            oBtn.TextColor3 = isOn and C.TEXT_1 or C.TEXT_2
            oBtn.Font = Enum.Font.GothamMedium
            oBtn.TextSize = 11
            oBtn.ZIndex = 21
            oBtn.MouseButton1Click:Connect(function()
                if isMulti then
                    if selected[opt] then
                        selected[opt] = nil
                    else
                        selected[opt] = true
                    end
                    for _, child in ipairs(panelScroll:GetChildren()) do
                        if child:IsA("TextButton") and child ~= clearBtn then
                            local on = selected[child.Text] == true
                            child.BackgroundColor3 = on and C.ACCENT_D or C.ELEVATED
                            child.TextColor3 = on and C.TEXT_1 or C.TEXT_2
                        end
                    end
                else
                    selected = (opt == "None") and "" or opt
                    panel.Visible = false
                    activeDropdown = nil
                end
                dropBtn.Text = displayText()
                local result
                if isMulti then
                    result = {}
                    for k in pairs(selected) do
                        result[#result + 1] = k
                    end
                else
                    result = selected
                end
                callback(result)
            end)
        end
    end
    rebuildOptions(options)

    dropBtn.MouseButton1Click:Connect(function()
        if panel.Visible then
            panel.Visible = false
            activeDropdown = nil
            return
        end
        if activeDropdown and activeDropdown ~= panel then
            activeDropdown.Visible = false
        end
        local absPos  = dropBtn.AbsolutePosition
        local absSize = dropBtn.AbsoluteSize
        panel.Position = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y + 4)
        panel.Visible = true
        activeDropdown = panel
    end)

    local function SetOptions(newOpts)
        rebuildOptions(newOpts)
        panel.Size = UDim2.new(0, 220, 0, math.min(#newOpts * 28 + 36, 180))
    end

    local function SetSelected(val)
        if isMulti and type(val) == "table" then
            table.clear(selected)
            for _, v in ipairs(val) do
                selected[v] = true
            end
        elseif not isMulti and type(val) == "string" then
            selected = val
        end
        dropBtn.Text = displayText()
    end

    return row, nil, SetOptions, SetSelected
end

S.UserInputService.InputBegan:Connect(function(input)
    if not activeDropdown or not activeDropdown.Visible then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
    and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local p   = input.Position
    local pos = activeDropdown.AbsolutePosition
    local size = activeDropdown.AbsoluteSize
    if p.X >= pos.X and p.X <= pos.X + size.X
    and p.Y >= pos.Y and p.Y <= pos.Y + size.Y then return end
    activeDropdown.Visible = false
    activeDropdown = nil
end)

-- ── WINDOW ────────────────────────────────────────────────────
local Root = Instance.new("Frame", MainSG)
Root.Size = UDim2.new(0, 390, 0, 300)
Root.Position = UDim2.new(0.5, -195, 0.5, -150)
Root.BackgroundTransparency = 1

local Win = Instance.new("Frame", Root)
Win.Size = UDim2.new(1, 0, 1, 0)
Win.BackgroundColor3 = C.BASE
Win.ClipsDescendants = true
Corner(Win, 8)
Stroke(Win, C.BORDER, 1)

local Header = Instance.new("Frame", Win)
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = C.SURFACE
Corner(Header, 8)

local HFix = Instance.new("Frame", Header)
HFix.Size = UDim2.new(1, 0, 0, 8)
HFix.Position = UDim2.new(0, 0, 1, -8)
HFix.BackgroundColor3 = C.SURFACE
HFix.BorderSizePixel = 0

local AccentLine = Instance.new("Frame", Header)
AccentLine.Size = UDim2.new(0, 40, 0, 3)
AccentLine.Position = UDim2.new(0, 16, 0, 0)
AccentLine.BackgroundColor3 = C.ACCENT
AccentLine.BorderSizePixel = 0
Corner(AccentLine, 2)

local TitleLbl = Instance.new("TextLabel", Header)
TitleLbl.Size = UDim2.new(1, -80, 1, 0)
TitleLbl.Position = UDim2.new(0, 16, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.RichText = true
TitleLbl.Text = "ASTRO  <font color='#8D5DD1'>DUPE</font>"
TitleLbl.TextColor3 = C.TEXT_1
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = 14
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
MakeDraggable(Root, Header)

local minimized = false
local normalSize = UDim2.new(0, 390, 0, 300)
local miniSize   = UDim2.new(0, 390, 0, 45)

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -34, 0.5, -12)
MinBtn.BackgroundColor3 = C.SURFACE
MinBtn.BorderSizePixel = 0
MinBtn.Text = "—"
MinBtn.TextColor3 = C.TEXT_2
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.AutoButtonColor = false
Corner(MinBtn, 4)
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    MinBtn.Text = minimized and "□" or "—"
    S.TweenService:Create(Root, TweenInfo.new(0.2), {
        Size = minimized and miniSize or normalSize
    }):Play()
end)

local Content = Instance.new("ScrollingFrame", Win)
Content.Size = UDim2.new(1, 0, 1, -45)
Content.Position = UDim2.new(0, 0, 0, 45)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = C.DIVIDER

local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

local Pad = Instance.new("UIPadding", Content)
Pad.PaddingTop = UDim.new(0, 15)
Pad.PaddingBottom = UDim.new(0, 15)
Pad.PaddingLeft = UDim.new(0, 15)
Pad.PaddingRight = UDim.new(0, 15)

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 30)
end)

-- ── CONFIG ────────────────────────────────────────────────────
local CONFIG_FILE = "Astro_Dupe.json"
local savedConfig = {}
if writefile and readfile and isfile and isfile(CONFIG_FILE) then
    pcall(function()
        savedConfig = S.HttpService:JSONDecode(readfile(CONFIG_FILE))
    end)
end

local function saveMyConfig(data)
    if writefile then
        pcall(function()
            writefile(CONFIG_FILE, S.HttpService:JSONEncode(data))
        end)
    end
end

local selectedCrystals       = savedConfig.selectedCrystals       or {}
local selectedRunes          = savedConfig.selectedRunes          or {}
local selectedRarities       = savedConfig.selectedRarities       or {}
local selectedRunesToCollect = savedConfig.selectedRunesToCollect or {}
local crystalOptions         = {}
local runeOptions            = {}
local collectRuneOptions     = {}

local kickDropMethod        = savedConfig.kickDropMethod    or "Drop Only"
local isAutoDropOnKick      = savedConfig.isAutoDropOnKick  or false
local isAutoCollect         = savedConfig.isAutoCollect     or false
local isAutoRejoin          = savedConfig.isAutoRejoin      or false
local rejoinDelay           = savedConfig.rejoinDelay       or 5
local rejoinMethod          = savedConfig.rejoinMethod      or "Current Server"
local privateServerLink     = savedConfig.privateServerLink or ""
local collectRadius         = savedConfig.collectRadius     or 100
local crystalDropAmount     = savedConfig.crystalDropAmount or nil
local runeDropAmount        = savedConfig.runeDropAmount    or nil

local function updateConfig()
    saveMyConfig({
        selectedCrystals       = selectedCrystals,
        selectedRunes          = selectedRunes,
        selectedRarities       = selectedRarities,
        selectedRunesToCollect = selectedRunesToCollect,
        kickDropMethod         = kickDropMethod,
        isAutoDropOnKick       = isAutoDropOnKick,
        isAutoCollect          = isAutoCollect,
        isAutoRejoin           = isAutoRejoin,
        rejoinDelay            = rejoinDelay,
        rejoinMethod           = rejoinMethod,
        privateServerLink      = privateServerLink,
        collectRadius          = collectRadius,
        crystalDropAmount      = crystalDropAmount,
        runeDropAmount         = runeDropAmount,
    })
end

local rarityList = {
    "Common", "Uncommon", "Rare", "Epic", "Legendary",
    "Mythic", "Empyrean", "Pulsar", "Quasar"
}

-- ── INVENTORY SCANNING ──────────────────────────────────────
local function isCrystalTool(child)
    if not child:IsA("Tool") then return false end
    return child:GetAttribute("CrystalName") ~= nil
        or child:GetAttribute("Tier") ~= nil
        or child.Name:find("Crystal") ~= nil
end

local function isRuneTool(child)
    if not child:IsA("Tool") then return false end
    return child:GetAttribute("RuneId") ~= nil
        or child:GetAttribute("RuneName") ~= nil
        or child:GetAttribute("IsRune") == true
        or child.Name:find("Rune", 1, true) ~= nil
end

local crystalSetOpts, runeSetOpts, runeCollectSetOpts
local getCrystalDropAmount, getRuneDropAmount
local resetCrystalDropAmount, resetRuneDropAmount

local function scanInventory()
    table.clear(crystalOptions)
    table.clear(runeOptions)
    table.clear(collectRuneOptions)

    local crystalMap, runeMap = {}, {}

    local function checkItem(child)
        if isRuneTool(child) then
            if not runeMap[child.Name] then
                runeMap[child.Name] = true
                table.insert(runeOptions, child.Name)
                table.insert(collectRuneOptions, child.Name)
            end
        elseif isCrystalTool(child) then
            if not crystalMap[child.Name] then
                crystalMap[child.Name] = true
                table.insert(crystalOptions, child.Name)
            end
        end
    end

    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if bp then
        for _, c in ipairs(bp:GetChildren()) do
            checkItem(c)
        end
    end

    local char = LocalPlayer.Character
    if char then
        for _, c in ipairs(char:GetChildren()) do
            checkItem(c)
        end
    end

    table.sort(crystalOptions)
    table.sort(runeOptions)
    table.sort(collectRuneOptions)
end
scanInventory()

-- ── REMOTES ──────────────────────────────────────────────────
local dropRemoteCache = nil
local function getDropRemote()
    if dropRemoteCache and dropRemoteCache.Parent then return dropRemoteCache end
    local r = S.ReplicatedStorage:FindFirstChild("Remotes")
    dropRemoteCache = r and r:FindFirstChild("CrystalDropRequest")
    return dropRemoteCache
end

-- ── CACHE ────────────────────────────────────────────────────
local runeDropCache     = {}
local crystalDropCache  = {}
local labelRuneCache    = nil
local labelCrystalCache = nil

local function readCountFromAttr(tool)
    local attrNames = {
        "Amount", "Count", "UsesLeft", "Stack",
        "Quantity", "StackSize", "Uses", "Charges", "Stacks"
    }
    for _, attr in ipairs(attrNames) do
        local val = tool:GetAttribute(attr)
        if type(val) == "number" and val > 0 then
            return math.floor(val)
        end
    end
    return nil
end

local function readCountFromUI()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return nil end

    local function searchLabels(parent, depth)
        if depth > 6 then return nil end
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("TextLabel") then
                local lname = child.Name:lower()
                if lname:find("uses") or lname:find("count")
                or lname:find("amount") or lname:find("stack") then
                    local num = tonumber(child.Text)
                    if num and num > 0 then
                        return math.floor(num)
                    end
                end
            end
            local found = searchLabels(child, depth + 1)
            if found then return found end
        end
        return nil
    end
    return searchLabels(playerGui, 0)
end

local function formatItemLog(cache, dropAmount, itemType)
    if not next(cache) then
        return itemType .. ": tidak ada di inv"
    end
    local parts = {}
    local totalRaw = 0
    for name, count in pairs(cache) do
        totalRaw = totalRaw + count
        local willDrop = dropAmount and math.min(count, dropAmount) or count
        local suffix = (dropAmount and dropAmount < count)
            and " (drop " .. tostring(willDrop) .. ")" or ""
        parts[#parts + 1] = name .. " ×" .. count .. suffix
    end
    table.sort(parts)
    local limitInfo = dropAmount
        and "  │  Limit: " .. tostring(dropAmount) .. "/item"
        or  "  │  Drop: All"
    return itemType .. " total " .. totalRaw .. limitInfo
        .. "\n" .. table.concat(parts, "  │  ")
end

local function updateCrystalCacheLabel()
    if not labelCrystalCache then return end
    if #selectedCrystals == 0 then
        labelCrystalCache.Text = "Crystal: pilih dulu di dropdown ↑"
        return
    end
    if not next(crystalDropCache) then
        labelCrystalCache.Text = "Crystal: klik Scan Ulang untuk hitung"
        return
    end
    local amt = getCrystalDropAmount and getCrystalDropAmount() or crystalDropAmount
    labelCrystalCache.Text = formatItemLog(crystalDropCache, amt, "Crystal")
end

local function updateRuneCacheLabel()
    if not labelRuneCache then return end
    if #selectedRunes == 0 then
        labelRuneCache.Text = "Rune: pilih dulu di dropdown ↑"
        return
    end
    if not next(runeDropCache) then
        labelRuneCache.Text = "Rune: klik Scan Ulang untuk hitung"
        return
    end
    local amt = getRuneDropAmount and getRuneDropAmount() or runeDropAmount
    labelRuneCache.Text = formatItemLog(runeDropCache, amt, "Rune")
end

local function buildCrystalCache()
    table.clear(crystalDropCache)
    if #selectedCrystals == 0 then
        updateCrystalCacheLabel()
        return
    end
    local targetSet = {}
    for _, name in ipairs(selectedCrystals) do
        targetSet[name] = true
    end

    local function countFrom(container)
        if not container then return end
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Tool") and isCrystalTool(child) and targetSet[child.Name] then
                crystalDropCache[child.Name] = (crystalDropCache[child.Name] or 0) + 1
            end
        end
    end

    countFrom(LocalPlayer:FindFirstChildOfClass("Backpack"))
    countFrom(LocalPlayer.Character)
    updateCrystalCacheLabel()
end

local scanRuneLock = false
local lastRuneScanTime = 0
local RUNE_SCAN_COOLDOWN = 3

local function buildRuneCache()
    local now = os.clock()
    if scanRuneLock or (now - lastRuneScanTime) < RUNE_SCAN_COOLDOWN then
        return
    end
    scanRuneLock = true
    table.clear(runeDropCache)

    if #selectedRunes == 0 then
        updateRuneCacheLabel()
        lastRuneScanTime = os.clock()
        scanRuneLock = false
        return
    end

    if labelRuneCache then
        labelRuneCache.Text = "Rune: scanning..."
    end

    task.spawn(function()
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local bp   = LocalPlayer:FindFirstChildOfClass("Backpack")

        local targetSet = {}
        for _, name in ipairs(selectedRunes) do
            targetSet[name] = true
        end

        local toolsToScan = {}
        local function collectFrom(container)
            if not container then return end
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("Tool") and isRuneTool(child)
                and targetSet[child.Name]
                and not toolsToScan[child.Name] then
                    toolsToScan[child.Name] = child
                end
            end
        end

        collectFrom(bp)
        collectFrom(char)

        for runeName, runeTool in pairs(toolsToScan) do
            local count = readCountFromAttr(runeTool)
            if count then
                runeDropCache[runeName] = count
            elseif hum then
                pcall(function() hum:EquipTool(runeTool) end)
                task.wait(0.15)
                local uiCount = readCountFromUI()
                runeDropCache[runeName] = uiCount or 1
                pcall(function() hum:UnequipTools() end)
                task.wait(0.05)
            else
                runeDropCache[runeName] = 1
            end
        end

        updateRuneCacheLabel()
        lastRuneScanTime = os.clock()
        scanRuneLock = false
    end)
end

local function buildAllCache()
    buildCrystalCache()
    buildRuneCache()
end

task.spawn(function()
    local knownRunes = {}

    local function hookBackpack(bp)
        if not bp then return end
        bp.ChildAdded:Connect(function(child)
            task.wait(0.1)
            if isCrystalTool(child) then
                buildCrystalCache()
            elseif isRuneTool(child) then
                local inSel = false
                for _, name in ipairs(selectedRunes) do
                    if name == child.Name then
                        inSel = true
                        break
                    end
                end
                if inSel and not knownRunes[child.Name] then
                    knownRunes[child.Name] = true
                    buildRuneCache()
                end
            end
        end)
        bp.ChildRemoved:Connect(function(child)
            if isCrystalTool(child) then
                buildCrystalCache()
            end
            if isRuneTool(child) then
                knownRunes[child.Name] = nil
            end
        end)
    end

    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if bp then
        for _, child in ipairs(bp:GetChildren()) do
            if isRuneTool(child) then
                knownRunes[child.Name] = true
            end
        end
        hookBackpack(bp)
    end

    LocalPlayer.ChildAdded:Connect(function(child)
        if child:IsA("Backpack") then
            table.clear(knownRunes)
            hookBackpack(child)
        end
    end)
end)

-- ── EXECUTE DROP ─────────────────────────────────────────────
local function executeDropItems()
    local remote = getDropRemote()
    if not remote then return end

    local hasCrystal = next(crystalDropCache) ~= nil
    local hasRune    = next(runeDropCache) ~= nil
    if not hasCrystal and not hasRune then return end

    local cAmt = getCrystalDropAmount and getCrystalDropAmount() or crystalDropAmount
    local rAmt = getRuneDropAmount    and getRuneDropAmount()    or runeDropAmount

    if hasCrystal then
        task.spawn(function()
            for crystalName, count in pairs(crystalDropCache) do
                local willDrop = cAmt and math.min(count, cAmt) or count
                for i = 1, willDrop do
                    pcall(function()
                        remote:FireServer(crystalName)
                    end)
                end
            end
        end)
    end

    if hasRune then
        task.spawn(function()
            for runeName, count in pairs(runeDropCache) do
                local willDrop = rAmt and math.min(count, rAmt) or count
                for i = 1, willDrop do
                    pcall(function()
                        remote:FireServer(runeName)
                    end)
                end
            end
        end)
    end
end

-- ── COLLECT ──────────────────────────────────────────────────
local holdRemote = nil
local function getHoldRemote()
    if holdRemote and holdRemote.Parent then return holdRemote end
    local r = S.ReplicatedStorage:FindFirstChild("Remotes")
    holdRemote = r and r:FindFirstChild("CrystalHoldComplete")
    return holdRemote
end

local function fireCrystalPickup(part)
    local hold = getHoldRemote()
    if hold then
        pcall(function() hold:FireServer(part) end)
    end

    local prompt = part:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        pcall(function()
            prompt.HoldDuration = 0
            prompt.RequiresLineOfSight = false
            prompt.Enabled = true
            prompt.MaxActivationDistance = 9999
        end)
        if typeof(fireproximityprompt) == "function" then
            pcall(function() fireproximityprompt(prompt, 1) end)
            pcall(function() fireproximityprompt(prompt, 0) end)
        end
        pcall(function()
            prompt:InputHoldBegin()
            prompt:InputHoldEnd()
        end)
    end

    local det = part:FindFirstChildWhichIsA("ClickDetector", true)
    if det and typeof(fireclickdetector) == "function" then
        pcall(function() fireclickdetector(det, 0) end)
    end
end

local function fireRunePickup(obj)
    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
        or (obj:IsA("BasePart") and obj:FindFirstChildOfClass("ProximityPrompt"))
    if prompt then
        pcall(function()
            prompt.HoldDuration = 0
            prompt.RequiresLineOfSight = false
            prompt.Enabled = true
            prompt.MaxActivationDistance = 9999
        end)
        if typeof(fireproximityprompt) == "function" then
            pcall(function() fireproximityprompt(prompt, 1) end)
            pcall(function() fireproximityprompt(prompt, 0) end)
        end
        pcall(function()
            prompt:InputHoldBegin()
            prompt:InputHoldEnd()
        end)
    end

    local hold = getHoldRemote()
    if hold then
        if obj:IsA("BasePart") then
            pcall(function() hold:FireServer(obj) end)
        else
            local part = obj:FindFirstChildWhichIsA("BasePart", true)
            if part then
                pcall(function() hold:FireServer(part) end)
            end
        end
    end
end

local function getCrystalRarity(child)
    local tierName = child:GetAttribute("TierName")
    if type(tierName) == "string" and tierName ~= "" then
        return tierName
    end
    local tier = tonumber(child:GetAttribute("Tier")) or 0
    return rarityList[tier] or "Unknown"
end

local function rarityAllowed(child)
    if #selectedRarities == 0 then return true end
    local r = getCrystalRarity(child)
    for _, sel in ipairs(selectedRarities) do
        if sel == r then return true end
    end
    return false
end

local function isRuneInWorld(obj)
    if obj:GetAttribute("RuneId")   ~= nil then return true end
    if obj:GetAttribute("IsRune")   == true then return true end
    if obj:GetAttribute("RuneName") ~= nil then return true end
    if obj.Name:find(" Rune", 1, true) ~= nil then return true end
    return false
end

local function runeNameAllowed(obj)
    if #selectedRunesToCollect == 0 then return true end
    for _, name in ipairs(selectedRunesToCollect) do
        if obj.Name == name then return true end
    end
    return false
end

task.spawn(function()
    while task.wait(0.25) do
        if not isAutoCollect then goto continue end

        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then goto continue end

        local WS = game:GetService("Workspace")
        local containers = {WS}

        local dropped = WS:FindFirstChild("DroppedCrystals") or WS:FindFirstChild("Crystals")
        if dropped then table.insert(containers, dropped) end

        local things = WS:FindFirstChild("Things")
        if things then
            local dc = things:FindFirstChild("DroppedCrystals") or things:FindFirstChild("Crystals")
            if dc then table.insert(containers, dc) end
        end

        for _, container in ipairs(containers) do
            for _, child in ipairs(container:GetChildren()) do
                if not isAutoCollect then break end
                if not child:IsA("BasePart") then continue end

                local isValid = child:GetAttribute("Value") ~= nil
                    and (child:GetAttribute("CrystalName") ~= nil or child:GetAttribute("Tier") ~= nil)
                if not isValid then continue end
                if child:GetAttribute("Collected") == true then continue end
                if not rarityAllowed(child) then continue end

                local dist = (child.Position - root.Position).Magnitude
                if dist > collectRadius then continue end

                root.CFrame = CFrame.new(child.Position + Vector3.new(0, 3, 0))
                task.wait(0.05)
                fireCrystalPickup(child)
                task.wait(0.1)
            end
        end

        if not isAutoCollect then goto continue end

        local runeContainers = {}
        local droppedRunes = WS:FindFirstChild("DroppedRunes")
        if droppedRunes then table.insert(runeContainers, droppedRunes) end

        if things then
            local dr = things:FindFirstChild("DroppedRunes")
            if dr then table.insert(runeContainers, dr) end
        end

        if #runeContainers == 0 then
            table.insert(runeContainers, WS)
        end

        for _, container in ipairs(runeContainers) do
            for _, obj in ipairs(container:GetChildren()) do
                if not isAutoCollect then break end
                if not isRuneInWorld(obj) then continue end
                if not runeNameAllowed(obj) then continue end

                local pos = nil
                if obj:IsA("BasePart") then
                    pos = obj.Position
                elseif obj:IsA("Model") then
                    local pp = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                    if pp then pos = pp.Position end
                end
                if not pos then continue end

                local dist = (pos - root.Position).Magnitude
                if dist > collectRadius then continue end

                root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                task.wait(0.05)
                fireRunePickup(obj)
                task.wait(0.1)
            end
        end

        ::continue::
    end
end)

-- ── BUILD UI ──────────────────────────────────────────────────
BuatSection(Content, "Drop Selection")

local _,_,cSetOpts,_ = BuatDropdown(
    Content,
    "Crystals to Drop",
    crystalOptions,
    true,
    selectedCrystals,
    function(sel)
        selectedCrystals = sel
        updateConfig()
        task.spawn(function()
            task.wait(0.1)
            buildCrystalCache()
        end)
    end
)
crystalSetOpts = cSetOpts

local _crystalAmountRow, _getCrystalAmt, _resetCrystalAmt = BuatDropAmount(
    Content,
    "Crystal Drop Amt",
    savedConfig.crystalDropAmount or nil,
    function(amt)
        crystalDropAmount = amt
        updateConfig()
        updateCrystalCacheLabel()
    end
)
getCrystalDropAmount   = _getCrystalAmt
resetCrystalDropAmount = _resetCrystalAmt

labelCrystalCache = BuatLabel(Content, "Crystal: belum di-scan")
labelCrystalCache.TextColor3 = C.TEXT_3
labelCrystalCache.TextSize = 10

local _,_,rSetOpts,_ = BuatDropdown(
    Content,
    "Runes to Drop",
    runeOptions,
    true,
    selectedRunes,
    function(sel)
        selectedRunes = sel
        updateConfig()
        lastRuneScanTime = 0
        task.spawn(function()
            task.wait(0.1)
            buildRuneCache()
        end)
    end
)
runeSetOpts = rSetOpts

local _runeAmountRow, _getRuneAmt, _resetRuneAmt = BuatDropAmount(
    Content,
    "Rune Drop Amt",
    savedConfig.runeDropAmount or nil,
    function(amt)
        runeDropAmount = amt
        updateConfig()
        updateRuneCacheLabel()
    end
)
getRuneDropAmount   = _getRuneAmt
resetRuneDropAmount = _resetRuneAmt

labelRuneCache = BuatLabel(Content, "Rune: belum di-scan")
labelRuneCache.TextColor3 = C.TEXT_3
labelRuneCache.TextSize = 10

local ScanBtn = BuatButton(Content, "⟳ Scan Ulang Count (Crystal + Rune)")
ScanBtn.MouseButton1Click:Connect(function()
    lastRuneScanTime = 0
    buildAllCache()
    Notify("Scanning cache...", 2)
end)

local RefreshBtn = BuatButton(Content, "↻ Refresh Inventory")
RefreshBtn.MouseButton1Click:Connect(function()
    scanInventory()
    if crystalSetOpts     then crystalSetOpts(crystalOptions) end
    if runeSetOpts        then runeSetOpts(runeOptions) end
    if runeCollectSetOpts then runeCollectSetOpts(collectRuneOptions) end
    lastRuneScanTime = 0
    task.spawn(function()
        task.wait(0.2)
        buildAllCache()
    end)
    Notify("Inventory di-refresh", 2)
end)

local ResetAmtBtn = BuatButton(Content, "↺ Reset Drop Amount → All")
ResetAmtBtn.MouseButton1Click:Connect(function()
    if resetCrystalDropAmount then resetCrystalDropAmount() end
    if resetRuneDropAmount    then resetRuneDropAmount() end
    crystalDropAmount = nil
    runeDropAmount = nil
    updateConfig()
    updateCrystalCacheLabel()
    updateRuneCacheLabel()
    Notify("Drop Amount di-reset → All", 2)
end)

-- Auto Collect
BuatSection(Content, "Auto Collect (Map Scanner)")

BuatDropdown(
    Content,
    "Rarity to Collect",
    rarityList,
    true,
    selectedRarities,
    function(sel)
        selectedRarities = sel
        updateConfig()
    end
)

local _,_,rcSetOpts,_ = BuatDropdown(
    Content,
    "Runes to Collect",
    collectRuneOptions,
    true,
    selectedRunesToCollect,
    function(sel)
        selectedRunesToCollect = sel
        updateConfig()
    end
)
runeCollectSetOpts = rcSetOpts

BuatSlider(
    Content,
    "Collect Radius",
    10,
    5000,
    collectRadius,
    function(v)
        collectRadius = math.floor(v)
        updateConfig()
    end
)

local CollectBtn, CollectSet = BuatToggle(
    Content,
    "Auto Collect Selected",
    isAutoCollect
)
CollectBtn.MouseButton1Click:Connect(function()
    isAutoCollect = not isAutoCollect
    CollectSet(isAutoCollect)
    updateConfig()
end)

-- Auto Drop
BuatSection(Content, "Auto Drop")

local _,_,_kickMethodSetOpts,_ = BuatDropdown(
    Content,
    "Drop Kick Method",
    {"Drop Only", "Reset Then Drop"},
    false,
    kickDropMethod,
    function(sel)
        kickDropMethod = sel
        updateConfig()
        Notify("Drop method: " .. sel, 2)
    end
)

local DropToggleBtn, DropSet = BuatToggle(
    Content,
    "Auto Drop On Kick",
    isAutoDropOnKick
)
DropToggleBtn.MouseButton1Click:Connect(function()
    isAutoDropOnKick = not isAutoDropOnKick
    DropSet(isAutoDropOnKick)
    updateConfig()
end)

-- Rejoin Settings
BuatSection(Content, "Rejoin Settings")

BuatInput(
    Content,
    "Rejoin Delay [s]",
    "Contoh: 5",
    tostring(rejoinDelay),
    function(val)
        local num = tonumber(val)
        if num then
            rejoinDelay = num
            updateConfig()
            Notify("Delay: " .. val .. "s", 2)
        end
    end
)

local _,_,methodSetOpts,_ = BuatDropdown(
    Content,
    "Rejoin Method",
    {"Current Server", "Private Server Link", "Random Server"},
    false,
    rejoinMethod,
    function(sel)
        rejoinMethod = sel
        updateConfig()
    end
)

BuatInput(
    Content,
    "Link Private Server",
    "Paste full URL VIP",
    privateServerLink,
    function(val)
        privateServerLink = val
        updateConfig()
        Notify("Link di-update", 2)
    end
)

local RejoinBtn, RejoinSet = BuatToggle(
    Content,
    "Auto Rejoin",
    isAutoRejoin
)
RejoinBtn.MouseButton1Click:Connect(function()
    isAutoRejoin = not isAutoRejoin
    RejoinSet(isAutoRejoin)
    updateConfig()
end)

-- ── KICK DETECTION + UNIFIED TRIGGER ────────────────────────
local connectionTriggered = false
local coreGui = S.CoreGui

local function handleRejoin()
    if not isAutoRejoin then return end
    task.spawn(function()
        task.wait(rejoinDelay)
        local TS      = S.TeleportService
        local placeId = game.PlaceId

        while task.wait(3) do
            if rejoinMethod == "Current Server" then
                pcall(function()
                    TS:TeleportToPlaceInstance(placeId, game.JobId, LocalPlayer)
                end)
            elseif rejoinMethod == "Random Server" then
                pcall(function()
                    TS:Teleport(placeId, LocalPlayer)
                end)
            elseif rejoinMethod == "Private Server Link" then
                if privateServerLink ~= "" then
                    local code = privateServerLink:match("privateServerLinkCode=([^&]+)")
                    if code then
                        pcall(function()
                            TS:TeleportToPrivateServer(placeId, code, {LocalPlayer})
                        end)
                    else
                        pcall(function()
                            TS:TeleportToPrivateServer(placeId, privateServerLink, {LocalPlayer})
                        end)
                    end
                end
            end
        end
    end)
end

local function triggerDropAndRejoin()
    if connectionTriggered then return end
    connectionTriggered = true

    if isAutoDropOnKick then
        if kickDropMethod == "Reset Then Drop" then
            executeDropItems()
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function() hum.Health = 0 end)
            end
        else
            executeDropItems()
        end
    end

    handleRejoin()
end

-- Listener 1: GuiService ErrorMessage
S.GuiService.ErrorMessageChanged:Connect(function()
    local ok, msg = pcall(function()
        return S.GuiService:GetErrorMessage()
    end)
    if not ok or type(msg) ~= "string" or msg == "" then return end

    msg = msg:lower()
    if msg:find("same account") or msg:find("another device")
    or msg:find("profile session") or msg:find("please rejoin")
    or msg:find("error code: 267") or msg:find("(267)") then
        triggerDropAndRejoin()
    end
end)

-- Listener 2: CoreGui prompt / disconnect screen scan
task.spawn(function()
    while task.wait(0.05) do
        if connectionTriggered then break end
        pcall(function()
            local promptGui = coreGui:FindFirstChild("RobloxPromptGui")
            if promptGui then
                local overlay = promptGui:FindFirstChild("promptOverlay")
                if overlay then
                    for _, child in ipairs(overlay:GetChildren()) do
                        if child.Name:find("ErrorPrompt") then
                            for _, label in ipairs(child:GetDescendants()) do
                                if label:IsA("TextLabel") then
                                    local text = label.Text:lower()
                                    if text:find("profile session") or text:find("please rejoin")
                                    or text:find("267") or text:find("same account")
                                    or text:find("another device") then
                                        triggerDropAndRejoin()
                                        return
                                    end
                                end
                            end
                        end
                    end
                end
            end

            for _, child in ipairs(coreGui:GetChildren()) do
                if child:IsA("ScreenGui") and child.Enabled then
                    local lname = child.Name:lower()
                    if lname:find("disconnect") or lname:find("error") then
                        for _, label in ipairs(child:GetDescendants()) do
                            if label:IsA("TextLabel") then
                                local text = label.Text:lower()
                                if text:find("profile session") or text:find("please rejoin")
                                or text:find("267") or text:find("same account")
                                or text:find("another device") then
                                    triggerDropAndRejoin()
                                    return
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- ── MISC ──────────────────────────────────────────────────────
BuatSection(Content, "Misc")

local ManualBtn = BuatButton(Content, "🗑 Manual Drop Selected")
ManualBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        executeDropItems()
        Notify("Manual drop selesai", 2)
    end)
end)

local ResetCharBtn = BuatButton(Content, "⟳ Reset Character")
ResetCharBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum.Health = 0 end)
    end
end)

-- Auto scan on load
task.spawn(function()
    task.wait(1.5)
    buildAllCache()
    Notify("Cache siap!", 2)
end)