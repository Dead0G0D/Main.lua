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
    Name = "Auto Equip Best Accessories",
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
    ["Dragon Ball Power"] = rp:WaitForChild("RollDragonBallPower"),
    ["Saiyan Power"]      = rp:WaitForChild("RollSaiyanPower"),
    ["Avocado"]   = rp:WaitForChild("RollAvocadoPower"),
    ["Breathing"] = rp:WaitForChild("RollBreathingPower"),
    ["Dagger"]    = rp:WaitForChild("RollDaggerPower"),
    ["Farm"]      = rp:WaitForChild("RollFarmPower"),
    ["Fruit"]     = rp:WaitForChild("RollFruitPower"),
    ["Grimoires"] = rp:WaitForChild("RollGrimoiresPower"),
    ["Jungle"]    = rp:WaitForChild("RollJunglePower"),
    ["Lava"]      = rp:WaitForChild("RollLavaPower"),
    ["Pet"]       = rp:WaitForChild("RollPetPower"),
    ["Robot"]     = rp:WaitForChild("RollRobotPower"),
    ["Saturn"]    = rp:WaitForChild("RollSaturnPower"),
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