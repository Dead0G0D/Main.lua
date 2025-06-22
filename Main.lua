-- Carrega a biblioteca DrRay
local DrRayLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/DrRay-UI-Library/main/DrRay.lua"))()

-- Cria a janela principal
local window = DrRayLibrary:Load("Gacha UI", "Default")

-- Cria o tab "Gacha"
local tabGacha = DrRayLibrary.newTab("Gacha", "ImageIdHere")

-- Toggle de Auto Gacha (Swords)
local autoGacha = false
tabGacha.newToggle("Auto Gacha (Swords)", "Ativa o gacha automático da aba Swords", false, function(state)
    autoGacha = state
    if autoGacha then
        task.spawn(function()
            while autoGacha do
                local args = {{
                    Open_Amount = 2,
                    Action = "_Gacha_Activate",
                    Name = "Swords"
                }}
                game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("To_Server"):FireServer(unpack(args))
                task.wait(1) -- ajuste o delay se necessário
            end
        end)
    end
end)
