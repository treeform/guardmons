
# Collection of OS utilities that should have been part of OS.

* `daemon` - Demonizes a process (makes it run in the background)
* `watchmon` - Watches files matching a pattern for changes and runs a command if one of them changes.
* `copymon` - Watches files matching a pattern and copies them to other machines when they changes.
* `loopmon` - Runs a process in a loop, if they crash restarts them.
* `cronmon` - Runs a process on a schedule time.
* `logmon` - Watches log files matching a pattern and sends to an endpoint.
* `topmon` - List processes matching a pattern and maybe kill them. (cross platform "ps aux | grep" that works on windows)
* `zipmon` - Zips directories into archives.
* `unzipmon` - Unzips directories into archives.
* `killmon` - Watches and kills processes that use too much CPU, file descriptors or memory.
