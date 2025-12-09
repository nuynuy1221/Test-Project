----------------------------------------------------------------
-- 🕒 รอเกมโหลดให้เสร็จ
----------------------------------------------------------------
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

----------------------------------------------------------------
-- 🕒 ฟังก์ชันรอให้ GUI และ Networking โหลดครบจริง ๆ
----------------------------------------------------------------
local function waitForGameReady()
    -- รอ PlayerGui
    local playerGui = player:WaitForChild("PlayerGui", 30)

    -- รอให้ GUI ภายในเริ่มโผล่มาบ้าง
    repeat task.wait() until #playerGui:GetChildren() > 0

    -- รอ HUD ตัวหลัก (เกมนี้ชอบโหลดช้า)
    repeat task.wait() until playerGui:FindFirstChild("HUD")

    -- รอปุ่มสำคัญ เช่น SkipWave
    repeat task.wait() until playerGui.HUD:FindFirstChild("SkipWave")

    -- รอ Networking โหลดเสร็จ
    repeat task.wait() until ReplicatedStorage:FindFirstChild("Networking")

    repeat task.wait() until ReplicatedStorage.Networking:FindFirstChild("Units")
    repeat task.wait() until ReplicatedStorage.Networking.Units:FindFirstChild("UnitSelectionEvent")

    -- รอ TeleportEvent (บางแมพโหลดช้ามาก)
    repeat task.wait() until ReplicatedStorage.Networking:FindFirstChild("TeleportEvent")

    task.wait(0.5) -- กันดีเลย์หลังโหลด event

    print("[Loader] Game environment ready.")
end

waitForGameReady()

----------------------------------------------------------------
--      เริ่มโหลดไฟล์จาก GitHub หลังจากเกมพร้อมแล้ว
----------------------------------------------------------------

local repo = "https://raw.githubusercontent.com/nuynuy1221/Test-Project/main/"
local index = "Index.txt"

local function fetch(url)
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        return response
    else
        warn("[Loader] Fetch failed:", url)
        return nil
    end
end

-- โหลดรายชื่อไฟล์จาก Index.txt
local fileList = fetch(repo .. index)
if not fileList then
    warn("[Loader] Unable to load Index!")
    return
end

local files = string.split(fileList, "\n")

for _, file in ipairs(files) do
    file = file:gsub("\r", "")
    if file ~= "" and file ~= index then
        local url = repo .. file
        print("[Loader] Loading:", url)

        local content = fetch(url)
        if content then
            local ok, err = pcall(function()
                loadstring(content)()
            end)

            if not ok then
                warn("[Loader Error in file:", file .. "]", err)
            end
        end
    end
end

print("[Loader] All scripts loaded successfully.")
