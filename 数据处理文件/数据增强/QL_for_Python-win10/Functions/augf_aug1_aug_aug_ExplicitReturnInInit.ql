/**
 * @name Explicit value return in `__init__` method
 * @description Identifies non-None returns in Python `__init__` methods that trigger runtime TypeErrors.
 *              The analysis excludes returns of None, calls to never-returning functions, and nested
 *              `__init__` method invocations to minimize false positive results.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-return-in-init
 */

import python

from Return ret, Expr val
where
  // Verify the return statement is located within an __init__ method
  ret.getScope().(Function).isInitMethod() and
  // Confirm the return statement contains an expression value
  ret.getValue() = val and
  // Exclude None returns to avoid false positives
  not val.pointsTo(Value::none_()) and
  // Filter out function calls that never return
  not exists(FunctionValue noReturnFunc |
    noReturnFunc.getACall() = val.getAFlowNode() and
    noReturnFunc.neverReturns()
  ) and
  // Exclude nested __init__ method calls which might be legitimate
  not exists(Attribute attr |
    attr = val.(Call).getFunc() and
    attr.getName() = "__init__"
  )
select ret, "Explicit return in __init__ method."