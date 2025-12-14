repeat task.wait() until game:IsLoaded()
task.wait(1)

local targetPlace = 16146832113
if game.PlaceId ~= targetPlace then
    warn("PlaceId ไม่ตรง — ไม่รัน Fuse")
    return
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FuseEvent = ReplicatedStorage:WaitForChild("Networking"):WaitForChild("Units"):WaitForChild("FuseEvent")
local SummonEvent = ReplicatedStorage:WaitForChild("Networking"):WaitForChild("Units"):WaitForChild("SummonEvent")

-- ชื่อตัวละครหลักที่จะอัปเลเวล
local targetName = "Ackers"

-- =========================
-- ฟังก์ชันดึงตัวหลักโดยหา GUID จากชื่อ
-- =========================
local function getMainUnit()
    local ok, cacheContainer = pcall(function()
        local windows = playerGui:FindFirstChild("Windows")
        local globalInventory = windows and windows:FindFirstChild("GlobalInventory")
        local holder = globalInventory and globalInventory:FindFirstChild("Holder")
        local leftContainer = holder and holder:FindFirstChild("LeftContainer")
        local fakeScroll = leftContainer and leftContainer:FindFirstChild("FakeScrollingFrame")
        local items = fakeScroll and fakeScroll:FindFirstChild("Items")
        local cache = items and items:FindFirstChild("CacheContainer")
        return cache and cache:GetChildren() or {}
    end)
    if not ok or not cacheContainer then return nil end

    for _, item in ipairs(cacheContainer) do
        local ok2, unitNameObj = pcall(function()
            return item.Container.Holder.Main.UnitName
        end)
        if ok2 and unitNameObj and unitNameObj.Text == targetName then
            return item
        end
    end
    return nil
end

-- =========================
-- ฟังก์ชันดึง Level ของตัวหลัก
-- =========================
local function getUnitLevel(item)
    local ok, levelObj = pcall(function()
        return item.Container.Holder.Main.LevelFrame.Level
    end)
    if ok and levelObj and levelObj.Text then
        local str = tostring(levelObj.Text):gsub("[^%d]", "")
        return tonumber(str) or 0
    end
    return 0
end

-- =========================
-- ฟังก์ชันดึงตัวละครตาม Rank
-- =========================
local function getUnitsByRank(rank)
    local units = {}
    local ok, cacheContainer = pcall(function()
        local windows = playerGui:FindFirstChild("Windows")
        local globalInventory = windows and windows:FindFirstChild("GlobalInventory")
        local holder = globalInventory and globalInventory:FindFirstChild("Holder")
        local leftContainer = holder and holder:FindFirstChild("LeftContainer")
        local fakeScroll = leftContainer and leftContainer:FindFirstChild("FakeScrollingFrame")
        local items = fakeScroll and fakeScroll:FindFirstChild("Items")
        local cache = items and items:FindFirstChild("CacheContainer")
        return cache and cache:GetChildren() or {}
    end)
    if not ok or not cacheContainer then return units end

    for _, item in ipairs(cacheContainer) do
        local ok2, glow = pcall(function()
            return item.Container:FindFirstChild("Glow") and item.Container.Glow:FindFirstChild(rank)
        end)
        if ok2 and glow then
            local ok3, unitNameObj = pcall(function()
                return item.Container.Holder.Main.UnitName
            end)
            if ok3 and unitNameObj then
                table.insert(units, {Item = item, Name = item.Name, UnitName = unitNameObj.Text})
            end
        end
    end
    return units
end

-- =========================
-- ฟังก์ชัน Summon ตัวละคร
-- =========================
local function summonSpecial()
    local SummonFuse = {
        [1] = "SummonMany",
        [2] = "Special",
        [3] = 5
    }
    SummonEvent:FireServer(unpack(SummonFuse))
    task.wait(1)
end

-- =========================
-- ฟังก์ชัน Fuse ตัวละคร
-- =========================
local function fuseUnits(mainUnit)
    for _, rank in ipairs({"Rare","Epic","Legendary"}) do
        local units = getUnitsByRank(rank)
        local subUnits = {}
        for _, u in ipairs(units) do
            if u.UnitName ~= targetName then
                table.insert(subUnits, u.Name)
            end
        end

        local subToUse = {}
        for i = 1, math.min(5, #subUnits) do
            table.insert(subToUse, subUnits[i])
        end

        if mainUnit and #subToUse > 0 then
            local args = {
                [1] = "Fuse",
                [2] = {
                    [1] = mainUnit.Name,
                    [2] = subToUse
                }
            }
            FuseEvent:FireServer(unpack(args))
            task.wait(0.5)
        end
    end
end

-- =========================
-- ลูปหลัก Auto Summon + Fuse + เช็ค Level
-- =========================
task.spawn(function()
    while true do
        local mainUnit = getMainUnit()
        if mainUnit then
            local level = getUnitLevel(mainUnit)
            if level < 30 then
                summonSpecial()
                fuseUnits(mainUnit)
            else
                break
            end
        end
        task.wait(1)
    end
end)
