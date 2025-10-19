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
  Call callSite, 
  Value calledValue, 
  ClassValue calledClass, 
  Expr calledExpr, 
  AstNode valueOrigin
where
  // Extract the expression being called from the call site
  calledExpr = callSite.getFunc() and
  
  // Resolve the called expression to its concrete value and origin
  calledExpr.pointsTo(calledValue, valueOrigin) and
  
  // Determine the class type of the called value
  calledClass = calledValue.getClass() and
  
  // Verify the class is not callable and type inference succeeded
  not calledClass.isCallable() and
  not calledClass.failedInference(_) and
  
  // Exclude descriptor objects with __get__ (callable via protocol)
  not calledClass.hasAttribute("__get__") and
  
  // Exclude explicit None values (known non-callable)
  not calledValue = Value::named("None") and
  
  // Exclude NotImplemented in raise statements (special case)
  not use_of_not_implemented_in_raise(_, calledExpr)
select 
  callSite, 
  "Call to a $@ of $@.", 
  valueOrigin, 
  "non-callable", 
  calledClass, 
  calledClass.toString()