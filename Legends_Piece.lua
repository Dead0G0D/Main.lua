local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/Beta.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Legends Piece",
    SubTitle = "by Latency",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    F = Window:AddTab({ Title = "Farm", Icon = "sword" }),
    B = Window:AddTab({ Title = "Bosses", Icon = "flame" }),
    L = Window:AddTab({ Title = "Island", Icon = "mountain" }),
    P = Window:AddTab({ Title = "Player", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local Options = Fluent.Options

local autoHit = false
Tabs.F:AddSection("Toggles", "sword")
Tabs.F:AddToggle("AutoHit", {
    Title = "Auto Hit",
    Default = false,
    Callback = function(on)
        autoHit = on
        if on then
            task.spawn(function()
                while autoHit do
                    game:GetService("ReplicatedStorage").Remotes.Combat:FireServer("Swing", "Execute", {Aerial = false})
                    task.wait(0.15)
                end
            end)
        end
    end
})

local state = state or {}
local rs = game:GetService("RunService")
local player = game.Players.LocalPlayer

local function GetIslandList()
    local t = {}
    for _, v in ipairs(workspace.World.Entities:GetChildren()) do
        if v:IsA("Folder") then
            table.insert(t, v.Name)
        end
    end
    return t
end

local function GetEnemyListForIsland(island)
    if not island then return {} end
    local namesSet = {}
    local list = {}
    local folder = workspace.World.Entities:FindFirstChild(island)
    if not folder then return list end
    for _, mob in ipairs(folder:GetChildren()) do
        local baseName = mob.Name:match("^(.-)%d*$") or mob.Name
        if not namesSet[baseName] then
            namesSet[baseName] = true
            table.insert(list, baseName)
        end
    end
    return list
end

Tabs.F:AddSection("Farm", "mouse")
local enemyMultiDropdown
Tabs.F:AddDropdown("SelectIsland", {
    Title = "Select Island",
    Values = GetIslandList(),
    Multi = false,
    Default = state.selectedIsland,
    Callback = function(v)
        state.selectedIsland = v
        state.selectedEnemies = {}
        if enemyMultiDropdown then
            enemyMultiDropdown:SetValue({})
            enemyMultiDropdown:SetValues(GetEnemyListForIsland(v))
        end
    end
})

enemyMultiDropdown = Tabs.F:AddDropdown("EnemyMultiDropdown", {
    Title = "Enemies",
    Values = state.selectedIsland and GetEnemyListForIsland(state.selectedIsland) or {},
    Multi = true,
    Default = {},
    Callback = function(val)
        state.selectedEnemies = {}
        for name, ok in pairs(val) do
            if ok then
                table.insert(state.selectedEnemies, name)
            end
        end
    end
})

Tabs.F:AddButton({
    Title = "Refresh Enemies",
    Description = "Refresh the enemy list",
    Callback = function()
        if enemyMultiDropdown and state.selectedIsland then
            enemyMultiDropdown:SetValues(GetEnemyListForIsland(state.selectedIsland))
        end
    end
})

local bossMode = false
local bossTeleportStep = 1
local lastTeleport = 0
Tabs.F:AddToggle("BossMode", {
    Title = "Boss Mode",
    Default = false,
    Callback = function(on)
        bossMode = on
        bossTeleportStep = 1
        lastTeleport = 0
    end
})

local currentTarget = nil
local connection
local autoEnemiesActive = false

local function findClosestValidEnemy()
    local folder = workspace.World.Entities:FindFirstChild(state.selectedIsland)
    if not folder then return nil end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closestEnemy = nil
    local shortestDist = math.huge
    for _, mob in ipairs(folder:GetChildren()) do
        local baseName = mob.Name:match("^(.-)%d*$") or mob.Name
        if table.find(state.selectedEnemies, baseName) and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
            if mob.Humanoid.Health > 0 then
                local dist = (mob.HumanoidRootPart.Position - root.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closestEnemy = mob
                end
            end
        end
    end
    return closestEnemy
end

Tabs.F:AddToggle("AutoEnemies", {
    Title = "Auto Enemies",
    Default = false,
    Callback = function(on)
        autoEnemiesActive = on
        if on then
            connection = rs.Heartbeat:Connect(function()
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root or not state.selectedIsland or #state.selectedEnemies == 0 then return end
                if not currentTarget or not currentTarget.Parent or not currentTarget:FindFirstChild("Humanoid") or currentTarget.Humanoid.Health <= 0 then
                    currentTarget = findClosestValidEnemy()
                end
                if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
                    local npcHRP = currentTarget.HumanoidRootPart
                    if bossMode then
                        if tick() - lastTeleport >= 0.6 then
                            local positions = {
                                Vector3.new(5, 0, 0),
                                Vector3.new(-5, 0, 0),
                                Vector3.new(0, 0, 5),
                                Vector3.new(0, 0, -5),
                            }
                            local teleportOffset = positions[bossTeleportStep]
                            local targetPos = npcHRP.Position + teleportOffset
                            local lookAt = CFrame.lookAt(targetPos, npcHRP.Position)
                            root.CFrame = lookAt
                            bossTeleportStep = bossTeleportStep + 1
                            if bossTeleportStep > #positions then bossTeleportStep = 1 end
                            lastTeleport = tick()
                        end
                    else
                        local height = 7
                        local abovePos = npcHRP.Position + Vector3.new(0, height, 0)
                        local lookAt = CFrame.lookAt(abovePos, npcHRP.Position)
                        root.CFrame = lookAt * CFrame.Angles(0, 0, math.rad(90))
                    end
                end
            end)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end
})

local function GetSpawnedBossList()
    local bosses = {}
    local bossFolder = workspace.World.Entities:FindFirstChild("WorldBosses")
    if bossFolder then
        for _, boss in ipairs(bossFolder:GetChildren()) do
            if boss:IsA("Model") and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
                table.insert(bosses, boss.Name)
            end
        end
    end
    return bosses
end

local bossDropdown = Tabs.B:AddDropdown("BossDropdown", {
    Title = "Boss Spawnado",
    Values = GetSpawnedBossList(),
    Multi = false,
    Default = nil,
    Callback = function(val)
        state.selectedBoss = val
    end
})

Tabs.B:AddButton({
    Title = "Refresh Bosses",
    Callback = function()
        if bossDropdown and bossDropdown.SetValues then
            bossDropdown:SetValues(GetSpawnedBossList())
        end
    end
})

local bossFarmCurrentTarget = nil
local bossFarmConnection
Tabs.B:AddToggle("AutoBossFarm", {
    Title = "Auto Boss",
    Default = false,
    Callback = function(enabled)
        if enabled then
            bossFarmConnection = rs.Heartbeat:Connect(function()
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local bossName = state.selectedBoss
                if not root or not bossName then bossFarmCurrentTarget = nil return end
                local bossFolder = workspace.World.Entities:FindFirstChild("WorldBosses")
                local bossModel = bossFolder and bossFolder:FindFirstChild(bossName)
                if bossModel and bossModel:FindFirstChild("Humanoid") and bossModel:FindFirstChild("HumanoidRootPart") and bossModel.Humanoid.Health > 0 then
                    bossFarmCurrentTarget = bossModel
                    local npcHRP = bossModel.HumanoidRootPart
                    if bossMode then
                        if tick() - lastTeleport >= 0.6 then
                            local positions = {
                                Vector3.new(5, 0, 0),
                                Vector3.new(-5, 0, 0),
                                Vector3.new(0, 0, 5),
                                Vector3.new(0, 0, -5),
                            }
                            local teleportOffset = positions[bossTeleportStep]
                            local targetPos = npcHRP.Position + teleportOffset
                            local lookAt = CFrame.lookAt(targetPos, npcHRP.Position)
                            root.CFrame = lookAt
                            bossTeleportStep = bossTeleportStep + 1
                            if bossTeleportStep > #positions then bossTeleportStep = 1 end
                            lastTeleport = tick()
                        end
                    else
                        local height = 7
                        local abovePos = npcHRP.Position + Vector3.new(0, height, 0)
                        local lookAt = CFrame.lookAt(abovePos, npcHRP.Position)
                        root.CFrame = lookAt * CFrame.Angles(0, 0, math.rad(90))
                    end
                else
                    bossFarmCurrentTarget = nil
                end
            end)
        else
            if bossFarmConnection then
                bossFarmConnection:Disconnect()
                bossFarmConnection = nil
            end
            bossFarmCurrentTarget = nil
        end
    end
})

local autoFruitAbility = false
local selectedAbilities = {FirstAbility = true}
Tabs.F:AddSection("Player", "user")
local abilityDropdown = Tabs.F:AddDropdown("AbilityDropdown", {
    Title = "Choose Ability",
    Description = "Select the abilities to use automatically.",
    Values = {"FirstAbility", "SecondAbility", "ThirdAbility", "FourthAbility", "FifthAbility"},
    Multi = true,
    Default = {"FirstAbility"},
})

abilityDropdown:OnChanged(function(Value)
    selectedAbilities = {}
    for v, enabled in next, Value do
        if enabled then
            selectedAbilities[v] = true
        end
    end
end)

Tabs.F:AddToggle("AutoFruitAbility", {
    Title = "Auto Fruit Ability",
    Default = false,
    Callback = function(on)
        autoFruitAbility = on
        if on then
            spawn(function()
                while autoFruitAbility do
                    task.wait(1.5)
                    local target = farmQuestCurrentTarget or currentTarget or bossFarmCurrentTarget
                    if target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                        local pos = target.HumanoidRootPart.Position
                        if bossMode then
                            task.wait(0.15)
                        end
                        local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CastAbility")
                        for abilityName, _ in pairs(selectedAbilities) do
                            local args1 = {
                                "Execute",
                                {
                                    Index = abilityName,
                                    MousePosition = pos
                                }
                            }
                            local args2 = {
                                "Terminate",
                                {
                                    Index = abilityName,
                                    MousePosition = pos
                                }
                            }
                            remote:FireServer(unpack(args1))
                            task.wait(0.2)
                            remote:FireServer(unpack(args2))
                            task.wait(0.2)
                        end
                    end
                end
            end)
        end
    end
})

local function findBestQuestNPC()
    local npcsFolder = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("NPCs")
    local bestNPC = nil
    local highestLevel = 0
    local playerLevel = player.Data.Level.Value
    if npcsFolder then
        for _, npc in ipairs(npcsFolder:GetChildren()) do
            local hrp = npc:FindFirstChild("HumanoidRootPart")
            local nameyuh = hrp and hrp:FindFirstChild("nameyuh")
            local NAME = nameyuh and nameyuh:FindFirstChild("NAME")
            local REQ = nameyuh and nameyuh:FindFirstChild("Req")
            if NAME and REQ and NAME:IsA("TextLabel") and REQ:IsA("TextLabel") and NAME.Text == "QUEST" then
                local reqText = REQ.Text
                local requiredLevel = tonumber(reqText:match("%d+"))
                if requiredLevel and playerLevel >= requiredLevel and requiredLevel > highestLevel then
                    bestNPC = npc
                    highestLevel = requiredLevel
                end
            end
        end
    end
    return bestNPC
end

Tabs.F:AddToggle("AutoQuest", {
    Title = "Auto Quest",
    Default = false,
    Callback = function(state)
        autoQuestActive = state
        if autoQuestActive then
            task.spawn(function()
                local firstQuest = true
                while autoQuestActive do
                    local questUI = player.PlayerGui:FindFirstChild("QuestUI")
                    local activeQuest = questUI and questUI:FindFirstChild("ActiveQuest")
                    if activeQuest and activeQuest.Visible then
                        task.wait(2)
                        firstQuest = false
                    else
                        local bestNPC = findBestQuestNPC()
                        if bestNPC then
                            if firstQuest then
                                local hrp = bestNPC:FindFirstChild("HumanoidRootPart")
                                if hrp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                    player.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
                                    task.wait(0.5)
                                end
                                firstQuest = false
                            end
                            local hrp = bestNPC:FindFirstChild("HumanoidRootPart")
                            local prompt = hrp and hrp:FindFirstChild("Interact")
                            if prompt and prompt:IsA("ProximityPrompt") then
                                fireproximityprompt(prompt)
                                task.wait(0.2)
                                local dialogue = player.PlayerGui:FindFirstChild("Dialogue")
                                local frame = dialogue and dialogue:FindFirstChild("Frame")
                                local answer1 = frame and frame:FindFirstChild("Answer1")
                                if answer1 and answer1:IsA("ImageButton") then
                                    firesignal(answer1.Activated)
                                end
                            end
                        end
                        task.wait(0.1)
                    end
                end
            end)
        end
    end
})

local farmQuestNPC = false
local questNPCConnection
local currentTargetIndex = 1
farmQuestCurrentTarget = nil

Tabs.F:AddToggle("FarmQuestNPC", {
    Title = "Farm Quest NPC",
    Default = false,
    Callback = function(enabled)
        farmQuestNPC = enabled
        if enabled then
            questNPCConnection = rs.Heartbeat:Connect(function()
                if not farmQuestNPC then return end
                local questFolder = player:FindFirstChild("Quest")
                local targetName = questFolder and questFolder:FindFirstChild("Target") and questFolder.Target.Value
                if targetName and workspace.World and workspace.World:FindFirstChild("Entities") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local entitiesFolder = workspace.World.Entities
                    local npcList = {}
                    local spawnCFrame = nil
                    for _, island in ipairs(entitiesFolder:GetChildren()) do
                        if island:IsA("Folder") then
                            for _, n in ipairs(island:GetChildren()) do
                                if string.find(n.Name, targetName, 1, true) and n:FindFirstChild("HumanoidRootPart") and n:FindFirstChild("Humanoid") and n:FindFirstChild("Spawn") and n.Spawn:IsA("Vector3Value") then
                                    if not spawnCFrame then spawnCFrame = CFrame.new(n.Spawn.Value) end
                                    table.insert(npcList, n)
                                end
                            end
                        end
                    end

                    while npcList[currentTargetIndex] and npcList[currentTargetIndex].Humanoid.Health <= 0 do
                        currentTargetIndex = currentTargetIndex + 1
                    end

                    local root = player.Character.HumanoidRootPart
                    if npcList[currentTargetIndex] and npcList[currentTargetIndex].Humanoid.Health > 0 then
                        local npc = npcList[currentTargetIndex]
                        farmQuestCurrentTarget = npc
                        local npcRoot = npc.HumanoidRootPart
                        local abovePos = npcRoot.Position + Vector3.new(0, 7, 0)
                        local lookAt = CFrame.lookAt(abovePos, npcRoot.Position)
                        root.CFrame = lookAt * CFrame.Angles(0, 0, math.rad(90))
                    elseif spawnCFrame then
                        currentTargetIndex = 1
                        farmQuestCurrentTarget = nil
                        local waitPos = spawnCFrame.Position + Vector3.new(0, 50, 0)
                        root.CFrame = CFrame.new(waitPos)
                    else
                        farmQuestCurrentTarget = nil
                        local bestNPC = findBestQuestNPC()
                        if bestNPC and bestNPC:FindFirstChild("HumanoidRootPart") then
                            root.CFrame = bestNPC.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                        end
                    end
                end
            end)
        elseif questNPCConnection then
            questNPCConnection:Disconnect()
            questNPCConnection = nil
            currentTargetIndex = 1
            farmQuestCurrentTarget = nil
        end
    end
})

local selectedStat = "Fruit"
local autoStatEnabled = false

Tabs.P:AddDropdown("StatType", {
    Title = "Select",
    Values = {"Fruit", "Defense", "Fighting", "Stamina", "Sword"},
    Multi = false,
    Default = "Fruit",
    Callback = function(value)
        selectedStat = value
    end
})

Tabs.P:AddToggle("AutoStat", {
    Title = "Auto Up Selected",
    Default = false,
    Callback = function(state)
        autoStatEnabled = state
        task.spawn(function()
            while autoStatEnabled do
                local args = {
                    {
                        ChangeStat = selectedStat,
                        Increment = 1
                    }
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("MenuMisc"):FireServer(unpack(args))
                task.wait()
            end
        end)
    end
})

local player = game.Players.LocalPlayer
local selectedEquipName = nil
local autoequip = false

local function getBackpackList()
    local items = {}
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            table.insert(items, tool.Name)
        end
    end
    return items
end

local equipDropdown = Tabs.P:AddDropdown("EquipDropdown", {
    Title = "Select Weapon",
    Values = getBackpackList(),
    Multi = false,
    Default = nil,
    Callback = function(selected)
        selectedEquipName = selected
    end
})

Tabs.P:AddButton({
    Title = "Refresh Equipment List",
    Description = "Manually refreshes the dropdown list with current Backpack items.",
    Callback = function()
        local options = getBackpackList()
        if equipDropdown and equipDropdown.SetValues then
            equipDropdown:SetValues(options)
        end
    end
})

Tabs.P:AddToggle("AutoEquip", {
    Title = "Auto Equip",
    Default = false,
    Callback = function(state)
        autoequip = state
        if autoequip then
            task.spawn(function()
                while autoequip do
                    if selectedEquipName then
                        local toolInBackpack = player.Backpack:FindFirstChild(selectedEquipName)
                        local toolInChar = player.Character and player.Character:FindFirstChild(selectedEquipName)
                        if not toolInBackpack and not toolInChar then
                            local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("MenuMisc")
                            local argsUnequip = {
                                {
                                    InventoryControl = true,
                                    Item = selectedEquipName,
                                    State = "UNEQUIP"
                                }
                            }
                            remote:FireServer(unpack(argsUnequip))
                            task.wait(0.3)
                            local argsEquip = {
                                {
                                    InventoryControl = true,
                                    Item = selectedEquipName,
                                    State = "EQUIP"
                                }
                            }
                            remote:FireServer(unpack(argsEquip))
                        elseif toolInBackpack and not toolInChar then
                            player.Character.Humanoid:EquipTool(toolInBackpack)
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

local fruitInput = Tabs.P:AddInput("FruitNameInput", {
    Title = "Fruit Name",
    Placeholder = "Ex: Dark Fruit",
    Default = "",
})

local autoRollFruitToggle
local autoRollFruitActive = false

autoRollFruitToggle = Tabs.P:AddToggle("AutoRollFruit", {
    Title = "Auto Roll Fruit",
    Default = false,
    Callback = function(state)
        autoRollFruitActive = state
        if state then
            spawn(function()
                while autoRollFruitActive do
                    local fruitName = fruitInput.Value
                    local found = false
                    for _, tool in ipairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
                        if tool:IsA("Tool") and tool.Name == fruitName and fruitName ~= "" then
                            found = true
                            break
                        end
                    end
                    if found then
                        autoRollFruitToggle:SetValue(false) -- desliga automaticamente!
                        break
                    else
                        -- Roda a roleta de fruta
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("GachaRemote"):FireServer()
                    end
                    task.wait(0.1) -- tempo entre as tentativas
                end
            end)
        end
    end
})

local redeemCodesActive = false
local codesList = {
    "MORESPINS",
    "SMOKED",
    "SEABEASTS",
    "BETTERSTATS",
    "FAVORITE",
    "SORRY",
    "WELCOME"
}

Tabs.P:AddToggle("RedeemCodesToggle", {
    Title = "Auto Redeem Codes",
    Default = false,
    Callback = function(enabled)
        redeemCodesActive = enabled
        if enabled then
            spawn(function()
                for _, code in ipairs(codesList) do
                    if not redeemCodesActive then break end
                    local args = { code }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RedeemCode"):FireServer(unpack(args))
                    wait(1) -- Wait 1 second between each code
                end
                redeemCodesActive = false
            end)
        end
    end
})

Tabs.P:AddButton({
    Title = "Clear Particles",
    Description = "Deletes everything.",
    Callback = function()
        local particles = game:GetService("ReplicatedStorage"):FindFirstChild("Assets")
        particles = particles and particles:FindFirstChild("Effects")
        particles = particles and particles:FindFirstChild("Particles")
        if particles then
            for _, v in ipairs(particles:GetChildren()) do
                v:Destroy()
            end
            print("All particles deleted!")
        else
            print("Particles folder not found!")
        end
    end
})

local function GetIslandDropdownList()
    local list = {}
    local islandsFolder = workspace.World:FindFirstChild("Islands")
    if islandsFolder then
        for _, island in ipairs(islandsFolder:GetChildren()) do
            if island:IsA("Model") then
                table.insert(list, island.Name)
            end
        end
    end
    return list
end

local selectedIslandName = nil
Tabs.L:AddDropdown("IslandDropdown", {
    Title = "Select Island",
    Values = GetIslandDropdownList(),
    Multi = false,
    Default = nil,
    Callback = function(name)
        selectedIslandName = name
    end
})

local teleportToggleActive = false
Tabs.L:AddToggle("TeleportIslandToggle", {
    Title = "Teleport to Island",
    Default = false,
    Callback = function(on)
        teleportToggleActive = on
        if on and selectedIslandName then
            local islandsFolder = workspace.World:FindFirstChild("Islands")
            local islandModel = islandsFolder and islandsFolder:FindFirstChild(selectedIslandName)
            local spawnPosValue = islandModel and islandModel:FindFirstChild("Information") and islandModel.Information:FindFirstChild("SpawnPosition")
            local spawnPos = spawnPosValue and spawnPosValue.Value
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root and spawnPos then
                root.CFrame = CFrame.new(spawnPos)
            end
        end
    end
})

local autoBossFinderActive = false

Tabs.B:AddToggle("AutoBossFinder", {
    Title = "Auto Boss Finder",
    Default = false,
    Callback = function(enabled)
        autoBossFinderActive = enabled
        if enabled then
            spawn(function()
                local islandsFolder = workspace.World:FindFirstChild("Islands")
                while autoBossFinderActive do
                    if islandsFolder then
                        for _, island in ipairs(islandsFolder:GetChildren()) do
                            if not autoBossFinderActive then break end
                            if island:IsA("Model") then
                                local infoFolder = island:FindFirstChild("Information")
                                local bossSpawnValue = infoFolder and infoFolder:FindFirstChild("BossSpawnPosition")
                                local bossSpawnPos = bossSpawnValue and bossSpawnValue.Value
                                local char = game.Players.LocalPlayer.Character
                                local root = char and char:FindFirstChild("HumanoidRootPart")
                                if root and bossSpawnPos then
                                    if typeof(bossSpawnPos) == "CFrame" then
                                        bossSpawnPos = bossSpawnPos.Position
                                    end
                                    root.CFrame = CFrame.new(bossSpawnPos)
                                    wait(0.5)
                                    local worldBosses = workspace.World.Entities:FindFirstChild("WorldBosses")
                                    if worldBosses and #worldBosses:GetChildren() > 0 then
                                        Fluent:Notify({
                                            Title = "Boss Found",
                                            Content = "A boss has appeared at " .. island.Name .. "!",
                                            Duration = 4
                                        })
                                        autoBossFinderActive = false
                                        break
                                    else
                                        wait(1)
                                    end
                                end
                            end
                        end
                    end
                    wait(1)
                end
            end)
        end
    end
})

Tabs.B:AddButton({
    Title = "Manual Server Hop",
    Description = "Switch to a new server manually.",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId)
    end
})

local autoServerHopActive = false
Tabs.B:AddToggle("AutoServerHop", {
    Title = "Auto Server Hop",
    Default = false,
    Callback = function(state)
        autoServerHopActive = state
        if state then
            spawn(function()
                while autoServerHopActive do
                    local TeleportService = game:GetService("TeleportService")
                    TeleportService:Teleport(game.PlaceId)
                    wait(60) -- Change the wait time as you prefer
                end
            end)
        end
    end
})

local afk = false
Tabs.Settings:AddSection("Player", "settings")
Tabs.Settings:AddToggle("AntiAfk", {
    Title = "Anti-AFK",
    Default = false,
    Callback = function(Value)
        afk = Value
        local vu = game:GetService("VirtualUser")
        if Value then
            Fluent:Notify({
                Title = "Anti-AFK",
                Content = "Ativado",
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
        end
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/Legends Piece")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
Tabs.F:ForceCanvas()
