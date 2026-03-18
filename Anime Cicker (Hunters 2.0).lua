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
    Icon = "114022464350371", --"115111586638831", --"136362783020632",  --"116180233441379", --"101497542169555", --"77933017176374", --"125967972654762",
    DefaultSize = UDim2.fromOffset(540, 540),
    PlayerInfoBlur = true,
    PlayerStatus = true,
    BuildWarnings = true,
    InterfaceAdvertisingPrompts = true,
    NotifyOnCallbackError = true,
    LoadingEnabled = true,
    
    LoadingSettings = {
        Title = "Null Hub Entertainments",
        Subtitle = "Welcome to Null Hub, Baby.",
    },
  
    FileSettings = {
        ConfigFolder = "NullHub - " .. GameName,
    },
})

local MS = Window:CreateTabSection("MAIN")
local SS = Window:CreateTabSection("SETTINGS")

local MainTab = MS:CreateTab({
    Name = "| Main",
    Icon = "114022464350371",
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
    Icon = "114022464350371",
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

local function removeNotifications()
    local notifications = LocalPlayer.PlayerGui:WaitForChild("Plus"):WaitForChild("Notifications")
    for _, desc in ipairs(notifications:GetDescendants()) do
        if desc:IsA("TextLabel") and desc.Name == "Description" then
            if string.find(desc.Text, "You don't have enough") then
                desc.Parent.Parent:Destroy()
            end
        end
    end
end

local GAME_MODES = {"Dungeon Easy", "Dungeon Medium", "Raid", "Trial Easy", "Trial Medium", "Infinite Castle"}

local function Modes(mode)
    local hud = LocalPlayer.PlayerGui:FindFirstChild("UI", true)
    hud = hud and hud:FindFirstChild("HUD", true)
    local gamemodes = hud and hud:FindFirstChild("Gamemodes", true)
    if not gamemodes then return false end

    if mode then
        local frame = gamemodes:FindFirstChild(mode, true)
        return frame ~= nil and frame.Visible
    end

    for _, name in ipairs(GAME_MODES) do
        local frame = gamemodes:FindFirstChild(name, true)
        if frame and frame.Visible then return true end
    end

    return false
end

local function GetUniqueEnemyNames()
    local names = {}
    for _, enemy in ipairs(workspace.Server:GetDescendants()) do
        if enemy:IsA("BasePart") and enemy:GetAttribute("Health") and enemy:GetAttribute("ID") then
            names[enemy.Name] = true
        end
    end
    
    local uniqueList = {}
    for name in pairs(names) do
        table.insert(uniqueList, name)
    end
    return uniqueList
end

local function getEnemyIDsInRadius(maxDist)
    local ids = {}
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return ids end
    
    local rootPos = root.Position
    for _, enemy in ipairs(workspace.Server:GetDescendants()) do
        if enemy:IsA("BasePart") and enemy:GetAttribute("ID") and enemy:GetAttribute("Died") ~= true then
            local id = enemy:GetAttribute("ID")
            local distance = (rootPos - enemy.Position).Magnitude
            if distance <= maxDist then
                table.insert(ids, id)
            end
        end
    end
    
    return ids
end

local farmRunning = false
local selectedNpcNames = {}
local priorityEnemyNames = {}
local currentTargetID = nil

local NpcAutoFarm = AutoFarmBox:CreateToggle({
    Name = "Auto Farm Enemy",
    Icon = NebulaIcons:GetIcon('user-cog', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        farmRunning = Value
        if Value then 
          Starlight.Window.SetPlayerStatus("Farming")
          else
          Starlight.Window.SetPlayerStatus("Running")
        end
        
        if not Value then
            currentTargetID = nil
            return
        end
        
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

                local hasPriorityAlive = false
                if priorityEnemyNames and #priorityEnemyNames > 0 then
                    for _, enemy in ipairs(workspace.Server:GetDescendants()) do
                        if enemy:IsA("BasePart") and table.find(priorityEnemyNames, enemy.Name) and enemy:GetAttribute("Died") ~= true then
                            hasPriorityAlive = true
                            break
                        end
                    end
                end

                local namesToFarm = hasPriorityAlive and priorityEnemyNames or selectedNpcNames
                for _, enemyName in ipairs(namesToFarm) do
                    if not farmRunning then break end
                    
                    local target = nil
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then continue end
                    
                    for _, enemy in ipairs(workspace.Server:GetDescendants()) do
                        if enemy:IsA("BasePart") and enemy.Name == enemyName and enemy:GetAttribute("Died") ~= true and enemy:GetAttribute("Health") and enemy:GetAttribute("ID") then
                            target = enemy
                            break
                        end
                    end

                    if target then
                        currentTargetID = target:GetAttribute("ID")
                        repeat
                            if not farmRunning or not target.Parent or target:GetAttribute("Died") == true then break end
                            if priorityEnemyNames and #priorityEnemyNames > 0 and not table.find(priorityEnemyNames, enemyName) then
                                local prioritySpawned = false
                                for _, enemy in ipairs(workspace.Server:GetDescendants()) do
                                    if enemy:IsA("BasePart") and table.find(priorityEnemyNames, enemy.Name) and enemy:GetAttribute("Died") ~= true then
                                        prioritySpawned = true
                                        break
                                    end
                                end
                                if prioritySpawned then break end
                            end

                            char = LocalPlayer.Character
                            hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if not hrp then break end
                            hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 2.5, 2.5))
                            
                            RunService.Heartbeat:Wait()
                        until target:GetAttribute("Died") == true or not target.Parent
                        currentTargetID = nil
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

local rp = game:GetService("ReplicatedStorage").Remotes.Signal
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
                  local targetIDs = {}
                  if currentTargetID then
                      table.insert(targetIDs, currentTargetID)
                  else
                      targetIDs = getEnemyIDsInRadius(15)
                  end
                  if #targetIDs > 0 then
                        for _, id in ipairs(targetIDs) do
                            rp:FireServer("General", "Attack", "Click", id)
                            rp:FireServer("General", "Attack", "FirstShinobi", id)
                        end
                    else
                      rp:FireServer("General", "Attack", "Click")
                  end
                end)
                RunService.Heartbeat:Wait()
            end
        end)
    end,
}, "TOGGLE_AUTOCLICK")

