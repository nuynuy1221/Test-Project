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
local UNITS = {
    { Name = "Ackers", ID = 241 },
    { Name = "Bounty Hunter", ID = 347 }
}

local CURRENT_UNIT_INDEX = 1   -- ใช้สลับ Ackers ↔ Bounty Hunter ในทั้งสองชุด

local PHASE = 1   -- 1 = ชุด 1 (Low positions) | 2 = ชุด 2 (High positions)

local CONFIG = {
    STOP_LEVEL = 11,
    STOP_PRESENTS26 = 100000,
   
    NORMAL_POSITIONS = {
        Vector3.new(445.17132568359375, 2.29998779296875, -342.4508056640625),
        Vector3.new(445.14013671875, 2.29998779296875, -346.05340576171875),
        Vector3.new(445.0626220703125, 2.29998779296875, -344.2766418457031)
    },
   
    WINTER_POSITIONS_LOW = {   -- ชุด 1
        Vector3.new(-99.29846954345703, 252.38645935058594, 97.77344512939453),
        Vector3.new(-101.04096984863281, 252.38645935058594, 97.84931182861328),
        Vector3.new(-102.84765625, 252.38645935058594, 97.72704315185547),
        Vector3.new(-104.75141143798828, 252.38645935058594, 97.61274719238281),
        Vector3.new(-106.52127838134766, 252.58840942382812, 97.32903289794922),
        Vector3.new(-108.38831329345703, 252.38645935058594, 97.20975494384766),
        Vector3.new(-110.16625213623047, 252.38645935058594, 97.04420471191406)
    },
   
    WINTER_POSITIONS_HIGH = {   -- ชุด 2
        Vector3.new(-204.57949829101562, 251.7419891357422, 97.60990142822266),
        Vector3.new(-207.57949829101562, 251.7419891357422, 97.60990142822266),
        Vector3.new(-210.6171875, 251.78878784179688, 98.69621276855469),
        Vector3.new(-213.57949829101562, 251.7419891357422, 97.60990142822266),
        Vector3.new(-216.57949829101562, 251.7419891357422, 97.60990142822266),
        Vector3.new(-219.57949829101562, 251.7419891357422, 97.60990142822266),
        Vector3.new(-222.57949829101562, 251.7419891357422, 97.60990142822266)
    },
   
    PLACE_DELAY = 0.42,
    CYCLE_DELAY = 1.6,
    UPGRADE_DELAY = 0.65,
    SLOT_INDEX = 1,
   
    WAVE_CHANGE = 15
}

-- Index สำหรับแต่ละเซ็ตตำแหน่ง
local normalIndex = 1
local winterLowIndex = 1
local winterHighIndex = 1
local alreadySwitched = false
local lastWave = 0

