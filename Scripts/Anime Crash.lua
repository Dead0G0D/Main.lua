local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Null3Hub/WindUI-Boreal-Forked/refs/heads/main/main.lua"))()
executor = identifyexecutor and identifyexecutor() or "Unknown"
local device = "PC"
if game:GetService("UserInputService").TouchEnabled and not game:GetService("UserInputService").KeyboardEnabled then
    device = "Mobile"
end
MarketplaceService = game:GetService("MarketplaceService")
local GameName = MarketplaceService:GetProductInfo(game.PlaceId).Name

local GreyGradient = WindUI:Gradient({
    ["0"]   = { Color = Color3.fromHex("#353A3E"), Transparency = 0 },
    ["100"] = { Color = Color3.fromHex("#E0E0E0"), Transparency = 1 }
}, { Rotation = 0 })

local MoonGradient = WindUI:Gradient({
    ["0"]   = { Color = Color3.fromHex("#6667AB"), Transparency = 0.5 },
    ["100"] = { Color = Color3.fromHex("#7B337E"), Transparency = 0 }
}, { Rotation = 0 })

local Midv2Gradient = WindUI:Gradient({
    ["0"]   = { Color = Color3.fromHex("#F5D5E0"), Transparency = 1 },
    ["100"] = { Color = Color3.fromHex("#D4A574"), Transparency = 0 }
}, { Rotation = 0 })

local ThemeGradients = {
    ["Grey"]  = GreyGradient,
    ["Moon"]  = MoonGradient,
    ["Midv2"] = Midv2Gradient,
}

WindUI:SetNotificationLower(true)
local Window = WindUI:CreateWindow({
    Title = "Null Hub",
    Author = GameName,
    Folder = "NullHub - Anime Leveling",
    Icon = "rbxassetid://90057404579525",
    IconThemed = true,
    Theme = "Moon",
    Size = UDim2.fromOffset(730, 455),
    Transparent = true,
    Acrylic = true,
    SideBarWidth = 210,
    ScrollBarEnabled = true,
    HideSearchBar = false,
    Resizable = true,
    ModernLayout = true,
    ModernLayoutMergeElements = false,
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function() end,
    },
    OpenButton = {
        Enabled = true,
        Title = "Open UI",
        Icon = "rbxassetid://90057404579525",
        Position = UDim2.new(0.5, 0, 0, 20),
        Draggable = true,
        OnlyMobile = false,
        CornerRadius = UDim.new(0, 18),
        StrokeThickness = 2,
        Scale = 0.9,
        Color = ColorSequence.new(
            Color3.fromHex("#6667AB"),
            Color3.fromHex("#7B337E")
        ),
    },
    Topbar = {
        Height = 52,
        ButtonsType = "Default",
    },
    Watermark = {
        Enabled = true,
        Text = "Null Hub Entertainment",
        Position = "bottom-right",
        Opacity = 0.5,
        Size = 13,
    },
})

Window:DisableTopbarButtons({ "Fullscreen" })
Window:OnDestroy(function()
    print("Null Hub Advertise • Script Deleted")
    farmRunning = false
    modeFarm = false
    autoModesActive = false
    joiningMode = false
    ac = false
    autoEquip = false
    autopetroll = false
    upp2 = false
    autoGacha = false
    autoLeveling = false
    hideNameActive = false
    applySpeedActive = false
    antiAfkActive = false
    afkModeEnabled = false
    for _, conn in ipairs(hideNameConnections) do
        pcall(function() conn:Disconnect() end)
    end
    hideNameConnections = {}
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = 16 end
        end
    end)
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level05
        local camera = workspace.CurrentCamera
        if camera then camera.CameraType = Enum.CameraType.Custom end
    end)
    print("Null Hub • All features cleaned up")
end)

local function notify(title, content, icon, duration)
    WindUI:Notify({
        Title = title,
        Content = content,
        Icon = icon,
        Duration = duration or 4,
    })
end

