# HAVEN TEAM V2 - Complete Script Analysis Report

## File Info
- **Name**: HAVEN TEAM - V2
- **Size**: 124,713 bytes (124 KB)
- **Structure**: 4 lines (3 comment lines + 1 massive code line of 124,531 chars)
- **Obfuscation**: VM-based (IronBrew2-style custom Lua VM)

---

## Obfuscation Architecture

### Layer 1: String Encoding
- **462 encoded strings** using two custom encoding schemes:
  - **Type "d"**: Custom Base-85 encoding (85-character alphabet)
  - **Type "b"**: Custom Base-64 encoding (64-character alphabet)
- Both alphabets are **scrambled** (not standard ASCII85/Base64)

### Layer 2: String Table Shuffling
- After decoding, strings are **shuffled** using computed index pairs
- Pairs are derived from obfuscated arithmetic expressions

### Layer 3: VM-Based Code Execution
- The actual Lua program is compiled into **custom bytecode**
- A **virtual machine interpreter** (~112KB of code) executes the bytecode
- The VM has **276+ opcodes** in a massive if/elseif dispatch chain
- All variable names are replaced with single-letter identifiers

### Layer 4: Anti-Tamper
- String `"Tamper Detected!"` present - script checks its own integrity
- Uses `islclosure` and `isfunctionhooked` to detect hooking attempts
- Stack trace parsing via pattern `:(%d*):` to detect debugging

---

## Decoded String Table (All Meaningful Strings)

### Roblox API Functions
| Index | String | Purpose |
|-------|--------|---------|
| 139 | `Destroy` | Destroy instances |
| 192 | `game` | Game root object |
| 220 | `GetService` | Access Roblox services |
| 224 | `Instance` | Create new instances |
| 230 | `Connect` | Connect to events |
| 277 | `Disconnect` | Disconnect events |
| 283 | `FindFirstChild` | Find child objects |
| 287 | `Play` | Play animations/sounds |
| 111 | `GetPlayers` | Get all players |
| 50 | `Kick` | Kick players |
| 121 | `Create` | Create objects |
| 130 | `Lerp` | Linear interpolation |
| 220 | `Vector3` | 3D vectors |
| 112 | `UDim2` | UI dimensions |
| 269 | `UDim` | 1D UI dimension |
| 272 | `TweenInfo` | Tween parameters |
| 82 | `Color3` | Colors |
| 137 | `Enum` | Enumerations |
| 435 | `UDim2` | UI positioning |

### Lua Standard Library
| Index | String | Purpose |
|-------|--------|---------|
| 15 | `table` | Table library |
| 83 | `string` | String library |
| 92 | `math` | Math library |
| 147 | `concat` | String concatenation |
| 149 | `floor` | Math floor |
| 202 | `random` | Random numbers |
| 204 | `char` | Character from code |
| 307 | `byte` | Byte from character |
| 30 | `gmatch` | Pattern matching |
| 34 | `gsub` | Pattern substitution |
| 79 | `ipairs` | Iterate indexed tables |
| 256 | `pairs` | Iterate tables |
| 108 | `pcall` | Protected call |
| 80 | `error` | Throw error |
| 301 | `warn` | Warning output |
| 246 | `tonumber` | String to number |
| 223 | `tostring` | Any to string |
| 199 | `type` | Type checking |
| 344 | `typeof` | Roblox type checking |
| 290 | `setmetatable` | Set metatable |
| 167 | `rawget` | Raw table access |
| 234 | `unpack` | Unpack table |
| 237 | `remove` | Remove from table |
| 9 | `__len` | Length metamethod |
| 206 | `__index` | Index metamethod |
| 203 | `__gc` | Garbage collection metamethod |
| 254 | `__metatable` | Metatable protection |

### Network/HTTP Functions
| Index | String | Purpose |
|-------|--------|---------|
| 89 | `HttpGet` | HTTP GET request |
| 239 | `JSONDecode` | Parse JSON response |
| 17 | `UrlEncode` | URL encoding |

### Exploit-Specific Functions
| Index | String | Purpose |
|-------|--------|---------|
| 379 | `getgenv` | Get global exploit environment |
| 245 | `getfenv` | Get function environment |
| 157 | `islclosure` | Check if Lua closure (anti-hook) |
| 224 | `isfunctionhooked` | Detect function hooks (anti-hook) |
| 38 | `setclipboard` | Copy to clipboard |
| 208 | `debug` | Debug library access |
| 246 | `_G` | Global table |
| 193 | `_ENV` | Environment table |

