/**
 * @name Explicit value return in `__init__` method
 * @description Detects non-None returns in Python `__init__` methods that cause runtime TypeErrors.
 *              Excludes returns of None, never-returning function calls, and nested `__init__` calls
 *              to minimize false positives.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-return-in-init
 */

import python

from Return retStmt, Expr retValue
where
  // Ensure return statement is within an __init__ method
  retStmt.getScope().(Function).isInitMethod() and
  // Confirm return statement has a value expression
  retStmt.getValue() = retValue and
  // Exclude None returns
  not retValue.pointsTo(Value::none_()) and
  // Filter out never-returning function calls
  not exists(FunctionValue neverReturnFunc |
    neverReturnFunc.getACall() = retValue.getAFlowNode() and
    neverReturnFunc.neverReturns()
  ) and
  // Avoid nested __init__ method calls
  not exists(Attribute attrAccess |
    attrAccess = retValue.(Call).getFunc() and
    attrAccess.getName() = "__init__"
  )
select retStmt, "Explicit return in __init__ method."