local Fluent = loadstring(Game:HttpGet("https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/Beta.lua", true))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Anime Arise Simulator",
    SubTitle = "by Latency",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Farm", Icon = "swords" }),
    Trials = Window:AddTab({ Title = "Gamemodes", Icon = "landmark" }),
    Upgrade = Window:AddTab({ Title = "Player/Gachas", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

task.spawn(function()
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local remoteFound = false
    while not remoteFound do
        for _, child in ipairs(replicatedStorage:GetChildren()) do
            if child:IsA("Folder") then
                for _, item in ipairs(child:GetDescendants()) do
                    if item:IsA("RemoteEvent") then
                        getgenv().RemoteFireCode = item
                        remoteFound = true
                        print("RemoteEvent found at:", item:GetFullName())
                        break
                    end
                end
                if remoteFound then break end
            end
        end
        if not remoteFound then
            task.wait(1)
        end
    end
end)

local key = "01010010 01100101 01110000 01101100 01101001 01100011 01100001 01110100 01100101 01100100 01010011 01110100 01101111 01110010 01100001 01100111 01100101 00101110 01010110 01101001 01101110 01101110 01111001 01000110 01110010 01100001 01101101 01100101 01110111 01101111 01110010 01101011 00101110 01001100 01101001 01100010 01110010 01100001 01110010 01111001 00101110 01000011 01101111 01101110 01101110 01100101 01100011 01110100 01101001 01101111 01101110 00101110 01110100 01101000 01110010 01100101 01100001 01100100 01011111 01110011 01100101 01100011 01110101 01110010 01101001 01110100 01111001 00111010 00110001 00001010 01010010 01100101 01110000 01101100 01101001 01100011 01100001 01110100 01100101 01100100 01010011 01110100 01101111 01110010 01100001 01100111 01100101 00101110 01010110 01101001 01101110 01101110 01111001 01000110 01110010 01100001 01101101 01100101 01110111 01101111 01110010 01101011 00101110 01001100 01101001 01100010 01110010 01100001 01110010 01111001 00101110 01000011 01101111 01101110 01101110 01100101 01100011 01110100 01101001 01101111 01101110 00111010 00110001 00110101 00110110 00100000 01100110 01110101 01101110 01100011 01110100 01101001 01101111 01101110 00100000 01110011 01100101 01101110 01100100 00001010 01010010 01100101 01110000 01101100 01101001 01100011 01100001 01110100 01100101 01100100 01010011 01110100 01101111 01110010 01100001 01100111 01100101 00101110 01010110 01101001 01101110 01101110 01111001 01000110 01110010 01100001 01101101 01100101 01110111 01101111 01110010 01101011 00101110 01001100 01101001 01100010 01110010 01100001 01110010 01111001 00101110 01000011 01101100 01101001 01100101 01101110 01110100 00101110 01010110 01100001 01110101 01101100 01110100 01000111 01100001 01100011 01101000 01100001 01010011 01100101 01110100 01110101 01110000 00111010 00110010 00110101 00111001 00001010"

Tabs.Main:AddSection("Toggles", "sword")
local autoClickActive = false
Tabs.Main:AddToggle("Click", {
    Title = "Auto Click",
    Default = false,
    Callback = function(state)
        autoClickActive = state
        task.spawn(function()
            while autoClickActive do   
local args = {
	key,
	"System",
	"Enemies",
	"Damage"
}
                RemoteFireCode:FireServer(unpack(args))
local args = {
	key,
	"System",
	"Click",
	"Run"
}
                RemoteFireCode:FireServer(unpack(args))
                task.wait(0.01)
            end
        end)
    end
})

local MultiDropdown = nil
getgenv().SelectedEnemies = {}

local function getEnemyNames()
    local enemiesFolder = workspace:FindFirstChild("_Enemies")
    if not enemiesFolder then return {} end

    local namesSet = {}
    for _, model in ipairs(enemiesFolder:GetChildren()) do
        if model:IsA("Model") then
            namesSet[model.Name] = true
        end
    end

    local uniqueNames = {}
    for name in pairs(namesSet) do
        table.insert(uniqueNames, name)
    end

    table.sort(uniqueNames)
    return uniqueNames
end

local function updateDropdown()
    local values = getEnemyNames()
    MultiDropdown:SetValues(values)
end

MultiDropdown = Tabs.Main:AddDropdown("EnemyMultiDropdown", {
    Title = "Enemies",
    Description = "Select Enemies.",
    Values = getEnemyNames(),
    Multi = true,
    Default = {},
})

MultiDropdown:OnChanged(function(Value)
    getgenv().SelectedEnemies = {}
    for nome, ativo in pairs(Value) do
        if ativo then
            table.insert(getgenv().SelectedEnemies, nome)
        end
    end
end)

local enemiesFolder = workspace:WaitForChild("_Enemies")
enemiesFolder.ChildAdded:Connect(function(child)
    if child:IsA("Model") then
        updateDropdown()
    end
end)
enemiesFolder.ChildRemoved:Connect(function(child)
    if child:IsA("Model") then
        updateDropdown()
    end
end)

local AutoEnemies = false
Tabs.Main:AddToggle("AutoEnemiesToggle", {
    Title = "Auto Enemies",
    Default = false,
    Callback = function(Value)
        AutoEnemies = Value
    end,
})

task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoEnemies then
            local enemiesFolder = workspace:FindFirstChild("_Enemies")
            if enemiesFolder then
                for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                    if not AutoEnemies then break end
                    if enemy:IsA("Model") and table.find(getgenv().SelectedEnemies, enemy.Name) then
                        local hrp = enemy:FindFirstChild("HumanoidRootPart")
                        local char = game.Players.LocalPlayer.Character
                        local chrHrp = char and char:FindFirstChild("HumanoidRootPart")
                        local enemyHealth = enemy:GetAttribute("Health")
                        if hrp and chrHrp and enemyHealth and enemyHealth > 0 then
                            local togglePosition = true
                            repeat
                                local zOffset = togglePosition and -3 or 3
                                chrHrp.CFrame = hrp.CFrame * CFrame.new(0, 0, zOffset)
                                togglePosition = not togglePosition      
                                task.wait(0.5)
                                enemyHealth = enemy:GetAttribute("Health")
                            until (enemyHealth and enemyHealth <= 0) or not AutoEnemies or not enemy.Parent
                        end
                    end
                end
            end
        end
    end
end)

local function watchTrialEasyTexts(onUpdate)
    local watchedLabels = {}

    local function tryConnect(label)
        if label and label:IsA("TextLabel") and not watchedLabels[label] then
            watchedLabels[label] = true
            label:GetPropertyChangedSignal("Text"):Connect(onUpdate)
        end
    end

    task.spawn(function()
        while true do
            local player = game:GetService("Players").LocalPlayer
            local gui = player and player:FindFirstChild("PlayerGui")
            local surfaces = gui and gui:FindFirstChild("Surfaces")
            local trialEasy = surfaces and surfaces:FindFirstChild("TrialEasy")
            if trialEasy then
                local title = trialEasy:FindFirstChild("Title")
                local state = trialEasy:FindFirstChild("State")
                tryConnect(title)
                if title and title:IsA("TextLabel") then
                    tryConnect(title:FindFirstChild("Title"))
                end
                tryConnect(state)
                onUpdate() -- Atualiza sempre que encontra as labels
            end
            task.wait(1)
        end
    end)
end

local function getTrialEasyStatus()
    local player = game:GetService("Players").LocalPlayer
    local gui = player and player:FindFirstChild("PlayerGui")
    local surfaces = gui and gui:FindFirstChild("Surfaces")
    local trialEasy = surfaces and surfaces:FindFirstChild("TrialEasy")
    if not trialEasy then return "N/A" end

    local title = trialEasy:FindFirstChild("Title")
    if title and title:IsA("TextLabel") and title.Text ~= "" then
        return title.Text
    end
    local titleTitle = title and title:FindFirstChild("Title")
    if titleTitle and titleTitle:IsA("TextLabel") and titleTitle.Text ~= "" then
        return titleTitle.Text
    end
    local state = trialEasy:FindFirstChild("State")
    if state and state:IsA("TextLabel") and state.Text ~= "" then
        return state.Text
    end
    return "Trial"
end

local function isTrialOpened()
    local status = getTrialEasyStatus()
    return tostring(status):upper() == "OPENED"
end

Tabs.Trials:AddSection("Trial", "landmark")
local trialParagraph = Tabs.Trials:AddParagraph({
    Title = "⏳ Timers",
    Content = "Easy Trial: N/A"
})

local function updateParagraph()
    trialParagraph:SetDesc("Easy Trial: " .. getTrialEasyStatus())
end
watchTrialEasyTexts(updateParagraph)
updateParagraph()

function InTrial()
    return pcall(function()
        return game:GetService("Players").LocalPlayer.PlayerGui.Animation.Top.Visible
    end) and game:GetService("Players").LocalPlayer.PlayerGui.Animation.Top.Visible or false
end

local t1 = false
Tabs.Trials:AddToggle("tr1", {
    Title = "Auto Join EasyTrial",
    Default = false,
    Callback = function(state)
        t1 = state
        task.spawn(function()
            while t1 do
                if not InTrial() then
                    local args = {
                        key,
                        "System",
                        "Islands",
                        "Teleport",
                        -2,
                        "Easy"
                    }
                    RemoteFireCode:FireServer(unpack(args))
                end
                task.wait(1)
            end
        end)
    end
})

local AutoFarmTrial = false
Tabs.Trials:AddToggle("AutoFarmTrial", {
    Title = "Auto Farm Trial",
    Default = false,
    Callback = function(state)
        AutoFarmTrial = state
    end
})

task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoFarmTrial then
            local enemiesFolder = workspace:FindFirstChild("_Enemies")
            if enemiesFolder then
                for _, npc in ipairs(enemiesFolder:GetChildren()) do
                    if not AutoFarmTrial then break end
                    if npc:IsA("Model") and npc:GetAttribute("Area") == -2 then
                        local hrp = npc:FindFirstChild("HumanoidRootPart")
                        local char = game.Players.LocalPlayer.Character
                        local chrHrp = char and char:FindFirstChild("HumanoidRootPart")
                        local npcHealth = npc:GetAttribute("Health")
                        if hrp and chrHrp and npcHealth and npcHealth > 0 then
                            local togglePosition = true
                            repeat
                                local zOffset = togglePosition and -3 or 3
                                chrHrp.CFrame = hrp.CFrame * CFrame.new(0, 0, zOffset)
                                togglePosition = not togglePosition
                                task.wait(0.6)
                                npcHealth = npc:GetAttribute("Health")
                            until (npcHealth and npcHealth <= 0) or not AutoFarmTrial or not npc.Parent
                        end
                    end
                end
            end
        end
    end
end)

