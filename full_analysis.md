# HAVEN TEAM V2 - التحليل الأمني الكامل
# Complete Security Analysis

## ⚠️ تحذير: سكريبت خبيث (Malicious Script Warning)

هذا السكريبت هو **أداة اختراق/غش لـ Roblox** مشفرة بعدة طبقات حماية.

## الملخص التنفيذي (Executive Summary)

| الخاصية | القيمة |
|---------|--------|
| حجم الملف | 124,531 حرف |
| السلاسل المشفرة | 461 |
| السلاسل المقروءة | 157 |
| حالات VM | 67 فريدة |
| انتقالات الحالة | 95 |
| فروع شرطية | 25 |
| نقطة الدخول | state 4015136 |
| تشفير Base64 | أبجدية مخصصة (64 حرف) |
| تشفير Base85 | أبجدية مخصصة (85 حرف) |
| w(x) offset | j[x + 34172] |

## طبقات التشفير (Encryption Layers)

1. **Base64 مخصص** (بادئة 'b'): أبجدية 64 حرف غير قياسية
2. **Base85 مخصص** (بادئة 'd'): أبجدية 85 حرف
3. **تسطيح تدفق التحكم**: آلة حالات بشجرة بحث ثنائية
4. **تشويش أرقام**: تعبيرات حسابية بدل أرقام مباشرة
5. **نظام مراجع**: O[]/H[] لإدارة الذاكرة والتشويش

## السلوكيات الخبيثة (Malicious Behaviors)

### 🔴 سرقة الحافظة (Clipboard Theft)
- `setclipboard` يُستدعى **17 مرة** - الأكثر استدعاءً في السكريبت
- يجمع بيانات من اللاعبين واللعبة
- يستخدم `UrlEncode` لترميز البيانات (3 مرات)

### 🔴 اتصال بالشبكة (Network Communication)
- `HttpGet`: تحميل بيانات/أوامر من خادم خارجي
- `JSONDecode`: فك ترميز الاستجابة
- URLs مبنية في وقت التشغيل عبر `string.char`/`string.byte`

### 🔴 مكافحة التلاعب (Anti-Tamper)
- `isfunctionhooked()`: يكشف إذا كانت الدوال مُعترضة
- `islclosure()`: يتحقق من أصالة الدوال
- `Kick('Tamper Detected!')`: يطرد اللاعب عند الكشف

### 🔴 تلاعب بالبيئة (Environment Manipulation)
- `getgenv()`: الوصول لبيئة exploit المشتركة
- `getfenv()`: الوصول لبيئة الدالة
- `_G`: جدول المتغيرات العامة

## جدول السلاسل المصنف (Categorized String Table)

### Exploit API

| Index | w() | String |
|-------|-----|--------|
| 20 | w(-34152) | `islclosure` |
| 30 | w(-34142) | `rawget` |
| 153 | w(-34019) | `setmetatable` |
| 225 | w(-33947) | `isfunctionhooked` |
| 362 | w(-33810) | `setclipboard` |
| 413 | w(-33759) | `HttpGet` |

### Anti-Tamper Messages

| Index | w() | String |
|-------|-----|--------|
| 275 | w(-33897) | `Tamper Detected!` |

### Network API

| Index | w() | String |
|-------|-----|--------|
| 341 | w(-33831) | `UrlEncode` |

### Roblox Services

| Index | w() | String |
|-------|-----|--------|
| 193 | w(-33979) | `game` |

### Roblox Methods

| Index | w() | String |
|-------|-----|--------|
| 2 | w(-34170) | `Destroy` |
| 93 | w(-34079) | `Connect` |
| 140 | w(-34032) | `Disconnect` |
| 221 | w(-33951) | `GetService` |
| 284 | w(-33888) | `FindFirstChild` |
| 288 | w(-33884) | `Play` |
| 374 | w(-33798) | `Kick` |
| 435 | w(-33737) | `GetPlayers` |
| 445 | w(-33727) | `Create` |

### Roblox Types

