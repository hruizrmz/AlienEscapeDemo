local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local SFX = ReplicatedStorage:WaitForChild("Sounds")
local BGM = ReplicatedStorage:WaitForChild("Music")
local CurrentSFX = Workspace:WaitForChild("SFX")
local CurrentBGM = Workspace:WaitForChild("BGM")

local SoundManager = {}

function SoundManager.PlaySFX(sfxName : string, volume : number)
    local sound = SFX[sfxName]:Clone()
    if sound then
        sound.Volume = volume
        sound.Parent = CurrentSFX
        sound:Play()
        task.wait(sound.TimeLength + 0.05)
        sound:Destroy()
    else
        warn("Did not find SFX to play!")
    end
end

function SoundManager.PlayBGM(bgmName : string, volume : number, timePos : number)
    local sound = BGM[bgmName]:Clone()
    if sound then
        sound.Volume = 0
        sound.Parent = CurrentBGM
        sound.TimePosition = timePos or 0
        sound:Play()
        while sound.Volume < volume do
            sound.Volume += 0.05
            task.wait(0.05)
        end
    else
        warn("Did not find BGM to play!")
    end
end

function SoundManager.StopBGM(bgmName : string)
    print(typeof(bgmName))
    local sound = CurrentBGM:FindFirstChild(bgmName)
    if sound then
        while sound.Volume > 0 do
            sound.Volume -= 0.05
            task.wait(0.05)
        end
        sound:Destroy()
    else
        warn("Did not find BGM to stop!")
    end
end

return SoundManager