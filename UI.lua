repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

-- สร้าง ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ColorfulStatusHUD"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 9999
screenGui.Parent = playerGui

-- ฟังก์ชันสร้างแถบใหญ่ตรงกลางพร้อมสีสันและอีโมจิ
local function createBar(name, posScale, bgColor, emoji)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.AnchorPoint = Vector2.new(0.5,0.5)
    frame.Position = UDim2.new(0.5,0,posScale,0)
    frame.Size = UDim2.new(0.85,0,0.15,0)
    frame.BackgroundColor3 = bgColor
    frame.BackgroundTransparency = 0.35
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    frame.ZIndex = 10

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,20)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = bgColor:lerp(Color3.new(1,1,1),0.3)
    stroke.Thickness = 4
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.Position = UDim2.new(0,0,0,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Text = emoji.." "..name
    label.Parent = frame
    label.ZIndex = 11

    return label
end

-- สร้าง 4 แถบ: User / Level / Leaves / Lich King
local userLabel   = createBar("User", 0.18, Color3.fromRGB(52,152,219), "🧑")
local levelLabel  = createBar("Level", 0.36, Color3.fromRGB(46,204,113), "🏆")
local leavesLabel = createBar("Leaves", 0.54, Color3.fromRGB(241,196,15), "🍀")
local lichLabel   = createBar("LichKing", 0.72, Color3.fromRGB(231,76,60), "👑")

-- ตั้งค่า Attribute ถ้าไม่มี
if player:GetAttribute("HasLichKing") == nil then
    player:SetAttribute("HasLichKing", false)
end

-- ฟังก์ชันเช็ค Level
local function getLevel()
    for _, attr in ipairs({"Level","level","PlayerLevel","Player_Level"}) do
        local v = player:GetAttribute(attr)
        if v ~= nil then return tonumber(v) end
    end
    return 0
end

-- ฟังก์ชันเช็ค Leaves
local function getLeaves()
    for _, attr in ipairs({"Leaves","leaves","Leaf","leaf","LeavesAmount","LeavesEarned"}) do
        local v = player:GetAttribute(attr)
        if v ~= nil then return tonumber(v) end
    end
    return 0
end

-- ฟังก์ชันเช็ค Lich King ใน Inventory ไม่สน GUID
local function checkLichKing()
    local ok, itemsFolder = pcall(function()
        local folder = playerGui:FindFirstChild("Windows") and
                       playerGui.Windows:FindFirstChild("GlobalInventory") and
                       playerGui.Windows.GlobalInventory:FindFirstChild("Holder") and
                       playerGui.Windows.GlobalInventory.Holder:FindFirstChild("LeftContainer") and
                       playerGui.Windows.GlobalInventory.Holder.LeftContainer:FindFirstChild("FakeScrollingFrame") and
                       playerGui.Windows.GlobalInventory.Holder.LeftContainer.FakeScrollingFrame:FindFirstChild("Items") and
                       playerGui.Windows.GlobalInventory.Holder.LeftContainer.FakeScrollingFrame.Items:FindFirstChild("CacheContainer")
        return folder and folder:GetChildren() or {}
    end)
    if ok and itemsFolder then
        for _, item in ipairs(itemsFolder) do
            local unitNameObj = item:FindFirstChild("Container") and
                                item.Container:FindFirstChild("Holder") and
                                item.Container.Holder:FindFirstChild("Main") and
                                item.Container.Holder.Main:FindFirstChild("UnitName")
            if unitNameObj and unitNameObj.Text:match("Lich King") then
                return true
            end
        end
    end
    return false
end

-- อัปเดต UI ทุก Frame
RunService.RenderStepped:Connect(function()
    userLabel.Text   = "👤 User : "..player.Name
    levelLabel.Text  = "🔵 Level : "..tostring(getLevel())
    leavesLabel.Text = "🍀 Leaves : "..tostring(getLeaves())

    -- เช็ค Lich King และเซฟ Attribute
    if checkLichKing() then
        player:SetAttribute("HasLichKing", true)
    end
    local hasLich = player:GetAttribute("HasLichKing")
    lichLabel.Text = "👑 Lich King : "..(hasLich and "✅" or "❌")
end)