| Index | w() | String |
|-------|-----|--------|
| 83 | w(-34089) | `Vector3` |
| 87 | w(-34085) | `Instance` |
| 132 | w(-34040) | `UDim` |
| 135 | w(-34037) | `TweenInfo` |
| 406 | w(-33766) | `Color3` |
| 436 | w(-33736) | `UDim2` |
| 461 | w(-33711) | `Enum` |

### Lua Standard Library

| Index | w() | String |
|-------|-----|--------|
| 97 | w(-34075) | `unpack` |
| 109 | w(-34063) | `tonumber` |
| 164 | w(-34008) | `warn` |
| 200 | w(-33972) | `type` |
| 224 | w(-33948) | `tostring` |
| 257 | w(-33915) | `pairs` |
| 339 | w(-33833) | `table` |
| 345 | w(-33827) | `typeof` |
| 373 | w(-33799) | `task` |
| 403 | w(-33769) | `ipairs` |
| 404 | w(-33768) | `error` |
| 407 | w(-33765) | `string` |
| 416 | w(-33756) | `math` |
| 432 | w(-33740) | `pcall` |

### Metatable Keys

| Index | w() | String |
|-------|-----|--------|
| 204 | w(-33968) | `__gc` |
| 207 | w(-33965) | `__index` |
| 333 | w(-33839) | `__len` |

### String/Math Operations

| Index | w() | String |
|-------|-----|--------|
| 10 | w(-34162) | `concat` |
| 12 | w(-34160) | `floor` |
| 67 | w(-34105) | `char` |
| 203 | w(-33969) | `random` |
| 308 | w(-33864) | `byte` |
| 358 | w(-33814) | `gsub` |

### Other Identifiers

| Index | w() | String |
|-------|-----|--------|
| 3 | w(-34169) | `x` |
| 8 | w(-34164) | `GdZqCInRyo6E` |
| 13 | w(-34159) | `Xka7Cy91cJEQ` |
| 17 | w(-34155) | `UhfI41gmZRyE7` |
| 18 | w(-34154) | `+K^I` |
| 19 | w(-34153) | `AlDeeEo6yF610` |
| 23 | w(-34149) | `tuGv` |
| 25 | w(-34147) | `AzI7BJkBWxVH5k` |
| 45 | w(-34127) | `GRLAjQzPtRH2` |
| 49 | w(-34123) | `o` |
| 50 | w(-34122) | `Q9hIowrNaaja` |
| 53 | w(-34119) | `SPVyAcVcC1O7PY` |
| 55 | w(-34117) | `UDL0RUYuiekrwR` |
| 56 | w(-34116) | `_ENV` |
| 57 | w(-34115) | `Z2IAu7xPeVU6Q` |
| 61 | w(-34111) | `EFLEIqjsJWgGf` |
| 63 | w(-34109) | `u` |
| 71 | w(-34101) | `debug` |
| 73 | w(-34099) | `Hzu4uRjdkG7f` |
| 78 | w(-34094) | `y` |
| 79 | w(-34093) | `Od3Hii1UvyrO` |
| 82 | w(-34090) | `mqV` |
| 100 | w(-34072) | `remove` |
| 114 | w(-34058) | `J` |
| 122 | w(-34050) | `QQDyzlGL7eEhO` |
| 134 | w(-34038) | `K4q3aFp6H2kI` |
| 165 | w(-34007) | `I` |
| 167 | w(-34005) | `Mp1XJnUbAVMm` |
| 170 | w(-34002) | `xZF0x` |
| 172 | w(-34000) | `VaxxFshwomfbV` |
| 182 | w(-33990) | `TQ3n7eSAILoO` |
| 189 | w(-33983) | `UZsd8gWN4Gu6ga` |
| 196 | w(-33976) | `JshWNO5iJdz7Cy` |
| 198 | w(-33974) | `W` |
| 201 | w(-33971) | `R7E38sEVC5hC` |
| 202 | w(-33970) | `Z1PDS7WvnCEnqD` |
| 208 | w(-33964) | `M21RkMGpVmui` |
| 212 | w(-33960) | `TWj7ylXR2BYFS` |
| 223 | w(-33949) | `OdBHt8Rbv65u43` |
| 227 | w(-33945) | `TvOBnLIZWbO1tK` |
| 231 | w(-33941) | `yQ6AjG` |
| 233 | w(-33939) | `ZeBH4XbMCWxy0g` |
| 240 | w(-33932) | `PEhRgH4HPnGbX` |
| 254 | w(-33918) | `:(%d*):` |
| 255 | w(-33917) | `OzlH1R8IdgHv7` |
| 258 | w(-33914) | `QNXv0eUdHKx4` |
| 270 | w(-33902) | `BoNs5JTmUlsHdj` |
| 273 | w(-33899) | `KfZ2vEXHZpgXH` |
| 340 | w(-33832) | `F` |
| 349 | w(-33823) | `AWR0rtFSffF6ZE` |
| 378 | w(-33794) | `N6UAZfjFIw6cd` |
| 380 | w(-33792) | `ZDfJ7VLZlGpy` |
| 394 | w(-33778) | `KJ1M4ilP1qJsOm` |
| 402 | w(-33770) | `PappL3lkmPqUk` |
| 423 | w(-33749) | `BJgN4jyfqip5` |
| 426 | w(-33746) | `rcw` |
| 437 | w(-33735) | `RXVqPZX6yV7u` |
| 450 | w(-33722) | `Flk5z4Z8huKCS` |
| 453 | w(-33719) | `c` |
| 454 | w(-33718) | `Lerp` |

