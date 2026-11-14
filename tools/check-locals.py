#!/usr/bin/env python3
"""يحاكي حد Luau: 200 متغير محلي حي في وقت واحد داخل الدالة الواحدة."""
import sys
from luaparser import ast, astnodes

LIMIT = 200

def decl_count(st):
    if isinstance(st, astnodes.LocalAssign):
        return len(st.targets)
    if isinstance(st, astnodes.LocalFunction):
        return 1
    return 0

def scan_block(stmts, live, worst):
    """live = عدد المتغيرات الحية عند دخول هذه الكتلة."""
    for st in stmts:
        live += decl_count(st)
        if live > worst[0]:
            worst[0] = live
            worst[1] = getattr(st, "line", "?")
        # كتل تشارك نفس فضاء السجلات (مو دوال)
        for sub, extra in sub_blocks(st):
            scan_block(sub, live + extra, worst)
    return worst

def sub_blocks(st):
    out = []
    if isinstance(st, astnodes.Do):
        out.append((st.body.body, 0))
    elif isinstance(st, astnodes.While):
        out.append((st.body.body, 0))
    elif isinstance(st, astnodes.Repeat):
        out.append((st.body.body, 0))
    elif isinstance(st, astnodes.If):
        out.append((st.body.body, 0))
        orelse = st.orelse
        while orelse is not None:
            if isinstance(orelse, astnodes.ElseIf):
                out.append((orelse.body.body, 0))
                orelse = orelse.orelse
            elif isinstance(orelse, astnodes.Block):
                out.append((orelse.body, 0))
                break
            else:
                break
    elif isinstance(st, astnodes.Fornum):
        out.append((st.body.body, 1))
    elif isinstance(st, astnodes.Forin):
        out.append((st.body.body, len(st.targets) + 3))
    return out

def main(path):
    tree = ast.parse(open(path, encoding="utf-8").read())
    mains = [n for n in ast.walk(tree)
             if isinstance(n, astnodes.AnonymousFunction) and len(n.body.body) > 50]
    main_fn = max(mains, key=lambda n: len(n.body.body))
    worst = scan_block(main_fn.body.body, 0, [0, "?"])
    print(f"peak live locals in the main chunk: {worst[0]} (limit {LIMIT})  near line {worst[1]}")
    return 0 if worst[0] <= LIMIT else 1

if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
