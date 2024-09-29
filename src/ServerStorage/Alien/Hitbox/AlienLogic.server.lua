local Players = game:GetService("Players")
local PlayerTables = require(game:GetService("ServerScriptService").PlayerTables)
local PointValues = require(game:GetService("ServerScriptService").PointValues)

local spawnLocation = game.Workspace:WaitForChild("SpawnLocation")

local function findPlayerPosition(table, player)
    for i, v in ipairs(table) do
        if v == player then
            return i
        end
    end
    return nil -- player was not found
end

-- if an alien catches a human, they respawn as an alien
local function onCatch(alienPlayer, humanPlayer)
    print(alienPlayer.Name .. " has caught " .. humanPlayer.Name)
    alienPlayer.leaderstats.AlienPoints.Value = alienPlayer.leaderstats.AlienPoints.Value + PointValues.EatHuman
    humanPlayer:FindFirstChild("isAlien").Value = true
    table.remove(PlayerTables.HumansPlaying, findPlayerPosition(PlayerTables.HumansPlaying, humanPlayer))
    table.insert(PlayerTables.Eaten, humanPlayer)
    table.insert(PlayerTables.AliensPlaying, humanPlayer)
    -- move player back to spawn point instead of loading
    humanPlayer.Character.HumanoidRootPart.CFrame = spawnLocation.CFrame + Vector3.new(0, 5, 0)
end

local function onTouched(otherPart)
    if not script.Parent.Parent.HumanoidRootPart.Anchored then
        local humanPlayer = Players:GetPlayerFromCharacter(otherPart.Parent)
        if humanPlayer and humanPlayer:FindFirstChild("isAlien") and not humanPlayer.isAlien.Value then
            -- check that player character is valid as well
            local alienPlayer = Players:GetPlayerFromCharacter(script.Parent.Parent)
            if alienPlayer then
                onCatch(alienPlayer, humanPlayer)
            end
        end
    end
end

local hitbox = script.Parent
hitbox.Touched:Connect(onTouched)