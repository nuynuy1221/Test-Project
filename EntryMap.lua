repeat task.wait() until game:IsLoaded()
task.wait(1)

repeat task.wait() until game:IsLoaded()
local targetPlace = 16146832113
if game.PlaceId ~= targetPlace then
    warn("PlaceId ไม่ตรง ไม่เข้าแมพให้")
    return
end

local player = game:GetService("Players").LocalPlayer
local rep = game:GetService("ReplicatedStorage")

-- Reference จุดที่มีข้อมูลเลเวล
local levelLabel = player.PlayerGui.HUD.Main.Level:WaitForChild("Level")

-- ฟังก์ชันดึงเลเวลจากข้อความ เช่น "Level 6 (0/300)"
local function getLevel()
    local text = levelLabel.Text or ""
    local number = string.match(text, "Level%s+(%d+)")
    return tonumber(number) or 0
end

-- ฟังก์ชันเข้าสู่แมทช์
local function startMatch()
    print("📌 Level ต่ำกว่า 11 → เข้าด่าน Story อัตโนมัติ")

    -- AddMatch
    local args1 = {
        [1] = "AddMatch",
        [2] = {
            ["Difficulty"] = "Normal",
            ["Act"] = "Act1",
            ["StageType"] = "Story",
            ["Stage"] = "Stage1",
            ["FriendsOnly"] = false
        }
    }
    rep.Networking.LobbyEvent:FireServer(unpack(args1))

    task.wait(3)

    -- StartMatch
    local args2 = {
        [1] = "StartMatch"
    }
    rep.Networking.LobbyEvent:FireServer(unpack(args2))

    print("🚀 ด่านเริ่มต้นแล้ว")
end

-- ฟังก์ชันเข้า AFK
local function GoLich()
    print("🔥 Level ≥ 11 → FallEvent")

    local args = { "Create", "Infinite" }
    game:GetService("ReplicatedStorage").Networking.Fall.FallLTMEvent:FireServer(unpack(args))
    wait(3)
    local args2 = { "StartMatch" }
    game:GetService("ReplicatedStorage").Networking.LobbyEvent:FireServer(unpack(args2))
end

-- ลูปหลัก
while true do
    local level = getLevel()
    print("Player Level:", level)

    if level >= 11 then
        GoLich()
    else
        startMatch()
    end

    -- รอให้ระบบรีอัพเดทก่อนเช็คใหม่
    task.wait(10)
end


