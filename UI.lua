repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- =========================
-- GUI HUD
-- =========================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ColorfulStatusHUD"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 9999
screenGui.Parent = playerGui

local function createBar(name, posScale, bgColor, emoji)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.AnchorPoint = Vector2.new(0.5,0.5)
    frame.Position = UDim2.new(0.5,0,posScale,0)
    frame.Size = UDim2.new(0.85,0,0.15,0)
    frame.BackgroundColor3 = bgColor
    frame.BackgroundTransparency = 0.35
    frame.BorderSizePixel = 0
    frame.ZIndex = 10
    frame.Parent = screenGui

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,20)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = bgColor:lerp(Color3.new(1,1,1),0.3)
    stroke.Thickness = 4

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Text = emoji.." "..name
    label.ZIndex = 11
    label.Parent = frame

    return label
end

local userLabel   = createBar("User", 0.18, Color3.fromRGB(52,152,219), "🧑")
local levelLabel  = createBar("Level", 0.36, Color3.fromRGB(46,204,113), "🏆")
local leavesLabel = createBar("Leaves", 0.54, Color3.fromRGB(241,196,15), "🍀")
local lichLabel   = createBar("LichKing", 0.72, Color3.fromRGB(231,76,60), "👑")

-- =========================
-- Attribute
-- =========================
if player:GetAttribute("HasLichKing") == nil then
    player:SetAttribute("HasLichKing", false)
end

-- =========================
-- Helper
-- =========================
local function getAttr(list)
    for _, name in ipairs(list) do
        local v = player:GetAttribute(name)
        if v ~= nil then return tonumber(v) end
    end
    return 0
end

local function getLevel()
    return getAttr({"Level","level","PlayerLevel","Player_Level"})
end

local function getLeaves()
    return getAttr({"Leaves","leaves","Leaf","leaf","LeavesAmount"})
end

-- =========================
-- 🔍 เช็ค Lich จาก Units GUI (ไม่สน GUID)
-- =========================
local TARGET = "lich"

local function getUnitsContainer()
    local ok, container = pcall(function()
        return playerGui
            .Windows
            .Units
            .Holder
            .Main
            .Units
    end)
    return ok and container or nil
end

local function checkLichFromUnits()
    local units = getUnitsContainer()
    if not units then return false end

    for _, unitItem in ipairs(units:GetChildren()) do
        local ok, nameLabel = pcall(function()
            return unitItem.Container.Holder.Main.UnitName
        end)

        if ok and nameLabel and nameLabel.Text then
            if nameLabel.Text:lower():find(TARGET) then
                -- 🔑 เจอ Lich + GUID
                -- print("FOUND LICH | GUID =", unitItem.Name)
                return true
            end
        end
    end
    return false
end

-- =========================
-- Update HUD
-- =========================
RunService.RenderStepped:Connect(function()
    userLabel.Text   = "🤖 User : "..player.Name
    levelLabel.Text  = "⬆️ Level : "..getLevel()
    leavesLabel.Text = "🍀 Leaves : "..getLeaves()

    local hasLich = checkLichFromUnits()
    player:SetAttribute("HasLichKing", hasLich)

    lichLabel.Text = "👑 Lich King : "..(hasLich and "✅" or "❌")
end)
