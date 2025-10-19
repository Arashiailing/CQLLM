/**
 * @name Explicit value return in `__init__` method
 * @description Identifies Python `__init__` methods that return explicit values other than None.
 *              Such returns cause runtime TypeErrors. This query eliminates false positives by
 *              excluding returns of None, calls to functions that never return, and
 *              nested `__init__` method invocations.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-return-in-init
 */

import python

from Return initReturn, Expr returnValue
where
  // Ensure the return statement is within an __init__ method
  initReturn.getScope().(Function).isInitMethod() and
  // Check that the return statement has a value expression
  initReturn.getValue() = returnValue and
  // Exclude returns of None
  not returnValue.pointsTo(Value::none_()) and
  // Filter out calls to functions that never return
  not exists(FunctionValue nonReturningFunction |
    nonReturningFunction.getACall() = returnValue.getAFlowNode() and
    nonReturningFunction.neverReturns()
  ) and
  // Avoid nested __init__ method calls
  not exists(Attribute initCall |
    initCall = returnValue.(Call).getFunc() and
    initCall.getName() = "__init__"
  )
select initReturn, "Explicit return in __init__ method."