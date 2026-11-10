#!/usr/bin/env python3
"""Decode the obfuscated string table from HAVEN TEAM V2 script."""

import math
import re
import json

# The "b" decoder table (base64-like mapping char -> value)
D_table = {
    'r': 284023695 % 14948613, '4': 29, 'S': 634717789 % 7131660, 'P': 15,
    '1': 1198379979 % 10605132, 'U': 19, 'E': 45, 'D': 696047909 % 6823999,
    'i': 23, '0': 60, 'N': 27, 'z': 26854750 % 516437,
    '+': 66545986 % 1147344, 'C': 61, '9': 1197611549 % 14785327,
    'a': 346593770 % 1893955, 'p': 12, 'F': 6, 'X': 25,
    's': 1, 'x': 776279967 % 4676385, 'Y': 3369942613 % 13372788,
    'w': 4, '2': 498988161 % 2697233, 'j': 14, 'L': 50,
    'l': 35, 'e': 22, 'R': 32, 't': 41,
    'A': 13, 'b': 45000377 % 529416, 'u': 1468092580 % 11651528,
    'f': 1422838266 % 9360778, '8': 47, 'n': 0, 'k': 2825141124 % 12612237,
    'Z': 7, 'M': 24, '3': 59, 'v': 54,
    'O': 33, 'K': 195318913 % 1490984, '/': 51, 'g': 836098408 % 8709358,
    'm': 53, 'V': 135538562 % 1303255, 'h': 30, '6': 31,
    'd': 3, '7': 55, '5': 16, 'q': 39,
    'o': 20, 'B': 58, 'J': 44, 'c': 1258294663 % 9320701,
    'G': 38, 'I': 1991110209 % 11443162, 'y': 46, 'T': 267761698 % 15750688,
    'H': 8, 'Q': 43, 'W': 18,
}

# The "d" decoder table (base85-like mapping char -> value)
H_table = {
    '^': 71, '[': 40, 'D': 75, '<': 23,
    '+': 54, '8': 63, 'j': 9, 'n': 842061359 % 3523269,
    'k': 81, '%': 31, 'g': 21, '7': 27,
    '5': 10892360 % 187798, 's': 39, 'e': 37, 'l': 20,
    'G': 47, '!': 64, 'u': 26, 'R': 1628029346 % 9146232,
    'q': 3524106048 % 14153036, 'i': 994167677 % 4057827,
    'J': 815466124 % 11170768, '-': 1333153575 % 11694329,
    '*': 19, 'F': 240026035 % 2353196, 'V': 61,
    '\\': 44, '(': 36, '6': 14, 'd': 3,
    '4': 80, 'S': 35, 'W': 321879434 % 3424249,
    'r': 3251898129 % 12853352, 'B': 13, 'X': 49,
    '?': 38, '"': 2837376481 % 11871868, ';': 34,
    'P': 12, ':': 45, '#': 1285224186 % 8683947,
    '.': 481474481 % 12670379, 'C': 46, '/': 66,
    'U': 18, '_': 8, 'N': 1372084001 % 11828310,
    'f': 59, '$': 1377663352 % 16598353, 'I': 1858415083 % 9338769,
    'Q': 587433271 % 4978248, '&': 51, 'A': 25,
    ')': 74, 'm': 82, 'c': 6, 'Z': 2249035492 % 9907645,
    'o': 48, '1': 4, '@': 16, 'L': 24,
    '0': 941067884 % 11618122, 't': 0, ']': 1044897063 % 8780647,
    '=': 42, 'p': 607031425 % 7587892, 'E': 298319289 % 12429969,
    'b': 78, '>': 10, 'Y': 11, ',': 353419502 % 8835487,
    'K': 58, "'": 56, 'T': 3765897712 % 15371011,
    '3': 73748777 % 326322, 'M': 32, '`': 83,
    'a': 55, 'O': 67, '2': 15, 'H': 57,
    'h': 1, '9': 72,
}

# Precompute all table values
for k in list(D_table.keys()):
    D_table[k] = int(D_table[k])
for k in list(H_table.keys()):
    H_table[k] = int(H_table[k])

