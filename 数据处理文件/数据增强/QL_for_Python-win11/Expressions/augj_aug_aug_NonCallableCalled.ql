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
  Value calledObject, 
  ClassValue objectClass, 
  Expr calleeExpression, 
  AstNode originNode
where
  // Extract the callee expression from the invocation
  calleeExpression = callNode.getFunc() and
  
  // Resolve the callee expression to its target value and origin
  calleeExpression.pointsTo(calledObject, originNode) and
  
  // Obtain the class of the target object
  objectClass = calledObject.getClass() and
  
  // Verify the object's class is not callable
  not objectClass.isCallable() and
  
  // Ensure type inference was successful
  not objectClass.failedInference(_) and
  
  // Exclude descriptor objects with __get__ method
  // (These might be callable through descriptor protocol)
  not objectClass.hasAttribute("__get__") and
  
  // Exclude None values (explicitly non-callable)
  not calledObject = Value::named("None") and
  
  // Special case: exclude NotImplemented in raise statements
  not use_of_not_implemented_in_raise(_, calleeExpression)
select 
  callNode, 
  "Call to a $@ of $@.", 
  originNode, 
  "non-callable", 
  objectClass, 
  objectClass.toString()