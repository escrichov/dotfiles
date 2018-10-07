#!/usr/bin/env python
# encoding: utf-8

import subprocess


app_extensions = [
    ("VLC", ".avi"),
    ("VLC", ".mp4"),
    ("VLC", ".mkv"),
    ("VLC", ".avi"),
    ("VLC", ".mp3"),
    ("VLC", ".wav"),
    ("VLC", ".m4v"),
    ("VLC", ".mpg"),
    ("VLC", ".mpeg"),
    ("VLC", ".wmv"),
    ("VLC", ".flv"),
    ("VLC", ".3gp"),
    ("VLC", ".h264"),

    ("MacDown", ".md"),

    ("TextMate", ".txt"),
    ("TextMate", ".c"),
    ("TextMate", ".h"),
    ("TextMate", ".cpp"),
    ("TextMate", ".hpp"),
    ("TextMate", ".cs"),
    ("TextMate", ".java"),
    ("TextMate", ".sh"),
    ("TextMate", ".java"),
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

    ("Unarchiver", ".tar.gz"),
    ("Unarchiver", ".zip"),
    ("Unarchiver", ".tar"),
    ("Unarchiver", ".gz"),
    ("Unarchiver", ".7z"),
    ("Unarchiver", ".rar"),

    ("calibre", ".epub"),
    ("calibre", ".mobi"),
]


def bind_extension(app, extension):
    whichProcess = ["bind-extension", app, extension]
    p = subprocess.Popen(whichProcess, bufsize=1, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (output, err) = p.communicate()


for app, extension in app_extensions:
    bind_extension(app, extension)
