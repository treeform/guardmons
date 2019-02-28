# Simple utility that takes a file a command to watch and reruns it when any of the files there change.
# Example:
# watchmon --watch:"*.nim" --command:"nim c main.nim"


import os, osproc, streams, strutils, tables, times, parseopt2


var
  watching = newTable[string, int64]()
  command: string

proc watchDirOrFile(pattern: string) =
  for fileName in walkPattern(pattern):
    if existsFile(fileName):
      watching[fileName] = 0
    else:
      quit("Can't watch " & fileName & " does not exist.")


for kind, key, val in getopt():
  # this will iterate over all arguments passed to the cmdline.
  # echo kind, key, val
  if key == "watch" or key == "w":
    watchDirOrFile(val)
  if key == "command" or key == "c":
    command = val


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
        runCommand = true
  if runCommand:
    discard execShellCmd(command)
  sleep(100)
