/**
 * @name CWE-20: Improper Input Validation
 * @description Detects instances where input is not properly validated before being used in potentially dangerous contexts.
 */
import python

from FunctionCall input_call, StringLiteral unsafe_string, Call site_call
where input_call.getName() = "input" and
      (unsafe_string.getString() like "%$" or unsafe_string.getString() like "%'" or unsafe_string.getString() like "%`") and
      site_call.getExpression().getTarget() = input_call.getResult() and
      site_call.getName() in ("exec", "eval", "compile", "subprocess.run", "os.system")
select site_call, "Potential improper input validation leading to code injection or similar vulnerabilities."