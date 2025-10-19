import python

/**
 * Detects improper input validation by checking for direct usage of untrusted inputs
 * without validation checks.
 */
predicate isUnvalidatedInput(String inputSource) {
  // Check if the input source is a direct user input (e.g., input(), sys.stdin)
  exists(Call call, String methodName)
    | call = callTo(methodName, "input", "sys.stdin.read")
    | inputSource = call.getArgument(0).toString()
}

from Call call
where 
  call.getMethod().getName() = "print" and
  call.getArgumentCount() > 0 and
  isUnvalidatedInput(call.getArgument(0).toString())
select call, "Potential CWE-20: Improper Input Validation - Unvalidated input used in output"