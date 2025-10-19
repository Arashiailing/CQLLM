/**
 * @name Explicit value return in `__init__` method
 * @description Detects Python `__init__` methods returning non-None values, which cause runtime TypeErrors.
 *              The query applies precise filters to exclude false positives: None returns,
 *              calls to non-returning functions, and nested `__init__` invocations.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-return-in-init
 */

import python

from Function initMethod, Return stmtReturn, Expr returnedValue
where
  // Identify __init__ method containing the return statement
  initMethod.isInitMethod() and
  stmtReturn.getScope() = initMethod and
  // Ensure return statement has a non-None value expression
  stmtReturn.getValue() = returnedValue and
  not returnedValue.pointsTo(Value::none_()) and
  // Exclude calls to functions that never return
  not exists(FunctionValue nonReturningFunc |
    nonReturningFunc.getACall() = returnedValue.getAFlowNode() and
    nonReturningFunc.neverReturns()
  ) and
  // Skip returns from nested __init__ method calls
  not exists(Attribute initCall |
    initCall = returnedValue.(Call).getFunc() and
    initCall.getName() = "__init__"
  )
select stmtReturn, "Explicit return in __init__ method."