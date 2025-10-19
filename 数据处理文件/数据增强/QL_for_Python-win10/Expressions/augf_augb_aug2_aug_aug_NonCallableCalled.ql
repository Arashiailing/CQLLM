/**
 * @name Non-callable invoked
 * @description Detects invocations of objects that cannot be called,
 *              which would cause runtime TypeError exceptions.
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
  Value resolvedValue, 
  ClassValue targetClass, 
  Expr calledExpr, 
  AstNode origin
where
  // Identify the expression being invoked at the call site
  calledExpr = callSite.getFunc() and
  
  // Resolve the called expression to its concrete value and origin
  calledExpr.pointsTo(resolvedValue, origin) and
  
  // Determine the class type of the resolved value
  targetClass = resolvedValue.getClass() and
  
  // Core check: verify the object's class is not callable
  not targetClass.isCallable() and
  
  // Ensure type inference succeeded for accurate analysis
  not targetClass.failedInference(_) and
  
  // Exclude descriptor objects implementing __get__ protocol
  not targetClass.hasAttribute("__get__") and
  
  // Explicitly filter out None values (known non-callable)
  not resolvedValue = Value::named("None") and
  
  // Special case: exclude NotImplemented used in raise statements
  not use_of_not_implemented_in_raise(_, calledExpr)
select 
  callSite, 
  "Call to a $@ of $@.", 
  origin, 
  "non-callable", 
  targetClass, 
  targetClass.toString()