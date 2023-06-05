## shellmon - shell used by sshmon to run commands
## Programmible shell that flushes all the time.
## Writes the length of a strings as 64bit byte.
## No more guessling or looking for new lines.

import osproc, streams, json, os

let stdinStream = newFileStream(stdin)
let stdoutStream = newFileStream(stdout)

while true:
  let commandLen = stdinStream.readUint64()
  let command = stdinStream.readStr(int commandLen)

  case command:
  of "$$$exit":
    stdoutStream.write(uint64 0)
    stdoutStream.write(uint64 0)
    stdoutStream.flush()
    quit(0)

  of "$$$read":
    let pathLen = stdinStream.readUint64()
    let path = stdinStream.readStr(int pathLen)
    var output = ""
    var code = -1
    if existsFile(path):
      code = 0
      output = readFile(path)
    stdoutStream.write(uint64 code)
    stdoutStream.flush()
    stdoutStream.write(uint64 output.len)
    stdoutStream.flush()
    stdoutStream.write(output)
    stdoutStream.flush()

  of "$$$write":
    let pathLen = stdinStream.readUint64()
    let path = stdinStream.readStr(int pathLen)
    let dataLen = stdinStream.readUint64()
    let data = stdinStream.readStr(int dataLen)
    var code = 0
    try:
      writeFile(path, data)
    except:
      code = -1
    stdoutStream.write(uint64 code)
    stdoutStream.flush()

  else: # normal linux command
    let (output, code) = execCmdEx(command)
    stdoutStream.write(uint64 code)
    stdoutStream.flush()
    stdoutStream.write(uint64 output.len)
    stdoutStream.flush()
    stdoutStream.write(output)
    stdoutStream.flush()

