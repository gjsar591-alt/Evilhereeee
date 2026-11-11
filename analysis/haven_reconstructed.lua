-- ============================================================================
-- HAVEN TEAM V2 - Reconstructed Source Code
-- ============================================================================
-- Original: VM-based IronBrew2 obfuscation (276+ opcodes, ~124KB)
-- Decoded:  461 strings extracted, 348 VM references resolved
-- URL:      https://haven-auth.lsamh9034.workers.dev/checkban
-- Key:      HAVEN-KEY-2025
-- Target:   Roblox "Time Bomb" map cheat
-- ============================================================================
-- NOTE: This is a RECONSTRUCTED approximation based on static analysis of the
-- obfuscated VM bytecode. The original source was compiled into custom bytecode
-- running on an embedded virtual machine, making exact recovery impossible
-- without runtime execution. The program flow and API calls are accurate;
-- variable names and exact control flow are approximated.
-- ============================================================================

----------------------------------------------
-- [1] ANTI-TAMPER / INTEGRITY CHECK MODULE
----------------------------------------------

local function checkIntegrity()
    -- Uses islclosure() to verify functions haven't been replaced with C closures
    -- Uses isfunctionhooked() to detect function hooking (e.g., from other scripts)
    -- Parses stack traces via ":(%d*):" pattern to detect debugger attachment

    local function isHooked(fn)
        if type(fn) ~= "function" then return true end
        if islclosure and not islclosure(fn) then return true end
        if isfunctionhooked and isfunctionhooked(fn) then return true end
        return false
    end

    -- Check critical game functions for hooks
    local criticalFunctions = {
        game.HttpGet,
        game.GetService,
    }

    for _, fn in pairs(criticalFunctions) do
        if isHooked(fn) then
            warn("Tamper Detected!")
            game:GetService("Players").LocalPlayer:Kick("Tamper Detected!")
            return false
        end
    end

    -- Stack trace verification via :(%d*): pattern
    local info = debug.info or debug.getinfo
    if info then
        local stackStr = tostring(info(2, "l") or "")
        local lineNum = stackStr:match(":(%d*):")
        -- Verify stack trace is consistent (not being debugged)
    end

    return true
end

----------------------------------------------
-- [2] ENVIRONMENT SETUP
----------------------------------------------

local env = getgenv()  -- Get global exploit environment

-- Initialize environment flags using obfuscated keys
-- (Original uses random alphanumeric strings like "GdZqCInRyo6E" as keys)
env["HAVEN_LOADED"] = true
env["HAVEN_VERSION"] = "V2"

-- Prevent multiple loads
if env["HAVEN_INITIALIZED"] then
    return
end
env["HAVEN_INITIALIZED"] = true

----------------------------------------------
-- [3] SERVICE REFERENCES
----------------------------------------------

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

----------------------------------------------
-- [4] AUTHENTICATION / BAN CHECK
----------------------------------------------

local AUTH_URL = "https://haven-auth.lsamh9034.workers.dev/checkban"

local function authenticate()
    -- Build authentication URL with player data
    -- URL is constructed via ~20 string concatenation operations in the VM
    -- using fragments extracted from the constant pool via H[g[N]] lookups

    local userId = tostring(LocalPlayer.UserId)
    local playerName = tostring(LocalPlayer.Name)

    -- URL-encode parameters
    local encodedUserId = HttpService:UrlEncode(userId)
    local encodedName = HttpService:UrlEncode(playerName)
    local encodedKey = HttpService:UrlEncode("HAVEN-KEY-2025")

    -- Build the full request URL
    local requestUrl = AUTH_URL
        .. "?userid=" .. encodedUserId
        .. "&username=" .. encodedName
        .. "&key=" .. encodedKey

    -- Make HTTP request
    local success, response = pcall(function()
        return game:HttpGet(requestUrl)
    end)

    if not success then
        warn("HAVEN: Auth request failed")
        return false
    end

    -- Parse JSON response
    local success2, data = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    if not success2 then
        warn("HAVEN: Failed to decode auth response")
        return false
    end

    -- Check ban status
    -- Server returns: {"banned": false} for valid users
    --                 {"banned": true, "reason": "..."} for banned users
    if data.banned == true then
        LocalPlayer:Kick("You are banned from HAVEN. Reason: " .. tostring(data.reason or "Unknown"))
        return false
    end

    return true
end

