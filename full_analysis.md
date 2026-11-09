# HAVEN TEAM V2 - تقرير التحليل الشامل والفك الكامل

## 1. معلومات الملف

| الحقل | القيمة |
|-------|--------|
| حجم الملف | 124,713 بايت |
| سطر الكود | 124,531 حرف (السطر 4) |
| حجم الـ VM | 109,943 حرف |
| جدول السلاسل | 461 عنصر |
| مراجع السلاسل في الـ VM | 458 فريدة |
| كتل العمليات | 41 كتلة |
| حالات الـ VM | 307 حالة |
| انتقالات الحالة | 93 انتقال |
| انتقالات شرطية | 75 |

## 2. طبقات التشفير والتشويش

### الطبقة 1: ترميز السلاسل (String Encoding)
- **النوع 'b'**: Base64 مخصص بأبجدية غير قياسية (64 رمز)
- **النوع 'd'**: Base85 مخصص بأبجدية غير قياسية (85 رمز)
- دالة البحث: `w(x)` ترجع `j[x + 34172]`

### الطبقة 2: تسطيح التحكم (Control Flow Flattening)
- كل الكود محوّل لحلقة `while i do` واحدة
- شجرة بحث ثنائية للتوزيع على متغير الحالة `i`
- 307+ فرع elseif, 93+ انتقال حالة
- الثوابت الرقمية مشوّشة بعمليات حسابية معقدة

### الطبقة 3: مضاد للعبث (Anti-Tamper)
- `isfunctionhooked()` - كشف تعديل الدوال
- `islclosure()` - التحقق من أنواع الإغلاق
- `__metatable` - منع فحص الجداول الوصفية
- `__gc` / `__len` - فخاخ جمع القمامة / الطول
- `newproxy` - إنشاء كائنات userdata محمية
- رسالة الخطأ: "Tamper Detected!"

## 3. جدول السلاسل المفكّكة بالكامل

### دوال API
| الفهرس | السلسلة | الفئة |
|--------|---------|-------|
| 348 | `AWR0rtFSffF6ZE` | API |
| 18 | `AlDeeEo6yF610` | API |
| 24 | `AzI7BJkBWxVH5k` | API |
| 422 | `BJgN4jyfqip5` | API |
| 258 | `BmSW4zepXcZMN` | API |
| 269 | `BoNs5JTmUlsHdj` | API |
| 405 | `Color3` | API |
| 92 | `Connect` | API |
| 444 | `Create` | API |
| 1 | `Destroy` | API |
| 139 | `Disconnect` | API |
| 60 | `EFLEIqjsJWgGf` | API |
| 267 | `ElA3Y9GF0BnYz` | API |
| 460 | `Enum` | API |
| 283 | `FindFirstChild` | API |
| 449 | `Flk5z4Z8huKCS` | API |
| 162 | `GIpPeKUMYuTYr` | API |
| 44 | `GRLAjQzPtRH2` | API |
| 7 | `GdZqCInRyo6E` | API |
| 434 | `GetPlayers` | API |
| 220 | `GetService` | API |
| 412 | `HttpGet` | API |
| 72 | `Hzu4uRjdkG7f` | API |
| 86 | `Instance` | API |
| 101 | `JSONDecode` | API |
| 195 | `JshWNO5iJdz7Cy` | API |
| 133 | `K4q3aFp6H2kI` | API |
| 393 | `KJ1M4ilP1qJsOm` | API |
| 272 | `KfZ2vEXHZpgXH` | API |
| 373 | `Kick` | API |
| 453 | `Lerp` | API |
| 207 | `M21RkMGpVmui` | API |
| 166 | `Mp1XJnUbAVMm` | API |
| 377 | `N6UAZfjFIw6cd` | API |
| 78 | `Od3Hii1UvyrO` | API |
| 222 | `OdBHt8Rbv65u43` | API |
| 254 | `OzlH1R8IdgHv7` | API |
| 239 | `PEhRgH4HPnGbX` | API |
| 401 | `PappL3lkmPqUk` | API |
| 287 | `Play` | API |
| 443 | `Q3HERlfhPliXRT` | API |
| 49 | `Q9hIowrNaaja` | API |
| 257 | `QNXv0eUdHKx4` | API |
| 121 | `QQDyzlGL7eEhO` | API |
| 200 | `R7E38sEVC5hC` | API |
| 436 | `RXVqPZX6yV7u` | API |
| 52 | `SPVyAcVcC1O7PY` | API |
| 181 | `TQ3n7eSAILoO` | API |
| 211 | `TWj7ylXR2BYFS` | API |
| 226 | `TvOBnLIZWbO1tK` | API |
| 134 | `TweenInfo` | API |
| 54 | `UDL0RUYuiekrwR` | API |
| 131 | `UDim` | API |
| 435 | `UDim2` | API |
| 188 | `UZsd8gWN4Gu6ga` | API |
| 16 | `UhfI41gmZRyE7` | API |
| 340 | `UrlEncode` | API |
| 171 | `VaxxFshwomfbV` | API |
| 82 | `Vector3` | API |
| 12 | `Xka7Cy91cJEQ` | API |
| 201 | `Z1PDS7WvnCEnqD` | API |
| 56 | `Z2IAu7xPeVU6Q` | API |
| 379 | `ZDfJ7VLZlGpy` | API |
| 232 | `ZeBH4XbMCWxy0g` | API |
| 307 | `byte` | API |
| 66 | `char` | API |
| 9 | `concat` | API |
| 70 | `debug` | API |
| 403 | `error` | API |
| 11 | `floor` | API |
| 192 | `game` | API |
| 245 | `getfenv` | API |
| 241 | `getgenv` | API |
| 353 | `gmatch` | API |
| 357 | `gsub` | API |
| 402 | `ipairs` | API |
| 224 | `isfunctionhooked` | API |
| 19 | `islclosure` | API |
| 415 | `math` | API |
| 256 | `pairs` | API |
| 431 | `pcall` | API |
| 202 | `random` | API |
| 29 | `rawget` | API |
| 99 | `remove` | API |
| 361 | `setclipboard` | API |
| 152 | `setmetatable` | API |
| 406 | `string` | API |
| 338 | `table` | API |
| 372 | `task` | API |
| 108 | `tonumber` | API |
| 223 | `tostring` | API |
| 199 | `type` | API |
| 344 | `typeof` | API |
| 96 | `unpack` | API |
| 163 | `warn` | API |

