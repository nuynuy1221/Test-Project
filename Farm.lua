repeat task.wait() until game:IsLoaded()
task.wait(1)

--== เช็ค PlaceId ก่อนรัน ==--
local targetPlace = 16277809958
if game.PlaceId ~= targetPlace then
    warn("PlaceId ไม่ตรง สคริปต์จะไม่ทำงาน")
    return
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networking = ReplicatedStorage:WaitForChild("Networking")
local UnitEvent = Networking:WaitForChild("UnitEvent")
local TeleportEvent = Networking:WaitForChild("TeleportEvent")
local matchRestartEvent = Networking:WaitForChild("MatchRestartSettingEvent")
local playerGui = player:WaitForChild("PlayerGui")

-- =========================
-- แปลง string เป็น number
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

-- =========================
-- ฟังก์ชันเช็ค Level / Leaves
-- =========================
local function getLevel()
    for _, attrName in ipairs({"Level","level","PlayerLevel","Player_Level"}) do
        local v = player:GetAttribute(attrName)
        if v ~= nil then return tonumber(v) or toNumber(v) end
    end
    return 0
end

local function getLeaves()
    for _, attrName in ipairs({"Leaves","leaves","Leaf","leaf","LeavesAmount","LeavesEarned"}) do
        local v = player:GetAttribute(attrName)
        if v ~= nil then return tonumber(v) or toNumber(v) end
    end
    return 0
end

-- =========================
-- Teleport Lobby
-- =========================
local function teleportToLobby()
    pcall(function()
        TeleportEvent:FireServer("Lobby")
        warn("🔥 เลเวลถึง 11 — Teleport กลับ Lobby แล้ว!")
    end)
end

-- =========================
-- สถานะหยุดสคริปต์
-- =========================
local stopScript = false

-- =========================
-- เช็ค Level + StageAct + Leaves
-- =========================
task.spawn(function()
    while true do
        task.wait(1)
        local lv = getLevel()
        local leaves = getLeaves()

        -- อ่าน StageAct ให้เสถียร
        local stageActText
        repeat
            local ok, stageAct = pcall(function()
                return playerGui.Guides.List.StageInfo.StageFrame:WaitForChild("StageAct",3)
            end)
            if ok and stageAct and stageAct.Text then
                stageActText = stageAct.Text
            else
                task.wait(0.5)
            end
        until stageActText

        -- เงื่อนไข teleport
        if lv >= 11 then
            if stageActText == "Fall — Infinite" and leaves >= 100000 then
                stopScript = true
                teleportToLobby()
            elseif stageActText ~= "Fall — Infinite" then
                stopScript = true
                teleportToLobby()
            end
        else
            stopScript = false
        end
    end
end)

-- =========================
-- ตัวละครที่จะวาง
-- =========================
local unitsToPlace1 = {
    {name = "Luffo", id = 39},
    {name = "Roku",  id = 41}
}

local unitsToPlace2 = {
    {name = "Ackers", id = 241}
}

local placements1 = {
    Vector3.new(427.757, 2.3, -347.031),
    Vector3.new(441.123, 2.3, -348.028),
    Vector3.new(438.842, 2.3, -322.007),
    Vector3.new(451.996, 2.3, -322.661),
    Vector3.new(450.403, 2.3, -349.508),
    Vector3.new(463.731, 2.3, -348.710)
}

local placements2 = {
    Vector3.new(354.797, 48.49, -166.937),
    Vector3.new(353.004, 48.49, -166.919),
    Vector3.new(351.165, 48.49, -166.960)
}

-- =========================
-- ฟังก์ชันวางตัวละครทีละตัว
-- =========================
local function placeUnitsLoop()
    while true do
        if stopScript then
            task.wait(1)
        else
            -- เช็ค StageAct
            local stageActText
            local ok, stageAct = pcall(function()
                return playerGui.Guides.List.StageInfo.StageFrame.StageAct
            end)
            if ok and stageAct and stageAct.Text then
                stageActText = stageAct.Text
            end

            local unitsToPlace, placements
            if stageActText == "Fall — Infinite" then
                unitsToPlace = unitsToPlace2
                placements   = placements2
            else
                unitsToPlace = unitsToPlace1
                placements   = placements1
            end

            -- วางทีละตัวตามตำแหน่ง
            for _, unit in ipairs(unitsToPlace) do
                for _, pos in ipairs(placements) do
                    if stopScript then break end
                    local RenderUnit = {"Render", {unit.name, unit.id, pos, 0}}
                    pcall(function()
                        UnitEvent:FireServer(unpack(RenderUnit))
                    end)
                    task.wait(0.5) -- delay ระหว่างตัวละครแต่ละตัว
                end
                task.wait(0.5) -- delay หลังวางแต่ละ unit
            end

            task.wait(2) -- delay หลังวางครบชุด ก่อนวนลูปใหม่
        end
    end
end

-- =========================
-- เรียกใช้งาน
-- =========================
task.spawn(placeUnitsLoop)

-- =========================
-- ฟังก์ชันอัปเกรดตัวละคร
-- =========================
local function upgradeUnits()
    local unitsFolder = workspace:WaitForChild("Units")
    for _, unitInstance in ipairs(unitsFolder:GetChildren()) do
        if stopScript then return end
        local success, err = pcall(function()
            UnitEvent:FireServer("Upgrade", unitInstance.Name)
        end)
        if not success then
            warn("ระบบอัปเกรดเกิดปัญหา: "..err)
        end
        task.wait(0.5)
    end
end

-- =========================
-- ระบบอัปเกรด + Retry
-- =========================
task.spawn(function()
    while true do
        if not stopScript then
            local ok, err = pcall(upgradeUnits)
            if not ok then
                warn("Retry ระบบอัปเกรดใน 2 วิ: "..tostring(err))
                task.wait(2)
            else
                task.wait(1)
            end
        else
            task.wait(1)
        end
    end
end)

-- =========================
-- เช็ค Wave = 20 เพื่อ Vote MatchRestart
-- =========================
local function getWaveAmount()
    local ok, waveObj = pcall(function()
        return playerGui.HUD.Map.WavesAmount
    end)
    if ok and waveObj and waveObj.Text then
        local wave = tonumber(waveObj.Text:match("%d+"))
        return wave or 0
    end
    return 0
end

local function voteMatchRestart()
    pcall(function()
        matchRestartEvent:FireServer("Vote")
    end)
    print("✅ Vote MatchRestart ส่งแล้ว")
end

task.spawn(function()
    while true do
        task.wait(1)
        local wave = getWaveAmount()
        if wave >= 20 then
            voteMatchRestart()
        end
    end
end)


