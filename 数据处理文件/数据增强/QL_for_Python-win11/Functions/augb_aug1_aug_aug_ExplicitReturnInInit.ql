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

from Return explicitReturn, Expr returnedValue
where
  // Identify returns inside __init__ methods with explicit values
  explicitReturn.getScope().(Function).isInitMethod() and
  explicitReturn.getValue() = returnedValue and
  
  // Filter out None returns (allowed in __init__)
  not returnedValue.pointsTo(Value::none_()) and
  
  // Exclude never-returning function calls (e.g., sys.exit)
  not exists(FunctionValue neverReturnFunc |
    neverReturnFunc.getACall() = returnedValue.getAFlowNode() and
    neverReturnFunc.neverReturns()
  ) and
  
  // Avoid nested __init__ calls (common false positive pattern)
  not exists(Attribute initAttr |
    initAttr = returnedValue.(Call).getFunc() and
    initAttr.getName() = "__init__"
  )
select explicitReturn, "Explicit return in __init__ method."