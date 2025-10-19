/**
 * @name Explicit value return in `__init__` method
 * @description Detects non-None return values in Python `__init__` methods, which lead to runtime TypeErrors.
 *              This query filters out returns of None, calls to functions that never return, and nested
 *              `__init__` calls to reduce false positives and focus on actual issues.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-return-in-init
 */

import python

from Return initReturnStmt, Expr returnedValue
where
  // Condition 1: Return statement is inside an __init__ method
  initReturnStmt.getScope().(Function).isInitMethod() and
  // Condition 2: Return statement has a value expression
  initReturnStmt.getValue() = returnedValue and
  // Condition 3: Filter out None returns
  not returnedValue.pointsTo(Value::none_()) and
  // Condition 4: Exclude never-returning function calls
  not exists(FunctionValue nonReturningFunc |
    nonReturningFunc.getACall() = returnedValue.getAFlowNode() and
    nonReturningFunc.neverReturns()
  ) and
  // Condition 5: Avoid nested __init__ method calls
  not exists(Attribute initAttrAccess |
    initAttrAccess = returnedValue.(Call).getFunc() and
    initAttrAccess.getName() = "__init__"
  )
select initReturnStmt, "Explicit return in __init__ method."