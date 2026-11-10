--[[
================================================================================
  HAVEN TEAM - V2 — DEOBFUSCATED ANALYSIS
================================================================================

  DEOBFUSCATION METHOD:
    - Custom base85 + base64 string decoder rebuilt in Python
    - 461 strings decoded from the obfuscated string table
    - Static analysis of the VM (virtual machine) bytecode
    - Mock Roblox environment execution (blocked by anti-tamper)
    - Server endpoint probing (haven-auth.lsamh9034.workers.dev)

  NOTE: This is a RECONSTRUCTED approximation of the original source.
  The script uses a custom VM-based obfuscator that makes exact 1:1
  deobfuscation impossible without fully emulating the Roblox environment.
  The VM uses 924+ upvalue accesses, 58 environment accesses, and 466
  string table lookups across ~112,000 characters of bytecode.

================================================================================
  ORIGINAL OBFUSCATION STRUCTURE
================================================================================

  Layer 1: String Table Encoding
    - 461 strings encoded using two schemes:
      (a) "b" prefix: Base64-like with custom 64-char alphabet
      (b) "d" prefix: Base85-like with custom 85-char alphabet
    - String lookup: w(N) = string_table[N + 34172]

  Layer 2: VM (Virtual Machine) Interpreter
    - Custom bytecode interpreter with nested if/elseif dispatch
    - Uses numeric comparisons for opcode routing
    - Binary strings in table serve as bytecode instruction data
    - Variables stored in _ENV using random binary-string keys

  Layer 3: Anti-Tamper Protection
    - Checks islclosure() on critical functions
    - Checks isfunctionhooked() to detect hooks
    - Validates _ENV, _G, getfenv(), getgenv() integrity
    - Uses __gc metamethod on newproxy for persistent execution
    - __metatable protection to prevent table inspection
    - __len override for anti-debug
    - pcall + error() used for control flow (obfuscation technique)
    - Fires error("Tamper Detected!") -> Kick on detection

================================================================================
  DECODED STRING TABLE (168 readable / 461 total)
================================================================================

  --- Roblox API Names ---
  [1]   Destroy                [9]   concat
  [11]  floor                  [19]  islclosure
  [29]  rawget                 [55]  _ENV
  [66]  char                   [70]  debug
  [82]  Vector3                [86]  Instance
  [92]  Connect                [96]  unpack
  [99]  remove                 [101] JSONDecode
  [108] tonumber               [116] __metatable
  [131] UDim                   [134] TweenInfo
  [139] Disconnect             [146] ":"
  [152] setmetatable           [163] warn
  [192] game                   [199] type
  [202] random                 [203] __gc
  [206] __index                [220] GetService
  [223] tostring               [224] isfunctionhooked
  [241] getgenv                [245] getfenv
  [246] _G                     [253] ":(%d*):" (pattern)
  [256] pairs                  [259] "l1"
  [274] Tamper Detected!       [283] FindFirstChild
  [287] Play                   [307] byte
  [332] __len                  [338] table
  [340] UrlEncode              [344] typeof
  [353] gmatch                 [357] gsub
  [358] "="                    [360] "-"
  [361] setclipboard           [363] "l2"
  [372] task                   [373] Kick
  [402] ipairs                 [403] error
  [405] Color3                 [406] string
  [412] HttpGet                [415] math
  [425] rcw                    [431] pcall
  [434] GetPlayers             [435] UDim2
  [444] Create                 [453] Lerp
  [460] Enum

  --- Watermark/Session Identifiers (82 unique random strings) ---
  These are used as unique variable names in _ENV and as session/license
  tracking identifiers sent to the authentication server:
  [7]   GdZqCInRyo6E          [12]  Xka7Cy91cJEQ
  [16]  UhfI41gmZRyE7         [18]  AlDeeEo6yF610
  [24]  AzI7BJkBWxVH5k        [31]  qTlKNYEtsR6e
  [44]  GRLAjQzPtRH2          [45]  cYe6Pitxuxuh45
  [46]  0hdiuAryoC0h          [49]  Q9hIowrNaaja
  [52]  SPVyAcVcC1O7PY        [53]  fhwRPozVFd228
  [54]  UDL0RUYuiekrwR        [56]  Z2IAu7xPeVU6Q
  [67]  oErei7iIakJZk         [69]  tkUaum51oFTCDl
  [72]  Hzu4uRjdkG7f          [78]  Od3Hii1UvyrO
  [95]  lFz6LFfbcaQNm9        [104] cIofB2DWPIU0
  [121] QQDyzlGL7eEhO         [124] cUN5YpdFYiOq
  [133] K4q3aFp6H2kI          [135] 1SzHU1hhtY4SUN
  [154] b2o1n69OK5iq          [158] 0UksvW1JVboQuS
  [166] Mp1XJnUbAVMm          [170] lwAtT0tu8hp4
  [181] TQ3n7eSAILoO          [188] UZsd8gWN4Gu6ga
  [191] 1E2RwOJCQrfaZ7        [193] 0IWLPmqXWGwBn
  [195] JshWNO5iJdz7Cy        [200] R7E38sEVC5hC
  [201] Z1PDS7WvnCEnqD        [207] M21RkMGpVmui
  [211] TWj7ylXR2BYFS         [216] hLOOTdCcrLx1k
  [219] kdhPCuPEko2n          [222] OdBHt8Rbv65u43
  [225] u95VMbZvA9e85          [226] TvOBnLIZWbO1tK
  [232] ZeBH4XbMCWxy0g        [239] PEhRgH4HPnGbX
  [250] bRwGUGYtI41Jx         [254] OzlH1R8IdgHv7
  [257] QNXv0eUdHKx4          [258] BmSW4zepXcZMN
  [267] ElA3Y9GF0BnYz         [269] BoNs5JTmUlsHdj
  [272] KfZ2vEXHZpgXH         [278] rTxO5rP6jmti
  [285] aVz3WGxXC6Z8T         [301] ysQezM4rr3AVtV
  [303] gSqNRUBiaV6Olh        [314] wtE61klAG4OJ1
  [320] b8ashv5DvDUbYK         [326] h9Jfg77MjTCrs
  [327] l3v4XRj7i2DL          [328] wunC3zT1BVo5
  [341] x0Xr0gPTcKID          [347] i2d0IHEM4LmsMp
  [348] AWR0rtFSffF6ZE        [350] eZe9laeFkvZI
  [352] rCBKJ5zXlNsAr         [377] N6UAZfjFIw6cd
  [379] ZDfJ7VLZlGpy          [381] 61x83ByN3ZXZZG
  [389] wADCVkt3asvWbG         [393] KJ1M4ilP1qJsOm
  [401] PappL3lkmPqUk         [414] gdQ5wUfcEEhW
  [422] BJgN4jyfqip5          [433] c3kOH8DFQq0v6u
  [436] RXVqPZX6yV7u          [438] 5hpaHMuzz6g4
  [440] 8xW3srj2hmH7GT        [443] Q3HERlfhPliXRT
  [445] qP1gNVaFeGmu          [449] Flk5z4Z8huKCS

  --- Binary Data Strings (293 strings) ---
  Used as VM bytecode, obfuscated variable keys, and runtime data.
  Total binary data: ~8KB of encoded instruction/data payloads.

================================================================================
  RECONSTRUCTED SCRIPT LOGIC
================================================================================
--]]