Tabs.Trials:AddSection("Raids", "key")
local RaidList = {
    "PieceRaid",
    "AlienRaid",
    "JojoRaid",
    "BleachRaid",
    "JujutsuRaid"
}

local RaidIDs = {
    PieceRaid = -1000,
    AlienRaid = -1001,
    JojoRaid = -1002,
    BleachRaid = -1003,
    JujutsuRaid = -1004
}

local RaidToggles = {}
for _, raidName in ipairs(RaidList) do
    RaidToggles[raidName] = false
    Tabs.Trials:AddToggle("AutoJoin_"..raidName, {
        Title = "Auto Join "..raidName,
        Default = false,
        Callback = function(state)
            RaidToggles[raidName] = state
        end
    })
end

local targetWave = 20
local autoLeavePerWave = false

Tabs.Trials:AddInput("TargetWaveInput", {
    Title = "Target Wave",
    Description = "Set the wave to auto leave.",
    Default = tostring(targetWave),
    Placeholder = "Wave...",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        targetWave = tonumber(Value) or targetWave
    end
})

Tabs.Trials:AddToggle("Auto Leave Per Wave", {
    Title = "Auto Leave Per Wave",
    Default = false,
    Callback = function(state)
        autoLeavePerWave = state
    end
})

local AutoFarmRaid = false
Tabs.Trials:AddToggle("fraid", {
    Title = "Auto Enemies Raid",
    Default = false,
    Callback = function(state)
        AutoFarmRaid = state
    end
})

