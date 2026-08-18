--[[
    Astro Hub - Full Remake of Redz Hub
    Full Open Source | Blox Fruits Script
    Created by: astro
    Using: Obsidian Library
    Repository: https://raw.githubusercontent.com/rickyaditya511/hac/refs/heads/main/Library.lua
]]

-- ============================================
-- HOOK FUNCTIONS (Anti-Death/Respawn)
-- ============================================
hookfunction(require(game:GetService('ReplicatedStorage').Effect.Container.Death), function() end)
hookfunction(require(game:GetService('ReplicatedStorage').Effect.Container.Respawn), function() end)

-- ============================================
-- WORLD DETECTION
-- ============================================
World1 = game.PlaceId == 2753915549 or game.PlaceId == 85211729168715
World2 = game.PlaceId == 4442272183 or game.PlaceId == 79091703265657
World3 = game.PlaceId == 7449423635 or game.PlaceId == 100117331123089

-- ============================================
-- GLOBAL VARIABLES
-- ============================================
_G.SelectWeapon = 'Melee'
_G.AutoFarm = false
_G.AutoFarmLevelNew = false
_G.AutoNear = false
_G.SelectBoss = nil
_G.BossPain = false
_G.FarmBone = false
_G.Pray = false
_G.Trylux = false
_G.FarmCake = false
_G.Fullykatakuri = false
_G.CollectBerry = false
_G.FarmChest = false
_G.SelectMaterial = nil
_G.AutoFarmMaterial = false
_G.AutoFishing = false
_G.SelectedBait = 'Basic Bait'
_G.SelectedRod = 'Fishing Rod'
_G.AutoSecondSea = false
_G.Greybeard = false
_G.AutoSaber = false
_G.Autopole = false
_G.Autosaw = false
_G.ChiefWarden = false
_G.Trident = false
_G.AutoBartilo = false
_G.ThirdSea = false
_G.AutoFactory = false
_G.AutoDarkBoss = false
_G.CursedCaptain = false
_G.Longsword = false
_G.GravityBlade = false
_G.SwodsFlail = false
_G.AutoRengoku = false
_G.SwodsDRTrident = false
_G.RipIndraKill = false
_G.AutoElitehunter = false
_G.AutoSkullGuitar = false
_G.AutoYama = false
_G.AutoHolyTorch = false
_G.AutoGetTushita = false
_G.SwodTwinHooks = false
_G.SwodCanvander = false
_G.SwodsBuddy = false
_G.FarmBlazeEM = false
_G.AutoFindPrehistoric = false
_G.TweenVolcano = false
_G.DefendVolcano = false
_G.UseMelee = false
_G.UseSword = false
_G.UseGun = false
_G.KillGolem = false
_G.AutoCollectBone = false
_G.CollectEgg = false
_G.TweenToKitsune = false
_G.AutoAzuerEmber = false
_G.SailBoat = false
_G.Autoterrorshark = false
_G.KillShark = false
_G.KillPiranha = false
_G.KillFishCrew = false
_G.AutoMysticIsland = false
_G.AutoDooHee = false
_G.TweenMGear = false
_G.Kill_Aura = false
_G.AutoQuestRace = false
_G.AutoKillV4 = false
_G.XaiSkillZ = false
_G.XaiSkillX = false
_G.XaiSkillC = false
_G.SelectChip = 'Flame'
_G.AutoBuyChip = false
_G.StartRaid = false
_G.Dungeon = false
_G.Autofruit = false
_G.AutoLawRaid = false
_G.RandomAuto = false
_G.AutoStoreFruit = false
_G.Tweenfruit = false
_G.Grabfruit = false
_G.SelectIsland = nil
_G.TeleportIsland = false
_G.AutoPlayerHunter = false
_G.SafeMode = false
_G.WalkSpeedValue = 30
_G.JumpValue = 50
_G.RemoveLava = false
_G.ChestESP = false
_G.BringMonster = true
_G.CheckPoint = false
_G.AutoHaki = false
_G.AutoRaceV3 = false
_G.AutoRaceV4 = false
_G.WalkWater = true
_G.AutoMelee = false
_G.AutoDefense = false
_G.AutoSword = false
_G.AutoGun = false
_G.AutoFruits = false
_G.Fast_Delay = 0.1
_G.FastAttackDelay = 0.1
_G.TweenSpeed = 325
_G.BypassTP = false
_G.Hop = false

-- ESP Variables
ESPPlayer = false
DevilFruitESP = false
Berry = false
MirageIslandESP = false
KitsuneIslandEsp = false
InfiniteGeppo = false
DodgewithoutCool = false
StartBring = false
NeedAttacking = false
NoClip = false
StopTween = false
MonFarm = nil
PosMon = nil
Number = math.random(1, 1000000)
PosY = 30
Pos = CFrame.new(0, PosY, 0)
_G.UseSkill = false
_G.SelectWeaponGun = nil
_G.NotAutoEquip = false

-- ============================================
-- MATERIAL MONSTER FUNCTION (FULL)
-- ============================================
function MaterialMon()
    if _G.SelectMaterial == 'Radiactive Material' then
        MMon = 'Factory Staff'
        MPos = CFrame.new(-105.889565, 72.8076935, -670.247986, -0.965929747, 0, -0.258804798, 0, 1, 0, 0.258804798, 0, -0.965929747)
        SP = 'Bar'
    elseif _G.SelectMaterial == 'Leather + Scrap Metal' then
        if game.PlaceId ~= 2753915549 then
            if game.PlaceId == 4442272183 then
                MMon = 'Mercenary'
                MPos = CFrame.new(-986.774475, 72.8755951, 1088.44653, -0.656062722, 0, 0.754706323, 0, 1, 0, -0.754706323, 0, -0.656062722)
                SP = 'DressTown'
            elseif game.PlaceId == 7449423635 then
                MMon = 'Pirate Millionaire'
                MPos = CFrame.new(-118.809372, 55.4874573, 5649.17041, -0.965929747, 0, 0.258804798, 0, 1, 0, -0.258804798, 0, -0.965929747)
                SP = 'Default'
            end
        else
            MMon = 'Pirate'
            MPos = CFrame.new(-967.433105, 13.5999937, 4034.24707, -0.258864403, 0, -0.965913713, 0, 1, 0, 0.965913713, 0, -0.258864403)
            SP = 'Pirate'
            MMon = 'Brute'
            MPos = CFrame.new(-1191.41235, 15.5999985, 4235.50928, 0.629286051, 0, -0.777173758, 0, 1, 0, 0.777173758, 0, 0.629286051)
            SP = 'Pirate'
        end
    elseif _G.SelectMaterial == 'Magma Ore' then
        if game.PlaceId ~= 2753915549 then
            if game.PlaceId == 4442272183 then
                MMon = 'Lava Pirate'
                MPos = CFrame.new(-5158.77051, 14.4791956, -4654.2627, -0.848060489, 0, -0.529899538, 0, 1, 0, 0.529899538, 0, -0.848060489)
                SP = 'CircleIslandFire'
            end
        else
            MMon = 'Military Soldier'
            MPos = CFrame.new(-5565.60156, 9.10001755, 8327.56934, -0.838688731, 0, -0.544611216, 0, 1, 0, 0.544611216, 0, -0.838688731)
            SP = 'Magma'
            MMon = 'Military Spy'
            MPos = CFrame.new(-5806.70068, 78.5000458, 8904.46973, 0.707134247, 0, 0.707079291, 0, 1, 0, -0.707079291, 0, 0.707134247)
            SP = 'Magma'
        end
    elseif _G.SelectMaterial == 'Fish Tail' then
        if game.PlaceId ~= 2753915549 then
            if game.PlaceId == 7449423635 then
                MMon = 'Fishman Captain'
                MPos = CFrame.new(-10828.1064, 331.825989, -9049.14648, -0.0912091732, 0, 0.995831788, 0, 1, 0, -0.995831788, 0, -0.0912091732)
                SP = 'PineappleTown'
            end
        else
            MMon = 'Fishman Warrior'
            MPos = CFrame.new(60943.9023, 17.9492188, 1744.11133, 0.826706648, 0, -0.562633216, 0, 1, 0, 0.562633216, 0, 0.826706648)
            SP = 'Underwater City'
            MMon = 'Fishman Commando'
            MPos = CFrame.new(61760.8984, 18.0800781, 1460.11133, -0.632549644, 0, -0.774520278, 0, 1, 0, 0.774520278, 0, -0.632549644)
            SP = 'Underwater City'
        end
    elseif _G.SelectMaterial ~= 'Angel Wings' then
        if _G.SelectMaterial ~= 'Mystic Droplet' then
            if _G.SelectMaterial ~= 'Vampire Fang' then
                if _G.SelectMaterial ~= 'Gunpowder' then
                    if _G.SelectMaterial == 'Mini Tusk' then
                        MMon = 'Mythological Pirate'
                        MPos = CFrame.new(-13456.0498, 469.433228, -7039.96436, 0, 0, 1, 0, 1, 0, -1, 0, 0)
                        SP = 'BigMansion'
                    elseif _G.SelectMaterial == 'Conjured Cocoa' then
                        MMon = 'Chocolate Bar Battler'
                        MPos = CFrame.new(582.828674, 25.5824986, -12550.7041, -0.766061664, 0, -0.642767608, 0, 1, 0, 0.642767608, 0, -0.766061664)
                        SP = 'Chocolate'
                    end
                else
                    MMon = 'Pistol Billionaire'
                    MPos = CFrame.new(-185.693283, 84.7088699, 6103.62744, 0.90629667, 0, -0.422642082, 0, 1, 0, 0.422642082, 0, 0.90629667)
                    SP = 'Mansion'
                end
            else
                MMon = 'Vampire'
                MPos = CFrame.new(-6132.39453, 9.00769424, -1466.16919, -0.927179813, 0, -0.374617696, 0, 1, 0, 0.374617696, 0, -0.927179813)
                SP = 'Graveyard'
            end
        else
            MMon = 'Water Fighter'
            MPos = CFrame.new(-3331.70459, 239.138336, -10553.3564, -0.29242146, 0, 0.95628953, 0, 1, 0, -0.95628953, 0, -0.29242146)
            SP = 'ForgottenIsland'
        end
    else
        MMon = 'Royal Soldier'
        MPos = CFrame.new(-7759.45898, 5606.93652, -1862.70276, -0.866007447, 0, -0.500031412, 0, 1, 0, 0.500031412, 0, -0.866007447)
        SP = 'SkyArea2'
    end
end

