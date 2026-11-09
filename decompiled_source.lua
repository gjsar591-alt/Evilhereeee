-- ============================================================================
-- HAVEN TEAM V2 - السورس الأصلي الكامل المعاد بناؤه
-- Complete Reconstructed Source Code (Deep VM Trace)
-- ============================================================================
-- Strings: 461 total, 157 readable
-- VM Operations: 326 ops in 63 blocks
-- State transitions: 95, Conditional: 25
-- Entry state: 4015136
-- ============================================================================

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  1. جدول السلاسل المصنف (Categorized String Table)        ║
-- ╚══════════════════════════════════════════════════════════════╝

-- [Exploit API] (6 entries)
--   j[20] = "islclosure"  -- w(-34152)
--   j[30] = "rawget"  -- w(-34142)
--   j[153] = "setmetatable"  -- w(-34019)
--   j[225] = "isfunctionhooked"  -- w(-33947)
--   j[362] = "setclipboard"  -- w(-33810)
--   j[413] = "HttpGet"  -- w(-33759)

-- [Anti-Tamper Messages] (1 entries)
--   j[275] = "Tamper Detected!"  -- w(-33897)

-- [Network API] (1 entries)
--   j[341] = "UrlEncode"  -- w(-33831)

-- [Roblox Services] (1 entries)
--   j[193] = "game"  -- w(-33979)

-- [Roblox Methods] (9 entries)
--   j[2] = "Destroy"  -- w(-34170)
--   j[93] = "Connect"  -- w(-34079)
--   j[140] = "Disconnect"  -- w(-34032)
--   j[221] = "GetService"  -- w(-33951)
--   j[284] = "FindFirstChild"  -- w(-33888)
--   j[288] = "Play"  -- w(-33884)
--   j[374] = "Kick"  -- w(-33798)
--   j[435] = "GetPlayers"  -- w(-33737)
--   j[445] = "Create"  -- w(-33727)

-- [Roblox Types] (7 entries)
--   j[83] = "Vector3"  -- w(-34089)
--   j[87] = "Instance"  -- w(-34085)
--   j[132] = "UDim"  -- w(-34040)
--   j[135] = "TweenInfo"  -- w(-34037)
--   j[406] = "Color3"  -- w(-33766)
--   j[436] = "UDim2"  -- w(-33736)
--   j[461] = "Enum"  -- w(-33711)

-- [Lua Standard Library] (14 entries)
--   j[97] = "unpack"  -- w(-34075)
--   j[109] = "tonumber"  -- w(-34063)
--   j[164] = "warn"  -- w(-34008)
--   j[200] = "type"  -- w(-33972)
--   j[224] = "tostring"  -- w(-33948)
--   j[257] = "pairs"  -- w(-33915)
--   j[339] = "table"  -- w(-33833)
--   j[345] = "typeof"  -- w(-33827)
--   j[373] = "task"  -- w(-33799)
--   j[403] = "ipairs"  -- w(-33769)
--   j[404] = "error"  -- w(-33768)
--   j[407] = "string"  -- w(-33765)
--   j[416] = "math"  -- w(-33756)
--   j[432] = "pcall"  -- w(-33740)

-- [Metatable Keys] (3 entries)
--   j[204] = "__gc"  -- w(-33968)
--   j[207] = "__index"  -- w(-33965)
--   j[333] = "__len"  -- w(-33839)

-- [String/Math Operations] (6 entries)
--   j[10] = "concat"  -- w(-34162)
--   j[12] = "floor"  -- w(-34160)
--   j[67] = "char"  -- w(-34105)
--   j[203] = "random"  -- w(-33969)
--   j[308] = "byte"  -- w(-33864)
--   j[358] = "gsub"  -- w(-33814)

-- [VM Internal Keys] (41 entries)
--   j[29] = "p3DUdOQM"  -- w(-34143)
--   j[32] = "qTlKNYEtsR6e"  -- w(-34140)
--   j[46] = "cYe6Pitxuxuh45"  -- w(-34126)
--   j[47] = "0hdiuAryoC0h"  -- w(-34125)
--   j[68] = "oErei7iIakJZk"  -- w(-34104)
--   j[70] = "tkUaum51oFTCDl"  -- w(-34102)
--   j[72] = "yQgppOqWQmbQXX"  -- w(-34100)
--   j[96] = "lFz6LFfbcaQNm9"  -- w(-34076)
--   j[105] = "cIofB2DWPIQM"  -- w(-34067)
--   j[110] = "bdGAHArOOhwc"  -- w(-34062)
--   j[125] = "cUN5YpdFYiOq"  -- w(-34047)
--   j[136] = "1SzHU1hhtY4SUN"  -- w(-34036)
--   j[155] = "b2o1n69OK5iq"  -- w(-34017)
--   j[159] = "0UksvW1JVboQuS"  -- w(-34013)
--   j[171] = "lwAtT0tu8hp4"  -- w(-34001)
--   j[192] = "1E2RwOJCQrfaZ7"  -- w(-33980)
--   j[194] = "0IWLPmqXWGwBn"  -- w(-33978)
--   j[217] = "hLOOTdCcrLx1k"  -- w(-33955)
--   j[220] = "kdhPCuPEko2n"  -- w(-33952)
--   j[226] = "u95VMbZvA9e85"  -- w(-33946)
--   j[251] = "bRwGUGYtI41Jx"  -- w(-33921)
--   j[279] = "rTxO5rP6jmti"  -- w(-33893)
--   j[286] = "aVz3WGxXC6Z8T"  -- w(-33886)
--   j[302] = "ysQezM4rr3AVtV"  -- w(-33870)
--   j[304] = "gSqNRUBiaV6Olh"  -- w(-33868)
--   j[315] = "wtE61klAG4OJ1"  -- w(-33857)
--   j[321] = "b8ashv5DvDUbYK"  -- w(-33851)
--   j[327] = "h9Jfg77MjTCrs"  -- w(-33845)
--   j[328] = "l3v4XRj7i2DL"  -- w(-33844)
--   j[329] = "wunC3zT1BVo5"  -- w(-33843)
--   j[342] = "x0Xr0gPTcKID"  -- w(-33830)
--   j[348] = "i2d0IHEM4LmsMp"  -- w(-33824)
--   j[352] = "oyJrifjEJZLi"  -- w(-33820)
--   j[353] = "rCBKJ5zXlNsAr"  -- w(-33819)
--   j[382] = "61x83ByN3ZXZZG"  -- w(-33790)
--   j[390] = "wADCVkt3asvWbG"  -- w(-33782)
--   j[415] = "gdQ5wUfcEEhW"  -- w(-33757)
--   j[434] = "c3kOH8DFQq0v6u"  -- w(-33738)
--   j[439] = "5hpaHMuzz6g4"  -- w(-33733)
--   j[441] = "8xW3srj2hmH7GT"  -- w(-33731)
--   j[446] = "qP1gNVaFeGmu"  -- w(-33726)

-- [Other Identifiers] (60 entries)
--   j[3] = "x"  -- w(-34169)
--   j[8] = "GdZqCInRyo6E"  -- w(-34164)
--   j[13] = "Xka7Cy91cJEQ"  -- w(-34159)
--   j[17] = "UhfI41gmZRyE7"  -- w(-34155)
--   j[18] = "+K^I"  -- w(-34154)
--   j[19] = "AlDeeEo6yF610"  -- w(-34153)
--   j[23] = "tuGv"  -- w(-34149)
--   j[25] = "AzI7BJkBWxVH5k"  -- w(-34147)
--   j[45] = "GRLAjQzPtRH2"  -- w(-34127)
--   j[49] = "o"  -- w(-34123)
--   j[50] = "Q9hIowrNaaja"  -- w(-34122)
--   j[53] = "SPVyAcVcC1O7PY"  -- w(-34119)
--   j[55] = "UDL0RUYuiekrwR"  -- w(-34117)
--   j[56] = "_ENV"  -- w(-34116)
--   j[57] = "Z2IAu7xPeVU6Q"  -- w(-34115)
--   j[61] = "EFLEIqjsJWgGf"  -- w(-34111)
--   j[63] = "u"  -- w(-34109)
--   j[71] = "debug"  -- w(-34101)
--   j[73] = "Hzu4uRjdkG7f"  -- w(-34099)
--   j[78] = "y"  -- w(-34094)
--   j[79] = "Od3Hii1UvyrO"  -- w(-34093)
--   j[82] = "mqV"  -- w(-34090)
--   j[100] = "remove"  -- w(-34072)
--   j[114] = "J"  -- w(-34058)
--   j[122] = "QQDyzlGL7eEhO"  -- w(-34050)
--   j[134] = "K4q3aFp6H2kI"  -- w(-34038)
--   j[165] = "I"  -- w(-34007)
--   j[167] = "Mp1XJnUbAVMm"  -- w(-34005)
--   j[170] = "xZF0x"  -- w(-34002)
--   j[172] = "VaxxFshwomfbV"  -- w(-34000)
--   j[182] = "TQ3n7eSAILoO"  -- w(-33990)
--   j[189] = "UZsd8gWN4Gu6ga"  -- w(-33983)
--   j[196] = "JshWNO5iJdz7Cy"  -- w(-33976)
--   j[198] = "W"  -- w(-33974)
--   j[201] = "R7E38sEVC5hC"  -- w(-33971)
--   j[202] = "Z1PDS7WvnCEnqD"  -- w(-33970)
--   j[208] = "M21RkMGpVmui"  -- w(-33964)
--   j[212] = "TWj7ylXR2BYFS"  -- w(-33960)
--   j[223] = "OdBHt8Rbv65u43"  -- w(-33949)
--   j[227] = "TvOBnLIZWbO1tK"  -- w(-33945)
--   j[231] = "yQ6AjG"  -- w(-33941)
--   j[233] = "ZeBH4XbMCWxy0g"  -- w(-33939)
--   j[240] = "PEhRgH4HPnGbX"  -- w(-33932)
--   j[254] = ":(%d*):"  -- w(-33918)
--   j[255] = "OzlH1R8IdgHv7"  -- w(-33917)
--   j[258] = "QNXv0eUdHKx4"  -- w(-33914)
--   j[270] = "BoNs5JTmUlsHdj"  -- w(-33902)
--   j[273] = "KfZ2vEXHZpgXH"  -- w(-33899)
--   j[340] = "F"  -- w(-33832)
--   j[349] = "AWR0rtFSffF6ZE"  -- w(-33823)
--   j[378] = "N6UAZfjFIw6cd"  -- w(-33794)
--   j[380] = "ZDfJ7VLZlGpy"  -- w(-33792)
--   j[394] = "KJ1M4ilP1qJsOm"  -- w(-33778)
--   j[402] = "PappL3lkmPqUk"  -- w(-33770)
--   j[423] = "BJgN4jyfqip5"  -- w(-33749)
--   j[426] = "rcw"  -- w(-33746)
--   j[437] = "RXVqPZX6yV7u"  -- w(-33735)
--   j[450] = "Flk5z4Z8huKCS"  -- w(-33722)
--   j[453] = "c"  -- w(-33719)
--   j[454] = "Lerp"  -- w(-33718)

