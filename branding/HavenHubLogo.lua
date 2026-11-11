--[[
    Haven Hub - animated circular logo + loading screen
    Built only from GUI objects (no image assets needed), red & white.

    Usage (paste this file at the top of your script, replacing the last
    line "return Haven" with your own code, or load it as a module):

        -- 1) Full loading screen (auto progress, closes itself after 4s):
        Haven.Intro({ Title = "HAVEN HUB", Subtitle = "LOADING", Duration = 4 })

        -- 2) Loading screen you control yourself:
        local intro = Haven.Intro({ Subtitle = "V2" })
        intro:SetProgress(0.4)   -- 0..1
        intro:SetProgress(1)
        intro:Close()

        -- 3) Just the animated logo inside your own GUI:
        local logo = Haven.Logo(myFrame, 120)       -- parent, size in pixels
        logo.Position = UDim2.fromScale(0.5, 0.5)
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local RED = Color3.fromRGB(240, 34, 46)
local RED_DARK = Color3.fromRGB(150, 4, 18)
local WHITE = Color3.fromRGB(255, 255, 255)
local CENTER = Vector2.new(0.5, 0.5)

local Haven = {}

local function new(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function circle(parent, scale, props)
    local f = new("Frame", {
        AnchorPoint = CENTER,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(scale, scale),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, parent)
    for k, v in pairs(props or {}) do
        f[k] = v
    end
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, f)
    return f
end

-- a ring whose stroke fades out on one side and spins forever
local function orbit(parent, scale, color, thickness, seconds, direction)
    local ring = circle(parent, scale)
    local stroke = new("UIStroke", { Color = color, Thickness = thickness }, ring)
    local gradient = new("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.55, 1),
            NumberSequenceKeypoint.new(1, 1),
        }),
    }, stroke)
    TweenService:Create(
        gradient,
        TweenInfo.new(seconds, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
        { Rotation = 360 * direction }
    ):Play()
    return ring
end

-- one white piece of the "H" (positions are 0..1 inside the red disc)
local function piece(parent, x, y, w, h, rotation)
    return new("Frame", {
        AnchorPoint = CENTER,
        Position = UDim2.fromScale(x, y),
        Size = UDim2.fromScale(w, h),
        Rotation = rotation or 0,
        BackgroundColor3 = WHITE,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, parent)
end

-- soft red halo made of stacked translucent circles
local function glow(parent)
    local holder = circle(parent, 1)
    local layers = { { 0.74, 0.78 }, { 0.84, 0.86 }, { 0.96, 0.92 }, { 1.1, 0.96 } }
    for _, layer in ipairs(layers) do
        circle(holder, layer[1], { BackgroundTransparency = layer[2], BackgroundColor3 = RED })
    end
    local pulse = new("UIScale", { Scale = 1 }, holder)
    TweenService:Create(
        pulse,
        TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        { Scale = 1.12 }
    ):Play()
end

-- dial of 60 small ticks that turns slowly
local function dial(parent)
    local holder = circle(parent, 1)
    for i = 0, 59 do
        local major = i % 5 == 0
        local length = major and 0.042 or 0.022
        local angle = math.rad(i * 6)
        local radius = 0.5 - length / 2
        new("Frame", {
            AnchorPoint = CENTER,
            Position = UDim2.fromScale(0.5 + radius * math.cos(angle), 0.5 + radius * math.sin(angle)),
            Size = UDim2.fromScale(major and 0.009 or 0.006, length),
            Rotation = i * 6 + 90,
            BackgroundColor3 = WHITE,
            BackgroundTransparency = major and 0.05 or 0.7,
            BorderSizePixel = 0,
        }, holder)
    end
    TweenService:Create(
        holder,
        TweenInfo.new(48, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
        { Rotation = 360 }
    ):Play()
end

-- Creates the animated logo. Returns the root Frame (AnchorPoint is its center).
function Haven.Logo(parent, size)
    size = size or 220

    local root = new("Frame", {
        Name = "HavenHubLogo",
        AnchorPoint = CENTER,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1,
    }, parent)
    local scale = new("UIScale", { Scale = 0 }, root)

    glow(root)
    dial(root)

    -- spinning comet arcs
    orbit(root, 0.84, WHITE, math.max(2, size * 0.013), 2, 1)
    orbit(root, 0.75, RED, math.max(2, size * 0.02), 4, -1)

    -- red disc with a white rim
    local disc = circle(root, 0.62, { BackgroundTransparency = 0, BackgroundColor3 = WHITE, ZIndex = 2 })
    new("UIGradient", { Color = ColorSequence.new(RED, RED_DARK), Rotation = 55 }, disc)
    new("UIStroke", { Color = WHITE, Thickness = math.max(1.5, size * 0.011) }, disc)
    local inner = circle(disc, 0.86, { ZIndex = 2 })
    new("UIStroke", { Color = WHITE, Transparency = 0.75, Thickness = math.max(1, size * 0.005) }, inner)

    -- the mark: two pointed towers joined by a roof, with a diamond above
    local mark = circle(disc, 1.14, { ZIndex = 3 })
    piece(mark, 0.34, 0.53, 0.10, 0.38)
    piece(mark, 0.66, 0.53, 0.10, 0.38)
    piece(mark, 0.34, 0.34, 0.0707, 0.0707, 45) -- pointed tower tops
    piece(mark, 0.66, 0.34, 0.0707, 0.0707, 45)
    piece(mark, 0.42, 0.58, 0.226, 0.085, -45) -- roof
    piece(mark, 0.58, 0.58, 0.226, 0.085, 45)
    piece(mark, 0.5, 0.5, 0.083, 0.083, 45) -- tip of the roof
    piece(mark, 0.5, 0.325, 0.065, 0.065, 45) -- diamond

    -- pop in, then breathe
    local popIn = TweenService:Create(scale, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
    popIn.Completed:Connect(function()
        TweenService:Create(
            scale,
            TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            { Scale = 1.03 }
        ):Play()
    end)
    popIn:Play()

    return root
end

-- Full-screen loading screen. Options: Title, Subtitle, Size, Duration, Parent
function Haven.Intro(options)
    options = options or {}
    local size = options.Size or 260
    local fade = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local gui = new("ScreenGui", {
        Name = "HavenHubIntro",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        DisplayOrder = 999,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, options.Parent or Players.LocalPlayer:WaitForChild("PlayerGui"))

    local dim = new("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(8, 6, 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, gui)

    local content = new("CanvasGroup", {
        AnchorPoint = CENTER,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(size + 260, size * 1.3 + 150),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
    }, gui)

    local logo = Haven.Logo(content, size)
    logo.Position = UDim2.new(0.5, 0, 0, size * 0.68)

    local function label(text, y, height, color, font)
        return new("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, y),
            Size = UDim2.new(1, 0, 0, height),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = color,
            TextSize = height,
            Font = font,
        }, content)
    end

    local function spaced(text)
        return (string.gsub(text, ".", "%0 "))
    end

    local y = size * 1.3 + 20
    label(spaced(options.Title or "HAVEN HUB"), y, 26, WHITE, Enum.Font.GothamBold)
    label(spaced(options.Subtitle or "LOADING"), y + 36, 12, RED, Enum.Font.GothamMedium)

    local bar = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, y + 64),
        Size = UDim2.fromOffset(240, 2),
        BackgroundColor3 = WHITE,
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
    }, content)
    local fill = new("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = RED,
        BorderSizePixel = 0,
    }, bar)
    local head = new("Frame", { -- bright dot at the end of the bar
        AnchorPoint = CENTER,
        Position = UDim2.fromScale(1, 0.5),
        Size = UDim2.fromOffset(6, 6),
        BackgroundColor3 = WHITE,
        BorderSizePixel = 0,
    }, fill)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, head)
    local percent = label("0%", y + 76, 11, WHITE, Enum.Font.Gotham)

    TweenService:Create(dim, fade, { BackgroundTransparency = 0.35 }):Play()
    TweenService:Create(content, fade, { GroupTransparency = 0 }):Play()

    local intro = { Gui = gui, Closed = false }

    function intro:SetProgress(value)
        value = math.clamp(value, 0, 1)
        percent.Text = math.floor(value * 100 + 0.5) .. "%"
        TweenService:Create(fill, TweenInfo.new(0.25), { Size = UDim2.fromScale(value, 1) }):Play()
    end

    function intro:Close()
        if self.Closed then
            return
        end
        self.Closed = true
        TweenService:Create(dim, fade, { BackgroundTransparency = 1 }):Play()
        local out = TweenService:Create(content, fade, { GroupTransparency = 1 })
        out.Completed:Connect(function()
            gui:Destroy()
        end)
        out:Play()
    end

    if options.Duration then
        task.spawn(function()
            local steps = 50
            for i = 1, steps do
                if intro.Closed then
                    return
                end
                intro:SetProgress(i / steps)
                task.wait(options.Duration / steps)
            end
            task.wait(0.3)
            intro:Close()
        end)
    end

    return intro
end

return Haven
