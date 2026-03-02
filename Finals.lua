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

local MS = Window:CreateTabSection("MAIN")
local SS = Window:CreateTabSection("SETTINGS")

local MainTab = MS:CreateTab({
    Name = "| Main",
    Icon = NebulaIcons:GetIcon('home', 'Symbols'),
    Columns = 2,
}, "TAB_MAIN")

local Modes = MS:CreateTab({
    Name = "| ?",
    Icon = NebulaIcons:GetIcon('house', 'Symbols'),
    Columns = 2,
}, "TAB_GM")

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

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

local AutoFarmBox = MainTab:CreateGroupbox({
    Name = "Auto Farm",
    Icon = NebulaIcons:GetIcon('sword', 'Phosphor'),
    Column = 1,
}, "GB_AUTOFARM")

local Pl = MainTab:CreateGroupbox({
    Name = "Player",
    Icon = NebulaIcons:GetIcon('trending_up', 'Material'),
    Column = 1,
}, "GB_STATS")

local Up = MainTab:CreateGroupbox({
    Name = "Player Upgrades",
    Icon = NebulaIcons:GetIcon('dots-three-circle', 'Phosphor'),
    Column = 2,
}, "GB_STATS")

local ConfigMisc = Config:CreateGroupbox({
    Name = "Misc",
    Icon = NebulaIcons:GetIcon('shield-check', 'Phosphor'),
    Column = 1,
}, "GB_CONFIG_MISC")

Theme:BuildThemeGroupbox(1)
Config:BuildConfigGroupbox(1)

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

                            if selectedFarmMode == "Tp" then
                                hrp.CFrame = target.HumanoidRootPart.CFrame + Vector3.new(0, 0, 2.5)
                            elseif selectedFarmMode == "Legit" and humanoid then
                                humanoid:MoveTo(target.HumanoidRootPart.Position + Vector3.new(0, 0, 2.7))
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
Up:CreateDivider()
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
              if v.Name ~= "Hunter" and v.Name ~= "PyramidKey" then
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

local spt = UpOptions[1] or ""
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
    CurrentOptions = {UpOptions[1]},
    Callback = function(Options)
        spt = Options[1]
    end,
}, "DD_UPGRADES_SELECT1")

local spt2 = pro[1] or ""
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
    CurrentOptions = {pro[1]},
    Callback = function(Options)
        spt2 = Options[1]
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