Window:BindShortcut("LeftShift", function()
    Window:Toggle()
end, {
    Description = "Toggle window",
    EnabledWhenClosed = true,
})

local TagExecutor = Window:Tag({ Title = executor, Icon = "solar:programming-linear" })
local TagDevice   = Window:Tag({ Title = device, Icon = "solar:monitor-smartphone-linear" })
local AllTags = { TagExecutor, TagDevice }

local function ApplyThemeToUI(themeName)
    local gradient = ThemeGradients[themeName]
    if not gradient then return end
    for _, tag in ipairs(AllTags) do
        tag:SetColor(gradient)
    end
    Window:EditOpenButton({ Color = gradient.Color })
end

ApplyThemeToUI("Moon")

Window:SideBarDivider({})
local AboutHubTab = Window:Tab({ Title = "| About Hub", Icon = "solar:notebook-minimalistic-linear", ShowTabTitle = true, Border = true })
Window:SideBarDivider({})
Window:SelectTab(AboutHubTab)
local MainTab = Window:Tab({ Title = "| Main", Icon = "solar:home-angle-linear", ShowTabTitle = true, Border = true })
local GmTab = Window:Tab({ Title = "| Gamemodes", Icon = "solar:gamepad-linear", ShowTabTitle = true, Border = true })
local ConfigTab = Window:Tab({ Title = "| Config", Icon = "solar:settings-linear", ShowTabTitle = true, Border = true })

-- ==================== VARIÁVEIS GLOBAIS ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local MaterialService = game:GetService("MaterialService")
local rp = game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

local AutoFarmSection = MainTab:Section({ Title = "Auto Farm", Icon = "repeat", Box = true })
local PlayerSection = MainTab:Section({ Title = "Player", Icon = "user-cog", Box = true })
local UpgradesSection = MainTab:Section({ Title = "Gachas|Levelings", Icon = "diamond-plus", Box = true })


local clickRange = 50 
local selectedWorld = ""
local farmRunning = false
local selectedNpcNames = {}
local priorityEnemyNames = {}
local ac = false
local autoEquip = false
local petroll = ""
local autopetroll = false
local selectedStat = "Energy"
local upp2 = false
local selectedGachas = {}
local autoGacha = false
local selectedLeveling = {}
local autoLeveling = false
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
local hideNameActive = false
local hideNameConnections = {}
local fakeHideName = "YeahUsingScript"
local speedValue = 70
local applySpeedActive = false
local antiAfkActive = false
local afkModeEnabled = false
local autoFarmWasEnabled = false
local autoFarmLockedByMode = false
if not getgenv().C then getgenv().C = { F = fakeHideName, D = fakeHideName } end

-- ==================== FUNÇÕES AUXILIARES ====================
local function Modes()
    local dungeon = LocalPlayer.PlayerGui.Paradox.ModesInfo
    return dungeon and dungeon.Visible or false
end

local function GetWorlds()
    local worlds = {}
    for _, obj in pairs(workspace.Game.Mobs.Server:GetChildren()) do
        if obj then table.insert(worlds, obj.Name) end
    end
    return worlds
end

local function GetUniqueEnemyNames()
    local names = {}
    local world = workspace.Game.Mobs.Server:FindFirstChild(selectedWorld)
    if not world then return {} end
    for _, enemy in ipairs(world:GetDescendants()) do
        if enemy:IsA("BasePart") then names[enemy.Name] = true end
    end
    local list = {}
    for name in pairs(names) do table.insert(list, name) end
    return list
end

local function IsNPCValid(obj)
    if not obj or not obj.Parent then return false end
    if not obj:IsA("BasePart") then return false end
    return obj:GetAttribute("Died") ~= true
