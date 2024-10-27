local PointValues = {}

PointValues.EatHuman = 10 -- you caught a human as an alien
PointValues.EscapeShip = 15 -- you escaped as a human
PointValues.AliensWin = 25 -- most humans eaten, given only to original aliens and those who caught someone
PointValues.HumansWin = 25 -- most humans escaped, given only to surviving humans
PointValues.FullHumanWin = 50 -- all humans escaped in a lobby of at least 5 players, given to all humans
PointValues.FullAlienWin = 50 -- all humans eaten in a lobby of at least 5 players, given only to original aliens and those who caught someone

return PointValues