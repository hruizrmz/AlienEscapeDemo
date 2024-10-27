local ReplicatedStorage = game:GetService("ReplicatedStorage")

ReplicatedStorage.Remotes.ShowRoleText.OnClientEvent:Connect(function(alienPlayer)
	if alienPlayer then
		script.Parent.Text = "You are an alien: catch the humans!"
	else 
		script.Parent.Text = "You are a human: escape the aliens!"
	end

	script.Parent.Visible = true
	task.wait(2)

	for i = 1,20 do -- fade out text animation
		script.Parent.TextTransparency += 0.05
		script.Parent.TextStrokeTransparency += 0.05
		task.wait(0.05)
	end

	script.Parent.Visible = false

	script.Parent.TextTransparency = 0
	script.Parent.TextStrokeTransparency = 0
end)