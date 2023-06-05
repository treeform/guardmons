## Demonizes a process
## Example:
## daemon server

import osproc, os, posix, io

# grab full command line
var cmdLine = ""
for i in 0..paramCount():
  if i == 0: continue
  if i > 1: cmdLine.add " "
  cmdLine.add paramStr(i)

# fork
let pid = posix.fork()
if pid < 0:
  quit(QuitFailure)
if pid > 0:
  quit(QuitSuccess)

# set the mask
discard posix.umask(0)

# set sid
let sid = posix.setsid()
if sid < 0:
  quit(QuitFailure)

# set cwd
setCurrentDir("/")

# set signals
posix.signal(SIGCHLD, SIG_IGN)

# close handles
stdout.reopen("/dev/null", fmWrite)
stderr.reopen("/dev/null", fmWrite)
stdin.reopen("/dev/null", fmRead)

while true:
  discard execCmd(cmdLine)
  sleep(1000)
