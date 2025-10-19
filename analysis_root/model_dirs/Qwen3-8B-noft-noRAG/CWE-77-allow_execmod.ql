import semmle.python.Python

/**
 * Detects potential Command Injection vulnerabilities by identifying calls to functions that execute system commands,
 * where arguments are constructed using untrusted input without proper sanitization.
 */
from Call call, Argument arg, Expression expr
where (call.getTarget().getName() = "subprocess.run" or
       call.getTarget().getName() = "subprocess.call" or
       call.getTarget().getName() = "subprocess.check_call" or
       call.getTarget().getName() = "subprocess.check_output" or
       call.getTarget().getName() = "os.system") and
      arg.getIndex() = 0 and
      expr = call.getArgument(0) and
      expr.hasStringInterpolation()
select call, "Potential Command Injection vulnerability detected via direct string interpolation in command execution."