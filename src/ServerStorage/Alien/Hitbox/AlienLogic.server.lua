local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local GameData = ServerStorage:WaitForChild("GameData")
local SoundManager = require(ServerStorage:WaitForChild("SoundManager"))
local PlayerTables = require(GameData:WaitForChild("PlayerTables"))
local PointValues = require(GameData:WaitForChild("PointValues"))

local spawnLocation = game.Workspace:FindFirstChild("SpawnPoints"):WaitForChild("SpawnLocation1")
local isTouching = false

local function findPlayerPosition(humansPlaying : table, player)
    for i, v : Player in ipairs(humansPlaying) do
        if v == player then
            return i
        end
    end
    warn("Player was not found in Player Tables!")
    return nil
end

-- if an alien catches a human, they respawn as an alien
local function onCatch(alienPlayer, humanPlayer)
    if alienPlayer:FindFirstChild("caughtHumans") and not alienPlayer.caughtHumans.Value then
        alienPlayer.caughtHumans.Value = true
    end
    alienPlayer.leaderstats.AlienPoints.Value = alienPlayer.leaderstats.AlienPoints.Value + PointValues.EatHuman
    humanPlayer:FindFirstChild("isAlien").Value = true
    table.remove(PlayerTables.HumansPlaying, findPlayerPosition(PlayerTables.HumansPlaying, humanPlayer))
    table.insert(PlayerTables.Eaten, humanPlayer)
    table.insert(PlayerTables.AliensPlaying, humanPlayer)
    -- move player back to spawn point instead of loading
    humanPlayer.Character.HumanoidRootPart.CFrame = spawnLocation.CFrame + Vector3.new(0, 5, 0)
    SoundManager.PlaySFX("AlienRoar", 0.35)
end

local function onTouched(otherPart)
    if not isTouching then
        isTouching = true
        if not script.Parent.Parent.HumanoidRootPart.Anchored then
            local humanPlayer = Players:GetPlayerFromCharacter(otherPart.Parent)
            if humanPlayer and not humanPlayer:FindFirstChild("isAlien").Value then
                -- check that player character is valid as well
                local alienPlayer = Players:GetPlayerFromCharacter(script.Parent.Parent)
                if alienPlayer then
                    onCatch(alienPlayer, humanPlayer)
                end
            end
        end
        task.wait(1) -- touch cooldown
        isTouching = false
    end
end

local alienHitbox : BasePart = script.Parent
alienHitbox.Size = Vector3.new(3, 8, 3.3)
alienHitbox.Touched:Connect(onTouched)