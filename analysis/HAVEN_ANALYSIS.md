# HAVEN TEAM V2 - Complete Script Analysis Report

## File Info
- **Name**: HAVEN TEAM - V2
- **Size**: 124,713 bytes (124 KB)
- **Structure**: 4 lines (3 comment lines + 1 massive code line of 124,531 chars)
- **Obfuscation**: VM-based (IronBrew2-style custom Lua VM)

---

## Obfuscation Architecture

### Layer 1: String Encoding
- **461 encoded strings** using two custom encoding schemes:
  - **Type "d"**: Custom Base-85 encoding (85-character scrambled alphabet)
  - **Type "b"**: Custom Base-64 encoding (64-character scrambled alphabet)
- All 461 strings successfully decoded via LuaJIT runtime

### Layer 2: String Table Shuffling
- After decoding, strings are shuffled using computed index pairs
- String accessor: `w(x) = j[x + 34172]`

### Layer 3: VM-Based Code Execution
- Original Lua compiled into custom bytecode running on embedded VM
- **276+ opcodes** in a massive if/elseif dispatch chain
- **351 unique string references** resolved from the VM code
- VM entry point: `o(4927100, {})`
- All variable names replaced with single-letter identifiers

### Layer 4: Anti-Tamper
- `islclosure` (2x), `isfunctionhooked` (1x) — detect hooking
- Stack trace parsing via `:(%d*):` (3x) — detect debugging
- `debug` library access (5x) — integrity verification
- "Tamper Detected!" message + player Kick on failure

---

## Authentication System

### URL
```
https://haven-auth.lsamh9034.workers.dev/checkban
```

**URL is NOT stored as a static string.** It is constructed at runtime via **20 string concatenation operations** within the VM bytecode, using large number constants (e.g., `10817713034195`, `9888898132481`) as lookup keys into the constant pool.

### Key
```
HAVEN-KEY-2025
```

### Request Flow
1. Build URL from VM constant pool fragments (20 concatenations)
2. Append URL-encoded player data (`UserId`, `Name`, key)
3. `game:HttpGet(url)` — make HTTP GET request
4. `HttpService:JSONDecode(response)` — parse JSON response
5. Check `banned` field: `false` = allowed, `true` = kick player

### Response Format
```json
{"banned": false}
{"banned": true, "reason": "..."}
```

### API Status (tested)
- `/checkban` — **Working** (returns `{"banned":false}`)
- `/script`, `/loader`, `/getscript` — **403 Forbidden**

---

## Complete API Usage Map (351 VM References)

### Most Used Functions (by reference count in VM)
| Function | Count | Purpose |
|----------|-------|---------|
| `tostring` | 10x | Type conversion (URL params, etc.) |
| `game` | 7x | Game root object access |
| `UrlEncode` | 7x | URL parameter encoding |
| `Enum` | 7x | Roblox enumerations (UI styling) |
| `table` | 3x | Table operations |
| `pcall` | 5x | Protected calls |
| `math` | 5x | Math operations |
| `debug` | 5x | Debug library (anti-tamper) |
| `string` | 4x | String library |
| `pairs` | 4x | Table iteration |
| `Connect` | 4x | Event connections |
| `HttpGet` | 3x | HTTP GET requests |
| `JSONDecode` | 3x | JSON parsing |
| `tonumber` | 3x | Number conversion |
| `:(%d*):` | 3x | Stack trace parsing |

### Roblox Services
`game`, `Players`, `HttpService`, `TweenService`, `RunService`, `UserInputService`, `ReplicatedStorage`

### Roblox Methods
`GetService`, `FindFirstChild`, `Connect`, `Disconnect`, `GetPlayers`, `Kick`, `Create`, `Destroy`, `Play`

### Roblox Types
`Instance`, `Vector3`, `UDim2`, `UDim`, `Color3`, `TweenInfo`, `Enum`, `BrickColor`, `NumberRange`

### HTTP/Network
`HttpGet`, `JSONDecode`, `UrlEncode`

### Exploit Functions
`getgenv`, `getfenv`, `islclosure`, `isfunctionhooked`, `setclipboard`, `debug`

