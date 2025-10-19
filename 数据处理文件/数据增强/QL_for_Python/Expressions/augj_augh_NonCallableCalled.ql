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
from Call callNode, Value calledValue, ClassValue calledClass, Expr funcExpr, AstNode valueSource
where
  // Extract the function expression being called
  funcExpr = callNode.getFunc() and
  
  // Determine what value the function expression points to
  funcExpr.pointsTo(calledValue, valueSource) and
  
  // Get the class of the target value
  calledClass = calledValue.getClass() and
  
  // Verify the class is not callable and type inference was successful
  not calledClass.isCallable() and
  not calledClass.failedInference(_) and
  
  // Exclude objects with __get__ attribute (descriptors)
  not calledClass.hasAttribute("__get__") and
  
  // Exclude None values (handled separately)
  not calledValue = Value::named("None") and
  
  // Exclude NotImplemented used in raise statements
  not use_of_not_implemented_in_raise(_, funcExpr)
select callNode, "Call to a $@ of $@.", valueSource, "non-callable", calledClass, calledClass.toString()