local upp = false
local up1 = Pl:CreateToggle({
    Name = "Auto Rankup",
    Icon = NebulaIcons:GetIcon('panel-bottom-open', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        upp = Value
        if not Value then return end
        task.spawn(function()
            while upp do
                pcall(function()
                local args = {"General", "RankUp", "Upgrade"}
                rp:FireServer(unpack(args))
                end)
                RunService.Heartbeat:Wait()
            end
        end)
    end,
}, "TOGGLE_RANKUP")

local AUTOTR = false
Pl:CreateToggle({
    Name = "Auto Collect TimeRewards",
    Icon = NebulaIcons:GetIcon('calendar-check', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        AUTOTR = Value
        if not Value then return end
        task.spawn(function()
            while AUTOTR do
                pcall(function()
                    local holder = LocalPlayer.PlayerGui.UI.Frames.TimeRewards.Background.Holder
                    for i = 1, 7 do
                    local btn = holder:FindFirstChild(tostring(i))
                    if btn and btn:FindFirstChild("Button") and btn.Button:FindFirstChild("CanClaim") then
                        if btn.Button.CanClaim.Visible then
                            local args = {"General", "TimeRewards", "Claim", i}
                            rp:FireServer(unpack(args))
                            task.wait(0.1)
                          end
                      end
                  end
                end)
                RunService.Heartbeat:Wait()
            end
        end)
    end,
}, "TOGGLE_AUTOTR")

local CODES = {"DAILYREWARD9", "TELEPORTFIX", "THX5MVISITS", "DAILYREWARD9", "DAILYREWARD8", "MINIUPD2.5", "DAILYREWARD7", "20KLIKES", "UPD2.2QOL", "DAILYREWARD6", "UPD2QOL", "AVATARBUGS", "RELEASE", "TESTERREWARD", "1KLIKES", "5KMEMBERSDC", "SRRY4DELAY", "5KFAVS", "RAIDTELEPORT", "ACCESSORYTYPE", "FIXEDMERCHANT", "THX4KACTIVES", "2.5KLIKES", "FIXEDINDEX", "THX5KACTIVES", "SRRY4SHUTDOWN", "PASSIVEUPDATE", "UPDATE1", "5KLIKES", "4KFAVORITES", "LEVELUPGRADEFIXED", "10KLIKES", "AVATARBUGS", "10KLIKES", "5KFAVS", "DAILYREWARD", "POWERARENA", "SORRYFORDELAY", "FIXEDMOBILE", "DAILYREWARD3", "DAILYREWARD2", "DAILYREWARD4", "15KLIKES", "THX8KACTIVES", "DAILYREWARD5", "GACHIAKUTA", "GACHIAKUTADELAY", "THX10KACTIVES", "RELEASEPART2", "THEDEVGOAT", "FIXEDPASSIVEINTERACT"}
Pl:CreateButton({
    Name = "Redeem Codes",
    Icon = NebulaIcons:GetIcon('book-copy', 'Lucide'),
    Style = 1,
    CenterContent = true,
    Callback = function()
        for _, code in ipairs(CODES) do
            rp:FireServer("General", "Codes", "Claim", code)
        end
    end,
}, "BB_CODES")

local stars = {}
for _, star in ipairs(game:GetService("ReplicatedStorage").Shared.Stars:GetChildren()) do
    table.insert(stars, star.Name)
end

local petroll = stars[1] or ""
local autopetroll = false
local AutoPet = Up:CreateToggle({
    Name = "Star Roll",
    Icon = NebulaIcons:GetIcon('star', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autopetroll = Value
        if not Value then return end
        task.spawn(function()
            while autopetroll do
                pcall(function()
                    local args = {"General", "Stars", "Multi", petroll}
                    rp:FireServer(unpack(args))
                end)
                RunService.Heartbeat:Wait()
            end
        end)
    end,
}, "TOGGLE_PETROLL")

AutoPet:AddDropdown({
    Options = stars,
    CurrentOptions = {stars[1]},
    Callback = function(Options)
        petroll = Options[1]
    end,
}, "DD_PETROLL")

local selectedStat = "Power"
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
                        rp:FireServer("General", "LevelUpgrades", "Upgrade", selectedStat, 1)
                    end)
                end
                RunService.Heartbeat:Wait()
            end
        end)
    end,
}, "TOGGLE_Up2")

