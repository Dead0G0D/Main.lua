local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/Beta.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local state = {
    autoClick = false,
    autoFarm = false,
    autoEgg = false,
    autoCollectRewards = false,
    autoRejoin = false,
    autoClaimPass = false,
    autoRankup = false,
    autoRedeemCodes = false,
    selectedWorld = nil,
    selectedEnemies = {},
    selectedEgg = nil,
    selectedTrials = {},
    jtrial = false,
    autoFarmTrial = false,
    teleportOnExitTrial = false,
    svposi = nil,
    autoBossRush = false,
    selectedRush = nil,
    autoInvBleach = false,
    autoInvJjk = false,
    slayerTower = false,
    summerTower = false,
    selectedUpgrades = {},
    autoUpgradeBleach = false,
    autoUpgradeJjk = false,
    antiAfk = false,
}

local function Notify(title, content, duration)
    Fluent:Notify({ Title = title, Content = content, Duration = duration or 4 })
end

local function AutoLoop(flag, func, interval)
    task.spawn(function()
        while flag() do
            func()
            task.wait(interval or 0.5)
        end
    end)
end

local function GetAllNPCsWithName(name)
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

local function GetNpcListWithWorldAttribute(world)
    local names, added = {}, {}
    for _, folder in ipairs(workspace.Npc:GetChildren()) do
        if folder:IsA("Folder") then
            for _, npc in ipairs(folder:GetChildren()) do
                if npc:IsA("Model") and npc:GetAttribute("World") == world and not added[npc.Name] then
                    table.insert(names, npc.Name)
                    added[npc.Name] = true
                end
            end
        end
    end
    local hidden = game:GetService("ReplicatedStorage"):FindFirstChild("HiddenNpcs")
    if hidden then
        for _, npc in ipairs(hidden:GetChildren()) do
            if npc:IsA("Model") and npc:GetAttribute("World") == world and not added[npc.Name] then
                table.insert(names, npc.Name)
                added[npc.Name] = true
            end
        end
    end
    return names
end

local function GetEggList()
    local eggs = {}
    for _, egg in ipairs(workspace:WaitForChild("Eggs"):GetChildren()) do
        table.insert(eggs, egg.Name)
    end
    return eggs
end

local function IsInTrial()
    local g = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Visual")
    local f = g and g:FindFirstChild("TimeTrialFrame")
    return f and f.Visible
end

local function WatchLabel(path, callback)
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
                label:GetPropertyChangedSignal("Text"):Connect(callback)
                callback()
            else
                task.wait(1)
            end
        end
    end)
    return function() return label end
end

local function AutoUpgrade(flag, upgrades, invasionName)
    AutoLoop(flag, function()
        for _, upgradeName in ipairs(upgrades()) do
            game:GetService("ReplicatedStorage").Remotes.Invasion.InvasionUpgrade:FireServer(upgradeName, invasionName)
            task.wait(0.5)
        end
    end)
end