task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoFarmRaid then
            for _, raidName in ipairs(RaidList) do
                if RaidToggles[raidName] and InRaid(raidName) then
                    local enemiesFolder = workspace:FindFirstChild("_Enemies")
                    if enemiesFolder then
                        for _, npc in ipairs(enemiesFolder:GetChildren()) do
                            if not AutoFarmRaid then break end
                            if npc:IsA("Model") and npc:GetAttribute("Raid") == raidName then
                                local hrp = npc:FindFirstChild("HumanoidRootPart")
                                local char = game.Players.LocalPlayer.Character
                                local chrHrp = char and char:FindFirstChild("HumanoidRootPart")
                                local npcHealth = npc:GetAttribute("Health")
                                if hrp and chrHrp and npcHealth and npcHealth > 0 then
                                    local togglePosition = true
                                    repeat
                                        local zOffset = togglePosition and -3 or 3
                                        chrHrp.CFrame = hrp.CFrame * CFrame.new(0, 0, zOffset)
                                        togglePosition = not togglePosition
                                        task.wait(0.6)
                                        npcHealth = npc:GetAttribute("Health")
                                    until (npcHealth and npcHealth <= 0) or not AutoFarmRaid or not npc.Parent
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

function InRaid(raidName)
    local ok = false
    pcall(function()
        local gui = game:GetService("Players").LocalPlayer.PlayerGui.Animation[raidName]
        if gui and gui.Visible then
            ok = true
        end
    end)
    return ok
