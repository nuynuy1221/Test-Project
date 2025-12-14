repeat task.wait() until game:IsLoaded()
task.wait(2)

local targetPlace = 16277809958
if game.PlaceId ~= targetPlace then
    return
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networking = ReplicatedStorage:WaitForChild("Networking")

-- =========================
-- ฟังก์ชัน Skip Wave
-- =========================
local function pressSkipButton()
    local args = {
        [1] = "Skip"
    }

    pcall(function()
        Networking:WaitForChild("SkipWaveEvent"):FireServer(unpack(args))
    end)
end

-- =========================
-- ฟังก์ชัน Vote Retry
-- =========================
local function pressRetryButton()
    local args = {
        [1] = "Retry"
    }

    pcall(function()
        Networking:WaitForChild("EndScreen"):WaitForChild("VoteEvent"):FireServer(unpack(args))
    end)
end

-- =========================
-- Loop ทุก 2 วินาที
-- =========================
task.spawn(function()
    while true do
        task.wait(2)
        pressSkipButton()
        pressRetryButton()
    end
end)
