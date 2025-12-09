local repo = "https://raw.githubusercontent.com/nuynuy1221/Test-Project/main/"
local index = "Index.txt"

----------------------------------------------------
-- 🛡 ฟังก์ชันโหลดไฟล์แบบปลอดภัย + retry 3 รอบ
----------------------------------------------------
local function safeGet(url)
    for i = 1, 3 do
        local ok, res = pcall(function()
            return game:HttpGet(url)
        end)

        if ok then
            return res
        end

        warn("[Loader] Retry", i, ":", url)
        task.wait(0.5)
    end

    error("[Loader] โหลดไฟล์ไม่สำเร็จ: " .. url)
end

----------------------------------------------------
-- 📄 โหลด Index (รายชื่อไฟล์ทั้งหมด)
----------------------------------------------------
local fileList = safeGet(repo .. index)
local files = string.split(fileList, "\n")

----------------------------------------------------
-- 🔁 โหลดสคริปต์ทั้งหมดตามรายชื่อ
----------------------------------------------------
for _, file in ipairs(files) do
    file = file:gsub("\r", "")  -- ลบ CR จาก Windows

    if file ~= "" and file ~= index then
        local url = repo .. file
        print("[Loader] Loading:", url)

        local success, result = pcall(function()
            return loadstring(safeGet(url))()
        end)

        if not success then
            warn("[Loader Error] ไฟล์:", file, "->", result)
        end
    end
end

print("[Loader] ✔ โหลดสคริปต์ทั้งหมดเรียบร้อย")