-- [Operators/Symbols] (8 entries)
--   j[112] = "}"  -- w(-34060)
--   j[139] = ""  -- w(-34033)
--   j[147] = ":"  -- w(-34025)
--   j[247] = "_G"  -- w(-33925)
--   j[253] = "'"  -- w(-33919)
--   j[359] = "="  -- w(-33813)
--   j[361] = "-"  -- w(-33811)
--   j[364] = "l2"  -- w(-33808)

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  2. السورس المعاد بناؤه (Reconstructed Source Code)        ║
-- ╚══════════════════════════════════════════════════════════════╝

-- ═══════════ الغلاف الخارجي (Outer Wrapper) ═══════════
return (function(newproxy, unpack, getmetatable, setmetatable, _ENV, select, ...)
    local args = {...}

    -- ═══════════ جداول فك التشفير (Decryption Tables) ═══════════
    -- D[64]: Custom Base64 alphabet (A→13, B→58, C→61, ...)
    -- H[85]: Custom Base85 alphabet (^→71, [→40, <→23, ...)
    -- String decoding: prefix 'b' = Base64, prefix 'd' = Base85
    -- w(x) returns j[x + 34172] (decoded string table)

    -- ═══════════ جدول السلاسل المشفر (Encrypted String Table) ═══════════
    local j = { --[[ 461 encrypted strings ]] }
    local function w(x) return j[x + 34172] end

    -- ═══════════ نظام إدارة المراجع (Reference Management) ═══════════
    local O = {}  -- reference count: O[key] = count
    local H = {}  -- value store: H[key] = value
    local g = {}   -- register file / argument array

    -- ═══════════ آلة الحالات الافتراضية (Virtual State Machine) ═══════════
    -- Entry point: state 4015136
    -- 67 unique states, 95 transitions, 25 conditional branches
    -- Dispatch: binary search tree of if/elseif i<threshold comparisons

    -- ═══════════════════════════════════════════════════════════
    -- التنفيذ المعاد بناؤه (Reconstructed Execution)
    -- ═══════════════════════════════════════════════════════════

    -- ━━━ Block 1 [META] ━━━
    if <condition> then
        goto state_13753759
    else
        goto state_9490551
    end
    if <condition> then
        goto state_3247466
    else
        goto state_530266
    end
    -- ref: 'setmetatable'  -- j[153]
    if <condition> then
        goto state_3286621
    else
        goto state_2414939
    end
    -- ref: 'y'  -- j[78]
    -- ref: ''  -- j[139]

    -- ━━━ Block 2 [META_KEY] ━━━
    -- ref: '__len'  -- j[333]
    -- ref: 'W'  -- j[198]

    -- ━━━ Block 3 [ENV] ━━━
    -- ref: 'AzI7BJkBWxVH5k'  -- j[25]
    if <condition> then
        goto state_6609017
    else
        goto state_11618016
    end
    if <condition> then
        goto state_4469785
    else
        goto state_10739070
    end
    goto state_61
    -- ref: 'l2'  -- j[364]
    goto state_1832632
    goto state_13311217
    goto state_244600
    if <condition> then
        goto state_4480913
    else
        goto state_531053
    end
    goto state_11749104
    goto state_8446674
    goto state_5567448
    goto state_15657715
    if <condition> then
        goto state_16349376
    else
        goto state_15540632
    end
    if <condition> then
        goto state_7162254
    else
        goto state_15691660
    end
    goto state_16364167
    goto state_3538028
    goto state_14168058
    goto state_3538028
    goto state_798397
    -- ref: 'Z2IAu7xPeVU6Q'  -- j[57]
    -- ref: 'M21RkMGpVmui'  -- j[208]
    -- ref: '='  -- j[359]
    -- ref: '_ENV'  -- j[56]

    -- ━━━ Block 4 [INTERNAL] ━━━
    -- ref: 'mqV'  -- j[82]

    -- ━━━ Block 5 [STRING_MATH | UI_METHOD] ━━━
    -- ref: 'Q9hIowrNaaja'  -- j[50]
    -- ref: 'oErei7iIakJZk'  -- j[68]
    -- ref: 'c'  -- j[453]
    -- ref: 'floor'  -- j[12]
    -- ref: 'UhfI41gmZRyE7'  -- j[17]
    -- ref: 'x0Xr0gPTcKID'  -- j[342]
    -- ref: 'UhfI41gmZRyE7'  -- j[17]
    -- ref: 'UhfI41gmZRyE7'  -- j[17]
    -- ref: '-'  -- j[361]
    -- ref: 'Destroy'  -- j[2]
    -- ref: '-'  -- j[361]
    -- ref: 'N6UAZfjFIw6cd'  -- j[378]
    -- ref: '-'  -- j[361]
    -- ref: 'TvOBnLIZWbO1tK'  -- j[227]
    -- ref: 'UhfI41gmZRyE7'  -- j[17]
    -- ref: 'UhfI41gmZRyE7'  -- j[17]

    -- ━━━ Block 6 [CLIPBOARD | STRING_MATH] ━━━
    goto state_3740949
    -- ref: 'KJ1M4ilP1qJsOm'  -- j[394]
    goto state_11024643
    -- ref: 'setclipboard'  -- j[362]
    goto state_1183749
    if <condition> then
        goto state_7479895
    else
        goto state_10947362
    end
    -- ref: 'p3DUdOQM'  -- j[29]
    -- ref: 'Mp1XJnUbAVMm'  -- j[167]
    goto state_0
    -- ref: 'table'  -- j[339]

    -- ━━━ Block 7 [TYPE_CHECK] ━━━
    -- ref: 'tonumber'  -- j[109]
    goto state_11749104

    -- ━━━ Block 8 [INTERNAL] ━━━
    -- ref: 'bdGAHArOOhwc'  -- j[110]
    if <condition> then
        goto state_12501617
    else
        goto state_2431793
    end

    -- ━━━ Block 9 [INTERNAL] ━━━
    goto state_8837418
    -- ref: 'tuGv'  -- j[23]

    -- ━━━ Block 10 [STRING_MATH] ━━━
    goto state_16085214
    if <condition> then
        goto state_13161543
    else
        goto state_14419034
    end
    goto state_0
    -- ref: 'string'  -- j[407]
    goto state_3538028

    -- ━━━ Block 11 [ANTI_TAMPER] ━━━
    -- ref: 'islclosure'  -- j[20]

    -- ━━━ Block 12 [STRING_MATH] ━━━
    -- ref: 'byte'  -- j[308]

    -- ━━━ Block 13 [ERROR_HANDLING] ━━━
    -- ref: 'bRwGUGYtI41Jx'  -- j[251]
    -- ref: 'warn'  -- j[164]
    -- ref: 'ysQezM4rr3AVtV'  -- j[302]
    -- ref: 'TQ3n7eSAILoO'  -- j[182]
    goto state_11468469
    -- ref: '-'  -- j[361]

    -- ━━━ Block 14 [INTERNAL] ━━━
    -- ref: 'M21RkMGpVmui'  -- j[208]

    -- ━━━ Block 15 [ANTI_TAMPER | ROBLOX] ━━━
    goto state_16123142
    goto state_3538028
    -- ref: 'game'  -- j[193]
    if <condition> then
        goto state_4330395
    else
        goto state_12737404
    end
    goto state_0
    -- ref: '0IWLPmqXWGwBn'  -- j[194]
    -- ref: 'Hzu4uRjdkG7f'  -- j[73]
    -- ref: 'b8ashv5DvDUbYK'  -- j[321]
    goto state_798397
    -- ref: 'Kick'  -- j[374]
    -- ref: 'GetService'  -- j[221]

    -- ━━━ Block 16 [ITERATION | NETWORK | STRING_MATH | UI | UI_METHOD] ━━━
    -- ref: 'pairs'  -- j[257]
    -- ref: 'random'  -- j[203]
    goto state_15849203
    goto state_2147483647
    -- ref: 'HttpGet'  -- j[413]
    -- ref: 'Vector3'  -- j[83]
    -- ref: 'Vector3'  -- j[83]
    -- ref: '''  -- j[253]
    goto state_798397
    -- ref: 'Vector3'  -- j[83]
    -- ref: 'Create'  -- j[445]
    goto state_8718107
    -- ref: ':(%d*):'  -- j[254]
    -- ref: '-'  -- j[361]

    -- ━━━ Block 17 [INTERNAL] ━━━
    -- ref: 'KJ1M4ilP1qJsOm'  -- j[394]

    -- ━━━ Block 18 [INTERNAL] ━━━
    goto state_9296206
    -- ref: 'o'  -- j[49]
    -- ref: ''  -- j[139]
    -- ref: 'remove'  -- j[100]
    -- ref: '-'  -- j[361]
    -- ref: '-'  -- j[361]

    -- ━━━ Block 19 [UI_METHOD] ━━━
    -- ref: '1E2RwOJCQrfaZ7'  -- j[192]
    -- ref: 'ZDfJ7VLZlGpy'  -- j[380]
    goto state_909560
    -- ref: 'Lerp'  -- j[454]
    goto state_1575708
    goto state_11797508
    goto state_2673020

    -- ━━━ Block 20 [META_KEY | ROBLOX] ━━━
    -- ref: '__index'  -- j[207]
    -- ref: 'M21RkMGpVmui'  -- j[208]
    -- ref: 'F'  -- j[340]
    -- ref: '-'  -- j[361]
    -- ref: 'FindFirstChild'  -- j[284]
    -- ref: 'FindFirstChild'  -- j[284]
    -- ref: 'cIofB2DWPIQM'  -- j[105]
    if <condition> then
        goto state_7276068
    else
        goto state_15221698
    end

    -- ━━━ Block 21 [INTERNAL] ━━━
    -- ref: 'Q9hIowrNaaja'  -- j[50]
    goto state_13096207
    goto state_798397
    -- ref: 'Od3Hii1UvyrO'  -- j[79]
    goto state_11024643
    goto state_244600

    -- ━━━ Block 22 [INTERNAL] ━━━
    goto state_939896
    -- ref: 'PEhRgH4HPnGbX'  -- j[240]
    -- ref: '1SzHU1hhtY4SUN'  -- j[136]

    -- ━━━ Block 23 [TYPE_CHECK] ━━━
    -- ref: '-'  -- j[361]
    -- ref: 'type'  -- j[200]

    -- ━━━ Block 24 [ERROR_HANDLING | STRING_MATH] ━━━
    -- ref: 'char'  -- j[67]
    goto state_15835387
    -- ref: 'pcall'  -- j[432]
    goto state_8936327

    -- ━━━ Block 25 [INTERNAL] ━━━
    -- ref: '-'  -- j[361]
    -- ref: '5hpaHMuzz6g4'  -- j[439]
    goto state_3538028
    -- ref: 'x'  -- j[3]
    -- ref: '+K^I'  -- j[18]
    -- ref: 'gSqNRUBiaV6Olh'  -- j[304]
    if <condition> then
        goto state_11737393
    else
        goto state_16627728
    end
    goto state_3538028

    -- ━━━ Block 26 [ROBLOX | TYPE_CHECK | UI] ━━━
    -- ref: 'kdhPCuPEko2n'  -- j[220]
    -- ref: 'mqV'  -- j[82]
    -- ref: 'wtE61klAG4OJ1'  -- j[315]
    -- ref: '}'  -- j[112]
    -- ref: 'GetPlayers'  -- j[435]
    -- ref: 'tostring'  -- j[224]
    -- ref: 'rcw'  -- j[426]
    -- ref: 'Enum'  -- j[461]
    -- ref: 'lFz6LFfbcaQNm9'  -- j[96]
    -- ref: 'K4q3aFp6H2kI'  -- j[134]

    -- ━━━ Block 27 [INTERNAL] ━━━
    -- ref: 'o'  -- j[49]
    -- ref: 'JshWNO5iJdz7Cy'  -- j[196]

    -- ━━━ Block 28 [STRING_MATH] ━━━
    -- ref: 'concat'  -- j[10]
    -- ref: 'UZsd8gWN4Gu6ga'  -- j[189]
    -- ref: 'aVz3WGxXC6Z8T'  -- j[286]
    -- ref: 'GdZqCInRyo6E'  -- j[8]

    -- ━━━ Block 29 [UI] ━━━
    -- ref: 'UDim2'  -- j[436]
    -- ref: 'AlDeeEo6yF610'  -- j[19]

    -- ━━━ Block 30 [INTERNAL] ━━━
    -- ref: 'cUN5YpdFYiOq'  -- j[125]

    -- ━━━ Block 31 [INTERNAL] ━━━
    -- ref: 'oyJrifjEJZLi'  -- j[352]

    -- ━━━ Block 32 [INTERNAL] ━━━
    -- ref: 'lwAtT0tu8hp4'  -- j[171]
    -- ref: 'hLOOTdCcrLx1k'  -- j[217]

    -- ━━━ Block 33 [ERROR_HANDLING | UI] ━━━
    -- ref: 'TweenInfo'  -- j[135]
    -- ref: 'rTxO5rP6jmti'  -- j[279]
    -- ref: 'error'  -- j[404]

    -- ━━━ Block 34 [UI_METHOD] ━━━
    -- ref: 'Play'  -- j[288]
    -- ref: '0UksvW1JVboQuS'  -- j[159]
    -- ref: 'gdQ5wUfcEEhW'  -- j[415]
    -- ref: 'RXVqPZX6yV7u'  -- j[437]

    -- ━━━ Block 35 [INTERNAL] ━━━
    -- ref: 'BoNs5JTmUlsHdj'  -- j[270]
    -- ref: 'qTlKNYEtsR6e'  -- j[32]

    -- ━━━ Block 36 [INTERNAL] ━━━
    -- ref: 'Z1PDS7WvnCEnqD'  -- j[202]
    -- ref: 'OdBHt8Rbv65u43'  -- j[223]

    -- ━━━ Block 37 [INTERNAL] ━━━
    -- ref: 'debug'  -- j[71]
    -- ref: 'b2o1n69OK5iq'  -- j[155]

    -- ━━━ Block 38 [INTERNAL] ━━━
    -- ref: 'GRLAjQzPtRH2'  -- j[45]
    -- ref: 'h9Jfg77MjTCrs'  -- j[327]
    -- ref: 'UDL0RUYuiekrwR'  -- j[55]
    -- ref: 'EFLEIqjsJWgGf'  -- j[61]
    -- ref: 'QNXv0eUdHKx4'  -- j[258]

    -- ━━━ Block 39 [INTERNAL] ━━━
    -- ref: 'ZeBH4XbMCWxy0g'  -- j[233]
    -- ref: '-'  -- j[361]

    -- ━━━ Block 40 [ANTI_TAMPER] ━━━
    -- ref: 'Tamper Detected!'  -- j[275]
    -- ref: 'i2d0IHEM4LmsMp'  -- j[348]

    -- ━━━ Block 41 [INTERNAL] ━━━
    -- ref: 'M21RkMGpVmui'  -- j[208]
    goto state_798397

    -- ━━━ Block 42 [EVENT | META | UI] ━━━
    -- ref: '-'  -- j[361]
    goto state_939896
    goto state_12526461
    if <condition> then
        goto state_736776
    else
        goto state_6038829
    end
    goto state_1922567
    -- ref: 'M21RkMGpVmui'  -- j[208]
    -- ref: '61x83ByN3ZXZZG'  -- j[382]
    -- ref: 'Disconnect'  -- j[140]
    -- ref: 'Vector3'  -- j[83]
    -- ref: 'rawget'  -- j[30]
    goto state_7645216
    goto state_0

    -- ━━━ Block 43 [ANTI_TAMPER | ITERATION | TYPE_CHECK] ━━━
    goto state_15625259
    goto state_8700592
    goto state_6492964
    goto state_551847
    -- ref: 'isfunctionhooked'  -- j[225]
    if <condition> then
        goto state_3702371
    else
        goto state_14776115
    end
    -- ref: 'typeof'  -- j[345]
    -- ref: 'o'  -- j[49]
    goto state_8164605
    -- ref: 'ipairs'  -- j[403]
    -- ref: '-'  -- j[361]
    -- ref: 'Xka7Cy91cJEQ'  -- j[13]
    goto state_2660989
    goto state_10906476
    goto state_551847
    if <condition> then
        goto state_13805665
    else
        goto state_2486982
    end
    -- ref: 'KJ1M4ilP1qJsOm'  -- j[394]
    goto state_3088118

    -- ━━━ Block 44 [UI] ━━━
    goto state_5992705
    -- ref: 'Color3'  -- j[406]

    -- ━━━ Block 45 [INTERNAL] ━━━
    -- ref: 'BJgN4jyfqip5'  -- j[423]
    goto state_8446674
    if <condition> then
        goto state_16500342
    else
        goto state_9980560
    end
    -- ref: 'AWR0rtFSffF6ZE'  -- j[349]
    if <condition> then
        goto state_14762014
    else
        goto state_10402853
    end
    goto state_15376699

    -- ━━━ Block 46 [ENV] ━━━
    goto state_16512164
    if <condition> then
        goto state_1670327
    else
        goto state_1575708
    end
    -- ref: '_G'  -- j[247]
    goto state_3538028
    if <condition> then
        goto state_14515332
    else
        goto state_7950622
    end
    -- ref: 'wunC3zT1BVo5'  -- j[329]
    -- ref: 'M21RkMGpVmui'  -- j[208]
    goto state_609472
    goto state_0
    -- ref: 'Mp1XJnUbAVMm'  -- j[167]
    goto state_16246968
    -- ref: 'remove'  -- j[100]

    -- ━━━ Block 47 [INTERNAL] ━━━
    -- ref: 'VaxxFshwomfbV'  -- j[172]
    goto state_800973
    goto state_798397
    goto state_6618969

    -- ━━━ Block 48 [INTERNAL] ━━━
    goto state_16123142
    -- ref: 'QQDyzlGL7eEhO'  -- j[122]
    -- ref: 'SPVyAcVcC1O7PY'  -- j[53]
    -- ref: 'yQ6AjG'  -- j[231]

    -- ━━━ Block 49 [UI] ━━━
    goto state_798397
    -- ref: 'l3v4XRj7i2DL'  -- j[328]
    -- ref: '8xW3srj2hmH7GT'  -- j[441]
    -- ref: 'u95VMbZvA9e85'  -- j[226]
    -- ref: 'UDim'  -- j[132]
    -- ref: 'qP1gNVaFeGmu'  -- j[446]

    -- ━━━ Block 50 [ITERATION | STRING_MATH] ━━━
    -- ref: 'gsub'  -- j[358]
    goto state_7963929
    goto state_7896600
    -- ref: 'KfZ2vEXHZpgXH'  -- j[273]
    if <condition> then
        goto state_3760843
    else
        goto state_16123142
    end
    goto state_2006289
    if <condition> then
        goto state_6732394
    else
        goto state_2114199
    end
    -- ref: 'unpack'  -- j[97]

    -- ━━━ Block 51 [INTERNAL] ━━━
    goto state_59
    goto state_8700592
    goto state_12499165
    -- ref: 'rCBKJ5zXlNsAr'  -- j[353]
    -- ref: 'wADCVkt3asvWbG'  -- j[390]
    -- ref: 'PappL3lkmPqUk'  -- j[402]
    goto state_4489035
    goto state_8164605
    -- ref: 'TWj7ylXR2BYFS'  -- j[212]

    -- ━━━ Block 52 [INTERNAL] ━━━
    -- ref: 'F'  -- j[340]
    -- ref: ':'  -- j[147]
    goto state_8754929
    -- ref: 'tkUaum51oFTCDl'  -- j[70]
    goto state_15792381
    goto state_1636512
    -- ref: 'R7E38sEVC5hC'  -- j[201]
    -- ref: 'OzlH1R8IdgHv7'  -- j[255]

    -- ━━━ Block 53 [INTERNAL] ━━━
    -- ref: 'c3kOH8DFQq0v6u'  -- j[434]
    -- ref: 'xZF0x'  -- j[170]

    -- ━━━ Block 54 [EVENT | ITERATION | META_KEY | UI] ━━━
    -- ref: 'J'  -- j[114]
    -- ref: '-'  -- j[361]
    -- ref: 'yQgppOqWQmbQXX'  -- j[72]
    -- ref: 'Instance'  -- j[87]
    -- ref: 'cYe6Pitxuxuh45'  -- j[46]
    -- ref: 'I'  -- j[165]
    -- ref: '-'  -- j[361]
    -- ref: 'Flk5z4Z8huKCS'  -- j[450]
    -- ref: 'UhfI41gmZRyE7'  -- j[17]
    -- ref: '-'  -- j[361]
    -- ref: 'UhfI41gmZRyE7'  -- j[17]
    -- ref: '0hdiuAryoC0h'  -- j[47]
    -- ref: 'UhfI41gmZRyE7'  -- j[17]
    -- ref: '-'  -- j[361]
    -- ref: 'Connect'  -- j[93]
    -- ref: 'UhfI41gmZRyE7'  -- j[17]
    -- ref: 'UhfI41gmZRyE7'  -- j[17]
    -- ref: 'task'  -- j[373]
    -- ref: 'KJ1M4ilP1qJsOm'  -- j[394]
    goto state_683771
    -- ref: 'u'  -- j[63]
    if <condition> then
        goto state_8389699
    else
        goto state_16373456
    end
    -- ref: 'Vector3'  -- j[83]
    -- ref: '__gc'  -- j[204]
    -- ref: 'F'  -- j[340]

    -- ━━━ Block 55 [CLIPBOARD | NETWORK | STRING_MATH] ━━━
    goto state_9722294
    -- ref: 'setclipboard'  -- j[362]
    -- ref: 'math'  -- j[416]
    -- ref: 'UrlEncode'  -- j[341]
    -- ref: 'UrlEncode'  -- j[341]

    -- ═══════════════════════════════════════════════════════════
    -- التحليل السلوكي (Behavioral Analysis)
    -- ═══════════════════════════════════════════════════════════

    -- [1] التهيئة (INITIALIZATION)
    -- الدالة تُمرر بـ: newproxy, unpack, getmetatable, setmetatable, _ENV, select
    -- تبني جداول فك تشفير D[64] و H[85]
    -- تفك تشفير جدول السلاسل (461 سلسلة)
    -- تهيئ نظام المراجع O[]/H[]

    -- [2] فحص مكافحة التلاعب (ANTI-TAMPER CHECK)
    -- isfunctionhooked(): يفحص إذا كانت الدوال مُعدلة
    -- islclosure(): يتحقق من أن الدوال هي إغلاقات Lua أصلية
    -- عند الكشف: warn('Tamper Detected!') → Kick('Tamper Detected!')
    if isfunctionhooked(setclipboard) or not islclosure(getfenv) then
        warn('Tamper Detected!')
        game:GetService('Players').LocalPlayer:Kick('Tamper Detected!')
        return error('Tamper Detected!')
    end

    -- [3] الوصول للبيئة (ENVIRONMENT ACCESS)
    -- getgenv(): بيئة exploit المشتركة
    -- getfenv(): بيئة الدالة الحالية
    -- _G: الجدول العام
    local genv = getgenv()
    local fenv = getfenv()
    local _G_ref = _G

    -- [4] حماية Metatables (METATABLE PROTECTION)
    -- __index: التحكم في قراءة الحقول
    -- __gc: التنظيف عند جمع القمامة
    -- __len: التحكم في عامل #
    -- __metatable: منع getmetatable()
    local protected = setmetatable({}, {
        __index = function(self, key) return rawget(self, key) end,
        __gc = function(self) --[[ release references ]] end,
        __len = function(self) return 0 end,
        __metatable = 'locked'
    })

    -- [5] الشبكة (NETWORK OPERATIONS)
    -- HttpGet: تحميل بيانات من URL (URL يُبنى في وقت التشغيل)
    -- UrlEncode: ترميز البيانات للإرسال (3 استدعاءات)
    -- JSONDecode: فك ترميز الاستجابة
    -- :(%d*): نمط لاستخراج أرقام من سلاسل
    local HttpService = game:GetService('HttpService')
    local response = game:HttpGet(--[[ runtime URL ]])
    local data = HttpService:JSONDecode(response)

    -- [6] واجهة المستخدم (UI CONSTRUCTION)
    -- Instance.new(): إنشاء عناصر واجهة
    -- UDim/UDim2: أبعاد واجهة المستخدم
    -- Color3: ألوان
    -- TweenInfo: معلومات الحركة
    -- Lerp: انتقال سلس للألوان/المواقع
    -- Vector3: إحداثيات ثلاثية الأبعاد
    -- Enum: تعدادات Roblox
    local frame = Instance.new('Frame')
    frame.Size = UDim2.new(...)
    frame.BackgroundColor3 = Color3.new(...)

    -- [7] ربط الأحداث (EVENT CONNECTIONS)
    -- 7 استدعاءات Connect لربط أحداث
    -- 2 استدعاء Disconnect لفصل أحداث
    -- الأحداث تشمل: تحديثات اللاعبين, إدخال المستخدم, تغييرات اللعبة
    local connections = {}
    connections[1] = event:Connect(function(...)
        -- معالج الحدث
    end)

    -- [8] سرقة البيانات (DATA EXFILTRATION) ⚠️
    -- setclipboard: يُستدعى 17 مرة - الأكثر استدعاءً في السكريبت بأكمله!
    -- يجمع بيانات اللاعبين واللعبة ويضعها في الحافظة
    -- UrlEncode يُستخدم لترميز البيانات قبل الإرسال
    -- string.byte/char/gsub/gmatch للتلاعب بالسلاسل
    setclipboard(collected_data) -- ×17 across execution

    -- [9] معالجة السلاسل (STRING PROCESSING)
    -- النمط ':(%d*):' يُستخدم لاستخراج أرقام من سلاسل
    -- string.byte: تحويل حرف → رقم
    -- string.char: تحويل رقم → حرف
    -- gsub: استبدال أنماط في سلاسل
    -- gmatch: مطابقة أنماط متعددة
    -- concat: دمج سلاسل
    for num in string.gmatch(data, ':(%d*):') do
        -- process extracted numbers
    end

    -- [10] إدارة اللاعبين (PLAYER MANAGEMENT)
    -- GetPlayers: الحصول على قائمة اللاعبين
    -- FindFirstChild: البحث عن عنصر فرعي
    -- Destroy: تدمير عناصر
    -- Play: تشغيل صوت/حركة
    for _, player in pairs(game:GetService('Players'):GetPlayers()) do
        -- process each player
    end

    -- [11] معالجة الأخطاء (ERROR HANDLING)
    -- pcall: تنفيذ محمي
    -- error: إلقاء خطأ
    -- warn: تحذير
    local ok, result = pcall(function()
        -- protected execution
    end)
    if not ok then
        warn(result)
    end

end)

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  3. تتبع مراجع w() الكامل (Complete w() Reference Trace)  ║
-- ╚══════════════════════════════════════════════════════════════╝

-- Total w() references: 595
-- Unique readable strings referenced: 157

-- Reference counts (most → least):
--   "-": 17x
--   "UhfI41gmZRyE7": 10x
--   "M21RkMGpVmui": 6x
--   "Vector3": 5x
--   "KJ1M4ilP1qJsOm": 4x
--   "o": 3x
--   "F": 3x
--   "": 2x
--   "mqV": 2x
--   "Q9hIowrNaaja": 2x
--   "setclipboard": 2x
--   "Mp1XJnUbAVMm": 2x
--   "remove": 2x
--   "FindFirstChild": 2x
--   "UrlEncode": 2x
--   "setmetatable": 1x
--   "y": 1x
--   "__len": 1x
--   "W": 1x
--   "AzI7BJkBWxVH5k": 1x
--   "l2": 1x
--   "Z2IAu7xPeVU6Q": 1x
--   "=": 1x
--   "_ENV": 1x
--   "oErei7iIakJZk": 1x
--   "c": 1x
--   "floor": 1x
--   "x0Xr0gPTcKID": 1x
--   "Destroy": 1x
--   "N6UAZfjFIw6cd": 1x
--   "TvOBnLIZWbO1tK": 1x
--   "p3DUdOQM": 1x
--   "table": 1x
--   "tonumber": 1x
--   "bdGAHArOOhwc": 1x
--   "tuGv": 1x
--   "string": 1x
--   "islclosure": 1x
--   "byte": 1x
--   "bRwGUGYtI41Jx": 1x
--   "warn": 1x
--   "ysQezM4rr3AVtV": 1x
--   "TQ3n7eSAILoO": 1x
--   "game": 1x
--   "0IWLPmqXWGwBn": 1x
--   "Hzu4uRjdkG7f": 1x
--   "b8ashv5DvDUbYK": 1x
--   "Kick": 1x
--   "GetService": 1x
--   "pairs": 1x
--   "random": 1x
--   "HttpGet": 1x
--   "'": 1x
--   "Create": 1x
--   ":(%d*):": 1x
--   "1E2RwOJCQrfaZ7": 1x
--   "ZDfJ7VLZlGpy": 1x
--   "Lerp": 1x
--   "__index": 1x
--   "cIofB2DWPIQM": 1x
--   "Od3Hii1UvyrO": 1x
--   "PEhRgH4HPnGbX": 1x
--   "1SzHU1hhtY4SUN": 1x
--   "type": 1x
--   "char": 1x
--   "pcall": 1x
--   "5hpaHMuzz6g4": 1x
--   "x": 1x
--   "+K^I": 1x
--   "gSqNRUBiaV6Olh": 1x
--   "kdhPCuPEko2n": 1x
--   "wtE61klAG4OJ1": 1x
--   "}": 1x
--   "GetPlayers": 1x
--   "tostring": 1x
--   "rcw": 1x
--   "Enum": 1x
--   "lFz6LFfbcaQNm9": 1x
--   "K4q3aFp6H2kI": 1x
--   "JshWNO5iJdz7Cy": 1x
--   "concat": 1x
--   "UZsd8gWN4Gu6ga": 1x
--   "aVz3WGxXC6Z8T": 1x
--   "GdZqCInRyo6E": 1x
--   "UDim2": 1x
--   "AlDeeEo6yF610": 1x
--   "cUN5YpdFYiOq": 1x
--   "oyJrifjEJZLi": 1x
--   "lwAtT0tu8hp4": 1x
--   "hLOOTdCcrLx1k": 1x
--   "TweenInfo": 1x
--   "rTxO5rP6jmti": 1x
--   "error": 1x
--   "Play": 1x
--   "0UksvW1JVboQuS": 1x
--   "gdQ5wUfcEEhW": 1x
--   "RXVqPZX6yV7u": 1x
--   "BoNs5JTmUlsHdj": 1x
--   "qTlKNYEtsR6e": 1x
--   "Z1PDS7WvnCEnqD": 1x
--   "OdBHt8Rbv65u43": 1x
--   "debug": 1x
--   "b2o1n69OK5iq": 1x
--   "GRLAjQzPtRH2": 1x
--   "h9Jfg77MjTCrs": 1x
--   "UDL0RUYuiekrwR": 1x
--   "EFLEIqjsJWgGf": 1x
--   "QNXv0eUdHKx4": 1x
--   "ZeBH4XbMCWxy0g": 1x
--   "Tamper Detected!": 1x
--   "i2d0IHEM4LmsMp": 1x
--   "61x83ByN3ZXZZG": 1x
--   "Disconnect": 1x
--   "rawget": 1x
--   "isfunctionhooked": 1x
--   "typeof": 1x
--   "ipairs": 1x
--   "Xka7Cy91cJEQ": 1x
--   "Color3": 1x
--   "BJgN4jyfqip5": 1x
--   "AWR0rtFSffF6ZE": 1x
--   "_G": 1x
--   "wunC3zT1BVo5": 1x
--   "VaxxFshwomfbV": 1x
--   "QQDyzlGL7eEhO": 1x
--   "SPVyAcVcC1O7PY": 1x
--   "yQ6AjG": 1x
--   "l3v4XRj7i2DL": 1x
--   "8xW3srj2hmH7GT": 1x
--   "u95VMbZvA9e85": 1x
--   "UDim": 1x
--   "qP1gNVaFeGmu": 1x
--   "gsub": 1x
--   "KfZ2vEXHZpgXH": 1x
--   "unpack": 1x
--   "rCBKJ5zXlNsAr": 1x
--   "wADCVkt3asvWbG": 1x
--   "PappL3lkmPqUk": 1x
--   "TWj7ylXR2BYFS": 1x
--   ":": 1x
--   "tkUaum51oFTCDl": 1x
--   "R7E38sEVC5hC": 1x
--   "OzlH1R8IdgHv7": 1x
--   "c3kOH8DFQq0v6u": 1x
--   "xZF0x": 1x
--   "J": 1x
--   "yQgppOqWQmbQXX": 1x
--   "Instance": 1x
--   "cYe6Pitxuxuh45": 1x
--   "I": 1x
--   "Flk5z4Z8huKCS": 1x
--   "0hdiuAryoC0h": 1x
--   "Connect": 1x
--   "task": 1x
--   "u": 1x
--   "__gc": 1x
--   "math": 1x

--[[
╔══════════════════════════════════════════════════════════════╗
║  4. جدول السلاسل الكامل (Complete String Table Dump)       ║
╚══════════════════════════════════════════════════════════════╝

  w(-34171) → j[1] = <binary 1B: c6>
  w(-34170) → j[2] = 'Destroy'
  w(-34169) → j[3] = 'x'
  w(-34168) → j[4] = <binary 12B: a17dd8f6c67f82a99f7e340d>
  w(-34167) → j[5] = <binary 4B: db60c11f>
  w(-34166) → j[6] = <binary 1B: 98>
  w(-34165) → j[7] = <binary 8B: 7afacaa730190b01>
  w(-34164) → j[8] = 'GdZqCInRyo6E'
  w(-34163) → j[9] = <binary 8B: 4cf438f01c808635>
  w(-34162) → j[10] = 'concat'
  w(-34161) → j[11] = <binary 1B: de>
  w(-34160) → j[12] = 'floor'
  w(-34159) → j[13] = 'Xka7Cy91cJEQ'
  w(-34158) → j[14] = <binary 10B: a92edae205f1ab171a95>
  w(-34157) → j[15] = <binary 10B: e98c8e76faa24a9f10af>
  w(-34156) → j[16] = <binary 8B: 36add531154f7960>
  w(-34155) → j[17] = 'UhfI41gmZRyE7'
  w(-34154) → j[18] = '+K^I'
  w(-34153) → j[19] = 'AlDeeEo6yF610'
  w(-34152) → j[20] = 'islclosure'
  w(-34151) → j[21] = <binary 8B: 0624a5fa1ed55f85>
  w(-34150) → j[22] = <binary 8B: e5c240f7fe3b7e17>
  w(-34149) → j[23] = 'tuGv'
  w(-34148) → j[24] = <binary 4B: 13e8bc0b>
  w(-34147) → j[25] = 'AzI7BJkBWxVH5k'
  w(-34146) → j[26] = <binary 10B: c56ede0692e43d943390>
  w(-34145) → j[27] = <binary 1B: c9>
  w(-34144) → j[28] = <binary 4B: 82cf334d>
  w(-34143) → j[29] = 'p3DUdOQM'
  w(-34142) → j[30] = 'rawget'
  w(-34141) → j[31] = <binary 13B: 63809a3769b913e3443e445bff>
  w(-34140) → j[32] = 'qTlKNYEtsR6e'
  w(-34139) → j[33] = <binary 10B: 18a0edc967ea9a477c90>
  w(-34138) → j[34] = <binary 4B: 179462be>
  w(-34137) → j[35] = <binary 1B: 9b>
  w(-34136) → j[36] = <binary 78B: 8d4093e3e11dc93d970fc0341ada8c40c682162b>
  w(-34135) → j[37] = <binary 5B: a926412b23>
  w(-34134) → j[38] = <binary 16B: 183556bd7125aef1e519f1080d2743f4>
  w(-34133) → j[39] = <binary 7B: 3d1e85f7426a22>
  w(-34132) → j[40] = <binary 3B: e37cf7>
  w(-34131) → j[41] = <binary 4B: cbeef1de>
  w(-34130) → j[42] = <binary 8B: 04b9d89bc4ae2285>
  w(-34129) → j[43] = <binary 8B: cb981096d467705d>
  w(-34128) → j[44] = <binary 6B: 0173f80d4444>
  w(-34127) → j[45] = 'GRLAjQzPtRH2'
  w(-34126) → j[46] = 'cYe6Pitxuxuh45'
  w(-34125) → j[47] = '0hdiuAryoC0h'
  w(-34124) → j[48] = <binary 10B: a742cb2984e4a77e7e8c>
  w(-34123) → j[49] = 'o'
  w(-34122) → j[50] = 'Q9hIowrNaaja'
  w(-34121) → j[51] = <binary 6B: c2623725b037>
  w(-34120) → j[52] = <binary 8B: 513db0c88c0b73c7>
  w(-34119) → j[53] = 'SPVyAcVcC1O7PY'
  w(-34118) → j[54] = <binary 14B: 66687752506f7657b86695622f54>
  w(-34117) → j[55] = 'UDL0RUYuiekrwR'
  w(-34116) → j[56] = '_ENV'
  w(-34115) → j[57] = 'Z2IAu7xPeVU6Q'
  w(-34114) → j[58] = <binary 6B: d62ad55c99a2>
  w(-34113) → j[59] = <binary 4B: 60ba23a0>
  w(-34112) → j[60] = <binary 12B: ff2b0993b43c8f7312c90309>
  w(-34111) → j[61] = 'EFLEIqjsJWgGf'
  w(-34110) → j[62] = <binary 12B: da90f6d026b4693cc5109a9d>
  w(-34109) → j[63] = 'u'
  w(-34108) → j[64] = <binary 4B: c242a1cf>
  w(-34107) → j[65] = <binary 8B: a71b2f580e0f4a32>
  w(-34106) → j[66] = <binary 29B: c276f7c87bb80bc3e584980a2433ec4d6c7fd609>
  w(-34105) → j[67] = 'char'
  w(-34104) → j[68] = 'oErei7iIakJZk'
  w(-34103) → j[69] = <binary 1B: f3>
  w(-34102) → j[70] = 'tkUaum51oFTCDl'
  w(-34101) → j[71] = 'debug'
  w(-34100) → j[72] = 'yQgppOqWQmbQXX'
  w(-34099) → j[73] = 'Hzu4uRjdkG7f'
  w(-34098) → j[74] = <binary 21B: c0ac6b038af932c068d41849bda8a2a7ac4be15e>
  w(-34097) → j[75] = <binary 10B: 6a56216257e6db6f4399>
  w(-34096) → j[76] = <binary 4B: df240c50>
  w(-34095) → j[77] = <binary 5B: df8dfe50e0>
  w(-34094) → j[78] = 'y'
  w(-34093) → j[79] = 'Od3Hii1UvyrO'
  w(-34092) → j[80] = <binary 10B: 99e49e2d70049c54232d>
  w(-34091) → j[81] = <binary 8B: e43ecc203405f3e3>
  w(-34090) → j[82] = 'mqV'
  w(-34089) → j[83] = 'Vector3'
  w(-34088) → j[84] = <binary 11B: 5a31900e083e1427b3edd8>
  w(-34087) → j[85] = <binary 10B: 515a538cf7828276e348>
  w(-34086) → j[86] = <binary 8B: 530e4f868da5d0b9>
  w(-34085) → j[87] = 'Instance'
  w(-34084) → j[88] = <binary 15B: e335fd322f527e4fd729bbb5bc6c78>
  w(-34083) → j[89] = <binary 1B: 99>
  w(-34082) → j[90] = <binary 4B: 96b8bed1>
  w(-34081) → j[91] = <binary 16B: 37d58cbe34f449cfdbc95e36f7b8b728>
  w(-34080) → j[92] = <binary 6B: 17fdb170ab31>
  w(-34079) → j[93] = 'Connect'
  w(-34078) → j[94] = <binary 1B: 05>
  w(-34077) → j[95] = <binary 6B: a6db0bb7b407>
  w(-34076) → j[96] = 'lFz6LFfbcaQNm9'
  w(-34075) → j[97] = 'unpack'
  w(-34074) → j[98] = <binary 4B: 8af68906>
  w(-34073) → j[99] = <binary 7B: 81676ef0436ed8>
  w(-34072) → j[100] = 'remove'
  w(-34071) → j[101] = <binary 6B: 7ba3039459ee>
  w(-34070) → j[102] = <binary 11B: 4a534f4e4465636f6463ab>
  w(-34069) → j[103] = <binary 8B: 34bd1b64acd164bc>
  w(-34068) → j[104] = <binary 3B: efaf17>
  w(-34067) → j[105] = 'cIofB2DWPIQM'
  w(-34066) → j[106] = <binary 14B: e904e71a5f349b49dc31daa2dd9b>
  w(-34065) → j[107] = <binary 7B: e4040fc5481ed7>
  w(-34064) → j[108] = <binary 10B: 8d8d428dec50d7d65b8b>
  w(-34063) → j[109] = 'tonumber'
  w(-34062) → j[110] = 'bdGAHArOOhwc'
  w(-34061) → j[111] = <binary 10B: 00c204120e8d043447e4>
  w(-34060) → j[112] = '}'
  w(-34059) → j[113] = <binary 35B: cdeee29f7a5031e2a7c5f8120c2461740785f049>
  w(-34058) → j[114] = 'J'
  w(-34057) → j[115] = <binary 4B: 1d4f44bf>
  w(-34056) → j[116] = <binary 6B: e09f8139a957>
  w(-34055) → j[117] = <binary 12B: 5f5f6965bc0d9c5c0444f24d>
  w(-34054) → j[118] = <binary 40B: 5e543ea4f559b2020f68dac76a26df548afa760b>
  w(-34053) → j[119] = <binary 8B: c41e1479622cb6f5>
  w(-34052) → j[120] = <binary 3B: 20f457>
  w(-34051) → j[121] = <binary 9B: 3ce842f9beaecdef67>
  w(-34050) → j[122] = 'QQDyzlGL7eEhO'
  w(-34049) → j[123] = <binary 8B: a60c255bd69fda86>
  w(-34048) → j[124] = <binary 10B: 95b5ea86b65d2624e68b>
  w(-34047) → j[125] = 'cUN5YpdFYiOq'
  w(-34046) → j[126] = <binary 3B: 549a7d>
  w(-34045) → j[127] = <binary 16B: e788dc655dc45508690f940d64654557>
  w(-34044) → j[128] = <binary 5B: d4e3d2ebb8>
  w(-34043) → j[129] = <binary 5B: e526390798>
  w(-34042) → j[130] = <binary 4B: 1d820096>
  w(-34041) → j[131] = <binary 8B: 0664a9de919dff40>
  w(-34040) → j[132] = 'UDim'
  w(-34039) → j[133] = <binary 12B: 13ef6f5206d7008de678f76e>
  w(-34038) → j[134] = 'K4q3aFp6H2kI'
  w(-34037) → j[135] = 'TweenInfo'
  w(-34036) → j[136] = '1SzHU1hhtY4SUN'
  w(-34035) → j[137] = <binary 10B: 788cd5e500b5ac0ff4e6>
  w(-34034) → j[138] = <binary 1B: c4>
  w(-34033) → j[139] = '\r'
  w(-34032) → j[140] = 'Disconnect'
  w(-34031) → j[141] = <binary 5B: 66d597b27c>
  w(-34030) → j[142] = <binary 4B: 9e6a53c3>
  w(-34029) → j[143] = <binary 6B: c9e1e7937b3e>
  w(-34028) → j[144] = <binary 8B: 8af9b9d243c5af4e>
  w(-34027) → j[145] = <binary 4B: bfaa80de>
  w(-34026) → j[146] = <binary 7B: 6668296fd167e6>
  w(-34025) → j[147] = ':'
  w(-34024) → j[148] = <binary 9B: 5d10b3e1a5823891ab>
  w(-34023) → j[149] = <binary 4B: c2da8cb2>
  w(-34022) → j[150] = <binary 43B: 3d1435e359239931f72621c1391457382a7d1be8>
  w(-34021) → j[151] = <binary 16B: 3605403d067179fd2835421bf0594735>
  w(-34020) → j[152] = <binary 16B: a2e8641193b87703cbb2347de9190943>
  w(-34019) → j[153] = 'setmetatable'
  w(-34018) → j[154] = <binary 4B: 8de574d5>
  w(-34017) → j[155] = 'b2o1n69OK5iq'
  w(-34016) → j[156] = <binary 10B: 1dcdd8c297ca95f9202a>
  w(-34015) → j[157] = <binary 4B: 3596a434>
  w(-34014) → j[158] = <binary 5B: 95bbff8014>
  w(-34013) → j[159] = '0UksvW1JVboQuS'
  w(-34012) → j[160] = <binary 12B: be267df4e68141dfe9b8b00d>
  w(-34011) → j[161] = <binary 24B: b1b0ec29551108c727c1313aadb15effcdca2458>
  w(-34010) → j[162] = <binary 4B: f0368515>
  w(-34009) → j[163] = <binary 14B: 47496c3bfd370f13034c72cd7aaf>
  w(-34008) → j[164] = 'warn'
  w(-34007) → j[165] = 'I'
  w(-34006) → j[166] = <binary 4B: 37371c97>
  w(-34005) → j[167] = 'Mp1XJnUbAVMm'
  w(-34004) → j[168] = <binary 4B: 7bcfa719>
  w(-34003) → j[169] = <binary 40B: aaca072b6813ee76e14daeb97cfcadda4f887c8f>
  w(-34002) → j[170] = 'xZF0x'
  w(-34001) → j[171] = 'lwAtT0tu8hp4'
  w(-34000) → j[172] = 'VaxxFshwomfbV'
  w(-33999) → j[173] = <binary 8B: 6eb08c654426bf5e>
  w(-33998) → j[174] = <binary 6B: cc5d6ca9bfa0>
  w(-33997) → j[175] = <binary 5B: 3e4653bb1c>
  w(-33996) → j[176] = <binary 9B: 4662982b983d753626>
  w(-33995) → j[177] = <binary 4B: 4a713ae3>
  w(-33994) → j[178] = <binary 3B: 02d178>
  w(-33993) → j[179] = <binary 40B: 80d9a17543e04fd3126f94fe9e5571c9d4b4c8c2>
  w(-33992) → j[180] = <binary 5B: 1fde7f4f69>
  w(-33991) → j[181] = <binary 5B: 60e1df34e6>
  w(-33990) → j[182] = 'TQ3n7eSAILoO'
  w(-33989) → j[183] = <binary 10B: 9b03e4652cb7361ea87c>
  w(-33988) → j[184] = <binary 9B: 3ec05c96d1cf753e6b>
  w(-33987) → j[185] = <binary 9B: 9441b29376b272c058>
  w(-33986) → j[186] = <binary 10B: f00ccd8f3cd77f4ae086>
  w(-33985) → j[187] = <binary 13B: 8fb195863bb66c4af5792b2bca>
  w(-33984) → j[188] = <binary 4B: 8e36fc3f>
  w(-33983) → j[189] = 'UZsd8gWN4Gu6ga'
  w(-33982) → j[190] = <binary 23B: 54f6b87ac7a00362bb75ea2a8af799a819888564>
  w(-33981) → j[191] = <binary 1B: f0>
  w(-33980) → j[192] = '1E2RwOJCQrfaZ7'
  w(-33979) → j[193] = 'game'
  w(-33978) → j[194] = '0IWLPmqXWGwBn'
  w(-33977) → j[195] = <binary 1B: 93>
  w(-33976) → j[196] = 'JshWNO5iJdz7Cy'
  w(-33975) → j[197] = <binary 5B: 4e08eede7e>
  w(-33974) → j[198] = 'W'
  w(-33973) → j[199] = <binary 1B: cc>
  w(-33972) → j[200] = 'type'
  w(-33971) → j[201] = 'R7E38sEVC5hC'
  w(-33970) → j[202] = 'Z1PDS7WvnCEnqD'
  w(-33969) → j[203] = 'random'
  w(-33968) → j[204] = '__gc'
  w(-33967) → j[205] = <binary 1B: fc>
  w(-33966) → j[206] = <binary 4B: 61504d13>
  w(-33965) → j[207] = '__index'
  w(-33964) → j[208] = 'M21RkMGpVmui'
  w(-33963) → j[209] = <binary 9B: 4f60870fdea094c139>
  w(-33962) → j[210] = <binary 3B: cbef18>
  w(-33961) → j[211] = <binary 1B: 88>
  w(-33960) → j[212] = 'TWj7ylXR2BYFS'
  w(-33959) → j[213] = <binary 4B: 1ac031fd>
  w(-33958) → j[214] = <binary 9B: 755ab2437cee2ceeb7>
  w(-33957) → j[215] = <binary 16B: feaa09e288266e8a4d87eb99d7497a2b>
  w(-33956) → j[216] = <binary 6B: a3ff5bf75b32>
  w(-33955) → j[217] = 'hLOOTdCcrLx1k'
  w(-33954) → j[218] = <binary 1B: a6>
  w(-33953) → j[219] = <binary 7B: 8cf24373d430a0>
  w(-33952) → j[220] = 'kdhPCuPEko2n'
  w(-33951) → j[221] = 'GetService'
  w(-33950) → j[222] = <binary 6B: efc31c4f6aa1>
  w(-33949) → j[223] = 'OdBHt8Rbv65u43'
  w(-33948) → j[224] = 'tostring'
  w(-33947) → j[225] = 'isfunctionhooked'
  w(-33946) → j[226] = 'u95VMbZvA9e85'
  w(-33945) → j[227] = 'TvOBnLIZWbO1tK'
  w(-33944) → j[228] = <binary 4B: 04f67b98>
  w(-33943) → j[229] = <binary 2B: 0ad9>
  w(-33942) → j[230] = <binary 10B: cac92f45f082ebeff291>
  w(-33941) → j[231] = 'yQ6AjG'
  w(-33940) → j[232] = <binary 0B: >
  w(-33939) → j[233] = 'ZeBH4XbMCWxy0g'
  w(-33938) → j[234] = <binary 10B: 7f37bbe6727260238939>
  w(-33937) → j[235] = <binary 10B: 8af77a99ab61aa9dba92>
  w(-33936) → j[236] = <binary 11B: 0f7c557f193ba78c3818b3>
  w(-33935) → j[237] = <binary 7B: cdf6d44bc71cbf>
  w(-33934) → j[238] = <binary 2B: 9552>
  w(-33933) → j[239] = <binary 14B: a0e10324bf03c4888245ed63028d>
  w(-33932) → j[240] = 'PEhRgH4HPnGbX'
  w(-33931) → j[241] = <binary 4B: 60144db7>
  w(-33930) → j[242] = <binary 8B: 67657467656e71f2>
  w(-33929) → j[243] = <binary 6B: 6d2db5f2358a>
  w(-33928) → j[244] = <binary 7B: 7f647e0536ac65>
  w(-33927) → j[245] = <binary 4B: 4f58dfe9>
  w(-33926) → j[246] = <binary 8B: 67657466656e71f2>
  w(-33925) → j[247] = '_G'
  w(-33924) → j[248] = <binary 7B: 1423fc82b6eabc>
  w(-33923) → j[249] = <binary 4B: d18b67bf>
  w(-33922) → j[250] = <binary 8B: c79ac6a399230920>
  w(-33921) → j[251] = 'bRwGUGYtI41Jx'
  w(-33920) → j[252] = <binary 4B: 25e7eaa5>
  w(-33919) → j[253] = '''
  w(-33918) → j[254] = ':(%d*):'
  w(-33917) → j[255] = 'OzlH1R8IdgHv7'
  w(-33916) → j[256] = <binary 16B: 8133c20f4189a7be8e354296c604659a>
  w(-33915) → j[257] = 'pairs'
  w(-33914) → j[258] = 'QNXv0eUdHKx4'
  w(-33913) → j[259] = <binary 15B: 426d4f8e102ca4b293468cd18c8947>
  w(-33912) → j[260] = <binary 3B: 6c2fa6>
  w(-33911) → j[261] = <binary 4B: 06d328ed>
  w(-33910) → j[262] = <binary 9B: 48d66d3e2aaaf155cd>
  w(-33909) → j[263] = <binary 1B: c7>
  w(-33908) → j[264] = <binary 14B: 339ff9ecd4581a32332ac40d26e1>
  w(-33907) → j[265] = <binary 10B: e7a88e6b7675ca7252d1>
  w(-33906) → j[266] = <binary 20B: 94a4949113fac5be44ee413fe2e319cb200a86b9>
  w(-33905) → j[267] = <binary 15B: b90f0101f3528a164487f228df305b>
  w(-33904) → j[268] = <binary 14B: 456c41335939474630426a5bb5e5>
  w(-33903) → j[269] = <binary 4B: eae900ac>
  w(-33902) → j[270] = 'BoNs5JTmUlsHdj'
  w(-33901) → j[271] = <binary 1B: 03>
  w(-33900) → j[272] = <binary 1B: ab>
  w(-33899) → j[273] = 'KfZ2vEXHZpgXH'
  w(-33898) → j[274] = <binary 6B: 58b5e00ebd07>
  w(-33897) → j[275] = 'Tamper Detected!'
  w(-33896) → j[276] = <binary 4B: 972a0534>
  w(-33895) → j[277] = <binary 8B: 60d735f8ec59ce02>
  w(-33894) → j[278] = <binary 4B: 47f33a0c>
  w(-33893) → j[279] = 'rTxO5rP6jmti'
  w(-33892) → j[280] = <binary 80B: 9d2ca6f87277a358965c5eaed4a8096b249ea98c>
  w(-33891) → j[281] = <binary 4B: 6ceba3f3>
  w(-33890) → j[282] = <binary 11B: 3b4929999c9a9d120ceaef>
  w(-33889) → j[283] = <binary 5B: dcad559bb5>
  w(-33888) → j[284] = 'FindFirstChild'
  w(-33887) → j[285] = <binary 5B: aca6856946>
  w(-33886) → j[286] = 'aVz3WGxXC6Z8T'
  w(-33885) → j[287] = <binary 8B: 9123382b3a9c75b0>
  w(-33884) → j[288] = 'Play'
  w(-33883) → j[289] = <binary 3B: 3dd5f3>
  w(-33882) → j[290] = <binary 4B: ca055c57>
  w(-33881) → j[291] = <binary 4B: 36c2269c>
  w(-33880) → j[292] = <binary 4B: efc8251b>
  w(-33879) → j[293] = <binary 6B: e9c7acf1808f>
  w(-33878) → j[294] = <binary 4B: 88a2a9b5>
  w(-33877) → j[295] = <binary 4B: a01be0e1>
  w(-33876) → j[296] = <binary 44B: 2a990368f853dd99f13d2dee8afcd7f7d30191e2>
  w(-33875) → j[297] = <binary 4B: 1e9e61d4>
  w(-33874) → j[298] = <binary 3B: 0d1f95>
  w(-33873) → j[299] = <binary 5B: 616ca53f89>
  w(-33872) → j[300] = <binary 44B: f091f7371052da205eeab5cd69ef911ad1666c71>
  w(-33871) → j[301] = <binary 6B: 77677ad3dbd5>
  w(-33870) → j[302] = 'ysQezM4rr3AVtV'
  w(-33869) → j[303] = <binary 4B: 2ccf4557>
  w(-33868) → j[304] = 'gSqNRUBiaV6Olh'
  w(-33867) → j[305] = <binary 7B: 6ac072c2dff206>
  w(-33866) → j[306] = <binary 10B: d6c6f782447242fbe942>
  w(-33865) → j[307] = <binary 8B: b52598dcb3153ae9>
  w(-33864) → j[308] = 'byte'
  w(-33863) → j[309] = <binary 5B: 7aebebdecb>
  w(-33862) → j[310] = <binary 1B: f6>
  w(-33861) → j[311] = <binary 4B: fd3974fd>
  w(-33860) → j[312] = <binary 10B: cb6dd36563f428ba8613>
  w(-33859) → j[313] = <binary 5B: 3ee6740ced>
  w(-33858) → j[314] = <binary 8B: f1c3a78bf702ae70>
  w(-33857) → j[315] = 'wtE61klAG4OJ1'
  w(-33856) → j[316] = <binary 1B: dd>
  w(-33855) → j[317] = <binary 8B: c4030b3a7648da70>
  w(-33854) → j[318] = <binary 22B: 62b2dd19d91b419f910edaf9c561f49c5374de16>
  w(-33853) → j[319] = <binary 6B: 0c1431e00bc5>
  w(-33852) → j[320] = <binary 47B: 32fbc25900d2ebdbc6b35e46633348b459bcca7b>
  w(-33851) → j[321] = 'b8ashv5DvDUbYK'
  w(-33850) → j[322] = <binary 1B: ef>
  w(-33849) → j[323] = <binary 6B: 0fb0133cf057>
  w(-33848) → j[324] = <binary 10B: 663efc93eee269e09ccb>
  w(-33847) → j[325] = <binary 7B: a1db6ff5c7ef47>
  w(-33846) → j[326] = <binary 4B: a3f44523>
  w(-33845) → j[327] = 'h9Jfg77MjTCrs'
  w(-33844) → j[328] = 'l3v4XRj7i2DL'
  w(-33843) → j[329] = 'wunC3zT1BVo5'
  w(-33842) → j[330] = <binary 14B: e5f20892f984b6ea9bae2f857261>
  w(-33841) → j[331] = <binary 5B: 67b5937431>
  w(-33840) → j[332] = <binary 16B: b64e3a06baa72bcc4908277a8afabbde>
  w(-33839) → j[333] = '__len'
  w(-33838) → j[334] = <binary 16B: 7b2fd6856bd4dfa9330a8c4e04a227d6>
  w(-33837) → j[335] = <binary 10B: 0adf2e4be8a0c272cb49>
  w(-33836) → j[336] = <binary 5B: 673893e302>
  w(-33835) → j[337] = <binary 41B: 7812f7c82691cc5e0623bc1981fc525e8758c941>
  w(-33834) → j[338] = <binary 7B: 7975399d2a7ea7>
  w(-33833) → j[339] = 'table'
  w(-33832) → j[340] = 'F'
  w(-33831) → j[341] = 'UrlEncode'
  w(-33830) → j[342] = 'x0Xr0gPTcKID'
  w(-33829) → j[343] = <binary 9B: 1c8077d3cfd101b244>
  w(-33828) → j[344] = <binary 7B: 3047a1ec53ffae>
  w(-33827) → j[345] = 'typeof'
  w(-33826) → j[346] = <binary 4B: 8318f167>
  w(-33825) → j[347] = <binary 6B: 26db9f1e1741>
  w(-33824) → j[348] = 'i2d0IHEM4LmsMp'
  w(-33823) → j[349] = 'AWR0rtFSffF6ZE'
  w(-33822) → j[350] = <binary 3B: f57128>
  w(-33821) → j[351] = <binary 12B: 655a616c1d4714d371464f99>
  w(-33820) → j[352] = 'oyJrifjEJZLi'
  w(-33819) → j[353] = 'rCBKJ5zXlNsAr'
  w(-33818) → j[354] = <binary 7B: 676d61746366a8>
  w(-33817) → j[355] = <binary 1B: 96>
  w(-33816) → j[356] = <binary 4B: c2cac341>
  w(-33815) → j[357] = <binary 7B: d00d1abce423c3>
  w(-33814) → j[358] = 'gsub'
  w(-33813) → j[359] = '='
  w(-33812) → j[360] = <binary 1B: 8b>
  w(-33811) → j[361] = '-'
  w(-33810) → j[362] = 'setclipboard'
  w(-33809) → j[363] = <binary 1B: b3>
  w(-33808) → j[364] = 'l2'
  w(-33807) → j[365] = <binary 11B: 94dd2b75ab793bd0980e8c>
  w(-33806) → j[366] = <binary 5B: 3052b37e96>
  w(-33805) → j[367] = <binary 10B: 905d7696940d160b3fcc>
  w(-33804) → j[368] = <binary 4B: 76192bde>
  w(-33803) → j[369] = <binary 12B: 9b6ed492d352d32f5d4fb728>
  w(-33802) → j[370] = <binary 6B: cb6bcbc2aaca>
  w(-33801) → j[371] = <binary 6B: ba43907a9fd7>
  w(-33800) → j[372] = <binary 8B: cbd077d191fa1088>
  w(-33799) → j[373] = 'task'
  w(-33798) → j[374] = 'Kick'
  w(-33797) → j[375] = <binary 1B: b5>
  w(-33796) → j[376] = <binary 9B: a27fefc8d136e0b9d6>
  w(-33795) → j[377] = <binary 1B: 18>
  w(-33794) → j[378] = 'N6UAZfjFIw6cd'
  w(-33793) → j[379] = <binary 9B: 48dd52a73c79ef0467>
  w(-33792) → j[380] = 'ZDfJ7VLZlGpy'
  w(-33791) → j[381] = <binary 4B: 6008e8ae>
  w(-33790) → j[382] = '61x83ByN3ZXZZG'
  w(-33789) → j[383] = <binary 1B: 9a>
  w(-33788) → j[384] = <binary 8B: abde98a48dc97b10>
  w(-33787) → j[385] = <binary 9B: 029c0caf4965fd592f>
  w(-33786) → j[386] = <binary 10B: 8af42d85655e9b675afe>
  w(-33785) → j[387] = <binary 6B: fc34d66a9eb4>
  w(-33784) → j[388] = <binary 24B: 0f2ef3a5b57cd254de51d0b8e1aa766a3c7e7a42>
  w(-33783) → j[389] = <binary 8B: e2b5cb1c5f6f2f96>
  w(-33782) → j[390] = 'wADCVkt3asvWbG'
  w(-33781) → j[391] = <binary 1B: bc>
  w(-33780) → j[392] = <binary 5B: 1a8683f21a>
  w(-33779) → j[393] = <binary 10B: b473cb10cfc3283eeff2>
  w(-33778) → j[394] = 'KJ1M4ilP1qJsOm'
  w(-33777) → j[395] = <binary 4B: fa22af0b>
  w(-33776) → j[396] = <binary 6B: 837caa61099e>
  w(-33775) → j[397] = <binary 9B: b5bf406c52fdde6a8e>
  w(-33774) → j[398] = <binary 1B: 9f>
  w(-33773) → j[399] = <binary 6B: c2a43d7eb9e1>
  w(-33772) → j[400] = <binary 10B: 83c8daaef919672ded08>
  w(-33771) → j[401] = <binary 5B: dd301fb11d>
  w(-33770) → j[402] = 'PappL3lkmPqUk'
  w(-33769) → j[403] = 'ipairs'
  w(-33768) → j[404] = 'error'
  w(-33767) → j[405] = <binary 3B: 79804d>
  w(-33766) → j[406] = 'Color3'
  w(-33765) → j[407] = 'string'
  w(-33764) → j[408] = <binary 1B: 89>
  w(-33763) → j[409] = <binary 5B: cb9ba2240a>
  w(-33762) → j[410] = <binary 7B: 9e0858b1215e26>
  w(-33761) → j[411] = <binary 4B: 0b875794>
  w(-33760) → j[412] = <binary 4B: ddbdb68a>
  w(-33759) → j[413] = 'HttpGet'
  w(-33758) → j[414] = <binary 4B: e4b4e497>
  w(-33757) → j[415] = 'gdQ5wUfcEEhW'
  w(-33756) → j[416] = 'math'
  w(-33755) → j[417] = <binary 7B: e5704922a09c66>
  w(-33754) → j[418] = <binary 12B: da2d6bfa01254bd7b7bf5b41>
  w(-33753) → j[419] = <binary 4B: 8b36944f>
  w(-33752) → j[420] = <binary 10B: c5411ec1f13671230e9f>
  w(-33751) → j[421] = <binary 2B: 8afb>
  w(-33750) → j[422] = <binary 10B: 607f18a3abaf493f3319>
  w(-33749) → j[423] = 'BJgN4jyfqip5'
  w(-33748) → j[424] = <binary 1B: d7>
  w(-33747) → j[425] = <binary 12B: 00e22c064e45d383a902b2bb>
  w(-33746) → j[426] = 'rcw'
  w(-33745) → j[427] = <binary 9B: b7f8cce6ee8e154f49>
  w(-33744) → j[428] = <binary 1B: 1d>
  w(-33743) → j[429] = <binary 6B: 23b122d5fe47>
  w(-33742) → j[430] = <binary 7B: 23148b213d2205>
  w(-33741) → j[431] = <binary 5B: 56348a2017>
  w(-33740) → j[432] = 'pcall'
  w(-33739) → j[433] = <binary 16B: c667dda82ac7b418ecd9aa174e4a8091>
  w(-33738) → j[434] = 'c3kOH8DFQq0v6u'
  w(-33737) → j[435] = 'GetPlayers'
  w(-33736) → j[436] = 'UDim2'
  w(-33735) → j[437] = 'RXVqPZX6yV7u'
  w(-33734) → j[438] = <binary 11B: 3d3a742dfddb27477035a4>
  w(-33733) → j[439] = '5hpaHMuzz6g4'
  w(-33732) → j[440] = <binary 9B: 5f51b5980208e2b545>
  w(-33731) → j[441] = '8xW3srj2hmH7GT'
  w(-33730) → j[442] = <binary 44B: 6217c5b546a92b9c5f4b1dda6ebcb0d3b423c91a>
  w(-33729) → j[443] = <binary 3B: 63f5ce>
  w(-33728) → j[444] = <binary 15B: 51334845526c665caf2f3e2b808934>
  w(-33727) → j[445] = 'Create'
  w(-33726) → j[446] = 'qP1gNVaFeGmu'
  w(-33725) → j[447] = <binary 10B: c8666d6a843cff86a923>
  w(-33724) → j[448] = <binary 8B: 579f1b0612e17d17>
  w(-33723) → j[449] = <binary 46B: 78b8e357be956f1b62aa19327fbe12505ceedfb8>
  w(-33722) → j[450] = 'Flk5z4Z8huKCS'
  w(-33721) → j[451] = <binary 8B: 7f691a17cc5c9447>
  w(-33720) → j[452] = <binary 3B: 2e3306>
  w(-33719) → j[453] = 'c'
  w(-33718) → j[454] = 'Lerp'
  w(-33717) → j[455] = <binary 1B: f2>
  w(-33716) → j[456] = <binary 6B: d80cc4ca3f85>
  w(-33715) → j[457] = <binary 8B: 4c09ad3314c5c0f1>
  w(-33714) → j[458] = <binary 8B: 343de0c712ad74d9>
  w(-33713) → j[459] = <binary 16B: c3b4ddacdc5e67334b46ac195ec4a698>
  w(-33712) → j[460] = <binary 4B: 27a5c0e9>
  w(-33711) → j[461] = 'Enum'
--]]

