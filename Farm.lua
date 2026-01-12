repeat task.wait() until game:IsLoaded()
task.wait(1.5)

local targetPlace = 16277809958
if game.PlaceId ~= targetPlace then
    warn("ผิดแมพ! ใช้ได้ในห้องฟาร์มเท่านั้น")
    return
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local Networking = RS:WaitForChild("Networking", 8)
local UnitEvent = Networking and Networking:WaitForChild("UnitEvent", 5)
local TeleportEvent = Networking and Networking:WaitForChild("TeleportEvent", 5)

if not UnitEvent then
    warn("ไม่เจอ UnitEvent → เกมอาจอัปเดตแล้ว")
    return
end

-- ==============================================
-- SETTINGS
-- ==============================================
local SETTINGS = {
    UNITS_TO_PLACE = {
        {name = "Ackers", id = 241},
    },

    PLACEMENT_POSITIONS = {
        Vector3.new(354.797, 48.49, -166.937),
        Vector3.new(353.004, 48.49, -166.919),
        Vector3.new(351.165, 48.49, -166.960)
    },

    DELAY_BETWEEN_PLACEMENT = 1,
    DELAY_BETWEEN_CYCLE    = 3,
    AUTO_UPGRADE           = true,
    UPGRADE_DELAY          = 2,
    STOP_LEAVES            = 45000,
    STOP_LEVEL             = 11,
}

-- ==============================================
-- Helper Functions
-- ==============================================
local function safeFire(...)
    pcall(UnitEvent.FireServer, UnitEvent, ...)
end

local function getCurrentLeaves()
    return player:GetAttribute("Leaves") 
        or player:GetAttribute("leaves") 
        or player:GetAttribute("Leaf") 
        or 0
end

local function getLevel()
    return player:GetAttribute("Level") 
        or player:GetAttribute("PlayerLevel") 
        or 0
end

-- ==============================================
-- ระบบหยุดสคริปต์
-- ==============================================
local STOP_SCRIPT = false

task.spawn(function()
    while true do
        task.wait(2)

        local level = getLevel()
        local leaves = getCurrentLeaves()
        local hasLich = false

        -- เช็ค Lich King (path แบบปลอดภัย)
        pcall(function()
            local pg = player.PlayerGui
            local w = pg.Windows
            local u = w.Units
            local h = u.Holder
            local m = h.Main
            local uf = m.Units

            for _, frame in uf:GetChildren() do
                local nameLabel = frame.Container
                    and frame.Container.Holder
                    and frame.Container.Holder.Main
                    and frame.Container.Holder.Main.UnitName

                if nameLabel and nameLabel.Text and nameLabel.Text:find("Lich King") then
                    hasLich = true
                    break
                end
            end
        end)

        if level >= SETTINGS.STOP_LEVEL and (hasLich or leaves >= SETTINGS.STOP_LEAVES) then
            if not STOP_SCRIPT then
                STOP_SCRIPT = true
                warn(string.format("หยุดแล้ว (Lv.%d | Leaves: %d)", level, leaves))
                task.delay(5, function()
                    if TeleportEvent then
                        TeleportEvent:FireServer("Lobby")
                    end
                end)
            end
        else
            STOP_SCRIPT = false
        end
    end
end)

-- ==============================================
-- วางตัว (แก้ error unpack โดยไม่ใช้ unpack เลย)
-- ==============================================
task.spawn(function()
    while true do
        task.wait(STOP_SCRIPT and 3 or SETTINGS.DELAY_BETWEEN_CYCLE)

        if STOP_SCRIPT then continue end

        for _, unit in SETTINGS.UNITS_TO_PLACE do
            for _, pos in SETTINGS.PLACEMENT_POSITIONS do
                if STOP_SCRIPT then break end

                -- รูปแบบที่ 1 (รูปแบบใหม่ที่คุณให้มา - แนะนำให้ใช้หลัก)
                safeFire(
                    "Render",
                    {unit.name, unit.id, pos, 0},
                    {SlotIndex = 1}
                )

                -- รูปแบบที่ 2 (fallback แบบเก่า ถ้าอันบนไม่เวิร์ค)
                task.wait(0.08)
                safeFire("Render", unit.name, unit.id, pos, 0)

                task.wait(SETTINGS.DELAY_BETWEEN_PLACEMENT)
            end
        end
    end
end)

-- ==============================================
-- Auto Upgrade
-- ==============================================
if SETTINGS.AUTO_UPGRADE then
    task.spawn(function()
        while true do
            if not STOP_SCRIPT then
                pcall(function()
                    local units = workspace:FindFirstChild("Units")
                    if units then
                        for _, unit in units:GetChildren() do
                            if unit:IsA("Model") then
                                safeFire("Upgrade", unit.Name)
                                task.wait(SETTINGS.UPGRADE_DELAY)
                            end
                        end
                    end
                end)
            end
            task.wait(1.3)
        end
    end)
end

print("สคริปต์ Anime Vanguards Auto Farm รันเสร็จแล้ว")
