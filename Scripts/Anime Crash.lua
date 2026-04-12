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

local starRollActive = false
local starRollConnections = {}
local starRollTask = nil
local summonPart = nil

local function cleanupStarRollConnections()
    for _, conn in ipairs(starRollConnections) do
        pcall(function() conn:Disconnect() end)
    end
    starRollConnections = {}
end
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

AboutHubTab:Stats({
    Title = "Null Hub Information",
    Desc = "Null Hub is a premium automation interface built for ".. tostring(GameName) ..", designed to enhance your gameplay with efficient, secure, and user-friendly features.",
    Items = {
        {Key = "Discord", Value = "Join our community"},
        {Key = "YouTube Channel", Value = "New Scripts & Updates"},
        {Key = "Website", Value = "Official Portal"},
    },
})

local Aboutg = AboutHubTab:Group({})
Aboutg:Button({
    Title = "YouTube",
    Icon = "youtube",
    IconAlign = "Left",
    Justify = "Center",
    Callback = function()
        WindUI:Notify({
            Title = "YouTube",
            Content = "Channel coming soon! Stay tuned for tutorials and updates.",
            Icon = "rbxassetid://90057404579525",
            Duration = 2.5,
        })
    end,
})

Aboutg:Button({
    Title = "Discord",
    Icon = "rbxassetid://101192191207677",
    IconAlign = "Left",
    Justify = "Center",
    Callback = function()
        setclipboard("https://discord.gg/m3Q6CPbCS9")
        WindUI:Notify({
            Title = "Discord",
            Content = "Invite link copied to clipboard!",
            Icon = "rbxassetid://90057404579525",
            Duration = 2.5,
        })
    end,
})

Aboutg:Button({
    Title = "Website",
    Icon = "globe",
    IconAlign = "Left",
    Justify = "Center",
    Callback = function()
        WindUI:Notify({
            Title = "Website",
            Content = "Official website coming soon! Check back later for updates.",
            Icon = "rbxassetid://90057404579525",
            Duration = 2.5,
        })
    end,
})

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
        if enemy:IsA("BasePart") and enemy.Name ~= "HumanoidRootPart" then
            names[enemy.Name] = true
        end
    end

    local list = {}
    for name in pairs(names) do
        table.insert(list, name)
    end
    table.sort(list)
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


local function FindNearestEnemyAnyWorld(range)
    local mobsServer = workspace:FindFirstChild("Game") 
        and workspace.Game:FindFirstChild("Mobs") 
        and workspace.Game.Mobs:FindFirstChild("Server")
    
    if not mobsServer then return nil end
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local nearest = nil
    local nearestDist = range
    
    -- Varre TODOS os mundos disponíveis
    for _, worldFolder in ipairs(mobsServer:GetChildren()) do
        if worldFolder:IsA("Folder") or worldFolder:IsA("Model") then
            for _, obj in ipairs(worldFolder:GetDescendants()) do
                if obj:IsA("BasePart") 
                    and obj.Name ~= "HumanoidRootPart"
                    and IsNPCValid(obj)  -- Verifica Died == false
                then
                    local dist = (hrp.Position - obj.Position).Magnitude
                    if dist < nearestDist then
                        nearest = obj
                        nearestDist = dist
                    end
                end
            end
        end
    end
    
    return nearest
end

-- ==================== AUTO FARM (mantido original com ajustes) ====================
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
                -- Segurança: para se entrar em Mode
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
                
                -- Usa o mundo selecionado na dropdown
                local world = workspace.Game.Mobs.Server:FindFirstChild(selectedWorld)
                if not world then task.wait(0.5) continue end

                -- Verifica prioridades
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

                    -- Busca target específico no mundo selecionado
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
                            
                            -- Re-check de prioridades durante o farm
                            if #priorityEnemyNames > 0 and not table.find(priorityEnemyNames, name) then
                                local spawned = false
                                for _, e in ipairs(world:GetDescendants()) do
                                    if e:IsA("BasePart") and table.find(priorityEnemyNames, e.Name) and e:GetAttribute("Died") == false then 
                                        spawned = true 
                                        break 
                                    end
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
--game:GetService("Players").LocalPlayer.PlayerGui.Paradox.ModesInfo.Wave
-- ==================== AUTO CLICK - INDEPENDENTE DE WORLD ====================
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
                -- Busca NPC em QUALQUER mundo dentro do range
                local target = FindNearestEnemyAnyWorld(clickRange)
                
                if target and IsNPCValid(target) then
                    -- NPC no range: usa remote com alvo específico
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
                    -- Sem NPC no range: usa click normal (sem alvo)
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


