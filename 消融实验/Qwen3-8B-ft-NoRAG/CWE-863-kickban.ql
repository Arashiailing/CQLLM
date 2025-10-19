import python

/** @name CWE-863: Incorrect Authorization */
/** @description Detects incorrect authorization checks in Python code */
from Call c
where c.getCallee().getName() = "check_authorization" and
      c.getArg(0).getType().isMemberOf("User") and
      c.getArg(1).getType().isMemberOf("Resource") and
      not (c.getArg(2).getType().isMemberOf("Permission") or
           c.getArg(2).getType().isMemberOf("str"))
select c, "Potential incorrect authorization check detected"