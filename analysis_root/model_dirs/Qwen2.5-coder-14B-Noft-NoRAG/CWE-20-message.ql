import python

/**
 * CWE-20: Improper Input Validation
 * This query detects functions that receive input but do not validate it properly.
 */

from Function f, Parameter p
where f.getLanguage() = "python"
  and p.hasType("str")
  and not exists(Expr e | e instanceof Call and e.getCallee().getName() = "validate" and e.getArgument(0) = p)
select f, "Function does not validate input parameter " + p.getName()