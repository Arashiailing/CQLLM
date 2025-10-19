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
  Call functionCall, 
  Value calledObject, 
  ClassValue objectClass, 
  Expr calledExpression, 
  AstNode originNode
where
  // Extract the expression being invoked from the function call
  calledExpression = functionCall.getFunc() and
  
  // Trace the called expression to its resolved value and origin point
  calledExpression.pointsTo(calledObject, originNode) and
  
  // Retrieve the class type of the target object
  objectClass = calledObject.getClass() and
  
  // Verify the object's class is not callable
  not objectClass.isCallable() and
  
  // Ensure type inference was successful for accurate analysis
  not objectClass.failedInference(_) and
  
  // Exclude descriptor objects that implement __get__ method
  // These objects might be callable through the descriptor protocol
  not objectClass.hasAttribute("__get__") and
  
  // Filter out None values as they are explicitly non-callable
  not calledObject = Value::named("None") and
  
  // Special case: exclude NotImplemented when used in raise statements
  not use_of_not_implemented_in_raise(_, calledExpression)
select 
  functionCall, 
  "Call to a $@ of $@.", 
  originNode, 
  "non-callable", 
  objectClass, 
  objectClass.toString()