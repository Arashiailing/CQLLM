import python

/**
 * CWE-264: Unsafe Shell Command Construction
 * Detects the use of subprocess.call, subprocess.Popen, or os.system with user-controlled input.
 */

from Call call, Argument arg
where call.getCallee().getName() = "call" or
      call.getCallee().getName() = "Popen" or
      call.getCallee().getName() = "system" and
      arg = call.getArgument(0)
select arg, "This call to subprocess.call, subprocess.Popen, or os.system may be vulnerable to shell injection due to the use of user-controlled input."