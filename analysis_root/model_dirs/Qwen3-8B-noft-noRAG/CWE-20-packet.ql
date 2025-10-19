import python

/** @name CWE-20: Improper Input Validation */
/**
 * Detects instances where user input is used without proper validation.
 * This includes direct use of input in dangerous functions, string formatting,
 * command execution, or file operations without sanitization.
 */

from InputString input, Call call
where input.getTarget() = call.getSource()
  and call.getMethodName() in ["eval", "exec", "compile", "subprocess.run", "os.system"]
  and not (call.getArgument(0).getType().isSubtypeOf("str") and call.getArgument(0).getSymbol().getName() = input.getName())
select call, "Potential improper input validation: Unvalidated input used in dangerous operation"