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
  Call callNode, 
  Value targetObject, 
  ClassValue targetClass, 
  Expr calleeExpr, 
  AstNode sourceNode
where
  // Extract the function being called from the invocation
  calleeExpr = callNode.getFunc() and
  
  // Resolve the called expression to its concrete value and origin
  calleeExpr.pointsTo(targetObject, sourceNode) and
  
  // Determine the class type of the target object
  targetClass = targetObject.getClass() and
  
  // Verify the object's class is not callable
  not targetClass.isCallable() and
  
  // Ensure type inference was successful for accurate analysis
  not targetClass.failedInference(_) and
  
  // Exclude descriptor objects implementing __get__ method
  // These objects might be callable through the descriptor protocol
  not targetClass.hasAttribute("__get__") and
  
  // Filter out None values as they are explicitly non-callable
  not targetObject = Value::named("None") and
  
  // Special case: exclude NotImplemented when used in raise statements
  not use_of_not_implemented_in_raise(_, calleeExpr)
select 
  callNode, 
  "Call to a $@ of $@.", 
  sourceNode, 
  "non-callable", 
  targetClass, 
  targetClass.toString()