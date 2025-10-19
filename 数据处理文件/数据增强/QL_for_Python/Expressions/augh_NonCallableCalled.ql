/**
 * @name Non-callable called
 * @description Detects calls to objects that are not callable, which would raise a TypeError at runtime.
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

// Identify function calls where the target is not callable
from Call functionCall, Value targetValue, ClassValue targetClass, Expr calledExpr, AstNode valueOrigin
where
  // Extract the function expression being called
  calledExpr = functionCall.getFunc() and
  // Determine what value the function expression points to
  calledExpr.pointsTo(targetValue, valueOrigin) and
  // Get the class of the target value
  targetClass = targetValue.getClass() and
  // Verify the class is not callable
  not targetClass.isCallable() and
  // Ensure type inference was successful
  not targetClass.failedInference(_) and
  // Exclude objects with __get__ attribute (descriptors)
  not targetClass.hasAttribute("__get__") and
  // Exclude None values (handled separately)
  not targetValue = Value::named("None") and
  // Exclude NotImplemented used in raise statements
  not use_of_not_implemented_in_raise(_, calledExpr)
select functionCall, "Call to a $@ of $@.", valueOrigin, "non-callable", targetClass, targetClass.toString()