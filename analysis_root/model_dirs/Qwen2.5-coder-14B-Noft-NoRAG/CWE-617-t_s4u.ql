import python

/**
 * This query detects potential CWE-617: Command Injection vulnerabilities
 * by looking for unsafe use of subprocess functions.
 */

from Call call, StringLiteral command
where call.getCallee().getName() = "subprocess.call" or
      call.getCallee().getName() = "subprocess.run" or
      call.getCallee().getName() = "os.system" or
      call.getCallee().getName() = "os.popen" or
      call.getCallee().getName() = "os.execv" or
      call.getCallee().getName() = "os.execve" or
      call.getCallee().getName() = "os.execl" or
      call.getCallee().getName() = "os.execle" or
      call.getCallee().getName() = "os.execvp" or
      call.getCallee().getName() = "os.execvpe" or
      call.getCallee().getName() = "os.spawnl" or
      call.getCallee().getName() = "os.spawnlp" or
      call.getCallee().getName() = "os.spawnle" or
      call.getCallee().getName() = "os.spawnv" or
      call.getCallee().getName() = "os.spawnvp" or
      call.getCallee().getName() = "os.spawnve" or
      call.getCallee().getName() = "os.spawnvpe" or
      call.getCallee().getName() = "os.startfile"
  and call.getArgument(0) = command
select call, "Potentially vulnerable to CWE-617: Command Injection"