up2:AddDropdown({
    Options = {"Power", "Stars", "Luck", "Damage", "Exp"},
    CurrentOptions = {"Power"},
    Callback = function(Options)
        selectedStat = Options[1] or "Power"
    end,
}, "DD_UP2")

local gachasFolder = game:GetService("ReplicatedStorage").Shared.Gachas
local gachaNames = {}
for _, child in ipairs(gachasFolder:GetChildren()) do
    table.insert(gachaNames, child.Name)
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
                            rp:FireServer("General", "Gacha", "Roll", gacha, {})
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

local ProgressionsFolder = game:GetService("ReplicatedStorage").Shared.Progressions
local ProNames = {}
for _, child in ipairs(ProgressionsFolder:GetChildren()) do
    table.insert(ProNames, child.Name)
end

local selectedPro = {}
local upp4 = false
local up4 = Up:CreateToggle({
    Name = "Auto Progression",
    Icon = NebulaIcons:GetIcon('circle-fading-arrow-up', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        upp4 = Value
        if not Value then return end
        task.spawn(function()
          while upp4 do
              if selectedPro and #selectedPro > 0 then
                  for _, Progression in ipairs(selectedPro) do
                      if not upp4 then break end
                      pcall(function()
                          rp:FireServer("General", "Progressions", "Upgrade", Progression)
                      end)
                      task.wait(0.1)
                  end
              end
              RunService.Heartbeat:Wait()
          end
       end)
    end,
}, "TOGGLE_Up4")

up4:AddDropdown({
    Options = ProNames,
    CurrentOptions = {},
    MultipleOptions = true,
    Callback = function(Options)
        selectedPro = Options or {}
    end,
}, "DD_UP4")

local selectedShinobiStat = "Attack Speed"
local autoShinobiUpgrade = false
local ShinobiUpgrade = Up:CreateToggle({
    Name = "Auto Shinobi Upgrades",
    Icon = NebulaIcons:GetIcon('sword', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autoShinobiUpgrade = Value
        if not Value then return end
        task.spawn(function()
            while autoShinobiUpgrade do
                pcall(function()
                    rp:FireServer("General", "ShinobiUpgrades", "Upgrade", selectedShinobiStat)
                end)
                RunService.Heartbeat:Wait()
            end
        end)
    end,
}, "TOGGLE_SHINOBI_UPGRADE")

ShinobiUpgrade:AddDropdown({
    Options = {"Attack Speed", "Damage", "Range"},
    CurrentOptions = {"Attack Speed"},
    Callback = function(Options)
        selectedShinobiStat = Options[1] or "Attack Speed"
    end,
}, "DD_SHINOBI_STAT")

local timemodes = GamemodeBox:CreateParagraph({
    Name = "Timers",
    Icon = NebulaIcons:GetIcon('clock-fading', 'Lucide'),
    Content = "Carregando...",
}, "PARA_MODES")

local function updateEventParagraph(paragraph, hour, min, sec)
    local function timeToNext(minuteMarks)
        table.sort(minuteMarks)
        for _, mark in ipairs(minuteMarks) do
            if min < mark or (min == mark and sec == 0) then
                local m = mark - min
                local s = (60 - sec) % 60
                if s == 0 then s = 0 else m = m - 1 end
                if m < 0 then m = m + 60 end
                return string.format("%02d:%02d", m, s)
            end
        end
        local m = 60 - min + minuteMarks[1]
        local s = (60 - sec) % 60
        if s == 0 then s = 0 else m = m - 1 end
        return string.format("%02d:%02d", m, s)
    end

    local raidTimer = timeToNext({15, 45})
    local easyTimer = timeToNext({0})
    local mediumTimer = timeToNext({30})
    local TeasyTimer = timeToNext({5,35})
    local TmediumTimer = timeToNext({25,55})

    local text =
        "Dungeon Easy Open: XX:00\nNext In: " .. easyTimer .. "\n" ..
        "Dungeon Medium Open: XX:30\nNext In: " .. mediumTimer .. "\n" ..
        "Trial Easy Open: XX:05 & XX:35\nNext In: " .. TeasyTimer .. "\n" ..
        "Trial Medium Open: XX:25 & XX:55\nNext In: " .. TmediumTimer .. "\n" ..
        "Raids Open: XX:15 & XX:45\nNext In: " .. raidTimer

    paragraph:Set({Content = text})
end

local now = os.date("!*t")
updateEventParagraph(timemodes, now.hour, now.min, now.sec)

task.spawn(function()
    while true do
        local now = os.date("!*t")
        updateEventParagraph(timemodes, now.hour, now.min, now.sec)
        task.wait(1)
    end
end)

GamemodeBox:CreateDivider()

GamemodeBox:CreateParagraph({
    Name = "Info",
    Icon = NebulaIcons:GetIcon('settings', 'Lucide'),
    Content = "- Auto Setup applies damage setup when joining modes.\n- After leaving, it applies the best or full power setup.\n- Modes Priority\nTrials > Raid > Infinite Castle",
}, "PARA_INFOMODES")

GamemodeBox:CreateDivider()

local lveasy = ""
local lvmedium = ""
local lvraid = ""
local lvtrialeasy = ""
local lvtrialmedium = ""
local lvinfinitecastle = ""
local selectedMap = ""
local hasJustTeleported = false
local autoSetup = false

local SvPosition = nil
local PositionParagraph = SV:CreateParagraph({
    Name = "Saved Position",
    Icon = NebulaIcons:GetIcon('map-pinned', 'Lucide'),
    Content = "No position saved yet",
}, "PARA_SAVED_POS")

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
            PositionParagraph:Set({Content = string.format("X: %.2f, Y: %.2f, Z: %.2f", SvPosition.X, SvPosition.Y, SvPosition.Z)})
        end
    end,
}, "BTN_SAVE_POS")