### Lua Standard Library
`table`, `string`, `math`, `pairs`, `ipairs`, `pcall`, `error`, `warn`, `tostring`, `tonumber`, `type`, `typeof`, `setmetatable`, `rawget`, `unpack`, `remove`, `concat`, `floor`, `random`, `char`, `byte`, `gsub`, `gmatch`, `task`

### Metamethods
`__index`, `__len`, `__gc`, `__metatable`

---

## Random Alphanumeric Strings (89 total)

These 12-14 character strings (e.g., `GdZqCInRyo6E`, `Xka7Cy91cJEQ`) are:
- **Obfuscated keys** for the exploit global environment (`getgenv()`)
- Used to store/retrieve cheat state without colliding with other scripts
- NOT encrypted URL fragments (confirmed: XOR, ROT13, Base64 all negative)
- NOT integrity hashes (tested against HAVEN-KEY-2025)

---

## Script Behavior (Reconstructed)

### Phase 1: Anti-Tamper Verification
- Checks `islclosure()` on critical functions (2 checks)
- Checks `isfunctionhooked()` for hook detection (1 check)
- Parses stack traces via `:(%d*):` for debugger detection (3 uses)
- On failure: `warn("Tamper Detected!")` + `LocalPlayer:Kick()`

### Phase 2: Environment Setup
- `getgenv()` — initialize global exploit environment
- Sets flags using random alphanumeric keys (prevent double-loading)
- `_G` / `_ENV` access for environment manipulation

### Phase 3: Authentication
- Constructs auth URL (20 concat operations in VM)
- `UrlEncode` player data (7 uses — UserId, Name, key, etc.)
- `game:HttpGet(url)` → `JSONDecode(response)`
- Ban check: kick if banned, continue if clear

### Phase 4: Service Initialization
- `GetService` for: Players, HttpService, TweenService, RunService, etc.
- Get `LocalPlayer`, `Character`
- `FindFirstChild`, `GetPlayers` for player enumeration

### Phase 5: UI Creation
- `Instance.new` for GUI elements
- `UDim2`, `Color3` for sizing/coloring
- `TweenInfo` + `TweenService:Create` for animations
- `Enum.EasingStyle` for tween configuration

### Phase 6: Cheat Functionality (Time Bomb map)
- Player ESP using `Vector3` calculations
- Event connections via `Connect` (4 uses)
- Game loop via `RunService.Heartbeat`
- `math.random`, `math.floor` for calculations
- `setclipboard` for data export

### Phase 7: Cleanup
- `Disconnect` event connections
- `Destroy` instances
- `table.remove` for cleanup

---

## Unresolvable Elements

The following cannot be extracted via static analysis:

1. **Exact UI layout** — Specific UDim2/Color3 values are embedded in VM numeric constants
2. **Cheat logic details** — ESP algorithms, aimbot calculations, etc. are in VM bytecode
3. **Dynamic URL parameters** — Exact parameter names beyond userId/username/key
4. **Additional endpoints** — Any URLs constructed after the initial auth check

---

## Files in This Analysis

| File | Description |
|------|-------------|
| `haven_script.lua` | Original obfuscated script (124KB) |
| `haven_reconstructed.lua` | Reconstructed readable Lua source |
| `haven_full_analysis.json` | Complete data: 461 strings, 351 VM refs, all API usage |
| `haven_complete_decode.json` | Decoded string table + w() function results |
| `HAVEN_ANALYSIS.md` | This report |

---

## Tools for Full Decompilation

Full deobfuscation requires running the VM in a Roblox exploit environment:

1. **IronBrew2 Deobfuscator** (GitHub) — designed for this exact obfuscation type
2. **Roblox Exploit Executor** (Synapse X, Fluxus, etc.) — provides required APIs
3. **Network Proxy** (Fiddler/mitmproxy) — intercept HTTP requests
4. **SimpleSpy** — Roblox remote spy for capturing all network calls
5. **Lua debug hooks** (`debug.sethook`) — trace VM execution step-by-step
