getgenv().InterfaceName = "Latency"
getgenv().SecureMode = true

local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

MarketplaceService = game:GetService("MarketplaceService")
PlaceId = game.PlaceId
ProductInfo = MarketplaceService:GetProductInfo(PlaceId)
GameName = ProductInfo.Name

local Window = Starlight:CreateWindow({
    Name = "/Latency/",
    Subtitle = GameName,
    Icon = "136362783020632",  --"116180233441379", --"101497542169555", --"77933017176374", --"125967972654762",
    DefaultSize = UDim2.fromOffset(540, 800),
    BuildWarnings = true,
    InterfaceAdvertisingPrompts = true,
    NotifyOnCallbackError = true,
    LoadingEnabled = false,
    
    FileSettings = {
        ConfigFolder = "Latency - " .. GameName,
    },
})

local MS = Window:CreateTabSection("   --MAIN--")
local PL = Window:CreateTabSection("   --PLAYER/MISC--")
local SS = Window:CreateTabSection("   --SETTINGS--")

local MainTab = MS:CreateTab({
    Name = "| Main",
    Icon = 77630928106024,
    Columns = 1,
}, "TAB_MAIN")
               --Groupboxs--
local AutoFarmBox = MainTab:CreateGroupbox({
    Name = "Auto Farm",
    Icon = NebulaIcons:GetIcon('sword', 'Phosphor'),
    Column = 1,
}, "GB_AUTOFARM")

local PlayerTab = PL:CreateTab({
    Name = "| Player/Misc",
    Icon = 77630928106024,
    Columns = 1,
}, "TAB_PLAYER")

local Pl = PlayerTab:CreateGroupbox({
    Name = "Player",
    Icon = NebulaIcons:GetIcon('trending_up', 'Material'),
    Column = 1,
}, "GB_PLMISC")

local Up = MainTab:CreateGroupbox({
    Name = "Player Upgrades",
    Icon = NebulaIcons:GetIcon('dots-three-circle', 'Phosphor'),
    Column = 1,
}, "GB_UPGRADES")

local Modes = MS:CreateTab({
    Name = "| Gamemodes",
    Icon = 77630928106024,
    Columns = 1,
}, "TAB_GM")
              --Groupboxs--
local GamemodeBox = Modes:CreateGroupbox({
    Name = "Auto Modes",
    Icon = NebulaIcons:GetIcon('sword', 'Phosphor'),
    Column = 1,
}, "GB_AUTOFARMMODES")

local Gm = Modes:CreateGroupbox({
    Name = "Join/Leave",
    Icon = NebulaIcons:GetIcon('sword', 'Phosphor'),
    Column = 1,
}, "GB_JLMODES")

local SV = Modes:CreateGroupbox({
    Name = "Save Position",
    Icon = NebulaIcons:GetIcon('map', 'Phosphor'),
    Column = 1,
}, "GB_SVMODES")

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

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

Theme:BuildThemeGroupbox(1)
Config:BuildConfigGroupbox(1)

local ModeConfig = {
    Type = "Text",
    Root = function()
        return LocalPlayer.PlayerGui:FindFirstChild("DungeonGui")
    end,
    Path = function()
        return LocalPlayer.PlayerGui.DungeonGui.Canvas.DungeonUI.DungeonName.NameLabel
    end,
}

local function Modes(mode)
    local rootSuccess, rootInstance = pcall(ModeConfig.Root)
    if not rootSuccess or not rootInstance or not rootInstance.Enabled then return false end

    local pathSuccess, element = pcall(ModeConfig.Path)
    if not pathSuccess or not element then return false end

    if ModeConfig.Type == "Text" then
        if not element.Visible then return false end
        return element.ContentText == mode
    elseif ModeConfig.Type == "Visible" then
        local frame = element:FindFirstChild(mode, true)
        return frame and frame.Enabled or false
    end

    return false
end

local activeModes = {"Dungeon Easy", "Dungeon Medium", "Raid Pyramid"}
local function AnyModeActive()
    for _, mode in ipairs(activeModes) do
        if Modes(mode) then return true end
    end
    return false
end

local rp = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local ac = false
Up:CreateDivider()
local Atc = AutoFarmBox:CreateToggle({
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
                rp:WaitForChild("AttackEvent"):FireServer()
                rp:WaitForChild("ClickRemote"):FireServer()
                end)
                RunService.Heartbeat:Wait()
            end
        end)
    end,
}, "TOGGLE_AUTOCLICK")