local maps = {}
local excludedMaps = {"Trials", "Raid", "Infinite Castle"}
for _, folder in ipairs(workspace.Client.Maps:GetChildren()) do
    if folder:IsA("Folder") then
        local shouldExclude = false
        for _, excluded in ipairs(excludedMaps) do
            if folder.Name == excluded then
                shouldExclude = true
                break
            end
        end
        if not shouldExclude then
            table.insert(maps, folder.Name)
        end
    end
end

local MapLabel = SV:CreateLabel({
    Name = "Map to Leave",
    Icon = NebulaIcons:GetIcon('map', 'Lucide'),
}, "LABEL_MAP")

MapLabel:AddDropdown({
    Options = maps,
    CurrentOptions = {},
    Placeholder = "Select Map",
    Callback = function(Options)
        selectedMap = Options[1] or ""
    end,
}, "DD_MAP_SELECT")

local function equipAllDamage()
    pcall(function()
        game:GetService("ReplicatedStorage").Remotes.Signal:FireServer("General", "StatusBest", "Best", "Damage")
    end)
end

local function equipAllPower()
    pcall(function()
        game:GetService("ReplicatedStorage").Remotes.Signal:FireServer("General", "StatusBest", "Best", "Power")
    end)
end

local function tpback()
    if hasJustTeleported then return end
    hasJustTeleported = true
    if SvPosition then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Signal"):FireServer("General", "Teleport", "Teleport", selectedMap)
            end)
            task.wait(0.5)
            hrp.CFrame = CFrame.new(SvPosition)
            if autoSetup then
                equipAllPower()
            end
            hasJustTeleported = false
        end
    end
