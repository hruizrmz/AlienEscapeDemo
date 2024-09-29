--[[
This script was made by Wheez.
--]]
local UI=script.Parent
local Camera=workspace.CurrentCamera
--local Button=UI:WaitForChild("Frame"):WaitForChild("TextButton")
local Debounce=false
--[[]]--
local DiedConnection
local Render
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PlayerList
local CurrentIndex
local function GetPlayerList()
    PlayerList = Players:GetPlayers()
    for i, v in pairs(PlayerList) do
        if v == Players.LocalPlayer then
            table.remove(PlayerList, i)
            break
            end
        end
    table.insert(PlayerList, Players.LocalPlayer)
end
local SpectateSettings={
	["SmoothTransitions"]={
		["Tween"]=true;
		--[[
		The drawback of turning this true, is that you cannot rotate your camera
		while spectating. Your camera is fixed at a specific position with respect to
		the player.
		--]]
		["Status"]=false;
		--[[
		If the above setting is set to false, the camera will immediately get fixed
		at the next player to be spectated. In the other case, it will smoothly move towards the
		next player to be spectated.
		--]]
		["Style"]=Enum.EasingStyle.Quad;
		["Direction"]=Enum.EasingDirection.Out;
		["Time"]=0.1;
		--[[
		Increase the time for slower movement of the camera,
		and decrease it for faster movement of the camera to the next player to be spectated.
		--]]
		["DistanceFromPlayer"]=10; -- 10 Studs Distance From Player
		["HeightDistance"]=3; -- 7 Studs Above Their Head
		["InclinationAngle"]=20;
		--[[
		Mess around with the above two settings as per your
		preference. You will get what you prefer only with trial and error.
		=-]]
	};
	--[[
	Dont mess with the settings below.
	--]]
	["SpectateOn"]=false;
}
local function MouseEnterTween(ButtonItem)
	ButtonItem.MouseEnter:Connect(function()
		game.TweenService:Create(ButtonItem,TweenInfo.new(0.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0),{BackgroundColor3=Color3.fromRGB(255,255,255)}):Play()
	end)
	ButtonItem.MouseLeave:Connect(function()
		game.TweenService:Create(ButtonItem,TweenInfo.new(0.2,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0),{BackgroundColor3=Color3.fromRGB(161, 161, 161)}):Play()
	end)
end
local function SetCameraSubject(Character,OnActivation)
	if typeof(DiedConnection)~='nil' then
		DiedConnection:Disconnect()
		DiedConnection=nil
	end
	if typeof(Render)~='nil' then
		Render:Disconnect()
		Render=nil
		SpectateSettings.SmoothTransitions.Tween:Pause()
		SpectateSettings.SmoothTransitions.Tween=nil
	end
	if SpectateSettings.SmoothTransitions.Status==true then
		Camera.CameraType=Enum.CameraType.Scriptable
		local TargetCFrame
		Render=game:GetService("RunService").RenderStepped:Connect(function()
			TargetCFrame=Character.HumanoidRootPart.CFrame
			TargetCFrame*=CFrame.new(0,0,SpectateSettings.SmoothTransitions.DistanceFromPlayer)
			TargetCFrame*=CFrame.new(0,SpectateSettings.SmoothTransitions.HeightDistance,0)
			TargetCFrame*=CFrame.Angles(math.rad(-SpectateSettings.SmoothTransitions.InclinationAngle),0,0)
			SpectateSettings.SmoothTransitions.Tween=game.TweenService:Create(Camera,TweenInfo.new(SpectateSettings.SmoothTransitions.Time,SpectateSettings.SmoothTransitions.Style,SpectateSettings.SmoothTransitions.Direction,0,false,0),{CFrame=TargetCFrame})
			SpectateSettings.SmoothTransitions.Tween:Play()
		end)
	else
		Camera.CameraType=Enum.CameraType.Custom
		Camera.CameraSubject=Character.Humanoid
	end
	DiedConnection=Character.Humanoid.Died:Connect(function()
		OnActivation()
	end)
	UI.Buttons.Frame.PlayerName.Text=Character.Name
end
local function ValidityCheck()
	if not game.Players.LocalPlayer.Character then return end
	if not game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then return end
	if not game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
	return true
