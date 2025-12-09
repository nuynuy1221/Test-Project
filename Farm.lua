--== เช็ค PlaceId ก่อนรัน ==--
local targetPlace = 16277809958
if game.PlaceId ~= targetPlace then
    warn("PlaceId ไม่ตรง สคริปต์จะไม่ทำงาน")
    return
end

repeat task.wait() until game:IsLoaded()
task.wait(1)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networking = ReplicatedStorage:WaitForChild("Networking")
local UnitEvent = Networking:WaitForChild("UnitEvent")

--------------------------------------------------------------------
-- 🔍 ฟังก์ชันเช็คเลเวล
--------------------------------------------------------------------
local function getLevel()
    local levelLabel = player.PlayerGui.Hotbar.Main.Level:WaitForChild("Level")
    local text = levelLabel.Text or ""
    local num = text:match("%d+")
    return tonumber(num) or 0
end

--------------------------------------------------------------------
-- 🚪 ฟังก์ชันเทเลพอร์ตเมื่อเลเวลถึง 11
--------------------------------------------------------------------
local function teleportToLobby()
    local args = {"Lobby"}
    game:GetService("ReplicatedStorage"):WaitForChild("Networking"):WaitForChild("TeleportEvent"):FireServer(unpack(args))
    warn("🔥 เลเวลถึง 11 — Teleport กลับ Lobby แล้ว!")
end

--------------------------------------------------------------------
-- ⭐ สถานะหยุดสคริปต์
--------------------------------------------------------------------
local stopScript = false

task.spawn(function()
    while true do
        local lv = getLevel()
        if lv >= 11 then
            stopScript = true
            teleportToLobby()
        else
            stopScript = false
        end
        task.wait(1)
    end
end)

--------------------------------------------------------------------
-- ตัวละครที่จะวาง
--------------------------------------------------------------------
local unitsToPlace = {
    {name = "Luffo", id = 39},
    {name = "Roku",  id = 41}
}

local placements = {
    Vector3.new(427.75726318359375, 2.29998779296875, -347.031005859375),
    Vector3.new(441.1226501464844, 2.29998779296875, -348.0281677246094),
    Vector3.new(438.84246826171875, 2.29998779296875, -322.0071716308594),
    Vector3.new(451.99615478515625, 2.29998779296875, -322.6607971191406),
    Vector3.new(450.403076171875, 2.29998779296875, -349.50823974609375),
    Vector3.new(463.7310791015625, 2.29998779296875, -348.7103271484375)
}

--------------------------------------------------------------------
-- 🔄 ฟังก์ชันวางตัวละคร
--------------------------------------------------------------------
local function placeUnits()
    for _, unit in ipairs(unitsToPlace) do
        for _, pos in ipairs(placements) do
            if stopScript then return end
            local args = {"Render", {unit.name, unit.id, pos, 0}}
            local success, err = pcall(function()
                UnitEvent:FireServer(unpack(args))
            end)
            if not success then
                warn("เกิดปัญหาในการวางตัว: "..err)
            end
            task.wait(1)
        end
    end
end

--------------------------------------------------------------------
-- 🔄 ฟังก์ชันวางตัวละคร + Retry
--------------------------------------------------------------------
task.spawn(function()
    while true do
        if not stopScript then
            local ok, err = pcall(placeUnits)
            if not ok then
                warn("ระบบวางตัวเกิดปัญหา — รีสตาร์ทใน 2 วินาที: "..tostring(err))
                task.wait(2)
            else
                task.wait(5)
            end
        else
            task.wait(1)
        end
    end
end)

--------------------------------------------------------------------
-- 🔄 ฟังก์ชันอัปเกรดตัวละคร
--------------------------------------------------------------------
local function upgradeUnits()
    local unitsFolder = workspace:WaitForChild("Units")
    for _, unitInstance in ipairs(unitsFolder:GetChildren()) do
        if stopScript then return end
        if unitInstance then
            local success, err = pcall(function()
                UnitEvent:FireServer("Upgrade", unitInstance.Name)
            end)
            if not success then
                warn("ระบบอัปเกรดเกิดปัญหา: "..err)
            end
            task.wait(1)
        end
    end
end

--------------------------------------------------------------------
-- 🔄 ระบบอัปเกรด + Retry
--------------------------------------------------------------------
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