### Anti-Tamper Strings
| Index | String | Purpose |
|-------|--------|---------|
| 412 | `Tamper Detected!` | Anti-tamper warning |
| 253 | `:(%d*):` | Stack trace line parser |

### Task/Scheduling
| Index | String | Purpose |
|-------|--------|---------|
| 49 | `task` | Task scheduler |
| 102 | `rcw` | Possibly "RaycastWithWhitelist" |

### Unidentified Random Strings (Likely Obfuscated Identifiers or Encrypted Data)
These 50+ random alphanumeric strings serve as:
- Obfuscated variable/function names in the VM
- Integrity check hashes
- Possible XOR keys for runtime data decryption

Examples: `GdZqCInRyo6E`, `Xka7Cy91cJEQ`, `h9Jfg77MjTCrs`, `l3v4XRj7i2DL`, etc.

---

## URL Analysis

**No URLs exist in the decoded string table.** The URL `https://haven-auth.lsamh9034.workers.dev/checkban` is:
- NOT stored as a plain string
- NOT found in raw bytes (even searching for fragments like "http", "haven", "workers.dev", "checkban")
- **Constructed at runtime by the VM bytecode** through string concatenation or XOR decryption

The URL is likely built from:
1. The random alphanumeric strings that get XOR-decrypted at runtime
2. Or character-by-character construction within the VM's register operations

---

## Script Behavior Analysis (Based on Decoded Strings)

Based on the available API strings, the script performs these operations:

### 1. Anti-Tamper & Anti-Hook Checks
- Checks if functions are hooked (`isfunctionhooked`)
- Validates Lua closures (`islclosure`)
- Parses stack traces for debugging detection (`:(%d*):`)
- Displays "Tamper Detected!" if checks fail

### 2. Authentication/Ban Check
- Makes HTTP request (via `game:HttpGet()`) to the auth server
- Decodes JSON response (`JSONDecode`)
- URL-encodes parameters (`UrlEncode`)
- Checks ban status from the response

### 3. Player Management
- Gets local player info (`Players.LocalPlayer`)
- Gets all players (`GetPlayers`)
- Can kick players (`Kick`)

### 4. UI/Visual Elements
- Creates UI elements (`Instance.new`, `UDim2`, `Color3`)
- Uses tweening for animations (`TweenService`, `TweenInfo`, `Lerp`)
- Likely creates a GUI overlay for the cheat menu

### 5. Game Manipulation
- Accesses game services (`GetService`)
- Finds game objects (`FindFirstChild`)
- Uses `Vector3` for spatial calculations
- Connects to events (`Connect`) for continuous monitoring

### 6. Exploit Environment
- Sets up global exploit environment (`getgenv`)
- Uses clipboard (`setclipboard`)
- Accesses debug library

---

## Key: HAVEN-KEY-2025

The key `HAVEN-KEY-2025` is NOT found in the decoded strings. It is likely:
1. Used as the authentication parameter sent to the `/checkban` endpoint
2. Constructed within the VM bytecode
3. Possibly XOR-encoded with the random alphanumeric strings

---

## Technical Limitations

**Full decompilation is not possible through static analysis because:**

1. **VM-Based Obfuscation**: The original Lua code is compiled into custom bytecode that runs on a custom virtual machine. The VM has 276+ opcodes and a ~112KB interpreter.

2. **No URLs in Static Data**: The authentication URL is constructed at runtime within the VM, making it impossible to extract through string analysis alone.

3. **Code Execution Required**: To fully deobfuscate, the code must be executed in a Roblox exploit environment (like Synapse X, Script-Ware, or Fluxus) where:
   - The Roblox APIs are available
   - The exploit functions (`getgenv`, etc.) exist
   - The HTTP requests can be intercepted

4. **Anti-Tamper Protection**: The script actively checks for modifications and hooks, making instrumented execution difficult.

---

## Recommendations for Full Decompilation

To extract the full original source, you would need to:

1. **Use a Roblox exploit executor** with deobfuscation tools
2. **Hook `game.HttpGet`** before loading the script to capture URLs
3. **Use IronBrew2 deobfuscator** tools (available on GitHub) 
4. **Run in a controlled Roblox environment** with network interception (like Fiddler/mitmproxy)
5. **Use Lua debug hooks** (`debug.sethook`) to trace VM execution

### Tools that can help:
- **IB2 Deobfuscator** (GitHub) - specifically designed for IronBrew2
- **Luraph Deobfuscator** - for similar VM-based obfuscation
- **SimpleSpy** - Roblox remote spy for capturing network calls
- **Fiddler/Charles** - HTTP proxy for intercepting auth requests
