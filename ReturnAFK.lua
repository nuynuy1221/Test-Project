repeat task.wait() until game:IsLoaded()
task.wait(2)

-- =======================
-- เช็ค PlaceId ก่อนเสมอ
-- =======================
local targetPlace = 18219125606
if game.PlaceId ~= targetPlace then
    warn("PlaceId ไม่ตรง — ไม่รันสคริปต์")
    return
end

local player = game:GetService("Players").LocalPlayer
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- หา Button จาก GUI
local button
pcall(function()
    button = player.PlayerGui:FindFirstChild("Main") 
             and player.PlayerGui.Main:FindFirstChild("Create")
             and player.PlayerGui.Main.Create:FindFirstChild("Button")
end)

if button then
    button.Selectable = true
    GuiService.SelectedCoreObject = button

    -- กดปุ่ม Enter
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)

    task.wait(0.1)
    GuiService.SelectedCoreObject = nil

    print("[แจ้งเตือน] ✅ กดปุ่มสำเร็จ")
else
    warn("[แจ้งเตือน] ❌ หา Button ไม่เจอ")
end