local Window = Fluent:CreateWindow({
    Title = "Anime Storm Simulator",
    SubTitle = "by Latency",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 360),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Farms", Icon = "sword" }),
    Trials = Window:AddTab({ Title = "GameModes", Icon = "landmark" }),
    Player = Window:AddTab({ Title = "Player/Upgrades", Icon = "list" }),
    Traits = Window:AddTab({ Title = "Traits", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

Tabs.Main:AddSection("Toggles", "sword")
Tabs.Main:AddToggle("AutoClickDamage", {
    Title = "Auto Click + Damage",
    Default = false,
    Callback = function(value)
        state.autoClick = value
        if value then
            AutoLoop(function() return state.autoClick end, function()
                game:GetService("ReplicatedStorage").Remotes.Input:FireServer("GainStrength")
            end, 0.1)
        end
    end
})

local atwes = Tabs.Main:AddToggle("AutoFarmEnemies", {
    Title = "Auto World Enemies",
    Default = false,
    Callback = function(value)
        state.autoFarm = value
        if value then
            AutoLoop(function() return state.autoFarm end, function()
                for _, enemyName in ipairs(state.selectedEnemies) do
                    for _, npc in ipairs(GetAllNPCsWithName(enemyName)) do
                        local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                        local char = game.Players.LocalPlayer.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if npcRoot and hrp then
                            hrp.CFrame = CFrame.lookAt(npcRoot.Position + Vector3.new(0, 0, 2), npcRoot.Position)
                            repeat task.wait(0.1)
                            until not npc:IsDescendantOf(game) or (npc:FindFirstChild("Health") and npc.Health.Value <= 0) or not state.autoFarm
                        end
                    end
                end
            end, 0.5)
        end
    end
})

Tabs.Main:AddSection("World", "map")
local worlds = (function()
    local r = {}
    for _, folder in ipairs(workspace.Npc:GetChildren()) do
        if folder:IsA("Folder") then table.insert(r, folder.Name) end
    end
    return r
end)()
state.selectedWorld = worlds[1] or "nothing"

local enemyMultiDropdown
Tabs.Main:AddDropdown("SelectWorld", {
    Title = "Select World",
    Values = worlds,
    Multi = false,
    Default = state.selectedWorld,
    Callback = function(value)
        state.selectedWorld = value
        state.selectedEnemies = {}
        if enemyMultiDropdown then
            enemyMultiDropdown:SetValue({})
            enemyMultiDropdown:SetValues(GetNpcListWithWorldAttribute(state.selectedWorld))
        end
    end
})

enemyMultiDropdown = Tabs.Main:AddDropdown("EnemyMultiDropdown", {
    Title = "Enemies",
    Values = GetNpcListWithWorldAttribute(state.selectedWorld),
    Multi = true,
    Default = {},
    Callback = function(value)
        state.selectedEnemies = {}
        for enemyName, active in pairs(value) do
            if active then table.insert(state.selectedEnemies, enemyName) end
        end
    end
})

Tabs.Main:AddButton({
    Title = "Refresh Enemies",
    Description = "Refresh",
    Callback = function()
        if enemyMultiDropdown then enemyMultiDropdown:SetValues(GetNpcListWithWorldAttribute(state.selectedWorld)) end
    end
})

Tabs.Main:AddSection("Eggs", "egg")
local dropdown
dropdown = Tabs.Main:AddDropdown("SelectEgg", {
    Title = "Select Egg",
    Values = GetEggList(),
    Multi = false,
    Default = nil,
    Callback = function(value)
        state.selectedEgg = value
    end
})

local function updateEggList()
    if dropdown then
        dropdown:SetValues(GetEggList())
    end
end
workspace.Eggs.ChildAdded:Connect(updateEggList)
workspace.Eggs.ChildRemoved:Connect(updateEggList)

Tabs.Main:AddToggle("AutoOpenEggs", {
    Title = "Auto Open Eggs",
    Default = false,
    Callback = function(value)
        state.autoEgg = value
        if value then
            AutoLoop(function() return state.autoEgg end, function()
                game.ReplicatedStorage.Remotes.Egg.EggHatch:InvokeServer("Hatch", state.selectedEgg)
            end, 0.2)
        end
    end
})

local function WatchLabel(path, callback)
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
                label:GetPropertyChangedSignal("Text"):Connect(callback)
                callback()
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
    local success, _ = pcall(function() label = getLabel and getLabel() end)
    return (label and label.Text) or "Waiting for Time"
end

Tabs.Trials:AddSection("Trial", "landmark")
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

easyTrial = WatchLabel(easyTrialPath, updateParagraph)
mediumTrial = WatchLabel(mediumTrialPath, updateParagraph)
demot = WatchLabel(demotPath, updateParagraph)
sumt = WatchLabel(sumtPath, updateParagraph)

local cft = {
    EasyTrial = CFrame.new(7784.22461, -26.3008652, 84.3378296, 0, 0, -1, 0, 1, 0, 1, 0, 0),
    MediumTrial = CFrame.new(7202.21826, -18.2700043, 220.671005, 0.990270376, 0, 0.13915664, 0, 1, 0, -0.13915664, 0, 0.990270376)
}

local trialTypes = {"EasyTrial", "MediumTrial"}
state.selectedTrials = {}

Tabs.Trials:AddDropdown("TrialTypeMultiDropdown", {
    Title = "Select Trials",
    Values = trialTypes,
    Multi = true,
    Default = {},
    Callback = function(value)
        state.selectedTrials = {}
        for trial, active in pairs(value) do
            if active then table.insert(state.selectedTrials, trial) end
        end
    end
})

state.jtrial = false
local function IsInTrial()
    local g = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Visual")
    local f = g and g:FindFirstChild("TimeTrialFrame")
    return f and f.Visible
end

Tabs.Trials:AddToggle("trialtp", {
    Title = "Auto Join Trials",
    Default = false,
    Callback = function(s)
        state.jtrial = s
        task.spawn(function()
            while state.jtrial do
                if not IsInTrial() then
                    for _, selectedTrial in ipairs(state.selectedTrials) do
                        if selectedTrial == "EasyTrial" and safeText(easyTrial) == "Closes in: 1 minute at XX:16!" then
                            local c = game.Players.LocalPlayer.Character
                            if c and c:FindFirstChild("HumanoidRootPart") then
                                atwes:SetValue(false)
                                task.wait(1)
                                c.HumanoidRootPart.CFrame = cft.EasyTrial
                                task.wait(1)
                                break
                            end
                        elseif selectedTrial == "MediumTrial" and safeText(mediumTrial) == "Closes in: 1 minute at XX:31!" then
                            local c = game.Players.LocalPlayer.Character
                            if c and c:FindFirstChild("HumanoidRootPart") then
                                atwes:SetValue(false)
                                task.wait(1)
                                c.HumanoidRootPart.CFrame = cft.MediumTrial
                                task.wait(1)
                                break
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
})

state.autoFarmTrial = false
local last_room = ""
local trialNpcFolders = {
    EasyTrial = "Easy",
    MediumTrial = "Medium",
}
local function getCurrentRoom()
    local g = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Visual")
    local f = g and g:FindFirstChild("TimeTrialFrame")
    local r = f and f:FindFirstChild("Room")
    return r and r.Text or ""
end

local lastTrialState = nil
Tabs.Trials:AddToggle("AutoFarmTrial", {
    Title = "Auto Trial Enemies",
    Default = false,
    Callback = function(s)
        state.autoFarmTrial = s
        task.spawn(function()
            while state.autoFarmTrial do
                local current_room = getCurrentRoom()
                if current_room ~= "" and current_room ~= last_room then
                    last_room = current_room
                    for _, selectedTrial in ipairs(state.selectedTrials) do
                        local folderName = trialNpcFolders[selectedTrial]
                        local f = workspace:FindFirstChild("TrialRoomNpc")
                        local folder = f and f:FindFirstChild(folderName)
                        if folder then
                            for _, npc in ipairs(folder:GetChildren()) do
                                if not state.autoFarmTrial then break end
                                local npcRoot = npc:FindFirstChild("HumanoidRootPart")
                                local char = game.Players.LocalPlayer.Character
                                local humanoidRoot = char and char:FindFirstChild("HumanoidRootPart")
                                if npcRoot and humanoidRoot then
                                    if humanoidRoot:FindFirstChild("AutoFarmAlign") then humanoidRoot.AutoFarmAlign:Destroy() end
                                    if humanoidRoot:FindFirstChild("AutoFarmAttachment") then humanoidRoot.AutoFarmAttachment:Destroy() end
                                    if npcRoot:FindFirstChild("AutoFarmAttachment") then npcRoot.AutoFarmAttachment:Destroy() end
                                    humanoidRoot.CFrame = npcRoot.CFrame
                                    local hrpAttachment = Instance.new("Attachment", humanoidRoot)
                                    hrpAttachment.Name = "AutoFarmAttachment"
                                    hrpAttachment.Position = Vector3.new(0, 0, 2)
                                    local npcAttachment = Instance.new("Attachment", npcRoot)
                                    npcAttachment.Name = "AutoFarmAttachment"
                                    npcAttachment.Position = Vector3.new(0, 0, 0)
                                    local align = Instance.new("AlignPosition")
                                    align.Name = "AutoFarmAlign"
                                    align.Attachment0 = hrpAttachment
                                    align.Attachment1 = npcAttachment
                                    align.Responsiveness = 200
                                    align.MaxForce = 50000
                                    align.Parent = humanoidRoot
                                    repeat task.wait(0.1)
                                    until not state.autoFarmTrial or not npc:IsDescendantOf(game) or not npc:FindFirstChild("Health") or npc.Health.Value <= 0
                                    if humanoidRoot:FindFirstChild("AutoFarmAlign") then humanoidRoot.AutoFarmAlign:Destroy() end
                                    if humanoidRoot:FindFirstChild("AutoFarmAttachment") then humanoidRoot.AutoFarmAttachment:Destroy() end
                                    if npcRoot:FindFirstChild("AutoFarmAttachment") then npcRoot.AutoFarmAttachment:Destroy() end
                                end
                                if not state.autoFarmTrial then break end
                            end
                        end
                        if not state.autoFarmTrial then break end
                    end
                end
                local inTrialNow = IsInTrial()
                if lastTrialState == true and inTrialNow == false then
                    if state.svposi then
                        local char = game.Players.LocalPlayer.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = CFrame.new(state.svposi)
                            task.spawn(function()
                                task.wait(3)
                                if not IsInTrial() then
                                    atwes:SetValue(true)
                                end
                            end)
                        end
                    end
                end
                lastTrialState = inTrialNow
                task.wait(0.25)
            end
            lastTrialState = nil
        end)
    end
})

state.teleportOnExitTrial = false
Tabs.Trials:AddToggle("TeleportToSavedPosition", {
    Title = "Teleport to Saved Position",
    Default = false,
    Callback = function(value)
        state.teleportOnExitTrial = value
        task.spawn(function()
            local lastTrialState = nil
            while state.teleportOnExitTrial do
                if state.autoFarmTrial then
                    local inTrialNow = IsInTrial()
                    if lastTrialState == true and inTrialNow == false then
                        if state.svposi then
                            local char = game.Players.LocalPlayer.Character
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                hrp.CFrame = CFrame.new(state.svposi)
                                task.spawn(function()
                                    task.wait(3)
                                    if not IsInTrial() then
                                        atwes:SetValue(true)
                                    end
                                end)
                            end
                        end
                    end
                    lastTrialState = inTrialNow
                else
                    lastTrialState = nil
                end
                task.wait(0.25)
            end
        end)
    end
})

state.svposi = nil
local positionParagraph = Tabs.Trials:AddParagraph({
    Title = "Saved Position",
    Content = "No position saved yet"
})

Tabs.Trials:AddButton({
    Title = "Save Position",
    Description = "Saves your current position",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            state.svposi = hrp.Position
            positionParagraph:SetDesc(
                string.format("X: %.2f, Y: %.2f, Z: %.2f", state.svposi.X, state.svposi.Y, state.svposi.Z)
            )
        else
            Fluent:Notify({
                Title = "Notification",
                Content = "Player not found?",
                SubContent = "Cannot save position",
                Duration = 5
            })
        end
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
state.selectedRush = bossRushKeys[1]
Tabs.Trials:AddSection("Modes", "flame")
Tabs.Trials:AddDropdown("SelectBossRush", {
    Title = "Select BossRush",
    Values = bossRushKeys,
    Default = bossRushKeys[1],
    Multi = false,
    Callback = function(value)
        state.selectedRush = value or bossRushKeys[1]
    end
})

state.autoBossRush = false
Tabs.Trials:AddToggle("AutoBossRush", {
    Title = "Auto Farm BossRush",
    Default = false,
    Callback = function(value)
        state.autoBossRush = value
        task.spawn(function()
            while state.autoBossRush do
                local data = bossRushData[state.selectedRush]
                if not data then task.wait(1) else
                    game:GetService("ReplicatedStorage").Remotes.BossRush.BossRushStart:FireServer("StartUi", state.selectedRush)
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
                        local worldFolder = folder and folder:FindFirstChild(state.selectedRush)
                        npc = worldFolder and worldFolder:FindFirstChild(data.npcName)
                    until npc and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Health") or timeout >= 45
                    if npc and npc:FindFirstChild("Health") then
                        while npc and npc.Health and npc.Health.Value > 0 and state.autoBossRush do
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
                    game:GetService("ReplicatedStorage").Remotes.Invasion.InvasionStart:FireServer(unpack(a))
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
                while ai_b and t.Text == "⌛ Starts in 30 seconds!" do task.wait(0.5) end
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
                                    repeat task.wait() until not n:IsDescendantOf(game) or n.Health.Value <= 0 or not ai_b
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
local cf_j = Vector3.new(-3252.41895, 3200.5022, 1444.74194, -0.325602531, 0, -0.945506752, 0, 1, 0, 0.945506752, 0, -0.325602531)
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
                    game:GetService("ReplicatedStorage").Remotes.Invasion.InvasionStart:FireServer(unpack(a))
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
                while ai_j and t.Text == "⌛ Starts in 30 seconds!" do task.wait(0.5) end
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
                                    repeat task.wait() until not n:IsDescendantOf(game) or n.Health.Value <= 0 or not ai_j
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

local st, atp = false, false
local lr = ""
local dtPath = {"Portals","Tower","DemonSlayer","TeleportEffect","Timer","Frame","TextLabel"}
local dtCF = CFrame.new(-62.0549965,12797.8887,-256.52298,-0.0522800684,0,0.998632431,0,1,0,-0.998632431,0,-0.0522800684)
local dtTimer = WatchLabel(dtPath, function() end)

local function inTower()
    local g = game.Players.LocalPlayer.PlayerGui:FindFirstChild("Visual")
    local f = g and g:FindFirstChild("TowerFrame")
    return f and f.Visible
end

Tabs.Trials:AddToggle("AutoSlayerTower", {
    Title = "Auto SlayerTower",
    Default = false,
    Callback = function(v)
        st, atp = v, v
        task.spawn(function()
            while st or atp do
                if atp and not inTower() and safeText(dtTimer) == "Closes in: 1 minute at XX:01!" then
                    local c = game.Players.LocalPlayer.Character
                    local hrp = c and c:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = dtCF end
                    task.wait(2)
                end
                if st and inTower() then
                    local g = game.Players.LocalPlayer.PlayerGui.Visual
                    local room = g.TowerFrame.Room.Text
                    if room ~= lr then
                        lr = room
                        local f = workspace.TowerNpc and workspace.TowerNpc.DemonSlayer
                        if f then
                            for _,n in ipairs(f:GetChildren()) do
                                if not st then break end
                                local hrp = n:FindFirstChild("HumanoidRootPart")
                                local hp = n:FindFirstChild("Health")
                                if hrp and hp then
                                    local c = game.Players.LocalPlayer.Character
                                    local myhrp = c and c:FindFirstChild("HumanoidRootPart")
                                    if myhrp then myhrp:MoveTo(hrp.Position + Vector3.new(0,0,2)) end
                                    repeat task.wait() until not n:IsDescendantOf(game) or hp.Value <= 0 or not st
                                end
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
})

local st, tp = false, false
local lr = ""
local cf = CFrame.new(-6319.40234, 5678.91895, -3891.84473, 0.0175017118, 0, -0.999846935, 0, 1, 0, 0.999846935, 0, 0.0175017118)
local path = {"Portals","Tower","Summer2025","TeleportEffect","Timer","Frame","TextLabel"}
local timer = WatchLabel(path, function() end)

local function inTower()
    local g = game.Players.LocalPlayer.PlayerGui:FindFirstChild("Visual")
    local f = g and g:FindFirstChild("TowerFrame")
    return f and f.Visible
end

Tabs.Trials:AddToggle("SummerTower", {
    Title = "Auto SummerTower",
    Default = false,
    Callback = function(v)
        st, tp = v, v
        task.spawn(function()
            while st or tp do
                if tp and not inTower() and safeText(timer) == "Closes in: 1 minute at XX:01!" then
                    local c = game.Players.LocalPlayer.Character
                    local hrp = c and c:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = cf end
                    task.wait(2)
                end
                if st and inTower() then
                    local g = game.Players.LocalPlayer.PlayerGui.Visual
                    local room = g.TowerFrame.Room.Text
                    if room ~= lr then
                        lr = room
                        local f = workspace.TowerNpc and workspace.TowerNpc.Summer2025
                        if f then
                            for _,n in ipairs(f:GetChildren()) do
                                if not st then break end
                                local hrp = n:FindFirstChild("HumanoidRootPart")
                                local hp = n:FindFirstChild("Health")
                                if hrp and hp then
                                    local c = game.Players.LocalPlayer.Character
                                    local myhrp = c and c:FindFirstChild("HumanoidRootPart")
                                    if myhrp then myhrp:MoveTo(hrp.Position + Vector3.new(0,0,2)) end
                                    repeat task.wait() until not n:IsDescendantOf(game) or hp.Value <= 0 or not st
                                end
                            end
                        end
                    end
                end
                task.wait(0.1)
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

Tabs.Player:AddSection("Claims", "star")
Tabs.Player:AddToggle("AutoCollectTimeRewards", {
    Title = "Auto Claim TimeRewards",
    Default = false,
    Callback = function(value)
        state.autoCollectRewards = value
        if value then
            AutoLoop(function() return state.autoCollectRewards end, function()
                for i = 1, totalRewards do
                    local rewardName = "Reward" .. i
                    if not collected[rewardName] and player.CurrentTotalPlaytime.Value >= TimedRewardsConfig[rewardName].TimeRequired then
                        ReplicatedStorage.Remotes.TimedRewards:FireServer(rewardName)
                        task.wait(1)
                    end
                end
            end, 10)
        end
    end
})

Tabs.Player:AddToggle("AutoRejoinAfterRewards", {
    Title = "Rejoin after all Rewards",
    Default = false,
    Callback = function(value)
        state.autoRejoin = value
        if value then
            AutoLoop(function() return state.autoRejoin end, function()
                local lastRewardTime = TimedRewardsConfig["Reward" .. totalRewards].TimeRequired
                if player.CurrentTotalPlaytime.Value >= lastRewardTime + 500 then
                    TeleportService:Teleport(game.PlaceId, player, game.JobId)
                end
            end, 25)
        end
    end
})

ReplicatedStorage.Remotes.TimedRewards.OnClientEvent:Connect(function(rewardName)
    collected[rewardName] = true
end)

Tabs.Player:AddToggle("AutoClaimPass", {
    Title = "Auto Claim Pass",
    Default = false,
    Callback = function(value)
        state.autoClaimPass = value
        if value then
            AutoLoop(function() return state.autoClaimPass end, function()
                local args = { { Tier = "All" } }
                game:GetService("ReplicatedStorage").Remotes.SeasonPass.Claim:FireServer(unpack(args))
            end, 15)
        end
    end
})

Tabs.Player:AddSection("Player", "shield")
Tabs.Player:AddToggle("AutoRankup", {
    Title = "Auto Rankup",
    Default = false,
    Callback = function(value)
        state.autoRankup = value
        if value then
            AutoLoop(function() return state.autoRankup end, function()
                game.ReplicatedStorage.Remotes.Rebirth:FireServer("Rebirth")
            end, 10)
        end
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
    Callback = function(value)
        state.autoRedeemCodes = value
        if value then
            AutoLoop(function() return state.autoRedeemCodes end, function()
                for _, code in ipairs(codes) do
                    if not state.autoRedeemCodes then break end
                    game:GetService("ReplicatedStorage").Remotes.Code:InvokeServer(code)
                    task.wait(1)
                end
            end, 15)
        end
    end
})

Tabs.Player:AddButton({
    Title = "Fps Boost",
    Description = "Remove all VFX",
    Callback = function()
        local assets = game:GetService("ReplicatedStorage"):FindFirstChild("Assets", 5)
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

        local att = game.Players.LocalPlayer.PlayerScripts:FindFirstChild("Controller")
        att = att and att:FindFirstChild("InputController")
        att = att and att:FindFirstChild("HitEffect")
        att = att and att:FindFirstChild("Attachment")
        if att then for _, c in ipairs(att:GetChildren()) do c:Destroy() end end

        local pName = game.Players.LocalPlayer.Name
        local pModel = workspace:FindFirstChild(pName)
        if pModel then
            local rh = pModel:FindFirstChild("RightHand")
            local gs = rh and rh:FindFirstChild("GojoSword")
            local gsj = gs and gs:FindFirstChild("Gojo sword")
            local part = gsj and gsj:FindFirstChild("Part")
            if part then part:Destroy() end
        end

        Fluent:Notify({ Title = "All Vfx Removed", Content = "Fps Boosted!", Duration = 3 })
    end
})

local upgradeOptions = {
    "Strength",
    "Gem",
    "Luck",
    "Drops",
    "DropLuck"
}
state.selectedUpgrades = {}

Tabs.Player:AddSection("Upgrades", "power")
local MultiDropdown = Tabs.Player:AddDropdown("UpgradeMultiDropdown", {
    Title = "Upgrades",
    Description = "Select Upgrades",
    Values = upgradeOptions,
    Multi = true,
    Default = {},
})

MultiDropdown:OnChanged(function(Value)
    state.selectedUpgrades = {}
    for nome, ativo in pairs(Value) do
        if ativo then
            table.insert(state.selectedUpgrades, nome)
        end
    end
end)

Tabs.Player:AddToggle("UpBleach", {
    Title = "Auto Upgrade Bleach",
    Default = false,
    Callback = function(value)
        state.autoUpgradeBleach = value
        if value then
            AutoUpgrade(function() return state.autoUpgradeBleach end, function() return state.selectedUpgrades end, "Bleach")
        end
    end
})

Tabs.Player:AddToggle("UpJjk", {
    Title = "Auto Upgrade Jjk",
    Default = false,
    Callback = function(value)
        state.autoUpgradeJjk = value
        if value then
            AutoUpgrade(function() return state.autoUpgradeJjk end, function() return state.selectedUpgrades end, "Jjk")
        end
    end
})

Tabs.Settings:AddSection("Game", "settings")
local vu = game:GetService("VirtualUser")
Tabs.Settings:AddToggle("AntiAfk", {
    Title = "Anti AFK",
    Default = false,
    Callback = function(Value)
        state.antiAfk = Value
        if Value then
            Notify("Anti AFK", " - On", 4)
            AutoLoop(function() return state.antiAfk end, function()
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end, 450)
        else
            Notify("AntiAFK", " - Off", 4)
        end
    end
})

local traitState = {}

local function getCurrentTraitName()
    local traitFrame = game:GetService("Players").LocalPlayer.PlayerGui.Frames.TraitReroll.ContentFrame.CurrentTraitFrame
    local traitNameLabel = traitFrame and traitFrame:FindFirstChild("TraitName")
    return (traitNameLabel and traitNameLabel.Text) or "Nenhuma trait"
end

local currentTraitParagraph = Tabs.Traits:AddParagraph({
    Title = "Pet Trait",
    Content = getCurrentTraitName()
})

local traitFrame = game:GetService("Players").LocalPlayer.PlayerGui.Frames.TraitReroll.ContentFrame.CurrentTraitFrame
if traitFrame and traitFrame:FindFirstChild("TraitName") then
    traitFrame.TraitName:GetPropertyChangedSignal("Text"):Connect(function()
        currentTraitParagraph:SetDesc(getCurrentTraitName())
    end)
end

local petIds, petNames = {}, {}
local petsFolder = game:GetService("Players").LocalPlayer.PlayerGui.Frames.Champions.ContentFrame.Scroll.ScrollingFrame

local nameCount = {}

for _,v in ipairs(petsFolder:GetChildren()) do
    local pf = v:FindFirstChild("PetFrame")
    local pn = pf and pf:FindFirstChild("PetName")
    if pn and pn.Text ~= "" then
        local baseName = pn.Text
        nameCount[baseName] = (nameCount[baseName] or 0) + 1
        local displayName = baseName
        if nameCount[baseName] > 1 then
            displayName = baseName .. " " .. tostring(nameCount[baseName])
        end
        table.insert(petIds, v.Name)
        table.insert(petNames, displayName)
    end
end

local selectedPetId = petIds[1]

Tabs.Traits:AddDropdown("PetSelect", {
    Title = "Select Pet",
    Values = petNames,
    Default = petNames[1] or "",
    Callback = function(selected)
        for i, name in ipairs(petNames) do
            if name == selected then
                selectedPetId = petIds[i]
                break
            end
        end
    end
})

local traitNames = {}
local indexFrame = game:GetService("Players").LocalPlayer.PlayerGui.Frames.TraitReroll.IndexFrame
for _, img in ipairs(indexFrame:GetChildren()) do
    if img:IsA("ImageLabel") then
        local holder = img:FindFirstChild("Holder")
        if holder then
            local traitNameLabel = holder:FindFirstChild("TraitName")
            if traitNameLabel and traitNameLabel.Text ~= "" then
                table.insert(traitNames, traitNameLabel.Text)
            end
        end
    end
end

traitState.selectedTraits = {}

local TraitMultiDropdown = Tabs.Traits:AddDropdown("TraitMultiSelect", {
    Title = "Select Traits",
    Description = "Select Traits in order priority",
    Values = traitNames,
    Multi = true,
    Default = {},
})

TraitMultiDropdown:OnChanged(function(Value)
    traitState.selectedTraits = {}
    for _, trait in ipairs(traitNames) do
        if Value[trait] then
            table.insert(traitState.selectedTraits, trait)
        end
    end
    if #traitState.selectedTraits > 0 then
        Notify("Traits Selecionadas", "Ordem: " .. table.concat(traitState.selectedTraits, ", "), 4)
    end
end)

local autoRerollActive = false

local rtrais = Tabs.Traits:AddToggle("AutoRerollTraits", {
    Title = "Auto Reroll Traits",
    Default = false,
    Callback = function(isEnabled)
        autoRerollActive = isEnabled
        task.spawn(function()
            while autoRerollActive do
                if selectedPetId and #traitState.selectedTraits > 0 then
                    local traitAtual = getCurrentTraitName()
                    for i, traitDesejada in ipairs(traitState.selectedTraits) do
                        if traitAtual == traitDesejada then
                            autoRerollActive = false
                            rtrais:SetValue(false)
                            Notify("Trait Obtida", "Você conseguiu: " .. traitDesejada .. " ("..i.."º na ordem)", 5)
                            break
                        end
                    end
                    if not autoRerollActive then break end
                    local args = {"UniversalReroll", selectedPetId}
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Traits"):WaitForChild("Trait"):FireServer(unpack(args))
                end
                task.wait(0.1)
            end
        end)
    end
})

if traitFrame and traitFrame:FindFirstChild("TraitName") then
    traitFrame.TraitName:GetPropertyChangedSignal("Text"):Connect(function()
        currentTraitParagraph:SetDesc(getCurrentTraitName())
        if autoRerollActive and #traitState.selectedTraits > 0 then
            local traitAtual = getCurrentTraitName()
            for i, traitDesejada in ipairs(traitState.selectedTraits) do
                if traitAtual == traitDesejada then
                    autoRerollActive = false
                    rtrais:SetValue(false)
                    Notify("Trait Obtida", "Você conseguiu: " .. traitDesejada .. " ("..i.."º na ordem)", 5)
                    break
                end
            end
        end
    end)
end

--------------------------
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
