## List processes matching a pattern (cross platform "ps aux | grep" that works on windows)

## Example:
## List all processes:
## > topmon
## List all process with chrome:
## > topmon -p chrome
## List all process with chrome and kill them:
## > topmon -p chrome -k
## List all process with chrome and kill the 8th one:
## > topmon -p chrome -k 8

import os, osproc, streams, strutils, tables, times, parseopt, strformat, algorithm


when defined(nimscript):
  discard
elif defined(windows):
  import winlean, times
elif defined(posix):
  import posix, times

proc getCurrentProcessId*(): int =
  ## return current process ID. See also ``osproc.processID(p: Process)``.
  when defined(windows):
    proc GetCurrentProcessId(): DWORD {.stdcall, dynlib: "kernel32",
                                        importc: "GetCurrentProcessId".}
    result = GetCurrentProcessId().int
  else:
    result = getpid()


type ProcessEntry = object
  name: string
  path: string
  commandLine: string
  pid: int
  parentPid: int

var entries = newSeq[ProcessEntry]()

when defined(windows):
  type
    Heading = object
      name: string
      start: int
      stop: int

  let (data, code) = execCmdEx("WMIC path win32_process get Caption,ExecutablePath,ProcessId,CommandLine,CreationDate,ParentProcessId")
  var headings = newSeq[Heading]()
  var lines = data.split("\n")
  for i, process in lines:
    if i == 0:
      var word = ""
      for j, c in process:
        if c != ' ':
          word.add c
        else:
          if word.len > 0:
            let at = j - word.len
            if headings.len > 0:
              headings[^1].stop = at
            headings.add(Heading(name: word, start: at))
            word = ""
      if headings.len > 0:
        headings[^1].stop = 100000
    else:
      if process.len > 0:
        var entry = ProcessEntry()
        var j = 0
        for heading in headings:
          let value = process[heading.start..<min(process.len, heading.stop)].strip()
          #echo heading.name, ":", value
          case heading.name:
            of "Caption": entry.name = value
            of "ProcessId": entry.pid = parseInt(value)
            of "CommandLine": entry.commandLine = value
            of "ExecutablePath": entry.path = value
            else:
              discard
        entries.add(entry)

else:
  let (data, code) = execCmdEx("ps aux")
  var
    i = 0
    header: seq[string]
  for line in data.split("\n"):
    if i == 0:
      header = line.splitWhitespace()
    else:
      var entry = ProcessEntry()
      var j = 0
      for value in line.splitWhitespace(header.len-1):
        case header[j]:
          of "PID": entry.pid = parseInt(value)
          of "COMMAND":
            entry.commandLine = value
            entry.path = entry.commandLine.split(" ")[0]
            entry.name = entry.path.split("/")[^1]
          else: discard
        inc j
      entries.add(entry)
    inc i


entries.sort proc(a,b: ProcessEntry): int = cmp(a.name, b.name)


const
  KILL_NONE = -2
  KILL_ALL = -1
var
  patterns: seq[string]
  killPid = KILL_NONE
  color = true


for kind, key, value in getopt():
  if key == "pattern" or key == "p":
    patterns.add(value)
  if key == "monochrome" or key == "m":
    color = false
  if key == "kill" or key == "k":
    if value == "":
      killPid = KILL_ALL
    else:
      killPid = parseInt(value)

var n = 0
for entry in entries:
  if getCurrentProcessId() == entry.pid:
    continue
  var outline = if color:
     &"[\e[34m{n:>2}\e[39m] \e[31m{entry.pid:>8} \e[32m{entry.name:<40} \e[39m{entry.commandLine}"
  else:
    &"[{n:>2} {entry.pid:>8} {entry.name:<40} {entry.commandLine}"
  if patterns.len > 0:
    var match = false
    for pattern in patterns:
      if pattern.toLowerAscii() in outline.toLowerAscii():
        match = true
        break
    if match:
      if killPid == n or killPid == KILL_ALL:
        outline[5] = 'K'
        when defined(windows):
          let (data, code) = execCmdEx("taskkill /F /PID " & $entry.pid)
        else:
          echo "killing:", entry.pid
          let (data, code) = execCmdEx("kill -9 " & $entry.pid)
      echo outline
      inc n
  else:
    echo outline
    inc n

