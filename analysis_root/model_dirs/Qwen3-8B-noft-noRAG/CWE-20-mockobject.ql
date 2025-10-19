import python

/**
 * @name CWE-20: Improper Input Validation
 * @description Detects cases where user input is not properly validated before being used in potentially unsafe contexts.
 */
from InputString input, Call call
where input.getString() = "input()" and
      call.getFunctionName() in ("eval", "exec", "os.system", "subprocess.check_output")
      and call.getParameter(0).getSymbol().getName() = input.getVariable()
select call, "Unvalidated user input used in dangerous context"