--[[
╔══════════════════════════════════════════════════════════════╗
║  5. خريطة حالات الآلة الافتراضية (VM State Map)            ║
╚══════════════════════════════════════════════════════════════╝

Unique destination states: 67
Most targeted states:
  State 3538028: 8 transitions to it
  State 798397: 7 transitions to it
  State 0: 5 transitions to it
  State 244600: 2 transitions to it
  State 11749104: 2 transitions to it
  State 8446674: 2 transitions to it
  State 11024643: 2 transitions to it
  State 16123142: 2 transitions to it
  State 939896: 2 transitions to it
  State 3875469: 2 transitions to it
  State 8754929: 2 transitions to it
  State 8700592: 2 transitions to it
  State 551847: 2 transitions to it
  State 8164605: 2 transitions to it
  State 61: 1 transitions to it
  State 1832632: 1 transitions to it
  State 13311217: 1 transitions to it
  State 5567448: 1 transitions to it
  State 15657715: 1 transitions to it
  State 16364167: 1 transitions to it

Conditional branches: 25
  if <cond> → 13753759 else → 9490551
  if <cond> → 3247466 else → 530266
  if <cond> → 3286621 else → 2414939
  if <cond> → 6609017 else → 11618016
  if <cond> → 4469785 else → 10739070
  if <cond> → 4480913 else → 531053
  if <cond> → 16349376 else → 15540632
  if <cond> → 7162254 else → 15691660
  if <cond> → 7479895 else → 10947362
  if <cond> → 12501617 else → 2431793
  if <cond> → 13161543 else → 14419034
  if <cond> → 4330395 else → 12737404
  if <cond> → 7276068 else → 15221698
  if <cond> → 11737393 else → 16627728
  if <cond> → 5763310 else → 7153999
  if <cond> → 736776 else → 6038829
  if <cond> → 3702371 else → 14776115
  if <cond> → 13805665 else → 2486982
  if <cond> → 16500342 else → 9980560
  if <cond> → 14762014 else → 10402853
  if <cond> → 1670327 else → 1575708
  if <cond> → 14515332 else → 7950622
  if <cond> → 3760843 else → 16123142
  if <cond> → 6732394 else → 2114199
  if <cond> → 8389699 else → 16373456
--]]

-- ============================================================================
-- نهاية السورس الكامل المعاد بناؤه
-- END OF COMPLETE RECONSTRUCTED SOURCE
-- ============================================================================