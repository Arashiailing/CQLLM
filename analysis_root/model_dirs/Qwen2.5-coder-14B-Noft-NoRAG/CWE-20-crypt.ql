import python

/**
 * CWE-20: Improper Input Validation
 *
 * This query detects instances where user input is not properly validated.
 */
from Function func, Parameter param
where func.hasName("someFunction")
  and param = func.getParameter(0)
  and not exists(DataFlow::Node inputNode |
    DataFlow::localFlow(func, param, inputNode)
    and inputNode instanceof CallExpr
    and inputNode.getCallee().hasName("validateInput")
  )
select param, "This parameter does not appear to be properly validated."