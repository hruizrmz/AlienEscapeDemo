local CalculateResults = {}

function CalculateResults:FullAlienWin(PlayerTables, PointValues, total)
	for i, v in ipairs(PlayerTables.AliensPlaying) do -- from all alien players by the end of the game...
		if not table.find(PlayerTables.OriginalAliens, v) then -- see if they were one of the original aliens
			if v:FindFirstChild("caughtHumans") and v.caughtHumans.Value then -- if they were not, then see if they caught anyone
				v.leaderstats.AlienWins.Value = v.leaderstats.AlienWins.Value + 1
				if total > 9 then -- more points are given for fuller lobbies
					v.leaderstats.AlienPoints.Value = v.leaderstats.AlienPoints.Value + PointValues.FullAlienWin
					v.awardedPoints.Value = PointValues.FullAlienWin
				else
					v.leaderstats.AlienPoints.Value = v.leaderstats.AlienPoints.Value + PointValues.AliensWin
					v.awardedPoints.Value = PointValues.AliensWin
				end
			end
		else
			v.leaderstats.AlienWins.Value = v.leaderstats.AlienWins.Value + 1
			if total > 9 then
				v.leaderstats.AlienPoints.Value = v.leaderstats.AlienPoints.Value + PointValues.FullAlienWin
				v.awardedPoints.Value = PointValues.FullAlienWin
			else
				v.leaderstats.AlienPoints.Value = v.leaderstats.AlienPoints.Value + PointValues.AliensWin
				v.awardedPoints.Value = PointValues.AliensWin
			end
		end
	end
end

function CalculateResults:FullHumanWin(PlayerTables, PointValues, total)
	for i, v in ipairs(PlayerTables.Escaped) do
		v.leaderstats.HumanWins.Value = v.leaderstats.HumanWins.Value + 1
		if total > 9 then -- more points are given for fuller lobbies
			v.leaderstats.HumanPoints.Value = v.leaderstats.HumanPoints.Value + PointValues.FullHumanWin
			v.awardedPoints.Value = PointValues.FullHumanWin
		else
			v.leaderstats.HumanPoints.Value = v.leaderstats.HumanPoints.Value + PointValues.HumansWin
			v.awardedPoints.Value = PointValues.HumansWin
		end
	end
end

function CalculateResults:AlienWin(PlayerTables, PointValues)
	for i, v in ipairs(PlayerTables.AliensPlaying) do -- from all alien players by the end of the game...
		if not table.find(PlayerTables.OriginalAliens, v) then -- see if they were one of the original aliens
			if v:FindFirstChild("caughtHumans") and v.caughtHumans.Value then -- if they were not, then see if they caught anyone
				v.leaderstats.AlienPoints.Value = v.leaderstats.AlienPoints.Value + PointValues.AliensWin
				v.awardedPoints.Value = PointValues.AliensWin
			end
		else
			v.leaderstats.AlienPoints.Value = v.leaderstats.AlienPoints.Value + PointValues.AliensWin
			v.awardedPoints.Value = PointValues.AliensWin
		end
	end
	
end

function CalculateResults:HumanWin(PlayerTables, PointValues)
	for i, v in ipairs(PlayerTables.Escaped) do
		v.leaderstats.HumanPoints.Value = v.leaderstats.HumanPoints.Value + PointValues.HumansWin
		v.awardedPoints.Value = PointValues.HumansWin
	end
end

return CalculateResults