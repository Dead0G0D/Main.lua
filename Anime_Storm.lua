local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/Beta.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Anime Storm Simulator",
    SubTitle = "In Latency",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Farms", Icon = "sword" }),
    Player = Window:AddTab({ Title = "Player", Icon = "list" }),
    Trials = Window:AddTab({ Title = "GameModes", Icon = "landmark" }),
    Up = Window:AddTab({ Title = "Upgrades", Icon = "power" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

Tabs.Main:AddSection("Toggles", "axe")
local autoClick = false
Tabs.Main:AddToggle("AutoClickDamage", {
    Title = "Auto Click + Damage",
    Default = false,
    Callback = function(state)
        autoClick = state
        if state then
            task.spawn(function()
                while autoClick do
                    game:GetService("ReplicatedStorage").Remotes.Input:FireServer("GainStrength")
                    task.wait()
                end
            end)
        end
    end
})

local selectedEnemies = {}
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
    Title = "Auto World Enemies",
    Default = false,
    Callback = function(state)
        autoFarm = state
        task.spawn(function()
            while autoFarm do
                for _, enemyName in ipairs(selectedEnemies) do
                    for _, npc in ipairs(getAllNPCsWithName(enemyName)) do
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
                task.wait(0.5)
            end
        end)
    end
})

Tabs.Main:AddSection("Worlds")
local function getWorlds()
    local result = {}
    for _, folder in ipairs(workspace.Npc:GetChildren()) do
        if folder:IsA("Folder") then
            table.insert(result, folder.Name)
        end
    end
    return result
end

local worlds = getWorlds()
local selectedWorld = worlds[1] or "nothing"

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

local enemyMultiDropdown
Tabs.Main:AddDropdown("SelectWorld", {
    Title = "Select World",
    Values = worlds,
    Multi = false,
    Default = selectedWorld,
    Callback = function(value)
        selectedWorld = value
        if enemyMultiDropdown then
            enemyMultiDropdown:SetValues(getNpcListFromWorld())
        end
    end
})

enemyMultiDropdown = Tabs.Main:AddDropdown("EnemyMultiDropdown", {
    Title = "Enemies",
    Values = getNpcListFromWorld(),
    Multi = true,
    Default = {},
    Callback = function(value)
        selectedEnemies = {}
        for enemyName, active in pairs(value) do
            if active then
                table.insert(selectedEnemies, enemyName)
            end
        end
    end
})

Tabs.Main:AddButton({
    Title = "Refresh Enemies",
    Description = "Refresh",
    Callback = function()
        if enemyMultiDropdown then
            enemyMultiDropdown:SetValues(getNpcListFromWorld())
        end
    end
})

Tabs.Main:AddSection("Eggs", "egg")
local selectedEgg = "?"
local dropdown
local function updateEggList()
    local eggList = {}
    for _, egg in ipairs(workspace:WaitForChild("Eggs"):GetChildren()) do
        table.insert(eggList, egg.Name)
    end
    if dropdown then
        dropdown:SetValues(eggList)
    end
end

dropdown = Tabs.Main:AddDropdown("SelectEgg", {
    Title = "Select Egg",
    Values = {},
    Multi = false,
    Default = nil,
    Callback = function(value)
        selectedEgg = value
    end
})

updateEggList()
workspace.Eggs.ChildAdded:Connect(updateEggList)
workspace.Eggs.ChildRemoved:Connect(updateEggList)

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

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local TimedRewardsConfig = require(ReplicatedStorage.Configs.TimedRewardsConfig)
local player = Players.LocalPlayer
local totalRewards = 8
local collected = {}

Tabs.Player:AddToggle("AutoCollectTimeRewards", {
    Title = "Auto Collect TimeRewards",
    Default = false,
    Callback = function(state)
        _G.AutoCollectRewards = state
        if not state then _G.AutoCollectRewards = false end
        if state then
            task.spawn(function()
                while _G.AutoCollectRewards do
                    for i = 1, totalRewards do
                        local rewardName = "Reward" .. i
                        if not collected[rewardName] and player.CurrentTotalPlaytime.Value >= TimedRewardsConfig[rewardName].TimeRequired then
                            ReplicatedStorage.Remotes.TimedRewards:FireServer(rewardName)
                            task.wait(1)
                        end
                    end
                    task.wait(10)
                end
            end)
        end
    end
})