end
local function FindNearestEnemyInRange(mapName, range)
    local mobsServer = workspace:FindFirstChild("Game") 
        and workspace.Game:FindFirstChild("Mobs") 
        and workspace.Game.Mobs:FindFirstChild("Server")
    
    if not mobsServer then return nil end
    
    local mapFolder = mobsServer:FindFirstChild(mapName)
    if not mapFolder then return nil end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local nearest = nil
    local nearestDist = range -- Começa com o limite do range
    
    for _, obj in ipairs(mapFolder:GetDescendants()) do
        if obj:IsA("BasePart") 
            and obj.Name ~= "HumanoidRootPart"
            and IsNPCValid(obj)
        then
            local dist = (hrp.Position - obj.Position).Magnitude
            if dist < nearestDist then
                nearest = obj
                nearestDist = dist
            end
        end
    end
    
    return nearest
end

local npcDD
local priorityDD

local worldDD = AutoFarmSection:Dropdown({
    Title = "Select World",
    Icon = "globe",
    Values = GetWorlds(),
    Flag = "autofarm_world",
    Callback = function(val)
        selectedWorld = val or ""
        task.defer(function()
            local names = GetUniqueEnemyNames()
            if npcDD then npcDD:Refresh(names, false) end
            if priorityDD then priorityDD:Refresh(names, false) end
        end)
    end,
})

npcDD = AutoFarmSection:Dropdown({
    Title = "Select NPCs",
    Placeholder = "Select NPCs",
    Values = {},
    Multi = true,
    SearchBarEnabled = true,
    Flag = "autofarm_npcs",
    Callback = function(val)
        selectedNpcNames = val or {}
    end,
})

priorityDD = AutoFarmSection:Dropdown({
    Title = "Priority NPCs",
    Placeholder = "Priority NPCs",
    Values = {},
    Multi = true,
    SearchBarEnabled = true,
    Flag = "autofarm_priority",
    Callback = function(val)
        priorityEnemyNames = val or {}
    end,
})

local autoFarmToggle = AutoFarmSection:Toggle({
    Title = "Auto Farm Enemy",
    Icon = "user-cog",
    Value = false,
    Flag = "autofarm_enabled",
    Callback = function(Value)
        farmRunning = Value
        if not Value then return end
        task.spawn(function()
            while farmRunning do
                if Modes() then
                    farmRunning = false
                    if autoFarmToggle and autoFarmToggle.Set then
                        autoFarmToggle:Set(false)
                        autoFarmToggle:Lock()
                    end
                    autoFarmLockedByMode = true
                    break
                end
                
                if #selectedNpcNames == 0 then task.wait(0.5) continue end
                local world = workspace.Game.Mobs.Server:FindFirstChild(selectedWorld)
                if not world then task.wait(0.5) continue end

                local hasPriority = false
                for _, e in ipairs(world:GetDescendants()) do
                    if e:IsA("BasePart") and table.find(priorityEnemyNames, e.Name) and e:GetAttribute("Died") == false then
                        hasPriority = true
                        break
                    end
                end

                local toFarm = hasPriority and priorityEnemyNames or selectedNpcNames
                for _, name in ipairs(toFarm) do
                    if not farmRunning then break end
                    
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then continue end

                    local target = nil
                    for _, e in ipairs(world:GetDescendants()) do
                         if e:IsA("BasePart") and e.Name == name and e:GetAttribute("Died") == false then
                            target = e
                            break
                        end
                    end

                    if target then
                        repeat
                            if not farmRunning or not target.Parent or target:GetAttribute("Died") == true then break end
                            if #priorityEnemyNames > 0 and not table.find(priorityEnemyNames, name) then
                                local spawned = false
                                for _, e in ipairs(world:GetDescendants()) do
                                    if e:IsA("BasePart") and table.find(priorityEnemyNames, e.Name) and e:GetAttribute("Died") == false then spawned = true break end
                                end
                                if spawned then break end
                            end
                            char = LocalPlayer.Character
                            hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if not hrp then break end
                            local pivot = target:GetPivot()
                            local pos = pivot.Position
                            if (hrp.Position - pos).Magnitude > 7 then
                                hrp.CFrame = pivot * CFrame.new(0, 0.5, 1.5)
                            end
                            RunService.Heartbeat:Wait()
                        until target:GetAttribute("Died") == true or not target.Parent
                    end
                    task.wait(0.1)
                end
            end
        end)
    end,
})