local farmRunning = false
local selectedNpcNames = {}
local selectedFarmMode = "Tp"

local function GetUniqueNpcNames()
    local names = {}
    for _, npc in ipairs(workspace.Enemies:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") then
            names[npc.Name] = true
        end
    end
    local list = {}
    for name, _ in pairs(names) do
        table.insert(list, name)
    end
    return list
end

local FarmModeLabel = AutoFarmBox:CreateLabel({
    Name = "Farm Mode",
    Icon = NebulaIcons:GetIcon('arrows-left-right', 'Phosphor'),
}, "LABEL_FARM_MODE")

FarmModeLabel:AddDropdown({
    Options = {"Tp", "Legit"},
    CurrentOptions = {"Tp"},
    Callback = function(Options)
        selectedFarmMode = Options[1]
    end,
}, "DD_FARM_MODE")

local NpcAutoFarm = AutoFarmBox:CreateToggle({
    Name = "Auto Farm",
    Icon = NebulaIcons:GetIcon('target', 'Phosphor'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        farmRunning = Value
        if not Value then return end
        task.spawn(function()
            while farmRunning do
                if AnyModeActive() then
                    task.wait(0.5)
                    continue
                end
                if not selectedNpcNames or #selectedNpcNames == 0 then
                    task.wait(0.5)
                    continue
                end

                for _, npcName in ipairs(selectedNpcNames) do
                    if not farmRunning then break end

                    local target = nil
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local humanoid = char and char:FindFirstChild("Humanoid")

                    for _, npc in ipairs(workspace.Enemies:GetChildren()) do
                        local h = npc:FindFirstChild("Humanoid")
                        local hrpNpc = npc:FindFirstChild("HumanoidRootPart")
                        local canTake = npc:FindFirstChild("CanTakeDamage")
                        if npc.Name == npcName and h and h.Health > 0 and hrpNpc and canTake and canTake.Value then
                            if selectedFarmMode == "Legit" and hrp then
                                local dist = (hrp.Position - hrpNpc.Position).Magnitude
                                if not target or dist < (hrp.Position - target.HumanoidRootPart.Position).Magnitude then
                                    target = npc
                                end
                            else
                                target = npc
                                break
                            end
                        end
                    end

                    if target then
                        repeat
                            if not farmRunning or not target.Parent then break end
                            if not table.find(selectedNpcNames, npcName) then break end

                            char = LocalPlayer.Character
                            hrp = char and char:FindFirstChild("HumanoidRootPart")
                            humanoid = char and char:FindFirstChild("Humanoid")
                            if not hrp then break end

                            local pivot = target:GetPivot()

                            if selectedFarmMode == "Tp" then
                                if (hrp.Position - pivot.Position).Magnitude > 6 then
                                    hrp.CFrame = CFrame.lookAt((pivot * CFrame.new(0, 0, 2.5)).Position, pivot.Position)
                                end
                            elseif selectedFarmMode == "Legit" and humanoid then
                                humanoid:MoveTo(pivot.Position + Vector3.new(0, 0, 2.7))
                            end
                            
                            RunService.Heartbeat:Wait()
                        until not target.Parent
                    end

                    task.wait(0.1)
                end
            end
        end)
    end,
}, "TOGGLE_NPC_AUTO_FARM")

local NpcDropdown = NpcAutoFarm:AddDropdown({
    Options = GetUniqueNpcNames(),
    CurrentOptions = {},
    Placeholder = "Select",
    MultipleOptions = true,
    Callback = function(Options)
        selectedNpcNames = Options
    end,
}, "DD_NPC_SELECT")

AutoFarmBox:CreateButton({
    Name = "Refresh",
    Icon = NebulaIcons:GetIcon('caret-circle-right', 'Phosphor'),
    Style = 1,
    CenterContent = true,
    Callback = function()
        npcnames = GetUniqueNpcNames()    
        NpcDropdown:Set({Options = npcnames})
    end,
}, "BTN_REFRESH_NPCS")

local islands = (function()
    local list = {}
    for _, v in ipairs(workspace.Islands:GetChildren()) do
              if v.Name ~= "Dungeon" then
                  table.insert(list, v.Name)
              end
          end
    return list
end)()

local petroll = islands[1] or ""
local autopetroll = false
local autopetroll = Up:CreateToggle({
    Name = "Pet Roll",
    Icon = NebulaIcons:GetIcon('dice-five', 'Phosphor'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autopetroll = Value
        if not Value then return end
        task.spawn(function()
            while autopetroll do
                pcall(function()
                 local args = { petroll, 1, { autoDelete = true, pity = { mythic = 0, legendary = 0, mTotal = 10000, lTotal = 1000 }}}
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ChampionRollRequest"):InvokeServer(unpack(args))
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

local UpOptions = (function()
    local list = {}
    for _, v in ipairs(game:GetService("ReplicatedStorage").SharedData.PowerConfigs:GetChildren()) do
              if v.Name ~= "Hunter" and v.Name ~= "PyramidKey" and v.Name ~= "Dungeon" then
                  table.insert(list, v.Name)
              end
          end
    return list
end)()

local pro = (function()
    local list = {}
    for _, v in ipairs(game:GetService("ReplicatedStorage").SharedData.ProgressionConfigs:GetChildren()) do
          table.insert(list, v.Name)
        end
    return list
end)()

local spt = {}
local autoupg = false
Up:CreateDivider()
local autoprott1 = Up:CreateToggle({
    Name = "Auto Roll",
    Icon = NebulaIcons:GetIcon('dice-five', 'Phosphor'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autoupg = Value
        if not Value then return end
        task.spawn(function()
            while autoupg do
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestPowerRoll"):InvokeServer(spt)
                end)
                RunService.Heartbeat:Wait()
            end
        end)
    end,
}, "TOGGLE_AUTO_ROLL1")

autoprott1:AddDropdown({
    Options = UpOptions,
    CurrentOptions = {},
    MultipleOptions = true,
    Callback = function(Options)
        spt = Options
    end,
}, "DD_UPGRADES_SELECT1")

local spt2 = {}
local autopro = false
Up:CreateDivider()
local autoprott2 = Up:CreateToggle({
    Name = "Auto Progression",
    Icon = NebulaIcons:GetIcon('dice-five', 'Phosphor'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autopro = Value
        if not Value then return end
        task.spawn(function()
            while autopro do
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestProgressionUpgrade"):InvokeServer(spt2)
                end)
                RunService.Heartbeat:Wait()
            end
        end)
    end,
}, "TOGGLE_AUTO_UP")

autoprott2:AddDropdown({
    Options = pro,
    CurrentOptions = {},
    MultipleOptions = true,
    Callback = function(Options)
        spt2 = Options
    end,
}, "DD_UPGRADES_SELECT2")

local autoEquip = false
Pl:CreateToggle({
    Name = "Auto Equip Best Avatar",
    Icon = NebulaIcons:GetIcon('armchair', 'Phosphor'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autoEquip = Value
        if not Value then return end
        task.spawn(function()
            while autoEquip do
                pcall(function()
                    rp:WaitForChild("AvatarEquip"):FireServer("EquipBest")
                end)
                task.wait(35)
            end
        end)
    end,
}, "TOGGLE_AUTO_EQUIP")

Up:CreateDivider()

local autoEquip2 = false
Pl:CreateToggle({
    Name = "Auto Equip Best Accessory",
    Icon = NebulaIcons:GetIcon('armchair', 'Phosphor'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autoEquip2 = Value
        if not Value then return end
        task.spawn(function()
            while autoEquip2 do
                pcall(function()
                    rp:WaitForChild("AccessoryEquip"):FireServer("EquipBest")
                end)
                task.wait(35)
            end
        end)
    end,
}, "TOGGLE_AUTO_EQUIP2")

local autoPresents = false

Pl:CreateToggle({
    Name = "Auto Collect Presents",
    Icon = NebulaIcons:GetIcon('gift', 'Phosphor'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autoPresents = Value
        if not Value then return end

        task.spawn(function()
            while autoPresents do
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then
                    task.wait(0.5)
                    continue
                end

                local savedPos = hrp.CFrame
                local collected = false

                local presentFolders = {
                    workspace.Presents:FindFirstChild("Group"),
                    workspace.Presents:FindFirstChild("Daily"),
                }

                for _, folder in ipairs(presentFolders) do
                    if not folder then continue end

                    local timer = folder:FindFirstChild("BillboardGui", true)
                        and folder:FindFirstPath("BillboardGui.GiftFrame.GiftTimer")

                    -- busca o GiftTimer em cada present do folder
                    for _, present in ipairs(folder:GetChildren()) do
                        if not autoPresents then break end

                        local giftTimer = present:FindFirstChild("BillboardGui")
                            and present.BillboardGui:FindFirstChild("GiftFrame")
                            and present.BillboardGui.GiftFrame:FindFirstChild("GiftTimer")

                        if giftTimer and giftTimer.ContentText == "Claim!" then
                            if not AnyModeActive() then
                                hrp.CFrame = present:GetPivot()
                                collected = true
                                task.wait(0.3)
                            end
                        end
                    end
                end

                if collected then
                    task.wait(0.3)
                    hrp.CFrame = savedPos
                end

                task.wait(1)
            end
        end)
    end,
}, "TOGGLE_AUTO_PRESENTS")

local CodesParagraph = Pl:CreateParagraph({
    Name = "Codes Status",
    Icon = NebulaIcons:GetIcon('ticket', 'Lucide'),
    Content = "Click in Redeem Codes",
}, "PARA_CODES")

local rdcs = Pl:CreateButton({
    Name = "Redeem Codes",
    Icon = NebulaIcons:GetIcon('ticket', 'Lucide'),
    Style = 1,
    CenterContent = true,
    Callback = function()
        CodesParagraph:Set({Content = "⏳ Iniciando resgate de códigos..."})
        
        local CodesModule = require(game:GetService("ReplicatedStorage").SharedData.CodesConfig)
        local CodesConfig = CodesModule.Codes
        
        local redeemed = 0
        local failed = 0
        local expired = 0
        
        for codeName, codeData in pairs(CodesConfig) do
            if not codeData.Expired then
                CodesParagraph:Set({Content = string.format("⏳ Resgatando: %s...", codeName)})
                
                local success = pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RedeemCode"):InvokeServer(codeName)
                end)
                
                if success then
                    redeemed = redeemed + 1
                    CodesParagraph:Set({Content = string.format("🎫 Successfully Redeemed: %s\n🎫 Total Successful: %d | ⚠️ Total Failed: %d", codeName, redeemed, failed)})
                else
                    failed = failed + 1
                    CodesParagraph:Set({Content = string.format("⚠️ Failed Attempt: %s\n🎫 Total Successful: %d | ⚠️ Total Failed: %d", codeName, redeemed, failed)})
                end
                
                task.wait(0.5)
            else
                expired = expired + 1
            end
        end
        
        local finalText = string.format("🎁 All Codes Processed!\n🎫 Successfully Redeemed: %d\n⚠️ Failed Attempts: %d\n⛔️ Expired Codes: %d", redeemed, failed, expired)
        CodesParagraph:Set({Content = finalText})
    end,
}, "BTN_REDEEM_CODES")

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

    local easyTimer = timeToNext({0, 30})
    local mediumTimer = timeToNext({15, 45})

    local text =
        "Dungeon Easy Open: XX:00 & XX:30\nNext In: " .. easyTimer .. "\n" ..
        "Dungeon Medium Open: XX:15 & XX:45\nNext In: " .. mediumTimer

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

local modeFarm = false
local GMF = GamemodeBox:CreateToggle({
    Name = "Auto Farm Modes",
    Icon = NebulaIcons:GetIcon('shield-sword', 'Phosphor'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        modeFarm = Value
        if not Value then return end

        task.spawn(function()
            while modeFarm do
                if not AnyModeActive() then
                    task.wait(0.5)
                    continue
                end

                local foundAny = false
                for _, npc in ipairs(workspace.Enemies:GetChildren()) do
                    local isDungeon = npc:GetAttribute("IsDungeonEnemy") == true
                    local isRaid = npc:GetAttribute("IsRaidEnemy") == true
                    if not isDungeon and not isRaid then continue end

                    local h = npc:FindFirstChild("Humanoid")
                    local hrpNpc = npc:FindFirstChild("HumanoidRootPart")
                    local canTake = npc:FindFirstChild("CanTakeDamage")
                    if not h or h.Health <= 0 or not hrpNpc or not canTake or not canTake.Value then continue end

                    foundAny = true

                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                  repeat
                      if not modeFarm or not npc.Parent then break end
                      if not AnyModeActive() then break end
                      if not h or h.Health <= 0 then break end
                  
                      local char = LocalPlayer.Character
                      hrp = char and char:FindFirstChild("HumanoidRootPart")
                      hrpNpc = npc:FindFirstChild("HumanoidRootPart")
                      if not hrp or not hrpNpc then break end
                  
                      local pivot = npc:GetPivot()
                  
                      if (hrp.Position - pivot.Position).Magnitude > 10 then
                          hrp.CFrame = CFrame.lookAt((pivot * CFrame.new(0, 0, 2.5)).Position, pivot.Position)
                      end
                  
                      RunService.Heartbeat:Wait()
                  until not npc.Parent or not h or h.Health <= 0
                    task.wait(0.1)
                end

                if not foundAny then RunService.Heartbeat:Wait() end
            end
        end)
    end,
}, "TOGGLE_AUTO_FARM_MODES")

local autoRaid = false

GamemodeBox:CreateToggle({
    Name = "Auto Next Room Raid",
    Icon = NebulaIcons:GetIcon('door', 'Phosphor'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        autoRaid = Value
        if not Value then return end

        task.spawn(function()
            while autoRaid do
                if not Modes("Pyramid Raid") then
                    task.wait(0.5)
                    continue
                end

                local ok, label = pcall(function()
                    return LocalPlayer.PlayerGui.DungeonGui.Canvas.DungeonUI.Content.RoomsCleared.RoomsLabel
                end)

                if ok and label and label.Text == "Go to Next Room" then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        for _, folder in ipairs(workspace:GetChildren()) do
                            if folder.Name:match("Raid_W4") then
                                local startTp = folder.Start and folder.Start:FindFirstChild("TP")
                                local coreTp = folder.Core and folder.Core:FindFirstChild("TP")

                                local tp = nil

                                if coreTp and coreTp:GetAttribute("Teleporting") == true then
                                    tp = coreTp
                                elseif startTp and startTp:GetAttribute("Enabled") == true then
                                    tp = startTp
                                end

                                if tp then
                                    hrp.CFrame = tp.CFrame
                                end

                                break
                            end
                        end
                    end
                end

                task.wait(0.5)
            end
        end)
    end,
}, "TOGGLE_AUTO_RAID")

local SvPosition = nil
local PositionParagraph = SV:CreateParagraph({
    Name = "Saved Position",
    Icon = NebulaIcons:GetIcon('map-pinned', 'Lucide'),
    Content = "No position saved yet",
}, "PARA_SAVED_POS")

local svp = SV:CreateButton({
    Name = "Save Position",
    Icon = NebulaIcons:GetIcon('map-pinned', 'Lucide'),
    Style = 1,
    CenterContent = true,
    Callback = function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            SvPosition = hrp.Position
            PositionParagraph.Instance.Content.Text = string.format("X: %.2f, Y: %.2f, Z: %.2f", SvPosition.X, SvPosition.Y, SvPosition.Z)
        end
    end,
}, "BTN_SAVE_POS")

local lveasy = ""
local Join2 = Gm:CreateInput({
    Name = "Leave Room Easy",
    Icon = NebulaIcons:GetIcon('text-cursor-input', 'Lucide'),
    CurrentValue = "",
    Numeric = true,
    Enter = true,
    MaxCharacters = 30,
    Callback = function(Value)
       lveasy = Value
       print("InputEasy: Dungeon Easy auto-leave room:", lveasy)
    end,
}, "JOIN1")

local lvmedium = ""
local Join3 = Gm:CreateInput({
    Name = "Leave Room Medium",
    Icon = NebulaIcons:GetIcon('text-cursor-input', 'Lucide'),
    CurrentValue = "",
    Numeric = true,
    Enter = true,
    MaxCharacters = 30,
    Callback = function(Value)
       lvmedium = Value
       print("InputMedium: Dungeon Medium auto-leave room:", lvmedium)
    end,
}, "JOIN2")

local lvraid = ""
local Join1 = Gm:CreateInput({
    Name = "Leave Wave Raid",
    Icon = NebulaIcons:GetIcon('text-cursor-input', 'Lucide'),
    CurrentValue = "",
    PlaceholderText = "e.g. 5",
    Numeric = true,
    Enter = true,
    Callback = function(Value)
       lvraid = Value
       print("InputRaid: Raid auto-leave wave:", lvraid)
    end,
}, "JOIN3")

local antiAfkEnabled = false
ConfigMisc:CreateToggle({
    Name = "Anti AFK",
    Icon = NebulaIcons:GetIcon('activity', 'Phosphor'),
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        antiAfkEnabled = Value
        if Value then
            task.spawn(function()
                while antiAfkEnabled do
                    task.wait(500)
                    if not antiAfkEnabled then break end
                    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Jump = true end
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0, 0))
                end
            end)
        end
    end,
}, "TOGGLE_ANTI_AFK")

Starlight:OnDestroy(function()
    print("Script Deleted")
end)
Starlight:LoadAutoloadConfig()
Starlight:LoadAutoloadTheme()
print("Script Loaded!")