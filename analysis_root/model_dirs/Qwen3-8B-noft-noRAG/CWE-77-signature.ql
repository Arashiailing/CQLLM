import python

/**
 * Detects potential command injection vulnerabilities by analyzing function calls
 * that construct commands with untrusted input.
 */
from Call call
where 
  (call.getTarget().getName() = "os.system" or
   call.getTarget().getName() = "subprocess.run" or
   call.getTarget().getName() = "subprocess.call" or
   call.getTarget().getName() = "subprocess.Popen") and
  exists(Argument arg | call.getArguments() contains arg and
    arg.getValue().getKind() = "String" and
    arg.getValue().hasUntrustedInput())
select call, "Potential command injection vulnerability detected through direct command string concatenation"