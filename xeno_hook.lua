local URLS = {}
local SOURCES = {}
local _clip = setclipboard
local _err = error
local _ls = loadstring
local old
old = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local result = nil
    local handled = false
    if method == "HttpGet" or method == "HttpGetAsync" then
        local url = tostring(select(1, ...))
        warn("[URL] " .. url)
        table.insert(URLS, url)
        local ok, resp = pcall(old, self, ...)
        if ok then
            warn("[RESP] " .. tostring(resp):sub(1, 2000))
            table.insert(SOURCES, tostring(resp))
            if writefile then
                writefile("HAVEN_src_" .. tostring(#SOURCES) .. ".txt", tostring(resp))
            end
        end
        result = resp
        handled = true
    end
    if method == "Kick" then
        warn("[KICK BLOCKED]")
        handled = true
    end
    if method == "JSONDecode" then
        warn("[JSON] " .. tostring(select(1, ...)):sub(1, 500))
    end
    if handled then
        return result
    end
    return old(self, ...)
end)
getgenv().loadstring = function(src)
    local s = tostring(src)
    warn("[LOADSTRING] " .. tostring(#s) .. " chars")
    table.insert(SOURCES, s)
    if writefile then
        writefile("HAVEN_ls_" .. tostring(#SOURCES) .. ".lua", s)
    end
    return _ls(src)
end
getgenv().setclipboard = function(data)
    warn("[CLIP] " .. tostring(data):sub(1, 500))
    table.insert(SOURCES, tostring(data))
end
getgenv().error = function(msg)
    if string.find(tostring(msg), "Tamper") then
        warn("[TAMPER BLOCKED]")
        return
    end
    _err(msg)
end
getgenv().dump = function()
    local r = ""
    for i = 1, #URLS do
        r = r .. "[URL] " .. URLS[i] .. "\n"
    end
    for i = 1, #SOURCES do
        r = r .. "---\n" .. SOURCES[i] .. "\n"
    end
    if writefile then
        writefile("HAVEN_DUMP.txt", r)
    end
    if _clip then
        _clip(r)
    end
    warn("[DUMP DONE]")
end
task.delay(30, getgenv().dump)
warn("[HOOK READY] Run HAVEN now")
