repeat task.wait() until game:IsLoaded()
task.wait(2)

local targetPlace = 16277809958
if game.PlaceId ~= targetPlace then
    warn("PlaceId ไม่ตรง ไม่ Anti-AFK ให้")
    return
end

task.spawn(function()
    while true do

        local GuiService = game:GetService("GuiService")
        local VirtualInputManager = game:GetService("VirtualInputManager")
        local button = game:GetService("Players").LocalPlayer.PlayerGui.Guides.List.StageInfo.Buttons.StageInfo.Button
    
        button.Selectable = true
        GuiService.SelectedCoreObject = button
        
        VirtualInputManager:SendKeyEvent(true,Enum.KeyCode.Return,false,game)
        VirtualInputManager:SendKeyEvent(false,Enum.KeyCode.Return,false,game)
        
        wait(0.1)
        GuiService.SelectedCoreObject = nil
        
        wait(15)
        
        local GuiService = game:GetService("GuiService")
         local VirtualInputManager = game:GetService("VirtualInputManager")
        local button = game:GetService("Players").LocalPlayer.PlayerGui.StageInfo.Holder.Back.Button
        
        button.Selectable = true
        GuiService.SelectedCoreObject = button
        
        VirtualInputManager:SendKeyEvent(true,Enum.KeyCode.Return,false,game)
        VirtualInputManager:SendKeyEvent(false,Enum.KeyCode.Return,false,game)
        
        wait(0.1)
        GuiService.SelectedCoreObject = nil
        task.wait(15)
    end
end)