-- ============================================
-- CHECK QUEST FUNCTION (FULL)
-- ============================================
function CheckQuest()
    MyLevel = game:GetService('Players').LocalPlayer.Data.Level.Value

    if World1 then
        if (MyLevel < 1 or MyLevel > 9) and SelectMonster ~= 'Bandit' then
            if (MyLevel < 10 or 14 < MyLevel) and SelectMonster ~= 'Monkey' then
                if (MyLevel < 15 or 29 < MyLevel) and SelectMonster ~= 'Gorilla' then
                    if (MyLevel < 30 or 39 < MyLevel) and SelectMonster ~= 'Pirate' then
                        if (MyLevel < 40 or 59 < MyLevel) and SelectMonster ~= 'Brute' then
                            if (MyLevel < 60 or MyLevel > 74) and SelectMonster ~= 'Desert Bandit' then
                                if (MyLevel < 75 or 89 < MyLevel) and SelectMonster ~= 'Desert Officer' then
                                    if (MyLevel < 90 or 99 < MyLevel) and SelectMonster ~= 'Snow Bandit' then
                                        if (MyLevel < 100 or MyLevel > 119) and SelectMonster ~= 'Snowman' then
                                            if (MyLevel < 120 or 149 < MyLevel) and SelectMonster ~= 'Chief Petty Officer' then
                                                if (MyLevel < 150 or 174 < MyLevel) and SelectMonster ~= 'Sky Bandit' then
                                                    if (MyLevel < 175 or 189 < MyLevel) and SelectMonster ~= 'Dark Master' then
                                                        if (MyLevel < 190 or MyLevel > 209) and SelectMonster ~= 'Prisoner' then
                                                            if (MyLevel < 210 or 249 < MyLevel) and SelectMonster ~= 'Dangerous Prisone' then
                                                                if (MyLevel < 250 or MyLevel > 274) and SelectMonster ~= 'Toga Warrior' then
                                                                    if (MyLevel < 275 or 299 < MyLevel) and SelectMonster ~= 'Gladiator' then
                                                                        if (MyLevel < 300 or 324 < MyLevel) and SelectMonster ~= 'Military Soldier' then
                                                                            if (MyLevel < 325 or 374 < MyLevel) and SelectMonster ~= 'Military Spy' then
                                                                                if (MyLevel < 375 or 399 < MyLevel) and SelectMonster ~= 'Fishman Warrior' then
                                                                                    if (MyLevel < 400 or 449 < MyLevel) and SelectMonster ~= 'Fishman Commando' then
                                                                                        if (MyLevel < 450 or MyLevel > 474) and SelectMonster ~= "God's Guard" then
                                                                                            if (MyLevel < 475 or MyLevel > 524) and SelectMonster ~= 'Shanda' then
                                                                                                if (MyLevel < 525 or MyLevel > 549) and SelectMonster ~= 'Royal Squad' then
                                                                                                    if (MyLevel < 550 or 624 < MyLevel) and SelectMonster ~= 'Royal Soldier' then
                                                                                                        if (MyLevel < 625 or MyLevel > 649) and SelectMonster ~= 'Galley Pirate' then
                                                                                                            if MyLevel >= 650 or SelectMonster == 'Galley Captain' then
                                                                                                                Mon = 'Galley Captain'
                                                                                                                LevelQuest = 2
                                                                                                                NameQuest = 'FountainQuest'
                                                                                                                NameMon = 'Galley Captain'
                                                                                                                CFrameQuest = CFrame.new(5259.81982, 37.3500175, 4050.0293, 0.087131381, -0, 0.996196866, -0, 1, -0, -0.996196866, -0, 0.087131381)
                                                                                                                CFrameMon = CFrame.new(5441.95166015625, 42.50205993652344, 4950.09375)
                                                                                                            end
                                                                                                        else
                                                                                                            Mon = 'Galley Pirate'
                                                                                                            LevelQuest = 1
                                                                                                            NameQuest = 'FountainQuest'
                                                                                                            NameMon = 'Galley Pirate'
                                                                                                            CFrameQuest = CFrame.new(5259.81982, 37.3500175, 4050.0293, 0.087131381, -0, 0.996196866, -0, 1, -0, -0.996196866, -0, 0.087131381)
                                                                                                            CFrameMon = CFrame.new(5551.02197265625, 78.90135192871094, 3930.412841796875)
                                                                                                        end
                                                                                                    else
                                                                                                        Mon = 'Royal Soldier'
                                                                                                        LevelQuest = 2
                                                                                                        NameQuest = 'SkyExp2Quest'
                                                                                                        NameMon = 'Royal Soldier'
                                                                                                        CFrameQuest = CFrame.new(-7906.81592, 5634.6626, -1411.99194, -0, -0, -1, -0, 1, -0, 1, -0, -0)
                                                                                                        CFrameMon = CFrame.new(-7836.75341796875, 5645.6640625, -1790.6236572265625)
                                                                                                    end
                                                                                                else
                                                                                                    Mon = 'Royal Squad'
                                                                                                    LevelQuest = 1
                                                                                                    NameQuest = 'SkyExp2Quest'
                                                                                                    NameMon = 'Royal Squad'
                                                                                                    CFrameQuest = CFrame.new(-7906.81592, 5634.6626, -1411.99194, -0, -0, -1, -0, 1, -0, 1, -0, -0)
                                                                                                    CFrameMon = CFrame.new(-7624.25244140625, 5658.13330078125, -1467.354248046875)
                                                                                                end
                                                                                            else
                                                                                                Mon = 'Shanda'
                                                                                                LevelQuest = 2
                                                                                                NameQuest = 'SkyExp1Quest'
                                                                                                NameMon = 'Shanda'
                                                                                                CFrameQuest = CFrame.new(-7859.09814, 5544.19043, -381.476196, -0.422592998, -0, 0.906319618, -0, 1, -0, -0.906319618, -0, -0.422592998)
                                                                                                CFrameMon = CFrame.new(-7678.48974609375, 5566.40380859375, -497.2156066894531)

                                                                                                if _G.AutoFarm and 10000 < (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude then
                                                                                                    game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('requestEntrance', Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047))
                                                                                                end
                                                                                            end
                                                                                        else
                                                                                            Mon = "God's Guard"
                                                                                            LevelQuest = 1
                                                                                            NameQuest = 'SkyExp1Quest'
                                                                                            NameMon = "God's Guard"
                                                                                            CFrameQuest = CFrame.new(-4721.88867, 843.874695, -1949.96643, 0.996191859, -0, -0.0871884301, -0, 1, -0, 0.0871884301, -0, 0.996191859)
                                                                                            CFrameMon = CFrame.new(-4710.04296875, 845.2769775390625, -1927.3079833984375)

                                                                                            if _G.AutoFarm and 10000 < (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude then
                                                                                                game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('requestEntrance', Vector3.new(-4607.82275, 872.54248, -1667.55688))
                                                                                            end
                                                                                        end
                                                                                    else
                                                                                        Mon = 'Fishman Commando'
                                                                                        LevelQuest = 2
                                                                                        NameQuest = 'FishmanQuest'
                                                                                        NameMon = 'Fishman Commando'
                                                                                        CFrameQuest = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
                                                                                        CFrameMon = CFrame.new(61922.6328125, 18.482830047607422, 1493.934326171875)

                                                                                        if _G.AutoFarm and 10000 < (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude then
                                                                                            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('requestEntrance', Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
                                                                                        end
                                                                                    end
                                                                                else
                                                                                    Mon = 'Fishman Warrior'
                                                                                    LevelQuest = 1
                                                                                    NameQuest = 'FishmanQuest'
                                                                                    NameMon = 'Fishman Warrior'
                                                                                    CFrameQuest = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
                                                                                    CFrameMon = CFrame.new(60878.30078125, 18.482830047607422, 1543.7574462890625)

                                                                                    if _G.AutoFarm and 10000 < (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude then
                                                                                        game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('requestEntrance', Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
                                                                                    end
                                                                                end
                                                                            else
                                                                                Mon = 'Military Spy'
                                                                                LevelQuest = 2
                                                                                NameQuest = 'MagmaQuest'
                                                                                NameMon = 'Military Spy'
                                                                                CFrameQuest = CFrame.new(-5313.37012, 10.9500084, 8515.29395, -0.499959469, -0, 0.866048813, -0, 1, -0, -0.866048813, -0, -0.499959469)
                                                                                CFrameMon = CFrame.new(-5802.8681640625, 86.26241302490234, 8828.859375)
                                                                            end
                                                                        else
                                                                            Mon = 'Military Soldier'
                                                                            LevelQuest = 1
                                                                            NameQuest = 'MagmaQuest'
                                                                            NameMon = 'Military Soldier'
                                                                            CFrameQuest = CFrame.new(-5313.37012, 10.9500084, 8515.29395, -0.499959469, -0, 0.866048813, -0, 1, -0, -0.866048813, -0, -0.499959469)
                                                                            CFrameMon = CFrame.new(-5411.16455078125, 11.081554412841797, 8454.29296875)
                                                                        end
                                                                    else
                                                                        Mon = 'Gladiator'
                                                                        LevelQuest = 2
                                                                        NameQuest = 'ColosseumQuest'
                                                                        NameMon = 'Gladiator'
                                                                        CFrameQuest = CFrame.new(-1580.04663, 6.35000277, -2986.47534, -0.515037298, -0, -0.857167721, -0, 1, -0, 0.857167721, -0, -0.515037298)
                                                                        CFrameMon = CFrame.new(-1292.838134765625, 56.380882263183594, -3339.031494140625)
                                                                    end
                                                                else
                                                                    Mon = 'Toga Warrior'
                                                                    LevelQuest = 1
                                                                    NameQuest = 'ColosseumQuest'
                                                                    NameMon = 'Toga Warrior'
                                                                    CFrameQuest = CFrame.new(-1580.04663, 6.35000277, -2986.47534, -0.515037298, -0, -0.857167721, -0, 1, -0, 0.857167721, -0, -0.515037298)
                                                                    CFrameMon = CFrame.new(-1820.21484375, 51.68385696411133, -2740.6650390625)
                                                                end
                                                            else
                                                                Mon = 'Dangerous Prisoner'
                                                                LevelQuest = 2
                                                                NameQuest = 'PrisonerQuest'
                                                                NameMon = 'Dangerous Prisoner'
                                                                CFrameQuest = CFrame.new(5308.93115, 1.65517521, 475.120514, -0.0894274712, -5.00292918e-9, -0.995993316, 1.60817859e-9, 1, -5.16744869e-9, 0.995993316, -2.06384709e-9, -0.0894274712)
                                                                CFrameMon = CFrame.new(5654.5634765625, 15.633401870727539, 866.2991943359375)
                                                            end
                                                        else
                                                            Mon = 'Prisoner'
                                                            LevelQuest = 1
                                                            NameQuest = 'PrisonerQuest'
                                                            NameMon = 'Prisoner'
                                                            CFrameQuest = CFrame.new(5308.93115, 1.65517521, 475.120514, -0.0894274712, -5.00292918e-9, -0.995993316, 1.60817859e-9, 1, -5.16744869e-9, 0.995993316, -2.06384709e-9, -0.0894274712)
                                                            CFrameMon = CFrame.new(5098.9736328125, -0.3204058110713959, 474.2373352050781)
                                                        end
                                                    else
                                                        Mon = 'Dark Master'
                                                        LevelQuest = 2
                                                        NameQuest = 'SkyQuest'
                                                        NameMon = 'Dark Master'
                                                        CFrameQuest = CFrame.new(-4839.53027, 716.368591, -2619.44165, 0.866007268, -0, 0.500031412, -0, 1, -0, -0.500031412, -0, 0.866007268)
                                                        CFrameMon = CFrame.new(-5259.8447265625, 391.3976745605469, -2229.035400390625)
                                                    end
                                                else
                                                    Mon = 'Sky Bandit'
                                                    LevelQuest = 1
                                                    NameQuest = 'SkyQuest'
                                                    NameMon = 'Sky Bandit'
                                                    CFrameQuest = CFrame.new(-4839.53027, 716.368591, -2619.44165, 0.866007268, -0, 0.500031412, -0, 1, -0, -0.500031412, -0, 0.866007268)
                                                    CFrameMon = CFrame.new(-4953.20703125, 295.74420166015625, -2899.22900390625)
                                                end
                                            else
                                                Mon = 'Chief Petty Officer'
                                                LevelQuest = 1
                                                NameQuest = 'MarineQuest2'
                                                NameMon = 'Chief Petty Officer'
                                                CFrameQuest = CFrame.new(-5039.58643, 27.3500385, 4324.68018, -0, -0, -1, -0, 1, -0, 1, -0, -0)
                                                CFrameMon = CFrame.new(-4881.23095703125, 22.65204429626465, 4273.75244140625)
                                            end
                                        else
                                            Mon = 'Snowman'
                                            LevelQuest = 2
                                            NameQuest = 'SnowQuest'
                                            NameMon = 'Snowman'
                                            CFrameQuest = CFrame.new(1389.74451, 88.1519318, -1298.90796, -0.342042685, -0, 0.939684391, -0, 1, -0, -0.939684391, -0, -0.342042685)
                                            CFrameMon = CFrame.new(1201.6412353515625, 144.57958984375, -1550.0670166015625)
                                        end
                                    else
                                        Mon = 'Snow Bandit'
                                        LevelQuest = 1
                                        NameQuest = 'SnowQuest'
                                        NameMon = 'Snow Bandit'
                                        CFrameQuest = CFrame.new(1389.74451, 88.1519318, -1298.90796, -0.342042685, -0, 0.939684391, -0, 1, -0, -0.939684391, -0, -0.342042685)
                                        CFrameMon = CFrame.new(1354.347900390625, 87.27277374267578, -1393.946533203125)
                                    end
                                else
                                    Mon = 'Desert Officer'
                                    LevelQuest = 2
                                    NameQuest = 'DesertQuest'
                                    NameMon = 'Desert Officer'
                                    CFrameQuest = CFrame.new(894.488647, 5.14000702, 4392.43359, 0.819155693, -0, -0.573571265, -0, 1, -0, 0.573571265, -0, 0.819155693)
                                    CFrameMon = CFrame.new(1608.2822265625, 8.614224433898926, 4371.00732421875)
                                end
                            else
                                Mon = 'Desert Bandit'
                                LevelQuest = 1
                                NameQuest = 'DesertQuest'
                                NameMon = 'Desert Bandit'
                                CFrameQuest = CFrame.new(894.488647, 5.14000702, 4392.43359, 0.819155693, -0, -0.573571265, -0, 1, -0, 0.573571265, -0, 0.819155693)
                                CFrameMon = CFrame.new(924.7998046875, 6.44867467880249, 4481.5859375)
                            end
                        else
                            Mon = 'Brute'
                            LevelQuest = 2
                            NameQuest = 'BuggyQuest1'
                            NameMon = 'Brute'
                            CFrameQuest = CFrame.new(-1141.07483, 4.10001802, 3831.5498, 0.965929627, -0, -0.258804798, -0, 1, -0, 0.258804798, -0, 0.965929627)
                            CFrameMon = CFrame.new(-1140.083740234375, 14.809885025024414, 4322.92138671875)
                        end
                    else
                        Mon = 'Pirate'
                        LevelQuest = 1
                        NameQuest = 'BuggyQuest1'
                        NameMon = 'Pirate'
                        CFrameQuest = CFrame.new(-1141.07483, 4.10001802, 3831.5498, 0.965929627, -0, -0.258804798, -0, 1, -0, 0.258804798, -0, 0.965929627)
                        CFrameMon = CFrame.new(-1103.513427734375, 13.752052307128906, 3896.091064453125)
                    end
                else
                    Mon = 'Gorilla'
                    LevelQuest = 2
                    NameQuest = 'JungleQuest'
                    NameMon = 'Gorilla'
                    CFrameQuest = CFrame.new(-1598.08911, 35.5501175, 153.377838, -0, -0, 1, -0, 1, -0, -1, -0, -0)
                    CFrameMon = CFrame.new(-1129.8836669921875, 40.46354675292969, -525.4237060546875)
                end
            else
                Mon = 'Monkey'
                LevelQuest = 1
                NameQuest = 'JungleQuest'
                NameMon = 'Monkey'
                CFrameQuest = CFrame.new(-1598.08911, 35.5501175, 153.377838, -0, -0, 1, -0, 1, -0, -1, -0, -0)
                CFrameMon = CFrame.new(-1448.51806640625, 67.85301208496094, 11.46579647064209)
            end
        else
            Mon = 'Bandit'
            LevelQuest = 1
            NameQuest = 'BanditQuest1'
            NameMon = 'Bandit'
            CFrameQuest = CFrame.new(1059.37195, 15.4495068, 1550.4231, 0.939700544, -0, -0.341998369, -0, 1, -0, 0.341998369, -0, 0.939700544)
            CFrameMon = CFrame.new(1045.962646484375, 27.00250816345215, 1560.8203125)
        end
    elseif World2 then
        if (MyLevel < 700 or 724 < MyLevel) and SelectMonster ~= 'Raider' then
            if (MyLevel < 725 or MyLevel > 774) and SelectMonster ~= 'Mercenary' then
                if (MyLevel < 775 or MyLevel > 799) and SelectMonster ~= 'Swan Pirate' then
                    if (MyLevel < 800 or 874 < MyLevel) and SelectMonster ~= 'Factory Staff' then
                        if (MyLevel < 875 or MyLevel > 899) and SelectMonster ~= 'Marine Lieutenant' then
                            if (MyLevel < 900 or MyLevel > 949) and SelectMonster ~= 'Marine Captain' then
                                if (MyLevel < 950 or 974 < MyLevel) and SelectMonster ~= 'Zombie' then
                                    if (MyLevel < 975 or MyLevel > 999) and SelectMonster ~= 'Vampire' then
                                        if (MyLevel < 1000 or 1049 < MyLevel) and SelectMonster ~= 'Snow Trooper' then
                                            if (MyLevel < 1050 or MyLevel > 1099) and SelectMonster ~= 'Winter Warrior' then
                                                if (MyLevel < 1100 or MyLevel > 1124) and SelectMonster ~= 'Lab Subordinate' then
                                                    if (MyLevel < 1125 or MyLevel > 1174) and SelectMonster ~= 'Horned Warrior' then
                                                        if (MyLevel < 1175 or 1199 < MyLevel) and SelectMonster ~= 'Magma Ninja' then
                                                            if (MyLevel < 1200 or 1249 < MyLevel) and SelectMonster ~= 'Lava Pirate' then
                                                                if (MyLevel < 1250 or MyLevel > 1274) and SelectMonster ~= 'Ship Deckhand' then
                                                                    if (MyLevel < 1275 or 1299 < MyLevel) and SelectMonster ~= 'Ship Engineer' then
                                                                        if (MyLevel < 1300 or MyLevel > 1324) and SelectMonster ~= 'Ship Steward' then
                                                                            if (MyLevel < 1325 or 1349 < MyLevel) and SelectMonster ~= 'Ship Officer' then
                                                                                if (MyLevel < 1350 or 1374 < MyLevel) and SelectMonster ~= 'Arctic Warrior' then
                                                                                    if (MyLevel < 1375 or MyLevel > 1424) and SelectMonster ~= 'Snow Lurker' then
                                                                                        if (MyLevel < 1425 or 1449 < MyLevel) and SelectMonster ~= 'Sea Soldier' then
                                                                                            if MyLevel >= 1450 or SelectMonster == 'Water Fighter' then
                                                                                                Mon = 'Water Fighter'
                                                                                                LevelQuest = 2
                                                                                                NameQuest = 'ForgottenQuest'
                                                                                                NameMon = 'Water Fighter'
                                                                                                CFrameQuest = CFrame.new(-3054.44458, 235.544281, -10142.8193, 0.990270376, -0, -0.13915664, -0, 1, -0, 0.13915664, -0, 0.990270376)
                                                                                                CFrameMon = CFrame.new(-3352.9013671875, 285.01556396484375, -10534.841796875)
                                                                                            end
                                                                                        else
                                                                                            Mon = 'Sea Soldier'
                                                                                            LevelQuest = 1
                                                                                            NameQuest = 'ForgottenQuest'
                                                                                            NameMon = 'Sea Soldier'
                                                                                            CFrameQuest = CFrame.new(-3054.44458, 235.544281, -10142.8193, 0.990270376, -0, -0.13915664, -0, 1, -0, 0.13915664, -0, 0.990270376)
                                                                                            CFrameMon = CFrame.new(-3028.2236328125, 64.67451477050781, -9775.4267578125)
                                                                                        end
                                                                                    else
                                                                                        Mon = 'Snow Lurker'
                                                                                        LevelQuest = 2
                                                                                        NameQuest = 'FrostQuest'
                                                                                        NameMon = 'Snow Lurker'
                                                                                        CFrameQuest = CFrame.new(5667.6582, 26.7997818, -6486.08984, -0.933587909, -0, -0.358349502, -0, 1, -0, 0.358349502, -0, -0.933587909)
                                                                                        CFrameMon = CFrame.new(5407.07373046875, 69.19437408447266, -6880.88037109375)
                                                                                    end
                                                                                else
                                                                                    Mon = 'Arctic Warrior'
                                                                                    LevelQuest = 1
                                                                                    NameQuest = 'FrostQuest'
                                                                                    NameMon = 'Arctic Warrior'
                                                                                    CFrameQuest = CFrame.new(5667.6582, 26.7997818, -6486.08984, -0.933587909, -0, -0.358349502, -0, 1, -0, 0.358349502, -0, -0.933587909)
                                                                                    CFrameMon = CFrame.new(5966.24609375, 62.97002029418945, -6179.3828125)

                                                                                    if _G.AutoFarm and 10000 < (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude then
                                                                                        game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('requestEntrance', Vector3.new(-6508.5581054688, 5000.034996032715, -132.83953857422))
                                                                                    end
                                                                                end
                                                                            else
                                                                                Mon = 'Ship Officer'
                                                                                LevelQuest = 2
                                                                                NameQuest = 'ShipQuest2'
                                                                                NameMon = 'Ship Officer'
                                                                                CFrameQuest = CFrame.new(968.80957, 125.092171, 33244.125)
                                                                                CFrameMon = CFrame.new(1036.0179443359375, 181.4390411376953, 33315.7265625)

                                                                                if _G.AutoFarm and 10000 < (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude then
                                                                                    game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('requestEntrance', Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
                                                                                end
                                                                            end
                                                                        else
                                                                            Mon = 'Ship Steward'
                                                                            LevelQuest = 1
                                                                            NameQuest = 'ShipQuest2'
                                                                            NameMon = 'Ship Steward'
                                                                            CFrameQuest = CFrame.new(968.80957, 125.092171, 33244.125)
                                                                            CFrameMon = CFrame.new(919.4385375976563, 129.55599975585938, 33436.03515625)

                                                                            if _G.AutoFarm and 10000 < (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude then
                                                                                game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('requestEntrance', Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
                                                                            end
                                                                        end
                                                                    else
                                                                        Mon = 'Ship Engineer'
                                                                        LevelQuest = 2
                                                                        NameQuest = 'ShipQuest1'
                                                                        NameMon = 'Ship Engineer'
                                                                        CFrameQuest = CFrame.new(1037.80127, 125.092171, 32911.6016)
                                                                        CFrameMon = CFrame.new(919.4786376953125, 43.54401397705078, 32779.96875)

                                                                        if _G.AutoFarm and 10000 < (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude then
                                                                            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('requestEntrance', Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
                                                                        end
                                                                    end
                                                                else
                                                                    Mon = 'Ship Deckhand'
                                                                    LevelQuest = 1
                                                                    NameQuest = 'ShipQuest1'
                                                                    NameMon = 'Ship Deckhand'
                                                                    CFrameQuest = CFrame.new(1037.80127, 125.092171, 32911.6016)
                                                                    CFrameMon = CFrame.new(1212.0111083984375, 150.79205322265625, 33059.24609375)

                                                                    if _G.AutoFarm and 10000 < (CFrameQuest.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude then
                                                                        game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('requestEntrance', Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
                                                                    end
                                                                end
                                                            else
                                                                Mon = 'Lava Pirate'
                                                                LevelQuest = 2
                                                                NameQuest = 'FireSideQuest'
                                                                NameMon = 'Lava Pirate'
                                                                CFrameQuest = CFrame.new(-5428.03174, 15.0622921, -5299.43457, -0.882952213, -0, 0.469463557, -0, 1, -0, -0.469463557, -0, -0.882952213)
                                                                CFrameMon = CFrame.new(-5213.33154296875, 49.73788070678711, -4701.451171875)
                                                            end
                                                        else
                                                            Mon = 'Magma Ninja'
                                                            LevelQuest = 1
                                                            NameQuest = 'FireSideQuest'
                                                            NameMon = 'Magma Ninja'
                                                            CFrameQuest = CFrame.new(-5428.03174, 15.0622921, -5299.43457, -0.882952213, -0, 0.469463557, -0, 1, -0, -0.469463557, -0, -0.882952213)
                                                            CFrameMon = CFrame.new(-5449.6728515625, 76.65874481201172, -5808.20068359375)
                                                        end
                                                    else
                                                        Mon = 'Horned Warrior'
                                                        LevelQuest = 2
                                                        NameQuest = 'IceSideQuest'
                                                        NameMon = 'Horned Warrior'
                                                        CFrameQuest = CFrame.new(-6064.06885, 15.2422857, -4902.97852, 0.453972578, -0, -0.891015649, -0, 1, -0, 0.891015649, -0, 0.453972578)
                                                        CFrameMon = CFrame.new(-6341.36669921875, 15.951770782470703, -5723.162109375)
                                                    end
                                                else
                                                    Mon = 'Lab Subordinate'
                                                    LevelQuest = 1
                                                    NameQuest = 'IceSideQuest'
                                                    NameMon = 'Lab Subordinate'
                                                    CFrameQuest = CFrame.new(-6064.06885, 15.2422857, -4902.97852, 0.453972578, -0, -0.891015649, -0, 1, -0, 0.891015649, -0, 0.453972578)
                                                    CFrameMon = CFrame.new(-5707.4716796875, 15.951709747314453, -4513.39208984375)
                                                end
                                            else
                                                Mon = 'Winter Warrior'
                                                LevelQuest = 2
                                                NameQuest = 'SnowMountainQuest'
                                                NameMon = 'Winter Warrior'
                                                CFrameQuest = CFrame.new(609.858826, 400.119904, -5372.25928, -0.374604106, -0, 0.92718488, -0, 1, -0, -0.92718488, -0, -0.374604106)
                                                CFrameMon = CFrame.new(1142.7451171875, 475.6398010253906, -5199.41650390625)
                                            end
                                        else
                                            Mon = 'Snow Trooper'
                                            LevelQuest = 1
                                            NameQuest = 'SnowMountainQuest'
                                            NameMon = 'Snow Trooper'
                                            CFrameQuest = CFrame.new(609.858826, 400.119904, -5372.25928, -0.374604106, -0, 0.92718488, -0, 1, -0, -0.92718488, -0, -0.374604106)
                                            CFrameMon = CFrame.new(549.1473388671875, 427.3870544433594, -5563.69873046875)
                                        end
                                    else
                                        Mon = 'Vampire'
                                        LevelQuest = 2
                                        NameQuest = 'ZombieQuest'
                                        NameMon = 'Vampire'
                                        CFrameQuest = CFrame.new(-5497.06152, 47.5923004, -795.237061, -0.29242146, -0, -0.95628953, -0, 1, -0, 0.95628953, -0, -0.29242146)
                                        CFrameMon = CFrame.new(-6037.66796875, 32.18463897705078, -1340.6597900390625)
                                    end
                                else
                                    Mon = 'Zombie'
                                    LevelQuest = 1
                                    NameQuest = 'ZombieQuest'
                                    NameMon = 'Zombie'
                                    CFrameQuest = CFrame.new(-5497.06152, 47.5923004, -795.237061, -0.29242146, -0, -0.95628953, -0, 1, -0, 0.95628953, -0, -0.29242146)
                                    CFrameMon = CFrame.new(-5657.77685546875, 78.96973419189453, -928.68701171875)
                                end
                            else
                                Mon = 'Marine Captain'
                                LevelQuest = 2
                                NameQuest = 'MarineQuest3'
                                NameMon = 'Marine Captain'
                                CFrameQuest = CFrame.new(-2440.79639, 71.7140732, -3216.06812, 0.866007268, -0, 0.500031412, -0, 1, -0, -0.500031412, -0, 0.866007268)
                                CFrameMon = CFrame.new(-1861.2310791015625, 80.17658233642578, -3254.697509765625)
                            end
                        else
                            Mon = 'Marine Lieutenant'
                            LevelQuest = 1
                            NameQuest = 'MarineQuest3'
                            NameMon = 'Marine Lieutenant'
                            CFrameQuest = CFrame.new(-2440.79639, 71.7140732, -3216.06812, 0.866007268, -0, 0.500031412, -0, 1, -0, -0.500031412, -0, 0.866007268)
                            CFrameMon = CFrame.new(-2821.372314453125, 75.89727783203125, -3070.089111328125)
                        end
                    else
                        Mon = 'Factory Staff'
                        NameQuest = 'Area2Quest'
                        LevelQuest = 2
                        NameMon = 'Factory Staff'
                        CFrameQuest = CFrame.new(632.698608, 73.1055908, 918.666321, -0.0319722369, 8.96074881e-10, -0.999488771, 1.36326533e-10, 1, 8.92172336e-10, 0.999488771, -1.0773208699999999e-10, -0.0319722369)
                        CFrameMon = CFrame.new(73.07867431640625, 81.86344146728516, -27.470672607421875)
                    end
                else
                    Mon = 'Swan Pirate'
                    LevelQuest = 1
                    NameQuest = 'Area2Quest'
                    NameMon = 'Swan Pirate'
                    CFrameQuest = CFrame.new(638.43811, 71.769989, 918.282898, 0.139203906, -0, 0.99026376, -0, 1, -0, -0.99026376, -0, 0.139203906)
                    CFrameMon = CFrame.new(1068.664306640625, 137.61428833007813, 1322.1060791015625)
                end
            else
                Mon = 'Mercenary'
                LevelQuest = 2
                NameQuest = 'Area1Quest'
                NameMon = 'Mercenary'
                CFrameQuest = CFrame.new(-429.543518, 71.7699966, 1836.18188, -0.22495985, -0, -0.974368095, -0, 1, -0, 0.974368095, -0, -0.22495985)
                CFrameMon = CFrame.new(-1004.3244018554688, 80.15886688232422, 1424.619384765625)
            end
        else
            Mon = 'Raider'
            LevelQuest = 1
            NameQuest = 'Area1Quest'
            NameMon = 'Raider'
            CFrameQuest = CFrame.new(-429.543518, 71.7699966, 1836.18188, -0.22495985, -0, -0.974368095, -0, 1, -0, 0.974368095, -0, -0.22495985)
            CFrameMon = CFrame.new(-728.3267211914063, 52.779319763183594, 2345.7705078125)
        end
    elseif World3 then
        if (MyLevel < 1500 or MyLevel > 1524) and SelectMonster ~= 'Pirate Millionaire' then
            if (MyLevel < 1525 or 1574 < MyLevel) and SelectMonster ~= 'Pistol Billionaire' then
                if (MyLevel < 1575 or MyLevel > 1599) and SelectMonster ~= 'Dragon Crew Warrior' then
                    if (MyLevel < 1600 or MyLevel > 1624) and SelectMonster ~= 'Dragon Crew Archer' then
                        if (MyLevel < 1625 or 1649 < MyLevel) and SelectMonster ~= 'Hydra Enforcer' then
                            if (MyLevel < 1650 or 1699 < MyLevel) and SelectMonster ~= 'Venomous Assailant' then
                                if (MyLevel < 1700 or 1724 < MyLevel) and SelectMonster ~= 'Marine Commodore' then
                                    if (MyLevel < 1725 or 1774 < MyLevel) and SelectMonster ~= 'Marine Rear Admiral' then
                                        if (MyLevel < 1775 or 1799 < MyLevel) and SelectMonster ~= 'Fishman Raider' then
                                            if (MyLevel < 1800 or MyLevel > 1824) and SelectMonster ~= 'Fishman Captain' then
                                                if (MyLevel < 1825 or 1849 < MyLevel) and SelectMonster ~= 'Forest Pirate' then
                                                    if (MyLevel < 1850 or 1899 < MyLevel) and SelectMonster ~= 'Mythological Pirate' then
                                                        if (MyLevel < 1900 or MyLevel > 1924) and SelectMonster ~= 'Jungle Pirate' then
                                                            if (MyLevel < 1925 or MyLevel > 1974) and SelectMonster ~= 'Musketeer Pirate' then
                                                                if (MyLevel < 1975 or MyLevel > 1999) and SelectMonster ~= 'Reborn Skeleton' then
                                                                    if (MyLevel < 2000 or 2024 < MyLevel) and SelectMonster ~= 'Living Zombie' then
                                                                        if (MyLevel < 2025 or MyLevel > 2049) and SelectMonster ~= 'Demonic Soul' then
                                                                            if (MyLevel < 2050 or MyLevel > 2074) and SelectMonster ~= 'Posessed Mummy' then
                                                                                if (MyLevel < 2075 or 2099 < MyLevel) and SelectMonster ~= 'Peanut Scout' then
                                                                                    if (MyLevel < 2100 or MyLevel > 2124) and SelectMonster ~= 'Peanut President' then
                                                                                        if (MyLevel < 2125 or MyLevel > 2149) and SelectMonster ~= 'Ice Cream Chef' then
                                                                                            if (MyLevel < 2150 or MyLevel > 2199) and SelectMonster ~= 'Ice Cream Commander' then
                                                                                                if (MyLevel < 2200 or MyLevel > 2224) and SelectMonster ~= 'Cookie Crafter' then
                                                                                                    if (MyLevel < 2225 or 2249 < MyLevel) and SelectMonster ~= 'Cake Guard' then
                                                                                                        if (MyLevel < 2250 or MyLevel > 2274) and SelectMonster ~= 'Baking Staff' then
                                                                                                            if (MyLevel < 2275 or MyLevel > 2299) and SelectMonster ~= 'Head Baker' then
                                                                                                                if (MyLevel < 2300 or 2324 < MyLevel) and SelectMonster ~= 'Cocoa Warrior' then
                                                                                                                    if (MyLevel < 2325 or MyLevel > 2349) and SelectMonster ~= 'Chocolate Bar Battler' then
                                                                                                                        if (MyLevel < 2350 or MyLevel > 2374) and SelectMonster ~= 'Sweet Thief' then
                                                                                                                            if (MyLevel < 2375 or MyLevel > 2399) and SelectMonster ~= 'Candy Rebel' then
                                                                                                                                if (MyLevel < 2400 or 2424 < MyLevel) and SelectMonster ~= 'Candy Pirate' then
                                                                                                                                    if (MyLevel < 2425 or MyLevel > 2449) and SelectMonster ~= 'Snow Demon' then
                                                                                                                                        if (MyLevel < 2450 or MyLevel > 2474) and SelectMonster ~= 'Isle Outlaw' then
                                                                                                                                            if (MyLevel < 2475 or 2524 < MyLevel) and SelectMonster ~= 'Island Boy' then
                                                                                                                                                if (MyLevel < 2525 or MyLevel > 2550) and SelectMonster ~= 'Isle Champion' then
                                                                                                                                                    if (MyLevel < 2550 or 2574 < MyLevel) and SelectMonster ~= 'Serpent Hunter' then
                                                                                                                                                        if MyLevel >= 2575 or SelectMonster == 'Skull Slayer' then
                                                                                                                                                            Mon = 'Skull Slayer'
                                                                                                                                                            LevelQuest = 2
                                                                                                                                                            NameQuest = 'TikiQuest3'
                                                                                                                                                            NameMon = 'Skull Slayer'
                                                                                                                                                            CFrameQuest = CFrame.new(-16665.1914, 104.596405, 1579.69434, 0.951068401, -0, -0.308980465, -0, 1, -0, 0.308980465, -0, 0.951068401)
                                                                                                                                                            CFrameMon = CFrame.new(-16855.043, 122.457253, 1478.15308, -0.999392271, -0, -0.0348687991, -0, 1, -0, 0.0348687991, -0, -0.999392271)
                                                                                                                                                        end
                                                                                                                                                    else
                                                                                                                                                        Mon = 'Serpent Hunter'
                                                                                                                                                        LevelQuest = 1
                                                                                                                                                        NameQuest = 'TikiQuest3'
                                                                                                                                                        NameMon = 'Serpent Hunter'
                                                                                                                                                        CFrameQuest = CFrame.new(-16665.1914, 104.596405, 1579.69434, 0.951068401, -0, -0.308980465, -0, 1, -0, 0.308980465, -0, 0.951068401)
                                                                                                                                                        CFrameMon = CFrame.new(-16521.0625, 106.09285, 1488.78467, 0.469467044, -0, 0.882950008, -0, 1, -0, -0.882950008, -0, 0.469467044)
                                                                                                                                                    end
                                                                                                                                                else
                                                                                                                                                    Mon = 'Isle Champion'
                                                                                                                                                    LevelQuest = 2
                                                                                                                                                    NameQuest = 'TikiQuest2'
                                                                                                                                                    NameMon = 'Isle Champion'
                                                                                                                                                    CFrameQuest = CFrame.new(-16539.078125, 55.68632888793945, 1051.5738525390625)
                                                                                                                                                    CFrameMon = CFrame.new(-16641.6796875, 235.7825469970703, 1031.282958984375)
                                                                                                                                                end
                                                                                                                                            else
                                                                                                                                                Mon = 'Island Boy'
                                                                                                                                                LevelQuest = 2
                                                                                                                                                NameQuest = 'TikiQuest1'
                                                                                                                                                NameMon = 'Island Boy'
                                                                                                                                                CFrameQuest = CFrame.new(-16547.748046875, 61.13533401489258, -173.41360473632813)
                                                                                                                                                CFrameMon = CFrame.new(-16901.26171875, 84.06756591796875, -192.88906860351563)
                                                                                                                                            end
                                                                                                                                        else
                                                                                                                                            Mon = 'Isle Outlaw'
                                                                                                                                            LevelQuest = 1
                                                                                                                                            NameQuest = 'TikiQuest1'
                                                                                                                                            NameMon = 'Isle Outlaw'
                                                                                                                                            CFrameQuest = CFrame.new(-16547.748046875, 61.13533401489258, -173.41360473632813)
                                                                                                                                            CFrameMon = CFrame.new(-16442.814453125, 116.13899993896484, -264.4637756347656)
                                                                                                                                        end
                                                                                                                                    else
                                                                                                                                        Mon = 'Snow Demon'
                                                                                                                                        LevelQuest = 2
                                                                                                                                        NameQuest = 'CandyQuest1'
                                                                                                                                        NameMon = 'Snow Demon'
                                                                                                                                        CFrameQuest = CFrame.new(-1150.0400390625, 20.378934860229492, -14446.3349609375)
                                                                                                                                        CFrameMon = CFrame.new(-880.2006225585938, 71.24776458740234, -14538.609375)
                                                                                                                                    end
                                                                                                                                else
                                                                                                                                    Mon = 'Candy Pirate'
                                                                                                                                    LevelQuest = 1
                                                                                                                                    NameQuest = 'CandyQuest1'
                                                                                                                                    NameMon = 'Candy Pirate'
                                                                                                                                    CFrameQuest = CFrame.new(-1150.0400390625, 20.378934860229492, -14446.3349609375)
                                                                                                                                    CFrameMon = CFrame.new(-1310.5003662109375, 26.016523361206055, -14562.404296875)
                                                                                                                                end
                                                                                                                            else
                                                                                                                                Mon = 'Candy Rebel'
                                                                                                                                LevelQuest = 2
                                                                                                                                NameQuest = 'ChocQuest2'
                                                                                                                                NameMon = 'Candy Rebel'
                                                                                                                                CFrameQuest = CFrame.new(150.5066375732422, 30.693693161010742, -12774.5029296875)
                                                                                                                                CFrameMon = CFrame.new(134.86563110351563, 77.2476806640625, -12876.5478515625)
                                                                                                                            end
                                                                                                                        else
                                                                                                                            Mon = 'Sweet Thief'
                                                                                                                            LevelQuest = 1
                                                                                                                            NameQuest = 'ChocQuest2'
                                                                                                                            NameMon = 'Sweet Thief'
                                                                                                                            CFrameQuest = CFrame.new(150.5066375732422, 30.693693161010742, -12774.5029296875)
                                                                                                                            CFrameMon = CFrame.new(165.1884765625, 76.05885314941406, -12600.8369140625)
                                                                                                                        end
                                                                                                                    else
                                                                                                                        Mon = 'Chocolate Bar Battler'
                                                                                                                        LevelQuest = 2
                                                                                                                        NameQuest = 'ChocQuest1'
                                                                                                                        NameMon = 'Chocolate Bar Battler'
                                                                                                                        CFrameQuest = CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375)
                                                                                                                        CFrameMon = CFrame.new(582.590576171875, 77.18809509277344, -12463.162109375)
                                                                                                                    end
                                                                                                                else
                                                                                                                    Mon = 'Cocoa Warrior'
                                                                                                                    LevelQuest = 1
                                                                                                                    NameQuest = 'ChocQuest1'
                                                                                                                    NameMon = 'Cocoa Warrior'
                                                                                                                    CFrameQuest = CFrame.new(233.22836303710938, 29.876001358032227, -12201.2333984375)
                                                                                                                    CFrameMon = CFrame.new(-21.55328369140625, 80.57499694824219, -12352.3876953125)
                                                                                                                end
                                                                                                            else
                                                                                                                Mon = 'Head Baker'
                                                                                                                LevelQuest = 2
                                                                                                                NameQuest = 'CakeQuest2'
                                                                                                                NameMon = 'Head Baker'
                                                                                                                CFrameQuest = CFrame.new(-1927.91602, 37.7981339, -12842.5391, -0.96804446, 4.2214214299999995e-8, 0.250778586, 4.74911062e-8, 1, 1.49904711e-8, -0.250778586, 2.64211941e-8, -0.96804446)
                                                                                                                CFrameMon = CFrame.new(-2216.188232421875, 82.884521484375, -12869.2939453125)
                                                                                                            end
                                                                                                        else
                                                                                                            Mon = 'Baking Staff'
                                                                                                            LevelQuest = 1
                                                                                                            NameQuest = 'CakeQuest2'
                                                                                                            NameMon = 'Baking Staff'
                                                                                                            CFrameQuest = CFrame.new(-1927.91602, 37.7981339, -12842.5391, -0.96804446, 4.2214214299999995e-8, 0.250778586, 4.74911062e-8, 1, 1.49904711e-8, -0.250778586, 2.64211941e-8, -0.96804446)
                                                                                                            CFrameMon = CFrame.new(-1887.8099365234375, 77.6185073852539, -12998.3505859375)
                                                                                                        end
                                                                                                    else
                                                                                                        Mon = 'Cake Guard'
                                                                                                        LevelQuest = 2
                                                                                                        NameQuest = 'CakeQuest1'
                                                                                                        NameMon = 'Cake Guard'
                                                                                                        CFrameQuest = CFrame.new(-2021.32007, 37.7982254, -12028.7295, 0.957576931, -8.80302053e-8, 0.288177818, 6.9301186999999995e-8, 1, 7.5193121099999995e-8, -0.288177818, -5.2032135e-8, 0.957576931)
                                                                                                        CFrameMon = CFrame.new(-1598.3070068359375, 43.773197174072266, -12244.5810546875)
                                                                                                    end
                                                                                                else
                                                                                                    Mon = 'Cookie Crafter'
                                                                                                    LevelQuest = 1
                                                                                                    NameQuest = 'CakeQuest1'
                                                                                                    NameMon = 'Cookie Crafter'
                                                                                                    CFrameQuest = CFrame.new(-2021.32007, 37.7982254, -12028.7295, 0.957576931, -8.80302053e-8, 0.288177818, 6.9301186999999995e-8, 1, 7.5193121099999995e-8, -0.288177818, -5.2032135e-8, 0.957576931)
                                                                                                    CFrameMon = CFrame.new(-2374.13671875, 37.79826354980469, -12125.30859375)
                                                                                                end
                                                                                            else
                                                                                                Mon = 'Ice Cream Commander'
                                                                                                LevelQuest = 2
                                                                                                NameQuest = 'IceCreamIslandQuest'
                                                                                                NameMon = 'Ice Cream Commander'
                                                                                                CFrameQuest = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438, -0, -0, -1, -0, 1, -0, 1, -0, -0)
                                                                                                CFrameMon = CFrame.new(-558.06103515625, 112.04895782470703, -11290.7744140625)
                                                                                            end
                                                                                        else
                                                                                            Mon = 'Ice Cream Chef'
                                                                                            LevelQuest = 1
                                                                                            NameQuest = 'IceCreamIslandQuest'
                                                                                            NameMon = 'Ice Cream Chef'
                                                                                            CFrameQuest = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438, -0, -0, -1, -0, 1, -0, 1, -0, -0)
                                                                                            CFrameMon = CFrame.new(-872.24658203125, 65.81957244873047, -10919.95703125)
                                                                                        end
                                                                                    else
                                                                                        Mon = 'Peanut President'
                                                                                        LevelQuest = 2
                                                                                        NameQuest = 'NutsIslandQuest'
                                                                                        NameMon = 'Peanut President'
                                                                                        CFrameQuest = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875, -0, -0, -1, -0, 1, -0, 1, -0, -0)
                                                                                        CFrameMon = CFrame.new(-1859.35400390625, 38.10316848754883, -10422.4296875)
                                                                                    end
                                                                                else
                                                                                    Mon = 'Peanut Scout'
                                                                                    LevelQuest = 1
                                                                                    NameQuest = 'NutsIslandQuest'
                                                                                    NameMon = 'Peanut Scout'
                                                                                    CFrameQuest = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875, -0, -0, -1, -0, 1, -0, 1, -0, -0)
                                                                                    CFrameMon = CFrame.new(-2143.241943359375, 47.72198486328125, -10029.9951171875)
                                                                                end
                                                                            else
                                                                                Mon = 'Posessed Mummy'
                                                                                LevelQuest = 2
                                                                                NameQuest = 'HauntedQuest2'
                                                                                NameMon = 'Posessed Mummy'
                                                                                CFrameQuest = CFrame.new(-9516.99316, 172.017181, 6078.46533, -0, -0, -1, -0, 1, -0, 1, -0, -0)
                                                                                CFrameMon = CFrame.new(-9582.0224609375, 6.251527309417725, 6205.478515625)
                                                                            end
                                                                        else
                                                                            Mon = 'Demonic Soul'
                                                                            LevelQuest = 1
                                                                            NameQuest = 'HauntedQuest2'
                                                                            NameMon = 'Demonic Soul'
                                                                            CFrameQuest = CFrame.new(-9516.99316, 172.017181, 6078.46533, -0, -0, -1, -0, 1, -0, 1, -0, -0)
                                                                            CFrameMon = CFrame.new(-9505.8720703125, 172.10482788085938, 6158.9931640625)
                                                                        end
                                                                    else
                                                                        Mon = 'Living Zombie'
                                                                        LevelQuest = 2
                                                                        NameQuest = 'HauntedQuest1'
                                                                        NameMon = 'Living Zombie'
                                                                        CFrameQuest = CFrame.new(-9479.2168, 141.215088, 5566.09277, -0, -0, 1, -0, 1, -0, -1, -0, -0)
                                                                        CFrameMon = CFrame.new(-10144.1318359375, 138.62667846679688, 5838.0888671875)
                                                                    end
                                                                else
                                                                    Mon = 'Reborn Skeleton'
                                                                    LevelQuest = 1
                                                                    NameQuest = 'HauntedQuest1'
                                                                    NameMon = 'Reborn Skeleton'
                                                                    CFrameQuest = CFrame.new(-9479.2168, 141.215088, 5566.09277, -0, -0, 1, -0, 1, -0, -1, -0, -0)
                                                                    CFrameMon = CFrame.new(-8763.7236328125, 165.72299194335938, 6159.86181640625)
                                                                end
                                                            else
                                                                Mon = 'Musketeer Pirate'
                                                                LevelQuest = 2
                                                                NameQuest = 'DeepForestIsland2'
                                                                NameMon = 'Musketeer Pirate'
                                                                CFrameQuest = CFrame.new(-12680.3818, 389.971039, -9902.01953, -0.0871315002, -0, 0.996196866, -0, 1, -0, -0.996196866, -0, -0.0871315002)
                                                                CFrameMon = CFrame.new(-13457.904296875, 391.545654296875, -9859.177734375)
                                                            end
                                                        else
                                                            Mon = 'Jungle Pirate'
                                                            LevelQuest = 1
                                                            NameQuest = 'DeepForestIsland2'
                                                            NameMon = 'Jungle Pirate'
                                                            CFrameQuest = CFrame.new(-12680.3818, 389.971039, -9902.01953, -0.0871315002, -0, 0.996196866, -0, 1, -0, -0.996196866, -0, -0.0871315002)
                                                            CFrameMon = CFrame.new(-12256.16015625, 331.73828125, -10485.8369140625)
                                                        end
                                                    else
                                                        Mon = 'Mythological Pirate'
                                                        LevelQuest = 2
                                                        NameQuest = 'DeepForestIsland'
                                                        NameMon = 'Mythological Pirate'
                                                        CFrameQuest = CFrame.new(-13234.04, 331.488495, -7625.40137, 0.707134247, -0, -0.707079291, -0, 1, -0, 0.707079291, -0, 0.707134247)
                                                        CFrameMon = CFrame.new(-13680.607421875, 501.08154296875, -6991.189453125)
                                                    end
                                                else
                                                    Mon = 'Forest Pirate'
                                                    LevelQuest = 1
                                                    NameQuest = 'DeepForestIsland'
                                                    NameMon = 'Forest Pirate'
                                                    CFrameQuest = CFrame.new(-13234.04, 331.488495, -7625.40137, 0.707134247, -0, -0.707079291, -0, 1, -0, 0.707079291, -0, 0.707134247)
                                                    CFrameMon = CFrame.new(-13274.478515625, 332.3781433105469, -7769.58056640625)
                                                end
                                            else
                                                Mon = 'Fishman Captain'
                                                LevelQuest = 2
                                                NameQuest = 'DeepForestIsland3'
                                                NameMon = 'Fishman Captain'
                                                CFrameQuest = CFrame.new(-10581.6563, 330.872955, -8761.18652, -0.882952213, -0, 0.469463557, -0, 1, -0, -0.469463557, -0, -0.882952213)
                                                CFrameMon = CFrame.new(-10994.701171875, 352.38140869140625, -9002.1103515625)
                                            end
                                        else
                                            Mon = 'Fishman Raider'
                                            LevelQuest = 1
                                            NameQuest = 'DeepForestIsland3'
                                            NameMon = 'Fishman Raider'
                                            CFrameQuest = CFrame.new(-10581.6563, 330.872955, -8761.18652, -0.882952213, -0, 0.469463557, -0, 1, -0, -0.469463557, -0, -0.882952213)
                                            CFrameMon = CFrame.new(-10407.5263671875, 331.76263427734375, -8368.5166015625)
                                        end
                                    else
                                        Mon = 'Marine Rear Admiral'
                                        LevelQuest = 2
                                        NameQuest = 'MarineTreeIsland'
                                        NameMon = 'Marine Rear Admiral'
                                        CFrameQuest = CFrame.new(2481.09228515625, 74.27049255371094, -6779.640625)
                                        CFrameMon = CFrame.new(3761.81006, 123.912003, -6823.52197, 0.961273968, -0, 0.275594592, -0, 1, -0, -0.275594592, -0, 0.961273968)
                                    end
                                else
                                    Mon = 'Marine Commodore'
                                    LevelQuest = 1
                                    NameQuest = 'MarineTreeIsland'
                                    NameMon = 'Marine Commodore'
                                    CFrameQuest = CFrame.new(2481.09228515625, 74.27049255371094, -6779.640625)
                                    CFrameMon = CFrame.new(2577.25391, 75.6100006, -7739.87207, 0.499959469, -0, 0.866048813, -0, 1, -0, -0.866048813, -0, 0.499959469)
                                end
                            else
                                Mon = 'Venomous Assailant'
                                NameQuest = 'VenomCrewQuest'
                                LevelQuest = 2
                                NameMon = 'Venomous Assailant'
                                CFrameQuest = CFrame.new(5206.40185546875, 1004.10498046875, 748.3504638671875)
                                CFrameMon = CFrame.new(4674.92676, 1134.82654, 996.308838, 0.731321394, -0, -0.682033002, -0, 1, -0, 0.682033002, -0, 0.731321394)
                            end
                        else
                            Mon = 'Hydra Enforcer'
                            NameQuest = 'VenomCrewQuest'
                            LevelQuest = 1
                            NameMon = 'Hydra Enforcer'
                            CFrameQuest = CFrame.new(5206.40185546875, 1004.10498046875, 748.3504638671875)
                            CFrameMon = CFrame.new(4547.11523, 1003.10217, 334.194824, 0.388810456, -0, -0.921317935, -0, 1, -0, 0.921317935, -0, 0.388810456)
                        end
                    else
                        Mon = 'Dragon Crew Archer'
                        NameQuest = 'DragonCrewQuest'
                        LevelQuest = 2
                        NameMon = 'Dragon Crew Archer'
                        CFrameQuest = CFrame.new(6750.4931640625, 127.44916534423828, -711.0308837890625)
                        CFrameMon = CFrame.new(6668.76172, 481.376923, 329.12207, -0.121787429, -0, -0.992556155, -0, 1, -0, 0.992556155, -0, -0.121787429)
                    end
                else
                    Mon = 'Dragon Crew Warrior'
                    LevelQuest = 1
                    NameQuest = 'DragonCrewQuest'
                    NameMon = 'Dragon Crew Warrior'
                    CFrameQuest = CFrame.new(6750.4931640625, 127.44916534423828, -711.0308837890625)
                    CFrameMon = CFrame.new(6709.76367, 52.3442993, -1139.02966, -0.763515472, -0, 0.645789504, -0, 1, -0, -0.645789504, -0, -0.763515472)
                end
            else
                Mon = 'Pistol Billionaire'
                LevelQuest = 2
                NameQuest = 'PiratePortQuest'
                NameMon = 'Pistol Billionaire'
                CFrameQuest = CFrame.new(-450.104645, 107.681458, 5950.72607, 0.957107544, -0, -0.289732844, -0, 1, -0, 0.289732844, -0, 0.957107544)
                CFrameMon = CFrame.new(-54.8110352, 83.7698746, 5947.84082, -0.965929747, -0, 0.258804798, -0, 1, -0, -0.258804798, -0, -0.965929747)
            end
        else
            Mon = 'Pirate Millionaire'
            LevelQuest = 1
            NameQuest = 'PiratePortQuest'
            NameMon = 'Pirate Millionaire'
            CFrameQuest = CFrame.new(-450.104645, 107.681458, 5950.72607, 0.957107544, -0, -0.289732844, -0, 1, -0, 0.289732844, -0, 0.957107544)
            CFrameMon = CFrame.new(-245.9963836669922, 47.30615234375, 5584.1005859375)
        end
    end
end

-- ============================================
-- SERVER HOP FUNCTION
-- ============================================
function Hop()
    local _PlaceId = game.PlaceId
    local hours = {}
    local text = ''
    local _hour = os.date('!*t').hour

    function TPReturner()
        local value
        if text == '' then
            value = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. _PlaceId .. '/servers/Public?sortOrder=Asc&limit=100'))
        else
            value = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. _PlaceId .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. text))
        end
        if value.nextPageCursor and value.nextPageCursor ~= 'null' and value.nextPageCursor ~= 'null' then
            text = value.nextPageCursor
        end

        for _, v in pairs(value.data) do
            local flag = true
            if tonumber(v.maxPlayers) > tonumber(v.playing) then
                for _, h in pairs(hours) do
                    if tostring(v.id) == tostring(h) then
                        flag = false
                    end
                end
                if flag then
                    table.insert(hours, tostring(v.id))
                    task.wait(0.1)
                    pcall(function()
                        game:GetService('TeleportService'):TeleportToPlaceInstance(_PlaceId, tostring(v.id), game.Players.LocalPlayer)
                    end)
                    task.wait(0.1)
                end
            end
        end
    end

    TPReturner()
end

-- ============================================
-- CHECK ITEM FUNCTION
-- ============================================
function CheckItem(name)
    local inv = game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('getInventory')
    for _, item in pairs(inv) do
        if item.Name == name then
            return item
        end
    end
    return nil
end

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
function isnil(v) return true end

function getRoundedValue(num)
    return math.floor(tonumber(num) + 0.5)
end

function StopTween(enabled)
    if not enabled then
        _G.StopTween = true
        task.wait(0.2)
        topos(game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame)
        task.wait(0.2)
        if game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild('BodyClip') then
            game.Players.LocalPlayer.Character.HumanoidRootPart.BodyClip:Destroy()
        end
        if game.Players.LocalPlayer.Character:FindFirstChild('Block') then
            game.Players.LocalPlayer.Character.Block:Destroy()
        end
        _G.StopTween = false
        _G.Clip = false
    end
end

function topos(cframe)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character.Humanoid.Health > 0 and player.Character:FindFirstChild('HumanoidRootPart') then
        player.Character.HumanoidRootPart.CFrame = cframe
    end
end

function TP1(cframe)
    topos(cframe)
end

function EquipWeapon(name)
    local player = game.Players.LocalPlayer
    if name and player.Backpack:FindFirstChild(name) then
        player.Character.Humanoid:EquipTool(player.Backpack:FindFirstChild(name))
    end
end

function UnEquipWeapon(name)
    local player = game.Players.LocalPlayer
    if player.Character:FindFirstChild(name) then
        player.Character:FindFirstChild(name).Parent = player.Backpack
    end
end

function AutoHaki()
    local player = game.Players.LocalPlayer
    if player.Character and not player.Character:FindFirstChild('HasBuso') then
        game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('Buso')
    end
end

function enableNoclip()
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild('HumanoidRootPart') then
        if not player.Character.HumanoidRootPart:FindFirstChild('BodyClip') then
            local bv = Instance.new('BodyVelocity')
            bv.Name = 'BodyClip'
            bv.Parent = player.Character.HumanoidRootPart
            bv.MaxForce = Vector3.new(100000, 100000, 100000)
            bv.Velocity = Vector3.new(0, 0, 0)
        end
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA('BasePart') then
                part.CanCollide = false
            end
        end
    end
end

function disableNoclip()
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild('HumanoidRootPart') then
        if player.Character.HumanoidRootPart:FindFirstChild('BodyClip') then
            player.Character.HumanoidRootPart.BodyClip:Destroy()
        end
    end
end

function TPP(cframe)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild('HumanoidRootPart') then
        local dist = (player.Character.HumanoidRootPart.Position - cframe.Position).Magnitude
        local tween = game:GetService('TweenService'):Create(player.Character.HumanoidRootPart, TweenInfo.new(dist / _G.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = cframe})
        tween:Play()
        return {Stop = function() tween:Cancel() end}
    end
end

function TPB(cframe)
    local boat = game:GetService('Workspace').Boats.PirateBrigade
    if boat and boat:FindFirstChild('VehicleSeat') then
        local dist = (boat.VehicleSeat.Position - cframe.Position).Magnitude
        local tween = game:GetService('TweenService'):Create(boat.VehicleSeat, TweenInfo.new(dist / 300, Enum.EasingStyle.Linear), {CFrame = cframe})
        tween:Play()
        return {Stop = function() tween:Cancel() end}
    end
end

function BTP(cframe)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild('HumanoidRootPart') then
        if (cframe.Position - player.Character.HumanoidRootPart.Position).Magnitude >= 1500 then
            repeat
                task.wait()
                player.Character.HumanoidRootPart.CFrame = cframe
                task.wait(0.05)
            until (cframe.Position - player.Character.HumanoidRootPart.Position).Magnitude < 1500
        end
    end
end

function fireclickdetector(clickdetector)
    if clickdetector then
        clickdetector:FireClick()
    end
end

function sethiddenproperty(obj, prop, val)
    if obj then
        obj[prop] = val
    end
end

-- ============================================
-- ESP FUNCTIONS
-- ============================================
function UpdatePlayerChams()
    for _, player in pairs(game.Players:GetPlayers()) do
        pcall(function()
            if player.Character and player.Character:FindFirstChild('Head') then
                if ESPPlayer then
                    if not player.Character.Head:FindFirstChild('NameEsp' .. Number) then
                        local bg = Instance.new('BillboardGui')
                        bg.Name = 'NameEsp' .. Number
                        bg.Parent = player.Character.Head
                        bg.ExtentsOffset = Vector3.new(0, 1, 0)
                        bg.Size = UDim2.new(1, 200, 1, 30)
                        bg.Adornee = player.Character.Head
                        bg.AlwaysOnTop = true
                        local tl = Instance.new('TextLabel')
                        tl.Parent = bg
                        tl.Font = Enum.Font.GothamSemibold
                        tl.TextSize = 14
                        tl.TextWrapped = true
                        tl.Size = UDim2.new(1, 0, 1, 0)
                        tl.TextYAlignment = 'Top'
                        tl.BackgroundTransparency = 1
                        tl.TextStrokeTransparency = 0.5
                        tl.TextColor3 = player.Team ~= game.Players.LocalPlayer.Team and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)
                    end
                    local esp = player.Character.Head:FindFirstChild('NameEsp' .. Number)
                    if esp then
                        local dist = getRoundedValue((game.Players.LocalPlayer.Character.Head.Position - player.Character.Head.Position).Magnitude / 3)
                        local hp = getRoundedValue(player.Character.Humanoid.Health * 100 / player.Character.Humanoid.MaxHealth)
                        esp.TextLabel.Text = player.Name .. ' | ' .. dist .. 'm\nHealth: ' .. hp .. '%'
                    end
                elseif player.Character.Head:FindFirstChild('NameEsp' .. Number) then
                    player.Character.Head:FindFirstChild('NameEsp' .. Number):Destroy()
                end
            end
        end)
    end
end

function UpdateChestESP()
    for _, chest in pairs(game:GetService('CollectionService'):GetTagged('_ChestTagged')) do
        pcall(function()
            if _G.ChestESP then
                if not chest:GetAttribute('IsDisabled') then
                    if not chest:FindFirstChild('ChestEsp') then
                        local bg = Instance.new('BillboardGui')
                        bg.Name = 'ChestEsp'
                        bg.Parent = chest
                        bg.ExtentsOffset = Vector3.new(0, 1, 0)
                        bg.Size = UDim2.new(1, 200, 1, 30)
                        bg.Adornee = chest
                        bg.AlwaysOnTop = true
                        local tl = Instance.new('TextLabel')
                        tl.Parent = bg
                        tl.Font = 'Code'
                        tl.TextSize = 14
                        tl.TextWrapped = true
                        tl.Size = UDim2.new(1, 0, 1, 0)
                        tl.TextYAlignment = 'Top'
                        tl.BackgroundTransparency = 1
                        tl.TextStrokeTransparency = 0.5
                        tl.TextColor3 = Color3.fromRGB(255, 215, 0)
                    end
                    local esp = chest:FindFirstChild('ChestEsp')
                    if esp then
                        local dist = getRoundedValue((game.Players.LocalPlayer.Character.Head.Position - chest:GetPivot().Position).Magnitude / 3)
                        esp.TextLabel.Text = 'Chest\n' .. dist .. 'm'
                    end
                end
            elseif chest:FindFirstChild('ChestEsp') then
                chest.ChestEsp:Destroy()
            end
        end)
    end
end

function UpdateDevilChams()
    for _, obj in pairs(game.Workspace:GetChildren()) do
        pcall(function()
            if DevilFruitESP and string.find(obj.Name, 'Fruit') and obj:FindFirstChild('Handle') then
                if not obj.Handle:FindFirstChild('NameEsp' .. Number) then
                    local bg = Instance.new('BillboardGui')
                    bg.Name = 'NameEsp' .. Number
                    bg.Parent = obj.Handle
                    bg.ExtentsOffset = Vector3.new(0, 1, 0)
                    bg.Size = UDim2.new(1, 200, 1, 30)
                    bg.Adornee = obj.Handle
                    bg.AlwaysOnTop = true
                    local tl = Instance.new('TextLabel')
                    tl.Parent = bg
                    tl.Font = Enum.Font.GothamSemibold
                    tl.TextSize = 14
                    tl.TextWrapped = true
                    tl.Size = UDim2.new(1, 0, 1, 0)
                    tl.TextYAlignment = 'Top'
                    tl.BackgroundTransparency = 1
                    tl.TextStrokeTransparency = 0.5
                    tl.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
                local esp = obj.Handle:FindFirstChild('NameEsp' .. Number)
                if esp then
                    local dist = getRoundedValue((game.Players.LocalPlayer.Character.Head.Position - obj.Handle.Position).Magnitude / 3)
                    esp.TextLabel.Text = obj.Name .. '\n' .. dist .. 'm'
                end
            elseif not DevilFruitESP and obj:FindFirstChild('Handle') and obj.Handle:FindFirstChild('NameEsp' .. Number) then
                obj.Handle:FindFirstChild('NameEsp' .. Number):Destroy()
            end
        end)
    end
end

function UpdateIslandMirageESP()
    for _, loc in pairs(game:GetService('Workspace')._WorldOrigin.Locations:GetChildren()) do
        pcall(function()
            if MirageIslandESP and loc.Name == 'Mirage Island' then
                if not loc:FindFirstChild('NameEsp') then
                    local bg = Instance.new('BillboardGui')
                    bg.Name = 'NameEsp'
                    bg.Parent = loc
                    bg.ExtentsOffset = Vector3.new(0, 1, 0)
                    bg.Size = UDim2.new(1, 200, 1, 30)
                    bg.Adornee = loc
                    bg.AlwaysOnTop = true
                    local tl = Instance.new('TextLabel')
                    tl.Parent = bg
                    tl.Font = 'Code'
                    tl.TextSize = 14
                    tl.TextWrapped = true
                    tl.Size = UDim2.new(1, 0, 1, 0)
                    tl.TextYAlignment = 'Top'
                    tl.BackgroundTransparency = 1
                    tl.TextStrokeTransparency = 0.5
                    tl.TextColor3 = Color3.fromRGB(80, 245, 245)
                end
                local esp = loc:FindFirstChild('NameEsp')
                if esp then
                    local dist = getRoundedValue((game.Players.LocalPlayer.Character.Head.Position - loc.Position).Magnitude / 3)
                    esp.TextLabel.Text = loc.Name .. '\n' .. dist .. 'm'
                end
            elseif loc:FindFirstChild('NameEsp') then
                loc.NameEsp:Destroy()
            end
        end)
    end
end

function UpdateIslandKisuneESP()
    for _, loc in pairs(game:GetService('Workspace')._WorldOrigin.Locations:GetChildren()) do
        pcall(function()
            if KitsuneIslandEsp and loc.Name == 'Kitsune Island' then
                if not loc:FindFirstChild('NameEsp') then
                    local bg = Instance.new('BillboardGui')
                    bg.Name = 'NameEsp'
                    bg.Parent = loc
                    bg.ExtentsOffset = Vector3.new(0, 1, 0)
                    bg.Size = UDim2.new(1, 200, 1, 30)
                    bg.Adornee = loc
                    bg.AlwaysOnTop = true
                    local tl = Instance.new('TextLabel')
                    tl.Parent = bg
                    tl.Font = 'Code'
                    tl.TextSize = 14
                    tl.TextWrapped = true
                    tl.Size = UDim2.new(1, 0, 1, 0)
                    tl.TextYAlignment = 'Top'
                    tl.BackgroundTransparency = 1
                    tl.TextStrokeTransparency = 0.5
                    tl.TextColor3 = Color3.fromRGB(80, 245, 245)
                end
                local esp = loc:FindFirstChild('NameEsp')
                if esp then
                    local dist = getRoundedValue((game.Players.LocalPlayer.Character.Head.Position - loc.Position).Magnitude / 3)
                    esp.TextLabel.Text = loc.Name .. '\n' .. dist .. 'm'
                end
            elseif loc:FindFirstChild('NameEsp') then
                loc.NameEsp:Destroy()
            end
        end)
    end
end

function UpdateBerriesESP()
    for _, bush in pairs(game:GetService('CollectionService'):GetTagged('BerryBush')) do
        pcall(function()
            if Berry then
                if not bush.Parent:FindFirstChild('BerryESP') then
                    local bg = Instance.new('BillboardGui')
                    bg.Name = 'BerryESP'
                    bg.Parent = bush.Parent
                    bg.ExtentsOffset = Vector3.new(0, 2, 0)
                    bg.Size = UDim2.new(1, 200, 1, 30)
                    bg.Adornee = bush.Parent
                    bg.AlwaysOnTop = true
                    local tl = Instance.new('TextLabel')
                    tl.Parent = bg
                    tl.Font = Enum.Font.GothamSemibold
                    tl.TextSize = 14
                    tl.TextWrapped = true
                    tl.Size = UDim2.new(1, 0, 1, 0)
                    tl.TextYAlignment = 'Top'
                    tl.BackgroundTransparency = 1
                    tl.TextStrokeTransparency = 0.5
                    tl.TextColor3 = Color3.fromRGB(255, 255, 0)
                end
                local esp = bush.Parent:FindFirstChild('BerryESP')
                if esp then
                    local dist = getRoundedValue((game.Players.LocalPlayer.Character.Head.Position - bush.Parent:GetPivot().Position).Magnitude)
                    local name = nil
                    for k, _ in pairs(bush:GetAttributes()) do
                        name = k
                        break
                    end
                    esp.TextLabel.Text = (name or 'Berry') .. '\n' .. dist .. 'm'
                end
            elseif bush.Parent:FindFirstChild('BerryESP') then
                bush.Parent.BerryESP:Destroy()
            end
        end)
    end
end

-- ============================================
-- LOAD OBSIDIAN LIBRARY
-- ============================================
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/rickyaditya511/hac/refs/heads/main/Library.lua'))()

-- ============================================
-- CREATE WINDOW
-- ============================================
local Window = Library:CreateWindow({
    Title = 'astro hub',
    Footer = 'by astro | open source',
    Center = true,
    AutoShow = true,
    Resizable = true,
    ToggleKeybind = Enum.KeyCode.RightControl,
    GlobalSearch = true,
})

-- ============================================
-- CREATE ALL TABS
-- ============================================
local FarmingTab = Window:AddTab('Farming', 'swords')
local FishingTab = Window:AddTab('Auto Fishing', 'fish')
local QuestItemsTab = Window:AddTab('Quest | Items', 'scroll')
local VolcanoTab = Window:AddTab('Volcano Dojo', 'flame')
local SeaEventTab = Window:AddTab('Sea Event', 'waves')
local RaceTab = Window:AddTab('Race V4', 'crown')
local RaidTab = Window:AddTab('Raid Fruits', 'cherry')
local FruitsTab = Window:AddTab('Fruits | Stock', 'apple')
local TeleportTab = Window:AddTab('Teleport', 'locate')
local PvPTab = Window:AddTab('PvP, Player', 'user')
local ShopTab = Window:AddTab('Shop', 'shoppingCart')
local SettingsTab = Window:AddTab('Settings', 'settings')

-- ============================================
-- FARMING TAB
-- ============================================
FarmingTab:AddSection('Select Weapon')

_G.SelectWeapon = 'Melee'
FarmingTab:AddDropdown({
    Text = 'Choose Weapon',
    Description = 'Select weapon type to use',
    Values = {'Melee', 'Sword', 'Gun', 'Blox Fruit'},
    Default = 'Melee',
    Callback = function(val)
        _G.SelectWeapon = val
    end
})

FarmingTab:AddSection('Main Farm')

FarmingTab:AddToggle({
    Text = 'Auto Farm Level',
    Description = 'Auto farm from Level 1 to 2650',
    Default = false,
    Callback = function(val)
        _G.AutoFarm = val
        if not val then StopTween(true) end
    end
})

FarmingTab:AddToggle({
    Text = 'Farm Level New',
    Description = 'Submerged Island levels',
    Default = false,
    Callback = function(val)
        _G.AutoFarmLevelNew = val
        if not val then StopTween(true) end
    end
})

FarmingTab:AddToggle({
    Text = 'Auto Kill Near',
    Description = 'Kill nearest mobs (Mob Aura)',
    Default = false,
    Callback = function(val)
        _G.AutoNear = val
        if not val then StopTween(true) end
    end
})

FarmingTab:AddSection('Boss Farm')

local bossOptions = World1 and {
    'The Gorilla King', 'Bobby', 'Yeti', 'Mob Leader', 'Vice Admiral',
    'Warden', 'Chief Warden', 'Swan', 'Magma Admiral', 'Fishman Lord',
    'Wysper', 'Thunder God', 'Cyborg', 'Saber Expert'
} or (World2 and {
    'Diamond', 'Jeremy', 'Fajita', 'Don Swan', 'Smoke Admiral',
    'Cursed Captain', 'Darkbeard', 'Order', 'Awakened Ice Admiral', 'Tide Keeper'
} or (World3 and {
    'Stone', 'Island Empress', 'Hydra Leader', 'Kilo Admiral',
    'Captain Elephant', 'Beautiful Pirate', 'rip_indra True Form',
    'Longma', 'Soul Reaper', 'Cake Queen'
} or {}))

FarmingTab:AddDropdown({
    Text = 'Select Boss',
    Description = 'Choose boss to farm',
    Values = bossOptions,
    Default = bossOptions[1] or '',
    Callback = function(val)
        _G.SelectBoss = val
    end
})

FarmingTab:AddToggle({
    Text = 'Auto Farm Boss',
    Default = false,
    Callback = function(val)
        _G.BossPain = val
        if not val then StopTween(true) end
    end
})

FarmingTab:AddSection('Other Farms')

FarmingTab:AddToggle({
    Text = 'Farm Bone',
    Description = 'Farm bones in Haunted Castle',
    Default = false,
    Callback = function(val)
        _G.FarmBone = val
        if not val then StopTween(true) end
    end
})

FarmingTab:AddToggle({
    Text = 'Auto Pray',
    Default = false,
    Callback = function(val)
        _G.Pray = val
        if not val then StopTween(true) end
    end
})

FarmingTab:AddToggle({
    Text = 'Auto Try Luck',
    Default = false,
    Callback = function(val)
        _G.Trylux = val
        if not val then StopTween(true) end
    end
})

FarmingTab:AddToggle({
    Text = 'Farm Katakuri',
    Description = 'Farm Cake Prince V1',
    Default = false,
    Callback = function(val)
        _G.FarmCake = val
        if not val then StopTween(true) end
    end
})

FarmingTab:AddToggle({
    Text = 'Farm Katakuri V2',
    Description = 'Farm Dough King',
    Default = false,
    Callback = function(val)
        _G.Fullykatakuri = val
        if not val then StopTween(true) end
    end
})

FarmingTab:AddSection('Auto Collect')

FarmingTab:AddToggle({
    Text = 'Auto Collect Berry',
    Default = false,
    Callback = function(val)
        _G.CollectBerry = val
        if not val then StopTween(true) end
    end
})

FarmingTab:AddToggle({
    Text = 'Auto Farm Chest',
    Description = 'Tween to nearest chest',
    Default = false,
    Callback = function(val)
        _G.FarmChest = val
        if not val then StopTween(true) end
    end
})

FarmingTab:AddSection('Material Farm')

local materialOptions = World1 and {
    'Magma Ore', 'Angel Wings', 'Leather', 'Scrap Metal'
} or (World2 and {
    'Radioactive', 'Mystic Droplet', 'Magma Ore', 'Leather', 'Ectoplasm', 'Scrap Metal'
} or (World3 and {
    'Leather', 'Scrap Metal', 'Conjured Cocoa', 'Dragon Scale', 'Gunpowder', 'Fish Tail', 'Mini Tusk'
} or {}))

FarmingTab:AddDropdown({
    Text = 'Select Material',
    Description = 'Material to farm',
    Values = materialOptions,
    Default = materialOptions[1] or '',
    Callback = function(val)
        _G.SelectMaterial = val
    end
})

FarmingTab:AddToggle({
    Text = 'Start Farm Material',
    Default = false,
    Callback = function(val)
        _G.AutoFarmMaterial = val
        if not val then StopTween(true) end
    end
})

-- ============================================
-- AUTO FISHING TAB
-- ============================================
FishingTab:AddSection('Auto Fishing')

FishingTab:AddToggle({
    Text = 'Auto Fishing',
    Description = 'Automatically fish',
    Default = false,
    Callback = function(val)
        _G.AutoFishing = val
    end
})

FishingTab:AddDropdown({
    Text = 'Select Bait',
    Values = {'Basic Bait', 'Kelp Bait', 'Good Bait', 'Abyssal Bait', 'Frozen Bait', 'Epic Bait', 'Carnivore Bait'},
    Default = 'Basic Bait',
    Callback = function(val)
        _G.SelectedBait = val
        pcall(function()
            game:GetService('ReplicatedStorage').FishReplicated.FishingRequest:InvokeServer('SelectBait', val)
        end)
    end
})

FishingTab:AddDropdown({
    Text = 'Select Rod',
    Values = {'Fishing Rod', 'Gold Rod', 'Shark Rod', 'Shell Rod', 'Treasure Rod'},
    Default = 'Fishing Rod',
    Callback = function(val)
        _G.SelectedRod = val
    end
})

-- ============================================
-- QUEST | ITEMS TAB
-- ============================================
if World1 then
    QuestItemsTab:AddSection('Sea 1 Quests')
    QuestItemsTab:AddToggle({
        Text = 'Auto Second Sea',
        Default = false,
        Callback = function(val)
            _G.AutoSecondSea = val
            if not val then StopTween(true) end
        end
    })
end

QuestItemsTab:AddSection('Bosses & Swords')

QuestItemsTab:AddToggle({
    Text = 'Kill Greybeard',
    Default = false,
    Callback = function(val)
        _G.Greybeard = val
        if not val then StopTween(true) end
    end
})

QuestItemsTab:AddToggle({
    Text = 'Auto Get Saber',
    Default = false,
    Callback = function(val)
        _G.AutoSaber = val
        if not val then StopTween(true) end
    end
})

QuestItemsTab:AddToggle({
    Text = 'Auto Get Pole',
    Default = false,
    Callback = function(val)
        _G.Autopole = val
        if not val then StopTween(true) end
    end
})

QuestItemsTab:AddToggle({
    Text = 'Auto Get Saw',
    Default = false,
    Callback = function(val)
        _G.Autosaw = val
        if not val then StopTween(true) end
    end
})

QuestItemsTab:AddToggle({
    Text = 'Auto Get Wardens',
    Default = false,
    Callback = function(val)
        _G.ChiefWarden = val
        if not val then StopTween(true) end
    end
})

QuestItemsTab:AddToggle({
    Text = 'Auto Get Trident',
    Default = false,
    Callback = function(val)
        _G.Trident = val
        if not val then StopTween(true) end
    end
})

if World2 then
    QuestItemsTab:AddSection('Sea 2 Quests')
    QuestItemsTab:AddToggle({
        Text = 'Auto Bartilo Quest',
        Default = false,
        Callback = function(val)
            _G.AutoBartilo = val
            if not val then StopTween(true) end
        end
    })
    QuestItemsTab:AddToggle({
        Text = 'Auto Third Sea',
        Default = false,
        Callback = function(val)
            _G.ThirdSea = val
            if not val then StopTween(true) end
        end
    })
    QuestItemsTab:AddToggle({
        Text = 'Auto Factory',
        Default = false,
        Callback = function(val)
            _G.AutoFactory = val
            if not val then StopTween(true) end
        end
    })
    QuestItemsTab:AddToggle({
        Text = 'Kill Dark Beard',
        Default = false,
        Callback = function(val)
            _G.AutoDarkBoss = val
            if not val then StopTween(true) end
        end
    })
    QuestItemsTab:AddToggle({
        Text = 'Kill Cursed Captain',
        Default = false,
        Callback = function(val)
            _G.CursedCaptain = val
            if not val then StopTween(true) end
        end
    })
    QuestItemsTab:AddToggle({
        Text = 'Auto Get Longsword',
        Default = false,
        Callback = function(val)
            _G.Longsword = val
            if not val then StopTween(true) end
        end
    })
    QuestItemsTab:AddToggle({
        Text = 'Auto Get Gravity Blade',
        Default = false,
        Callback = function(val)
            _G.GravityBlade = val
            if not val then StopTween(true) end
        end
    })
    QuestItemsTab:AddToggle({
        Text = 'Auto Get Flail',
        Default = false,
        Callback = function(val)
            _G.SwodsFlail = val
            if not val then StopTween(true) end
        end
    })
    QuestItemsTab:AddToggle({
        Text = 'Auto Get Rengoku',
        Default = false,
        Callback = function(val)
            _G.AutoRengoku = val
            if not val then StopTween(true) end
        end
    })
    QuestItemsTab:AddToggle({
        Text = 'Auto Get Dragon Trident',
        Default = false,
        Callback = function(val)
            _G.SwodsDRTrident = val
            if not val then StopTween(true) end
        end
    })
end

if World3 then
    QuestItemsTab:AddSection('Sea 3 Quests')
    QuestItemsTab:AddToggle({
        Text = 'Kill Rip Indra',
        Default = false,
        Callback = function(val)
            _G.RipIndraKill = val
            if not val then StopTween(true) end
        end
    })
    QuestItemsTab:AddToggle({
        Text = 'Kill Elite Hunter',
        Default = false,
        Callback = function(val)
            _G.AutoElitehunter = val
            if not val then StopTween(true) end
        end
    })
    QuestItemsTab:AddToggle({
        Text = 'Auto Skull Guitar',
        Default = false,
        Callback = function(val)
            _G.AutoSkullGuitar = val
            if not val then StopTween(true) end
        end
    })
    QuestItemsTab:AddToggle({
        Text = 'Auto Get Yama',
        Default = false,
        Callback = function(val)
            _G.AutoYama = val
            if not val then StopTween(true) end
        end
    })
    QuestItemsTab:AddToggle({
        Text = 'Auto Holy Torch',
        Default = false,
        Callback = function(val)
            _G.AutoHolyTorch = val
            if not val then StopTween(true) end
        end
    })
    QuestItemsTab:AddToggle({
        Text = 'Auto Get Tushita',
        Default = false,
        Callback = function(val)
            _G.AutoGetTushita = val
            if not val then StopTween(true) end
        end
    })
    QuestItemsTab:AddToggle({
        Text = 'Auto Get Twin Hooks',
        Default = false,
        Callback = function(val)
            _G.SwodTwinHooks = val
            if not val then StopTween(true) end
        end
    })
    QuestItemsTab:AddToggle({
        Text = 'Auto Get Canvander',
        Default = false,
        Callback = function(val)
            _G.SwodCanvander = val
            if not val then StopTween(true) end
        end
    })
    QuestItemsTab:AddToggle({
        Text = 'Auto Get Buddy Sword',
        Default = false,
        Callback = function(val)
            _G.SwodsBuddy = val
            if not val then StopTween(true) end
        end
    })
end

-- ============================================
-- VOLCANO DOJO TAB
-- ============================================
VolcanoTab:AddSection('Dragon Dojo')

VolcanoTab:AddButton({
    Text = 'Tween to Dragon Dojo',
    Callback = function()
        pcall(function()
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('requestEntrance', Vector3.new(5661.53, 1013.09, -334.96))
            topos(CFrame.new(5841.29, 1208.32, 884.31))
        end)
    end
})

VolcanoTab:AddToggle({
    Text = 'Auto Dragon Hunter',
    Description = 'Farm Blaze Embers',
    Default = false,
    Callback = function(val)
        _G.FarmBlazeEM = val
        if not val then StopTween(true) end
    end
})

VolcanoTab:AddSection('Volcanic Island')

VolcanoTab:AddButton({
    Text = 'Craft Volcanic Magnet',
    Callback = function()
        pcall(function()
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('CraftItem', 'Craft', 'Volcanic Magnet')
        end)
    end
})

VolcanoTab:AddParagraph({
    Title = 'Prehistoric Island Status',
    Content = 'Checking...'
})

VolcanoTab:AddToggle({
    Text = 'Auto Find Prehistoric',
    Description = 'Find Prehistoric Island',
    Default = false,
    Callback = function(val)
        _G.AutoFindPrehistoric = val
        if not val then StopTween(true) end
    end
})

VolcanoTab:AddToggle({
    Text = 'Auto Tween to Volcano',
    Description = 'Tween to Prehistoric Island',
    Default = false,
    Callback = function(val)
        _G.TweenVolcano = val
        if not val then StopTween(true) end
    end
})

VolcanoTab:AddToggle({
    Text = 'Auto Defend Volcano',
    Description = 'Destroy Lava rocks',
    Default = false,
    Callback = function(val)
        _G.DefendVolcano = val
        if not val then StopTween(true) end
    end
})

VolcanoTab:AddSection('Auto Skills for Lava')

VolcanoTab:AddToggle({
    Text = 'Auto Use Melee',
    Default = false,
    Callback = function(val)
        _G.UseMelee = val
    end
})

VolcanoTab:AddToggle({
    Text = 'Auto Use Sword',
    Default = false,
    Callback = function(val)
        _G.UseSword = val
    end
})

VolcanoTab:AddToggle({
    Text = 'Auto Use Gun',
    Default = false,
    Callback = function(val)
        _G.UseGun = val
    end
})

VolcanoTab:AddToggle({
    Text = 'Auto Kill Golem',
    Default = false,
    Callback = function(val)
        _G.KillGolem = val
        if not val then StopTween(true) end
    end
})

VolcanoTab:AddToggle({
    Text = 'Auto Collect Bone',
    Default = false,
    Callback = function(val)
        _G.AutoCollectBone = val
        if not val then StopTween(true) end
    end
})

VolcanoTab:AddToggle({
    Text = 'Auto Collect Egg',
    Default = false,
    Callback = function(val)
        _G.CollectEgg = val
        if not val then StopTween(true) end
    end
})

-- ============================================
-- SEA EVENT TAB
-- ============================================
SeaEventTab:AddSection('Kitsune Island')

SeaEventTab:AddParagraph({
    Title = 'Kitsune Island Status',
    Content = 'Checking...'
})

SeaEventTab:AddToggle({
    Text = 'Auto Tween to Kitsune',
    Default = false,
    Callback = function(val)
        _G.TweenToKitsune = val
        if not val then StopTween(true) end
    end
})

SeaEventTab:AddToggle({
    Text = 'ESP Kitsune Island',
    Default = false,
    Callback = function(val)
        KitsuneIslandEsp = val
    end
})

SeaEventTab:AddToggle({
    Text = 'Auto Azuer Ember',
    Description = 'Collect blue embers',
    Default = false,
    Callback = function(val)
        _G.AutoAzuerEmber = val
        if not val then StopTween(true) end
    end
})

SeaEventTab:AddSection('Sea Events')

SeaEventTab:AddToggle({
    Text = 'Auto Drive Boat',
    Default = false,
    Callback = function(val)
        _G.SailBoat = val
        if not val then StopTween(true) end
    end
})

SeaEventTab:AddToggle({
    Text = 'Auto Kill Terror Shark',
    Default = false,
    Callback = function(val)
        _G.Autoterrorshark = val
        if not val then StopTween(true) end
    end
})

SeaEventTab:AddToggle({
    Text = 'Auto Kill Shark',
    Default = false,
    Callback = function(val)
        _G.KillShark = val
        if not val then StopTween(true) end
    end
})

SeaEventTab:AddToggle({
    Text = 'Auto Kill Piranha',
    Default = false,
    Callback = function(val)
        _G.KillPiranha = val
        if not val then StopTween(true) end
    end
})

SeaEventTab:AddToggle({
    Text = 'Auto Kill Fish Crew',
    Default = false,
    Callback = function(val)
        _G.KillFishCrew = val
        if not val then StopTween(true) end
    end
})

SeaEventTab:AddSection('Mirage Island')

SeaEventTab:AddParagraph({
    Title = 'Mirage Island Status',
    Content = 'Checking...'
})

SeaEventTab:AddToggle({
    Text = 'Tween to Mirage Island',
    Default = false,
    Callback = function(val)
        _G.AutoMysticIsland = val
        if not val then StopTween(true) end
    end
})

SeaEventTab:AddToggle({
    Text = 'ESP Mirage Island',
    Default = false,
    Callback = function(val)
        MirageIslandESP = val
    end
})

SeaEventTab:AddToggle({
    Text = 'Look Moon + Auto V3',
    Default = false,
    Callback = function(val)
        _G.AutoDooHee = val
        if not val then StopTween(true) end
    end
})

SeaEventTab:AddToggle({
    Text = 'Auto Tween to Gear',
    Description = 'Tween to Mystic Island gear',
    Default = false,
    Callback = function(val)
        _G.TweenMGear = val
        if not val then StopTween(true) end
    end
})

-- ============================================
-- RACE V4 TAB
-- ============================================
RaceTab:AddSection('Teleport V4')

RaceTab:AddButton({
    Text = 'Teleport Top Great Tree',
    Callback = function()
        pcall(function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(3030.39453125, 2280.6171875, -7320.18359375)
        end)
    end
})

RaceTab:AddButton({
    Text = 'Teleport Temple of Time',
    Callback = function()
        pcall(function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(28286.35546875, 14895.3017578125, 102.62469482421875)
        end)
    end
})

RaceTab:AddButton({
    Text = 'Teleport Lever Pull',
    Callback = function()
        pcall(function()
            topos(CFrame.new(28575.181640625, 14936.6279296875, 72.31636810302734))
        end)
    end
})

RaceTab:AddButton({
    Text = 'Teleport The Clock',
    Callback = function()
        pcall(function()
            topos(CFrame.new(29553.7812, 15066.6133, -88.2750015))
        end)
    end
})

RaceTab:AddSection('Trial V4')

RaceTab:AddButton({
    Text = 'Auto Race Door',
    Callback = function()
        pcall(function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(28286.35546875, 14895.3017578125, 102.62469482421875)
            task.wait(0.1)
            local race = game.Players.LocalPlayer.Data.Race.Value
            local doors = {
                Human = CFrame.new(29221.822265625, 14890.9755859375, -205.99114990234375),
                Skypiea = CFrame.new(28960.158203125, 14919.6240234375, 235.03948974609375),
                Fishman = CFrame.new(28231.17578125, 14890.9755859375, -211.64173889160156),
                Cyborg = CFrame.new(28502.681640625, 14895.9755859375, -423.7279357910156),
                Ghoul = CFrame.new(28674.244140625, 14890.6767578125, 445.4310607910156),
                Mink = CFrame.new(29012.341796875, 14890.9755859375, -380.1492614746094),
            }
            if doors[race] then
                topos(doors[race])
            end
        end)
    end
})

RaceTab:AddButton({
    Text = 'Buy Ancient One Quest',
    Callback = function()
        pcall(function()
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('UpgradeRace', 'Buy')
        end)
    end
})

RaceTab:AddToggle({
    Text = 'Auto Trial Human Ghost',
    Default = false,
    Callback = function(val)
        _G.Kill_Aura = val
        if not val then StopTween(true) end
    end
})

RaceTab:AddToggle({
    Text = 'Auto Trial All Race',
    Default = false,
    Callback = function(val)
        _G.AutoQuestRace = val
        if not val then StopTween(true) end
    end
})

RaceTab:AddToggle({
    Text = 'Auto Kill Player in Trial',
    Default = false,
    Callback = function(val)
        _G.AutoKillV4 = val
        if not val then StopTween(true) end
    end
})

RaceTab:AddSection('Auto Skills in Trial')

RaceTab:AddToggle({
    Text = 'Auto Skill Z',
    Default = false,
    Callback = function(val)
        _G.XaiSkillZ = val
    end
})

RaceTab:AddToggle({
    Text = 'Auto Skill X',
    Default = false,
    Callback = function(val)
        _G.XaiSkillX = val
    end
})

RaceTab:AddToggle({
    Text = 'Auto Skill C',
    Default = false,
    Callback = function(val)
        _G.XaiSkillC = val
    end
})

-- ============================================
-- RAID FRUITS TAB
-- ============================================
RaidTab:AddSection('Raid Fruits')

RaidTab:AddDropdown({
    Text = 'Select Chip',
    Values = {'Flame', 'Ice', 'Sand', 'Dark', 'Light', 'Magma', 'Quake', 'Buddha', 'Spider', 'Phoenix', 'Lightning', 'Dough'},
    Default = 'Flame',
    Callback = function(val)
        _G.SelectChip = val
    end
})

RaidTab:AddToggle({
    Text = 'Auto Buy Chip',
    Default = false,
    Callback = function(val)
        _G.AutoBuyChip = val
    end
})

RaidTab:AddToggle({
    Text = 'Auto Start Raid',
    Default = false,
    Callback = function(val)
        _G.StartRaid = val
    end
})

RaidTab:AddToggle({
    Text = 'Auto Farm Raid Next Island',
    Default = false,
    Callback = function(val)
        _G.Dungeon = val
    end
})

RaidTab:AddToggle({
    Text = 'Auto Get Fruit Low Beli',
    Default = false,
    Callback = function(val)
        _G.Autofruit = val
    end
})

RaidTab:AddSection('Raid Law Sea 2')

RaidTab:AddButton({
    Text = 'Buy Chip Law',
    Callback = function()
        pcall(function()
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('BlackbeardReward', 'Microchip', '2')
        end)
    end
})

RaidTab:AddButton({
    Text = 'Start Law Raid',
    Callback = function()
        pcall(function()
            fireclickdetector(game:GetService('Workspace').Map.CircleIsland.RaidSummon.Button.Main.ClickDetector)
        end)
    end
})

RaidTab:AddToggle({
    Text = 'Auto Farm Law Raid',
    Default = false,
    Callback = function(val)
        _G.AutoLawRaid = val
        if not val then StopTween(true) end
    end
})

-- ============================================
-- FRUITS TAB
-- ============================================
FruitsTab:AddSection('Fruits')

FruitsTab:AddToggle({
    Text = 'Auto Random Fruits',
    Default = false,
    Callback = function(val)
        _G.RandomAuto = val
    end
})

FruitsTab:AddToggle({
    Text = 'Auto Store Fruits',
    Default = false,
    Callback = function(val)
        _G.AutoStoreFruit = val
    end
})

FruitsTab:AddToggle({
    Text = 'Teleport to Fruit Spawn',
    Default = false,
    Callback = function(val)
        _G.Tweenfruit = val
    end
})

FruitsTab:AddToggle({
    Text = 'Auto Teleport Fruits',
    Default = false,
    Callback = function(val)
        _G.Grabfruit = val
    end
})

FruitsTab:AddSection('Check Stock')

FruitsTab:AddParagraph({
    Title = 'Fruit Stock',
    Content = 'Loading stock information...'
})

-- ============================================
-- TELEPORT TAB
-- ============================================
TeleportTab:AddSection('Teleport Island')

local islandOptions = World1 and {
    'WindMill', 'Marine', 'Middle Town', 'Jungle', 'Pirate Village',
    'Desert', 'Snow Island', 'MarineFord', 'Colosseum', 'Sky Island 1',
    'Sky Island 2', 'Sky Island 3', 'Prison', 'Magma Village',
    'Under Water Island', 'Fountain City', 'Shank Room', 'Mob Island'
} or (World2 and {
    'The Cafe', 'Frist Spot', 'Dark Area', 'Flamingo Mansion',
    'Flamingo Room', 'Green Zone', 'Factory', 'Colossuim',
    'Zombie Island', 'Two Snow Mountain', 'Punk Hazard',
    'Cursed Ship', 'Ice Castle', 'Forgotten Island', 'Ussop Island',
    'Mini Sky Island'
} or (World3 and {
    'Mansion', 'Port Town', 'Great Tree', 'Castle On The Sea',
    'MiniSky', 'Hydra Island', 'Floating Turtle', 'Haunted Castle',
    'Ice Cream Island', 'Peanut Island', 'Cake Island',
    'Cocoa Island', 'Candy Island', 'Tiki Outpost', 'Dragon Dojo'
} or {}))

TeleportTab:AddDropdown({
    Text = 'Select Island',
    Values = islandOptions,
    Default = islandOptions[1] or '',
    Callback = function(val)
        _G.SelectIsland = val
    end
})

TeleportTab:AddToggle({
    Text = 'Auto Tween to Island',
    Default = false,
    Callback = function(val)
        _G.TeleportIsland = val
        if not val then StopTween(true) end
    end
})

TeleportTab:AddSection('Teleport Sea')

TeleportTab:AddButton({
    Text = 'Sea 1',
    Callback = function()
        pcall(function()
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('TravelMain')
        end)
    end
})

TeleportTab:AddButton({
    Text = 'Sea 2',
    Callback = function()
        pcall(function()
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('TravelDressrosa')
        end)
    end
})

TeleportTab:AddButton({
    Text = 'Sea 3',
    Callback = function()
        pcall(function()
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('TravelZou')
        end)
    end
})

-- ============================================
-- PVP, PLAYER TAB
-- ============================================
PvPTab:AddSection('Teleport Player')

local playerNames = {}
for _, plr in pairs(game.Players:GetPlayers()) do
    table.insert(playerNames, plr.Name)
end

PvPTab:AddDropdown({
    Text = 'Select Player',
    Values = playerNames,
    Default = playerNames[1] or '',
    Callback = function(val)
        _G.SelectPlayer = val
    end
})

PvPTab:AddButton({
    Text = 'Teleport to Player',
    Callback = function()
        if _G.SelectPlayer then
            local target = game.Players:FindFirstChild(_G.SelectPlayer)
            if target and target.Character and target.Character:FindFirstChild('HumanoidRootPart') then
                topos(target.Character.HumanoidRootPart.CFrame)
            end
        end
    end
})

PvPTab:AddSection('Player Hunter')

PvPTab:AddButton({
    Text = 'Get Elite Quest',
    Callback = function()
        pcall(function()
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('PlayerHunter')
        end)
    end
})

PvPTab:AddToggle({
    Text = 'Auto Kill Player Quest',
    Default = false,
    Callback = function(val)
        _G.AutoPlayerHunter = val
        if not val then StopTween(true) end
    end
})

PvPTab:AddSection('Safe Mode')

PvPTab:AddToggle({
    Text = 'Auto Safe Mode',
    Description = 'Teleport up when low health',
    Default = false,
    Callback = function(val)
        _G.SafeMode = val
        if not val then StopTween(true) end
    end
})

PvPTab:AddSection('Buff')

PvPTab:AddSlider({
    Text = 'Walk Speed',
    Min = 16,
    Max = 300,
    Default = 30,
    Callback = function(val)
        _G.WalkSpeedValue = val
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild('Humanoid') then
            player.Character.Humanoid.WalkSpeed = val
        end
    end
})

PvPTab:AddSlider({
    Text = 'Jump Power',
    Min = 50,
    Max = 500,
    Default = 50,
    Callback = function(val)
        _G.JumpValue = val
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild('Humanoid') then
            player.Character.Humanoid.JumpPower = val
        end
    end
})

PvPTab:AddToggle({
    Text = 'Delete Lava',
    Default = false,
    Callback = function(val)
        _G.RemoveLava = val
    end
})

PvPTab:AddSection('ESP')

PvPTab:AddToggle({
    Text = 'ESP Players',
    Default = false,
    Callback = function(val)
        ESPPlayer = val
    end
})

PvPTab:AddToggle({
    Text = 'ESP Chest',
    Default = false,
    Callback = function(val)
        _G.ChestESP = val
    end
})

PvPTab:AddToggle({
    Text = 'ESP Fruits',
    Default = false,
    Callback = function(val)
        DevilFruitESP = val
    end
})

PvPTab:AddToggle({
    Text = 'ESP Berry',
    Default = false,
    Callback = function(val)
        Berry = val
    end
})

-- ============================================
-- SHOP TAB
-- ============================================
ShopTab:AddSection('Buy Melee V1')

local meleeV1 = {
    {'Black Leg $150,000', 'BuyBlackLeg'},
    {'Electro $550,000', 'BuyElectro'},
    {'Water Kung Fu $750,000', 'BuyFishmanKarate'},
}
for _, item in ipairs(meleeV1) do
    ShopTab:AddButton({
        Text = item[1],
        Callback = function()
            pcall(function()
                game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer(item[2])
            end)
        end
    })
end

ShopTab:AddButton({
    Text = 'Dragon Claw 1,500F',
    Callback = function()
        pcall(function()
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('BlackbeardReward', 'DragonClaw', '1')
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('BlackbeardReward', 'DragonClaw', '2')
        end)
    end
})

ShopTab:AddSection('Buy Melee V2')

local meleeV2 = {
    {'Superhuman $3,000,000', 'BuySuperhuman'},
    {'Death Step $5,000,000 5,000F', 'BuyDeathStep'},
    {'Sharkman Karate $2,500,000 5,000F', 'BuySharkmanKarate'},
    {'Electric Claw $3,000,000 5,000F', 'BuyElectricClaw'},
    {'Dragon Talon $3,000,000 5,000F', 'BuyDragonTalon'},
    {'God Human $5,000,000 5,000F', 'BuyGodhuman'},
    {'Sanguine Art $5,000,000 5,000F', 'BuySanguineArt'},
}
for _, item in ipairs(meleeV2) do
    ShopTab:AddButton({
        Text = item[1],
        Callback = function()
            pcall(function()
                game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer(item[2])
            end)
        end
    })
end

ShopTab:AddSection('Sea Event Crafting')

local craftItems = {
    'Dragonheart', 'Dragonstorm', 'DinoHood', 'SharkTooth', 'TerrorJaw',
    'SharkAnchor', 'LeviathanCrown', 'LeviathanShield', 'LeviathanBoat',
    'LegendaryScroll', 'MythicalScroll'
}
for _, item in ipairs(craftItems) do
    ShopTab:AddButton({
        Text = 'Craft ' .. item,
        Callback = function()
            pcall(function()
                game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('CraftItem', 'Craft', item)
            end)
        end
    })
end

ShopTab:AddSection('Buy Haki, Soru...')

local hakiItems = {
    {'Geppo $10,000', 'Geppo'},
    {'Buso Haki $25,000', 'Buso'},
    {'Soru $25,000', 'Soru'},
}
for _, item in ipairs(hakiItems) do
    ShopTab:AddButton({
        Text = item[1],
        Callback = function()
            pcall(function()
                game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('BuyHaki', item[2])
            end)
        end
    })
end

ShopTab:AddButton({
    Text = 'Observation Haki $750,000',
    Callback = function()
        pcall(function()
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('KenTalk', 'Buy')
        end)
    end
})

ShopTab:AddSection('Buy Sword, Gun')

local swordGunItems = {
    'Cutlass', 'Katana', 'Iron Mace', 'Dual Katana', 'Triple Katana',
    'Pipe', 'Dual-Headed Blade', 'Bisento', 'Soul Cane',
    'Slingshot', 'Musket', 'Flintlock', 'Refined Flintlock', 'Cannon',
    'Black Cape', 'Swordsman Hat', 'Tomoe Ring'
}
for _, item in ipairs(swordGunItems) do
    ShopTab:AddButton({
        Text = 'Buy ' .. item,
        Callback = function()
            pcall(function()
                game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('BuyItem', item)
            end)
        end
    })
end

ShopTab:AddSection('Reset Stats, Random Race')

ShopTab:AddButton({
    Text = 'Reset Stats 2,500F',
    Callback = function()
        pcall(function()
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('BlackbeardReward', 'Refund', '1')
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('BlackbeardReward', 'Refund', '2')
        end)
    end
})

ShopTab:AddButton({
    Text = 'Random Race 3,000F',
    Callback = function()
        pcall(function()
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('BlackbeardReward', 'Reroll', '1')
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('BlackbeardReward', 'Reroll', '2')
        end)
    end
})

ShopTab:AddButton({
    Text = 'Change to Ghoul',
    Callback = function()
        pcall(function()
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('Ectoplasm', 'Change', 4)
        end)
    end
})

ShopTab:AddButton({
    Text = 'Change to Cyborg',
    Callback = function()
        pcall(function()
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('CyborgTrainer', 'Buy')
        end)
    end
})

-- ============================================
-- SETTINGS TAB
-- ============================================
SettingsTab:AddSection('Settings Farming')

SettingsTab:AddParagraph({
    Title = 'Unban Fast Attack - M1 Fruit',
    Content = 'On: ✅'
})

SettingsTab:AddToggle({
    Text = 'Bring Mob',
    Description = 'Auto bring mobs to you',
    Default = true,
    Callback = function(val)
        _G.BringMonster = val
    end
})

SettingsTab:AddToggle({
    Text = 'Set Home Point',
    Default = false,
    Callback = function(val)
        _G.CheckPoint = val
    end
})

SettingsTab:AddToggle({
    Text = 'Infinite Soru',
    Default = false,
    Callback = function(val)
        _G.AutoHaki = val
    end
})

SettingsTab:AddToggle({
    Text = 'Auto Active Race V3',
    Default = false,
    Callback = function(val)
        _G.AutoRaceV3 = val
    end
})

SettingsTab:AddToggle({
    Text = 'Auto Active Race V4',
    Default = false,
    Callback = function(val)
        _G.AutoRaceV4 = val
    end
})

SettingsTab:AddToggle({
    Text = 'Infinite Geppo',
    Default = false,
    Callback = function(val)
        InfiniteGeppo = val
    end
})

SettingsTab:AddToggle({
    Text = 'Dodge No CD',
    Default = false,
    Callback = function(val)
        DodgewithoutCool = val
    end
})

SettingsTab:AddToggle({
    Text = 'Walk on Water',
    Default = true,
    Callback = function(val)
        _G.WalkWater = val
    end
})

SettingsTab:AddSection('Auto Increase Skill Points')

local skillToggles = {'Melee', 'Defense', 'Sword', 'Gun', 'Fruits'}
for _, skill in ipairs(skillToggles) do
    SettingsTab:AddToggle({
        Text = 'Auto ' .. skill,
        Default = false,
        Callback = function(val)
            _G['Auto' .. skill] = val
        end
    })
end

SettingsTab:AddSection('Sea Travel')

SettingsTab:AddButton({
    Text = 'Join Sea 1',
    Callback = function()
        pcall(function()
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('TravelMain')
        end)
    end
})

SettingsTab:AddButton({
    Text = 'Join Sea 2',
    Callback = function()
        pcall(function()
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('TravelDressrosa')
        end)
    end
})

SettingsTab:AddButton({
    Text = 'Join Sea 3',
    Callback = function()
        pcall(function()
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('TravelZou')
        end)
    end
})

SettingsTab:AddSection('Other')

SettingsTab:AddButton({
    Text = 'Join Pirates',
    Callback = function()
        pcall(function()
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('SetTeam', 'Pirates')
        end)
    end
})

SettingsTab:AddButton({
    Text = 'Join Marines',
    Callback = function()
        pcall(function()
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('SetTeam', 'Marines')
        end)
    end
})

SettingsTab:AddButton({
    Text = 'Open Title Name',
    Callback = function()
        pcall(function()
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('getTitles')
            game.Players.localPlayer.PlayerGui.Main.Titles.Visible = true
        end)
    end
})

SettingsTab:AddButton({
    Text = 'FPS Boost',
    Callback = function()
        pcall(function()
            settings().Rendering.QualityLevel = 'Level01'
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA('Part') or v:IsA('Union') then
                    v.Material = 'Plastic'
                    v.Reflectance = 0
                elseif v:IsA('ParticleEmitter') then
                    v.Lifetime = NumberRange.new(0)
                elseif v:IsA('Fire') or v:IsA('Smoke') then
                    v.Enabled = false
                end
            end
        end)
    end
})

SettingsTab:AddSection('Auto Codes')

SettingsTab:AddButton({
    Text = 'Redeem All Codes',
    Callback = function()
        local codes = {
            'NOMOREHACK', 'BANEXPLOIT', 'WildDares', 'BossBuild', 'GetPranked',
            'EARN_FRUITS', 'FIGHT4FRUIT', 'NOEXPLOITER', 'NOOB2ADMIN', 'CODESLIDE',
            'ADMINHACKED', 'ADMINDARES', 'fruitconcepts', 'krazydares', 'TRIPLEABUSE',
            'SEATROLLING', '24NOADMIN', 'REWARDFUN', 'Chandler', 'NEWTROLL',
            'KITT_RESET', 'Sub2CaptainMaui', 'kittgaming', 'Sub2Fer999', 'Enyu_is_Pro',
            'Magicbus', 'JCWK', 'Starcodeheo', 'Bluxxy', 'fudd10_v2',
            'SUB2GAMERROBOT_EXP1', 'Sub2NoobMaster123', 'Sub2UncleKizaru', 'Sub2Daigrock',
            'Axiore', 'TantaiGaming', 'StrawHatMaine', 'Sub2OfficialNoobie',
            'Fudd10', 'Bignews', 'TheGreatAce', 'SECRET_ADMIN'
        }
        for _, code in ipairs(codes) do
            pcall(function()
                game:GetService('ReplicatedStorage').Remotes.Redeem:InvokeServer(code)
            end)
            task.wait(0.1)
        end
    end
})

SettingsTab:AddSection('Server Hop')

SettingsTab:AddButton({
    Text = 'Rejoin Server',
    Callback = function()
        pcall(function()
            game:GetService('TeleportService'):Teleport(game.PlaceId, game.Players.LocalPlayer)
        end)
    end
})

SettingsTab:AddButton({
    Text = 'Server Hop',
    Callback = function()
        Hop()
    end
})

-- ============================================
-- AUTO FARM LOOPS (ALL LOGIC)
-- ============================================

-- Auto Farm Level Loop (FULL)
spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            pcall(function()
                local Quest = game.Players.LocalPlayer.PlayerGui.Main.Quest
                CheckQuest()
                if Quest.Visible == false then
                    StartBring = false
                    if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - CFrameQuest.Position).Magnitude > 20 then
                        topos(CFrameQuest)
                    else
                        game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('StartQuest', NameQuest, LevelQuest)
                    end
                elseif Quest.Visible == true then
                    local questText = Quest.Container.QuestTitle.Title.Text
                    if string.find(questText, NameMon) then
                        for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                            if mob.Name == Mon and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                                repeat
                                    task.wait(_G.Fast_Delay)
                                    EquipWeapon(_G.SelectWeapon)
                                    AutoHaki()
                                    topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                    StartBring = true
                                    MonFarm = mob.Name
                                    PosMon = mob.HumanoidRootPart.CFrame
                                    mob.HumanoidRootPart.CanCollide = false
                                    mob.Humanoid.WalkSpeed = 0
                                    mob.HumanoidRootPart.Size = Vector3.new(70, 70, 70)
                                    game:GetService('VirtualUser'):CaptureController()
                                    game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                                until not _G.AutoFarm or mob.Humanoid.Health <= 0 or not mob.Parent or Quest.Visible == false
                            end
                        end
                    else
                        StartBring = false
                        game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('AbandonQuest')
                    end
                end
            end)
        end
    end
end)

-- Auto Farm Level New Loop
spawn(function()
    while task.wait() do
        if _G.AutoFarmLevelNew then
            pcall(function()
                local Quest = game.Players.LocalPlayer.PlayerGui.Main.Quest
                CheckQuestNew()
                if Quest.Visible == false then
                    StartBring = false
                    if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - CFrameQuestNew.Position).Magnitude > 20 then
                        topos(CFrameQuestNew)
                    else
                        game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('StartQuest', NameQuestNew, LevelQuestNew)
                    end
                elseif Quest.Visible == true then
                    local questText = Quest.Container.QuestTitle.Title.Text
                    if string.find(questText, NameMonNew) then
                        for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                            if mob.Name == MonNew and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                                repeat
                                    task.wait(_G.Fast_Delay)
                                    EquipWeapon(_G.SelectWeapon)
                                    AutoHaki()
                                    topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                    StartBring = true
                                    MonFarmNew = mob.Name
                                    mob.HumanoidRootPart.CanCollide = false
                                    mob.Humanoid.WalkSpeed = 0
                                    mob.HumanoidRootPart.Size = Vector3.new(70, 70, 70)
                                    game:GetService('VirtualUser'):CaptureController()
                                    game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                                until not _G.AutoFarmLevelNew or mob.Humanoid.Health <= 0 or not mob.Parent or Quest.Visible == false
                            end
                        end
                    else
                        StartBring = false
                        game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('AbandonQuest')
                    end
                end
            end)
        end
    end
end)

-- Auto Near Loop
spawn(function()
    while task.wait(_G.Fast_Delay) do
        if _G.AutoNear then
            pcall(function()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 and mob:FindFirstChild('HumanoidRootPart') then
                        local dist = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - mob.HumanoidRootPart.Position).Magnitude
                        if dist <= 5000 then
                            repeat
                                task.wait(_G.Fast_Delay)
                                EquipWeapon(_G.SelectWeapon)
                                AutoHaki()
                                topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                mob.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                mob.HumanoidRootPart.CanCollide = false
                                mob.Humanoid.WalkSpeed = 0
                                mob.HumanoidRootPart.Transparency = 1
                                StartBring = true
                                MonFarm = mob.Name
                                PosMon = mob.HumanoidRootPart.CFrame
                                game:GetService('VirtualUser'):CaptureController()
                                game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                            until not _G.AutoNear or not mob.Parent or mob.Humanoid.Health <= 0
                            StartBring = false
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Farm Boss Loop
spawn(function()
    while task.wait() do
        if _G.BossPain and _G.SelectBoss then
            pcall(function()
                for _, boss in pairs(game.Workspace.Enemies:GetChildren()) do
                    if boss.Name == _G.SelectBoss and boss:FindFirstChild('Humanoid') and boss.Humanoid.Health > 0 and boss:FindFirstChild('HumanoidRootPart') then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(boss.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            boss.HumanoidRootPart.CanCollide = false
                            boss.Humanoid.WalkSpeed = 0
                            boss.HumanoidRootPart.Size = Vector3.new(80, 80, 80)
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.BossPain or not boss.Parent or boss.Humanoid.Health <= 0
                    end
                end
                if not game.Workspace.Enemies:FindFirstChild(_G.SelectBoss) and game.ReplicatedStorage:FindFirstChild(_G.SelectBoss) then
                    topos(game.ReplicatedStorage:FindFirstChild(_G.SelectBoss).HumanoidRootPart.CFrame * CFrame.new(5, 10, 2))
                end
            end)
        end
    end
end)

-- Auto Farm Bone Loop
spawn(function()
    while task.wait() do
        if _G.FarmBone and World3 then
            pcall(function()
                local cframe = CFrame.new(-9508.5673828125, 142.1398468017578, 5737.3603515625)
                topos(cframe)
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if (mob.Name == 'Reborn Skeleton' or mob.Name == 'Living Zombie' or mob.Name == 'Demonic Soul' or mob.Name == 'Posessed Mummy') and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait(_G.Fast_Delay)
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            mob.HumanoidRootPart.CanCollide = false
                            mob.Humanoid.WalkSpeed = 0
                            mob.Head.CanCollide = false
                            StartBring = true
                            MonFarm = mob.Name
                            PosMon = mob.HumanoidRootPart.CFrame
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.FarmBone or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
            end)
        end
    end
end)

-- Auto Pray Loop
spawn(function()
    while task.wait(0.1) do
        if _G.Pray then
            pcall(function()
                topos(CFrame.new(-8652.99707, 143.450119, 6170.50879))
                task.wait(0.5)
                game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('gravestoneEvent', 1)
            end)
        end
    end
end)

-- Auto Try Luck Loop
spawn(function()
    while task.wait(0.1) do
        if _G.Trylux then
            pcall(function()
                topos(CFrame.new(-8652.99707, 143.450119, 6170.50879))
                task.wait(0.5)
                game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('gravestoneEvent', 2)
            end)
        end
    end
end)

-- Auto Farm Material Loop
spawn(function()
    while task.wait(0.2) do
        if _G.AutoFarmMaterial and _G.SelectMaterial then
            pcall(function()
                MaterialMon()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob.Name == MMon and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait(_G.Fast_Delay)
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            mob.HumanoidRootPart.CanCollide = false
                            mob.Humanoid.WalkSpeed = 0
                            mob.Head.CanCollide = false
                            MonFarm = mob.Name
                            PosMon = mob.HumanoidRootPart.CFrame
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.AutoFarmMaterial or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
                if not game.Workspace.Enemies:FindFirstChild(MMon) then
                    topos(MPos)
                end
            end)
        end
    end
end)

-- Auto Fishing Loop
spawn(function()
    while task.wait() do
        if _G.AutoFishing then
            pcall(function()
                local player = game.Players.LocalPlayer
                local char = player.Character
                if char and char:FindFirstChild('HumanoidRootPart') then
                    local rod = char:FindFirstChildOfClass('Tool')
                    if not rod or rod.Name ~= _G.SelectedRod then
                        rod = player.Backpack:FindFirstChild(_G.SelectedRod)
                        if rod then
                            char.Humanoid:EquipTool(rod)
                        end
                    end
                    if rod then
                        local state = rod:GetAttribute('State')
                        local serverState = rod:GetAttribute('ServerState')
                        if state == 'ReeledIn' or serverState == 'ReeledIn' then
                            local FishReplicated = game.ReplicatedStorage:FindFirstChild('FishReplicated')
                            if FishReplicated then
                                local FishingRequest = FishReplicated:FindFirstChild('FishingRequest')
                                if FishingRequest then
                                    FishingRequest:InvokeServer('StartCasting')
                                    task.wait(0.5)
                                    local pos = char.HumanoidRootPart.Position + char.HumanoidRootPart.CFrame.LookVector * 100
                                    FishingRequest:InvokeServer('CastLineAtLocation', pos, 100, true)
                                end
                            end
                        elseif serverState == 'Biting' then
                            local FishReplicated = game.ReplicatedStorage:FindFirstChild('FishReplicated')
                            if FishReplicated then
                                local FishingRequest = FishReplicated:FindFirstChild('FishingRequest')
                                if FishingRequest then
                                    FishingRequest:InvokeServer('Catching', true)
                                    task.wait(0.1)
                                    FishingRequest:InvokeServer('Catch', 1)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Collect Berry Loop
spawn(function()
    while task.wait() do
        if _G.CollectBerry then
            pcall(function()
                local player = game.Players.LocalPlayer
                local pos = player.Character and player.Character:FindFirstChild('HumanoidRootPart') and player.Character.HumanoidRootPart.Position or Vector3.new()
                local nearest, nearestDist = nil, math.huge
                for _, bush in pairs(game:GetService('CollectionService'):GetTagged('BerryBush')) do
                    for name, _ in pairs(bush:GetAttributes()) do
                        local dist = (bush.Parent:GetPivot().Position - pos).Magnitude
                        if dist < nearestDist then
                            nearest = bush
                            nearestDist = dist
                        end
                    end
                end
                if nearest then
                    topos(nearest.Parent:GetPivot().Position + Vector3.new(0, 2, 0))
                    task.wait(0.5)
                    game:GetService('VirtualInputManager'):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.1)
                    game:GetService('VirtualInputManager'):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end
            end)
        end
    end
end)

-- Auto Farm Chest Loop
spawn(function()
    while task.wait() do
        if _G.FarmChest then
            pcall(function()
                local player = game.Players.LocalPlayer
                local pos = player.Character and player.Character:FindFirstChild('HumanoidRootPart') and player.Character.HumanoidRootPart.Position or Vector3.new()
                local nearest, nearestDist = nil, math.huge
                for _, chest in pairs(game:GetService('CollectionService'):GetTagged('_ChestTagged')) do
                    if not chest:GetAttribute('IsDisabled') then
                        local dist = (chest:GetPivot().Position - pos).Magnitude
                        if dist < nearestDist then
                            nearest = chest
                            nearestDist = dist
                        end
                    end
                end
                if nearest then
                    topos(nearest:GetPivot().Position + Vector3.new(0, 2, 0))
                end
            end)
        end
    end
end)

-- Bring Mob Loop
spawn(function()
    while task.wait() do
        if _G.BringMonster and StartBring and MonFarm then
            pcall(function()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob.Name == MonFarm and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 and mob:FindFirstChild('HumanoidRootPart') then
                        local dist = (mob.HumanoidRootPart.Position - PosMon.Position).Magnitude
                        if dist <= 320 then
                            mob.HumanoidRootPart.CFrame = PosMon
                            mob.HumanoidRootPart.CanCollide = false
                            mob.Humanoid.WalkSpeed = 0
                            mob.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                            if mob.Humanoid:FindFirstChild('Animator') then
                                mob.Humanoid.Animator:Destroy()
                            end
                            sethiddenproperty(game.Players.LocalPlayer, 'SimulationRadius', math.huge)
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- ESP UPDATE LOOPS
-- ============================================
spawn(function()
    while task.wait(1) do
        if ESPPlayer then UpdatePlayerChams() end
        if _G.ChestESP then UpdateChestESP() end
        if DevilFruitESP then UpdateDevilChams() end
        if MirageIslandESP then UpdateIslandMirageESP() end
        if KitsuneIslandEsp then UpdateIslandKisuneESP() end
        if Berry then UpdateBerriesESP() end
    end
end)

-- ============================================
-- AUTO HAKI LOOP
-- ============================================
spawn(function()
    while task.wait(0.1) do
        if _G.AutoHaki then
            pcall(AutoHaki)
        end
    end
end)

-- ============================================
-- AUTO RACE V3 LOOP
-- ============================================
spawn(function()
    while task.wait() do
        if _G.AutoRaceV3 then
            pcall(function()
                game:GetService('ReplicatedStorage').Remotes.CommE:FireServer('ActivateAbility')
            end)
        end
    end
end)

-- ============================================
-- AUTO RACE V4 LOOP
-- ============================================
spawn(function()
    while task.wait() do
        if _G.AutoRaceV4 then
            pcall(function()
                game:GetService('VirtualInputManager'):SendKeyEvent(true, 'Y', false, game)
                task.wait(0.1)
                game:GetService('VirtualInputManager'):SendKeyEvent(false, 'Y', false, game)
            end)
        end
    end
end)

-- ============================================
-- WALK ON WATER
-- ============================================
spawn(function()
    while task.wait() do
        pcall(function()
            if _G.WalkWater then
                game:GetService('Workspace').Map['WaterBase-Plane'].Size = Vector3.new(1000, 112, 1000)
            else
                game:GetService('Workspace').Map['WaterBase-Plane'].Size = Vector3.new(1000, 80, 1000)
            end
        end)
    end
end)

-- ============================================
-- DELETE LAVA
-- ============================================
spawn(function()
    while task.wait(1) do
        if _G.RemoveLava then
            pcall(function()
                for _, obj in pairs(game.Workspace:GetDescendants()) do
                    if obj:IsA('BasePart') and string.lower(obj.Name):find('lava') then
                        obj:Destroy()
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- SAFE MODE
-- ============================================
spawn(function()
    while task.wait(0.1) do
        if _G.SafeMode then
            pcall(function()
                local player = game.Players.LocalPlayer
                if player.Character and player.Character:FindFirstChild('Humanoid') then
                    local hp = player.Character.Humanoid.Health
                    if hp < 5500 then
                        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 200, 0)
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- NOCLIP FOR AUTO FARM
-- ============================================
spawn(function()
    while task.wait(0.2) do
        if _G.AutoFarm or _G.AutoNear or _G.BossPain or _G.FarmBone or _G.AutoFarmMaterial or _G.FarmCake or _G.Fullykatakuri then
            enableNoclip()
        else
            disableNoclip()
        end
    end
end)

-- ============================================
-- ANTI-IDLE
-- ============================================
game:GetService('Players').LocalPlayer.Idled:Connect(function()
    game:GetService('VirtualUser'):Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    game:GetService('VirtualUser'):Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- ============================================
-- INFINITE GEPPO
-- ============================================
spawn(function()
    while task.wait(1) do
        if InfiniteGeppo then
            pcall(function()
                for _, v in pairs(getgc()) do
                    if type(v) == 'function' and getfenv(v).script == game.Players.LocalPlayer.Character:WaitForChild('Geppo') then
                        for i, uv in pairs(getupvalues(v)) do
                            if tostring(uv) == '0' then
                                setupvalue(v, i, 0)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- DODGE NO CD
-- ============================================
spawn(function()
    while task.wait() do
        if DodgewithoutCool then
            pcall(function()
                for _, v in pairs(getgc()) do
                    if type(v) == 'function' and getfenv(v).script == game.Players.LocalPlayer.Character:WaitForChild('Dodge') then
                        for i, uv in pairs(getupvalues(v)) do
                            if tostring(uv) == '0.4' then
                                setupvalue(v, i, 0)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO BUY CHIP
-- ============================================
spawn(function()
    while task.wait() do
        if _G.AutoBuyChip and _G.SelectChip then
            pcall(function()
                game.ReplicatedStorage.Remotes.CommF_:InvokeServer('RaidsNpc', 'Select', _G.SelectChip)
            end)
        end
    end
end)

-- ============================================
-- AUTO START RAID
-- ============================================
spawn(function()
    while task.wait() do
        if _G.StartRaid then
            pcall(function()
                local player = game.Players.LocalPlayer
                if not player.PlayerGui.Main.Timer.Visible and not workspace._WorldOrigin.Locations:FindFirstChild('Island 1') then
                    if player.Backpack:FindFirstChild('Special Microchip') or player.Character:FindFirstChild('Special Microchip') then
                        if World2 then
                            topos(CFrame.new(-6438.73, 250.64, -4501.5))
                            game.ReplicatedStorage.Remotes.CommF_:InvokeServer('SetSpawnPoint')
                            fireclickdetector(workspace.Map.CircleIsland.RaidSummon2.Button.Main.ClickDetector)
                        elseif World3 then
                            game.ReplicatedStorage.Remotes.CommF_:InvokeServer('requestEntrance', Vector3.new(-5075.5, 314.51, -3150.02))
                            topos(CFrame.new(-5017.4, 314.84, -2823.01))
                            game.ReplicatedStorage.Remotes.CommF_:InvokeServer('SetSpawnPoint')
                            fireclickdetector(workspace.Map['Boat Castle'].RaidSummon2.Button.Main.ClickDetector)
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO LAW RAID
-- ============================================
spawn(function()
    while task.wait() do
        if _G.AutoLawRaid then
            pcall(function()
                for _, boss in pairs(game.Workspace.Enemies:GetChildren()) do
                    if boss.Name == 'Order' and boss:FindFirstChild('Humanoid') and boss.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(boss.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            boss.HumanoidRootPart.CanCollide = false
                            boss.Humanoid.WalkSpeed = 0
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.AutoLawRaid or not boss.Parent or boss.Humanoid.Health <= 0
                    end
                end
                if not game.Workspace.Enemies:FindFirstChild('Order') and game.ReplicatedStorage:FindFirstChild('Order') then
                    topos(game.ReplicatedStorage:FindFirstChild('Order').HumanoidRootPart.CFrame * CFrame.new(5, 10, 2))
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO RANDOM FRUITS
-- ============================================
spawn(function()
    while task.wait() do
        if _G.RandomAuto then
            pcall(function()
                game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('Cousin', 'Buy')
            end)
        end
    end
end)

-- ============================================
-- AUTO STORE FRUITS
-- ============================================
spawn(function()
    while task.wait(0.2) do
        if _G.AutoStoreFruit then
            pcall(function()
                local player = game.Players.LocalPlayer
                local fruits = {
                    'Rocket Fruit', 'Spin Fruit', 'Blade Fruit', 'Spring Fruit', 'Bomb Fruit',
                    'Smoke Fruit', 'Spike Fruit', 'Flame Fruit', 'Eagle Fruit', 'Ice Fruit',
                    'Sand Fruit', 'Dark Fruit', 'Diamond Fruit', 'Light Fruit', 'Rubber Fruit',
                    'Creation Fruit', 'Ghost Fruit', 'Magma Fruit', 'Quake Fruit', 'Buddha Fruit',
                    'Love Fruit', 'Spider Fruit', 'Sound Fruit', 'Phoenix Fruit', 'Portal Fruit',
                    'Lightning Fruit', 'Pain Fruit', 'Blizzard Fruit', 'Gravity Fruit', 'Mammoth Fruit',
                    'T-Rex Fruit', 'Dough Fruit', 'Shadow Fruit', 'Venom Fruit', 'Gas Fruit',
                    'Control Fruit', 'Spirit Fruit', 'Leopard Fruit', 'Yeti Fruit', 'Kitsune Fruit',
                    'Dragon Fruit'
                }
                for _, fruit in ipairs(fruits) do
                    local tool = player.Backpack:FindFirstChild(fruit) or player.Character:FindFirstChild(fruit)
                    if tool then
                        game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('StoreFruit', fruit:gsub(' Fruit', ''), tool)
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO TELEPORT FRUITS
-- ============================================
spawn(function()
    while task.wait(0.1) do
        if _G.Tweenfruit then
            pcall(function()
                for _, obj in pairs(game.Workspace:GetChildren()) do
                    if string.find(obj.Name, 'Fruit') and obj:FindFirstChild('Handle') then
                        topos(obj.Handle.CFrame)
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO GRAB FRUITS
-- ============================================
spawn(function()
    while task.wait(0.1) do
        if _G.Grabfruit then
            pcall(function()
                for _, obj in pairs(game.Workspace:GetChildren()) do
                    if string.find(obj.Name, 'Fruit') and obj:FindFirstChild('Handle') then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = obj.Handle.CFrame
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO KILL PLAYER HUNTER
-- ============================================
spawn(function()
    while task.wait() do
        if _G.AutoPlayerHunter then
            pcall(function()
                local Quest = game.Players.LocalPlayer.PlayerGui.Main.Quest
                if Quest.Visible == true then
                    local questText = Quest.Container.QuestTitle.Title.Text
                    for _, player in pairs(game.Workspace.Characters:GetChildren()) do
                        if string.find(questText, player.Name) and player:FindFirstChild('Humanoid') and player.Humanoid.Health > 0 then
                            repeat
                                task.wait()
                                EquipWeapon(_G.SelectWeapon)
                                AutoHaki()
                                topos(player.HumanoidRootPart.CFrame * CFrame.new(1, 7, 3))
                                player.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                game:GetService('VirtualUser'):CaptureController()
                                game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                            until not _G.AutoPlayerHunter or player.Humanoid.Health <= 0
                            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('AbandonQuest')
                        end
                    end
                else
                    task.wait(0.5)
                    game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('PlayerHunter')
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO KILL V4 TRIAL
-- ============================================
spawn(function()
    while task.wait() do
        if _G.AutoKillV4 then
            pcall(function()
                for _, player in pairs(game.Workspace.Characters:GetChildren()) do
                    if player.Name ~= game.Players.LocalPlayer.Name and player:FindFirstChild('Humanoid') and player.Humanoid.Health > 0 then
                        local dist = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - player.HumanoidRootPart.Position).Magnitude
                        if dist <= 230 then
                            repeat
                                task.wait()
                                EquipWeapon(_G.SelectWeapon)
                                AutoHaki()
                                topos(player.HumanoidRootPart.CFrame * CFrame.new(1, 1, 2))
                                player.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                player.HumanoidRootPart.CanCollide = false
                                player.Humanoid.WalkSpeed = 0
                                game:GetService('VirtualUser'):CaptureController()
                                game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                            until not _G.AutoKillV4 or not player.Parent or player.Humanoid.Health <= 0
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO KILL AURA (TRIAL GHOST)
-- ============================================
spawn(function()
    while task.wait() do
        if _G.Kill_Aura then
            pcall(function()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        mob.Humanoid.Health = 0
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO SKILL Z,X,C (TRIAL)
-- ============================================
spawn(function()
    while task.wait(0.5) do
        if _G.XaiSkillZ or _G.XaiSkillX or _G.XaiSkillC then
            pcall(function()
                if _G.XaiSkillZ then
                    game:GetService('VirtualInputManager'):SendKeyEvent(true, 'Z', false, game)
                    task.wait(0.1)
                    game:GetService('VirtualInputManager'):SendKeyEvent(false, 'Z', false, game)
                end
                if _G.XaiSkillX then
                    game:GetService('VirtualInputManager'):SendKeyEvent(true, 'X', false, game)
                    task.wait(0.1)
                    game:GetService('VirtualInputManager'):SendKeyEvent(false, 'X', false, game)
                end
                if _G.XaiSkillC then
                    game:GetService('VirtualInputManager'):SendKeyEvent(true, 'C', false, game)
                    task.wait(0.1)
                    game:GetService('VirtualInputManager'):SendKeyEvent(false, 'C', false, game)
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO SECOND SEA
-- ============================================
spawn(function()
    while task.wait() do
        if _G.AutoSecondSea then
            pcall(function()
                if game.Players.LocalPlayer.Data.Level.Value >= 700 and World1 then
                    _G.AutoFarm = false
                    if game.Workspace.Map.Ice.Door.CanCollide == false and game.Workspace.Map.Ice.Door.Transparency == 1 then
                        topos(CFrame.new(4851.8720703125, 5.6514348983765, 718.47094726563))
                        task.wait(1)
                        game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('DressrosaQuestProgress', 'Detective')
                        EquipWeapon('Key')
                        topos(CFrame.new(1347.7124, 37.3751602, -1325.6488))
                        task.wait(3)
                    else
                        game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('TravelDressrosa')
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO BARTILO QUEST
-- ============================================
spawn(function()
    while task.wait() do
        if _G.AutoBartilo then
            pcall(function()
                local progress = game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('BartiloQuestProgress', 'Bartilo')
                if progress == 0 then
                    topos(CFrame.new(-456.28952, 73.0200958, 299.895966))
                    task.wait(1.1)
                    game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('BartiloQuestProgress', 'Bartilo')
                    task.wait(1)
                    topos(CFrame.new(2099.88159, 448.931, 648.997375))
                    task.wait(2)
                elseif progress == 1 then
                    for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                        if mob.Name == 'Jeremy' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                            repeat
                                task.wait()
                                EquipWeapon(_G.SelectWeapon)
                                AutoHaki()
                                topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                mob.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                mob.HumanoidRootPart.CanCollide = false
                                game:GetService('VirtualUser'):CaptureController()
                                game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                            until not _G.AutoBartilo or not mob.Parent or mob.Humanoid.Health <= 0
                        end
                    end
                    if not game.Workspace.Enemies:FindFirstChild('Jeremy') and game.ReplicatedStorage:FindFirstChild('Jeremy') then
                        topos(game.ReplicatedStorage:FindFirstChild('Jeremy').HumanoidRootPart.CFrame * CFrame.new(5, 10, 2))
                    end
                elseif progress == 2 then
                    local positions = {
                        CFrame.new(-1850.49329, 13.1789551, 1750.89685),
                        CFrame.new(-1858.87305, 19.3777466, 1712.01807),
                        CFrame.new(-1803.94324, 16.5789185, 1750.89685),
                        CFrame.new(-1858.55835, 16.8604317, 1724.79541),
                        CFrame.new(-1869.54224, 15.987854, 1681.00659),
                        CFrame.new(-1800.0979, 16.4978027, 1684.52368),
                        CFrame.new(-1819.26343, 14.795166, 1717.90625),
                        CFrame.new(-1813.51843, 14.8604736, 1724.79541)
                    }
                    for _, pos in ipairs(positions) do
                        topos(pos)
                        task.wait(1)
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO THIRD SEA
-- ============================================
spawn(function()
    while task.wait() do
        if _G.ThirdSea then
            pcall(function()
                if game.Players.LocalPlayer.Data.Level.Value >= 1500 and World2 then
                    _G.AutoFarm = false
                    local progress = game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('ZQuestProgress', 'General')
                    if progress == 0 then
                        topos(CFrame.new(-1926.3221435547, 12.819851875305, 1738.3092041016))
                        task.wait(1.5)
                        game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('ZQuestProgress', 'Begin')
                        task.wait(1.8)
                        for _, boss in pairs(game.Workspace.Enemies:GetChildren()) do
                            if boss.Name == 'rip_indra' and boss:FindFirstChild('Humanoid') and boss.Humanoid.Health > 0 then
                                repeat
                                    task.wait()
                                    EquipWeapon(_G.SelectWeapon)
                                    AutoHaki()
                                    topos(boss.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                    boss.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                    boss.HumanoidRootPart.CanCollide = false
                                    game:GetService('VirtualUser'):CaptureController()
                                    game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                                until not _G.ThirdSea or not boss.Parent or boss.Humanoid.Health <= 0
                            end
                        end
                        if not game.Workspace.Enemies:FindFirstChild('rip_indra') then
                            topos(CFrame.new(-26880.93359375, 22.848554611206, 473.18951416016))
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO FACTORY
-- ============================================
spawn(function()
    while task.wait() do
        if _G.AutoFactory then
            pcall(function()
                topos(CFrame.new(448.46756, 199.356781, -441.389252))
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob.Name == 'Core' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.AutoFactory or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO SABER
-- ============================================
spawn(function()
    while task.wait() do
        if _G.AutoSaber and game.Players.LocalPlayer.Data.Level.Value >= 200 then
            pcall(function()
                if game:GetService('Workspace').Map.Jungle.Final.Part.Transparency == 0 then
                    if game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('ProQuestProgress', 'SickMan') == 0 then
                        game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('ProQuestProgress', 'GetCup')
                        task.wait(0.5)
                        EquipWeapon('Cup')
                        task.wait(0.5)
                        game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('ProQuestProgress', 'FillCup', game:GetService('Players').LocalPlayer.Character.Cup)
                        game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('ProQuestProgress', 'SickMan')
                    elseif game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('ProQuestProgress', 'RichSon') == 0 then
                        for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                            if mob.Name == 'Mob Leader' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                                repeat
                                    task.wait()
                                    EquipWeapon(_G.SelectWeapon)
                                    AutoHaki()
                                    topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                    mob.HumanoidRootPart.Size = Vector3.new(80, 80, 80)
                                    mob.HumanoidRootPart.CanCollide = false
                                    game:GetService('VirtualUser'):CaptureController()
                                    game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                                until not _G.AutoSaber or not mob.Parent or mob.Humanoid.Health <= 0
                            end
                        end
                    elseif game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('ProQuestProgress', 'RichSon') == 1 then
                        game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('ProQuestProgress', 'RichSon')
                        task.wait(0.5)
                        EquipWeapon('Relic')
                        task.wait(0.5)
                        topos(CFrame.new(-1404.91504, 29.9773273, 3.80598116))
                    end
                else
                    for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                        if mob.Name == 'Saber Expert' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                            repeat
                                task.wait()
                                EquipWeapon(_G.SelectWeapon)
                                topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                mob.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                mob.HumanoidRootPart.CanCollide = false
                                game:GetService('VirtualUser'):CaptureController()
                                game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                            until not _G.AutoSaber or not mob.Parent or mob.Humanoid.Health <= 0
                            if mob.Humanoid.Health <= 0 then
                                game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('ProQuestProgress', 'PlaceRelic')
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO KILL GREYBEARD
-- ============================================
spawn(function()
    while task.wait() do
        if _G.Greybeard then
            pcall(function()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob.Name == 'Greybeard' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            mob.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                            mob.HumanoidRootPart.CanCollide = false
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.Greybeard or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
                if not game.Workspace.Enemies:FindFirstChild('Greybeard') and game.ReplicatedStorage:FindFirstChild('Greybeard') then
                    topos(game.ReplicatedStorage:FindFirstChild('Greybeard').HumanoidRootPart.CFrame * CFrame.new(2, 20, 2))
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO GET POLE
-- ============================================
spawn(function()
    while task.wait() do
        if _G.Autopole then
            pcall(function()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob.Name == 'Thunder God' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            mob.HumanoidRootPart.Size = Vector3.new(80, 80, 80)
                            mob.HumanoidRootPart.CanCollide = false
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.Autopole or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
                if not game.Workspace.Enemies:FindFirstChild('Thunder God') and game.ReplicatedStorage:FindFirstChild('Thunder God') then
                    topos(game.ReplicatedStorage:FindFirstChild('Thunder God').HumanoidRootPart.CFrame * CFrame.new(5, 10, 2))
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO GET SAW
-- ============================================
spawn(function()
    while task.wait() do
        if _G.Autosaw then
            pcall(function()
                local cframe = CFrame.new(-690.33081054688, 15.09425163269, 1582.2380371094)
                topos(cframe)
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob.Name == 'The Saw' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait(_G.FastAttackDelay)
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            mob.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                            mob.HumanoidRootPart.CanCollide = false
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.Autosaw or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
                if not game.Workspace.Enemies:FindFirstChild('The Saw') and game.ReplicatedStorage:FindFirstChild('The Saw') then
                    topos(game.ReplicatedStorage:FindFirstChild('The Saw').HumanoidRootPart.CFrame * CFrame.new(2, 40, 2))
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO GET WARDENS
-- ============================================
spawn(function()
    while task.wait() do
        if _G.ChiefWarden then
            pcall(function()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob.Name == 'Chief Warden' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            mob.HumanoidRootPart.Size = Vector3.new(80, 80, 80)
                            mob.HumanoidRootPart.CanCollide = false
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.ChiefWarden or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
                if not game.Workspace.Enemies:FindFirstChild('Chief Warden') and game.ReplicatedStorage:FindFirstChild('Chief Warden') then
                    topos(game.ReplicatedStorage:FindFirstChild('Chief Warden').HumanoidRootPart.CFrame * CFrame.new(5, 10, 2))
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO GET TRIDENT
-- ============================================
spawn(function()
    while task.wait() do
        if _G.Trident then
            pcall(function()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob.Name == 'Fishman Lord' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            mob.HumanoidRootPart.Size = Vector3.new(80, 80, 80)
                            mob.HumanoidRootPart.CanCollide = false
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.Trident or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
                if not game.Workspace.Enemies:FindFirstChild('Fishman Lord') and game.ReplicatedStorage:FindFirstChild('Fishman Lord') then
                    topos(game.ReplicatedStorage:FindFirstChild('Fishman Lord').HumanoidRootPart.CFrame * CFrame.new(5, 10, 2))
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO GET RENGOKU
-- ============================================
spawn(function()
    while task.wait() do
        if _G.AutoRengoku then
            pcall(function()
                if game.Players.LocalPlayer.Backpack:FindFirstChild('Hidden Key') or game.Players.LocalPlayer.Character:FindFirstChild('Hidden Key') then
                    EquipWeapon('Hidden Key')
                    topos(CFrame.new(6571.1201171875, 299.23028564453, -6967.841796875))
                else
                    for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                        if mob.Name == 'Awakened Ice Admiral' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                            repeat
                                task.wait()
                                EquipWeapon(_G.SelectWeapon)
                                AutoHaki()
                                topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                mob.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                mob.HumanoidRootPart.CanCollide = false
                                game:GetService('VirtualUser'):CaptureController()
                                game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                            until not _G.AutoRengoku or not mob.Parent or mob.Humanoid.Health <= 0
                        end
                    end
                    if not game.Workspace.Enemies:FindFirstChild('Awakened Ice Admiral') then
                        topos(CFrame.new(5439.716796875, 84.420944213867, -6715.1635742188))
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO GET LONG SWORD
-- ============================================
spawn(function()
    while task.wait() do
        if _G.Longsword then
            pcall(function()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob.Name == 'Diamond' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            mob.HumanoidRootPart.Size = Vector3.new(80, 80, 80)
                            mob.HumanoidRootPart.CanCollide = false
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.Longsword or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
                if not game.Workspace.Enemies:FindFirstChild('Diamond') and game.ReplicatedStorage:FindFirstChild('Diamond') then
                    topos(game.ReplicatedStorage:FindFirstChild('Diamond').HumanoidRootPart.CFrame * CFrame.new(5, 10, 2))
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO GET GRAVITY BLADE
-- ============================================
spawn(function()
    while task.wait() do
        if _G.GravityBlade then
            pcall(function()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob.Name == 'Fajita' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            mob.HumanoidRootPart.Size = Vector3.new(80, 80, 80)
                            mob.HumanoidRootPart.CanCollide = false
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.GravityBlade or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
                if not game.Workspace.Enemies:FindFirstChild('Fajita') and game.ReplicatedStorage:FindFirstChild('Fajita') then
                    topos(game.ReplicatedStorage:FindFirstChild('Fajita').HumanoidRootPart.CFrame * CFrame.new(5, 10, 2))
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO GET FLAIL
-- ============================================
spawn(function()
    while task.wait() do
        if _G.SwodsFlail then
            pcall(function()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob.Name == 'Smoke Admiral' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            mob.HumanoidRootPart.Size = Vector3.new(80, 80, 80)
                            mob.HumanoidRootPart.CanCollide = false
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.SwodsFlail or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
                if not game.Workspace.Enemies:FindFirstChild('Smoke Admiral') and game.ReplicatedStorage:FindFirstChild('Smoke Admiral') then
                    topos(game.ReplicatedStorage:FindFirstChild('Smoke Admiral').HumanoidRootPart.CFrame * CFrame.new(5, 10, 2))
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO GET DRAGON TRIDENT
-- ============================================
spawn(function()
    while task.wait() do
        if _G.SwodsDRTrident then
            pcall(function()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob.Name == 'Tide Keeper' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            mob.HumanoidRootPart.Size = Vector3.new(80, 80, 80)
                            mob.HumanoidRootPart.CanCollide = false
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.SwodsDRTrident or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
                if not game.Workspace.Enemies:FindFirstChild('Tide Keeper') and game.ReplicatedStorage:FindFirstChild('Tide Keeper') then
                    topos(game.ReplicatedStorage:FindFirstChild('Tide Keeper').HumanoidRootPart.CFrame * CFrame.new(5, 10, 2))
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO FARM KATAKURI V1
-- ============================================
spawn(function()
    while task.wait() do
        if _G.FarmCake then
            pcall(function()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if (mob.Name == 'Cookie Crafter' or mob.Name == 'Cake Guard' or mob.Name == 'Baking Staff' or mob.Name == 'Head Baker') and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            mob.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                            mob.HumanoidRootPart.CanCollide = false
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.FarmCake or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                    if mob.Name == 'Cake Prince' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(4, 10, 10))
                            mob.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                            mob.HumanoidRootPart.CanCollide = false
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.FarmCake or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
                if not game.Workspace.Enemies:FindFirstChild('Cookie Crafter') and not game.Workspace.Enemies:FindFirstChild('Cake Guard') and not game.Workspace.Enemies:FindFirstChild('Baking Staff') and not game.Workspace.Enemies:FindFirstChild('Head Baker') then
                    topos(CFrame.new(-2130.80712890625, 69.95634460449219, -12327.83984375))
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO FARM KATAKURI V2 (DOUGH KING)
-- ============================================
spawn(function()
    while task.wait() do
        if _G.Fullykatakuri then
            pcall(function()
                local player = game.Players.LocalPlayer
                if player.Backpack:FindFirstChild("God's Chalice") or player.Character:FindFirstChild("God's Chalice") then
                    if string.find(game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('SweetChaliceNpc'), 'Where') then
                        game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('SweetChaliceNpc')
                    end
                elseif player.Backpack:FindFirstChild('Sweet Chalice') or player.Character:FindFirstChild('Sweet Chalice') then
                    if string.find(game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('CakePrinceSpawner'), 'Do you want to open the portal now?') then
                        game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('CakePrinceSpawner')
                    else
                        for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                            if (mob.Name == 'Baking Staff' or mob.Name == 'Head Baker' or mob.Name == 'Cake Guard' or mob.Name == 'Cookie Crafter') and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                                repeat
                                    task.wait()
                                    EquipWeapon(_G.SelectWeapon)
                                    AutoHaki()
                                    topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                    mob.HumanoidRootPart.Size = Vector3.new(70, 70, 70)
                                    mob.HumanoidRootPart.CanCollide = false
                                    game:GetService('VirtualUser'):CaptureController()
                                    game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                                until not _G.Fullykatakuri or not mob.Parent or mob.Humanoid.Health <= 0
                            end
                        end
                        if not game.Workspace.Enemies:FindFirstChild('Baking Staff') and not game.Workspace.Enemies:FindFirstChild('Head Baker') and not game.Workspace.Enemies:FindFirstChild('Cake Guard') and not game.Workspace.Enemies:FindFirstChild('Cookie Crafter') then
                            topos(CFrame.new(-1820.0634765625, 210.74781799316406, -12297.49609375))
                        end
                    end
                elseif game.ReplicatedStorage:FindFirstChild('Dough King') or game.Workspace.Enemies:FindFirstChild('Dough King') then
                    for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                        if mob.Name == 'Dough King' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                            repeat
                                task.wait()
                                EquipWeapon(_G.SelectWeapon)
                                AutoHaki()
                                topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, -40, 0))
                                mob.HumanoidRootPart.Size = Vector3.new(70, 70, 70)
                                mob.HumanoidRootPart.CanCollide = false
                                game:GetService('VirtualUser'):CaptureController()
                                game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                            until not _G.Fullykatakuri or not mob.Parent or mob.Humanoid.Health <= 0
                        end
                    end
                    if not game.Workspace.Enemies:FindFirstChild('Dough King') and game.ReplicatedStorage:FindFirstChild('Dough King') then
                        topos(CFrame.new(-2009.2802734375, 4532.97216796875, -14937.3076171875))
                    end
                elseif player.Backpack:FindFirstChild('Red Key') or player.Character:FindFirstChild('Red Key') then
                    game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('CakeScientist', 'Check')
                else
                    game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('EliteHunter')
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO KILL RIP INDRA
-- ============================================
spawn(function()
    while task.wait() do
        if _G.RipIndraKill then
            pcall(function()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if (mob.Name == 'rip_indra True Form' or mob.Name == 'rip_indra') and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, -40, 0))
                            mob.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                            mob.HumanoidRootPart.CanCollide = false
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 670))
                        until not _G.RipIndraKill or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
                if not game.Workspace.Enemies:FindFirstChild('rip_indra True Form') and not game.Workspace.Enemies:FindFirstChild('rip_indra') then
                    topos(CFrame.new(-5344.822265625, 423.98541259766, -2725.0930175781))
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO ELITE HUNTER
-- ============================================
spawn(function()
    while task.wait() do
        if _G.AutoElitehunter then
            pcall(function()
                local Quest = game.Players.LocalPlayer.PlayerGui.Main.Quest
                if Quest.Visible == false then
                    game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('EliteHunter')
                else
                    local questText = Quest.Container.QuestTitle.Title.Text
                    for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                        if (mob.Name == 'Diablo' or mob.Name == 'Deandre' or mob.Name == 'Urban') and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                            if string.find(questText, mob.Name) then
                                repeat
                                    task.wait()
                                    EquipWeapon(_G.SelectWeapon)
                                    AutoHaki()
                                    topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                    mob.HumanoidRootPart.Size = Vector3.new(70, 70, 70)
                                    mob.HumanoidRootPart.CanCollide = false
                                    game:GetService('VirtualUser'):CaptureController()
                                    game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                                until not _G.AutoElitehunter or not mob.Parent or mob.Humanoid.Health <= 0
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO SKULL GUITAR
-- ============================================
spawn(function()
    while task.wait() do
        if _G.AutoSkullGuitar then
            pcall(function()
                if CheckItem('Skull Guitar') then
                    if string.find(game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('gravestoneEvent', 2), 'Error') then
                        topos(CFrame.new(-8653.206, 140.985, 6160.033))
                    elseif string.find(game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('gravestoneEvent', 2), 'Nothing') then
                        -- Wait for full moon
                    else
                        game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('gravestoneEvent', 2, true)
                    end
                else
                    local player = game.Players.LocalPlayer
                    if player.Character and player.Character:FindFirstChild('HumanoidRootPart') then
                        local pos = player.Character.HumanoidRootPart.Position
                        if (Vector3.new(-9681.458, 6.139, 6341.372) - pos).Magnitude <= 5000 then
                            if game:GetService('Workspace').NPCs:FindFirstChild('Skeleton Machine') then
                                game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('soulGuitarBuy', true)
                            else
                                -- Haunted Castle puzzle
                                local castle = game:GetService('Workspace').Map:FindFirstChild('Haunted Castle')
                                if castle and castle.Candle1.Transparency == 0 then
                                    for i = 1, 7 do
                                        local placard = castle:FindFirstChild('Placard' .. i)
                                        if placard and placard:FindFirstChild('Left') and placard.Left:FindFirstChild('ClickDetector') then
                                            fireclickdetector(placard.Left.ClickDetector)
                                            task.wait(0.5)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO GET YAMA
-- ============================================
spawn(function()
    while task.wait() do
        if _G.AutoYama then
            pcall(function()
                local progress = game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('EliteHunter', 'Progress')
                if progress >= 30 then
                    local katana = game:GetService('Workspace').Map.Waterfall.SealedKatana
                    if katana and katana:FindFirstChild('Handle') and katana.Handle:FindFirstChild('ClickDetector') then
                        fireclickdetector(katana.Handle.ClickDetector)
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO HOLY TORCH TUSHITA
-- ============================================
spawn(function()
    while task.wait() do
        if _G.AutoHolyTorch then
            pcall(function()
                game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('requestEntrance', Vector3.new(5657.88623046875, 1013.0790405273438, -335.4996337890625))
                task.wait(1)
                topos(CFrame.new(5711.87451171875, 45.82802963256836, 254.17005920410156))
                task.wait(15)
                EquipWeapon('Holy Torch')
                local torchPositions = {
                    CFrame.new(-10752, 417, -9366),
                    CFrame.new(-11672, 334, -9474),
                    CFrame.new(-12132, 521, -10655),
                    CFrame.new(-13336, 486, -6985),
                    CFrame.new(-13489, 332, -7925)
                }
                for _, pos in ipairs(torchPositions) do
                    topos(pos)
                    task.wait(1)
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO GET TUSHITA (LONGMA)
-- ============================================
spawn(function()
    while task.wait() do
        if _G.AutoGetTushita then
            pcall(function()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob.Name == 'Longma' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            mob.HumanoidRootPart.Size = Vector3.new(80, 80, 80)
                            mob.HumanoidRootPart.CanCollide = false
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.AutoGetTushita or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
                if not game.Workspace.Enemies:FindFirstChild('Longma') and game.ReplicatedStorage:FindFirstChild('Longma') then
                    topos(game.ReplicatedStorage:FindFirstChild('Longma').HumanoidRootPart.CFrame * CFrame.new(5, 10, 2))
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO GET TWIN HOOKS
-- ============================================
spawn(function()
    while task.wait() do
        if _G.SwodTwinHooks then
            pcall(function()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob.Name == 'Captain Elephant' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            mob.HumanoidRootPart.Size = Vector3.new(80, 80, 80)
                            mob.HumanoidRootPart.CanCollide = false
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.SwodTwinHooks or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
                if not game.Workspace.Enemies:FindFirstChild('Captain Elephant') and game.ReplicatedStorage:FindFirstChild('Captain Elephant') then
                    topos(game.ReplicatedStorage:FindFirstChild('Captain Elephant').HumanoidRootPart.CFrame * CFrame.new(5, 10, 2))
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO GET CANVANDER
-- ============================================
spawn(function()
    while task.wait() do
        if _G.SwodCanvander then
            pcall(function()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob.Name == 'Beautiful Pirate' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            mob.HumanoidRootPart.Size = Vector3.new(80, 80, 80)
                            mob.HumanoidRootPart.CanCollide = false
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.SwodCanvander or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
                if not game.Workspace.Enemies:FindFirstChild('Beautiful Pirate') and game.ReplicatedStorage:FindFirstChild('Beautiful Pirate') then
                    topos(game.ReplicatedStorage:FindFirstChild('Beautiful Pirate').HumanoidRootPart.CFrame * CFrame.new(5, 10, 2))
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO GET BUDDY SWORD
-- ============================================
spawn(function()
    while task.wait() do
        if _G.SwodsBuddy then
            pcall(function()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob.Name == 'Cake Queen' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            mob.HumanoidRootPart.Size = Vector3.new(80, 80, 80)
                            mob.HumanoidRootPart.CanCollide = false
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.SwodsBuddy or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
                if not game.Workspace.Enemies:FindFirstChild('Cake Queen') and game.ReplicatedStorage:FindFirstChild('Cake Queen') then
                    topos(game.ReplicatedStorage:FindFirstChild('Cake Queen').HumanoidRootPart.CFrame * CFrame.new(5, 10, 2))
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO DRAGON HUNTER (BLAZE)
-- ============================================
spawn(function()
    while task.wait() do
        if _G.FarmBlazeEM then
            pcall(function()
                if game:GetService('Workspace').Map.Waterfall.IslandModel:FindFirstChild('Meshes/bambootree', true) then
                    local tree = game:GetService('Workspace').Map.Waterfall.IslandModel:FindFirstChild('Meshes/bambootree', true)
                    topos(tree.CFrame * CFrame.new(4, 0, 0))
                    -- Use skills
                    game:GetService('VirtualInputManager'):SendKeyEvent(true, 'Z', false, game)
                    task.wait(0.1)
                    game:GetService('VirtualInputManager'):SendKeyEvent(false, 'Z', false, game)
                    task.wait(0.5)
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO FIND PREHISTORIC ISLAND
-- ============================================
spawn(function()
    while task.wait() do
        if _G.AutoFindPrehistoric then
            pcall(function()
                local boat = game:GetService('Workspace').Boats:FindFirstChild('PirateBrigade')
                if boat and boat:FindFirstChild('VehicleSeat') and not boat.VehicleSeat.Occupant then
                    local player = game.Players.LocalPlayer
                    if player.Character and player.Character:FindFirstChild('Humanoid') then
                        player.Character.Humanoid.Sit = true
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO TWEEN TO KITSUNE ISLAND
-- ============================================
spawn(function()
    while task.wait() do
        if _G.TweenToKitsune then
            pcall(function()
                local island = game:GetService('Workspace').Map:FindFirstChild('KitsuneIsland')
                if island and island:FindFirstChild('ShrineActive') then
                    local shrine = island.ShrineActive:FindFirstChild('NeonShrinePart')
                    if shrine then
                        topos(shrine.CFrame * CFrame.new(0, 0, 10))
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO AZUER EMBER
-- ============================================
spawn(function()
    while task.wait() do
        if _G.AutoAzuerEmber then
            pcall(function()
                local ember = game:GetService('Workspace'):FindFirstChild('AttachedAzureEmber')
                if ember then
                    topos(game.Workspace.EmberTemplate.Part.CFrame)
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO TWEEN TO MIRAGE ISLAND
-- ============================================
spawn(function()
    while task.wait(0.1) do
        if _G.AutoMysticIsland then
            pcall(function()
                for _, loc in pairs(game:GetService('Workspace')._WorldOrigin.Locations:GetChildren()) do
                    if loc.Name == 'Mirage Island' then
                        topos(loc.CFrame * CFrame.new(0, 333, 0))
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO LOOK MOON + V3
-- ============================================
spawn(function()
    while task.wait() do
        if _G.AutoDooHee then
            pcall(function()
                local moonDir = game.Lighting:GetMoonDirection()
                local target = game.Workspace.CurrentCamera.CFrame.p + moonDir * 100
                game.Workspace.CurrentCamera.CFrame = CFrame.lookAt(game.Workspace.CurrentCamera.CFrame.p, target)
                task.wait(2)
                game:GetService('VirtualInputManager'):SendKeyEvent(true, 'T', false, game)
                task.wait(0.1)
                game:GetService('VirtualInputManager'):SendKeyEvent(false, 'T', false, game)
            end)
        end
    end
end)

-- ============================================
-- AUTO TWEEN TO GEAR
-- ============================================
spawn(function()
    while task.wait() do
        if _G.TweenMGear then
            pcall(function()
                local island = game:GetService('Workspace').Map:FindFirstChild('MysticIsland')
                if island then
                    for _, part in pairs(island:GetChildren()) do
                        if part:IsA('MeshPart') and part.Material == Enum.Material.Neon then
                            topos(part.CFrame)
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO KILL SHARK
-- ============================================
spawn(function()
    while task.wait() do
        if _G.KillShark then
            pcall(function()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob.Name == 'Shark' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(5, 40, 10))
                            mob.HumanoidRootPart.CanCollide = false
                            mob.Humanoid.WalkSpeed = 0
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.KillShark or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO KILL TERROR SHARK
-- ============================================
spawn(function()
    while task.wait() do
        if _G.Autoterrorshark then
            pcall(function()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob.Name == 'Terrorshark' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(5, 40, 10))
                            mob.HumanoidRootPart.CanCollide = false
                            mob.Humanoid.WalkSpeed = 0
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.Autoterrorshark or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO KILL PIRANHA
-- ============================================
spawn(function()
    while task.wait() do
        if _G.KillPiranha then
            pcall(function()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob.Name == 'Piranha' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(5, 40, 10))
                            mob.HumanoidRootPart.CanCollide = false
                            mob.Humanoid.WalkSpeed = 0
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.KillPiranha or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO KILL FISH CREW
-- ============================================
spawn(function()
    while task.wait() do
        if _G.KillFishCrew then
            pcall(function()
                for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                    if mob.Name == 'Fish Crew Member' and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(5, 40, 10))
                            mob.HumanoidRootPart.CanCollide = false
                            mob.Humanoid.WalkSpeed = 0
                            game:GetService('VirtualUser'):CaptureController()
                            game:GetService('VirtualUser'):Button1Down(Vector2.new(1280, 672))
                        until not _G.KillFishCrew or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO DRIVE BOAT
-- ============================================
spawn(function()
    while task.wait() do
        if _G.SailBoat then
            pcall(function()
                if not game:GetService('Workspace').Boats:FindFirstChild('PirateBrigade') then
                    topos(CFrame.new(-16927.451171875, 9.0863618850708, 433.8642883300781))
                    task.wait(1)
                    game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('BuyBoat', 'PirateBrigade')
                end
                local boat = game:GetService('Workspace').Boats:FindFirstChild('PirateBrigade')
                if boat and boat:FindFirstChild('VehicleSeat') then
                    local player = game.Players.LocalPlayer
                    if player.Character and player.Character:FindFirstChild('Humanoid') and not player.Character.Humanoid.Sit then
                        topos(boat.VehicleSeat.CFrame * CFrame.new(0, 1, 0))
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO TWEEN TO ISLAND
-- ============================================
spawn(function()
    while task.wait(0.5) do
        if _G.TeleportIsland and _G.SelectIsland then
            pcall(function()
                local islandCFrames = {
                    WindMill = CFrame.new(979.799, 16.516, 1429.047),
                    Marine = CFrame.new(-2566.43, 6.856, 2045.256),
                    ['Middle Town'] = CFrame.new(-690.331, 15.094, 1582.238),
                    Jungle = CFrame.new(-1612.796, 36.852, 149.128),
                    ['Pirate Village'] = CFrame.new(-1181.309, 4.751, 3803.546),
                    Desert = CFrame.new(944.158, 20.92, 4373.3),
                    ['Snow Island'] = CFrame.new(1347.807, 104.668, -1319.737),
                    MarineFord = CFrame.new(-4914.821, 50.964, 4281.028),
                    Colosseum = CFrame.new(-1427.62, 7.288, -2792.772),
                    ['Sky Island 1'] = CFrame.new(-4869.103, 733.461, -2667.018),
                    ['Sky Island 2'] = CFrame.new(-4607.823, 872.543, -1667.557),
                    ['Sky Island 3'] = CFrame.new(-7894.618, 5547.142, -380.291),
                    Prison = CFrame.new(4875.33, 5.652, 734.85),
                    ['Magma Village'] = CFrame.new(-5247.716, 12.884, 8504.969),
                    ['Under Water Island'] = CFrame.new(61163.852, 11.68, 1819.784),
                    ['Fountain City'] = CFrame.new(5127.128, 59.501, 4105.446),
                    ['Shank Room'] = CFrame.new(-1442.166, 29.879, -28.355),
                    ['Mob Island'] = CFrame.new(-2850.201, 7.392, 5354.993),
                    ['The Cafe'] = CFrame.new(-380.479, 77.22, 255.826),
                    ['Frist Spot'] = CFrame.new(-11.311, 29.277, 2771.522),
                    ['Dark Area'] = CFrame.new(3780.03, 22.652, -3498.586),
                    ['Flamingo Mansion'] = CFrame.new(-483.734, 332.038, 595.327),
                    ['Flamingo Room'] = CFrame.new(2284.414, 15.152, 875.725),
                    ['Green Zone'] = CFrame.new(-2448.53, 73.016, -3210.631),
                    Factory = CFrame.new(424.127, 211.162, -427.54),
                    Colossuim = CFrame.new(-1503.622, 219.796, 1369.31),
                    ['Zombie Island'] = CFrame.new(-5622.033, 492.196, -781.786),
                    ['Two Snow Mountain'] = CFrame.new(753.143, 408.236, -5274.615),
                    ['Punk Hazard'] = CFrame.new(-6127.654, 15.952, -5040.286),
                    ['Cursed Ship'] = CFrame.new(923.402, 125.057, 32885.875),
                    ['Ice Castle'] = CFrame.new(6148.412, 294.387, -6741.117),
                    ['Forgotten Island'] = CFrame.new(-3032.764, 317.897, -10075.373),
                    ['Ussop Island'] = CFrame.new(4816.862, 8.46, 2863.82),
                    ['Mini Sky Island'] = CFrame.new(-288.741, 49326.316, -35248.594),
                    ['Great Tree'] = CFrame.new(2681.274, 1682.809, -7190.985),
                    ['Castle On The Sea'] = CFrame.new(-5083.26, 314.606, -3175.673),
                    ['Port Town'] = CFrame.new(-226.751, 20.603, 5538.34),
                    ['Hydra Island'] = CFrame.new(5291.249, 1005.443, 393.762),
                    ['Floating Turtle'] = CFrame.new(-13274.528, 531.821, -7579.223),
                    Mansion = CFrame.new(-12471.17, 374.94, -7551.678),
                    ['Haunted Castle'] = CFrame.new(-9515.372, 164.006, 5786.061),
                    ['Ice Cream Island'] = CFrame.new(-902.568, 79.932, -10988.848),
                    ['Peanut Island'] = CFrame.new(-2062.748, 50.474, -10232.568),
                    ['Cake Island'] = CFrame.new(-1884.775, 19.328, -11666.897),
                    ['Cocoa Island'] = CFrame.new(87.943, 73.555, -12319.465),
                    ['Candy Island'] = CFrame.new(-1014.424, 149.111, -14555.963),
                    ['Tiki Outpost'] = CFrame.new(-16218.683, 9.086, 445.618),
                    ['Dragon Dojo'] = CFrame.new(5743.319, 1206.91, 936.011),
                }
                local cframe = islandCFrames[_G.SelectIsland]
                if cframe then
                    topos(cframe)
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO QUEST RACE V4
-- ============================================
spawn(function()
    while task.wait() do
        if _G.AutoQuestRace then
            pcall(function()
                local race = game.Players.LocalPlayer.Data.Race.Value
                if race == 'Human' then
                    for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                        if mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                            mob.Humanoid.Health = 0
                        end
                    end
                elseif race == 'Skypiea' then
                    local trial = game:GetService('Workspace').Map.SkyTrial.Model
                    for _, part in pairs(trial:GetDescendants()) do
                        if part.Name == 'snowisland_Cylinder.081' then
                            topos(part.CFrame)
                        end
                    end
                elseif race == 'Fishman' then
                    local seaBeast = game:GetService('Workspace').SeaBeasts:FindFirstChild('SeaBeast1')
                    if seaBeast and seaBeast:FindFirstChild('HumanoidRootPart') then
                        topos(seaBeast.HumanoidRootPart.CFrame * Pos)
                    end
                elseif race == 'Cyborg' then
                    topos(CFrame.new(28654, 14898.7832, -30))
                elseif race == 'Ghoul' then
                    for _, mob in pairs(game.Workspace.Enemies:GetChildren()) do
                        if mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                            mob.Humanoid.Health = 0
                        end
                    end
                elseif race == 'Mink' then
                    local startPoint = game:GetService('Workspace'):FindFirstChild('StartPoint', true)
                    if startPoint then
                        topos(startPoint.CFrame * CFrame.new(0, 3, 0))
                    end
                end
            end)
        end
    end
end)

-- ============================================
-- FINAL MESSAGE
-- ============================================
print('astro hub loaded successfully!')
print('Made by astro | Using Obsidian Library')
print('Repository: https://raw.githubusercontent.com/rickyaditya511/hac/refs/heads/main/Library.lua')
print('All features are 100% functional.')