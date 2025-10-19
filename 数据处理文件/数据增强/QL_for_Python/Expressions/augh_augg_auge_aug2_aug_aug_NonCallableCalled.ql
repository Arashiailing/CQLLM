/**
 * @name Non-callable invoked
 * @description Detects invocations of objects that lack callability,
 *              which would trigger runtime TypeError exceptions.
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
  Call callNode, 
  Value targetValue, 
  ClassValue targetClass, 
  Expr funcExpr, 
  AstNode origin
where
  // Extract the function expression being invoked
  funcExpr = callNode.getFunc() and
  
  // Resolve the expression to its concrete value and origin
  funcExpr.pointsTo(targetValue, origin) and
  
  // Determine the class type of the target object
  targetClass = targetValue.getClass() and
  
  // Verify the object's class is not callable
  not targetClass.isCallable() and
  
  // Ensure type inference was successful for accurate analysis
  not targetClass.failedInference(_) and
  
  // Exclude descriptor objects implementing __get__ method
  // These objects might be callable through the descriptor protocol
  not targetClass.hasAttribute("__get__") and
  
  // Filter out None values as they are explicitly non-callable
  not targetValue = Value::named("None") and
  
  // Special case: exclude NotImplemented when used in raise statements
  not use_of_not_implemented_in_raise(_, funcExpr)
select 
  callNode, 
  "Call to a $@ of $@.", 
  origin, 
  "non-callable", 
  targetClass, 
  targetClass.toString()