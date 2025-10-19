import python
import semmle.code.python.dataflow.DataFlow
import semmle.code.python.controlflow.ControlFlow

/** @name LDAP query built from user-controlled sources */
/** @description Building an LDAP query from user-controlled sources is vulnerable to insertion of malicious LDAP code by the user. */
/** @id py/t_kdb */

from StringConcatenation c, Variable v
where c.getParts() contains v
  and v.isFromUserInput()
  and c.toString().matches("\\(.*?\\)")
  and not c.toString().matches("\\(.*?\\)\\s*AND\\s*.*?")
select c, "Potential LDAP injection vulnerability: LDAP query constructed using user-controlled input."