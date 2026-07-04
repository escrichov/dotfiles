#!/usr/bin/env python3
# encoding: utf-8

import subprocess


app_extensions = [
    ("IINA", ".avi"),
    ("IINA", ".mp4"),
    ("IINA", ".mkv"),
    ("IINA", ".mp3"),
    ("IINA", ".wav"),
    ("IINA", ".m4v"),
    ("IINA", ".mpg"),
    ("IINA", ".mpeg"),
    ("IINA", ".wmv"),
    ("IINA", ".flv"),
    ("IINA", ".3gp"),
    ("IINA", ".h264"),

    ("TextMate", ".txt"),
    ("TextMate", ".c"),
    ("TextMate", ".h"),
    ("TextMate", ".cpp"),
    ("TextMate", ".hpp"),
    ("TextMate", ".cs"),
    ("TextMate", ".java"),
    ("TextMate", ".sh"),
    ("TextMate", ".php"),
    ("TextMate", ".js"),
    ("TextMate", ".py"),
    ("TextMate", ".rb"),
    ("TextMate", ".html"),
    ("TextMate", ".css"),
    ("TextMate", ".scss"),
    ("TextMate", ".csv"),
    ("TextMate", ".sql"),
    ("TextMate", ".log"),

    ("Preview", ".jpeg"),
    ("Preview", ".jpg"),
    ("Preview", ".png"),
    ("Preview", ".gif"),
    ("Preview", ".ico"),
    ("Preview", ".tiff"),
    ("Preview", ".tif"),
    ("Preview", ".svg"),
    ("Preview", ".pdf"),

    ("The Unarchiver", ".zip"),
    ("The Unarchiver", ".tar"),
    ("The Unarchiver", ".gz"),
    ("The Unarchiver", ".7z"),
    ("The Unarchiver", ".rar"),

    ("calibre", ".epub"),
    ("calibre", ".mobi"),

    ("poedit", ".po"),
]


def bind_extension(app, extension):
    whichProcess = ["bind-extension", app, extension]
    p = subprocess.Popen(whichProcess, bufsize=1, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (output, err) = p.communicate()


for app, extension in app_extensions:
    bind_extension(app, extension)
