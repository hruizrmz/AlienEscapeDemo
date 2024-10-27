local ReplicatedStorage = game:GetService("ReplicatedStorage")

ReplicatedStorage.Remotes.ShowResultsText.OnClientEvent:Connect(function(text : string, awardedPoints : number)
	script.Parent.Text = ""..text.." (+"..awardedPoints.." pts)"

	script.Parent.Visible = true
	task.wait(3)

	for i = 1, 20 do
		script.Parent.TextTransparency += 0.05
		script.Parent.TextStrokeTransparency += 0.05
		task.wait(0.05)
	end

	script.Parent.Visible = false

	script.Parent.TextTransparency = 0
	script.Parent.TextStrokeTransparency = 0
end)