local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/Beta.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Anime Hunters",
    SubTitle = "by Latency",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    F = Window:AddTab({ Title = "Main", Icon = "star" }),
    P = Window:AddTab({ Title = "Player", Icon = "user" }),
    T = Window:AddTab({ Title = "Gamemodes", Icon = "landmark" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local Options = Fluent.Options

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local function InDungeon()
    local frame = game.Players.LocalPlayer.PlayerGui:FindFirstChild("UI", true)
    frame = frame and frame:FindFirstChild("HUD", true)
    frame = frame and frame:FindFirstChild("Gamemodes", true)
    frame = frame and frame:FindFirstChild("Dungeon", true)
    return frame and frame.Visible or false
end

local function InRaid()
    local frame = game.Players.LocalPlayer.PlayerGui:FindFirstChild("UI", true)
    frame = frame and frame:FindFirstChild("HUD", true)
    frame = frame and frame:FindFirstChild("Gamemodes", true)
    frame = frame and frame:FindFirstChild("Raid", true)
    return frame and frame.Visible or false
end

local function getAllEnemyIDsInRadius(maxDist)
    local ids = {}
    local function checkFolder(folder)
        for _, enemy in ipairs(folder:GetChildren()) do
            if enemy:IsA("BasePart") and enemy:GetAttribute("Health") and enemy:GetAttribute("Health") > 0 then
                local distance = (root.Position - enemy.Position).Magnitude
                if distance <= maxDist then
                    table.insert(ids, enemy:GetAttribute("ID"))
                end
            end
        end
    end
    -- World Enemies
    for _, folder in ipairs(workspace.Server.Enemies.World:GetChildren()) do
        if folder:IsA("Folder") then
            checkFolder(folder)
        end
    end
    -- Raid Enemies
    if InRaid() then
        for _, folder in ipairs(workspace.Server.Enemies.Gamemodes:GetChildren()) do
            if folder:IsA("Folder") then
                checkFolder(folder)
            end
        end
    end
    -- DungeonEasy Enemies
    if workspace.Server.Gamemodes:FindFirstChild("DungeonEasy") and InDungeon() then
        for _, folder in ipairs(workspace.Server.Gamemodes.DungeonEasy:GetChildren()) do
            if folder:IsA("Folder") then
                checkFolder(folder)
            end
        end
    end
    -- DungeonMedium Enemies
    if workspace.Server.Gamemodes:FindFirstChild("DungeonMedium") and InDungeon() then
        for _, folder in ipairs(workspace.Server.Gamemodes.DungeonMedium:GetChildren()) do
            if folder:IsA("Folder") then
                checkFolder(folder)
            end
        end
    end
    return ids
end

local autoFarm = false
local autoFarmConnection

Tabs.F:AddToggle("AutoFarmToggle", {
    Title = "Auto Farm Nearest",
    Default = false,
    Callback = function(state)
        autoFarm = state
        if autoFarm then
            autoFarmConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local ids = getAllEnemyIDsInRadius(25)
                if #ids > 0 then
                    for _, id in ipairs(ids) do
                        local args = {
                            "General",
                            "Attack",
                            "Click",
                            id
                        }
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Signal"):FireServer(unpack(args))
                    end
                else
                    local args = {
                        "General",
                        "Attack",
                        "Click"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Signal"):FireServer(unpack(args))
                end
            end)
        else
            if autoFarmConnection then
                autoFarmConnection:Disconnect()
                autoFarmConnection = nil
            end
        end
    end
})

Tabs.T:AddParagraph({
    Title = "Open Times",
    Content = 
        "Raid: XX:15 e XX:45\n" ..
        "Dungeon Easy: XX:00\n" ..
        "Dungeon Medium: XX:30"
})

local lastJoinRaid, lastJoinEasy, lastJoinMedium = 0, 0, 0
local autoJoinEasy, autoJoinMedium, autoJoinRaid = false, false, false
local autoJoinConns = {}

-- RAID: XX:15 e XX:45
Tabs.T:AddToggle("AutoJoinRaid", {
    Title = "Auto Join Raid",
    Default = false,
    Callback = function(state)
        autoJoinRaid = state
        if state then
            autoJoinConns.Raid = game:GetService("RunService").Heartbeat:Connect(function()
                local min = os.date("*t").min
                if (min == 15 or min == 45) and os.time() - lastJoinRaid > 50 then
                    if not InRaid() then
                        lastJoinRaid = os.time()
                        game:GetService("ReplicatedStorage").Remotes.Signal:FireServer("Gamemodes", "Raid", "Join")
                    end
                end
            end)
        elseif autoJoinConns.Raid then
            autoJoinConns.Raid:Disconnect()
            autoJoinConns.Raid = nil
        end
    end
})

-- DUNGEON EASY: XX:00
Tabs.T:AddToggle("AutoJoinDungeonEasy", {
    Title = "Auto Join Dungeon Easy",
    Default = false,
    Callback = function(state)
        autoJoinEasy = state
        if state then
            autoJoinConns.Easy = game:GetService("RunService").Heartbeat:Connect(function()
                local min = os.date("*t").min
                if min == 0 and os.time() - lastJoinEasy > 50 then
                    if not InDungeon() then
                        lastJoinEasy = os.time()
                        game:GetService("ReplicatedStorage").Remotes.Signal:FireServer("Gamemodes", "Dungeon Easy", "Join")
                    end
                end
            end)
        elseif autoJoinConns.Easy then
            autoJoinConns.Easy:Disconnect()
            autoJoinConns.Easy = nil
        end
    end
})

-- DUNGEON MEDIUM: XX:30
Tabs.T:AddToggle("AutoJoinDungeonMedium", {
    Title = "Auto Join Dungeon Medium",
    Default = false,
    Callback = function(state)
        autoJoinMedium = state
        if state then
            autoJoinConns.Medium = game:GetService("RunService").Heartbeat:Connect(function()
                local min = os.date("*t").min
                if min == 30 and os.time() - lastJoinMedium > 50 then
                    if not InDungeon() then
                        lastJoinMedium = os.time()
                        game:GetService("ReplicatedStorage").Remotes.Signal:FireServer("Gamemodes", "Dungeon Medium", "Join")
                    end
                end
            end)
        elseif autoJoinConns.Medium then
            autoJoinConns.Medium:Disconnect()
            autoJoinConns.Medium = nil
        end
    end
})

local stars = {}
for _, star in ipairs(workspace.Server.Stars:GetChildren()) do
    table.insert(stars, star.Name)
end

local selectedStar = stars[1]
local autoHatch = false
local autoHatchConnection

local StarDropdown = Tabs.F:AddDropdown("StarDropdown", {
    Title = "Select Star",
    Values = stars,
    Multi = false,
    Default = selectedStar,
})

StarDropdown:OnChanged(function(star)
    selectedStar = star
end)

Tabs.F:AddToggle("AutoHatchToggle", {
    Title = "Auto Hatch",
    Default = false,
    Callback = function(state)
        autoHatch = state
        if autoHatch then
            autoHatchConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if selectedStar then
                    local args = {
                        "General",
                        "Stars",
                        "Multi",
                        selectedStar
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Signal"):FireServer(unpack(args))
                end
            end)
        else
            if autoHatchConnection then
                autoHatchConnection:Disconnect()
                autoHatchConnection = nil
            end
        end
    end
})

Tabs.F:AddButton({
    Title = "Star Animation",
    Description = "Remove o Star Animation",
    Callback = function()
        local player = game:GetService("Players").LocalPlayer
        local gui = player.PlayerGui:FindFirstChild("Star_Open")
        if gui and gui:FindFirstChild("Template") and gui.Template:FindFirstChild("Viewport") then
            gui.Template.Viewport:Destroy()
        end
    end
})

local autoRankUp = false
local autoRankUpConnection

Tabs.P:AddToggle("AutoRankUpToggle", {
    Title = "Auto Rank Up",
    Default = false,
    Callback = function(state)
        autoRankUp = state
        if autoRankUp then
            autoRankUpConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local args = {
                    "General",
                    "RankUp",
                    "Upgrade"
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Signal"):FireServer(unpack(args))
            end)
        else
            if autoRankUpConnection then
                autoRankUpConnection:Disconnect()
                autoRankUpConnection = nil
            end
        end
    end
})

local gachasFolder = game:GetService("ReplicatedStorage").Shared.Gachas
local gachaNames = {}
for _, child in ipairs(gachasFolder:GetChildren()) do
    table.insert(gachaNames, child.Name)
end
local selectedGacha = gachaNames[1]
local autoRollConn

Tabs.P:AddDropdown("GachaDropdown", {
    Title = "Select Gacha",
    Values = gachaNames,
    Multi = false,
    Default = selectedGacha,
}):OnChanged(function(gacha)
    selectedGacha = gacha
end)

Tabs.P:AddToggle("AutoRollToggle", {
    Title = "Auto Roll Gacha",
    Default = false,
    Callback = function(state)
        if state then
            autoRollConn = game:GetService("RunService").Heartbeat:Connect(function()
                if selectedGacha then
                    game:GetService("ReplicatedStorage").Remotes.Signal:FireServer(
                        "General", "Gacha", "Roll", selectedGacha, {}
                    )
                end
            end)
        elseif autoRollConn then
            autoRollConn:Disconnect()
            autoRollConn = nil
        end
    end
})

Tabs.Settings:AddSection("Player", "settings")
Tabs.Settings:AddButton({
    Title = "Server Hop",
    Description = "Switch to a new server manually.",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId)
    end
})

local a = false
local p = game:GetService("Players")
local l = p.LocalPlayer

Tabs.Settings:AddToggle("AntiAfk", {
    Title = "Anti-AFK",
    Default = false,
    Callback = function(v)
        a = v  
        if a then
            Fluent:Notify({
                Title = "Anti-AFK",
                Content = "Ativado",
                Duration = 4
            })
            if not l.i then
                l.i = l.Idled:Connect(function()
                    if a then
                        local vu = game:GetService("VirtualUser")
                        vu:CaptureController()
                        vu:ClickButton2(Vector2.new())
                    end
                end)
            end
        else
            Fluent:Notify({
                Title = "Anti-AFK",
                Content = "Desativado",
                Duration = 4
            })
            if l.i then
                l.i:Disconnect()
                l.i = nil
            end
        end
    end
})

local i = Tabs.Settings:AddInput("SpeedInput", {
    Title = "Speed Input",
    Description = "Set player speed",
    Default = "16",
    Placeholder = "Type speed",
    Numeric = true,
    Finished = true,
    Callback = function(v)
        local n = tonumber(v)
        if n and l.Character and l.Character:FindFirstChildOfClass("Humanoid") then
            l.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = n
        end
    end
})

i:OnChanged(function()
    local n = tonumber(i.Value)
    if n and l.Character and l.Character:FindFirstChildOfClass("Humanoid") then
        l.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = n
    end
end)

l.CharacterAdded:Connect(function(c)
    local n = tonumber(i.Value)
    local h = c:FindFirstChildOfClass("Humanoid")
    if h and n then
        h.WalkSpeed = n
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/Anime Hunters")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
