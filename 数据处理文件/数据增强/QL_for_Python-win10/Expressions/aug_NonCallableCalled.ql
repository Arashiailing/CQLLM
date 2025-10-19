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
  Call callSite, 
  Value calledValue, 
  ClassValue valueType, 
  Expr functionExpr, 
  AstNode valueOrigin
where
  // Identify the function expression in the call
  functionExpr = callSite.getFunc() and
  
  // Trace the function expression to its underlying value and origin
  functionExpr.pointsTo(calledValue, valueOrigin) and
  
  // Determine the class of the called value
  valueType = calledValue.getClass() and
  
  // Verify the class is not callable
  not valueType.isCallable() and
  
  // Ensure type inference succeeded
  not valueType.failedInference(_) and
  
  // Exclude descriptor objects with __get__ (which might be callable through protocol)
  not valueType.hasAttribute("__get__") and
  
  // Exclude None values (explicitly non-callable)
  not calledValue = Value::named("None") and
  
  // Exclude NotImplemented in raise statements (special handling)
  not use_of_not_implemented_in_raise(_, functionExpr)
select 
  callSite, 
  "Call to a $@ of $@.", 
  valueOrigin, 
  "non-callable", 
  valueType, 
  valueType.toString()