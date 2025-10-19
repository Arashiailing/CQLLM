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
  Call invocation, 
  Value targetValue, 
  ClassValue targetClass, 
  Expr funcExpression, 
  AstNode valueOrigin
where
  // Extract the function expression being invoked at the call site
  funcExpression = invocation.getFunc() and
  
  // Resolve the function expression to its concrete value and origin
  funcExpression.pointsTo(targetValue, valueOrigin) and
  
  // Determine the class type of the resolved value
  targetClass = targetValue.getClass() and
  
  // Verify the class is not callable and type inference succeeded
  not targetClass.isCallable() and
  not targetClass.failedInference(_) and
  
  // Exclude descriptor objects with __get__ (callable via protocol)
  not targetClass.hasAttribute("__get__") and
  
  // Exclude explicit None values (known non-callable)
  not targetValue = Value::named("None") and
  
  // Exclude NotImplemented in raise statements (special case)
  not use_of_not_implemented_in_raise(_, funcExpression)
select 
  invocation, 
  "Call to a $@ of $@.", 
  valueOrigin, 
  "non-callable", 
  targetClass, 
  targetClass.toString()