/**
 * @name Explicit value return in `__init__` method
 * @description Detects non-None return values in Python `__init__` methods which lead to runtime TypeErrors.
 *              The query excludes returns of None, calls to functions that never return, and nested `__init__`
 *              method invocations to reduce false positive findings.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-return-in-init
 */

import python

from Return initReturnStmt, Expr returnedExpr
where
  // Check that the return statement is inside an __init__ method
  initReturnStmt.getScope().(Function).isInitMethod() and
  // Verify the return statement has an expression
  initReturnStmt.getValue() = returnedExpr and
  
  // Filter out benign return cases
  not returnedExpr.pointsTo(Value::none_()) and
  // Exclude functions that never return
  not exists(FunctionValue noReturnFunc |
    noReturnFunc.getACall() = returnedExpr.getAFlowNode() and
    noReturnFunc.neverReturns()
  ) and
  // Exclude calls to nested __init__ methods
  not exists(Attribute initAttrAccess |
    initAttrAccess = returnedExpr.(Call).getFunc() and
    initAttrAccess.getName() = "__init__"
  )
select initReturnStmt, "Explicit return in __init__ method."