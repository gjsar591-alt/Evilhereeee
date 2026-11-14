-- فحص Haven Hub: يقول وين بالضبط تطيح المشكلة ويعرض النتيجة على الشاشة
-- يشتغل لحاله، ما يحتاج أي شي، ويطلع لوحة تقدر تصورها وترسلها
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local URL = "https://raw.githubusercontent.com/gjsar591-alt/Evilhereeee/refs/heads/claude/fervent-volta-w64bf7/HavenHub-auto-restart.lua"

local report, label = {}, nil
local function Show()
  local text = table.concat(report, "\n")
  if label then label.Text = text end
  pcall(function() warn("[HAVEN DEBUG]\n" .. text) end)
  return text
end
local function Add(line)
  report[#report + 1] = tostring(line)
  Show()
end

-- ====== اللوحة ======
pcall(function()
  local gui = Instance.new("ScreenGui")
  gui.Name = "HavenDebug"
  gui.ResetOnSpawn = false
  gui.IgnoreGuiInset = true
  gui.DisplayOrder = 2000000
  local parented = false
  for _, get in ipairs({
    function() return gethui and gethui() end,
    function() return game:GetService("CoreGui") end,
    function() return LocalPlayer:WaitForChild("PlayerGui") end
  }) do
    if pcall(function() gui.Parent = get() end) and gui.Parent then parented = true break end
  end
  if not parented then return end

  local panel = Instance.new("Frame")
  panel.Size = UDim2.fromScale(0.92, 0.8)
  panel.Position = UDim2.fromScale(0.5, 0.5)
  panel.AnchorPoint = Vector2.new(0.5, 0.5)
  panel.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
  panel.BorderSizePixel = 0
  panel.Parent = gui
  Instance.new("UICorner").Parent = panel
  local stroke = Instance.new("UIStroke")
  stroke.Color = Color3.fromRGB(225, 29, 46)
  stroke.Thickness = 2
  stroke.Parent = panel

  local title = Instance.new("TextLabel")
  title.Size = UDim2.new(1, -16, 0, 30)
  title.Position = UDim2.fromOffset(8, 6)
  title.BackgroundTransparency = 1
  title.Font = Enum.Font.GothamBold
  title.TextSize = 16
  title.TextXAlignment = Enum.TextXAlignment.Left
  title.TextColor3 = Color3.fromRGB(225, 29, 46)
  title.Text = "HAVEN HUB - DIAGNOSTIC"
  title.Parent = panel

  label = Instance.new("TextLabel")
  label.Size = UDim2.new(1, -16, 1, -80)
  label.Position = UDim2.fromOffset(8, 38)
  label.BackgroundTransparency = 1
  label.Font = Enum.Font.Code
  label.TextSize = 13
  label.TextWrapped = true
  label.TextXAlignment = Enum.TextXAlignment.Left
  label.TextYAlignment = Enum.TextYAlignment.Top
  label.TextColor3 = Color3.fromRGB(255, 255, 255)
  label.Text = "..."
  label.Parent = panel

  local function Button(text, x, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.44, 0, 0, 34)
    btn.Position = UDim2.new(x, 0, 1, -40)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Parent = panel
    Instance.new("UICorner").Parent = btn
    btn.Activated:Connect(callback)
    return btn
  end
  Button("COPY REPORT", 0.03, Color3.fromRGB(225, 29, 46), function()
    local text = Show()
    pcall(function() if setclipboard then setclipboard(text) elseif toclipboard then toclipboard(text) end end)
    Add("-> copied to clipboard")
  end)
  Button("CLOSE", 0.53, Color3.fromRGB(45, 45, 52), function() gui:Destroy() end)
end)

-- ====== الفحوصات ======
local function Has(name, value)
  return name .. "=" .. ((type(value) == "function" or type(value) == "table") and "yes" or "NO")
end

Add("time: " .. os.date("!%H:%M:%S") .. "Z")
local execName = "unknown"
pcall(function() if identifyexecutor then execName = tostring(identifyexecutor()) end end)
Add("executor: " .. execName)
pcall(function()
  Add("platform: " .. tostring(UserInputService:GetPlatform())
    .. "  touch=" .. tostring(UserInputService.TouchEnabled)
    .. "  kb=" .. tostring(UserInputService.KeyboardEnabled))
end)
Add(Has("httpget", game.HttpGet) .. "  " .. Has("loadstring", loadstring or load))
Add(Has("getgenv", getgenv) .. "  " .. Has("gethui", gethui) .. "  " .. Has("setclipboard", setclipboard))
Add(Has("writefile", writefile) .. "  " .. Has("readfile", readfile) .. "  " .. Has("listfiles", listfiles))
Add(Has("getconnections", getconnections) .. "  " .. Has("firetouch", firetouchinterest))
Add(Has("queue_on_teleport", queue_on_teleport or (syn and syn.queue_on_teleport)) .. "  " .. Has("request", request or http_request))

pcall(function()
  local pg = LocalPlayer:FindFirstChild("PlayerGui")
  Add("MainGUI present: " .. tostring(pg ~= nil and pg:FindFirstChild("MainGUI") ~= nil))
  local play = nil
  if pg then
    for _, d in ipairs(pg:GetDescendants()) do
      if d:IsA("TextButton") and tostring(d.Text):lower():gsub("%s", "") == "play" then play = d break end
    end
  end
  Add("play button found: " .. tostring(play ~= nil) .. (play and (" (" .. play:GetFullName() .. ")") or ""))
end)

-- ====== الأزرار الظاهرة الحين (عشان نعرف شكل شاشة اختيار الجهاز) ======
pcall(function()
  local pg = LocalPlayer:FindFirstChild("PlayerGui")
  if not pg then Add("no PlayerGui") return end
  local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
  Add("viewport: " .. (vp and (math.floor(vp.X) .. "x" .. math.floor(vp.Y)) or "?")
    .. " -> device guess: " .. ((vp and math.min(vp.X, vp.Y) >= 600) and "tablet" or "phone"))

  local function Shown(obj)
    while obj and obj ~= pg do
      if obj:IsA("GuiObject") and not obj.Visible then return false end
      if obj:IsA("ScreenGui") and not obj.Enabled then return false end
      obj = obj.Parent
    end
    return obj ~= nil
  end
  local function TextOf(obj)
    if (obj:IsA("TextButton") or obj:IsA("TextLabel")) and obj.Text ~= "" then return obj.Text end
    for _, child in ipairs(obj:GetDescendants()) do
      if child:IsA("TextLabel") and child.Text ~= "" then return child.Text end
    end
    return ""
  end

  local shown, hits = 0, 0
  Add("-- visible buttons / device matches --")
  for _, d in ipairs(pg:GetDescendants()) do
    if d:IsA("GuiObject") and Shown(d) and d.AbsoluteSize.X > 40 then
      local text = TextOf(d)
      local blob = (d.Name .. " " .. text):lower()
      local isMatch = blob:find("phone") or blob:find("tablet") or blob:find("device") or blob:find("play")
      if (d:IsA("GuiButton") and shown < 18) or isMatch then
        if isMatch then hits = hits + 1 end
        shown = shown + 1
        Add(string.format("%s | %s | text=%q | %dx%d | %s",
          d.ClassName, d.Name, text:sub(1, 24),
          math.floor(d.AbsoluteSize.X), math.floor(d.AbsoluteSize.Y),
          d:GetFullName():gsub("^Players%.[^.]+%.PlayerGui%.", "")))
      end
    end
  end
  Add("-- listed " .. shown .. " objects, " .. hits .. " device/play matches --")
end)

-- تحميل السكربت
local okGet, source = pcall(function() return game:HttpGet(URL) end)
Add("download: " .. tostring(okGet) .. "  bytes=" .. tostring(okGet and #source or 0))
if not okGet then
  Add("ERROR: " .. tostring(source))
  Add("-> المنفذ ما قدر ينزّل من الانترنت")
  return
end

-- ترجمة (compile)
local loader = loadstring or load
local chunk, compileErr = loader(source, "HavenHub")
Add("compile: " .. (chunk and "OK" or ("FAILED -> " .. tostring(compileErr))))
if not chunk then
  Add("-> السكربت ما ينترجم على هذا المنفذ")
  return
end

-- تشغيل
pcall(function()
  local env = (getgenv and getgenv()) or _G
  env.HavenHubStartedAt = nil
  env.HavenHubStartedJob = nil
  shared.VertexLoaded = nil
  shared.VertexJob = nil
  env.HavenHubSource = source -- عشان ينحفظ نسخة عن نفسه للريجوين
end)
local okRun, runErr = pcall(chunk)
Add("run: " .. (okRun and "started" or ("ERROR -> " .. tostring(runErr))))

task.wait(12)
Add("hub loaded: " .. tostring(shared.VertexLoaded == true))
pcall(function()
  local found = {}
  for _, where in ipairs({gethui and gethui() or nil, game:GetService("CoreGui"), LocalPlayer:FindFirstChild("PlayerGui")}) do
    if where then
      for _, child in ipairs(where:GetChildren()) do
        if tostring(child.Name):find("Haven") then found[#found + 1] = child.Name .. "@" .. where.Name end
      end
    end
  end
  Add("haven guis: " .. (#found > 0 and table.concat(found, ", ") or "none"))
end)
Add("-- end of report --")
