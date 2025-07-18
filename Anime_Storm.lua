local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Anime Storm",
    SubTitle = " In Latency",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "sword" }),
    Trials = Window:AddTab({ Title = "Trial/Tower/Boss", Icon = "flame" }),
    Summer = Window:AddTab({ Title = "SummerEvent", Icon = "sun" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "list" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

Tabs.Main:AddSection("Toggles")
local autoClick = false
Tabs.Main:AddToggle("AutoClickDamage", {
    Title = "Auto Click + Damage",
    Default = false,
    Callback = function(state)
        autoClick = state
        task.spawn(function()
            while autoClick do
                game:GetService("ReplicatedStorage").Remotes.Input:FireServer("GainStrength")
                task.wait()
            end
        end)
    end
})

local selectedEnemy = nil
local function getAllNPCsWithName(name)
    local all = {}
    for _, folder in ipairs(workspace.Npc:GetChildren()) do
        if folder:IsA("Folder") then
            for _, npc in ipairs(folder:GetChildren()) do
                if npc:IsA("Model") and npc.Name == name then
                    table.insert(all, npc)
                end
            end
        end
    end
    local hidden = game:GetService("ReplicatedStorage"):FindFirstChild("HiddenNpcs")
    if hidden then
        for _, npc in ipairs(hidden:GetChildren()) do
            if npc:IsA("Model") and npc.Name == name then
                table.insert(all, npc)
            end
        end
    end
    return all
end

local autoFarm = false
Tabs.Main:AddToggle("AutoFarmEnemies", {
    Title = "Auto Farm Enemies",
    Default = false,
    Callback = function(state)
        autoFarm = state
        task.spawn(function()
            while autoFarm do
                if selectedEnemy then
                    for _, npc in ipairs(getAllNPCsWithName(selectedEnemy)) do
                        if not autoFarm then break end
                        if npc:FindFirstChild("HumanoidRootPart") then
                            local char = game.Players.LocalPlayer.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                char:MoveTo(npc.HumanoidRootPart.Position + Vector3.new(0, 0, 3))
                            end
                            repeat
                                task.wait(0.1)
                            until not npc:IsDescendantOf(game) or (npc:FindFirstChild("Health") and npc.Health.Value <= 0) or not autoFarm
                        end
                    end
                end
                task.wait(1.5)
            end
        end)
    end
})

Tabs.Main:AddSection(" Worlds")
local selectedWorld = "nothing"
local function getWorlds()
    local result = {}
    for _, folder in ipairs(workspace.Npc:GetChildren()) do
        if folder:IsA("Folder") then
            table.insert(result, folder.Name)
        end
    end
    return result
end

Tabs.Main:AddDropdown("SelectWorld", {
    Title = "Select World",
    Values = getWorlds(),
    Multi = false,
    Default = nil,
    Callback = function(value)
        selectedWorld = value
    end
})

local function getNpcListFromWorld()
    local names, added = {}, {}
    local folder = workspace.Npc:FindFirstChild(selectedWorld)
    if folder then
        for _, npc in ipairs(folder:GetChildren()) do
            if npc:IsA("Model") and not added[npc.Name] then
                table.insert(names, npc.Name)
                added[npc.Name] = true
            end
        end
    end
    return names
end

local enemyDropdown = Tabs.Main:AddDropdown("EnemyDropdown", {
    Title = "Enemies",
    Values = getNpcListFromWorld(),
    Multi = false,
    Default = nil,
    Callback = function(value)
        selectedEnemy = value
    end
})

Tabs.Main:AddButton({
    Title = "Refresh Enemies",
    Description = "Refresh lol",
    Callback = function()
        enemyDropdown:SetValues(getNpcListFromWorld())
    end
})

Tabs.Main:AddSection(" Eggs")
local selectedEgg = "?"
Tabs.Main:AddDropdown("SelectEgg", {
    Title = "Select Egg",
    Values = { "Dbz", "Naruto", "Bleach", "Summer2025", "Jjk", "DemonSlayer", "OnePiece" },
    Multi = false,
    Default = nil,
    Callback = function(value)
        selectedEgg = value
    end
})

local autoEgg = false
Tabs.Main:AddToggle("AutoOpenEggs", {
    Title = "Auto Open Eggs",
    Default = false,
    Callback = function(state)
        autoEgg = state
        task.spawn(function()
            while autoEgg do
                game.ReplicatedStorage.Remotes.Egg.EggHatch:InvokeServer("Hatch", selectedEgg)
                task.wait(0.2)
            end
        end)
    end
})

Tabs.Misc:AddToggle("AutoCollectTimeRewards", {
    Title = "Auto Collect TimeRewards",
    Default = false,
    Callback = function(state)
        task.spawn(function()
            while state do
                for i = 1, 8 do
                    game.ReplicatedStorage.Remotes.TimedRewards:FireServer("Reward" .. i)
                    task.wait(1)
                end
                task.wait(600)
            end
        end)
    end
})

Tabs.Misc:AddToggle("AutoRankup", {
    Title = "Auto Rankup",
    Default = false,
    Callback = function(state)
        task.spawn(function()
            while state do
                game.ReplicatedStorage.Remotes.Rebirth:FireServer("Rebirth")
                task.wait(10)
            end
        end)
    end
})

Tabs.Misc:AddToggle("AutoClaimPass", {
    Title = "Auto Claim Pass",
    Default = false,
    Callback = function(state)
        task.spawn(function()
            while state do
                local args = { { Tier = "All" } }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SeasonPass"):WaitForChild("Claim"):FireServer(unpack(args))
                task.wait(15)
            end
        end)
    end
})

Tabs.Misc:AddButton({
    Title = "Fps Boost",
    Description = "Remove all VFX",
    Callback = function()
    local assets = game:GetService("ReplicatedStorage"):WaitForChild("Assets", 5)
    local vfx = assets and assets:FindFirstChild("Vfx")
    local drops = assets and assets:FindFirstChild("Drops")

    if not vfx or not drops then
        Fluent:Notify({
            Title = "Erro",
            Content = "Pastas 'Assets.Vfx' ou 'Assets.Drops' não encontradas.",
            Duration = 4
        })
        return
    end

    local targets = {
        vfx:FindFirstChild("DeathEffectModel") and vfx.DeathEffectModel:FindFirstChild("DeathEffect"),
        vfx:FindFirstChild("HitEffectModel") and vfx.HitEffectModel:FindFirstChild("HitEffect"),
        vfx:FindFirstChild("SpawnEffectModel") and vfx.SpawnEffectModel:FindFirstChild("SpawnEffect")
    }

    for _, effectPart in ipairs(targets) do
        if effectPart then
            for _, obj in ipairs(effectPart:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Decal") then
                    obj:Destroy()
                end
            end
        end
    end

    local gemPart = drops:FindFirstChild("GemPart")
    if gemPart then
        gemPart:ClearAllChildren()
    end

    local summerGemPart = drops:FindFirstChild("SummerGemPart")
    if summerGemPart then
        summerGemPart:ClearAllChildren()
    end

    Fluent:Notify({
        Title = "All Vfx Removed",
        Content = "Fps Boosted!",
        Duration = 3
    })
end
})

Tabs.Trials:AddToggle("AutoFarmTrials", {
    Title = "Auto Trial",
    Default = false,
    Callback = function(state)
        task.spawn(function()
            while state do
                local folder = workspace:FindFirstChild("TrialRoomNpc") and workspace.TrialRoomNpc:FindFirstChild("Easy")
                if folder then
                    for _, npc in ipairs(folder:GetChildren()) do
                        if not state then break end
                        if npc:FindFirstChild("HumanoidRootPart") then
                            local char = game.Players.LocalPlayer.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                char:MoveTo(npc.HumanoidRootPart.Position + Vector3.new(0, 0, 2))
                            end
                            repeat
                                task.wait(0.2)
                            until not npc:IsDescendantOf(game) or (npc:FindFirstChild("Health") and npc.Health.Value <= 0) or not state
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
})

local autoKimetsuRush = false
Tabs.Trials:AddToggle("AutoKimetsuRush", {
    Title = "Auto KimetsuRush",
    Default = false,
    Callback = function(state)
        autoKimetsuRush = state
        task.spawn(function()
            while autoKimetsuRush do
                game:GetService("ReplicatedStorage").Remotes.BossRush.BossRushStart:FireServer("StartUi", "DemonSlayer")
                task.wait(1.5)
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(-181.595001, 7914.17285, -32.5060158, 0.999391913, 0, 0.0348687991, 0, 1, 0, -0.0348687991, 0, 0.999391913)
                end

                local npc, timeout = nil, 0
                repeat
                    task.wait(1)
                    timeout += 1
                    npc = workspace:FindFirstChild("BossRushNpc") and workspace.BossRushNpc:FindFirstChild("DemonSlayer") and workspace.BossRushNpc.DemonSlayer:FindFirstChild("Muzan")
                until npc and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Health") or timeout >= 45

                if npc and npc:FindFirstChild("Health") then
                    while npc and npc.Health and npc.Health.Value > 0 and autoKimetsuRush do
                        char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("HumanoidRootPart") then
                            char:MoveTo(npc.HumanoidRootPart.Position + Vector3.new(0, -9, 0))
                        end
                        task.wait()
                    end
                end

                task.wait(4.4)
            end
        end)
    end
})

local autoJJKRush = false
Tabs.Trials:AddToggle("AutoJujutsuRush", {
    Title = "Auto JujutsuRush",
    Default = false,
    Callback = function(state)
        autoJJKRush = state
        task.spawn(function()
            while autoJJKRush do
                game:GetService("ReplicatedStorage").Remotes.BossRush.BossRushStart:FireServer("StartUi", "Jjk")
                task.wait(1.5)
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(-181.595001, 7914.17285, -32.5060158, 0.999391913, 0, 0.0348687991, 0, 1, 0, -0.0348687991, 0, 0.999391913)
                end

                local npc, timeout = nil, 0
                repeat
                    task.wait(1)
                    timeout += 1
                    npc = workspace:FindFirstChild("BossRushNpc") and workspace.BossRushNpc:FindFirstChild("Jjk") and workspace.BossRushNpc.DemonSlayer:FindFirstChild("Maharaga")
                until npc and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Health") or timeout >= 45

                if npc and npc:FindFirstChild("Health") then
                    while npc and npc.Health and npc.Health.Value > 0 and autoJJKRush do
                        char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("HumanoidRootPart") then
                            char:MoveTo(npc.HumanoidRootPart.Position + Vector3.new(0, -9, 0))
                        end
                        task.wait()
                    end
                end
                task.wait(4.4)
            end
        end)
    end
})

local autoPieceRush = false
Tabs.Trials:AddToggle("AutoOnePieceRush", {
    Title = "Auto OnePieceRush",
    Default = false,
    Callback = function(state)
        autoPieceRush = state
        task.spawn(function()
            while autoPieceRush do
                game:GetService("ReplicatedStorage").Remotes.BossRush.BossRushStart:FireServer("StartUi", "OnePiece")
                task.wait(1.5)
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(-2591.25806, 6047.97705, -712.478027, 0.241953552, -0, -0.970287859, 0, 1, -0, 0.970287859, 0, 0.241953552)
                end

                local npc, timeout = nil, 0
                repeat
                    task.wait(1)
                    timeout += 1
                    npc = workspace:FindFirstChild("BossRushNpc") and workspace.BossRushNpc:FindFirstChild("OnePiece") and workspace.BossRushNpc.OnePiece:FindFirstChild("Kaido")
                until npc and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Health") or timeout >= 45

                if npc and npc:FindFirstChild("Health") then
                    while npc and npc.Health and npc.Health.Value > 0 and autoPieceRush do
                        char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("HumanoidRootPart") then
                            char:MoveTo(npc.HumanoidRootPart.Position + Vector3.new(0, -9, 0))
                        end
                        task.wait()
                    end
                end
                task.wait(4.4)
            end
        end)
    end
})

local autoSummerTower = false
local lastRoom = ""
Tabs.Summer:AddToggle("AutoSummerTower", {
    Title = "Auto SummerTower",
    Default = false,
    Callback = function(state)
        autoSummerTower = state
        task.spawn(function()
            while autoSummerTower do
                local gui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Visual")
                local roomLabel = gui:WaitForChild("TowerFrame"):WaitForChild("Room")

                local currentRoom = roomLabel.Text
                if currentRoom ~= lastRoom then
                    lastRoom = currentRoom
                    task.wait(1.5)

                    local folder = workspace:FindFirstChild("TowerNpc") and workspace.TowerNpc:FindFirstChild("Summer2025")
                    if folder then
                        for _, npc in ipairs(folder:GetChildren()) do
                            if not autoSummerTower then break end
                            if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Health") then
                                local char = game.Players.LocalPlayer.Character
                                if char and char:FindFirstChild("HumanoidRootPart") then
                                    char:MoveTo(npc.HumanoidRootPart.Position + Vector3.new(0, 0, 2))
                                end
                                repeat
                                    task.wait()
                                until not npc:IsDescendantOf(game) or npc.Health.Value <= 0 or not autoSummerTower
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
})

local autoSummer = false
Tabs.Summer:AddToggle("AutoSummerRush", {
    Title = "Auto SummerRush",
    Default = false,
    Callback = function(state)
        autoSummer = state
        task.spawn(function()
            while autoSummer do
                game:GetService("ReplicatedStorage").Remotes.BossRush.BossRushStart:FireServer("StartUi", "Summer2025")
                task.wait(1.5)
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(-6276.3252, 2811.78809, -3883.45605, -0.997561932, 0, -0.0697919354, 0, 1, 0, 0.0697919354, 0, -0.997561932)
                end

                local npc, timeout = nil, 0
                repeat
                    task.wait(1)
                    timeout += 1
                    npc = workspace:FindFirstChild("BossRushNpc") and workspace.BossRushNpc:FindFirstChild("Summer2025") and workspace.BossRushNpc.Summer2025:FindFirstChild("BrolySummer")
                until npc and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Health") or timeout >= 45

                if npc and npc:FindFirstChild("Health") then
                    while npc and npc.Health and npc.Health.Value > 0 and autoSummer do
                        char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("HumanoidRootPart") then
                            char:MoveTo(npc.HumanoidRootPart.Position + Vector3.new(0, -9, 0))
                        end
                        task.wait()
                    end
                end
                task.wait(4.4)
            end
        end)
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/AnimeStorm")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
Tabs.Main:ForceCanvas()
