/**
 * @name Explicit value return in `__init__` method
 * @description Identifies Python `__init__` methods that return non-None values, which cause runtime TypeErrors.
 *              The query applies several filters to eliminate false positives: excludes None returns,
 *              calls to functions that never return, and nested `__init__` invocations, ensuring
 *              detection of genuine problematic cases.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-return-in-init
 */

import python

from Return initMethodReturn, Expr returnedExpr
where
  // Verify the return statement is within an __init__ method
  initMethodReturn.getScope().(Function).isInitMethod() and
  // Ensure the return statement has an associated value expression
  initMethodReturn.getValue() = returnedExpr and
  // Exclude cases where the returned value is None
  not returnedExpr.pointsTo(Value::none_()) and
  // Filter out calls to functions that are known to never return
  not exists(FunctionValue noReturnFunction |
    noReturnFunction.getACall() = returnedExpr.getAFlowNode() and
    noReturnFunction.neverReturns()
  ) and
  // Skip returns from nested __init__ method calls
  not exists(Attribute initMethodCall |
    initMethodCall = returnedExpr.(Call).getFunc() and
    initMethodCall.getName() = "__init__"
  )
select initMethodReturn, "Explicit return in __init__ method."