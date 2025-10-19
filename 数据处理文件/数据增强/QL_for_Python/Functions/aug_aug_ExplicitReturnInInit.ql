/**
 * @name Explicit value return in `__init__` method
 * @description Identifies non-None returns in Python `__init__` methods that cause runtime TypeErrors.
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

from Return returnStatement, Expr returnValue
where
  // Verify return statement exists within an __init__ method
  returnStatement.getScope().(Function).isInitMethod() and
  // Ensure return statement has a value expression
  returnStatement.getValue() = returnValue and
  // Filter out None returns
  not returnValue.pointsTo(Value::none_()) and
  // Exclude never-returning function calls
  not exists(FunctionValue neverReturningFunction |
    neverReturningFunction.getACall() = returnValue.getAFlowNode() and
    neverReturningFunction.neverReturns()
  ) and
  // Avoid nested __init__ method calls
  not exists(Attribute attributeAccess |
    attributeAccess = returnValue.(Call).getFunc() and
    attributeAccess.getName() = "__init__"
  )
select returnStatement, "Explicit return in __init__ method."