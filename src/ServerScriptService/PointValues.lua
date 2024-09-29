local PointValues = {}

PointValues.AliensWin = 8 -- most humans eaten, given to all aliens
PointValues.EatHuman = 16 -- you caught a human as an alien, given to all aliens
PointValues.EscapeShip = 24 -- you escaped as a human
PointValues.HumansWin = 32 -- most humans escaped, given only to surviving humans
PointValues.FullHumanWin = 40 -- all humans escaped in a lobby of at least 10 players, given only to original aliens
PointValues.FullAlienWin = 42 -- all humans eaten in a lobby of at least 10 players

return PointValues