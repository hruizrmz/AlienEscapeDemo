local ReplicatedStorage = game:GetService("ReplicatedStorage")

ReplicatedStorage.Remotes.ShowResultsText.OnClientEvent:Connect(function(PlayerTables, PointValues)
	local remainingPlayers = #PlayerTables.HumansPlaying

	local total = remainingPlayers + #PlayerTables.Eaten + #PlayerTables.Escaped

	if total == (#PlayerTables.Eaten + remainingPlayers) then
		script.Parent.Text = "Aliens win! No human survived the hunt."
		for i, v in ipairs(PlayerTables.OriginalAliens) do
			v.leaderstats.AlienWins.Value = v.leaderstats.AlienWins.Value + 1
			v.leaderstats.AlienPoints.Value = v.leaderstats.AlienPoints.Value + PointValues.FullAlienWin
		end
		for i, v in ipairs(PlayerTables.AliensPlaying) do
			v.leaderstats.AlienPoints.Value = v.leaderstats.AlienPoints.Value + PointValues.AliensWin
		end
	elseif total == #PlayerTables.Escaped then
		script.Parent.Text = "Humans win! Everyone escaped the aliens."
		for i, v in ipairs(PlayerTables.Escaped) do
			v.leaderstats.HumanWins.Value = v.leaderstats.HumanWins.Value + 1
			v.leaderstats.HumanPoints.Value = v.leaderstats.HumanPoints.Value + PointValues.FullHumanWin
		end
	elseif (#PlayerTables.Eaten + remainingPlayers) > #PlayerTables.Escaped then
		if #PlayerTables.Escaped == 1 then
			script.Parent.Text = "Aliens took over the ship, but 1 human escaped..."
		else
			script.Parent.Text = "Aliens took over the ship, but "..#PlayerTables.Escaped.." humans escaped..."
		end
		for i, v in ipairs(PlayerTables.AliensPlaying) do
			v.leaderstats.AlienPoints.Value = v.leaderstats.AlienPoints.Value + PointValues.AliensWin
		end
	else
		if (#PlayerTables.Eaten + remainingPlayers) == 1 then
			script.Parent.Text = "Most humans survived, but 1 human didn't escape..."
		else
			script.Parent.Text = "Most humans survived, but "..#PlayerTables.Eaten.." humans didn't escape..."
		end
		for i, v in ipairs(PlayerTables.Escaped) do
			v.leaderstats.HumanPoints.Value = v.leaderstats.HumanPoints.Value + PointValues.HumansWin
		end
	end

	script.Parent.Visible = true
	task.wait(3)

	for i = 1,20 do
		script.Parent.TextTransparency += 0.05
		script.Parent.TextStrokeTransparency += 0.05
		task.wait(0.05)
	end

	script.Parent.Visible = false

	script.Parent.TextTransparency = 0
	script.Parent.TextStrokeTransparency = 0
end)