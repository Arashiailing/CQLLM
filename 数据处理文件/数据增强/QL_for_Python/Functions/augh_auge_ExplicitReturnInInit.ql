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

from Return returnStmt, Expr returnValue
where
  // Locate return statements inside __init__ methods
  exists(Function initMethod | 
    initMethod.isInitMethod() and 
    returnStmt.getScope() = initMethod
  ) and
  // Ensure return value is not None (permitted in __init__)
  not returnValue.pointsTo(Value::none_()) and
  // Exclude non-returning function calls
  not exists(FunctionValue funcValue | 
    funcValue.getACall() = returnValue.getAFlowNode() | 
    funcValue.neverReturns()
  ) and
  // Prevent false positives from nested __init__ calls
  not exists(Attribute methodAttr | 
    methodAttr = returnValue.(Call).getFunc() | 
    methodAttr.getName() = "__init__"
  ) and
  // Match return statement to its value expression
  returnStmt.getValue() = returnValue
select returnStmt, "Explicit return in __init__ method."