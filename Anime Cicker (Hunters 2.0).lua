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

local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

MarketplaceService = game:GetService("MarketplaceService")
PlaceId = game.PlaceId
ProductInfo = MarketplaceService:GetProductInfo(PlaceId)
GameName = ProductInfo.Name

local Window = Starlight:CreateWindow({
    Name = string.format("NullHub [%s] [%s]", device, executor),
    Subtitle = GameName,
    Icon = "114022464350371", --"115111586638831", --"136362783020632",  --"116180233441379", --"101497542169555", --"77933017176374", --"125967972654762",
    DefaultSize = UDim2.fromOffset(540, 540),
    BuildWarnings = true,
    InterfaceAdvertisingPrompts = true,
    NotifyOnCallbackError = true,
    LoadingEnabled = false,
    
    FileSettings = {
        ConfigFolder = "NullHub - " .. GameName,
    },
})

local MS = Window:CreateTabSection("MAIN")
local SS = Window:CreateTabSection("SETTINGS")

local MainTab = MS:CreateTab({
    Name = "| Main",
    Icon = "114022464350371", --115111586638831", --77630928106024,
    Columns = 1,
}, "TAB_MAIN")
               --Groupboxs--
local AutoFarmBox = MainTab:CreateGroupbox({
    Name = "Auto Farm",
    Icon = NebulaIcons:GetIcon('refresh-ccw-dot', 'Lucide'),
    Column = 1,
}, "GB_AUTOFARM")
              --Groupboxs--
local Pl = MainTab:CreateGroupbox({
    Name = "Player",
    Icon = NebulaIcons:GetIcon('user', 'Lucide'),
    Column = 1,
}, "GB_PLMISC")

local Up = MainTab:CreateGroupbox({
    Name = "Units|Upgrades|Gachas",
    Icon = NebulaIcons:GetIcon('diamond-plus', 'Lucide'),
    Column = 1,
}, "GB_UPGRADES")

local GMS = MS:CreateTab({
    Name = "| Gamemodes",
    Icon = "114022464350371", --"115111586638831", --77630928106024,
    Columns = 1,
}, "TAB_GM")
              --Groupboxs--
local GamemodeBox = GMS:CreateGroupbox({
    Name = "Auto Modes",
    Icon = NebulaIcons:GetIcon('sword', 'Phosphor'),
    Column = 1,
}, "GB_AUTOFARMMODES")

local SV = GMS:CreateGroupbox({
    Name = "Save Position",
    Icon = NebulaIcons:GetIcon('map', 'Phosphor'),
    Column = 1,
}, "GB_SVMODES")

local Gm = GMS:CreateGroupbox({
    Name = "Join/Leave",
    Icon = NebulaIcons:GetIcon('sword', 'Phosphor'),
    Column = 1,
}, "GB_JLMODES")

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

if not getgenv().C then getgenv().C={F="YeahUsingScript",D="YeahUsingScript"} end
local p=game:GetService('Players') local l=p.LocalPlayer local n=l.Name local d=l.DisplayName
local function r(t) t=t or"" t=string.gsub(t,n,getgenv().C.F) t=string.gsub(t,d,getgenv().C.D) return t end
local function f(o)
    if o:IsA("TextBox") or o:IsA("TextLabel") or o:IsA("TextButton") then
        o.Text=r(o.Text) o.Name=r(o.Name)
        o.Changed:Connect(function(x)if x=="Text"then o.Text=r(o.Text)elseif x=="Name"then o.Name=r(o.Name)end end)
    end
end
for _,v in next,game:GetDescendants()do f(v)end
game.DescendantAdded:Connect(f)
pcall(function()l.DisplayName=getgenv().C.D end)
task.spawn(function()
    local tcs=game:GetService("TextChatService")
    if tcs and tcs.ChatVersion==Enum.ChatVersion.TextChatService then
        tcs.OnIncomingMessage=tcs.OnIncomingMessage:Connect(function(m)
            if m.TextSource and m.TextSource.UserId==l.UserId then
                m.PrefixText="["..getgenv().C.F.."] " m.Text=string.gsub(m.Text,n,getgenv().C.F)
            end
        end)
    else
        local ch=game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if ch and ch:FindFirstChild("OnMessageDoneFiltering") then
            ch.OnMessageDoneFiltering.OnClientEvent:Connect(function(d)
                if d.FromSpeaker==l.Name then d.FromSpeaker=getgenv().C.F end
            end)
        end
    end
end)
task.spawn(function()
    while task.wait()do
        local c=l.Character or l.CharacterAdded:Wait()
        for _,v in pairs(c:GetDescendants())do
            if v:IsA("BillboardGui")and v.Name=="NameTag"then
                for _,b in pairs(v:GetDescendants())do
                    if b:IsA("TextLabel")then b.Text=getgenv().C.F end
                end
            end
        end
    end
end)

