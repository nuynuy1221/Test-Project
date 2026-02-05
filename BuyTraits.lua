repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ================= CONFIG CHECK (REQUIRED) =================
local Config = getgenv().Config

if not Config then
    warn("❌ ไม่มี Config — ไม่ซื้อ Reroll ให้")
    return
end

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
    :WaitForChild("Shop")
    :WaitForChild("PurchaseItem")
-- ============================================

-- ================= BUY CONFIG =================
local BuyArgs = {
    "Winter Shop",     -- Shop Name
    "TraitRerolls",    -- Item
    1                  -- Amount
}
-- =============================================

for i = 1, 50 do
    local success, err = pcall(function()
        ShopEvent:FireServer(unpack(BuyArgs))
    end)

    if not success then
        warn("❌ เกิดปัญหา FireServer:", err)
    end

    task.wait(0.1) -- กัน server block
end

print("✅ BuyTraitReroll: ซื้อ Reroll เสร็จเรียบร้อย")