end
local function OnActivation(spectateStatus)
	if ValidityCheck()~=true then return end
	SpectateSettings.SpectateOn = spectateStatus
	if SpectateSettings.SpectateOn==true then
		UI.Buttons.Visible=true
		UI.Buttons.Position=UDim2.new(0.5,0,1.1,0)
		game.TweenService:Create(UI.Buttons,TweenInfo.new(0.24,Enum.EasingStyle.Back,Enum.EasingDirection.Out,0,false,0),{Position=UDim2.new(0.5,0,0.9,0)}):Play()
		GetPlayerList()
		CurrentIndex=#PlayerList
		SetCameraSubject(game.Players.LocalPlayer.Character,OnActivation)
	else
		if typeof(DiedConnection)~='nil' then
			DiedConnection:Disconnect()
			DiedConnection=nil
		end
		if typeof(Render)~='nil' then
			Render:Disconnect()
			Render=nil
			SpectateSettings.SmoothTransitions.Tween:Cancel()
			SpectateSettings.SmoothTransitions.Tween=nil
		end
		game.TweenService:Create(UI.Buttons,TweenInfo.new(0.23,Enum.EasingStyle.Back,Enum.EasingDirection.In,0,false,0),{Position=UDim2.new(0.5,0,1.1,0)}):Play()
		task.delay(0.23,function()
			UI.Buttons.Visible=false
		end)
		Camera.CameraType=Enum.CameraType.Custom
		Camera.CameraSubject=game.Players.LocalPlayer.Character.Humanoid
	end
end
ReplicatedStorage.Remotes.ShowSpectateUI.OnClientEvent:Connect(function()
	if Debounce==true then return end
	Debounce=true
	OnActivation(true)
	task.wait(0.3)
    Debounce=false
end)
ReplicatedStorage.Remotes.HideSpectateUI.OnClientEvent:Connect(function()
	if Debounce==true then return end
	Debounce=true
	OnActivation(false)
	task.wait(0.3)
    Debounce=false
end)
UI.Buttons.Next.Activated:Connect(function()
	if ValidityCheck()~=true then return end
	if Debounce==true then return end
	Debounce=true
	UI.Buttons.Next.Size=UDim2.new(0.2,0,.7,0)
	game.TweenService:Create(UI.Buttons.Next,TweenInfo.new(0.24,Enum.EasingStyle.Back,Enum.EasingDirection.Out,0,false,0),{Size=UDim2.new(0.2,0,.85,0)}):Play()
	local Valid=false
	repeat
		if CurrentIndex==#PlayerList then
			CurrentIndex=1
		else CurrentIndex=CurrentIndex+1
		end
		if PlayerList[CurrentIndex].Character and PlayerList[CurrentIndex].Character:FindFirstChild("Humanoid") and PlayerList[CurrentIndex].Character:FindFirstChild("HumanoidRootPart") then
			Valid=true
		end
		game:GetService("RunService").RenderStepped:Wait()
	until Valid==true
	SetCameraSubject(PlayerList[CurrentIndex].Character,OnActivation)
	task.wait(0.2)
    Debounce=false
end)
UI.Buttons.Previous.Activated:Connect(function()
	if ValidityCheck()~=true then return end
	if Debounce==true then return end
	Debounce=true
	UI.Buttons.Previous.Size=UDim2.new(0.2,0,.7,0)
	game.TweenService:Create(UI.Buttons.Previous,TweenInfo.new(0.24,Enum.EasingStyle.Back,Enum.EasingDirection.Out,0,false,0),{Size=UDim2.new(0.2,0,.85,0)}):Play()
	local Valid=false
	repeat
		if CurrentIndex==1 then
			CurrentIndex=#PlayerList
		else CurrentIndex=CurrentIndex-1
		end
		if PlayerList[CurrentIndex].Character and PlayerList[CurrentIndex].Character:FindFirstChild("Humanoid") and PlayerList[CurrentIndex].Character:FindFirstChild("HumanoidRootPart") then
			Valid=true
		end
		game:GetService("RunService").RenderStepped:Wait()
	until Valid==true
	SetCameraSubject(PlayerList[CurrentIndex].Character,OnActivation)
	task.wait(0.2)
    Debounce=false
end)
--[[]]--
MouseEnterTween(UI.Buttons.Next)
MouseEnterTween(UI.Buttons.Previous)