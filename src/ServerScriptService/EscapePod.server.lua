local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local PlayerTables = require(game:GetService("ServerScriptService").PlayerTables)
local PointValues = require(game:GetService("ServerScriptService").PointValues)

local function findPlayerPosition(table, player)
    for i, v in ipairs(table) do
        if v == player then
            return i
        end
    end
    return nil -- player was not found
end

local function onTouched(otherPart, door)
    if not door:FindFirstChild("Occupied").Value then
        local player = Players:GetPlayerFromCharacter(otherPart.Parent)
        if player and not player:FindFirstChild("isAlien").Value then
            door.Occupied.Value = true
            task.wait(0.1)
            door.Material = "DiamondPlate"
            door.BrickColor = BrickColor.new("Maroon")
            door.Transparency = 0.2
            door.CollisionGroup = "Default"
            player.Character.Humanoid.JumpPower = 0
            ------
            player.leaderstats.HumanPoints.Value = player.leaderstats.HumanPoints.Value + PointValues.EscapeShip
            table.remove(PlayerTables.HumansPlaying, findPlayerPosition(PlayerTables.HumansPlaying, player))
            table.insert(PlayerTables.Escaped, player)
        end
    end
end

for i, door in pairs(CollectionService:GetTagged("EscapePodDoor")) do
    door.Touched:Connect(function(otherPart)
        onTouched(otherPart, door)
    end)
end