local function placeUnit(pos)
    local unit = UNITS[CURRENT_UNIT_INDEX]
    local renderTable = { unit.Name, unit.ID, pos, 0 }
    local slotTable = { SlotIndex = CONFIG.SLOT_INDEX }
   
    pcall(function()
        UnitEvent:FireServer("Render", renderTable, slotTable)
    end)
   
    -- สลับหน่วยสำหรับรอบถัดไป (ทั้งชุด 1 และชุด 2)
    CURRENT_UNIT_INDEX = (CURRENT_UNIT_INDEX % #UNITS) + 1
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

local function getCurrentWave()
    local wave = 0

    pcall(function()
        local wavesAmount = player
            :WaitForChild("PlayerGui")
            :WaitForChild("HUD")
            :WaitForChild("Map")
            :WaitForChild("WavesAmount")

        local rawText = wavesAmount.ContentText or ""
        local cleanText = rawText:gsub("<[^>]->", "")
        local numStr = cleanText:match("%d+")

        if numStr then
            wave = tonumber(numStr)
        end
    end)

    return wave
end

-- ฟังก์ชันเช็ค Ice Queen (Release) เหมือนเดิม
local function hasIceQueen()
    local hasQueen = false
    pcall(function()
        local windows = playerGui:FindFirstChild("Windows")
        if windows and windows:FindFirstChild("Units") then
            local holder = windows.Units:FindFirstChild("Holder")
            if holder and holder:FindFirstChild("Main") then
                local unitsFolder = holder.Main:FindFirstChild("Units")
                if unitsFolder then
                    for _, frame in ipairs(unitsFolder:GetChildren()) do
                        local nameLabel = frame:FindFirstChild("Container", true)
                            and frame.Container:FindFirstChild("Holder", true)
                            and frame.Container.Holder:FindFirstChild("Main", true)
                            and frame.Container.Holder.Main:FindFirstChild("UnitName")
                        if nameLabel and nameLabel.Text and nameLabel.Text:find("Ice Queen %(Release%)") then
                            hasQueen = true
                            break
                        end
                    end
                end
            end
        end
    end)
    return hasQueen
end

-- ระบบหยุด / วาร์ป Lobby (เหมือนเดิม)
local stopScript = false
task.spawn(function()
    while true do
        task.wait(2)
        local level = player:GetAttribute("Level") or 0
        local Presents26 = player:GetAttribute("Presents26") or 0
        local stage = getCurrentStageAct()
        local hasQueen = hasIceQueen()
       
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
        else
            if hasQueen then
                stopScript = false
            elseif Presents26 >= CONFIG.STOP_PRESENTS26 then
                if not stopScript then
                    stopScript = true
                    warn("Winter Infinite - Presents26 ถึง " .. Presents26 .. " (ไม่มี Ice Queen) → Lobby ใน 4 วินาที")
                    task.delay(4, function()
                        if TeleportEvent then TeleportEvent:FireServer("Lobby") end
                    end)
                end
            else
                stopScript = false
            end
        end
    end
end)

local function syncPhaseWithWave(wave, stage)
    if stage ~= "Winter — Infinite" then
        return
    end

    -- ก่อน Wave เปลี่ยน → ต้อง LOW เสมอ (ถ้ายังไม่เคยขายชุด 1)
    if wave > 0 and wave < CONFIG.WAVE_CHANGE and not alreadySwitched then
        if PHASE ~= 1 then
            PHASE = 1
            winterLowIndex = 1
            winterHighIndex = 1
            warn("🔁 Sync → Wave " .. wave .. " บังคับกลับ PHASE 1 (LOW)")
        end
    end

    -- หลัง Wave เปลี่ยน → HIGH
    if wave >= CONFIG.WAVE_CHANGE and PHASE ~= 2 then
        PHASE = 2
        winterHighIndex = 1
        warn("🔁 Sync → Wave " .. wave .. " เข้า PHASE 2 (HIGH)")
    end
end

-- Loop วางตัวหลัก
task.spawn(function()
    while true do
        if stopScript then
            task.wait(3)
            continue
        end
       
        local stage = getCurrentStageAct()
        local wave = getCurrentWave()

        -- 🔥 ตรวจจับ Restart จริงจาก Wave ลด
        if stage == "Winter — Infinite" and lastWave > 0 and wave < lastWave then
            warn("🔄 Detect Restart จาก Wave " .. lastWave .. " → " .. wave)

            PHASE = 1
            alreadySwitched = false
            winterLowIndex = 1
            winterHighIndex = 1
            normalIndex = 1
        end

        lastWave = wave

        syncPhaseWithWave(wave, stage)

        if stage == "Winter — Infinite" and wave < CONFIG.WAVE_CHANGE and PHASE ~= 1 then
            task.wait(0.3)
            continue
        end

        local positions, currentIndex

        if stage == "Winter — Infinite" and wave == 1 then
            task.wait(1)
            continue
        end
       
        if stage == "Winter — Infinite" then
            if PHASE == 1 then
                positions = CONFIG.WINTER_POSITIONS_LOW
                currentIndex = winterLowIndex
            else
                positions = CONFIG.WINTER_POSITIONS_HIGH
                currentIndex = winterHighIndex
            end
        else
            positions = CONFIG.NORMAL_POSITIONS
            currentIndex = normalIndex
        end
       
        if #positions > 0 then
            local pos = positions[currentIndex]
            placeUnit(pos)
           
            -- อัปเดต index
            if stage == "Winter — Infinite" then
                if PHASE == 1 then
                    winterLowIndex = (winterLowIndex % #positions) + 1
                else
                    winterHighIndex = (winterHighIndex % #positions) + 1
                end
            else
                normalIndex = (normalIndex % #positions) + 1
            end
        end
       
        task.wait(CONFIG.PLACE_DELAY)
        task.wait(CONFIG.CYCLE_DELAY)
    end
end)

-- Auto Upgrade (เหมือนเดิม)
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

-- เช็ค Wave 15 → ขายชุด 1 แล้วสลับ PHASE เป็น 2
task.spawn(function()
    while true do
        task.wait(0.8)
       
        local wave = getCurrentWave()
        local stage = getCurrentStageAct()
       
        if stage == "Winter — Infinite"
           and wave == CONFIG.WAVE_CHANGE
           and not alreadySwitched then
           
            alreadySwitched = true
            winterHighIndex = 1   -- รีเซ็ต index ชุด 2 ให้เริ่มที่จุดแรก
           
            warn("Wave " .. wave .. " → ขายชุด 1 ทั้งหมด แล้วสลับไปชุด 2 (ตำแหน่ง HIGH)")
           
            pcall(function()
                local units = workspace:FindFirstChild("Units")
                if units then
                    for _, unit in ipairs(units:GetChildren()) do
                        if unit:IsA("Model") then
                            pcall(function()
                                UnitEvent:FireServer("Sell", unit.Name)
                            end)
                            task.wait(0.25)  -- ขายเร็วขึ้นหน่อย ป้องกัน lag
                        end
                    end
                    warn("ขายชุด 1 เรียบร้อย → เริ่มวางชุด 2")
                end
            end)
        end
    end
end)

print("✅ Auto Farm - ชุด 1 (Ackers + Bounty Hunter @ Low) → Wave 15 ขาย → ชุด 2 (Ackers + Bounty Hunter @ High)")
