import osproc, os

var cmdLine = ""
for i in 0..paramCount():
  if i == 0: continue
  if i > 1: cmdLine.add " "
  cmdLine.add paramStr(i)

while true:
  discard execCmd(cmdLine)
  sleep(1000)
