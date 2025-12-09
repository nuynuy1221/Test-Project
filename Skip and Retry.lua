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
    task.wait(30) -- รอ 30 วิแล้วลูปใหม่
end
