repeat task.wait() until game:IsLoaded()
task.wait(2)

repeat task.wait() until game:IsLoaded()
local targetPlace = 16277809958
if game.PlaceId ~= targetPlace then
    warn("PlaceId ไม่ตรง ไม่ Skip และ Retry ให้")
    return
end

task.spawn(function()
    while true do
        local args = {
            [1] = "Retry"
        }
            
        game:GetService("ReplicatedStorage")
            :WaitForChild("Networking")
            :WaitForChild("EndScreen")
            :WaitForChild("VoteEvent")
            :FireServer(unpack(args))
            
        wait(1)
            
        local args = {
            [1] = "Skip"
        }
            
        game:GetService("ReplicatedStorage"):WaitForChild("Networking"):WaitForChild("SkipWaveEvent"):FireServer(unpack(args))
        task.wait(5) -- รอ 30 วิแล้วลูปใหม่
    end
end)


