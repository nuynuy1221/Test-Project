repeat task.wait() until game:IsLoaded()
task.wait(1)

local targetPlace = 16146832113
if game.PlaceId ~= targetPlace then
    warn("PlaceId ไม่ตรง ไม่เข้าแมพให้")
    return
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local rep = game:GetService("ReplicatedStorage")
local playerGui = player:WaitForChild("PlayerGui", 10)

-- =========================
-- ฟังก์ชันดึงเลเวลจาก Attribute (เสถียรกว่า GUI)
-- =========================
local function getLevel()
    -- ชื่อ Attribute ที่น่าจะเป็น (เรียงจากน่าจะเจอมากที่สุด)
    local possibleLevelNames = {
        "Level",          -- ชื่อมาตรฐานที่สุด
        "PlayerLevel",
        "level",
        "playerLevel",
        "CurrentLevel"
    }
    
    for _, name in ipairs(possibleLevelNames) do
        local value = player:GetAttribute(name)
        if value ~= nil then
            local num = tonumber(value)
            if num then
                print("พบ Level จาก Attribute:", name, "=", num)  -- debug ว่าชื่อจริงคืออะไร
                return num
            end
        end
    end
    
    -- ถ้าไม่เจอเลย ให้ fallback ไปเช็ค GUI เดิม (หรือ return 0)
    warn("ไม่พบ Attribute Level — fallback ไปเช็ค GUI")
    local success, levelLabel = pcall(function()
        return playerGui:WaitForChild("HUD", 5)
                     :WaitForChild("Main", 5)
                     :WaitForChild("Level", 5)  -- หรือปรับ path ตามจริง
    end)
    
    if success and levelLabel and levelLabel:IsA("TextLabel") then
        local text = levelLabel.Text or ""
        local num = text:match("%d+")  -- ดึงตัวเลขแรก
        return tonumber(num) or 0
    end
    
    return 0  -- ถ้าไม่เจอทั้งคู่
end

-- =========================
-- ฟังก์ชันเข้าสู่แมทช์ Story
-- =========================
local function startMatch()
    print("📌 Level ต่ำกว่า 11 → เข้าด่าน Story อัตโนมัติ")
    
    local lobbyEvent = rep:WaitForChild("Networking"):WaitForChild("LobbyEvent")
    
    local addMatchArgs = {
        "AddMatch",
        {
            ["Difficulty"] = "Normal",
            ["Act"] = "Act1",
            ["StageType"] = "Story",
            ["Stage"] = "Stage1",
            ["FriendsOnly"] = false
        }
    }
    pcall(function() lobbyEvent:FireServer(unpack(addMatchArgs)) end)
    task.wait(3)
    
    pcall(function() lobbyEvent:FireServer("StartMatch") end)
    print("🚀 ด่าน Story เริ่มแล้ว")
end

-- =========================
-- ฟังก์ชัน WinterEvent
-- =========================
local function GoWinter()
    print("🔥 Level ≥ 11 → WinterEvent")
    
    local winterEvent = rep:WaitForChild("Networking"):WaitForChild("Winter"):WaitForChild("WinterLTMEvent")
    local lobbyEvent = rep:WaitForChild("Networking"):WaitForChild("LobbyEvent")
    
    pcall(function() winterEvent:FireServer("Create", "Infinite") end)
    task.wait(3)
    pcall(function() lobbyEvent:FireServer("StartMatch") end)
end

-- =========================
-- เช็ค Presents26 (ทำให้ง่ายขึ้น)
-- =========================
local function getPresents26()
    local value = player:GetAttribute("Presents26")
    if value ~= nil then
        return tonumber(value) or 0
    end
    return 0
end

-- =========================
-- เช็ค Ice Queen (Release)
-- =========================
local function hasIceQueen()
    local success, cache = pcall(function()
        return playerGui:WaitForChild("Windows", 8)
                     :WaitForChild("GlobalInventory", 8)
                     .Holder.LeftContainer.FakeScrollingFrame.Items.CacheContainer
    end)
    
    if not success or not cache then
        warn("ไม่เจอ Inventory Cache — ลองเปิด Inventory ก่อน")
        return false
    end
    
    for _, item in ipairs(cache:GetChildren()) do
        local unitName = item:FindFirstChild("Container", true) 
                      and item.Container:FindFirstChild("Holder", true)
                      and item.Container.Holder:FindFirstChild("Main", true)
                      and item.Container.Holder.Main:FindFirstChild("UnitName")
        if unitName and unitName.Text and unitName.Text:find("Ice Queen %(Release%)") then
            return true
        end
    end
    return false
end

-- =========================
-- Summon Event
-- =========================
local summonEvent = rep:WaitForChild("Networking"):WaitForChild("Units"):WaitForChild("SummonEvent")
local summonArgs = {"SummonMany", "Winter26", 10}

-- =========================
-- ลูปหลัก (เพิ่ม pcall ห่อเพื่อป้องกัน crash)
-- =========================
while true do
    local success, err = pcall(function()
        local level = getLevel()
        local presents = getPresents26()
        
        print("Level:", level, "| Presents26:", presents, "| มี Ice Queen:", hasIceQueen())
        
        if level < 11 then
            startMatch()
        else
            if hasIceQueen() then
                print("✅ มี Ice Queen (Release) → เริ่ม Winter")
                GoWinter()
            else
                if presents >= 1500 then
                    print("Summon Winter26 x10")
                    summonEvent:FireServer(unpack(summonArgs))
                    task.wait(2)  -- รอ summon เสร็จ
                else
                    print("Presents26 ไม่พอ → เริ่ม Winter")
                    GoWinter()
                end
            end
        end
    end)
    
    if not success then
        warn("Error ใน loop:", err)
    end
    
    task.wait(1.5)  -- ป้องกัน spam เร็วเกิน
end
