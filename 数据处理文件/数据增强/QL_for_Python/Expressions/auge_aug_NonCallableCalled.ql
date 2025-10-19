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

from 
  Call invocation,  // Renamed from callSite for clarity
  Value invokedValue,  // Renamed from calledValue
  ClassValue targetClass,  // Renamed from valueType
  Expr funcExpression,  // Renamed from functionExpr
  AstNode valueSource  // Renamed from valueOrigin
where
  // Extract the function expression from the call site
  funcExpression = invocation.getFunc() and
  
  // Trace the function expression to its resolved value and origin
  funcExpression.pointsTo(invokedValue, valueSource) and
  
  // Identify the class of the invoked value
  targetClass = invokedValue.getClass() and
  
  // Verify the target class is not callable
  not targetClass.isCallable() and
  
  // Ensure type inference was successful
  not targetClass.failedInference(_) and
  
  // Exclude descriptor objects with __get__ (callable via descriptor protocol)
  not targetClass.hasAttribute("__get__") and
  
  // Exclude explicit None values (known non-callable)
  not invokedValue = Value::named("None") and
  
  // Exclude special handling of NotImplemented in raise statements
  not use_of_not_implemented_in_raise(_, funcExpression)
select 
  invocation, 
  "Call to a $@ of $@.", 
  valueSource, 
  "non-callable", 
  targetClass, 
  targetClass.toString()