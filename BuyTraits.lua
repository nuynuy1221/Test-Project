repeat task.wait() until game:IsLoaded()
task.wait(2)

local targetPlace = 126884695634066
if game.PlaceId ~= targetPlace then
    warn("PlaceId ไม่ตรง — ไม่ซื้อ Reroll ให้")
    return
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShopEvent = ReplicatedStorage:WaitForChild("Networking"):WaitForChild("Summer"):WaitForChild("ShopEvent")

local BuyTraits = {
    [1] = "Purchase",
    [2] = {"TraitRerolls", 10}
}

for i = 1, 6 do
    local success, err = pcall(function()
        ShopEvent:FireServer(unpack(BuyTraits))
    end)
    if not success then
        warn("เกิดปัญหา FireServer: "..tostring(err))
    end
    task.wait(1) -- เพิ่ม delay กัน server block
end
