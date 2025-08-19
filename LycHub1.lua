local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local decalId = "rbxassetid://71192722711909"

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DraggableImageButtonGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local imageButton = Instance.new("ImageButton")
imageButton.Name = "DraggableButton"
imageButton.Image = decalId
imageButton.Size = UDim2.new(0, 65, 0, 65)
imageButton.AnchorPoint = Vector2.new(0.5, 0.5)
imageButton.Position = UDim2.new(0.2, 0, 0.02, 0)
imageButton.BackgroundTransparency = 0
imageButton.AutoButtonColor = false
imageButton.Parent = screenGui

local dragging, dragInput, mousePos, startPos = false

imageButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		mousePos = input.Position
		startPos = imageButton.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

imageButton.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local GuiInset = game:GetService("GuiService"):GetGuiInset()
		local Delta = input.Position - mousePos
		local ViewportSize = workspace.CurrentCamera.ViewportSize
		local CurrentX = startPos.X.Scale + (Delta.X / ViewportSize.X)
		local CurrentY = startPos.Y.Scale + (Delta.Y / ViewportSize.Y)
		if CurrentX < 0 then CurrentX = 0 end
		if CurrentX > 1 then CurrentX = 1 end
		if CurrentY < 0 then CurrentY = 0 end
		if CurrentY > 1 then CurrentY = 1 end
		imageButton.Position = UDim2.fromScale(CurrentX, CurrentY)
	end
end)

imageButton.MouseButton1Click:Connect(function()
	Window:Minimize()
end)

local gui = Fluent.GUI
local playerGui = player.PlayerGui

if _G.fluentLoopRunning then
    _G.fluentLoopRunning = _G.fluentLoopRunning + 1
else
    _G.fluentLoopRunning = 1
end
local runId = _G.fluentLoopRunning

task.spawn(function()
    while gui and gui:IsDescendantOf(game) do
        if _G.fluentLoopRunning ~= runId then break end
        task.wait(0.05)
    end
    if _G.fluentLoopRunning == runId then
        local drag = playerGui:FindFirstChild("DraggableImageButtonGui")
        if drag then drag.Enabled = true end
    end
end)

task.spawn(function()
    while true do
        if _G.fluentLoopRunning ~= runId then break end
        if not gui or not gui:IsDescendantOf(game) then
            local drag = playerGui:FindFirstChild("DraggableImageButtonGui")
            if drag then drag:Destroy() end
            break
        end
        local minimized = Window and Window.Minimized
        local drag = playerGui:FindFirstChild("DraggableImageButtonGui")
        if drag then drag.Enabled = minimized end
        task.wait(0.025)
    end
    if _G.fluentLoopRunning == runId then
        local drag = playerGui:FindFirstChild("DraggableImageButtonGui")
        if drag then drag.Enabled = true end
    end
end)
