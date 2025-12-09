-- รอเกมโหลดให้เสร็จ
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local player = game.Players.LocalPlayer

-- รอ PlayerGui โผล่มาครบ
local playerGui = player:WaitForChild("PlayerGui", 30)

-- รอให้มี GUI อย่างน้อย 1 อัน (กัน TP แล้ว GUI ยังไม่มา)
repeat task.wait() until #playerGui:GetChildren() > 0
task.wait(1) -- กัน lag load asset

----------------------------------------------------------------
--      เริ่มระบบโหลดไฟล์จาก GitHub หลังจากเกมพร้อมแล้ว
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
                warn("[Loader Error]", file, err)
            end
        end
    end
end

print("[Loader] All scripts loaded successfully.")
