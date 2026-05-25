-- ══════════════════════════════════════════════
--   EXAMPLE SCRIPT - Kick a Lucky Block GUI
--   Panggil UILibrary dari GitHub Raw
-- ══════════════════════════════════════════════

local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/USERNAME/REPO/main/UILibrary.lua"
))()

-- ── Buat Window ──────────────────────────────
local Window = UI:CreateWindow({
    Title       = "ChiyoLib",
    Game        = "Kick a Lucky Block",
    Discord     = "discord.gg/chiyo",
    Version     = "v2.1",
    MinimizeKey = Enum.KeyCode.RightShift, -- tekan RShift untuk minimize
})

-- ══════════════════════════════════════════════
--  TAB 1: Main
-- ══════════════════════════════════════════════
local MainTab = Window:AddTab({ Name = "Main", Icon = "⚔️" })

-- ── Farming Section (kiri) ───────────────────
local FarmSection = MainTab:AddSection({ Name = "Farming", Side = "left" })

local AutoFarmToggle = FarmSection:AddToggle({
    Name     = "Auto Farm",
    Default  = false,
    Callback = function(v)
        print("Auto Farm:", v)
        -- taruh logika auto farm kamu di sini
    end,
})

local WalkSpeedSlider = FarmSection:AddSlider({
    Name     = "Walk Speed",
    Min      = 1,
    Max      = 200,
    Default  = 45,
    Suffix   = "",
    Callback = function(v)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    end,
})

local KickPowerSlider = FarmSection:AddSlider({
    Name     = "Kick Power",
    Min      = 1,
    Max      = 100,
    Default  = 100,
    Suffix   = "%",
    Callback = function(v)
        print("Kick Power:", v)
    end,
})

FarmSection:AddToggle({
    Name     = "Auto Adjust Power",
    Default  = true,
    Callback = function(v)
        print("Auto Adjust:", v)
    end,
})

FarmSection:AddDivider("TARGET FILTER")

FarmSection:AddSlider({
    Name     = "Minimum CPS",
    Min      = 0,
    Max      = 100,
    Default  = 0,
    Callback = function(v) print("Min CPS:", v) end,
})

local FarmModeDD = FarmSection:AddDropdown({
    Name     = "Farm Skip Mode",
    Options  = { "Remote", "Local", "Disabled" },
    Default  = "Remote",
    Callback = function(v) print("Farm Mode:", v) end,
})

FarmSection:AddDropdown({
    Name     = "Target Brainrot",
    Options  = { "---", "Brainrot A", "Brainrot B", "Brainrot C" },
    Default  = "---",
    Callback = function(v) print("Target:", v) end,
})

FarmSection:AddDropdown({
    Name     = "Target Rarity",
    Options  = { "---", "Common", "Rare", "Epic", "Legendary" },
    Default  = "---",
    Callback = function(v) print("Rarity:", v) end,
})

-- ── Selling Section (kanan) ──────────────────
local SellSection = MainTab:AddSection({ Name = "Selling", Side = "right" })

SellSection:AddDropdown({
    Name     = "Method",
    Options  = { "All", "Selected", "None" },
    Default  = "All",
    Callback = function(v) print("Sell Method:", v) end,
})

SellSection:AddSlider({
    Name     = "Sell Interval",
    Min      = 1,
    Max      = 30,
    Default  = 2,
    Suffix   = "s",
    Callback = function(v) print("Interval:", v) end,
})

SellSection:AddButton({
    Name     = "Sell Now",
    Callback = function()
        print("Selling...")
        -- logika sell di sini
    end,
})

SellSection:AddToggle({
    Name     = "Auto Sell",
    Default  = false,
    Callback = function(v) print("Auto Sell:", v) end,
})

SellSection:AddDivider("MISC")

SellSection:AddToggle({
    Name     = "Auto Rebirth",
    Default  = false,
    Callback = function(v) print("Auto Rebirth:", v) end,
})

SellSection:AddToggle({
    Name     = "Auto Open Lucky Blocks",
    Default  = false,
    Callback = function(v) print("Auto Blocks:", v) end,
})

SellSection:AddButton({
    Name     = "Tween to Save Zone",
    Callback = function()
        print("Tweening...")
    end,
})

SellSection:AddDivider("FAVORITES")

SellSection:AddToggle({
    Name     = "Auto Favorite",
    Default  = false,
    Callback = function(v) print("Auto Fav:", v) end,
})

SellSection:AddToggle({
    Name     = "Auto Unfavorite Non Matching",
    Default  = false,
    Callback = function(v) print("Auto Unfav:", v) end,
})

SellSection:AddButton({
    Name     = "Filter Setup",
    Callback = function() print("Filter Setup clicked") end,
})

-- ══════════════════════════════════════════════
--  TAB 2: Player
-- ══════════════════════════════════════════════
local PlayerTab = Window:AddTab({ Name = "Player", Icon = "👤" })

local PlayerSection = PlayerTab:AddSection({ Name = "Character", Side = "left" })

PlayerSection:AddSlider({
    Name     = "Walk Speed",
    Min      = 16,
    Max      = 500,
    Default  = 16,
    Callback = function(v)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    end,
})

PlayerSection:AddSlider({
    Name     = "Jump Power",
    Min      = 50,
    Max      = 500,
    Default  = 50,
    Callback = function(v)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
    end,
})

PlayerSection:AddToggle({
    Name     = "Noclip",
    Default  = false,
    Callback = function(v)
        -- noclip logic
        local noclip = v
        game:GetService("RunService").Stepped:Connect(function()
            if noclip then
                for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end,
})

-- ── Notif contoh ─────────────────────────────
task.delay(1, function()
    Window:Notify({
        Title    = "ChiyoLib Loaded!",
        Desc     = "Script berhasil di-load. Tekan RShift untuk minimize.",
        Duration = 4,
        Color    = Color3.fromRGB(80, 130, 240),
    })
end)
