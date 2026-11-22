#!/usr/bin/env python3
"""Affiche le bloc LSApplicationQueriesSchemes à coller dans Info.plist,
à partir de Resources/known_apps.json (iOS limite à 50 schémas)."""
import json
import sys

path = sys.argv[1] if len(sys.argv) > 1 else "Resources/known_apps.json"
with open(path, encoding="utf-8") as f:
    apps = json.load(f)

schemes = sorted({a["scheme"] for a in apps})
if len(schemes) > 50:
    sys.exit("Erreur : iOS n'autorise que 50 schémas dans LSApplicationQueriesSchemes.")

print("<key>LSApplicationQueriesSchemes</key>\n<array>")
for s in schemes:
    print(f"    <string>{s}</string>")
print("</array>")