Theme:BuildThemeGroupbox(1)
Config:BuildConfigGroupbox(1)

local textsToFind = {
    "[RANK UP] You don't have enough Power!",
    "You don't have enough points!",
    "[RANK UP] You don't have enough Crystals!"
}
local function removeNotifications()
    local player = game:GetService("Players").LocalPlayer
    local notifications = player.PlayerGui:WaitForChild("Plus"):WaitForChild("Notifications")
    
    for _, desc in ipairs(notifications:GetDescendants()) do
        if desc:IsA("TextLabel") and desc.Name == "Description" then
            for _, txt in ipairs(textsToFind) do
                if desc.Text == txt then
                    desc:Destroy()
                end
            end
        end
    end
end

local function Modes(mode)
    local player = game:GetService("Players").LocalPlayer
    local gui = player.PlayerGui:FindFirstChild("UI", true)
    local hud = gui and gui:FindFirstChild("HUD", true)
    local gamemodes = hud and hud:FindFirstChild("Gamemodes", true)
    if not gamemodes then return false end

    if mode == "Dungeon Easy" or mode == "Dungeon Medium" or mode == "Raid" or mode == "Trial Easy" or mode == "Trial Medium" or mode == "Infinite Castle" then
        local frame = gamemodes:FindFirstChild(mode, true)
        return frame and frame.Visible or false
    else
        local easy = gamemodes:FindFirstChild("Dungeon Easy", true)
        local medium = gamemodes:FindFirstChild("Dungeon Medium", true)
        local raid = gamemodes:FindFirstChild("Raid", true)
        local TMedium = gamemodes:FindFirstChild("Trial Easy", true)
        local Teasy = gamemodes:FindFirstChild("Trial Medium", true)
        local infcastle = gamemodes:FindFirstChild("Infinite Castle", true)
        return (easy and easy.Visible) or (medium and medium.Visible) or (raid and raid.Visible) or (TMedium and TMedium.Visible) or (Teasy and Teasy.Visible) or (infcastle and infcastle.Visible) or false
    end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

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
    Icon = NebulaIcons:GetIcon('sword', 'Phosphor'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        farmRunning = Value
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
                            rp:FireServer("General", "Attack", "FirstShinigami", id)
                            rp:FireServer("General", "Attack", "FirstShadow", id)
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
    Icon = NebulaIcons:GetIcon('package-open', 'Lucide'),
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
                removeNotifications()
                end)
                RunService.Heartbeat:Wait()
            end
        end)
    end,
}, "TOGGLE_RANKUP")

local CODES = {"DAILYREWARD9", "TELEPORTFIX", "THX5MVISITS", "DAILYREWARD9", "DAILYREWARD8", "MINIUPD2.5", "DAILYREWARD7", "20KLIKES", "UPD2.2QOL", "DAILYREWARD6", "UPD2QOL", "AVATARBUGS", "RELEASE", "TESTERREWARD", "1KLIKES", "5KMEMBERSDC", "SRRY4DELAY", "5KFAVS", "RAIDTELEPORT", "ACCESSORYTYPE", "FIXEDMERCHANT", "THX4KACTIVES", "2.5KLIKES", "FIXEDINDEX", "THX5KACTIVES", "SRRY4SHUTDOWN", "PASSIVEUPDATE", "UPDATE1", "5KLIKES", "4KFAVORITES", "LEVELUPGRADEFIXED", "10KLIKES", "AVATARBUGS", "10KLIKES", "5KFAVS", "DAILYREWARD", "POWERARENA", "SORRYFORDELAY", "FIXEDMOBILE", "DAILYREWARD3", "DAILYREWARD2", "DAILYREWARD4", "15KLIKES", "THX8KACTIVES", "DAILYREWARD5", "GACHIAKUTA", "GACHIAKUTADELAY", "THX10KACTIVES", "RELEASEPART2", "THEDEVGOAT", "FIXEDPASSIVEINTERACT"}
Pl:CreateButton({
    Name = "Redeem Codes",
    Icon = NebulaIcons:GetIcon('list', 'Lucide'),
    Style = 1,
    CenterContent = true,
    Callback = function()
        for _, code in ipairs(CODES) do
            rp:FireServer("General", "Codes", "Claim", code)
        end
    end,
}, "BB_CODES")

