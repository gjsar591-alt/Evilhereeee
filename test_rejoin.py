# -*- coding: utf-8 -*-
# اختبار نظام الريجوين: نحاكي Roblox ونشغّل نفس كود الموديول الموجود في ssss.lua
import json, sys
from lupa import LuaRuntime

src = open('/home/user/Evilhereeee/ssss.lua', encoding='utf-8').read()
start = src.index('  local HavenRejoin = {}')
end = src.index('\n\n  -- شاشة التحميل تخلص أول', start)
block = src[start:end]
# نكشف الدوال الداخلية للاختبار فقط (ما نعدّل الملف الأصلي)
block = block.rstrip()
assert block.endswith('end')
block = block[:-3] + '''
    _G.HavenRejoin = HavenRejoin
    _G.__t = {GetLoader = GetLoader, BuildQueue = BuildQueue, GetServers = GetServers,
              TryTeleport = TryTeleport, OnDisconnected = OnDisconnected, Prepare = Prepare}
  end'''

HARNESS = r'''
-- ====== محاكاة Roblox ======
local calls = {teleports = {}, notify = {}, queued = {}, saved = 0, marks = {}}
_G.__calls = calls
_G.servers_json = nil
_G.http_fail = false

local function Signal()
  local s = {handlers = {}}
  function s:Connect(fn) table.insert(self.handlers, fn) return {Disconnect = function() end} end
  function s:Fire(...) for _, fn in ipairs(self.handlers) do fn(...) end end
  return s
end
_G.__Signal = Signal

local teleportInitFailed = Signal()
_G.__teleportInitFailed = teleportInitFailed
_G.__failNextTeleport = false

local TeleportService = {TeleportInitFailed = teleportInitFailed}
function TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
  table.insert(calls.teleports, {kind = "instance", place = placeId, job = jobId})
  if _G.__failNextTeleport then teleportInitFailed:Fire() end
end
function TeleportService:Teleport(placeId, player)
  table.insert(calls.teleports, {kind = "plain", place = placeId})
  if _G.__failNextTeleport then teleportInitFailed:Fire() end
end

local promptOverlay = {ChildAdded = Signal(), children = {}}
function promptOverlay:GetChildren() return self.children end
local RobloxPromptGui = {}
function RobloxPromptGui:WaitForChild(n) if n == "promptOverlay" then return promptOverlay end end
_G.__promptOverlay = promptOverlay

local CoreGui = {}
function CoreGui:WaitForChild(n) if n == "RobloxPromptGui" then return RobloxPromptGui end end
local NetworkClient = {ChildRemoved = Signal()}
_G.__networkChildRemoved = NetworkClient.ChildRemoved

HttpService = {}
function HttpService:JSONEncode(t) return _pyEncode(t) end
function HttpService:JSONDecode(s) return _pyDecode(s) end

Services = {TeleportService = TeleportService, CoreGui = CoreGui, NetworkClient = NetworkClient,
            HttpService = HttpService}

game = {PlaceId = 142823291, JobId = "MY-JOB-ID"}
function game:HttpGet(url)
  if _G.http_fail then error("http blocked") end
  table.insert(calls.http or {}, url)
  return _G.servers_json
end
calls.http = {}

LocalPlayer = {Name = "Tester"}
local playerCount = 1
Players = {}
function Players:GetPlayers() local t = {} for i = 1, playerCount do t[i] = {} end return t end
function _G.__setPlayers(n) playerCount = n end

shared = {VertexLoaded = true}
HavenConnections = {}

local genv = _G
function getgenv() return genv end

-- ساعة وهمية: كل task.wait يقدّمها، عشان حلقات الانتظار تنتهي فوراً
local realos = os
local vclock = 0
os = {clock = function() return vclock end, date = realos.date, time = realos.time}
function _G.__clock() return vclock end

-- task: spawn يخزّن الخيط عشان نشغّله يدوياً، wait يقدّم الساعة ويرجع فوراً
local threads = {}
_G.__threads = threads
task = {
  wait = function(t)
    vclock = vclock + (tonumber(t) or 0.03)
    local c = (_G.__waitCount or 0) + 1 _G.__waitCount = c
    if c > (_G.__maxWait or 400) then shared.VertexLoaded = nil error("WAIT-CAP", 0) end
    return t or 0
  end,
  spawn = function(fn, ...) table.insert(threads, {fn = fn, args = {...}}) end,
  delay = function(_, fn) table.insert(threads, {fn = fn, args = {}}) end,
}
function _G.__runThreads()
  local list = threads
  threads = {} _G.__threads = threads
  for _, t in ipairs(list) do
    _G.__waitCount = 0   -- سقف الانتظار لكل خيط لحاله (عشان نكسر حلقة المراقبة فقط)
    local ok, err = pcall(t.fn, table.unpack(t.args))
    if not ok and tostring(err) ~= "WAIT-CAP" then error(err, 0) end
  end
end

-- خيارات الواجهة (نفس سلوك المكتبة الأصلية)
Options = {}
local function mkToggle(flag, state)
  local o = {Class = "Toggle", State = state}
  function o:GetValue() return self.State end
  Options[flag] = o return o
end
local function mkSlider(flag, def)
  local o = {Class = "Slider", Value = def}
  function o:GetValue() return self.Value end
  Options[flag] = o return o
end
local function mkInput(flag)
  local o = {Class = "Input", Text = ""}
  function o:GetInput() return self.Text end
  Options[flag] = o return o
end

local section = {}
function section:SubLabel() return {} end
function section:Input(s, flag) return mkInput(flag) end
function section:Toggle(flag, name, cfg) return mkToggle(flag, cfg and cfg.State == true) end
function section:Slider(flag, name, mn, mx, def) return mkSlider(flag, def) end
function section:Button(s) calls.buttons = calls.buttons or {} calls.buttons[s.Name] = s.Callback return {} end
shared.tabs = {Settings = {Section = function() return section end}}

HavenLib = {}
function HavenLib:ExportState() return {objects = {{type = "Toggle", flag = "AutoFarm", state = true}}} end
function HavenLib:SaveConfig() calls.saved = calls.saved + 1 return true end

Window = {}
function Window:Notify(n) table.insert(calls.notify, n) end

function Mark(a) table.insert(calls.marks, a) end

-- المنفذ: queue_on_teleport موجود
function queue_on_teleport(payload) table.insert(calls.queued, payload) end
'''

