local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local alienModel = ServerStorage:WaitForChild("Alien")

local ALIEN_RESPAWN_BUFFER = 4

local function onTouched(otherPart) -- when player respawns, check if their model has to be changed or not
    local alien = alienModel:Clone()
    local alienHRP = alien:WaitForChild("HumanoidRootPart")
    local humanPlayer = Players:GetPlayerFromCharacter(otherPart.Parent)
    if humanPlayer and not humanPlayer:FindFirstChild("modelChanged").Value and humanPlayer:FindFirstChild("isAlien").Value then
        alienHRP.CFrame = humanPlayer.Character:WaitForChild("HumanoidRootPart").CFrame
        alien.Name = humanPlayer.Name
        humanPlayer.Character = alien
        alien.Parent = Workspace
        humanPlayer.modelChanged.Value = true

        humanPlayer.Character.HumanoidRootPart.Anchored = true -- anchor aliens temporarily to give humans an advantage
        task.wait(ALIEN_RESPAWN_BUFFER+2)
        humanPlayer.Character.HumanoidRootPart.Anchored = false
    end
end

local hitbox = script.Parent
hitbox.Touched:Connect(onTouched)