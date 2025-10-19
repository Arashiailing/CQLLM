/**
 * @name Explicit value return in `__init__` method
 * @description Detects non-None returns in Python `__init__` methods that cause runtime TypeErrors.
 *              This query identifies problematic return statements in initialization methods
 *              that would lead to TypeError exceptions at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-return-in-init
 */

import python

from Return returnStmt, Expr returnValue
where
  // Condition 1: Return statement must be inside an __init__ method
  returnStmt.getScope().(Function).isInitMethod() and
  // Condition 2: Return statement must have a value (non-empty return)
  returnStmt.getValue() = returnValue and
  // Condition 3: Exclude returns of None value
  not returnValue.pointsTo(Value::none_()) and
  // Condition 4: Filter out calls to functions that never return
  not exists(FunctionValue neverReturningFunction |
    neverReturningFunction.getACall() = returnValue.getAFlowNode() and
    neverReturningFunction.neverReturns()
  ) and
  // Condition 5: Avoid nested __init__ method calls
  not exists(Attribute attributeAccess |
    attributeAccess = returnValue.(Call).getFunc() and
    attributeAccess.getName() = "__init__"
  )
select returnStmt, "Explicit return in __init__ method."