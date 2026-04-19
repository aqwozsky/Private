local files = {
    {
        name = "gui/guiMain.lua",
        url = "https://raw.githubusercontent.com/aqwozsky/Private/refs/heads/main/gui/guiMain.lua",
    },
    {
        name = "scripts/voidSpamTp.lua",
        url = "https://raw.githubusercontent.com/aqwozsky/Private/refs/heads/main/scripts/voidSpamTp.lua",
    },
}

local httpLoader = game and game.HttpGet
assert(type(httpLoader) == "function", "Cheatwoz loader requires game:HttpGet().")

local compiler = loadstring or load
assert(type(compiler) == "function", "Cheatwoz loader requires loadstring() or load().")

for _, file in ipairs(files) do
    local source = httpLoader(game, file.url)
    local chunk, err = compiler(source, "@" .. file.name)
    assert(chunk, ("Failed to compile %s: %s"):format(file.name, tostring(err)))
    chunk()
end