task.spawn(function()
    while true do
        task.wait(1)
        local inMode = Modes()
        if inMode and not autoFarmLockedByMode then
            if farmRunning then
                autoFarmWasEnabled = true
                farmRunning = false
            end
            if autoFarmToggle then
                autoFarmToggle:Set(false)
                autoFarmToggle:Lock()
            end
            autoFarmLockedByMode = true
            
        elseif not inMode and autoFarmLockedByMode then
            autoFarmLockedByMode = false
            if autoFarmWasEnabled then
                autoFarmToggle:Unlock()
                autoFarmToggle:Set(true)
                farmRunning = true
                autoFarmWasEnabled = false
                notify("Auto Farm", "Mode ended. Auto Farm reactivated.", "play", 2)
            end
        end
    end
end)

AutoFarmSection:Button({
    Title = "Refresh",
    Icon = "refresh-cw",
    Callback = function()
         local names = GetUniqueEnemyNames()
         if npcDD then npcDD:Refresh(names, false) end
         if priorityDD then priorityDD:Refresh(names, false) end
    end,
})

PlayerSection:Slider({
    Title = "Auto Click Range",
    Icon = "ruler",
    Value = { Min = 25, Max = 250, Default = 50 },
    Step = 5,
    Flag = "autoclick_range",
    Callback = function(value)
        clickRange = value
    end,
})

PlayerSection:ToggleKeybind({
    Title = "Auto Click",
    Type = "Toggle",
    Value = false,
    Keybind = "F",
    Icon = "mouse-pointer-click",
    Flag = "player_autoclick",
    Callback = function(Value)
        ac = Value
        notify("AutoClick", tostring(Value), "rbxassetid://132747288758157")
        if not Value then return end
        task.spawn(function()
            while ac do
                if selectedWorld == "" then
                    task.wait(0.5)
                    continue
                end
                local target = FindNearestEnemyInRange(selectedWorld, clickRange)
                if target and IsNPCValid(target) then
                    local args = {
                        {
                            {
                                "Action",
                                "Action",
                                {
                                    Callback = "M1",
                                    Action = "Callback",
                                    Targets = { target }
                                }
                            },
                            "\006"
                        }
                    }
                    pcall(function() rp:FireServer(unpack(args)) end)
                else
                    local args = {
                        {
                            {
                                "Action",
                                "Action",
                                {
                                    Callback = "M1",
                                    Action = "Callback"
                                }
                            },
                            "\006"
                        }
                    }
                    pcall(function() rp:FireServer(unpack(args)) end)
                end
                
                RunService.Heartbeat:Wait()
            end
        end)
    end,
})

--local args = {{{"TrialReceiver","Join","Easy"},"\006"}} rp:FireServer(unpack(args))

local savedStarRollPos = nil

PlayerSection:Toggle({
    Title = "Star Roll",
    Icon = "package-open",
    Value = false,
    Flag = "upgrades_starroll",
    Callback = function(Value)
        autopetroll = Value
        local summon = workspace:FindFirstChild("Game") 
            and workspace.Game:FindFirstChild("Zones") 
            and workspace.Game.Zones:FindFirstChild("Summons") 
            and workspace.Game.Zones.Summons:FindFirstChild("Summon")
        if Value then
            if not farmRunning then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then savedStarRollPos = hrp.CFrame end
            end
            if summon and summon:IsA("BasePart") then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then 
                    hrp.CFrame = summon.CFrame + Vector3.new(0, 5, 0) 
                end
            end
        elseif not Value and savedStarRollPos then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = savedStarRollPos end
            savedStarRollPos = nil
        end
        
        if not Value then return end
        
        task.spawn(function()
            while autopetroll do
                -- Remote comprimido em linha única
                pcall(function() rp:FireServer({{"Pets","Summon",{useMaxRoll=true}},"\006"}) end)
                task.wait(0.5)
            end
        end)
    end,
})
