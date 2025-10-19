/**
 * @name Invocation of Non-Callable Objects
 * @description Detects function call expressions where the target object
 *              lacks callable capability, which would cause a runtime TypeError.
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
  Value targetObject, 
  ClassValue targetClass, 
  Expr targetExpression, 
  AstNode sourceNode
where
  // Extract the function being called
  targetExpression = functionCall.getFunc() and
  
  // Resolve the target's value and origin
  targetExpression.pointsTo(targetObject, sourceNode) and
  
  // Determine the class of the target
  targetClass = targetObject.getClass() and
  
  // Verify the target's class is not callable
  not targetClass.isCallable() and
  
  // Ensure type inference succeeded
  not targetClass.failedInference(_) and
  
  // Exclude descriptor protocol objects
  not targetClass.hasAttribute("__get__") and
  
  // Exclude explicit None values
  not targetObject = Value::named("None") and
  
  // Special case: exclude NotImplemented in raise contexts
  not use_of_not_implemented_in_raise(_, targetExpression)
select 
  functionCall, 
  "Call to a $@ of $@.", 
  sourceNode, 
  "non-callable", 
  targetClass, 
  targetClass.toString()