local timerLabel = LocalPlayer.PlayerGui.UI.Frames.TimeRewards.Background.BarFrame.Main.ResetTimer.Value
local RT = Pl:CreateParagraph({
    Name = "Rewards Timer",
    Icon = NebulaIcons:GetIcon('clock-fading', 'Lucide'),
    Content = "Loading...",
}, "PARA_REWARDSTIMER")

timerLabel:GetPropertyChangedSignal("Text"):Connect(function()
    RT:Set({Content = "Next reset: " .. tostring(timerLabel.Text})
end)

local AUTOTR = false
Pl:CreateToggle({
    Name = "Auto Collect TimeRewards",
    Icon = NebulaIcons:GetIcon('time', 'Lucide'),
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

local stars = {}
for _, star in ipairs(game:GetService("ReplicatedStorage").Shared.Stars:GetChildren()) do
    table.insert(stars, star.Name)
end

local petroll = stars[1] or ""
local autopetroll = false
local AutoPet = Up:CreateToggle({
    Name = "Star Roll",
    Icon = NebulaIcons:GetIcon('package-open', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autopetroll = Value
        if not Value then return end
        task.spawn(function()
            while autopetroll do
                pcall(function()
                    local args = {"General", "Stars", "Multi", petroll}
                    ro:FireServer(unpack(args))
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
    Icon = NebulaIcons:GetIcon('package-open', 'Lucide'),
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
                        removeNotifications()
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

local timemodes = GamemodeBox:CreateParagraph({
    Name = "Dungeon Timers",
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

    local text =
        "Raids Open: XX:15 & XX:45\nNext In: " .. raidTimer .. "\n" ..
        "Dungeon Easy Open: XX:00\nNext In: " .. easyTimer .. "\n" ..
        "Dungeon Medium Open: XX:30\nNext In: " .. mediumTimer

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

local modeFarm = false
GamemodeBox:CreateToggle({
    Name = "Auto Farm Modes",
    Icon = NebulaIcons:GetIcon('shield-sword', 'Phosphor'),
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

                        hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 2.5, 2.5))

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

local lveasy = ""
local lvmedium = ""
local lvraid = ""
local lvtrialeasy = ""
local lvtrialmedium = ""
local lvinfinitecastle = ""
local selectedMap = ""
local hasJustTeleported = false
local lastJoinEasy, lastJoinMedium, lastJoinRaid = 0, 0, 0
local autoJoinEasy, autoJoinMedium, autoJoinRaid, autoJoinInfinite = false, false, false, false

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
local excludedMaps = {"Raid", "Defense"}
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

local MAptoleav = Gm:CreateLabel({
    Name = "Map to Leave",
    Icon = NebulaIcons:GetIcon('target', 'Phosphor'),
}, "LABEL_MAP")

MAptoleav:AddDropdown({
    Options = maps,
    CurrentOptions = {},
    Placeholder = "Select Map",
    Callback = function(Options)
        selectedMap = Options[1] or ""
    end,
}, "DD_MAPTOLEAVE")

local autoSetup = false
Gm:CreateToggle({
    Name = "Auto Setup",
    Icon = NebulaIcons:GetIcon('package-open', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autoSetup = Value
    end,
}, "TOGGLE_AUTOSETUP")

local function equipAllDamage()
    pcall(function()
        rp:FireServer("General", "StatusBest", "Best", "Damage")
    end)
end

local function equipAllPower()
    pcall(function()
        rp:FireServer("General", "StatusBest", "Best", "Power")
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
                rp:FireServer("General", "Teleport", "Teleport", selectedMap)
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
    Name = "Leave Room Easy",
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
    Name = "Leave Room Medium",
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
    Name = "Leave Wave Raid",
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
    Name = "Leave Room Trial Easy",
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
    Name = "Leave Room Trial Medium",
    Icon = NebulaIcons:GetIcon('text-cursor-input', 'Lucide'),
    CurrentValue = "",
    Numeric = true,
    Enter = true,
    MaxCharacters = 30,
    Callback = function(Text)
        lvtrialmedium = Text
    end,
}, "INPUT_LEAVE_TRIAL_MEDIUM")

Gm:CreateInput({
    Name = "Leave Wave Infinite Castle",
    Icon = NebulaIcons:GetIcon('text-cursor-input', 'Lucide'),
    CurrentValue = "",
    Numeric = true,
    Enter = true,
    MaxCharacters = 50,
    Callback = function(Text)
        lvinfinitecastle = Text
    end,
}, "INPUT_LEAVE_INFINITE")

local function shouldWaitForLeave(mode)
    if mode == "Raid" then return lvraid == "" end
    if mode == "Dungeon Easy" then return lveasy == "" end
    if mode == "Dungeon Medium" then return lvmedium == "" end
    if mode == "Trial Easy" then return lvtrialeasy == "" end
    if mode == "Trial Medium" then return lvtrialmedium == "" end
    if mode == "Infinite Castle" then return lvinfinitecastle == "" end
    return true
end

local AutoLeaveAll = false
Gm:CreateToggle({
    Name = "Auto Leave",
    Icon = NebulaIcons:GetIcon('package-open', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        AutoLeaveAll = Value
        if not Value then return end
        task.spawn(function()
            while AutoLeaveAll do
                pcall(function()
                    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                    if not playerGui then return end
                    local hud = playerGui:FindFirstChild("UI") and playerGui.UI:FindFirstChild("HUD")
                    if not hud then return end
    
                    if Modes("Raid") then
                        if shouldWaitForLeave("Raid") then
                            repeat task.wait(1) until not Modes("Raid")
                            tpback()
                            return
                        else
                            local raidGui = hud:FindFirstChild("Gamemodes") and hud.Gamemodes:FindFirstChild("Raid")
                            if raidGui and raidGui:FindFirstChild("Wave") then
                                local waveNumber = tonumber(string.match(raidGui.Wave.Value.Text, "%d+"))
                                if waveNumber and tonumber(lvraid) == waveNumber then
                                    tpback()
                                end
                            end
                        end
                    end
    
                    if Modes("Dungeon Easy") then
                        if shouldWaitForLeave("Dungeon Easy") then
                            repeat task.wait(1) until not Modes("Dungeon Easy")
                            tpback()
                            return
                        else
                            local gui = hud:FindFirstChild("Gamemodes") and hud.Gamemodes:FindFirstChild("Dungeon Easy")
                            if gui and gui:FindFirstChild("Rooms") then
                                local roomNumber = tonumber(string.match(gui.Rooms.Value.Text, "%d+"))
                                if roomNumber and tonumber(lveasy) == roomNumber then
                                    tpback()
                                end
                            end
                        end
                    end
    
                    if Modes("Dungeon Medium") then
                        if shouldWaitForLeave("Dungeon Medium") then
                            repeat task.wait(1) until not Modes("Dungeon Medium")
                            tpback()
                            return
                        else
                            local gui = hud:FindFirstChild("Gamemodes") and hud.Gamemodes:FindFirstChild("Dungeon Medium")
                            if gui and gui:FindFirstChild("Rooms") then
                                local roomNumber = tonumber(string.match(gui.Rooms.Value.Text, "%d+"))
                                if roomNumber and tonumber(lvmedium) == roomNumber then
                                    tpback()
                                end
                            end
                        end
                    end
                    
                    if Modes("Trial Easy") then
                        if shouldWaitForLeave("Trial Easy") then
                            repeat task.wait(1) until not Modes("Trial Easy")
                            tpback()
                            return
                        else
                            local gui = hud:FindFirstChild("Gamemodes") and hud.Gamemodes:FindFirstChild("Trial Easy")
                            if gui and gui:FindFirstChild("Rooms") then
                                local roomNumber = tonumber(string.match(gui.Rooms.Value.Text, "%d+"))
                                if roomNumber and tonumber(lvtrialeasy) == roomNumber then
                                    tpback()
                                end
                            end
                        end
                    end
                    
                    if Modes("Trial Medium") then
                        if shouldWaitForLeave("Trial Medium") then
                            repeat task.wait(1) until not Modes("Trial Medium")
                            tpback()
                            return
                        else
                            local gui = hud:FindFirstChild("Gamemodes") and hud.Gamemodes:FindFirstChild("Trial Medium")
                            if gui and gui:FindFirstChild("Rooms") then
                                local roomNumber = tonumber(string.match(gui.Rooms.Value.Text, "%d+"))
                                if roomNumber and tonumber(lvtrialmedium) == roomNumber then
                                    tpback()
                                end
                            end
                        end
                    end
                    
                    if Modes("Infinite Castle") then
                          if shouldWaitForLeave("Infinite Castle") then
                              repeat task.wait(1) until not Modes("Infinite Castle")
                              tpback()
                              return
                          else
                              local gui = hud:FindFirstChild("Gamemodes") and hud.Gamemodes:FindFirstChild("Infinite Castle")
                              if gui and gui:FindFirstChild("Wave") then
                                  local waveNumber = tonumber(string.match(gui.Wave.Value.Text, "%d+"))
                                  if waveNumber and tonumber(lvinfinitecastle) == waveNumber then
                                      if autoJoinInfinite then
                                          local retryBtn = gui:FindFirstChild("Buttons") and gui.Buttons:FindFirstChild("Retry")
                                          if retryBtn and retryBtn:IsA("ImageButton") then
                                              pcall(function()
                                                  firesignal(retryBtn.Activated)
                                              end)
                                          end
                                      end
                                  end
                              end
                          end
                    end
                    
                    if not Modes("Raid") and not Modes("Dungeon Easy") and not Modes("Dungeon Medium") and not Modes("Trial Easy") and not Modes("Trial Medium") and not Modes("Infinite Castle") then
                        hasJustTeleported = false
                    end
                end)
                task.wait(0.5)
            end
        end)
    end,
}, "TOGGLE_AUTOLEAVE")

Gm:CreateToggle({
    Name = "Auto Join Dungeon Easy",
    Icon = NebulaIcons:GetIcon('log-in', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autoJoinEasy = Value
        if not Value then return end
        task.spawn(function()
            while autoJoinEasy do
                pcall(function()
                    local min = os.date("*t").min
                    if min == 0 and os.time() - lastJoinEasy > 2 then
                        if not Modes("Dungeon Easy") then
                            lastJoinEasy = os.time()
                            if autoSetup then equipAllDamage() end
                            task.wait(1)
                            rp:FireServer("Gamemodes", "Dungeon Easy", "Join")
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end,
}, "TOGGLE_AUTO_JOIN_EASY")

Gm:CreateToggle({
    Name = "Auto Join Dungeon Medium",
    Icon = NebulaIcons:GetIcon('log-in', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autoJoinMedium = Value
        if not Value then return end
        task.spawn(function()
            while autoJoinMedium do
                pcall(function()
                    local min = os.date("*t").min
                    if min == 30 and os.time() - lastJoinMedium > 2 then
                        if not Modes("Dungeon Medium") then
                            lastJoinMedium = os.time()
                            if autoSetup then equipAllDamage() end
                            task.wait(1)
                            rp:FireServer("Gamemodes", "Dungeon Medium", "Join")
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end,
}, "TOGGLE_AUTO_JOIN_MEDIUM")

Gm:CreateToggle({
    Name = "Auto Join Raid",
    Icon = NebulaIcons:GetIcon('log-in', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autoJoinRaid = Value
        if not Value then return end
        task.spawn(function()
            while autoJoinRaid do
                pcall(function()
                    local min = os.date("*t").min
                    if (min == 15 or min == 45) and os.time() - lastJoinRaid > 2 then
                        if not Modes("Raid") then
                            lastJoinRaid = os.time()
                            if autoSetup then equipAllDamage() end
                            task.wait(1)
                            rp:FireServer("Gamemodes", "Raid", "Join")
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end,
}, "TOGGLE_AUTO_JOIN_RAID")

Gm:CreateToggle({
    Name = "Auto Join Infinite Castle",
    Icon = NebulaIcons:GetIcon('log-in', 'Lucide'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autoJoinInfinite = Value
        if not Value then return end
        task.spawn(function()
            while autoJoinInfinite do
                pcall(function()
                    if not Modes("Infinite Castle") then
                        if autoSetup then equipAllDamage() end
                        task.wait(1)
                        rp:FireServer("Gamemodes", "Infinite Castle", "Start_Queue", 1)
                    end
                end)
                task.wait(5)
            end
        end)
    end,
}, "TOGGLE_AUTO_JOIN_INFINITE")

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
    Content = "You're now using NullHub, baby.\nScript loaded Successfully."
}, "SCTS")
print("Script Loaded!")