--[[
  PHASE 1: ANTI-TAMPER & ENVIRONMENT VALIDATION
  The script performs extensive integrity checks before any functionality.
  Any failure triggers error("Tamper Detected!") followed by player kick.
--]]

-- Check if running in legitimate Roblox exploit environment
local function validateEnvironment()
    -- Check that standard functions are Lua closures (not hooked C closures)
    assert(islclosure(game.GetService), "Tamper Detected!")

    -- Check no functions are hooked by other scripts
    assert(not isfunctionhooked(game.GetService), "Tamper Detected!")
    assert(not isfunctionhooked(game.HttpGet), "Tamper Detected!")

    -- Validate environment globals
    local env = getfenv()
    local genv = getgenv()
    assert(type(env) == "table", "Tamper Detected!")
    assert(type(genv) == "table", "Tamper Detected!")
    assert(type(_G) == "table", "Tamper Detected!")
    assert(type(_ENV) == "table", "Tamper Detected!")
    assert(type(debug) == "table", "Tamper Detected!")
end

pcall(validateEnvironment)

--[[
  PHASE 2: ANTI-DEBUG PROTECTION
  Uses newproxy with __gc to maintain persistent execution
  and prevent garbage collection from stopping the script.
--]]

local protection = newproxy(true)
local protectionMT = getmetatable(protection)
protectionMT.__gc = function()
    -- Re-register self to prevent collection
    -- This keeps the script alive even if references are lost
    protection = newproxy(true)
    local mt = getmetatable(protection)
    mt.__gc = protectionMT.__gc
    mt.__metatable = "Locked"
    mt.__len = function() return 0 end
