local repo = "https://raw.githubusercontent.com/nuynuy1221/Test-Project/main/"
local index = "Index.txt"

-- โหลด lists ไฟล์จาก index.txt
local fileList = game:HttpGet(repo .. index)
local files = string.split(fileList, "\n")

for _, file in ipairs(files) do
    file = file:gsub("\r", "")  -- ลบ \r กันบัคใน Windows

    if file ~= "" and file ~= index then
        local url = repo .. file
        print("[Loader] Loading:", url)

        local success, result = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)

        if not success then
            warn("[Loader Error]", file, result)
        end
    end
end

print("[Loader] All scripts loaded.")
