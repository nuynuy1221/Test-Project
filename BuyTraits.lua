repeat task.wait() until game:IsLoaded()
task.wait(2)

local targetPlace = 16146832113
if game.PlaceId ~= targetPlace then
    warn("PlaceId ไม่ตรง ไม่ EquipUnits ให้")
    return
end

local ShopEvent = ReplicatedStorage:WaitForChild("Networking"):WaitForChild("Summer"):WaitForChild("ShopEvent")

local BuyTraits = {
    [1] = "Purchase",
    [2] = {"TraitRerolls", 10}
}

for i = 1, 6 do
  ShopEvent:FireServer(unpack(BuyTraits))
  task.wait(0.5)
end