def run(executor_has_queue=True):
    lua = LuaRuntime(unpack_returned_tuples=True)
    g = lua.globals()
    g._pyEncode = lambda t: json.dumps(lua_to_py(t))
    g._pyDecode = lambda s: lua.table_from(py_to_lua(json.loads(s), lua))
    lua.execute(HARNESS)
    if not executor_has_queue:
        lua.execute("queue_on_teleport = nil")
    lua.execute(block)
    return lua

def lua_to_py(v):
    if hasattr(v, 'items'):
        keys = list(v.keys())
        if keys and all(isinstance(k, int) for k in keys):
            return [lua_to_py(v[k]) for k in sorted(keys)]
        return {str(k): lua_to_py(v[k]) for k in keys}
    return v

def py_to_lua(v, lua):
    if isinstance(v, dict):
        return lua.table_from({k: py_to_lua(x, lua) for k, x in v.items()})
    if isinstance(v, list):
        return lua.table_from([py_to_lua(x, lua) for x in v])
    return v

fails = []
def check(name, cond, extra=""):
    print(("PASS  " if cond else "FAIL  ") + name + (("  -> " + str(extra)) if (extra and not cond) else ""))
    if not cond: fails.append(name)

SERVERS = json.dumps({"nextPageCursor": None, "data": [
    {"id": "full-server",  "playing": 12, "maxPlayers": 12},
    {"id": "MY-JOB-ID",    "playing": 1,  "maxPlayers": 12},
    {"id": "busy",         "playing": 9,  "maxPlayers": 12},
    {"id": "fewest",       "playing": 2,  "maxPlayers": 12},
    {"id": "middle",       "playing": 5,  "maxPlayers": 12},
    {"id": "ghost",        "playing": 0,  "maxPlayers": 12},
]})

# ---------- 1) الخيارات تنبني وتتسجّل ----------
lua = run()
O = lua.globals().Options
check("الخيارات الأربعة تنبني", all(O[k] is not None for k in ("RejoinLoader","AutoRejoinKick","AutoHopEmpty","HopPlayerLimit")))
check("ريجوين الطرد مفعّل افتراضياً", O.AutoRejoinKick.State is True)
check("الانتقال عند الفراغ مفعّل افتراضياً", O.AutoHopEmpty.State is True)
check("حد اللاعبين الافتراضي = 1", O.HopPlayerLimit.Value == 1)
check("الأزرار موجودة", lua.globals().__calls.buttons["Rejoin Now"] is not None
                        and lua.globals().__calls.buttons["Hop To Another Server"] is not None)

# ---------- 2) قائمة السيرفرات: ترتيب وفلترة ----------
lua = run()
lua.globals().servers_json = SERVERS
lst = lua.globals().__t.GetServers()
ids = [lst[i].id for i in sorted(lst.keys())]
check("يتجاهل سيرفري الحالي والممتلئ والفاضي", ids == ["fewest","middle","busy"], ids)
check("مرتّب من الأقل أعضاء", [lst[i].playing for i in sorted(lst.keys())] == [2,5,9])

