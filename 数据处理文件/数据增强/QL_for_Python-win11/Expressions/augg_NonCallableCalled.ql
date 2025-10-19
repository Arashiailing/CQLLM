/**
 * @name Non-callable called
 * @description Detects calls to objects that are not callable, which will raise a TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/call-to-non-callable
 */

import python
import Exceptions.NotImplemented

from Call callNode, Expr funcExpr, Value pointedValue, ClassValue valueClass, AstNode originNode
where
  // Extract function expression and its pointed value
  funcExpr = callNode.getFunc() and
  funcExpr.pointsTo(pointedValue, originNode) and
  valueClass = pointedValue.getClass() and
  
  // Verify the value's class is not callable
  not valueClass.isCallable() and
  not valueClass.failedInference(_) and
  not valueClass.hasAttribute("__get__") and
  
  // Exclude special cases: None and NotImplemented in raise statements
  not pointedValue = Value::named("None") and
  not use_of_not_implemented_in_raise(_, funcExpr)
select callNode, "Call to a $@ of $@.", originNode, "non-callable", valueClass, valueClass.toString()