PlayerSection:Toggle({
    Title = "Star Roll",
    Icon = "package-open",
    Value = false,
    Flag = "upgrades_starroll",
    Callback = function(Value)
        autopetroll = Value

        summonPart = workspace:FindFirstChild("Game")
            and workspace.Game:FindFirstChild("Zones")
            and workspace.Game.Zones:FindFirstChild("Summons")
            and workspace.Game.Zones.Summons:FindFirstChild("GachaModel")

        if Value then
            if not summonPart then
                notify("Error", "Summon part not found!", "alert-circle", 3)
                return
            end

            starRollActive = true
            farmRunning = false
            if autoFarmToggle and autoFarmToggle.Set then
                autoFarmToggle:Set(false)
            end

            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = summonPart:GetPivot()
            end

            pcall(function() rp:FireServer({{"Pets","Summon",{useMaxRoll=true}},"\006"}) end)

            local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
            if not playerGui then
                starRollActive = false
                farmRunning = true
                return
            end

            local summonAnimate = playerGui:WaitForChild("SummonAnimate", 10)
            if not summonAnimate then
                starRollActive = false
                farmRunning = true
                return
            end

            local gachaFrame = summonAnimate:WaitForChild("Gacha", 10)
            if not gachaFrame then
                starRollActive = false
                farmRunning = true
                return
            end

            local hasPetVisible = false

            local function isValidPetFrame(child)
                if not child:IsA("Frame") and not child:IsA("TextButton") then
                    return false
                end
                local name = child.Name:lower()
                local ignored = {"template","viewport","frame","stop","uigridthlayout","uilistlayout","uiaspectratioconstraint","uipadding","uicorner"}
                for _, ign in ipairs(ignored) do
                    if name:find(ign) then
                        return false
                    end
                end
                return child:FindFirstChild("TextLabel") or child:FindFirstChild("ImageLabel") or name:match("%w+")
            end

            local connAdded = gachaFrame.ChildAdded:Connect(function(child)
                if isValidPetFrame(child) then
                    hasPetVisible = true
                end
            end)

            local connRemoved = gachaFrame.ChildRemoved:Connect(function(child)
                if isValidPetFrame(child) then
                    hasPetVisible = false
                end
            end)

            table.insert(starRollConnections, connAdded)
            table.insert(starRollConnections, connRemoved)

            starRollTask = task.spawn(function()
                while starRollActive and autopetroll do
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and summonPart then
                        hrp.CFrame = summonPart:GetPivot()
                    end

                    pcall(function() rp:FireServer({{"Pets","Summon",{useMaxRoll=true}},"\006"}) end)

                    local waitCount = 0
                    while not hasPetVisible and starRollActive and autopetroll do
                        task.wait(0.1)
                        waitCount = waitCount + 0.1
                        if waitCount > 6 then
                            break
                        end
                    end

                    while hasPetVisible and starRollActive and autopetroll do
                        task.wait(0.1)
                    end

                    task.wait(1)
                end

                if autoFarmToggle and autoFarmToggle.Set and not starRollActive then
                    farmRunning = true
                    autoFarmToggle:Set(true)
                end
            end)

        elseif not Value then
            starRollActive = false

            if starRollTask then
                task.cancel(starRollTask)
                starRollTask = nil
            end

            cleanupStarRollConnections()

            if autoFarmToggle and autoFarmToggle.Set then
                farmRunning = true
                autoFarmToggle:Set(true)
            end
        end
    end,
})

PlayerSection:Toggle({
    Title = "Auto Rankup",
    Icon = "gem",
    Value = false,
    Flag = "player_arankup",
    Callback = function(Value)
        autoEquip = Value
        if not Value then return end
        task.spawn(function()
            while autoEquip do
                pcall(function()
                    rp:FireServer({{"Rank","Rankup"},"\006"})
                end)
                task.wait(15)
            end
        end)
    end,
})