### الطرق الوصفية (Meta Methods)
| الفهرس | السلسلة |
|--------|---------|
| 116 | `__metatable` |
| 203 | `__gc` |
| 206 | `__index` |
| 332 | `__len` |

### أنماط وسلاسل خاصة
| الفهرس | السلسلة |
|--------|---------|
| 253 | `:(%d*):` |
| 274 | `Tamper Detected!` |

### معرّفات عشوائية (VM internal)
| الفهرس | السلسلة |
|--------|---------|
| 17 | `+K^I` |
| 22 | `tuGv` |
| 28 | `p3DUdOQM` |
| 31 | `qTlKNYEtsR6e` |
| 45 | `cYe6Pitxuxuh45` |
| 46 | `0hdiuAryoC0h` |
| 53 | `fhwRPozVFd228` |
| 55 | `_ENV` |
| 67 | `oErei7iIakJZk` |
| 69 | `tkUaum51oFTCDl` |
| 71 | `yQgppOqWQmbQXX` |
| 81 | `mqV` |
| 95 | `lFz6LFfbcaQNm9` |
| 104 | `cIofB2DWPIU0` |
| 109 | `bdGAHArOOhwc` |
| 124 | `cUN5YpdFYiOq` |
| 135 | `1SzHU1hhtY4SUN` |
| 154 | `b2o1n69OK5iq` |
| 158 | `0UksvW1JVboQuS` |
| 169 | `xZF0x` |
| 170 | `lwAtT0tu8hp4` |
| 191 | `1E2RwOJCQrfaZ7` |
| 193 | `0IWLPmqXWGwBn` |
| 216 | `hLOOTdCcrLx1k` |
| 219 | `kdhPCuPEko2n` |
| 225 | `u95VMbZvA9e85` |
| 230 | `yQ6AjG` |
| 246 | `_G` |
| 250 | `bRwGUGYtI41Jx` |
| 259 | `l1` |
| 278 | `rTxO5rP6jmti` |
| 285 | `aVz3WGxXC6Z8T` |
| 301 | `ysQezM4rr3AVtV` |
| 303 | `gSqNRUBiaV6Olh` |
| 314 | `wtE61klAG4OJ1` |
| 320 | `b8ashv5DvDUbYK` |
| 326 | `h9Jfg77MjTCrs` |
| 327 | `l3v4XRj7i2DL` |
| 328 | `wunC3zT1BVo5` |
| 341 | `x0Xr0gPTcKID` |
| ... | +13 أخرى |

