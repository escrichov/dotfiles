#!/usr/bin/env python3
# encoding: utf-8
"""
setup-login-items.py
This script configures the Login items of current user
"""

import os
import subprocess
import sys


# Apps a añadir como login items (solo se añaden si están instaladas)
loginItems = [
    "/Applications/Dropbox.app",
    "/Applications/Magnet.app",
    "/Applications/CopyLess 2.app",
]


def run_osascript(script):
    """Ejecuta un fragmento AppleScript y devuelve (returncode, stdout)."""
    result = subprocess.run(
        ["osascript", "-e", script],
        capture_output=True,
        text=True,
    )
    return result.returncode, result.stdout.strip(), result.stderr.strip()


# Remove all login items
def remove_all_login_items():
    rc, output, err = run_osascript(
        'tell application "System Events" to get the name of every login item'
    )
    if rc != 0:
        print(err)
        return -1

    current_login_items = [i.strip() for i in output.split(",") if i.strip()]
    for loginItem in current_login_items:
        rc, _, err = run_osascript(
            'tell application "System Events" to delete login item "{}"'.format(loginItem)
        )
        if rc != 0:
            print(err)
            return -1

    return 0


# Create specified login items
def create_login_items(login_items):
    for path in login_items:
        if not os.path.exists(path):
            print("Skipped (not installed): {}".format(path))
            continue
        script = (
            'tell application "System Events" to make login item at end '
            'with properties {{path: "{path}", hidden: false}}'.format(path=path)
        )
        rc, _, err = run_osascript(script)
        if rc != 0:
            print(err)
            return -1

    return 0


error_code = remove_all_login_items()
if error_code != 0:
    print("Failed to remove all Login Items")
    sys.exit(1)

error_code = create_login_items(loginItems)
if error_code != 0:
    print("Failed to create Login Items")
    sys.exit(1)

print("Added Login Items")
