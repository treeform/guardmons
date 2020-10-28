## Simply loops the command line, waiting 1 second in between
## Example:
## loopman myprogram

import osproc, os

var cmdLine = ""
for i in 0..paramCount():
  if i == 0: continue
  if i > 1: cmdLine.add " "
  cmdLine.add paramStr(i)

while true:
  discard execCmd(cmdLine)
  sleep(1000)