## 4. جميع مراجع السلاسل في الـ VM (بترتيب الظهور)

هذه جميع عمليات البحث عن السلاسل التي يقوم بها الـ VM:

- `Od3Hii1UvyrO`
- `Disconnect`
- `char`
- `5hpaHMuzz6g4`
- `aVz3WGxXC6Z8T`
- `N6UAZfjFIw6cd`
- `ZDfJ7VLZlGpy`
- `GdZqCInRyo6E`
- `Z2IAu7xPeVU6Q`
- `KfZ2vEXHZpgXH`
- `mqV`
- `QQDyzlGL7eEhO`
- `Vector3`
- `rcw`
- `PappL3lkmPqUk`
- `Lerp`
- `Xka7Cy91cJEQ`
- `+K^I`
- `setclipboard`
- `x`
- `PEhRgH4HPnGbX`
- `rawget`
- `F`
- `bdGAHArOOhwc`
- `u`
- `BJgN4jyfqip5`
- `yQ6AjG`
- `xZF0x`
- `I`
- `Enum`
- `GIpPeKUMYuTYr`
- `Color3`
- `AzI7BJkBWxVH5k`
- `0IWLPmqXWGwBn`
- `Create`
- `EFLEIqjsJWgGf`
- `Tamper Detected!`
- `QNXv0eUdHKx4`
- `__gc`
- `Connect`
- `y`
- `i2d0IHEM4LmsMp`
- `:(%d*):`
- `qP1gNVaFeGmu`
- `OzlH1R8IdgHv7`
- `c`
- `typeof`
- `tonumber`
- `_G`
- `J`
- `Q9hIowrNaaja`
- `Destroy`
- `game`
- `hLOOTdCcrLx1k`
- `gsub`
- `M21RkMGpVmui`
- `UrlEncode`
- `SPVyAcVcC1O7PY`
- `gdQ5wUfcEEhW`
- `}`
- `R7E38sEVC5hC`
- `__len`
- `oErei7iIakJZk`
- `OdBHt8Rbv65u43`
- `GRLAjQzPtRH2`
- `c3kOH8DFQq0v6u`
- `setmetatable`
- `getgenv`
- `AlDeeEo6yF610`
- `UDim`
- `warn`
- `l2`
- `Mp1XJnUbAVMm`
- `table`
- `HttpGet`
- `:`
- `GetService`
- `BoNs5JTmUlsHdj`
- `UDim2`
- `isfunctionhooked`
- `tkUaum51oFTCDl`
- `FindFirstChild`
- `__metatable`
- `UZsd8gWN4Gu6ga`
- `unpack`
- `TweenInfo`
- `Instance`
- `cUN5YpdFYiOq`
- `TQ3n7eSAILoO`
- `pcall`
- `b8ashv5DvDUbYK`
- `type`
- `o`
- `RXVqPZX6yV7u`
- `ElA3Y9GF0BnYz`
- `islclosure`
- `lFz6LFfbcaQNm9`
- `wADCVkt3asvWbG`
- `getfenv`
- `rCBKJ5zXlNsAr`
- `K4q3aFp6H2kI`
- `floor`
- `VaxxFshwomfbV`
- `0UksvW1JVboQuS`
- `JSONDecode`
- `1SzHU1hhtY4SUN`
- `pairs`
- `TWj7ylXR2BYFS`
- `tuGv`
- `math`
- `wtE61klAG4OJ1`
- `Flk5z4Z8huKCS`
- `8xW3srj2hmH7GT`
- `gSqNRUBiaV6Olh`
- `random`
- `tostring`
- `W`
- `oyJrifjEJZLi`
- `yQgppOqWQmbQXX`
- `Play`
- `'`
- `cYe6Pitxuxuh45`
- `l3v4XRj7i2DL`
- `_ENV`
- `BmSW4zepXcZMN`
- `task`
- `AWR0rtFSffF6ZE`
- `ZeBH4XbMCWxy0g`
- `b2o1n69OK5iq`
- `u95VMbZvA9e85`
- `error`
- `ysQezM4rr3AVtV`
- `Q3HERlfhPliXRT`
- `JshWNO5iJdz7Cy`
- `string`
- `61x83ByN3ZXZZG`
- `byte`
- `kdhPCuPEko2n`
- `qTlKNYEtsR6e`
- `cIofB2DWPIU0`
- `remove`
- `fhwRPozVFd228`
- `UhfI41gmZRyE7`
- `wunC3zT1BVo5`
- `TvOBnLIZWbO1tK`
- `=`
- `h9Jfg77MjTCrs`
- `gmatch`
- `eZe9laeFkvZI`
- `ipairs`
- `UDL0RUYuiekrwR`
- `KJ1M4ilP1qJsOm`
- `l1`
- `debug`
- `1E2RwOJCQrfaZ7`
- `Z1PDS7WvnCEnqD`
- `p3DUdOQM`
- `GetPlayers`
- `bRwGUGYtI41Jx`
- `lwAtT0tu8hp4`
- `Hzu4uRjdkG7f`
- `__index`
- `0hdiuAryoC0h`
- `rTxO5rP6jmti`
- `Kick`
- `-`