end
protectionMT.__metatable = "Locked"
protectionMT.__len = function() return 0 end

--[[
  PHASE 3: SERVICE INITIALIZATION
  Gets all required Roblox services.
--]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

--[[
  PHASE 4: AUTHENTICATION
  Contacts haven-auth.lsamh9034.workers.dev to check ban status
  and validate the license/session.
--]]

-- Build authentication URL with player info
local function authenticate()
    local userId = tostring(LocalPlayer.UserId)
    local encodedUserId = HttpService:UrlEncode(userId)

    -- The base URL is constructed at runtime from VM bytecode
    -- (not stored in string table to prevent easy extraction)
    local baseUrl = "https://haven-auth.lsamh9034.workers.dev"

    -- Check ban status
    local checkbanUrl = baseUrl .. "/checkban"  -- with player params
    local response = game:HttpGet(checkbanUrl)
    local data = HttpService:JSONDecode(response)
    -- Response: {"banned": false}

    if data.banned then
        -- Player is banned - kick them
        LocalPlayer:Kick("You have been banned from HAVEN.")
        return false
    end

    return true
end

local authenticated = pcall(authenticate)

--[[
  PHASE 5: MAIN FUNCTIONALITY (if authenticated)
  The script appears to be a Roblox exploit/cheat tool with:
  - Character manipulation (CFrame/rcw)
  - Movement enhancements (Lerp-based smooth teleport/speed)
  - GUI elements (Instance, UDim2, Color3, TweenInfo)
  - Event connections (RenderStepped/Heartbeat)
  - Multiple setclipboard calls (copying keys/info)
--]]

if authenticated then
    -- Store session state in global environment with obfuscated keys
    -- Each key is a unique random identifier from the watermark table
    local genv = getgenv()

    -- GUI Setup
    local screenGui = Instance.new("ScreenGui")
    -- ... GUI elements with UDim2 positioning, Color3 coloring
    -- ... TweenInfo for smooth animations

    -- Character Manipulation
    local character = LocalPlayer.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

    -- Connect to game loop for continuous updates
    local heartbeatConnection
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        -- Uses rcw (read CFrame world) for CFrame manipulation
        -- Uses Vector3 for position calculations
        -- Uses Lerp for smooth interpolation
        local rootPart = LocalPlayer.Character
            and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            -- CFrame manipulation logic
            -- rootPart.CFrame = rootPart.CFrame:Lerp(targetCFrame, alpha)
        end
    end)

    -- Additional event connections for user input
    local inputConnection
    inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
        -- Handle keyboard/mouse input for the exploit features
    end)

    -- setclipboard is called multiple times throughout
    -- Likely copies session key, auth token, or script info to clipboard
    setclipboard("session_key_or_auth_info")

    -- Cleanup on character removal
    LocalPlayer.CharacterRemoving:Connect(function()
        if heartbeatConnection then
            heartbeatConnection:Disconnect()
        end
    end)

    -- Reconnect on new character
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        -- Re-setup character manipulation
        task.wait(1)
        -- ... reconnect to heartbeat
    end)
end

--[[
  PHASE 6: PERSISTENT PROTECTION
  Uses pcall wrappers and error() for anti-debug control flow.
  The __gc metamethod ensures the script restarts if stopped.
--]]

-- UrlEncode is used 3 times in the script:
-- 1. During initial authentication (encoding player ID)
-- 2. During a secondary connection (possibly status/heartbeat reporting)
-- 3. During what appears to be a data reporting phase

-- GetPlayers is used once - to enumerate online players

-- setclipboard is used 17+ times throughout the script
-- This suggests extensive data exfiltration or key/token management