## إحصائيات الاستدعاءات (Call Statistics)

| الدالة | عدد المراجع |
|--------|------------|
| `-` | 17 |
| `UhfI41gmZRyE7` | 10 |
| `M21RkMGpVmui` | 6 |
| `Vector3` | 5 |
| `KJ1M4ilP1qJsOm` | 4 |
| `o` | 3 |
| `F` | 3 |
| `` | 2 |
| `mqV` | 2 |
| `Q9hIowrNaaja` | 2 |
| `setclipboard` | 2 |
| `Mp1XJnUbAVMm` | 2 |
| `remove` | 2 |
| `FindFirstChild` | 2 |
| `UrlEncode` | 2 |

## خريطة الحالات الأكثر استهدافاً (Most Targeted States)

| State | Transitions To |
|-------|---------------|
| 3538028 | 8 |
| 798397 | 7 |
| 0 | 5 |
| 244600 | 2 |
| 11749104 | 2 |
| 8446674 | 2 |
| 11024643 | 2 |
| 16123142 | 2 |
| 939896 | 2 |
| 3875469 | 2 |
| 8754929 | 2 |
| 8700592 | 2 |
| 551847 | 2 |
| 8164605 | 2 |
| 61 | 1 |

## الفروع الشرطية (Conditional Branches)

- if `<condition>` → state 13753759 else → state 9490551
- if `<condition>` → state 3247466 else → state 530266
- if `<condition>` → state 3286621 else → state 2414939
- if `<condition>` → state 6609017 else → state 11618016
- if `<condition>` → state 4469785 else → state 10739070
- if `<condition>` → state 4480913 else → state 531053
- if `<condition>` → state 16349376 else → state 15540632
- if `<condition>` → state 7162254 else → state 15691660
- if `<condition>` → state 7479895 else → state 10947362
- if `<condition>` → state 12501617 else → state 2431793
- if `<condition>` → state 13161543 else → state 14419034
- if `<condition>` → state 4330395 else → state 12737404
- if `<condition>` → state 7276068 else → state 15221698
- if `<condition>` → state 11737393 else → state 16627728
- if `<condition>` → state 5763310 else → state 7153999
- if `<condition>` → state 736776 else → state 6038829
- if `<condition>` → state 3702371 else → state 14776115
- if `<condition>` → state 13805665 else → state 2486982
- if `<condition>` → state 16500342 else → state 9980560
- if `<condition>` → state 14762014 else → state 10402853
- if `<condition>` → state 1670327 else → state 1575708
- if `<condition>` → state 14515332 else → state 7950622
- if `<condition>` → state 3760843 else → state 16123142
- if `<condition>` → state 6732394 else → state 2114199
- if `<condition>` → state 8389699 else → state 16373456

---
*تم التحليل بواسطة Deep VM Trace Decompiler*
*Analysis generated by Deep VM Trace Decompiler*
