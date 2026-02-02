local RunService = game:GetService("RunService")
local cloneref = (cloneref or clonereference or function(instance) return instance end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local WindUI

do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)
    
    if ok then
        WindUI = result
    else 
        if cloneref(game:GetService("RunService")):IsStudio() then
            WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
        else
            WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
        end
    end
end

MarketplaceService = game:GetService("MarketplaceService")
PlaceId = game.PlaceId
ProductInfo = MarketplaceService:GetProductInfo(PlaceId)
GameName = ProductInfo.Name

local Window = WindUI:CreateWindow({
    Title = "Latency" .. GameName,
    Icon = "landmark",
    Author = "?",
    Folder = "Latency" .. GameName,
    Size = UDim2.fromOffset(580, 380),
    Transparent = true,
    Theme = "Dark",
    Resizable = false,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = false,
    ScrollBarEnabled = true,
})

local Tab = Window:Tab({
    Title = "Farm",
    Icon = "house", -- optional
    Locked = false,
})

local Rp = game:GetService("ReplicatedStorage")
local comboConn

local ToggleAttackClick = Tab:Toggle({
    Title = "Auto click",
    Desc = "",
    Icon = "",
    Type = "Toggle",
    Value = false,
    Callback = function(state)
        if comboConn then
            comboConn:Disconnect()
            comboConn = nil
        end
        if state then
            comboConn = RunService.Heartbeat:Connect(function()
                Rp:WaitForChild("Remotes"):WaitForChild("AttackEvent"):FireServer()
                Rp:WaitForChild("Remotes"):WaitForChild("ClickRemote"):FireServer()
            end)
        end
    end
})

local c1
local ToggleAttackClick = Tab:Toggle({
    Title = "Click",
    Desc = "",
    Icon = "",
    Type = "Toggle",
    Value = false,
    Callback = function(state)
        if c1 then
            c1:Disconnect()
            c1 = nil
        end
        if state then
            c1 = RunService.Heartbeat:Connect(function()
                Rp:WaitForChild("Remotes"):WaitForChild("ClickRemote"):FireServer()
            end)
        end
    end
})

local selectedNpcNames = {}

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

local npcDropdown = Tab:Dropdown({
    Title = "Selecionar NPCs",
    Desc = "",
    Values = GetUniqueNpcNames(),
    Value = {},
    Multi = true,
    AllowNone = true,
    Callback = function(option)
        selectedNpcNames = option
    end
})

local Button = Tab:Button({
    Title = "Refresh",
    Desc = "",
    Locked = false,
    Callback = function()
        if npcDropdown then
            npcDropdown:Refresh(GetUniqueNpcNames())
        end
    end
})

local player = game:GetService("Players").LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:FindFirstChild("HumanoidRootPart")
local humanoid = char:FindFirstChild("Humanoid")
local running = false
local currentTarget = nil

local selectedFarmMode = "Tp"
local FarmModeDropdown = Tab:Dropdown({
    Title = "Farm Mode",
    Desc = "",
    Values = { "Tp", "Legit" },
    Value = "Tp",
    Multi = false,
    AllowNone = false,
    Callback = function(option)
        selectedFarmMode = option
    end
})



local ToggleNpcAutoFarm = Tab:Toggle({
    Title = "Auto Farm Selected NPCs",
    Desc = "",
    Icon = "",
    Type = "Toggle",
    Value = false,
    Callback = function(state)
        running = false
        currentTarget = nil
        if state then
            running = true
            while running do
                if not selectedNpcNames or #selectedNpcNames == 0 then break end
                for _, npcName in ipairs(selectedNpcNames) do
                    if not running then break end
                    while running do
                        local target = nil
                        if selectedFarmMode == "Legit" and hrp then
                            local closestDist = 60
                            for _, npc in ipairs(workspace.Enemies:GetChildren()) do
                                local h, hrpNpc, canTake = npc:FindFirstChild("Humanoid"), npc:FindFirstChild("HumanoidRootPart"), npc:FindFirstChild("CanTakeDamage")
                                if npc.Name == npcName and h and h.Health > 0 and hrpNpc and canTake and canTake.Value == true then
                                    local dist = (hrp.Position - hrpNpc.Position).Magnitude
                                    if dist <= closestDist then
                                        closestDist = dist
                                        target = npc
                                    end
                                end
                            end
                        else
                            for _, npc in ipairs(workspace.Enemies:GetChildren()) do
                                local h, hrpNpc, canTake = npc:FindFirstChild("Humanoid"), npc:FindFirstChild("HumanoidRootPart"), npc:FindFirstChild("CanTakeDamage")
                                if npc.Name == npcName and h and h.Health > 0 and hrpNpc and canTake and canTake.Value == true then
                                    target = npc
                                    break
                                end
                            end
                        end
                        if target and running then
                            repeat
                                if not running then return end
                                if not target.Parent then break end
                                local health = target.Humanoid.Health
                                if selectedFarmMode == "Tp" and hrp then
                                    hrp.CFrame = target.HumanoidRootPart.CFrame + Vector3.new(0, 0, -2.5)
                                elseif selectedFarmMode == "Legit" and humanoid and hrp then
                                    local destination = target.HumanoidRootPart.Position + Vector3.new(0,0,2.7)
                                    humanoid:MoveTo(destination)
                                end

                                if not health or health <= 0 then break end
                                RunService.Heartbeat:Wait()
                            until not running
                        else
                            break
                        end
                    end
                    if not running then break end
                end
                wait(0.1)
            end
        end
    end
})

local selectedWorld = nil

local Dropdown = Tab:Dropdown({
    Title = "Select World",
    Desc = "Choose the World for the capsule",
    Values = { "World 1", "World 2", "World 3", "World 4" },
    Value = "",
    Callback = function(option)
        selectedWorld = option
    end
})

local openCapsuleConn

local ToggleOpenCapsule = Tab:Toggle({
    Title = "Open Capsule",
    Desc = "",
    Icon = "",
    Type = "Toggle",
    Value = false,
    Callback = function(state)
        if openCapsuleConn then
            openCapsuleConn:Disconnect()
            openCapsuleConn = nil
        end
        if state then
            openCapsuleConn = game:GetService("RunService").Heartbeat:Connect(function()
                local args = { selectedWorld, 1, { autoDelete = true, pity = { mythic = 0, legendary = 0, mTotal = 10000, lTotal = 1000 }}}
                Rp:WaitForChild("Remotes"):WaitForChild("ChampionRollRequest"):InvokeServer(unpack(args))
            end)
        end
    end
})

local selectedPowerType = nil
local powerConn = nil

local Dropdown = Tab:Dropdown({
    Title = "Select Power Type",
    Desc = "",
    Values = { "Race", "Fruit", "Genes", "Form", "Biju", "Doujutsu" },
    Value = "",
    Multi = false,
    AllowNone = false,
    Callback = function(option)
        selectedPowerType = option
    end
})

local TogglePower = Tab:Toggle({
    Title = "Auto RequestPowerRoll",
    Desc = "",
    Icon = "",
    Type = "Toggle",
    Value = false,
    Callback = function(state)
        if powerConn then
            powerConn:Disconnect()
            powerConn = nil
        end
        if state and selectedPowerType then
            powerConn = RunService.Heartbeat:Connect(function()
                Rp:WaitForChild("Remotes"):WaitForChild("RequestPowerRoll"):InvokeServer(selectedPowerType)
            end)
        end
    end
})
