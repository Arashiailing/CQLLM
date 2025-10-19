/**
 * @name Non-callable invoked
 * @description Detects code that attempts to invoke objects which are not callable,
 *              potentially causing TypeError exceptions at runtime.
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
  Call funcCall, 
  Value invokedObject, 
  ClassValue objectClass, 
  Expr callee, 
  AstNode originNode
where
  // Identify the expression being called
  callee = funcCall.getFunc() and
  
  // Resolve the callee to its actual value and origin
  callee.pointsTo(invokedObject, originNode) and
  
  // Determine the class of the invoked object
  objectClass = invokedObject.getClass() and
  
  // Ensure the object's class is not callable
  not objectClass.isCallable() and
  
  // Verify type inference was successful
  not objectClass.failedInference(_) and
  
  // Exclude descriptor objects that implement __get__
  // These can be callable via the descriptor protocol
  not objectClass.hasAttribute("__get__") and
  
  // Skip None values since they are explicitly non-callable
  not invokedObject = Value::named("None") and
  
  // Special handling: exclude NotImplemented when used in raise statements
  not use_of_not_implemented_in_raise(_, callee)
select 
  funcCall, 
  "Call to a $@ of $@.", 
  originNode, 
  "non-callable", 
  objectClass, 
  objectClass.toString()