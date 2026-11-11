(function()
  if not game:IsLoaded() then game.Loaded:Wait() end

  -- توافق مع كل المنفذات: بديل لو getgenv غير موجودة
  local getgenv = getgenv or function() return (getfenv and getfenv(0)) or _G end

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

  -- توافق مع كل المنفذات: يجرب gethui ثم CoreGui ثم PlayerGui
  local function SafeParentGui(guiObj)
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
      settingsImage   = "rbxassetid://18767849817",
      chevronImage    = "rbxassetid://18865373378"
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
      pcall(function()
        local vp = workspace.CurrentCamera.ViewportSize
        local sx = (windowSize.X.Offset > 0) and ((vp.X - 16) / windowSize.X.Offset) or 1
        local sy = (windowSize.Y.Offset > 0) and ((vp.Y - 16) / windowSize.Y.Offset) or 1
        fitScale = math.clamp(math.min(sx, sy), 0.5, 1)
      end)
      local baseScale = Create("UIScale", {Name = "BaseUIScale", Scale = fitScale, Parent = base})

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
      local tabSwitchersScrollingFrame = Create("ScrollingFrame", {Name = "TabSwitchersScrollingFrame", AutomaticCanvasSize = Enum.AutomaticSize.Y, BottomImage = "", CanvasSize = UDim2.new(), ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 0, TopImage = "", BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 58), Size = UDim2.new(1, 0, 1, -(58 + 50)), Parent = rail}, {
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
        Create("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder})
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
        local gsBtn = Create("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.fromOffset(200, 30), ZIndex = 15, Parent = globalSettings}, {
          Create("UIPadding", {PaddingLeft = UDim.new(0, 15)}),
          Create("UIListLayout", {Padding = UDim.new(0, 10), FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center})
        })
        local check = Create("Frame", {BackgroundColor3 = Theme.AccentSecondary, BackgroundTransparency = gSettings.Default and 0 or 1, Size = UDim2.fromOffset(8, 8), LayoutOrder = -1, ZIndex = 15, Parent = gsBtn}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
        local sName = Create("TextLabel", {FontFace = InterFont(Enum.FontWeight.Medium), Text = gSettings.Name, TextColor3 = Theme.Text, TextSize = 13, TextTransparency = gSettings.Default and 0.1 or 0.5, AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, ZIndex = 15, Parent = gsBtn})
        local st = gSettings.Default
        gsBtn.MouseButton1Click:Connect(function()
          st = not st check.BackgroundTransparency = st and 0 or 1 sName.TextTransparency = st and 0.1 or 0.5
          if gSettings.Callback then task.spawn(gSettings.Callback, st) end
        end)
        return {}
      end

      function WindowFunctions:TabGroup()
        local GroupFuncs = {}
        local sectionTabSwitchers = Create("Frame", {AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 0, 0), Parent = tabSwitchersScrollingFrame}, {
          Create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
        })

        function GroupFuncs:Tab(tSettings)
          local TabFunctions = {}
          tabIndex = tabIndex + 1
          -- زر التبويب: أيقونة وتحتها اسم قصير
          local shortName = string.match(tSettings.Name, "^[%w]+") or tSettings.Name
          local tabSwitcher = Create("TextButton", {Name = "TabSwitcher", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 52), LayoutOrder = tabIndex, Parent = sectionTabSwitchers})
          local tabTile = Create("Frame", {Name = "TabTile", AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = Theme.CardBg, BorderSizePixel = 0, Position = UDim2.new(0.5, 0, 0, 2), Size = UDim2.fromOffset(40, 32), Parent = tabSwitcher}, {
            Create("UICorner", {CornerRadius = UDim.new(0, 10)})
          })
          local tabStroke = Create("UIStroke", {Name = "TabSwitcherUIStroke", ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.StrokeIdle, Transparency = 0.45, Parent = tabTile})
          local tabImage = tSettings.Image and Create("ImageLabel", {Name = "TabImage", Image = tSettings.Image, ImageColor3 = Theme.SubText, AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(20, 20), Parent = tabTile})
          local tabSwitcherName = Create("TextLabel", {Name = "TabSwitcherName", FontFace = InterFont(Enum.FontWeight.SemiBold), Text = shortName, TextColor3 = Theme.SubText, TextSize = 8, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1, Position = UDim2.fromOffset(2, 37), Size = UDim2.new(1, -4, 0, 12), Parent = tabSwitcher})
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
              buttonInteract.MouseButton1Click:Connect(function() if bSettings.Callback then bSettings.Callback() end end)
              return {UpdateName = function(_, n) buttonInteract.Text = n end, SetVisibility = function(_, s) buttonRow.Visible = s end}
            end

            function SectionFunctions:Toggle(Flag, DisplayName, Config, Callback)
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
              interact.MouseButton1Click:Connect(DoToggle)
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
              touchArea.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = true SetValue(inp) end end)
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
              local InputFunctions = {IgnoreConfig = false, Class = "Input", Callback = iSettings.Callback}
              local input = NewRow(40)

              local inputName = Create("TextLabel", {FontFace = InterFont(Enum.FontWeight.Medium), Text = iSettings.Name, RichText = true, TextColor3 = Theme.Text, TextSize = 13, TextTransparency = 0.25, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -90, 1, 0), Parent = input})
              local inputBox = Create("TextBox", {FontFace = InterFont(Enum.FontWeight.Medium), Text = iSettings.Default or "", PlaceholderText = iSettings.Placeholder or "", TextColor3 = Theme.Text, TextSize = 12, TextTransparency = 0.15, AnchorPoint = Vector2.new(1, 0.5), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Theme.BaseBg, BackgroundTransparency = 0.2, BorderSizePixel = 0, ClipsDescendants = true, Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(60, 24), ZIndex = 2, Parent = input}, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Create("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Theme.Accent, Transparency = 0.6}),
                Create("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}),
                Create("UISizeConstraint", {MaxSize = Vector2.new(175, 999)})
              })
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
              function KeybindFunctions:Bind(Key) if Key then binded = Key binderBox.Text = Key.Name else binded = nil binderBox.Text = "NONE" end end
              function KeybindFunctions:GetBind() return binded end
              function KeybindFunctions:SetBind(Key) KeybindFunctions:Bind(Key) end
              function KeybindFunctions:UpdateName(n) keybindName.Text = n end
              function KeybindFunctions:SetVisibility(s) keybind.Visible = s end
              binderBox.Focused:Connect(function() focused = true binderBox.Text = "..." end)
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
                if tile then Tween(tile, tabInfo, {BackgroundColor3 = Theme.CardBg}):Play() end
                if stroke then Tween(stroke, tabInfo, {Transparency = 0.45}):Play() end
                if image then Tween(image, tabInfo, {ImageColor3 = Theme.SubText}):Play() end
                if name then Tween(name, tabInfo, {TextColor3 = Theme.SubText}):Play() end
              end
            end
            tabs[tabSwitcher].Parent = content
            currentTabInstance = tabs[tabSwitcher]
            currentTab.Text = string.upper(tSettings.Name)
            Tween(tabTile, tabInfo, {BackgroundColor3 = Theme.Accent}):Play()
            Tween(tabStroke, tabInfo, {Transparency = 1}):Play()
            Tween(tabSwitcherName, tabInfo, {TextColor3 = Theme.Text}):Play()
            if tabImage then Tween(tabImage, tabInfo, {ImageColor3 = Theme.Text}):Play() end
          end

          tabSwitcher.MouseButton1Click:Connect(SelectCurrentTab)
          function TabFunctions:Select() SelectCurrentTab() end
          function TabFunctions:InsertConfigSection(_, THISWINDOW)
            THISWINDOW:GlobalSetting({Name = "See-Through Window", Default = THISWINDOW:GetAcrylicBlurState(), Callback = function(b) THISWINDOW:SetAcrylicBlurState(b) end})
            THISWINDOW:GlobalSetting({Name = "Show My Account", Default = THISWINDOW:GetUserInfoState(), Callback = function(b) THISWINDOW:SetUserInfoState(b) end})
            local configSection = TabFunctions:Section({Side = "Left"})
            configSection:SubLabel({Text = "SAVING & SERVERS"})
            configSection:Toggle("SaveSettings", "Auto Save Config", function()
              local lastSave = 0
              repeat task.wait(1)
                if os.clock() - lastSave >= 5 then lastSave = os.clock() haven:SaveConfig(game.PlaceId) end
              until not Options.SaveSettings:GetValue()
            end)
            configSection:Toggle("AutoRejoin", "Auto Rejoin If Kicked", function(value)
              if value then
                repeat task.wait(1)
                  pcall(function()
                    Services.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
                      if child.Name == "ErrorPrompt" then Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end
                    end)
                  end)
                until not Options.AutoRejoin:GetValue()
              end
            end)
            configSection:Divider()
            configSection:Button({Name = "Rejoin This Server", Callback = function() Services.TeleportService:Teleport(game.PlaceId, LocalPlayer) end})
            configSection:Button({Name = "Join Another Server", Callback = function()
              pcall(function()
                local Site = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                for _, v in pairs(Site.data) do
                  if tonumber(v.maxPlayers) > tonumber(v.playing) and tostring(v.id) ~= tostring(game.JobId) then
                    Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, tostring(v.id), LocalPlayer)
                    task.wait(4)
                  end
                end
              end)
            end})
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
          btn.MouseButton1Click:Connect(function() if v.Callback then v.Callback() end dialog:Destroy() end)
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
        for _, opt in pairs(haven.Options) do
          if opt.Class == "Toggle" and opt.State then pcall(function() opt:UpdateState(false) end) end
        end
        screenGui:Destroy() pcall(function() LocalPlayer.PlayerGui.HavenClickButton:Destroy() end)
        shared.loaded = nil shared.VertexLoaded = nil
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

      function haven:SaveConfig(Path)
        if not Path or not writefile then return false end
        local data = {objects = {}}
        for flag, opt in pairs(haven.Options) do
          if opt.Class == "Toggle" then table.insert(data.objects, {type = "Toggle", flag = flag, state = opt.State or false})
          elseif opt.Class == "Slider" then table.insert(data.objects, {type = "Slider", flag = flag, value = tostring(opt.Value or 0)})
          elseif opt.Class == "Input" then table.insert(data.objects, {type = "Input", flag = flag, text = opt.Text or ""})
          elseif opt.Class == "Dropdown" then table.insert(data.objects, {type = "Dropdown", flag = flag, value = opt.Value}) end
        end
        local ok, enc = pcall(HttpService.JSONEncode, HttpService, data)
        if ok then pcall(writefile, haven.Folder .. "/settings/" .. tostring(Path) .. ".json", enc) end
        return true
      end

      function haven:LoadConfig(Path)
        shared.tabs = nil
        if not Path or not isfile or not readfile then return false end
        local file = haven.Folder .. "/settings/" .. tostring(Path) .. ".json"
        if not isfile(file) then return false end
        local ok, dec = pcall(HttpService.JSONDecode, HttpService, readfile(file))
        if not ok or not dec or not dec.objects then return false end
        for _, opt in ipairs(dec.objects) do
          local target = haven.Options[opt.flag]
          if target then
            task.spawn(function()
              if opt.type == "Toggle" and opt.state ~= nil then target:UpdateState(opt.state)
              elseif opt.type == "Slider" and opt.value then target:UpdateValue(opt.value)
              elseif opt.type == "Input" and opt.text then target:UpdateText(opt.text)
              elseif opt.type == "Dropdown" and opt.value then target:UpdateSelection(opt.value) end
            end)
          end
        end
        return true
      end

      pcall(function()
        local pGui = LocalPlayer:WaitForChild("PlayerGui")
        if pGui:FindFirstChild("HavenClickButton") then pGui.HavenClickButton:Destroy() end
        local cGui = Create("ScreenGui", {Name = "HavenClickButton", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999999, ZIndexBehavior = Enum.ZIndexBehavior.Global, Parent = pGui})
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
        cBtn.Activated:Connect(function() if not bMoved then WindowFunctions:SetState(not WindowFunctions:GetState()) end end)
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
    local gui, dim, cardScale, baseScale, renderConn
    local shown, target = 0, 0

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

    local function DecodeBase64(data)
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
    local FONT_ID   = "rbxassetid://12187365364"

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

      dim = New("Frame", {Name = "Dim", Active = true, BackgroundColor3 = Color3.fromRGB(8, 8, 10), BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1)}, gui)

      local card = New("Frame", {Name = "Card", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(420, 400), BackgroundTransparency = 1, BorderSizePixel = 0}, gui)

      -- تصغير تلقائي للشاشات الصغيرة (الجوال)
      baseScale = 1
      pcall(function()
        local vp = workspace.CurrentCamera.ViewportSize
        baseScale = math.clamp(math.min(vp.X / 460, vp.Y / 440), 0.45, 1)
      end)
      cardScale = New("UIScale", {Scale = baseScale * 0.8}, card)

      -- منطقة الشعار
      local holder = New("Frame", {Name = "LogoHolder", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 26), Size = UDim2.fromOffset(230, 230), BackgroundTransparency = 1}, card)

      -- الحلقة الخارجية الباهتة
      local ringBase = Circle(208, WHITE, 1, holder, 4)
      New("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = TRACK, Thickness = 1, Transparency = 0.35}, ringBase)

      -- القوس الأبيض الدوار
      local ringWhite = Circle(208, WHITE, 1, holder, 5)
      local whiteStroke = New("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = WHITE, Thickness = 2, Transparency = 0}, ringWhite)
      local whiteGrad = New("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.45, 0.85), NumberSequenceKeypoint.new(0.6, 1), NumberSequenceKeypoint.new(1, 1)})}, whiteStroke)

      -- القوس الأحمر الداخلي
      local ringRed = Circle(190, WHITE, 1, holder, 5)
      local redStroke = New("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = RED, Thickness = 3, Transparency = 0}, ringRed)
      local redGrad = New("UIGradient", {Rotation = 180, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0.8), NumberSequenceKeypoint.new(0.7, 1), NumberSequenceKeypoint.new(1, 1)})}, redStroke)

      -- النقطة البيضاء التي تدور على الحلقة
      local orbit = New("Frame", {Name = "Orbit", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(208, 208), BackgroundTransparency = 1, ZIndex = 6}, holder)
      local dot = New("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(11, 11), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 6}, orbit)
      New("UICorner", {CornerRadius = UDim.new(1, 0)}, dot)

      -- الشعار (صورة) أو حرف H احتياطي لو المشغل ما يدعم getcustomasset
      if logoAsset then
        New("ImageLabel", {Name = "Logo", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(158, 158), BackgroundTransparency = 1, Image = logoAsset, ScaleType = Enum.ScaleType.Fit, ZIndex = 7}, holder)
      else
        New("TextLabel", {Name = "Logo", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(150, 150), BackgroundTransparency = 1, Text = "H", TextColor3 = WHITE, TextSize = 96, FontFace = Font.new(FONT_ID, Enum.FontWeight.Bold, Enum.FontStyle.Italic), ZIndex = 7}, holder)
      end

      -- النصوص
      New("TextLabel", {Name = "Title", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 276), Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "H A V E N   H U B", TextColor3 = WHITE, TextSize = 25, FontFace = Font.new(FONT_ID, Enum.FontWeight.Bold, Enum.FontStyle.Normal)}, card)
      New("TextLabel", {Name = "Status", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 312), Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = "L O A D I N G", TextColor3 = RED, TextSize = 11, FontFace = Font.new(FONT_ID, Enum.FontWeight.Bold, Enum.FontStyle.Normal)}, card)

      -- شريط التقدم
      local track = New("Frame", {Name = "Track", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 345), Size = UDim2.fromOffset(240, 2), BackgroundColor3 = TRACK, BorderSizePixel = 0}, card)
      New("UICorner", {CornerRadius = UDim.new(1, 0)}, track)
      local fill = New("Frame", {Name = "Fill", Size = UDim2.fromScale(0, 1), BackgroundColor3 = RED, BorderSizePixel = 0}, track)
      New("UICorner", {CornerRadius = UDim.new(1, 0)}, fill)
      local knob = New("Frame", {Name = "Knob", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(7, 7), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 2}, track)
      New("UICorner", {CornerRadius = UDim.new(1, 0)}, knob)
      local percent = New("TextLabel", {Name = "Percent", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 356), Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = "0%", TextColor3 = WHITE, TextSize = 11, TextTransparency = 0.1, FontFace = Font.new(FONT_ID, Enum.FontWeight.Medium, Enum.FontStyle.Normal)}, card)

      -- حركة الدوران + تحديث النسبة
      local angle = 0
      renderConn = RunService.RenderStepped:Connect(function(dt)
        angle = (angle + dt * 150) % 360
        orbit.Rotation = angle
        whiteGrad.Rotation = angle
        redGrad.Rotation = (180 - angle * 0.6) % 360
        shown = shown + (target - shown) * math.min(1, dt * 7)
        if target - shown < 0.05 then shown = target end
        local alpha = math.clamp(shown / 100, 0, 1)
        fill.Size = UDim2.fromScale(alpha, 1)
        knob.Position = UDim2.fromScale(alpha, 0.5)
        percent.Text = tostring(math.floor(shown + 0.5)) .. "%"
      end)

      TweenService:Create(dim, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.3}):Play()
      TweenService:Create(cardScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = baseScale}):Play()
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
        repeat task.wait() until shown >= 99.5 or os.clock() - started > 2
        task.wait(0.35)
        TweenService:Create(dim, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {BackgroundTransparency = 1}):Play()
        TweenService:Create(cardScale, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {Scale = 0}):Play()
        task.wait(0.32)
      end)
      pcall(function() if renderConn then renderConn:Disconnect() end end)
      pcall(function() if gui then gui:Destroy() end end)
    end

    return loader
  end)()
  HavenLib.LogoAsset = HavenLoader.LogoAsset
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
    Main     = Vertex:Tab({Name = "Farming", Image = "rbxassetid://10709811110"}),
    Roles    = Vertex:Tab({Name = "Combat", Image = "rbxassetid://10734975692"}),
    Target   = Vertex:Tab({Name = "Targeting", Image = "rbxassetid://10734977012"}),
    Visual   = Vertex:Tab({Name = "Visuals", Image = "rbxassetid://10723346959"}),
    Player   = Vertex:Tab({Name = "Character", Image = "rbxassetid://10734920149"}),
    Tracker  = Vertex:Tab({Name = "Webhooks", Image = "rbxassetid://10734943902"}),
    Settings = Vertex:Tab({Name = "Settings", Image = "rbxassetid://10734963191"})
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
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local tRoot = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot and tRoot then
          local savedCF, start = myRoot.CFrame, os.clock()
          while os.clock() - start < 1.2 and tRoot.Parent do
            RunService.Heartbeat:Wait()
            myRoot.CFrame = tRoot.CFrame
            myRoot.AssemblyLinearVelocity = Vector3.new(9000, 9000, 9000)
            myRoot.AssemblyAngularVelocity = Vector3.new(9000, 9000, 9000)
          end
          myRoot.AssemblyLinearVelocity = Vector3.zero
          myRoot.AssemblyAngularVelocity = Vector3.zero
          myRoot.CFrame = savedCF
        end
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

  CoinAttribute = function(coinPart, checkOnly)
    if not coinPart then return false end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not root or not hum.Parent.PrimaryPart then return false end
    local dist = (coinPart.Position - hum.Parent.PrimaryPart.Position).Magnitude
    if dist <= 4 and shared.Premium then
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

  local function IsBagFull()
    if not roles then return false end
    local elite = LocalPlayer:GetAttribute("Elite")
    local coins = tonumber(roles.Coins) or 0
    return (elite ~= nil and coins >= 50) or (elite == nil and coins >= 40)
  end

  local function TweenTo(targetCF, speed, useQuad, waitCollect, targetCoin)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if v17 then v17:Cancel() end
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    local dur = math.clamp((root.Position - targetCF.Position).Magnitude / speed, 0.15, 5)
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
    local originCF
    if not Options.KillM:GetValue() then
      local att = myRoot:FindFirstChild("GunShoulderAttachment")
      originCF = att and att.WorldCFrame or myRoot.CFrame
    else
      local att = mRoot:FindFirstChild("RootAttachment")
      originCF = att and (att.WorldCFrame * CFrame.new(0, 2, 0)) or mRoot.CFrame
    end
    local handle = gun:FindFirstChild("Handle")
    local reload = handle and handle:FindFirstChild("Reload")
    if reload and not reload.Playing then
      local shoot = workspace:FindFirstChild(LocalPlayer.Name) and workspace[LocalPlayer.Name]:FindFirstChild("Gun") and workspace[LocalPlayer.Name].Gun:FindFirstChild("Shoot")
      if shoot then shoot:FireServer(originCF, predictedCF) end
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
  end

  local function DisableFloat()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and root:FindFirstChild("BodyVelocity") then root.BodyVelocity:Destroy() end
  end

  local function ResetOrLobby()
    pcall(function()
      if Options.Mode:GetValue() == "Nearest" then LocalPlayer.Character.Humanoid.Health = 0 return end
      for _, child in pairs(workspace:GetChildren()) do
        if (child:IsA("Model") or child:IsA("Folder")) and string.find(string.lower(child.Name), "lobby") then
          for _, desc in pairs(child:GetDescendants()) do
            if desc:IsA("SpawnLocation") then TweenTo(CFrame.new(desc.Position + Vector3.new(0, 5, 0)), 5000) return end
          end
        end
      end
    end)
  end

  local function FindCoin(rootPart, mode)
    local container = GetMapElement("CoinContainer")
    if not container then return nil end
    local closest, huge, nearTbl, safeTbl = nil, math.huge, {}, {}
    local mPlayer = v14 and Players:FindFirstChild(v14)
    local mRoot = mPlayer and mPlayer.Character and mPlayer.Character:FindFirstChild("HumanoidRootPart")
    local mPos = mRoot and mRoot.Position or nil

    for _, child in pairs(container:GetChildren()) do
      if CoinAttribute(child, true) and child.Name == "Coin_Server" and child:FindFirstChild("TouchInterest") and child:FindFirstChild("CoinVisual") and IsPlayerAlive(LocalPlayer, roles) then
        local pos = child.CoinVisual.Position
        local mag = (rootPart.Position - pos).Magnitude
        if mPos and (pos - mPos).Magnitude >= 25 then table.insert(safeTbl, child) end
        if mag <= 50 then table.insert(nearTbl, child) end
        if mag < huge then huge = mag closest = child end
      end
    end
    if mode == "closest" then return closest
    elseif mode == "random" then
      if #nearTbl > 0 then return nearTbl[math.random(1, #nearTbl)]
      elseif #safeTbl > 0 then return safeTbl[math.random(1, #safeTbl)] end
    end
    return nil
  end

  local function MoveToCoin(coin, rootPart)
    local pos = coin.CoinVisual.Position
    local mag = (rootPart.Position - pos).Magnitude
    local speed = shared.Premium and (shared.speed or 23) or 21
    if not IsBagFull() and CoinAttribute(coin, true) then
      local cf = CFrame.new(pos.X, pos.Y, pos.Z)
      if mag > 200 then
        rootPart.CFrame = cf * CFrame.new(0, 10, 0) task.wait(2)
        TweenTo(cf * CFrame.new(0, 1.5, 0), 5000, false)
      elseif Options.Mode:GetValue() == "Randomize" then
        TweenTo(cf * CFrame.new(0, 1.5, 0), 20, true, true, coin)
      else
        TweenTo(cf * CFrame.new(0, 1.5, 0), speed, false)
      end
    end
  end

  local function RunAutoFarm()
    pcall(function()
      local char = LocalPlayer.Character
      local hum = char and char:FindFirstChild("Humanoid")
      local root = char and char:FindFirstChild("HumanoidRootPart")
      if not v14 then DisableFloat() return end

      local function farmStep()
        if not Options.AutoFarm:GetValue() or not IsPlayerAlive(LocalPlayer, roles) or not root then return end
        local mode = (Options.Mode:GetValue() == "Nearest" or Options.Mode:GetValue() == "Nearest + XP Farm") and "closest" or "random"
        local coin = FindCoin(root, mode)
        if coin and v18 ~= coin then EnableFloat() MoveToCoin(coin, root) v18 = coin end
      end

      if not IsBagFull() or not root or not hum or hum.Health <= 0 or not IsPlayerAlive(LocalPlayer, roles) then farmStep() return end
      if Options.KillAll:GetValue() or Options.KillM:GetValue() or Options.AutoShoot:GetValue() then
        if v14 == LocalPlayer.Name or v15 == LocalPlayer.Name then farmStep() else ResetOrLobby() end
      else ResetOrLobby() end
    end)
  end

  local function UpdateChams()
    for _, player in pairs(Players:GetPlayers()) do
      if player ~= LocalPlayer then
        local char = player.Character
        if not char then
          if tbl[player] then tbl[player]:Destroy() tbl[player] = nil end
        else
          local hl = char:FindFirstChild("Highlight") or Instance.new("Highlight", char)
          tbl[player] = hl
          if not IsPlayerAlive(player, roles) then hl.FillColor = Color3.fromRGB(255, 255, 255)
          else
            local item = roles and roles[player.Name]
            if item and item.Role == "Murderer" then hl.FillColor = Color3.fromRGB(225, 0, 0)
            elseif item and (item.Role == "Sheriff" or item.Role == "Hero") then hl.FillColor = Color3.fromRGB(0, 110, 255)
            else hl.FillColor = Color3.fromRGB(76, 215, 134) end
          end
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
    for _, p in pairs(Players:GetPlayers()) do
      local head = p.Character and p.Character:FindFirstChild("Head")
      if head and head:FindFirstChild("UsernameTag") then head.UsernameTag:Destroy() end
    end
  end

  -- ============================================================================
  -- 4. بناء الأزرار والخيارات (بدون إيموجيات نهائياً)
  -- ============================================================================
  HavenLoader:SetProgress(75)
  shared.Main:SubLabel({Text = "COIN FARMING"})
  shared.Main:Toggle("AutoFarm", "Auto Collect Coins", function(arg1)
    if arg1 then
      Noclipping = RunService.Stepped:Connect(function()
        if LocalPlayer.Character and IsPlayerAlive(LocalPlayer, roles) then
          for _, d in pairs(LocalPlayer.Character:GetDescendants()) do if d:IsA("BasePart") and d.CanCollide then d.CanCollide = false end end
        end
      end)
    end
    repeat task.wait() RunAutoFarm() until not Options.AutoFarm:GetValue()
    if Noclipping then Noclipping:Disconnect() end
    DisableFloat()
  end)

  shared.Main:Dropdown({Name = "Collection Mode", Multi = false, Required = true, Options = {"Nearest + XP Farm", "Nearest", "Randomize"}, Default = 2, Callback = function() DisableFloat() end}, "Mode")
  shared.Main:Divider()
  shared.Main:SubLabel({Text = "ROUND HELPERS"})

  shared.Main:Toggle("AutoGrab", "Auto Pick Up Gun", function(arg1)
    if arg1 then
      repeat task.wait()
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

  shared.Main:Toggle("DodgeKnife", "Evade Thrown Knives", function(arg1)
    if arg1 then
      repeat task.wait()
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

  shared.Main:Toggle("EndRound", "Force Round End", function(arg1)
    if arg1 then
      Window:Notify({Title = "HAVEN HUB", Description = "Flings Murderer when you are not in the round.", Duration = 5})
      repeat task.wait()
        local mPlayer = v14 and Players:FindFirstChild(v14)
        if mPlayer and not IsPlayerAlive(LocalPlayer, roles) and v14 ~= LocalPlayer.Name then res:fling(mPlayer) task.wait(3) end
      until not Options.EndRound:GetValue()
    end
  end)

  shared.Main:Divider()
  shared.Main:SubLabel({Text = "TELEPORTS"})
  shared.Main:Button({Name = "Go To Lobby", Callback = function()
    for _, child in pairs(workspace:GetChildren()) do
      if (child:IsA("Model") or child:IsA("Folder")) and string.find(string.lower(child.Name), "lobby") then
        for _, desc in pairs(child:GetDescendants()) do
          if desc:IsA("SpawnLocation") then TweenTo(CFrame.new(desc.Position + Vector3.new(0, 5, 0)), 5000) return end
        end
      end
    end
  end})

  shared.Main:Button({Name = "Go To Map", Callback = function()
    local spawns = GetMapElement("Spawns")
    if spawns then
      for _, desc in ipairs(spawns:GetDescendants()) do
        if desc:IsA("BasePart") then TweenTo(desc.CFrame * CFrame.new(0, 5, 0), 5000) return end
      end
    else Window:Notify({Title = "HAVEN HUB", Description = "Map does not exist yet.", Duration = 5}) end
  end})

  -- قسم Target
  shared.Target:SubLabel({Text = "PLAYER TARGETING"})
  local TargetDropdown = shared.Target:Dropdown({Name = "Selected Player", Search = true, Multi = false, Required = false, Options = {}, Default = {}, Callback = function() end}, "Target")
  local res12 = Players.PlayerAdded:Connect(function(p) TargetDropdown:InsertOptions({p.Name}) end)
  local res13 = Players.PlayerRemoving:Connect(function(p) TargetDropdown:RemoveOptions({p.Name}) end)
  for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then TargetDropdown:InsertOptions({p.Name}) end end

  shared.Target:Toggle("TargetFling", "Fling Selected Player", function(arg1)
    if arg1 then
      repeat task.wait()
        local target = Options.Target:GetValue() and Players:FindFirstChild(Options.Target:GetValue())
        if target then res:fling(target) end
        task.wait(3)
      until not Options.TargetFling:GetValue()
    end
  end)

  shared.Target:Toggle("Spectate", "Watch Selected Player", function(arg1)
    if arg1 then
      repeat task.wait()
        local target = Options.Target:GetValue() and Players:FindFirstChild(Options.Target:GetValue())
        if target and target.Character and target.Character:FindFirstChild("Head") then workspace.CurrentCamera.CameraSubject = target.Character.Head end
      until not Options.Spectate:GetValue()
      if LocalPlayer.Character then workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid") end
    end
  end)

  shared.Target:Toggle("Annoy", "Follow Selected Player", function(arg1)
    if arg1 then
      repeat task.wait()
        pcall(function()
          local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
          local tChar = Options.Target:GetValue() and workspace:FindFirstChild(Options.Target:GetValue())
          if myRoot and tChar and tChar:FindFirstChild("HumanoidRootPart") then myRoot.CFrame = tChar.HumanoidRootPart.CFrame end
        end)
      until not Options.Annoy:GetValue()
    end
  end)

  shared.Target:Button({Name = "Go To Selected Player", Callback = function()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tChar = Options.Target:GetValue() and workspace:FindFirstChild(Options.Target:GetValue())
    if myRoot and tChar and tChar:FindFirstChild("HumanoidRootPart") then myRoot.CFrame = tChar.HumanoidRootPart.CFrame end
  end})

  shared.Target:Divider()
  shared.Target:Toggle("FlingSheriff", "Fling The Sheriff", function(arg1)
    if arg1 then
      repeat task.wait()
        local sPlayer = v15 and Players:FindFirstChild(v15)
        if sPlayer and v15 ~= LocalPlayer.Name then res:fling(sPlayer) task.wait(3) end
      until not Options.FlingSheriff:GetValue()
    end
  end)

  shared.Target:Toggle("FlingMurderer", "Fling The Murderer", function(arg1)
    if arg1 then
      repeat task.wait()
        local mPlayer = v14 and Players:FindFirstChild(v14)
        if mPlayer and v14 ~= LocalPlayer.Name then res:fling(mPlayer) task.wait(3) end
      until not Options.FlingMurderer:GetValue()
    end
  end)

  -- قسم Visuals
  shared.Visual:SubLabel({Text = "ESP & HIGHLIGHTS"})
  shared.Visual:Toggle("Chams", "Role Colors ESP", function(arg1)
    if arg1 then
      repeat task.wait(0.2) UpdateChams() until not Options.Chams:GetValue()
      ClearESP()
    end
  end)

  shared.Visual:Toggle("GunDropCham", "Dropped Gun ESP", function(arg1)
    while arg1 and Options.GunDropCham:GetValue() do
      task.wait(0.5)
      local gunDrop = GetGunDrop()
      if gunDrop and not gunDrop:FindFirstChild("GunESP") then
        local hl = Instance.new("Highlight", gunDrop)
        hl.Name = "GunESP" hl.FillTransparency = 0.5 hl.FillColor = Color3.fromRGB(128, 225, 0) hl.OutlineColor = Color3.fromRGB(0, 163, 0)
      end
    end
  end)

  shared.Visual:Toggle("Render", "Pause Rendering In Background", function(arg1)
    if arg1 then
      UserInputService.WindowFocusReleased:Connect(function() if Options.Render:GetValue() then RunService:Set3dRenderingEnabled(false) end end)
      UserInputService.WindowFocused:Connect(function() RunService:Set3dRenderingEnabled(true) end)
    end
  end)

  shared.Visual:Toggle("Names", "Name Tags ESP", function()
    while Options.Names:GetValue() do
      task.wait(0.5)
      for _, p in pairs(Players:GetPlayers()) do if p.Character then CreateNameESP(p) end end
    end
    ClearESP()
  end)

  shared.Visual:Divider()
  shared.Visual:Dropdown({Name = "Emote Choice", Multi = false, Required = true, Options = {"ninja", "dab", "floss", "headless", "zen", "zombie", "sit"}, Default = 1, Callback = function() end}, "Emote")
  shared.Visual:Toggle("AutoEmote", "Loop Emote", function()
    while Options.AutoEmote:GetValue() do task.wait(0.2) res:emote(Options.Emote:GetValue()) end
  end)

  -- قسم Combat & Roles
  shared.Roles:SubLabel({Text = "MURDERER TOOLS"})
  shared.Roles:Toggle("KillAura", "Knife Aura", function(arg1)
    if arg1 then
      repeat task.wait()
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

  shared.Roles:Slider("AuraDistance", "Aura Range", 5, 50, 5, "Percent", function() end)

  KillAll = function()
    pcall(function()
      EquipTool("Knife")
      for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and workspace:FindFirstChild(p.Name) and workspace[p.Name]:FindFirstChild("HumanoidRootPart") then
          LocalPlayer.Character.Knife.Events.HandleTouched:FireServer(workspace[p.Name].HumanoidRootPart)
        end
      end
    end)
  end

  shared.Roles:Toggle("KillAll", "Eliminate Everyone", function(arg1)
    if arg1 then
      repeat task.wait()
        if v14 and (IsBagFull() or not Options.AutoFarm:GetValue()) and v14 == LocalPlayer.Name then KillAll() end
      until not Options.KillAll:GetValue()
    end
  end)

  shared.Roles:Divider()
  shared.Roles:SubLabel({Text = "SHERIFF TOOLS"})
  shared.Roles:Toggle("SilentAim", "Silent Aim", function(arg1)
    if arg1 then
      local conn = nil
      repeat task.wait()
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
                if gun:FindFirstChild("Shoot") then gun.Shoot:FireServer(originCF, mRoot.CFrame) end
              end
            end)
          end
        end
      until not Options.SilentAim:GetValue()
      if conn then conn:Disconnect() end
    end
  end)

  shared.Roles:Toggle("KillM", "Instant Shot (Obvious)", function(arg1)
    if arg1 then
      repeat task.wait()
        if IsBagFull() or not Options.AutoFarm:GetValue() then EquipTool("Gun") ShootMurderer() end
      until not Options.KillM:GetValue()
    end
  end)

  shared.Roles:Toggle("AutoShoot", "Auto Fire At Murderer", function(arg1)
    if arg1 then
      repeat task.wait()
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

  shared.Roles:Keybind("ShootBind", "Fire Key", function() pcall(function() EquipTool("Gun") ShootMurderer() end) end)

  -- قسم Webhooks
  shared.Tracker:SubLabel({Text = "DISCORD WEBHOOK"})
  local WebhookInput = shared.Tracker:Input({Name = "Webhook Link", Placeholder = "https://discord.com/api/webhooks/...", AcceptedCharacters = "All", Callback = function() end}, "Webhook")
  shared.Tracker:Divider()
  shared.Tracker:Toggle("CoinTracker", "Coin Reports", function() end)
  shared.Tracker:Input({Name = "Report Interval (Minutes)", Placeholder = "minutes", AcceptedCharacters = "Numeric", Callback = function(arg1)
    local num = tonumber(arg1) if num then Options.WebhookTimeInSeconds = num * 60 end
  end}, "WebhookTime")
  local TrackerStatusLabel = shared.Tracker:SubLabel({Text = "COIN REPORTS ARE OFF"})
  shared.Tracker:Divider()

  shared.Tracker:Toggle("BoxNotification", "Unbox Alerts", function(arg1)
    if not arg1 then
      if unboxConnection then unboxConnection:Disconnect() unboxConnection = nil end
    else
      local shop = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Shop")
      local itemService = require(ReplicatedStorage:WaitForChild("ClientServices"):WaitForChild("ItemService"))
      local syncDB = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
      local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
      unboxConnection = shop.BoxController.Event:Connect(function(items)
        local now = os.date("!*t", os.time())
        for _, value in ipairs(items) do
          local itemId, boxId = value.RewardedItemId, value.MysteryBoxId
          local info = itemService:GetDisplayInfo(itemId, "Weapons")
          local rarity = (syncDB.Weapons[itemId] and syncDB.Weapons[itemId].Rarity) or "Unknown"
          local isChroma = info.Chroma and true or false
          pcall(function()
            req({
              Url = WebhookInput:GetInput(),
              Method = "POST",
              Headers = {["Content-Type"] = "application/json"},
              Body = HttpService:JSONEncode({
                username = "Haven Hub - Unbox Notification",
                content = isChroma and "@everyone" or "",
                embeds = {{
                  title = "Mystery Box Unboxed",
                  description = "**Name:** " .. tostring(info.Name) .. "\n**Rarity:** " .. tostring(rarity) .. "\n**Box:** " .. tostring(boxId) .. "\n**Chroma:** `" .. tostring(isChroma) .. "`",
                  timestamp = string.format("%d-%d-%dT%02d:%02d:%02dZ", now.year, now.month, now.day, now.hour, now.min, now.sec),
                  footer = {text = "Powered by Haven Hub"}
                }}
              })
            })
          end)
        end
      end)
    end
  end)

  -- قسم LocalPlayer
  shared.Player:SubLabel({Text = "MOVEMENT"})
  shared.Player:Toggle("WalkSpeed", "Custom Speed", function(arg1)
    if arg1 then
      repeat task.wait() SetStats(Options.WalkSpeedSlider:GetValue(), nil) until not Options.WalkSpeed:GetValue()
      SetStats(16, nil)
    end
  end)
  shared.Player:Slider("WalkSpeedSlider", "Speed Value", 16, 100, 16, "Percent", function() end)

  shared.Player:Toggle("Jump", "Custom Jump", function(arg1)
    if arg1 then
      repeat task.wait() SetStats(nil, Options.JumpPower:GetValue()) until not Options.Jump:GetValue()
      SetStats(nil, 50)
    end
  end)
  shared.Player:Slider("JumpPower", "Jump Value", 50, 100, 50, "Percent", function() end)
  shared.Player:Divider()

  local isInvis = false
  shared.Player:Keybind("Invis", "Invisibility Key", function(arg1)
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

  LocalPlayer.CharacterAdded:Connect(function()
    isInvis = false
    local chair = workspace:FindFirstChild("invischair")
    if chair then chair:Destroy() end
  end)

  shared.Player:Toggle("AntiFling", "Fling Protection", function(arg1)
    if arg1 then
      antifling = RunService.Stepped:Connect(function()
        for _, p in pairs(Players:GetPlayers()) do
          if p ~= LocalPlayer and p.Character then
            for _, d in pairs(p.Character:GetDescendants()) do
              if d:IsA("BasePart") and d.CanCollide and not Options.TargetFling:GetValue() then d.CanCollide = false end
            end
          end
        end
      end)
    end
    repeat task.wait() until not Options.AntiFling:GetValue()
    if antifling then antifling:Disconnect() end
  end)

  -- حماية التبادل (Anti-Stealer)
  HavenLoader:SetProgress(90)
  local trade = ReplicatedStorage:WaitForChild("Trade")
  local declineRemote = trade:FindFirstChild("DeclineTrade")
  local dialogOpen = false
  local tradeConn
  if declineRemote and declineRemote:IsA("RemoteEvent") then
    declineRemote:FireServer()
    tradeConn = trade:WaitForChild("UpdateTrade").OnClientEvent:Connect(function()
      if declineRemote.Parent then declineRemote:FireServer() end
      if not dialogOpen then
        dialogOpen = true
        Window:Dialog({
          Title = "HAVEN HUB SECURITY",
          Description = "We detected an unauthorized trade in the background and blocked it automatically.",
          Buttons = {
            {Name = "Keep Protection Enabled", Callback = function() dialogOpen = false end},
            {Name = "Disable Protection", Callback = function() if tradeConn then tradeConn:Disconnect() tradeConn = nil end dialogOpen = false end}
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

  local function SendCoinWebhook(coinsGained, bagType)
    local now = os.date("!*t", os.time())
    pcall(function()
      local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
      local sec = Options.WebhookTimeInSeconds or 60
      local mins = sec / 60
      local mFmt = (mins % 1 == 0) and mins or tonumber(string.format("%.1f", mins))
      local str = tostring(mFmt) .. " " .. (mFmt == 1 and "Minute" or "Minutes")
      req({
        Url = WebhookInput:GetInput(),
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
          username = "Haven Hub - Coin Tracker",
          embeds = {{
            title = "Haven Hub Currency Tracker",
            color = 14753070,
            fields = {
              {name = "Bag:", value = tostring(bagType), inline = false},
              {name = "Coins Collected in " .. str .. ":", value = tostring(coinsGained), inline = false},
              {name = "Estimated Coins per Hour:", value = tostring(math.floor(coinsGained / sec * 3600)), inline = false}
            },
            timestamp = string.format("%d-%d-%dT%02d:%02d:%02dZ", now.year, now.month, now.day, now.hour, now.min, now.sec),
            footer = {text = "Powered by Haven Hub"}
          }}
        })
      })
    end)
  end

  task.spawn(function()
    while task.wait(0.5) do
      if shared.VertexLoaded ~= true then break end
      if not Options.CoinTracker:GetValue() then
        TrackerStatusLabel:UpdateName("COIN REPORTS ARE OFF")
        table.clear(tbl5) table.clear(tbl6)
      else
        local cd = Options.WebhookTimeInSeconds or 60
        while cd > 0 and Options.CoinTracker:GetValue() do
          TrackerStatusLabel:UpdateName("NEXT REPORT IN " .. cd .. " SECONDS")
          task.wait(1) cd = cd - 1
        end
        if Options.CoinTracker:GetValue() then
          TrackerStatusLabel:UpdateName("SENDING REPORT...")
          for k, v in pairs(tbl5) do if v > 0 then SendCoinWebhook(v, k) end end
          TrackerStatusLabel:UpdateName("REPORT SENT")
          table.clear(tbl5)
        end
      end
    end
  end)

  task.spawn(function()
    while task.wait(0.1) do
      if shared.VertexLoaded ~= true then break end
      pcall(function()
        v14 = FindPlayerWithTool("Knife")
        v15 = FindPlayerWithTool("Gun")
        roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
      end)
    end
    if unboxConnection then unboxConnection:Disconnect() end
    if res36 then res36:Disconnect() end
    if tradeConn then tradeConn:Disconnect() end
    if res12 then res12:Disconnect() end
    if res13 then res13:Disconnect() end
    shared.speed = nil
  end)

  shared.tabs.Main:Select(shared.Main)
  shared.tabs.Settings:InsertConfigSection("Left", Window)
  HavenLib:LoadConfig(game.PlaceId)

  if HavenLoader.Active then
    HavenLoader:Finish()
    Window:SetState(true)
  end

  Window:Notify({
    Title = "HAVEN HUB LOADED",
    Description = "Welcome to Haven Hub. Press LeftControl or the logo button to toggle the UI.",
    Duration = 6
  })

  -- حماية السقوط في الـ Void
  local fallenHeight = workspace.FallenPartsDestroyHeight
  while task.wait(0.1) do
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