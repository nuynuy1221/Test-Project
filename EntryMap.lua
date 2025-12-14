repeat task.wait() until game:IsLoaded()
task.wait(1)

local targetPlace = 16146832113
if game.PlaceId ~= targetPlace then
    warn("PlaceId ไม่ตรง ไม่เข้าแมพให้")
    return
end

local player = game:GetService("Players").LocalPlayer
local rep = game:GetService("ReplicatedStorage")
local playerGui = player:WaitForChild("PlayerGui")

-- =========================
-- ฟังก์ชันดึงเลเวลจาก GUI
-- =========================
local function getLevel()
    local levelLabel = player.PlayerGui.HUD.Main.Level:WaitForChild("Level")
    local text = levelLabel.Text or ""
    local number = string.match(text, "Level%s+(%d+)")
    return tonumber(number) or 0
end

-- =========================
-- ฟังก์ชันเข้าสู่แมทช์ Story
-- =========================
local function startMatch()
    print("📌 Level ต่ำกว่า 11 → เข้าด่าน Story อัตโนมัติ")

    -- AddMatch
    local Namek1 = {
        [1] = "AddMatch",
        [2] = {
            ["Difficulty"] = "Normal",
            ["Act"] = "Act1",
            ["StageType"] = "Story",
            ["Stage"] = "Stage1",
            ["FriendsOnly"] = false
        }
    }
    rep.Networking.LobbyEvent:FireServer(unpack(Namek1))
    task.wait(3)

    -- StartMatch
    local Namek2 = { [1] = "StartMatch" }
    rep.Networking.LobbyEvent:FireServer(unpack(Namek2))

    print("🚀 ด่านเริ่มต้นแล้ว")
end

-- =========================
-- ฟังก์ชัน FallEvent / Lich
-- =========================
local function GoLich()
    print("🔥 Level ≥ 11 → FallEvent")

    local args = {"Create", "Infinite"}
    rep.Networking.Fall.FallLTMEvent:FireServer(unpack(args))
    task.wait(3)
    local args2 = {"StartMatch"}
    rep.Networking.LobbyEvent:FireServer(unpack(args2))
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
-- ฟังก์ชันเช็ค Lich King (ไม่สน GUID)
-- =========================
local function hasLichKing()
    local ok, itemsFolder = pcall(function()
        local folder = playerGui:FindFirstChild("Windows") and
                       playerGui.Windows:FindFirstChild("GlobalInventory") and
                       playerGui.Windows.GlobalInventory:FindFirstChild("Holder") and
                       playerGui.Windows.GlobalInventory.Holder:FindFirstChild("LeftContainer") and
                       playerGui.Windows.GlobalInventory.Holder.LeftContainer:FindFirstChild("FakeScrollingFrame") and
                       playerGui.Windows.GlobalInventory.Holder.LeftContainer.FakeScrollingFrame:FindFirstChild("Items") and
                       playerGui.Windows.GlobalInventory.Holder.LeftContainer.FakeScrollingFrame.Items:FindFirstChild("CacheContainer")
        return folder and folder:GetChildren() or {}
    end)

    if ok and itemsFolder then
        for _, item in ipairs(itemsFolder) do
            local unitNameObj = item:FindFirstChild("Container") and
                                item.Container:FindFirstChild("Holder") and
                                item.Container.Holder:FindFirstChild("Main") and
                                item.Container.Holder.Main:FindFirstChild("UnitName")
            if unitNameObj and unitNameObj.Text:match("Lich King") then
                return true
            end
        end
    end
    return false
end

-- =========================
-- Event
-- =========================
local SummonEvent = rep:WaitForChild("Networking"):WaitForChild("Units"):WaitForChild("SummonEvent")
local Summons = { [1]="SummonMany", [2]="Fall", [3]=10 }

-- =========================
-- ลูปหลัก
-- =========================
while true do
    local level = getLevel()
    local leaves = getLeaves()

    if level >= 11 then
        if leaves >= 1500 then
            SummonEvent:FireServer(unpack(Summons))
            task.wait(1)
        else
            if hasLichKing() then
                print("⚠️ เจอ Lich King (Ruler) → รอ 60 วินาที")
                task.wait(180)
            end
            GoLich() -- เรียก FallEvent หลังจากรอถ้าเจอ Lich King
        end
    else
        startMatch()
    end

    task.wait(1)
end