PlayerSection:Toggle({
    Title = "Auto Equip Best All",
    Icon = "gem",
    Value = false,
    Flag = "player_autoequipbest",
    Callback = function(Value)
        autoEquip = Value
        if not Value then return end
        task.spawn(function()
            while autoEquip do
                pcall(function()
                  rp:FireServer({{"Pets","EquipBest"},"\006"})
                    rp:FireServer({{"WarriorSystem","EquipBest"},"\006"})
                end)
                task.wait(15)
            end
        end)
    end,
})

-- ==================== GAMEMODES TAB ====================
local GMM = GmTab:MultiSection({
    Title = "Gamemodes Area",
    Icon = "rows-3",
    Opened = true,
    Box = true,
    BoxBorder = true,
})
local GamemodeSection = GMM:Tab({ Title = "Auto Modes", Icon = "repeat" })
local SaveSection = GMM:Tab({ Title = "Save Position", Icon = "map-pin" })
local LeaveSection = GMM:Tab({ Title = "Retry/Leave", Icon = "arrow-right-left" })

-- ==================== CONFIGURAÇÃO DOS MODOS ====================
local TRIAL_DIFFICULTIES = {"Easy"}
local RAID_DIFFICULTIES = {"Normal", "Medium", "Hard", "Extreme"}
local MODE_PRIORITIES = {"Raid", "Trial"}
local MODE_SCHEDULES = {
    ["Trial"] = {minutes = {0, 30}},
    ["Raid"] = {always = true},
}

-- ==================== FUNÇÕES AUXILIARES DE GAMEMODES ====================
local function GetCurrentWave()
    pcall(function()
        local modesInfo = LocalPlayer.PlayerGui:WaitForChild("Paradox", 10):WaitForChild("ModesInfo", 10)
        if modesInfo and modesInfo:FindFirstChild("Wave") then
            return tonumber(modesInfo.Wave.ContentText:match("%d+")) or 0
        end
    end)
    return 0
end

local function IsAvailable(modeName)
    local s = MODE_SCHEDULES[modeName]
    return s and (s.always or table.find(s.minutes, os.date("*t").min)) or false
end

local function CanJoinMode(modeName)
    return table.find(selectedModes, modeName) and not (justLeftMode[modeName] and os.time() - justLeftMode[modeName] < 55) and IsAvailable(modeName)
end

local function GetHighestPriorityAvailable()
    for _, m in ipairs(MODE_PRIORITIES) do
        if CanJoinMode(m) then
            return m
        end
    end
    return nil
end

local function JoinMode(modeName, difficulty)
    if joiningMode then return end
    joiningMode = true
    task.spawn(function()
        repeat
            pcall(function()
                if modeName == "Raid" then
                    rp:FireServer({{{"Gamemodes","Create",{Raid="Frieza Force Invasion",Gamemode="Raid",Mode=difficulty}}},"\006"})
                else
                    rp:FireServer({{{"TrialReceiver","Join",difficulty or "Easy"},"\006"}})
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
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and SvPosition and selectedMap ~= "" then
        task.wait(1)
        pcall(function()
            rp:FireServer({{{"Teleporter","Teleport",{World= selectedMap}},"\006"}})
        end)
        task.wait(0.5)
        hrp.CFrame = CFrame.new(SvPosition)
    end
    justLeftMode[currentMode] = os.time()
    currentMode = nil
    joiningMode = false
    hasJustTeleported = false
end

-- ==================== TIMER PARAGRAPH ====================
local TimerPara = GamemodeSection:Paragraph({
    Title = "Timer Tracker",
    Icon = "clock-fading",
    Content = "Loading...",
})

task.spawn(function()
    while true do
        local min, sec = os.date("*t").min, os.date("*t").sec
        local raidTimer = string.format("%02d:%02d", math.abs(min - (min < 29 and 29 or 59)), (60 - sec) % 60)
        local wave = GetCurrentWave()
        TimerPara:SetDesc("Wave: " .. wave .. " | Next Trial: " .. raidTimer .. " | Raid: Always")
        task.wait(1)
    end
end)

-- ==================== DROPDOWN DE MODOS E DIFICULDADE ====================
GamemodeSection:Dropdown({
    Title = "Select Modes",
    Icon = "list",
    Values = {"Trial", "Raid"},
    Multi = true,
    Flag = "gamemodes_selected",
    Callback = function(val) selectedModes = val or {} end,
})

GamemodeSection:Dropdown({
    Title = "Trial Difficulty",
    Icon = "trending-up",
    Values = TRIAL_DIFFICULTIES,
    Value = "",
    Flag = "gamemodes_trial_difficulty",
    Callback = function(val)
        selectedTrialDifficulty = val
    end,
})

GamemodeSection:Dropdown({
    Title = "Raid Difficulty",
    Icon = "sword",
    Values = RAID_DIFFICULTIES,
    Value = "",
    Flag = "gamemodes_raid_difficulty",
    Callback = function(val)
        selectedRaidDifficulty = val
    end,
})

-- ==================== AUTO JOIN TOGGLE ====================
GamemodeSection:Toggle({
    Title = "Auto Join",
    Icon = "door-open",
    Value = false,
    Flag = "gamemodes_autojoin",
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
                    if not best then task.wait(5) return end
                    if currentMode == best then task.wait(5) return end
                    if currentMode and currentMode ~= best then
                        LeaveCurrentMode()
                        task.wait(2)
                        return
                    end
                    if not inMode and not joiningMode then
                        local difficulty = best == "Raid" and selectedRaidDifficulty or selectedTrialDifficulty
                        JoinMode(best, difficulty)
                    end
                end)
                task.wait(1)
            end
        end)
    end,
})

