/**
 * @name Non-None return in `__init__` method
 * @description Identifies explicit value returns in Python `__init__` methods that trigger TypeErrors.
 *              Filters out None returns, never-returning functions, and nested `__init__` calls
 *              to reduce false positives.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-return-in-init
 */

import python

from Return retStmt, Expr retExpr
where
  // Locate returns within __init__ methods containing explicit values
  retStmt.getScope().(Function).isInitMethod() and
  retStmt.getValue() = retExpr and
  
  // Exclude None returns (permitted in __init__)
  not retExpr.pointsTo(Value::none_()) and
  
  // Filter never-returning function calls (e.g., sys.exit)
  not exists(FunctionValue neverReturnFunc |
    neverReturnFunc.getACall() = retExpr.getAFlowNode() and
    neverReturnFunc.neverReturns()
  ) and
  
  // Skip nested __init__ calls (common false positive pattern)
  not exists(Attribute initAttr |
    initAttr = retExpr.(Call).getFunc() and
    initAttr.getName() = "__init__"
  )
select retStmt, "Explicit return in __init__ method."