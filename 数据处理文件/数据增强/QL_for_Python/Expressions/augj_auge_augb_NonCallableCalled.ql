/**
 * @name Non-callable called
 * @description Identifies code locations where objects that are not callable are being invoked,
 *              which would lead to a TypeError at runtime.
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

// Identify all call sites where non-callable objects are invoked
from Call callSite, Value targetValue, ClassValue targetClass, Expr calleeExpr, AstNode valueOrigin
where
  // Extract the call expression and the value it references
  calleeExpr = callSite.getFunc() and
  calleeExpr.pointsTo(targetValue, valueOrigin) and
  
  // Determine the class of the target value and verify its non-callable nature
  targetClass = targetValue.getClass() and
  not targetClass.isCallable() and
  
  // Filter out special cases to reduce false positives
  // Ensure type inference was successful
  not targetClass.failedInference(_) and
  // Exclude descriptor protocol objects
  not targetClass.hasAttribute("__get__") and
  // Exclude calls to None
  not targetValue = Value::named("None") and
  // Exclude NotImplemented usage in raise statements
  not use_of_not_implemented_in_raise(_, calleeExpr)
select callSite, "Call to a $@ of $@.", valueOrigin, "non-callable", targetClass, targetClass.toString()