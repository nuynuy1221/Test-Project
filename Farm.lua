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

        if lv >= 11 then
            if stageActText == "Fall — Infinite" and leaves >= 45000 then
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
    Vector3.new(445.17132568359375, 2.29998779296875, -342.4508056640625),
    Vector3.new(445.14013671875, 2.29998779296875, -346.05340576171875),
    Vector3.new(445.0626220703125, 2.29998779296875, -344.2766418457031)

}

local placements2 = {
    Vector3.new(354.797, 48.49, -166.937),
    Vector3.new(353.004, 48.49, -166.919),
    Vector3.new(351.165, 48.49, -166.960)
}

-- =========================
-- ฟังก์ชันวางตัวละคร
-- =========================
local function placeUnitsLoop()
    while true do
        if stopScript then
            task.wait(1)
        else
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
                unitsToPlace = unitsToPlace2
                placements   = placements1
            end

            for _, unit in ipairs(unitsToPlace) do
                for _, pos in ipairs(placements) do
                    if stopScript then break end
                    pcall(function()
                        UnitEvent:FireServer("Render", {unit.name, unit.id, pos, 0})
                    end)
                    task.wait(0.5)
                end
                task.wait(0.5)
            end

            task.wait(2)
        end
    end
end

task.spawn(placeUnitsLoop)

-- =========================
-- ฟังก์ชันอัปเกรดตัวละคร
-- =========================
local function upgradeUnits()
    local unitsFolder = workspace:WaitForChild("Units")
    for _, unitInstance in ipairs(unitsFolder:GetChildren()) do
        pcall(function()
            UnitEvent:FireServer("Upgrade", unitInstance.Name)
        end)
        task.wait(0.5)
    end
end

-- =========================
-- ระบบอัปเกรดต่อเนื่อง
-- =========================
task.spawn(function()
    while true do
        if not stopScript then
            pcall(upgradeUnits)
        end
        task.wait(1)
    end
end)



