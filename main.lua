local root = "CheatwozPriv"
local files = {
    "gui/guiMain.lua",
    "scripts/voidSpamTp.lua",
}

local fileReader = readfile
assert(type(fileReader) == "function", "Cheatwoz loader requires readfile().")

local compiler = loadstring or load
assert(type(compiler) == "function", "Cheatwoz loader requires loadstring() or load().")

for _, relativePath in ipairs(files) do
    local fullPath = root .. "/" .. relativePath
    local source = fileReader(fullPath)
    local chunk, err = compiler(source, "@" .. relativePath)
    assert(chunk, ("Failed to compile %s: %s"):format(relativePath, tostring(err)))
    chunk()
end
