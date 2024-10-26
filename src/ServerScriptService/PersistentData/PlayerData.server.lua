local Players = game:GetService("Players")
local playerData = game:GetService("ServerStorage"):WaitForChild("PlayerData")

local HUMAN_SPEED = 40
local HUMAN_JUMP_POWER = 35
local ALIEN_SPEED = 48

local function playerSettings(player)
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

local function instancePlayer(player)
    for i, instance in pairs(playerData:GetChildren()) do -- pairs iterates through unknown key-value pairs in a table
        local clonedInstance = instance:Clone()
        clonedInstance.Parent = player -- clones every child found in playerData, and moves it into the player joining the game
    end
end

Players.PlayerAdded:Connect(function(player)
    instancePlayer(player)
    playerSettings(player)
end)