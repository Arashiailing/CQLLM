/**
 * @name Non-None return in `__init__` method
 * @description Detects explicit non-None returns in Python `__init__` methods that cause TypeErrors.
 *              Excludes None returns, never-returning functions (like sys.exit), and nested `__init__` calls
 *              to minimize false positives while maintaining high precision.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-return-in-init
 */

import python

from Return returnStatement, Expr returnValueExpr
where
  // Identify returns within __init__ methods with explicit values
  returnStatement.getScope().(Function).isInitMethod() and
  returnStatement.getValue() = returnValueExpr and
  
  // Exclude permitted None returns
  not returnValueExpr.pointsTo(Value::none_()) and
  
  // Filter calls to never-returning functions (e.g., sys.exit)
  not exists(FunctionValue neverReturningFunction |
    neverReturningFunction.getACall() = returnValueExpr.getAFlowNode() and
    neverReturningFunction.neverReturns()
  ) and
  
  // Skip nested __init__ invocations (common false positive pattern)
  not exists(Attribute initAttribute |
    initAttribute = returnValueExpr.(Call).getFunc() and
    initAttribute.getName() = "__init__"
  )
select returnStatement, "Explicit return in __init__ method."