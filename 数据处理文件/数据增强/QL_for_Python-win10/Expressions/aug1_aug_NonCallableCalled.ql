/**
 * @name Non-callable called
 * @description Identifies calls to objects that are not callable, which will raise a TypeError at runtime.
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

from 
  Call callExpr, 
  Value targetValue, 
  ClassValue targetClass, 
  Expr funcExpr, 
  AstNode valueSource
where
  // Extract the function expression from the call site
  funcExpr = callExpr.getFunc() and
  
  // Resolve the function expression to its concrete value and origin
  funcExpr.pointsTo(targetValue, valueSource) and
  
  // Determine the class type of the called value
  targetClass = targetValue.getClass() and
  
  // Verify the class is not callable and type inference succeeded
  not targetClass.isCallable() and
  not targetClass.failedInference(_) and
  
  // Exclude descriptor objects with __get__ (callable via protocol)
  not targetClass.hasAttribute("__get__") and
  
  // Exclude explicit None values (known non-callable)
  not targetValue = Value::named("None") and
  
  // Exclude NotImplemented in raise statements (special case)
  not use_of_not_implemented_in_raise(_, funcExpr)
select 
  callExpr, 
  "Call to a $@ of $@.", 
  valueSource, 
  "non-callable", 
  targetClass, 
  targetClass.toString()