end

Gm:CreateInput({
    Name = "Set Room - Dungeon Easy",
    Icon = NebulaIcons:GetIcon('text-cursor-input', 'Lucide'),
    CurrentValue = "",
    Numeric = true,
    Enter = true,
    MaxCharacters = 30,
    Callback = function(Text)
        lveasy = Text
    end,
}, "INPUT_LEAVE_EASY")

Gm:CreateInput({
    Name = "Set Room - Dungeon Medium",
    Icon = NebulaIcons:GetIcon('text-cursor-input', 'Lucide'),
    CurrentValue = "",
    Numeric = true,
    Enter = true,
    MaxCharacters = 30,
    Callback = function(Text)
        lvmedium = Text
    end,
}, "INPUT_LEAVE_MEDIUM")

Gm:CreateInput({
    Name = "Set Wave - Raid",
    Icon = NebulaIcons:GetIcon('text-cursor-input', 'Lucide'),
    CurrentValue = "",
    Numeric = true,
    Enter = true,
    MaxCharacters = 30,
    Callback = function(Text)
        lvraid = Text
    end,
}, "INPUT_LEAVE_RAID")

Gm:CreateInput({
    Name = "Set Room - Trial Easy",
    Icon = NebulaIcons:GetIcon('text-cursor-input', 'Lucide'),
    CurrentValue = "",
    Numeric = true,
    Enter = true,
    MaxCharacters = 30,
    Callback = function(Text)
        lvtrialeasy = Text
    end,
}, "INPUT_LEAVE_TRIAL_EASY")

Gm:CreateInput({
    Name = "Set Room - Trial Medium",
    Icon = NebulaIcons:GetIcon('text-cursor-input', 'Lucide'),
    CurrentValue = "",
    Numeric = true,
    Enter = true,
    MaxCharacters = 30,
    Callback = function(Text)
        lvtrialmedium = Text
    end,
}, "INPUT_LEAVE_TRIAL_MEDIUM")

local AutoLeaveAll = false
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
                    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                    if not playerGui then return end
                    local hud = playerGui:FindFirstChild("UI") and playerGui.UI:FindFirstChild("HUD")
                    if not hud then return end
                    local gamemodes = hud:FindFirstChild("Gamemodes")
                    if not gamemodes then return end

                    local inMode = Modes()

                    if inMode then
                        wasInMode = true
                    elseif wasInMode and not inMode then
                        wasInMode = false
                        tpback()
                        return
                    end

                    local function checkAndLeave(modeName, valuePath, inputVar)
                        if not Modes(modeName) then return end
                        if not inputVar or inputVar == "" then return end

                        local frame = gamemodes:FindFirstChild(modeName)
                        if not frame then return end

                        local valueLabel = frame
                        for _, key in ipairs(valuePath) do
                            valueLabel = valueLabel:FindFirstChild(key)
                            if not valueLabel then return end
                        end

                        local current = tonumber(string.match(valueLabel.Text, "%d+"))
                        if current and current == tonumber(inputVar) then
                            wasInMode = false
                            tpback()
                        end
                    end

                    checkAndLeave("Raid",           {"Wave", "Value"},  lvraid)
                    checkAndLeave("Dungeon Easy",   {"Rooms", "Value"}, lveasy)
                    checkAndLeave("Dungeon Medium", {"Rooms", "Value"}, lvmedium)
                    checkAndLeave("Trial Easy",     {"Rooms", "Value"}, lvtrialeasy)
                    checkAndLeave("Trial Medium",   {"Rooms", "Value"}, lvtrialmedium)

                    if not inMode then
                        hasJustTeleported = false
                    end
                end)
                task.wait(0.5)
            end
        end)
    end,
}, "TOGGLE_AUTOLEAVE")

