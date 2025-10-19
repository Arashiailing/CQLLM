import python

/**
 * CWE-287: Improper Authentication
 * This query detects potential command injection vulnerabilities.
 */
from Call call, Function func
where call.getCallee() = func and
      func.getName() = "subprocess.call" or
      func.getName() = "subprocess.Popen" or
      func.getName() = "os.system" or
      func.getName() = "os.popen" or
      func.getName() = "os.execv" or
      func.getName() = "os.execve" or
      func.getName() = "os.execl" or
      func.getName() = "os.execle" or
      func.getName() = "os.execvp" or
      func.getName() = "os.execvpe" or
      func.getName() = "os.startfile" or
      func.getName() = "os.spawnl" or
      func.getName() = "os.spawnle" or
      func.getName() = "os.spawnlp" or
      func.getName() = "os.spawnlpe" or
      func.getName() = "os.spawnv" or
      func.getName() = "os.spawnve" or
      func.getName() = "os.spawnvp" or
      func.getName() = "os.spawnvpe" or
      func.getName() = "os.system" or
      func.getName() = "os.popen" or
      func.getName() = "os.execv" or
      func.getName() = "os.execve" or
      func.getName() = "os.execl" or
      func.getName() = "os.execle" or
      func.getName() = "os.execvp" or
      func.getName() = "os.execvpe" or
      func.getName() = "os.startfile" or
      func.getName() = "os.spawnl" or
      func.getName() = "os.spawnle" or
      func.getName() = "os.spawnlp" or
      func.getName() = "os.spawnlpe" or
      func.getName() = "os.spawnv" or
      func.getName() = "os.spawnve" or
      func.getName() = "os.spawnvp" or
      func.getName() = "os.spawnvpe"
select call, "Potentially vulnerable to command injection via " + func.getName()