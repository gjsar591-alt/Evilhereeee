--[[
================================================================================
  HAVEN TEAM V2 - INTERCEPTOR / DUMPER
  شغّل هذا السكربت في الـ executor قبل تشغيل السكربت المشفر
  سيعترض جميع الاستدعاءات ويسجلها
================================================================================
--]]

-- ======= الإعدادات =======
local LOG = {} -- كل السجلات
local CAPTURED_URLS = {} -- كل الروابط
local CAPTURED_SOURCE = {} -- أي سورس يتم تحميله
local OUTPUT_FILE = "HAVEN_DUMP.txt" -- اسم ملف الحفظ

-- دالة تسجيل
local function log(category, msg)
    local entry = "[" .. category .. "] " .. tostring(msg)
    table.insert(LOG, entry)
    print(entry) -- يطبع في console الـ executor
end

-- ======= 1. اعتراض HttpGet =======
local oldHttpGet = game.HttpGet
hookfunction(game.HttpGet, function(self, url, ...)
    log("HTTP_GET", url)
    table.insert(CAPTURED_URLS, url)

    -- اجلب الرد الفعلي
    local success, response = pcall(oldHttpGet, self, url, ...)
    if success then
        log("HTTP_RESPONSE", url .. " => " .. tostring(response):sub(1, 500))
        table.insert(CAPTURED_SOURCE, {
            url = url,
            response = response
        })
    else
        log("HTTP_ERROR", url .. " => " .. tostring(response))
    end

    return success and response or nil
end)

-- ======= 2. اعتراض HttpService =======
local HttpService = game:GetService("HttpService")

-- اعتراض JSONDecode
local oldJSONDecode = HttpService.JSONDecode
hookfunction(HttpService.JSONDecode, function(self, str, ...)
    log("JSON_DECODE", tostring(str):sub(1, 500))
    return oldJSONDecode(self, str, ...)
end)

-- اعتراض UrlEncode
local oldUrlEncode = HttpService.UrlEncode
hookfunction(HttpService.UrlEncode, function(self, str, ...)
    log("URL_ENCODE", tostring(str))
    return oldUrlEncode(self, str, ...)
end)

-- ======= 3. اعتراض loadstring (لو يحمل سورس إضافي) =======
local oldLoadstring = loadstring
getgenv().loadstring = function(src, ...)
    log("LOADSTRING", "=== SOURCE CODE LOADED (" .. #src .. " chars) ===")
    log("LOADSTRING_SOURCE", src)
    table.insert(CAPTURED_SOURCE, {
        type = "loadstring",
        source = src
    })
    return oldLoadstring(src, ...)
end

-- ======= 4. اعتراض setclipboard =======
local oldSetclipboard = setclipboard
getgenv().setclipboard = function(data, ...)
    log("CLIPBOARD", tostring(data):sub(1, 1000))
    table.insert(CAPTURED_SOURCE, {
        type = "clipboard",
        data = tostring(data)
    })
    -- لا تنسخ فعلياً - فقط سجّل
    -- اذا تبي ينسخ فعلاً، شيل التعليق من السطر التالي:
    -- return oldSetclipboard(data, ...)
end

-- ======= 5. اعتراض Kick (يمنع الطرد) =======
local Player = game:GetService("Players").LocalPlayer
local oldKick = Player.Kick
hookfunction(Player.Kick, function(self, reason, ...)
    log("KICK_BLOCKED", "Reason: " .. tostring(reason))
    -- لا تطرد اللاعب - فقط سجّل
end)

-- ======= 6. اعتراض error (يمنع Tamper Detected) =======
local oldError = error
getgenv().error = function(msg, ...)
    log("ERROR_BLOCKED", tostring(msg))
    if tostring(msg):find("Tamper") then
        log("TAMPER", "Anti-tamper triggered but BLOCKED!")
        return -- لا ترمي خطأ
    end
    return oldError(msg, ...)
end

-- ======= 7. اعتراض warn =======
local oldWarn = warn
getgenv().warn = function(...)
    local args = {...}
    local msg = ""
    for _, v in ipairs(args) do
        msg = msg .. tostring(v) .. " "
    end
    log("WARN", msg)
    return oldWarn(...)
end

-- ======= 8. مراقبة Instance.new =======
local oldInstanceNew = Instance.new
hookfunction(Instance.new, function(className, ...)
    log("INSTANCE_NEW", className)
    return oldInstanceNew(className, ...)
end)

-- ======= 9. مراقبة GetService =======
local oldGetService = game.GetService
hookfunction(game.GetService, function(self, serviceName, ...)
    log("GET_SERVICE", serviceName)
    return oldGetService(self, serviceName, ...)
end)

-- ======= دالة حفظ النتائج =======
local function dumpResults()
    local output = {}
    table.insert(output, "=" .. string.rep("=", 79))
    table.insert(output, "  HAVEN TEAM V2 - FULL INTERCEPT DUMP")
    table.insert(output, "  Date: " .. os.date())
    table.insert(output, "=" .. string.rep("=", 79))

    -- الروابط
    table.insert(output, "\n\n=== CAPTURED URLs ===")
    for i, url in ipairs(CAPTURED_URLS) do
        table.insert(output, i .. ". " .. url)
    end

    -- السورسات المحملة
    table.insert(output, "\n\n=== CAPTURED SOURCES / RESPONSES ===")
    for i, src in ipairs(CAPTURED_SOURCE) do
        table.insert(output, "\n--- Entry " .. i .. " ---")
        if src.url then
            table.insert(output, "URL: " .. src.url)
            table.insert(output, "Response:\n" .. tostring(src.response))
        elseif src.type == "loadstring" then
            table.insert(output, "Type: loadstring")
            table.insert(output, "Source:\n" .. tostring(src.source))
        elseif src.type == "clipboard" then
            table.insert(output, "Type: clipboard")
            table.insert(output, "Data: " .. tostring(src.data))
        end
    end

    -- كل السجلات
    table.insert(output, "\n\n=== FULL LOG ===")
    for _, entry in ipairs(LOG) do
        table.insert(output, entry)
    end

    local finalOutput = table.concat(output, "\n")

    -- انسخ للحافظة
    if oldSetclipboard then
        oldSetclipboard(finalOutput)
        print("\n\n[DUMPER] ✅ Results copied to clipboard! Paste in notepad.")
    end

    -- احفظ كملف (اذا الـ executor يدعم writefile)
    if writefile then
        writefile(OUTPUT_FILE, finalOutput)
        print("[DUMPER] ✅ Saved to file: " .. OUTPUT_FILE)
    end

    print("[DUMPER] Total logs: " .. #LOG)
    print("[DUMPER] Total URLs: " .. #CAPTURED_URLS)
    print("[DUMPER] Total Sources: " .. #CAPTURED_SOURCE)
end

-- ======= حفظ تلقائي بعد 30 ثانية =======
task.spawn(function()
    task.wait(30)
    log("DUMPER", "Auto-dumping after 30 seconds...")
    dumpResults()
end)

-- ======= أوامر يدوية =======
-- اكتب في console: getgenv().dump() لحفظ النتائج يدوياً
getgenv().dump = dumpResults

-- اكتب: getgenv().showlog() لعرض السجلات
getgenv().showlog = function()
    for _, entry in ipairs(LOG) do
        print(entry)
    end
end

print("=" .. string.rep("=", 59))
print("  [INTERCEPTOR] READY! Now run the HAVEN script.")
print("  Auto-dump in 30 seconds, or type dump() manually")
print("=" .. string.rep("=", 59))
