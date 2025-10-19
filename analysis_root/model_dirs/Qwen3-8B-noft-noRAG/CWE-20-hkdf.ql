/**
 * @name CWE-20: Improper Input Validation
 */
import python

from FunctionCall fc, Parameter p, Call c
where fc.getName() = "input" and
      p = fc.getParameter(0) and
      c.getTarget() = p.getValue()
select c, "Potential CWE-20: Unvalidated input used without verification"