# ---------- 3) HttpGet يفشل -> قائمة فاضية بدون خطأ ----------
lua = run()
lua.globals().http_fail = True
lst = lua.globals().__t.GetServers()
check("فشل الشبكة ما يرمي خطأ", len(dict(lst)) == 0)

# ---------- 4) سطر التشغيل ----------
lua = run()
t = lua.globals().__t
check("بدون رابط -> nil", t.GetLoader() is None)
lua.globals().Options.RejoinLoader.Text = "   https://x.dev/a.lua   "
check("رابط يتحوّل loadstring", t.GetLoader() == 'loadstring(game:HttpGet("https://x.dev/a.lua"))()', t.GetLoader())
lua.globals().Options.RejoinLoader.Text = 'loadstring(game:HttpGet("https://y/z"))()'
check("كود جاهز يُستخدم كما هو", t.GetLoader() == 'loadstring(game:HttpGet("https://y/z"))()')
lua.globals().Options.RejoinLoader.Text = "short"
check("نص قصير مرفوض", t.GetLoader() is None)

# ---------- 5) نص الـ queue: ينفّذ فعلاً ويرجّع الحالة سليمة ----------
lua = run()
lua.globals().Options.RejoinLoader.Text = "https://x.dev/a.lua"
payload = lua.globals().__t.BuildQueue()
check("نص الـ queue فيه الحالة والـ loader",
      "HavenHubRestore" in payload and "loadstring" in payload)
# نشغّل النص المتولّد في بيئة نظيفة ونتأكد إن JSON يرجع حرفياً
lua2 = LuaRuntime(unpack_returned_tuples=True)
expected = json.dumps(lua_to_py(lua.globals().HavenLib.ExportState(lua.globals().HavenLib)))
lua2.execute("function loadstring() return function() end end\nlocal g = _G function getgenv() return g end\ngame = {HttpGet = function() return '' end}")
ok = True
try:
    lua2.execute(payload)
except Exception as e:
    ok = False; err = e
check("نص الـ queue كود Lua صحيح وينفّذ", ok, locals().get('err'))
if ok:
    got = lua2.globals().HavenHubRestore
    check("الحالة تعبر الريجوين حرفياً بدون تلف", got == expected, (got, expected))

# ---------- 6) بدون رابط: ما نحط queue لكن الريجوين يشتغل ----------
lua = run()
g = lua.globals()
g.Options.RejoinLoader.Text = ""
g.HavenRejoin.Rejoin(g.HavenRejoin, "test")
g.__runThreads()
c = g.__calls
check("ريجوين بدون رابط ينتقل برضه", len(dict(c.teleports)) >= 1)
check("ما ينحط queue بدون رابط", len(dict(c.queued)) == 0)
check("ينبّه المستخدم يحط الرابط", "Settings" in c.notify[1].Description, c.notify[1].Description)
check("يحفظ الإعدادات قبل الانتقال", c.saved == 1)

# ---------- 7) ريجوين بالرابط: queue + نفس السيرفر ----------
lua = run()
g = lua.globals()
g.Options.RejoinLoader.Text = "https://x.dev/a.lua"
g.HavenRejoin.Rejoin(g.HavenRejoin, "kicked")
g.__runThreads()
c = g.__calls
check("ينحط queue قبل الانتقال", len(dict(c.queued)) == 1)
check("يرجع لنفس السيرفر أول", c.teleports[1].kind == "instance" and c.teleports[1].job == "MY-JOB-ID")
check("يسجّل الحركة", "rejoin: kicked" in c.marks[1])

# ---------- 8) فشل الانتقال لنفس السيرفر -> ريجوين عادي ----------
lua = run()
g = lua.globals()
g.__failNextTeleport = True
g.Options.RejoinLoader.Text = "https://x.dev/a.lua"
g.HavenRejoin.Rejoin(g.HavenRejoin, "x")
g.__runThreads()
tp = [g.__calls.teleports[i].kind for i in sorted(dict(g.__calls.teleports).keys())]
check("لو فشل نفس السيرفر يسوي ريجوين عادي", tp == ["instance","plain"], tp)

# ---------- 9) الانتقال المتدرج: الأقل أعضاء أول ----------
lua = run()
g = lua.globals()
g.servers_json = SERVERS
g.Options.RejoinLoader.Text = "https://x.dev/a.lua"
g.HavenRejoin.Hop(g.HavenRejoin, "manual")
g.__runThreads()
tp = g.__calls.teleports
check("ينتقل للسيرفر الأقل أعضاء", dict(tp).__len__() == 1 and tp[1].job == "fewest", [tp[i].job for i in sorted(dict(tp).keys())])