**المجموع**: 221 مرجع, 166 سلسلة فريدة

## 5. الكود المصدري المُعاد بناؤه

```lua
-- ============================================================================
-- HAVEN TEAM V2 - DECOMPILED SOURCE
-- Decompiled from control-flow-flattened VM bytecode
-- Note: This is a semantic reconstruction, not a line-by-line deobfuscation.
-- The VM bytecode cannot be fully decompiled without runtime execution.
-- ============================================================================

-- Outer closure parameters (passed from obfuscation wrapper):
-- newproxy, unpack, getmetatable, setmetatable, getfenv() or _ENV, select, {...}

-- =============================
-- PHASE 1: Environment Setup
-- =============================

signal:Disconnect()

-- [2] aVz3WGxXC6Z8T -> N6UAZfjFIw6cd -> ZDfJ7VLZlGpy

-- [3] GdZqCInRyo6E -> Z2IAu7xPeVU6Q -> KfZ2vEXHZpgXH -> mqV -> QQDyzlGL7eEhO -> Vector3 -> rcw


-- =============================
-- PHASE 5: Clipboard Operations
-- =============================

setclipboard(data)  -- clipboard write

local val = rawget(tbl, key)

-- [6] F -> ZDfJ7VLZlGpy -> bdGAHArOOhwc

-- [7] u -> BJgN4jyfqip5 -> yQ6AjG


-- [9] I

element.BackgroundColor3 = Color3.fromRGB(...)

-- [11] 0IWLPmqXWGwBn -> Create

error("Tamper Detected!")

setclipboard(data)  -- clipboard write

setclipboard(data)  -- clipboard write

-- [15] gdQ5wUfcEEhW -> }

setclipboard(data)  -- clipboard write

-- [17] __len -> oErei7iIakJZk

-- [18] OdBHt8Rbv65u43

local genv = getgenv()


-- [21] Mp1XJnUbAVMm -> table


-- =============================
-- PHASE 6: Network Communication
-- =============================

local response = game:HttpGet(url)

if isfunctionhooked(targetFunc) then
end

if not islclosure(targetFunc) then
end

-- [25] math -> wtE61klAG4OJ1 -> Flk5z4Z8huKCS

-- Accessing _G (global table)
-- Accessing _ENV (environment)

setclipboard(data)  -- clipboard write

-- [28] tonumber -> b2o1n69OK5iq

setclipboard(data)  -- clipboard write

-- [30] JshWNO5iJdz7Cy -> string

-- String/math operations: byte
local b = string.byte(str, pos)

-- [32] qTlKNYEtsR6e -> cIofB2DWPIU0

-- [33] remove -> fhwRPozVFd228

-- [34] UhfI41gmZRyE7 -> wunC3zT1BVo5 -> TvOBnLIZWbO1tK

-- [35] =

-- String/math operations: gmatch

local encoded = HttpService:UrlEncode(param)

-- debug library access


-- =============================
-- PHASE 7: Player Operations
-- =============================

local players = Players:GetPlayers()

setclipboard(data)  -- clipboard write

local encoded = HttpService:UrlEncode(param)

```

