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
    STOP_PRESENTS26 = 45000,
    
    NORMAL_POSITIONS = {
        Vector3.new(445.17132568359375, 2.29998779296875, -342.4508056640625),
        Vector3.new(445.14013671875, 2.29998779296875, -346.05340576171875),
        Vector3.new(445.0626220703125, 2.29998779296875, -344.2766418457031)
    },
    
    WINTER_POSITIONS = {
        Vector3.new(-277.788330078125, 251.36184692382812, 97.78836059570312),
        Vector3.new(-275.8544921875, 251.36184692382812, 97.96082305908203),
        Vector3.new(-273.71441650390625, 251.36184692382812, 97.8721694946289)
    },
    
    PLACE_DELAY = 0.42,
    CYCLE_DELAY = 1.6,
    UPGRADE_DELAY = 0.65,
    SLOT_INDEX = 1
}

-- สลับจุดแยกแมพ
local normalIndex = 1
local winterIndex = 1

local function getOffsetPosition(basePos)
    local offsetX = math.random(-10, 10) / 10
    local offsetZ = math.random(-10, 10) / 10
    return basePos + Vector3.new(offsetX, 0, offsetZ)
end

-- Safe FireServer
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
        local guides = playerGui:FindFirstChild("Guides")
        if guides then
            local list = guides:FindFirstChild("List")
            if list then
                local stageInfo = list:FindFirstChild("StageInfo")
                if stageInfo then
                    local stageFrame = stageInfo:FindFirstChild("StageFrame")
                    if stageFrame then
                        local stageAct = stageFrame:FindFirstChild("StageAct")
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

-- ฟังก์ชันเช็คว่ามี Ice Queen (Release) ใน inventory หรือไม่
local function hasIceQueen()
    local hasQueen = false
    
    pcall(function()
        local windows = playerGui:FindFirstChild("Windows")
        if windows then
            local units = windows:FindFirstChild("Units")
            if units then
                local holder = units:FindFirstChild("Holder")
                if holder then
                    local main = holder:FindFirstChild("Main")
                    if main then
                        local unitsFolder = main:FindFirstChild("Units")
                        if unitsFolder then
                            for _, frame in ipairs(unitsFolder:GetChildren()) do
                                local nameLabel = frame:FindFirstChild("Container", true)
                                    and frame.Container:FindFirstChild("Holder", true)
                                    and frame.Container.Holder:FindFirstChild("Main", true)
                                    and frame.Container.Holder.Main:FindFirstChild("UnitName")
                                
                                if nameLabel and nameLabel.Text and nameLabel.Text:find("Ice Queen (Release)") then
                                    hasQueen = true
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    
    return hasQueen
end

-- ระบบหยุด / วาร์ปกลับ Lobby
local stopScript = false

task.spawn(function()
    while true do
        task.wait(2)
        
        local level = player:GetAttribute("Level") or 0
        local Presents26 = player:GetAttribute("Presents26") or 0
        local stage = getCurrentStageAct()
        local hasQueen = hasIceQueen()
        
        -- ด่านปกติ → ถึงเลเวล 11 ให้วาร์ปกลับทันที
        if stage ~= "Winter — Infinite" then
            if level >= CONFIG.STOP_LEVEL then
                if not stopScript then
                    stopScript = true
                    warn("ด่านปกติ - ถึงเลเวล " .. level .. " → Teleport Lobby ใน 4 วินาที")
                    task.delay(4, function()
                        if TeleportEvent then TeleportEvent:FireServer("Lobby") end
                    end)
                end
            else
                stopScript = false
            end
            
        -- ด่าน Winter — Infinite
        else
            if hasQueen then
                -- มี Ice Queen (Release) แล้ว → ฟาร์มต่อไปเรื่อย ๆ ไม่ต้องหยุด ไม่วาร์ป
                stopScript = false
            else
                -- ยังไม่มี Ice Queen (Release) → ฟาร์มจน Presents26 ครบ แล้ววาร์ป
                if Presents26 >= CONFIG.STOP_PRESENTS26 then
                    if not stopScript then
                        stopScript = true
                        warn("Winter Infinite - Presents26 ถึง " .. Presents26 .. " (ยังไม่มี Ice Queen (Release)) → Teleport Lobby ใน 4 วินาที")
                        task.delay(4, function()
                            if TeleportEvent then TeleportEvent:FireServer("Lobby") end
                        end)
                    end
                else
                    stopScript = false
                end
            end
        end
    end
end)

-- วางตัว
task.spawn(function()
    while true do
        if stopScript then
            task.wait(3)
            continue
        end
        
        local stage = getCurrentStageAct()
        local positions = (stage == "Winter — Infinite") and CONFIG.WINTER_POSITIONS or CONFIG.NORMAL_POSITIONS
        
        local index = (stage == "Winter — Infinite") and winterIndex or normalIndex
        
        local basePos = positions[index]
        local pos = getOffsetPosition(basePos)
        
        placeUnit(pos)
        
        task.wait(CONFIG.PLACE_DELAY)
        
        -- สลับจุด
        if stage == "Winter — Infinite" then
            winterIndex = (winterIndex % #CONFIG.WINTER_POSITIONS) + 1
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
