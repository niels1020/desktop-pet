import os
from win32gui import GetWindowRect, GetForegroundWindow
cache = os.getenv('LOCALAPPDATA') + "\\mds.desktop pet"

file = open(cache + "\\window pos.txt", "x")

file.write(str(GetWindowRect(GetForegroundWindow())))