GamemodeSection:Toggle({
    Title = "Auto Farm Modes",
    Icon = "user-cog",
    Value = false,
    Flag = "gamemodes_autofarm",
    Callback = function(Value)
        modeFarm = Value
        if not Value then return end
        task.spawn(function()
            while modeFarm do
                if not Modes() then task.wait(0.5) continue end
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then task.wait(0.5) continue end

                local target = nil
                
                if currentMode == "Raid" then
                    for _, e in ipairs(workspace:GetDescendants()) do
                        if e:IsA("BasePart") and e:GetAttribute("Died") == false and e:GetAttribute("Raid") == true then
                            target = e
                            break
                        end
                    end
                else
                    for _, e in ipairs(workspace:GetDescendants()) do
                        if e:IsA("BasePart") and e:GetAttribute("Died") == false then
                            target = e
                            break
                        end
                    end
                end

                if target then
                    repeat
                        if not modeFarm or target:GetAttribute("Died") == true then break end
                        if not Modes() then break end
                        char = LocalPlayer.Character
                        hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if not hrp then break end
                        local pivot = target:GetPivot()
                        local pos = pivot.Position
                        if (hrp.Position - pos).Magnitude > 6 then
                            hrp.CFrame = pivot * CFrame.new(0, 0, 1.5)
                        end
                        RunService.Heartbeat:Wait()
                    until target:GetAttribute("Died") == true or not target.Parent
                    task.wait(0.1)
                else
                    task.wait(0.5)
                end
            end
        end)
    end,
})

-- ==================== SAVE POSITION ====================
SaveSection:Button({
    Title = "Save Position",
    Icon = "map-pin",
    Callback = function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then SvPosition = hrp.Position end
    end,
})

SaveSection:Dropdown({
    Title = "Map to Leave",
    Icon = "map",
    Values = GetWorlds(),
    Placeholder = "Select Map",
    Flag = "gamemodes_map",
    Callback = function(val) selectedMap = val or "" end,
})

-- ==================== AUTO LEAVE COM WAVE ====================
SaveSection:Toggle({
    Title = "Auto Leave",
    Icon = "door-closed",
    Value = false,
    Flag = "gamemodes_autoleave",
    Callback = function(Value)
        AutoLeaveAll = Value
        if not Value then return end
        task.spawn(function()
            local wasIn = false
            while AutoLeaveAll do
                pcall(function()
                    local inMode = Modes()
                    if inMode then
                        wasIn = true
                    elseif wasIn and not inMode then
                        wasIn = false
                        LeaveCurrentMode()
                        return
                    end

                    if inMode and lvwave ~= "" then
                        local currentWave = GetCurrentWave()
                        if currentWave >= tonumber(lvwave) then
                            wasIn = false
                            LeaveCurrentMode()
                        end
                    end
                    if not inMode then hasJustTeleported = false end
                end)
                task.wait(0.5)
            end
        end)
    end,
})

