--[[
  HAVEN V2 - Source Extractor (Xeno Executor)
  1. شغّل هذا السكربت
  2. شغّل سكربت HAVEN المشفر
  3. انتظر 30 ثانية أو اكتب dump() في الكونسول
--]]

local LOG = {}
local URLS = {}
local SOURCES = {}

local function log(tag, msg)
    local entry = "[" .. tag .. "] " .. tostring(msg)
    table.insert(LOG, entry)
    warn(entry)
end

-- ======= اعتراض __namecall (الطريقة الأساسية في Xeno) =======
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- اعتراض HttpGet
    if method == "HttpGet" or method == "HttpGetAsync" then
        local url = tostring(args[1])
        log("URL", url)
        table.insert(URLS, url)

        local ok, resp = pcall(oldNamecall, self, ...)
        if ok then
            local respStr = tostring(resp)
            log("RESPONSE", url .. "\n" .. respStr:sub(1, 3000))
            table.insert(SOURCES, {
                type = "http",
                url = url,
                data = respStr
            })
            -- اذا الرد كود Lua، احفظه مباشرة
            if respStr:find("function") or respStr:find("local ") or respStr:find("return") then
                log("LUA_SOURCE", "Detected Lua code in response! Length: " .. #respStr)
                if writefile then
                    writefile("HAVEN_source_" .. #SOURCES .. ".lua", respStr)
                end
            end
            return resp
        else
            log("HTTP_ERR", tostring(resp))
            return oldNamecall(self, ...)
        end

    -- اعتراض JSONDecode
    elseif method == "JSONDecode" then
        log("JSON", tostring(args[1]):sub(1, 1000))

    -- اعتراض UrlEncode
    elseif method == "UrlEncode" then
        log("ENCODE", tostring(args[1]))

    -- حظر Kick
    elseif method == "Kick" then
        log("KICK", "BLOCKED: " .. tostring(args[1]))
        return nil

    -- تسجيل GetService
    elseif method == "GetService" then
        log("SERVICE", tostring(args[1]))
    end

    return oldNamecall(self, ...)
end))

-- ======= اعتراض loadstring =======
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

-- ======= اعتراض setclipboard =======
local oldClipboard = setclipboard
getgenv().setclipboard = newcclosure(function(data)
    local str = tostring(data)
    log("CLIPBOARD", str:sub(1, 2000))
    table.insert(SOURCES, {type = "clipboard", data = str})
    if writefile then
        writefile("HAVEN_clip_" .. #SOURCES .. ".txt", str)
    end
end)

-- ======= حظر error (Tamper Detected) =======
local oldError = error
getgenv().error = newcclosure(function(msg, ...)
    local m = tostring(msg)
    if m:find("Tamper") or m:find("tamper") then
        log("TAMPER", "BLOCKED: " .. m)
        return
    end
    return oldError(msg, ...)
end)

-- ======= اعتراض warn =======
local oldWarn = warn
getgenv().warn = newcclosure(function(...)
    local args = {...}
    local msg = ""
    for _, v in pairs(args) do msg = msg .. tostring(v) .. " " end
    table.insert(LOG, "[WARN] " .. msg)
    return oldWarn(...)
end)

-- ======= دالة الحفظ =======
function getgenv().dump()
    local out = {}
    table.insert(out, string.rep("=", 60))
    table.insert(out, "  HAVEN V2 - EXTRACTED DATA (Xeno)")
    table.insert(out, "  URLs: " .. #URLS .. " | Sources: " .. #SOURCES .. " | Logs: " .. #LOG)
    table.insert(out, string.rep("=", 60))

    table.insert(out, "\n\n=== ALL URLs ===")
    for i, u in ipairs(URLS) do
        table.insert(out, i .. ") " .. u)
    end

    table.insert(out, "\n\n=== CAPTURED DATA ===")
    for i, s in ipairs(SOURCES) do
        table.insert(out, "\n--- [" .. i .. "] Type: " .. s.type .. " ---")
        if s.url then table.insert(out, "URL: " .. s.url) end
        table.insert(out, s.data)
    end

    table.insert(out, "\n\n=== FULL LOG ===")
    for _, e in ipairs(LOG) do
        table.insert(out, e)
    end

    local result = table.concat(out, "\n")

    if writefile then
        writefile("HAVEN_FULL_DUMP.txt", result)
        warn("[DUMP] Saved to workspace/HAVEN_FULL_DUMP.txt")
    end

    if oldClipboard then
        oldClipboard(result)
        warn("[DUMP] Copied to clipboard - paste in notepad!")
    end

    warn("[DUMP] Done! URLs: " .. #URLS .. " | Sources: " .. #SOURCES)
end

-- حفظ تلقائي بعد 30 ثانية
task.spawn(function()
    task.wait(30)
    warn("[AUTO-DUMP] Saving results...")
    getgenv().dump()
end)

warn(string.rep("=", 50))
warn("  [XENO HOOK] READY!")
warn("  Now execute the HAVEN script")
warn("  Auto-dump in 30 sec | Manual: dump()")
warn(string.rep("=", 50))
