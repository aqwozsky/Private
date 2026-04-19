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
local currentJobId = game.JobId or ""

local function queueBootstrapOnTeleport()
    if sharedEnv.CheatwozQueuedFromJobId == currentJobId and currentJobId ~= "" then
        warn("Cheatwoz: already queued for this server, skipping.")
        return
    end

    sharedEnv.CheatwozQueuedFromJobId = nil
    sharedEnv.CheatwozTeleportQueued = false
    sharedEnv.CheatwozTeleportQueueMethod = nil

    local bootstrapCode = ('loadstring(game:HttpGet("%s"))()'):format(bootstrapUrl)
    sharedEnv.CheatwozBootstrapUrl = bootstrapUrl
    sharedEnv.CheatwozBootstrapCode = bootstrapCode

    local queueFunctions = {
        { name = "queue_on_teleport",        fn = type(queue_on_teleport) == "function" and queue_on_teleport },
        { name = "queueonteleport",          fn = type(queueonteleport) == "function" and queueonteleport },
        { name = "syn.queue_on_teleport",    fn = syn and type(syn.queue_on_teleport) == "function" and syn.queue_on_teleport },
        { name = "fluxus.queue_on_teleport", fn = fluxus and type(fluxus.queue_on_teleport) == "function" and fluxus.queue_on_teleport },
    }

    local queued = false
    for _, entry in ipairs(queueFunctions) do
        if entry.fn then
            local ok, err = pcall(entry.fn, bootstrapCode)
            if ok then
                sharedEnv.CheatwozQueuedFromJobId = currentJobId
                sharedEnv.CheatwozTeleportQueued = true
                sharedEnv.CheatwozTeleportQueueMethod = entry.name
                print(("Cheatwoz: queued via %s (JobId: %s)"):format(entry.name, currentJobId))
                queued = true
                break
            else
                warn(("Cheatwoz: %s failed -> %s"):format(entry.name, tostring(err)))
            end
        end
    end

    if not queued then
        warn("Cheatwoz: NO queue_on_teleport function found! Auto-load will NOT work after server change.")
        warn("Cheatwoz: Make sure your executor supports queue_on_teleport.")
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
        local ok, response = pcall(requestFn, { Url = url, Method = "GET" })
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

-- Queue FIRST before loading scripts, so even if a script errors the queue is set
queueBootstrapOnTeleport()

for _, file in ipairs(files) do
    local ok, err = pcall(function()
        local source = fetchSource(file.url)
        assert(type(source) == "string" and source ~= "", ("No source returned for %s"):format(file.name))
        local chunk, compileErr = compiler(source, "@" .. file.name)
        assert(chunk, ("Failed to compile %s: %s"):format(file.name, tostring(compileErr)))
        chunk()
    end)
    if not ok then
        warn(("Cheatwoz: failed to load %s -> %s"):format(file.name, tostring(err)))
    end
end
