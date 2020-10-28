# Simple utility that watches a pattern of files for changes and copies then when they change.
# You can think of it as real time rsync

# copymon --watch:"*.nim" --address:"me@server.com:/file/path"

import os, osproc, streams, strutils, tables, times, parseopt, strformat

var
  watching = newTable[string, int64]()
  address: string

proc watchDirOrFile(pattern: string) =
  for fileName in walkPattern(pattern):
    if existsFile(fileName):
      echo "* init ", fileName
      watching[fileName] = 0
    else:
      quit("Can't watch " & fileName & " does not exist.")


for kind, key, val in getopt():
  if key == "watch" or key == "w":
    watchDirOrFile(val)
  if key == "address" or key == "a":
    address = val


proc run(command: string) =
  echo command
  discard execShellCmd(command)


while true:
  var runCommand = false
  for fileName, fileTime in watching.mpairs:
    if existsFile(fileName):
      let lastWriteTime = getFileInfo(fileName).lastWriteTime.toUnix()
      if lastWriteTime != fileTime:
        if fileTime == 0:
          echo "* watching ", fileName
        else:
          echo "* changed ", fileName
        fileTime = lastWriteTime
        let command = &"scp {fileName} {address}/{fileName}"
        run(command)

  sleep(100)