local MODE_PRIORITIES = {"Trial Easy", "Trial Medium", "Raid", "Infinite Castle"}

local MODE_SCHEDULES = {
    ["Trial Easy"]      = {minutes = {5, 35}},
    ["Trial Medium"]    = {minutes = {25, 55}},
    ["Raid"]            = {minutes = {15, 45}},
    ["Infinite Castle"] = {always = true}
}

local selectedModes = {}
local currentMode = nil
local autoModesActive = false
local justLeftMode = {}
local joiningMode = false

local function IsAvailable(modeName)
    local schedule = MODE_SCHEDULES[modeName]
    if not schedule then return false end
    if schedule.always then return true end
    local min = os.date("*t").min
    if schedule.minutes then
        return table.find(schedule.minutes, min) ~= nil
    end
    return false
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

local function LeaveCurrentMode()
    if not currentMode then return end
    tpback()
    justLeftMode[currentMode] = os.time()
    currentMode = nil
    joiningMode = false
end

local function JoinMode(modeName)
    if joiningMode then return end
    joiningMode = true

    if autoSetup then equipAllDamage() end
    task.wait(0.5)

    if modeName == "Infinite Castle" then
        rp:FireServer("Gamemodes", "Infinite Castle", "Start_Queue", 1)
    else
        rp:FireServer("Gamemodes", modeName, "Join")
    end

    task.wait(1)
    currentMode = modeName
    joiningMode = false
end

local ModeLabel = GamemodeBox:CreateLabel({
    Name = "Select Gamemodes",
    Icon = NebulaIcons:GetIcon('list', 'Phosphor'),
}, "LABEL_MODES")

ModeLabel:AddDropdown({
    Options = {"Trial Easy", "Trial Medium", "Raid", "Infinite Castle"},
    CurrentOptions = {},
    Placeholder = "Select Modes",
    MultipleOptions = true,
    Callback = function(Options)
        selectedModes = Options or {}
    end,
}, "DD_MODES")

