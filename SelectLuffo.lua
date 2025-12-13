repeat task.wait() until game:IsLoaded()
local targetPlace = 16146832113
if game.PlaceId ~= targetPlace then
    warn("PlaceId ไม่ตรง สคริปต์จะไม่ทำงาน")
    return
end

local SelectLuffo = {
    [1] = "Select",
    [2] = "Luffo"
}

game:GetService("ReplicatedStorage"):WaitForChild("Networking"):WaitForChild("Units"):WaitForChild("UnitSelectionEvent"):FireServer(unpack(SelectLuffo))

wait(1)

local LoginGirl = {
    [1] = "Claim",
    [2] = 1
}

game:GetService("ReplicatedStorage"):WaitForChild("Networking"):WaitForChild("NewPlayerRewardsEvent"):FireServer(unpack(LoginGirl))
