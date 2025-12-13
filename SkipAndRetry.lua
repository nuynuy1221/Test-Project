repeat task.wait() until game:IsLoaded()
task.wait(2)

repeat task.wait() until game:IsLoaded()
local targetPlace = 16277809958
if game.PlaceId ~= targetPlace then
    warn("PlaceId ไม่ตรง ไม่ Skip และ Retry ให้")
    return
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- ฟังก์ชันกดปุ่ม Skip
local function pressSkipButton()
    local success, button = pcall(function()
        return playerGui.SkipWave.Holder.Yes.Button
    end)
    
    if success and button then
        button.Selectable = true
        GuiService.SelectedCoreObject = button

        -- กด Enter
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)

        wait(0.1)
        GuiService.SelectedCoreObject = nil
    end
end

local function pressRetryButton()
    local success, button = pcall(function()
        return playerGui.EndScreen.Holder.Buttons.Retry.Button
    end)
    
    if success and button then
        button.Selectable = true
        GuiService.SelectedCoreObject = button

        -- กด Enter
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)

        wait(0.1)
        GuiService.SelectedCoreObject = nil
    end
end

-- เช็คปุ่มทุก 2 วิ
task.spawn(function()
    while true do
        task.wait(2)
        pressSkipButton()
        pressRetryButton()
    end
end)
