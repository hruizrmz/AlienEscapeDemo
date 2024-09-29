local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local playerData = ServerStorage:WaitForChild("PlayerData")
local status = game.Workspace:WaitForChild("Status")
local PlayerTables = require(game:GetService("ServerScriptService").PlayerTables)
local PointValues = require(game:GetService("ServerScriptService").PointValues)

local PLAYERS_NEEDED_TO_START = 2
local INTERMISSION_TIME = 3
local HUMAN_SPEED = 30
local ALIEN_SPEED = 32
local ALIEN_RESPAWN_BUFFER = 3
local GAME_TIME = 25

local function playerSettings(player)
    player.CharacterAdded:Connect(function(character)
        if player:FindFirstChild("isAlien") and player.isAlien.Value then
            character.Humanoid.WalkSpeed = ALIEN_SPEED
        else
            character.Humanoid.WalkSpeed = HUMAN_SPEED
        end
        character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
    end)
end

local function instancePlayer(player)
    for i, instance in pairs(playerData:GetChildren()) do -- pairs iterates through unknown key-value pairs in a table
        local clonedInstance = instance:Clone()
        clonedInstance.Parent = player -- clones every child found in playerData, and moves it into the player joining the game
    end
end

local function respawnPlayers()
    for i, player in pairs(Players:GetPlayers()) do
        if player.Character then
            player.Character:Destroy()
        end
        player.modelChanged.Value = false
        player:LoadCharacter()
    end
end

local function setUpGame()
    status.Value = ""
    for i, player in pairs(Players:GetPlayers()) do
        for key, list in pairs(PlayerTables) do
            if type(list) == "table" then
                table.clear(list)
            end
        end
        if player:FindFirstChild("isAlien").Value == true then
            player:FindFirstChild("isAlien").Value = false
            player:FindFirstChild("modelChanged").Value = false
        end
        respawnPlayers()
    end
end

local function gameLoop()
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

    if #Players:GetPlayers() == PLAYERS_NEEDED_TO_START then
        for i = INTERMISSION_TIME, -1, -1 do
            task.wait(1)
            status.Value = "Prepare to run in "..i..""
        end
    end
    status.Value = ""

    -- assigning roles
    local randomPlayerID = math.random(1, #Players:GetPlayers())
    local maxAliens = math.ceil(#Players:GetPlayers() / 3) -- aliens start a 1/3 of players for early game balance
    local selectedAliens = {}
    local uniqueIDs = {}

    for key, list in pairs(PlayerTables) do
        if type(list) == "table" then
            table.clear(list)
        end
    end

    while #selectedAliens < maxAliens do
        if not uniqueIDs[randomPlayerID] then -- find a new random player that is not already an alien
            uniqueIDs[randomPlayerID] = true
            table.insert(selectedAliens, randomPlayerID)
        else
            randomPlayerID = math.random(1, #Players:GetPlayers()) -- if we dont have maxAliens yet, assign another one
        end
    end

    for i, player in pairs(Players:GetPlayers()) do
        if uniqueIDs[i] then
            player:FindFirstChild("isAlien").Value = true
            table.insert(PlayerTables.AliensPlaying, player)
        else
            player:FindFirstChild("isAlien").Value = false
            table.insert(PlayerTables.HumansPlaying, player)
        end
    end

    -- preparing game arena
    respawnPlayers()

    for i, player in pairs(Players:GetPlayers()) do
        task.wait(1)
        if uniqueIDs[i] then
            ReplicatedStorage.Remotes.ShowRoleText:FireClient(player,true)
        else
            ReplicatedStorage.Remotes.ShowRoleText:FireClient(player,false)
        end
    end

    for i = ALIEN_RESPAWN_BUFFER, -1, -1 do
        task.wait(1)
        status.Value = "Aliens will wake up in "..i..""
    end
    status.Value = ""

    -- game time logic
    for i = GAME_TIME, 0, -1 do
        task.wait(1)
        if #PlayerTables.HumansPlaying == 0 then
            status.Value = ""
            ReplicatedStorage.Remotes.ShowResultsText:FireAllClients(PlayerTables, PointValues)
            task.wait(5)

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
    ReplicatedStorage.Remotes.ShowResultsText:FireAllClients(PlayerTables, PointValues)
    task.wait(5)

    setUpGame()
    gameLoop()
end

Players.PlayerAdded:Connect(function(player)
    instancePlayer(player)
    playerSettings(player)
end)
gameLoop()