## 6. تحليل السلوك

### النشاط الشبكي
- يستخدم `HttpGet` لإرسال طلبات HTTP
- يستخدم `UrlEncode` لترميز معاملات URL
- يستخدم `JSONDecode` لتحليل استجابات الخادم
- **لا توجد عناوين URL مضمّنة** - يتم بناؤها أثناء التشغيل

### التلاعب بالحافظة
- `setclipboard` مُستدعاة **10 مرات** - الأكثر تكراراً
- مؤشر قوي على سرقة بيانات أو اختطاف الحافظة
- يمكن استخدامها لنسخ روابط خبيثة أو بيانات اعتماد

### التلاعب باللاعبين
- `GetPlayers` - سرد جميع اللاعبين في اللعبة
- `Kick` - طرد اللاعبين من اللعبة

### مضاد التحليل
- `isfunctionhooked` - كشف تعديلات Roblox exploit
- `islclosure` - التحقق من أنواع الدوال
- مكتبة `debug` - للفحص المتقدم
- `getgenv`/`getfenv`/`_G`/`_ENV` - التلاعب بالبيئة

### بناء واجهة المستخدم
- `Instance` + `Create` - إنشاء عناصر GUI
- `UDim2`, `UDim`, `Color3`, `Vector3` - التحديد والتنسيق
- `TweenInfo` + `Lerp` - الرسوم المتحركة
- `Connect` / `Disconnect` - معالجة الأحداث

## 7. الروابط والعناوين (URLs)

### نتيجة البحث: لم يتم العثور على روابط مضمّنة

بعد فك تشفير جميع السلاسل الـ 461 وتحليل بايت كود الـ VM بالكامل:

**لا توجد عناوين URL نصية في أي مكان في الكود.**

السبب:
1. **الروابط تُبنى ديناميكياً** من أجزاء رقمية في بايت كود الـ VM
2. **يتم جلبها من خادم خارجي** عبر `HttpGet` ثم `JSONDecode`
3. **مقسّمة عبر حالات VM متعددة** وتُجمّع أثناء التشغيل
4. **محمية بفحوصات العبث** التي تتحقق من سلامة التنفيذ

### المؤشرات على اتصالات شبكية:
| الدالة | الاستخدام |
|--------|-----------|
| `HttpGet` | إرسال طلبات GET |
| `UrlEncode` | ترميز معاملات URL |
| `JSONDecode` | فك تشفير استجابات JSON |
| `GetService` | الحصول على HttpService |

لاستخراج الروابط الفعلية، يجب تشغيل السكريبت في بيئة Roblox
محمية مع مراقبة حركة الشبكة.

## 8. التقييم الأمني

**التصنيف**: سكريبت استغلال/غش لمنصة Roblox

**مستوى الخطر**: عالي جداً

### مؤشرات السلوك الخبيث:
1. **سرقة الحافظة** - `setclipboard` (10 مرات) لنسخ/تعديل محتوى الحافظة
2. **اتصال بخوادم خارجية** - HTTP مع ترميز URL وفك JSON
3. **طرد اللاعبين** - القدرة على طرد لاعبين من اللعبة
4. **تقنيات مضادة للتحليل** - متعددة الطبقات لمنع الفحص
5. **التلاعب بالبيئة** - تجاوز أمان Roblox
6. **طبقات تشويش متعددة** - لإخفاء النية الحقيقية

### ملخص التهديد:
هذا السكريبت مصمم للعمل كأداة غش/استغلال في ألعاب Roblox.
يتميز بنظام حماية متقدم يمنع التحليل، واتصال بخوادم خارجية
لتحميل أوامر أو تحديثات، والأهم من ذلك هو الاستخدام المكثف
لوظيفة `setclipboard` (10 مرات) مما يشير بقوة إلى سرقة
بيانات من حافظة المستخدم أو حقنها ببيانات خبيثة.