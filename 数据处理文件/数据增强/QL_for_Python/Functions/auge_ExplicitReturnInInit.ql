/**
 * @name `__init__` method returns a value
 * @description Explicitly returning a value from an `__init__` method will raise a TypeError.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-return-in-init
 */

import python

from Return r, Expr rv
where
  // Identify return statements within __init__ methods
  exists(Function initMethod | 
    initMethod.isInitMethod() and 
    r.getScope() = initMethod
  ) and
  // Match return value to the expression
  r.getValue() = rv and
  // Exclude None returns (allowed in __init__)
  not rv.pointsTo(Value::none_()) and
  // Filter out non-returning function calls
  not exists(FunctionValue funcValue | 
    funcValue.getACall() = rv.getAFlowNode() | 
    funcValue.neverReturns()
  ) and
  // Prevent duplicate reports for nested __init__ calls
  not exists(Attribute methodAttr | 
    methodAttr = rv.(Call).getFunc() | 
    methodAttr.getName() = "__init__"
  )
select r, "Explicit return in __init__ method."