import python

/**
 * This query detects potential CWE-78: Improper Neutralization of Special Elements used in an OS Command ('OS Command Injection').
 * It looks for cases where user-controlled input is used directly in a command execution function.
 */

from Call call, StringLiteral cmd, Argument arg
where call.getCallee().getName() = "subprocess.call" or
      call.getCallee().getName() = "subprocess.run" or
      call.getCallee().getName() = "os.system" or
      call.getCallee().getName() = "os.popen"
  and arg = call.getArgument(0)
  and arg.getValue() = cmd
select call, "This command execution may be vulnerable to OS Command Injection because it uses a user-controlled string."