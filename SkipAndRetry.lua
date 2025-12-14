repeat task.wait() until game:IsLoaded()
task.wait(2)

--== เช็ค PlaceId ก่อนรัน ==--
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
    pcall(function()
        Networking:WaitForChild("SkipWaveEvent"):FireServer("Skip")
    end)
end

-- =========================
-- ฟังก์ชัน Vote Retry
-- =========================
local function pressRetryButton()
    pcall(function()
        Networking
            :WaitForChild("EndScreen")
            :WaitForChild("VoteEvent")
            :FireServer("Retry")
    end)
end

-- =========================
-- ฟังก์ชัน Vote MatchRestart
-- =========================
local function voteMatchRestart()
    pcall(function()
        Networking
            :WaitForChild("MatchRestartSettingEvent")
            :FireServer("Vote")
    end)
end

-- =========================
-- Loop ทุก 2 วินาที
-- =========================
task.spawn(function()
    while true do
        task.wait(2)
        pressSkipButton()
    end
end)

task.spawn(function()
    while true do
        task.wait(15)
        pressRetryButton()
        voteMatchRestart()
    end
end)
