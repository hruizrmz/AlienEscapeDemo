local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local status = game.Workspace:WaitForChild("Status")
local ServerStorage = game:GetService("ServerStorage")
local GameData = ServerStorage:WaitForChild("GameData")
local PlayerTables = require(GameData:WaitForChild("PlayerTables"))
local PointValues = require(GameData:WaitForChild("PointValues"))
local CalculateResults = require(GameData:WaitForChild("CalculateResults"))
local SoundManager = require(ServerStorage:WaitForChild("SoundManager"))

local PLAYERS_NEEDED_TO_START = 2
local INTERMISSION_TIME = 10
local ALIEN_RESPAWN_BUFFER = 4
local GAME_TIME = 90
local BGM_VOLUME = 0.6

local function respawnPlayers()
    for i, player : Player in pairs(Players:GetPlayers()) do
        if player.Character then
            player.Character:Destroy()
        end
        player.modelChanged.Value = false
        player:LoadCharacter()
    end
end

local function setUpGame()
    status.Value = ""
    for i, door : Object in pairs(CollectionService:GetTagged("EscapePodDoor")) do
        door.Occupied.Value = true
        door.Material = "DiamondPlate"
        door.BrickColor = BrickColor.new("Maroon")
        door.Transparency = 0.2
        door.CollisionGroup = "Default"
    end
    for i, player : Player in pairs(Players:GetPlayers()) do
        for key, list : table in pairs(PlayerTables) do
            if type(list) == "table" then
                table.clear(list)
            end
        end
        if player:FindFirstChild("isAlien").Value == true then
            player:FindFirstChild("awardedPoints").Value = 0
            player:FindFirstChild("isAlien").Value = false
            player:FindFirstChild("modelChanged").Value = false
            player:FindFirstChild("caughtHumans").Value = false
        end
        ReplicatedStorage.Remotes.HideSpectateUI:FireClient(player)
    end
    respawnPlayers()
end

local function calculateWinners()
    local remainingPlayers = #PlayerTables.HumansPlaying
	local total = remainingPlayers + #PlayerTables.Eaten + #PlayerTables.Escaped

    if total == (#PlayerTables.Eaten + remainingPlayers) then
        CalculateResults:FullAlienWin(PlayerTables, PointValues, total)
        return "Aliens win! No human survived the hunt."
    elseif total == #PlayerTables.Escaped then
        CalculateResults:FullHumanWin(PlayerTables, PointValues, total)
        return "Humans win! Everyone escaped the ship."
    elseif (#PlayerTables.Eaten + remainingPlayers) > #PlayerTables.Escaped then
        CalculateResults:AlienWin(PlayerTables, PointValues)
        if #PlayerTables.Escaped == 1 then
            return "Aliens took over the ship, but 1 human escaped..."
        else
            return "Aliens took over the ship, but "..#PlayerTables.Escaped.." humans escaped..."
        end
    else
        CalculateResults:HumanWin(PlayerTables, PointValues)
        if (#PlayerTables.Eaten + remainingPlayers) == 1 then
            return "Most humans survived, but 1 human didn't escape..."
        else
            return "Most humans survived, but "..#PlayerTables.Eaten.." humans didn't escape..."
        end
    end
end

local function gameLoop()
    SoundManager.PlayBGM("LobbyMusic", BGM_VOLUME, 20)
    -- waiting for players
    status.Value = "Loading..."
    task.wait(1)
    if #Players:GetPlayers() < PLAYERS_NEEDED_TO_START then
        repeat
            local playersNeeded = PLAYERS_NEEDED_TO_START - #Players:GetPlayers()
            status.Value = "Not enough players! ("..playersNeeded.." more)"
            task.wait(1)
        until #Players:GetPlayers() >= PLAYERS_NEEDED_TO_START
    end

    if #Players:GetPlayers() >= PLAYERS_NEEDED_TO_START then
        for i = INTERMISSION_TIME, -1, -1 do
            task.wait(1)
            status.Value = "Prepare to run in "..i..""
        end

        if #Players:GetPlayers() < PLAYERS_NEEDED_TO_START then
            gameLoop()
        end
    end
    status.Value = ""

    -- assigning roles
    local randomPlayerID = math.random(1, #Players:GetPlayers())
    local maxAliens = math.floor(#Players:GetPlayers() / 2) -- lobbies can be up to 10 players as there's only 5 escape pods
    local selectedAliens = {}
    local uniqueAlienIDs = {}

    for key, list : table in pairs(PlayerTables) do
        if type(list) == "table" then
            table.clear(list)
        end
    end

    while #selectedAliens < maxAliens do
        if not uniqueAlienIDs[randomPlayerID] then -- find a new random player that is not already an alien
            uniqueAlienIDs[randomPlayerID] = true
            table.insert(selectedAliens, randomPlayerID)
        else
            randomPlayerID = math.random(1, #Players:GetPlayers()) -- if we dont have maxAliens yet, assign another one
        end
    end

    for i, player : Player in pairs(Players:GetPlayers()) do
        if uniqueAlienIDs[i] then
            player:FindFirstChild("isAlien").Value = true
            table.insert(PlayerTables.AliensPlaying, player)
            table.insert(PlayerTables.OriginalAliens, player)
        else
            player:FindFirstChild("isAlien").Value = false
            table.insert(PlayerTables.HumansPlaying, player)
        end
    end

    -- preparing game arena
    SoundManager.StopBGM("LobbyMusic")
    respawnPlayers()
    task.wait(1)
    SoundManager.PlayBGM("GameMusic", BGM_VOLUME)
    
    for i, player : Player in pairs(Players:GetPlayers()) do
        if uniqueAlienIDs[i] then
            ReplicatedStorage.Remotes.ShowRoleText:FireClient(player,true)
        else
            ReplicatedStorage.Remotes.ShowRoleText:FireClient(player,false)
        end
    end

    for i, door : Object in pairs(CollectionService:GetTagged("EscapePodDoor")) do
        door.Occupied.Value = false
        door.Material = "CrackedLava"
        door.BrickColor = BrickColor.new("Teal")
        door.Transparency = 0.4
        door.CollisionGroup = "PodDoors"
    end

    for i = ALIEN_RESPAWN_BUFFER, 0, -1 do
        task.wait(1)
        status.Value = "Aliens will wake up in "..i..""
    end
    SoundManager.PlaySFX("StartGame")
    status.Value = ""

    -- game time logic
    for i = GAME_TIME, 0, -1 do
        task.wait(1)
        if #PlayerTables.HumansPlaying == 0 then
            status.Value = ""
            task.wait(1)
            local resultsText = calculateWinners()
            for i, player : Player in pairs(Players:GetPlayers()) do
                ReplicatedStorage.Remotes.ShowResultsText:FireClient(player, resultsText, player.awardedPoints.Value)
            end
            task.wait(5)

            SoundManager.StopBGM("GameMusic")
            setUpGame()
            gameLoop()
            return
        end
        if #PlayerTables.HumansPlaying == 1 then
            status.Value = "The escape pods will leave in "..i.." seconds! (1 human remains)"
        else
            status.Value = "The escape pods will leave in "..i.." seconds! ("..#PlayerTables.HumansPlaying.." humans remain)"
        end
    end

    status.Value = ""
    task.wait(1)
    local resultsText = calculateWinners()
    for i, player : Player in pairs(Players:GetPlayers()) do
        ReplicatedStorage.Remotes.ShowResultsText:FireClient(player, resultsText, player.awardedPoints.Value)
    end
    task.wait(5)

    SoundManager.StopBGM("GameMusic")
    setUpGame()
    gameLoop()
end

gameLoop()