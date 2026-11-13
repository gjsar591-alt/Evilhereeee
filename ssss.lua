(function()
  if not game:IsLoaded() then game.Loaded:Wait() end

  -- توافق مع كل المنفذات: بديل لو getgenv غير موجودة
  local getgenv = getgenv or function() return (getfenv and getfenv(0)) or _G end

  -- حماية من التشغيل مرتين بنفس الوقت (مثلاً السكربت في autoexec وشغّلته بعد يدوياً): النسخة الثانية تطلع
  do
    local env = getgenv()
    local startedAt = tonumber(env.HavenHubStartedAt)
    -- الحارس يخص السيرفر اللي شغّلنا فيه فقط: بعد الريجوين الـ JobId يتغير فالسكربت يرجع يشتغل
    if shared.VertexLoaded == true or (startedAt and env.HavenHubStartedJob == game.JobId and os.clock() - startedAt < 60) then return end
    env.HavenHubStartedAt = os.clock()
    env.HavenHubStartedJob = game.JobId
  end

  local Services = setmetatable({}, {
    __index = function(self, k)
      local s = game:GetService(k)
      rawset(self, k, s)
      return s
    end
  })
  getgenv().Services = Services

  local Players = Services.Players
  local LocalPlayer = Players.LocalPlayer
  local TweenService = Services.TweenService
  local RunService = Services.RunService
  local HttpService = Services.HttpService
  local UserInputService = Services.UserInputService
  local ReplicatedStorage = Services.ReplicatedStorage

  -- الإغلاق الكامل: كل اتصال (Connect) يتم عبر هذي الخدمات ينحفظ هنا عشان ينفصل كله عند الإغلاق
  local HavenConnections = {}
  local function TrackedService(real)
    return setmetatable({}, {__index = function(_, key)
      local value = real[key]
      if typeof(value) == "RBXScriptSignal" then
        return {
          Connect = function(_, fn) local conn = value:Connect(fn) table.insert(HavenConnections, conn) return conn end,
          Wait = function() return value:Wait() end
        }
      elseif type(value) == "function" then
        return function(_, ...) return value(real, ...) end
      end
      return value
    end})
  end
  Players = TrackedService(Players)
  RunService = TrackedService(RunService)
  UserInputService = TrackedService(UserInputService)

  -- توافق مع كل المنفذات: يجرب gethui ثم CoreGui ثم PlayerGui
  -- اللغة: تنختار من نافذة قبل التحميل (تحت). HavenT يترجم أسماء الأزرار والقوائم والتبويبات لو اللغة عربي.
  -- خيارات القوائم المنسدلة والتنبيهات تبقى إنجليزي (الكود يقارن خيارات القوائم بنصها)
  local HavenLanguage = "English"
  local HavenArabic = {
    ["Enable Coin Auto-Farm"] = "تشغيل الأوتو فارم",
    ["Kill Everyone When Bag Is Full"] = "اقتل الكل لما تمتلي الحقيبة",
    ["Shoot Murderer When Bag Is Full"] = "أطلق على القاتل لما تمتلي الحقيبة",
    ["Fling Murderer When Bag Is Full"] = "فلنق للقاتل لما تمتلي الحقيبة",
    ["Survivor: Kill Zombies When Bag Is Full"] = "ناجي: فلنق للزومبي لما تمتلي الحقيبة",
    ["Zombie Mode: Reset When Bag Is Full"] = "طور الزومبي: ريسيت لما تمتلي الحقيبة",
    ["Zombie: Kill Survivors When Bag Is Full"] = "زومبي: اقتل الناجين لما تمتلي الحقيبة",
    ["Auto Grab Dropped Gun"] = "التقاط المسدس الطايح تلقائياً",
    ["Knife Dodge"] = "تفادي السكين",
    ["Auto Finish Round"] = "إنهاء الجولة تلقائياً",
    ["Show Map Vote Panel"] = "إظهار لوحة التصويت",
    ["Fling Player"] = "فلنق للاعب",
    ["Spectate Player"] = "مراقبة اللاعب",
    ["Stick To Player"] = "الالتصاق باللاعب",
    ["Fling The Sheriff"] = "فلنق للشريف",
    ["Fling The Murderer"] = "فلنق للقاتل",
    ["Advanced ESP"] = "ESP متطور",
    ["Skeleton"] = "الهيكل العظمي",
    ["Box"] = "المربع",
    ["Info Tag (Name / Role / Distance / HP)"] = "بطاقة المعلومات (الاسم / الدور / المسافة / الصحة)",
    ["Gun Drop ESP"] = "ESP المسدس الطايح",
    ["Hide MM2 Popups"] = "إخفاء نوافذ اللعبة",
    ["Hide End-Of-Round Screens"] = "إخفاء شاشات نهاية الجولة",
    ["Stop Rendering When Unfocused"] = "إيقاف الرسم لما تطلع من اللعبة",
    ["Name ESP"] = "ESP الأسماء",
    ["Spam Emote"] = "تكرار الرقصة",
    ["Kill Aura"] = "هالة القتل",
    ["Kill All Players"] = "اقتل كل اللاعبين",
    ["Knife Throw Auto Aim"] = "تصويب تلقائي لرمية السكين",
    ["Show Knife Aim Button"] = "إظهار زر تصويب السكين",
    ["Hitbox Expander (Enemies)"] = "تكبير الهيت بوكس (الخصوم)",
    ["Silent Aim"] = "سايلنت ايم",
    ["Instant Kill Murderer"] = "قتل القاتل فوراً",
    ["Auto Shoot On Sight"] = "إطلاق تلقائي عند الرؤية",
    ["Aim Lock"] = "ايم لوك",
    ["Aim Lock Wall Check"] = "فحص الجدران للايم لوك",
    ["Team Check (Skip Teammates)"] = "تيم تشيك (تجاهل الزملاء)",
    ["Show Aim Lock Button"] = "إظهار زر الايم لوك",
    ["Coin Tracker"] = "متتبع العملات",
    ["Unbox Notification"] = "إشعار فتح الصناديق",
    ["Walk Speed"] = "سرعة المشي",
    ["Jump Power"] = "قوة القفز",
    ["Anti Fling"] = "مضاد الفلنق",
    ["Anti-Stealer (Block Trades)"] = "مضاد السرقة (حظر التبادل)",
    ["Farm Speed"] = "سرعة الفارم",
    ["Skeleton Thickness"] = "سماكة الهيكل",
    ["Kill Aura Range"] = "مدى هالة القتل",
    ["Hitbox Size"] = "حجم الهيت بوكس",
    ["Aim Lock Smoothness"] = "نعومة الايم لوك",
    ["Knife Aim Hotkey"] = "اختصار تصويب السكين",
    ["Shoot Murderer Hotkey"] = "اختصار إطلاق على القاتل",
    ["Aim Lock Hotkey"] = "اختصار الايم لوك",
    ["Invisible [FE]"] = "اختفاء [FE]",
    ["AUTO FARMING & COLLECTION"] = "الأوتو فارم والتجميع",
    ["ZOMBIE MODE"] = "طور الزومبي",
    ["ROUND ASSISTS"] = "مساعدات الجولة",
    ["QUICK TELEPORTS"] = "انتقالات سريعة",
    ["MAP VOTE"] = "تصويت المابات",
    ["CHOSEN PLAYER"] = "اللاعب المختار",
    ["ESP OPTIONS"] = "خيارات ESP",
    ["ESP SETTINGS"] = "إعدادات ESP",
    ["MM2 INTERFACE"] = "واجهة اللعبة",
    ["MURDERER MODE"] = "وضع القاتل",
    ["SHERIFF MODE"] = "وضع الشريف",
    ["AIM LOCK"] = "ايم لوك",
    ["DISCORD WEBHOOK INTEGRATION"] = "ربط ويب هوك ديسكورد",
    ["COIN TRACKER IS TURNED OFF"] = "متتبع العملات مطفي",
    ["CHARACTER MODIFIERS"] = "تعديلات الشخصية",
    ["Farm Style"] = "نوع الفارم",
    ["Farm Target"] = "هدف الفارم",
    ["Teleport To Lobby"] = "انتقال للوبي",
    ["Teleport To Map"] = "انتقال للماب",
    ["Scan Map Vote (Copy Info)"] = "فحص التصويت (نسخ المعلومات)",
    ["Choose Player"] = "اختر لاعب",
    ["Teleport To Player"] = "انتقال للاعب",
    ["Go To Murderer"] = "روح للقاتل",
    ["Go To Sheriff"] = "روح للشريف",
    ["Show ESP For"] = "إظهار ESP لـ",
    ["ESP Player"] = "لاعب ESP",
    ["Box Style"] = "شكل المربع",
    ["Skeleton Color"] = "لون الهيكل",
    ["Murderer Color"] = "لون القاتل",
    ["Sheriff Color"] = "لون الشريف",
    ["Innocent Color"] = "لون البريء",
    ["Pick Emote"] = "اختر رقصة",
    ["Knife Aim Target"] = "هدف تصويب السكين",
    ["Aim Lock Target"] = "هدف الايم لوك",
    ["Aim Lock Player"] = "لاعب الايم لوك",
    ["Aim Lock Part"] = "جزء الايم لوك",
    ["Webhook URL"] = "رابط الويب هوك",
    ["Send Test Webhook"] = "إرسال ويب هوك تجريبي",
    ["Minutes To Send Webhook"] = "الدقايق بين كل إرسال",
    ["Auto Farm"] = "أوتو فارم",
    ["Farm"] = "فارم",
    ["Combat"] = "قتال",
    ["Player Target"] = "استهداف لاعب",
    ["Target"] = "هدف",
    ["ESP & Visuals"] = "ESP والمرئيات",
    ["ESP"] = "ESP",
    ["My Character"] = "شخصيتي",
    ["Player"] = "اللاعب",
    ["Discord Webhooks"] = "ويب هوك ديسكورد",
    ["Discord"] = "ديسكورد",
    ["Settings"] = "الإعدادات",
    ["Config"] = "إعدادات",
    ["REJOIN & SERVERS"] = "الريجوين والسيرفرات",
    ["Script Link"] = "رابط السكربت",
    ["Auto Rejoin When Kicked"] = "ريجوين تلقائي لما تنطرد",
    ["Hop When Server Is Empty"] = "انتقل لما السيرفر يفضى",
    ["Hop When Players Are"] = "انتقل لما اللاعبين",
    ["Rejoin Now"] = "ريجوين الآن",
    ["Hop To Another Server"] = "انتقل لسيرفر ثاني",
  }
  local function HavenT(text)
    if HavenLanguage ~= "Arabic" or type(text) ~= "string" then return text end
    return HavenArabic[text] or text
  end

  -- سجل آخر حركات السكربت (انتقال، طلقة من بعيد...) ينحفظ في HavenHub/last_actions.txt
  -- عشان لو اللعبة طردتك (Invalid position) نعرف أي أمر كان شغال قبل الطرد بلحظة
  local actionLog, actionSavedAt = {}, 0
  local function Mark(action, force)
    local line = string.format("%s  %s", os.date("%H:%M:%S"), action)
    local changed = actionLog[#actionLog] == nil or string.sub(actionLog[#actionLog], 11) ~= action
    if changed then table.insert(actionLog, line) else actionLog[#actionLog] = line end
    if #actionLog > 60 then table.remove(actionLog, 1) end
    -- الكتابة على القرص توقف الفريمات، فنكتب كل 5 ثواني بس (إلا الخطوات المهمة: فوراً، عشان لو كرشت نعرف آخر خطوة)
    if force or os.clock() - actionSavedAt > 5 then
      actionSavedAt = os.clock()
      pcall(function() if writefile then writefile("HavenHub/last_actions.txt", table.concat(actionLog, "\n")) end end)
    end
  end


  -- كل واجهات السكربت (غير شاشة التحميل) تبقى مخفية لين يخلص التحميل، ثم ShowPendingGuis يظهرها
  local pendingGuis, guisReady = {}, false
  local function HideUntilReady(guiObj)
    if guisReady or guiObj.Name == "HavenHubLoader" or guiObj.Name == "HavenHubLanguage" then return end
    pcall(function() guiObj.Enabled = false table.insert(pendingGuis, guiObj) end)
  end
  local function ShowPendingGuis()
    guisReady = true
    for _, guiObj in ipairs(pendingGuis) do pcall(function() guiObj.Enabled = true end) end
    pendingGuis = {}
  end
  local function SafeParentGui(guiObj)
    HideUntilReady(guiObj)
    local targets = {
      function() return gethui and gethui() end,
      function() local cg = game:GetService("CoreGui") return (cloneref and cloneref(cg)) or cg end,
      function() return LocalPlayer:WaitForChild("PlayerGui") end
    }
    for _, getTarget in ipairs(targets) do
      local ok = pcall(function()
        local target = getTarget()
        if typeof(target) ~= "Instance" then error("no target") end
        guiObj.Parent = target
      end)
      if ok and guiObj.Parent then return true end
    end
    return false
  end
  -- فك ترميز Base64 (للشعار والأصوات المدمجة داخل السكربت)
  local function HavenDecodeBase64(data)
    local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local map = {}
    for i = 1, 64 do map[string.byte(alphabet, i)] = i - 1 end
    local out, count = {}, 0
    for i = 1, #data, 4 do
      local a, b, c, d = string.byte(data, i, i + 3)
      local v1, v2, v3, v4 = map[a], map[b], map[c], map[d]
      if not v1 or not v2 then break end
      local n = v1 * 262144 + v2 * 4096 + (v3 or 0) * 64 + (v4 or 0)
      local b1, b2, b3 = math.floor(n / 65536), math.floor(n / 256) % 256, n % 256
      count = count + 1
      if v3 and v4 then out[count] = string.char(b1, b2, b3)
      elseif v3 then out[count] = string.char(b1, b2)
      else out[count] = string.char(b1) end
    end
    return table.concat(out)
  end

  local HavenLib = (function()
    local haven = {Options = {}, Folder = "HavenHub"}
    getgenv().Options = getgenv().Options or {}

    local windowState = true
    local acrylicBlur = true
    local hasGlobalSetting = false
    local tabs = {}
    local currentTabInstance = nil
    local tabIndex = 0

    local Theme = {
      BaseBg          = Color3.fromRGB(10, 10, 11),
      SidebarBg       = Color3.fromRGB(6, 6, 7),
      SectionBg       = Color3.fromRGB(15, 15, 17),
      CardBg          = Color3.fromRGB(22, 22, 25),
      CardHover       = Color3.fromRGB(34, 24, 27),
      PromptBg        = Color3.fromRGB(13, 13, 15),
      Accent          = Color3.fromRGB(225, 29, 46),
      AccentSecondary = Color3.fromRGB(255, 92, 104),
      ToggleOff       = Color3.fromRGB(36, 36, 40),
      ToggleHeadOff   = Color3.fromRGB(140, 140, 146),
      StrokeIdle      = Color3.fromRGB(52, 52, 58),
      StrokeHover     = Color3.fromRGB(225, 29, 46),
      Text            = Color3.fromRGB(255, 255, 255),
      SubText         = Color3.fromRGB(165, 165, 172)
    }

    local assets = {
      interFont       = "rbxassetid://12187365364",
      userInfoBlurred = "rbxassetid://18824089198",
      buttonImage     = "rbxassetid://10709791437",
      shadowImage     = "rbxassetid://1316045217",
      settingsImage   = "rbxassetid://10734950309",
      chevronImage    = "rbxassetid://10709790948"
    }

    local function Tween(inst, info, props)
      return TweenService:Create(inst, info, props)
    end

    local function Create(className, props, children)
      local inst = Instance.new(className)
      for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
      end
      for _, child in ipairs(children or {}) do
        child.Parent = inst
      end
      if props and props.Parent then inst.Parent = props.Parent end
      return inst
    end

    local function InterFont(weight)
      return Font.new(assets.interFont, weight, Enum.FontStyle.Normal)
    end

    -- أصوات الواجهة: أصوات خاصة مدمجة داخل السكربت (WAV)، ولو المشغل ما يدعم الملفات نرجع لأصوات Roblox المدمجة
    local SoundData = {
      click = table.concat({
        "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",
        "xwsoDGkMiAyJDGsMMQzdC3IL9ApkCsgJIgl3CMoHIAd7BuAFUgXUBGkEEwTUA68DpAO0A94DJASEBPwEjAUxBugGrweDCGAJQwooCwwM6gy/DYcOQA/lD3MQ",
        "6RBEEYERoRGhEYERQRHhEGMQyA8RD0EOWg1fDFMLOQoWCewHwAaUBW4ETwM8AjgBRQBo/6D+8P1Z/d38fPw3/Az8+/sC/CH8Vfyc/PP8V/3G/Tv+tP4u/6T/",
        "EwB6ANQAHgFXAX0BjAGEAWQBKwHZAG4A7P9S/6L+3v0I/SP8Mvs3+jb5Mvgv9y/2NvVH9GbzlvLZ8THxofAr8M/vkO9t72bvfe+v7/zvY/Dh8HTxG/LS8pfz",
        "ZvQ99Rj29PbN96H4bfku+uH6hPsV/JL8+/xN/Yr9sP2//bn9n/1y/TP95fyJ/CT8tvtE+9D6XPrt+YX5JvnU+JH4X/hA+Db4Q/hm+KL49fhh+eP5ffor++37",
        "wfyl/ZX+kP+RAJgBoQKoA6oEpQWWBnoHTQgPCb4JVgrYCkILkwvMC+wL8wvjC70Lggs0C9UKaArvCWwJ4ghVCMYHOQexBjAGuAVMBe4EnwRiBDYEHQQYBCYE",
        "RwR7BMAEFQV6BesFZgbqBnQHAgiQCBsJowkiCpgKAQtbC6UL3Av+CwwMAwzjC6wLXwv6CoAK8glQCZ0I2gcLBzAGTQVlBHkDjgKlAcEA5/8V/1D+mv30/F/8",
        "3vtx+xj71Pqk+on6gfqL+qf60voK+077m/vu+0f8ofz6/FH9ov3r/Sv+X/6F/pz+o/6Z/n7+UP4R/sD9X/3u/G784vtK+6n6AfpV+ab4+PdM96b2CPZz9ev0",
        "cfQH9K/zavM68x7zF/Mm80vzhPPR8zH0o/Qk9bT1UPb19qL3VfgK+b/5cvoh+8n7aPz9/IX9//1q/sX+D/9I/3D/h/+O/4b/b/9M/x3/5P6k/l7+Ff7L/YL9",
        "PP38/MT8lfxy/Fv8U/xb/HP8nPzX/CL9f/3t/Wr+9f6O/zEA3wCVAVECEAPQA5AESwUBBq8GVAfsB3YI8ghdCbYJ/gkyClMKYQpdCkYKHwroCaIJTwnxCIkI",
        "GwinBzAHuQZDBtAFYwX+BKEETwQJBNADpAOHA3gDdwOFA6EDyQP+AzwEhATUBCgFgQXbBTUGjAbeBioHbgenB9UH9QcHCAkI+gfbB6sHagcYB7YGRAbEBTgF",
        "nwT9A1MDowLvATkBhADR/yL/ev7a/UT9ufw7/Mv7a/sZ+9j6p/qG+nT6cvp9+pb6uvro+h/7XPuf++T7K/xw/LP88fwp/Vn9gP2c/az9sf2o/ZL9b/0//QL9",
        "ufxl/Af8ofs0+8H6S/rT+Vv55fhz+Af4o/dI9/j2tPZ+9lf2P/Y29j/2V/aA9rj2//ZV97f3Jvie+B/5p/k0+sT6Vfvm+3T8/fyB/f39b/7Y/jX/hv/K/wAA",
        "KgBHAFcAWwBTAEEAJgADANr/rP97/0j/Fv/m/rr+k/50/l3+T/5N/lb+a/6N/rz++P5B/5b/9v9gANUAUQHVAV0C6QJ3AwUEkQQZBZwFGAaLBvQGUgejB+cH",
        "HQhFCF4IaAhkCFEIMQgFCM0HiwdAB+4GlQY5BtsFewUdBcEEagQYBM0DigNQAyED/ALiAtMCzwLWAucCAgMmA1EDgwO7A/UDMgRwBKwE5gQcBUsFdAWUBaoF",
        "tgW2BakFkAVqBTcF9wSrBFME8AODAw0DkAIMAoUB+gBuAOT/Wv/V/lT+2/1p/QH9o/xQ/An8zvuf+337aPte+2D7bPuC+6D7xvvy+yL8VvyK/L/88/wj/U/9",
        "df2V/az9u/3B/b39r/2X/XT9Sf0U/db8kfxG/PX7oPtJ+/H6mfpD+vD5o/lb+Rz55fi4+JX4f/h0+Hb4hPig+Mf4+vg5+YL51Pkv+pH6+Ppk+9P7Q/yz/CH9",
        "jP3z/VP+rf4A/0n/if+//+v/DAAkADIANgAyACYAEgD6/93/vP+Z/3X/Uv8y/xT//P7p/t3+2f7e/uz+BP8l/1H/hv/G/w0AXQC1ABQBeAHhAUwCuQImA5ED",
        "+gNfBL8EFwVoBbAF7wUjBkwGagZ8BoMGfwZwBlcGNAYJBtYFnAVdBRsF1QSOBEcEAgS/A4ADRgMSA+UCvwKhAosCfgJ6An0CiQKdArcC1wL9AiYDUwOBA68D",
        "3AMIBC8EUwRwBIcElQScBJkEjAR1BFUEKgT1A7cDbwMgA8kCawIIAqIBOAHMAGAA9/+O/yn/yf5v/hz+0P2N/VL9If36/Nz8yPy9/Lv8wfzO/OL8/Pwa/Tv9",
        "X/2D/aj9y/3r/Qj+IP4y/j7+Q/5B/jf+Jv4M/uv9wv2T/V79I/3j/KD8W/wU/M77iPtF+wb7y/qW+mj6Qfoi+g36Afr/+Qf6GPoz+lj6hfq6+vf6OvuD+9D7",
        "IPxy/MX8GP1q/bj9A/5K/or+xf75/iX/Sv9m/3z/if+P/4//iP97/2r/Vv8+/yX/C//y/tr+xf60/qf+oP6f/qX+s/7I/uX+Cv82/2v/pv/o/y4AewDMACAB",
        "dwHOASUCewLOAh4DaQOvA+8DJwRXBIAEoAS2BMUEygTHBLwEqQSPBG8ESgQhBPQDxQOVA2UDNgMJA98CuAKWAnkCYgJSAkcCQwJGAk8CXwJ0Ao4CrALOAvMC",
        "GQNAA2cDjQOxA9ED7QMEBBUEHwQjBB4EEgT+A+IDvgOSA14DJAPkAp4CVAIGArYBZAESAcAAcAAiANn/k/9S/xf/4/61/o7+b/5X/kb+PP45/jv+RP5Q/mH+",
        "dP6K/qH+t/7O/uL+9P4C/wz/Ef8R/wz/AP/u/tb+t/6T/mn+Ov4H/tD9l/1b/R794fyl/Gv8M/z/+9D7pvuC+2X7Tvs/+zj7OftB+1H7aPuG+6r71PsC/DX8",
        "a/yj/N38Fv1Q/Yj9vf3v/R7+SP5t/o3+p/67/sn+0f7U/tL+y/7A/rH+oP6M/nj+Y/5P/j3+LP4f/hb+Ef4S/hj+JP43/lD+b/6V/sH+8v4p/2T/pP/m/yoA",
        "cAC3AP4ARAGHAccBBAI8Am8CnQLEAuUC/wITAyADJgMmAyADFQMFA/EC2QK/AqMChgJqAk4CMwIbAgYC9AHnAd4B2gHbAeEB7AH8ARECKgJGAmYCiQKtAtIC",
        "9wIcAz8DYAN+A5gDrgO/A8oDzwPOA8YDuAOkA4kDaANBAxYD5QKxAnkCPwIEAsgBiwFQARYB3wCrAHoATgAmAAQA6P/Q/73/sP+o/6X/pv+r/7P/vv/K/9j/",
        "5v/0/wAACgASABcAGAAVAA0AAQDw/9r/vv+e/3n/UP8j//L+v/6K/lT+Hv7o/bP9gP1P/SL9+fzU/LX8m/yH/Hj8cPxu/HH8evyJ/Jz8tPzP/O78D/0y/Vb9",
        "ev2d/b/94P3+/Rj+MP5D/lL+Xf5k/mb+ZP5e/lT+R/44/ib+Ev7+/en91f3C/bL9o/2Y/ZD9jf2P/ZX9oP2x/cf94v0D/ij+Uv5//rD+5P4Z/1H/if/B//j/",
        "LQBhAJIAwADqAA8BMQFNAWQBdwGEAY0BkQGRAY0BhgF8AW8BYgFTAUQBNgEpAR0BFAEOAQoBCwEPARcBIwEzAUgBXwF7AZkBugHdAQICJwJNAnIClgK5AtkC",
        "9gIPAyUDNgNCA0kDSwNIAz8DMgMgAwkD7gLPAq4CiQJjAjwCEwLrAcQBngF5AVcBOAEcAQQB7wDfANIAyQDEAMIAxADJANAA2ADiAO0A+QADAQ0BFQEbAR4B",
        "HgEaARMBCAH4AOQAzACwAJAAbABGABwA8f/D/5T/Zf81/wf/2v6u/oX+X/49/h7+BP7u/dz9z/3H/cP9w/3H/c792f3m/fb9B/4Z/iz+Pv5Q/mD+b/57/oX+",
        "jP6Q/pH+jv6I/n/+cv5j/lH+Pf4n/hD++f3h/cr9tP2f/Y39ff1x/Wf9Yv1h/WT9a/13/Yf9m/2z/c/97v0Q/jX+W/6D/qv+1P78/iP/Sf9t/47/rf/I/+H/",
        "9f8FABMAHQAkACcAKAAmACIAHAAVAA4ABwAAAPr/9v/z//L/9P/5/wEADAAbAC0AQwBbAHcAlQC2ANgA/AAhAUYBawGPAbIB0wHyAQ4CJwI9Ak8CXgJoAm4C",
        "cAJuAmkCXwJTAkQCMwIfAgoC9AHeAccBsgGdAYoBeAFpAVwBUgFLAUcBRQFGAUoBUQFZAWQBcAF8AYoBlwGkAbEBuwHEAcsBzwHRAc8ByQHAAbQBpAGQAXkB",
        "XwFCASIBAAHdALgAkwBtAEcAIgAAAN7/vv+h/4b/bv9Z/0j/Ov8v/yj/I/8h/yL/Jf8p/y//Nv8+/0X/TP9S/1f/W/9c/1v/WP9S/0n/Pf8v/x//C//2/t/+",
        "xv6s/pL+d/5c/kL+Kf4R/vz96P3Y/cr9wP25/bX9tf25/b/9yv3X/ef9+f0O/iT+PP5U/m3+hv6e/rX+y/7g/vL+Av8Q/xz/Jf8r/y//MP8w/y3/Kf8j/x3/",
        "Fv8O/wf/Af/8/vn+9/73/vr+//4H/xL/IP8x/0X/W/90/4//rP/L/+v/CgArAEwAbACLAKkAxQDfAPcADAEfAS4BOwFEAUsBTwFQAU4BSwFFAT8BNwEuASUB",
        "GwETAQsBBAH/APsA+QD6APwAAQEIAREBHQEqATkBSQFaAWwBfgGQAaIBswHCAdAB3AHmAe4B8gH0AfMB7wHoAd4B0QHCAbABnAGGAW8BVgE9ASQBCgHyANoA",
        "wwCtAJoAiAB4AGsAYABXAFAATABJAEkASgBMAE8AUgBWAFoAXgBgAGIAYgBgAFwAVgBOAEQANwAoABcABADv/9j/v/+m/4v/cP9V/zv/If8I//D+2v7G/rT+",
        "pP6X/o3+hv6B/n7+fv6B/oX+jP6U/p3+qP6z/r7+yf7U/t7+5/7u/vX++f78/v3+/P75/vX+7/7n/t7+1P7J/r7+sv6n/pz+kv6K/oP+ff56/nn+ev59/oP+",
        "jP6X/qX+tP7G/tr+7/4F/x3/Nf9N/2b/fv+V/6v/wP/U/+b/9v8DAA4AGAAgACUAKQArACwAKwAqACgAJQAiAB8AHQAcABwAHQAfACQAKgAyADsARwBVAGQA",
        "dQCHAJoArgDDANgA7QACARYBKgE7AUwBWwFnAXIBegGAAYQBhQGEAYEBfAF1AWwBYgFXAUsBPgExASQBGAEMAQEB9wDvAOgA4gDeANwA2wDcAN4A4gDmAOwA",
        "8gD3AP0AAgEHAQsBDgEPAQ8BDgELAQYB/wD2AOsA3gDQAMAArwCcAIkAdQBgAEwANwAjAA8A/v/s/9z/zf/A/7T/qv+i/5z/l/+U/5L/kv+S/5T/lv+Y/5v/",
        "nv+h/6P/pf+m/6b/pf+j/6D/nP+W/4//iP9//3b/a/9h/1b/S/9A/zb/K/8i/xn/Ev8M/wf/A/8B/wD/AP8D/wb/C/8R/xj/IP8p/zP/Pf9H/1H/W/9l/27/",
        "d/9//4f/jf+T/5j/m/+e/6D/of+i/6H/of+g/57/nf+c/5v/mv+a/5r/m/+d/6D/o/+n/63/s/+6/8H/yv/S/9z/5v/v//r/AgAMABYAHwAnAC8ANwA9AEMA",
        "SABLAE8AUQBSAFMAUwBSAFEATwBNAEsASQBHAEUAQwBBAD8APgA+AD4APgA/AEAAQgBEAEYASQBMAE8AUgBVAFgAWwBdAF8AYQBiAGMAYwBjAGIAYQBfAF0A",
        "WgBXAFMATwBLAEYAQgA9ADkANAAwACwAKAAkACEAHgAbABkAFwAVABQAEwASABEAEQARABEAEQAQABAAEAAQABAADwAOAA0ADAALAAoACAAHAAUAAwABAAAA",
        "///9//v/+v/4//f/9v/1//T/8//z//P/8//z//P/9P/0//X/9v/3//f/+P/5//r/+//8//3//v/+////AAAAAA=="
      }),
      toggle = table.concat({
        "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"
      })
    }
    local FallbackSoundIds = {click = "rbxasset://sounds/clickfast.wav", toggle = "rbxasset://sounds/switch.wav"}
    local soundsEnabled, soundCache, soundParent = true, {}, nil
    local function ResolveSound(kind)
      local id, volume = FallbackSoundIds[kind] or FallbackSoundIds.click, 3
      pcall(function()
        local getAsset = getcustomasset or getsynasset
        if type(writefile) ~= "function" or type(getAsset) ~= "function" or not SoundData[kind] then return end
        local path = "HavenHub/haven_" .. kind .. ".wav"
        local bytes = HavenDecodeBase64(SoundData[kind])
        if #bytes < 500 then return end
        local needWrite = true
        pcall(function()
          if isfile and readfile and isfile(path) and readfile(path) == bytes then needWrite = false end
        end)
        if needWrite then writefile(path, bytes) end
        local asset = getAsset(path)
        if type(asset) == "string" and #asset > 0 then id, volume = asset, 2 end
      end)
      return id, volume
    end
    local function PlaySound(kind)
      if haven.Closed or not soundsEnabled then return end
      pcall(function()
        local sound = soundCache[kind]
        if not sound then
          local id, volume = ResolveSound(kind)
          sound = Instance.new("Sound")
          sound.Name = "HavenSound_" .. kind
          sound.SoundId = id
          sound.Volume = volume
          sound.Parent = soundParent
          soundCache[kind] = sound
        end
        Services.SoundService:PlayLocalSound(sound)
      end)
    end

    haven.PlaySound = PlaySound

    local function AttachCardHover(cardFrame, strokeObj)
      cardFrame.MouseEnter:Connect(function()
        Tween(cardFrame, TweenInfo.new(0.18, Enum.EasingStyle.Sine), {BackgroundColor3 = Theme.CardHover}):Play()
        if strokeObj then Tween(strokeObj, TweenInfo.new(0.18, Enum.EasingStyle.Sine), {Color = Theme.StrokeHover, Transparency = 0.45}):Play() end
      end)
      cardFrame.MouseLeave:Connect(function()
        Tween(cardFrame, TweenInfo.new(0.18, Enum.EasingStyle.Sine), {BackgroundColor3 = Theme.CardBg}):Play()
        if strokeObj then Tween(strokeObj, TweenInfo.new(0.18, Enum.EasingStyle.Sine), {Color = Theme.StrokeIdle, Transparency = 0.65}):Play() end
      end)
    end

    pcall(function()
      if makefolder then
        makefolder("HavenHub")
        makefolder("HavenHub/settings")
      end
    end)

    function haven:Window(Settings)
      local WindowFunctions = {}
      if Settings.AcrylicBlur ~= nil then acrylicBlur = Settings.AcrylicBlur end

      local MenuKeybind = Settings.Keybind or Enum.KeyCode.LeftControl
      local windowSize = Settings.Size or UDim2.fromOffset(620, 480)
      local RAIL_W, HEADER_H = 68, 54

      local screenGui = Create("ScreenGui", {Name = "HavenHubUI", ResetOnSpawn = false, DisplayOrder = 100, IgnoreGuiInset = true, ScreenInsets = Enum.ScreenInsets.None, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
      SafeParentGui(screenGui)
      soundParent = screenGui
      local notifications = Create("Frame", {Name = "Notifications", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 20, Parent = screenGui}, {
        Create("UIListLayout", {Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom}),
        Create("UIPadding", {PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 14)})
      })

      local base = Create("Frame", {Name = "Base", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Theme.BaseBg, BackgroundTransparency = acrylicBlur and 0.03 or 0, BorderSizePixel = 0, Position = UDim2.fromScale(0.5, 0.5), Size = windowSize, Parent = screenGui}, {
        Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
        Create("ImageLabel", {Name = "DropShadow", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 44, 1, 44), ZIndex = 0, Image = assets.shadowImage, ImageColor3 = Theme.Accent, ImageTransparency = 0.78, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(10, 10, 118, 118)})
      })

      -- تصغير تلقائي لو الشاشة أصغر من النافذة (الجوال)
      local fitScale = 1
      local function ComputeFit()
        pcall(function()
          local vp = workspace.CurrentCamera.ViewportSize
          local sx = (windowSize.X.Offset > 0) and ((vp.X - 16) / windowSize.X.Offset) or 1
          local sy = (windowSize.Y.Offset > 0) and ((vp.Y - 16) / windowSize.Y.Offset) or 1
          fitScale = math.clamp(math.min(sx, sy), 0.4, 1)
        end)
      end
      ComputeFit()
      local baseScale = Create("UIScale", {Name = "BaseUIScale", Scale = fitScale, Parent = base})
      -- لو تغيّر حجم الشاشة أو انقلب الجوال: نعيد حساب الحجم
      pcall(function()
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
          ComputeFit()
          baseScale.Scale = fitScale
        end)
      end)

      local baseStroke = Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(255, 255, 255), Thickness = 1.2, Transparency = 0.15, Parent = base})
      Create("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(44, 44, 50)), ColorSequenceKeypoint.new(1, Theme.Accent)}), Rotation = 35, Parent = baseStroke})

      -- ====================== شريط الأيقونات الجانبي (Rail) ======================
      local rail = Create("Frame", {Name = "Rail", BackgroundColor3 = Theme.SidebarBg, BackgroundTransparency = 0.25, BorderSizePixel = 0, Size = UDim2.new(0, RAIL_W, 1, 0), Parent = base}, {
        Create("UICorner", {CornerRadius = UDim.new(0, 12)}),
        Create("Frame", {Name = "Divider", AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.82, BorderSizePixel = 0, Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 1, 1, 0)})
      })
      if haven.LogoAsset then
        Create("ImageLabel", {Name = "Logo", AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0, 8), Size = UDim2.fromOffset(42, 42), Image = haven.LogoAsset, ScaleType = Enum.ScaleType.Fit, Parent = rail})
      else
        Create("TextLabel", {Name = "Logo", AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Position = UDim2.new(0.5, 0, 0, 12), Size = UDim2.fromOffset(34, 34), FontFace = InterFont(Enum.FontWeight.Bold), Text = "H", TextColor3 = Theme.Text, TextSize = 18, Parent = rail}, {
          Create("UICorner", {CornerRadius = UDim.new(0, 10)})
        })
      end
      local tabSwitchersScrollingFrame = Create("ScrollingFrame", {Name = "TabSwitchersScrollingFrame", AutomaticCanvasSize = Enum.AutomaticSize.Y, BottomImage = "", CanvasSize = UDim2.new(), ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 0, TopImage = "", BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 56), Size = UDim2.new(1, 0, 1, -(56 + 46)), Parent = rail}, {
        Create("UIListLayout", {Padding = UDim.new(0, 4), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder})
      })
      local headshotImage, isReady
      pcall(function() headshotImage, isReady = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size48x48) end)
      local headshot = Create("ImageLabel", {Name = "Headshot", AnchorPoint = Vector2.new(0.5, 1), BackgroundColor3 = Theme.CardBg, BorderSizePixel = 0, Position = UDim2.new(0.5, 0, 1, -10), Size = UDim2.fromOffset(30, 30), Image = (isReady and headshotImage) or "rbxassetid://0", Parent = rail}, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.Accent, Transparency = 0.3})
      })

      -- ====================== الشريط العلوي (عنوان التبويب + الأزرار) ======================
      local header = Create("Frame", {Name = "Header", BackgroundTransparency = 1, Position = UDim2.fromOffset(RAIL_W, 0), Size = UDim2.new(1, -RAIL_W, 0, HEADER_H), Parent = base}, {
        Create("Frame", {Name = "Divider", AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.85, BorderSizePixel = 0, Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1)})
      })
      local dragInteract = Create("TextButton", {Name = "Interact", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 1, Parent = header})
      local currentTab = Create("TextLabel", {Name = "CurrentTab", FontFace = InterFont(Enum.FontWeight.Bold), RichText = true, Text = "HAVEN HUB", TextColor3 = Theme.Text, TextSize = 17, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1, Position = UDim2.fromOffset(18, 9), Size = UDim2.new(1, -146, 0, 20), ZIndex = 2, Parent = header})
      local subtitle = Create("Frame", {Name = "Subtitle", BackgroundTransparency = 1, Position = UDim2.fromOffset(18, 31), Size = UDim2.new(1, -146, 0, 12), ZIndex = 2, Parent = header}, {
        Create("UIListLayout", {Padding = UDim.new(0, 6), FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center})
      })
      Create("TextLabel", {Name = "Brand", FontFace = InterFont(Enum.FontWeight.Bold), Text = "HAVEN HUB", TextColor3 = Theme.Accent, TextSize = 9, AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 12), ZIndex = 2, Parent = subtitle})
      local displayName = Create("TextLabel", {Name = "DisplayName", FontFace = InterFont(Enum.FontWeight.SemiBold), Text = LocalPlayer.DisplayName, TextColor3 = Theme.Text, TextSize = 9, TextTransparency = 0.25, AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.fromOffset(0, 12), ZIndex = 2, Parent = subtitle})
      local username = Create("TextLabel", {Name = "Username", FontFace = InterFont(Enum.FontWeight.Medium), Text = "@" .. LocalPlayer.Name, TextColor3 = Theme.SubText, TextSize = 9, TextTransparency = 0.25, AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, LayoutOrder = 2, Size = UDim2.fromOffset(0, 12), ZIndex = 2, Parent = subtitle})

      local controls = Create("Frame", {Name = "Controls", AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(114, 32), ZIndex = 3, Parent = header}, {
        Create("UIListLayout", {Padding = UDim.new(0, 6), FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center})
      })
      local function ControlButton(name, order, hoverColor)
        local btn = Create("TextButton", {Name = name, Text = "", AutoButtonColor = false, BackgroundColor3 = Theme.CardBg, BorderSizePixel = 0, LayoutOrder = order, Size = UDim2.fromOffset(32, 32), ZIndex = 3, Parent = controls}, {
          Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
          Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.StrokeIdle, Transparency = 0.5})
        })
        btn.MouseEnter:Connect(function() Tween(btn, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {BackgroundColor3 = hoverColor}):Play() end)
        btn.MouseLeave:Connect(function() Tween(btn, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {BackgroundColor3 = Theme.CardBg}):Play() end)
        btn.MouseButton1Click:Connect(function() PlaySound("click") end)
        return btn
      end
      local globalSettingsButton = ControlButton("GlobalSettingsButton", 0, Theme.CardHover)
      Create("ImageLabel", {Image = assets.settingsImage, ImageColor3 = Theme.AccentSecondary, AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(14, 14), ZIndex = 3, Parent = globalSettingsButton})
      local minimize = ControlButton("Minimize", 1, Theme.CardHover)
      local minimizeLine = Create("Frame", {Name = "CollapseIcon", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Theme.Text, BorderSizePixel = 0, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(11, 2), ZIndex = 3, Parent = minimize})
      local restoreBox = Create("Frame", {Name = "RestoreIcon", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(9, 9), Visible = false, ZIndex = 3, Parent = minimize}, {
        Create("UICorner", {CornerRadius = UDim.new(0, 2)}),
        Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.Text, Thickness = 1.5})
      })
      local exit = ControlButton("Exit", 2, Theme.Accent)
      Create("TextLabel", {FontFace = InterFont(Enum.FontWeight.Bold), Text = "X", TextColor3 = Theme.Text, TextSize = 12, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 3, Parent = exit})

      local previousElite
      pcall(function() previousElite = LocalPlayer:GetAttribute("Elite") end)
      LocalPlayer:SetAttribute("Elite", true)

      task.spawn(function()
        repeat task.wait() until shared.tabs ~= nil
        for key, tabObj in pairs(shared.tabs) do
          if key ~= "Settings" then shared[key] = tabObj:Section({Side = "Left"}) end
        end
        shared.loaded = true
        shared.done = true
      end)

      -- سحب النافذة من الشريط العلوي
      local dragging_, dragInput, dragStart, startPos = false, nil, nil, nil
      dragInteract.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
          dragging_ = true dragStart = input.Position startPos = base.Position
          input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging_ = false end end)
        end
      end)
      dragInteract.InputChanged:Connect(function(input)
        if dragging_ and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then dragInput = input end
      end)
      UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging_ then
          local delta = input.Position - dragStart
          base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
      end)

      -- ====================== المحتوى ======================
      local content = Create("Frame", {Name = "Content", BackgroundTransparency = 1, ClipsDescendants = true, Position = UDim2.fromOffset(RAIL_W, HEADER_H), Size = UDim2.new(1, -RAIL_W, 1, -HEADER_H), Parent = base})

      -- ====================== قائمة الإعدادات العامة ======================
      local globalSettings = Create("Frame", {Name = "GlobalSettings", AnchorPoint = Vector2.new(1, 0), AutomaticSize = Enum.AutomaticSize.XY, BackgroundColor3 = Theme.PromptBg, BorderSizePixel = 0, Position = UDim2.new(1, -12, 0, HEADER_H + 4), ZIndex = 15, Parent = base}, {
        Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.Accent, Transparency = 0.5}),
        Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
        Create("UIPadding", {PaddingBottom = UDim.new(0, 10), PaddingTop = UDim.new(0, 10)}),
        Create("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}),
        Create("TextLabel", {Name = "Title", FontFace = InterFont(Enum.FontWeight.Bold), Text = "QUICK SETTINGS", TextColor3 = Theme.AccentSecondary, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, LayoutOrder = -1, Size = UDim2.fromOffset(220, 22), ZIndex = 15}, {
          Create("UIPadding", {PaddingLeft = UDim.new(0, 14)})
        })
      })
      local globalSettingsUIScale = Create("UIScale", {Scale = 0, Parent = globalSettings})
      local gsToggled = false
      globalSettingsButton.MouseButton1Click:Connect(function()
        if hasGlobalSetting then
          gsToggled = not gsToggled
          Tween(globalSettingsUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Scale = gsToggled and 1 or 0}):Play()
        end
      end)

      function WindowFunctions:GlobalSetting(gSettings)
        hasGlobalSetting = true
        local gsBtn = Create("TextButton", {Text = "", AutoButtonColor = false, BackgroundColor3 = Theme.CardHover, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromOffset(220, 36), ZIndex = 15, Parent = globalSettings})
        local st = gSettings.Default and true or false
        local sName = Create("TextLabel", {FontFace = InterFont(Enum.FontWeight.Medium), Text = gSettings.Name, TextColor3 = Theme.Text, TextSize = 13, TextTransparency = st and 0.05 or 0.4, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -66, 1, 0), ZIndex = 15, Parent = gsBtn})
        local gsSwitch = Create("Frame", {AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = st and Theme.Accent or Theme.ToggleOff, BorderSizePixel = 0, Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(32, 16), ZIndex = 15, Parent = gsBtn}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
        local gsKnob = Create("Frame", {AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = st and Theme.Text or Theme.ToggleHeadOff, BorderSizePixel = 0, Position = st and UDim2.new(1, -13, 0.5, 0) or UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(10, 10), ZIndex = 15, Parent = gsSwitch}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
        gsBtn.MouseEnter:Connect(function() Tween(gsBtn, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.45}):Play() end)
        gsBtn.MouseLeave:Connect(function() Tween(gsBtn, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {BackgroundTransparency = 1}):Play() end)
        gsBtn.MouseButton1Click:Connect(function()
          PlaySound("toggle")
          st = not st
          local info = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
          Tween(gsSwitch, info, {BackgroundColor3 = st and Theme.Accent or Theme.ToggleOff}):Play()
          Tween(gsKnob, info, {BackgroundColor3 = st and Theme.Text or Theme.ToggleHeadOff, Position = st and UDim2.new(1, -13, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}):Play()
          sName.TextTransparency = st and 0.05 or 0.4
          if gSettings.Callback then task.spawn(gSettings.Callback, st) end
        end)
        return {}
      end

      function WindowFunctions:TabGroup()
        local GroupFuncs = {}
        local sectionTabSwitchers = Create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 0, 0), Parent = tabSwitchersScrollingFrame}, {
          Create("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder})
        })

        function GroupFuncs:Tab(tSettings)
          tSettings.Name = HavenT(tSettings.Name)
          tSettings.Short = HavenT(tSettings.Short)
          local TabFunctions = {}
          tabIndex = tabIndex + 1
          -- زر التبويب: أيقونة وتحتها اسم قصير
          local shortName = tSettings.Short or string.match(tSettings.Name, "^[%w]+") or tSettings.Name
          local tabSwitcher = Create("TextButton", {Name = "TabSwitcher", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 50), LayoutOrder = tabIndex, Parent = sectionTabSwitchers})
          -- مؤشر أحمر على حافة الشريط للتبويب المفتوح
          local activeBar = Create("Frame", {Name = "ActiveBar", AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0, -6, 0, 19), Size = UDim2.fromOffset(3, 22), Parent = tabSwitcher}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
          local tabTile = Create("Frame", {Name = "TabTile", AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = Theme.CardBg, BorderSizePixel = 0, Position = UDim2.new(0.5, 0, 0, 1), Size = UDim2.fromOffset(36, 36), Parent = tabSwitcher}, {
            Create("UICorner", {CornerRadius = UDim.new(1, 0)})
          })
          local tabStroke = Create("UIStroke", {Name = "TabSwitcherUIStroke", ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.StrokeIdle, Thickness = 1, Transparency = 0.45, Parent = tabTile})
          local tabImage = tSettings.Image and Create("ImageLabel", {Name = "TabImage", Image = tSettings.Image, ImageColor3 = Theme.SubText, AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(18, 18), Parent = tabTile})
          local tabSwitcherName = Create("TextLabel", {Name = "TabSwitcherName", FontFace = InterFont(Enum.FontWeight.SemiBold), Text = shortName, TextColor3 = Theme.SubText, TextSize = 8, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 38), Size = UDim2.new(1, 0, 0, 11), Parent = tabSwitcher})
          tabSwitcher.MouseEnter:Connect(function() if currentTabInstance ~= tabs[tabSwitcher] then Tween(tabTile, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {BackgroundColor3 = Theme.CardHover}):Play() end end)
          tabSwitcher.MouseLeave:Connect(function() if currentTabInstance ~= tabs[tabSwitcher] then Tween(tabTile, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {BackgroundColor3 = Theme.CardBg}):Play() end end)

          local elements1 = Create("Frame", {Name = "Elements", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1)})
          local elementsScrolling = Create("ScrollingFrame", {Name = "ElementsScrolling", AutomaticCanvasSize = Enum.AutomaticSize.Y, BottomImage = "", CanvasSize = UDim2.new(), ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarImageColor3 = Theme.Accent, ScrollBarImageTransparency = 0.3, ScrollBarThickness = 2, TopImage = "", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Parent = elements1})
          local left = Create("Frame", {Name = "Left", AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Parent = elementsScrolling}, {
            Create("UIListLayout", {Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder}),
            Create("UIPadding", {PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 16), PaddingTop = UDim.new(0, 14)})
          })

          function TabFunctions:Section()
            local SectionFunctions = {}
            local section = Create("Frame", {Name = "Section", AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), Parent = left}, {
              Create("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})
            })

            -- الخيارات تتجمع في بطاقات: كل SubLabel بعد Divider يبدأ بطاقة جديدة بعنوان
            local currentGroup, groupCount, rowCount = nil, 0, 0
            local function GetGroup()
              if not currentGroup then
                groupCount = groupCount + 1
                rowCount = 0
                currentGroup = Create("Frame", {Name = "Group", AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.SectionBg, BackgroundTransparency = 0.05, BorderSizePixel = 0, LayoutOrder = groupCount, Size = UDim2.new(1, 0, 0, 0), Parent = section}, {
                  Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
                  Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.StrokeIdle, Transparency = 0.5}),
                  Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}),
                  Create("UIPadding", {PaddingBottom = UDim.new(0, 5), PaddingTop = UDim.new(0, 5)})
                })
              end
              return currentGroup
            end
            local function NewRow(height, padded, noHover)
              local group = GetGroup()
              rowCount = rowCount + 1
              local row = Create("Frame", {Name = "Row", BackgroundColor3 = Theme.CardHover, BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = rowCount, Size = UDim2.new(1, 0, 0, height), Parent = group})
              if padded then Create("UIPadding", {PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = row}) end
              if rowCount > 1 then
                Create("Frame", {Name = "Separator", BackgroundColor3 = Theme.StrokeIdle, BackgroundTransparency = 0.55, BorderSizePixel = 0, Position = UDim2.fromOffset(padded and 0 or 14, 0), Size = UDim2.new(1, padded and 0 or -28, 0, 1), Parent = row})
              end
              if not noHover then
                row.MouseEnter:Connect(function() Tween(row, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.45}):Play() end)
                row.MouseLeave:Connect(function() Tween(row, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {BackgroundTransparency = 1}):Play() end)
              end
              return row
            end

            function SectionFunctions:Button(bSettings)
              bSettings.Name = HavenT(bSettings.Name)
              local buttonRow = NewRow(44, false, true)
              local button = Create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.86, BorderSizePixel = 0, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, -28, 0, 32), Parent = buttonRow}, {
                Create("UICorner", {CornerRadius = UDim.new(0, 8)})
              })
              local bStroke = Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.Accent, Transparency = 0.55, Parent = button})
              local buttonInteract = Create("TextButton", {FontFace = InterFont(Enum.FontWeight.SemiBold), RichText = true, AutoButtonColor = false, TextColor3 = Theme.Text, TextSize = 13, TextTransparency = 0.05, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = bSettings.Name, Parent = button})
              Create("ImageLabel", {Image = assets.buttonImage, ImageColor3 = Theme.AccentSecondary, ImageTransparency = 0.2, AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(14, 14), Parent = button})
              button.MouseEnter:Connect(function()
                Tween(button, TweenInfo.new(0.18, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.7}):Play()
                Tween(bStroke, TweenInfo.new(0.18, Enum.EasingStyle.Sine), {Transparency = 0.2}):Play()
              end)
              button.MouseLeave:Connect(function()
                Tween(button, TweenInfo.new(0.18, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.86}):Play()
                Tween(bStroke, TweenInfo.new(0.18, Enum.EasingStyle.Sine), {Transparency = 0.55}):Play()
              end)
              buttonInteract.MouseButton1Click:Connect(function() PlaySound("click") if bSettings.Callback then bSettings.Callback() end end)
              return {UpdateName = function(_, n) buttonInteract.Text = n end, SetVisibility = function(_, s) buttonRow.Visible = s end}
            end

            function SectionFunctions:Toggle(Flag, DisplayName, Config, Callback)
              DisplayName = HavenT(DisplayName)
              if type(Config) == "function" then Callback = Config Config = {} end
              Config = Config or {}
              local ToggleFunctions = {IgnoreConfig = false, Class = "Toggle", Callback = Callback}
              local toggle = NewRow(40)

              local toggleName = Create("TextLabel", {FontFace = InterFont(Enum.FontWeight.Medium), Text = DisplayName, RichText = true, TextColor3 = Theme.Text, TextSize = 13, TextTransparency = 0.3, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -76, 1, 0), Parent = toggle})
              local switchBg = Create("Frame", {AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Theme.ToggleOff, BorderSizePixel = 0, Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(38, 20), Parent = toggle}, {
                Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
                Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(255, 255, 255), Transparency = 0.88})
              })
              local knob = Create("Frame", {AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Theme.ToggleHeadOff, BorderSizePixel = 0, Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(14, 14), Parent = switchBg}, {
                Create("UICorner", {CornerRadius = UDim.new(1, 0)})
              })
              -- الضغط على أي مكان في الصف يبدّل الحالة
              local interact = Create("TextButton", {Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = toggle})

              local tInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
              local function ToggleState(State)
                Tween(switchBg, tInfo, {BackgroundColor3 = State and Theme.Accent or Theme.ToggleOff}):Play()
                Tween(knob, tInfo, {BackgroundColor3 = State and Color3.fromRGB(255, 255, 255) or Theme.ToggleHeadOff, Position = State and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}):Play()
                Tween(toggleName, tInfo, {TextTransparency = State and 0.05 or 0.3}):Play()
                ToggleFunctions.State = State
              end
              local togglebool = (Config.State == true)
              ToggleState(togglebool)
              local function DoToggle()
                togglebool = not togglebool ToggleState(togglebool)
                if ToggleFunctions.Callback then task.spawn(ToggleFunctions.Callback, togglebool) end
              end
              interact.MouseButton1Click:Connect(function() PlaySound("toggle") DoToggle() end)
              function ToggleFunctions:Toggle() DoToggle() end
              function ToggleFunctions:UpdateState(State)
                togglebool = State ToggleState(togglebool) Options[Flag] = self
                if togglebool and ToggleFunctions.Callback then task.spawn(ToggleFunctions.Callback, togglebool) end
              end
              function ToggleFunctions:GetState() return togglebool end
              function ToggleFunctions:GetValue() return togglebool end
              function ToggleFunctions:UpdateName(Name) toggleName.Text = Name end
              function ToggleFunctions:SetVisibility(State) toggle.Visible = State end
              if Flag then Options[Flag] = ToggleFunctions haven.Options[Flag] = ToggleFunctions end
              return ToggleFunctions
            end

            function SectionFunctions:Slider(Flag, Name, Minimum, Maximum, Default, _, Callback)
              Name = HavenT(Name)
              local SliderFunctions = {IgnoreConfig = false, Class = "Slider", Callback = Callback}
              local slider = NewRow(58)

              local sliderName = Create("TextLabel", {FontFace = InterFont(Enum.FontWeight.Medium), Text = Name, RichText = true, TextColor3 = Theme.Text, TextSize = 13, TextTransparency = 0.25, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -84, 0, 20), Parent = slider})
              local sliderValue = Create("TextBox", {FontFace = InterFont(Enum.FontWeight.Bold), Text = tostring(Default), TextColor3 = Theme.AccentSecondary, TextSize = 11, AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.86, BorderSizePixel = 0, Position = UDim2.new(1, -12, 0, 8), Size = UDim2.fromOffset(46, 20), ZIndex = 2, Parent = slider}, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.Accent, Transparency = 0.65})
              })
              local sliderBar = Create("Frame", {AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Theme.ToggleOff, BorderSizePixel = 0, Position = UDim2.new(0, 16, 1, -15), Size = UDim2.new(1, -32, 0, 5), Parent = slider}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
              local sliderFill = Create("Frame", {BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Size = UDim2.fromScale(0.5, 1), Parent = sliderBar}, {
                Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
                Create("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(1, Theme.AccentSecondary)})})
              })
              local sliderHead = Create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(12, 12), ZIndex = 2, Parent = sliderBar}, {
                Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
                Create("UIStroke", {Color = Theme.Accent, Thickness = 2})
              })
              -- منطقة لمس أكبر من الشريط نفسه (أسهل على الجوال)
              local touchArea = Create("Frame", {Active = true, AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 16, 0, 24), ZIndex = 3, Parent = sliderBar})

              local dragging, finalValue = false, Default
              local function SetValue(val, ignorecallback)
                local posXScale = (typeof(val) == "Instance") and math.clamp((val.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1) or math.clamp((val - Minimum) / (Maximum - Minimum), 0, 1)
                sliderHead.Position = UDim2.new(posXScale, 0, 0.5, 0)
                sliderFill.Size = UDim2.fromScale(posXScale, 1)
                finalValue = posXScale * (Maximum - Minimum) + Minimum
                sliderValue.Text = tostring(math.round(finalValue))
                if not ignorecallback and SliderFunctions.Callback then task.spawn(SliderFunctions.Callback, finalValue) end
                SliderFunctions.Value = finalValue
              end
              SetValue(Default, true)
              touchArea.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = true PlaySound("click") SetValue(inp) end end)
              touchArea.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
              UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
              sliderValue.FocusLost:Connect(function()
                local num = tonumber(sliderValue.Text:match("%-?%d+%.?%d*"))
                if num then SetValue(math.clamp(num, Minimum, Maximum)) else sliderValue.Text = tostring(math.round(finalValue)) end
              end)
              UserInputService.InputChanged:Connect(function(inp) if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then SetValue(inp) end end)

              function SliderFunctions:UpdateName(n) sliderName.Text = n end
              function SliderFunctions:SetVisibility(s) slider.Visible = s end
              function SliderFunctions:UpdateValue(v) SetValue(tonumber(v) or Default, true) end
              function SliderFunctions:GetValue() return finalValue end
              if Flag then Options[Flag] = SliderFunctions haven.Options[Flag] = SliderFunctions end
              return SliderFunctions
            end

            function SectionFunctions:Input(iSettings, Flag)
              iSettings.Name = HavenT(iSettings.Name)
              local InputFunctions = {IgnoreConfig = false, Class = "Input", Callback = iSettings.Callback}
              local input = NewRow(40)

              local inputName = Create("TextLabel", {FontFace = InterFont(Enum.FontWeight.Medium), Text = iSettings.Name, RichText = true, TextColor3 = Theme.Text, TextSize = 13, TextTransparency = 0.25, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -90, 1, 0), Parent = input})
              local inputBox = Create("TextBox", {FontFace = InterFont(Enum.FontWeight.Medium), Text = iSettings.Default or "", PlaceholderText = iSettings.Placeholder or "", TextColor3 = Theme.Text, TextSize = 12, TextTransparency = 0.15, AnchorPoint = Vector2.new(1, 0.5), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Theme.BaseBg, BackgroundTransparency = 0.2, BorderSizePixel = 0, ClipsDescendants = true, Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(60, 24), ZIndex = 2, Parent = input}, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.Accent, Transparency = 0.6}),
                Create("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}),
                Create("UISizeConstraint", {MaxSize = Vector2.new(175, 999)})
              })
              inputBox.Focused:Connect(function() PlaySound("click") end)
              inputBox.FocusLost:Connect(function()
                if iSettings.AcceptedCharacters == "Numeric" then inputBox.Text = inputBox.Text:gsub("[^%d-]", "") end
                InputFunctions.Text = inputBox.Text
                if InputFunctions.Callback then task.spawn(InputFunctions.Callback, inputBox.Text) end
              end)
              function InputFunctions:UpdateName(n) inputName.Text = n end
              function InputFunctions:SetVisibility(s) input.Visible = s end
              function InputFunctions:GetInput() return inputBox.Text end
              function InputFunctions:UpdateText(t) inputBox.Text = t or "" InputFunctions.Text = inputBox.Text if InputFunctions.Callback then task.spawn(InputFunctions.Callback, inputBox.Text) end end
              if Flag then haven.Options[Flag] = InputFunctions Options[Flag] = InputFunctions end
              return InputFunctions
            end

            function SectionFunctions:Keybind(Flag, Name, Config, Callback)
              Name = HavenT(Name)
              if type(Config) == "function" then Callback = Config end
              local KeybindFunctions = {IgnoreConfig = false, Class = "Keybind", Callback = Callback}
              local keybind = NewRow(40)

              local keybindName = Create("TextLabel", {FontFace = InterFont(Enum.FontWeight.Medium), Text = Name, RichText = true, TextColor3 = Theme.Text, TextSize = 13, TextTransparency = 0.25, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -90, 1, 0), Parent = keybind})
              local binderBox = Create("TextBox", {CursorPosition = -1, FontFace = InterFont(Enum.FontWeight.Bold), PlaceholderText = "...", Text = "NONE", TextColor3 = Theme.AccentSecondary, TextSize = 11, AnchorPoint = Vector2.new(1, 0.5), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Theme.BaseBg, BackgroundTransparency = 0.2, BorderSizePixel = 0, Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(40, 22), ZIndex = 2, Parent = keybind}, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.Accent, Transparency = 0.6}),
                Create("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})
              })
              local focused, skipNextKey, binded = false, nil, nil
              -- على أجهزة اللمس: زر RUN يشغّل الأمر بدون كيبورد
              if UserInputService.TouchEnabled then
                local runButton = Create("TextButton", {Name = "RunButton", FontFace = InterFont(Enum.FontWeight.Bold), Text = "RUN", TextColor3 = Theme.Text, TextSize = 10, AutoButtonColor = false, AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.15, BorderSizePixel = 0, Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(46, 24), ZIndex = 2, Parent = keybind}, {
                  Create("UICorner", {CornerRadius = UDim.new(0, 6)})
                })
                binderBox.Position = UDim2.new(1, -66, 0.5, 0)
                keybindName.Size = UDim2.new(1, -150, 1, 0)
                runButton.MouseButton1Click:Connect(function()
                  PlaySound("click")
                  if KeybindFunctions.Callback then task.spawn(KeybindFunctions.Callback, binded or Enum.KeyCode.Unknown) end
                end)
              end
              function KeybindFunctions:Bind(Key) if Key then binded = Key binderBox.Text = Key.Name else binded = nil binderBox.Text = "NONE" end end
              function KeybindFunctions:GetBind() return binded end
              function KeybindFunctions:SetBind(Key) KeybindFunctions:Bind(Key) end
              function KeybindFunctions:UpdateName(n) keybindName.Text = n end
              function KeybindFunctions:SetVisibility(s) keybind.Visible = s end
              binderBox.Focused:Connect(function() PlaySound("click") focused = true binderBox.Text = "..." end)
              binderBox.FocusLost:Connect(function() focused = false binderBox.Text = binded and binded.Name or "NONE" end)
              UserInputService.InputBegan:Connect(function(inp)
                if focused and inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode ~= Enum.KeyCode.Unknown then
                  binded = inp.KeyCode binderBox.Text = inp.KeyCode.Name skipNextKey = inp.KeyCode focused = false binderBox:ReleaseFocus()
                end
              end)
              UserInputService.InputEnded:Connect(function(inp)
                if skipNextKey and inp.KeyCode == skipNextKey then skipNextKey = nil return end
                if not focused and inp.UserInputType == Enum.UserInputType.Keyboard and binded and inp.KeyCode == binded then
                  if KeybindFunctions.Callback then KeybindFunctions.Callback(binded) end
                end
              end)
              if Flag then haven.Options[Flag] = KeybindFunctions Options[Flag] = KeybindFunctions end
              return KeybindFunctions
            end

            function SectionFunctions:Dropdown(dSettings, Flag)
              dSettings.Name = HavenT(dSettings.Name)
              local DropdownFunctions = {IgnoreConfig = false, Class = "Dropdown", Callback = dSettings.Callback}
              local Selected, OptionObjs = {}, {}
              local dropdown = NewRow(38, true)
              dropdown.ClipsDescendants = true

              local interact = Create("TextButton", {Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), ZIndex = 2, Parent = dropdown})
              local dropdownName = Create("TextLabel", {FontFace = InterFont(Enum.FontWeight.Medium), Text = dSettings.Name, RichText = true, TextColor3 = Theme.Text, TextSize = 13, TextTransparency = 0.25, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 38), Parent = dropdown})
              local chevron = Create("ImageLabel", {Image = assets.chevronImage, ImageColor3 = Theme.AccentSecondary, ImageTransparency = 0.2, AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Position = UDim2.new(1, 0, 0, 12), Size = UDim2.fromOffset(14, 14), Parent = dropdown})
              local dropdownFrame = Create("Frame", {BackgroundTransparency = 1, ClipsDescendants = true, Size = UDim2.fromScale(1, 1), Visible = false, AutomaticSize = Enum.AutomaticSize.Y, Parent = dropdown}, {
                Create("UIPadding", {PaddingTop = UDim.new(0, 40), PaddingBottom = UDim.new(0, 10)}),
                Create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
              })

              local function CalculateDropdownSize()
                local totalHeight, count = 0, 0
                for _, v in pairs(dropdownFrame:GetChildren()) do
                  if not v:IsA("UIComponent") and v.Visible then totalHeight = totalHeight + v.AbsoluteSize.Y count = count + 1 end
                end
                return totalHeight + (4 * math.max(0, count - 1)) + 50
              end
              local function ToggleOption(optionName)
                if not OptionObjs[optionName] then return end
                for name, opt in pairs(OptionObjs) do
                  opt.Dot.BackgroundTransparency = (name == optionName) and 0 or 1
                  opt.NameLabel.TextTransparency = (name == optionName) and 0.05 or 0.5
                end
                Selected = {optionName}
                DropdownFunctions.Value = optionName
                dropdownName.Text = dSettings.Name .. '  |  <font color="#FF5C68">' .. optionName .. '</font>'
              end
              local dropped = false
              interact.MouseButton1Click:Connect(function()
                PlaySound("click")
                dropped = not dropped dropdownFrame.Visible = dropped
                Tween(chevron, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {Rotation = dropped and 180 or 0}):Play()
                Tween(dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = dropped and UDim2.new(1, 0, 0, CalculateDropdownSize()) or UDim2.new(1, 0, 0, 38)}):Play()
              end)
              local function addOption(i, v)
                if OptionObjs[v] then return end
                local option = Create("TextButton", {Text = "", AutoButtonColor = false, BackgroundColor3 = Theme.BaseBg, BackgroundTransparency = 0.5, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 28), ZIndex = 3, Parent = dropdownFrame}, {
                  Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                  Create("UIPadding", {PaddingLeft = UDim.new(0, 10)}),
                  Create("UIListLayout", {Padding = UDim.new(0, 8), FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center})
                })
                local dot = Create("Frame", {BackgroundColor3 = Theme.AccentSecondary, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromOffset(6, 6), LayoutOrder = -1, ZIndex = 3, Parent = option}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                local optionName = Create("TextLabel", {FontFace = InterFont(Enum.FontWeight.Medium), Text = v, RichText = true, TextColor3 = Theme.Text, TextSize = 12, TextTransparency = 0.5, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, ZIndex = 3, Parent = option})
                OptionObjs[v] = {Index = i, Button = option, NameLabel = optionName, Dot = dot}
                option.MouseButton1Click:Connect(function()
                  PlaySound("click")
                  ToggleOption(v)
                  if DropdownFunctions.Callback then task.spawn(DropdownFunctions.Callback, Selected[1]) end
                end)
                if dropped then dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize()) end
              end
              for i, v in pairs(dSettings.Options or {}) do addOption(i, v) end
              if dSettings.Default then
                local def = (type(dSettings.Default) == "number") and (dSettings.Options and dSettings.Options[dSettings.Default]) or dSettings.Default
                if type(def) == "string" and OptionObjs[def] then ToggleOption(def) end
              end
              function DropdownFunctions:GetValue() return Selected[1] end
              function DropdownFunctions:UpdateSelection(s) if type(s) == "string" and OptionObjs[s] then ToggleOption(s) end end
              function DropdownFunctions:InsertOptions(newOpts) for i, v in pairs(newOpts or {}) do addOption(i, v) end end
              function DropdownFunctions:RemoveOptions(rem)
                for _, n in ipairs(rem or {}) do if OptionObjs[n] then OptionObjs[n].Button:Destroy() OptionObjs[n] = nil end end
                if dropped then dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize()) end
              end
              function DropdownFunctions:SetVisibility(s) dropdown.Visible = s end
              if Flag then Options[Flag] = DropdownFunctions haven.Options[Flag] = DropdownFunctions end
              return DropdownFunctions
            end

            function SectionFunctions:SubLabel(sSettings)
              sSettings.Text = HavenT(sSettings.Text or sSettings.Name)
              local isTitle = (currentGroup == nil) or (rowCount == 0)
              local subLabel = NewRow(isTitle and 30 or 28, false, true)
              if isTitle then
                Create("Frame", {AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Position = UDim2.new(0, 14, 0.5, 0), Size = UDim2.fromOffset(3, 12), Parent = subLabel}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
              end
              local subLabelText = Create("TextLabel", {FontFace = InterFont(Enum.FontWeight.Bold), RichText = true, Text = string.upper(sSettings.Text or sSettings.Name or ""), TextColor3 = isTitle and Theme.AccentSecondary or Theme.SubText, TextSize = isTitle and 11 or 10, TextTransparency = 0.1, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1, Position = UDim2.fromOffset(isTitle and 24 or 14, 0), Size = UDim2.new(1, isTitle and -38 or -28, 1, 0), Parent = subLabel})
              return {UpdateName = function(_, New) subLabelText.Text = string.upper(New) end, SetVisibility = function(_, State) subLabel.Visible = State end}
            end

            function SectionFunctions:Divider()
              currentGroup = nil
              return {Remove = function() end, SetVisibility = function() end}
            end

            return SectionFunctions
          end

          local function SelectCurrentTab()
            local tabInfo = TweenInfo.new(0.18, Enum.EasingStyle.Sine)
            if currentTabInstance then currentTabInstance.Parent = nil end
            for _, v in pairs(tabSwitchersScrollingFrame:GetDescendants()) do
              if v.Name == "TabSwitcher" then
                local tile = v:FindFirstChild("TabTile")
                local stroke = tile and tile:FindFirstChild("TabSwitcherUIStroke")
                local image = tile and tile:FindFirstChild("TabImage")
                local name = v:FindFirstChild("TabSwitcherName")
                local bar = v:FindFirstChild("ActiveBar")
                if bar then Tween(bar, tabInfo, {BackgroundTransparency = 1}):Play() end
                if tile then Tween(tile, tabInfo, {BackgroundColor3 = Theme.CardBg}):Play() end
                if stroke then Tween(stroke, tabInfo, {Color = Theme.StrokeIdle, Thickness = 1, Transparency = 0.45}):Play() end
                if image then Tween(image, tabInfo, {ImageColor3 = Theme.SubText}):Play() end
                if name then Tween(name, tabInfo, {TextColor3 = Theme.SubText}):Play() end
              end
            end
            tabs[tabSwitcher].Parent = content
            currentTabInstance = tabs[tabSwitcher]
            currentTab.Text = string.upper(tSettings.Name)
            Tween(tabTile, tabInfo, {BackgroundColor3 = Theme.Accent}):Play()
            Tween(tabStroke, tabInfo, {Color = Theme.Accent, Thickness = 3, Transparency = 0.7}):Play()
            Tween(activeBar, tabInfo, {BackgroundTransparency = 0}):Play()
            Tween(tabSwitcherName, tabInfo, {TextColor3 = Theme.Text}):Play()
            if tabImage then Tween(tabImage, tabInfo, {ImageColor3 = Theme.Text}):Play() end
          end

          tabSwitcher.MouseButton1Click:Connect(function() PlaySound("click") SelectCurrentTab() end)
          function TabFunctions:Select() SelectCurrentTab() end
          function TabFunctions:InsertConfigSection(_, THISWINDOW)
            THISWINDOW:GlobalSetting({Name = "Glass Window", Default = THISWINDOW:GetAcrylicBlurState(), Callback = function(b) THISWINDOW:SetAcrylicBlurState(b) end})
            THISWINDOW:GlobalSetting({Name = "Show My Profile", Default = THISWINDOW:GetUserInfoState(), Callback = function(b) THISWINDOW:SetUserInfoState(b) end})
            THISWINDOW:GlobalSetting({Name = "Click Sounds", Default = THISWINDOW:GetSoundsEnabled(), Callback = function(b) THISWINDOW:SetSoundsEnabled(b) end})
            local configSection = TabFunctions:Section({Side = "Left"})
            configSection:SubLabel({Text = "CONFIGURATION"})
            configSection:Toggle("SaveSettings", "Auto Save Settings", function()
              local lastSave = 0
              repeat task.wait(1)
                if os.clock() - lastSave >= 5 then lastSave = os.clock() haven:SaveConfig(game.PlaceId) end
              until not Options.SaveSettings:GetValue()
            end)
          end
          tabs[tabSwitcher] = elements1
          return TabFunctions
        end
        return GroupFuncs
      end

      function WindowFunctions:Notify(nSettings)
        local notification = Create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.PromptBg, BorderSizePixel = 0, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(nSettings.SizeX or 270, 0), Parent = notifications}, {
          Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.Accent, Transparency = 0.35}),
          Create("UICorner", {CornerRadius = UDim.new(0, 10)})
        })
        local nScale = Create("UIScale", {Scale = 0, Parent = notification})
        local nInfo = Create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = notification}, {
          Create("UIPadding", {PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 10)})
        })
        Create("TextLabel", {FontFace = InterFont(Enum.FontWeight.Bold), RichText = true, Text = string.upper(nSettings.Title or "HAVEN HUB"), TextColor3 = Theme.AccentSecondary, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 0, 0), Parent = nInfo})
        Create("TextLabel", {FontFace = InterFont(Enum.FontWeight.Medium), Text = nSettings.Description or "", TextColor3 = Theme.Text, TextSize = 11, TextTransparency = 0.2, TextWrapped = true, RichText = true, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 0, 0), Parent = nInfo}, {Create("UIPadding", {PaddingTop = UDim.new(0, 18)})})
        task.spawn(function()
          Tween(nScale, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Scale = 1}):Play()
          task.wait(nSettings.Lifetime or nSettings.Duration or 4)
          local out = Tween(nScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Scale = 0})
          out:Play() out.Completed:Wait() notification:Destroy()
        end)
      end

      function WindowFunctions:Dialog(dSettings)
        local dialog = Create("TextButton", {Text = "", AutoButtonColor = false, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.45, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 25, Parent = base}, {Create("UICorner", {CornerRadius = UDim.new(0, 12)})})
        local prompt = Create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.PromptBg, BorderSizePixel = 0, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(310, 0), ZIndex = 25, Parent = dialog}, {
          Create("UIStroke", {Color = Theme.Accent, Transparency = 0.35}),
          Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
          Create("UIPadding", {PaddingBottom = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20), PaddingTop = UDim.new(0, 20)}),
          Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12)})
        })
        Create("TextLabel", {FontFace = InterFont(Enum.FontWeight.Bold), RichText = true, Text = dSettings.Title or "HAVEN HUB", TextColor3 = Theme.AccentSecondary, TextSize = 16, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 0), ZIndex = 25, Parent = prompt})
        Create("TextLabel", {FontFace = InterFont(Enum.FontWeight.Medium), RichText = true, Text = dSettings.Description or "", TextColor3 = Theme.Text, TextSize = 13, TextTransparency = 0.25, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1, Size = UDim2.fromScale(1, 0), ZIndex = 25, Parent = prompt})
        local interactions = Create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 2, Size = UDim2.fromScale(1, 0), ZIndex = 25, Parent = prompt}, {Create("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})})
        for _, v in pairs(dSettings.Buttons or {}) do
          local btn = Create("TextButton", {FontFace = InterFont(Enum.FontWeight.SemiBold), Text = v.Name, TextColor3 = Theme.Text, TextSize = 13, AutoButtonColor = false, AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.75, BorderSizePixel = 0, Size = UDim2.fromScale(1, 0), ZIndex = 25, Parent = interactions}, {
            Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
            Create("UIPadding", {PaddingBottom = UDim.new(0, 8), PaddingTop = UDim.new(0, 8)})
          })
          btn.MouseButton1Click:Connect(function() PlaySound("click") if v.Callback then v.Callback() end dialog:Destroy() end)
        end
      end

      function WindowFunctions:SetState(State)
        windowState = State
        base.Visible = State
        if State then
          baseScale.Scale = fitScale * 0.95
          Tween(baseScale, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = fitScale}):Play()
        end
      end
      function WindowFunctions:GetState() return windowState end
      function WindowFunctions:SetSoundsEnabled(State) soundsEnabled = (State == true) end
      function WindowFunctions:GetSoundsEnabled() return soundsEnabled end
      function WindowFunctions:SetAcrylicBlurState(State) acrylicBlur = State base.BackgroundTransparency = State and 0.03 or 0 end
      function WindowFunctions:GetAcrylicBlurState() return acrylicBlur end
      local showUserInfo = true
      function WindowFunctions:SetUserInfoState(State)
        showUserInfo = State
        headshot.Image = State and ((isReady and headshotImage) or "rbxassetid://0") or assets.userInfoBlurred
        username.Text = State and ("@" .. LocalPlayer.Name) or "@hidden"
        displayName.Text = State and LocalPlayer.DisplayName or "Haven Hub User"
      end
      function WindowFunctions:GetUserInfoState() return showUserInfo end

      UserInputService.InputEnded:Connect(function(inp, gpe)
        if not gpe and inp.KeyCode == MenuKeybind then WindowFunctions:SetState(not WindowFunctions:GetState()) end
      end)

      -- زر التصغير: يحوّل النافذة إلى شريط صغير (مناسب للجوال) والضغط مرة ثانية يرجّعها
      local BAR_SIZE = UDim2.fromOffset(320, HEADER_H)
      local collapsed = false
      local function SetCollapsed(State)
        if collapsed == State then return end
        collapsed = State
        -- نثبّت الحافة العلوية للنافذة مكانها أثناء التصغير/التكبير
        local shift = (windowSize.Y.Offset - BAR_SIZE.Y.Offset) / 2 * fitScale
        local pos = base.Position
        if State then
          if gsToggled then gsToggled = false globalSettingsUIScale.Scale = 0 end
          rail.Visible = false
          content.Visible = false
          globalSettingsButton.Visible = false
          header.Position = UDim2.fromOffset(0, 0)
          header.Size = UDim2.fromScale(1, 1)
          base.Size = BAR_SIZE
          base.Position = UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset - shift)
        else
          base.Size = windowSize
          base.Position = UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset + shift)
          header.Position = UDim2.fromOffset(RAIL_W, 0)
          header.Size = UDim2.new(1, -RAIL_W, 0, HEADER_H)
          rail.Visible = true
          content.Visible = true
          globalSettingsButton.Visible = true
        end
        minimizeLine.Visible = not State
        restoreBox.Visible = State
      end
      function WindowFunctions:SetCollapsed(State) SetCollapsed(State == true) end
      function WindowFunctions:GetCollapsed() return collapsed end
      minimize.MouseButton1Click:Connect(function() SetCollapsed(not collapsed) end)

      -- زر الإغلاق النهائي: يطفّي كل المميزات الشغالة ويحذف الواجهة وزر الشعار
      local function CloseHub()
        -- 1) نطفّي كل المميزات الشغالة
        for _, opt in pairs(haven.Options) do
          if opt.Class == "Toggle" and opt.State then pcall(function() opt:UpdateState(false) end) end
        end
        -- 2) من هنا ما يطلع أي صوت ولا يشتغل أي اختصار
        haven.Closed = true
        pcall(function() RunService:UnbindFromRenderStep("HavenAimLock") end)
        for _, conn in ipairs(HavenConnections) do pcall(function() conn:Disconnect() end) end
        for i = #HavenConnections, 1, -1 do HavenConnections[i] = nil end
        for kind, sound in pairs(soundCache) do
          pcall(function() sound:Stop() end)
          pcall(function() sound:Destroy() end)
          soundCache[kind] = nil
        end
        -- 3) نرجّع اللي غيّرناه ونحذف كل الواجهات
        pcall(function() LocalPlayer:SetAttribute("Elite", previousElite) end)
        screenGui:Destroy() pcall(function() LocalPlayer.PlayerGui.HavenClickButton:Destroy() end)
        shared.loaded = nil shared.VertexLoaded = nil
        pcall(function() getgenv().HavenHubStartedAt = nil end) -- عشان تقدر تشغّله من جديد مباشرة بعد الإطفاء
      end
      local closeDialogOpen = false
      exit.MouseButton1Click:Connect(function()
        if closeDialogOpen then return end
        closeDialogOpen = true
        SetCollapsed(false)
        WindowFunctions:Dialog({
          Title = "CLOSE HAVEN HUB",
          Description = "This closes the hub completely and turns off every running feature. You will need to run the script again to reopen it.",
          Buttons = {
            {Name = "Close Hub", Callback = CloseHub},
            {Name = "Cancel", Callback = function() closeDialogOpen = false end}
          }
        })
      end)

      -- حالة كل الخيارات كجدول: للحفظ بملف أو للنقل مع الريجوين
      function haven:ExportState()
        local data = {objects = {}}
        for flag, opt in pairs(haven.Options) do
          if opt.Class == "Toggle" then table.insert(data.objects, {type = "Toggle", flag = flag, state = opt.State or false})
          elseif opt.Class == "Slider" then table.insert(data.objects, {type = "Slider", flag = flag, value = tostring(opt.Value or 0)})
          elseif opt.Class == "Input" then table.insert(data.objects, {type = "Input", flag = flag, text = opt.Text or ""})
          elseif opt.Class == "Dropdown" then table.insert(data.objects, {type = "Dropdown", flag = flag, value = opt.Value})
          elseif opt.Class == "Keybind" then
            local bind = opt.GetBind and opt:GetBind()
            if bind then table.insert(data.objects, {type = "Keybind", flag = flag, key = bind.Name}) end
          end
        end
        return data
      end

      function haven:SaveConfig(Path)
        if not Path or not writefile then return false end
        local ok, enc = pcall(HttpService.JSONEncode, HttpService, haven:ExportState())
        if ok then pcall(writefile, haven.Folder .. "/settings/" .. tostring(Path) .. ".json", enc) end
        return true
      end

      function haven:LoadConfig(Path)
        shared.tabs = nil
        if not Path or not isfile or not readfile then return false end
        local file = haven.Folder .. "/settings/" .. tostring(Path) .. ".json"
        if not isfile(file) then return false end
        local ok, dec = pcall(HttpService.JSONDecode, HttpService, readfile(file))
        if not ok then return false end
        return haven:ImportState(dec)
      end

      function haven:ImportState(dec)
        if type(dec) ~= "table" or type(dec.objects) ~= "table" then return false end
        for _, opt in ipairs(dec.objects) do
          local target = haven.Options[opt.flag]
          if target then
            task.spawn(function()
              if opt.type == "Toggle" and opt.state ~= nil then target:UpdateState(opt.state)
              elseif opt.type == "Slider" and opt.value then target:UpdateValue(opt.value)
              elseif opt.type == "Input" and opt.text then target:UpdateText(opt.text)
              elseif opt.type == "Dropdown" and opt.value then target:UpdateSelection(opt.value)
              elseif opt.type == "Keybind" and type(opt.key) == "string" and opt.key ~= "" then
                local ok, key = pcall(function() return Enum.KeyCode[opt.key] end)
                if ok and key then target:Bind(key) end
              end
            end)
          end
        end
        return true
      end

      pcall(function()
        local pGui = LocalPlayer:WaitForChild("PlayerGui")
        if pGui:FindFirstChild("HavenClickButton") then pGui.HavenClickButton:Destroy() end
        local cGui = Create("ScreenGui", {Name = "HavenClickButton", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999999, ZIndexBehavior = Enum.ZIndexBehavior.Global, Parent = pGui})
        HideUntilReady(cGui)
        local cBtn = Create("TextButton", {Name = "ClickButton", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -20, 0.5, 0), Size = UDim2.fromOffset(48, 48), BackgroundTransparency = 0.08, BackgroundColor3 = Theme.BaseBg, FontFace = InterFont(Enum.FontWeight.Bold), Text = "HH", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 16, AutoButtonColor = false, ZIndex = 999999, Parent = cGui}, {Create("UICorner", {CornerRadius = UDim.new(0, 12)})})
        local cStroke = Create("UIStroke", {Thickness = 2, Transparency = 0.1, Color = Color3.fromRGB(255, 255, 255), ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = cBtn})
        Create("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(1, Theme.AccentSecondary)}), Parent = cStroke})
        local bDrag, bMoved, bStart, bPos = false, false, nil, nil
        cBtn.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then bStart = inp.Position bPos = cBtn.Position bDrag = false bMoved = false end end)
        UserInputService.InputChanged:Connect(function(inp)
          if bStart and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local delta = inp.Position - bStart
            if not bMoved and delta.Magnitude >= 8 then bMoved = true bDrag = true end
            if bDrag then cBtn.Position = UDim2.new(bPos.X.Scale, bPos.X.Offset + delta.X, bPos.Y.Scale, bPos.Y.Offset + delta.Y) end
          end
        end)
        UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then bStart = nil bDrag = false end end)
        cBtn.Activated:Connect(function() if not bMoved then PlaySound("click") WindowFunctions:SetState(not WindowFunctions:GetState()) end end)
      end)

      return WindowFunctions
    end
    return haven
  end)()

  -- ============================================================================
  -- 1.5 شاشة التحميل (HAVEN HUB Loading Screen)
  -- كل شيء هنا داخل pcall: لو فشل أي جزء، السكربت يكمل طبيعي بدون شاشة تحميل
  -- ============================================================================
  local HavenLoader = (function()
    local loader = {Active = false}
    local gui, cardScale, baseScale, renderConn
    local shown, target = 0, 0
    local visibility, visTarget = 0, 1
    local MIN_TIME = 6 -- أقل مدة تبقى فيها شاشة التحميل (بالثواني)
    local startedAt = os.clock()
    local fadeItems, particles = {}, {}

    -- شعار Haven Hub (PNG 256x256 شفاف) مدمج داخل السكربت بصيغة Base64
    local LOGO_B64 = table.concat({
      "iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAYAAABccqhmAACM4ElEQVR42uy9d5wk2VXn+703ItKWt91V7b333WN6jDQjjwAZhGAFQhLCo4VdQPD27WLfYnYx",
      "AoEAOeSQQBKSEJIQckijkWZGM9PT3ntb1V2+Km3Evef9EZFZmVVZ1Wa6e3o0eT6f+nR2nozMiBtxzP0dB3WqU53qVKc61alOdapTnepUpzrVqU51qlOd6lSn",
      "OtWpTnWqU53qVKc61alOdapTnepUpzrVqU51qlOd6lSnOtWpTnWqU53qVKc61alOdapTnepUpzrVqU51qlOd6lSnOtWpTnWqU53qVKc61alOdapTnepUpzrV",
      "qU51qlOd6lSnOtWpTnWqU53qVKc61alOdapTnepUpzrVqU51qlOd6lSnOtWpTnWqU53qVKc61alOdapTnepUpzrVqU51qlOd6lSnOtWpTnWqU53qVKc61alO",
      "dapTnepUpzrVqU51qlOd6lSnOtWpTnWqU53qVKc61alOzx9S9SWor3v9AXlhPXg6+lcAU3GPpb48t4xKa66AoOI9W1+aOt1qgXcAN/q3ipZBvL5Et0zgS+te",
      "i7y6B1CnW3W/Sla+ZOHLtKazsyFj1Drf93caP7g/MMFmYG/g5948CiN1T+CmWvgyLWqZs9CX4jYx5v5i0b9XhDZQvzvoZz4WKQpTVwB1uukCv3Xu3FR/sbhW",
      "inJvYPwH/EJhW94UF/hADEgnGsAKRvjJ6GF0az3Adbo+gV/Y3L1I8LcFxtzv+/7OfKGwpohJCtDoJnAdl8CaU4N+bnnFNuyOVLxu/V7f8QIvpb3kvHnzkozl",
      "1omEAn/i8uD2oinO96Mb2dnSwda1q2XHvfeYFz/8sPqj3/k9efx7j+mWhpYh/Ezd+l8bdmKm7t3ntrYu0FZtE2Pv933/3uHRwbVFgrQFUirGkqVL2bhls3n4",
      "5S+TQi4vv/6rv+ok3Nil6HvUnbzudQVwhwu8Hs+vtmLvDQL//uylge0Fk1/sR35lR3M7K9eslrt23mt23n+f2rB5s+qdP08DrrVW3vH2n1MOTlbH9O4p1s3W",
      "171K4Ku8q962tnnKqG3WmAd8P7gvMzK+rihB0gApXOYvWMCmrZvNzgcfkLt33qtXrVmjkqmUA/Dev35PkDW+bkimnqKARDJmo9+QugKoP3gzCvyaNWtimQuX",
      "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"
    })

    local DecodeBase64 = HavenDecodeBase64

    -- يكتب الشعار في مجلد HavenHub ويرجعه كـ asset (يرجع nil لو المشغل ما يدعم)
    local function GetLogoAsset()
      local getAsset = getcustomasset or getsynasset
      if type(writefile) ~= "function" or type(getAsset) ~= "function" then return nil end
      local path = "HavenHub/haven_logo.png"
      local bytes = DecodeBase64(LOGO_B64)
      if #bytes < 1000 then return nil end
      pcall(function()
        if makefolder and not (isfolder and isfolder("HavenHub")) then makefolder("HavenHub") end
      end)
      local needWrite = true
      pcall(function()
        if isfile and readfile and isfile(path) and readfile(path) == bytes then needWrite = false end
      end)
      if needWrite then writefile(path, bytes) end
      local asset = getAsset(path)
      if type(asset) == "string" and #asset > 0 then return asset end
      return nil
    end

    local RED       = Color3.fromRGB(225, 29, 46)
    local TRACK     = Color3.fromRGB(62, 62, 68)
    local WHITE     = Color3.fromRGB(255, 255, 255)
    local GREY      = Color3.fromRGB(165, 165, 172)
    local FONT_ID   = "rbxassetid://12187365364"

    local STAGES = {
      {0, "INITIALIZING"},
      {18, "CONNECTING TO GAME"},
      {38, "BUILDING INTERFACE"},
      {60, "LOADING FEATURES"},
      {85, "FINISHING UP"},
      {100, "READY"}
    }
    local TIPS = {
      "Press LeftControl or tap the logo button to show or hide the hub",
      "Use the bar button at the top to shrink the hub on small screens",
      "Open the gear button for quick settings like click sounds",
      "Your settings can be saved automatically from the Settings tab"
    }

    local function New(className, props, parent)
      local inst = Instance.new(className)
      for k, v in pairs(props) do inst[k] = v end
      inst.Parent = parent
      return inst
    end

    local function Circle(size, color, transparency, parent, zindex)
      local f = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(size, size), BackgroundColor3 = color, BackgroundTransparency = transparency, BorderSizePixel = 0, ZIndex = zindex or 1}, parent)
      New("UICorner", {CornerRadius = UDim.new(1, 0)}, f)
      return f
    end

    -- عنصر يظهر ويختفي تدريجياً مع الشاشة (prop يبدأ من 1 = مخفي)
    local function Fade(inst, prop, shownValue)
      inst[prop] = 1
      fadeItems[#fadeItems + 1] = {inst, prop, shownValue}
      return inst
    end

    local function Font_(weight)
      return Font.new(FONT_ID, weight, Enum.FontStyle.Normal)
    end

    local built = pcall(function()
      local logoAsset
      pcall(function() logoAsset = GetLogoAsset() end)
      loader.LogoAsset = logoAsset

      gui = Instance.new("ScreenGui")
      gui.Name = "HavenHubLoader"
      gui.ResetOnSpawn = false
      gui.IgnoreGuiInset = true
      gui.DisplayOrder = 1000
      gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
      if not SafeParentGui(gui) then error("no gui parent") end

      -- ====================== الخلفية (كامل الشاشة) ======================
      local backdrop = New("Frame", {Name = "Backdrop", Active = true, BackgroundColor3 = WHITE, BorderSizePixel = 0, ClipsDescendants = true, Size = UDim2.fromScale(1, 1)}, gui)
      New("UIGradient", {Rotation = 90, Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 7, 12)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(7, 7, 9)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(7, 7, 9)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(34, 6, 11))
      })}, backdrop)
      Fade(backdrop, "BackgroundTransparency", 0.1)

      -- جزيئات صغيرة تطفو للأعلى
      for i = 1, 28 do
        local size = math.random(2, 5)
        local frame = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = (i % 3 == 0) and WHITE or RED, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromOffset(size, size)}, backdrop)
        New("UICorner", {CornerRadius = UDim.new(1, 0)}, frame)
        particles[i] = {frame = frame, x = math.random(), y = math.random(), speed = 0.02 + math.random() * 0.05, alpha = 0.2 + math.random() * 0.45, sway = math.random() * 6.28}
      end

      -- خط مسح أفقي يتحرك على الشاشة
      local scan = New("Frame", {Name = "ScanLine", BackgroundColor3 = RED, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1)}, backdrop)
      New("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1)})}, scan)
      Fade(scan, "BackgroundTransparency", 0.55)

      -- زوايا الإطار في أركان الشاشة
      local corners = {
        {Vector2.new(0, 0), UDim2.fromOffset(22, 22)},
        {Vector2.new(1, 0), UDim2.new(1, -22, 0, 22)},
        {Vector2.new(0, 1), UDim2.new(0, 22, 1, -22)},
        {Vector2.new(1, 1), UDim2.new(1, -22, 1, -22)}
      }
      for _, c in ipairs(corners) do
        Fade(New("Frame", {AnchorPoint = c[1], BackgroundColor3 = RED, BorderSizePixel = 0, Position = c[2], Size = UDim2.fromOffset(30, 2)}, backdrop), "BackgroundTransparency", 0.3)
        Fade(New("Frame", {AnchorPoint = c[1], BackgroundColor3 = RED, BorderSizePixel = 0, Position = c[2], Size = UDim2.fromOffset(2, 30)}, backdrop), "BackgroundTransparency", 0.3)
      end

      -- نصوص الأطراف
      Fade(New("TextLabel", {Name = "Brand", BackgroundTransparency = 1, Position = UDim2.fromOffset(40, 34), Size = UDim2.fromOffset(200, 16), Text = "HAVEN HUB", TextColor3 = WHITE, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Font_(Enum.FontWeight.Bold)}, backdrop), "TextTransparency", 0.1)
      Fade(New("TextLabel", {Name = "Game", AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Position = UDim2.new(1, -40, 0, 34), Size = UDim2.fromOffset(220, 16), Text = "MURDER MYSTERY 2", TextColor3 = GREY, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right, FontFace = Font_(Enum.FontWeight.SemiBold)}, backdrop), "TextTransparency", 0.2)
      local tip = Fade(New("TextLabel", {Name = "Tip", AnchorPoint = Vector2.new(0.5, 1), BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 1, -34), Size = UDim2.new(1, -100, 0, 16), Text = TIPS[1], TextColor3 = GREY, TextSize = 11, TextTruncate = Enum.TextTruncate.AtEnd, FontFace = Font_(Enum.FontWeight.Medium)}, backdrop), "TextTransparency", 0.25)

      -- ====================== المحتوى في الوسط ======================
      local card = New("Frame", {Name = "Card", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(440, 410), BackgroundTransparency = 1, BorderSizePixel = 0}, gui)

      -- يصغر تلقائياً على الجوال ويكبر شوي على الشاشات الكبيرة
      baseScale = 1
      pcall(function()
        local vp = workspace.CurrentCamera.ViewportSize
        baseScale = math.clamp(math.min(vp.X / 520, vp.Y / 520), 0.4, 1.25)
      end)
      cardScale = New("UIScale", {Scale = baseScale * 0.8}, card)

      local holder = New("Frame", {Name = "LogoHolder", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.fromOffset(290, 290), BackgroundTransparency = 1}, card)

      -- حلقة خارجية كبيرة تدور ببطء
      local ringOuter = Circle(282, WHITE, 1, holder, 2)
      local outerStroke = New("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = RED, Thickness = 1, Transparency = 0}, ringOuter)
      local outerGrad = New("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(0.3, 1), NumberSequenceKeypoint.new(0.7, 1), NumberSequenceKeypoint.new(1, 0.35)})}, outerStroke)
      local ringMid = Circle(246, WHITE, 1, holder, 2)
      local midStroke = New("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = WHITE, Thickness = 1, Transparency = 0}, ringMid)
      local midGrad = New("UIGradient", {Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(0.25, 1), NumberSequenceKeypoint.new(0.75, 1), NumberSequenceKeypoint.new(1, 0.6)})}, midStroke)

      -- الحلقة الباهتة + القوس الأبيض + القوس الأحمر
      local ringBase = Circle(208, WHITE, 1, holder, 4)
      New("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = TRACK, Thickness = 1, Transparency = 0.35}, ringBase)
      local ringWhite = Circle(208, WHITE, 1, holder, 5)
      local whiteStroke = New("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = WHITE, Thickness = 2, Transparency = 0}, ringWhite)
      local whiteGrad = New("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.45, 0.85), NumberSequenceKeypoint.new(0.6, 1), NumberSequenceKeypoint.new(1, 1)})}, whiteStroke)
      local ringRed = Circle(190, WHITE, 1, holder, 5)
      local redStroke = New("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = RED, Thickness = 3, Transparency = 0}, ringRed)
      local redGrad = New("UIGradient", {Rotation = 180, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0.8), NumberSequenceKeypoint.new(0.7, 1), NumberSequenceKeypoint.new(1, 1)})}, redStroke)

      -- النقطة البيضاء التي تدور على الحلقة
      local orbit = New("Frame", {Name = "Orbit", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(208, 208), BackgroundTransparency = 1, ZIndex = 6}, holder)
      local dot = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(11, 11), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 6}, orbit)
      New("UICorner", {CornerRadius = UDim.new(1, 0)}, dot)

      -- الشعار (صورة) أو حرف H احتياطي لو المشغل ما يدعم getcustomasset
      local logo
      if logoAsset then
        logo = New("ImageLabel", {Name = "Logo", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(158, 158), BackgroundTransparency = 1, Image = logoAsset, ScaleType = Enum.ScaleType.Fit, ZIndex = 7}, holder)
      else
        logo = New("TextLabel", {Name = "Logo", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(150, 150), BackgroundTransparency = 1, Text = "H", TextColor3 = WHITE, TextSize = 96, FontFace = Font.new(FONT_ID, Enum.FontWeight.Bold, Enum.FontStyle.Italic), ZIndex = 7}, holder)
      end
      local logoScale = New("UIScale", {Scale = 1}, logo)

      -- النصوص
      New("TextLabel", {Name = "Title", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 300), Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "H A V E N   H U B", TextColor3 = WHITE, TextSize = 26, FontFace = Font_(Enum.FontWeight.Bold)}, card)
      local status = New("TextLabel", {Name = "Status", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 336), Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = STAGES[1][2], TextColor3 = RED, TextSize = 11, FontFace = Font_(Enum.FontWeight.Bold)}, card)

      -- شريط التقدم
      local track = New("Frame", {Name = "Track", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 370), Size = UDim2.fromOffset(300, 3), BackgroundColor3 = TRACK, BorderSizePixel = 0}, card)
      New("UICorner", {CornerRadius = UDim.new(1, 0)}, track)
      local fill = New("Frame", {Name = "Fill", Size = UDim2.fromScale(0, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0}, track)
      New("UICorner", {CornerRadius = UDim.new(1, 0)}, fill)
      New("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 16, 28)), ColorSequenceKeypoint.new(1, RED)})}, fill)
      local knob = New("Frame", {Name = "Knob", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(9, 9), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 2}, track)
      New("UICorner", {CornerRadius = UDim.new(1, 0)}, knob)
      New("UIStroke", {Color = RED, Thickness = 2, Transparency = 0.4}, knob)
      local percent = New("TextLabel", {Name = "Percent", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 384), Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = "0%", TextColor3 = WHITE, TextSize = 13, TextTransparency = 0.05, FontFace = Font_(Enum.FontWeight.SemiBold)}, card)

      -- الحركة: الدوران + الجزيئات + النسبة
      local angle = 0
      renderConn = RunService.RenderStepped:Connect(function(dt)
        local now = os.clock()
        local elapsed = now - startedAt

        angle = (angle + dt * 150) % 360
        orbit.Rotation = angle
        whiteGrad.Rotation = angle
        redGrad.Rotation = (180 - angle * 0.6) % 360
        outerGrad.Rotation = (angle * 0.3) % 360
        midGrad.Rotation = (90 - angle * 0.45) % 360
        logoScale.Scale = 1 + math.sin(now * 2.2) * 0.025

        visibility = visibility + (visTarget - visibility) * math.min(1, dt * 5)
        for _, item in ipairs(fadeItems) do
          item[1][item[2]] = 1 - (1 - item[3]) * visibility
        end
        for _, p in ipairs(particles) do
          p.y = p.y - p.speed * dt
          if p.y < -0.05 then p.y = 1.05 p.x = math.random() end
          p.frame.Position = UDim2.fromScale(p.x + math.sin(now * 0.6 + p.sway) * 0.01, p.y)
          p.frame.BackgroundTransparency = 1 - p.alpha * visibility
        end
        scan.Position = UDim2.fromScale(0, (now * 0.12) % 1.1 - 0.05)
        tip.Text = TIPS[math.floor(elapsed / 3) % #TIPS + 1]

        -- النسبة ما تسبق الوقت الأدنى، فالشاشة تبقى MIN_TIME ثواني على الأقل
        local goal = math.min(target, math.min(100, elapsed / MIN_TIME * 100))
        shown = shown + (goal - shown) * math.min(1, dt * 6)
        if math.abs(goal - shown) < 0.05 then shown = goal end
        local alpha = math.clamp(shown / 100, 0, 1)
        fill.Size = UDim2.fromScale(alpha, 1)
        knob.Position = UDim2.fromScale(alpha, 0.5)
        percent.Text = tostring(math.floor(shown + 0.5)) .. "%"
        local stageText = STAGES[1][2]
        for _, stage in ipairs(STAGES) do
          if shown + 0.5 >= stage[1] then stageText = stage[2] end
        end
        status.Text = (shown >= 99.5) and stageText or (stageText .. string.rep(".", math.floor(now * 2) % 4))
      end)

      TweenService:Create(cardScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = baseScale}):Play()
    end)

    if built then
      loader.Active = true
    else
      pcall(function() if renderConn then renderConn:Disconnect() end end)
      pcall(function() if gui then gui:Destroy() end end)
    end

    function loader:SetProgress(value)
      if not loader.Active then return end
      value = tonumber(value) or 0
      if value > target then target = math.clamp(value, 0, 100) end
    end

    function loader:Finish()
      if not loader.Active then return end
      loader.Active = false
      pcall(function()
        target = 100
        local started = os.clock()
        repeat task.wait() until shown >= 99.5 or os.clock() - started > MIN_TIME + 3
        task.wait(0.5)
        visTarget = 0
        TweenService:Create(cardScale, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {Scale = 0}):Play()
        task.wait(0.5)
      end)
      pcall(function() if renderConn then renderConn:Disconnect() end end)
      pcall(function() if gui then gui:Destroy() end end)
    end

    return loader
  end)()
  HavenLib.LogoAsset = HavenLoader.LogoAsset

  -- نافذة اختيار اللغة: تطلع فوق شاشة التحميل (بعدها عشان نستخدم الشعار) وقبل بناء أي قائمة.
  -- لو ما اخترت خلال 10 ثواني تمشي على آخر لغة اخترتها (عشان التشغيل التلقائي ما يوقف)
  do
    local saved, chosen = nil, nil
    pcall(function() if isfile and readfile and isfile("HavenHub/language.txt") then saved = readfile("HavenHub/language.txt") end end)
    local fallback = (saved == "Arabic") and "Arabic" or "English"
    pcall(function()
      local RED, WHITE, GREY = Color3.fromRGB(225, 29, 46), Color3.fromRGB(255, 255, 255), Color3.fromRGB(165, 165, 172)
      local gui = Instance.new("ScreenGui")
      gui.Name = "HavenHubLanguage" gui.ResetOnSpawn = false gui.IgnoreGuiInset = true gui.DisplayOrder = 1000000
      if not SafeParentGui(gui) then error("no gui parent") end
      -- خلفية معتمة تغطي الشاشة كلها
      local backdrop = Instance.new("Frame", gui)
      backdrop.Size = UDim2.fromScale(1, 1) backdrop.BackgroundColor3 = Color3.fromRGB(6, 6, 8) backdrop.BackgroundTransparency = 0.12 backdrop.BorderSizePixel = 0
      backdrop.Active = true

      local card = Instance.new("Frame", backdrop)
      card.AnchorPoint = Vector2.new(0.5, 0.5) card.Position = UDim2.fromScale(0.5, 0.5) card.Size = UDim2.fromOffset(380, 310)
      card.BackgroundColor3 = Color3.fromRGB(14, 14, 17) card.BorderSizePixel = 0
      Instance.new("UICorner", card).CornerRadius = UDim.new(0, 18)
      local stroke = Instance.new("UIStroke", card)
      stroke.Color = RED stroke.Thickness = 1.5 stroke.Transparency = 0.35
      local glow = Instance.new("UIGradient", card)
      glow.Rotation = 90
      glow.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(190, 190, 200))
      local scale = Instance.new("UIScale", card)
      -- يصغر على الشاشات الصغيرة (جوال)
      local fit = 1
      pcall(function()
        local vp = workspace.CurrentCamera.ViewportSize
        fit = math.clamp(math.min((vp.X - 24) / 380, (vp.Y - 24) / 310), 0.5, 1)
      end)
      scale.Scale = fit * 0.88
      TweenService:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = fit}):Play()

      local function text(parent, content, y, size, color, height)
        local lbl = Instance.new("TextLabel", parent)
        lbl.BackgroundTransparency = 1 lbl.Position = UDim2.fromOffset(0, y) lbl.Size = UDim2.new(1, 0, 0, height or 22)
        lbl.Font = Enum.Font.GothamBold lbl.Text = content lbl.TextSize = size lbl.TextColor3 = color
        return lbl
      end
      if HavenLoader.LogoAsset then
        local logo = Instance.new("ImageLabel", card)
        logo.BackgroundTransparency = 1 logo.AnchorPoint = Vector2.new(0.5, 0) logo.Position = UDim2.new(0.5, 0, 0, 18) logo.Size = UDim2.fromOffset(84, 84)
        logo.Image = HavenLoader.LogoAsset logo.ScaleType = Enum.ScaleType.Fit
      end
      text(card, "H A V E N   H U B", 108, 19, WHITE)
      text(card, "Choose your language   •   اختر لغتك", 134, 12, GREY)

      local buttons = {}
      local function button(title, caption, x, value)
        local btn = Instance.new("TextButton", card)
        btn.AutoButtonColor = false btn.Text = "" btn.Position = UDim2.fromOffset(x, 172) btn.Size = UDim2.fromOffset(160, 66)
        btn.BackgroundColor3 = Color3.fromRGB(24, 24, 28) btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
        local edge = Instance.new("UIStroke", btn)
        edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border edge.Color = RED edge.Thickness = 1.5
        local titleLabel = text(btn, title, 12, 17, WHITE)
        local captionLabel = text(btn, caption, 36, 10, GREY, 16)
        local function paint(active)
          TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = active and RED or Color3.fromRGB(24, 24, 28)}):Play()
          edge.Transparency = active and 0 or 0.75
          captionLabel.TextColor3 = active and WHITE or GREY
        end
        paint(value == fallback)
        buttons[value] = paint
        btn.MouseEnter:Connect(function() paint(true) end)
        btn.MouseLeave:Connect(function() paint(value == (chosen or fallback)) end)
        btn.Activated:Connect(function()
          chosen = value
          for other, repaint in pairs(buttons) do repaint(other == value) end
        end)
        return titleLabel
      end
      button("English", "Continue in English", 22, "English")
      button("العربية", "المتابعة بالعربية", 198, "Arabic")

      -- عدّاد الاختيار التلقائي: نص + شريط ينقص
      local timer = text(card, "", 254, 11, Color3.fromRGB(120, 120, 128), 16)
      local track = Instance.new("Frame", card)
      track.Position = UDim2.fromOffset(22, 282) track.Size = UDim2.fromOffset(336, 3) track.BackgroundColor3 = Color3.fromRGB(40, 40, 46) track.BorderSizePixel = 0
      Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
      local fill = Instance.new("Frame", track)
      fill.Size = UDim2.fromScale(1, 1) fill.BackgroundColor3 = RED fill.BorderSizePixel = 0
      Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

      local WAIT = 10
      local started = os.clock()
      repeat
        local left = math.max(0, WAIT - (os.clock() - started))
        timer.Text = (fallback == "Arabic" and "العربية" or "English") .. "  •  " .. math.ceil(left) .. "s"
        fill.Size = UDim2.fromScale(left / WAIT, 1)
        task.wait()
      until chosen or left <= 0
      -- خروج ناعم
      TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = fit * 0.9}):Play()
      TweenService:Create(backdrop, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
      task.wait(0.2)
      gui:Destroy()
    end)
    HavenLanguage = chosen or fallback
    pcall(function()
      if makefolder and isfolder and not isfolder("HavenHub") then makefolder("HavenHub") end
      if writefile then writefile("HavenHub/language.txt", HavenLanguage) end
    end)
    -- لو صار خطأ والنافذة بقت، نشيلها عشان ما تغطي الشاشة
    pcall(function()
      for _, getParent in ipairs({function() return gethui and gethui() end, function() return game:GetService("CoreGui") end, function() return LocalPlayer:FindFirstChild("PlayerGui") end}) do
        pcall(function()
          local parent = getParent()
          local leftover = parent and parent:FindFirstChild("HavenHubLanguage")
          if leftover then leftover:Destroy() end
        end)
      end
    end)
  end
  local havenReady = false -- يصير true بعد ما تخلص شاشة التحميل؛ الأوامر والتصويت ما يبدون قبله
  HavenLoader:SetProgress(15)

  -- ============================================================================
  -- 2. تشغيل نافذة HAVEN HUB وتبويبات اللعبة (بدون إيموجيات)
  -- ============================================================================
  shared.VertexLoaded = true
  shared.Premium = true

  repeat task.wait() until LocalPlayer.PlayerGui:FindFirstChild("MainGUI")
  HavenLoader:SetProgress(35)

  local platform = UserInputService:GetPlatform()
  local isDesktop = (platform == Enum.Platform.Windows or platform == Enum.Platform.OSX) or (UserInputService.KeyboardEnabled and UserInputService.MouseEnabled and not UserInputService.TouchEnabled)
  local Window = HavenLib:Window({
    Size = isDesktop and UDim2.fromOffset(620, 480) or UDim2.fromOffset(540, 400),
    DragStyle = 1,
    ShowUserInfo = true,
    Keybind = Enum.KeyCode.LeftControl,
    AcrylicBlur = true
  })
  if HavenLoader.Active then Window:SetState(false) end

  -- زر الفتح/الإغلاق: شعار Haven Hub بدل نص HH (يبقى HH لو الصورة غير متوفرة)
  pcall(function()
    if not HavenLoader.LogoAsset then return end
    local clickButton = LocalPlayer.PlayerGui.HavenClickButton.ClickButton
    local logo = Instance.new("ImageLabel")
    logo.Name = "Logo"
    logo.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.Position = UDim2.fromScale(0.5, 0.5)
    logo.Size = UDim2.fromScale(1, 1)
    logo.BackgroundTransparency = 1
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Image = HavenLoader.LogoAsset
    logo.ImageTransparency = 0.35
    logo.ZIndex = clickButton.ZIndex
    logo.Parent = clickButton
    clickButton.Text = ""
    -- الشعار لحاله: بدون المربع الأسود والإطار
    clickButton.BackgroundTransparency = 1
    clickButton.Size = UDim2.fromOffset(60, 60)
    local stroke = clickButton:FindFirstChildOfClass("UIStroke")
    if stroke then stroke.Enabled = false end
  end)
  HavenLoader:SetProgress(50)

  Vertex = Window:TabGroup()
  shared.tabs = {
    Main     = Vertex:Tab({Name = "Auto Farm", Short = "Farm", Image = "rbxassetid://10709811110"}),
    Roles    = Vertex:Tab({Name = "Combat", Short = "Combat", Image = "rbxassetid://10734975692"}),
    Target   = Vertex:Tab({Name = "Player Target", Short = "Target", Image = "rbxassetid://10734977012"}),
    Visual   = Vertex:Tab({Name = "ESP & Visuals", Short = "ESP", Image = "rbxassetid://10723346959"}),
    Player   = Vertex:Tab({Name = "My Character", Short = "Player", Image = "rbxassetid://10734920149"}),
    Tracker  = Vertex:Tab({Name = "Discord Webhooks", Short = "Discord", Image = "rbxassetid://10734943902"}),
    Settings = Vertex:Tab({Name = "Settings", Short = "Config", Image = "rbxassetid://10734963191"})
  }

  repeat task.wait() until shared.loaded
  HavenLoader:SetProgress(65)

  -- ============================================================================
  -- 3. الدوال والمميزات الكاملة (Murder Mystery 2)
  -- ============================================================================
  local v17, v14, v15, v18, val, v91
  local tbl, roles = {}, {}
  local Noclipping, antifling, unboxConnection

  local res = {
    emote = function(_, emoteName) pcall(function() ReplicatedStorage.Remotes.Misc.PlayEmote:Fire(emoteName) end) end,
    fling = function(_, targetPlayer)
      pcall(function()
        local char = LocalPlayer.Character
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local tChar = targetPlayer and targetPlayer.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
        local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
        if not (myRoot and hum and tRoot and tHum) then return end
        local savedCF, startPos = myRoot.CFrame, tRoot.Position
        local oldDestroyHeight = workspace.FallenPartsDestroyHeight
        workspace.FallenPartsDestroyHeight = 0 / 0 -- عشان ما تنحذف أجزاءنا لو طارت
        -- قوة دفع ضخمة ثابتة على الجذر: هذي اللي تقذف الهدف لما نلمسه
        local bv = Instance.new("BodyVelocity")
        bv.Name = "HavenFlingVel" bv.Velocity = Vector3.new(9e7, -9e8, 9e7) bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge) bv.Parent = myRoot
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        myRoot.CanCollide = true
        local function place(offset, angle)
          local cf = CFrame.new(tRoot.Position) * offset * CFrame.Angles(math.rad(angle), 0, 0)
          myRoot.CFrame = cf
          myRoot.AssemblyLinearVelocity = Vector3.new(9e7, -9e8, 9e7)
          myRoot.AssemblyAngularVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        local start, angle = os.clock(), 0
        repeat
          angle = angle + 100
          local lead = tHum.MoveDirection * tRoot.AssemblyLinearVelocity.Magnitude / 1.25
          -- نضربه من فوق ومن الجنب ونحن ندور، والدفع كله لتحت: يخترق الأرض ويطيح في الفويد
          place(CFrame.new(Vector3.new(0, 2, 0) + lead), angle) task.wait()
          place(CFrame.new(Vector3.new(0, 0.5, 0) + lead), angle) task.wait()
          place(CFrame.new(Vector3.new(1.5, 2, -1.5) + lead), angle) task.wait()
          place(CFrame.new(Vector3.new(-1.5, 0.5, 1.5) + lead), angle) task.wait()
          -- نكمل لين يموت أو يطيح تحت الماب أو يطير بعيد (مو بس أول ما يتحرك)
        until os.clock() - start > 3.5 or not tRoot.Parent or targetPlayer.Character ~= tChar
          or tHum.Health <= 0 or hum.Health <= 0
          or tRoot.Position.Y < startPos.Y - 150 or (tRoot.Position - startPos).Magnitude > 1500
        bv:Destroy()
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        -- نرجع لمكاننا ونصفّر السرعة (نكرر لين نثبت فعلاً)
        local back = os.clock()
        repeat
          myRoot.CFrame = savedCF
          for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then part.AssemblyLinearVelocity = Vector3.zero part.AssemblyAngularVelocity = Vector3.zero end
          end
          hum:ChangeState(Enum.HumanoidStateType.GettingUp)
          task.wait()
        until (myRoot.Position - savedCF.Position).Magnitude < 10 or os.clock() - back > 1
        workspace.FallenPartsDestroyHeight = oldDestroyHeight
      end)
    end
  }

  local function EquipTool(toolName)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    local tool = LocalPlayer.Backpack:FindFirstChild(toolName)
    if hum and tool then hum:EquipTool(tool) end
  end

  local function GetMapElement(arg1)
    for _, child in pairs(workspace:GetChildren()) do
      if child:IsA("Model") and not string.find(string.lower(child.Name), "lobby") then
        if arg1 == "CoinContainer" and child:FindFirstChild("CoinContainer") then return child.CoinContainer
        elseif arg1 == "Spawns" and child:FindFirstChild("Spawns") then return child.Spawns end
      end
    end
    return nil
  end

  local function GetGunDrop()
    local spawns = GetMapElement("Spawns")
    return (spawns and spawns.Parent and spawns.Parent:FindFirstChild("GunDrop")) or false
  end

  local function IsPlayerAlive(arg1, arg2)
    if not arg2 or not arg1 then return false end
    local pData = arg2[arg1.Name] or arg2
    if pData and (pData.Killed or pData.Dead) then
      return (arg1.Character and arg1.Character:FindFirstChild("HumanoidCloned")) ~= nil
    end
    return true
  end

  local function FindPlayerWithTool(toolName)
    for _, p in ipairs(Players:GetPlayers()) do
      if p.Backpack:FindFirstChild(toolName) or (p.Character and p.Character:FindFirstChild(toolName)) then return p.Name end
    end
    return nil
  end

  local function SetStats(ws, jp)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
      if ws then hum.WalkSpeed = ws end
      if jp then hum.JumpPower = jp end
    end
  end

  -- الأوتو فارم كله من تحت الأرض: الشخصية تمشي تحت العملات وتلقطها من تحت
  local FARM_DEPTH = 4 -- كم تنزل الشخصية تحت العملة
  local farmIsUnderground = false
  local flingBusy = false -- وقت الفلنق نوقف النوكلب مؤقتاً (الفلنق يحتاج تصادم)
  -- يرجّع الشخصية فوق الأرض (لما يتوقف الفارم) عشان ما تطيح من الماب
  local function SurfaceFromUnderground()
    if not farmIsUnderground then return end
    Mark("surface from underground (+" .. (FARM_DEPTH + 4) .. " studs)")
    farmIsUnderground = false
    pcall(function()
      local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
      if not root then return end
      root.AssemblyLinearVelocity = Vector3.zero
      root.CFrame = CFrame.new(root.Position + Vector3.new(0, FARM_DEPTH + 4, 0)) -- يرجع واقف
    end)
  end

  CoinAttribute = function(coinPart, checkOnly)
    if not coinPart then return false end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not root or not hum.Parent.PrimaryPart then return false end
    local dist = (coinPart.Position - hum.Parent.PrimaryPart.Position).Magnitude
    -- من تحت الأرض نحتاج مدى أكبر شوي عشان نوصل للعملة اللي فوقنا
    local reach = farmIsUnderground and math.max(4, FARM_DEPTH + 0.75) or 4
    if dist <= reach and shared.Premium then
      task.wait()
      if firetouchinterest then
        firetouchinterest(coinPart, root, 1) task.wait(0.1) firetouchinterest(coinPart, root, 0)
      end
      coinPart:Destroy()
    elseif dist <= 2 then
      task.wait(0.1) coinPart.Name = "haven_collected"
    end
    if coinPart:GetAttribute("Collected") == true then return false end
    return checkOnly == true
  end

  -- حالة شنطة العملات: اللعبة ترسل (نوع العملة، العدد الحالي، الحد الأقصى) مع كل عملة تنلقط
  local bagCounts = {}                              -- [نوع العملة] = {current, max, lastGain}
  local bagGui = {time = -math.huge, full = false}  -- فحص كلمة FULL في واجهة اللعبة (احتياطي)
  pcall(function()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local gameplay = remotes and remotes:FindFirstChild("Gameplay")
    local collected = gameplay and gameplay:FindFirstChild("CoinCollected")
    if not collected then return end
    table.insert(HavenConnections, collected.OnClientEvent:Connect(function(coinType, current, max)
      current, max = tonumber(current), tonumber(max)
      if coinType == nil or not current then return end
      local bag = bagCounts[coinType] or {current = 0, lastGain = os.clock()}
      if current > bag.current then bag.lastGain = os.clock() end
      bag.current = current
      if max and max > 0 then bag.max = max end
      bagCounts[coinType] = bag
    end))
  end)
  local function ResetBagState()
    for key in pairs(bagCounts) do bagCounts[key] = nil end
    bagGui.full = false
    bagGui.time = -math.huge
  end

  local function IsBagFull()
    -- 1) من أرقام اللعبة نفسها
    for _, bag in pairs(bagCounts) do
      if bag.max and bag.current >= bag.max then return true end
      if bag.current >= 50 then return true end -- 50 = أكبر شنطة
      -- بدون حد أقصى معروف: وصلنا 40+ وما زاد العدد من 10 ثواني والفارم شغال = ممتلئة
      if not bag.max and bag.current >= 40 and os.clock() - bag.lastGain > 10 and Options.AutoFarm and Options.AutoFarm:GetValue() then return true end
    end
    -- 2) كلمة FULL الظاهرة على شنطة العملات في واجهة اللعبة (نفحصها مرتين بالثانية)
    if os.clock() - bagGui.time > 0.5 then
      bagGui.time = os.clock()
      bagGui.full = false
      pcall(function()
        local main = LocalPlayer.PlayerGui:FindFirstChild("MainGUI")
        local bags = main and main:FindFirstChild("CoinBags", true)
        if not bags then return end
        for _, desc in ipairs(bags:GetDescendants()) do
          if desc:IsA("TextLabel") and desc.Visible and string.lower(desc.Text) == "full" then
            local shown, parent = true, desc.Parent
            while parent and parent ~= bags do
              if parent:IsA("GuiObject") and not parent.Visible then shown = false break end
              parent = parent.Parent
            end
            if shown then bagGui.full = true return end
          end
        end
      end)
    end
    if bagGui.full then return true end
    -- 3) الطريقة الأصلية
    if not roles then return false end
    local elite = LocalPlayer:GetAttribute("Elite")
    local coins = tonumber(roles.Coins) or 0
    return (elite ~= nil and coins >= 50) or (elite == nil and coins >= 40)
  end

  local function TweenTo(targetCF, speed, useQuad, waitCollect, targetCoin, exactSpeed)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if v17 then v17:Cancel() end
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    local dur = (root.Position - targetCF.Position).Magnitude / speed
    -- exactSpeed: السرعة ثابتة مهما بعدت المسافة (بدون حد الخمس ثواني اللي كان يسرّعها)
    dur = exactSpeed and math.max(dur, 0.1) or math.clamp(dur, 0.15, 5)
    local tween = TweenService:Create(root, TweenInfo.new(dur, useQuad and Enum.EasingStyle.Quad or Enum.EasingStyle.Linear, useQuad and Enum.EasingDirection.Out or Enum.EasingDirection.In), {CFrame = targetCF})
    v17 = tween tween:Play()
    if waitCollect and targetCoin then
      repeat task.wait()
        if not CoinAttribute(targetCoin, true) or IsBagFull() then break end
      until not IsPlayerAlive(LocalPlayer, roles)
    end
    v17 = nil
  end

  ShootMurderer = function()
    if not v14 then return end
    local gun = (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Gun")) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun"))
    local mPlayer = Players:FindFirstChild(v14)
    local mChar = mPlayer and mPlayer.Character
    local mRoot = mChar and mChar:FindFirstChild("HumanoidRootPart")
    local mHum = mChar and mChar:FindFirstChild("Humanoid")
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not gun or not mRoot or not mHum or not myRoot then return end

    local predictedCF = CFrame.new(mRoot.Position + (mRoot.AssemblyLinearVelocity or Vector3.zero) * Vector3.new(0, 0.5, 0) * 0.18666666666666665 + (mHum.MoveDirection or Vector3.zero) * 2.8)
    -- الطلقة تطلع من عند القاتل نفسه فتصيبه من ورا الجدار (كل أوامر الطلق، ما عدا Silent Aim و Aim Lock اللي ما يمرون من هنا)
    local att = mRoot:FindFirstChild("RootAttachment")
    local originCF = att and (att.WorldCFrame * CFrame.new(0, 2, 0)) or mRoot.CFrame
    local handle = gun:FindFirstChild("Handle")
    local reload = handle and handle:FindFirstChild("Reload")
    if reload and not reload.Playing then
      local shoot = workspace:FindFirstChild(LocalPlayer.Name) and workspace[LocalPlayer.Name]:FindFirstChild("Gun") and workspace[LocalPlayer.Name].Gun:FindFirstChild("Shoot")
      if shoot then Mark("gun shot through wall (ShootMurderer)") shoot:FireServer(originCF, predictedCF) end
    end
  end

  local function IsVisible(targetPlayer)
    local myRoot = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):FindFirstChild("HumanoidRootPart")
    local tRoot = targetPlayer and targetPlayer ~= LocalPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not tRoot then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    local hit = workspace:Raycast(myRoot.Position, (tRoot.Position - myRoot.Position).Unit * 50, params)
    return not hit or hit.Instance.Parent == targetPlayer.Character
  end

  local function EnableFloat()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and not root:FindFirstChild("BodyVelocity") then
      local bv = Instance.new("BodyVelocity", root)
      bv.Name = "BodyVelocity" bv.Velocity = Vector3.zero bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    end
    -- PlatformStand يمنع الشخصية تحاول توقف نفسها وهي منسدحة
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end
  end

  local function DisableFloat()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and root:FindFirstChild("BodyVelocity") then root.BodyVelocity:Destroy() end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
  end



  local function FindCoin(rootPart, mode)
    local container = GetMapElement("CoinContainer")
    if not container then return nil end
    local closest, huge, nearTbl, safeTbl = nil, math.huge, {}, {}
    local closestSafe, safeDist = nil, math.huge
    local mPlayer = v14 and Players:FindFirstChild(v14)
    local mRoot = mPlayer and mPlayer.Character and mPlayer.Character:FindFirstChild("HumanoidRootPart")
    local mPos = mRoot and mRoot.Position or nil

    for _, child in pairs(container:GetChildren()) do
      if CoinAttribute(child, true) and child.Name == "Coin_Server" and child:FindFirstChild("TouchInterest") and child:FindFirstChild("CoinVisual") and IsPlayerAlive(LocalPlayer, roles) then
        local pos = child.CoinVisual.Position
        local mag = (rootPart.Position - pos).Magnitude
        if mPos and (pos - mPos).Magnitude >= 25 then
          table.insert(safeTbl, child)
          if mag < safeDist then safeDist = mag closestSafe = child end
        end
        if mag <= 50 then table.insert(nearTbl, child) end
        if mag < huge then huge = mag closest = child end
      end
    end
    if mode == "closest" then return closest
    elseif mode == "safe" then return closestSafe or closest -- أقرب عملة بعيدة عن القاتل، ولو ما فيه فالأقرب
    elseif mode == "random" then
      if #nearTbl > 0 then return nearTbl[math.random(1, #nearTbl)]
      elseif #safeTbl > 0 then return safeTbl[math.random(1, #safeTbl)] end
    end
    return nil
  end

  -- يتحرك تحت العملة بسرعة ثابتة (من سلايدر Farm Speed) بدون أي انتقال فوري
  local lastFarmTeleport = 0
  local function MoveToCoin(coin, rootPart)
    local pos = coin.CoinVisual.Position
    local speed = math.clamp(tonumber(Options.FarmSpeed and Options.FarmSpeed:GetValue()) or 26, 16, 40)
    if not IsBagFull() and CoinAttribute(coin, true) then
      local style = Options.FarmStyle and Options.FarmStyle:GetValue() or "Underground Lying"
      farmIsUnderground = style ~= "Above Ground"
      local target = CFrame.new(pos.X, pos.Y + (farmIsUnderground and -FARM_DEPTH or 1.5), pos.Z)
      -- منسدح على بطنه (مو واقف) وهو يتحرك تحت الأرض
      if style == "Underground Lying" then target = target * CFrame.Angles(math.rad(-90), 0, 0) end
      if style == "Teleport" then
        -- انتقال فوري تحت العملة، مرة كل ثانية
        local waitLeft = 1 - (os.clock() - lastFarmTeleport)
        if waitLeft > 0 then task.wait(waitLeft) end
        if not (coin.Parent and rootPart.Parent and Options.AutoFarm:GetValue()) then return end
        lastFarmTeleport = os.clock()
        if v17 then v17:Cancel() v17 = nil end
        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.CFrame = target
        return
      end
      TweenTo(target, speed, false, false, nil, true)
    end
  end

  local farmFullHandled = false
  local function RunAutoFarm()
    pcall(function()
      local char = LocalPlayer.Character
      local hum = char and char:FindFirstChild("Humanoid")
      local root = char and char:FindFirstChild("HumanoidRootPart")
      if not v14 then farmIsUnderground = false farmFullHandled = false DisableFloat() return end

      local function farmStep()
        if not Options.AutoFarm:GetValue() or not IsPlayerAlive(LocalPlayer, roles) or not root then return end
        local pick = Options.FarmTarget and Options.FarmTarget:GetValue()
        local mode = (pick == "Random Nearby" and "random") or (pick == "Far From Murderer" and "safe") or "closest"
        local coin = FindCoin(root, mode) -- لازم ينادى كل فريم: هو اللي يلقط العملات القريبة
        -- غير "الأقرب": نكمل على نفس العملة لين تنلقط، وإلا الهدف يتغير كل فريم والشخصية ترجف
        if mode ~= "closest" and v18 and v18.Parent and v18.Name == "Coin_Server" and v18:GetAttribute("Collected") ~= true then return end
        if coin and v18 ~= coin then EnableFloat() MoveToCoin(coin, root) v18 = coin end
      end

      if not IsBagFull() or not root or not hum or hum.Health <= 0 or not IsPlayerAlive(LocalPlayer, roles) then farmFullHandled = false farmStep() return end
      -- الشنطة امتلت: نوقف الفارم في مكانه (تحت الأرض) لين الجولة الجاية
      if not farmFullHandled then
        farmFullHandled = true
        v18 = nil
        root.AssemblyLinearVelocity = Vector3.zero
        TweenService:Create(root, TweenInfo.new(0.05), {CFrame = root.CFrame}):Play() -- يوقف أي حركة شغالة
        Window:Notify({Title = "AUTO FARM", Description = "Bag is full. Farm paused until the next round.", Duration = 5})
      end
    end)
  end

  -- ============================================================================
  -- Advanced ESP: هيكل عظمي مفصل لمفصل + مربع + بطاقة، وكله يتعدل من قائمة ESP SETTINGS
  -- ============================================================================
  local EspColorNames = {"Red", "Blue", "Green", "Yellow", "Orange", "Purple", "Pink", "Cyan", "White", "Black"}
  local EspColors = {
    Red = Color3.fromRGB(225, 29, 46), Blue = Color3.fromRGB(0, 110, 255), Green = Color3.fromRGB(76, 215, 134),
    Yellow = Color3.fromRGB(255, 214, 10), Orange = Color3.fromRGB(255, 140, 0), Purple = Color3.fromRGB(160, 90, 255),
    Pink = Color3.fromRGB(255, 105, 180), Cyan = Color3.fromRGB(0, 220, 230), White = Color3.fromRGB(255, 255, 255), Black = Color3.fromRGB(15, 15, 18)
  }
  -- الخيارات تنبني بعد هالكود، فنقرأها وقت التشغيل مع قيمة افتراضية
  local function EspOpt(id, default)
    local opt = Options[id]
    if not opt then return default end
    local value = opt:GetValue()
    if value == nil then return default end
    return value
  end
  local function EspColor(id, default) return EspColors[EspOpt(id, default)] or EspColors[default] end

  local espState = {} -- [player] = لون الهيكل (أو nil لو هيكله مخفي)
  local espLines = {} -- [player] = {LineHandleAdornment, ...}
  local espFolder = nil
  local function GetEspFolder()
    if not (espFolder and espFolder.Parent) then
      espFolder = Instance.new("Folder")
      espFolder.Name = "HavenEspLines"
      if not SafeParentGui(espFolder) then espFolder.Parent = workspace end
    end
    return espFolder
  end

  -- نقطة على محور القطعة: 0.5 = أعلاها، -0.5 = أسفلها
  local function EspJoint(part, yScale) return (part.CFrame * CFrame.new(0, part.Size.Y * yScale, 0)).Position end
  -- عظام الشخصية كأزواج نقاط (من، إلى) بين المفاصل الفعلية: رقبة، كتف، كوع، يد، حوض، ورك، ركبة، قدم
  -- أسماء القطع تتخزن لكل شخصية مرة وحدة بدل البحث عنها كل فريم
  local espPartCache = setmetatable({}, {__mode = "k"})
  local function Part(char, name)
    local cache = espPartCache[char]
    if not cache then cache = {} espPartCache[char] = cache end
    local part = cache[name]
    if part and part.Parent == char then return part end
    part = char:FindFirstChild(name)
    cache[name] = part
    return part
  end
  local function GetBones(char)
    local bones = {}
    local function add(a, b) if a and b then table.insert(bones, a) table.insert(bones, b) end end
    local head = Part(char, "Head")
    local upper, lower = Part(char, "UpperTorso"), Part(char, "LowerTorso")
    if upper and lower then -- R15
      local neck, pelvis = EspJoint(upper, 0.5), lower.Position
      add(head and head.Position, neck) add(neck, pelvis)
      for _, side in ipairs({"Left", "Right"}) do
        local upperArm, lowerArm, hand = Part(char, side .. "UpperArm"), Part(char, side .. "LowerArm"), Part(char, side .. "Hand")
        if upperArm and lowerArm then
          local shoulder, elbow = EspJoint(upperArm, 0.5), EspJoint(lowerArm, 0.5)
          add(neck, shoulder) add(shoulder, elbow) add(elbow, hand and hand.Position or EspJoint(lowerArm, -0.5))
        end
        local upperLeg, lowerLeg, foot = Part(char, side .. "UpperLeg"), Part(char, side .. "LowerLeg"), Part(char, side .. "Foot")
        if upperLeg and lowerLeg then
          local hip, knee = EspJoint(upperLeg, 0.5), EspJoint(lowerLeg, 0.5)
          add(pelvis, hip) add(hip, knee) add(knee, foot and foot.Position or EspJoint(lowerLeg, -0.5))
        end
      end
    else -- R6
      local torso = Part(char, "Torso")
      if not torso then return bones end
      local neck, pelvis = EspJoint(torso, 0.5), EspJoint(torso, -0.5)
      add(head and head.Position, neck) add(neck, pelvis)
      for _, side in ipairs({"Left", "Right"}) do
        local arm, leg = Part(char, side .. " Arm"), Part(char, side .. " Leg")
        if arm then local shoulder = EspJoint(arm, 0.5) add(neck, shoulder) add(shoulder, EspJoint(arm, -0.5)) end
        if leg then local hip = EspJoint(leg, 0.5) add(pelvis, hip) add(hip, EspJoint(leg, -0.5)) end
      end
    end
    return bones
  end

  -- كل فريم: يرسم خطوط الهيكل بين المفاصل (لازم كل فريم عشان تمشي مع حركة اللاعب)
  local function RenderSkeletons()
    local thickness = tonumber(EspOpt("EspThickness", 2)) or 2
    for player, lines in pairs(espLines) do
      local color, char = espState[player], player.Character
      local bones = (color and char) and GetBones(char) or {}
      local count = #bones / 2
      for index = 1, math.max(count, #lines) do
        local line = lines[index]
        if index <= count then
          if not line then
            line = Instance.new("LineHandleAdornment")
            line.Adornee = workspace.Terrain line.AlwaysOnTop = true line.ZIndex = 5
            line.Parent = GetEspFolder()
            lines[index] = line
          end
          local from, to = bones[index * 2 - 1], bones[index * 2]
          local length = (to - from).Magnitude
          line.Visible = length > 0.01
          if length > 0.01 then
            line.CFrame = CFrame.lookAt(from, to) line.Length = length line.Color3 = color line.Thickness = thickness
          end
        elseif line then
          line.Visible = false
        end
      end
    end
  end

  local function EspRemove(char, name)
    local head = char and char:FindFirstChild("Head")
    local gui = head and head:FindFirstChild(name)
    if gui then gui:Destroy() end
  end

  -- كل 0.2 ثانية: يحدد مين يظهر له ESP ولونه، ويحدّث المربع والبطاقة
  local function UpdateChams()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local showMode = EspOpt("EspShow", "Everyone")
    for player, lines in pairs(espLines) do
      if player.Parent == nil then
        for _, line in ipairs(lines) do line:Destroy() end
        espLines[player] = nil espState[player] = nil
      end
    end
    for _, player in pairs(Players:GetPlayers()) do
      if player ~= LocalPlayer then
        local char = player.Character
        local head = char and char:FindFirstChild("Head")
        -- الدور من بيانات الجولة، ولو ناقصة (دولز/زومبي) من السلاح اللي معه
        local item = roles and roles[player.Name]
        local role = type(item) == "table" and item.Role or nil
        local backpack = player:FindFirstChild("Backpack")
        local function has(tool) return (backpack and backpack:FindFirstChild(tool)) or (char and char:FindFirstChild(tool)) end
        local key, color
        if not IsPlayerAlive(player, roles) then key, color = "Dead", EspColors.White
        elseif role == "Murderer" or has("Knife") then key, color = "Murderer", EspColor("EspMurdererColor", "Red")
        elseif role == "Sheriff" or role == "Hero" or has("Gun") then key, color = "Sheriff", EspColor("EspSheriffColor", "Blue")
        else key, color = "Innocent", EspColor("EspInnocentColor", "Green") end
        local visible = head ~= nil and (
          showMode == "Everyone"
          or (showMode == "Murderer" and key == "Murderer")
          or (showMode == "Sheriff" and key == "Sheriff")
          or (showMode == "Murderer + Sheriff" and (key == "Murderer" or key == "Sheriff"))
          or (showMode == "Innocents" and key == "Innocent")
          or (showMode == "Chosen Player" and player.Name == EspOpt("EspPlayer", nil)))

        -- الهيكل
        espLines[player] = espLines[player] or {}
        if visible and EspOpt("EspSkeleton", true) then
          local pick = EspOpt("EspSkeletonColor", "Black")
          espState[player] = (pick == "Role Color") and color or EspColors[pick] or EspColors.Black
        else
          espState[player] = nil
        end

        -- المربع: حجمه بالستد فيصغر ويكبر مع المسافة
        if visible and EspOpt("EspBox", true) then
          local box = head:FindFirstChild("HavenEspBox")
          if not box then
            box = Instance.new("BillboardGui")
            box.Name = "HavenEspBox" box.Size = UDim2.new(4.2, 0, 6, 0) box.StudsOffset = Vector3.new(0, -0.2, 0) box.AlwaysOnTop = true
            local fill = Instance.new("Frame", box)
            fill.Name = "Fill" fill.Size = UDim2.new(1, 0, 1, 0) fill.BorderSizePixel = 0
            local edge = Instance.new("UIStroke", fill)
            edge.Name = "Edge" edge.Thickness = 1.5
            box.Parent = head
          end
          box.Adornee = char:FindFirstChild("HumanoidRootPart") or head
          local fill = box:FindFirstChild("Fill")
          if fill then
            fill.BackgroundColor3 = color
            fill.BackgroundTransparency = (EspOpt("EspBoxStyle", "Filled") == "Filled") and 0.65 or 1
            local edge = fill:FindFirstChild("Edge")
            if edge then edge.Color = color end
          end
        else
          EspRemove(char, "HavenEspBox")
        end

        -- البطاقة: الاسم، الدور، المسافة، الصحة
        if visible and EspOpt("EspTag", true) then
          local tag = head:FindFirstChild("HavenEspTag")
          if not tag then
            tag = Instance.new("BillboardGui")
            tag.Name = "HavenEspTag" tag.Adornee = head tag.Size = UDim2.new(0, 220, 0, 34) tag.StudsOffset = Vector3.new(0, 4.2, 0) tag.AlwaysOnTop = true
            local lbl = Instance.new("TextLabel", tag)
            lbl.Name = "Label" lbl.BackgroundTransparency = 1 lbl.Size = UDim2.new(1, 0, 1, 0) lbl.TextSize = 13 lbl.Font = Enum.Font.GothamBold
            lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) lbl.TextStrokeTransparency = 0.3
            tag.Parent = head
          end
          local lbl = tag:FindFirstChild("Label")
          if lbl then
            local dist = myRoot and math.floor((head.Position - myRoot.Position).Magnitude) or 0
            local hum = char:FindFirstChildOfClass("Humanoid")
            lbl.Text = player.Name .. "\n" .. string.upper(key) .. "  •  " .. dist .. "m  •  " .. math.floor(hum and hum.Health or 0) .. " HP"
            lbl.TextColor3 = color
          end
        else
          EspRemove(char, "HavenEspTag")
        end
      end
    end
  end

  local function CreateNameESP(player)
    if player ~= LocalPlayer and player.Character then
      local head = player.Character:FindFirstChild("Head")
      if head and not head:FindFirstChild("UsernameTag") then
        local bb = Instance.new("BillboardGui", head)
        bb.Name = "UsernameTag" bb.Adornee = head bb.Size = UDim2.new(0, 200, 0, 50) bb.StudsOffset = Vector3.new(0, 2.5, 0) bb.AlwaysOnTop = true
        local lbl = Instance.new("TextLabel", bb)
        lbl.Text = player.Name lbl.TextSize = 18 lbl.BackgroundTransparency = 1 lbl.TextColor3 = Color3.fromRGB(255, 255, 255) lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) lbl.TextStrokeTransparency = 0.4 lbl.Size = UDim2.new(1, 0, 1, 0) lbl.Font = Enum.Font.GothamBold
      end
    end
  end

  local function ClearESP()
    for k, v in pairs(tbl) do if v then v:Destroy() end tbl[k] = nil end
    for _, lines in pairs(espLines) do for _, line in ipairs(lines) do pcall(function() line:Destroy() end) end end
    espLines, espState = {}, {}
    if espFolder then pcall(function() espFolder:Destroy() end) espFolder = nil end
    for _, p in pairs(Players:GetPlayers()) do
      local head = p.Character and p.Character:FindFirstChild("Head")
      if head and head:FindFirstChild("UsernameTag") then head.UsernameTag:Destroy() end
      if head and head:FindFirstChild("HavenEspTag") then head.HavenEspTag:Destroy() end
      if head and head:FindFirstChild("HavenEspBox") then head.HavenEspBox:Destroy() end
    end
  end

  -- ============================================================================
  -- 4. بناء الأزرار والخيارات (بدون إيموجيات نهائياً)
  -- ============================================================================
  HavenLoader:SetProgress(75)
  shared.Main:SubLabel({Text = "AUTO FARMING & COLLECTION"})
  shared.Main:Toggle("AutoFarm", "Enable Coin Auto-Farm", function(arg1)
    if arg1 then
      local lastNoclip = 0
      Noclipping = RunService.Stepped:Connect(function()
        if os.clock() - lastNoclip < 0.15 then return end
        lastNoclip = os.clock()
        if LocalPlayer.Character and IsPlayerAlive(LocalPlayer, roles) and not flingBusy then
          for _, d in pairs(LocalPlayer.Character:GetDescendants()) do if d:IsA("BasePart") and d.CanCollide then d.CanCollide = false end end
        end
      end)
    end
    repeat task.wait(0.03) RunAutoFarm() until not Options.AutoFarm:GetValue()
    SurfaceFromUnderground()
    if Noclipping then Noclipping:Disconnect() end
    DisableFloat()
  end)

  shared.Main:Slider("FarmSpeed", "Farm Speed", 16, 40, 26, "Percent", function() end)
  shared.Main:Dropdown({Name = "Farm Style", Multi = false, Required = true, Options = {"Underground Lying", "Underground Standing", "Above Ground", "Teleport"}, Default = 1, Callback = function() end}, "FarmStyle")
  shared.Main:Dropdown({Name = "Farm Target", Multi = false, Required = true, Options = {"Closest", "Random Nearby", "Far From Murderer"}, Default = 1, Callback = function() end}, "FarmTarget")
  -- ==========================================================================
  -- أوامر الشنطة الممتلئة: تشتغل أول ما توصل الشنطة 50 أو تصير FULL، حسب دورك في الجولة
  -- ==========================================================================
  local function HasTool(player, toolName)
    local backpack = player:FindFirstChild("Backpack")
    return (backpack and backpack:FindFirstChild(toolName)) or (player.Character and player.Character:FindFirstChild(toolName))
  end

  -- يطلق على لاعب. الافتراضي: الطلقة تطلع من عند الهدف نفسه فتصيب حتى لو بينكم جدار.
  -- fromSelf = true: الطلقة تطلع من مسدسك أنت (تُستخدم لما تكون واقف جنب الهدف)
  local function ShootAtPlayer(target, fromSelf)
    local gun = HasTool(LocalPlayer, "Gun")
    local tChar = target and target.Character
    local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
    local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not (gun and tRoot and tHum and myRoot) then return false end
    local predictedCF = CFrame.new(tRoot.Position + (tRoot.AssemblyLinearVelocity or Vector3.zero) * Vector3.new(0, 0.5, 0) * 0.18666666666666665 + (tHum.MoveDirection or Vector3.zero) * 2.8)
    local originCF
    if fromSelf then
      local shoulder = myRoot:FindFirstChild("GunShoulderAttachment")
      originCF = shoulder and shoulder.WorldCFrame or myRoot.CFrame
    else
      local att = tRoot:FindFirstChild("RootAttachment")
      originCF = att and (att.WorldCFrame * CFrame.new(0, 2, 0)) or tRoot.CFrame
    end
    local handle = gun:FindFirstChild("Handle")
    local reload = handle and handle:FindFirstChild("Reload")
    if reload and reload.Playing then return false end
    local equipped = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")
    local shoot = equipped and equipped:FindFirstChild("Shoot")
    if not shoot then return false end
    Mark(fromSelf and "gun shot from my position" or "gun shot through wall (origin at target)")
    shoot:FireServer(originCF, predictedCF)
    return true
  end

  -- أقرب لاعب حي يحقق الشرط
  local function NearestPlayerWhere(condition)
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local best, bestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
      local tRoot = (p ~= LocalPlayer) and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
      local hum = tRoot and p.Character:FindFirstChildOfClass("Humanoid")
      if tRoot and hum and hum.Health > 0 and IsPlayerAlive(p, roles) and condition(p) then
        local dist = (tRoot.Position - myRoot.Position).Magnitude
        if dist < bestDist then bestDist = dist best = p end
      end
    end
    return best
  end

  -- يضرب بالسكين كل لاعب حي يحقق الشرط: ينتقل وراه، يطعنه، وينتقل للي بعده، ثم يرجع لمكانه
  -- (السيرفر يرفض الطعنة لو كنت بعيد، عشان كذا لازم ننتقل لكل واحد)
  local function StabPlayersWhere(condition)
    EquipTool("Knife")
    task.wait(0.1)
    local knife = HasTool(LocalPlayer, "Knife")
    local touched = knife and knife:FindFirstChild("Events") and knife.Events:FindFirstChild("HandleTouched")
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not (touched and myRoot) then return 0 end
    Mark("teleport to players and stab")
    local home, stabbed = myRoot.CFrame, 0
    for _, p in ipairs(Players:GetPlayers()) do
      local tChar = (p ~= LocalPlayer) and p.Character
      local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
      local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
      if tRoot and tHum and tHum.Health > 0 and IsPlayerAlive(p, roles) and condition(p) then
        pcall(function()
          local started = os.clock()
          repeat
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 2)
            task.wait()
          until os.clock() - started > 0.15 or not tRoot.Parent
          for _, name in ipairs({"HumanoidRootPart", "Head", "UpperTorso", "Torso"}) do
            local part = tChar:FindFirstChild(name)
            if part then touched:FireServer(part) end
          end
          task.wait(0.1)
          stabbed = stabbed + 1
        end)
      end
    end
    pcall(function() myRoot.AssemblyLinearVelocity = Vector3.zero myRoot.CFrame = home end)
    return stabbed
  end

  local function AliveOthers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
      local hum = (p ~= LocalPlayer) and p.Character and p.Character:FindFirstChildOfClass("Humanoid")
      if hum and hum.Health > 0 and p.Character:FindFirstChild("HumanoidRootPart") and IsPlayerAlive(p, roles) then table.insert(list, p) end
    end
    return list
  end

  -- يرمي السكين على كل لاعب من بعيد بدون انتقال: الرمية تطلع من جنب الهدف نفسه (نفس حيلة المسدس)
  -- يرجّع nil لو ما لقى أمر الرمي
  local function ThrowKnifeAtAll()
    EquipTool("Knife")
    task.wait(0.1)
    local knife = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Knife")
    local throw
    for _, d in ipairs(knife and knife:GetDescendants() or {}) do
      if d:IsA("RemoteEvent") and string.find(string.lower(d.Name), "throw", 1, true) then throw = d break end
    end
    if not throw then return nil end
    Mark("knife throws from far (origin near target)")
    for _, p in ipairs(AliveOthers()) do
      local tRoot = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
      if tRoot then
        local pos = tRoot.Position
        local origin = CFrame.lookAt((tRoot.CFrame * CFrame.new(0, 1, 3)).Position, pos)
        -- shortcut: شكل الأرقام مخمَّن (KnifeThrown = CFrame,CFrame / القديم Throw = CFrame,Vector3) وما انجرّب باللعبة، عدّله لو الرمية ما تصيب
        throw:FireServer(origin, throw.Name == "KnifeThrown" and CFrame.new(pos) or pos)
        task.wait(0.8) -- مهلة رجوع السكين قبل الرمية الجاية
      end
    end
    return true
  end

  -- القاتل: يقتل كل اللي بالجولة من بعيد برمي السكين، ولو الرمي ما قتل أحد يرجع للانتقال والطعن
  local throwFailed = false
  shared.Main:Toggle("KillAllFullBag", "Kill Everyone When Bag Is Full", function(arg1)
    if arg1 then
      repeat task.wait(0.2)
        pcall(function()
          if v14 == LocalPlayer.Name and HasTool(LocalPlayer, "Knife") and IsBagFull() and IsPlayerAlive(LocalPlayer, roles) then
            local before = #AliveOthers()
            if before == 0 then return end
            if not throwFailed then
              local ok = ThrowKnifeAtAll()
              task.wait(1)
              if not ok or #AliveOthers() >= before then throwFailed = true end
            else
              StabPlayersWhere(function() return true end)
            end
          end
        end)
      until not Options.KillAllFullBag:GetValue()
    end
  end)

  local function IsGunReloading()
    local gun = HasTool(LocalPlayer, "Gun")
    local handle = gun and gun:FindFirstChild("Handle")
    local reload = handle and handle:FindFirstChild("Reload")
    return reload ~= nil and reload.Playing == true
  end

  -- ينتقل ورا الهدف مباشرة، يطلق عليه من قريب، ثم يرجع لمكانه
  local function TeleportShoot(target)
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not (myRoot and tRoot) then return false end
    EquipTool("Gun")
    if IsGunReloading() then return false end
    Mark("teleport to target and shoot")
    local home = myRoot.CFrame
    local fired = false
    pcall(function()
      -- نبقى ورا الهدف لحظة عشان السيرفر يسجّل مكاننا، ثم نطلق
      local started = os.clock()
      repeat
        local behind = (tRoot.CFrame * CFrame.new(0, 0, 4)).Position
        myRoot.AssemblyLinearVelocity = Vector3.zero
        myRoot.CFrame = CFrame.lookAt(behind, tRoot.Position)
        task.wait()
      until os.clock() - started > 0.2 or not tRoot.Parent
      fired = ShootAtPlayer(target, true)
      task.wait(0.15)
    end)
    -- نرجع لمكاننا (تحت الأرض لو الفارم شغال)
    pcall(function()
      myRoot.AssemblyLinearVelocity = Vector3.zero
      myRoot.CFrame = home
    end)
    return fired
  end

  -- الشريف (أو أي أحد معه المسدس): يطلق على القاتل من مكانه من ورا الجدار (الطلقة تطلع من عند القاتل نفسه)
  -- ولو طلقتين ما قتلته، ينتقل له ويطلق من قريب ويرجع
  local wallShots = 0
  shared.Main:Toggle("ShootFullBag", "Shoot Murderer When Bag Is Full", function(arg1)
    if arg1 then
      repeat task.wait(0.1)
        pcall(function()
          local murderer = v14 and v14 ~= LocalPlayer.Name and Players:FindFirstChild(v14)
          local mHum = murderer and murderer.Character and murderer.Character:FindFirstChildOfClass("Humanoid")
          if not (mHum and mHum.Health > 0 and IsPlayerAlive(murderer, roles)) then wallShots = 0 return end
          if not (HasTool(LocalPlayer, "Gun") and IsBagFull() and IsPlayerAlive(LocalPlayer, roles)) then return end
          if IsGunReloading() then return end
          local fired
          if wallShots < 2 then
            EquipTool("Gun")
            task.wait(0.1) -- المسدس لازم يكون باليد قبل الطلقة
            fired = ShootAtPlayer(murderer)
            if fired then wallShots = wallShots + 1 end
          else
            fired = TeleportShoot(murderer)
          end
          -- ننتظر الطلقة توصل قبل ما نحكم إنه لسا حي
          if fired then task.wait(0.6) end
        end)
      until not Options.ShootFullBag:GetValue()
    end
  end)

  -- فلنق يشتغل حتى والفارم شغال: نرجّع التصادم ونشيل الطفو مؤقتاً، ثم نرجع لمكاننا
  local function FlingWithCollision(target)
    if flingBusy then return end
    flingBusy = true
    pcall(function()
      local char = LocalPlayer.Character
      local root = char and char:FindFirstChild("HumanoidRootPart")
      if not root then return end
      local hadFloat = root:FindFirstChild("BodyVelocity") ~= nil
      DisableFloat()
      for _, name in ipairs({"HumanoidRootPart", "Head", "Torso", "UpperTorso", "LowerTorso"}) do
        local part = char:FindFirstChild(name)
        if part then part.CanCollide = true end
      end
      Mark("fling")
      res:fling(target)
      if hadFloat then EnableFloat() end
    end)
    flingBusy = false
  end

  -- بريء (بدون سكين ولا مسدس): يسوي فلنق للقاتل
  shared.Main:Toggle("FlingFullBag", "Fling Murderer When Bag Is Full", function(arg1)
    if arg1 then
      repeat task.wait(0.3)
        pcall(function()
          local innocent = not HasTool(LocalPlayer, "Knife") and not HasTool(LocalPlayer, "Gun")
          -- يشتغل لما تمتلي الشنطة، ويكمل حتى لو متّ وطلعت من الجولة
          local outOfRound = not IsPlayerAlive(LocalPlayer, roles)
          if innocent and v14 and v14 ~= LocalPlayer.Name and (IsBagFull() or outOfRound) then
            local murderer = Players:FindFirstChild(v14)
            if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") and IsPlayerAlive(murderer, roles) then
              FlingWithCollision(murderer)
              task.wait(2)
            end
          end
        end)
      until not Options.FlingFullBag:GetValue()
    end
  end)

  -- وضع الزومبي: الناجين معهم مسدسات والزومبي معهم سكاكين
  shared.Main:SubLabel({Text = "ZOMBIE MODE"})

  -- ناجي: يسوي فلنق لكل الزومبي (اللي معهم سكين) واحد ورا الثاني، ويعيد على اللي باقي حي
  -- مود الزومبي فقط: بالجولة العادية فيه سكين وحدة ومسدس واحد، فلو غيرك معه مسدس أو فيه أكثر من سكين فهو مود زومبي
  local function IsZombieRound()
    local knives = 0
    for _, p in ipairs(Players:GetPlayers()) do
      if p ~= LocalPlayer and HasTool(p, "Gun") then return true end
      if HasTool(p, "Knife") then knives = knives + 1 end
    end
    return knives >= 2
  end

  shared.Main:Toggle("ZombieShoot", "Survivor: Kill Zombies When Bag Is Full", function(arg1)
    if arg1 then
      repeat task.wait(0.3)
        pcall(function()
          -- بدون هالشرط كان يسوي فلنق للقاتل بالجولة العادية لما تكون شريف
          if not IsZombieRound() then return end
          for _, p in ipairs(Players:GetPlayers()) do
            if not Options.ZombieShoot:GetValue() then return end
            if not (HasTool(LocalPlayer, "Gun") and IsBagFull() and IsPlayerAlive(LocalPlayer, roles)) then return end
            if p ~= LocalPlayer and HasTool(p, "Knife") and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and IsPlayerAlive(p, roles) then
              FlingWithCollision(p)
              task.wait(0.5)
            end
          end
        end)
      until not Options.ZombieShoot:GetValue()
    end
  end)

  -- مود الزومبي: أول ما تمتلي الشنطة يسوي ريسيت للشخصية (مرة وحدة، بعدها تصير ميت فما يعيد)
  shared.Main:Toggle("ZombieResetFullBag", "Zombie Mode: Reset When Bag Is Full", function(arg1)
    if arg1 then
      repeat task.wait(0.3)
        pcall(function()
          local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
          if hum and hum.Health > 0 and IsZombieRound() and IsBagFull() and IsPlayerAlive(LocalPlayer, roles) then
            hum.Health = 0
            task.wait(3) -- ننتظر حالة اللاعب تتحدث قبل الفحص الجاي
          end
        end)
      until not Options.ZombieResetFullBag:GetValue()
    end
  end)

  -- زومبي: ينتقل لكل ناجي (اللي ما معه سكين) ويطعنه عشان يتحول زومبي، واحد ورا الثاني
  shared.Main:Toggle("ZombieKillAll", "Zombie: Kill Survivors When Bag Is Full", function(arg1)
    if arg1 then
      repeat task.wait(0.2)
        pcall(function()
          if not (HasTool(LocalPlayer, "Knife") and IsBagFull() and IsPlayerAlive(LocalPlayer, roles)) then return end
          local hit = StabPlayersWhere(function(p) return not HasTool(p, "Knife") end)
          if hit > 0 then task.wait(0.5) end
        end)
      until not Options.ZombieKillAll:GetValue()
    end
  end)

  shared.Main:Divider()
  shared.Main:SubLabel({Text = "ROUND ASSISTS"})

  shared.Main:Toggle("AutoGrab", "Auto Grab Dropped Gun", function(arg1)
    if arg1 then
      repeat task.wait(0.1)
        pcall(function()
          if v14 and IsPlayerAlive(LocalPlayer, roles) and v14 ~= LocalPlayer.Name then
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local gunDrop = GetGunDrop()
            if myRoot and gunDrop and (IsBagFull() or not Options.AutoFarm:GetValue()) then gunDrop.CFrame = myRoot.CFrame end
          end
        end)
      until not Options.AutoGrab:GetValue()
    end
  end)

  shared.Main:Toggle("DodgeKnife", "Knife Dodge", function(arg1)
    if arg1 then
      repeat task.wait(0.03)
        pcall(function()
          for _, child in ipairs(workspace:GetChildren()) do
            if child.Name == "ThrowingKnife" then
              local blade = child:FindFirstChild("BladePosition")
              local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
              if blade and root and (blade.Position - root.Position).Magnitude <= 15 then
                local pos = root.Position
                root.CFrame = CFrame.new(pos.X, pos.Y + 100, pos.Z) task.wait(0.2) root.CFrame = CFrame.new(pos)
              end
            end
          end
        end)
      until not Options.DodgeKnife:GetValue()
    end
  end)

  shared.Main:Toggle("EndRound", "Auto Finish Round", function(arg1)
    if arg1 then
      Window:Notify({Title = "HAVEN HUB", Description = "Flings Murderer when you are not in the round.", Duration = 5})
      repeat task.wait(0.2)
        local mPlayer = v14 and Players:FindFirstChild(v14)
        if mPlayer and not IsPlayerAlive(LocalPlayer, roles) and v14 ~= LocalPlayer.Name then res:fling(mPlayer) task.wait(3) end
      until not Options.EndRound:GetValue()
    end
  end)

  shared.Main:Divider()
  shared.Main:SubLabel({Text = "QUICK TELEPORTS"})
  shared.Main:Button({Name = "Teleport To Lobby", Callback = function()
    for _, child in pairs(workspace:GetChildren()) do
      if (child:IsA("Model") or child:IsA("Folder")) and string.find(string.lower(child.Name), "lobby") then
        for _, desc in pairs(child:GetDescendants()) do
          if desc:IsA("SpawnLocation") then TweenTo(CFrame.new(desc.Position + Vector3.new(0, 5, 0)), 5000) return end
        end
      end
    end
  end})

  shared.Main:Button({Name = "Teleport To Map", Callback = function()
    local spawns = GetMapElement("Spawns")
    if spawns then
      for _, desc in ipairs(spawns:GetDescendants()) do
        if desc:IsA("BasePart") then TweenTo(desc.CFrame * CFrame.new(0, 5, 0), 5000) return end
      end
    else Window:Notify({Title = "HAVEN HUB", Description = "Map does not exist yet.", Duration = 5}) end
  end})

  -- فحص نظام التصويت على المابات: يجمع معلومات اللوبي وينسخها (قراءة فقط، ما يغيّر شي في اللعبة)
  local function ScanMapVote()
    local lines, total = {}, 0
    local function add(text) total = total + 1 if #lines < 500 then lines[#lines + 1] = text end end
    local function matches(name)
      local lower = string.lower(tostring(name))
      return string.find(lower, "vote", 1, true) ~= nil or string.find(lower, "map", 1, true) ~= nil
    end
    local function describe(inst)
      local extra = ""
      pcall(function()
        if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then extra = extra .. ' Text="' .. string.sub(inst.Text, 1, 70) .. '"' end
        if inst:IsA("ValueBase") then extra = extra .. " Value=" .. tostring(inst.Value) end
        if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then extra = extra .. " Image=" .. tostring(inst.Image) end
        if inst:IsA("Decal") or inst:IsA("Texture") then extra = extra .. " Texture=" .. tostring(inst.Texture) end
        if inst:IsA("BasePart") then
          extra = extra .. string.format(" Pos=(%d,%d,%d)", inst.Position.X, inst.Position.Y, inst.Position.Z)
          if inst:FindFirstChildOfClass("TouchTransmitter") then extra = extra .. " [TOUCH]" end
        end
        if inst:IsA("ClickDetector") or inst:IsA("ProximityPrompt") then extra = extra .. " [INTERACT]" end
        local attrs = inst:GetAttributes()
        for key, value in pairs(attrs) do extra = extra .. " @" .. tostring(key) .. "=" .. tostring(value) end
      end)
      return inst.ClassName .. " | " .. inst:GetFullName() .. extra
    end
    local function dump(root, maxItems)
      add(describe(root))
      local count = 0
      for _, desc in ipairs(root:GetDescendants()) do
        count = count + 1
        if count > maxItems then add("   ... (" .. (#root:GetDescendants() - maxItems) .. " more)") break end
        add("   " .. describe(desc))
      end
    end

    add("== HAVEN HUB MAP VOTE SCAN ==")
    add("-- LOBBY OBJECTS (name has vote/map) --")
    pcall(function()
      for _, child in ipairs(workspace:GetChildren()) do
        if string.find(string.lower(child.Name), "lobby", 1, true) then
          add("Lobby root: " .. child.ClassName .. " | " .. child:GetFullName())
          local seen = {}
          for _, desc in ipairs(child:GetDescendants()) do
            if matches(desc.Name) and not seen[desc] then
              local nested = false
              local parent = desc.Parent
              while parent and parent ~= child do if seen[parent] then nested = true break end parent = parent.Parent end
              if not nested then seen[desc] = true dump(desc, 80) end
            end
          end
          add("-- LOBBY SIGN TEXTS --")
          local texts = 0
          for _, desc in ipairs(child:GetDescendants()) do
            if texts >= 80 then break end
            if desc:IsA("TextLabel") and desc.Text ~= "" and (desc:FindFirstAncestorWhichIsA("SurfaceGui") or desc:FindFirstAncestorWhichIsA("BillboardGui")) then
              texts = texts + 1
              add(describe(desc))
            end
          end
        end
      end
    end)
    add("-- WORKSPACE TOP LEVEL --")
    pcall(function() for _, child in ipairs(workspace:GetChildren()) do add(child.ClassName .. " | " .. child.Name) end end)
    add("-- REMOTES (name has vote/map) --")
    pcall(function()
      for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
        if (desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") or desc:IsA("BindableEvent") or desc:IsA("BindableFunction")) and matches(desc.Name) then add(describe(desc)) end
      end
    end)
    add("-- GAMEPLAY REMOTES --")
    pcall(function()
      local gameplay = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Gameplay")
      if gameplay then for _, child in ipairs(gameplay:GetChildren()) do add(child.ClassName .. " | " .. child.Name) end end
    end)
    add("-- PLAYER GUI (name has vote/map) --")
    pcall(function()
      local seen = {}
      for _, desc in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if matches(desc.Name) and not seen[desc.Parent] then seen[desc] = true dump(desc, 40) end
      end
    end)
    add("== END (" .. total .. " lines) ==")

    local report = table.concat(lines, "\n")
    local copied, saved = false, false
    pcall(function() if setclipboard then setclipboard(report) copied = true elseif toclipboard then toclipboard(report) copied = true end end)
    pcall(function() if writefile then writefile("HavenHub/mapvote_scan.txt", report) saved = true end end)
    return total, copied, saved
  end

  -- ==========================================================================
  -- لوحة التصويت على المابات (Map Vote Panel)
  -- تطلع فوق الشاشة أول ما يبدأ التصويت، فيها المابات المعروضة وعدد أصواتها.
  -- تضغط على ماب: يوقف على منصته ويصوّت، ثم يسوي ريسيت ويعيد، لين يكمل العدد المطلوب.
  -- ==========================================================================
  local MapVote = {Running = false, StopRequested = false, Count = 10, Boards = {}, Status = "Waiting", ActiveName = nil, Done = 0, Total = 0, DismissedKey = nil}

  local function GetLobbyRoot()
    for _, child in ipairs(workspace:GetChildren()) do
      if (child:IsA("Model") or child:IsA("Folder")) and string.find(string.lower(child.Name), "lobby", 1, true) then return child end
    end
    return nil
  end

  local function ParseVotes(text)
    return tonumber(string.match(tostring(text or ""), "(%d+)")) or 0
  end

  -- نص مثل "Votes: 3"
  local function IsVotesText(text)
    return string.match(string.lower(tostring(text or "")), "^%s*votes?%s*:?%s*%d+%s*$") ~= nil
  end

  local function GetHolderPosition(holder)
    if not holder then return nil end
    if holder:IsA("BasePart") then return holder.Position end
    if holder:IsA("Model") then
      local ok, position = pcall(function() return holder:GetPivot().Position end)
      if ok then return position end
    end
    return nil
  end

  -- صور المابات: نجمع كل الصور الموجودة حول اللوحات (Decal / Texture / ImageLabel) ثم نعطي كل لوحة أقرب صورة لها.
  -- الصور المتكررة (خشب، إطارات...) تتأخر في الترتيب لأن صورة الماب تكون فريدة.
  local function AssignBoardImages(root, boards)
    if #boards == 0 then return end
    local candidates, uses = {}, {}
    local function addCandidate(image, part, info)
      if type(image) ~= "string" or image == "" or not part or not part:IsA("BasePart") then return end
      info = info or {}
      info.image = image
      info.position = part.Position
      info.size = math.max(part.Size.X, part.Size.Y, part.Size.Z)
      uses[image] = (uses[image] or 0) + 1
      table.insert(candidates, info)
    end
    pcall(function()
      for _, desc in ipairs(root:GetDescendants()) do
        if desc:IsA("Decal") or desc:IsA("Texture") then
          addCandidate(desc.Texture, desc.Parent)
        elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") then
          local gui = desc:FindFirstAncestorWhichIsA("SurfaceGui") or desc:FindFirstAncestorWhichIsA("BillboardGui")
          local holder = gui and (gui.Adornee or gui.Parent)
          if holder then
            local info = {}
            pcall(function() info.rectOffset = desc.ImageRectOffset info.rectSize = desc.ImageRectSize end)
            addCandidate(desc.Image, holder, info)
          end
        end
      end
    end)
    for _, board in ipairs(boards) do
      local best, bestScore = nil, math.huge
      for _, candidate in ipairs(candidates) do
        local dist = (candidate.position - board.position).Magnitude
        if dist <= 16 and candidate.size >= 2 then
          local mine = true
          for _, other in ipairs(boards) do
            if other ~= board and (candidate.position - other.position).Magnitude < dist then mine = false end
          end
          if mine then
            local score = dist + ((uses[candidate.image] > 1) and 100 or 0)
            if score < bestScore then bestScore = score best = candidate end
          end
        end
      end
      if best and bestScore < 100 then
        board.image = best.image
        board.imageRectOffset = best.rectOffset
        board.imageRectSize = best.rectSize
      end
    end
  end

  -- يدوّر على لوحات التصويت: أي لوحة فيها نص "Votes: N" ومعه اسم الماب
  local function DetectVoteBoards(root)
    local boards, seen = {}, {}
    local function consider(label, mustBeInWorld)
      if not (label:IsA("TextLabel") and IsVotesText(label.Text)) then return end
      local gui = label:FindFirstAncestorWhichIsA("SurfaceGui") or label:FindFirstAncestorWhichIsA("BillboardGui")
      if not gui or gui.Enabled == false then return end
      local holder = gui.Adornee or gui.Parent
      if mustBeInWorld and not (holder and holder:IsDescendantOf(workspace)) then return end
      local position = GetHolderPosition(holder)
      if not position then return end
      local name = nil
      for _, other in ipairs(gui:GetDescendants()) do
        if other ~= label and other:IsA("TextLabel") and not IsVotesText(other.Text) and string.match(other.Text, "%a") then
          name = name or other.Text
        end
      end
      if not name then return end
      name = string.gsub(string.gsub(name, "^%s+", ""), "%s+$", "")
      if name == "" or seen[name] then return end
      seen[name] = true
      table.insert(boards, {name = name, votesLabel = label, gui = gui, holder = holder, position = position})
    end
    pcall(function() for _, desc in ipairs(root:GetDescendants()) do consider(desc, false) end end)
    pcall(function() for _, desc in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do consider(desc, true) end end)
    table.sort(boards, function(a, b) return a.name < b.name end)
    pcall(AssignBoardImages, root, boards)
    return boards
  end

  -- التصويت لسا شغال لهذي اللوحة؟ (اللوحة موجودة وظاهرة ومكانها ما تغيّر)
  local function IsBoardAlive(board)
    local ok, alive = pcall(function()
      local label = board.votesLabel
      if label.Parent == nil or not IsVotesText(label.Text) then return false end
      if not (label:IsDescendantOf(workspace) or label:IsDescendantOf(LocalPlayer.PlayerGui)) then return false end
      if label.Visible == false or board.gui.Enabled == false then return false end
      local holder = board.gui.Adornee or board.gui.Parent
      if not holder or not holder:IsDescendantOf(workspace) then return false end
      local position = GetHolderPosition(holder)
      if position and (position - board.position).Magnitude > 6 then return false end
      return true
    end)
    return ok and alive
  end

  local function FlatDistance(a, b)
    return (Vector3.new(a.X, 0, a.Z) - Vector3.new(b.X, 0, b.Z)).Magnitude
  end

  -- اتجاه وجه اللوحة (الجهة اللي عليها الكتابة) على الأرض
  local function GetBoardFront(board)
    local normal = nil
    pcall(function()
      if board.gui:IsA("SurfaceGui") and board.holder:IsA("BasePart") then
        local world = board.holder.CFrame:VectorToWorldSpace(Vector3.FromNormalId(board.gui.Face))
        local flat = Vector3.new(world.X, 0, world.Z)
        if flat.Magnitude > 0.1 then normal = flat.Unit end
      end
    end)
    return normal
  end

  -- النقطة اللي قدام لوحة الماب مباشرة (مكان الوقوف للتصويت)
  local function GetStandPoint(board)
    local normal = GetBoardFront(board)
    if normal then return board.position + normal * 4, normal end
    return board.position, nil
  end

  -- مكان التصويت: المنصة اللي قدام اللوحة مباشرة. نتجاهل المناطق الكبيرة والأشياء اللي ورا اللوحة أو تبع لوحة ثانية
  local function FindVoteSpot(root, board)
    local point, normal = GetStandPoint(board)
    local best, bestDist = nil, math.huge
    for _, desc in ipairs(root:GetDescendants()) do
      local kind, part = nil, nil
      if desc:IsA("BasePart") and desc:FindFirstChildOfClass("TouchTransmitter") then kind, part = "touch", desc
      elseif desc:IsA("ClickDetector") and desc.Parent and desc.Parent:IsA("BasePart") then kind, part = "click", desc.Parent
      elseif desc:IsA("ProximityPrompt") and desc.Parent and desc.Parent:IsA("BasePart") then kind, part = "prompt", desc.Parent end
      if kind and not part:IsA("SpawnLocation") then
        local flat = FlatDistance(part.Position, point)
        local tooBig = math.max(part.Size.X, part.Size.Z) > 30
        local below = part.Position.Y <= board.position.Y + 1
        local inFront = (not normal) or ((part.Position - board.position):Dot(normal) > -1.5)
        if not tooBig and below and inFront and flat <= 12 and flat < bestDist then
          local mine = true
          for _, other in ipairs(MapVote.Boards) do
            if other ~= board and FlatDistance(part.Position, (GetStandPoint(other))) < flat then mine = false end
          end
          if mine then bestDist = flat best = {kind = kind, part = part, object = desc} end
        end
      end
    end
    -- floor = سطح الأرض في مكان التصويت (الشخصية توقف عليه بالضبط)
    local floor
    if best then
      floor = best.part.Position + Vector3.new(0, best.part.Size.Y / 2, 0)
    else
      -- ما لقينا منصة: الأرض اللي قدام اللوحة مباشرة
      floor = Vector3.new(point.X, point.Y - 3, point.Z)
      pcall(function()
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {LocalPlayer.Character}
        local hit = workspace:Raycast(point + Vector3.new(0, 4, 0), Vector3.new(0, -40, 0), params)
        if hit then floor = hit.Position end
      end)
    end
    return {floor = floor, trigger = best}
  end

  local function WaitForRoot(timeout)
    local started = os.clock()
    repeat
      local char = LocalPlayer.Character
      local hum = char and char:FindFirstChildOfClass("Humanoid")
      local root = char and char:FindFirstChild("HumanoidRootPart")
      if root and hum and hum.Health > 0 then return root end
      task.wait()
    until os.clock() - started > timeout
    return nil
  end

  -- يطلب من السيرفر يبدأ عدّاد الريسباون من الحين والشخصية لسا حية، فالتصويت وانتظار الريسباون يصيرون بنفس الوقت
  -- shortcut: يحتاج replicatesignal (مو كل الإكسكيوترات تدعمه) وما انجرّب باللعبة؛ بدونه يرجع للريسيت العادي
  local function StartEarlyRespawn()
    if not replicatesignal then return false end
    return (pcall(function() replicatesignal(LocalPlayer.ConnectDiedSignalBackend) end))
  end

  -- alreadyRespawning: الريسباون مطلوب من قبل (StartEarlyRespawn) فننتظره بدون قتل، ولو ما جاء نقتل الشخصية كالعادة
  local function ResetCharacterAndWait(oldChar, alreadyRespawning)
    oldChar = oldChar or LocalPlayer.Character
    local function waitNew(timeout)
      local started = os.clock()
      repeat
        local char = LocalPlayer.Character
        if char and char ~= oldChar and char:FindFirstChild("HumanoidRootPart") then return true end
        task.wait()
      until os.clock() - started > timeout
      return false
    end
    if alreadyRespawning and waitNew(Players.RespawnTime + 1.5) then return end
    local hum = oldChar and oldChar:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
    waitNew(12)
  end

  -- ارتفاع وسط الشخصية عن الأرض وهي واقفة (يختلف بين R6 و R15)
  local function GetStandHeight(root)
    local height = 3
    pcall(function()
      local hum = root.Parent:FindFirstChildOfClass("Humanoid")
      if hum and hum.RigType == Enum.HumanoidRigType.R15 then height = hum.HipHeight + root.Size.Y / 2 end
    end)
    return height
  end

  local function TouchVotePad(trigger, root)
    if not (trigger and trigger.kind == "touch" and firetouchinterest) then return end
    local parts = {root}
    for _, name in ipairs({"LeftFoot", "RightFoot", "Left Leg", "Right Leg"}) do
      local limb = root.Parent and root.Parent:FindFirstChild(name)
      if limb then table.insert(parts, limb) end
    end
    for _, limb in ipairs(parts) do firetouchinterest(trigger.part, limb, 0) end
    task.wait()
    for _, limb in ipairs(parts) do firetouchinterest(trigger.part, limb, 1) end
  end

  local function CastOneVote(spot, root)
    local trigger = spot.trigger
    if trigger and trigger.kind == "click" and fireclickdetector then
      fireclickdetector(trigger.object)
    elseif trigger and trigger.kind == "prompt" and fireproximityprompt then
      fireproximityprompt(trigger.object)
    end
    -- نوقف على أرض مكان التصويت بالضبط (بدون ما نرتفع عنها)
    Mark("map vote teleport")
    spot.stand = spot.floor + Vector3.new(0, GetStandHeight(root), 0)
    root.AssemblyLinearVelocity = Vector3.zero
    root.CFrame = CFrame.new(spot.stand)
    TouchVotePad(trigger, root)
  end

  -- يصوّت للماب عدد مرات: تصويت -> ريسيت -> تصويت ...
  local function RunVotes(board, total)
    if MapVote.Running then return end
    MapVote.Running = true
    MapVote.StopRequested = false
    MapVote.ActiveName = board.name
    MapVote.Done = 0
    MapVote.Total = total
    local reason = nil
    pcall(function()
      local searchRoot = GetLobbyRoot() or workspace
      local spot = nil      -- مكان التصويت ينحسب مرة وحدة وينعاد استخدامه (أسرع)
      local misses = 0      -- كم مرة ورا بعض ما انحسب الصوت
      local useEarly, earlyChar = true, nil -- الريسباون المبكر: يتعطل لو سبّب إن الصوت ما ينحسب
      while MapVote.Done < total do
        if MapVote.StopRequested or shared.VertexLoaded ~= true then reason = "Stopped" break end
        if not IsBoardAlive(board) then reason = "Vote ended" break end
        MapVote.Status = "Voting " .. (MapVote.Done + 1) .. "/" .. total
        local root = WaitForRoot(10)
        if not root then reason = "No character" break end
        local char = root.Parent
        if useEarly and earlyChar ~= char and MapVote.Done + 1 < total and StartEarlyRespawn() then earlyChar = char end
        if not spot or (spot.trigger and spot.trigger.part.Parent == nil) then spot = FindVoteSpot(searchRoot, board) end
        local before = ParseVotes(board.votesLabel.Text)
        CastOneVote(spot, root)
        -- ننتظر لين ينحسب الصوت (نبقى في مكان التصويت)
        local started, lastTouch, counted = os.clock(), os.clock(), false
        repeat
          task.wait()
          if ParseVotes(board.votesLabel.Text) > before then counted = true break end
          if not IsBoardAlive(board) then break end
          pcall(function()
            if not root.Parent then return end
            if FlatDistance(root.Position, spot.stand) > 3 or math.abs(root.Position.Y - spot.stand.Y) > 6 then
              root.AssemblyLinearVelocity = Vector3.zero
              root.CFrame = CFrame.new(spot.stand)
            end
            if os.clock() - lastTouch > 0.1 then lastTouch = os.clock() TouchVotePad(spot.trigger, root) end
          end)
        until os.clock() - started > 2 or MapVote.StopRequested -- السيرفر أحياناً يتأخر بتحديث العدد
        if counted then
          misses = 0
          MapVote.Done = MapVote.Done + 1
          if MapVote.Done < total and not MapVote.StopRequested then
            MapVote.Status = "Respawning " .. MapVote.Done .. "/" .. total .. string.format("  (server: %.1fs)", Players.RespawnTime)
            ResetCharacterAndWait(char, earlyChar == char)
          end
        else
          -- الصوت ما انحسب: ما نسوي ريسيت، نعيد المحاولة بنفس الشخصية. ثلاث مرات ورا بعض = التصويت خلص
          misses = misses + 1
          -- أول فشل: غالباً صوتك محسوب من قبل (كنت واقف على المنصة)، فالعدد ما يزيد إلا بعد ريسيت
          if earlyChar == char then useEarly = false end
          if misses == 1 and not MapVote.StopRequested then ResetCharacterAndWait(char) end
          if misses >= 3 then reason = (MapVote.Done > 0) and "Vote ended" or "No votes counted - press Scan Map Vote" break end
        end
      end
    end)
    if MapVote.StopRequested and not reason then reason = "Stopped" end
    if reason and string.find(reason, "No votes counted", 1, true) then
      MapVote.Status = reason
    else
      MapVote.Status = (reason and (reason .. "  +" .. MapVote.Done)) or ("Done  +" .. MapVote.Done)
    end
    MapVote.Running = false
  end

  shared.Main:Divider()
  shared.Main:SubLabel({Text = "MAP VOTE"})
  shared.Main:Toggle("MapVotePanel", "Show Map Vote Panel", {State = true}, function() end)
  shared.Main:Button({Name = "Scan Map Vote (Copy Info)", Callback = function()
    local total, copied, saved = ScanMapVote()
    local where = (copied and "Copied to clipboard. " or "") .. (saved and "Saved to HavenHub/mapvote_scan.txt." or "")
    if where == "" then where = "Your executor cannot copy or save files." end
    Window:Notify({Title = "MAP VOTE SCAN", Description = "Collected " .. tostring(total) .. " lines. " .. where, Duration = 7})
  end})

  local mapVoteGui
  pcall(function()
    local RED, WHITE, GREY = Color3.fromRGB(225, 29, 46), Color3.fromRGB(255, 255, 255), Color3.fromRGB(165, 165, 172)
    local PANEL_BG, CARD_BG, GREEN = Color3.fromRGB(13, 13, 15), Color3.fromRGB(22, 22, 25), Color3.fromRGB(52, 211, 153)
    local FONT_ID = "rbxassetid://12187365364"
    local function Make(className, props, parent)
      local inst = Instance.new(className)
      for k, v in pairs(props or {}) do inst[k] = v end
      inst.Parent = parent
      return inst
    end
    local function Text(props, parent, weight)
      props.BackgroundTransparency = 1
      props.FontFace = Font.new(FONT_ID, weight or Enum.FontWeight.Medium, Enum.FontStyle.Normal)
      props.TextColor3 = props.TextColor3 or WHITE
      return Make("TextLabel", props, parent)
    end
    local function Round(parent, radius) return Make("UICorner", {CornerRadius = radius or UDim.new(1, 0)}, parent) end

    mapVoteGui = Make("ScreenGui", {Name = "HavenMapVote", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 140, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    SafeParentGui(mapVoteGui)

    local panel = Make("Frame", {Name = "Panel", AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = PANEL_BG, BackgroundTransparency = 0.1, BorderSizePixel = 0, Position = UDim2.new(0.5, 0, 0, 62), Size = UDim2.fromOffset(400, 252), Visible = false}, mapVoteGui)
    Round(panel, UDim.new(0, 16))
    Make("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = RED, Thickness = 1, Transparency = 0.45}, panel)
    local panelScale = Make("UIScale", {Scale = 1}, panel)
    local function RefreshScale()
      pcall(function()
        local vp = workspace.CurrentCamera.ViewportSize
        panelScale.Scale = math.clamp(math.min((vp.X - 16) / panel.Size.X.Offset, (vp.Y - 70) / panel.Size.Y.Offset / 1.6), 0.45, 1)
      end)
    end
    RefreshScale()
    pcall(function() table.insert(HavenConnections, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(RefreshScale)) end)

    -- الرأس
    local header = Make("TextButton", {Name = "Header", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 52)}, panel)
    if HavenLoader.LogoAsset then
      Make("ImageLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 9), Size = UDim2.fromOffset(34, 34), Image = HavenLoader.LogoAsset, ScaleType = Enum.ScaleType.Fit}, header)
    else
      Round(Text({BackgroundTransparency = 0, BackgroundColor3 = RED, Position = UDim2.fromOffset(12, 9), Size = UDim2.fromOffset(34, 34), Text = "H", TextSize = 17}, header, Enum.FontWeight.Bold), UDim.new(0, 9)).Parent.BackgroundTransparency = 0
    end
    Text({Position = UDim2.fromOffset(56, 8), Size = UDim2.fromOffset(200, 18), Text = "Map Vote", TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left}, header, Enum.FontWeight.Bold)
    local statusDot = Make("Frame", {BackgroundColor3 = GREEN, BorderSizePixel = 0, Position = UDim2.fromOffset(57, 34), Size = UDim2.fromOffset(7, 7)}, header)
    Round(statusDot)
    local statusText = Text({Position = UDim2.fromOffset(70, 28), Size = UDim2.fromOffset(110, 18), Text = "Waiting", TextColor3 = GREY, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, header)

    local controls = Make("Frame", {AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Position = UDim2.new(1, -12, 0, 26), Size = UDim2.fromOffset(250, 30)}, header)
    Make("UIListLayout", {Padding = UDim.new(0, 8), FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center}, controls)
    local stopButton = Make("TextButton", {Name = "Stop", AutoButtonColor = false, BackgroundColor3 = RED, BorderSizePixel = 0, FontFace = Font.new(FONT_ID, Enum.FontWeight.Bold, Enum.FontStyle.Normal), LayoutOrder = 1, Size = UDim2.fromOffset(54, 26), Text = "Stop", TextColor3 = WHITE, TextSize = 11, Visible = false}, controls)
    Round(stopButton)
    local stepper = Make("Frame", {Name = "Stepper", BackgroundColor3 = CARD_BG, BorderSizePixel = 0, LayoutOrder = 2, Size = UDim2.fromOffset(104, 30)}, controls)
    Round(stepper)
    Make("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromRGB(52, 52, 58), Transparency = 0.4}, stepper)
    local function StepButton(symbol, x)
      return Make("TextButton", {Name = "Step" .. symbol, AutoButtonColor = false, BackgroundTransparency = 1, FontFace = Font.new(FONT_ID, Enum.FontWeight.Bold, Enum.FontStyle.Normal), Position = UDim2.fromOffset(x, 0), Size = UDim2.fromOffset(32, 30), Text = symbol, TextColor3 = GREY, TextSize = 16}, stepper)
    end
    local minusButton, plusButton = StepButton("-", 0), StepButton("+", 72)
    local countText = Text({Name = "Count", Position = UDim2.fromOffset(32, 0), Size = UDim2.fromOffset(40, 30), Text = tostring(MapVote.Count), TextSize = 13}, stepper, Enum.FontWeight.Bold)
    local hideButton = Make("TextButton", {Name = "Hide", AutoButtonColor = false, BackgroundColor3 = CARD_BG, BorderSizePixel = 0, FontFace = Font.new(FONT_ID, Enum.FontWeight.Bold, Enum.FontStyle.Normal), LayoutOrder = 3, Size = UDim2.fromOffset(30, 30), Text = "X", TextColor3 = GREY, TextSize = 11}, controls)
    Round(hideButton)
    Make("Frame", {BackgroundColor3 = RED, BackgroundTransparency = 0.8, BorderSizePixel = 0, Position = UDim2.fromOffset(12, 52), Size = UDim2.new(1, -24, 0, 1)}, panel)

    local cardsHolder = Make("Frame", {Name = "Cards", BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 60), Size = UDim2.new(1, -24, 1, -72)}, panel)
    Make("UIListLayout", {Padding = UDim.new(0, 6), FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder}, cardsHolder)

    local function SetCount(value)
      MapVote.Count = math.clamp(math.floor(value), 1, 50)
      countText.Text = tostring(MapVote.Count)
    end
    minusButton.MouseButton1Click:Connect(function() HavenLib.PlaySound("click") SetCount(MapVote.Count - 1) end)
    plusButton.MouseButton1Click:Connect(function() HavenLib.PlaySound("click") SetCount(MapVote.Count + 1) end)
    stopButton.MouseButton1Click:Connect(function() HavenLib.PlaySound("click") MapVote.StopRequested = true end)

    -- سحب اللوحة من الرأس
    local dragStart, dragPos = nil, nil
    header.InputBegan:Connect(function(inp)
      if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragStart = inp.Position dragPos = panel.Position end
    end)
    UserInputService.InputChanged:Connect(function(inp)
      if dragStart and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local delta = inp.Position - dragStart
        panel.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X, dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
      end
    end)
    UserInputService.InputEnded:Connect(function(inp)
      if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragStart = nil end
    end)

    -- بطاقات المابات
    local cards, cardsKey = {}, ""
    local function BuildCards(boards)
      for _, card in ipairs(cards) do pcall(function() card.frame:Destroy() end) end
      cards = {}
      -- قائمة عمودية: كل ماب صف (صورة صغيرة، الاسم، التقدم، عدد الأصوات)
      local count = math.max(#boards, 1)
      panel.Size = UDim2.fromOffset(400, 72 + count * 64 + (count - 1) * 6)
      RefreshScale()
      for index, board in ipairs(boards) do
        local frame = Make("Frame", {Name = "Card", BackgroundColor3 = CARD_BG, BorderSizePixel = 0, ClipsDescendants = true, LayoutOrder = index, Size = UDim2.new(1, 0, 0, 64)}, cardsHolder)
        Round(frame, UDim.new(0, 10))
        local stroke = Make("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = RED, Thickness = 2, Transparency = 1}, frame)
        local thumb = Make("Frame", {BackgroundColor3 = Color3.fromRGB(34, 34, 38), BorderSizePixel = 0, Position = UDim2.fromOffset(6, 6), Size = UDim2.fromOffset(96, 52)}, frame)
        Round(thumb, UDim.new(0, 7))
        if board.image then
          local picture = Make("ImageLabel", {Name = "MapImage", BackgroundTransparency = 1, BorderSizePixel = 0, Image = board.image, ScaleType = Enum.ScaleType.Crop, Size = UDim2.fromScale(1, 1)}, thumb)
          Round(picture, UDim.new(0, 7))
          pcall(function()
            if board.imageRectSize and (board.imageRectSize.X > 0 or board.imageRectSize.Y > 0) then
              picture.ImageRectOffset = board.imageRectOffset
              picture.ImageRectSize = board.imageRectSize
            end
          end)
        end
        local badge = Make("Frame", {AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.35, BorderSizePixel = 0, Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(48, 30)}, frame)
        Round(badge)
        local votes = Text({Size = UDim2.fromScale(1, 1), Text = "0", TextSize = 13}, badge, Enum.FontWeight.Bold)
        Text({Position = UDim2.fromOffset(112, 12), Size = UDim2.new(1, -178, 0, 18), Text = board.name, TextSize = 14, TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left}, frame, Enum.FontWeight.Bold)
        local progressText = Text({Position = UDim2.fromOffset(112, 33), Size = UDim2.new(1, -178, 0, 14), Text = "VOTE", TextColor3 = GREY, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left}, frame, Enum.FontWeight.SemiBold)
        local track = Make("Frame", {BackgroundColor3 = Color3.fromRGB(62, 62, 68), BackgroundTransparency = 0.4, BorderSizePixel = 0, Position = UDim2.new(0, 112, 1, -10), Size = UDim2.new(1, -178, 0, 4), Visible = false}, frame)
        Round(track)
        local fill = Make("Frame", {BackgroundColor3 = RED, BorderSizePixel = 0, Size = UDim2.fromScale(0, 1)}, track)
        Round(fill)
        local button = Make("TextButton", {Name = "VoteButton", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 2}, frame)
        button.MouseButton1Click:Connect(function()
          if MapVote.Running then return end
          HavenLib.PlaySound("click")
          task.spawn(RunVotes, board, MapVote.Count)
        end)
        cards[index] = {frame = frame, board = board, stroke = stroke, votes = votes, badge = badge, progressText = progressText, track = track, fill = fill}
      end
    end

    hideButton.MouseButton1Click:Connect(function() HavenLib.PlaySound("click") MapVote.DismissedKey = cardsKey end)

    -- التحديث: نعيد البحث عن اللوحات كل ثانيتين، ونحدّث الأرقام بينها
    task.spawn(function()
      local lastScan = -math.huge
      while shared.VertexLoaded == true and mapVoteGui.Parent do
        pcall(function()
          local stale = false
          for _, board in ipairs(MapVote.Boards) do if not IsBoardAlive(board) then stale = true end end
          if not MapVote.Running and (stale or os.clock() - lastScan > 2) then
            lastScan = os.clock()
            MapVote.Boards = DetectVoteBoards(GetLobbyRoot() or workspace)
            local names = {}
            for _, board in ipairs(MapVote.Boards) do table.insert(names, board.name .. "=" .. tostring(board.image or "")) end
            local key = table.concat(names, "|")
            if key ~= cardsKey then
              cardsKey = key
              if #MapVote.Boards > 0 then MapVote.Status = "Voting" MapVote.ActiveName = nil end
              BuildCards(MapVote.Boards)
            end
          end
          panel.Visible = havenReady and (#MapVote.Boards >= 2) and Options.MapVotePanel:GetValue() and MapVote.DismissedKey ~= cardsKey
          stopButton.Visible = MapVote.Running
          statusText.Text = MapVote.Status
          statusDot.BackgroundColor3 = MapVote.Running and RED or GREEN
          local top = 0
          for _, card in ipairs(cards) do top = math.max(top, ParseVotes(card.board.votesLabel.Text)) end
          for _, card in ipairs(cards) do
            local count = ParseVotes(card.board.votesLabel.Text)
            card.votes.Text = tostring(count)
            -- الماب المتصدر: شارة الأصوات تصير حمراء
            local leading = count > 0 and count == top
            card.badge.BackgroundColor3 = leading and RED or Color3.fromRGB(0, 0, 0)
            card.badge.BackgroundTransparency = leading and 0 or 0.35
            local active = (MapVote.ActiveName == card.board.name) and MapVote.Total > 0
            card.stroke.Transparency = active and 0 or 1
            card.track.Visible = active
            if active then
              card.progressText.Text = "+" .. MapVote.Done .. "/" .. MapVote.Total
              card.progressText.TextColor3 = RED
              card.fill.Size = UDim2.fromScale(math.clamp(MapVote.Done / MapVote.Total, 0, 1), 1)
            else
              card.progressText.Text = "TAP TO VOTE  x" .. MapVote.Count
              card.progressText.TextColor3 = GREY
            end
          end
        end)
        task.wait(0.15)
      end
      MapVote.StopRequested = true
      pcall(function() mapVoteGui:Destroy() end)
    end)
  end)

  -- قسم Target
  shared.Target:SubLabel({Text = "CHOSEN PLAYER"})
  local TargetDropdown = shared.Target:Dropdown({Name = "Choose Player", Search = true, Multi = false, Required = false, Options = {}, Default = {}, Callback = function() end}, "Target")
  local res12 = Players.PlayerAdded:Connect(function(p) TargetDropdown:InsertOptions({p.Name}) end)
  local res13 = Players.PlayerRemoving:Connect(function(p) TargetDropdown:RemoveOptions({p.Name}) end)
  for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then TargetDropdown:InsertOptions({p.Name}) end end

  shared.Target:Toggle("TargetFling", "Fling Player", function(arg1)
    if arg1 then
      repeat task.wait(0.1)
        local target = Options.Target:GetValue() and Players:FindFirstChild(Options.Target:GetValue())
        if target then res:fling(target) end
        task.wait(3)
      until not Options.TargetFling:GetValue()
    end
  end)

  shared.Target:Toggle("Spectate", "Spectate Player", function(arg1)
    if arg1 then
      repeat task.wait(0.05)
        local target = Options.Target:GetValue() and Players:FindFirstChild(Options.Target:GetValue())
        if target and target.Character and target.Character:FindFirstChild("Head") then workspace.CurrentCamera.CameraSubject = target.Character.Head end
      until not Options.Spectate:GetValue()
      if LocalPlayer.Character then workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid") end
    end
  end)

  shared.Target:Toggle("Annoy", "Stick To Player", function(arg1)
    if arg1 then
      repeat task.wait(0.03)
        pcall(function()
          local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
          local tChar = Options.Target:GetValue() and workspace:FindFirstChild(Options.Target:GetValue())
          if myRoot and tChar and tChar:FindFirstChild("HumanoidRootPart") then myRoot.CFrame = tChar.HumanoidRootPart.CFrame end
        end)
      until not Options.Annoy:GetValue()
    end
  end)

  shared.Target:Button({Name = "Teleport To Player", Callback = function()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tChar = Options.Target:GetValue() and workspace:FindFirstChild(Options.Target:GetValue())
    if myRoot and tChar and tChar:FindFirstChild("HumanoidRootPart") then myRoot.CFrame = tChar.HumanoidRootPart.CFrame end
  end})

  local function TeleportToRole(name, roleLabel)
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not name then Window:Notify({Title = "HAVEN HUB", Description = "No " .. roleLabel .. " right now.", Duration = 4}) return end
    if name == LocalPlayer.Name then Window:Notify({Title = "HAVEN HUB", Description = "You are the " .. roleLabel .. ".", Duration = 4}) return end
    local player = Players:FindFirstChild(name)
    local tRoot = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not (myRoot and tRoot) then Window:Notify({Title = "HAVEN HUB", Description = "Could not find the " .. roleLabel .. ".", Duration = 4}) return end
    myRoot.AssemblyLinearVelocity = Vector3.zero
    myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)
  end
  shared.Target:Button({Name = "Go To Murderer", Callback = function() pcall(TeleportToRole, v14, "murderer") end})
  shared.Target:Button({Name = "Go To Sheriff", Callback = function() pcall(TeleportToRole, v15, "sheriff") end})
  shared.Target:Divider()
  shared.Target:Toggle("FlingSheriff", "Fling The Sheriff", function(arg1)
    if arg1 then
      repeat task.wait(0.1)
        local sPlayer = v15 and Players:FindFirstChild(v15)
        if sPlayer and v15 ~= LocalPlayer.Name then res:fling(sPlayer) task.wait(3) end
      until not Options.FlingSheriff:GetValue()
    end
  end)

  shared.Target:Toggle("FlingMurderer", "Fling The Murderer", function(arg1)
    if arg1 then
      repeat task.wait(0.1)
        local mPlayer = v14 and Players:FindFirstChild(v14)
        if mPlayer and v14 ~= LocalPlayer.Name then res:fling(mPlayer) task.wait(3) end
      until not Options.FlingMurderer:GetValue()
    end
  end)

  -- قسم Visuals
  shared.Visual:SubLabel({Text = "ESP OPTIONS"})
  shared.Visual:Toggle("Chams", "Advanced ESP", function(arg1)
    if arg1 then
      local lastSkeleton = 0
      local render = RunService.RenderStepped:Connect(function()
        if os.clock() - lastSkeleton < 1 / 60 then return end
        lastSkeleton = os.clock()
        pcall(RenderSkeletons)
      end)
      repeat pcall(UpdateChams) task.wait(0.2) until not Options.Chams:GetValue()
      render:Disconnect()
      ClearESP()
    end
  end)

  -- قائمة إعدادات الـ ESP: مين يظهر، الأشكال، والألوان
  shared.Visual:SubLabel({Text = "ESP SETTINGS"})
  shared.Visual:Dropdown({Name = "Show ESP For", Multi = false, Required = true, Options = {"Everyone", "Murderer", "Sheriff", "Murderer + Sheriff", "Innocents", "Chosen Player"}, Default = 1, Callback = function() end}, "EspShow")
  local EspPlayerDropdown = shared.Visual:Dropdown({Name = "ESP Player", Search = true, Multi = false, Required = false, Options = {}, Default = {}, Callback = function() end}, "EspPlayer")
  for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then EspPlayerDropdown:InsertOptions({p.Name}) end end
  local espAdded = Players.PlayerAdded:Connect(function(p) EspPlayerDropdown:InsertOptions({p.Name}) end)
  local espRemoving = Players.PlayerRemoving:Connect(function(p) EspPlayerDropdown:RemoveOptions({p.Name}) end)
  shared.Visual:Toggle("EspSkeleton", "Skeleton", {State = true}, function() end)
  shared.Visual:Toggle("EspBox", "Box", {State = true}, function() end)
  shared.Visual:Toggle("EspTag", "Info Tag (Name / Role / Distance / HP)", {State = true}, function() end)
  shared.Visual:Dropdown({Name = "Box Style", Multi = false, Required = true, Options = {"Filled", "Outline Only"}, Default = 1, Callback = function() end}, "EspBoxStyle")
  shared.Visual:Slider("EspThickness", "Skeleton Thickness", 1, 5, 2, "Percent", function() end)
  shared.Visual:Dropdown({Name = "Skeleton Color", Multi = false, Required = true, Options = {"Black", "White", "Role Color", "Red", "Blue", "Green", "Yellow", "Orange", "Purple", "Pink", "Cyan"}, Default = 1, Callback = function() end}, "EspSkeletonColor")
  shared.Visual:Dropdown({Name = "Murderer Color", Multi = false, Required = true, Options = EspColorNames, Default = 1, Callback = function() end}, "EspMurdererColor")
  shared.Visual:Dropdown({Name = "Sheriff Color", Multi = false, Required = true, Options = EspColorNames, Default = 2, Callback = function() end}, "EspSheriffColor")
  shared.Visual:Dropdown({Name = "Innocent Color", Multi = false, Required = true, Options = EspColorNames, Default = 3, Callback = function() end}, "EspInnocentColor")

  shared.Visual:Toggle("GunDropCham", "Gun Drop ESP", function(arg1)
    while arg1 and Options.GunDropCham:GetValue() do
      task.wait(0.5)
      local gunDrop = GetGunDrop()
      if gunDrop and not gunDrop:FindFirstChild("GunESP") then
        local hl = Instance.new("Highlight", gunDrop)
        hl.Name = "GunESP" hl.FillTransparency = 0.5 hl.FillColor = Color3.fromRGB(128, 225, 0) hl.OutlineColor = Color3.fromRGB(0, 163, 0)
      end
    end
  end)

  -- ==========================================================================
  -- إخفاء نوافذ MM2 نفسها (العروض، الهدايا، التبادل، نتائج الجولة... إلخ)
  -- نخفي كل ScreenGui من اللعبة ما عدا MainGUI (فيه العملات والدور) وواجهات الهب،
  -- وداخل MainGUI نخفي الإطارات اللي اسمها يدل على نافذة منبثقة.
  -- ==========================================================================
  shared.Visual:Divider()
  shared.Visual:SubLabel({Text = "MM2 INTERFACE"})
  local hiddenMm2 = {}  -- [Instance] = القيمة الأصلية (Enabled أو Visible)
  -- واجهات ما تنخفى أبداً: MainGUI (العملات والدور) وتحكم الجوال (الجويستيك وزر القفز) وفقاعات الشات
  local KEEP_GUIS = {MainGUI = true, TouchGui = true, BubbleChat = true, Freecam = true}
  local hiddenMm2Conn
  local POPUP_WORDS = {"popup", "notif", "prompt", "alert", "offer", "gift", "trade", "shop", "reward", "announce", "event", "promo", "unbox", "code", "pass", "sale", "bundle", "daily", "spin", "crate", "battle", "quest", "season", "news", "update", "rate", "friend", "invite", "vote", "results"}
  local function LooksLikePopup(name)
    name = string.lower(name)
    for _, w in ipairs(POPUP_WORDS) do if string.find(name, w, 1, true) then return true end end
    return false
  end
  local function HideMm2Gui(obj)
    if hiddenMm2[obj] ~= nil then return end
    local name = obj.Name
    if string.sub(name, 1, 5) == "Haven" then return end -- واجهاتنا
    if obj:IsA("ScreenGui") and obj.Parent == LocalPlayer.PlayerGui then
      if KEEP_GUIS[name] then return end -- كان يخفي TouchGui فيختفي التحكم على الجوال
      hiddenMm2[obj] = obj.Enabled obj.Enabled = false
    elseif obj:IsA("GuiObject") and obj.Parent and obj.Parent.Name == "MainGUI" and LooksLikePopup(name) then
      hiddenMm2[obj] = obj.Visible obj.Visible = false
    end
  end
  shared.Visual:Toggle("HideMm2Popups", "Hide MM2 Popups", function(arg1)
    if arg1 then
      local pg = LocalPlayer.PlayerGui
      hiddenMm2Conn = pg.DescendantAdded:Connect(function(obj) task.defer(function() pcall(HideMm2Gui, obj) end) end)
      repeat
        pcall(function()
          for _, gui in ipairs(pg:GetChildren()) do HideMm2Gui(gui) end
          local main = pg:FindFirstChild("MainGUI")
          if main then for _, child in ipairs(main:GetChildren()) do HideMm2Gui(child) end end
          -- لو اللعبة رجّعت تظهر شي خفيناه، نخفيه مرة ثانية
          for obj in pairs(hiddenMm2) do
            if obj.Parent then
              if obj:IsA("ScreenGui") then obj.Enabled = false else obj.Visible = false end
            end
          end
        end)
        task.wait(0.5)
      until not Options.HideMm2Popups:GetValue()
      -- انطفى الزر: نرجّع كل شي مثل ما كان
      if hiddenMm2Conn then hiddenMm2Conn:Disconnect() hiddenMm2Conn = nil end
      for obj, original in pairs(hiddenMm2) do
        pcall(function()
          if obj:IsA("ScreenGui") then obj.Enabled = original else obj.Visible = original end
        end)
        hiddenMm2[obj] = nil
      end
    end
  end)

  -- شاشات نهاية الجولة (الفوز، النتائج، المكافآت، الليفل...): تنخفى تلقائياً بعد كل جولة.
  -- تعتمد على PlayerGui بس (متاح لكل الإكسكيوترات: بي سي، أندرويد، آيفون، محاكي)
  local END_WORDS = {"victory", "defeat", "gameover", "roundend", "endround", "roundover", "endscreen", "endgame", "matchend", "postgame", "result", "summary", "winner", "mvp", "levelup", "rewards"}
  local function IsEndScreenName(name)
    name = string.lower(string.gsub(name, "[%s_%-]", ""))
    for _, w in ipairs(END_WORDS) do if string.find(name, w, 1, true) then return true end end
    return false
  end
  shared.Visual:Toggle("HideEndScreens", "Hide End-Of-Round Screens", {State = true}, function(arg1)
    if not arg1 then return end
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local conns, tracked, windowHidden = {}, {}, {}
    local function hide(obj)
      if obj:IsA("ScreenGui") then if obj.Enabled then obj.Enabled = false end
      elseif obj.Visible then obj.Visible = false end
    end
    -- 1) بالاسم: أي واجهة اسمها يدل على نهاية الجولة، تنخفى لحظة ما تظهر
    local function track(obj)
      if tracked[obj] or KEEP_GUIS[obj.Name] or string.sub(obj.Name, 1, 5) == "Haven" then return end
      if not ((obj:IsA("GuiObject") or obj:IsA("ScreenGui")) and IsEndScreenName(obj.Name)) then return end
      tracked[obj] = true
      local prop = obj:IsA("ScreenGui") and "Enabled" or "Visible"
      table.insert(conns, obj:GetPropertyChangedSignal(prop):Connect(function() task.defer(function() pcall(hide, obj) end) end))
      pcall(hide, obj)
    end
    for _, d in ipairs(pg:GetDescendants()) do pcall(track, d) end
    table.insert(conns, pg.DescendantAdded:Connect(function(obj) task.defer(function() pcall(track, obj) end) end))
    -- 2) بالتوقيت: بعد إشارة نهاية الجولة من السيرفر، أي شاشة كاملة تنفتح خلال 12 ثانية تنخفى حتى لو اسمها ما يدل
    local windowUntil, baseline = 0, {}
    pcall(function()
      local gameplay = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Gameplay")
      for _, eventName in ipairs({"GameOver", "VictoryScreen", "RoundEndFade"}) do
        local ev = gameplay and gameplay:FindFirstChild(eventName)
        if ev and ev:IsA("RemoteEvent") then
          table.insert(conns, ev.OnClientEvent:Connect(function()
            windowUntil = os.clock() + 12
            baseline = {}
            for _, gui in ipairs(pg:GetChildren()) do if gui:IsA("ScreenGui") and gui.Enabled then baseline[gui] = true end end
          end))
        end
      end
    end)
    repeat
      pcall(function()
        for obj in pairs(tracked) do if obj.Parent == nil then tracked[obj] = nil else hide(obj) end end
        if os.clock() < windowUntil then
          for _, gui in ipairs(pg:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled and not baseline[gui] and not KEEP_GUIS[gui.Name] and string.sub(gui.Name, 1, 5) ~= "Haven" then
              gui.Enabled = false
              windowHidden[gui] = true
            end
          end
        end
      end)
      task.wait(0.2)
    until not Options.HideEndScreens:GetValue() or shared.VertexLoaded ~= true
    for _, conn in ipairs(conns) do pcall(function() conn:Disconnect() end) end
    -- الشاشات اللي خفيناها بالتوقيت نرجّعها (ممكن تكون شي تحتاجه)، واللي بالاسم تتركها اللعبة تظهرها بالجولة الجاية
    for gui in pairs(windowHidden) do pcall(function() gui.Enabled = true end) end
  end)

  shared.Visual:Toggle("Render", "Stop Rendering When Unfocused", function(arg1)
    if arg1 then
      UserInputService.WindowFocusReleased:Connect(function() if Options.Render:GetValue() then RunService:Set3dRenderingEnabled(false) end end)
      UserInputService.WindowFocused:Connect(function() RunService:Set3dRenderingEnabled(true) end)
    end
  end)

  shared.Visual:Toggle("Names", "Name ESP", function()
    while Options.Names:GetValue() do
      task.wait(0.5)
      for _, p in pairs(Players:GetPlayers()) do if p.Character then CreateNameESP(p) end end
    end
    ClearESP()
  end)

  shared.Visual:Divider()
  shared.Visual:Dropdown({Name = "Pick Emote", Multi = false, Required = true, Options = {"ninja", "dab", "floss", "headless", "zen", "zombie", "sit"}, Default = 1, Callback = function() end}, "Emote")
  shared.Visual:Toggle("AutoEmote", "Spam Emote", function()
    while Options.AutoEmote:GetValue() do task.wait(1.5) res:emote(Options.Emote:GetValue()) end
  end)

  -- قسم Combat & Roles
  shared.Roles:SubLabel({Text = "MURDERER MODE"})
  shared.Roles:Toggle("KillAura", "Kill Aura", function(arg1)
    if arg1 then
      repeat task.wait(0.15) -- كان كل فريم: طلبات أقل للسيرفر
        pcall(function()
          local hasKnife = LocalPlayer.Backpack:FindFirstChild("Knife") or LocalPlayer.Character:FindFirstChild("Knife")
          for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and hasKnife and IsPlayerAlive(p, roles) then
              local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
              if tRoot and (tRoot.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= Options.AuraDistance:GetValue() and v14 == LocalPlayer.Name then
                EquipTool("Knife") LocalPlayer.Character.Knife.Events.HandleTouched:FireServer(tRoot)
              end
            end
          end
        end)
      until not Options.KillAura:GetValue()
    end
  end)

  shared.Roles:Slider("AuraDistance", "Kill Aura Range", 5, 50, 5, "Percent", function() end)

  KillAll = function()
    Mark("stab everyone from far (Kill All)")
    pcall(function()
      EquipTool("Knife")
      for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and workspace:FindFirstChild(p.Name) and workspace[p.Name]:FindFirstChild("HumanoidRootPart") then
          LocalPlayer.Character.Knife.Events.HandleTouched:FireServer(workspace[p.Name].HumanoidRootPart)
        end
      end
    end)
  end

  shared.Roles:Toggle("KillAll", "Kill All Players", function(arg1)
    if arg1 then
      repeat task.wait(0.25) -- كان كل فريم: طلبات أقل للسيرفر
        if v14 and (IsBagFull() or not Options.AutoFarm:GetValue()) and v14 == LocalPlayer.Name then KillAll() end
      until not Options.KillAll:GetValue()
    end
  end)

  -- Knife Throw Auto Aim: لما ترمي السكين بنفسك، يوجّه الرمية لأقرب لاعب
  -- Team Check: الزميل = نفس فريق روبلوكس (Player.Team) أو نفس خاصية "Team" على اللاعب.
  -- shortcut: طريقة تخزين الفرق في الدولز مخمَّنة وما انجرّبت؛ لو اللعبة تخزنها بشكل ثاني عدّل GetTeamOf
  local function GetTeamOf(p)
    local team
    pcall(function() team = p.Team or p:GetAttribute("Team") or (p.Character and p.Character:GetAttribute("Team")) end)
    return team
  end
  -- فيه فرق فعلية؟ (أنا بفريق وفيه لاعب بفريق غيره). بالكلاسك لو الكل بنفس الفريق ما نعتبرهم زملاء
  local function TeamsActive()
    local mine = GetTeamOf(LocalPlayer)
    if mine == nil then return false end
    for _, other in ipairs(Players:GetPlayers()) do
      local theirs = GetTeamOf(other)
      if theirs ~= nil and theirs ~= mine then return true end
    end
    return false
  end
  local function IsTeammate(p)
    if p == LocalPlayer then return true end
    if not (Options.TeamCheck and Options.TeamCheck:GetValue()) then return false end
    return TeamsActive() and GetTeamOf(p) == GetTeamOf(LocalPlayer)
  end

  -- بنق مستخدم السكربت (رايح جاي) بالثواني، يتحدث كل نص ثانية
  local aimPing, aimPingAt = 0.06, -math.huge
  local function GetMyPing()
    if os.clock() - aimPingAt > 0.5 then
      aimPingAt = os.clock()
      local ok, ms = pcall(function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() end)
      if ok and type(ms) == "number" and ms > 0 then aimPing = ms / 1000
      else pcall(function() aimPing = LocalPlayer:GetNetworkPing() * 2 end) end
    end
    return aimPing
  end

  local knifeAimActive, knifeAimOldNamecall = false, nil
  local hitboxActive, hitboxCache, hitboxRadius = false, {}, 9 -- Hitbox Expander: أماكن الخصوم المكبَّرين (تنحسب برا الهوك)
  local knifeAimCached, knifeAimMyPos = nil, nil -- الهدف ومكاني، ينحسبون برا الهوك (الهوك ممنوع ينادي دوال اللعبة)
  local function GetKnifeAimPosition()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    -- الهدف حسب اختيار Knife Aim Target؛ لو ما فيه أحد من النوع المختار (مثلاً الشريف مات) يرجع لأقرب لاعب
    local choice = Options.KnifeAimTarget and Options.KnifeAimTarget:GetValue() or "Nearest Player"
    local bestPos, bestDist, anyPos, anyDist = nil, math.huge, nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
      local char = (p ~= LocalPlayer) and p.Character
      local tRoot = char and char:FindFirstChild("HumanoidRootPart")
      local hum = char and char:FindFirstChildOfClass("Humanoid")
      -- ميت فقط لو بيانات الجولة تقول كذا صريح؛ في الدولز وباقي المودات البيانات ممكن تكون ناقصة فنعتمد على الصحة
      local data = type(roles) == "table" and roles[p.Name]
      local dead = type(data) == "table" and (data.Killed or data.Dead) and not char:FindFirstChild("HumanoidCloned")
      if tRoot and hum and hum.Health > 0 and not dead and not IsTeammate(p) then
        local dist = (tRoot.Position - myRoot.Position).Magnitude
        -- الهدف هو الهيت بوكس (HumanoidRootPart)، ونسبقه بالبنق + 0.09 ثانية لوقت طيران السكين (عند بنق 30ms = القيمة القديمة 0.12)
        local pos = tRoot.Position + tRoot.AssemblyLinearVelocity * math.clamp(GetMyPing() + 0.09, 0.09, 0.5)
        if dist < anyDist then anyDist = dist anyPos = pos end
        -- النوع حسب السلاح اللي معه (يشتغل لما يكون فيه أكثر من مسدس/سكين مثل الدولز)
        local gun, knife = HasTool(p, "Gun"), HasTool(p, "Knife")
        local wanted = (choice == "Sheriff" and gun) or (choice == "Murderer" and knife)
          or (choice == "Innocent" and not gun and not knife)
        if wanted and dist < bestDist then bestDist = dist bestPos = pos end
      end
    end
    return bestPos or anyPos
  end
  -- يبدّل هدف الرمية داخل قيم الأمر المرسل للسيرفر مع الحفاظ على نوع كل قيمة.
  -- كل قيمة مكانية تتصنف: اتجاه (طولها 1) / نقطة انطلاق (قريبة مني) / هدف (الباقي، وآخر قيمة دايم هدف)
  -- لازم كل القيم تتعدل مع بعض: لو تغيّر الهدف وبقى اتجاه الانطلاق القديم السيرفر يرفض الرمية
  local function RedirectThrowArgs(args, targetPos, myPos)
    local spatial = {}
    for i = 1, args.n do
      local kind = typeof(args[i])
      if kind == "CFrame" or kind == "Vector3" then table.insert(spatial, i) end
    end
    if #spatial == 0 then return false end
    for order, i in ipairs(spatial) do
      local value = args[i]
      local isCF = typeof(value) == "CFrame"
      local pos = isCF and value.Position or value
      local isLast = (order == #spatial) and (#spatial > 1)
      if not isCF and pos.Magnitude <= 1.01 then
        local from = myPos or pos
        if (targetPos - from).Magnitude > 0.01 then args[i] = (targetPos - from).Unit end
      elseif not isLast and myPos and (pos - myPos).Magnitude <= 10 then
        if isCF and (targetPos - pos).Magnitude > 0.01 then args[i] = CFrame.lookAt(pos, targetPos) end
      else
        args[i] = isCF and CFrame.new(targetPos) or targetPos
      end
    end
    return true
  end
  -- لو آخر قيمة مكانية بالأمر (مكان الإصابة) داخل هيت بوكس مكبَّر، يرجّع مكان جسم صاحبه الحقيقي
  local function FindExpandedHit(args)
    local pos
    for i = args.n, 1, -1 do
      local kind = typeof(args[i])
      if kind == "CFrame" then pos = args[i].Position break
      elseif kind == "Vector3" and args[i].Magnitude > 1.01 then pos = args[i] break end
    end
    if not pos then return nil end
    for _, enemy in ipairs(hitboxCache) do
      if (pos - enemy.pos).Magnitude <= hitboxRadius then return enemy.aim end
    end
    return nil
  end
  local function InstallKnifeAimHook()
    if knifeAimOldNamecall then return true end
    if not (hookmetamethod and getnamecallmethod and checkcaller and newcclosure) then return false end
    local ok = pcall(function()
      knifeAimOldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = (hitboxActive or (knifeAimActive and knifeAimCached)) and not checkcaller() and getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
          local args = table.pack(...)
          local redirected = false
          -- ممنوع أي نداء بصيغة obj:Method() هنا: يخرّب اسم النداء الأصلي فالرمية ما تنرسل أبداً (هذا كان سبب إن السكين ما تنرمي)
          pcall(function()
            if typeof(self) ~= "Instance" then return end
            local class = self.ClassName
            if not (class == "RemoteEvent" or class == "RemoteFunction" or class == "UnreliableRemoteEvent") then return end
            local name = string.lower(self.Name)
            local isThrow = string.find(name, "throw", 1, true) ~= nil
            if not (isThrow or string.find(name, "shoot", 1, true)) then return end
            -- طلقة/رمية جت على هيت بوكس مكبَّر: السيرفر يحسب على الجسم الحقيقي، فنحوّلها لوسط جسمه عشان تقتله
            local target = hitboxActive and FindExpandedHit(args) or nil
            if not target and isThrow and knifeAimActive then target = knifeAimCached end
            if target then redirected = RedirectThrowArgs(args, target, knifeAimMyPos) end
          end)
          if redirected then
            if setnamecallmethod then setnamecallmethod(method) end
            return knifeAimOldNamecall(self, table.unpack(args, 1, args.n))
          end
        end
        return knifeAimOldNamecall(self, ...)
      end))
    end)
    return ok and knifeAimOldNamecall ~= nil
  end
  shared.Roles:Toggle("KnifeAim", "Knife Throw Auto Aim", function(arg1)
    if arg1 and not InstallKnifeAimHook() then
      knifeAimActive = false
      Window:Notify({Title = "HAVEN HUB", Description = "Your executor does not support this feature (needs hookmetamethod).", Duration = 6})
      task.defer(function() pcall(function() Options.KnifeAim:UpdateState(false) end) end)
      return
    end
    knifeAimActive = arg1 and true or false
    if arg1 then
      -- نحدّث الهدف كل فريم هنا، والهوك بس يقرأه
      repeat
        pcall(function()
          local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
          knifeAimMyPos = myRoot and myRoot.Position or nil
          knifeAimCached = GetKnifeAimPosition()
        end)
        task.wait()
      until not Options.KnifeAim:GetValue() or shared.VertexLoaded ~= true
      knifeAimActive = false
      knifeAimCached = nil
    end
  end)
  shared.Roles:Dropdown({Name = "Knife Aim Target", Multi = false, Required = true, Options = {"Nearest Player", "Sheriff", "Innocent", "Murderer"}, Default = 1, Callback = function() end}, "KnifeAimTarget")
  shared.Roles:Toggle("KnifeAimButton", "Show Knife Aim Button", {State = true}, function() end)
  local KnifeAimKeybind = shared.Roles:Keybind("KnifeAimKey", "Knife Aim Hotkey", function() HavenLib.PlaySound("toggle") Options.KnifeAim:Toggle() end)
  KnifeAimKeybind:Bind(Enum.KeyCode.Z) -- مفتاح افتراضي، تقدر تغيّره من الواجهة

  -- Hitbox Expander: يكبّر HumanoidRootPart حق الخصوم عندك (محلياً) فيسهل تصيبهم بالسكين والمسدس.
  -- الخصوم: وأنت القاتل = الكل، وأنت الشريف = القاتل بس (عشان ما تطلق على بريء بالغلط)، وبالدولز = الفريق الثاني
  local hitboxOriginal = {} -- [root] = {Size, Transparency, CanCollide}
  local function RestoreHitbox(root)
    local saved = hitboxOriginal[root]
    hitboxOriginal[root] = nil
    if saved then pcall(function() root.Size = saved[1] root.Transparency = saved[2] root.CanCollide = saved[3] end) end
  end
  shared.Roles:Toggle("HitboxExpander", "Hitbox Expander (Enemies)", function(arg1)
    if not arg1 then return end
    hitboxActive = InstallKnifeAimHook()
    if not hitboxActive then
      Window:Notify({Title = "HAVEN HUB", Description = "Hitboxes are enlarged, but shots cannot be snapped to the body on this executor (needs hookmetamethod).", Duration = 7})
    end
    repeat
      pcall(function()
        local size = math.clamp(tonumber(Options.HitboxSize and Options.HitboxSize:GetValue()) or 10, 4, 25)
        hitboxRadius = size * 0.9 -- نص قطر المكعب تقريباً
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        knifeAimMyPos = myRoot and myRoot.Position or nil
        local iHaveKnife, iHaveGun, teams = HasTool(LocalPlayer, "Knife"), HasTool(LocalPlayer, "Gun"), TeamsActive()
        local lead = math.clamp(GetMyPing() + 0.03, 0.03, 0.4)
        local cache, wanted = {}, {}
        for _, p in ipairs(Players:GetPlayers()) do
          local char = (p ~= LocalPlayer) and p.Character
          local root = char and char:FindFirstChild("HumanoidRootPart")
          local hum = char and char:FindFirstChildOfClass("Humanoid")
          if root and hum and hum.Health > 0 and not IsTeammate(p) and (teams or iHaveKnife or (iHaveGun and HasTool(p, "Knife"))) then
            wanted[root] = true
            if not hitboxOriginal[root] then hitboxOriginal[root] = {root.Size, root.Transparency, root.CanCollide} end
            if root.Size.X ~= size then root.Size = Vector3.new(size, size, size) end
            root.Transparency = 0.75
            root.CanCollide = false
            table.insert(cache, {pos = root.Position, aim = root.Position + root.AssemblyLinearVelocity * lead})
          end
        end
        for root in pairs(hitboxOriginal) do if not wanted[root] then RestoreHitbox(root) end end
        hitboxCache = cache
      end)
      task.wait()
    until not Options.HitboxExpander:GetValue() or shared.VertexLoaded ~= true
    hitboxActive = false
    hitboxCache = {}
    for root in pairs(hitboxOriginal) do RestoreHitbox(root) end
  end)
  shared.Roles:Slider("HitboxSize", "Hitbox Size", 4, 25, 10, "Percent", function() end)

  shared.Roles:Divider()
  shared.Roles:SubLabel({Text = "SHERIFF MODE"})
  shared.Roles:Toggle("SilentAim", "Silent Aim", function(arg1)
    if arg1 then
      local conn = nil
      repeat task.wait(0.2)
        local char = LocalPlayer.Character
        if char then
          local gun = char:FindFirstChild("Gun")
          if not gun and conn then conn:Disconnect() conn = nil
          elseif gun and v15 == LocalPlayer.Name and not conn then
            conn = gun.Activated:Connect(function()
              local mPlayer = v14 and Players:FindFirstChild(tostring(v14))
              local mRoot = mPlayer and mPlayer.Character and mPlayer.Character:FindFirstChild("HumanoidRootPart")
              if mRoot then
                local myRoot = char:FindFirstChild("HumanoidRootPart")
                local originCF = myRoot and (myRoot:FindFirstChild("RootAttachment") and myRoot.RootAttachment.WorldCFrame or myRoot.CFrame) or char:GetPrimaryPartCFrame()
                -- نصوّب على الهيت بوكس (HumanoidRootPart) ونسبقه بمقدار البنق، نفس حساب الايم لوك
                local lead = math.clamp(GetMyPing() + 0.03, 0.03, 0.4)
                local hitCF = CFrame.new(mRoot.Position + mRoot.AssemblyLinearVelocity * lead)
                if gun:FindFirstChild("Shoot") then gun.Shoot:FireServer(originCF, hitCF) end
              end
            end)
          end
        end
      until not Options.SilentAim:GetValue()
      if conn then conn:Disconnect() end
    end
  end)

  shared.Roles:Toggle("KillM", "Instant Kill Murderer", function(arg1)
    if arg1 then
      repeat task.wait(0.1)
        if IsBagFull() or not Options.AutoFarm:GetValue() then EquipTool("Gun") ShootMurderer() end
      until not Options.KillM:GetValue()
    end
  end)

  shared.Roles:Toggle("AutoShoot", "Auto Shoot On Sight", function(arg1)
    if arg1 then
      repeat task.wait(0.1)
        pcall(function()
          if v14 and v15 and v15 == LocalPlayer.Name then
            local mPlayer = Players:FindFirstChild(v14)
            if mPlayer and IsVisible(mPlayer) and not Options.KillM:GetValue() and (IsBagFull() or not Options.AutoFarm:GetValue()) then
              EquipTool("Gun") ShootMurderer()
            end
          end
        end)
      until not Options.AutoShoot:GetValue()
    end
  end)

  shared.Roles:Keybind("ShootBind", "Shoot Murderer Hotkey", function() pcall(function() EquipTool("Gun") ShootMurderer() end) end)
  -- Aim Lock: يثبّت الكاميرا على القاتل / الشريف
  shared.Roles:Divider()
  shared.Roles:SubLabel({Text = "AIM LOCK"})

  -- خيار Random: يختار جزء عشوائي من الجسم ويبدّله كل شوي
  local AimRandomParts = {"Head", "UpperTorso", "Torso", "HumanoidRootPart", "LowerTorso"}
  -- خيار Hitbox: أطراف عشوائية (كتف، يد، فخذ، ركبة، قدم). أسماء R15 و R6 مع بعض؛ الاسم اللي مو موجود بالشخصية يرجع لوسط الجسم
  local AimHitboxParts = {
    "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm", "LeftHand", "RightHand",
    "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot",
    "Left Arm", "Right Arm", "Left Leg", "Right Leg"
  }
  local aimRandomName, aimRandomUntil, aimRandomChoice = "Head", 0, nil
  local function GetAimPartName()
    local choice = Options.AimLockPart and Options.AimLockPart:GetValue() or "Hitbox"
    if choice == "Body" then return "HumanoidRootPart" end
    if choice == "Random" or choice == "Hitbox" then
      if os.clock() >= aimRandomUntil or aimRandomChoice ~= choice then
        local list = (choice == "Hitbox") and AimHitboxParts or AimRandomParts
        aimRandomChoice = choice
        aimRandomName = list[math.random(1, #list)]
        aimRandomUntil = os.clock() + 0.6 + math.random() * 0.9
      end
      return aimRandomName
    end
    return "Head"
  end

  -- هل الهدف ظاهر من الكاميرا (بدون جدار بينكم)؟
  local function IsAimPartVisible(part)
    local cam = workspace.CurrentCamera
    if not cam or not part then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    local origin = cam.CFrame.Position
    local hit = workspace:Raycast(origin, part.Position - origin, params)
    return (not hit) or hit.Instance:IsDescendantOf(part.Parent)
  end

  -- يرجّع الجزء المطلوب من لاعب لو كان هدف صالح (حي، مو أنا، وظاهر لو فحص الجدران مفعّل)
  local function GetValidAimPart(name, partName)
    local player = name and (name ~= LocalPlayer.Name) and Players:FindFirstChild(name)
    local char = player and player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local part = char and (char:FindFirstChild(partName) or char:FindFirstChild("HumanoidRootPart"))
    if not (part and hum and hum.Health > 0 and IsPlayerAlive(player, roles)) then return nil end
    if IsTeammate(player) then return nil end
    if Options.AimLockWallCheck and Options.AimLockWallCheck:GetValue() and not IsAimPartVisible(part) then return nil end
    return part
  end

  local aimTargetName = nil -- الهدف الحالي: نثبت عليه وما نبدّل بين اللاعبين كل فريم
  local function GetAimLockPart()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local mode = Options.AimLockTarget and Options.AimLockTarget:GetValue() or "Auto"
    local partName = GetAimPartName()
    local candidates = {}
    if mode == "Chosen Player" then
      local chosen = Options.AimLockPlayer and Options.AimLockPlayer:GetValue()
      if chosen then table.insert(candidates, chosen) end
    elseif mode == "Nearest Player" then
      for _, p in ipairs(Players:GetPlayers()) do table.insert(candidates, p.Name) end
    else
      if mode ~= "Sheriff" and v14 then table.insert(candidates, v14) end
      if mode ~= "Murderer" and v15 then table.insert(candidates, v15) end
    end
    -- لو الهدف الحالي لسا صالح ومن ضمن المرشحين (أو خصم بالدولز) نكمل عليه
    if aimTargetName and (table.find(candidates, aimTargetName) or (mode ~= "Chosen Player" and TeamsActive())) then
      local part = GetValidAimPart(aimTargetName, partName)
      if part then return part end
    end
    aimTargetName = nil
    local bestPart, bestDist = nil, math.huge
    for _, name in ipairs(candidates) do
      local part = GetValidAimPart(name, partName)
      if part then
        local dist = (part.Position - myRoot.Position).Magnitude
        if dist < bestDist then bestDist = dist bestPart = part aimTargetName = name end
      end
    end
    -- دولز (فيه فرق): لو وضع Auto/Murderer/Sheriff ما لقى هدف، يشبك على أقرب خصم
    if not bestPart and mode ~= "Chosen Player" and mode ~= "Nearest Player" and TeamsActive() then
      for _, p in ipairs(Players:GetPlayers()) do
        local part = GetValidAimPart(p.Name, partName)
        if part then
          local dist = (part.Position - myRoot.Position).Magnitude
          if dist < bestDist then bestDist = dist bestPart = part aimTargetName = p.Name end
        end
      end
    end
    return bestPart
  end

  local aimLockConn, aimLockBound = nil, false
  local aimLook = nil
  local function StopAimLock()
    aimLook = nil
    aimTargetName = nil
    if aimLockConn then aimLockConn:Disconnect() aimLockConn = nil end
    if aimLockBound then pcall(function() RunService:UnbindFromRenderStep("HavenAimLock") end) aimLockBound = false end
  end
  local function AimLockStep(dt)
    if shared.VertexLoaded ~= true or not Options.AimLock:GetValue() then StopAimLock() return end
    pcall(function()
      dt = math.clamp(dt or 0.016, 0, 0.1)
      local cam = workspace.CurrentCamera
      local part = GetAimLockPart()
      if not (cam and part) then aimLook = nil return end
      local camPos = cam.CFrame.Position
      -- نسبق حركة الهدف بمقدار البنق: اللي نشوفه متأخر عن مكانه بالسيرفر وقت وصول الطلقة ببنقنا الكامل + تنعيم الحركة (~0.03)
      -- بنق الهدف نفسه ما ينقرأ من الكلاينت، وتأثيره يلغي نفسه (يتأخر عندنا وعند السيرفر بنفس القدر)
      local aimPos = part.Position
      pcall(function() aimPos = aimPos + part.AssemblyLinearVelocity * math.clamp(GetMyPing() + 0.03, 0.03, 0.4) end)
      local offset = aimPos - camPos
      if offset.Magnitude < 0.05 then return end
      local desired = offset.Unit
      aimLook = aimLook or cam.CFrame.LookVector
      -- السرعة: 1 = أسرع شي، 10 = أبطأ شي. الدوران ناعم وبنفس السرعة على أي عدد فريمات
      local smooth = Options.AimLockSmooth and Options.AimLockSmooth:GetValue() or 5
      -- كل ما علا البنق يشبك أسرع (100ms = مرة ونص، 200ms = الضعف) عشان يعوّض تأخير الشبكة
      local rate = (9 - smooth * 0.8) * (1 + math.clamp(GetMyPing(), 0, 0.4) * 5)
      local closeness = aimLook:Dot(desired)
      if closeness > 0.999 then
        -- شابك على الهدف (أقل من ~2.5 درجة): يلصق فيه مباشرة بدون تأخير التنعيم عشان ما يفلت وهو يتحرك
        aimLook = desired
      else
        if closeness > 0.995 then rate = rate * 3 end
        local nextLook = aimLook:Lerp(desired, 1 - math.exp(-rate * dt))
        aimLook = (nextLook.Magnitude > 0.001) and nextLook.Unit or desired
      end
      cam.CFrame = CFrame.lookAt(camPos, camPos + aimLook)
    end)
  end

  shared.Roles:Toggle("AimLock", "Aim Lock", function(arg1)
    StopAimLock()
    if arg1 then
      -- بعد تحديث كاميرا اللعبة مباشرة، ولو المشغل ما يدعمها نستخدم RenderStepped
      local ok = pcall(function() RunService:BindToRenderStep("HavenAimLock", Enum.RenderPriority.Camera.Value + 1, AimLockStep) end)
      if ok then aimLockBound = true else aimLockConn = RunService.RenderStepped:Connect(AimLockStep) end
    end
  end)
  shared.Roles:Dropdown({Name = "Aim Lock Target", Multi = false, Required = true, Options = {"Auto", "Murderer", "Sheriff", "Nearest Player", "Chosen Player"}, Default = 1, Callback = function() end}, "AimLockTarget")
  -- قائمة اللاعبين لخيار Chosen Player (تتحدث لما يدخل أو يطلع لاعب)
  local AimLockPlayerDropdown = shared.Roles:Dropdown({Name = "Aim Lock Player", Multi = false, Required = false, Options = {}, Default = {}, Callback = function() end}, "AimLockPlayer")
  for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then AimLockPlayerDropdown:InsertOptions({p.Name}) end end
  local aimLockAdded = Players.PlayerAdded:Connect(function(p) AimLockPlayerDropdown:InsertOptions({p.Name}) end)
  local aimLockRemoving = Players.PlayerRemoving:Connect(function(p) AimLockPlayerDropdown:RemoveOptions({p.Name}) end)
  shared.Roles:Dropdown({Name = "Aim Lock Part", Multi = false, Required = true, Options = {"Hitbox", "Head", "Body", "Random"}, Default = 1, Callback = function() end}, "AimLockPart")
  shared.Roles:Slider("AimLockSmooth", "Aim Lock Smoothness", 1, 10, 5, "Percent", function() end)
  shared.Roles:Toggle("AimLockWallCheck", "Aim Lock Wall Check", function() end)
  shared.Roles:Toggle("TeamCheck", "Team Check (Skip Teammates)", {State = true}, function() end)

  -- تفعيل اللوك بسرعة: زر عائم على الشاشة + مفتاح اختصار
  local AimLockKeybind = shared.Roles:Keybind("AimLockKey", "Aim Lock Hotkey", function() HavenLib.PlaySound("toggle") Options.AimLock:Toggle() end)
  AimLockKeybind:Bind(Enum.KeyCode.X) -- مفتاح افتراضي، تقدر تغيّره من الواجهة
  shared.Roles:Toggle("AimLockButton", "Show Aim Lock Button", {State = true}, function() end)

  -- زر عائم على الشاشة يشغّل/يطفّي خيار (toggleId)، ويظهر حسب خيار (showId)
  local function MakeFloatButton(guiName, label, offsetY, toggleId, showId)
    local aimLockGui
    pcall(function()
    aimLockGui = Instance.new("ScreenGui")
    aimLockGui.Name = guiName
    aimLockGui.ResetOnSpawn = false
    aimLockGui.IgnoreGuiInset = true
    aimLockGui.DisplayOrder = 150
    aimLockGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    SafeParentGui(aimLockGui)

    local RED, DARK, WHITE = Color3.fromRGB(225, 29, 46), Color3.fromRGB(14, 14, 16), Color3.fromRGB(255, 255, 255)
    local lockBtn = Instance.new("TextButton")
    lockBtn.Name = "LockButton"
    lockBtn.AnchorPoint = Vector2.new(1, 0.5)
    lockBtn.Position = UDim2.new(1, -20, 0.5, offsetY)
    lockBtn.Size = UDim2.fromOffset(62, 62)
    lockBtn.AutoButtonColor = false
    lockBtn.BackgroundColor3 = DARK
    lockBtn.BackgroundTransparency = 0.15
    lockBtn.BorderSizePixel = 0
    lockBtn.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    lockBtn.Text = label .. "\nOFF"
    lockBtn.TextColor3 = WHITE
    lockBtn.TextSize = 12
    lockBtn.Parent = aimLockGui
    local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(1, 0) corner.Parent = lockBtn
    local stroke = Instance.new("UIStroke") stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border stroke.Color = RED stroke.Thickness = 2 stroke.Transparency = 0.2 stroke.Parent = lockBtn

    -- سحب الزر لأي مكان، والضغطة بدون سحب تشغّل/تطفّي اللوك
    local start, startPos, moved = nil, nil, false
    lockBtn.InputBegan:Connect(function(inp)
      if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then start = inp.Position startPos = lockBtn.Position moved = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
      if start and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local delta = inp.Position - start
        if not moved and delta.Magnitude >= 8 then moved = true end
        if moved then lockBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end
      end
    end)
    UserInputService.InputEnded:Connect(function(inp)
      if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then start = nil end
    end)
    lockBtn.Activated:Connect(function()
      if moved then return end
      HavenLib.PlaySound("toggle")
      Options[toggleId]:Toggle()
    end)

    -- يطابق شكل الزر مع حالة اللوك، ويختفي لو طفّيت خيار إظهاره
    task.spawn(function()
      while shared.VertexLoaded == true and aimLockGui.Parent do
        local on = Options[toggleId]:GetValue()
        lockBtn.Visible = Options[showId]:GetValue()
        lockBtn.Text = label .. (on and "\nON" or "\nOFF")
        lockBtn.BackgroundColor3 = on and RED or DARK
        stroke.Color = on and WHITE or RED
        task.wait(0.15)
      end
      pcall(function() aimLockGui:Destroy() end)
    end)
  end)
    return aimLockGui
  end
  local aimLockGui = MakeFloatButton("HavenAimLockButton", "LOCK", 76, "AimLock", "AimLockButton")
  local knifeAimGui = MakeFloatButton("HavenKnifeAimButton", "KNIFE", 148, "KnifeAim", "KnifeAimButton")

  -- قسم Webhooks
  shared.Tracker:SubLabel({Text = "DISCORD WEBHOOK INTEGRATION"})
  local WebhookInput = shared.Tracker:Input({Name = "Webhook URL", Placeholder = "https://discord.com/api/webhooks/...", AcceptedCharacters = "All", Callback = function() end}, "Webhook")
  -- يرسل للديسكورد ويرجّع (نجح؟، سبب الفشل) بدل ما يبلع الأخطاء بصمت
  local function PostWebhook(payload)
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if not req then return false, "EXECUTOR HAS NO REQUEST FUNCTION" end
    local url = string.gsub(tostring(WebhookInput:GetInput() or ""), "%s", "")
    if not string.match(url, "^https?://") then return false, "ENTER A VALID WEBHOOK URL" end
    local ok, res = pcall(req, {Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(payload)})
    if not ok then return false, "REQUEST ERROR" end
    local code = type(res) == "table" and tonumber(res.StatusCode)
    if code and (code < 200 or code >= 300) then return false, "DISCORD REJECTED IT (" .. code .. ")" end
    return true
  end
  -- وقت بصيغة ISO كاملة: الصيغة القديمة بدون أصفار (2026-1-5) يرفضها ديسكورد فما توصل الرسالة
  local function WebhookTimestamp() return os.date("!%Y-%m-%dT%H:%M:%SZ") end

  shared.Tracker:Button({Name = "Send Test Webhook", Callback = function()
    local ok, err = PostWebhook({username = "Haven Hub | Status", embeds = {{
      title = "Webhook Connected",
      description = "Reports for **" .. LocalPlayer.Name .. "** will be delivered to this channel.",
      color = 3461273,
      timestamp = WebhookTimestamp(),
      footer = {text = "Haven Hub • Murder Mystery 2"}
    }}})
    Window:Notify({Title = "WEBHOOK TEST", Description = ok and "Sent. Check your Discord channel." or ("Failed: " .. tostring(err)), Duration = 6})
  end})
  shared.Tracker:Divider()
  shared.Tracker:Toggle("CoinTracker", "Coin Tracker", function() end)
  -- كانت تنخزن كرقم داخل Options وهذا يكسر حفظ/تحميل الإعدادات (كل عناصر Options لازم تكون أزرار)
  local webhookSeconds = 60
  shared.Tracker:Input({Name = "Minutes To Send Webhook", Placeholder = "minutes", AcceptedCharacters = "Numeric", Callback = function(arg1)
    local num = tonumber(arg1) if num then webhookSeconds = math.max(math.floor(num * 60), 30) end
  end}, "WebhookTime")
  local TrackerStatusLabel = shared.Tracker:SubLabel({Text = "COIN TRACKER IS TURNED OFF"})
  shared.Tracker:Divider()

  shared.Tracker:Toggle("BoxNotification", "Unbox Notification", function(arg1)
    if not arg1 then
      if unboxConnection then unboxConnection:Disconnect() unboxConnection = nil end
    else
      local shop = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Shop")
      local itemService = require(ReplicatedStorage:WaitForChild("ClientServices"):WaitForChild("ItemService"))
      local syncDB = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
      unboxConnection = shop.BoxController.Event:Connect(function(items)
        for _, value in ipairs(items) do
          local itemId, boxId = value.RewardedItemId, value.MysteryBoxId
          local info = itemService:GetDisplayInfo(itemId, "Weapons")
          local rarity = (syncDB.Weapons[itemId] and syncDB.Weapons[itemId].Rarity) or "Unknown"
          local isChroma = info.Chroma and true or false
          pcall(PostWebhook, {
            username = "Haven Hub | Unbox Alert",
            content = isChroma and "@everyone" or "",
            embeds = {{
              title = isChroma and "Chroma Unboxed!" or "New Item Unboxed",
              description = "**" .. LocalPlayer.Name .. "** opened a mystery box.",
              color = isChroma and 16766720 or 14753070,
              fields = {
                {name = "Item", value = tostring(info.Name), inline = true},
                {name = "Rarity", value = tostring(rarity), inline = true},
                {name = "Box", value = tostring(boxId), inline = true}
              },
              timestamp = WebhookTimestamp(),
              footer = {text = "Haven Hub • Murder Mystery 2"}
            }}
          })
        end
      end)
    end
  end)

  -- قسم LocalPlayer
  shared.Player:SubLabel({Text = "CHARACTER MODIFIERS"})
  shared.Player:Toggle("WalkSpeed", "Walk Speed", function(arg1)
    if arg1 then
      repeat task.wait(0.5) SetStats(Options.WalkSpeedSlider:GetValue(), nil) until not Options.WalkSpeed:GetValue()
      SetStats(16, nil)
    end
  end)
  shared.Player:Slider("WalkSpeedSlider", "Walk Speed", 16, 100, 16, "Percent", function() end)

  shared.Player:Toggle("Jump", "Jump Power", function(arg1)
    if arg1 then
      repeat task.wait(0.5) SetStats(nil, Options.JumpPower:GetValue()) until not Options.Jump:GetValue()
      SetStats(nil, 50)
    end
  end)
  shared.Player:Slider("JumpPower", "Jump Power", 50, 100, 50, "Percent", function() end)
  shared.Player:Divider()

  local isInvis = false
  shared.Player:Keybind("Invis", "Invisible [FE]", function(arg1)
    if arg1 then
      isInvis = not isInvis
      if not isInvis then
        local chair = workspace:FindFirstChild("invischair")
        if chair then Window:Notify({Title = "HAVEN HUB", Description = "Invisibility disabled", Duration = 4}) chair:Destroy() end
      else
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local savedCF = root.CFrame
        task.wait() LocalPlayer.Character:MoveTo(Vector3.new(-25, -59536, 100)) task.wait(0.35)
        local seat = Instance.new("Seat", workspace)
        seat.Anchored = false seat.CanCollide = false seat.Name = "invischair" seat.Transparency = 1 seat.Position = Vector3.new(-25.95, 84, 3537.55)
        local weld = Instance.new("Weld", seat)
        weld.Part0 = seat weld.Part1 = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        task.wait() seat.CFrame = savedCF
        Window:Notify({Title = "HAVEN HUB", Description = "Invisibility enabled", Duration = 4})
      end
    end
  end)

  table.insert(HavenConnections, LocalPlayer.CharacterAdded:Connect(function()
    isInvis = false
    local chair = workspace:FindFirstChild("invischair")
    if chair then chair:Destroy() end
  end))

  shared.Player:Toggle("AntiFling", "Anti Fling", function(arg1)
    if arg1 then
      -- كان يمر على قطع كل اللاعبين كل فريم (أثقل شي بالسكربت على شاشة سريعة)
      local lastAntifling = 0
      antifling = RunService.Stepped:Connect(function()
        if os.clock() - lastAntifling < 0.2 then return end
        lastAntifling = os.clock()
        for _, p in pairs(Players:GetPlayers()) do
          if p ~= LocalPlayer and p.Character then
            for _, d in pairs(p.Character:GetDescendants()) do
              if d:IsA("BasePart") and d.CanCollide and not Options.TargetFling:GetValue() then d.CanCollide = false end
            end
          end
        end
      end)
    end
    repeat task.wait(0.2) until not Options.AntiFling:GetValue()
    if antifling then antifling:Disconnect() end
  end)

  -- حماية التبادل (Anti-Stealer)
  HavenLoader:SetProgress(90)
  local trade = ReplicatedStorage:WaitForChild("Trade")
  local declineRemote = trade:FindFirstChild("DeclineTrade")
  local dialogOpen = false
  local tradeConn
  -- زر تشغيل/إطفاء الحماية (شغالة افتراضياً). وهي مطفية تقدر تسوي تبادل عادي
  shared.Player:Toggle("AntiStealer", "Anti-Stealer (Block Trades)", {State = true}, function() end)
  if declineRemote and declineRemote:IsA("RemoteEvent") then
    declineRemote:FireServer()
    tradeConn = trade:WaitForChild("UpdateTrade").OnClientEvent:Connect(function()
      if not Options.AntiStealer:GetValue() then return end
      if declineRemote.Parent then declineRemote:FireServer() end
      if not dialogOpen then
        dialogOpen = true
        Window:Dialog({
          Title = "HAVEN HUB SECURITY",
          Description = "We detected an unauthorized trade in the background and blocked it automatically.",
          Buttons = {
            {Name = "Keep Protection Enabled", Callback = function() dialogOpen = false end},
            {Name = "Disable Protection", Callback = function() pcall(function() Options.AntiStealer:UpdateState(false) end) dialogOpen = false end}
          }
        })
      end
    end)
  end

  -- تتبع العملات والـ Webhook
  local coinCollected = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Gameplay"):FindFirstChild("CoinCollected")
  local tbl5, tbl6 = {}, {}
  local res36 = coinCollected.OnClientEvent:Connect(function(arg1, arg2)
    tbl5[arg1] = tbl5[arg1] or 0
    tbl6[arg1] = tbl6[arg1] or 0
    local diff = arg2 - tbl6[arg1]
    if diff > 0 then tbl5[arg1] = tbl5[arg1] + diff end
    tbl6[arg1] = arg2
  end)

  -- رسالة وحدة فيها كل أنواع العملات. ترجّع nil لو ما فيه شي ينرسل
  local function SendCoinWebhook(counts)
    local sec = webhookSeconds
    local fields, total = {}, 0
    for coinType, gained in pairs(counts) do
      if gained > 0 then
        total = total + gained
        table.insert(fields, {name = tostring(coinType), value = "**+" .. gained .. "**", inline = true})
      end
    end
    if total == 0 then return nil end
    local mins = sec / 60
    local mFmt = (mins % 1 == 0) and mins or tonumber(string.format("%.1f", mins))
    table.insert(fields, {name = "Period", value = tostring(mFmt) .. (mFmt == 1 and " minute" or " minutes"), inline = true})
    table.insert(fields, {name = "Rate", value = tostring(math.floor(total / sec * 3600)) .. " / hour", inline = true})
    return PostWebhook({
      username = "Haven Hub | Farm Report",
      embeds = {{
        title = "Coin Farm Report",
        description = "**" .. LocalPlayer.Name .. "** collected **" .. total .. "** coins.",
        color = 14753070,
        thumbnail = {url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=150&height=150&format=png"},
        fields = fields,
        timestamp = WebhookTimestamp(),
        footer = {text = "Haven Hub • Murder Mystery 2"}
      }}
    })
  end

  task.spawn(function()
    while task.wait(0.5) do
      if shared.VertexLoaded ~= true then break end
      if not Options.CoinTracker:GetValue() then
        TrackerStatusLabel:UpdateName("COIN TRACKER IS TURNED OFF")
        table.clear(tbl5) table.clear(tbl6)
      else
        local cd = webhookSeconds
        while cd > 0 and Options.CoinTracker:GetValue() do
          TrackerStatusLabel:UpdateName("WEBHOOK SENDING IN " .. cd .. " SECONDS")
          task.wait(1) cd = cd - 1
        end
        if Options.CoinTracker:GetValue() then
          TrackerStatusLabel:UpdateName("SENDING WEBHOOK...")
          local sent, failure = 0, nil
          local ok, okSend, err = pcall(SendCoinWebhook, tbl5)
          if not ok then failure = tostring(okSend)
          elseif okSend == false then failure = tostring(err)
          elseif okSend then sent = 1 end
          if failure then
            -- فشل: نخلي العملات محسوبة عشان تنرسل بالمحاولة الجاية
            TrackerStatusLabel:UpdateName("WEBHOOK FAILED: " .. failure)
          else
            TrackerStatusLabel:UpdateName(sent > 0 and "WEBHOOK SENT SUCCESSFULLY" or "NO COINS COLLECTED - NOTHING SENT")
            table.clear(tbl5)
          end
          task.wait(3) -- عشان تلحق تقرأ النتيجة قبل العدّاد الجاي
        end
      end
    end
  end)

  task.spawn(function()
    local lastRolesRequest = -math.huge
    while task.wait(0.1) do
      if shared.VertexLoaded ~= true then break end
      pcall(function()
        v14 = FindPlayerWithTool("Knife")
        v15 = FindPlayerWithTool("Gun")
        -- بين الجولات (ما أحد معه سكين أو مسدس) نصفّر حالة الشنطة
        if not v14 and not v15 then ResetBagState() end
        -- طلب بيانات اللاعبين من السيرفر مرتين بالثانية بدل عشر مرات (الطلبات الكثيرة ممكن تسبب طرد)
        if os.clock() - lastRolesRequest >= 0.5 then
          lastRolesRequest = os.clock()
          roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
        end
      end)
    end
    if unboxConnection then unboxConnection:Disconnect() end
    if res36 then res36:Disconnect() end
    if tradeConn then tradeConn:Disconnect() end
    if res12 then res12:Disconnect() end
    if res13 then res13:Disconnect() end
    if aimLockAdded then aimLockAdded:Disconnect() end
    if espAdded then espAdded:Disconnect() end
    if espRemoving then espRemoving:Disconnect() end
    if aimLockRemoving then aimLockRemoving:Disconnect() end
    shared.speed = nil
    -- تنظيف كامل بعد الإغلاق: ما يبقى أي أثر في اللعبة
    pcall(function() local gunDrop = GetGunDrop() if gunDrop and gunDrop:FindFirstChild("GunESP") then gunDrop.GunESP:Destroy() end end)
    pcall(function() local chair = workspace:FindFirstChild("invischair") if chair then chair:Destroy() end end)
    pcall(DisableFloat)
    pcall(ClearESP)
    pcall(function() RunService:Set3dRenderingEnabled(true) end)
    pcall(function()
      local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
      if hum then workspace.CurrentCamera.CameraSubject = hum end
    end)
    pcall(function() if aimLockGui then aimLockGui:Destroy() end end)
    pcall(function() if knifeAimGui then knifeAimGui:Destroy() end end)
    pcall(function() if mapVoteGui then mapVoteGui:Destroy() end end)
    pcall(function() if knifeAimOldNamecall and hookmetamethod then hookmetamethod(game, "__namecall", knifeAimOldNamecall) end end)
    for _, key in ipairs({"tabs", "Main", "Roles", "Target", "Visual", "Player", "Tracker", "Premium", "loaded", "done"}) do shared[key] = nil end
  end)

  shared.tabs.Main:Select(shared.Main)
  shared.tabs.Settings:InsertConfigSection("Left", Window)

  -- ============================================================================
  -- نظام الريجوين وتبديل السيرفرات
  -- يشتغل على كل الأجهزة (كمبيوتر، جوال، آيباد، محاكي) وكل المنفذات:
  -- كل دالة خاصة بالمنفذ تنختار من بين كل الأسماء المعروفة، وأي فشل ما يوقف الباقي
  -- ============================================================================
  local HavenRejoin = {}
  do
    local TeleportService = Services.TeleportService
    local PlaceId, MyJobId = game.PlaceId, game.JobId

    -- دالة من البيئة العامة بأمان (بعض المنفذات تحمي __index)
    local function Global(name)
      local ok, value = pcall(function() return getgenv()[name] end)
      if ok and value ~= nil then return value end
      ok, value = pcall(function() return _G[name] end)
      if ok then return value end
    end
    local function MemberOf(holder, key)
      local t = Global(holder)
      if type(t) == "table" then
        local ok, fn = pcall(function() return t[key] end)
        if ok and type(fn) == "function" then return fn end
      end
    end

    -- إعادة التشغيل بعد الانتقال: كل منفذ يسمي الدالة باسم مختلف
    local QueueFn = Global("queue_on_teleport") or Global("queueonteleport")
      or MemberOf("syn", "queue_on_teleport") or MemberOf("fluxus", "queue_on_teleport")
    if type(QueueFn) ~= "function" then QueueFn = nil end

    -- طلب HTTP لقائمة السيرفرات: request أو ما يعادلها، وإلا HttpGet
    local RawRequest = Global("request") or Global("http_request")
      or MemberOf("syn", "request") or MemberOf("http", "request") or MemberOf("fluxus", "request")
    if type(RawRequest) ~= "function" then RawRequest = nil end

    local function HttpGet(url)
      if RawRequest then
        local ok, res = pcall(RawRequest, {Url = url, Method = "GET"})
        if ok and type(res) == "table" and type(res.Body) == "string"
          and (res.StatusCode == nil or res.StatusCode == 200) then return res.Body end
      end
      local ok, body = pcall(function() return game:HttpGet(url) end)
      if ok and type(body) == "string" and #body > 0 then return body end
      return nil
    end

    -- سطر تشغيل السكربت: المستخدم يحطه مرة واحدة في خانة الإعدادات (ينحفظ مع بقية الإعدادات)
    local function GetLoader()
      local opt = Options.RejoinLoader
      local src = opt and opt.GetInput and opt:GetInput() or (opt and opt.Text) or ""
      src = tostring(src):gsub("^%s+", ""):gsub("%s+$", "")
      if #src < 8 then return nil end
      if src:match("^https?://") then return ('loadstring(game:HttpGet("' .. src .. '"))()') end
      return src
    end

    -- الحالة تنتقل جوّا نص الـ queue نفسه: لا ملف جديد ولا متغير يبقى بالذاكرة
    -- (ملف الإعدادات الأصلي يبقى خط ثاني للمنفذات اللي ما عندها queue)
    local function BuildQueue()
      local loader = GetLoader()
      if not loader then return nil end
      local ok, state = pcall(function() return HttpService:JSONEncode(HavenLib:ExportState()) end)
      if ok and type(state) == "string" and #state < 100000 then
        return "local e = (getgenv and getgenv() or _G) e.HavenHubRestore = " .. string.format("%q", state) .. "\n" .. loader
      end
      return loader
    end

    local function Prepare()
      pcall(function() HavenLib:SaveConfig(game.PlaceId) end)
      local payload = BuildQueue()
      if payload and QueueFn then pcall(QueueFn, payload) return true end
      return false
    end

    local function Tell(title, text)
      pcall(function() Window:Notify({Title = title, Description = text, Duration = 5}) end)
    end

    -- قائمة السيرفرات العامة مرتبة من الأقل أعضاء (التدرج: الأقل أول)
    local function GetServers()
      local list, seen, cursor, page = {}, {}, "", 0
      repeat
        local url = "https://games.roblox.com/v1/games/" .. tostring(PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor ~= "" then url = url .. "&cursor=" .. cursor end
        local body = HttpGet(url)
        if not body then break end
        local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
        if not ok or type(data) ~= "table" or type(data.data) ~= "table" then break end
        for _, s in ipairs(data.data) do
          local playing, maxPlayers = tonumber(s.playing), tonumber(s.maxPlayers) or 0
          if type(s.id) == "string" and s.id ~= MyJobId and not seen[s.id]
            and playing and playing > 0 and (maxPlayers == 0 or playing < maxPlayers) then
            seen[s.id] = true
            table.insert(list, {id = s.id, playing = playing})
          end
        end
        cursor = (type(data.nextPageCursor) == "string") and data.nextPageCursor or ""
        page = page + 1
      until cursor == "" or page >= 3 or #list >= 80
      table.sort(list, function(a, b) return a.playing < b.playing end)
      return list
    end

    local busy, failedJobs = false, {}

    -- انتقال واحد: يرجع true لو فشل الانتقال (عشان نجرب السيرفر اللي بعده)
    local function TryTeleport(jobId)
      local failed = false
      local conn = TeleportService.TeleportInitFailed:Connect(function() failed = true end)
      local ok = pcall(function()
        if jobId then TeleportService:TeleportToPlaceInstance(PlaceId, jobId, LocalPlayer)
        else TeleportService:Teleport(PlaceId, LocalPlayer) end
      end)
      if ok then
        local started = os.clock()
        repeat task.wait(0.25) until failed or (os.clock() - started) > 12
      end
      pcall(function() conn:Disconnect() end)
      return (not ok) or failed
    end

    -- ريجوين: نفس السيرفر إن قدرنا، وإلا أي سيرفر
    function HavenRejoin:Rejoin(reason)
      if busy then return end
      busy = true
      task.spawn(function()
        Mark("rejoin: " .. tostring(reason or "manual"), true)
        local queued = Prepare()
        Tell("REJOINING", queued and "Rejoining now. The script will come back by itself."
          or "Rejoining now. Add your script link in Settings so it comes back by itself.")
        task.wait(0.6)
        if TryTeleport(MyJobId) then TryTeleport(nil) end
        busy = false
      end)
    end

    -- انتقال متدرج: من السيرفرات الأقل أعضاء للأكثر، وإلا ريجوين عادي
    function HavenRejoin:Hop(reason)
      if busy then return end
      busy = true
      task.spawn(function()
        Mark("server hop: " .. tostring(reason or "manual"), true)
        local queued = Prepare()
        Tell("SERVER HOP", queued and (tostring(reason or "Moving to another server") .. ".")
          or "Hopping now. Add your script link in Settings so it comes back by itself.")
        local servers = GetServers()
        for _, s in ipairs(servers) do
          if not failedJobs[s.id] then
            failedJobs[s.id] = true
            if not TryTeleport(s.id) then busy = false return end
            task.wait(1)
          end
        end
        -- ما نفع ولا سيرفر (أو ما قدرنا نجيب القائمة): ريجوين عادي يحطنا بسيرفر فيه ناس
        if #servers == 0 then Tell("SERVER HOP", "Could not read the server list. Doing a normal rejoin.") end
        TryTeleport(nil)
        busy = false
      end)
    end

    -- ====== الخيارات في تبويب الإعدادات ======
    local rejoinSection = shared.tabs.Settings:Section({Side = "Left"})
    rejoinSection:SubLabel({Text = "REJOIN & SERVERS"})
    rejoinSection:Input({
      Name = "Script Link",
      Placeholder = "https://... raw script link",
      Callback = function() end
    }, "RejoinLoader")
    rejoinSection:Toggle("AutoRejoinKick", "Auto Rejoin When Kicked", {State = true})
    rejoinSection:Toggle("AutoHopEmpty", "Hop When Server Is Empty", {State = true})
    rejoinSection:Slider("HopPlayerLimit", "Hop When Players Are", 1, 6, 1)
    rejoinSection:Button({Name = "Rejoin Now", Callback = function() HavenRejoin:Rejoin("button") end})
    rejoinSection:Button({Name = "Hop To Another Server", Callback = function() HavenRejoin:Hop("Manual server hop") end})

    -- ====== السيرفر فضى: ننتقل بالتدرج لسيرفر أعضاؤه قليلة ======
    task.spawn(function()
      local emptySince = nil
      while task.wait(2) do
        if shared.VertexLoaded ~= true then break end
        local limit = math.floor(tonumber(Options.HopPlayerLimit and Options.HopPlayerLimit:GetValue()) or 1)
        local count = #Players:GetPlayers()
        if (Options.AutoHopEmpty and Options.AutoHopEmpty:GetValue()) and count <= limit then
          emptySince = emptySince or os.clock()
          if (os.clock() - emptySince) >= 10 then
            emptySince = nil
            HavenRejoin:Hop("Server has only " .. tostring(count) .. " player(s)")
          end
        else
          emptySince = nil
        end
      end
    end)

    -- ====== الطرد أو قطع الاتصال: نرجع فوراً والسكربت يرجع معنا ======
    -- مصدرين عشان يشتغل على كل الأجهزة: نافذة الخطأ في CoreGui، وانقطاع NetworkClient
    local kickHandled = false
    local function OnDisconnected(why)
      if kickHandled or busy then return end
      if not (Options.AutoRejoinKick and Options.AutoRejoinKick:GetValue()) then return end
      kickHandled = true
      HavenRejoin:Rejoin(why)
    end
    task.spawn(function()
      local overlay
      pcall(function()
        local prompt = Services.CoreGui:WaitForChild("RobloxPromptGui", 30)
        overlay = prompt and prompt:WaitForChild("promptOverlay", 30)
      end)
      if not overlay then return end
      local function Check(child)
        if child.Name == "ErrorPrompt" then task.delay(0.5, function() OnDisconnected("kicked") end) end
      end
      -- الاتصال ينحفظ مع الباقي عشان ينفصل لو المستخدم سكّر الهب
      pcall(function() table.insert(HavenConnections, overlay.ChildAdded:Connect(Check)) end)
      for _, child in ipairs(overlay:GetChildren()) do Check(child) end
    end)
    pcall(function()
      table.insert(HavenConnections, Services.NetworkClient.ChildRemoved:Connect(function()
        task.delay(0.5, function() OnDisconnected("disconnected") end)
      end))
    end)

    if not QueueFn then
      task.delay(8, function()
        Tell("REJOIN", "This executor has no queue_on_teleport, so the script cannot restart itself after a rejoin.")
      end)
    end
  end

  -- شاشة التحميل تخلص أول (Finish ينتظر لين تختفي)، بعدها نشغّل الأوامر المحفوظة ولوحة التصويت
  if HavenLoader.Active then
    HavenLoader:Finish()
    Window:SetState(true)
  end
  ShowPendingGuis()
  havenReady = true
  HavenLib:LoadConfig(game.PlaceId)
  -- حالة جات مع الريجوين: ترجّع كل الأوامر زي ما كانت، وتنمسح طول عشان ما تتكرر مرة ثانية
  pcall(function()
    local env = getgenv()
    local raw = env.HavenHubRestore
    env.HavenHubRestore = nil
    if type(raw) == "string" and #raw > 2 then
      local ok, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
      if ok then HavenLib:ImportState(decoded) end
    end
  end)

  Window:Notify({
    Title = "HAVEN HUB LOADED",
    Description = "Welcome to Haven Hub. Press LeftControl or the logo button to toggle the UI.",
    Duration = 6
  })

  -- حماية السقوط في الـ Void
  local fallenHeight = workspace.FallenPartsDestroyHeight
  while task.wait(0.1) do
    if shared.VertexLoaded ~= true then break end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root then
      val = nil
    else
      local y = root.Position.Y
      if y < fallenHeight or y > 5000 then
        val = val or os.clock()
        if (os.clock() - val) >= 5 and v91 then
          root.CFrame = v91 + Vector3.new(0, 4, 0)
          root.AssemblyLinearVelocity = Vector3.zero
          root.AssemblyAngularVelocity = Vector3.zero
        end
      else
        val = nil
        if hum and hum.FloorMaterial ~= Enum.Material.Air then
          local params = RaycastParams.new()
          params.FilterType = Enum.RaycastFilterType.Exclude
          params.FilterDescendantsInstances = {char}
          local hit = workspace:Raycast(root.Position, Vector3.new(0, -10, 0), params)
          if hit and hit.Instance:IsA("BasePart") then v91 = root.CFrame end
        end
      end
    end
  end
end)()