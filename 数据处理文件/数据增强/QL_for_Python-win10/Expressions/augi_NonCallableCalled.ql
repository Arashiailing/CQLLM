/**
 * @name Non-callable called
 * @description Detects calls to objects that are not callable, which would raise TypeError at runtime.
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

from Call callExpr, Value targetValue, ClassValue targetClass, Expr funcExpr, AstNode sourceNode
where
  // Extract the function expression being called
  funcExpr = callExpr.getFunc() and
  
  // Trace the function expression to its target value and source
  funcExpr.pointsTo(targetValue, sourceNode) and
  
  // Get the class of the target value
  targetClass = targetValue.getClass() and
  
  // Verify the target class is not callable and inference succeeded
  not targetClass.isCallable() and
  not targetClass.failedInference(_) and
  
  // Exclude special cases that might appear callable but aren't
  not targetClass.hasAttribute("__get__") and
  not targetValue = Value::named("None") and
  
  // Filter out NotImplemented usage in raise statements
  not use_of_not_implemented_in_raise(_, funcExpr)
select callExpr, "Call to a $@ of $@.", sourceNode, "non-callable", targetClass, targetClass.toString()