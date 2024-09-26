local ReplicatedStorage = game:GetService("ReplicatedStorage")

ReplicatedStorage.Remotes.ShowResultsText.OnClientEvent:Connect(function(results)
	if results == "Aliens" then
		script.Parent.Text = "The aliens ate all the humans!"
	elseif results == "Escaped" then
		script.Parent.Text = "You escaped the aliens!"
	end
	script.Parent.Visible = true
	task.wait(2)

	for i = 1,20 do
		script.Parent.TextTransparency += 0.05
		script.Parent.TextStrokeTransparency += 0.05
		task.wait(0.05)
	end

	script.Parent.Visible = false

	script.Parent.TextTransparency = 0
	script.Parent.TextStrokeTransparency = 0
end)