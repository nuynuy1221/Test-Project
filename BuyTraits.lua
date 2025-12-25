repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ================= CONFIG CHECK (REQUIRED) =================
local Config = getgenv().Config

-- ไม่มี Config เลย
if not Config then
    warn("❌ ไม่มี Config — ไม่ซื้อ Reroll ให้")
    return
end

-- ไม่มีการเปิดฟีเจอร์นี้
if Config.BuyTraitReroll ~= true then
    warn("❌ BuyTraitReroll ไม่ได้เปิด — ไม่ซื้อ Reroll ให้")
    return
end
-- ==========================================================

-- ================= PLACE CHECK =================
local TARGET_PLACE = 16146832113
if game.PlaceId ~= TARGET_PLACE then
    warn("❌ PlaceId ไม่ตรง — ไม่ซื้อ Reroll ให้")
    return
end
-- ===============================================

-- ================= SERVICES =================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShopEvent = ReplicatedStorage
    :WaitForChild("Networking")
    :WaitForChild("Summer")
    :WaitForChild("ShopEvent")
-- ============================================

local BuyTraits = {
    "Purchase",
    {"TraitRerolls", 10}
}

for i = 1, 6 do
    local success, err = pcall(function()
        ShopEvent:FireServer(unpack(BuyTraits))
    end)

    if not success then
        warn("❌ เกิดปัญหา FireServer:", err)
    end

    task.wait(1) -- กัน server block
end

print("✅ BuyTraitReroll: ซื้อ Reroll เสร็จเรียบร้อย")