end

function GetCurrentWave(raidName)
    local wave = nil
    pcall(function()
        local waveObj = game:GetService("Players").LocalPlayer.PlayerGui.Animation[raidName].CWave
        if waveObj and waveObj.Text then
            local num = string.match(waveObj.Text, "%d+")
            wave = tonumber(num)
        end
    end)
    return wave
end

game:GetService("RunService").RenderStepped:Connect(function()
    for _, raidName in ipairs(RaidList) do
        if RaidToggles[raidName] then
            if not InRaid(raidName) then
                local raidID = RaidIDs[raidName]
                if raidID then
                    local args = {
                        key,
                        "System",
                        "Islands",
                        "Teleport",
                        raidID
                    }
                    RemoteFireCode:FireServer(unpack(args))
                end
            elseif autoLeavePerWave then
                local currentWave = GetCurrentWave(raidName)
                if currentWave and currentWave >= targetWave then
                    local raidID = RaidIDs[raidName]
                    if raidID then
                        local args = {
                            key,
                            "System",
                            "Islands",
                            "Teleport",
                            raidID
                        }
                        RemoteFireCode:FireServer(unpack(args))
                    end
                end
            end
        end
    end
end)

local autoRankActive = false
Tabs.Upgrade:AddToggle("Auto Rank Up", {
    Title = "Auto Rank",
    Default = false,
    Callback = function(state)
        autoRankActive = state
        task.spawn(function()
            while autoRankActive do
local args = {
	key,
	"System",
	"Ranks",
	"Up"
}
                RemoteFireCode:FireServer(unpack(args))
                task.wait(0.5)
            end
        end)
    end
})

local up1 = false
Tabs.Upgrade:AddToggle("p1", {
    Title = "Auto Haki Gacha",
    Default = false,
    Callback = function(state)
        up1 = state
        task.spawn(function()
            while up1 do
                local args = {
	key,
	"System",
	"VaultGacha",
	"Roll",
	"Hakis"
}
				RemoteFireCode:FireServer(unpack(args))
                task.wait(0.1)
            end
        end)
    end
})

local up2 = false
Tabs.Upgrade:AddToggle("p2", {
    Title = "Auto Race Gacha",
    Default = false,
    Callback = function(state)
        up2 = state
        task.spawn(function()
            while up2 do
                local args = {
	key,
	"System",
	"VaultGacha",
	"Roll",
	"Races"
}
				RemoteFireCode:FireServer(unpack(args))
                task.wait(0.1)
            end
        end)
    end
})

local up3 = false
Tabs.Upgrade:AddToggle("p3", {
    Title = "Auto Range Gacha",
    Default = false,
    Callback = function(state)
        up3 = state
        task.spawn(function()
            while up3 do
                local args = {
	key,
	"System",
	"VaultGacha",
	"Roll",
	"Range"
}
				RemoteFireCode:FireServer(unpack(args))
                task.wait(0.1)
            end
        end)
    end
})

local up4 = false
Tabs.Upgrade:AddToggle("p4", {
    Title = "Auto GoldExperience Gacha",
    Default = false,
    Callback = function(state)
        up4 = state
        task.spawn(function()
            while up4 do
                local args = {
	key,
	"System",
	"VaultGacha",
	"Roll",
	"GoldExperience"
}
				RemoteFireCode:FireServer(unpack(args))
                task.wait(0.1)
            end
        end)
    end
})

