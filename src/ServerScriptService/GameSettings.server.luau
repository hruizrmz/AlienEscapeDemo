local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerStorage = game:GetService("ServerStorage")
local PlayerData = ServerStorage:WaitForChild("PlayerData")

local status = game.Workspace:WaitForChild("Status")

local INTERMISSION_TIME = 2
local GAME_TIME = 20
local PLAYERS_NEEDED_TO_START = 2
local TOKENS_FOR_HUMANS = 10
local TOKENS_FOR_ALIENS = 5

local ALIEN_RESPAWN_BUFFER = 5
local HUMAN_SPEED = 30
local ALIEN_SPEED = 34

local GamePlayers = {}

local function InstancePlayer(player)
    for i, instance in pairs(PlayerData:GetChildren()) do -- pairs iterates through unknown key-value pairs in a table
        local clonedInstance = instance:Clone()
        clonedInstance.Parent = player -- clones every child found in PlayerData, and moves it into the player joining the game
    end
end

local function PlayerSettings(player)
    player.CharacterAdded:Connect(function(character)
        if player:FindFirstChild("isAlien") and player.isAlien.Value then
            character.Humanoid.WalkSpeed = ALIEN_SPEED
            -- anchor aliens temporarily to give humans an advantage
            character:WaitForChild("HumanoidRootPart").Anchored = true
            task.wait(ALIEN_RESPAWN_BUFFER)
            character.HumanoidRootPart.Anchored = false
        else
            local alienLogicScript = character:FindFirstChild("AlienLogic")
            if alienLogicScript then
                alienLogicScript:Destroy()
            end
            character.Humanoid.WalkSpeed = HUMAN_SPEED
        end
    end)
end

local function SetUpGame()
    status.Value = ""
    for i, v in pairs(Players) do
        v:LoadCharacter()
        table.clear(GamePlayers)
    end
    for i, player in pairs(Players:GetPlayers()) do
        if player:FindFirstChild("isAlien").value == true then
            player:FindFirstChild("isAlien").value = false
        end
    end
end

local function RespawnPlayers()
    for i, player in pairs(Players:GetPlayers()) do
        if player.Character then
            player.Character:Destroy()
        end
        PlayerSettings(player)
        player:LoadCharacter()
    end
end

local function GameLoop()
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
        for i = INTERMISSION_TIME, 0, -1 do
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

    table.clear(GamePlayers)

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
        else
            player:FindFirstChild("isAlien").Value = false
        end
    end

    -- resetting game arena for game
    RespawnPlayers()

    for i, player in pairs(Players:GetPlayers()) do
        if uniqueIDs[i] then
            ReplicatedStorage.Remotes.ShowRoleText:FireClient(player,true)
        else
            ReplicatedStorage.Remotes.ShowRoleText:FireClient(player,false)
        end
    end

    for i = ALIEN_RESPAWN_BUFFER, 0, -1 do
        task.wait(1)
        status.Value = "Aliens will wake up in "..i..""
    end
    status.Value = ""

    
end

Players.PlayerAdded:Connect(function(player)
    InstancePlayer(player)
    PlayerSettings(player)
end)
GameLoop()