GamemodeBox:CreateToggle({
    Name = "Auto Join Modes",
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

Gm:CreateInput({
    Name = "Auto Retry - Infinite Castle",
    Icon = NebulaIcons:GetIcon('refresh-cw', 'Lucide'),
    CurrentValue = "",
    Numeric = true,
    Enter = true,
    Callback = function(Text)
        lvinfinitecastle = Text
    end,
}, "INPUT_RETRY_INFINITE")

local autoRetryActive = false
Gm:CreateToggle({
    Name = "Auto Retry",
    Icon = NebulaIcons:GetIcon('refresh-cw', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autoRetryActive = Value
        if not Value then return end
        
        task.spawn(function()
            while autoRetryActive do
                pcall(function()
                    if currentMode ~= "Infinite Castle" then return end
                    if not lvinfinitecastle or lvinfinitecastle == "" then return end
                    
                    local hud = LocalPlayer.PlayerGui:FindFirstChild("UI") and LocalPlayer.PlayerGui.UI:FindFirstChild("HUD")
                    if not hud then return end
                    
                    local gamemodes = hud:FindFirstChild("Gamemodes")
                    if not gamemodes then return end
                    
                    local modeFrame = gamemodes:FindFirstChild("Infinite Castle")
                    if not modeFrame or not modeFrame.Visible then return end
                    
                    local retryBtn = modeFrame:FindFirstChild("Buttons") and modeFrame.Buttons:FindFirstChild("Retry")
                    if not retryBtn then return end
                    
                    local waveLabel = modeFrame:FindFirstChild("Wave")
                    if not waveLabel or not waveLabel:FindFirstChild("Value") then return end
                    
                    local currentWave = tonumber(string.match(waveLabel.Value.Text, "%d+"))
                    
                    if currentWave and currentWave == tonumber(lvinfinitecastle) then
                        firesignal(retryBtn.MouseButton1Click)
                    end
                end)
                task.wait(1)
            end
        end)
    end,
}, "TOGGLE_AUTO_RETRY")

GamemodeBox:CreateToggle({
    Name = "Auto Setup",
    Icon = NebulaIcons:GetIcon('settings-2', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autoSetup = Value
    end,
}, "TOGGLE_AUTOSETUP")

local modeFarm = false
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

                local target = nil
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then
                    task.wait(0.5)
                    continue
                end

                for _, enemy in ipairs(workspace.Server:GetDescendants()) do
                    if enemy:IsA("BasePart") and enemy:GetAttribute("Mode") and enemy:GetAttribute("Died") ~= true and enemy:GetAttribute("Health") and enemy:GetAttribute("ID") then
                        target = enemy
                        break
                    end
                end

                if target then
                    repeat
                        if not modeFarm or not target.Parent or target:GetAttribute("Died") == true then break end
                        if not Modes() then break end

                        char = LocalPlayer.Character
                        hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if not hrp then break end

                        hrp.CFrame = target.CFrame * CFrame.new(0, 2.5, 2.5)

                        RunService.Heartbeat:Wait()
                    until target:GetAttribute("Died") == true or not target.Parent

                    task.wait(0.1)
                else
                    task.wait(0.5)
                end
            end
        end)
    end,
}, "TOGGLE_AUTO_FARM_MODES")

local nameSpoof = false
local spoofConnections = {}
local fakeName = "YeahUsingScript"
if not getgenv().C then getgenv().C = {F = fakeName, D = fakeName} end

ConfigMisc:CreateInput({
    Name = "Fake Name",
    Icon = NebulaIcons:GetIcon('user-pen', 'Lucide'),
    CurrentValue = "",
    PlaceholderText = "YeahUsingScript",
    Enter = true,
    Callback = function(Text)
        if Text and Text ~= "" then
            fakeName = Text
            getgenv().C.F = Text
            getgenv().C.D = Text
        end
    end,
}, "INPUT_FAKENAME")

local function setupSpoof()
    local Players = game:GetService("Players")
    local l = Players.LocalPlayer
    local n = l.Name
    local d = l.DisplayName

    local function replace(t)
        t = string.gsub(t, n, getgenv().C.F)
        t = string.gsub(t, d, getgenv().C.D)
        return t
    end

    local function hookText(o)
        if not (o:IsA("TextBox") or o:IsA("TextLabel") or o:IsA("TextButton")) then return end
        o.Text = replace(o.Text)
        o.Name = replace(o.Name)
        table.insert(spoofConnections, o.Changed:Connect(function(x)
            if x == "Text" then o.Text = replace(o.Text)
            elseif x == "Name" then o.Name = replace(o.Name) end
        end))
    end

    for _, v in next, game:GetDescendants() do hookText(v) end
    table.insert(spoofConnections, game.DescendantAdded:Connect(hookText))

    pcall(function() l.DisplayName = getgenv().C.D end)

    table.insert(spoofConnections, RunService.Heartbeat:Connect(function()
        if not nameSpoof then return end
        local c = l.Character
        if not c then return end
        for _, v in pairs(c:GetDescendants()) do
            if v:IsA("BillboardGui") and v.Name == "NameTag" then
                for _, b in pairs(v:GetDescendants()) do
                    if b:IsA("TextLabel") then b.Text = getgenv().C.F end
                end
            end
        end
    end))
end

local function cleanupSpoof()
    for _, conn in ipairs(spoofConnections) do
        conn:Disconnect()
    end
    spoofConnections = {}
end

ConfigMisc:CreateToggle({
    Name = "Name Spoof",
    Icon = NebulaIcons:GetIcon('user-x', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        nameSpoof = Value
        if Value then
            setupSpoof()
        else
            cleanupSpoof()
        end
    end,
}, "TOGGLE_NAMESPOOF")

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

LocalPlayer.CharacterAdded:Connect(function(char)
    if applySpeedActive then
        task.wait(0.5)
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speedValue
        end
    end
end)

local afkModeEnabled = false
ConfigMisc:CreateToggle({
    Name = "AFK Mode",
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

Starlight:OnDestroy(function()
    print("Script Deleted")
end)

Starlight:LoadAutoloadConfig()
Starlight:LoadAutoloadTheme()
Starlight:Notification({
    Title = "Script Status",
    Icon = "114022464350371",
    Duration = 5,
    Content = "You're now using NullHub, Baby.\nScript loaded Successfully."
}, "SCTS")
print("Script Loaded!")