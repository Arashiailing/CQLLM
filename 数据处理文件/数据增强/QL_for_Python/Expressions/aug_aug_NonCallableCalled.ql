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
  Call invocation, 
  Value targetObject, 
  ClassValue objectClass, 
  Expr calleeExpr, 
  AstNode sourceNode
where
  // Extract the callee expression from the invocation
  calleeExpr = invocation.getFunc() and
  
  // Follow the callee expression to its resolved value and origin
  calleeExpr.pointsTo(targetObject, sourceNode) and
  
  // Obtain the class of the target object
  objectClass = targetObject.getClass() and
  
  // Verify the object's class is not callable
  not objectClass.isCallable() and
  
  // Confirm that type inference was successful
  not objectClass.failedInference(_) and
  
  // Filter out descriptor objects with __get__ method
  // These might be callable through the descriptor protocol
  not objectClass.hasAttribute("__get__") and
  
  // Exclude None values as they are explicitly non-callable
  not targetObject = Value::named("None") and
  
  // Special case: exclude NotImplemented when used in raise statements
  not use_of_not_implemented_in_raise(_, calleeExpr)
select 
  invocation, 
  "Call to a $@ of $@.", 
  sourceNode, 
  "non-callable", 
  objectClass, 
  objectClass.toString()