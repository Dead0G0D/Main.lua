-- Carrega a biblioteca DrRay
local DrRayLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/DrRay-UI-Library/main/DrRay.lua"))()

-- Cria a janela principal
local window = DrRayLibrary:Load("Latency? 🎭", "Default")

-- Cria o tab "Gacha"
local tabGacha = DrRayLibrary.newTab("Gacha", "ImageIdHere")

-- Toggle de Auto Gacha (Swords)
local autoGachaSwords = false
tabGacha.newToggle("Auto Gacha (Swords)", "Ativa o gacha automático da aba Swords", false, function(state)
    autoGachaSwords = state
    if autoGachaSwords then
        task.spawn(function()
            while autoGachaSwords do
                local args = {{
                    Open_Amount = 2,
                    Action = "_Gacha_Activate",
                    Name = "Swords"
                }}
                game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("To_Server"):FireServer(unpack(args))
                task.wait(0.2)
            end
        end)
    end
end)

-- Toggle de Auto Gacha (Dragon_Race)
local autoGachaDragon = false
tabGacha.newToggle("Auto Gacha (Dragon_Race)", "Ativa o gacha automático da aba Dragon_Race", false, function(state)
    autoGachaDragon = state
    if autoGachaDragon then
        task.spawn(function()
            while autoGachaDragon do
                local args = {{
                    Open_Amount = 2,
                    Action = "_Gacha_Activate",
                    Name = "Dragon_Race"
                }}
                game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("To_Server"):FireServer(unpack(args))
                task.wait(0.2)
            end
        end)
    end
end)

-- Toggle de Auto Gacha (Saiyan_Evolution)
local autoGachaSaiyan = false
tabGacha.newToggle("Auto Gacha (Saiyan_Evolution)", "Ativa o gacha automático da aba Saiyan_Evolution", false, function(state)
    autoGachaSaiyan = state
    if autoGachaSaiyan then
        task.spawn(function()
            while autoGachaSaiyan do
                local args = {{
                    Open_Amount = 2,
                    Action = "_Gacha_Activate",
                    Name = "Saiyan_Evolution"
                }}
                game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("To_Server"):FireServer(unpack(args))
                task.wait(0.2)
            end
        end)
    end
end)
