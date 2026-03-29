getgenv().InterfaceName = "NULL"
getgenv().SecureMode = true

executor = identifyexecutor and identifyexecutor() or "Unknown"
local device = "Unknown"
local UIS = game:GetService("UserInputService")
if UIS.TouchEnabled and not UIS.KeyboardEnabled then
    device = "Mobile"
else
    device = "PC"
end

local Starlight = loadstring(game:HttpGet("https://raw.githubusercontent.com/Dead0G0D/Starlight-fork/refs/heads/main/forkdofork.lua"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()
--https://raw.githubusercontent.com/Dead0G0D/Starlight-fork/refs/heads/main/Starlight.fork.lua

MarketplaceService = game:GetService("MarketplaceService")
PlaceId = game.PlaceId
ProductInfo = MarketplaceService:GetProductInfo(PlaceId)
GameName = ProductInfo.Name

local Window = Starlight:CreateWindow({
    Name = string.format("Null Hub [%s] [%s]", device, executor),
    Subtitle = GameName,
    Icon = "105433751946385", --"90421697308928", --"114022464350371", --"115111586638831", --"136362783020632",  --"116180233441379", --"101497542169555", --"77933017176374", --"125967972654762",
    DefaultSize = UDim2.fromOffset(540, 540),
    PlayerInfoBlur = true,
    PlayerStatus = true,
    BuildWarnings = true,
    InterfaceAdvertisingPrompts = true,
    NotifyOnCallbackError = true,
    LoadingEnabled = true,
    
    LoadingSettings = {
        Title = "Null Hub Entertainments",
        Subtitle = "Welcome to Null Hub Baby.",
    },
  
    FileSettings = {
        ConfigFolder = "NullHub - " .. GameName,
    },
})

local MS = Window:CreateTabSection("MAIN")
local SS = Window:CreateTabSection("SETTINGS")

local MainTab = MS:CreateTab({
    Name = "| Main",
    Icon = "90421697308928",
    Columns = 1,
}, "TAB_MAIN")
               --Groupboxs--
local AutoFarmBox = MainTab:CreateGroupbox({
    Name = "Auto Farm",
    Icon = NebulaIcons:GetIcon('repeat-1', 'Lucide'),
    Column = 1,
}, "GB_AUTOFARM")
              --Groupboxs--
local Pl = MainTab:CreateGroupbox({
    Name = "Player",
    Icon = NebulaIcons:GetIcon('user-cog', 'Lucide'),
    Column = 1,
}, "GB_PLMISC")

local Up = MainTab:CreateGroupbox({
    Name = "Units|Upgrades|Gachas",
    Icon = NebulaIcons:GetIcon('diamond-plus', 'Lucide'),
    Column = 1,
}, "GB_UPGRADES")

local GMS = MS:CreateTab({
    Name = "| Gamemodes",
    Icon = "90421697308928",
    Columns = 1,
}, "TAB_GM")
              --Groupboxs--
local GamemodeBox = GMS:CreateGroupbox({
    Name = "Auto Modes",
    Icon = NebulaIcons:GetIcon('repeat-1', 'Lucide'),
    Column = 1,
}, "GB_AUTOFARMMODES")

local SV = GMS:CreateGroupbox({
    Name = "Save Position",
    Icon = NebulaIcons:GetIcon('map', 'Phosphor'),
    Column = 1,
}, "GB_SVMODES")

local Gm = GMS:CreateGroupbox({
    Name = "Retry/Leave",
    Icon = NebulaIcons:GetIcon('arrow-right-left', 'Lucide'),
    Column = 1,
}, "GB_RLMODES")

local Theme = SS:CreateTab({
    Name = "| Themes",
    Icon = NebulaIcons:GetIcon('iframe', 'Symbols'),
    Columns = 2,
}, "TAB_THEMES")

local Config = SS:CreateTab({
    Name = "| Config",
    Icon = NebulaIcons:GetIcon('settings', 'Symbols'),
    Columns = 2,
}, "TAB_CONFIG")
              --Groupboxs--
local ConfigMisc = Config:CreateGroupbox({
    Name = "Misc",
    Icon = NebulaIcons:GetIcon('shield-check', 'Phosphor'),
    Column = 1,
}, "GB_CONFIG_MISC")

Theme:BuildThemeGroupbox(1)
Config:BuildConfigGroupbox(1)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local MaterialService = game:GetService("MaterialService")

local function Modes()
    local dungeon = LocalPlayer.PlayerGui:FindFirstChild("Main")
    dungeon = dungeon and dungeon:FindFirstChild("HUD")
    dungeon = dungeon and dungeon:FindFirstChild("Dungeon")
    if not dungeon then return false end
    return dungeon.Visible
end

local selectedWorld = "World1"

local WorldLabel = AutoFarmBox:CreateLabel({
    Name = "Select World",
    Icon = NebulaIcons:GetIcon('globe', 'Lucide'),
}, "LABEL_WORLD")

WorldLabel:AddDropdown({
    Options = {"World1", "World2", "World3", "World4"},
    CurrentOptions = {"World1"},
    Callback = function(Options)
        selectedWorld = Options[1] or "World1"
    end,
}, "DD_WORLD_SELECT")

local function GetUniqueEnemyNames()
    local names = {}
    local world = workspace:FindFirstChild(selectedWorld)
    if not world then return {} end

    for _, enemy in ipairs(world:GetDescendants()) do
        if enemy:IsA("Model") and enemy:GetAttribute("Attackable") then
            names[enemy.Name] = true
        end
    end

    local uniqueList = {}
    for name in pairs(names) do
        table.insert(uniqueList, name)
    end
    return uniqueList
end

local farmRunning = false
local selectedNpcNames = {}
local priorityEnemyNames = {}

local NpcAutoFarm = AutoFarmBox:CreateToggle({
    Name = "Auto Farm Enemy",
    Icon = NebulaIcons:GetIcon('user-cog', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        farmRunning = Value
        if not Value then return end

        task.spawn(function()
            while farmRunning do
                if Modes() then
                    task.wait(0.5)
                    continue
                end
                
                if not selectedNpcNames or #selectedNpcNames == 0 then
                    task.wait(0.5)
                    continue
                end

                local world = workspace:FindFirstChild(selectedWorld)
                if not world then
                    task.wait(0.5)
                    continue
                end

                local hasPriorityAlive = false
                if priorityEnemyNames and #priorityEnemyNames > 0 then
                    for _, enemy in ipairs(world:GetDescendants()) do
                        if enemy:IsA("Model") and table.find(priorityEnemyNames, enemy.Name) and enemy:GetAttribute("Attackable") == true then
                            hasPriorityAlive = true
                            break
                        end
                    end
                end

                local namesToFarm = hasPriorityAlive and priorityEnemyNames or selectedNpcNames

                for _, enemyName in ipairs(namesToFarm) do
                    if not farmRunning then break end

                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then continue end

                    local target = nil
                    for _, enemy in ipairs(world:GetDescendants()) do
                        if enemy:IsA("Model") and enemy.Name == enemyName and enemy:GetAttribute("Attackable") == true then
                            target = enemy
                            break
                        end
                    end

                    if target then
                        repeat
                            if not farmRunning or not target.Parent or target:GetAttribute("Attackable") == false then break end

                            if priorityEnemyNames and #priorityEnemyNames > 0 and not table.find(priorityEnemyNames, enemyName) then
                                local prioritySpawned = false
                                for _, enemy in ipairs(world:GetDescendants()) do
                                    if enemy:IsA("Model") and table.find(priorityEnemyNames, enemy.Name) and enemy:GetAttribute("Attackable") == true then
                                        prioritySpawned = true
                                        break
                                    end
                                end
                                if prioritySpawned then break end
                            end

                            char = LocalPlayer.Character
                            hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if not hrp then break end
                            hrp.CFrame = CFrame.new(target:GetPivot().Position + Vector3.new(0, 2.5, 2.5))

                            RunService.Heartbeat:Wait()
                        until target:GetAttribute("Attackable") == false or not target.Parent
                    end
                    task.wait(0.1)
                end
            end
        end)
    end,
}, "TOGGLE_AUTO_FARM_ENEMY")

local NpcDropdown = NpcAutoFarm:AddDropdown({
    Options = GetUniqueEnemyNames(),
    CurrentOptions = {},
    Placeholder = "Select NPCs",
    MultipleOptions = true,
    Callback = function(Options)
        selectedNpcNames = Options
    end,
}, "DD_NPC_SELECT")

local PriorityDropdown = NpcAutoFarm:AddDropdown({
    Options = GetUniqueEnemyNames(),
    CurrentOptions = {},
    Placeholder = "Priority NPCs",
    MultipleOptions = true,
    Callback = function(Options)
        priorityEnemyNames = Options
    end,
}, "DD_PRIORITY_NPCS")

AutoFarmBox:CreateButton({
    Name = "Refresh",
    Icon = NebulaIcons:GetIcon('caret-circle-right', 'Phosphor'),
    Style = 1,
    CenterContent = true,
    Callback = function()
        local names = GetUniqueEnemyNames()
        NpcDropdown:Set({Options = names, CurrentOptions = {}})
        PriorityDropdown:Set({Options = names, CurrentOptions = {}})
    end,
}, "BTN_REFRESH_NPCS")

local rp = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local ac = false
local Atc = Pl:CreateToggle({
    Name = "Auto Click",
    Icon = NebulaIcons:GetIcon('cursor-click', 'Phosphor'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        ac = Value
        if not Value then return end
        task.spawn(function()
            while ac do
                pcall(function()
                rp:WaitForChild("Clicked"):FireServer()
                end)
                RunService.Heartbeat:Wait()
            end
        end)
    end,
}, "TOGGLE_AUTOCLICK")

local autoEquip = false
Pl:CreateToggle({
    Name = "Auto Equip Best All",
    Icon = NebulaIcons:GetIcon('gem', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autoEquip = Value
        if not Value then return end
        task.spawn(function()
            while autoEquip do
                pcall(function()
                    rp.Accessories.EquipBestAccessories:FireServer()
                    rp.MorphPets.EquipBestMorphPets:FireServer()
                    rp.Pets.EquipBestPets:FireServer()
                    rp.Weapons.EquipBestWeapons:FireServer()
                end)
                task.wait(15)
            end
        end)
    end,
}, "TOGGLE_AUTO_EQUIP")

local islands = (function()
    local list = {}
    for _, v in ipairs(workspace.Stars:GetChildren()) do
        local star = v:GetAttribute("star")
        if star then
            table.insert(list, star)
        end
    end
    return list
end)()

local petroll = islands[1] or ""
local autopetroll = false
local autopetroll = Up:CreateToggle({
    Name = "Pet Roll",
    Icon = NebulaIcons:GetIcon('package-open', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autopetroll = Value
        if not Value then return end
        task.spawn(function()
            while autopetroll do
                pcall(function()
                rp:WaitForChild("Eggs"):WaitForChild("Hatch"):InvokeServer(petroll, 3)
                end)
                RunService.Heartbeat:Wait()
            end
        end)
    end,
}, "TOGGLE_PETROLL")

autopetroll:AddDropdown({
    Options = islands,
    CurrentOptions = {islands[1]},
    Callback = function(Options)
        petroll = Options[1]
    end,
}, "DD_PETROLL")

local selectedStat = "Energy"
local upp2 = false
local up2 = Up:CreateToggle({
    Name = "Auto Up Stats",
    Icon = NebulaIcons:GetIcon('chart-no-axes-combined', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        upp2 = Value
        if not Value then return end
        task.spawn(function()
            while upp2 do
                if selectedStat and selectedStat ~= "" then
                    pcall(function()
                        rp:WaitForChild("StatPoints"):FireServer(selectedStat, 1)
                    end)
                end
                RunService.Heartbeat:Wait()
            end
        end)
    end,
}, "TOGGLE_Up2")

up2:AddDropdown({
    Options = {"Energy", "Coins", "Luck", "Damage"},
    CurrentOptions = {"Energy"},
    Callback = function(Options)
        selectedStat = Options[1] or "Energy"
    end,
}, "DD_UP2")
--game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("OpenWisteriaRaid"):FireServer()
local GACHA_REMOTES = {
    ["Pet"]             = rp:WaitForChild("RollPetPower"),
    ["TungFamily"]      = rp:WaitForChild("RollTungFamily"),
    ["Saiyan Power"]    = rp:WaitForChild("RollSaiyanPower"),
    ["DragonBall"]      = rp:WaitForChild("RollDragonBallPower"),
    ["Dagger"]          = rp:WaitForChild("RollDaggerPower"),
    ["Jungle"]          = rp:WaitForChild("RollJunglePower"),
    ["Farm"]            = rp:WaitForChild("RollFarmPower"),
    ["Avocado"]         = rp:WaitForChild("RollAvocadoPower"),
    ["Lava"]            = rp:WaitForChild("RollLavaPower"),
    ["Ballerina"]       = rp:WaitForChild("RollBallerinaPower"),
    ["Saturn"]          = rp:WaitForChild("RollSaturnPower"),
    ["Robot"]           = rp:WaitForChild("RollRobotPower"),
    ["Saiyan"]          = rp:WaitForChild("RollSaiyan"),
    ["Fruit"]           = rp:WaitForChild("RollFruitPower"),
    ["Grimoires"]       = rp:WaitForChild("RollGrimoires"),
    ["Grimoires Power"] = rp:WaitForChild("RollGrimoiresPower"),
    ["Demon"]           = rp:WaitForChild("RollDemon"),
    ["Demon Power"]     = rp:WaitForChild("RollDemonPower"),
    ["Breathing"]       = rp:WaitForChild("RollBreathing"),
    ["Breathing Power"] = rp:WaitForChild("RollBreathingPower"),
}

local gachaNames = {}
for name in pairs(GACHA_REMOTES) do
    table.insert(gachaNames, name)
end

local selectedGachas = {}
local upp3 = false

local up3 = Up:CreateToggle({
    Name = "Auto Roll Gachas",
    Icon = NebulaIcons:GetIcon('package-open', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        upp3 = Value
        if not Value then return end
        task.spawn(function()
            while upp3 do
                if selectedGachas and #selectedGachas > 0 then
                    for _, gacha in ipairs(selectedGachas) do
                        pcall(function()
                            local remote = GACHA_REMOTES[gacha]
                            if remote then
                                remote:FireServer()
                            end
                        end)
                    end
                end
                RunService.Heartbeat:Wait()
            end
        end)
    end,
}, "TOGGLE_Up3")

up3:AddDropdown({
    Options = gachaNames,
    CurrentOptions = {},
    MultipleOptions = true,
    Callback = function(Options)
        selectedGachas = Options or {}
    end,
}, "DD_UP3")

Up:CreateButton({
    Name = "Delete Gacha Animation",
    Icon = NebulaIcons:GetIcon('trash-2', 'Lucide'),
    Style = 1,
    CenterContent = true,
    Callback = function()
        pcall(function()
            local main = LocalPlayer.PlayerGui.Main
            local saiyan = main:FindFirstChild("SaiyanPowerGachaRoll")
            local gacha = main:FindFirstChild("GachaRoll")
            if saiyan then saiyan:Destroy() end
            if gacha then gacha:Destroy() end
        end)
    end,
}, "BTN_DELETE_GACHA_ANIM")

local LEVELING_REMOTES = {
    ["Tralalero"]   = rp:WaitForChild("TralaleroLeveling"),
    ["SharpMelon"]  = rp:WaitForChild("SharpMelonLeveling"),
    ["EnergyMelon"] = rp:WaitForChild("EnergyMelonLeveling"),
    ["Fortune"]     = rp:WaitForChild("FortuneLeveling"),
    ["Blessed"]     = rp:WaitForChild("BlessedLeveling"),
    ["Fruit"]       = rp:WaitForChild("FruitLeveling"),
    ["Haki"]        = rp:WaitForChild("HakiLeveling"),
    ["Hotspot"]     = rp:WaitForChild("HotspotLeveling"),
    ["Dragon"]      = rp:WaitForChild("DragonLeveling"),
    ["Christmas"]   = rp:WaitForChild("ChristmasLeveling"),
    ["Toaster"]     = rp:WaitForChild("ToasterLeveling"),
    ["Dragonfruit"] = rp:WaitForChild("DragonfruitLeveling"),
    ["BloodArt"]    = rp:WaitForChild("BloodArtLeveling"),
    ["Wisteria"]    = rp:WaitForChild("WisteriaLeveling"),
}

local levelingNames = {}
for name in pairs(LEVELING_REMOTES) do
    table.insert(levelingNames, name)
end

local selectedLeveling = {}
local autoLeveling = false

local LevelingToggle = Up:CreateToggle({
    Name = "Auto Leveling",
    Icon = NebulaIcons:GetIcon('trending-up', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autoLeveling = Value
        if not Value then return end
        task.spawn(function()
            while autoLeveling do
                if selectedLeveling and #selectedLeveling > 0 then
                    for _, leveling in ipairs(selectedLeveling) do
                        if not autoLeveling then break end
                        pcall(function()
                            local remote = LEVELING_REMOTES[leveling]
                            if remote then remote:FireServer() end
                        end)
                        task.wait(0.1)
                    end
                end
                RunService.Heartbeat:Wait()
            end
        end)
    end,
}, "TOGGLE_AUTO_LEVELING")

LevelingToggle:AddDropdown({
    Options = levelingNames,
    CurrentOptions = {},
    MultipleOptions = true,
    Placeholder = "Select Leveling",
    Callback = function(Options)
        selectedLeveling = Options or {}
    end,
}, "DD_LEVELING")

local CODES = {"Leveling", "Release", "Hype", "1K CCU"}
Pl:CreateButton({
    Name = "Redeem Codes",
    Icon = NebulaIcons:GetIcon('book-copy', 'Lucide'),
    Style = 1,
    CenterContent = true,
    Callback = function()
        for _, code in ipairs(CODES) do
            rp:WaitForChild("RedeemCode"):InvokeServer(code)
        end
    end,
}, "BB_CODES")

local autoChest = false
Pl:CreateToggle({
    Name = "Auto Collect Chests",
    Icon = NebulaIcons:GetIcon('package-open', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autoChest = Value
        if not Value then return end
        task.spawn(function()
            while autoChest do
                pcall(function()
                    local chests = {
                        workspace.Chests.GroupRewardsChest,
                        workspace.Chests.DailyRewardsChest,
                        workspace.Chests.VIPChest,
                        workspace.Chests.PremiumChest,
                    }
                    for _, chest in ipairs(chests) do
                        pcall(function()
                            local timeLabel = chest.BillboardGui.Main.Time
                            if not tonumber(timeLabel.Text) then
                                local hrp = LocalPlayer.Character.HumanoidRootPart
                                local touch = chest.Hitbox.TouchInterest
                                firetouchinterest(hrp, touch, 0)
                                task.wait(0.1)
                                firetouchinterest(hrp, touch, 1)
                            end
                        end)
                    end
                end)
                task.wait(1)
            end
        end)
    end,
}, "TOGGLE_AUTO_CHEST")

local lvwave = ""
local hasJustTeleported = false
local justLeftMode = {}
local selectedMap = ""
local autoModesActive = false
local joiningMode = false
local currentMode = nil
local AutoLeaveAll = false
local selectedModes = {}
local SvPosition = nil
local modeFarm = false

local MODE_PRIORITIES = {"Raid", "WisteriaRaid"}

local MODE_SCHEDULES = {
    ["Raid"]         = {minutes = {0, 30}},
    ["WisteriaRaid"] = {always = true},
}

local MODE_RAID_IDS = {
    ["Raid"]         = "TowerRaid",
    ["WisteriaRaid"] = "WisteriaRaid",
}

local function IsAvailable(modeName)
    local schedule = MODE_SCHEDULES[modeName]
    if not schedule then return false end
    if schedule.always then return true end
    local min = os.date("*t").min
    return table.find(schedule.minutes, min) ~= nil
end

local function CanJoinMode(modeName)
    if not table.find(selectedModes, modeName) then return false end
    local lastLeft = justLeftMode[modeName]
    if lastLeft and os.time() - lastLeft < 55 then return false end
    return IsAvailable(modeName)
end

local function GetHighestPriorityAvailable()
    for _, mode in ipairs(MODE_PRIORITIES) do
        if CanJoinMode(mode) then
            return mode
        end
    end
    return nil
end

local timemodes = GamemodeBox:CreateParagraph({
    Name = "Timers",
    Icon = NebulaIcons:GetIcon('clock-fading', 'Lucide'),
    Content = "Carregando...",
}, "PARA_MODES")

local function updateEventParagraph(paragraph, min, sec)
    local function timeToNext(minuteMarks)
        table.sort(minuteMarks)
        for _, mark in ipairs(minuteMarks) do
            if min < mark or (min == mark and sec == 0) then
                local m = mark - min
                local s = (60 - sec) % 60
                if s ~= 0 then m = m - 1 end
                if m < 0 then m = m + 60 end
                return string.format("%02d:%02d", m, s)
            end
        end
        local m = 60 - min + minuteMarks[1]
        local s = (60 - sec) % 60
        if s ~= 0 then m = m - 1 end
        return string.format("%02d:%02d", m, s)
    end

    local raidTimer = timeToNext({0, 30})
    paragraph:Set({Content = "Raid Open: XX:00 & XX:30\nNext In: " .. raidTimer .. "\nWisteria Raid: Always Available"})
end

local now = os.date("!*t")
updateEventParagraph(timemodes, now.min, now.sec)

task.spawn(function()
    while true do
        local now = os.date("!*t")
        updateEventParagraph(timemodes, now.min, now.sec)
        task.wait(1)
    end
end)

GamemodeBox:CreateDivider()

local StatusParagraph = GamemodeBox:CreateParagraph({
    Name = "Status",
    Icon = NebulaIcons:GetIcon('info', 'Lucide'),
    Content = "Idle",
}, "PARA_STATUS")

local function updateStatus()
    local waveLabel = LocalPlayer.PlayerGui.Main.HUD.Dungeon.RaidsInfo.WavesFrame:FindFirstChild("Wave")
    
    local currentWave = waveLabel and waveLabel.ContentText or "N/A"
    
    local posText = SvPosition and string.format("X: %.2f, Y: %.2f, Z: %.2f", SvPosition.X, SvPosition.Y, SvPosition.Z) or "Not Saved"

    local lines = {}
    table.insert(lines, "In Mode: " .. tostring(Modes()))
    table.insert(lines, "Current Mode: " .. (currentMode or "None"))
    table.insert(lines, "Current Wave: " .. currentWave)
    table.insert(lines, "Auto Join: " .. (autoModesActive and "ON" or "OFF"))
    table.insert(lines, "Auto Leave: " .. (AutoLeaveAll and "ON | Wave: " .. (lvwave ~= "" and lvwave or "End") or "OFF"))
    table.insert(lines, "Map to return: " .. (selectedMap ~= "" and selectedMap or "None"))
    table.insert(lines, "Saved Position: " .. posText)

    StatusParagraph:Set({Content = table.concat(lines, "\n")})
end

task.spawn(function()
    while true do
        pcall(updateStatus)
        task.wait(1)
    end
end)

GamemodeBox:CreateDivider()

SV:CreateButton({
    Name = "Save Position",
    Icon = NebulaIcons:GetIcon('map-pinned', 'Lucide'),
    Style = 1,
    CenterContent = true,
    Callback = function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            SvPosition = hrp.Position
        end
    end,
}, "BTN_SAVE_POS")

local function tpback()
    if hasJustTeleported then return end
    hasJustTeleported = true
    pcall(function()
        rp:WaitForChild("LeaveRaid"):FireServer()
    end)
    task.wait(1)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and SvPosition and selectedMap ~= "" then
        pcall(function()
            rp:WaitForChild("Teleport"):FireServer(selectedMap)
        end)
        task.wait(0.5)
        hrp.CFrame = CFrame.new(SvPosition)
    end
    hasJustTeleported = false
end

local MapLabel = SV:CreateLabel({
    Name = "Map to Leave",
    Icon = NebulaIcons:GetIcon('map', 'Lucide'),
}, "LABEL_MAP")

MapLabel:AddDropdown({
    Options = {"World1", "World2", "World3", "World4"},
    CurrentOptions = {},
    Placeholder = "Select Map",
    Callback = function(Options)
        selectedMap = Options[1] or ""
    end,
}, "DD_MAP_SELECT")

Gm:CreateInput({
    Name = "Set Wave",
    Icon = NebulaIcons:GetIcon('text-cursor-input', 'Lucide'),
    CurrentValue = "",
    Numeric = true,
    Enter = true,
    MaxCharacters = 30,
    Callback = function(Text)
        lvwave = Text
    end,
}, "INPUT_LEAVE_WAVE")

SV:CreateToggle({
    Name = "Auto Leave",
    Icon = NebulaIcons:GetIcon('door-closed', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        AutoLeaveAll = Value
        if not Value then return end
        task.spawn(function()
            local wasInMode = false
            while AutoLeaveAll do
                pcall(function()
                    local inMode = Modes()

                    if inMode then
                        wasInMode = true
                    elseif wasInMode and not inMode then
                        wasInMode = false
                        tpback()
                        return
                    end

                    if inMode and lvwave and lvwave ~= "" then
                      local waveLabel = LocalPlayer.PlayerGui.Main.HUD.Dungeon.RaidsInfo.WavesFrame:FindFirstChild("Wave")
                        if waveLabel then
                            local current = tonumber(string.match(waveLabel.ContentText, "^(%d+)"))
                            if current and current == tonumber(lvwave) then
                                wasInMode = false
                                tpback()
                            end
                        end
                    end

                    if not inMode then
                        hasJustTeleported = false
                    end
                end)
                task.wait(0.5)
            end
        end)
    end,
}, "TOGGLE_AUTOLEAVE")

local function JoinMode(modeName)
    if joiningMode then return end
    joiningMode = true
    task.spawn(function()
        repeat
            pcall(function()
                if modeName == "WisteriaRaid" then
                    rp:WaitForChild("OpenWisteriaRaid"):FireServer()
                    task.wait(1)
                    rp:WaitForChild("JoinWisteriaRaid"):FireServer()
                else
                    rp:WaitForChild("JoinTowerRaid"):FireServer()
                end
            end)
            task.wait(2)
        until Modes() or not autoModesActive
        currentMode = Modes() and modeName or nil
        joiningMode = false
    end)
end

local function LeaveCurrentMode()
    if not currentMode then return end
    tpback()
    justLeftMode[currentMode] = os.time()
    currentMode = nil
    joiningMode = false
end

local ModeLabel = GamemodeBox:CreateLabel({
    Name = "Select Modes",
    Icon = NebulaIcons:GetIcon('list', 'Lucide'),
}, "LABEL_MODES")

ModeLabel:AddDropdown({
    Options = {"Raid", "WisteriaRaid"},
    CurrentOptions = {},
    Placeholder = "Select Modes",
    MultipleOptions = true,
    Callback = function(Options)
        selectedModes = Options or {}
    end,
}, "DD_MODES")

GamemodeBox:CreateToggle({
    Name = "Auto Join",
    Icon = NebulaIcons:GetIcon('door-open', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autoModesActive = Value
        if not Value then
            currentMode = nil
            joiningMode = false
            return
        end

        task.spawn(function()
            while autoModesActive do
                pcall(function()
                    local inMode = Modes()

                    if not inMode and currentMode then
                        justLeftMode[currentMode] = os.time()
                        currentMode = nil
                        joiningMode = false
                    end

                    local best = GetHighestPriorityAvailable()

                    if not best then
                        task.wait(5)
                        return
                    end

                    if currentMode == best then
                        task.wait(5)
                        return
                    end

                    if currentMode and currentMode ~= best then
                        LeaveCurrentMode()
                        task.wait(2)
                        return
                    end

                    if not inMode and not joiningMode then
                        JoinMode(best)
                    end
                end)
                task.wait(3)
            end
        end)
    end,
}, "TOGGLE_AUTO_MODES")

GamemodeBox:CreateToggle({
    Name = "Auto Farm Modes",
    Icon = NebulaIcons:GetIcon('user-cog', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        modeFarm = Value
        if not Value then return end

        task.spawn(function()
            while modeFarm do
                if not Modes() then
                    task.wait(0.5)
                    continue
                end

                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then
                    task.wait(0.5)
                    continue
                end

                local expectedRaidId = currentMode and MODE_RAID_IDS[currentMode]

                local target = nil
                for _, enemy in ipairs(workspace:GetDescendants()) do
                    if enemy:IsA("Model") and enemy:GetAttribute("IsRaidEnemy") == true and enemy:GetAttribute("Attackable") == true then
                        local raidId = enemy:GetAttribute("RaidId")
                        if expectedRaidId and raidId and string.find(raidId, expectedRaidId) then
                            target = enemy
                            break
                        end
                    end
                end

                if target then
                    repeat
                        if not modeFarm or not target.Parent or target:GetAttribute("Attackable") == false then break end
                        if not Modes() then break end

                        local raidId = target:GetAttribute("RaidId")
                        if expectedRaidId and raidId and not string.find(raidId, expectedRaidId) then break end

                        char = LocalPlayer.Character
                        hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if not hrp then break end

                        hrp.CFrame = CFrame.new(target:GetPivot().Position + Vector3.new(0, 2.5, 2.5))

                        RunService.Heartbeat:Wait()
                    until target:GetAttribute("Attackable") == false or not target.Parent
                    task.wait(0.1)
                else
                    task.wait(0.5)
                end
            end
        end)
    end,
}, "TOGGLE_AUTO_FARM_MODES")

local hideNameActive = false
local hideNameConnections = {}
local fakeHideName = "YeahUsingScript"

if not getgenv().C then getgenv().C = {F = fakeHideName, D = fakeHideName} end

ConfigMisc:CreateInput({
    Name = "Set Name",
    Icon = NebulaIcons:GetIcon('user-pen', 'Lucide'),
    CurrentValue = "",
    PlaceholderText = "YeahUsingScript",
    Enter = true,
    Callback = function(Text)
        if Text and Text ~= "" then
            fakeHideName = Text
        end
    end,
}, "INPUT_HIDENAME_FAKE")

local function setupHideName()
    local l = LocalPlayer
    local char = l.Character or l.CharacterAdded:Wait()

    local function applyToChar(c)
        pcall(function()
            local titleGui = c:FindFirstChild("Head") and c.Head:FindFirstChild("PlayerTitleGui")
            if not titleGui then return end
            local playerLabel = titleGui:FindFirstChild("Frame") and titleGui.Frame:FindFirstChild("Player")
            if playerLabel then
                playerLabel.Text = fakeHideName
                table.insert(hideNameConnections, playerLabel:GetPropertyChangedSignal("Text"):Connect(function()
                    if playerLabel.Text ~= fakeHideName then
                        playerLabel.Text = fakeHideName
                    end
                end))
            end
        end)
    end

    applyToChar(char)
    table.insert(hideNameConnections, l.CharacterAdded:Connect(function(c)
        task.wait(0.5)
        applyToChar(c)
    end))
end

local function cleanupHideName()
    for _, conn in ipairs(hideNameConnections) do
        conn:Disconnect()
    end
    hideNameConnections = {}
end

ConfigMisc:CreateToggle({
    Name = "Hide Name",
    Icon = NebulaIcons:GetIcon('user-minus', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        hideNameActive = Value
        if Value then
            setupHideName()
        else
            cleanupHideName()
        end
    end,
}, "TOGGLE_HIDENAME")

local speedValue = 70
ConfigMisc:CreateInput({
    Name = "Set Speed",
    Icon = NebulaIcons:GetIcon('gauge', 'Lucide'),
    CurrentValue = "70",
    Numeric = true,
    Enter = true,
    MaxCharacters = 3,
    Callback = function(Text)
        speedValue = tonumber(Text) or 70
    end,
}, "INPUT_SPEED")

local applySpeedActive = false
ConfigMisc:CreateToggle({
    Name = "Apply Speed",
    Icon = NebulaIcons:GetIcon('zap', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        applySpeedActive = Value
        if not Value then return end
        task.spawn(function()
            while applySpeedActive do
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid.WalkSpeed = speedValue
                        end
                    end
                end)
                task.wait(0.1)
            end
        end)
    end,
}, "TOGGLE_APPLY_SPEED")

local antiAfkActive = false
ConfigMisc:CreateToggle({
    Name = "Anti AFK",
    Icon = NebulaIcons:GetIcon('shield-check', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        antiAfkActive = Value
    end,
}, "TOGGLE_ANTI_AFK")

local function simulateActivity()
    local camera = Workspace.CurrentCamera
    if not camera then return end
    
    VirtualUser:Button2Down(Vector2.zero, camera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.zero, camera.CFrame)
end

LocalPlayer.Idled:Connect(function()
    if antiAfkActive then
        simulateActivity()
        print("Null System • Player successfully un-idled ✓")
    end
end)

local afkModeEnabled = false
ConfigMisc:CreateToggle({
    Name = "Visual for AfkFarm",
    Icon = NebulaIcons:GetIcon('monitor-off', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        afkModeEnabled = Value
        
        if Value then
            local camera = workspace.CurrentCamera
            local Lighting = game:GetService("Lighting")
            
            local storedParts = {}
            local disabledLights = {}
            local disabledFX = {}
            local camConn, oldCamType, oldCamCFrame
            
            local function potatoWorld(enable)
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        if enable then
                            storedParts[v] = v.Material
                            v.Material = Enum.Material.Plastic
                            v.CastShadow = false
                        elseif storedParts[v] then
                            v.Material = storedParts[v]
                        end
                    elseif v:IsA("Texture") or v:IsA("Decal") then
                        v.Transparency = enable and 1 or 0
                    end
                end
                if not enable then storedParts = {} end
            end
            
            local function toggleShaders(enable)
                for _, v in ipairs(Lighting:GetChildren()) do
                    if v:IsA("BloomEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") then
                        v.Enabled = not enable
                    end
                end
            end
            
            local function toggleLights(enable)
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
                        if enable and v.Enabled then
                            disabledLights[v] = true
                            v.Enabled = false
                        elseif disabledLights[v] then
                            v.Enabled = true
                        end
                    end
                end
                if not enable then disabledLights = {} end
            end
            
            local function toggleFX(enable)
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") then
                        if enable and v.Enabled then
                            disabledFX[v] = true
                            v.Enabled = false
                        elseif disabledFX[v] then
                            v.Enabled = true
                        end
                    end
                end
                if not enable then disabledFX = {} end
            end
            
            local function lockCamera(enable)
                if enable then
                    oldCamType = camera.CameraType
                    oldCamCFrame = camera.CFrame
                    camera.CameraType = Enum.CameraType.Scriptable
                    camConn = RunService.RenderStepped:Connect(function()
                        camera.CFrame = CFrame.new(0, 999999, 0)
                    end)
                else
                    if camConn then camConn:Disconnect() end
                    camera.CameraType = oldCamType or Enum.CameraType.Custom
                    if oldCamCFrame then camera.CFrame = oldCamCFrame end
                end
            end
            
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            potatoWorld(true)
            toggleShaders(true)
            toggleLights(true)
            toggleFX(true)
            lockCamera(true)
            
            task.spawn(function()
                repeat task.wait() until not afkModeEnabled
                potatoWorld(false)
                toggleShaders(false)
                toggleLights(false)
                toggleFX(false)
                lockCamera(false)
            end)
        end
    end,
}, "TOGGLE_AFK_MODE")

local function applyFpsBooster()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.ShadowSoftness = 0
        if sethiddenproperty then
            sethiddenproperty(Lighting, "Technology", 2)
        end
    end)

    pcall(function()
        settings().Rendering.QualityLevel = 1
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
    end)

    pcall(function()
        for _, v in pairs(MaterialService:GetChildren()) do v:Destroy() end
        MaterialService.Use2022Materials = false
    end)

    pcall(function()
        if setfpscap then setfpscap(1e6) end
    end)

    pcall(function()
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
            if sethiddenproperty then
                sethiddenproperty(terrain, "Decoration", false)
            end
        end
    end)

    pcall(function()
        local energyFrame = LocalPlayer.PlayerGui.Main:FindFirstChild("EnergyFrame")
        if energyFrame then energyFrame:Destroy() end
    end)

    pcall(function()
        local damageAmount = game:GetService("ReplicatedStorage").BillboardGuis.HitPetGui.Holder:FindFirstChild("DamageAmount")
        if damageAmount then damageAmount:Destroy() end
    end)
end

ConfigMisc:CreateButton({
    Name = "FPS Booster",
    Icon = NebulaIcons:GetIcon('gauge', 'Lucide'),
    Style = 1,
    CenterContent = true,
    Callback = function()
        applyFpsBooster()
        for _, v in pairs(game:GetDescendants()) do
            processInstance(v)
        end
        game.DescendantAdded:Connect(function(v)
            task.wait(0.5)
            processInstance(v)
        end)
    end,
}, "BTN_FPS_BOOSTER")

Starlight:OnDestroy(function()
    print("Null System • Script Deleted")
end)

Starlight:LoadAutoloadConfig()
Starlight:LoadAutoloadTheme()
Starlight:Notification({
    Title = "Script Status",
    Icon = "114022464350371",
    Duration = 5,
    Content = " • You're now using NullHub, baby.\n • Script loaded Successfully."
}, "SCTS")
print("Null System • Script Loaded!")