-- ==================== INPUT DE WAVE PARA SAIR ====================
LeaveSection:Input({
    Title = "Set Wave to Leave",
    Icon = "text-cursor-input",
    Numeric = true,
    Flag = "gamemodes_wave",
    Callback = function(val) lvwave = tostring(val or "") end,
})

local ShopMulti = GmTab:MultiSection({
    Title = "Shop & Upgrades",
    Icon = "shopping-cart",
    Opened = true,
    Box = true,
    BoxBorder = true,
})

local UpgradesTab = ShopMulti:Tab({ Title = "Upgrades", Icon = "trending-up" })
local TrialShopTab = ShopMulti:Tab({ Title = "Trial Shop", Icon = "store" })

local selectedUpgrade = ""
local selectedTrialItem = ""
local trialQuantity = 1
local AutoBuyUpgrade = false
local AutoBuyTrial = false
UpgradesTab:Dropdown({
    Title = "Select Upgrade",
    Values = {
        "Energy", "Gems", "Luck", "Damage", "Movement Speed",
        "Fast Roll", "More Open Star", "More Gacha Open",
        "More Storage", "Drop"
    },
    Value = nil,
    Flag = "shop_upgrade_type",
    Callback = function(val)
        selectedUpgrade = val
    end,
})

UpgradesTab:Toggle({
    Title = "Auto Buy Upgrade",
    Icon = "shopping-cart",
    Value = false,
    Flag = "shop_autobuy_upgrade",
    Callback = function(state)
        AutoBuyUpgrade = state
        if state then
            task.spawn(function()
                while AutoBuyUpgrade do
                    if selectedUpgrade ~= "" then
                        pcall(function()
                        rp:FireServer(unpack({{{"Upgrade","Buy",{Upgrade=selectedUpgrade}},"\006"}}))
                        end)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end,
})

TrialShopTab:Dropdown({
    Title = "Select Item",
    Values = {
        "Energy Potion", "Gems Potion", "Damage Potion",
        "Exp Potion", "Drop Potion", "Luck Potion", "Frieza Key"
    },
    Value = nil,
    Flag = "shop_trial_item",
    Callback = function(val)
        selectedTrialItem = val
    end,
})

TrialShopTab:Input({
    Title = "Quantity",
    Icon = "hash",
    Numeric = true,
    Value = "1",
    Flag = "shop_trial_qty",
    Callback = function(val)
        trialQuantity = math.max(tonumber(val) or 1, 1)
    end,
})

TrialShopTab:Toggle({
    Title = "Auto Buy Trial Item",
    Icon = "shopping-bag",
    Value = false,
    Flag = "shop_autobuy_trial",
    Callback = function(state)
        AutoBuyTrial = state
        if state then
            task.spawn(function()
                while AutoBuyTrial do
                    if selectedTrialItem ~= "" then
                        pcall(function()
                         rp:FireServer(unpack({{{"TrialShop","Buy",{selectedTrialItem, trialQuantity}},"\006"}}))
                        end)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end,
})


-- ==================== MISC SECTION (Redesigned) ====================
local MiscSection = ConfigTab:Section({ 
    Title = "Miscellaneous", 
    Icon = "settings",
    Box = true,
    BoxBorder = true,
})

local SpeedGroup = MiscSection:Group({})
SpeedGroup:Slider({
    Title = "Walk Speed",
    Icon = "gauge",
    Value = { Min = 16, Max = 200, Default = 70 },
    Step = 1,
    Flag = "misc_speed",
    Callback = function(value)
        speedValue = value
        if applySpeedActive then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = value end
        end
    end,
})

SpeedGroup:Toggle({
    Title = "Apply Speed",
    Icon = "zap",
    Value = false,
    Flag = "misc_applyspeed",
    Callback = function(Value)
        applySpeedActive = Value
        if Value then
            task.spawn(function()
                while applySpeedActive do
                    pcall(function()
                        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if hum then hum.WalkSpeed = speedValue end
                    end)
                    task.wait(0.1)
                end
            end)
        else
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 16 end
            end)
        end
    end,
})

MiscSection:Divider()
local UtilityGroup = MiscSection:Group({})
UtilityGroup:Toggle({
    Title = "Anti AFK",
    Icon = "shield-check",
    Value = false,
    Flag = "misc_antiafk",
    Callback = function(Value)
        antiAfkActive = Value
    end,
})

UtilityGroup:Toggle({
    Title = "Visual AFK Mode",
    Icon = "monitor-off",
    Value = false,
    Flag = "misc_visualafk",
    Callback = function(Value)
        afkModeEnabled = Value
        if not Value then return end
        task.spawn(function()
            local cam = Workspace.CurrentCamera
            local stored, disabledLights, disabledFX = {}, {}, {}
            local oldCamType, oldCamCFrame, camConn
            
            local function potatoWorld(enable)
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        if enable then 
                            stored[v] = v.Material 
                            v.Material = Enum.Material.Plastic 
                            v.CastShadow = false
                        elseif stored[v] then 
                            v.Material = stored[v] 
                        end
                    elseif v:IsA("Texture") or v:IsA("Decal") then 
                        v.Transparency = enable and 1 or 0 
                    end
                end
                if not enable then stored = {} end
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
                    oldCamType = cam.CameraType 
                    oldCamCFrame = cam.CFrame 
                    cam.CameraType = Enum.CameraType.Scriptable
                    camConn = RunService.RenderStepped:Connect(function() 
                        cam.CFrame = CFrame.new(0, 999999, 0) 
                    end)
                else
                    if camConn then camConn:Disconnect() end
                    cam.CameraType = oldCamType or Enum.CameraType.Custom
                    if oldCamCFrame then cam.CFrame = oldCamCFrame end
                end
            end

            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            potatoWorld(true) 
            toggleLights(true) 
            toggleFX(true) 
            lockCamera(true)
            
            repeat task.wait() until not afkModeEnabled
            
            potatoWorld(false) 
            toggleLights(false) 
            toggleFX(false) 
            lockCamera(false)
        end)
    end,
})

LocalPlayer.Idled:Connect(function()
    if antiAfkActive then
        local cam = Workspace.CurrentCamera
        if cam then
            VirtualUser:Button2Down(Vector2.zero, cam.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.zero, cam.CFrame)
        end
    end
end)

MiscSection:Divider()
local ActionsGroup = MiscSection:Group({})
ActionsGroup:Button({
    Title = "FPS Booster",
    Icon = "zap",
    Variant = "Primary",
    Justify = "Center",
    Callback = function()
        pcall(function()
            Lighting.GlobalShadows = false 
            Lighting.FogEnd = 9e9 
            Lighting.ShadowSoftness = 0
            if sethiddenproperty then 
                sethiddenproperty(Lighting, "Technology", 2) 
            end
            settings().Rendering.QualityLevel = 1 
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
            for _, v in pairs(MaterialService:GetChildren()) do 
                v:Destroy() 
            end
            MaterialService.Use2022Materials = false
            if setfpscap then 
                setfpscap(1e6) 
            end
            local terr = workspace:FindFirstChildOfClass("Terrain")
            if terr then
                terr.WaterWaveSize = 0 
                terr.WaterWaveSpeed = 0 
                terr.WaterReflectance = 0 
                terr.WaterTransparency = 0
                if sethiddenproperty then 
                    sethiddenproperty(terr, "Decoration", false) 
                end
            end
        end)
        for _, v in pairs(game:GetDescendants()) do 
            processInstance(v) 
        end
        game.DescendantAdded:Connect(function(v) 
            task.wait(0.5) 
            processInstance(v) 
        end)
        notify("FPS Optimized", "Graphics settings optimized for performance", "rbxassetid://90057404579525", 3)
    end,
})

AboutHubTab:Dropdown({
    Title = "Choose Null Theme",
    Flag = "themes_selected",
    Values = { "Moon", "Grey", "Midv2" },
    Callback = function(SelectedTheme)
        WindUI:SetTheme(SelectedTheme)
        ApplyThemeToUI(SelectedTheme)
    end
})
-- ==================== CONFIG TAB ====================
local ConfigSection = ConfigTab:Section({ 
    Title = "Configuration Manager", 
    Icon = "settings",
    Box = true,
    BoxBorder = true,
})

local ConfigStats = ConfigSection:Stats({
    Title = "Config Status",
    Desc = "Current configuration status",
    Items = {
        {Key = "Current Config", Value = "None"},
        {Key = "Auto Load Config", Value = "None"},
        {Key = "Total Configs", Value = "0"},
    },
})

local selectedConfigName = "default"
local ConfigManager = Window.ConfigManager
local currentAutoLoadConfig = "None"

ConfigSection:Input({
    Title = "Config Name",
    Icon = "file-pen",
    Value = "default",
    Placeholder = "Enter config name...",
    Flag = "config_name_input",
    Callback = function(value)
        if value and value ~= "" then
            selectedConfigName = value
            ConfigStats:Update("Current Config", selectedConfigName)
        end
    end,
})

ConfigSection:Button({
    Title = "Create Config",
    Icon = "file-plus",
    Callback = function()
        if selectedConfigName and selectedConfigName ~= "" then
            local cfg = ConfigManager:Config(selectedConfigName)
            if cfg then
                cfg:Save()
                notify("Config Created", "Config '" .. selectedConfigName .. "' created successfully!", "check", 3)
                local allConfigs = ConfigManager:AllConfigs()                
                ConfigStats:Update("Total Configs", tostring(#allConfigs))
            end
        else
            notify("Error", "Please enter a valid config name!", "alert-circle", 3)
        end
    end,
})
ConfigSection:Divider()
local allConfigs = ConfigManager:AllConfigs()
local defaultConfig = table.find(allConfigs, "default") and "default" or allConfigs[1]

ConfigSection:Dropdown({
    Title = "Select Config",
    Icon = "folder",
    Values = allConfigs,
    Value = defaultConfig,
    Flag = "config_selector",
    Callback = function(value)
        if value then
            selectedConfigName = value
            ConfigStats:Update("Current Config", selectedConfigName)

            local cfg = ConfigManager:Config(selectedConfigName)
            if cfg then
                local data = cfg:GetData()
                local autoloadStatus = (data and data.autoload == true) and "Enabled" or "Disabled"
                ConfigStats:Update("Auto Load Config", autoloadStatus)
            end
        end
    end,
})

local ButtonRow1 = ConfigSection:Group({})
ButtonRow1:Button({
    Title = "Load Config",
    Icon = "download",
    Justify = "Center",
    Callback = function()
        if selectedConfigName then
            local cfg = ConfigManager:Config(selectedConfigName)
            if cfg:Load() then
                notify("Config Loaded", "Config '" .. selectedConfigName .. "' loaded successfully!", "check", 3)
                                -- Atualizar stats
                local data = cfg:GetData()
                if data then
                    local autoloadStatus = (data.autoload == true) and "Enabled" or "Disabled"
                    ConfigStats:Update("Auto Load Config", autoloadStatus)
                end
                ConfigStats:Update("Current Config", selectedConfigName)
            else
                notify("Error", "Failed to load config!", "alert-circle", 3)
            end
        end
    end,
})

ButtonRow1:Button({
    Title = "Update Config",
    Icon = "refresh-cw",
    Justify = "Center",
    Callback = function()
        if selectedConfigName then
            local cfg = ConfigManager:Config(selectedConfigName)
            if cfg:Save() then
                notify("Config Updated", "Config '" .. selectedConfigName .. "' updated successfully!", "check", 3)
                
                -- Atualizar total de configs
                local allCfgs = ConfigManager:AllConfigs()
                ConfigStats:Update("Total Configs", tostring(#allCfgs))
            else
                notify("Error", "Failed to update config!", "alert-circle", 3)
            end
        end
    end,
})

-- Refresh Config List Button
ConfigSection:Button({
     Title = "Refresh Config List",
    Icon = "rotate-ccw",
    Callback = function()
        local updatedConfigs = ConfigManager:AllConfigs()
        ConfigStats:Update("Total Configs", tostring(#updatedConfigs))
        notify("Refreshed", "Configuration list updated!", "check", 2)
    end,
})

ConfigSection:Divider()

ConfigSection:Toggle({
    Title = "Autoload Config",    Icon = "loader",
    Value = false,
    Flag = "config_autoload_toggle",
    Callback = function(value)
        if selectedConfigName then
            local cfg = ConfigManager:Config(selectedConfigName)
            cfg:SetAutoLoad(value)
            cfg:Save()
            
            local autoloadStatus = value and "Enabled" or "Disabled"
            ConfigStats:Update("Auto Load Config", autoloadStatus)
            currentAutoLoadConfig = value and selectedConfigName or "None"
            
            if value then
                notify("Autoload Enabled", "Config '" .. selectedConfigName .. "' will load on startup!", "check", 3)
            else
                notify("Autoload Disabled", "Autoload disabled for this config!", "info", 3)
            end
        end
    end,
})

ConfigSection:Divider()
ConfigSection:Paragraph({
    Title = "DANGER ZONE",
    Content = "> These actions cannot be undone. Proceed with caution!",
})
local DangerGroup = ConfigSection:Group({})

DangerGroup:Button({
    Title = "Clear Autoload",
    Icon = "circle-x",
    Color = Color3.fromHex("#F59E0B"),
    Justify = "Center",
    Callback = function()
        if selectedConfigName then
            local cfg = ConfigManager:Config(selectedConfigName)
            cfg:SetAutoLoad(false)
            cfg:Save()
            ConfigStats:Update("Auto Load Config", "Disabled")
            currentAutoLoadConfig = "None"
            notify("Autoload Cleared", "Autoload configuration cleared!", "check", 3)
        end
    end,
})
DangerGroup:Button({
    Title = "Delete Config",
    Icon = "trash-2",
    Color = Color3.fromHex("#EF4444"),
    Justify = "Center",
    Callback = function()
        if selectedConfigName then
            Window:Dialog({
                Title = "Confirm Deletion",
                Content = "Are you sure you want to delete config '" .. selectedConfigName .. "'?\n\nThis action <font color='#EF4444'>cannot be undone</font>!",
                Icon = "alert-triangle",
                Buttons = {
                    {
                        Title = "Cancel",
                        Variant = "Secondary",
                        Callback = function() end,
                    },
                    {
                        Title = "Delete",
                        Variant = "Danger",
                        Callback = function()
                            if ConfigManager:DeleteConfig(selectedConfigName) then
                                notify("Config Deleted", "Config '" .. selectedConfigName .. "' deleted successfully!", "trash-2", 3)
                                -- Refresh dropdown
                                local updatedConfigs = ConfigManager:AllConfigs()
                                ConfigStats:Update("Total Configs", tostring(#updatedConfigs))
                                if #updatedConfigs > 0 then
                                    selectedConfigName = updatedConfigs[1]
                                    ConfigStats:Update("Current Config", selectedConfigName)
                                else
                                    selectedConfigName = "default"
                                    ConfigStats:Update("Current Config", "None")
                                end
                                ConfigStats:Update("Auto Load Config", "Disabled")
                                currentAutoLoadConfig = "None"
                            else
                                notify("Error", "Failed to delete config!", "alert-circle", 3)
                            end
                        end,
                    },
                },
            })
        end
    end,
})

-- Inicializar stats
task.spawn(function()
    task.wait(0.5)
    local allCfgs = ConfigManager:AllConfigs()    ConfigStats:Update("Total Configs", tostring(#allCfgs))
    
    -- Verificar autoload
    local autoLoadConfigs = ConfigManager:GetAutoLoadConfigs()
    if #autoLoadConfigs > 0 then
        currentAutoLoadConfig = autoLoadConfigs[1]
        ConfigStats:Update("Current Config", currentAutoLoadConfig)
        ConfigStats:Update("Auto Load Config", "Enabled")
    else
        ConfigStats:Update("Current Config", "None")
        ConfigStats:Update("Auto Load Config", "None")
    end
end)

task.delay(0.5, function()
    notify(
        "Script Status",
        "• You're now using NullHub, baby.\n• Script loaded Successfully.",
        "rbxassetid://90057404579525",
        3
    )
end)

task.delay(0.5, function()
    Window:Dialog({
        Title = "Welcome to Null Hub",
        Content = GameName,
        Icon = "rbxassetid://90057404579525",
        Buttons = {
            {
                Title = "Enjoy!",
                Variant = "Primary",
                Callback = function()
                notify("Ty", "for choosing to use Null Hub.", "rbxassetid://90057404579525")
                end,
            },
        },
    })
end) 
