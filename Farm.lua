repeat task.wait() until game:IsLoaded()
task.wait(1.5)

-- เช็ค PlaceId
local targetPlace = 16277809958
if game.PlaceId ~= targetPlace then
    warn("ผิดแมพ! ต้องอยู่ในแมพฟาร์มเท่านั้น")
    return
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local Networking = RS:WaitForChild("Networking", 10)
local UnitEvent = Networking:WaitForChild("UnitEvent", 8)
local TeleportEvent = Networking:WaitForChild("TeleportEvent", 8)
local playerGui = player:WaitForChild("PlayerGui", 10)

if not UnitEvent then
    warn("ไม่เจอ UnitEvent → เกมอาจอัปเดตแล้ว")
    return
end

-- =========================
-- Settings
-- =========================
local CONFIG = {
    UNIT_NAME = "Ackers",
    UNIT_ID = 241,
    
    STOP_LEVEL = 11,
    STOP_LEAVES = 45000,
    
    NORMAL_POSITIONS = {
        Vector3.new(445.17132568359375, 2.29998779296875, -342.4508056640625),
        Vector3.new(445.14013671875, 2.29998779296875, -346.05340576171875),
        Vector3.new(445.0626220703125, 2.29998779296875, -344.2766418457031)
    },
    
    FALL_POSITIONS = {
        Vector3.new(354.797, 48.49, -166.937),
        Vector3.new(353.004, 48.49, -166.919),
        Vector3.new(351.165, 48.49, -166.960)
    },
    
    PLACE_DELAY = 0.42,
    CYCLE_DELAY = 1.6,
    UPGRADE_DELAY = 0.65,
    SLOT_INDEX = 1
}

-- สลับจุดแยกแมพ
local normalIndex = 1
local fallIndex = 1

local function getOffsetPosition(basePos)
    local offsetX = math.random(-10, 10) / 10
    local offsetZ = math.random(-10, 10) / 10
    return basePos + Vector3.new(offsetX, 0, offsetZ)
end

-- Safe FireServer (ไม่มี unpack ใน level นี้)
local function placeUnit(pos)
    local renderTable = { CONFIG.UNIT_NAME, CONFIG.UNIT_ID, pos, 0 }
    local slotTable = { SlotIndex = CONFIG.SLOT_INDEX }
    
    pcall(function()
        UnitEvent:FireServer("Render", renderTable, slotTable)
    end)
end

local function getCurrentStageAct()
    local stageText = ""
    pcall(function()
        local guides = playerGui.Guides
        if guides then
            local list = guides.List
            if list then
                local stageInfo = list.StageInfo
                if stageInfo then
                    local stageFrame = stageInfo.StageFrame
                    if stageFrame then
                        local stageAct = stageFrame.StageAct
                        if stageAct and stageAct.Text then
                            stageText = stageAct.Text
                        end
                    end
                end
            end
        end
    end)
    return stageText
end

-- ระบบหยุด
local stopScript = false

task.spawn(function()
    while true do
        task.wait(1.5)
        
        local level = player:GetAttribute("Level") or 0
        local leaves = player:GetAttribute("Leaves") or 0
        local stage = getCurrentStageAct()
        
        if level >= CONFIG.STOP_LEVEL then
            if (stage == "Fall — Infinite" and leaves >= CONFIG.STOP_LEAVES) 
            or (stage ~= "" and stage ~= "Fall — Infinite") then
                if not stopScript then
                    stopScript = true
                    warn("หยุดฟาร์มแล้ว → Teleport ใน 4 วินาที")
                    task.delay(4, function()
                        if TeleportEvent then TeleportEvent:FireServer("Lobby") end
                    end)
                end
            else
                stopScript = false
            end
        else
            stopScript = false
        end
    end
end)

-- วางตัว (แก้ error โดยไม่ใช้ unpack เลย)
task.spawn(function()
    while true do
        if stopScript then
            task.wait(3)
            continue
        end
        
        local stage = getCurrentStageAct()
        local positions = (stage == "Fall — Infinite") and CONFIG.FALL_POSITIONS or CONFIG.NORMAL_POSITIONS
        
        local index = (stage == "Fall — Infinite") and fallIndex or normalIndex
        
        local basePos = positions[index]
        local pos = getOffsetPosition(basePos)
        
        placeUnit(pos)  -- เรียกฟังก์ชัน safe ที่ไม่มี error
        
        task.wait(CONFIG.PLACE_DELAY)
        
        -- สลับ index
        if stage == "Fall — Infinite" then
            fallIndex = (fallIndex % #CONFIG.FALL_POSITIONS) + 1
        else
            normalIndex = (normalIndex % #CONFIG.NORMAL_POSITIONS) + 1
        end
        
        task.wait(CONFIG.CYCLE_DELAY)
    end
end)

-- Auto Upgrade
task.spawn(function()
    while true do
        if not stopScript then
            pcall(function()
                local units = workspace:FindFirstChild("Units")
                if units then
                    for _, unit in ipairs(units:GetChildren()) do
                        if unit:IsA("Model") then
                            pcall(function()
                                UnitEvent:FireServer("Upgrade", unit.Name)
                            end)
                            task.wait(CONFIG.UPGRADE_DELAY)
                        end
                    end
                end
            end)
        end
        task.wait(1.3)
    end
end)

print("✅ Auto Farm Script")