# ---------- 10) كل السيرفرات تفشل -> يجرب بالتدرج ثم ريجوين عادي ----------
lua = run()
g = lua.globals()
g.servers_json = SERVERS
g.__failNextTeleport = True
g.Options.RejoinLoader.Text = "https://x.dev/a.lua"
g.HavenRejoin.Hop(g.HavenRejoin, "manual")
g.__runThreads()
jobs = [ (g.__calls.teleports[i].job or "PLAIN") for i in sorted(dict(g.__calls.teleports).keys()) ]
check("يتدرّج من الأقل للأكثر ثم ريجوين عادي", jobs == ["fewest","middle","busy","PLAIN"], jobs)

# ---------- 11) السيرفر فضى: ينتقل بعد 10 ثواني فقط ----------
def watcher(players, waits, limit=None, enabled=True):
    lua = run(); g = lua.globals()
    g.servers_json = SERVERS
    g.Options.RejoinLoader.Text = "https://x.dev/a.lua"
    g.Options.AutoHopEmpty.State = enabled
    if limit is not None: g.Options.HopPlayerLimit.Value = limit
    g.__setPlayers(players)
    g.__maxWait = waits
    for _ in range(4): g.__runThreads()
    return [ (g.__calls.teleports[i].job or "PLAIN") for i in sorted(dict(g.__calls.teleports).keys()) ]

check("ما ينتقل قبل 10 ثواني من الفراغ", watcher(1, 3) == [], watcher(1, 3))
check("ينتقل بعد 10 ثواني فراغ للأقل أعضاء", watcher(1, 8)[:1] == ["fewest"], watcher(1, 8))
check("سيرفر فيه ناس -> ما ينتقل", watcher(6, 20) == [], watcher(6, 20))
check("حد اللاعبين يُحترم (3 لاعبين وحد 3)", watcher(3, 20, limit=3)[:1] == ["fewest"], watcher(3, 20, limit=3))
check("الزر مطفي -> ما ينتقل أبداً", watcher(1, 20, enabled=False) == [], watcher(1, 20, enabled=False))

# ---------- 12) الطرد: يرجع مرة واحدة فقط، ويحترم الزر ----------
def kickcase(prompt_name="ErrorPrompt", enabled=True, network=False):
    lua = run(); g = lua.globals()
    g.Options.RejoinLoader.Text = "https://x.dev/a.lua"
    g.Options.AutoHopEmpty.State = False       # نعزل الطرد عن مراقب الفراغ
    g.Options.AutoRejoinKick.State = enabled
    g.__runThreads()                           # يركّب مراقبات الطرد
    if network:
        g.__networkChildRemoved.Fire(g.__networkChildRemoved)
    else:
        g.__promptOverlay.ChildAdded.Fire(g.__promptOverlay.ChildAdded, lua.table_from({"Name": prompt_name}))
    for _ in range(3): g.__runThreads()
    return g, len(dict(g.__calls.teleports))

g, n = kickcase()
check("الطرد يسوي ريجوين", n >= 1, n)
g.__networkChildRemoved.Fire(g.__networkChildRemoved)
for _ in range(3): g.__runThreads()
check("ما يكرر الريجوين لو جاه إشعارين", len(dict(g.__calls.teleports)) == n, (n, len(dict(g.__calls.teleports))))

check("انقطاع الاتصال يسوي ريجوين", kickcase(network=True)[1] >= 1)
check("الزر مطفي -> ما يرجع", kickcase(enabled=False)[1] == 0)
check("نافذة غير الطرد ما تسوي شي", kickcase(prompt_name="SomethingElse")[1] == 0)

# ---------- 13) منفذ بدون queue_on_teleport: ما ينكسر وينبّه ----------
lua = run(executor_has_queue=False)
g = lua.globals()
g.Options.RejoinLoader.Text = "https://x.dev/a.lua"
g.HavenRejoin.Rejoin(g.HavenRejoin, "x")
g.__runThreads(); g.__runThreads()
check("بدون queue المنفذ ما ينكسر", len(dict(g.__calls.teleports)) >= 1)
msgs = " ".join(str(g.__calls.notify[i].Description) for i in sorted(dict(g.__calls.notify).keys()))
check("ينبّه إن المنفذ ما يدعم إعادة التشغيل", "queue_on_teleport" in msgs, msgs)

print()
print("FAILED:", len(fails), fails if fails else "")
sys.exit(1 if fails else 0)
