local LOG = {}
local URLS = {}
local SOURCES = {}

local function log(tag, msg)
    local entry = "[" .. tag .. "] " .. tostring(msg)
    table.insert(LOG, entry)
    warn(entry)
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "HttpGet" or method == "HttpGetAsync" then
        local url = tostring(args[1])
        log("URL", url)
        table.insert(URLS, url)
        local ok, resp = pcall(oldNamecall, self, ...)
        if ok then
            local respStr = tostring(resp)
            log("RESPONSE", url .. "\n" .. respStr:sub(1, 3000))
            table.insert(SOURCES, {type = "http", url = url, data = respStr})
            if respStr:find("function") or respStr:find("local ") or respStr:find("return") then
                log("LUA_SOURCE", "Lua code detected! Length: " .. #respStr)
                if writefile then
                    writefile("HAVEN_source_" .. #SOURCES .. ".lua", respStr)
                end
            end
            return resp
        else
            log("HTTP_ERR", tostring(resp))
            return oldNamecall(self, ...)
        end
    elseif method == "JSONDecode" then
        log("JSON", tostring(args[1]):sub(1, 1000))
    elseif method == "UrlEncode" then
        log("ENCODE", tostring(args[1]))
    elseif method == "Kick" then
        log("KICK", "BLOCKED: " .. tostring(args[1]))
        return nil
    elseif method == "GetService" then
        log("SERVICE", tostring(args[1]))
    end

    return oldNamecall(self, ...)
end))

local oldLoadstring = loadstring
getgenv().loadstring = newcclosure(function(src, ...)
    local srcStr = tostring(src)
    log("LOADSTRING", "Length: " .. #srcStr)
    log("LOADSTRING_CODE", srcStr)
    table.insert(SOURCES, {type = "loadstring", data = srcStr})
    if writefile then
        writefile("HAVEN_loadstring_" .. #SOURCES .. ".lua", srcStr)
    end
    return oldLoadstring(src, ...)
end)

local oldClipboard = setclipboard
getgenv().setclipboard = newcclosure(function(data)
    local str = tostring(data)
    log("CLIPBOARD", str:sub(1, 2000))
    table.insert(SOURCES, {type = "clipboard", data = str})
    if writefile then
        writefile("HAVEN_clip_" .. #SOURCES .. ".txt", str)
    end
end)

local oldError = error
getgenv().error = newcclosure(function(msg, ...)
    local m = tostring(msg)
    if m:find("Tamper") or m:find("tamper") then
        log("TAMPER", "BLOCKED: " .. m)
        return
    end
    return oldError(msg, ...)
end)

function getgenv().dump()
    local out = {}
    table.insert(out, "=== URLS ===")
    for i, u in ipairs(URLS) do
        table.insert(out, i .. ") " .. u)
    end
    table.insert(out, "\n=== SOURCES ===")
    for i, s in ipairs(SOURCES) do
        table.insert(out, "--- [" .. i .. "] " .. s.type .. " ---")
        if s.url then table.insert(out, "URL: " .. s.url) end
        table.insert(out, s.data)
    end
    table.insert(out, "\n=== LOG ===")
    for _, e in ipairs(LOG) do
        table.insert(out, e)
    end
    local result = table.concat(out, "\n")
    if writefile then
        writefile("HAVEN_FULL_DUMP.txt", result)
    end
    if oldClipboard then
        oldClipboard(result)
    end
    warn("[DUMP] Done! URLs: " .. #URLS .. " Sources: " .. #SOURCES)
end

task.spawn(function()
    task.wait(30)
    getgenv().dump()
end)

warn("[HOOK READY] Execute HAVEN script now. dump() to save.")
