/**
 * @name Non-callable invoked
 * @description Identifies invocations of objects that cannot be called,
 *              resulting in runtime TypeError exceptions.
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
  Value targetValue, 
  ClassValue targetClass, 
  Expr callExpr, 
  AstNode origin
where
  // Extract the expression being invoked from the function call
  callExpr = callSite.getFunc() and
  
  // Trace the called expression to its resolved value and origin point
  callExpr.pointsTo(targetValue, origin) and
  
  // Retrieve the class type of the target object
  targetClass = targetValue.getClass() and
  
  // Verify the object's class is not callable
  not targetClass.isCallable() and
  
  // Ensure type inference was successful for accurate analysis
  not targetClass.failedInference(_) and
  
  // Exclude descriptor objects that implement __get__ method
  // These objects might be callable through the descriptor protocol
  not targetClass.hasAttribute("__get__") and
  
  // Filter out None values as they are explicitly non-callable
  not targetValue = Value::named("None") and
  
  // Special case: exclude NotImplemented when used in raise statements
  not use_of_not_implemented_in_raise(_, callExpr)
select 
  callSite, 
  "Call to a $@ of $@.", 
  origin, 
  "non-callable", 
  targetClass, 
  targetClass.toString()