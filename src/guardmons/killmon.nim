## Watches the processes that misbehave and kills them
## kind of like oom killer on linux but with more options and cross platform.

import os, strutils, strformat, posix, tables

type ProcState = enum
  psRunning
  psSleeping
  psWaiting
  psZombie
  psStopped
  psTracing
  psPaging
  psDead
  psWakekill
  psWaking
  psParked
  psUnkown

proc states(state: string): ProcState =
  case state:
  of "R": psRunning
  of "S": psSleeping
  of "D": psWaiting
  of "Z": psZombie
  of "T": psStopped
  of "t": psTracing
  of "X": psDead
  of "x": psDead
  of "K": psWakekill
  of "W": psWaking
  of "P": psParked
  else: psUnkown

let hz = sysconf(SC_CLK_TCK).float64
let perPage = sysconf(SC_PAGE_SIZE)


var prevCPU: Table[int, float]
var avg1: Table[int, float]
var avg10: Table[int, float]
var avg60: Table[int, float]

while true:
  #echo "\ec"
  #echo "These processes are getting close to being killed:"
  #echo "pid       1s       10s      60s      memory name"

  for (k, f) in walkDir("/proc"):
    if f[^1].isDigit():
      var stat: seq[string]
      try:
        stat = readFile(f / "stat").split(" ")
      except:
        continue
      let
        pid = stat[0].parseInt
        exeName = stat[1][1 .. ^2]
        procState = states(stat[2])
        parentPid = stat[3]
        groupID = stat[4]
        sessionID = stat[5]
        controllingTerminal = stat[6]
        foregroundProcessGroupID = stat[7]
        kernelFlags = stat[8]
        minorFaultsNum = stat[9]
        childMinorFaultsNum = stat[10]
        majorFaultsNum = stat[11]
        childMajorFaultsNum = stat[12]
        userModeTime = stat[13].parseFloat / hz
        kernelModeTime = stat[14].parseFloat / hz
        childUserModeTime = stat[15].parseFloat / hz
        childKernelModeTime = stat[16].parseFloat / hz
        chedulingPriority = stat[17]
        niceValue = stat[18]
        threadNum = stat[19]
        # _ = stat[20]
        startTime = stat[21]
        virtualMemorySize = stat[22].parseInt
        realPageNum = stat[23].parseInt
        softLimit = stat[24]

      var cpu = userModeTime + kernelModeTime
      var memory = realPageNum * perPage
      var memoryG = memory.float / 1024 / 1024 / 1024
      var diff = 0.0
      if pid in prevCPU:
        diff = cpu - prevCPU[pid]
        avg1[pid] = diff
        avg10[pid] = diff * 1/10 + avg10[pid] * 9/10
        avg60[pid] = diff * 1/60 + avg60[pid] * 59/60
      else:
        avg1[pid] = 0
        avg10[pid] = 0
        avg60[pid] = 0

      prevCPU[pid] = cpu

      #if userModeTime + kernelModeTime > 0.20:
      if avg60[pid] > 0.1 or memoryG > 0.5:
        echo &"{pid:>6} {avg1[pid]:8.3f} {avg10[pid]:8.3f} {avg60[pid]:8.3f} {memoryG:>8.3f}G {exeName}"

      if avg60[pid] > 0.500 or memoryG > 5:
        echo "killing ------- ", pid, " "
        echo readFile(f / "cmdline")
        discard kill(Pid(pid), 9)

  sleep(1000)