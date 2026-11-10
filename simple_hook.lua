--[[
  نسخة مبسطة - اذا الـ executor ما يدعم hookfunction
  شغّل هذا أولاً ثم شغّل السكربت المشفر
--]]

local LOG = {}
local function log(msg) table.insert(LOG, msg) print(msg) end

-- 1. اعتراض loadstring
local _ls = loadstring
getgenv().loadstring = function(src, ...)
    log("[LOADSTRING] " .. #src .. " chars:")
    log(src)
    if writefile then writefile("HAVEN_loadstring_dump.lua", src) end
    if setclipboard then setclipboard(src) end
    return _ls(src, ...)
end

-- 2. اعتراض HttpGet عبر __namecall
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "HttpGet" or method == "HttpGetAsync" then
        log("[HTTP] " .. tostring(args[1]))
        local result = oldNamecall(self, ...)
        log("[HTTP_RESP] " .. tostring(result):sub(1, 2000))
        table.insert(LOG, "[SOURCE]\n" .. tostring(result))
        if writefile then
            writefile("HAVEN_http_" .. #LOG .. ".txt", tostring(result))
        end
        return result

    elseif method == "JSONDecode" then
        log("[JSON] " .. tostring(args[1]):sub(1, 500))

    elseif method == "UrlEncode" then
        log("[URL_ENCODE] " .. tostring(args[1]))

    elseif method == "Kick" then
        log("[KICK BLOCKED] " .. tostring(args[1]))
        return -- block kick

    elseif method == "GetService" then
        log("[SERVICE] " .. tostring(args[1]))
    end

    return oldNamecall(self, ...)
end)

-- 3. اعتراض setclipboard
local _sc = setclipboard
getgenv().setclipboard = function(d)
    log("[CLIPBOARD] " .. tostring(d):sub(1, 1000))
    if writefile then
        writefile("HAVEN_clipboard_" .. #LOG .. ".txt", tostring(d))
    end
end

-- 4. حظر الطرد والأخطاء
local _err = error
getgenv().error = function(msg, ...)
    if tostring(msg):find("Tamper") then
        log("[TAMPER BLOCKED]")
        return
    end
    return _err(msg, ...)
end

-- 5. حفظ
getgenv().dump = function()
    local out = table.concat(LOG, "\n")
    if writefile then writefile("HAVEN_FULL_DUMP.txt", out) end
    if _sc then _sc(out) end
    log("[DUMP] Done! " .. #LOG .. " entries")
end

task.spawn(function()
    task.wait(30)
    dump()
end)

print("[HOOK READY] Execute HAVEN script now. dump() to save.")
