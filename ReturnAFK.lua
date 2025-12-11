repeat task.wait() until game:IsLoaded()
wait(2)
-- =======================
-- เช็ค PlaceId ก่อนเสมอ
-- =======================
local targetPlace = 18219125606
if game.PlaceId ~= targetPlace then
    warn("PlaceId ไม่ตรง — ไม่รันสคริปต์")
    return
end

-- =======================
-- เริ่มเช็คเลเวล
-- =======================
local player = game:GetService("Players").LocalPlayer

-- ฟังก์ชันอ่านเลเวลจาก Attribute
local function getLevelAttribute()
    return tonumber(
        player:GetAttribute("Level") 
        or player:GetAttribute("level")
        or player:GetAttribute("PlayerLevel")
        or player:GetAttribute("Player_Level")
    ) or 0
end

-- รอจนกว่า Attribute จะโหลด
local level = 0
repeat
    level = getLevelAttribute()
    task.wait(0.2)
until level and level > 0

print("[แจ้งเตือน] 🎯 Level ปัจจุบัน:", level)

-- =======================
-- ถ้าเลเวล <= 11 → รันสคริปต์กดปุ่มอัตโนมัติ
-- =======================
if level <= 11 then
    print("[แจ้งเตือน] ✔ Level ต่ำกว่า 11 รันสคริปต์ให้")

    local GuiService = game:GetService("GuiService")
    local VirtualInputManager = game:GetService("VirtualInputManager")

    local button
    pcall(function()
        button = player.PlayerGui.Main.Create.Button
    end)

    if button then
        button.Selectable = true
        GuiService.SelectedCoreObject = button

        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)

        task.wait(0.1)
        GuiService.SelectedCoreObject = nil

        print("[แจ้งเตือน] ✅ กดปุ่มสำเร็จ")
    else
        warn("[แจ้งเตือน] ❌ หา Button ไม่เจอ")
    end
else
    print("[แจ้งเตือน] ❌ Level มากกว่า 11 — ไม่รันสคริปต์")
end