Tabs.Player:AddToggle("AutoRejoinAfterRewards", {
    Title = "Auto Rejoin",
    Default = false,
    Callback = function(state)
        _G.AutoRejoin = state
        if not state then _G.AutoRejoin = false end
        if state then
            task.spawn(function()
                while _G.AutoRejoin do
                    local lastRewardTime = TimedRewardsConfig["Reward" .. totalRewards].TimeRequired
                    if player.CurrentTotalPlaytime.Value >= lastRewardTime + 500 then
                        TeleportService:Teleport(game.PlaceId, player, game.JobId)
                        break
                    end
                    task.wait(25)
                end
            end)
        end
    end
})

ReplicatedStorage.Remotes.TimedRewards.OnClientEvent:Connect(function(rewardName)
    collected[rewardName] = true
end)

Tabs.Player:AddToggle("AutoRankup", {
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

Tabs.Player:AddToggle("AutoClaimPass", {
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

local codes = {
    "Update5",
    "AnimeStormSimulator",
    "500KVisits",
    "WowHunter",
    "SorryForSeasonPassBug"
}

Tabs.Player:AddToggle("AutoRedeemCodes", {
    Title = "Auto Redeem Codes",
    Default = false,
    Callback = function(state)
        _G.AutoRedeemCodes = state
        if not state then _G.AutoRedeemCodes = false end
        if state then
            task.spawn(function()
                for _, code in ipairs(codes) do
                    if not _G.AutoRedeemCodes then break end
                    local args = {code}
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Code"):InvokeServer(unpack(args))
                    task.wait(1)
                end
            end)
        end
    end
})

local function watchLabel(path, onUpdate)
    local label = nil
    task.spawn(function()
        while not label do
            local parent = workspace
            for _, v in ipairs(path) do
                parent = parent:FindFirstChild(v)
                if not parent then break end
            end
            if parent and parent:IsA("TextLabel") then
                label = parent
                label:GetPropertyChangedSignal("Text"):Connect(onUpdate)
                onUpdate()
            else
                task.wait(1)
            end
        end
    end)
    return function() return label end
end

local easyTrialPath = {"Maps","TimeTrialLobby","Doors","EasyTrialDoor","UiPart","Timer","TextLabel"}
local mediumTrialPath = {"Maps","TimeTrialLobby","Doors","MediumTrialDoor","UiPart","Timer","TextLabel"}
local demotPath = {"Portals","Tower","DemonSlayer","TeleportEffect","Timer","Frame","TextLabel"}
local sumtPath = {"Portals","Tower","Summer2025","TeleportEffect","Timer","Frame","TextLabel"}

local easyTrial, mediumTrial, demot, sumt

local function safeText(getLabel)
    local label = nil
    local success, err = pcall(function()
        label = getLabel and getLabel()
    end)
    return (label and label.Text) or "Waiting for Time"
end

local trialParagraph = Tabs.Trials:AddParagraph({
    Title = "⏳ Timers",
    Content = "Easy Trial: Waiting for Time\nMedium Trial: Waiting for Time\nDemon Tower: Waiting for Time\nSummer Tower: Waiting for Time"
})

local function updateParagraph()
    trialParagraph:SetDesc(
        "Easy Trial: " .. safeText(easyTrial) ..
        "\nMedium Trial: " .. safeText(mediumTrial) ..
        "\nDemon Tower: " .. safeText(demot) ..
        "\nSummer Tower: " .. safeText(sumt)
    )
end

easyTrial = watchLabel(easyTrialPath, updateParagraph)
mediumTrial = watchLabel(mediumTrialPath, updateParagraph)
demot = watchLabel(demotPath, updateParagraph)
sumt = watchLabel(sumtPath, updateParagraph)

local trialTypes = {"Easy", "Medium"}
local selectedTrials = {}

Tabs.Trials:AddDropdown("TrialTypeMultiDropdown", {
    Title = "Trials para Entrar",
    Values = trialTypes,
    Multi = true,
    Default = {},
    Callback = function(value)
        selectedTrials = {}
        for trial, active in pairs(value) do
            if active then
                table.insert(selectedTrials, trial)
            end
        end
    end
})

local auto_trial = false
Tabs.Trials:AddToggle("AutoTrialTeleport", {
    Title = "Auto Entrar Trials",
    Default = false,
    Callback = function(s)
        auto_trial = s
        task.spawn(function()
            while auto_trial do
                for _, selectedTrial in ipairs(selectedTrials) do
                    local p = workspace:FindFirstChild("Portals")
                    local ttl = p and p:FindFirstChild("TimeTrialLobby")
                    local trial = ttl and ttl:FindFirstChild(selectedTrial .. "Trial")
                    local timer = trial and trial:FindFirstChild("Timer")
                    local label = timer and timer:FindFirstChild("TextLabel")
                    local expectedText = selectedTrial == "Easy"
                        and "Closes in: 1 minute at XX:16!"
                        or "Closes in: 1 minute at XX:31!"
                    if label and label:IsA("TextLabel") and label.Text == expectedText then
                        local tp = trial:FindFirstChild("Teleporter")
                        if tp and tp:IsA("Model") and tp:FindFirstChild("PrimaryPart") then
                            local c = game.Players.LocalPlayer.Character
                            if c and c:FindFirstChild("HumanoidRootPart") then
                                c:MoveTo(tp.PrimaryPart.Position)
                                task.wait(0.3)
                                local prox = trial:FindFirstChild("TeleporterProximity")
                                if prox and prox:IsA("Part") then
                                    local prompt = prox:FindFirstChildOfClass("ProximityPrompt")
                                    if prompt and fireproximityprompt then
                                        fireproximityprompt(prompt)
                                        task.wait(1)
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
})

local auto_farm_trial = false
Tabs.Trials:AddToggle("AutoFarmTrial", {
    Title = "Auto Farm Trial Npcs",
    Default = false,
    Callback = function(s)
        auto_farm_trial = s
        task.spawn(function()
            while auto_farm_trial do
                for _, selectedTrial in ipairs(selectedTrials) do
                    local f = workspace:FindFirstChild("TrialRoomNpc")
                    local folder = f and f:FindFirstChild(selectedTrial)
                    if folder then
                        for _, npc in ipairs(folder:GetChildren()) do
                            if not auto_farm_trial then break end
                            if npc:FindFirstChild("HumanoidRootPart") then
                                local char = game.Players.LocalPlayer.Character
                                if char and char:FindFirstChild("HumanoidRootPart") then
                                    char:MoveTo(npc.HumanoidRootPart.Position + Vector3.new(0, 0, 2))
                                end
                                repeat
                                    task.wait(0.2)
                                until not npc:IsDescendantOf(game) or (npc:FindFirstChild("Health") and npc.Health.Value <= 0) or not auto_farm_trial
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
})

local bossRushData = {
    OnePiece = {
        npcName = "Kaido",
        cframe = CFrame.new(-2591.25806, 6047.97705, -712.478027, 0.241953552, -0, -0.970287859, 0, 1, -0, 0.970287859, 0, 0.241953552)
    },
    Hxh = {
        npcName = "Meruem",
        cframe = CFrame.new(-2980.14795, 399.122009, -3153.46802, -0.788017035, 0, 0.615653694, 0, 1, 0, -0.615653694, 0, -0.788017035)
    },
    Jjk = {
        npcName = "Maharaga",
        cframe = CFrame.new(-3240.84424, 6738.77246, 1901.71997, 0.207885921, -0, -0.97815311, 0, 1, -0, 0.97815311, 0, 0.207885921)
    },
    DemonSlayer = {
        npcName = "Muzan",
        cframe = CFrame.new(-181.595001, 7914.17285, -32.5060158, 0.999391913, 0, 0.0348687991, 0, 1, 0, -0.0348687991, 0, 0.999391913)
    },
    Summer2025 = {
        npcName = "BrolySummer",
        cframe = CFrame.new(-6276.3252, 2811.78809, -3883.45605, -0.997561932, 0, -0.0697919354, 0, 1, 0, 0.0697919354, 0, -0.997561932)
    }
}
local bossRushKeys = {}
for k, _ in pairs(bossRushData) do
    table.insert(bossRushKeys, k)
end
local selectedRush = bossRushKeys[1]
Tabs.Trials:AddDropdown("SelectBossRush", {
    Title = "Select BossRush",
    Values = bossRushKeys,
    Default = bossRushKeys[1],
    Multi = false,
    Callback = function(value)
        selectedRush = value or bossRushKeys[1]
    end
})

local autoBossRush = false
Tabs.Trials:AddToggle("AutoBossRush", {
    Title = "Auto Farm BossRush",
    Default = false,
    Callback = function(state)
        autoBossRush = state
        task.spawn(function()
            while autoBossRush do
                local data = bossRushData[selectedRush]
                if not data then task.wait(1) else
                    game:GetService("ReplicatedStorage").Remotes.BossRush.BossRushStart:FireServer("StartUi", selectedRush)
                    task.wait(1.7)
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = data.cframe
                    end
                    local npc, timeout = nil, 0
                    repeat
                        task.wait(1)
                        timeout += 1
                        local folder = workspace:FindFirstChild("BossRushNpc")
                        local worldFolder = folder and folder:FindFirstChild(selectedRush)
                        npc = worldFolder and worldFolder:FindFirstChild(data.npcName)
                    until npc and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Health") or timeout >= 45
                    if npc and npc:FindFirstChild("Health") then
                        while npc and npc.Health and npc.Health.Value > 0 and autoBossRush do
                            char = game.Players.LocalPlayer.Character
                            if char and char:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("HumanoidRootPart") then
                                char:MoveTo(npc.HumanoidRootPart.Position + Vector3.new(0, -9, 0))
                            end
                            task.wait()
                        end
                    end
                    task.wait(4.4)
                end
            end
        end)
    end
})

local ai_b = false
local uw_b = "Wave: 10/10"
local cf_b = Vector3.new(6392.59277, 3088.83203, -6815.19287)
local lw_b = ""
Tabs.Trials:AddToggle("AutoInvB", {
    Title = "Auto Invasion Bleach",
    Default = false,
    Callback = function(s)
        ai_b = s
        task.spawn(function()
            while ai_b do
                local g = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Visual")
                local f = g:FindFirstChild("InvasionFrame")
                local inInv = f and f.Visible
                if not inInv then
                    local a = {"StartUi", "Bleach"}
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Invasion"):WaitForChild("InvasionStart"):FireServer(unpack(a))
                    task.wait(2.5)
                    local c = game.Players.LocalPlayer.Character
                    if c and c:FindFirstChild("HumanoidRootPart") then
                        c:MoveTo(cf_b)
                    end
                end
                g = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Visual")
                f = g:WaitForChild("InvasionFrame")
                local w = f:WaitForChild("Wave")
                local t = f:WaitForChild("Timer")
                while ai_b and t.Text == "⌛ Starts in 30 seconds!" do
                    task.wait(0.5)
                end
                lw_b = ""
                while ai_b do
                    local wa = w.Text
                    if wa ~= lw_b then
                        lw_b = wa
                        task.wait(0.1)
                        local fd = workspace:FindFirstChild("InvasionNpc") and workspace.InvasionNpc:FindFirstChild("Bleach")
                        if fd then
                            for _, n in ipairs(fd:GetChildren()) do
                                if not ai_b then break end
                                if n:IsA("Model") and n:FindFirstChild("HumanoidRootPart") and n:FindFirstChild("Health") then
                                    local c = game.Players.LocalPlayer.Character
                                    if c and c:FindFirstChild("HumanoidRootPart") then
                                        c:MoveTo(n.HumanoidRootPart.Position + Vector3.new(0, 0, 2))
                                    end
                                    repeat
                                        task.wait()
                                    until not n:IsDescendantOf(game) or n.Health.Value <= 0 or not ai_b
                                end
                            end
                        end
                    end
                    if wa == uw_b then
                        task.wait(4.4)
                        break
                    end
                    task.wait(0.1)
                end
            end
        end)
    end
})

local ai_j = false
local uw_j = "Wave: 10/10"
local cf_j = Vector3.new(6392.59277, 3088.83203, -6815.19287)
local lw_j = ""
Tabs.Trials:AddToggle("AutoInvJjk", {
    Title = "Auto Invasion Jjk",
    Default = false,
    Callback = function(s)
        ai_j = s
        task.spawn(function()
            while ai_j do
                local g = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Visual")
                local f = g:FindFirstChild("InvasionFrame")
                local inInv = f and f.Visible
                if not inInv then
                    local a = {"StartUi", "Jjk"}
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Invasion"):WaitForChild("InvasionStart"):FireServer(unpack(a))
                    task.wait(2.5)
                    local c = game.Players.LocalPlayer.Character
                    if c and c:FindFirstChild("HumanoidRootPart") then
                        c:MoveTo(cf_j)
                    end
                end
                g = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Visual")
                f = g:WaitForChild("InvasionFrame")
                local w = f:WaitForChild("Wave")
                local t = f:WaitForChild("Timer")
                while ai_j and t.Text == "⌛ Starts in 30 seconds!" do
                    task.wait(0.5)
                end
                lw_j = ""
                while ai_j do
                    local wa = w.Text
                    if wa ~= lw_j then
                        lw_j = wa
                        task.wait(0.1)
                        local fd = workspace:FindFirstChild("InvasionNpc") and workspace.InvasionNpc:FindFirstChild("Jjk")
                        if fd then
                            for _, n in ipairs(fd:GetChildren()) do
                                if not ai_j then break end
                                if n:IsA("Model") and n:FindFirstChild("HumanoidRootPart") and n:FindFirstChild("Health") then
                                    local c = game.Players.LocalPlayer.Character
                                    if c and c:FindFirstChild("HumanoidRootPart") then
                                        c:MoveTo(n.HumanoidRootPart.Position + Vector3.new(0, 0, 2))
                                    end
                                    repeat
                                        task.wait()
                                    until not n:IsDescendantOf(game) or n.Health.Value <= 0 or not ai_j
                                end
                            end
                        end
                    end
                    if wa == uw_j then
                        task.wait(4.4)
                        break
                    end
                    task.wait(0.1)
                end
            end
        end)
    end
})

local slayerT = false
local lastRoom = ""
Tabs.Trials:AddToggle("SlayerTower", {
    Title = "Auto SlayerTower",
    Default = false,
    Callback = function(state)
        slayerT = state
        task.spawn(function()
            while slayerT do
                local gui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Visual")
                local roomLabel = gui:WaitForChild("TowerFrame"):WaitForChild("Room")
                local currentRoom = roomLabel.Text
                if currentRoom ~= lastRoom then
                    lastRoom = currentRoom
                    task.wait(0.1)
                    local folder = workspace:FindFirstChild("TowerNpc") and workspace.TowerNpc:FindFirstChild("DemonSlayer")
                    if folder then
                        for _, npc in ipairs(folder:GetChildren()) do
                            if not slayerT then break end
                            if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Health") then
                                local char = game.Players.LocalPlayer.Character
                                if char and char:FindFirstChild("HumanoidRootPart") then
                                    char:MoveTo(npc.HumanoidRootPart.Position + Vector3.new(0, 0, 2))
                                end
                                repeat
                                    task.wait()
                                until not npc:IsDescendantOf(game) or npc.Health.Value <= 0 or not slayerT
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
})

local summerT = false
local lastRoomSummer = ""
Tabs.Trials:AddToggle("SummerTower", {
    Title = "Auto SummerTower",
    Default = false,
    Callback = function(state)
        summerT = state
        task.spawn(function()
            while summerT do
                local gui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Visual")
                local roomLabel = gui:WaitForChild("TowerFrame"):WaitForChild("Room")
                local currentRoom = roomLabel.Text
                if currentRoom ~= lastRoomSummer then
                    lastRoomSummer = currentRoom
                    task.wait(0.1)
                    local folder = workspace:FindFirstChild("TowerNpc") and workspace.TowerNpc:FindFirstChild("Summer2025")
                    if folder then
                        for _, npc in ipairs(folder:GetChildren()) do
                            if not summerT then break end
                            if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Health") then
                                local char = game.Players.LocalPlayer.Character
                                if char and char:FindFirstChild("HumanoidRootPart") then
                                    char:MoveTo(npc.HumanoidRootPart.Position + Vector3.new(0, 0, 2))
                                end
                                repeat
                                    task.wait()
                                until not npc:IsDescendantOf(game) or npc.Health.Value <= 0 or not summerT
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
})

local upgradeOptions = {
    "Strength",
    "Gem",
    "Luck",
    "Drops",
    "DropLuck"
}
getgenv().SelectedUpgrades = {}

local MultiDropdown = Tabs.Up:AddDropdown("UpgradeMultiDropdown", {
    Title = "Upgrades",
    Description = "Select Upgrades",
    Values = upgradeOptions,
    Multi = true,
    Default = {},
})

MultiDropdown:OnChanged(function(Value)
    getgenv().SelectedUpgrades = {}
    for nome, ativo in pairs(Value) do
        if ativo then
            table.insert(getgenv().SelectedUpgrades, nome)
        end
    end
end)

local autoUpgradeBleach = false
Tabs.Up:AddToggle("UpBleach", {
    Title = "Auto Upgrade Bleach",
    Default = false,
    Callback = function(state)
        autoUpgradeBleach = state
        if not state then getgenv().SelectedUpgrades = {} end
        task.spawn(function()
            while autoUpgradeBleach do
                for _, upgradeName in ipairs(getgenv().SelectedUpgrades) do
                    local args = {upgradeName, "Bleach"}
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Invasion"):WaitForChild("InvasionUpgrade"):FireServer(unpack(args))
                    task.wait(0.5)
                end
                task.wait()
            end
        end)
    end
})

local autoUpgradeJjk = false
Tabs.Up:AddToggle("UpJjk", {
    Title = "Auto Upgrade Jjk",
    Default = false,
    Callback = function(state)
        autoUpgradeJjk = state
        if not state then getgenv().SelectedUpgrades = {} end
        task.spawn(function()
            while autoUpgradeJjk do
                for _, upgradeName in ipairs(getgenv().SelectedUpgrades) do
                    local args = {upgradeName, "Jjk"}
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Invasion"):WaitForChild("InvasionUpgrade"):FireServer(unpack(args))
                    task.wait(0.5)
                end
                task.wait()
            end
        end)
    end
})

Tabs.Settings:AddSection("Game", "settings")
local vu = game:GetService("VirtualUser")
local player = game.Players.LocalPlayer
local afk = false
Tabs.Settings:AddToggle("AntiAfk", {
    Title = "Anti AFK",
    Default = false,
    Callback = function(Value)
        afk = Value
        if Value then
            Fluent:Notify({
                Title = "Anti AFK",
                Content = " - On",
                Duration = 4
            })
            task.spawn(function()
                while afk do
                    wait(450)
                    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    wait(1)
                    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end
            end)
        else
            Fluent:Notify({
                Title = "AntiAFK",
                Content = " - Off",
                Duration = 4
            })
        end
    end
})

Tabs.Player:AddButton({
    Title = "Fps Boost",
    Description = "Remove all VFX",
    Callback = function()
        local assets = game:GetService("ReplicatedStorage"):WaitForChild("Assets", 5)
        local vfx, drops = assets and assets.Vfx, assets and assets.Drops
        for _, model in ipairs{vfx and vfx.DeathEffectModel, vfx and vfx.HitEffectModel, vfx and vfx.SpawnEffectModel} do
            local part = model and model:FindFirstChild(model.Name:gsub("Model", ""))
            if part then
                for _, obj in ipairs(part:GetDescendants()) do
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Decal") then obj:Destroy() end
                end
            end
        end
        if drops then
            for _, item in ipairs(drops:GetChildren()) do
                if item:IsA("Folder") then
                    for _, part in ipairs(item:GetDescendants()) do
                        if part:IsA("BasePart") then for _, c in ipairs(part:GetChildren()) do c:Destroy() end end
                    end
                elseif item:IsA("BasePart") then
                    for _, c in ipairs(item:GetChildren()) do c:Destroy() end
                end
            end
        end
        local gui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
        local dropsGui = gui and gui:FindFirstChild("Warning") and gui.Warning:FindFirstChild("ItemDrops")
        if dropsGui then for _, c in ipairs(dropsGui:GetChildren()) do c:Destroy() end end
        Fluent:Notify({ Title = "All Vfx Removed", Content = "Fps Boosted!", Duration = 3 })
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
