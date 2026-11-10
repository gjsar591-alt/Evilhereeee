local LOG = {}
local URLS = {}
local SOURCES = {}
local oldClipboard = setclipboard
local oldError = error

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = table.pack(...)
    if method == "HttpGet" or method == "HttpGetAsync" then
        warn("[URL] " .. tostring(args[1]))
        table.insert(URLS, tostring(args[1]))
        local ok, resp = pcall(oldNamecall, self, ...)
        if ok then
            warn("[RESP] " .. tostring(resp):sub(1, 2000))
            table.insert(SOURCES, {t = "http", url = tostring(args[1]), data = tostring(resp)})
            if writefile then
                writefile("HAVEN_src_" .. tostring(#SOURCES) .. ".lua", tostring(resp))
            end
            return resp
        end
        return oldNamecall(self, ...)
    elseif method == "JSONDecode" then
        warn("[JSON] " .. tostring(args[1]):sub(1, 500))
    elseif method == "Kick" then
        warn("[KICK BLOCKED]")
        return
    end
    return oldNamecall(self, ...)
end))

local oldLs = loadstring
getgenv().loadstring = newcclosure(function(src, name)
    warn("[LOADSTRING] len=" .. tostring(#tostring(src)))
    table.insert(SOURCES, {t = "loadstring", data = tostring(src)})
    if writefile then
        writefile("HAVEN_ls_" .. tostring(#SOURCES) .. ".lua", tostring(src))
    end
    if name then
        return oldLs(src, name)
    end
    return oldLs(src)
end)

getgenv().setclipboard = newcclosure(function(data)
    warn("[CLIP] " .. tostring(data):sub(1, 500))
    table.insert(SOURCES, {t = "clip", data = tostring(data)})
end)

getgenv().error = newcclosure(function(msg, level)
    local m = tostring(msg)
    if string.find(m, "Tamper") then
        warn("[TAMPER BLOCKED]")
        return
    end
    if level then
        return oldError(msg, level)
    end
    return oldError(msg)
end)

getgenv().dump = function()
    local r = ""
    for i, u in ipairs(URLS) do
        r = r .. "[URL " .. i .. "] " .. u .. "\n"
    end
    r = r .. "\n"
    for i, s in ipairs(SOURCES) do
        r = r .. "[" .. s.t .. "] " .. (s.url or "") .. "\n" .. s.data .. "\n---\n"
    end
    if writefile then
        writefile("HAVEN_DUMP.txt", r)
    end
    if oldClipboard then
        oldClipboard(r)
    end
    warn("[DUMP DONE] " .. #URLS .. " urls, " .. #SOURCES .. " sources")
end

task.delay(30, function()
    getgenv().dump()
end)

warn("[HOOK READY] Run HAVEN now. Type dump() to save.")
