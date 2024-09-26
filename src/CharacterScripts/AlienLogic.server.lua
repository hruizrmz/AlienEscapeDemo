local Players = game:GetService("Players")

-- if an alien catches a human, they respawn as an alien
local function onCatch(alienPlayer, humanPlayer)
    print(alienPlayer.Name .. " has caught " .. humanPlayer.Name)
    if humanPlayer.Character then
        humanPlayer.Character:Destroy()
    end
    humanPlayer:FindFirstChild("isAlien").Value = true
    humanPlayer:LoadCharacter()
    -- You can add more game logic here, like removing the human from the game or scoring points
end

local function onTouched(otherPart)
    local humanPlayer = Players:GetPlayerFromCharacter(otherPart.Parent)
    if humanPlayer and humanPlayer:FindFirstChild("isAlien") and not humanPlayer.isAlien.Value then
        -- check that player character is valid as well
        local alienPlayer = Players:GetPlayerFromCharacter(script.Parent)
        if alienPlayer then
            onCatch(alienPlayer, humanPlayer)
        end
    end
end

local humanoidRootPart = script.Parent:WaitForChild("HumanoidRootPart")
if humanoidRootPart then
    humanoidRootPart.Touched:Connect(onTouched)
end