----------------------------------------------
-- [5] ANTI-TAMPER VERIFICATION
----------------------------------------------

if not checkIntegrity() then
    return
end

----------------------------------------------
-- [6] AUTHENTICATION CHECK
----------------------------------------------

local authResult = authenticate()
if not authResult then
    return
end

----------------------------------------------
-- [7] UI / GUI MODULE
----------------------------------------------

-- Creates the cheat menu GUI using Roblox UI elements
-- Uses: Instance.new, UDim2, Color3, TweenInfo, Enum.EasingStyle, etc.

local function createGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HavenGui"
    screenGui.Parent = LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false

    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "HAVEN TEAM V2"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Parent = mainFrame

    -- Tween animations for smooth UI
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    return screenGui, mainFrame
end

----------------------------------------------
-- [8] CHEAT FUNCTIONALITY (Time Bomb Map)
----------------------------------------------

local function setupCheats()
    local connections = {}

    -- Player ESP / Wallhack
    local function createESP(player)
        if player == LocalPlayer then return end

        local character = player.Character
        if not character then return end

        local head = character:FindFirstChild("Head")
        if not head then return end

        -- Create BillboardGui for ESP display
        -- Uses Vector3, Color3, UDim2 for positioning
    end

    -- Monitor all players
    for _, player in pairs(Players:GetPlayers()) do
        createESP(player)
    end

    -- Connect to new players joining
    connections[#connections + 1] = Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            task.wait(1)
            createESP(player)
        end)
    end)

    -- Game loop connection
    connections[#connections + 1] = RunService.Heartbeat:Connect(function()
        -- Update ESP positions, aimbot calculations, etc.
        -- Uses Vector3 for spatial math
        -- Uses math.random, math.floor for calculations
    end)

    -- Cleanup function
    local function cleanup()
        for _, conn in pairs(connections) do
            if conn and conn.Connected then
                conn:Disconnect()
            end
        end
    end

    return cleanup
end

----------------------------------------------
-- [9] CLIPBOARD / UTILITY FUNCTIONS
----------------------------------------------

-- The script uses setclipboard() to copy data
-- Uses getfenv() and _G/_ENV for environment manipulation
-- Uses table.remove, table.concat for data management
-- Uses string.byte, string.char, string.gsub, string.gmatch for string ops

----------------------------------------------
-- [10] MAIN EXECUTION
----------------------------------------------

-- Create GUI
local gui, frame = createGui()

-- Setup cheats
local cleanupCheats = setupCheats()

-- Metatable protection
-- Uses setmetatable with __metatable, __index, __len, __gc metamethods
-- to protect internal state from external tampering

local protectedState = setmetatable({}, {
    __metatable = "HAVEN Protected",
    __index = function(self, key)
        return rawget(self, key)
    end,
})

-- Copy key info to clipboard
pcall(function()
    setclipboard("HAVEN TEAM V2 - Loaded Successfully")
end)

warn("HAVEN TEAM V2 loaded successfully!")

----------------------------------------------
-- DECODED STRING TABLE REFERENCE
----------------------------------------------
--[[
All 461 decoded strings from the obfuscated script are available in:
  analysis/haven_complete_decode.json

Key API strings used (348 VM references):
  - game (7x), GetService (1x)
  - HttpGet (3x), JSONDecode (3x), UrlEncode (7x)
  - tostring (10x), pcall (5x), pairs (4x)
  - Connect (4x), Enum (7x), debug (5x)
  - table (3x), string (4x), math (5x)
  - islclosure (2x), isfunctionhooked (1x)
  - Kick (2x), Destroy (2x), type (2x)
  - setmetatable (2x), rawget (2x), :(%d*): (3x)
  - tonumber (3x), getfenv (2x), random (2x)
  - setclipboard, warn, GetPlayers, FindFirstChild
  - Vector3, UDim2, TweenInfo, Instance, Create, Play
  - 89 random alphanumeric identifier strings (obfuscated keys)

Auth server response format:
  {"banned": false}           -- User is allowed
  {"banned": true, "reason":} -- User is banned

VM Architecture:
  - Entry point: o(4927100, {}) -- initial VM state
  - 276+ opcodes in flattened control flow dispatcher
  - Custom Base-85 + Base-64 string encoding
  - 461 encoded strings, shuffled after decoding
  - String accessor: w(x) = j[x + 34172]
--]]
