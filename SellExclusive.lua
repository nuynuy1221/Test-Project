repeat task.wait() until game:IsLoaded()
task.wait(2)

local targetPlace = 16146832113
if game.PlaceId ~= targetPlace then
    warn("PlaceId ไม่ตรง ไม่ขาย Exclusive ให้")
    return
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SellEvent = ReplicatedStorage:WaitForChild("Networking"):WaitForChild("Units"):WaitForChild("SellEvent")

task.spawn(function()
    while true do
        local unitFolder = player.PlayerGui.Windows.GlobalInventory.Holder.LeftContainer.FakeScrollingFrame.Items.CacheContainer
    
        for _, unit in ipairs(unitFolder:GetChildren()) do
            local success, glow = pcall(function()
                return unit.Container.Glow
            end)
    
            if success and glow:FindFirstChild("Exclusive") then
                local guid = unit.Name
    
                print("✅ Found Exclusive and Sold | GUID:", guid)
    
                local args = {
                    [1] = {
                    [1] = guid
                    }
                }
    
                SellEvent:FireServer(unpack(args))
            end
        end
    
        task.wait(1)
    end
end)
