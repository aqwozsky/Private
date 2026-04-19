local files = {
    {
        name = "gui/guiMain.lua",
        url = "https://raw.githubusercontent.com/aqwozsky/Private/main/gui/guiMain.lua",
    },
    {
        name = "scripts/voidSpamTp.lua",
        url = "https://raw.githubusercontent.com/aqwozsky/Private/main/scripts/voidSpamTp.lua",
    },
}

local compiler = loadstring or load
assert(type(compiler) == "function", "Cheatwoz loader requires loadstring() or load().")

local sharedEnv = (type(getgenv) == "function" and getgenv()) or _G
local bootstrapUrl = "https://raw.githubusercontent.com/aqwozsky/Private/main/main.lua"

local function queueBootstrapOnTeleport()
    sharedEnv.CheatwozBootstrapUrl = bootstrapUrl
    sharedEnv.CheatwozBootstrapCode = ('loadstring(game:HttpGet("%s"))()'):format(sharedEnv.CheatwozBootstrapUrl)

    local queueOnTeleport = queue_on_teleport or (syn and syn.queue_on_teleport)

    if type(queueOnTeleport) == "function" then
        queueOnTeleport(sharedEnv.CheatwozBootstrapCode)
    end
end

local function fetchSource(url)
    local errors = {}

    if game and type(game.HttpGet) == "function" then
        local ok, result = pcall(game.HttpGet, game, url)
        if ok and type(result) == "string" and result ~= "" then
            return result
        end
        errors[#errors + 1] = ("game:HttpGet -> %s"):format(tostring(result))
    end

    local requestFn = (syn and syn.request) or (http and http.request) or http_request or request
    if type(requestFn) == "function" then
        local ok, response = pcall(requestFn, {
            Url = url,
            Method = "GET",
        })

        if ok and type(response) == "table" then
            local body = response.Body or response.body
            if type(body) == "string" and body ~= "" then
                return body
            end
            errors[#errors + 1] = ("request -> status %s"):format(tostring(response.StatusCode or response.StatusMessage))
        else
            errors[#errors + 1] = ("request -> %s"):format(tostring(response))
        end
    end

    error(("Failed to fetch remote source from %s (%s)"):format(url, table.concat(errors, ", ")))
end

queueBootstrapOnTeleport()

for _, file in ipairs(files) do
    local source = fetchSource(file.url)
    assert(type(source) == "string" and source ~= "", ("No source returned for %s"):format(file.name))
    local chunk, err = compiler(source, "@" .. file.name)
    assert(chunk, ("Failed to compile %s: %s"):format(file.name, tostring(err)))
    chunk()
end
