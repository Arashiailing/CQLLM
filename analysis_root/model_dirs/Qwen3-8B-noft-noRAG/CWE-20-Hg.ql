import python

/**
 * @name CWE-20: Improper Input Validation
 * @description Detects improper input validation by identifying cases where untrusted inputs are directly used in potentially dangerous contexts without validation.
 */
from Call c, Var v
where c.getTarget() = "os.system" and 
      c.getArgCount() > 0 and 
      c.getArgument(0) = v and 
      v.getSource().getKind() = "Call" and 
      v.getSource().getTarget() = "builtins.input"
select c, "Potential CWE-20: Unvalidated input used in os.system call", c.getLocation()