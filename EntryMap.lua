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

-- ฟังก์ชันเข้า FallEvent
local function GoLich()
    print("🔥 Level ≥ 11 → FallEvent")

    local args = { "Create", "Infinite" }
    game:GetService("ReplicatedStorage").Networking.Fall.FallLTMEvent:FireServer(unpack(args))
    wait(3)
    local args2 = { "StartMatch" }
    game:GetService("ReplicatedStorage").Networking.LobbyEvent:FireServer(unpack(args2))
end

-- =========================
-- ฟังก์ชันเช็ค Leaves จาก Attribute
-- =========================
local function toNumber(str)
    if not str then return 0 end
    str = tostring(str):gsub("[^%d.]", "")
    local firstDot = str:find("%.")
    if firstDot then
        str = str:sub(1, firstDot) .. str:sub(firstDot+1):gsub("%.", "")
    end
    return tonumber(str) or 0
end

local function getLeaves()
    for _, attrName in ipairs({"Leaves","leaves","Leaf","leaf","LeavesAmount","LeavesEarned"}) do
        local v = player:GetAttribute(attrName)
        if v ~= nil then
            return tonumber(v) or toNumber(v)
        end
    end
    return 0
end

-- =========================
-- Events
-- =========================
local SummonEvent = ReplicatedStorage:WaitForChild("Networking"):WaitForChild("Units"):WaitForChild("SummonEvent")

-- =========================
-- Config
-- =========================

local Summons = {
    [1] = "SummonMany",
    [2] = "Fall",
    [3] = 10
}

-- ลูปหลัก
while true do
    local level = getLevel()

    if level >= 11 then
        if leaves >= 1500 then
            SummonEvent:FireServer(unpack(Summons))
            task.wait(1)
        else
            GoLich()
        end
    else
        startMatch()
    end

    -- รอให้ระบบรีอัพเดทก่อนเช็คใหม่
    task.wait(1)
end