local up5 = false
Tabs.Upgrade:AddToggle("p5", {
    Title = "Auto Sins Gacha",
    Default = false,
    Callback = function(state)
        up5 = state
        task.spawn(function()
            while up5 do
                local args = {
	key,
	"System",
	"VaultGacha",
	"Roll",
	"Sins"
}
				RemoteFireCode:FireServer(unpack(args))
                task.wait(0.1)
            end
        end)
    end
})

local up6 = false
Tabs.Upgrade:AddToggle("p6", {
    Title = "Auto Families Gacha",
    Default = false,
    Callback = function(state)
        up6 = state
        task.spawn(function()
            while up6 do
                local args = {
	key,
	"System",
	"VaultGacha",
	"Roll",
	"Families"
}
				RemoteFireCode:FireServer(unpack(args))
                task.wait(0.1)
            end
        end)
    end
})

local up7 = false
Tabs.Upgrade:AddToggle("p7", {
    Title = "Auto Nem Gacha",
    Default = false,
    Callback = function(state)
        up7 = state
        task.spawn(function()
            while up7 do
                local args = {
	key,
	"System",
	"VaultGacha",
	"Roll",
	"Nem"
}
				RemoteFireCode:FireServer(unpack(args))
                task.wait(0.1)
            end
        end)
    end
})

local up8 = false
Tabs.Upgrade:AddToggle("p8", {
    Title = "Auto MartialArts Gacha",
    Default = false,
    Callback = function(state)
        up8 = state
        task.spawn(function()
            while up8 do
                local args = {
	key,
	"System",
	"VaultGacha",
	"Roll",
	"Martialarts"
}
				RemoteFireCode:FireServer(unpack(args))
                task.wait(0.1)
            end
        end)
    end
})

local up9 = false
Tabs.Upgrade:AddToggle("p9", {
    Title = "Auto Kaisen Gacha",
    Default = false,
    Callback = function(state)
        up9 = state
        task.spawn(function()
            while up9 do
                local args = {
	key,
	"System",
	"VaultGacha",
	"Roll",
	"Kaisen"
}
				RemoteFireCode:FireServer(unpack(args))
                task.wait(0.1)
            end
        end)
    end
})

local selectedEgg = ""

local function getEggNames()
    local eggsFolder = workspace:FindFirstChild("_Eggs")
    if not eggsFolder then return {} end

    local eggNames = {}
    for _, egg in ipairs(eggsFolder:GetChildren()) do
        table.insert(eggNames, egg.Name)
    end
    table.sort(eggNames)
    return eggNames
end

local eggDropdown = Tabs.Main:AddDropdown("Egg", {
    Title = "Select Egg",
    Values = getEggNames(),
    Multi = false,
    Default = nil,
    Callback = function(value)
        selectedEgg = value
    end
})

local eggsFolder = workspace:FindFirstChild("_Eggs")
if eggsFolder then
    eggsFolder.ChildAdded:Connect(function()
        eggDropdown:SetValues(getEggNames())
    end)
    eggsFolder.ChildRemoved:Connect(function()
        eggDropdown:SetValues(getEggNames())
    end)
end

local egg = false
Tabs.Main:AddToggle("Hatch", {
    Title = "Auto Hatch",
    Default = false,
    Callback = function(state)
        egg = state
        task.spawn(function()
            while egg do
                local args = {
	key,
	"System",
	"Eggs",
	"Open",
	selectedEgg,
}
				RemoteFireCode:FireServer(unpack(args))
                task.wait(0.1)
            end
        end)
    end
})

local vu = game:GetService("VirtualUser")
local player = game.Players.LocalPlayer
local afk = false
Tabs.Settings:AddSection("Player", "wallpaper")
Tabs.Settings:AddToggle("AntiAfk", {
    Title = "Anti-Afk",
    Default = false,
    Callback = function(Value)
        afk = Value
        if Value then
            Fluent:Notify({
                Title = "Anti AFK",
                Content = "On",
                Duration = 4
            })
            task.spawn(function()
                while Afk do
                    wait(450)
                    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    wait(1)
                    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end
            end)
        else
            Fluent:Notify({
                Title = "AntiAFK",
                Content = "Off",
                Duration = 4
            })
        end
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/AnimeArise")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
