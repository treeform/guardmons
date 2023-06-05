# Cross-platform collection of OS Utilities written in Nim

This collection includes numerous utilities to manage various OS operations. They primarily function on Linux, however, some have been adapted to work on Windows, while maintaining the same Application Programming Interface (API). Below is a list of these utilities with their descriptions:

* `daemon` - This utility is designed to convert a process into a daemon, meaning it allows the process to run in the background of your system.

* `watchmon` - Monitors files that match a specific pattern for any modifications. If a change is detected, it executes a predetermined command.

* `copymon` - Keeps an eye on files fitting a particular pattern, and automatically copies them to other systems when changes occur.

* `loopmon` - This utility repeatedly runs a process. If the process fails or crashes, it restarts the process automatically.

* `cronmon` - Allows you to schedule a process to run at specific times.

* `logmon` - Monitors log files that match a certain pattern and forwards them to a designated endpoint.

* `topmon` - Provides a snapshot of the current active programs, functioning similarly to the 'top' command in Linux.

* `killmon` - Watches over processes and terminates those that consume excessive CPU, file descriptors, or memory resources.

* `zipmon` - Compresses directories into zip archive files.

* `unzipmon` - Extracts files from zip archives into directories.

* `shellmon` - Functions as a scriptable shell, facilitating scripting tasks.

* `sshmon` - A utility tool that leverages `shellmon` to execute operations on a remote computer via SSH.

* `usemem` - Gradually consumes all available memory. This is particularly useful for simulating low memory conditions for testing purposes.

* `useupcpu` - Uses up one CPU core, which is useful for simulating situations where CPU resources are scarce for testing purposes.