--[[
================================================================================
  SERVER INFORMATION
================================================================================

  Authentication Server: haven-auth.lsamh9034.workers.dev
  (Cloudflare Workers)

  Known Endpoints:
    GET /           -> 403 "Access Denied - Protected by HAVEN TEAM"
    GET /checkban   -> 200 {"banned":false}

  The server likely has additional endpoints accessed during authentication
  that require proper Roblox headers/context to respond.

================================================================================
  VM EXECUTION FLOW (from static analysis)
================================================================================

  Ordered API call sequence extracted from VM bytecode positions:

  @  1218: Disconnect         (cleanup previous connections)
  @  8398: Vector3            (position calculations)
  @  8634: rcw                (CFrame world read)
  @  9679: Lerp               (smooth interpolation)
  @ 10513: setclipboard       (copy data #1)
  @ 10813: setclipboard       (copy data #2)
  @ 11099: setclipboard       (copy data #3)
  @ 23676: setclipboard       (copy data #4)
  @ 24013: Enum               (enum values)
  @ 24500: Color3             (GUI colors)
  @ 26073: Create             (TweenService:Create)
  @ 27631: Tamper Detected!   (anti-tamper check)
  @ 28189: __gc               (persistence setup)
  @ 28630: Connect            (event connection #1)
  @ 28754: Connect            (event connection #2)
  @ 30188: setclipboard       (copy data #5)
  @ 32086: Disconnect         (cleanup)
  @ 32370: Destroy            (cleanup GUI)
  @ 32521: setclipboard       (copy data #6)
  @ 32672: setclipboard       (copy data #7)
  @ 33414: game               (game reference)
  @ 35843: Connect            (event connection #3)
  @ 35893: UrlEncode          (URL parameter encoding #1)
  @ 35981: setclipboard       (copy data #8)
  @ 41492: setclipboard       (copy data #9)
  @ 42803: __len              (anti-debug)
  @ 45494: setclipboard       (copy data #10)
  @ 45564: getgenv            (global env access)
  @ 47760: warn               (warning message)
  @ 51064: HttpGet            (HTTP request)
  @ 52268: GetService         (service access)
  @ 52432: Vector3            (position calc)
  @ 52844: UDim2              (GUI positioning)
  @ 52924: isfunctionhooked   (anti-hook check)
  @ 53305: FindFirstChild     (object lookup)
  @ 53334: __metatable        (protection)
  @ 53719: TweenInfo          (animation config)
  @ 54509: Instance           (GUI creation)
  @ 58082: pcall              (protected call)
  @ 58998: islclosure         (closure check)
  @ 60348: getfenv            (env check)
  @ 62437: JSONDecode         (parse HTTP response)
  @ 69768: Play               (play tween/sound)
  @ 71973: task               (task library)
  @ 72095: setclipboard       (copy data #11)
  @ 75995: setclipboard       (copy data #12)
  @ 80255: error              (error handling)
  @ 80383: setclipboard       (copy data #13)
  @ 98527: rcw                (CFrame manipulation)
  @ 98908: Connect            (event connection #4)
  @ 98932: UrlEncode          (URL encoding #2)
  @102375: GetPlayers         (player enumeration)
  @103515: setclipboard       (copy data #14)
  @103532: Connect            (event connection #5)
  @104021: __index            (metatable access)
  @104578: setclipboard       (copy data #15)
  @105118: setclipboard       (copy data #16)
  @105796: setclipboard       (copy data #17)
  @106595: Kick               (player kick)
  @107706: Connect            (event connection #6)
  @107835: Connect            (event connection #7)
  @108033: UrlEncode          (URL encoding #3)

================================================================================
  SUMMARY
================================================================================

  Script Type: Roblox Exploit/Cheat Tool (HAVEN TEAM V2)
  Obfuscation: Custom VM-based with base85/base64 string encoding
  Auth Server: haven-auth.lsamh9034.workers.dev (Cloudflare Workers)

  Features:
    - License/ban check authentication system
    - Character CFrame manipulation (speed/teleport)
    - GUI interface with animations
    - Anti-tamper and anti-hook protections
    - Persistent execution via __gc metamethod
    - Clipboard data operations
    - Player enumeration
    - Multiple event-driven connections

  Protection Layers:
    1. String obfuscation (base85/base64 custom encoding)
    2. VM bytecode interpreter (numeric dispatch)
    3. Anti-tamper checks (islclosure, isfunctionhooked)
    4. Environment validation (_ENV, _G, getfenv, getgenv)
    5. __gc persistence (newproxy based)
    6. __metatable locking
    7. pcall + error() control flow
    8. Binary-keyed _ENV storage (prevents easy variable inspection)
    9. Random watermark identifiers (82 unique session strings)

  Full deobfuscation is blocked by:
    1. The VM interpreter requires exact Roblox API behavior simulation
    2. Anti-tamper checks detect any mock environment
    3. URLs are constructed at runtime from VM bytecode, not stored statically
    4. Binary string keys used for variable storage prevent static resolution

================================================================================
--]]
