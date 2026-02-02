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

-- ชื่อตัวละครหลักที่จะอัปเลเวล (เพิ่มได้หลายตัว)
local targetNames = {"Ackers", "Bounty Hunter"}  -- เพิ่มชื่ออื่น ๆ ที่ต้องการอัพ

-- =========================
-- ฟังก์ชันดึง CacheContainer
-- =========================
local function getCacheContainer()
    local ok, cache = pcall(function()
        local windows = playerGui:WaitForChild("Windows", 10)
        local globalInventory = windows:WaitForChild("GlobalInventory", 10)
        local holder = globalInventory.Holder
        local leftContainer = holder.LeftContainer
        local fakeScroll = leftContainer.FakeScrollingFrame
        local items = fakeScroll.Items
        local cache = items.CacheContainer
        return cache
    end)
    return ok and cache or nil
end

-- =========================
-- ฟังก์ชันดึงตัวหลักโดยหา GUID จากชื่อ (รองรับหลายตัว)
-- =========================
local function getMainUnits()
    local cache = getCacheContainer()
    if not cache then return {} end
    
    local mainUnits = {}
    
    for _, name in ipairs(targetNames) do
        for _, item in ipairs(cache:GetChildren()) do
            local ok, unitNameObj = pcall(function()
                return item:FindFirstChild("Container") and item.Container:FindFirstChild("Holder") and item.Container.Holder:FindFirstChild("Main") and item.Container.Holder.Main:FindFirstChild("UnitName")
            end)
            if ok and unitNameObj and unitNameObj.Text and unitNameObj.Text:find(name) then
                table.insert(mainUnits, {Item = item, Name = name})
                break  -- หาเจอตัวนี้แล้ว ข้ามไปตัวถัดไป
            end
        end
    end
    
    return mainUnits
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
    local cache = getCacheContainer()
    if not cache then return units end

    for _, item in ipairs(cache:GetChildren()) do
        local ok, glowRank = pcall(function()
            return item.Container:FindFirstChild("Glow") and item.Container.Glow:FindFirstChild(rank)
        end)
        if ok and glowRank then
            local ok2, unitNameObj = pcall(function()
                return item.Container.Holder.Main.UnitName
            end)
            if ok2 and unitNameObj then
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
    task.wait(0.1)
end

-- =========================
-- ฟังก์ชัน Fuse ตัวละคร (สำหรับตัวหลักแต่ละตัว)
-- =========================
local function fuseUnits(mainUnitItem, targetName)
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

        if mainUnitItem and #subToUse > 0 then
            local args = {
                [1] = "Fuse",
                [2] = {
                    [1] = mainUnitItem.Name,
                    [2] = subToUse
                }
            }
            FuseEvent:FireServer(unpack(args))
            task.wait(0.1)
        end
    end
end

-- =========================
-- ลูปหลัก Auto Summon + Fuse + เช็ค Level
-- =========================
task.spawn(function()
    while true do
        local mainUnits = getMainUnits()
        if #mainUnits == 0 then
            print("ไม่พบตัวหลักใด ๆ ใน Inventory")
            task.wait(0.1)
            continue
        end
        
        local allAbove30 = true
        
        for _, main in ipairs(mainUnits) do
            local level = getUnitLevel(main.Item)
            if level < 30 then
                allAbove30 = false
                summonSpecial()
                fuseUnits(main.Item, main.Name)
            end
        end
        
        if allAbove30 then
            print("ตัวหลักทั้งหมดถึง Level 30 แล้ว — หยุด Fuse")
            break
        end
        
        task.wait(0.1)
    end
end)
