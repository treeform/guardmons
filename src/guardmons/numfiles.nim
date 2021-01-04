import os

proc getNumberOfOpenFiles(): int =
  let pid = getCurrentProcessId()
  for f in walkDir("/proc/" & $pid & "/fd/"):
    inc result

let f = open("/p/output.txt", fmRead)
echo getNumberOfOpenFiles()
f.close()