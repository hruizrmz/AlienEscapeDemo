local Players = game:GetService("Players")
local playerData = game:GetService("ServerStorage"):WaitForChild("PlayerData")
local DataStoreService = game:GetService("DataStoreService")

local database = DataStoreService:GetDataStore("playerScores")
local sessionData = {}

local HUMAN_SPEED = 40
local HUMAN_JUMP_POWER = 35
local ALIEN_SPEED = 48

local function playerSettings(player : Player)
    player.CharacterAdded:Connect(function(character)
        if player:FindFirstChild("isAlien") and player.isAlien.Value then
            character.Humanoid.WalkSpeed = ALIEN_SPEED
        else
            character.Humanoid.WalkSpeed = HUMAN_SPEED
            character.Humanoid.JumpPower = HUMAN_JUMP_POWER
        end
        character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end)
end

local function loadPlayerScore(player : Player)
    local success = nil
    local playerScore = nil
    local attempt = 1

    repeat
        success, playerScore = pcall(function()
            return database:GetAsync(player.UserId) -- get any data associated with that user ID
        end)
        attempt += 1
        if not success then
            warn(playerScore)
            task.wait(2)
        end
    until success or attempt == 5

    if success then
        print("Connected to database")
        if not playerScore then
            print("No player data history found.")
            playerScore = {
                ["AlienPoints"] = 0,
                ["AlienWins"] = 0,
                ["HumanPoints"] = 0,
                ["HumanWins"] = 0,
            }
        end
        sessionData[player.UserId] = playerScore
    else
        warn("Data not fetched for ", player.Name)
        player:Kick("Unable to load your score data. Try to join again later!")
    end

    local leaderstats = player:WaitForChild("leaderstats")
    leaderstats:FindFirstChild("AlienPoints").Value = playerScore.AlienPoints
    leaderstats:FindFirstChild("AlienPoints").Changed:Connect(function()
        playerScore.AlienPoints = leaderstats:FindFirstChild("AlienPoints").Value
    end)
    leaderstats:FindFirstChild("AlienWins").Value = playerScore.AlienWins
    leaderstats:FindFirstChild("AlienWins").Changed:Connect(function()
        playerScore.AlienWins = leaderstats:FindFirstChild("AlienWins").Value
    end)
    leaderstats:FindFirstChild("HumanPoints").Value = playerScore.HumanPoints
    leaderstats:FindFirstChild("HumanPoints").Changed:Connect(function()
        playerScore.HumanPoints = leaderstats:FindFirstChild("HumanPoints").Value
    end)
    leaderstats:FindFirstChild("HumanWins").Value = playerScore.HumanWins
    leaderstats:FindFirstChild("HumanWins").Changed:Connect(function()
        playerScore.HumanWins = leaderstats:FindFirstChild("HumanWins").Value
    end)

    print("Finished loading data for ", player.Name)
end

local function instancePlayer(player : Player)
    for i, instance in pairs(playerData:GetChildren()) do -- pairs iterates through unknown key-value pairs in a table
        local clonedInstance = instance:Clone()
        clonedInstance.Parent = player -- clones every child found in playerData, and moves it into the player joining the game
    end
    loadPlayerScore(player)
end

local function savePlayerScore(player : Player)
    if sessionData[player.UserId] then -- if the player has new data this session, save it
        local success = nil
        local errorMsg = nil
        local attempt = 1

        repeat
            success, errorMsg = pcall(function()
                database:SetAsync(player.UserId, sessionData[player.UserId]) -- set the given data to the user ID
            end)
            attempt += 1
            if not success then
                warn(errorMsg)
                task.wait(2) -- wait before trying again
            end
        until success or attempt == 5

        if success then
            print("Data saved for ", player.Name)
        else
            warn("Data not saved for ", player.Name) -- could not save after 5 attempts
        end
    end
end

local function serverShutdown()
    print("Server shutting down")
    for i, player : Player in ipairs(Players:GetPlayers()) do
        task.spawn(function()
            savePlayerScore(player)
        end)
    end
end

Players.PlayerAdded:Connect(function(player : Player)
    instancePlayer(player)
    playerSettings(player)
end)
Players.PlayerRemoving:Connect(function(player : Player)
    savePlayerScore(player)
end)
game:BindToClose(serverShutdown)