def decode_b(s):
    """Decode 'b' prefixed string (base64-like)."""
    s = s[1:]  # Remove 'b' prefix
    result = []
    G = 0
    P = 0
    b = 0

    while G < len(s):
        ch = s[G]
        w = D_table.get(ch)
        if w is not None:
            P = P + w * (64 ** (3 - b))
            b += 1
            if b == 4:
                b = 0
                v1 = math.floor(P / 65536)
                v2 = math.floor((P % 65536) / 256)
                v3 = P % 256
                result.append(chr(v1))
                result.append(chr(v2))
                result.append(chr(v3))
                P = 0
        elif ch == '=':
            result.append(chr(math.floor(P / 65536)))
            if G >= len(s) - 1 or s[G + 1] != '=':
                result.append(chr(math.floor((P % 65536) / 256)))
            break
        G += 1

    return ''.join(result)


def decode_d(s):
    """Decode 'd' prefixed string (base85-like)."""
    s = s[1:]  # Remove 'd' prefix
    D_len = len(s)
    result = []
    G = 0

    while G < D_len:
        remaining = D_len - G  # how many chars left
        w = 5 if remaining >= 5 else remaining

        if w <= 1:
            G += w
            continue

        i = 0
        valid = True

        for jj in range(5):  # 0..4
            if jj < w:
                if G + jj >= D_len:
                    valid = False
                    break
                ch = s[G + jj]
                n = H_table.get(ch)
                if n is None:
                    valid = False
                    break
            else:
                n = 84  # padding value
            i = i * 85 + n

        if valid:
            v1 = math.floor(i / 16777216) % 256
            v2 = math.floor(i / 65536) % 256
            v3 = math.floor(i / 256) % 256
            v4 = i % 256

            if w == 5:
                result.append(chr(v1))
                result.append(chr(v2))
                result.append(chr(v3))
                result.append(chr(v4))
            elif w == 4:
                result.append(chr(v1))
                result.append(chr(v2))
                result.append(chr(v3))
            elif w == 3:
                result.append(chr(v1))
                result.append(chr(v2))
            elif w == 2:
                result.append(chr(v1))

        G += w

    return ''.join(result)


def decode_string(s):
    """Decode a string based on its prefix."""
    if not s:
        return s
    if s[0] == 'b':
        return decode_b(s)
    elif s[0] == 'd':
        return decode_d(s)
    return s


# Parse the string table from the file
with open('/root/.claude/uploads/14997886-60c4-5a4d-8d3a-43b176c66be0/43c95ef6-message.txt', 'rb') as f:
    content = f.read()

lines = content.split(b'\r\n')
code = lines[3].decode('latin-1')

# Extract the string table - it starts with {"d8+",... and ends before the first "}local"
# Find the table
table_start = code.index('{')
# Find the matching closing brace - this is tricky with nested braces
# Let's use a simple approach: find all quoted strings in order

# Extract all strings from the table j={...}
# The table uses both , and ; as separators
# Strings are enclosed in double quotes with possible escape sequences

strings = []
i = table_start + 1
in_string = False
current = []
escape = False

while i < len(code):
    ch = code[i]
    if in_string:
        if escape:
            current.append(ch)
            escape = False
        elif ch == '\\':
            escape = True
            current.append(ch)
        elif ch == '"':
            s = ''.join(current)
            # Unescape Lua string escapes
            s = s.replace("\\'", "'")
            s = s.replace('\\"', '"')
            s = s.replace('\\\\', '\\')
            strings.append(s)
            in_string = False
            current = []
        else:
            current.append(ch)
    else:
        if ch == '"':
            in_string = True
            current = []
        elif ch == '}':
            break
    i += 1

print(f"Extracted {len(strings)} strings from table")
print()

# Decode all strings
decoded = []
readable_strings = []
for idx, s in enumerate(strings):
    try:
        d = decode_string(s)
        decoded.append(d)
        # Check if it's printable/readable
        if d and all(32 <= ord(c) < 127 for c in d):
            readable_strings.append((idx, d))
    except Exception as e:
        decoded.append(f"ERROR: {e}")

print(f"Total decoded: {len(decoded)}")
print(f"Readable strings: {len(readable_strings)}")
print()
print("=== ALL READABLE STRINGS ===")
for idx, s in readable_strings:
    print(f"  [{idx}] {s}")

# Also save full decoded table
with open('/tmp/claude-0/-home-user-Evilhereeee/14997886-60c4-5a4d-8d3a-43b176c66be0/scratchpad/decoded_strings.txt', 'w') as f:
    for idx, s in enumerate(decoded):
        f.write(f"[{idx}] {repr(s)}\n")

print("\nFull decoded table saved to decoded_strings.txt")
