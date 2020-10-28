
# Logmon
# Utility that reads logfiles and writes them to a service.
# Supported login services:
# * LogDNA

import json, httpclient, times, osproc, strutils, asyncdispatch, os, parseopt,
  tables, streams


var
  logKey = ""
  logDomain = "logs.logdna.com"
  patterns: seq[string]
  host = ""
  env = ""
  app = ""


for kind, key, val in getopt():
  # this will iterate over all arguments passed to the cmdline.
  # echo kind, key, val
  if key == "key" or key == "k":
    logKey = val
  if key == "domain" or key == "d":
    logDomain = val
  if key == "patter" or key == "p":
    patterns.add val
  if key == "env" or key == "e":
    env = val
  if key == "host" or key == "h":
    host = val
  if key == "app" or key == "a":
    app = val

proc getHost(): string =
  let (output, code) = execCmdEx("hostname")
  return output.strip()
if host == "":
  host = getHost()


proc sendLine(level, message: string) {.async.} =
  var client = newAsyncHttpClient()
  client.headers = newHttpHeaders({
    "Content-Type": "application/json",
  })
  var data = $(%*{
    "lines":[
        {
          "timestamp": epochTime()*1000,
          "line": message,
          "app": app,
          "level": level,
          # "env": env,
          # "meta": meta
        }
    ]
  })
  try:
    asyncCheck client.postContent(
      "https://" & logDomain & "/logs/ingest" &
        "?hostname=" & host &
        "&now=" & $(epochTime()*1000) &
        "&apikey=" & logKey,
      data)
  except:
    echo  "error sending log", getCurrentExceptionMsg()


proc sendLog(filepath: string, fromBytes: int) {.async.} =
  var level: string
  if filepath.contains("error") or filepath.contains("stderr"):
    level = "ERROR"
  else:
    level = "INFO"
  echo "send ", filepath, "starting at ", fromBytes
  var f = newFileStream(filepath)
  f.setPosition(fromBytes)
  let all = f.readAll()
  if all.len > 0:
    asyncCheck sendLine(level, all)


var fileCache = newTable[string, FileInfo]()


proc logTick*() {.async.} =
  for pattern in patterns:
    for file in walkFiles(pattern):
      var newInfo = getFileInfo(file)
      if file notin fileCache:
        echo "new file!"
      else:
        if fileCache[file].size > newInfo.size:
          echo "overwritten file!"
          asyncCheck sendLog(file, 0)
        if fileCache[file].size < newInfo.size:
          echo "expanded file"
          asyncCheck sendLog(file, int fileCache[file].size)
      fileCache[file] = newInfo


proc main() {.async.} =
  while true:
    await logTick()
    await sleepAsync(100)

waitFor main()
