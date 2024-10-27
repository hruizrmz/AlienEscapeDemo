local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local GameData = game:GetService("ServerStorage"):WaitForChild("GameData")
local PlayerTables = require(GameData:WaitForChild("PlayerTables"))
local PointValues = require(GameData:WaitForChild("PointValues"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function findPlayerPosition(humansPlaying : table, player)
    for i, v in ipairs(humansPlaying) do
        if v == player then
            return i
        end
    end
    warn("Player was not found in Player Tables!")
    return nil
end

local function onTouched(otherPart, door : Object)
    if not door:FindFirstChild("Occupied").Value then
        local player = Players:GetPlayerFromCharacter(otherPart.Parent)
        if player and not player:FindFirstChild("isAlien").Value then
            door.Occupied.Value = true
            door.Material = "DiamondPlate"
            door.BrickColor = BrickColor.new("Maroon")
            door.Transparency = 0.2
            door.CollisionGroup = "Default"
            ------
            player.leaderstats.HumanPoints.Value = player.leaderstats.HumanPoints.Value + PointValues.EscapeShip
            table.remove(PlayerTables.HumansPlaying, findPlayerPosition(PlayerTables.HumansPlaying, player))
            table.insert(PlayerTables.Escaped, player)
            ReplicatedStorage.Remotes.ShowSpectateUI:FireClient(player)
            ------
            local character = player.Character
            local seat = door:FindFirstChild("PodSeat")
            character:MoveTo(seat.Position)
            player.Character.Humanoid.JumpPower = 0
        end
    end
end

for i, door in pairs(CollectionService:GetTagged("EscapePodDoor")) do
    door.Touched:Connect(function(otherPart)
        onTouched(otherPart, door)
    end)
end

