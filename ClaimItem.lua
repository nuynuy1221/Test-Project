repeat task.wait() until game:IsLoaded()
task.wait(2)

--================ CONFIG =================--
local Config = getgenv().Config or {}

if Config.ClaimItem == false then
    warn("❌ ปิด ClaimItem จาก Config — ข้ามการรับของ")
    return
end
--========================================--

--================ PLACE CHECK =================--
local TARGET_PLACE = 16146832113
if game.PlaceId ~= TARGET_PLACE then
    warn("❌ PlaceId ไม่ตรง — ไม่รับของให้")
    return
end
--=============================================--

--================ SERVICES =================--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networking = ReplicatedStorage:WaitForChild("Networking")

local DailyRewardEvent     = Networking:WaitForChild("DailyRewardEvent")
local MilestonesEvent      = Networking:WaitForChild("Milestones"):WaitForChild("MilestonesEvent")
local QuestEvent           = Networking:WaitForChild("Quests"):WaitForChild("ClaimQuest")
local BattlepassEvent      = Networking:WaitForChild("BattlepassEvent")
local ReturningPlayerEvent = Networking:WaitForChild("ReturningPlayerEvent")
--============================================--

local DELAY = 0.3

local function safeFire(remote, args)
    local ok, err = pcall(function()
        remote:FireServer(unpack(args))
    end)

    if not ok then
        warn("❌ FireServer ล้มเหลว:", err)
    end

    task.wait(DELAY)
end

--================ DAILY REWARD =================--
local dailyRewards = {
    {"Special", 2},
    {"Special", 4},
    {"Special", 7},
    {"Fall",    7},
}

for _, reward in ipairs(dailyRewards) do
    safeFire(DailyRewardEvent, {
        "Claim",
        reward
    })
end

--================ MILESTONES =================--
for _, milestone in ipairs({5, 10}) do
    safeFire(MilestonesEvent, {
        "Claim",
        milestone
    })
end

--================ QUESTS =================--
safeFire(QuestEvent, {
    "ClaimAll"
})

--================ BATTLEPASS =================--
safeFire(BattlepassEvent, {
    "ClaimAll"
})

--================ RETURNING PLAYER =================--
for day = 1, 7 do
    safeFire(ReturningPlayerEvent, {
        "Claim",
        day
    })
end

print("✅ ClaimItem: รับของทั้งหมดเสร็จเรียบร้อย")
