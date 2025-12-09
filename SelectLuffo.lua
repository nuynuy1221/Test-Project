repeat task.wait() until game:IsLoaded()
local targetPlace = 16146832113
if game.PlaceId ~= targetPlace then
    warn("PlaceId ไม่ตรง สคริปต์จะไม่ทำงาน")
    return
end

local args = {
    [1] = "Select",
    [2] = "Luffo"
}

game:GetService("ReplicatedStorage"):WaitForChild("Networking"):WaitForChild("Units"):WaitForChild("UnitSelectionEvent"):FireServer(unpack(args))
