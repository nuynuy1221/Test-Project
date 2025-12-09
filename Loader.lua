local base = "https://raw.githubusercontent.com/USERNAME/REPOSITORY/main/"

local files = {
    "main.lua",
    "upgrade.lua",
    "autoplay.lua",
    "config.lua"
}

for _, file in ipairs(files) do
    local url = base .. file
    print("Loading:", url)
    loadstring(game:HttpGet(url))()
end
