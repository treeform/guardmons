# Simple utility that takes a file a command to watch and reruns it when any of the files there change.

# watchman - watches for changes and re runs commands
# killman  - kills processes, prevents some from running
# deman    - domonizes programs, makes sure that start on restart
# cronman  - runs a commands at spesific times

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
  # this will iterate over all arguments passed to the cmdline.
  # echo kind, key, val
  if key == "watch" or key == "w":
    watchDirOrFile(val)
  if key == "address" or key == "a":
    address = val


proc run(command: string) =
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
        let command = &"scp {fileName} {address}/{fileName} &"
        run(command)
        #echo command
        #var t = Thread[string]()
        #createThread[string](t, run, command)
        #discard execShellCmd(command)

  sleep(100)
