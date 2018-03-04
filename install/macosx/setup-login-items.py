#!/usr/bin/env python
# encoding: utf-8
"""
setup-login-items.py
This script configures the Login items of current user
"""


import subprocess
import sys


loginItems = [
    '{path: "/Applications/Dropbox.app", hidden:false}',
]


# Remove all login items
def remove_all_login_items():
    all_login_items = ['osascript', '-e', 'tell application "System Events" to get the name of every login item']
    p = subprocess.Popen(all_login_items, bufsize=1, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (output, err) = p.communicate()
    if err == "" and output != "":
        output = output.strip()
        if output != "":
            current_login_items = output.split(',')
            current_login_items = map(str.strip, current_login_items)
        else:
            current_login_items = []
        for loginItem in current_login_items:
            deleteItem = ['osascript', '-e', 'tell application "System Events" to delete login item "{}"'.format(loginItem)]
            p = subprocess.Popen(deleteItem, bufsize=1, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            (output, err) = p.communicate()
            if err != "":
                print(err)
                return -1
    else:
        print(err)
        return -1

    return 0


# Create specified login items
def create_login_items(login_items):
    for item in login_items:
        add_item = [
            'osascript', '-e',
            'tell application "System Events" to make login item at end with properties {item}'.format(item=item)
        ]
        p = subprocess.Popen(add_item, bufsize=1, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (output, err) = p.communicate()
        if err != "":
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
