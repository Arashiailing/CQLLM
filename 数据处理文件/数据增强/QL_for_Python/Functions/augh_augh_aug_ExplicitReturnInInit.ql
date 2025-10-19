/**
 * @name `__init__` method returns a value
 * @description Detects explicit non-None returns in Python `__init__` methods.
 *              Such returns violate Python's initialization contract and cause TypeErrors.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-return-in-init
 */

import python

// Identify problematic return statements in __init__ methods
from Return returnNode, Expr returnedExpr
where
  // Scope check: Return must be inside an __init__ method
  exists(Function initMethod | 
    initMethod.isInitMethod() and 
    returnNode.getScope() = initMethod
  ) and
  // Value check: Return must have a non-None expression
  returnNode.getValue() = returnedExpr and
  not returnedExpr.pointsTo(Value::none_()) and
  // Exception check: Exclude calls to functions that never return
  not exists(FunctionValue neverReturningFunc | 
    neverReturningFunc.getACall() = returnedExpr.getAFlowNode() | 
    neverReturningFunc.neverReturns()
  ) and
  // False positive prevention: Exclude returns from nested __init__ calls
  not exists(Attribute initCallAttr | 
    initCallAttr = returnedExpr.(Call).getFunc() | 
    initCallAttr.getName() = "__init__"
  )
// Report violation with standard message
select returnNode, "Explicit return in __init__ method."